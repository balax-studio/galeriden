import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/vehicle_category.dart';
import '../../providers/game_provider.dart';
import '../../providers/vasita_market_provider.dart';
import '../../widgets/ads/neo_brutal_native_ad_card.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_page_background.dart';
import 'vasita_expertise_screen.dart';
import 'vasita_negotiation_screen.dart';

class VasitaMarketScreen extends ConsumerStatefulWidget {
  const VasitaMarketScreen({super.key});

  @override
  ConsumerState<VasitaMarketScreen> createState() => _VasitaMarketScreenState();
}

class _VasitaMarketScreenState extends ConsumerState<VasitaMarketScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

    // Generate random ad positions
    final Random adRandom = Random(game.currentDay);
    final Set<int> adIndices = {};
    int nextAd = adRandom.nextInt(3) + 2; // 2-4 interval
    while (nextAd < filteredListings.length) {
      adIndices.add(nextAd);
      nextAd += adRandom.nextInt(3) + 2;
    }
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
                      HapticFeedback.mediumImpact();
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
                    icon: Icons.apps_rounded,
                    activeColor: AppColors.brutalYellow,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(vasitaMarketProvider.notifier).setCategoryFilter(null);
                    },
                  ),
                  ...VehicleCategory.values
                      .where((cat) => cat != VehicleCategory.car)
                      .map((cat) {
                    final isSelected = activeFilter == cat;
                    return _buildCategoryChip(
                      context: context,
                      isSelected: isSelected,
                      label: context.tr(cat.localizationKey),
                      icon: cat.icon,
                      activeColor: cat.badgeColor,
                      isDark: isDark,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(vasitaMarketProvider.notifier).setCategoryFilter(cat);
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // 2.5 Reactive Status Bar: Garage Capacity & Listing Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141721) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warehouse_rounded,
                          size: 16,
                          color: game.ownedCars.length >= game.maxGarageSlots
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF00E575),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${context.tr('vasita_garage_slots_badge')}: ${game.ownedCars.length} / ${game.maxGarageSlots}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: game.ownedCars.length >= game.maxGarageSlots
                                ? const Color(0xFFEF4444)
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${filteredListings.length} • ${context.tr('vasita_filter_all')}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

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
                  : RefreshIndicator(
                      color: Colors.black,
                      backgroundColor: AppColors.brutalYellow,
                      onRefresh: () async {
                        HapticFeedback.lightImpact();
                        ref.read(vasitaMarketProvider.notifier).refreshMarket();
                        NotificationService.showInfo(
                          context,
                          context.tr('vasita_market_refreshed'),
                        );
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                        physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics()),
                        itemCount: filteredListings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, index) {
                          final listing = filteredListings[index];
                          final showAdBefore = AdService.shouldShowNativeAdForDay(
                                  game.currentDay,
                                  NativeAdContextType.marketplace) &&
                              adIndices.contains(index);

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
    final lockedListings = ref.watch(vasitaLockedListingsProvider);
    final isLocked = lockedListings.contains(listing.id);

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
          if (isLocked) ...[
            const SizedBox(height: 6),
            NeoBrutalBadge(
              text: context.tr('vasita_badge_locked_today'),
              icon: Icons.block_rounded,
              backgroundColor: const Color(0xFFEF4444),
              textColor: Colors.white,
              fontSize: 9.5,
            ),
          ] else if (listing.isExpertiseCompleted) ...[
            const SizedBox(height: 6),
            NeoBrutalBadge(
              text: context.tr('vasita_expertise_seal_text'),
              icon: Icons.verified_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 9.5,
            ),
          ],
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
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => VasitaExpertiseScreen(
                        listingId: listing.id,
                        initialListing: listing,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              NeoBrutalButton(
                icon: isLocked ? Icons.block_rounded : Icons.handshake_rounded,
                label: isLocked
                    ? context.tr('vasita_badge_locked_today')
                    : (maxSlotsReached
                        ? context.tr('vasita_btn_garage_full')
                        : context.tr('vasita_btn_start_negotiation')),
                backgroundColor: isLocked
                    ? const Color(0xFF64748B)
                    : (maxSlotsReached
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF00E575)),
                textColor: isLocked ? Colors.white : Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                onPressed: (maxSlotsReached || isLocked)
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VasitaNegotiationScreen(listing: listing),
                          ),
                        );
                      },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
