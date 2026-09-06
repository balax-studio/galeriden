import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/home_interior_design_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';

class HomeInteriorCategoryDetailScreen extends ConsumerWidget {
  final String propertyId;
  final HomeInteriorCategory category;

  const HomeInteriorCategoryDetailScreen({
    super.key,
    required this.propertyId,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final property = game.ownedRealEstates.where((p) => p.id == propertyId).firstOrNull;
    if (property == null) {
      return Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr(category.titleKey),
        ),
        body: Center(
          child: Text(
            context.tr('real_estate_not_found'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    final catalogItems = HomeInteriorDesignCatalog.getItemsForCategory(category);
    final installedItemIds = property.interiorDesignItemIds.toSet();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: context.tr(category.titleKey),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Header summary badge
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderColor: Colors.black,
            borderWidth: 2.2,
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(
                    category.icon,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${context.tr('current_balance')} • ${CurrencyFormatter.format(game.balance)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Catalog items list
          ...catalogItems.map((item) {
            final isInstalled = installedItemIds.contains(item.id);
            final canAfford = game.balance >= item.price;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isInstalled
                    ? (isDark ? const Color(0xFF142E1F) : const Color(0xFFECFDF5))
                    : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderColor: isInstalled ? const Color(0xFF10B981) : Colors.black,
                borderWidth: 2.2,
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isInstalled
                                ? const Color(0xFF10B981)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.8),
                          ),
                          child: Icon(
                            category.icon,
                            color: isInstalled ? Colors.white : (isDark ? Colors.white : Colors.black),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      context.tr(item.nameKey),
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                  if (isInstalled)
                                    NeoBrutalBadge(
                                      text: context.tr('home_interior_item_installed'),
                                      backgroundColor: const Color(0xFF10B981),
                                      textColor: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                context.tr(item.descriptionKey),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Divider(color: Colors.black12, height: 1),
                    const SizedBox(height: 10),

                    // Metrics & Purchase row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CurrencyFormatter.format(item.price),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('home_interior_item_stats', {
                                'prestige': '${item.prestigeBonus}',
                                'appraisal': CurrencyFormatter.format(item.appraisalValue),
                              }),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        if (isInstalled)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981), width: 1.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  context.tr('home_interior_item_installed'),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: canAfford ? AppColors.brutalYellow : Colors.grey.shade400,
                              foregroundColor: Colors.black,
                              elevation: 0,
                              side: const BorderSide(color: Colors.black, width: 1.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: canAfford
                                ? () {
                                    HapticFeedback.heavyImpact();
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .buyHomeInteriorItem(propertyId, item.id);
                                    if (success) {
                                      NotificationService.showSuccess(
                                        context,
                                        context.tr('home_interior_purchase_success'),
                                      );
                                    }
                                  }
                                : null,
                            child: Text(
                              context.tr('home_interior_btn_buy_install'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
