import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/auction_model.dart';
import '../../../domain/usecases/auction_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class AuctionScreen extends ConsumerStatefulWidget {
  const AuctionScreen({super.key});

  @override
  ConsumerState<AuctionScreen> createState() => _AuctionScreenState();
}

class _AuctionScreenState extends ConsumerState<AuctionScreen> with SingleTickerProviderStateMixin {
  late AuctionModel _auction;
  List<UpcomingLotModel> _upcomingLots = [];
  Timer? _timer;
  bool _hasPlayerEnteredBid = false;
  bool _isHandlingAuctionEnd = false;
  bool _hasExtendedAuction = false;
  final List<String> _bidLogs = [];
  late AnimationController _pulseController;
  int _closedCountdown = 0;
  bool _isWindowOpen = true;
  bool _isOfficerConsulted = false;
  String? _officerSpeech;
  int _selectedTabIndex = 0; // 0: Canlı Müzayede Masası, 1: Müzayede Kataloğu (Gelecek Lotlar)

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);

    _isWindowOpen = AuctionEngine.isAuctionActiveNow();
    _closedCountdown = AuctionEngine.getSecondsUntilNextAuction();

    final game = ref.read(gameProvider);
    _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
    _upcomingLots = AuctionEngine.generateUpcomingLots(count: 3, playerLevel: game.level);

    _bidLogs.add('Gümrük ve Tasfiye İhale Seansı Başladı!');
    _bidLogs.add('Açılış Fiyatı: ${CurrencyFormatter.formatShort(_auction.startingPrice)}');
    _startAuctionTimer();
  }

  void _startAuctionTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final windowNow = AuctionEngine.isAuctionActiveNow();

      // Only transition to closed if not currently handling an active player round/dialog
      if (windowNow != _isWindowOpen) {
        if (windowNow || (!_isHandlingAuctionEnd && !_hasPlayerEnteredBid && _auction.secondsRemaining <= 0)) {
          setState(() {
            _isWindowOpen = windowNow;
            if (_isWindowOpen) {
              final game = ref.read(gameProvider);
              _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
              _upcomingLots = AuctionEngine.generateUpcomingLots(count: 3, playerLevel: game.level);
              _isOfficerConsulted = false;
              _officerSpeech = null;
            }
          });
        }
      }

      if (!_isWindowOpen) {
        final remaining = AuctionEngine.getSecondsUntilNextAuction();
        setState(() {
          _closedCountdown = remaining;
          if (remaining <= 0) {
            AuctionEngine.openSessionImmediately();
            _isWindowOpen = true;
            final game = ref.read(gameProvider);
            _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
            _upcomingLots = AuctionEngine.generateUpcomingLots(count: 3, playerLevel: game.level);
            _isOfficerConsulted = false;
            _officerSpeech = null;
          }
        });
        return;
      }

      if (_auction.secondsRemaining <= 1) {
        _timer?.cancel();
        if (_isHandlingAuctionEnd) return;
        _isHandlingAuctionEnd = true;

        setState(() {
          _auction = _auction.copyWith(secondsRemaining: 0, status: AuctionStatus.ended);
        });
        _handleAuctionEnd();
        return;
      }

      setState(() {
        _auction = _auction.copyWith(secondsRemaining: _auction.secondsRemaining - 1);
      });

      // Process rival bot bid
      final updated = AuctionEngine.processRivalBid(_auction);
      if (updated != null) {
        GameSoundHapticService.playAuctionBid();
        setState(() {
          _auction = updated;
          _bidLogs.insert(0, '${updated.highestBidderName} teklif yükseltti: ${CurrencyFormatter.formatShort(updated.currentBid)}');
        });
      }
    });
  }

  void _placePlayerBid(double increment, {bool isAggressiveFlag = false}) {
    if (_auction.isPlayerHighestBidder) {
      NotificationService.showInfo(context, 'En yüksek teklif zaten senin! Rakip teklif bekleniyor.');
      return;
    }

    final game = ref.read(gameProvider);
    if (game.ownedCars.length >= game.maxGarageSlots) {
      NotificationService.showError(context, 'Garajınız dolu! Yeni araç almadan önce mevcut araçlarınızı satmalı veya garajınızı genişletmelisiniz.');
      return;
    }

    final nextBid = _auction.currentBid + increment;

    if (game.balance < nextBid) {
      NotificationService.showError(context, 'Yetersiz Bakiye! Bu teklifi veremezsin.');
      return;
    }

    GameSoundHapticService.playAuctionBid();
    setState(() {
      _hasPlayerEnteredBid = true;
      _auction = _auction.copyWith(
        currentBid: nextBid,
        highestBidderName: '${game.dealershipName} • Sen',
        isPlayerHighestBidder: true,
        secondsRemaining: (_auction.secondsRemaining < 6) ? 7 : _auction.secondsRemaining,
        activeSpeech: isAggressiveFlag ? 'Bayrak kaldırdın! Rakipler tereddütte kaldı.' : null,
        activeSpeakerName: isAggressiveFlag ? game.dealershipName : null,
      );
      _bidLogs.insert(0, isAggressiveFlag ? 'AGRESİF BAYRAK TEKLİFİ: ${CurrencyFormatter.formatShort(nextBid)}' : 'SENİN TEKLİFİN: ${CurrencyFormatter.formatShort(nextBid)}');
    });
  }

  void _executeTrollBluff() {
    if (_auction.isPlayerHighestBidder) {
      NotificationService.showWarning(context, 'Zaten lider teklif sende! Blöf için bir rakibin teklif vermesini beklemelisin.');
      return;
    }

    final activeRivals = _auction.rivals.where((r) => !r.isFolded).toList();
    if (activeRivals.isEmpty) {
      NotificationService.showInfo(context, 'Tüm rakipler çekildi, blöf yapacak rakip kalmadı!');
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
      dialogue = '$rName kibirle gülümsedi: "Bu masanın kralı benim, çekilin kenara!"';
      toastMsg = 'Baron Tuzağa Düştü! $rName aşırı yüksek teklif verip zarara girdi • +75 XP!';
      earnedXp = 75;
    } else if (rName.contains('Ferit') || rName.contains('Koleksiyoner')) {
      extraCounter = 20000.0;
      dialogue = '$rName heyecanla bayrak kaldırdı: "Koleksiyonumun baş tacı olacak!"';
      toastMsg = 'Koleksiyoner Kapıştı! $rName nadir parça uğruna bütçesini zorladı • +50 XP!';
      earnedXp = 50;
    } else if (rName.contains('Rıza') || rName.contains('Al-Sat')) {
      extraCounter = 5000.0;
      dialogue = '$rName tereddütle: "Bu son teklifim, daha kuruş çıkmaz benden!"';
      toastMsg = 'Al-Satçı Köşeye Sıkıştı! $rName kâr marjını kaybetti • +40 XP!';
    } else {
      dialogue = 'Blöfün tuttu! $rName fahiş fiyat verdi ve sen masadan ustaca çekildin.';
      toastMsg = 'Mükemmel Blöf! $rName araca fahiş fiyat ödemek zorunda kaldı • +40 XP!';
    }

    final bluffBid = _auction.currentBid + 20000.0;
    final counterBid = bluffBid + extraCounter;

    setState(() {
      _hasPlayerEnteredBid = false;
      _auction = _auction.copyWith(
        currentBid: counterBid,
        highestBidderName: targetRival.name,
        isPlayerHighestBidder: false,
        activeSpeech: dialogue,
        activeSpeakerName: targetRival.name,
        secondsRemaining: 3,
      );
      _bidLogs.insert(0, 'BLÖF HAMLESİ: $rName ${CurrencyFormatter.formatShort(counterBid)} teklifle tuzağa düştü!');
    });

    ref.read(gameProvider.notifier).addXP(earnedXp);
    NotificationService.showSuccess(context, toastMsg);
  }

  void _resetAuctionSilently() {
    _timer?.cancel();
    if (!mounted) return;
    final game = ref.read(gameProvider);
    final isNowOpen = AuctionEngine.isAuctionActiveNow();

    setState(() {
      _isHandlingAuctionEnd = false;
      _hasPlayerEnteredBid = false;
      _hasExtendedAuction = false;
      _isWindowOpen = isNowOpen;
      _closedCountdown = AuctionEngine.getSecondsUntilNextAuction();

      if (_isWindowOpen) {
        _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
        _upcomingLots = AuctionEngine.generateUpcomingLots(count: 3, playerLevel: game.level);
        _bidLogs.clear();
        _bidLogs.add('Yeni Araç İhale Masasında!');
        _bidLogs.add('Başlangıç Fiyatı: ${CurrencyFormatter.formatShort(_auction.startingPrice)}');
      }
    });

    _startAuctionTimer();
  }

  void _showTrunkLootDialog(TrunkLoot loot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: AppColors.brutalYellow,
            borderWidth: 2.5,
            borderRadius: 12,
            shadowOffset: const Offset(4, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Colors.black, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('auction_trunk_surprise'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  loot.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                ),
                const SizedBox(height: 6),
                Text(
                  loot.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                NeoBrutalBadge(
                  text: 'Kazanılan Değer: +${CurrencyFormatter.format(loot.value)}',
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 12,
                ),
                const SizedBox(height: 18),
                NeoBrutalButton(
                  label: context.tr('auction_loot_claim_btn'),
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fullWidth: true,
                  onPressed: () {
                    ref.read(gameProvider.notifier).addMoney(loot.value);
                    Navigator.of(ctx).pop();
                    if (mounted) {
                      NotificationService.showSuccess(context, '${CurrencyFormatter.format(loot.value)} kasaya eklendi!');
                      _resetAuctionSilently();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleAuctionEnd() {
    if (!_hasPlayerEnteredBid && !_auction.isPlayerHighestBidder) {
      setState(() {
        _bidLogs.insert(0, 'İhale sona erdi • ${_auction.highestBidderName} kazandı.');
      });
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) _resetAuctionSilently();
      });
      return;
    }

    if (_auction.isPlayerHighestBidder) {
      final success = ref.read(gameProvider.notifier).buyCarDirectly(_auction.car, _auction.currentBid);
      if (!success) {
        NotificationService.showError(context, 'İhale kazanıldı ancak bakiye veya garaj kapasitesi yetersiz olduğu için alım tamamlanamadı!');
        _resetAuctionSilently();
        return;
      }

      GameSoundHapticService.playCashSuccess();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.brutalGreen,
              borderWidth: 2.5,
              borderRadius: 12,
              shadowOffset: const Offset(4, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.brutalGreen,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('auction_won_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_auction.car.modelYear} ${_auction.car.brand} ${_auction.car.modelName} aracını ${CurrencyFormatter.formatShort(_auction.currentBid)} kelepir fiyata galerine ekledin!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalBadge(
                    text: 'Piyasa Değeri: ${CurrencyFormatter.formatShort(_auction.estimatedMarketValue)}',
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalButton(
                    label: context.tr('auction_trunk_btn'),
                    icon: Icons.card_giftcard_rounded,
                    backgroundColor: AppColors.brutalOrange,
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (mounted) {
                        _showTrunkLootDialog(_auction.customsNote.trunkLoot);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalButton(
                    label: context.tr('auction_to_showroom_btn'),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (mounted) {
                        _resetAuctionSilently();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Dialog(
            backgroundColor: Colors.transparent,
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.errorRed,
              borderWidth: 2.5,
              borderRadius: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    context.tr('auction_lost_title'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_auction.highestBidderName} seni ${CurrencyFormatter.formatShort(_auction.currentBid)} teklifle sadece kıl payı geçti!\nBir sonraki turda fırsatı kaçırma.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 18),
                  if (!_hasExtendedAuction) ...[
                    NeoBrutalButton(
                      label: context.tr('auction_extend_btn'),
                      icon: Icons.access_time_filled_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 11,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        AdService.instance.showRewardedAdWithFallback(
                          context: context,
                          customRewardTitle: 'Gümrük Ekstra Süre İntikali',
                          onRewardEarned: () {
                            setState(() {
                              _isHandlingAuctionEnd = false;
                              _hasExtendedAuction = true;
                              _auction = _auction.copyWith(
                                secondsRemaining: 15,
                                status: AuctionStatus.active,
                              );
                              _startAuctionTimer();
                            });
                            NotificationService.showSuccess(
                              context,
                              'Gümrük memuru çekici masaya vurdu! Seans 15 saniye uzatıldı.',
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                  NeoBrutalButton(
                    label: 'SONRAKİ İHALEYE BAK',
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      if (mounted) {
                        _resetAuctionSilently();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  bool _isVipSession = false;

  void _switchToVipAuction() {
    final game = ref.read(gameProvider);
    if (game.level < 5) {
      NotificationService.showWarning(context, 'VIP Müzayede Kulübü Seviye 5 ve üzeri galerilere özeldir.');
      return;
    }
    if (game.balance < 500000) {
      NotificationService.showWarning(context, 'VIP Müzayedeye katılmak için en az ₺500.000 teminat bakiyesi gereklidir.');
      return;
    }

    setState(() {
      _isVipSession = true;
      _selectedTabIndex = 1;
      _auction = AuctionEngine.createVipAuction(playerLevel: game.level);
      _bidLogs.clear();
      _bidLogs.add('VIP Kapalı Devre Protokol Müzayedesi Başladı!');
      _bidLogs.add('Açılış Fiyatı: ${CurrencyFormatter.formatShort(_auction.startingPrice)}');
      _hasPlayerEnteredBid = false;
      _hasExtendedAuction = false;
      _isHandlingAuctionEnd = false;
    });
    _startAuctionTimer();
  }

  void _switchToStandardAuction() {
    final game = ref.read(gameProvider);
    setState(() {
      _isVipSession = false;
      _selectedTabIndex = 0;
      _auction = AuctionEngine.createLiveAuction(playerLevel: game.level);
      _bidLogs.clear();
      _bidLogs.add('Gümrük ve Tasfiye İhale Seansı Başladı!');
      _bidLogs.add('Açılış Fiyatı: ${CurrencyFormatter.formatShort(_auction.startingPrice)}');
      _hasPlayerEnteredBid = false;
      _hasExtendedAuction = false;
      _isHandlingAuctionEnd = false;
    });
    _startAuctionTimer();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    if (!game.isFeatureUnlocked('/auction')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
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
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('auction_title')),
        body: _buildLowReputationLockedView(isDark, game.reputationScore),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: _isVipSession ? context.tr('auction_vip_title') : context.tr('auction_title'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: _isVipSession ? 'VIP PROTOKOL' : (_isWindowOpen ? context.tr('auction_live_badge') : context.tr('auction_closed_badge')),
                backgroundColor: _isVipSession ? const Color(0xFF7C3AED) : (_isWindowOpen ? AppColors.errorRed : const Color(0xFF64748B)),
                textColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: !_isWindowOpen
          ? _buildClosedWindowView(isDark)
          : Column(
              children: [
                // Top 3-Way Tab Selector
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141721) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _switchToStandardAuction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 0
                                  ? (isDark ? AppColors.brutalOrange : AppColors.brutalYellow)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.gavel_rounded, size: 13, color: _selectedTabIndex == 0 ? Colors.black : (isDark ? Colors.white70 : Colors.black87)),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('auction_tab_customs'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _selectedTabIndex == 0 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: _switchToVipAuction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 1
                                  ? const Color(0xFF7C3AED)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.stars_rounded, size: 13, color: _selectedTabIndex == 1 ? Colors.white : const Color(0xFFA855F7)),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('auction_tab_vip'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _selectedTabIndex == 1 ? Colors.white : (isDark ? const Color(0xFFA855F7) : const Color(0xFF7C3AED)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedTabIndex = 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: _selectedTabIndex == 2
                                  ? (isDark ? AppColors.brutalOrange : AppColors.brutalYellow)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.list_alt_rounded, size: 13, color: _selectedTabIndex == 2 ? Colors.black : (isDark ? Colors.white70 : Colors.black87)),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr('auction_tab_catalog', {'count': '${_upcomingLots.length}'}),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _selectedTabIndex == 2 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
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
                      ? _buildLiveAuctionTab(isDark)
                      : _buildUpcomingCatalogTab(isDark),
                ),
              ],
            ),
    );
  }

  Widget _buildLiveAuctionTab(bool isDark) {
    final car = _auction.car;
    final isLastSeconds = _auction.secondsRemaining <= 5 && _auction.secondsRemaining > 0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. 3-STAGE GAVEL & FOMO TIMER BANNER
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isLastSeconds
              ? AppColors.errorRed.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF141721) : Colors.white),
          borderColor: isLastSeconds ? AppColors.errorRed : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
          borderRadius: 14,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLastSeconds ? AppColors.errorRed : AppColors.brutalYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          Icons.gavel_rounded,
                          color: isLastSeconds ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _auction.gavelCallText,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isLastSeconds ? AppColors.errorRed : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            'Kalan Süre: ${_auction.secondsRemaining} Saniye',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (isLastSeconds)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: 1.0 + (_pulseController.value * 0.15),
                          child: NeoBrutalBadge(
                            text: context.tr('auction_gavel_strike'),
                            backgroundColor: AppColors.errorRed,
                            textColor: Colors.white,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 1.1 CUSTOMS ANNOTATION & OFFICIAL REPORT
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.brutalOrange, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _auction.customsNote.originOffice,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: _auction.customsNote.legalStatus,
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Text('Ekspertiz Şerhi: ', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                  Expanded(
                    child: Text(
                      _auction.customsNote.riskRewardFactor,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. MONOLITHIC CAR DETAIL CARD
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.brand} ${car.modelName}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${car.modelYear} • ${car.expertise.mileage} KM • ${car.bodyType}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  NeoBrutalBadge(
                    text: context.tr('auction_market_est', {'price': CurrencyFormatter.formatShort(_auction.estimatedMarketValue)}),
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('auction_highest_bid_label'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatShort(_auction.currentBid),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr('auction_bidder_label'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        NeoBrutalBadge(
                          text: _auction.highestBidderName,
                          backgroundColor: _auction.isPlayerHighestBidder
                              ? AppColors.brutalGreen
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          textColor: _auction.isPlayerHighestBidder
                              ? Colors.black
                              : (isDark ? Colors.white : Colors.black),
                          fontSize: 10.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2.1 DYNAMIC RIVAL SPEECH BUBBLE
        if (_auction.activeSpeech != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brutalYellow.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brutalYellow, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.brutalYellow, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_auction.activeSpeakerName ?? "Salondan Biri"}: "${_auction.activeSpeech}"',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),

        // 3. QUICK BID BUTTONS & AGGRESSIVE FLAG BID
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('auction_quick_bids'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_auction.isPlayerHighestBidder)
                    NeoBrutalBadge(
                      text: context.tr('auction_leader_you'),
                      icon: Icons.workspace_premium_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 10,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: '+₺5.000',
                      backgroundColor: _auction.isPlayerHighestBidder
                          ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                          : AppColors.brutalYellow,
                      textColor: _auction.isPlayerHighestBidder
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: _auction.isPlayerHighestBidder ? null : () => _placePlayerBid(5000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: '+₺15.000',
                      backgroundColor: _auction.isPlayerHighestBidder
                          ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                          : AppColors.brutalOrange,
                      textColor: _auction.isPlayerHighestBidder
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: _auction.isPlayerHighestBidder ? null : () => _placePlayerBid(15000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: '+₺30.000',
                      backgroundColor: _auction.isPlayerHighestBidder
                          ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                          : AppColors.brutalGreen,
                      textColor: _auction.isPlayerHighestBidder
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: _auction.isPlayerHighestBidder ? null : () => _placePlayerBid(30000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      icon: Icons.flag_rounded,
                      label: context.tr('auction_btn_flag'),
                      backgroundColor: _auction.isPlayerHighestBidder
                          ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                          : const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: _auction.isPlayerHighestBidder ? null : () => _placePlayerBid(50000, isAggressiveFlag: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      icon: Icons.psychology_rounded,
                      label: context.tr('auction_btn_bluff'),
                      backgroundColor: _auction.isPlayerHighestBidder
                          ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                          : const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: _auction.isPlayerHighestBidder ? null : _executeTrollBluff,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 4. COMPETITORS / RIVALS
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('auction_rivals_title'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              ..._auction.rivals.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              r.isFolded ? Icons.close_rounded : Icons.person_rounded,
                              size: 15,
                              color: r.isFolded ? AppColors.errorRed : AppColors.brutalGreen,
                            ),
                            const SizedBox(width: 6),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.name,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: r.isFolded ? (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)) : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                                if (r.lastSpeech != null)
                                  Text(
                                    '"${r.lastSpeech}"',
                                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        NeoBrutalBadge(
                          text: r.isFolded ? 'Çekildi' : r.personality,
                          backgroundColor: r.isFolded
                              ? (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1))
                              : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                          textColor: r.isFolded ? (isDark ? Colors.white60 : Colors.black54) : (isDark ? Colors.white : Colors.black),
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 5. LIVE BIDDING LOGS
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('auction_live_stream_title'),
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              ..._bidLogs.take(5).map((log) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Text(
                      log,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: log.contains('SEN')
                            ? AppColors.brutalGreen
                            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569)),
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCatalogTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      physics: const BouncingScrollPhysics(),
      children: [
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.brutalYellow, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bu seansın ardından sırayla müzayede masasına çıkacak sonraki 3 araç listelenmektedir.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        ..._upcomingLots.map((lot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NeoBrutalBadge(
                        text: 'LOT #${lot.lotNumber}',
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10.5,
                      ),
                      NeoBrutalBadge(
                        text: 'Tahmini: ${CurrencyFormatter.formatShort(lot.estimatedMarketValue)}',
                        backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${lot.car.brand} ${lot.car.modelName}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${lot.car.modelYear} • ${lot.car.expertise.mileage} KM • ${lot.car.bodyType}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Başlangıç Fiyatı:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        Text(
                          CurrencyFormatter.formatShort(lot.startingPrice),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.gavel_rounded, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${lot.customsNote.legalStatus} • ${lot.customsNote.riskRewardFactor}',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildClosedWindowView(bool isDark) {
    final minutes = _closedCountdown ~/ 60;
    final seconds = _closedCountdown % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: AppColors.brutalYellow,
      strokeWidth: 2.5,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 350));
        if (mounted) {
          setState(() {
            _closedCountdown = AuctionEngine.getSecondsUntilNextAuction();
            _isWindowOpen = AuctionEngine.isAuctionActiveNow();
          });
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(22),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.lock_clock_rounded, color: AppColors.brutalOrange, size: 38),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('auction_closed_title'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gümrük ve hacizli araç ihale seansları kapalıdır. Yeni araç listeleri görevli memurlar tarafından tanzim edilmektedir.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                if (!_isOfficerConsulted) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brutalYellow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.support_agent_rounded, color: Colors.black, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Müzayede görevlisine danışarak bir sonraki ihale seansı vaktini öğrenebilirsiniz.',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalButton(
                    label: context.tr('auction_ask_officer_btn'),
                    icon: Icons.forum_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _isOfficerConsulted = true;
                        _officerSpeech = AuctionEngine.getRandomOfficerDialogue(timeStr);
                      });
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.brutalYellow.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.brutalYellow,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_rounded, color: AppColors.brutalYellow, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('auction_officer_label'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _officerSpeech ?? '',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Kalan Tahmini Süre: $timeStr',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeoBrutalButton(
                    label: context.tr('auction_reask_officer_btn'),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _officerSpeech = AuctionEngine.getRandomOfficerDialogue(timeStr);
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLowReputationLockedView(bool isDark, int repScore) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(24),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalOrange,
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.brutalOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.brutalOrange, width: 2),
                ),
                child: const Icon(Icons.lock_rounded, size: 42, color: AppColors.brutalOrange),
              ),
              const SizedBox(height: 16),
              const Text(
                'İHALE SALONU GİRİŞİ KİLİTLİ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Resmi devlet ve gümrük tasfiye ihalelerine katılabilmek için minimum 30 Esnaf İtibarı gereklidir.\n\nŞu anki İtibarınız: $repScore / 30',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              NeoBrutalButton(
                label: 'PAZARA GİT & İTİBAR KAZAN',
                icon: Icons.storefront_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 11.5,
                onPressed: () => context.push('/marketplace'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
