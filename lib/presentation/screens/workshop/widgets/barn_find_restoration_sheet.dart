import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class RestorationStageInfo {
  final int stage;
  final String titleKey;
  final String descriptionKey;
  final double cost;
  final IconData icon;

  const RestorationStageInfo({
    required this.stage,
    required this.titleKey,
    required this.descriptionKey,
    required this.cost,
    required this.icon,
  });
}

const List<RestorationStageInfo> kRestorationStages = [
  RestorationStageInfo(
    stage: 1,
    titleKey: 'barn_find_stage_1_title',
    descriptionKey: 'barn_find_stage_1_desc',
    cost: 4500,
    icon: Icons.cleaning_services_rounded,
  ),
  RestorationStageInfo(
    stage: 2,
    titleKey: 'barn_find_stage_2_title',
    descriptionKey: 'barn_find_stage_2_desc',
    cost: 9500,
    icon: Icons.settings_rounded,
  ),
  RestorationStageInfo(
    stage: 3,
    titleKey: 'barn_find_stage_3_title',
    descriptionKey: 'barn_find_stage_3_desc',
    cost: 6000,
    icon: Icons.bolt_rounded,
  ),
  RestorationStageInfo(
    stage: 4,
    titleKey: 'barn_find_stage_4_title',
    descriptionKey: 'barn_find_stage_4_desc',
    cost: 8000,
    icon: Icons.hardware_rounded,
  ),
  RestorationStageInfo(
    stage: 5,
    titleKey: 'barn_find_stage_5_title',
    descriptionKey: 'barn_find_stage_5_desc',
    cost: 12000,
    icon: Icons.palette_rounded,
  ),
];

class BarnFindRestorationSheet extends ConsumerStatefulWidget {
  final CarModel car;

  const BarnFindRestorationSheet({
    super.key,
    required this.car,
  });

  static Future<void> show(BuildContext context, CarModel car) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BarnFindRestorationSheet(car: car),
    );
  }

  @override
  ConsumerState<BarnFindRestorationSheet> createState() =>
      _BarnFindRestorationSheetState();
}

