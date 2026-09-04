import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/vehicle_category.dart';
import '../../providers/game_provider.dart';
import '../../providers/vasita_market_provider.dart';
import '../../../core/services/ad_service.dart';
import '../../widgets/ads/neo_brutal_native_ad_card.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_page_background.dart';

class VasitaMarketScreen extends ConsumerStatefulWidget {
  const VasitaMarketScreen({super.key});

  @override
  ConsumerState<VasitaMarketScreen> createState() => _VasitaMarketScreenState();
}

class _VasitaMarketScreenState extends ConsumerState<VasitaMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _purchasingListingId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final allListings = ref.watch(vasitaMarketProvider);
    final activeFilter = ref.watch(vasitaMarketFilterProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    // Filter by search query
    final filteredListings = allListings.where((l) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final titleMatch = l.title.toLowerCase().contains(query);
      final brandMatch = l.car.brand.toLowerCase().contains(query);
      final modelMatch = l.car.modelName.toLowerCase().contains(query);
      final cityMatch = l.sellerCity.toLowerCase().contains(query);
      return titleMatch || brandMatch || modelMatch || cityMatch;
    }).toList();

    return Scaffold(
      appBar: NeoBrutalAppBar(
        title: context.tr('vasita_market_title'),
        subtitle: context.tr('vasita_market_desc'),
        showLeading: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: NeoBrutalBadge(
                text: CurrencyFormatter.formatShort(game.balance),
                icon: Icons.account_balance_wallet_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.carWash,
        child: Column(
          children: [
            // 1. Search Bar & Refresh Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141721) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        decoration: InputDecoration(
                          hintText: context.tr('search_cars_hint'),
                          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF64748B)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeoBrutalButton(
                    icon: Icons.refresh_rounded,
                    label: context.tr('market_refresh_tooltip'),
                    backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    onPressed: () {
                      ref.read(vasitaMarketProvider.notifier).refreshMarket();
                    },
                  ),
                ],
              ),
            ),

            // 2. Category Selector Chips
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCategoryChip(
                    context: context,
                    isSelected: activeFilter == null,
                    label: context.tr('vasita_filter_all'),
                    countText: '485K',
                    icon: Icons.apps_rounded,
                    activeColor: AppColors.brutalYellow,
                    isDark: isDark,
                    onTap: () => ref.read(vasitaMarketProvider.notifier).setCategoryFilter(null),
                  ),
                  ...VehicleCategory.values
                      .where((cat) => cat != VehicleCategory.car)
                      .map((cat) {
                    final isSelected = activeFilter == cat;
                    return _buildCategoryChip(
                      context: context,
                      isSelected: isSelected,
                      label: context.tr(cat.localizationKey),
                      countText: _formatCatalogCount(cat.catalogCount),
                      icon: cat.icon,
                      activeColor: cat.badgeColor,
                      isDark: isDark,
                      onTap: () => ref.read(vasitaMarketProvider.notifier).setCategoryFilter(cat),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. Listings View
            Expanded(
              child: filteredListings.isEmpty
                  ? Center(
                      child: NeoBrutalEmptyState(
                        icon: Icons.search_off_rounded,
                        title: context.tr('empty_cars_found'),
                        description: context.tr('empty_filtered_cars'),
                        actionLabel: context.tr('market_refresh_tooltip'),
                        onActionPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          ref.read(vasitaMarketProvider.notifier).setCategoryFilter(null);
                        },
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredListings.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final listing = filteredListings[index];
                        final showAdBefore = AdService.shouldShowNativeAdForDay(
                                game.currentDay,
                                NativeAdContextType.marketplace) &&
                            index > 0 &&
                            index % 4 == 0;

                        final listingWidget = _buildListingCard(
                          context: context,
                          listing: listing,
                          gameBalance: game.balance,
                          maxSlotsReached: game.ownedCars.length >= game.maxGarageSlots,
                          isDark: isDark,
                        );

                        if (showAdBefore) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const NeoBrutalNativeAdCard(
                                contextType: NativeAdContextType.marketplace,
                                margin: EdgeInsets.only(bottom: 12),
                              ),
                              listingWidget,
                            ],
                          );
                        }

                        return listingWidget;
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required bool isSelected,
    required String label,
    required String countText,
    required IconData icon,
    required Color activeColor,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF141721) : Colors.white),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? Colors.black
                  : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
              width: isSelected ? 2.2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black26 : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  countText,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.black : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard({
    required BuildContext context,
    required ListingModel listing,
    required double gameBalance,
    required bool maxSlotsReached,
    required bool isDark,
  }) {
    final car = listing.car;
    final cat = car.vehicleCategory;
    final canAfford = gameBalance >= listing.askingPrice;
    final isPurchasing = _purchasingListingId == listing.id;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Category Badge & Rarity Badge
          Row(
            children: [
              NeoBrutalBadge(
                text: context.tr(cat.localizationKey),
                icon: cat.icon,
                backgroundColor: cat.badgeColor,
                textColor: Colors.black,
                fontSize: 10,
              ),
              const SizedBox(width: 6),
              NeoBrutalBadge(
                text: context.tr(cat.rarityKey),
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white70 : Colors.black87,
                fontSize: 9.5,
              ),
              const Spacer(),
              Text(
                '${listing.sellerCity} • ${listing.sellerName}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title & Year
          Text(
            '${car.brand} ${car.modelName}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 3),
          Text(
            '${context.tr('car_spec_year')}: ${car.modelYear} • ${car.bodyType} • ${car.expertise.mileage} ${cat == VehicleCategory.aircraft ? 'Saat' : 'KM'}',
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          // Condition Bars Row
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.speed_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${context.tr('car_expertise_engine')}: %${car.expertise.engineCondition.toInt()}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.settings_rounded, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        '${context.tr('car_expertise_transmission')}: %${car.expertise.transmissionCondition.toInt()}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Description
          Text(
            listing.description,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: Color(0xFF64748B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),

          // Footer: Price & Action Buttons
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('car_card_market_value'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(listing.askingPrice),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: canAfford ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              NeoBrutalButton(
                icon: Icons.assignment_outlined,
                label: context.tr('btn_inspect_expertise'),
                backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                textColor: isDark ? Colors.white : Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                onPressed: () => _showInspectionDialog(context, listing, isDark),
              ),
              const SizedBox(width: 6),
              NeoBrutalButton(
                icon: Icons.shopping_cart_checkout_rounded,
                label: isPurchasing ? '...' : context.tr('vasita_buy_button'),
                backgroundColor: canAfford && !maxSlotsReached && !isPurchasing
                    ? const Color(0xFF00E575)
                    : const Color(0xFF94A3B8),
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: (!canAfford || maxSlotsReached || isPurchasing)
                    ? null
                    : () => _handlePurchase(context, listing),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInspectionDialog(BuildContext context, ListingModel listing, bool isDark) {
    final car = listing.car;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          title: Row(
            children: [
              Icon(car.vehicleCategory.icon, color: car.vehicleCategory.badgeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('vasita_inspect_title'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${car.brand} ${car.modelName} • ${car.modelYear}',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  '${context.tr('car_spec_year')}: ${car.modelYear} • ${car.bodyType}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const Divider(height: 20),
                Text(
                  '${context.tr('car_expertise_engine')}: %${car.expertise.engineCondition.toInt()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr('car_expertise_transmission')}: %${car.expertise.transmissionCondition.toInt()}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '${context.tr('listing_tramer')}: ${CurrencyFormatter.format(car.expertise.tramerAmount.toDouble())}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 10),
                Text(
                  listing.description,
                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          actions: [
            NeoBrutalButton(
              label: context.tr('btn_close'),
              backgroundColor: AppColors.brutalYellow,
              textColor: Colors.black,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePurchase(BuildContext context, ListingModel listing) async {
    setState(() => _purchasingListingId = listing.id);

    try {
      final success = ref.read(vasitaMarketProvider.notifier).buyVasita(listing);
      if (success && mounted) {
        NotificationService.showSuccess(
          context,
          context.tr('vasita_buy_success'),
        );
      } else if (mounted) {
        NotificationService.showError(
          context,
          context.tr('err_insufficient_cash'),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingListingId = null);
      }
    }
  }

  String _formatCatalogCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(count >= 10000 ? 0 : 1)}K';
    }
    return count.toString();
  }
}
