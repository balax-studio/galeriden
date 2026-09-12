import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/tuning_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/dialogs/lucky_opportunity_dialog.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/mini_games/dyno_run_canvas.dart';
import '../../widgets/mini_games/engine_timing_canvas.dart';
import '../../../domain/usecases/operation_suspense_engine.dart';
import '../../widgets/dialogs/neo_brutal_operation_dialog.dart';
import '../../widgets/ads/neo_brutal_native_ad_card.dart';
import '../../../core/services/ad_service.dart';
import '../../widgets/hazard_stripe_widget.dart';
import '../../widgets/neo_brutal_stamp.dart';
import 'dart:math' as math;

class TuningStudioScreen extends ConsumerStatefulWidget {
  const TuningStudioScreen({super.key});

  @override
  ConsumerState<TuningStudioScreen> createState() => _TuningStudioScreenState();
}

class _TuningStudioScreenState extends ConsumerState<TuningStudioScreen> {
  CarModel? _selectedCar;
  int _selectedTabIndex =
      0; // 0: Tümü, 1: Motor, 2: Aero, 3: Yürüyen, 4: Egzoz, 5: Hazır Paketler
  final Set<String> _timedCalibratedCarIds = {};
  final Set<String> _dynoTestedCarIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentDay = ref.read(gameProvider).currentDay;
        if (AdService.shouldShowNativeAdForDay(currentDay, NativeAdContextType.workshop)) {
          AdService.instance.preloadNativeAd();
        }
      }
    });
  }

  void _runDynoSimulation(BuildContext context, CarDynoStats dyno) {
    if (_selectedCar == null) return;
    DynoRunCanvasModal.show(context, car: _selectedCar!, dyno: dyno);
    setState(() {
      _dynoTestedCarIds.add(_selectedCar!.id);
    });
  }

  void _runEngineTimingCalibration(BuildContext context) {
    if (_selectedCar == null) return;
    EngineTimingModal.show(
      context,
      car: _selectedCar!,
      onTimingCalibrated: (isPerfect, hpBonus, message) {
        final updatedCar = _selectedCar!.copyWith(
          expertise: _selectedCar!.expertise.copyWith(
            engineCondition: math.min(
                100.0,
                _selectedCar!.expertise.engineCondition +
                    (isPerfect ? 10.0 : 4.0)),
          ),
        );
        ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, 0.0);
        setState(() {
          _selectedCar = updatedCar;
          _timedCalibratedCarIds.add(updatedCar.id);
        });
        NotificationService.showSuccess(
          context,
          context.tr('tuning_toast_health_updated'),
        );
        final luckyOpp =
            ref.read(gameProvider.notifier).checkAndRollLuckyOpportunity();
        if (luckyOpp != null && context.mounted) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              LuckyOpportunityDialog.show(context, luckyOpp);
            }
          });
        }
      },
    );
  }

  Future<void> _applyTuningOption(TuningOptionModel opt) async {
    final game = ref.read(gameProvider);
    if (game.balance < opt.cost) {
      NotificationService.showError(
          context,
          context.tr('toast_insufficient_balance_needed',
              {'cost': CurrencyFormatter.formatShort(opt.cost)}));
      return;
    }

    final opType = OperationSuspenseType.fromTuningCategory(opt.category);
    await NeoBrutalOperationDialog.show(
      context,
      operationType: opType,
      carName: '${_selectedCar!.brand} ${_selectedCar!.modelName}',
      customTitle: opt.title,
      onComplete: () {
        final wasOverTuned = _selectedCar!.isOverTuned;
        final updatedCar = _selectedCar!.copyWith(
          appliedDetailingOptionIds: [
            ..._selectedCar!.appliedDetailingOptionIds,
            opt.id
          ],
        );
        ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, opt.cost);

        setState(() {
          _selectedCar = updatedCar;
        });

        NotificationService.showSuccess(
          context,
          context.tr('tuning_toast_option_applied'),
        );

        if (!wasOverTuned && updatedCar.isOverTuned && mounted) {
          _showOverTunedWarningDialog();
        }
      },
    );
  }

  Future<void> _applyPresetBuild(TuningPresetBuild preset) async {
    final game = ref.read(gameProvider);
    final discountedCost = preset.getDiscountedCost();

    if (game.balance < discountedCost) {
      NotificationService.showError(
          context, context.tr('err_insufficient_cash'));
      return;
    }

    await NeoBrutalOperationDialog.show(
      context,
      operationType: OperationSuspenseType.tuningPreset,
      carName: '${_selectedCar!.brand} ${_selectedCar!.modelName}',
      customTitle: preset.title,
      onComplete: () {
        final wasOverTuned = _selectedCar!.isOverTuned;
        // Apply all unapplied options
        final newOptionIds =
            Set<String>.from(_selectedCar!.appliedDetailingOptionIds)
              ..addAll(preset.optionIds);
        final updatedCar = _selectedCar!.copyWith(
          appliedDetailingOptionIds: newOptionIds.toList(),
        );

        ref
            .read(gameProvider.notifier)
            .updateOwnedCar(updatedCar, discountedCost);

        setState(() {
          _selectedCar = updatedCar;
        });

        NotificationService.showSuccess(
          context,
          context.tr('tuning_toast_preset_applied'),
        );

        if (!wasOverTuned && updatedCar.isOverTuned && mounted) {
          _showOverTunedWarningDialog();
        }
      },
    );
  }

  void _showOverTunedWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1410),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.brutalOrange, width: 2.8),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.brutalOrange, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.tr('tuning_overtuned_dialog_title'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('tuning_overtuned_dialog_desc'),
              style: const TextStyle(fontSize: 12.5, color: Color(0xFFFED7AA)),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr('tuning_overtuned_dialog_sub'),
              style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFFCBD5E1),
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: context.tr('tuning_overtuned_dialog_btn'),
            backgroundColor: AppColors.brutalOrange,
            textColor: Colors.black,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _applyLegalProject() {
    const certCost = 4500.0;
    final game = ref.read(gameProvider);
    if (game.balance < certCost) {
      NotificationService.showError(context,
          context.tr('toast_insufficient_balance_needed', {'cost': CurrencyFormatter.format(certCost)}));
      return;
    }

    final updatedCar = _selectedCar!.copyWith(
      appliedDetailingOptionIds: [
        ..._selectedCar!.appliedDetailingOptionIds,
        'tune_legal_project_cert'
      ],
    );

    ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, certCost);

    setState(() {
      _selectedCar = updatedCar;
    });

    NotificationService.showSuccess(
      context,
      context.tr('tuning_toast_project_approved'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ??
        (Theme.of(context).brightness == Brightness.dark);

    if (!game.isFeatureUnlocked('/tuning-studio')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF080B10) : const Color(0xFFF3F1EA),
        appBar: NeoBrutalAppBar(title: context.tr('tuning_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/tuning-studio',
          featureTitle: context.tr('tuning_screen_title'),
          icon: Icons.speed_rounded,
        ),
      );
    }

    final ownedCars = game.ownedCars;

    if (_selectedCar == null && ownedCars.isNotEmpty) {
      _selectedCar = ownedCars.first;
    } else if (_selectedCar != null &&
        !ownedCars.any((c) => c.id == _selectedCar!.id)) {
      _selectedCar = ownedCars.isNotEmpty ? ownedCars.first : null;
    } else if (_selectedCar != null) {
      _selectedCar = ownedCars.firstWhere((c) => c.id == _selectedCar!.id);
    }

    final dyno = _selectedCar != null
        ? CarDynoCalculator.calculateDyno(_selectedCar!)
        : null;

    final tabs = [
      (
        label: context.tr('tuning_tab_all',
            {'count': TuningCatalog.allOptions.length.toString()}),
        icon: Icons.tune_rounded
      ),
      (label: context.tr('tuning_tab_motor'), icon: Icons.speed_rounded),
      (label: context.tr('tuning_tab_aero'), icon: Icons.palette_rounded),
      (
        label: context.tr('tuning_tab_stance'),
        icon: Icons.directions_car_rounded
      ),
      (label: context.tr('tuning_tab_exhaust'), icon: Icons.volume_up_rounded),
      (
        label: context.tr('tuning_tab_packages'),
        icon: Icons.inventory_2_rounded
      ),
    ];

    List<TuningOptionModel> visibleOptions;
    switch (_selectedTabIndex) {
      case 1:
        visibleOptions =
            TuningCatalog.getOptionsByCategory(TuningCategory.powertrain);
        break;
      case 2:
        visibleOptions =
            TuningCatalog.getOptionsByCategory(TuningCategory.aero);
        break;
      case 3:
        visibleOptions =
            TuningCatalog.getOptionsByCategory(TuningCategory.stance);
        break;
      case 4:
        visibleOptions =
            TuningCatalog.getOptionsByCategory(TuningCategory.exhaust);
        break;
      default:
        visibleOptions = TuningCatalog.allOptions;
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF080B10) : const Color(0xFFF3F1EA),
      appBar: NeoBrutalAppBar(
        title: context.tr('tuning_screen_title'),
        subtitle: context.tr('tuning_slug'),
        titleBadgeColor: const Color(0xFFF43F5E),
        titleTextColor: Colors.white,
        headerAnimation: NeoBrutalHeaderAnimation.revBarFlash,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.precision_manufacturing_rounded, color: Colors.black),
              tooltip: context.tr('tuning_outsourced_screen_title'),
              onPressed: () => context.push('/contract-tuning'),
            ),
          ),
        ],
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.workshop,
        child: ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
            // VIP Outsource Banner Card
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: const Color(0xFF00E5FF),
                child: InkWell(
                  onTap: () => context.push('/contract-tuning'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.precision_manufacturing_rounded,
                            color: Color(0xFF00E5FF),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    context.tr('tuning_outsourced_banner_title'),
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    color: Colors.black,
                                    child: const Text(
                                      'VIP',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFFD600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('tuning_outsourced_banner_subtitle'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.black,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // 1. Header Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.speed_rounded,
                      color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('tuning_screen_title'),
                        style: const TextStyle(
                            fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('tuning_screen_subtitle'),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // VIP Outsourced Tuning Banner
          GestureDetector(
            onTap: () => context.push('/contract-tuning'),
            child: NeoBrutalCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              backgroundColor: isDark ? const Color(0xFF1E142B) : const Color(0xFFFAF5FF),
              borderColor: isDark ? const Color(0xFFD946EF) : const Color(0xFF7E22CE),
              borderRadius: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD946EF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.black, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              context.tr('tuning_outsourced_screen_title'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.toxicLime,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: const Text(
                                'VIP',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('tuning_outsourced_banner_subtitle'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFD8B4FE) : const Color(0xFF7E22CE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Car Selector
          Text(
            context.tr('tuning_select_car'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          if (ownedCars.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor:
                  isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Center(
                child: Text(
                  context.tr('tuning_no_cars'),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ownedCars.length,
                itemBuilder: (context, index) {
                  final car = ownedCars[index];
                  final isSelected = _selectedCar?.id == car.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCar = car),
                    child: Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark ? const Color(0xFF141721) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF7A00)
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF0F172A)),
                          width: isSelected ? 2.5 : 2.0,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${car.brand} ${car.modelName}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark ? Colors.white : Colors.black),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CurrencyFormatter.formatShort(car.baseMarketValue),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.black87
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // 3. Dyno Dashboard & Car Stats
          if (_selectedCar != null && dyno != null) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: _selectedCar!.isOverTuned
                  ? AppColors.brutalOrange
                  : (dyno.isInspectionCompliant ? AppColors.brutalGreen : AppColors.brutalCyan),
              borderWidth: 2.5,
              borderRadius: 14,
              shadowOffset: const Offset(4.0, 4.0),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_selectedCar!.isOverTuned) ...[
                        const ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          child: HazardStripeWidget(
                            height: 6,
                            color1: AppColors.brutalOrange,
                            color2: Colors.black,
                            isAnimated: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.speed_rounded,
                                  color: AppColors.brutalGreen, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                context.tr('tuning_dyno_card_title',
                                    {'brand': _selectedCar!.brand}),
                                style: const TextStyle(
                                    fontSize: 11.5, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 4,
                            children: [
                              if (_selectedCar!.isOverTuned)
                                NeoBrutalBadge(
                                  text: context.tr('tuning_overtuned_badge'),
                                  backgroundColor: AppColors.brutalOrange,
                                  textColor: Colors.black,
                                  fontSize: 9.0,
                                ),
                              NeoBrutalBadge(
                                text: dyno.isInspectionCompliant
                                    ? context.tr('tuning_tuvturk_ok')
                                    : context.tr('tuning_tuvturk_fail'),
                                backgroundColor: dyno.isInspectionCompliant
                                    ? AppColors.brutalGreen
                                    : AppColors.errorRed,
                                textColor: dyno.isInspectionCompliant
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 9.0,
                              ),
                            ],
                          ),
                        ],
                      ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _buildMetricTile(
                              context.tr('tuning_metric_power'),
                              '${dyno.totalHp} HP',
                              '+${dyno.totalHp - dyno.baseHp} HP',
                              AppColors.brutalGreen,
                              isDark)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildMetricTile(
                              context.tr('tuning_metric_torque'),
                              '${dyno.totalNm} Nm',
                              '+${dyno.totalNm - dyno.baseNm} Nm',
                              AppColors.brutalOrange,
                              isDark)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildMetricTile(
                              context.tr('tuning_metric_accel'),
                              '${dyno.currentAccel}s',
                              context.tr('tuning_metric_was',
                                  {'accel': dyno.baseAccel.toString()}),
                              const Color(0xFF06B6D4),
                              isDark)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildMetricTile(
                              context.tr('tuning_metric_sound'),
                              '${dyno.exhaustDb} dB',
                              context.tr('tuning_metric_score',
                                  {'score': dyno.tuningRating.toString()}),
                              const Color(0xFFA855F7),
                              isDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          icon: _dynoTestedCarIds.contains(_selectedCar!.id)
                              ? Icons.check_circle_rounded
                              : Icons.speed_rounded,
                          label: _dynoTestedCarIds.contains(_selectedCar!.id)
                              ? context.tr('tuning_btn_dyno_done')
                              : context.tr('tuning_btn_dyno_test'),
                          backgroundColor:
                              _dynoTestedCarIds.contains(_selectedCar!.id)
                                  ? const Color(0xFF1E293B)
                                  : AppColors.brutalYellow,
                          textColor:
                              _dynoTestedCarIds.contains(_selectedCar!.id)
                                  ? Colors.white54
                                  : Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          onPressed:
                              _dynoTestedCarIds.contains(_selectedCar!.id)
                                  ? null
                                  : () => _runDynoSimulation(context, dyno),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          icon:
                              _timedCalibratedCarIds.contains(_selectedCar!.id)
                                  ? Icons.check_circle_rounded
                                  : Icons.build_circle_rounded,
                          label:
                              _timedCalibratedCarIds.contains(_selectedCar!.id)
                                  ? context.tr('tuning_btn_timing_done')
                                  : context.tr('tuning_btn_timing_adjust'),
                          backgroundColor:
                              _timedCalibratedCarIds.contains(_selectedCar!.id)
                                  ? const Color(0xFF1E293B)
                                  : AppColors.brutalOrange,
                          textColor:
                              _timedCalibratedCarIds.contains(_selectedCar!.id)
                                  ? Colors.white54
                                  : Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          onPressed:
                              _timedCalibratedCarIds.contains(_selectedCar!.id)
                                  ? null
                                  : () => _runEngineTimingCalibration(context),
                        ),
                      ),
                      if (!dyno.isInspectionCompliant) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.shield_rounded,
                            label: context.tr('tuning_btn_legal_project'),
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            onPressed: _applyLegalProject,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              if (_dynoTestedCarIds.contains(_selectedCar!.id))
                Positioned(
                  right: 2,
                  bottom: 50,
                  child: NeoBrutalStamp(
                    text: 'DYNO ONAYLI',
                    subtext: '${dyno.totalHp} HP ONAY',
                    icon: Icons.verified_rounded,
                    type: NeoBrutalStampType.approved,
                    angle: -0.06,
                    fontSize: 10.0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

            // 4. Tab Bar (Tümü, Motor, Aero, Stance, Egzoz, Paketler)
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (ctx, i) {
                  final isTabSelected = _selectedTabIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isTabSelected
                            ? AppColors.brutalYellow
                            : (isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isTabSelected
                              ? const Color(0xFFFF7A00)
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFF0F172A)),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 13,
                            color: isTabSelected
                                ? Colors.black
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isTabSelected
                                  ? Colors.black
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 5. Preset Builds Tab or Option List
            if (_selectedTabIndex == 5) ...[
              ...TuningPresetBuilds.allPresets.map((preset) {
                final discountedPrice = preset.getDiscountedCost();
                final rawPrice =
                    TuningCatalog.calculateRawCost(preset.optionIds);
                final allApplied = preset.optionIds.every((id) =>
                    _selectedCar!.appliedDetailingOptionIds.contains(id));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor:
                        isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: allApplied
                        ? AppColors.brutalGreen
                        : AppColors.brutalOrange,
                    borderWidth: 2.5,
                    borderRadius: 14,
                    shadowOffset: const Offset(4.0, 4.0),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                    child: Text(preset.title,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900))),
                                NeoBrutalBadge(
                                  text: allApplied
                                      ? context.tr('tuning_badge_applied')
                                      : context.tr('tuning_badge_discount'),
                                  backgroundColor: allApplied
                                      ? AppColors.brutalGreen
                                      : AppColors.brutalYellow,
                                  textColor: Colors.black,
                                  fontSize: 10,
                                ),
                              ],
                            ),
                        const SizedBox(height: 6),
                        Text(preset.description,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    CurrencyFormatter.formatShort(rawPrice),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatShort(
                                        discountedPrice),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.brutalGreen),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton.luxury(
                              label: allApplied
                                  ? context.tr('tuning_btn_pkg_active')
                                  : context.tr('tuning_btn_apply_pkg'),
                              icon: allApplied
                                  ? Icons.check_circle_rounded
                                  : Icons.flash_on_rounded,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              onPressed: allApplied
                                  ? null
                                  : () => _applyPresetBuild(preset),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (allApplied)
                      Positioned(
                        right: 4,
                        top: 28,
                        child: NeoBrutalStamp(
                          text: 'YÜKLENDİ',
                          subtext: 'TAM DONANIM',
                          icon: Icons.verified_rounded,
                          type: NeoBrutalStampType.approved,
                          angle: -0.06,
                          fontSize: 10.0,
                        ),
                      ),
                  ],
                ),
              ),
            );
              }),
            ] else ...[
              // Standard Options List
              ...visibleOptions.map((opt) {
                final isApplied =
                    _selectedCar!.appliedDetailingOptionIds.contains(opt.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor:
                        isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isApplied
                        ? AppColors.brutalGreen
                        : (isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFF0F172A)),
                    borderWidth: 2.5,
                    borderRadius: 14,
                    shadowOffset: const Offset(3.5, 3.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: opt.color,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF333B4F)
                                            : const Color(0xFF0F172A),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Icon(opt.icon,
                                        color: Colors.black, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      opt.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isApplied)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: NeoBrutalBadge(
                                      text: context.tr('tuning_badge_applied'),
                                      backgroundColor: AppColors.brutalGreen,
                                      textColor: Colors.black,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                NeoBrutalBadge(
                                  text: context.tr('tuning_badge_val_gain', {
                                    'percent':
                                        ((opt.valueMultiplier - 1.0) * 100)
                                            .toStringAsFixed(0)
                                  }),
                                  backgroundColor: AppColors.brutalYellow,
                                  textColor: Colors.black,
                                  fontSize: 9.5,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt.description,
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),

                        // Performance Gain Badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (opt.hpGain > 0)
                              NeoBrutalBadge(
                                text: '+${opt.hpGain} HP',
                                backgroundColor: isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0),
                                textColor: AppColors.brutalGreen,
                                fontSize: 9.5,
                              ),
                            if (opt.nmGain > 0)
                              NeoBrutalBadge(
                                text: '+${opt.nmGain} Nm',
                                backgroundColor: isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0),
                                textColor: AppColors.brutalOrange,
                                fontSize: 9.5,
                              ),
                            if (opt.accelDelta != 0.0)
                              NeoBrutalBadge(
                                text: '${opt.accelDelta}s 0-100',
                                backgroundColor: isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0),
                                textColor: const Color(0xFF06B6D4),
                                fontSize: 9.5,
                              ),
                            if (opt.soundDbGain > 0)
                              NeoBrutalBadge(
                                text: '+${opt.soundDbGain} dB',
                                backgroundColor: isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0),
                                textColor: const Color(0xFFA855F7),
                                fontSize: 9.5,
                              ),
                            if (!opt.isLegalWithoutProject)
                              NeoBrutalBadge(
                                icon: Icons.warning_amber_rounded,
                                text: context.tr('tuning_badge_legal_req'),
                                backgroundColor: AppColors.errorRed,
                                textColor: Colors.white,
                                fontSize: 9.5,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                isApplied
                                    ? context.tr('tuning_btn_done')
                                    : CurrencyFormatter.formatShort(opt.cost),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isApplied
                                      ? const Color(0xFF64748B)
                                      : AppColors.brutalOrange,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            NeoBrutalButton.luxury(
                              label: isApplied
                                  ? context.tr('tuning_btn_applied')
                                  : context.tr('tuning_btn_apply'),
                              icon: isApplied
                                  ? Icons.check_circle_rounded
                                  : Icons.flash_on_rounded,
                              backgroundColor: isApplied ? null : opt.color,
                              textColor: isApplied ? null : Colors.black,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              onPressed: isApplied
                                  ? null
                                  : () => _applyTuningOption(opt),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
          const NeoBrutalNativeAdCard(
            contextType: NativeAdContextType.workshop,
            margin: EdgeInsets.only(top: 14, bottom: 8),
          ),
        ],
      ),
    ),
  );
  }

  static Widget _buildMetricTile(
      String title, String val, String sub, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E121A) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : const Color(0xFF0F172A),
            offset: const Offset(2.0, 2.0),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              sub,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
