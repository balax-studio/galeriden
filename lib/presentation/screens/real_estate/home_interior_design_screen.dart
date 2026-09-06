import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/home_interior_design_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';

class HomeInteriorDesignScreen extends ConsumerWidget {
  final String propertyId;

  const HomeInteriorDesignScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final property =
        game.ownedRealEstates.where((p) => p.id == propertyId).firstOrNull;

    if (property == null) {
      return Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr('home_interior_title'),
        ),
        body: Center(
          child: Text(
            context.tr('real_estate_not_found'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      );
    }

    final installedItems = property.interiorDesignItemIds
        .map((id) => HomeInteriorDesignCatalog.getItemById(id))
        .whereType<HomeInteriorItem>()
        .toList();

    final totalSpent = installedItems.fold<double>(0.0, (sum, i) => sum + i.basePrice);
    final appraisedBonus = HomeInteriorItem.calculateAppraisedInteriorBonus(property);
    final totalPrestige = installedItems.fold<int>(0, (sum, i) => sum + i.prestigeBonus);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: NeoBrutalAppBar(
        title: context.tr('home_interior_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Property Overview Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderColor: Colors.black,
            borderWidth: 2.2,
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.roofing_rounded,
                        color: Colors.black,
                        size: 26,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${property.district} • ${property.city}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    NeoBrutalBadge(
                      text: context.tr('real_estate_residence_badge'),
                      backgroundColor: const Color(0xFFE0E7FF),
                      textColor: const Color(0xFF3730A3),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('home_interior_subtitle'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Appraisal & Financial Metrics Grid
          Row(
            children: [
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7),
                  borderColor: Colors.black,
                  borderWidth: 2,
                  borderRadius: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('home_interior_total_investment'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.format(totalSpent),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFD1FAE5),
                  borderColor: Colors.black,
                  borderWidth: 2,
                  borderRadius: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('home_interior_appraised_bonus'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF065F46),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${CurrencyFormatter.format(appraisedBonus)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E7FF),
                  borderColor: Colors.black,
                  borderWidth: 2,
                  borderRadius: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('home_interior_prestige_bonus'),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3730A3),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+$totalPrestige',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. Category Sections Header
          Text(
            context.tr('home_interior_sections_title'),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),

          // 4. Category Cards List
          ...HomeInteriorCategory.values.map((category) {
            final categoryItems = HomeInteriorDesignCatalog.getItemsForCategory(category);
            final installedInCategory = categoryItems
                .where((item) => property.interiorDesignItemIds.contains(item.id))
                .toList();

            final isFullyFurnished = installedInCategory.length >= categoryItems.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  context.push('/emlak-ev-dizayn/$propertyId/${category.name}');
                },
                child: NeoBrutalCard(
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
                          color: isFullyFurnished
                              ? const Color(0xFF10B981)
                              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1.8),
                        ),
                        child: Icon(
                          category.icon,
                          color: isFullyFurnished
                              ? Colors.white
                              : (isDark ? Colors.white : Colors.black),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.tr(category.titleKey),
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${installedInCategory.length} / ${categoryItems.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isFullyFurnished
                                        ? const Color(0xFF10B981)
                                        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              installedInCategory.isNotEmpty
                                  ? installedInCategory.map((i) => context.tr(i.nameKey)).join(' • ')
                                  : context.tr('home_interior_no_items_yet'),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.black,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
