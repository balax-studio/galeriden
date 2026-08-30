import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/scrapyard_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import 'scrapyard_fulfill_order_dialog.dart';

class ScrapyardB2BOrdersTab extends ConsumerWidget {
  const ScrapyardB2BOrdersTab({super.key});

  Color _getTierColor(PartQualityTier tier) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final b2bOrders =
        game.b2bPartOrders.where((o) => !o.isCompleted).toList();
    final salvagedParts = game.salvagedParts;

    if (b2bOrders.isEmpty) {
      return Center(
        child: NeoBrutalCard(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(28),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.assignment_turned_in_rounded,
                  color: AppColors.brutalGreen, size: 40),
              const SizedBox(height: 10),
              Text(
                context.tr('scrap_b2b_all_done_title'),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('scrap_b2b_all_done_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      itemCount: b2bOrders.length,
      itemBuilder: (context, index) {
        final order = b2bOrders[index];

        final hasMatchingPart = salvagedParts.any((p) {
          if (p.category != order.requiredCategory) return false;
          if (order.requiredCarBrand != null) {
            if (!p.carModelName
                .toLowerCase()
                .contains(order.requiredCarBrand!.toLowerCase())) {
              return false;
            }
          }
          return p.tier.index >= order.minQualityTier.index;
        });

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(order.mechanicAvatar,
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          order.mechanicName,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: '+${order.reputationReward} İtibar',
                      backgroundColor: AppColors.brutalPurple,
                      textColor: Colors.white,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  order.description,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),

                // Required specifications
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1118)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('scrap_b2b_category', {
                            'cat':
                                '${order.requiredCategory.toUpperCase()}${order.requiredCarBrand != null ? " • ${order.requiredCarBrand}" : ""}'
                          }),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          context.tr('scrap_b2b_min_tier', {
                            'tier': order.minQualityTier.name.toUpperCase()
                          }),
                          style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _getTierColor(order.minQualityTier)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('scrap_b2b_mechanic_offer'),
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          CurrencyFormatter.formatShort(order.offeredPrice),
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                    NeoBrutalButton(
                      label: hasMatchingPart
                          ? context.tr('scrap_b2b_btn_fulfill')
                          : context.tr('scrap_b2b_btn_no_part'),
                      icon: hasMatchingPart
                          ? Icons.local_shipping_rounded
                          : Icons.block_rounded,
                      backgroundColor: hasMatchingPart
                          ? AppColors.brutalGreen
                          : const Color(0xFF64748B),
                      textColor:
                          hasMatchingPart ? Colors.black : Colors.white,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      onPressed: () => ScrapyardFulfillOrderDialog.show(
                          context, ref, order),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
