import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/workshop_job_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class WorkshopCustomPaintColorSheet {
  static void show(
    BuildContext context,
    WidgetRef ref,
    CarModel car, {
    VoidCallback? onColorApplied,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('custom_paint_title'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                  ),
                  NeoBrutalBadge(
                    text: car.isPainting
                        ? context.tr('workshop_paint_in_oven')
                        : context.tr('custom_paint_sub'),
                    backgroundColor: car.isPainting
                        ? AppColors.brutalOrange
                        : AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                car.isPainting
                    ? context.tr('toast_car_already_painting')
                    : context.tr('custom_paint_hint'),
                style: TextStyle(
                    fontSize: 11,
                    color: car.isPainting
                        ? AppColors.brutalOrange
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              ...CustomPaintColor.palette.map((paint) {
                final isCurrentPending = car.pendingPaintName == paint.name;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFF8FAFC),
                    borderColor: isCurrentPending
                        ? AppColors.brutalOrange
                        : (isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFCBD5E1)),
                    borderRadius: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: paint.color,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paint.name,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      CurrencyFormatter.format(paint.cost),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.brutalOrange),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoBrutalButton(
                          label: car.isPainting
                              ? context.tr('workshop_paint_in_oven')
                              : context.tr('paint_action_btn'),
                          backgroundColor: car.isPainting
                              ? (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFE2E8F0))
                              : AppColors.brutalYellow,
                          textColor:
                              car.isPainting ? Colors.grey : Colors.black,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          onPressed: car.isPainting
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  final game = ref.read(gameProvider);
                                  if (game.balance < paint.cost) {
                                    NotificationService.showError(
                                      context,
                                      context.tr(
                                          'toast_insufficient_balance_needed', {
                                        'cost': CurrencyFormatter.format(
                                            paint.cost)
                                      }),
                                    );
                                    return;
                                  }
                                  final success = ref
                                      .read(gameProvider.notifier)
                                      .applyCustomPaintRespray(car.id, paint);
                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      context.tr(
                                          'workshop_toast_paint_started'),
                                    );
                                    onColorApplied?.call();
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
