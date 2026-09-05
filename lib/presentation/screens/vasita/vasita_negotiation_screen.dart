import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/vehicle_category.dart';
import '../../../domain/usecases/vasita_negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/vasita_market_provider.dart';
import '../../providers/vasita_negotiation_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import 'widgets/noter_transfer_dialog.dart';

class VasitaNegotiationScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const VasitaNegotiationScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<VasitaNegotiationScreen> createState() =>
      _VasitaNegotiationScreenState();
}

class _VasitaNegotiationScreenState
    extends ConsumerState<VasitaNegotiationScreen> {
  bool _isInspectionExpanded = false;
  int _remainingSeconds = 180;
  int _viewerCount = 8;
  int _inquiryCount = 3;
  int _currentThinkingStepIndex = 0;
  int _totalThinkingSteps = 4;
  Timer? _countdownTimer;
  Timer? _viewerPulseTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });

    _viewerPulseTimer = Timer.periodic(const Duration(seconds: 7), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final rng = Random();
      setState(() {
        _viewerCount = 6 + rng.nextInt(7);
        _inquiryCount = 1 + rng.nextInt(4);
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _viewerPulseTimer?.cancel();
    super.dispose();
  }

  void _resetToAskingPrice() {
    HapticFeedback.selectionClick();
    ref.read(vasitaNegotiationProvider(widget.listing).notifier).resetToAskingPrice();
  }

  void _executeTactic(VasitaTactic tactic) {
    final notifier = ref.read(vasitaNegotiationProvider(widget.listing).notifier);
    final outcome = notifier.executeTactic(tactic);
    if (outcome == null) return;

    HapticFeedback.heavyImpact();
    if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(context, outcome.message);
    } else if (outcome.isSuccess) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(
        context,
        '${tactic.title} • ${context.tr('vasita_tactic_success_toast')}',
      );
    } else {
      GameSoundHapticService.playTapImpact();
      NotificationService.showWarning(
        context,
        '${tactic.title} • ${context.tr('vasita_tactic_failed_toast')}',
      );
    }
  }

  Future<void> _submitOffer() async {
    final currentState = ref.read(vasitaNegotiationProvider(widget.listing));
    if (currentState.isAccepted || currentState.isWalkaway || currentState.isProcessing) return;

    final notifier = ref.read(vasitaNegotiationProvider(widget.listing).notifier);
    notifier.setProcessing(true);
    HapticFeedback.mediumImpact();

    // Vehicle-specific contextual thinking steps and extended realistic suspense
    final steps = VasitaNegotiationEngine.getThinkingStepsForListing(widget.listing);
    final stepDurationMs = VasitaNegotiationEngine.getThinkingStepDurationMs(widget.listing);

    setState(() {
      _totalThinkingSteps = steps.length;
      _currentThinkingStepIndex = 0;
    });

    for (int i = 0; i < steps.length; i++) {
      if (!mounted) return;
      setState(() => _currentThinkingStepIndex = i);
      notifier.setDialogue(context.tr(steps[i]));
      HapticFeedback.selectionClick();
      await Future.delayed(Duration(milliseconds: stepDurationMs));
    }
    if (!mounted) return;

    final outcome = notifier.evaluateOffer();

    if (outcome.isAccepted) {
      GameSoundHapticService.playCashSuccess();
      _showNoterTransferDialog();
    } else if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
    } else {
      GameSoundHapticService.playTapImpact();
    }
  }

  void _showNoterTransferDialog() {
    final game = ref.read(gameProvider);
    final offeredPrice = ref.read(vasitaNegotiationProvider(widget.listing)).offeredPrice;
    final noterFee = VasitaNegotiationEngine.calculateNoterFee(offeredPrice);
    const regFee = VasitaNegotiationEngine.registrationFee;
    final isGarageFull = game.ownedCars.length >= game.maxGarageSlots;

    NoterTransferDialog.show(
      context: context,
      car: widget.listing.car,
      buyerName: game.playerName,
      sellerName: widget.listing.sellerName,
      agreedPrice: offeredPrice,
      noterFee: noterFee,
      registrationFee: regFee,
      playerBalance: game.balance,
      isGarageFull: isGarageFull,
      onComplete: () {
        final success = ref.read(vasitaMarketProvider.notifier).buyVasitaNegotiated(
              listing: widget.listing,
              agreedPrice: offeredPrice,
              noterFee: noterFee,
              registrationFee: regFee,
            );

        if (success) {
          if (mounted) {
            NotificationService.showSuccess(
              context,
              context.tr('noter_buy_success_toast'),
            );
            ref.read(vasitaNegotiationProvider(widget.listing).notifier).completeHandover();
            _showHandoverConfirmationDialog();
          }
        } else {
          if (mounted) {
            NotificationService.showError(
              context,
              context.tr('noter_buy_error_funds'),
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final negState = ref.watch(vasitaNegotiationProvider(widget.listing));
    final car = widget.listing.car;
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final successChance = VasitaNegotiationEngine.calculateOfferSuccessProbability(
      listing: widget.listing,
      offeredPrice: negState.offeredPrice,
      patience: negState.sellerPatience,
      playerLevel: game.level,
      extraBonusPercent: negState.bonusChancePercent / 100.0,
    );

    final applicableTactics =
        VasitaNegotiationEngine.getTacticsForVehicle(car.vehicleCategory);

    final isGarageFull = game.ownedCars.length >= game.maxGarageSlots;

    return PopScope(
      canPop: !negState.isProcessing,
      child: Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr('vasita_negotiation_title'),
          subtitle: '${car.brand} ${car.modelName}',
          showLeading: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: NeoBrutalBadge(
                  text: CurrencyFormatter.formatShort(game.balance),
                  icon: Icons.account_balance_wallet_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        body: NeoBrutalPageBackground(
          watermark: ThematicWatermarkType.carWash,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 0. Dark Pattern FOMO & Live Ticking Timer
                _buildLiveViewerAndTimerBar(isDark),

                // 1. Vehicle & Seller Header Card
                _buildVehicleHeaderCard(car, isDark),
                const SizedBox(height: 10),

                // 2. Dark Pattern Artificial Urgency Alert
                _buildUrgencyAlertRibbon(car, isDark),

                // 3. Sunk-Cost Warning (if expertise completed)
                if (widget.listing.isExpertiseCompleted)
                  _buildSunkCostNotice(isDark),

                // 4. Inspection & Expertise Card
                _buildExpertiseCard(car, isDark),
                const SizedBox(height: 12),

                // 5. Seller Card with Patience, Obstinacy & Dialogue
                _buildSellerCard(negState, isDark),
                const SizedBox(height: 14),

                // 6. Dealer Tactics Section
                _buildTacticsSection(applicableTactics, negState, isDark),
                const SizedBox(height: 16),

                // 7. Near-Miss Psychological Feedback Banner
                if (negState.lastNearMissAmount != null && !negState.isAccepted && !negState.isWalkaway)
                  _buildNearMissCard(negState.lastNearMissAmount!, isDark),

                // 8. Offer & Slider Card
                _buildOfferControlCard(negState, successChance, isDark),
                const SizedBox(height: 14),

                // 9. Action Button
                _buildActionButton(negState, isGarageFull, game.balance, isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHandoverConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 3),
        ),
        title: Text(
          context.tr('vasita_handover_dialog_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.listing.sellerName} • ${context.tr('vasita_handover_dialog_desc')}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00E575).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF00E575), width: 2),
              ),
              child: Text(
                context.tr('vasita_handover_market_cleaned_notice'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.black),
              ),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: context.tr('vasita_seller_handover_market_btn'),
            backgroundColor: const Color(0xFFE2E8F0),
            textColor: Colors.black,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
            },
          ),
          NeoBrutalButton(
            label: context.tr('vasita_seller_handover_garage_btn'),
            backgroundColor: const Color(0xFF00E575),
            textColor: Colors.black,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.go('/inventory');
            },
          ),
        ],
      ),
    );
  }

  int _calculateObstinacyScore() {
    int score = 65;
    final trait = widget.listing.sellerTrait.toLowerCase();
    if (trait.contains('filo') ||
        trait.contains('koleksiyon') ||
        trait.contains('doktor') ||
        trait.contains('memur') ||
        trait.contains('esnaf')) {
      score += 15;
    } else if (trait.contains('acele') || trait.contains('ihtiyaç') || trait.contains('sıkışık')) {
      score -= 20;
    }
    if (widget.listing.car.expertise.engineCondition >= 80) {
      score += 8;
    }
    if (widget.listing.askingPrice >= 2000000) {
      score += 10;
    }
    return score.clamp(40, 99);
  }

  String _getUrgencyKey(CarModel car) {
    final cat = car.vehicleCategory;
    final bType = car.bodyType.toLowerCase();
    final brand = car.brand.toLowerCase();

    if (cat == VehicleCategory.commercial ||
        bType.contains('çekici') ||
        bType.contains('kamyon') ||
        bType.contains('tır') ||
        bType.contains('panelvan')) {
      return 'vasita_dark_urgency_comm';
    }
    if (car.isRare ||
        bType.contains('coupe') ||
        bType.contains('spor') ||
        bType.contains('cabrio')) {
      return 'vasita_dark_urgency_perf';
    }
    if (cat == VehicleCategory.classic || car.modelYear < 2000 || bType.contains('klasik')) {
      return 'vasita_dark_urgency_classic';
    }
    if (bType.contains('suv') || bType.contains('arazi') || brand.contains('jeep')) {
      return 'vasita_dark_urgency_suv';
    }
    return 'vasita_dark_urgency_std';
  }

  Widget _buildLiveViewerAndTimerBar(bool isDark) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeFormatted =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    final isUrgent = _remainingSeconds < 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUrgent ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          width: isUrgent ? 2.0 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.tr('vasita_dark_live_viewers', {
                    'count': '$_viewerCount',
                    'inquiry': '$_inquiryCount',
                  }),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isUrgent
                  ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 14,
                      color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _remainingSeconds > 0
                          ? context.tr('vasita_dark_timer_label')
                          : context.tr('vasita_dark_timer_expired'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isUrgent ? const Color(0xFFEF4444) : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
                if (_remainingSeconds > 0)
                  Text(
                    timeFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isUrgent ? const Color(0xFFEF4444) : const Color(0xFF00E575),
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyAlertRibbon(CarModel car, bool isDark) {
    final urgencyKey = _getUrgencyKey(car);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.campaign_rounded,
            size: 18,
            color: Color(0xFFF59E0B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr(urgencyKey),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleHeaderCard(CarModel car, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NeoBrutalBadge(
                text: context.tr(car.vehicleCategory.localizationKey),
                icon: Icons.directions_car_filled_rounded,
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white70 : Colors.black87,
                fontSize: 10,
              ),
              const SizedBox(width: 8),
              NeoBrutalBadge(
                text: car.plateNumber.isNotEmpty ? car.plateNumber : '34 GLR 101',
                icon: Icons.badge_rounded,
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                textColor: isDark ? Colors.white : Colors.black,
                fontSize: 10,
              ),
              const Spacer(),
              Text(
                '${widget.listing.sellerCity} • ${widget.listing.sellerName}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${car.modelYear} ${car.brand} ${car.modelName}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(
            '${car.bodyType} • ${car.expertise.mileage} KM',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('deal_seller_asking_price'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              Text(
                CurrencyFormatter.format(widget.listing.askingPrice),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseCard(CarModel car, bool isDark) {
    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.fact_check_rounded, size: 18, color: Color(0xFF00E575)),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('vasita_expertise_card_title'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _isInspectionExpanded = !_isInspectionExpanded),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isInspectionExpanded
                            ? context.tr('vasita_expertise_collapse')
                            : context.tr('vasita_expertise_expand'),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                      Icon(
                        _isInspectionExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Condition Gauge Indicators
          Row(
            children: [
              Expanded(
                child: _buildConditionGauge(
                  context.tr('vasita_expertise_engine'),
                  car.expertise.engineCondition,
                  Icons.speed_rounded,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildConditionGauge(
                  context.tr('vasita_expertise_transmission'),
                  car.expertise.transmissionCondition,
                  Icons.settings_rounded,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tramer & Odometer row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('vasita_expertise_tramer'),
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.expertise.tramerAmount > 0
                            ? CurrencyFormatter.format(car.expertise.tramerAmount.toDouble())
                            : context.tr('tramer_no_damage'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: car.expertise.tramerAmount > 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('noter_field_mileage'),
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.expertise.isMileageTampered
                            ? context.tr('vasita_expertise_mileage_tampered')
                            : context.tr('vasita_expertise_mileage_verified'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: car.expertise.isMileageTampered ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Detailed Bodywork Panels (when expanded)
          if (_isInspectionExpanded) ...[
            const SizedBox(height: 10),
            Text(
              context.tr('vasita_expertise_parts_title'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: car.expertise.bodyParts.entries.map((entry) {
                final partName = entry.key;
                final status = entry.value;

                Color tagColor;
                String statusLabel;
                switch (status) {
                  case PartStatus.original:
                    tagColor = const Color(0xFF10B981);
                    statusLabel = context.tr('vasita_expertise_paint_original');
                    break;
                  case PartStatus.painted:
                    tagColor = const Color(0xFFF59E0B);
                    statusLabel = context.tr('vasita_expertise_paint_local');
                    break;
                  case PartStatus.localPainted:
                    tagColor = const Color(0xFFA855F7);
                    statusLabel = context.tr('vasita_expertise_local_painted');
                    break;
                  case PartStatus.changed:
                  case PartStatus.damaged:
                    tagColor = const Color(0xFFEF4444);
                    statusLabel = context.tr('vasita_expertise_paint_replaced');
                    break;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: tagColor.withValues(alpha: 0.5), width: 1),
                  ),
                  child: Text(
                    '$partName • $statusLabel',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConditionGauge(
    String label,
    double value,
    IconData icon,
    bool isDark,
  ) {
    final color = value >= 75
        ? const Color(0xFF10B981)
        : (value >= 50 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              const Spacer(),
              Text(
                '%${value.toInt()}',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100.0).clamp(0.0, 1.0),
              backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSellerCard(VasitaNegotiationState negState, bool isDark) {
    Color patienceColor = const Color(0xFF10B981);
    if (negState.sellerPatience < 40) {
      patienceColor = const Color(0xFFEF4444);
    } else if (negState.sellerPatience < 70) {
      patienceColor = const Color(0xFFF59E0B);
    }

    final obstinacyScore = _calculateObstinacyScore();

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF3B82F6),
                child: const Icon(Icons.person_rounded, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.listing.sellerName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      '${widget.listing.sellerCity} • ${widget.listing.sellerTrait}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${context.tr('vasita_label_patience')}: %${negState.sellerPatience}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: patienceColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  SizedBox(
                    width: 70,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (negState.sellerPatience / 100.0).clamp(0.0, 1.0),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(patienceColor),
                        minHeight: 5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tok Satıcı Skoru (Obstinacy Gauge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_alt_rounded, size: 16, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.tr('vasita_dark_obstinacy_label')} %$obstinacyScore',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      Text(
                        context.tr('vasita_dark_obstinacy_desc'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: (obstinacyScore / 100.0).clamp(0.0, 1.0),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Thinking Step Indicator during active negotiation evaluation
          if (negState.isProcessing) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF3B82F6), width: 1),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_currentThinkingStepIndex + 1} / $_totalThinkingSteps',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: ((_currentThinkingStepIndex + 1) / _totalThinkingSteps).clamp(0.0, 1.0),
                        backgroundColor: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                        minHeight: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
          ],

          // Speech Bubble
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                width: 1.5,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  negState.isProcessing ? Icons.hourglass_bottom_rounded : Icons.chat_bubble_outline_rounded,
                  size: 16,
                  color: negState.isProcessing ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    negState.sellerDialogue,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                      color: negState.isProcessing
                          ? (isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8))
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTacticsSection(List<VasitaTactic> tactics, VasitaNegotiationState negState, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('vasita_tactics_header'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            if (negState.bonusChancePercent > 0)
              Text(
                '${context.tr('vasita_label_bonus_chance')}: +%${negState.bonusChancePercent}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10B981),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tactics.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final tactic = tactics[index];
              final isUsed = negState.usedTacticIds.contains(tactic.id);
              final canUse = !isUsed && !negState.isAccepted && !negState.isProcessing && (!negState.isWalkaway || tactic.isRescue);

              return GestureDetector(
                onTap: canUse ? () => _executeTactic(tactic) : null,
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUsed
                        ? (isDark ? const Color(0xFF0C0E14) : const Color(0xFFE2E8F0))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isUsed
                          ? (isDark ? const Color(0xFF1E293B) : const Color(0xFF94A3B8))
                          : (canUse ? const Color(0xFF00E575) : const Color(0xFF64748B)),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            tactic.isRescue ? Icons.local_cafe_rounded : Icons.flash_on_rounded,
                            size: 16,
                            color: tactic.isRescue ? const Color(0xFFF59E0B) : const Color(0xFF00E575),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUsed
                                  ? Colors.grey.withValues(alpha: 0.2)
                                  : const Color(0xFF00E575).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isUsed ? context.tr('vasita_tactic_used') : tactic.badgeText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: isUsed ? const Color(0xFF64748B) : const Color(0xFF00E575),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        tactic.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isUsed ? const Color(0xFF64748B) : (isDark ? Colors.white : Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOfferControlCard(VasitaNegotiationState negState, int successChance, bool isDark) {
    final askingPrice = widget.listing.askingPrice;
    final safeMax = askingPrice > 1000.0 ? askingPrice : 1000.0;
    final rawMin = (safeMax * 0.50).roundToDouble();
    final minOffer = rawMin < safeMax ? rawMin : (safeMax * 0.5);
    final maxOffer = safeMax;

    final remainingAttempts = (3 - negState.offerAttemptCount).clamp(0, 3);
    final isLastAttempt = remainingAttempts <= 1;

    final discount = (askingPrice - negState.offeredPrice).clamp(0.0, double.infinity);
    final estNoterFee = VasitaNegotiationEngine.calculateNoterFee(negState.offeredPrice) +
        VasitaNegotiationEngine.registrationFee;
    final netBenefit = discount - estNoterFee;

    return NeoBrutalCard(
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('vasita_label_your_offer'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isLastAttempt
                      ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                      : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isLastAttempt ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                child: Text(
                  context.tr('vasita_dark_remaining_attempts', {'remaining': '$remainingAttempts'}),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isLastAttempt ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                  ),
                ),
              ),
              Row(
                children: [
                  Text(
                    '${context.tr('vasita_label_success_chance')}: ',
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  Text(
                    '%$successChance',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: successChance >= 70
                          ? const Color(0xFF10B981)
                          : (successChance >= 40 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Offer Amount & Reset Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.format(negState.offeredPrice),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00E575),
                ),
              ),
              GestureDetector(
                onTap: _resetToAskingPrice,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    context.tr('vasita_btn_asking_price'),
                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00E575),
              inactiveTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              thumbColor: const Color(0xFF00E575),
              overlayColor: const Color(0xFF00E575).withValues(alpha: 0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: negState.offeredPrice.clamp(minOffer, maxOffer),
              min: minOffer,
              max: maxOffer,
              divisions: 50,
              onChanged: (negState.isAccepted || negState.isWalkaway || negState.isProcessing)
                  ? null
                  : (val) {
                      ref.read(vasitaNegotiationProvider(widget.listing).notifier).updateOfferPrice((val / 1000).round() * 1000.0);
                    },
            ),
          ),

          // Financial Anchoring Breakdown (Dark Pattern Gain / Loss framing)
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('vasita_dark_discount_gain'),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    Text(
                      '+${CurrencyFormatter.format(discount)}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('vasita_dark_noter_est'),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                    Text(
                      CurrencyFormatter.format(estNoterFee),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFF59E0B)),
                    ),
                  ],
                ),
                if (netBenefit > 0) ...[
                  const Divider(height: 8, thickness: 0.8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('vasita_dark_net_benefit'),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '+${CurrencyFormatter.format(netBenefit)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF00E575)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(VasitaNegotiationState negState, bool isGarageFull, double playerBalance, bool isDark) {
    if (negState.isHandoverCompleted) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NeoBrutalButton(
            label: context.tr('vasita_seller_handover_garage_btn'),
            icon: Icons.garage_rounded,
            fullWidth: true,
            backgroundColor: const Color(0xFF00E575),
            textColor: Colors.black,
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/inventory');
            },
          ),
          const SizedBox(height: 8),
          NeoBrutalButton(
            label: context.tr('vasita_seller_handover_market_btn'),
            icon: Icons.storefront_rounded,
            fullWidth: true,
            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            textColor: isDark ? Colors.white : Colors.black,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    if (negState.isAccepted) {
      return NeoBrutalButton(
        label: context.tr('vasita_btn_complete_noter'),
        icon: Icons.verified_user_rounded,
        fullWidth: true,
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.white,
        onPressed: _showNoterTransferDialog,
      );
    }

    if (negState.isWalkaway) {
      final hasRescueTea = !negState.usedTacticIds.contains('sanayi_cayi');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasRescueTea) ...[
            NeoBrutalButton(
              label: context.tr('vasita_btn_rescue_tea'),
              icon: Icons.local_cafe_rounded,
              fullWidth: true,
              backgroundColor: const Color(0xFFF59E0B),
              textColor: Colors.black,
              onPressed: () {
                final teaTactic = VasitaNegotiationEngine.allTactics.firstWhere((t) => t.id == 'sanayi_cayi');
                _executeTactic(teaTactic);
              },
            ),
            const SizedBox(height: 8),
          ],
          NeoBrutalButton(
            label: context.tr('vasita_btn_leave_table'),
            icon: Icons.exit_to_app_rounded,
            fullWidth: true,
            backgroundColor: const Color(0xFFEF4444),
            textColor: Colors.white,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    }

    final canAfford = playerBalance >= negState.offeredPrice;

    final String buttonLabel;
    final Color buttonColor;
    final IconData buttonIcon;
    final VoidCallback? buttonAction;

    if (negState.isProcessing) {
      buttonLabel = '...';
      buttonColor = const Color(0xFF94A3B8);
      buttonIcon = Icons.hourglass_top_rounded;
      buttonAction = null;
    } else if (negState.isWalkaway) {
      buttonLabel = context.tr('vasita_btn_seller_walked');
      buttonColor = const Color(0xFFEF4444);
      buttonIcon = Icons.cancel_rounded;
      buttonAction = null;
    } else if (isGarageFull) {
      buttonLabel = context.tr('vasita_btn_garage_full');
      buttonColor = const Color(0xFF94A3B8);
      buttonIcon = Icons.warehouse_rounded;
      buttonAction = null;
    } else if (!canAfford) {
      buttonLabel = context.tr('vasita_btn_insufficient_funds');
      buttonColor = const Color(0xFFF59E0B);
      buttonIcon = Icons.account_balance_wallet_rounded;
      buttonAction = null;
    } else {
      buttonLabel = context.tr('vasita_btn_submit_offer');
      buttonColor = const Color(0xFF00E575);
      buttonIcon = Icons.send_rounded;
      buttonAction = _submitOffer;
    }

    return NeoBrutalButton(
      label: buttonLabel,
      icon: buttonIcon,
      fullWidth: true,
      backgroundColor: buttonColor,
      textColor: Colors.black,
      onPressed: buttonAction,
    );
  }

  Widget _buildNearMissCard(double nearMissAmount, bool isDark) {
    final diffText = CurrencyFormatter.format(nearMissAmount);
    final msg = context.tr('vasita_near_miss_message', {'amount': diffText});

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFB020).withValues(alpha: isDark ? 0.20 : 0.15),
        border: Border.all(color: const Color(0xFFFFB020), width: 2.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, color: Color(0xFFFFB020), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFFFFE082) : const Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunkCostNotice(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00E575).withValues(alpha: isDark ? 0.15 : 0.10),
        border: Border.all(color: const Color(0xFF00E575), width: 1.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Color(0xFF00E575), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              context.tr('vasita_dark_sunk_cost_warning'),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
