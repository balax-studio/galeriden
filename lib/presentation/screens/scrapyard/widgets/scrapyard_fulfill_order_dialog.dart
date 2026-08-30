import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_card.dart';

class ScrapyardFulfillOrderDialog {
  static void show(BuildContext context, WidgetRef ref, B2BPartOrder order) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final matchingParts = game.salvagedParts.where((p) {
      if (p.category != order.requiredCategory) return false;
      if (order.requiredCarBrand != null) {
        if (!p.carModelName
            .toLowerCase()
            .contains(order.requiredCarBrand!.toLowerCase())) {
          return false;
        }
      }
      return p.tier.index >= order.minQualityTier.index;
    }).toList();

    if (matchingParts.isEmpty) {
      NotificationService.showError(
        context,
        context.tr('scrap_b2b_missing_part_error', {'mechanic': order.mechanicName}),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('scrap_fulfill_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr(
                      'scrap_fulfill_desc', {'mechanic': order.mechanicName}),
                  style:
                      const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: matchingParts.length,
                    itemBuilder: (mCtx, i) {
                      final part = matchingParts[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            final success = ref
                                .read(gameProvider.notifier)
                                .fulfillB2BPartOrder(order.id, part.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                context.tr('scrap_b2b_fulfilled_toast', {
                                  'part': part.name,
                                  'mechanic': order.mechanicName,
                                  'price': CurrencyFormatter.formatShort(
                                      order.offeredPrice),
                                  'rep': '${order.reputationReward}',
                                }),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0F1118)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      part.name,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      '${part.carModelName} • %${part.conditionPercent} • ${part.tierName}',
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.brutalGreen, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
