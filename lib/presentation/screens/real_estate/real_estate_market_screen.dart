import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/real_estate_market_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/ads/neo_brutal_native_ad_card.dart';
import 'real_estate_negotiation_screen.dart';

class RealEstateMarketScreen extends ConsumerStatefulWidget {
  const RealEstateMarketScreen({super.key});

  @override
  ConsumerState<RealEstateMarketScreen> createState() =>
      _RealEstateMarketScreenState();
}

class _RealEstateMarketScreenState extends ConsumerState<RealEstateMarketScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);
    final allListings = ref.watch(realEstateMarketProvider);
    final activeFilter = ref.watch(realEstateMarketFilterProvider);
    final searchQuery = ref.watch(realEstateMarketSearchProvider);

    final filteredListings = allListings.where((listing) {
      if (activeFilter != null && listing.realEstate.category != activeFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchTitle = listing.realEstate.title.toLowerCase().contains(query);
        final matchCity = listing.realEstate.city.toLowerCase().contains(query);
        final matchDistrict =
            listing.realEstate.district.toLowerCase().contains(query);
        return matchTitle || matchCity || matchDistrict;
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: NeoBrutalAppBar(
        title: context.tr('real_estate_market_title'),
        subtitle: context.tr('real_estate_market_subtitle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: context.tr('real_estate_btn_refresh_market'),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(realEstateMarketProvider.notifier).refreshMarket();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status bar (Balance & Portfolio Slot Counter)
            _buildStatusBar(game),

            // Tab Bar: Market vs Portfolio
            Container(
              color: theme.colorScheme.surface,
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.black,
                indicatorWeight: 3,
                labelColor: Colors.black,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                unselectedLabelColor: Colors.grey.shade600,
                tabs: [
                  Tab(
                    icon: const Icon(Icons.storefront_rounded, size: 20),
                    text: context.tr('real_estate_tab_market'),
                  ),
                  Tab(
                    icon: const Icon(Icons.apartment_rounded, size: 20),
                    text:
                        '${context.tr('real_estate_tab_portfolio')} • ${game.ownedRealEstates.length}',
                  ),
                ],
              ),
            ),

            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Market Listings
                  _buildMarketTab(
                    theme,
                    filteredListings,
                    activeFilter,
                    game,
                  ),

                  // Tab 2: Owned Portfolio
                  _buildPortfolioTab(theme, game),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(dynamic game) {
    final isFull = game.ownedRealEstates.length >= game.maxRealEstateSlots;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        border: const Border(bottom: BorderSide(color: Colors.black, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                CurrencyFormatter.format(game.balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.holiday_village_rounded,
                color: isFull ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '${context.tr('real_estate_slots_badge')}: ${game.ownedRealEstates.length} / ${game.maxRealEstateSlots}',
                style: TextStyle(
                  color: isFull ? const Color(0xFFFCA5A5) : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketTab(
    ThemeData theme,
    List<RealEstateListingModel> listings,
    RealEstateCategory? activeFilter,
    dynamic game,
  ) {
    return Column(
      children: [
        // Category Filter Pills Bar
        _buildCategoryPillsBar(activeFilter),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              ref.read(realEstateMarketSearchProvider.notifier).state = val;
            },
            decoration: InputDecoration(
              hintText: context.tr('real_estate_search_hint'),
              hintStyle: const TextStyle(fontSize: 12),
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(realEstateMarketSearchProvider.notifier).state =
                            '';
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
          ),
        ),

        // Listings List
        Expanded(
          child: listings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.home_work_outlined,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('real_estate_empty_listings'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    final showNativeAd = index > 0 && index % 4 == 0;

                    final card = _buildListingCard(theme, listing, game);

                    if (showNativeAd) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const NeoBrutalNativeAdCard(
                            contextType: NativeAdContextType.marketplace,
                            margin: EdgeInsets.only(bottom: 14),
                          ),
                          card,
                        ],
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: card,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildCategoryPillsBar(RealEstateCategory? activeFilter) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(
            label: context.tr('real_estate_filter_all'),
            count: null,
            isSelected: activeFilter == null,
            onTap: () => ref
                .read(realEstateMarketProvider.notifier)
                .setCategoryFilter(null),
          ),
          ...RealEstateCategory.values.map((cat) {
            return _buildFilterChip(
              label: context.tr(cat.localizationKey),
              count: cat.catalogCount,
              icon: cat.icon,
              accentColor: cat.accentColor,
              isSelected: activeFilter == cat,
              onTap: () => ref
                  .read(realEstateMarketProvider.notifier)
                  .setCategoryFilter(cat),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    int? count,
    IconData? icon,
    Color? accentColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (accentColor ?? Colors.black)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.black : Colors.grey.shade400,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                count != null ? '$label • ${_formatCount(count)}' : label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListingCard(
    ThemeData theme,
    RealEstateListingModel listing,
    dynamic game,
  ) {
    final re = listing.realEstate;
    final isFull = game.ownedRealEstates.length >= game.maxRealEstateSlots;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Icon & Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: re.category.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: re.category.accentColor, width: 2),
                ),
                child: Icon(re.category.icon,
                    color: re.category.accentColor, size: 24),
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
                            re.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (listing.isHotDeal) ...[
                          const SizedBox(width: 6),
                          NeoBrutalBadge(
                            text: context.tr('real_estate_badge_hot_deal'),
                            backgroundColor: const Color(0xFFFEE2E2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${re.city} • ${re.district}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Specs Badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              NeoBrutalBadge(
                text: '${re.squareMeters} m²',
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text: re.roomCount,
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text:
                    '${re.buildingAge} ${context.tr('real_estate_badge_years_old')}',
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              NeoBrutalBadge(
                text: context.tr(re.deedType.localizationKey),
                backgroundColor: re.deedType == DeedType.ownershipDeed
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEF3C7),
              ),
              NeoBrutalBadge(
                text: context.tr(re.sellerType.localizationKey),
                backgroundColor: const Color(0xFFEDE9FE),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Seller description
          Text(
            listing.description,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
              height: 1.3,
            ),
          ),

          const Divider(height: 18),

          // Cost Breakdown Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('real_estate_label_asking_price'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(listing.askingPrice),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '+${CurrencyFormatter.format(listing.estimatedDeedFee + RealEstateListingModel.revolvingFundFee + listing.estimatedCommission)} ${context.tr('real_estate_label_fees')}',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              NeoBrutalButton(
                label: isFull
                    ? context.tr('real_estate_btn_slots_full')
                    : context.tr('real_estate_btn_negotiate'),
                icon: isFull ? Icons.block_rounded : Icons.handshake_rounded,
                onPressed: isFull
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                RealEstateNegotiationScreen(listing: listing),
                          ),
                        );
                      },
                backgroundColor: const Color(0xFFF59E0B),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioTab(ThemeData theme, dynamic game) {
    final List<RealEstateModel> properties = game.ownedRealEstates;

    if (properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.domain_disabled_rounded,
                  size: 56, color: Colors.grey),
              const SizedBox(height: 14),
              Text(
                context.tr('real_estate_empty_portfolio_title'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('real_estate_empty_portfolio_subtitle'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final prop = properties[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildPortfolioCard(theme, prop, game),
        );
      },
    );
  }

  Widget _buildPortfolioCard(
      ThemeData theme, RealEstateModel property, dynamic game) {
    final fairValue = property.estimatedRealValue;
    final totalAcquisition = property.currentPurchasePrice +
        property.deedFeePaid +
        property.commissionPaid;
    final potentialProfit = fairValue - totalAcquisition;
    final renovationCost = property.category.renovationBaseCost;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: property.category.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: property.category.accentColor, width: 2),
                ),
                child: Icon(property.category.icon,
                    color: property.category.accentColor, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${property.city} • ${property.district} • ${property.squareMeters} m²',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status badges
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (property.isRented)
                NeoBrutalBadge(
                  text:
                      '${context.tr('real_estate_badge_rented')} • ${CurrencyFormatter.format(property.dailyRentIncome)}/${context.tr('real_estate_unit_day')}',
                  backgroundColor: const Color(0xFFD1FAE5),
                )
              else
                NeoBrutalBadge(
                  text: context.tr('real_estate_badge_vacant'),
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              if (property.isRenovated)
                NeoBrutalBadge(
                  text: context.tr('real_estate_badge_renovated'),
                  backgroundColor: const Color(0xFFFEF3C7),
                ),
              NeoBrutalBadge(
                text: context.tr(property.deedType.localizationKey),
                backgroundColor: const Color(0xFFE2E8F0),
              ),
            ],
          ),

          const Divider(height: 20),

          // Financial Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr('real_estate_label_estimated_value'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(fairValue),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '${potentialProfit >= 0 ? '+' : ''}${CurrencyFormatter.format(potentialProfit)} ${context.tr('real_estate_label_flipping_profit')}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: potentialProfit >= 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),

              // Action Buttons
              Row(
                children: [
                  // Renovation button (if not renovated yet)
                  if (!property.isRenovated) ...[
                    OutlinedButton(
                      onPressed: game.balance >= renovationCost
                          ? () {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(gameProvider.notifier)
                                  .renovateRealEstate(property.id);
                              NotificationService.showSuccess(
                                context,
                                context.tr('real_estate_renovation_success_toast'),
                              );
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                      ),
                      child: Text(
                        '${context.tr('real_estate_btn_renovate')} • ${CurrencyFormatter.format(renovationCost)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],

                  // Rent toggle button
                  IconButton(
                    icon: Icon(
                      property.isRented
                          ? Icons.money_off_csred_rounded
                          : Icons.monetization_on_rounded,
                      color: property.isRented
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                    ),
                    tooltip: property.isRented
                        ? context.tr('real_estate_tooltip_stop_rent')
                        : context.tr('real_estate_tooltip_start_rent'),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(gameProvider.notifier)
                          .toggleRealEstateRent(property.id);
                    },
                  ),

                  // Sell property button
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      ref.read(gameProvider.notifier).sellRealEstate(
                            realEstateId: property.id,
                            salePrice: fairValue,
                          );
                      NotificationService.showSuccess(
                        context,
                        context.tr('real_estate_sell_success_toast'),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    child: Text(
                      context.tr('real_estate_btn_sell'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      final s = count.toString();
      return s.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      );
    }
    return count.toString();
  }
}
