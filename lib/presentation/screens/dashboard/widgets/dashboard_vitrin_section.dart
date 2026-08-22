import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/market_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';

/// Sahibinden Style "Vitrin İlanları" Section
class DashboardMarketplaceVitrinList extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardMarketplaceVitrinList({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final allListings = ref.watch(marketProvider);
    final listings = allListings.take(4).toList();

    if (listings.isEmpty) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        child: Center(
          child: Text(
            context.tr('no_market_listings'),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      children: listings.map((listing) {
        final car = listing.car;
        final exp = car.expertise;
        final isGoodDeal = listing.askingPrice < car.baseMarketValue;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            onTap: () => context.push('/marketplace'),
            child: Row(
              children: [
                // Vehicle Thumbnail Box with Monolithic Border
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.directions_car_filled_rounded,
                        size: 38,
                        color: isDark ? palette.primaryColor : const Color(0xFF0F172A),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE59),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${car.modelYear}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Listing Info & Specs
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.brand} ${car.modelName}',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Specs Chips
                      Row(
                        children: [
                          NeoBrutalBadge(
                            text: '${(exp.mileage / 1000).toStringAsFixed(0)}k KM',
                            fontSize: 9.5,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          ),
                          const SizedBox(width: 4),
                          NeoBrutalBadge(
                            text: exp.engineCondition >= 50
                                ? '%${exp.engineCondition.round()}'
                                : context.tr('damaged_label'),
                            backgroundColor: exp.engineCondition >= 80
                                ? const Color(0xFF00E575)
                                : (exp.engineCondition >= 50
                                    ? const Color(0xFFFFDE59)
                                    : const Color(0xFFFF54B0)),
                            textColor: Colors.black,
                            fontSize: 9.5,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          ),
                          if (isGoodDeal) ...[
                            const SizedBox(width: 4),
                            NeoBrutalBadge(
                              text: context.tr('good_deal_badge'),
                              backgroundColor: const Color(0xFF3B82F6),
                              textColor: Colors.white,
                              fontSize: 9.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Asking Price & Value
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatShort(listing.askingPrice),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                            ),
                          ),
                          Text(
                            context.tr('market_price_label', {'price': CurrencyFormatter.formatShort(car.baseMarketValue)}),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// Market Trend Card (Monolithic Market Pulse)
class DashboardMarketTrendCard extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardMarketTrendCard({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final trend = game.marketTrend;
    final activeNews = game.activeNews;
    final multipliers = trend.bodyTypeMultipliers;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: Colors.black,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  trend.headline,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          if (activeNews != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeNews.title,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFFFFDE59) : const Color(0xFFB45309),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeNews.description,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Multipliers Chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: multipliers.entries.map((e) {
              final isHigh = e.value > 1.0;
              final isLow = e.value < 1.0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isHigh
                      ? const Color(0xFF00E575).withValues(alpha: 0.15)
                      : (isLow
                          ? const Color(0xFFEF4444).withValues(alpha: 0.15)
                          : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isHigh
                        ? const Color(0xFF00E575)
                        : (isLow
                            ? const Color(0xFFEF4444)
                            : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1))),
                    width: 1.1,
                  ),
                ),
                child: Text(
                  '${e.key}: ${(e.value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isHigh
                        ? (isDark ? const Color(0xFF00E575) : const Color(0xFF15803D))
                        : (isLow
                            ? (isDark ? const Color(0xFFFF6B6B) : const Color(0xFFDC2626))
                            : (isDark ? Colors.white70 : const Color(0xFF475569))),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
