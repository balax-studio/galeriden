import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../../domain/usecases/collection_album_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class CollectionAlbumScreen extends ConsumerStatefulWidget {
  const CollectionAlbumScreen({super.key});

  @override
  ConsumerState<CollectionAlbumScreen> createState() =>
      _CollectionAlbumScreenState();
}

class _CollectionAlbumScreenState extends ConsumerState<CollectionAlbumScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Discovered, 2: Locked
  String? _selectedSegment;

  static const List<int> _milestones = [3, 5, 10, 20, 30, 60, 90];

  // Static cached catalog to avoid rebuilding catalog objects on every frame
  static final List<_CatalogCarItem> _cachedCatalogCars = _buildStaticCatalog();
  static final List<String> _cachedSegments =
      _cachedCatalogCars.map((c) => c.segment).toSet().toList();

  static List<_CatalogCarItem> _buildStaticCatalog() {
    final list = <_CatalogCarItem>[];
    for (final brand in GameConstants.carBrands) {
      for (final model in brand.models) {
        list.add(_CatalogCarItem(
          brand: brand.name,
          modelName: model,
          segment: brand.segment,
          popularity: brand.popularityWeight,
        ));
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeState = ref.watch(themeProvider);
    final palette = themeState.activePalette;
    final isDark = palette.isDark;

    final allCatalogCars = _cachedCatalogCars;
    final totalCatalogCount = allCatalogCars.length;

    // Set of discovered keys
    final discoveredKeys = game.discoveredCarModelIds.toSet();
    final ownedKeys =
        game.ownedCars.map((c) => _toKey(c.brand, c.modelName)).toSet();
    final soldTitles =
        game.salesHistory.map((s) => s.carTitle.toLowerCase()).toSet();

    bool isDiscovered(_CatalogCarItem car) {
      final key = _toKey(car.brand, car.modelName);
      if (discoveredKeys.contains(key) ||
          discoveredKeys.contains(car.modelName) ||
          discoveredKeys.contains('${car.brand} ${car.modelName}')) {
        return true;
      }
      if (ownedKeys.contains(key)) {
        return true;
      }
      final lowerTitle = '${car.brand} ${car.modelName}'.toLowerCase();
      if (soldTitles.any((t) =>
          t.contains(car.modelName.toLowerCase()) || lowerTitle.contains(t))) {
        return true;
      }
      return false;
    }

    bool isOwned(_CatalogCarItem car) {
      final key = _toKey(car.brand, car.modelName);
      return ownedKeys.contains(key);
    }

    bool isSold(_CatalogCarItem car) {
      final lowerModel = car.modelName.toLowerCase();
      return soldTitles.any((t) => t.contains(lowerModel));
    }

    final discoveredCars = allCatalogCars.where(isDiscovered).toList();

    final albumProgress = CollectionAlbumEngine.calculateAlbumProgress(
      discoveredCarIds:
          discoveredCars.map((c) => _toKey(c.brand, c.modelName)).toList(),
      discoveredRareColors: game.unlockedShowroomThemeIds,
      discoveredSpecialPlates: const [],
      restoredBarnFinds: const [],
      totalCatalogCarsCount: totalCatalogCount,
    );

    // Filter cars
    final filteredCars = allCatalogCars.where((car) {
      final discovered = isDiscovered(car);
      if (_selectedFilterIndex == 1 && !discovered) return false;
      if (_selectedFilterIndex == 2 && discovered) return false;
      if (_selectedSegment != null && car.segment != _selectedSegment) {
        return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('album_appbar_title'),
      ),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(14),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Header Progress & Stats Card
                _buildProgressCard(
                  context: context,
                  game: game,
                  progress: albumProgress,
                  discoveredCount: discoveredCars.length,
                  totalCount: totalCatalogCount,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // 2. Milestone Rewards Shelf
                _buildMilestoneShelf(
                  context: context,
                  game: game,
                  discoveredCount: discoveredCars.length,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // 3. Filter Bar & Segment Chips
                _buildFilterBar(
                  context: context,
                  allSegments: _cachedSegments,
                  discoveredCount: discoveredCars.length,
                  lockedCount: totalCatalogCount - discoveredCars.length,
                  totalCount: totalCatalogCount,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),
              ]),
            ),
          ),

          // 4. Vehicle Catalog Grid (Fully virtualized SliverGrid for 60/120 FPS)
          if (filteredCars.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _buildEmptyState(context: context, isDark: isDark),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.74,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final car = filteredCars[index];
                    final discovered = isDiscovered(car);
                    final owned = isOwned(car);
                    final sold = isSold(car);

                    return _buildCarCard(
                      context: context,
                      car: car,
                      isDiscovered: discovered,
                      isOwned: owned,
                      isSold: sold,
                      isDark: isDark,
                    );
                  },
                  childCount: filteredCars.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _toKey(String brand, String model) {
    return '${brand}_$model'.toLowerCase().replaceAll(' ', '_');
  }

  Widget _buildProgressCard({
    required BuildContext context,
    required DealershipModel game,
    required AlbumProgress progress,
    required int discoveredCount,
    required int totalCount,
    required bool isDark,
  }) {
    final pct = totalCount > 0 ? (discoveredCount / totalCount) : 0.0;
    final pctText = '%${(pct * 100).toStringAsFixed(1)}';

    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141824) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.auto_stories_rounded,
                        color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('album_progress_title'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '$discoveredCount / $totalCount Model',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: pctText,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E2433) : const Color(0xFFE2E8F0),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: pct.clamp(0.02, 1.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF00E575), Color(0xFF38BDF8)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('album_subtitle_desc'),
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneShelf({
    required BuildContext context,
    required DealershipModel game,
    required int discoveredCount,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor:
          isDark ? const Color(0xFF191D2B) : const Color(0xFFFEFCE8),
      borderColor: isDark ? const Color(0xFFEAB308) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                context.tr('album_milestones_title'),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: Color(0xFFEAB308),
                ),
              )),
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFEAB308), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _milestones.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final target = _milestones[index];
                final reward =
                    CollectionAlbumEngine.getMilestoneReward(target) ?? 10000;
                final isReached = discoveredCount >= target;
                final isClaimed = game.claimedAlbumMilestones.contains(target);

                return Container(
                  width: 130,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF242A3D) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isClaimed
                          ? const Color(0xFF64748B)
                          : (isReached
                              ? const Color(0xFF00E575)
                              : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1))),
                      width: 1.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$target Model',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          if (isClaimed)
                            const Icon(Icons.check_circle_rounded,
                                color: Color(0xFF64748B), size: 14)
                          else if (isReached)
                            const Icon(Icons.stars_rounded,
                                color: Color(0xFF00E575), size: 14)
                          else
                            const Icon(Icons.lock_outline_rounded,
                                color: Color(0xFF94A3B8), size: 14),
                        ],
                      ),
                      Expanded(
                          child: Text(
                        '+${CurrencyFormatter.formatShort(reward.toDouble())}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00E575),
                        ),
                      )),
                      SizedBox(
                        width: double.infinity,
                        height: 22,
                        child: isClaimed
                            ? Center(
                                child: Text(
                                  context.tr('album_btn_claimed'),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: isReached
                                    ? () {
                                        HapticFeedback.heavyImpact();
                                        ref
                                            .read(gameProvider.notifier)
                                            .claimAlbumMilestone(
                                                target, reward.toDouble());
                                        NotificationService.showSuccess(
                                          context,
                                          context
                                              .tr('album_toast_reward_claimed'),
                                        );
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00E575),
                                  disabledBackgroundColor: isDark
                                      ? const Color(0xFF1E2433)
                                      : const Color(0xFFE2E8F0),
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  isReached
                                      ? context.tr('album_btn_claim_reward')
                                      : '$discoveredCount/$target',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: isReached
                                        ? Colors.black
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar({
    required BuildContext context,
    required List<String> allSegments,
    required int discoveredCount,
    required int lockedCount,
    required int totalCount,
    required bool isDark,
  }) {
    final filters = [
      '${context.tr('album_filter_all')} • $totalCount',
      '${context.tr('album_filter_discovered')} • $discoveredCount',
      '${context.tr('album_filter_locked')} • $lockedCount',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(filters.length, (index) {
            final isSelected = _selectedFilterIndex == index;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: index < filters.length - 1 ? 6.0 : 0.0),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedFilterIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xFFFFDE59)
                              : const Color(0xFF0F172A))
                          : (isDark ? const Color(0xFF1E2433) : Colors.white),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFF0F172A),
                        width: 1.8,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      filters[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: isSelected
                            ? (isDark ? Colors.black : Colors.white)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF334155)),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        // Segment filter chips
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSegmentChip(
                label: context.tr('all_segments_filter'),
                isSelected: _selectedSegment == null,
                isDark: isDark,
                onTap: () => setState(() => _selectedSegment = null),
              ),
              ...allSegments.map((seg) {
                return _buildSegmentChip(
                  label: seg.toUpperCase(),
                  isSelected: _selectedSegment == seg,
                  isDark: isDark,
                  onTap: () => setState(() => _selectedSegment = seg),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF38BDF8)
                : (isDark ? const Color(0xFF191D2B) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF0F172A))
                  : (isDark
                      ? const Color(0xFF2E384D)
                      : const Color(0xFFCBD5E1)),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isSelected
                  ? Colors.black
                  : (isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCarCard({
    required BuildContext context,
    required _CatalogCarItem car,
    required bool isDiscovered,
    required bool isOwned,
    required bool isSold,
    required bool isDark,
  }) {
    final estimatedValue = 65000.0 + (car.popularity * 4500.0);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _showCarDetailModal(
          context: context,
          car: car,
          isDiscovered: isDiscovered,
          isOwned: isOwned,
          isSold: isSold,
          estimatedValue: estimatedValue,
          isDark: isDark,
        );
      },
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(10),
        backgroundColor: isDiscovered
            ? (isDark ? const Color(0xFF141824) : Colors.white)
            : (isDark ? const Color(0xFF0F121A) : const Color(0xFF1E293B)),
        borderColor: isDiscovered
            ? (isOwned
                ? const Color(0xFF00E575)
                : (isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A)))
            : const Color(0xFF475569),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDiscovered
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    car.segment.toUpperCase(),
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      color:
                          isDiscovered ? Colors.black : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                if (isDiscovered)
                  if (isOwned)
                    NeoBrutalBadge(
                      text: context.tr('album_status_in_garage'),
                      backgroundColor: const Color(0xFF00E575),
                      textColor: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    )
                  else if (isSold)
                    NeoBrutalBadge(
                      text: context.tr('album_status_discovered_sold'),
                      backgroundColor: const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    )
                  else
                    NeoBrutalBadge(
                      text: context.tr('album_status_discovered_seen'),
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                    )
                else
                  const NeoBrutalBadge(
                    text: 'GİZLİ',
                    icon: Icons.lock_rounded,
                    backgroundColor: Color(0xFF334155),
                    textColor: Color(0xFF94A3B8),
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
              ],
            ),

            // Car Silhouette or Vector Icon
            Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: isDiscovered
                      ? (isDark
                          ? const Color(0xFF1E2433)
                          : const Color(0xFFF1F5F9))
                      : const Color(0xFF090B10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDiscovered
                        ? (isDark
                            ? const Color(0xFF2E384D)
                            : const Color(0xFFE2E8F0))
                        : const Color(0xFF334155),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: isDiscovered
                    ? VectorIconWidget(
                        type: 'car',
                        size: 32,
                        color: isOwned
                            ? const Color(0xFF00E575)
                            : const Color(0xFF38BDF8),
                      )
                    : const Icon(
                        Icons.lock_outline_rounded,
                        color: Color(0xFF64748B),
                        size: 28,
                      ),
              ),
            ),

            // Brand & Model Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  car.brand,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDiscovered
                        ? (isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7))
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isDiscovered ? car.modelName : '??? • KİLİTLİ MODEL',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: isDiscovered
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isDiscovered
                      ? '~${CurrencyFormatter.formatShort(estimatedValue)}'
                      : '??? ₺',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDiscovered
                        ? const Color(0xFF00E575)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCarDetailModal({
    required BuildContext context,
    required _CatalogCarItem car,
    required bool isDiscovered,
    required bool isOwned,
    required bool isSold,
    required double estimatedValue,
    required bool isDark,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141824) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: context.tr('album_inspection_title'),
                    backgroundColor: const Color(0xFFFFDE59),
                    textColor: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                  if (isDiscovered)
                    NeoBrutalBadge(
                      text: isOwned
                          ? context.tr('album_status_in_garage')
                          : (isSold
                              ? context.tr('album_status_discovered_sold')
                              : context.tr('album_status_discovered_seen')),
                      backgroundColor: isOwned
                          ? const Color(0xFF00E575)
                          : const Color(0xFF38BDF8),
                      textColor: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    )
                  else
                    const NeoBrutalBadge(
                      text: 'KİLİTLİ SİLÜET',
                      icon: Icons.lock_rounded,
                      backgroundColor: Color(0xFF334155),
                      textColor: Color(0xFFCBD5E1),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isDiscovered
                    ? '${car.brand} ${car.modelName}'
                    : '${car.brand} • ???',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),
              if (isDiscovered) ...[
                _buildStatRow(
                  label: context.tr('album_spec_segment'),
                  value: car.segment.toUpperCase(),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  label: context.tr('album_spec_market_value'),
                  value: CurrencyFormatter.format(estimatedValue),
                  isDark: isDark,
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  label: context.tr('album_spec_popularity'),
                  value: '${car.popularity} / 30 Ağırlık',
                  isDark: isDark,
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2433)
                        : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded,
                          color: Color(0xFFEF4444), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          context.tr('album_mystery_hint'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: NeoBrutalButton(
                  label: context.tr('btn_close'),
                  icon: Icons.close_rounded,
                  backgroundColor: const Color(0xFF0F172A),
                  textColor: Colors.white,
                  fontSize: 12,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          )),
          Expanded(
              child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
      {required BuildContext context, required bool isDark}) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(24),
      backgroundColor: isDark ? const Color(0xFF141824) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded,
                size: 36, color: Color(0xFF64748B)),
            const SizedBox(height: 8),
            Text(
              'Bu filtrede araç bulunamadı',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogCarItem {
  final String brand;
  final String modelName;
  final String segment;
  final int popularity;

  const _CatalogCarItem({
    required this.brand,
    required this.modelName,
    required this.segment,
    required this.popularity,
  });
}
