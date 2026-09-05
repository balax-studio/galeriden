import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../domain/usecases/zoning_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/real_estate_market_provider.dart';
import '../../widgets/ads/neo_brutal_native_ad_card.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import 'real_estate_negotiation_screen.dart';
import 'widgets/real_estate_offers_sheet.dart';

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

  void _confirmExpandSlots(BuildContext context) {
    HapticFeedback.selectionClick();
    final cost = ref.read(gameProvider.notifier).realEstateSlotExpansionCost;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
        title: Text(
          context.tr('real_estate_expand_slots_dialog_title'),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        content: Text(
          context.tr('real_estate_expand_confirm_content', {'cost': CurrencyFormatter.format(cost)}),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              context.tr('real_estate_dialog_btn_cancel'),
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              final success =
                  ref.read(gameProvider.notifier).expandRealEstateSlots();
              if (success) {
                NotificationService.showSuccess(
                  context,
                  context.tr('real_estate_expand_slots_success_toast'),
                );
              } else {
                NotificationService.showError(
                  context,
                  context.tr('real_estate_expand_slots_error_funds'),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
            child: Text(
              '${context.tr('real_estate_expand_slots_btn')} • ${CurrencyFormatter.formatShort(cost)}',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSellListing(
    BuildContext context,
    RealEstateModel property,
  ) {
    if (property.isRented) {
      NotificationService.showWarning(
        context,
        context.tr('real_estate_sale_blocked_rented'),
      );
      return;
    }
    if (property.isPersonalResidence) {
      NotificationService.showWarning(
        context,
        context.tr('real_estate_sale_blocked_residence'),
      );
      return;
    }
    if (property.isUnderRenovation) {
      NotificationService.showWarning(
        context,
        context.tr('real_estate_sale_blocked_renovation'),
      );
      return;
    }
    if (property.isConstructionActive) {
      NotificationService.showWarning(
        context,
        context.tr('real_estate_sale_blocked_construction'),
      );
      return;
    }

    context.push('/emlak-ilan/${property.id}');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final game = ref.watch(gameProvider);

    if (!game.isFeatureUnlocked('/emlak')) {
      return Scaffold(
        appBar: NeoBrutalAppBar(
          title: context.tr('real_estate_market_title'),
          subtitle: context.tr('real_estate_market_subtitle'),
        ),
        body: NeoBrutalLockedFeatureView(
          route: '/emlak',
          featureTitle: context.tr('real_estate_market_title'),
          icon: Icons.domain_rounded,
        ),
      );
    }

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
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(bottom: BorderSide(color: Colors.black, width: 2)),
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
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _confirmExpandSlots(context),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded, size: 14, color: Colors.black),
                      Text(
                        '${context.tr('real_estate_expand_slots_btn')} • ${CurrencyFormatter.formatShort(ref.watch(gameProvider.notifier).realEstateSlotExpansionCost)}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
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
            isSelected: activeFilter == null,
            onTap: () => ref
                .read(realEstateMarketProvider.notifier)
                .setCategoryFilter(null),
          ),
          ...RealEstateCategory.values.map((cat) {
            return _buildFilterChip(
              label: context.tr(cat.localizationKey),
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
                label,
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
              if (re.category == RealEstateCategory.land) ...[
                Builder(builder: (_) {
                  final z = ZoningEngine.calculateZoning(
                    parcelSquareMeters: re.squareMeters.toDouble(),
                  );
                  return NeoBrutalBadge(
                    text: 'İMAR • KAKS ${z.kaks.toStringAsFixed(2)} • ${z.calculatedFloors} Kat • ${z.totalUnits} Daire',
                    backgroundColor: const Color(0xFFEFF6FF),
                    textColor: const Color(0xFF1D4ED8),
                  );
                }),
              ],
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

    final totalPendingRent =
        properties.fold<double>(0.0, (sum, p) => sum + p.pendingRentIncome);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 1. UNCOLLECTED RENT LOSS-AVERSION POOL BANNER
        if (totalPendingRent > 0) ...[
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: const Color(0xFFD1FAE5),
            borderColor: const Color(0xFF059669),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.savings_rounded,
                          color: Color(0xFF059669),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          context.tr('real_estate_rent_pool_title'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(totalPendingRent),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('real_estate_rent_pool_desc'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: NeoBrutalButton(
                    label:
                        '${context.tr('real_estate_rent_collect_all_btn')} • ${CurrencyFormatter.format(totalPendingRent)}',
                    icon: Icons.account_balance_wallet_rounded,
                    backgroundColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      final collected = ref
                          .read(gameProvider.notifier)
                          .collectAllPendingRents();
                      if (collected > 0) {
                        NotificationService.showSuccess(
                          context,
                          context.tr('real_estate_rent_collect_toast',
                              {'amount': CurrencyFormatter.format(collected)}),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: NeoBrutalButton(
                    label: context.tr('rental_screen_title'),
                    icon: Icons.key_rounded,
                    backgroundColor: const Color(0xFFFEF08A),
                    textColor: Colors.black,
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/emlak-kiralama');
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 2. OWNED PROPERTIES LIST
        ...properties.map(
          (prop) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildPortfolioCard(theme, prop, game),
          ),
        ),
      ],
    );
  }

  Widget _buildPortfolioCard(
      ThemeData theme, RealEstateModel property, dynamic game) {
    final fairValue = property.estimatedRealValue;
    final totalAcquisition = property.currentPurchasePrice +
        property.deedFeePaid +
        property.commissionPaid;
    final potentialProfit = fairValue - totalAcquisition;
    final isDark = theme.brightness == Brightness.dark;

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
              if (property.isPersonalResidence)
                NeoBrutalBadge(
                  text:
                      '${context.tr('real_estate_residence_badge')} • +${property.personalResidencePrestigeBonus} PRESTİJ',
                  backgroundColor: const Color(0xFFE0E7FF),
                  textColor: const Color(0xFF3730A3),
                ),
              if (property.isRented)
                NeoBrutalBadge(
                  text:
                      '${context.tr('real_estate_badge_rented')} • ${CurrencyFormatter.format(property.dailyRentIncome)}/${context.tr('real_estate_unit_day')}',
                  backgroundColor: const Color(0xFFD1FAE5),
                )
              else if (!property.isPersonalResidence)
                NeoBrutalBadge(
                  text: context.tr('real_estate_badge_vacant'),
                  backgroundColor: const Color(0xFFF1F5F9),
                ),
              if (property.isUnderRenovation)
                NeoBrutalBadge(
                  text: 'TADİLAT SÜRÜYOR • %${property.renovationPercent}',
                  backgroundColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFF92400E),
                )
              else if (property.isRenovated)
                NeoBrutalBadge(
                  text: context.tr('real_estate_badge_renovated'),
                  backgroundColor: const Color(0xFFD1FAE5),
                ),
              if (property.hasWaterLeakRisk)
                NeoBrutalBadge(
                  text: context.tr('real_estate_leak_badge'),
                  backgroundColor: const Color(0xFFFEE2E2),
                  textColor: const Color(0xFF991B1B),
                ),
              if (property.category == RealEstateCategory.land) ...[
                Builder(builder: (_) {
                  final z = ZoningEngine.calculateZoning(
                    parcelSquareMeters: property.squareMeters.toDouble(),
                  );
                  return NeoBrutalBadge(
                    text: 'KAKS ${z.kaks.toStringAsFixed(2)} • ${z.totalConstructionArea.round()} m²',
                    backgroundColor: const Color(0xFFDBEAFE),
                    textColor: const Color(0xFF1D4ED8),
                  );
                }),
                if (property.isConstructionActive)
                  NeoBrutalBadge(
                    text: property.constructionStage >= 8
                        ? context.tr('real_estate_construction_badge_ready')
                        : '${context.tr('real_estate_construction_badge_active')} • %${property.constructionPercent}',
                    backgroundColor: property.constructionStage >= 8
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEF3C7),
                    textColor: property.constructionStage >= 8
                        ? const Color(0xFF065F46)
                        : const Color(0xFF92400E),
                  )
                else
                  NeoBrutalBadge(
                    text: context.tr('real_estate_construction_badge_idle'),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
              ],
              NeoBrutalBadge(
                text: context.tr(property.deedType.localizationKey),
                backgroundColor: const Color(0xFFE2E8F0),
              ),
              if (property.isPersonalResidence)
                const NeoBrutalBadge(
                  text: 'İkametgah',
                  backgroundColor: Color(0xFFEEF2FF),
                  textColor: Color(0xFF4F46E5),
                ),
              if (property.isRented)
                NeoBrutalBadge(
                  text: 'Kirada • ${property.currentTenant?.name ?? 'Kiracı'}',
                  backgroundColor: const Color(0xFFD1FAE5),
                  textColor: const Color(0xFF065F46),
                )
              else if (property.isRentalListed)
                const NeoBrutalBadge(
                  text: 'Kiralık İlanda',
                  backgroundColor: Color(0xFFDBEAFE),
                  textColor: Color(0xFF1D4ED8),
                ),
              if (property.isListed) ...[
                NeoBrutalBadge(
                  text: 'Satılık • ${CurrencyFormatter.formatShort(property.customListingPrice ?? fairValue)}',
                  backgroundColor: const Color(0xFFFEF3C7),
                  textColor: const Color(0xFF92400E),
                ),
                if (property.activeOffers.isNotEmpty)
                  NeoBrutalBadge(
                    text: 'Gelen Teklif • ${property.activeOffers.length}',
                    backgroundColor: const Color(0xFFD1FAE5),
                    textColor: const Color(0xFF065F46),
                  ),
              ],
            ],
          ),

          // Pending rent loss-aversion banner inside property
          if (property.pendingRentIncome > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: property.uncollectedRentDays >= 3
                    ? (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEF2F2))
                    : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: property.uncollectedRentDays >= 3
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF059669),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${context.tr('real_estate_rent_pool_title')}: ${CurrencyFormatter.format(property.pendingRentIncome)} • ${property.uncollectedRentDays} ${context.tr('day')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: property.uncollectedRentDays >= 3
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF059669),
                          ),
                        ),
                        if (property.uncollectedRentDays >= 3)
                          Text(
                            context.tr('real_estate_rent_delay_warning'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      final collected = ref
                          .read(gameProvider.notifier)
                          .collectRent(property.id);
                      if (collected > 0) {
                        NotificationService.showSuccess(
                          context,
                          context.tr('real_estate_rent_collect_toast',
                              {'amount': CurrencyFormatter.format(collected)}),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    child: Text(
                      context.tr('real_estate_rent_collect_btn'),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Divider(height: 20),

          // Financial Value & Actions
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
                  // Land Construction Project Button -> navigates to /emlak-insaat/:id
                  if (property.category == RealEstateCategory.land) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push('/emlak-insaat/${property.id}');
                      },
                      icon: const Icon(Icons.architecture_rounded, size: 14),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: property.isConstructionActive
                            ? (property.constructionStage >= 8
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7))
                            : const Color(0xFFE0E7FF),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                      ),
                      label: Text(
                        property.isConstructionActive
                            ? (property.constructionStage >= 8
                                ? context.tr('real_estate_construction_badge_ready')
                                : '${context.tr('real_estate_btn_manage_construction')} • %${property.constructionPercent}')
                            : context.tr('real_estate_btn_start_construction'),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ] else if (!property.isRenovated || property.hasWaterLeakRisk) ...[
                    // Renovation Button -> navigates to /emlak-tadilat/:id
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        context.push('/emlak-tadilat/${property.id}');
                      },
                      icon: const Icon(Icons.handyman_rounded, size: 14),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: property.hasWaterLeakRisk
                            ? const Color(0xFFFEE2E2)
                            : (property.isUnderRenovation
                                ? const Color(0xFFFEF3C7)
                                : Colors.white),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                      ),
                      label: Text(
                        property.hasWaterLeakRisk
                            ? context.tr('real_estate_leak_badge')
                            : (property.renovationStage > 0
                                ? '${context.tr('real_estate_badge_under_renovation')} • %${property.renovationPercent}'
                                : context.tr('real_estate_btn_renovate')),
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Personal Residence Toggle Button (strictly housing only)
                  if (property.isPersonalResidence)
                    IconButton(
                      icon: const Icon(
                        Icons.home_work_rounded,
                        color: Color(0xFF4F46E5),
                      ),
                      tooltip: context.tr('real_estate_vacate_residence_btn'),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        ref
                            .read(gameProvider.notifier)
                            .vacatePersonalResidence(property.id);
                        NotificationService.showInfo(
                          context,
                          context.tr('real_estate_residence_vacated_toast'),
                        );
                      },
                    )
                  else if (property.canBePersonalResidence)
                    IconButton(
                      icon: const Icon(
                        Icons.add_home_work_rounded,
                        color: Color(0xFF64748B),
                      ),
                      tooltip: context.tr('real_estate_set_residence_btn'),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        final ok = ref
                            .read(gameProvider.notifier)
                            .setPersonalResidence(property.id);
                        if (ok) {
                          NotificationService.showSuccess(
                            context,
                            context.tr('real_estate_residence_toast'),
                          );
                        }
                      },
                    ),

                  // Rental Portal Button
                  IconButton(
                    icon: Icon(
                      property.isRented
                          ? Icons.key_rounded
                          : Icons.monetization_on_rounded,
                      color: property.isRented
                          ? const Color(0xFF10B981)
                          : (property.isRentalListed
                              ? const Color(0xFF3B82F6)
                              : (property.canBeRented
                                  ? const Color(0xFF64748B)
                                  : Colors.grey)),
                    ),
                    tooltip: context.tr('rental_portal_title'),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context.push('/emlak-kiralama/${property.id}');
                    },
                  ),

                  // Showcase offers button (if listed and has offers)
                  if (property.isListed && property.activeOffers.isNotEmpty) ...[
                    OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        RealEstateOffersSheet.show(context: context, property: property);
                      },
                      icon: const Icon(Icons.local_offer_rounded, size: 14),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: const Color(0xFFD1FAE5),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      ),
                      label: Text(
                        context.tr('real_estate_btn_offers_count', {'count': property.activeOffers.length}),
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],

                  // Unified Listing & Sale button
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      _navigateToSellListing(context, property);
                    },
                    icon: Icon(
                      property.isListed ? Icons.storefront_rounded : Icons.campaign_rounded,
                      size: 14,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !property.canBeSold
                          ? const Color(0xFF94A3B8)
                          : (property.isListed ? const Color(0xFFFEF08A) : const Color(0xFF10B981)),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: Colors.black, width: 1.5),
                      ),
                    ),
                    label: Text(
                      property.isListed
                          ? context.tr('real_estate_btn_manage_listing')
                          : context.tr('real_estate_btn_list_for_sale'),
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
}
