import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/vehicle_category.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/part_order_model.dart';
import '../../../../data/models/staff_model.dart';
import '../../../../domain/usecases/psychology_engine.dart';
import '../../../../domain/usecases/repair_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/dialogs/generic_rush_job_dialog.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/neo_brutal_empty_state.dart';
import 'animated_order_card.dart';
import 'barn_find_restoration_sheet.dart';
import 'order_parts_sheet.dart';
import 'repair_tier_selection_sheet.dart';
import 'workshop_acoustic_diagnostic_dialog.dart';
import 'workshop_custom_paint_color_sheet.dart';
import 'workshop_equipment_tile.dart';
import 'workshop_repair_tile.dart';

class WorkshopGarageRepairsTab extends ConsumerStatefulWidget {
  const WorkshopGarageRepairsTab({super.key});

  @override
  ConsumerState<WorkshopGarageRepairsTab> createState() =>
      _WorkshopGarageRepairsTabState();
}

class _WorkshopGarageRepairsTabState
    extends ConsumerState<WorkshopGarageRepairsTab> {
  CarModel? _selectedCar;

  Widget _buildHealthBar({
    required String label,
    required double percent,
    required bool isDark,
  }) {
    final color = percent >= 80
        ? const Color(0xFF00E575)
        : (percent >= 50 ? const Color(0xFFFFDE59) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10.5, fontWeight: FontWeight.w800),
                ),
              ),
              Expanded(
                child: Text(
                  '%${percent.toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percent / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _buyEquipment(String eqId, double cost, String name) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(
        context,
        context.tr('toast_insufficient_balance_needed',
            {'cost': CurrencyFormatter.format(cost)}),
      );
      return;
    }

    final success =
        ref.read(gameProvider.notifier).purchaseEquipmentUpgrade(eqId, cost);
    if (success) {
      NotificationService.showReward(
          context, context.tr('workshop_toast_equip_installed'));
      setState(() {});
    }
  }

  void _executeTierRepair(
      CarModel car, String repairType, RepairTier tier, double cost) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(
        context,
        context.tr('toast_insufficient_balance_needed',
            {'cost': CurrencyFormatter.format(cost)}),
      );
      return;
    }

    if (repairType == 'engine') {
      if (car.expertise.engineCondition >= 99.5) {
        NotificationService.showInfo(
            context, context.tr('workshop_engine_perfect_toast'));
        return;
      }
      if (tier == RepairTier.master &&
          !game.unlockedBuildings.contains('workshop_eq_lift')) {
        NotificationService.showError(
            context, context.tr('workshop_toast_lift_req'));
        return;
      }
      final result =
          ref.read(gameProvider.notifier).repairEngineWithTier(car, tier);
      if (result.isSuccess) {
        NotificationService.showSuccess(context, result.message);
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      } else {
        NotificationService.showError(context, result.message);
      }
    } else if (repairType == 'transmission') {
      if (car.expertise.transmissionCondition >= 99.5) {
        NotificationService.showInfo(
            context, context.tr('toast_gearbox_already_perfect'));
        return;
      }
      if (tier == RepairTier.master &&
          !game.unlockedBuildings.contains('workshop_eq_lift')) {
        NotificationService.showError(
            context, context.tr('workshop_toast_lift_req'));
        return;
      }
      final result =
          ref.read(gameProvider.notifier).repairTransmissionWithTier(car, tier);
      if (result.isSuccess) {
        NotificationService.showSuccess(context, result.message);
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      } else {
        NotificationService.showError(context, result.message);
      }
    } else if (repairType == 'bodywork') {
      final nonOriginalParts = car.expertise.bodyParts.entries
          .where((e) => e.value != PartStatus.original)
          .map((e) => e.key)
          .toList();

      if (nonOriginalParts.isEmpty) {
        NotificationService.showInfo(
            context, context.tr('toast_body_no_damaged_parts'));
        return;
      }

      final hasMechanic =
          game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final double successRate =
          hasMechanic ? 1.0 : RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(
          context,
          context.tr('workshop_paint_failed_toast',
              {'waste': CurrencyFormatter.formatShort(cost * 0.4)}),
        );
        return;
      }

      final success =
          ref.read(gameProvider.notifier).performWorkshopStationRepair(
                car.id,
                repairType: 'bodywork',
                cost: cost,
              );

      if (success) {
        NotificationService.showSuccess(
            context, context.tr('workshop_toast_body_all_done'));
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    } else if (repairType == 'ecu') {
      if (car.expertise.isEcuCleaned) {
        NotificationService.showInfo(
            context, context.tr('workshop_ecu_perfect_toast'));
        return;
      }
      final hasMechanic =
          game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final double successRate =
          hasMechanic ? 1.0 : RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(
          context,
          context.tr('workshop_ecu_failed_toast',
              {'waste': CurrencyFormatter.formatShort(cost * 0.4)}),
        );
        return;
      }
      final success =
          ref.read(gameProvider.notifier).performWorkshopStationRepair(
                car.id,
                repairType: 'ecu',
                cost: cost,
              );
      if (success) {
        NotificationService.showSuccess(
            context, context.tr('workshop_toast_ecu_done'));
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    } else if (repairType == 'chassis') {
      if (car.expertise.isChassisAligned) {
        NotificationService.showInfo(
            context, context.tr('workshop_chassis_perfect_toast'));
        return;
      }
      final hasMechanic =
          game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final double successRate =
          hasMechanic ? 1.0 : RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(
          context,
          context.tr('workshop_chassis_failed_toast',
              {'waste': CurrencyFormatter.formatShort(cost * 0.4)}),
        );
        return;
      }
      final success =
          ref.read(gameProvider.notifier).performWorkshopStationRepair(
                car.id,
                repairType: 'chassis',
                cost: cost,
              );
      if (success) {
        NotificationService.showSuccess(
            context, context.tr('workshop_toast_chassis_done'));
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (game.ownedCars.isEmpty) {
      return NeoBrutalEmptyState(
        icon: Icons.build_circle_rounded,
        accentColor: const Color(0xFFFF7A00),
        badgeText: context.tr('workshop_empty_badge'),
        title: context.tr('workshop_empty_title'),
        description: context.tr('workshop_empty_desc'),
        actionLabel: context.tr('car_wash_btn_go_market'),
        actionIcon: Icons.storefront_rounded,
        onActionPressed: () => context.push('/marketplace'),
      );
    }

    if (_selectedCar == null ||
        !game.ownedCars.any((c) => c.id == _selectedCar!.id)) {
      _selectedCar = game.ownedCars.first;
    } else {
      _selectedCar = game.ownedCars.firstWhere(
        (c) => c.id == _selectedCar!.id,
        orElse: () => game.ownedCars.first,
      );
    }

    final hasLift = game.unlockedBuildings.contains('workshop_eq_lift');
    final hasChassisBench =
        game.unlockedBuildings.contains('workshop_eq_chassis_bench');
    final hasPaintBooth =
        game.unlockedBuildings.contains('workshop_eq_paint_booth');
    final paintCostMultiplier = hasPaintBooth ? 0.50 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // VIP Tuning Banner Nav
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(Icons.speed_rounded,
                          color: Colors.black, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(context.tr('workshop_tuning_studio_title'),
                              style: const TextStyle(
                                  fontSize: 12.5, fontWeight: FontWeight.w900)),
                          Text(
                            context.tr('workshop_tuning_studio_subtitle'),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NeoBrutalButton(
                label: game.isFeatureUnlocked('/tuning-studio')
                    ? context.tr('workshop_btn_tuning_enter')
                    : context.tr('locked_badge'),
                backgroundColor: game.isFeatureUnlocked('/tuning-studio')
                    ? AppColors.brutalYellow
                    : const Color(0xFF64748B),
                textColor: game.isFeatureUnlocked('/tuning-studio')
                    ? Colors.black
                    : Colors.white,
                fontSize: 10.5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: () {
                  if (game.isFeatureUnlocked('/tuning-studio')) {
                    context.push('/tuning-studio');
                  } else {
                    NotificationService.showInfo(
                      context,
                      context.tr('cashflow_locked_feature_toast', {
                        'branch': DealershipModel.getRequiredBranchName(
                            '/tuning-studio', context)
                      }),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Car Selector Carousel
        Text(
          context.tr('workshop_select_car_title',
              {'count': game.ownedCars.length.toString()}),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 94,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: game.ownedCars.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final car = game.ownedCars[index];
              final isSelected = _selectedCar?.id == car.id;
              final exp = car.expertise;
              final isPerfect = exp.engineCondition >= 95 &&
                  exp.transmissionCondition >= 95;

              return GestureDetector(
                onTap: () => setState(() => _selectedCar = car),
                child: Container(
                  width: 190,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFFEF3C7))
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
                      Text(car.brand,
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B)),
                          maxLines: 1),
                      Text(car.modelName,
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: NeoBrutalBadge(
                              text: isPerfect
                                  ? context.tr('workshop_badge_perfect')
                                  : context.tr('workshop_badge_engine_cond', {
                                      'val':
                                          exp.engineCondition.toInt().toString()
                                    }),
                              backgroundColor: isPerfect
                                  ? const Color(0xFF00E575)
                                  : const Color(0xFFFF7A00),
                              textColor: Colors.black,
                              fontSize: 8.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              CurrencyFormatter.formatShort(
                                  car.baseMarketValue),
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Active Vehicle Mechanical Diagnosis Card
        if (_selectedCar != null) ...[
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _selectedCar!.vehicleCategory !=
                                VehicleCategory.car
                            ? _selectedCar!.vehicleCategory.badgeColor
                            : const Color(0xFFFF7A00),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                          _selectedCar!.vehicleCategory !=
                                  VehicleCategory.car
                              ? _selectedCar!.vehicleCategory.icon
                              : Icons.car_repair_rounded,
                          color: Colors.black,
                          size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${_selectedCar!.brand} ${_selectedCar!.modelName}',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedCar!.vehicleCategory !=
                                  VehicleCategory.car) ...[
                                const SizedBox(width: 6),
                                NeoBrutalBadge(
                                  text: context.tr(_selectedCar!
                                      .vehicleCategory.localizationKey),
                                  icon: _selectedCar!.vehicleCategory.icon,
                                  backgroundColor: _selectedCar!
                                      .vehicleCategory.badgeColor,
                                  textColor: Colors.black,
                                  fontSize: 8.5,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${context.tr('car_card_market_value')}: ${CurrencyFormatter.format(_selectedCar!.estimatedRealValue)} • ${context.tr('workshop_badge_perfect')}: ${CurrencyFormatter.formatShort(_selectedCar!.baseMarketValue)} • ${_selectedCar!.modelYear}',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Gauges
                Row(
                  children: [
                    Expanded(
                      child: _buildHealthBar(
                        label: context.tr('car_expertise_engine'),
                        percent: _selectedCar!.expertise.engineCondition,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHealthBar(
                        label: context.tr('car_expertise_transmission'),
                        percent: _selectedCar!.expertise.transmissionCondition,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // RPG Quick Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        icon: Icons.oil_barrel_rounded,
                        label: _selectedCar!.isPeriodicMaintained
                            ? context.tr('workshop_btn_10k_maintained')
                            : context.tr('workshop_btn_10k_service'),
                        backgroundColor: _selectedCar!.isPeriodicMaintained
                            ? const Color(0xFF1E2330)
                            : AppColors.brutalYellow,
                        textColor: _selectedCar!.isPeriodicMaintained
                            ? (isDark ? Colors.white54 : Colors.black54)
                            : Colors.black,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        onPressed: _selectedCar!.isPeriodicMaintained
                            ? null
                            : () {
                                if (game.balance < 3500) {
                                  NotificationService.showError(
                                    context,
                                    context.tr(
                                        'toast_insufficient_balance_needed',
                                        {'cost': '₺3.500'}),
                                  );
                                  return;
                                }
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .performPeriodicMaintenance(
                                        _selectedCar!.id);
                                if (success) {
                                  NotificationService.showSuccess(
                                    context,
                                    context.tr(
                                        'workshop_10k_maintenance_toast'),
                                  );
                                  setState(() {
                                    _selectedCar = ref
                                        .read(gameProvider)
                                        .ownedCars
                                        .firstWhere(
                                            (c) => c.id == _selectedCar!.id,
                                            orElse: () => _selectedCar!);
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: NeoBrutalButton(
                        icon: Icons.palette_rounded,
                        label: _selectedCar!.isPainting
                            ? context.tr('workshop_paint_in_oven')
                            : context.tr('workshop_btn_paint_oven'),
                        backgroundColor: _selectedCar!.isPainting
                            ? (isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFCBD5E1))
                            : const Color(0xFFA855F7),
                        textColor: _selectedCar!.isPainting
                            ? (isDark ? Colors.white60 : Colors.black54)
                            : Colors.white,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        onPressed: _selectedCar!.isPainting
                            ? null
                            : () => WorkshopCustomPaintColorSheet.show(
                                  context,
                                  ref,
                                  _selectedCar!,
                                  onColorApplied: () {
                                    setState(() {
                                      _selectedCar = ref
                                          .read(gameProvider)
                                          .ownedCars
                                          .firstWhere(
                                              (c) => c.id == _selectedCar!.id,
                                              orElse: () => _selectedCar!);
                                    });
                                  },
                                ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: NeoBrutalButton(
                        icon: Icons.hearing_rounded,
                        label: context.tr('workshop_btn_engine_listen'),
                        backgroundColor: const Color(0xFF06B6D4),
                        textColor: Colors.black,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        onPressed: () =>
                            WorkshopAcousticDiagnosticDialog.show(
                                context, _selectedCar!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        icon: Icons.hardware_rounded,
                        label: _selectedCar!.hasPdrRepaired
                            ? context.tr('workshop_pdr_done')
                            : context.tr('workshop_btn_pdr'),
                        backgroundColor: _selectedCar!.hasPdrRepaired
                            ? const Color(0xFF1E2330)
                            : const Color(0xFF00E575),
                        textColor: _selectedCar!.hasPdrRepaired
                            ? (isDark ? Colors.white54 : Colors.black54)
                            : Colors.black,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        onPressed: _selectedCar!.hasPdrRepaired
                            ? null
                            : () {
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .performPdrDentRepair(_selectedCar!.id);
                                if (success) {
                                  NotificationService.showSuccess(context,
                                      context.tr('workshop_pdr_dent_toast'));
                                  setState(() {
                                    _selectedCar = ref
                                        .read(gameProvider)
                                        .ownedCars
                                        .firstWhere(
                                            (c) => c.id == _selectedCar!.id,
                                            orElse: () => _selectedCar!);
                                  });
                                } else {
                                  NotificationService.showError(
                                    context,
                                    context.tr(
                                        'toast_insufficient_balance_needed',
                                        {'cost': '₺3.200'}),
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: NeoBrutalButton(
                        icon: Icons.verified_rounded,
                        label: _selectedCar!.hasTuvturkCertified
                            ? context.tr('workshop_tuvturk_certified')
                            : context.tr('workshop_btn_tuvturk'),
                        backgroundColor: _selectedCar!.hasTuvturkCertified
                            ? const Color(0xFF1E2330)
                            : const Color(0xFF38BDF8),
                        textColor: _selectedCar!.hasTuvturkCertified
                            ? (isDark ? Colors.white54 : Colors.black54)
                            : Colors.black,
                        fontSize: 10,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        onPressed: _selectedCar!.hasTuvturkCertified
                            ? null
                            : () {
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .certifyTuvturkInspection(
                                        _selectedCar!.id);
                                if (success) {
                                  NotificationService.showSuccess(
                                    context,
                                    context
                                        .tr('workshop_toast_tuvturk_done'),
                                  );
                                  setState(() {
                                    _selectedCar = ref
                                        .read(gameProvider)
                                        .ownedCars
                                        .firstWhere(
                                            (c) => c.id == _selectedCar!.id,
                                            orElse: () => _selectedCar!);
                                  });
                                } else {
                                  NotificationService.showError(
                                    context,
                                    context.tr(
                                        'toast_insufficient_balance_needed',
                                        {'cost': '₺1.500'}),
                                  );
                                }
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (_selectedCar!.isBarnFind) ...[
                  NeoBrutalButton(
                    label: context.tr('workshop_btn_barn_find', {
                      'stage': _selectedCar!.barnFindStage.toString()
                    }),
                    icon: Icons.auto_fix_high_rounded,
                    backgroundColor: const Color(0xFFA855F7),
                    textColor: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    fullWidth: true,
                    onPressed: () => BarnFindRestorationSheet.show(
                        context, _selectedCar!),
                  ),
                  const SizedBox(height: 8),
                ],

                NeoBrutalButton(
                  label: context.tr('workshop_btn_order_parts'),
                  icon: Icons.local_shipping_rounded,
                  backgroundColor: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFE2E8F0),
                  textColor: isDark ? Colors.white : Colors.black,
                  fontSize: 10.5,
                  fullWidth: true,
                  onPressed: () => OrderPartsSheet.show(
                    context: context,
                    car: _selectedCar!,
                    game: game,
                    onOrderConfirmed:
                        (partName, type, cost, durationSeconds) {
                      if (game.pendingOrders.any((o) =>
                          o.carId == _selectedCar!.id &&
                          o.partName.toLowerCase().trim() ==
                              partName.toLowerCase().trim())) {
                        NotificationService.showWarning(
                          context,
                          context.tr('toast_part_order_duplicate'),
                        );
                        return;
                      }
                      if (game.balance < cost &&
                          type != OrderType.salvagedScrap) {
                        NotificationService.showError(
                          context,
                          context.tr('toast_insufficient_balance_needed',
                              {'cost': CurrencyFormatter.format(cost)}),
                        );
                        return;
                      }
                      final success =
                          ref.read(gameProvider.notifier).orderPart(
                                carId: _selectedCar!.id,
                                partName: partName,
                                orderType: type,
                                cost: cost,
                                deliveryDurationSeconds: durationSeconds,
                              );
                      if (success) {
                        NotificationService.showSuccess(
                          context,
                          context.tr('workshop_toast_order_dispatched'),
                        );
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Five Specialized Repair Stations
        Text(
          context.tr('workshop_stations_title'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        Builder(
          builder: (context) {
            final exp = _selectedCar?.expertise;
            final isEngineRepaired =
                (exp?.engineCondition ?? 100.0) >= 95.0;
            final isTransmissionRepaired =
                (exp?.transmissionCondition ?? 100.0) >= 95.0;
            final isEcuRepaired = exp?.isEcuCleaned ?? false;
            final isBodyworkRepaired = !(exp?.bodyParts.values
                    .any((v) => v != PartStatus.original) ??
                false);
            final isChassisRepaired = exp?.isChassisAligned ?? false;

            final carBaseVal = _selectedCar != null
                ? max(150000.0, _selectedCar!.baseMarketValue.toDouble())
                : 400000.0;
            final dynamicEngineCost =
                (carBaseVal * 0.035).clamp(8500.0, 75000.0);
            final dynamicTransCost =
                (carBaseVal * 0.025).clamp(6500.0, 50000.0);
            final dynamicEcuCost =
                (carBaseVal * 0.010).clamp(2500.0, 20000.0);
            final dynamicBodyCost =
                (carBaseVal * 0.045 * paintCostMultiplier)
                    .clamp(12000.0, 90000.0);
            final dynamicChassisCost =
                (carBaseVal * 0.065).clamp(25000.0, 150000.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkshopRepairTile(
                  title: _selectedCar != null &&
                          _selectedCar!.vehicleCategory != VehicleCategory.car
                      ? '1. ${context.tr(_selectedCar!.vehicleCategory.engineRepairKey)}'
                      : '1. ${context.tr('workshop_station_engine')}',
                  description: context.tr('workshop_station_engine_desc'),
                  cost: dynamicEngineCost,
                  bonusText: context.tr('workshop_bonus_engine'),
                  netRoiText: _selectedCar != null
                      ? PsychologyEngine.getNetRoiRepairText(dynamicEngineCost,
                          _selectedCar!.estimatedRealValue * 0.10)
                      : null,
                  badgeColor: const Color(0xFF00E575),
                  isDark: isDark,
                  isRepaired: isEngineRepaired,
                  disabledLabel:
                      '${context.tr('workshop_no_repair_needed')} • ${context.tr('sticker_mechanical_flaw')}',
                  onRepair: () => RepairTierSelectionSheet.show(
                    context: context,
                    car: _selectedCar!,
                    repairType: 'engine',
                    baseCost: dynamicEngineCost,
                    onTierSelected: (tier, cost) => _executeTierRepair(
                        _selectedCar!, 'engine', tier, cost),
                  ),
                  onAdRepair: () {
                    GenericRushJobDialog.show(
                      context,
                      titleBadge: context.tr('rush_lore_night_shift_title'),
                      targetTitle:
                          '${_selectedCar!.brand} ${_selectedCar!.modelName} • ${context.tr('workshop_station_engine')}',
                      targetSubtitle:
                          context.tr('workshop_station_engine_desc'),
                      loreDescription:
                          context.tr('rush_lore_night_shift_desc'),
                      icon: Icons.precision_manufacturing_rounded,
                      badgeColor: const Color(0xFF10B981),
                      actionButtonLabel:
                          context.tr('rush_lore_night_shift_btn'),
                      onRushSuccess: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .performWorkshopStationRepair(
                              _selectedCar!.id,
                              repairType: 'engine',
                              cost: 0.0,
                            );
                        if (success) {
                          NotificationService.showSuccess(context,
                              context.tr('workshop_10k_maintenance_toast'));
                          setState(() {
                            _selectedCar = ref
                                .read(gameProvider)
                                .ownedCars
                                .firstWhere((c) => c.id == _selectedCar!.id,
                                    orElse: () => _selectedCar!);
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                WorkshopRepairTile(
                  title: _selectedCar != null &&
                          _selectedCar!.vehicleCategory != VehicleCategory.car
                      ? '2. ${context.tr(_selectedCar!.vehicleCategory.transmissionRepairKey)}'
                      : '2. ${context.tr('workshop_station_transmission')}',
                  description:
                      context.tr('workshop_station_transmission_desc'),
                  cost: dynamicTransCost,
                  bonusText: context.tr('workshop_bonus_gearbox'),
                  netRoiText: _selectedCar != null
                      ? PsychologyEngine.getNetRoiRepairText(dynamicTransCost,
                          _selectedCar!.estimatedRealValue * 0.08)
                      : null,
                  badgeColor: const Color(0xFF38BDF8),
                  isDark: isDark,
                  isRepaired: isTransmissionRepaired,
                  disabledLabel:
                      '${context.tr('workshop_no_repair_needed')} • ${context.tr('scrapyard_tab_transmission')}',
                  onRepair: () => RepairTierSelectionSheet.show(
                    context: context,
                    car: _selectedCar!,
                    repairType: 'transmission',
                    baseCost: dynamicTransCost,
                    onTierSelected: (tier, cost) => _executeTierRepair(
                        _selectedCar!, 'transmission', tier, cost),
                  ),
                  onAdRepair: () {
                    GenericRushJobDialog.show(
                      context,
                      titleBadge: context.tr('rush_lore_night_shift_title'),
                      targetTitle:
                          '${_selectedCar!.brand} ${_selectedCar!.modelName} • ${context.tr('workshop_station_transmission')}',
                      targetSubtitle:
                          context.tr('workshop_station_transmission_desc'),
                      loreDescription:
                          context.tr('rush_lore_night_shift_desc'),
                      icon: Icons.settings_input_component_rounded,
                      badgeColor: const Color(0xFF38BDF8),
                      actionButtonLabel:
                          context.tr('rush_lore_night_shift_btn'),
                      onRushSuccess: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .performWorkshopStationRepair(
                              _selectedCar!.id,
                              repairType: 'transmission',
                              cost: 0.0,
                            );
                        if (success) {
                          NotificationService.showSuccess(
                              context, context.tr('toast_gearbox_free_done'));
                          setState(() {
                            _selectedCar = ref
                                .read(gameProvider)
                                .ownedCars
                                .firstWhere((c) => c.id == _selectedCar!.id,
                                    orElse: () => _selectedCar!);
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                WorkshopRepairTile(
                  title: '3. ${context.tr('workshop_station_ecu')}',
                  description: context.tr('workshop_station_ecu_desc'),
                  cost: dynamicEcuCost,
                  bonusText: context.tr('workshop_bonus_ecu'),
                  netRoiText: _selectedCar != null
                      ? PsychologyEngine.getNetRoiRepairText(dynamicEcuCost,
                          _selectedCar!.estimatedRealValue * 0.05)
                      : null,
                  badgeColor: const Color(0xFFA855F7),
                  isDark: isDark,
                  isRepaired: isEcuRepaired,
                  disabledLabel:
                      '${context.tr('workshop_no_repair_needed')} • OBD-II',
                  onRepair: () => RepairTierSelectionSheet.show(
                    context: context,
                    car: _selectedCar!,
                    repairType: 'ecu',
                    baseCost: dynamicEcuCost,
                    onTierSelected: (tier, cost) => _executeTierRepair(
                        _selectedCar!, 'ecu', tier, cost),
                  ),
                  onAdRepair: () {
                    GenericRushJobDialog.show(
                      context,
                      titleBadge: context.tr('rush_lore_ecu_flash_title'),
                      targetTitle:
                          '${_selectedCar!.brand} ${_selectedCar!.modelName} • ${context.tr('workshop_station_ecu')}',
                      targetSubtitle: context.tr('workshop_station_ecu_desc'),
                      loreDescription: context.tr('rush_lore_ecu_flash_desc'),
                      icon: Icons.memory_rounded,
                      badgeColor: const Color(0xFFA855F7),
                      actionButtonLabel:
                          context.tr('rush_lore_ecu_flash_btn'),
                      onRushSuccess: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .performWorkshopStationRepair(
                              _selectedCar!.id,
                              repairType: 'ecu',
                              cost: 0.0,
                            );
                        if (success) {
                          NotificationService.showSuccess(
                              context, context.tr('workshop_toast_ecu_done'));
                          setState(() {
                            _selectedCar = ref
                                .read(gameProvider)
                                .ownedCars
                                .firstWhere((c) => c.id == _selectedCar!.id,
                                    orElse: () => _selectedCar!);
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                WorkshopRepairTile(
                  title: _selectedCar != null &&
                          _selectedCar!.vehicleCategory != VehicleCategory.car
                      ? '4. ${context.tr(_selectedCar!.vehicleCategory.bodyworkRepairKey)}'
                      : '4. ${context.tr('workshop_station_bodywork')}',
                  description: context.tr('workshop_station_bodywork_desc'),
                  cost: dynamicBodyCost,
                  bonusText: hasPaintBooth
                      ? context.tr('workshop_bonus_paint_booth')
                      : context.tr('workshop_bonus_paint'),
                  netRoiText: _selectedCar != null
                      ? PsychologyEngine.getNetRoiRepairText(dynamicBodyCost,
                          _selectedCar!.estimatedRealValue * 0.15)
                      : null,
                  badgeColor: const Color(0xFFFFDE59),
                  isDark: isDark,
                  isRepaired: isBodyworkRepaired,
                  disabledLabel:
                      '${context.tr('workshop_no_repair_needed')} • ${context.tr('scrapyard_tab_body_rims')}',
                  onRepair: () => RepairTierSelectionSheet.show(
                    context: context,
                    car: _selectedCar!,
                    repairType: 'bodywork',
                    baseCost: dynamicBodyCost,
                    onTierSelected: (tier, cost) => _executeTierRepair(
                        _selectedCar!, 'bodywork', tier, cost),
                  ),
                  onAdRepair: () {
                    GenericRushJobDialog.show(
                      context,
                      titleBadge: context.tr('rush_lore_paint_booth_title'),
                      targetTitle:
                          '${_selectedCar!.brand} ${_selectedCar!.modelName} • ${context.tr('workshop_station_bodywork')}',
                      targetSubtitle:
                          context.tr('workshop_station_bodywork_desc'),
                      loreDescription:
                          context.tr('rush_lore_paint_booth_desc'),
                      icon: Icons.format_paint_rounded,
                      badgeColor: const Color(0xFFFFDE59),
                      actionButtonLabel:
                          context.tr('rush_lore_paint_booth_btn'),
                      onRushSuccess: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .performWorkshopStationRepair(
                              _selectedCar!.id,
                              repairType: 'bodywork',
                              cost: 0.0,
                            );
                        if (success) {
                          NotificationService.showSuccess(
                              context,
                              context.tr('workshop_toast_body_all_done'));
                          setState(() {
                            _selectedCar = ref
                                .read(gameProvider)
                                .ownedCars
                                .firstWhere((c) => c.id == _selectedCar!.id,
                                    orElse: () => _selectedCar!);
                          });
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
                WorkshopRepairTile(
                  title: '5. ${context.tr('workshop_station_chassis')}',
                  description: context.tr('workshop_station_chassis_desc'),
                  cost: dynamicChassisCost,
                  bonusText: hasChassisBench
                      ? context.tr('workshop_bonus_chassis_bench')
                      : context.tr('workshop_bonus_chassis'),
                  netRoiText: _selectedCar != null
                      ? PsychologyEngine.getNetRoiRepairText(dynamicChassisCost,
                          _selectedCar!.estimatedRealValue * 0.20)
                      : null,
                  badgeColor: const Color(0xFFEF4444),
                  isDark: isDark,
                  isRepaired: isChassisRepaired,
                  disabledLabel:
                      '${context.tr('workshop_no_repair_needed')} • ${context.tr('chassis_laser_scanning')}',
                  onRepair: () => RepairTierSelectionSheet.show(
                    context: context,
                    car: _selectedCar!,
                    repairType: 'chassis',
                    baseCost: dynamicChassisCost,
                    onTierSelected: (tier, cost) => _executeTierRepair(
                        _selectedCar!, 'chassis', tier, cost),
                  ),
                  onAdRepair: () {
                    GenericRushJobDialog.show(
                      context,
                      titleBadge:
                          context.tr('rush_lore_chassis_laser_title'),
                      targetTitle:
                          '${_selectedCar!.brand} ${_selectedCar!.modelName} • ${context.tr('workshop_station_chassis')}',
                      targetSubtitle:
                          context.tr('workshop_station_chassis_desc'),
                      loreDescription:
                          context.tr('rush_lore_chassis_laser_desc'),
                      icon: Icons.straighten_rounded,
                      badgeColor: const Color(0xFFEF4444),
                      actionButtonLabel:
                          context.tr('rush_lore_chassis_laser_btn'),
                      onRushSuccess: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .performWorkshopStationRepair(
                              _selectedCar!.id,
                              repairType: 'chassis',
                              cost: 0.0,
                            );
                        if (success) {
                          NotificationService.showSuccess(context,
                              context.tr('workshop_toast_chassis_done'));
                          setState(() {
                            _selectedCar = ref
                                .read(gameProvider)
                                .ownedCars
                                .firstWhere((c) => c.id == _selectedCar!.id,
                                    orElse: () => _selectedCar!);
                          });
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 20),

        // Pending Part Orders
        if (game.pendingOrders.isNotEmpty) ...[
          Text(
            context.tr('workshop_pending_orders_title',
                {'count': game.pendingOrders.length.toString()}),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ...game.pendingOrders.map((order) {
            return AnimatedOrderCard(
              order: order,
              p: p,
              onCancel: () {
                final success = ref
                    .read(gameProvider.notifier)
                    .cancelPartOrder(order.id);
                if (success) {
                  NotificationService.showInfo(
                    context,
                    context.tr('order_card_cancelled_toast'),
                  );
                  setState(() {});
                }
              },
              onInstall: () {
                final success = ref
                    .read(gameProvider.notifier)
                    .installDeliveredPart(order.id);
                if (success) {
                  NotificationService.showSuccess(
                    context,
                    context.tr('toast_part_install_completed',
                        {'part': order.partName}),
                  );
                  setState(() {});
                }
              },
              onFastDeliverWithAd: () {
                GenericRushJobDialog.show(
                  context,
                  titleBadge: context.tr('rush_lore_air_cargo_title'),
                  targetTitle: order.partName,
                  targetSubtitle: context.tr(
                      'order_card_in_cargo', {'sec': order.remainingSeconds}),
                  loreDescription: context.tr('rush_lore_air_cargo_desc'),
                  icon: Icons.airplanemode_active_rounded,
                  badgeColor: AppColors.brutalYellow,
                  actionButtonLabel: context.tr('rush_lore_air_cargo_btn'),
                  actionButtonIcon: Icons.flight_takeoff_rounded,
                  onRushSuccess: () {
                    ref
                        .read(gameProvider.notifier)
                        .instantDeliverPartOrder(order.id);
                    NotificationService.showReward(
                        context, context.tr('workshop_toast_fast_shipping'));
                    setState(() {});
                  },
                );
              },
            );
          }),
          const SizedBox(height: 16),
        ],

        // Salvaged Parts
        if (game.salvagedParts.isNotEmpty) ...[
          Text(
            context.tr('workshop_salvaged_parts_title',
                {'count': game.salvagedParts.length.toString()}),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          ...game.salvagedParts.map((part) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64748B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(Icons.settings_suggest_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(part.name,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w900)),
                          Text(
                            context.tr('workshop_part_cond_val', {
                              'cond': part.conditionPercent.toString(),
                              'val':
                                  CurrencyFormatter.format(part.estimatedValue),
                            }),
                            style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: context.tr('workshop_btn_install_salvage'),
                      icon: Icons.build_rounded,
                      backgroundColor: const Color(0xFF00E575),
                      textColor: Colors.black,
                      fontSize: 10.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      onPressed: () {
                        if (_selectedCar == null) return;
                        final success = ref
                            .read(gameProvider.notifier)
                            .installPartToCar(part.id, _selectedCar!.id);
                        if (success) {
                          NotificationService.showSuccess(context,
                              context.tr('workshop_toast_part_installed'));
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
        ],

        // Equipment Upgrades
        Text(
          context.tr('workshop_equipment_title'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),

        WorkshopEquipmentTile(
          id: 'workshop_eq_lift',
          title: context.tr('workshop_eq_lift_title'),
          description: context.tr('workshop_eq_lift_desc'),
          cost: 85000.0,
          isOwned: hasLift,
          icon: Icons.elevator_rounded,
          color: const Color(0xFFFF7A00),
          isDark: isDark,
          onBuy: () => _buyEquipment('workshop_eq_lift', 85000.0,
              context.tr('workshop_eq_lift_title')),
        ),
        const SizedBox(height: 8),

        WorkshopEquipmentTile(
          id: 'workshop_eq_chassis_bench',
          title: context.tr('workshop_eq_chassis_title'),
          description: context.tr('workshop_eq_chassis_desc'),
          cost: 220000.0,
          isOwned: hasChassisBench,
          icon: Icons.straighten_rounded,
          color: const Color(0xFFEF4444),
          isDark: isDark,
          onBuy: () => _buyEquipment('workshop_eq_chassis_bench', 220000.0,
              context.tr('workshop_eq_chassis_title')),
        ),
        const SizedBox(height: 8),

        WorkshopEquipmentTile(
          id: 'workshop_eq_paint_booth',
          title: context.tr('workshop_eq_paint_title'),
          description: context.tr('workshop_eq_paint_desc'),
          cost: 450000.0,
          isOwned: hasPaintBooth,
          icon: Icons.format_paint_rounded,
          color: const Color(0xFFFFDE59),
          isDark: isDark,
          onBuy: () => _buyEquipment('workshop_eq_paint_booth', 450000.0,
              context.tr('workshop_eq_paint_title')),
        ),
      ],
    );
  }
}
