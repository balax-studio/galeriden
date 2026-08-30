import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/dialogs/lucky_opportunity_dialog.dart';
import '../../../widgets/mini_games/scrapyard_teardown_canvas.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pneumatic_nut_particle_widget.dart';

class ScrapyardDismantleDialog {
  static Color _getTierColor(PartQualityTier tier) {
    switch (tier) {
      case PartQualityTier.worn:
        return const Color(0xFFEF4444);
      case PartQualityTier.usable:
        return const Color(0xFFF59E0B);
      case PartQualityTier.good:
        return const Color(0xFF3B82F6);
      case PartQualityTier.pristine:
        return const Color(0xFF10B981);
    }
  }

  static void show(BuildContext context, WidgetRef ref, ScrapyardCar car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initialParts = car.parts;

    showDialog(
      context: context,
      builder: (ctx) {
        return Consumer(
          builder: (dialogCtx, ref, _) {
            final game = ref.watch(gameProvider);
            final currentCarIndex =
                game.scrapyardCars.indexWhere((c) => c.id == car.id);
            final currentCar = currentCarIndex != -1
                ? game.scrapyardCars[currentCarIndex]
                : null;
            final remainingPartIds =
                currentCar?.parts.map((p) => p.id).toSet() ?? <String>{};
            final remainingCount = remainingPartIds.length;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(18),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('scrap_dialog_dismantle_title'),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        NeoBrutalBadge(
                          text: remainingCount > 0
                              ? context.tr('scrap_remaining_parts_badge',
                                  {'count': '$remainingCount'})
                              : context.tr('scrap_all_dismantled_badge'),
                          backgroundColor: remainingCount > 0
                              ? AppColors.brutalOrange
                              : AppColors.brutalGreen,
                          textColor: Colors.black,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${car.brand} ${car.modelName.replaceAll(RegExp(r'\s*\(.*?\)\s*'), '')}',
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: initialParts.length,
                        itemBuilder: (pCtx, i) {
                          final part = initialParts[i];
                          final isAlreadyDismantled =
                              !remainingPartIds.contains(part.id);
                          final tierColor = _getTierColor(part.tier);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isAlreadyDismantled
                                  ? (isDark
                                      ? const Color(0xFF141722).withValues(alpha: 0.5)
                                      : const Color(0xFFF1F5F9))
                                  : (isDark
                                      ? const Color(0xFF0F1118)
                                      : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isAlreadyDismantled
                                    ? (isDark
                                        ? const Color(0xFF1E2330)
                                        : const Color(0xFFE2E8F0))
                                    : (isDark
                                        ? const Color(0xFF333B4F)
                                        : const Color(0xFF0F172A)),
                                width: 1.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: isAlreadyDismantled
                                        ? Colors.grey.withValues(alpha: 0.2)
                                        : tierColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isAlreadyDismantled
                                          ? Colors.grey
                                          : tierColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.build_circle_outlined,
                                    color: isAlreadyDismantled
                                        ? Colors.grey
                                        : tierColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        part.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          decoration: isAlreadyDismantled
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: isAlreadyDismantled
                                              ? (isDark
                                                  ? Colors.white38
                                                  : Colors.black38)
                                              : (isDark
                                                  ? Colors.white
                                                  : const Color(0xFF0F172A)),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isAlreadyDismantled
                                            ? context.tr('scrap_dismantled_status')
                                            : 'Kondisyon: %${part.conditionPercent} • ${CurrencyFormatter.format(part.estimatedValue)}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: isAlreadyDismantled
                                              ? (isDark
                                                  ? Colors.white30
                                                  : Colors.black26)
                                              : tierColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!isAlreadyDismantled)
                                  NeoBrutalButton(
                                    label: context.tr('scrap_btn_dismantle_take'),
                                    backgroundColor: AppColors.brutalOrange,
                                    textColor: Colors.black,
                                    fontSize: 10.5,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    onPressed: () {
                                      _handleDismantleChoice(
                                          dialogCtx, ref, car, part);
                                    },
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      context.tr('scrap_btn_dismantled_badge'),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white38
                                            : Colors.black38,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (car.isPurchased && remainingCount == 0)
                          Expanded(
                            child: NeoBrutalButton(
                              label: context.tr('scrap_melt_car_btn'),
                              icon: Icons.local_fire_department_rounded,
                              backgroundColor: AppColors.brutalRed,
                              textColor: Colors.white,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              onPressed: () {
                                Navigator.pop(ctx);
                                final result = ref
                                    .read(gameProvider.notifier)
                                    .crushChassisToScrapMetal(car.id);
                                if (result.success) {
                                  NotificationService.showSuccess(
                                      context, result.message);
                                } else {
                                  NotificationService.showError(
                                      context, result.message);
                                }
                              },
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        NeoBrutalButton(
                          label: context.tr('close'),
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor:
                              isDark ? Colors.white70 : const Color(0xFF64748B),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static void _handleDismantleChoice(
      BuildContext context, WidgetRef ref, ScrapyardCar car, SalvagedPart part) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalYellow,
          borderRadius: 14,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned(
                top: -6,
                right: -4,
                child: PneumaticNutParticleWidget(size: 55),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.tr('scrap_dismantle_method_title'),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${part.name} • Mevcut Kondisyon: %${part.conditionPercent}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  NeoBrutalButton(
                    label: context.tr('scrap_manual_dismantle_btn'),
                    icon: Icons.build_circle_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScrapyardTeardownModal.show(
                        context,
                        partName: part.name,
                        carName: '${car.brand} ${car.modelName}',
                        initialCondition: part.conditionPercent,
                        onCompleted: (isSuccess, finalCondition, message) {
                          final result = ref
                              .read(gameProvider.notifier)
                              .dismantleSinglePartFromScrap(
                                car.id,
                                part.id,
                                forceSuccess: isSuccess,
                                customCondition:
                                    isSuccess ? finalCondition : null,
                              );
                          if (isSuccess && result.isSalvaged) {
                            NotificationService.showSuccess(
                              context,
                              context.tr('scrap_dismantle_success_toast', {
                                'name': part.name,
                                'cond': '$finalCondition'
                              }),
                            );
                            final luckyOpp = ref
                                .read(gameProvider.notifier)
                                .checkAndRollLuckyOpportunity();
                            if (luckyOpp != null && context.mounted) {
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                if (context.mounted) {
                                  LuckyOpportunityDialog.show(
                                      context, luckyOpp);
                                }
                              });
                            }
                          } else {
                            NotificationService.showWarning(
                                context, result.message);
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  NeoBrutalButton(
                    label: context.tr('scrap_auto_dismantle_btn'),
                    icon: Icons.flash_on_rounded,
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fontSize: 11.5,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () {
                      Navigator.pop(ctx);
                      final result = ref
                          .read(gameProvider.notifier)
                          .dismantleSinglePartFromScrap(car.id, part.id);
                      if (result.success) {
                        if (result.isSalvaged) {
                          NotificationService.showSuccess(
                              context, result.message);
                        } else {
                          NotificationService.showWarning(
                              context, result.message);
                        }
                      } else {
                        NotificationService.showError(context, result.message);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
