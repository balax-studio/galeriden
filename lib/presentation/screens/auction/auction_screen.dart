import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/auction_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../domain/usecases/auction_engine.dart';
import '../../providers/auction_session_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import 'widgets/auction_closed_window_view.dart';
import 'widgets/auction_hammer_result_modal.dart';
import 'widgets/auction_live_bidding_view.dart';
import 'widgets/auction_low_rep_view.dart';
import 'widgets/auction_trunk_loot_dialog.dart';
import 'widgets/auction_upcoming_catalog_tab.dart';
import 'widgets/auction_sell_tab.dart';

class AuctionScreen extends ConsumerStatefulWidget {
  const AuctionScreen({super.key});

  @override
  ConsumerState<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends ConsumerState<AuctionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedTabIndex = 0;
  bool _isAuctionInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isAuctionInitialized) {
      _isAuctionInitialized = true;
      final notifier = ref.read(auctionSessionProvider.notifier);
      final auction = ref.read(auctionSessionProvider).auction;
      notifier.addBidLog(context.tr('auction_starting_price_log', {
        'price': CurrencyFormatter.formatShort(auction.startingPrice),
      }));
      notifier.addBidLog(context.tr('auction_session_started'));
    }
  }

  @override
  void initState() {
    super.initState();
    AdService.instance.loadRewardedAd();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  void _placePlayerBid(double increment, {bool isAggressiveFlag = false}) {
    final auctionState = ref.read(auctionSessionProvider);
    final auction = auctionState.auction;

    if (auction.isPlayerHighestBidder) {
      NotificationService.showInfo(
          context, context.tr('auction_highest_bid_yours'));
      return;
    }

    final game = ref.read(gameProvider);
    if (game.ownedCars.length >= game.maxGarageSlots) {
      NotificationService.showError(
          context, context.tr('auction_garage_full_err'));
      return;
    }

    final nextBid = auction.currentBid + increment;

    if (game.balance < nextBid) {
      NotificationService.showError(
          context, context.tr('deal_insufficient_balance'));
      return;
    }

    final wasLateBid = auction.secondsRemaining <= 5;
    final nextSeconds = wasLateBid
        ? math.min(auction.secondsRemaining + 15, 60)
        : auction.secondsRemaining;
    final extensions = wasLateBid
        ? auction.antiSnipingCount + 1
        : auction.antiSnipingCount;

    GameSoundHapticService.playAuctionBid();
    ref
        .read(gameProvider.notifier)
        .updateMissionProgress(MissionType.auctionBid, 1);

    final bidLogText = isAggressiveFlag
        ? context.tr('auction_aggressive_flag_bid',
            {'price': CurrencyFormatter.formatShort(nextBid)})
        : context.tr('auction_your_bid_log',
            {'price': CurrencyFormatter.formatShort(nextBid)});

    ref.read(auctionSessionProvider.notifier).recordPlayerBid(
          nextBid: nextBid,
          highestBidderName:
              '${game.dealershipName} • ${context.tr('profile_player_suffix')}',
          nextSeconds: nextSeconds,
          antiSnipingCount: extensions,
          wasLateBid: wasLateBid,
          speech: isAggressiveFlag ? context.tr('auction_flag_raised_speech') : null,
          speakerName: isAggressiveFlag ? game.dealershipName : null,
          bidLogText: bidLogText,
        );

    if (wasLateBid) {
      HapticFeedback.heavyImpact();
      NotificationService.showWarning(
        context,
        context.tr('auction_anti_sniping_alert', {'sec': '15'}),
      );
    }
  }

  void _executeTrollBluff() {
    final auctionState = ref.read(auctionSessionProvider);
    final auction = auctionState.auction;

    if (auctionState.hasBluffedInCurrentAuction) {
      NotificationService.showWarning(
          context, context.tr('auction_bluff_already_used'));
      return;
    }

    if (auction.isPlayerHighestBidder) {
      NotificationService.showWarning(
          context, context.tr('auction_already_leading'));
      return;
    }

    final activeRivals = auction.rivals.where((r) => !r.isFolded).toList();
    if (activeRivals.isEmpty) {
      NotificationService.showInfo(context, context.tr('auction_all_folded'));
      return;
    }

    final targetRival = activeRivals.first;
    final rName = targetRival.name;
    double extraCounter = 10000.0;
    String dialogue;
    String toastMsg;
    int earnedXp = 40;

    if (rName.contains('Baron') || rName.contains('Selim')) {
      extraCounter = 35000.0;
      dialogue = context.tr('auction_baron_speech', {'name': rName});
      toastMsg = context.tr('auction_baron_trapped', {'name': rName});
      earnedXp = 75;
    } else if (rName.contains('Ferit') || rName.contains('Koleksiyoner')) {
      extraCounter = 20000.0;
      dialogue = context.tr('auction_collector_speech', {'name': rName});
      toastMsg = context.tr('auction_collector_trapped', {'name': rName});
      earnedXp = 50;
    } else if (rName.contains('Rıza') || rName.contains('Al-Sat')) {
      extraCounter = 5000.0;
      dialogue = context.tr('auction_flipper_speech', {'name': rName});
      toastMsg = context.tr('auction_flipper_trapped', {'name': rName});
    } else {
      dialogue = context.tr('auction_bluff_success', {'name': rName});
      toastMsg = context.tr('auction_bluff_toast', {'name': rName});
    }

    final bluffBid = auction.currentBid + 20000.0;
    final counterBid = bluffBid + extraCounter;

    ref.read(auctionSessionProvider.notifier).recordBluff(
          counterBid: counterBid,
          rivalName: targetRival.name,
          dialogue: dialogue,
          logText: context.tr('auction_bluff_move_log', {
            'name': rName,
            'price': CurrencyFormatter.formatShort(counterBid),
          }),
        );

    ref.read(gameProvider.notifier).addXP(earnedXp);
    NotificationService.showSuccess(context, toastMsg);
  }

  void _resetAuctionSilently() {
    if (!mounted) return;
    final game = ref.read(gameProvider);
    final notifier = ref.read(auctionSessionProvider.notifier);
    notifier.resetRound(playerLevel: game.level);
    notifier.addBidLog(context.tr('auction_starting_price_log', {
      'price': CurrencyFormatter.formatShort(ref.read(auctionSessionProvider).auction.startingPrice),
    }));
    notifier.addBidLog(context.tr('auction_new_car_table'));
  }

  void _showTrunkLootDialog(TrunkLoot loot) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AuctionTrunkLootDialog(
          loot: loot,
          onClaim: () {
            ref.read(gameProvider.notifier).addMoney(loot.value);
            Navigator.of(ctx).pop();
            if (mounted) {
              NotificationService.showSuccess(
                context,
                context.tr('auction_loot_added_to_vault', {
                  'amount': CurrencyFormatter.format(loot.value),
                }),
              );
              _resetAuctionSilently();
            }
          },
        );
      },
    );
  }

  void _handleAuctionEnd(AuctionSessionState auctionState) {
    final auction = auctionState.auction;
    final notifier = ref.read(auctionSessionProvider.notifier);

    if (!auctionState.hasPlayerEnteredBid && !auction.isPlayerHighestBidder) {
      notifier.addBidLog(
        context.tr('auction_ended_winner', {'winner': auction.highestBidderName}),
      );
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _resetAuctionSilently();
      });
      return;
    }

    if (auction.isPlayerHighestBidder) {
      final success = ref
          .read(gameProvider.notifier)
          .buyCarDirectly(auction.car, auction.currentBid);
      if (!success) {
        NotificationService.showError(
            context, context.tr('auction_win_failed_funds'));
        _resetAuctionSilently();
        return;
      }

      GameSoundHapticService.playCashSuccess();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AuctionWonDialog(
            auction: auction,
            onOpenTrunk: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                _showTrunkLootDialog(auction.customsNote.trunkLoot);
              }
            },
            onGoToShowroom: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                _resetAuctionSilently();
              }
            },
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return AuctionLostDialog(
            auction: auction,
            hasExtendedAuction: auctionState.hasExtendedAuction,
            hasPlayerEnteredBid: auctionState.hasPlayerEnteredBid,
            onExtendAuction: () {
              notifier.extendAuction();
            },
            onNextAuction: () {
              Navigator.of(ctx).pop();
              if (mounted) {
                _resetAuctionSilently();
              }
            },
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _switchToVipAuction() {
    final game = ref.read(gameProvider);
    if (game.level < 5) {
      NotificationService.showWarning(
          context, context.tr('auction_vip_level_warn'));
      return;
    }
    if (game.balance < 500000) {
      NotificationService.showWarning(
          context, context.tr('auction_vip_deposit_warn'));
      return;
    }

    AdService.instance.showRewardedAdWithFallback(
      context: context,
      customRewardTitle: context.tr('auction_vip_ad_reward'),
      onRewardEarned: () {
        setState(() => _selectedTabIndex = 1);
        final notifier = ref.read(auctionSessionProvider.notifier);
        final tempVip = AuctionEngine.createVipAuction(playerLevel: game.level);
        notifier.startVipAuction(
          playerLevel: game.level,
          startedLog: context.tr('auction_vip_session_started'),
          startingPriceLog: context.tr('auction_starting_price_log', {
            'price': CurrencyFormatter.formatShort(tempVip.startingPrice),
          }),
        );
      },
    );
  }

  void _switchToStandardAuction() {
    final game = ref.read(gameProvider);
    setState(() => _selectedTabIndex = 0);
    ref.read(auctionSessionProvider.notifier).startStandardAuction(playerLevel: game.level);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuctionSessionState>(auctionSessionProvider, (prev, next) {
      if (next.isHandlingAuctionEnd && !(prev?.isHandlingAuctionEnd ?? false)) {
        _handleAuctionEnd(next);
      }
    });

    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);
    final auctionState = ref.watch(auctionSessionProvider);

    if (!game.isFeatureUnlocked('/auction')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('auction_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/auction',
          featureTitle: context.tr('auction_title'),
          icon: Icons.gavel_rounded,
        ),
      );
    }

    if (game.reputationScore < 30) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('auction_title')),
        body: AuctionLowReputationView(
          isDark: isDark,
          reputationScore: game.reputationScore,
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: auctionState.isVipSession
            ? context.tr('auction_vip_title')
            : context.tr('auction_title'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: auctionState.isVipSession
                    ? context.tr('auction_badge_vip')
                    : (auctionState.isWindowOpen
                        ? context.tr('auction_live_badge')
                        : context.tr('auction_closed_badge')),
                backgroundColor: auctionState.isVipSession
                    ? const Color(0xFF7C3AED)
                    : (auctionState.isWindowOpen
                        ? AppColors.errorRed
                        : const Color(0xFF64748B)),
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: !auctionState.isWindowOpen
          ? AuctionClosedWindowView(
              isDark: isDark,
              closedCountdown: auctionState.closedCountdown,
              isOfficerConsulted: auctionState.isOfficerConsulted,
              officerSpeech: auctionState.officerSpeech,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                await Future.delayed(const Duration(milliseconds: 350));
                if (mounted) {
                  ref.read(auctionSessionProvider.notifier).refreshWindow();
                }
              },
              onConsultOfficer: (speech) {
                ref.read(auctionSessionProvider.notifier).consultOfficer(speech);
              },
            )
          : Column(
              children: [
                // Top 3-Way Tab Selector (Neo-Brutalist Monolithic Bar)
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141721) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF0F172A),
                        offset: Offset(2.5, 2.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Tab 0: GÜMRÜK
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _switchToStandardAuction();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? AppColors.brutalYellow
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _selectedTabIndex == 0
                                  ? Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 1.5,
                                    )
                                  : null,
                              boxShadow: _selectedTabIndex == 0
                                  ? const [
                                      BoxShadow(
                                        color: Color(0xFF0F172A),
                                        offset: Offset(1.5, 1.5),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.gavel_rounded,
                                    size: 14,
                                    color: _selectedTabIndex == 0
                                        ? Colors.black
                                        : (isDark
                                            ? Colors.white60
                                            : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('auction_tab_customs'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                      color: _selectedTabIndex == 0
                                          ? Colors.black
                                          : (isDark
                                              ? Colors.white70
                                              : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Tab 1: VIP SALON
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _switchToVipAuction();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? const Color(0xFFA855F7)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _selectedTabIndex == 1
                                  ? Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 1.5,
                                    )
                                  : null,
                              boxShadow: _selectedTabIndex == 1
                                  ? const [
                                      BoxShadow(
                                        color: Color(0xFF0F172A),
                                        offset: Offset(1.5, 1.5),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 14,
                                    color: _selectedTabIndex == 1
                                        ? Colors.black
                                        : const Color(0xFFA855F7),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('auction_tab_vip'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                      color: _selectedTabIndex == 1
                                          ? Colors.black
                                          : (isDark
                                              ? const Color(0xFFA855F7)
                                              : const Color(0xFF7C3AED)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Tab 2: KATALOG
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTabIndex = 2);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 2
                                  ? const Color(0xFF38BDF8)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _selectedTabIndex == 2
                                  ? Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 1.5,
                                    )
                                  : null,
                              boxShadow: _selectedTabIndex == 2
                                  ? const [
                                      BoxShadow(
                                        color: Color(0xFF0F172A),
                                        offset: Offset(1.5, 1.5),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.list_alt_rounded,
                                    size: 14,
                                    color: _selectedTabIndex == 2
                                        ? Colors.black
                                        : (isDark
                                            ? Colors.white60
                                            : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('auction_tab_catalog', {
                                      'count': '${auctionState.upcomingLots.length}',
                                    }),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                      color: _selectedTabIndex == 2
                                          ? Colors.black
                                          : (isDark
                                              ? Colors.white70
                                              : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Tab 3: ARACIMI SAT
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedTabIndex = 3);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 3
                                  ? AppColors.brutalGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: _selectedTabIndex == 3
                                  ? Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 1.5,
                                    )
                                  : null,
                              boxShadow: _selectedTabIndex == 3
                                  ? const [
                                      BoxShadow(
                                        color: Color(0xFF0F172A),
                                        offset: Offset(1.5, 1.5),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sell_rounded,
                                    size: 13,
                                    color: _selectedTabIndex == 3
                                        ? Colors.black
                                        : (isDark
                                            ? Colors.white60
                                            : const Color(0xFF64748B)),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    context.tr('auction_sell_tab'),
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                      color: _selectedTabIndex == 3
                                          ? Colors.black
                                          : (isDark
                                              ? Colors.white70
                                              : const Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: (_selectedTabIndex == 0 || _selectedTabIndex == 1)
                      ? AuctionLiveBiddingView(
                          auction: auctionState.auction,
                          bidLogs: auctionState.bidLogs,
                          isDark: isDark,
                          playerBalance: game.balance,
                          hasPlayerEnteredBid: auctionState.hasPlayerEnteredBid,
                          onPlaceBid: _placePlayerBid,
                          onBluff: _executeTrollBluff,
                        )
                      : (_selectedTabIndex == 2
                          ? AuctionUpcomingCatalogTab(
                              upcomingLots: auctionState.upcomingLots,
                              isDark: isDark,
                            )
                          : AuctionSellTab(
                              isDark: isDark,
                            )),
                ),
              ],
            ),
    );
  }
}
