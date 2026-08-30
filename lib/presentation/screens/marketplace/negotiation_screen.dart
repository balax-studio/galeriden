import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/first_time_action_keys.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/notary_event_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/negotiation_suspense_engine.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/dialogs/notary_transfer_dialog.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import 'widgets/negotiation_action_buttons.dart';
import 'widgets/negotiation_dialogue_outcome_card.dart';
import 'widgets/negotiation_discrepancy_card.dart';
import 'widgets/negotiation_offer_dial_card.dart';
import 'widgets/negotiation_seller_profile_card.dart';
import 'widgets/negotiation_tactical_actions_bar.dart';

/// Full-Page Dedicated "Pazarlık Masası" (Live Deal Room Screen)
class NegotiationScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const NegotiationScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends ConsumerState<NegotiationScreen> {
  late double _offeredPrice;
  double? _agreedFinalPrice;
  String? _sellerResponse;
  bool _isAccepted = false;
  bool _isProcessing = false;
  bool _isThinking = false;
  String _thinkingText = '';
  int _counterOfferCount = 0;
  bool _isNearMiss = false;
  bool _isLockedOut = false;
  bool _hasRescuedWithTea = false;
  late CustomerModel _customer;
  late String _fomoText;
  int _bonusChancePercent = 0;
  late List<EsnafTactic> _dynamicTactics;
  final Set<String> _usedTacticIds = {};
  int _tacticUsageCount = 0;
  TacticRollOutcome? _lastTacticOutcome;
  bool _hasUsedHonestDiscount = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.loadRewardedAd();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _customer =
        CustomerModel.generateSellerFromListing(widget.listing.sellerName);
    _fomoText = PsychologyEngine.getRandomFomoText();
    _dynamicTactics = NegotiationEngine.generateTactics(
      isBuying: true,
      car: widget.listing.car,
      customer: _customer,
      price: widget.listing.askingPrice,
    );
  }

  int _calculateSuccessChance(int negotiationSkillLevel,
      {double decorBonusPercent = 0.0}) {
    final baseChance = NegotiationEngine.calculateMarketplaceBuyerSuccessChance(
      askingPrice: widget.listing.askingPrice,
      offeredPrice: _offeredPrice,
      negotiationSkillLevel: negotiationSkillLevel,
    );
    return (baseChance + _bonusChancePercent + decorBonusPercent.toInt())
        .clamp(5, 95);
  }

  void _snapToDiscount(double asking, double discountPercent) {
    if (_isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _offeredPrice = (asking * (1.0 - discountPercent)).roundToDouble();
    });
  }

  void _executeTactic(
      EsnafTactic tactic, CarModel car, double asking, DealershipModel game) {
    if (_usedTacticIds.contains(tactic.id) || _tacticUsageCount >= 3) {
      return;
    }
    if (_isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing) {
      return;
    }

    final outcome = NegotiationEngine.rollTactic(
      tactic: tactic,
      tacticUsageIndex: _tacticUsageCount,
      negotiationSkillLevel: game.skills.negotiationLevel,
      car: car,
      customer: _customer,
      isBuying: true,
      purchasedAcademyCourses: game.purchasedAcademyCourses,
      isTraderSpecialization:
          game.specializationPath == SpecializationPath.trader,
    );

    setState(() {
      _usedTacticIds.add(tactic.id);
      _tacticUsageCount++;
      _bonusChancePercent += outcome.bonusChance;
      _lastTacticOutcome = outcome;
      if (outcome.isWalkaway) {
        _isLockedOut = true;
        _sellerResponse = outcome.message;
      }
    });

    HapticFeedback.heavyImpact();
    if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(context, outcome.message);
    } else if (outcome.isSuccess) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(context,
          'Zar: ${outcome.diceRoll}/${outcome.threshold} • ${outcome.message}');
    } else {
      GameSoundHapticService.playTapImpact();
      NotificationService.showWarning(context,
          'Zar: ${outcome.diceRoll}/${outcome.threshold} • ${outcome.message}');
    }
  }

  Future<void> _handleSendOffer(int chancePercent) async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
      _isThinking = true;
      _counterOfferCount++;
    });

    final random = Random();
    final stages = NegotiationSuspenseEngine.getBuyingSuspenseStages(
      archetype: _customer.archetype,
      rng: random,
    );
    final durations =
        NegotiationSuspenseEngine.generateRandomStageDurations(rng: random);

    // Stage 1: Initial reaction & appraisal (800ms - 1300ms)
    setState(() => _thinkingText = stages[0]);
    HapticFeedback.selectionClick();
    await Future.delayed(Duration(milliseconds: durations[0]));
    if (!mounted) return;

    // Stage 2: Deep calculation & tension (1000ms - 1700ms)
    setState(() => _thinkingText = stages[1]);
    HapticFeedback.mediumImpact();
    GameSoundHapticService.playTapImpact();
    await Future.delayed(Duration(milliseconds: durations[1]));
    if (!mounted) return;

    // Stage 3: Final hesitation & decision posture (800ms - 1400ms)
    setState(() => _thinkingText = stages[2]);
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: durations[2]));
    if (!mounted) return;

    final roll = random.nextInt(100) + 1;
    if (roll <= chancePercent) {
      ref.read(gameProvider.notifier).checkAndAwardFirstTimeAction(
          FirstTimeActionKeys.firstNegotiationWin);
      GameSoundHapticService.playCashSuccess();
      setState(() {
        _isThinking = false;
        _isProcessing = false;
        _isAccepted = true;
        _agreedFinalPrice = _offeredPrice;
        _isNearMiss = false;
        switch (_customer.archetype) {
          case CustomerArchetype.skepticalOfficial:
            _sellerResponse = context.tr('deal_skeptical_accept');
            break;
          case CustomerArchetype.impatientYouth:
            _sellerResponse = context.tr('deal_impatient_accept');
            break;
          case CustomerArchetype.greedyFlipper:
            _sellerResponse = context.tr('deal_greedy_accept');
            break;
          case CustomerArchetype.familyMan:
            _sellerResponse = context.tr('deal_family_accept');
            break;
        }
      });
    } else {
      final isNear = roll <= chancePercent + 15;
      final isLocked = _counterOfferCount >= 3;
      GameSoundHapticService.playWarningVibration();
      setState(() {
        _isThinking = false;
        _isProcessing = false;
        _isAccepted = false;
        _isNearMiss = isNear;
        _isLockedOut = isLocked;
        if (isLocked) {
          _sellerResponse = context.tr('deal_seller_locked_resp');
        } else {
          switch (_customer.archetype) {
            case CustomerArchetype.skepticalOfficial:
              _sellerResponse = context.tr('deal_skeptical_reject');
              break;
            case CustomerArchetype.impatientYouth:
              _sellerResponse = context.tr('deal_impatient_reject');
              break;
            case CustomerArchetype.greedyFlipper:
              _sellerResponse = context.tr('deal_greedy_reject');
              break;
            case CustomerArchetype.familyMan:
              _sellerResponse = context.tr('deal_family_reject');
              break;
          }
        }
      });
    }
  }

  void _handlePayAndBuy(ListingModel currentListing, DealershipModel game) {
    if (game.ownedCars.length >= game.maxGarageSlots) {
      NotificationService.showError(
        context,
        context.tr('deal_garage_full_msg', {
          'current': game.ownedCars.length,
          'max': game.maxGarageSlots,
        }),
      );
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _isProcessing = true);
    final finalPayPrice = _agreedFinalPrice ?? _offeredPrice;
    final outcome = ref.read(gameProvider.notifier).buyCar(
          currentListing.car,
          finalPayPrice,
          isExpertiseCompleted: currentListing.isExpertiseCompleted,
        );
    if (outcome != null) {
      ref.read(marketProvider.notifier).removeListing(currentListing.id);

      if (outcome.isTrapped) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            child: NeoBrutalCard(
              backgroundColor:
                  isDark ? const Color(0xFF161922) : Colors.white,
              borderColor: isDark
                  ? const Color(0xFF333B4F)
                  : const Color(0xFF0F172A),
              borderWidth: 2.5,
              borderRadius: 16,
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: themeExt.palette.errorColor, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          outcome.title,
                          style: TextStyle(
                              color: themeExt.palette.errorColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    outcome.description,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  NeoBrutalButton(
                    label: context.tr('modal_understood'),
                    icon: Icons.check_circle_outline,
                    backgroundColor: const Color(0xFFFFDE59),
                    textColor: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/marketplace');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        NotaryTransferDialog.show(
          context: context,
          car: currentListing.car,
          buyerName: '${game.dealershipName} • ${game.playerName}',
          sellerName: currentListing.getLocalizedSellerName(context),
          salePrice: finalPayPrice,
          isBuying: true,
          eventResult: NotaryEventResult(
            type: NotaryEventType.smoothDeal,
            title: context.tr('notary_success_title'),
            description: context.tr('notary_success_desc'),
          ),
          onComplete: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/marketplace');
            }
          },
        );
      }
    }
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(marketProvider);
    final currentListing = listings.firstWhere(
      (l) => l.id == widget.listing.id,
      orElse: () => widget.listing,
    );
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final asking = currentListing.askingPrice;
    final decorBonus =
        game.hasDecor('decor_leather_chair_desk') ? 4.0 : 0.0;
    final chancePercent = _calculateSuccessChance(
      game.skills.negotiationLevel,
      decorBonusPercent: decorBonus,
    );

    final isLocked = _isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('deal_negotiation_table'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: context.tr('deal_status_live'),
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1 & 2: Seller Profile & Vehicle Summary
              NegotiationSellerProfileCard(
                listing: currentListing,
                customer: _customer,
                fomoText: _fomoText,
                counterOfferCount: _counterOfferCount,
                isDark: isDark,
              ),
              const SizedBox(height: 12),

              // 3: Offer Dial Card
              NegotiationOfferDialCard(
                offeredPrice: _offeredPrice,
                askingPrice: asking,
                chancePercent: chancePercent,
                decorBonus: decorBonus,
                isDark: isDark,
                isLocked: isLocked,
                onPriceChanged: (newPrice) =>
                    setState(() => _offeredPrice = newPrice),
                onSnapDiscount: (discountPct) =>
                    _snapToDiscount(asking, discountPct),
              ),
              const SizedBox(height: 12),

              // 4: Tactical Esnaf Actions Bar
              if (_sellerResponse == null && !_isLockedOut) ...[
                NegotiationTacticalActionsBar(
                  dynamicTactics: _dynamicTactics,
                  usedTacticIds: _usedTacticIds,
                  tacticUsageCount: _tacticUsageCount,
                  lastTacticOutcome: _lastTacticOutcome,
                  isDark: isDark,
                  isLocked: isLocked,
                  onExecuteTactic: (tactic) =>
                      _executeTactic(tactic, currentListing.car, asking, game),
                ),
                const SizedBox(height: 12),
              ],

              // 5 & 6: Thinking & Dialogue Outcome Card
              NegotiationDialogueOutcomeCard(
                isThinking: _isThinking,
                thinkingText: _thinkingText,
                sellerResponse: _sellerResponse,
                isAccepted: _isAccepted,
                customerName: _customer.name,
                isNearMiss: _isNearMiss,
                isLockedOut: _isLockedOut,
                hasRescuedWithTea: _hasRescuedWithTea,
                isDark: isDark,
                onTeaRescue: () {
                  setState(() {
                    _isLockedOut = false;
                    _hasRescuedWithTea = true;
                    _counterOfferCount = 1;
                    _sellerResponse = null;
                    _isNearMiss = false;
                  });
                },
              ),

              // 7: Discrepancy & Leverage Card
              if (_sellerResponse == null &&
                  currentListing.isExpertiseCompleted) ...[
                NegotiationDiscrepancyCard(
                  listing: currentListing,
                  customer: _customer,
                  negotiationSkillLevel: game.skills.negotiationLevel,
                  hasUsedHonestDiscount: _hasUsedHonestDiscount,
                  isDark: isDark,
                  isLocked: isLocked,
                  onUseHonestDiscount: () {
                    setState(() {
                      _hasUsedHonestDiscount = true;
                      _bonusChancePercent += 10;
                      _sellerResponse =
                          context.tr('deal_honest_seller_resp');
                    });
                  },
                  onBluffResult: (isSuccess, targetDiscPrice, response) {
                    setState(() {
                      if (isSuccess) {
                        _offeredPrice = targetDiscPrice;
                        _agreedFinalPrice = targetDiscPrice;
                        _isAccepted = true;
                      } else {
                        _isAccepted = false;
                      }
                      _sellerResponse = response;
                    });
                  },
                  onDefectStrikeResult: (targetDiscPrice, response) {
                    setState(() {
                      _offeredPrice = targetDiscPrice;
                      _agreedFinalPrice = targetDiscPrice;
                      _isAccepted = true;
                      _sellerResponse = response;
                    });
                  },
                ),
              ],

              // 8: Monolithic Action Buttons
              NegotiationActionButtons(
                sellerResponse: _sellerResponse,
                isAccepted: _isAccepted,
                isLockedOut: _isLockedOut,
                isThinking: _isThinking,
                isProcessing: _isProcessing,
                offeredPrice: _offeredPrice,
                agreedFinalPrice: _agreedFinalPrice,
                counterOfferCount: _counterOfferCount,
                canAfford: game.balance >= (_agreedFinalPrice ?? _offeredPrice),
                isDark: isDark,
                onSendOffer: () => _handleSendOffer(chancePercent),
                onPayAndBuy: () => _handlePayAndBuy(currentListing, game),
                onReviseOffer: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _sellerResponse = null;
                    _isProcessing = false;
                    _isThinking = false;
                    _isNearMiss = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
