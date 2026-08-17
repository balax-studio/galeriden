import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/animated_rolling_counter.dart';
import '../../widgets/car_icons.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_skeleton.dart';
import '../../widgets/pulsing_dot.dart';
import '../../widgets/staggered_item_entry.dart';
import 'interactive_negotiation_sheet.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String _selectedFilter = 'all'; // 'all', 'bargain', 'clean', 'affordable'
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  bool _isRefreshing = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _searchQuery = query.trim().toLowerCase();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final allListings = ref.watch(marketProvider);
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final marketSenseLevel = game.skills.marketSense;
    final trend = game.marketTrend;

    // Filter listings based on active chip filter and search query
    final listings = allListings.where((item) {
      if (_searchQuery.isNotEmpty) {
        final matchBrand = item.car.brand.toLowerCase().contains(_searchQuery);
        final matchModel = item.car.modelName.toLowerCase().contains(_searchQuery);
        final matchBody = item.car.bodyType.toLowerCase().contains(_searchQuery);
        final matchYear = item.car.modelYear.toString().contains(_searchQuery);
        if (!matchBrand && !matchModel && !matchBody && !matchYear) return false;
      }

      if (_selectedFilter == 'bargain') {
        return item.sellerTrait.contains('Fırsat') || item.askingPrice < item.car.estimatedRealValue * 0.88;
      } else if (_selectedFilter == 'clean') {
        return item.car.expertise.bodyParts.values.every((v) => v == PartStatus.original) && !item.car.expertise.isMileageTampered;
      } else if (_selectedFilter == 'affordable') {
        return item.askingPrice <= game.balance;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: 'İKİNCİ EL PAZARI',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Pazarı Yenile',
            onPressed: () async {
              HapticFeedback.lightImpact();
              setState(() => _isRefreshing = true);
              ref.read(gameProvider.notifier).refreshMarketTrends();
              ref.read(marketProvider.notifier).refreshMarket();
              await Future.delayed(const Duration(milliseconds: 400));
              if (mounted) setState(() => _isRefreshing = false);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar with Real-Time Debounce and Clear Button
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141721) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black : const Color(0xFF0F172A),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Marka, model veya kasa tipi ara...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          padding: const EdgeInsets.all(10),
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ),

          // Market Trend & Skill Intel Banner (Neo-Brutal Card)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: p.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.insights_rounded, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trend.headline,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (marketSenseLevel >= 3)
                          Text(
                            'Piyasa Sezgisi (Lv $marketSenseLevel): SUV x${trend.bodyTypeMultipliers['SUV']} | Spor x${trend.bodyTypeMultipliers['Spor']}',
                            style: TextStyle(
                              color: p.primaryColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            'Piyasa Sezgisi Lv 3 ile kâr çarpanları açılır.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Quick Filter Chips Bar (Monolithic Buttons)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tüm İlanlar (${allListings.length})', Icons.directions_car_rounded, p, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('bargain', 'Kelepir Fırsatlar', Icons.local_fire_department_rounded, p, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('clean', 'Hatasız / Boyasız', Icons.verified_user_rounded, p, isDark),
                const SizedBox(width: 8),
                _buildFilterChip('affordable', 'Bütçeme Uygun', Icons.account_balance_wallet_rounded, p, isDark),
              ],
            ),
          ),

          // Sub-Header Info Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Listelenen: ${listings.length} Araç',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Kasa: ${CurrencyFormatter.formatShort(game.balance)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),

          // Listings Scrollable List with Pull-To-Refresh and Skeleton Loading
          Expanded(
            child: RefreshIndicator(
              color: Colors.black,
              backgroundColor: const Color(0xFFFFDE59),
              strokeWidth: 2.5,
              onRefresh: () async {
                HapticFeedback.mediumImpact();
                setState(() => _isRefreshing = true);
                await Future.delayed(const Duration(milliseconds: 450));
                ref.read(gameProvider.notifier).refreshMarketTrends();
                ref.read(marketProvider.notifier).refreshMarket();
                if (mounted) setState(() => _isRefreshing = false);
              },
              child: _isRefreshing
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: EdgeInsets.fromLTRB(14, 8, 14, 24),
                      child: NeoBrutalSkeletonList(itemCount: 4),
                    )
                  : listings.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Text(
                                'Aranan kriterde araç bulunamadı.',
                                style: AppTypography.bodyMedium(p.isDark),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      final car = item.car;
                      final exp = car.expertise;
                      final isFlash = item.sellerTrait.contains('Fırsat');
                      final viewerCount = PsychologyEngine.getLiveViewerCount();

                      // Convert hex string to Color
                      Color carColor;
                      try {
                        carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xFF')));
                      } catch (e) {
                        carColor = p.primaryColor;
                      }

                      // Estimated net profit & ROI calculation
                      final estimatedRepairCost = (100 - exp.engineCondition) * 150 +
                          (100 - exp.transmissionCondition) * 120 +
                          exp.bodyParts.values.where((s) => s == PartStatus.damaged).length * 800;
                      final estNetProfit = car.estimatedRealValue - item.askingPrice - estimatedRepairCost;
                      final estRoi = (estNetProfit / item.askingPrice) * 100;

                      return RepaintBoundary(
                        child: StaggeredItemEntry(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: NeoBrutalCard(
                            padding: const EdgeInsets.all(14),
                            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                            borderColor: car.isRare
                                ? const Color(0xFFA855F7)
                                : (isFlash
                                    ? const Color(0xFFFF7A00)
                                    : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))),
                            borderRadius: 10,
                            borderWidth: 2.5,
                            shadowOffset: const Offset(4.0, 4.0),
                            showDotGrid: true,
                            showHazardHeader: isFlash || car.isBarnFind,
                            onTap: () => context.push('/listing-detail', extra: item),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Tag & Live Viewer FOMO with PulsingDot
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        NeoBrutalBadge(
                                          text: car.bodyType,
                                          backgroundColor: p.secondaryColor.withValues(alpha: 0.2),
                                          textColor: isDark ? p.secondaryColor : const Color(0xFF0F172A),
                                          borderColor: p.secondaryColor,
                                          fontSize: 9.5,
                                        ),
                                        if (car.isBarnFind) ...[
                                          const SizedBox(width: 6),
                                          const NeoBrutalBadge(
                                            text: 'SAMANLIK KELEPİRİ',
                                            backgroundColor: Color(0xFFD97706),
                                            textColor: Colors.white,
                                            fontSize: 9.5,
                                          ),
                                        ] else if (car.isRare) ...[
                                          const SizedBox(width: 6),
                                          const NeoBrutalBadge(
                                            text: 'NADİR KOLEKSİYON',
                                            backgroundColor: Color(0xFFA855F7),
                                            textColor: Colors.white,
                                            fontSize: 9.5,
                                          ),
                                        ],
                                        if (isFlash) ...[
                                          const SizedBox(width: 6),
                                          const NeoBrutalBadge(
                                            text: 'KELEPİR FIRSAT',
                                            backgroundColor: Color(0xFFFF7A00),
                                            textColor: Colors.black,
                                            fontSize: 9.5,
                                          ),
                                        ],
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const PulsingDot(
                                          color: Color(0xFF00E575),
                                          size: 6.5,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$viewerCount kişi bakıyor',
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
                                const SizedBox(height: 10),

                              // Car Header: Silhouette Icon + Name + City
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: CarSilhouetteWidget(
                                      bodyType: car.bodyType,
                                      color: carColor,
                                      width: 52,
                                      height: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${car.brand} ${car.modelName}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.sellerCity} • ${car.modelYear} Model',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Color-Coded Stat Badges (KM, Engine, Tramer, Profit Margin)
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  NeoBrutalBadge(
                                    text: '${(exp.mileage / 1000).toStringAsFixed(0)}K KM',
                                    backgroundColor: StatColors.getMileageColor(exp.mileage).withValues(alpha: 0.2),
                                    textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                    borderColor: StatColors.getMileageColor(exp.mileage),
                                    fontSize: 10,
                                  ),
                                  NeoBrutalBadge(
                                    text: exp.tramerAmount == 0
                                        ? 'Tramer: ₺0'
                                        : 'Tramer: ${CurrencyFormatter.formatShort(exp.tramerAmount.toDouble())}',
                                    backgroundColor: StatColors.getTramerColor(exp.tramerAmount).withValues(alpha: 0.2),
                                    textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                    borderColor: StatColors.getTramerColor(exp.tramerAmount),
                                    fontSize: 10,
                                  ),
                                  NeoBrutalBadge(
                                    text: 'Motor: %${exp.engineCondition.round()}',
                                    backgroundColor: StatColors.getEngineColor(exp.engineCondition).withValues(alpha: 0.2),
                                    textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                    borderColor: StatColors.getEngineColor(exp.engineCondition),
                                    fontSize: 10,
                                  ),
                                  if (estNetProfit > 0)
                                    NeoBrutalBadge(
                                      text: 'Kâr: +${CurrencyFormatter.formatShort(estNetProfit)} (%${estRoi.toStringAsFixed(0)} ROI)',
                                      backgroundColor: estRoi >= 15
                                          ? const Color(0xFF00E575).withValues(alpha: 0.2)
                                          : const Color(0xFFFFDE59).withValues(alpha: 0.2),
                                      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                      borderColor: estRoi >= 15 ? const Color(0xFF00E575) : const Color(0xFFFFDE59),
                                      fontSize: 10,
                                    )
                                  else
                                    NeoBrutalBadge(
                                      text: 'Düşük Marj (${CurrencyFormatter.formatShort(estNetProfit)})',
                                      backgroundColor: const Color(0xFFEF4444).withValues(alpha: 0.15),
                                      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                      borderColor: const Color(0xFFEF4444),
                                      fontSize: 10,
                                    ),
                                  if (exp.isMileageTampered && item.isExpertiseCompleted)
                                    const NeoBrutalBadge(
                                      text: 'ŞÜPHELİ KM!',
                                      backgroundColor: Color(0xFFEF4444),
                                      textColor: Colors.white,
                                      fontSize: 10,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Price & Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'İlan Fiyatı',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                        ),
                                      ),
                                      AnimatedRollingCounter(
                                        value: item.askingPrice,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      NeoBrutalButton(
                                        label: item.isExpertiseCompleted ? 'RAPOR' : 'EKSPERTİZ',
                                        icon: Icons.assignment_outlined,
                                        backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                        textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                        fontSize: 10.5,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        onPressed: () {
                                          context.push('/expertise', extra: item);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      NeoBrutalButton(
                                        label: 'TEKLİF VER & PAZARLIK ET',
                                        icon: Icons.handshake_rounded,
                                        backgroundColor: const Color(0xFFFFDE59),
                                        textColor: Colors.black,
                                        fontSize: 11,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (ctx) => InteractiveNegotiationSheet(listing: item),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                ),
            ),
          ),
      ],
    ),
  );
}

  Widget _buildFilterChip(
    String key,
    String label,
    IconData icon,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final isSelected = _selectedFilter == key;
    final activeBg = const Color(0xFFFFDE59);
    final inactiveBg = isDark ? const Color(0xFF141721) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = key);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : inactiveBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)) : borderColor,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black : (isDark ? p.primaryColor : const Color(0xFF0F172A)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