class _BarnFindRestorationSheetState
    extends ConsumerState<BarnFindRestorationSheet> {
  bool _useOriginalParts = true;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final currentCar = game.ownedCars.firstWhere(
      (c) => c.id == widget.car.id,
      orElse: () => widget.car,
    );

    final currentStage = currentCar.barnFindStage;
    final isCompleted = currentStage >= 5;

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (§1.3 / Q6)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.home_repair_service_rounded,
                      size: 24, color: AppColors.brutalYellow),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('barn_find_header'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${currentCar.brand} ${currentCar.modelName} • ${currentCar.modelYear}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Overview Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                  context.tr('barn_find_progress', {'stage': currentStage}),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? const Color(0xFF93C5FD)
                        : const Color(0xFF1E3A8A),
                  ),
                )),
                NeoBrutalBadge(
                  text: isCompleted
                      ? context.tr('barn_find_masterpiece_done')
                      : context.tr('barn_find_in_progress'),
                  backgroundColor: isCompleted
                      ? const Color(0xFF00E575)
                      : const Color(0xFFFFDE59),
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Original vs Aftermarket Selector (§1.3 / Q6)
          if (!isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _useOriginalParts
                      ? const Color(0xFFFFD700)
                      : const Color(0xFF64748B),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _useOriginalParts,
                    activeColor: const Color(0xFFFFD700),
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setState(() => _useOriginalParts = val ?? true);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('barn_find_use_original'),
                          style: const TextStyle(
                              fontSize: 10.5, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _useOriginalParts
                              ? context.tr('barn_find_original_desc')
                              : context.tr('barn_find_aftermarket_desc'),
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Stages List
          Expanded(
            child: ListView.builder(
              itemCount: kRestorationStages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx, idx) {
                final stageInfo = kRestorationStages[idx];
                final isDone = currentStage >= stageInfo.stage;
                final isCurrent = currentStage + 1 == stageInfo.stage;
                final effectiveCost = _useOriginalParts
                    ? (stageInfo.cost * 1.25)
                    : stageInfo.cost;
                final stageTitle = context.tr(stageInfo.titleKey);
                final stageDesc = context.tr(stageInfo.descriptionKey);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDone
                        ? (isDark
                            ? const Color(0xFF10281E)
                            : const Color(0xFFECFDF5))
                        : (isCurrent
                            ? (isDark
                                ? const Color(0xFF261D12)
                                : const Color(0xFFFFFBEB))
                            : (isDark
                                ? const Color(0xFF181C26)
                                : const Color(0xFFF1F5F9))),
                    borderColor: isDone
                        ? const Color(0xFF00E575)
                        : (isCurrent
                            ? const Color(0xFFFF7A00)
                            : (isDark
                                ? const Color(0xFF2A3142)
                                : const Color(0xFFCBD5E1))),
                    borderWidth: (isDone || isCurrent) ? 1.8 : 1.0,
                    borderRadius: 10,
                    child: Row(
                      children: [
                        Icon(
                          stageInfo.icon,
                          size: 22,
                          color: isDone
                              ? const Color(0xFF00E575)
                              : (isCurrent
                                  ? const Color(0xFFFF7A00)
                                  : (isDark ? Colors.white38 : Colors.black38)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: Text(
                                    stageTitle,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isDone || isCurrent
                                          ? (isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A))
                                          : (isDark
                                              ? Colors.white38
                                              : Colors.black38),
                                    ),
                                  )),
                                  if (isDone)
                                    const Icon(Icons.check_circle_rounded,
                                        size: 16, color: Color(0xFF00E575))
                                  else
                                    Text(
                                      CurrencyFormatter.formatShort(
                                          effectiveCost),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isCurrent
                                            ? const Color(0xFFFF7A00)
                                            : (isDark
                                                ? Colors.white38
                                                : Colors.black38),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                stageDesc,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Action Button
          if (!isCompleted) ...[
            Builder(
              builder: (context) {
                final nextStage = currentStage + 1;
                final nextStageInfo =
                    kRestorationStages.firstWhere((s) => s.stage == nextStage);
                final cost = _useOriginalParts
                    ? (nextStageInfo.cost * 1.25)
                    : nextStageInfo.cost;
                final nextStageTitle = context.tr(nextStageInfo.titleKey);

                return NeoBrutalButton(
                  label: context.tr('barn_find_btn_complete_stage', {
                    'title': nextStageTitle,
                    'cost': CurrencyFormatter.formatShort(cost),
                  }),
                  icon: Icons.handyman_rounded,
                  backgroundColor: const Color(0xFFFFDE59),
                  textColor: Colors.black,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    if (game.balance < cost) {
                      NotificationService.showError(
                        context,
                        '${CurrencyFormatter.formatShort(cost)} bakiye gereklidir.',
                      );
                      return;
                    }

                    // Update car in inventory
                    final updatedCar = currentCar.copyWith(
                      barnFindStage: nextStage,
                      isBarnFindOriginalParts: _useOriginalParts,
                      isBarnFindRestored: nextStage >= 5,
                      expertise: currentCar.expertise.copyWith(
                        engineCondition:
                            (currentCar.expertise.engineCondition + 15)
                                .clamp(0, 100),
                        transmissionCondition:
                            (currentCar.expertise.transmissionCondition + 15)
                                .clamp(0, 100),
                      ),
                    );

                    ref
                        .read(gameProvider.notifier)
                        .updateOwnedCar(updatedCar, cost);

                    NotificationService.showSuccess(
                      context,
                      '$nextStageTitle • OK',
                    );
                  },
                );
              },
            ),
          ] else ...[
            NeoBrutalButton(
              label: context.tr('barn_find_btn_all_done'),
              icon: Icons.auto_awesome_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}
