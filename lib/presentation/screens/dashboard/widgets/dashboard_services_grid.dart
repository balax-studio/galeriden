import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class _ServiceItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final Color color;
  final String route;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.color,
    required this.route,
  });
}

class DashboardServicesGrid extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardServicesGrid({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardServicesGridContent(
      game: game,
      palette: palette,
    );
  }
}

class _DashboardServicesGridContent extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const _DashboardServicesGridContent({
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;

    // Progression-ordered service definitions
    final allServices = [
      _ServiceItem(
        icon: Icons.directions_car_rounded,
        title: context.tr('service_showroom'),
        subtitle: context.tr('service_showroom_sub'),
        badge: game.incomingOffers.isNotEmpty
            ? '${game.incomingOffers.length}'
            : null,
        color: const Color(0xFFFFDE59),
        route: '/showroom',
      ),
      _ServiceItem(
        icon: Icons.storefront_rounded,
        title: context.tr('service_buy_car'),
        subtitle: context.tr('service_buy_car_sub'),
        color: const Color(0xFF38BDF8),
        route: '/marketplace',
      ),
      _ServiceItem(
        icon: Icons.local_car_wash_rounded,
        title: context.tr('service_car_wash'),
        subtitle: context.tr('service_car_wash_sub'),
        color: const Color(0xFF00F0FF),
        route: '/car-wash',
      ),
      _ServiceItem(
        icon: Icons.build_circle_rounded,
        title: context.tr('service_workshop'),
        subtitle: context.tr('service_workshop_sub'),
        color: const Color(0xFFFF7A00),
        route: '/workshop',
      ),
      _ServiceItem(
        icon: Icons.speed_rounded,
        title: context.tr('service_tuning'),
        subtitle: context.tr('service_tuning_sub'),
        color: const Color(0xFFA855F7),
        route: '/tuning-studio',
      ),
      _ServiceItem(
        icon: Icons.people_alt_rounded,
        title: context.tr('service_staff'),
        subtitle: context.tr('service_staff_sub', {'count': game.hiredStaff.length}),
        color: const Color(0xFFEC4899),
        route: '/staff',
      ),
      _ServiceItem(
        icon: Icons.history_edu_rounded,
        title: context.tr('service_history'),
        subtitle: context.tr('service_history_sub'),
        color: const Color(0xFF14B8A6),
        route: '/history',
      ),
      _ServiceItem(
        icon: Icons.gavel_rounded,
        title: context.tr('service_auction'),
        subtitle: context.tr('service_auction_sub'),
        badge: context.tr('weather_live_impact'),
        color: const Color(0xFFEF4444),
        route: '/auction',
      ),
      _ServiceItem(
        icon: Icons.account_balance_rounded,
        title: context.tr('service_finance'),
        subtitle: context.tr('service_finance_sub'),
        color: const Color(0xFF00E575),
        route: '/finance',
      ),
      _ServiceItem(
        icon: Icons.trending_up_rounded,
        title: context.tr('service_stocks'),
        subtitle: context.tr('service_stocks_sub'),
        color: const Color(0xFF6366F1),
        route: '/stock-market',
      ),
      _ServiceItem(
        icon: Icons.reviews_rounded,
        title: context.tr('service_reviews'),
        subtitle: context.tr('service_reviews_sub', {'rep': game.reputationScore}),
        color: const Color(0xFFF59E0B),
        route: '/reviews',
      ),
      _ServiceItem(
        icon: Icons.palette_rounded,
        title: context.tr('service_decor'),
        subtitle: context.tr('service_decor_sub'),
        color: const Color(0xFF06B6D4),
        route: '/showroom-decor',
      ),
      _ServiceItem(
        icon: Icons.directions_boat_filled_rounded,
        title: context.tr('service_vasita_market'),
        subtitle: context.tr('service_vasita_market_sub'),
        color: const Color(0xFF06B6D4),
        route: '/vasita',
      ),
      _ServiceItem(
        icon: Icons.domain_rounded,
        title: context.tr('service_real_estate'),
        subtitle: context.tr('service_real_estate_sub'),
        color: const Color(0xFF10B981),
        route: '/emlak',
      ),
      _ServiceItem(
        icon: Icons.delete_outline_rounded,
        title: context.tr('service_scrapyard'),
        subtitle: context.tr('service_scrapyard_sub'),
        color: const Color(0xFF64748B),
        route: '/scrapyard',
      ),
      _ServiceItem(
        icon: Icons.car_rental_rounded,
        title: context.tr('service_rent_car'),
        subtitle: context.tr('service_rent_car_sub'),
        color: const Color(0xFF38BDF8),
        route: '/rent-a-car',
      ),
      _ServiceItem(
        icon: Icons.masks_rounded,
        title: context.tr('service_black_market'),
        subtitle: context.tr('service_black_market_sub'),
        color: const Color(0xFFDC2626),
        route: '/black-market',
      ),
      _ServiceItem(
        icon: Icons.apartment_rounded,
        title: context.tr('service_branches'),
        subtitle: context.tr('service_branches_sub'),
        color: const Color(0xFF8B5CF6),
        route: '/branches',
      ),
      _ServiceItem(
        icon: Icons.business_center_rounded,
        title: context.tr('service_side_biz'),
        subtitle: context.tr('service_side_biz_sub'),
        color: const Color(0xFF10B981),
        route: '/side-businesses',
      ),
      _ServiceItem(
        icon: Icons.map_rounded,
        title: context.tr('service_district'),
        subtitle: context.tr('service_district_sub'),
        color: const Color(0xFF38BDF8),
        route: '/districts',
      ),
      _ServiceItem(
        icon: Icons.record_voice_over_rounded,
        title: context.tr('service_gossip'),
        subtitle: context.tr('service_gossip_sub'),
        badge: game.activeGossips.isNotEmpty
            ? '${game.activeGossips.length}'
            : null,
        color: const Color(0xFFFFDE59),
        route: '/gossip',
      ),
      _ServiceItem(
        icon: Icons.handshake_rounded,
        title: context.tr('service_consignment'),
        subtitle: context.tr('service_consignment_sub'),
        badge: game.consignmentOffers.isNotEmpty
            ? '${game.consignmentOffers.length}'
            : null,
        color: const Color(0xFF00E575),
        route: '/consignment',
      ),
      _ServiceItem(
        icon: Icons.sports_score_rounded,
        title: context.tr('service_night_market'),
        subtitle: context.tr('service_night_market_sub'),
        color: const Color(0xFFF43F5E),
        route: '/night-market',
      ),
      _ServiceItem(
        icon: Icons.casino_rounded,
        title: context.tr('service_casino'),
        subtitle: context.tr('service_casino_sub'),
        badge: 'VIP',
        color: const Color(0xFFFFDE59),
        route: '/casino',
      ),
    ];

    final isShowroomUnlocked = game.isFeatureUnlocked('/showroom');
    final isWorkshopUnlocked = game.isFeatureUnlocked('/workshop');
    final isWashUnlocked = game.isFeatureUnlocked('/car-wash');
    final isTuningUnlocked = game.isFeatureUnlocked('/tuning-studio');
    final isMarketplaceUnlocked = game.isFeatureUnlocked('/marketplace');
    final isAuctionUnlocked = game.isFeatureUnlocked('/auction');
    final isHistoryUnlocked = game.isFeatureUnlocked('/history');
    final isFinanceUnlocked = game.isFeatureUnlocked('/finance');
    final isStaffUnlocked = game.isFeatureUnlocked('/staff');
    final isStocksUnlocked = game.isFeatureUnlocked('/stock-market');
    final isBranchesUnlocked = game.isFeatureUnlocked('/branches');
    final isRealEstateUnlocked = game.isFeatureUnlocked('/emlak');
    final isDecorUnlocked = game.isFeatureUnlocked('/showroom-decor');
    final isVasitaUnlocked = game.isFeatureUnlocked('/vasita');
    final isScrapyardUnlocked = game.isFeatureUnlocked('/scrapyard');
    final isBlackMarketUnlocked = game.isFeatureUnlocked('/black-market');
    final isReviewsUnlocked = game.isFeatureUnlocked('/reviews');

    final bool useHangar = isWorkshopUnlocked || isWashUnlocked || isTuningUnlocked;
    final bool useAuctionFinance = isAuctionUnlocked || isFinanceUnlocked || isStocksUnlocked;
    final bool useBoulevard = isMarketplaceUnlocked || isVasitaUnlocked || isHistoryUnlocked;
    final bool useExecutiveDossier = isBranchesUnlocked || isRealEstateUnlocked || isStaffUnlocked;
    final bool useClassifiedNoir = isBlackMarketUnlocked || isScrapyardUnlocked || isReviewsUnlocked || isDecorUnlocked;

    final handledRoutes = <String>{
      if (isShowroomUnlocked) '/showroom',
      if (useHangar) ...[
        if (isWorkshopUnlocked) '/workshop',
        if (isWashUnlocked) '/car-wash',
        if (isTuningUnlocked) '/tuning-studio',
      ],
      if (useBoulevard) ...[
        if (isMarketplaceUnlocked) '/marketplace',
        if (isVasitaUnlocked) '/vasita',
        if (isHistoryUnlocked) '/history',
      ],
      if (useAuctionFinance) ...[
        if (isAuctionUnlocked) '/auction',
        if (isFinanceUnlocked) '/finance',
        if (isStocksUnlocked) '/stock-market',
      ],
      if (useExecutiveDossier) ...[
        if (isBranchesUnlocked) '/branches',
        if (isRealEstateUnlocked) '/emlak',
        if (isStaffUnlocked) '/staff',
      ],
      if (useClassifiedNoir) ...[
        if (isBlackMarketUnlocked) '/black-market',
        if (isScrapyardUnlocked) '/scrapyard',
        if (isReviewsUnlocked) '/reviews',
        if (isDecorUnlocked) '/showroom-decor',
      ],
    };

    final expansionUnlocked = allServices
        .where((s) => !handledRoutes.contains(s.route) && game.isFeatureUnlocked(s.route))
        .toList();
    final lockedItems = allServices.where((s) => !game.isFeatureUnlocked(s.route)).toList();

    final List<Widget> gridRows = [];

    // Typology 1: Showroom Flight-Deck Hero
    if (isShowroomUnlocked) {
      gridRows.add(_buildShowroomFlightDeckHero(context, ref, game, palette, isDark));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 2: Sanayi Endüstriyel Mega-Hangarı (Maslak 2. Kısım Unified 3-Zone Deck)
    if (useHangar) {
      gridRows.add(_buildSanayiMegaHangar(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isWorkshopUnlocked: isWorkshopUnlocked,
        isWashUnlocked: isWashUnlocked,
        isTuningUnlocked: isTuningUnlocked,
      ));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 3: Açık Oto Pazarı & Vasıta Boulevard Dock
    if (useBoulevard) {
      gridRows.add(_buildMarketBoulevardVasitaDock(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isMarketplaceUnlocked: isMarketplaceUnlocked,
        isVasitaUnlocked: isVasitaUnlocked,
        isHistoryUnlocked: isHistoryUnlocked,
      ));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 4: Canlı İhale & Finans Wall Street Terminali
    if (useAuctionFinance) {
      gridRows.add(_buildAuctionFinanceTerminal(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isAuctionUnlocked: isAuctionUnlocked,
        isFinanceUnlocked: isFinanceUnlocked,
        isStocksUnlocked: isStocksUnlocked,
      ));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 5: Holding & Mülk İmparatorluğu Executive Dossier
    if (useExecutiveDossier) {
      gridRows.add(_buildHoldingExecutiveDossier(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isBranchesUnlocked: isBranchesUnlocked,
        isRealEstateUnlocked: isRealEstateUnlocked,
        isStaffUnlocked: isStaffUnlocked,
      ));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 6: Yeraltı & Karaborsa Noir Classified Folder
    if (useClassifiedNoir) {
      gridRows.add(_buildClassifiedUndergroundFolder(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isBlackMarketUnlocked: isBlackMarketUnlocked,
        isScrapyardUnlocked: isScrapyardUnlocked,
        isReviewsUnlocked: isReviewsUnlocked,
        isDecorUnlocked: isDecorUnlocked,
      ));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 7: Secondary & Expansion Sectors
    if (expansionUnlocked.isNotEmpty) {
      gridRows.add(_buildSecondaryExpansionStrip(context, ref, game, palette, isDark, expansionUnlocked));
      gridRows.add(const SizedBox(height: 8));
    }

    // Typology 8: Dynamic Next Target Motivating Banner
    if (lockedItems.isNotEmpty) {
      gridRows.add(
        _DynamicNextTargetBanner(
          lockedItems: lockedItems,
          game: game,
          palette: palette,
          isDark: isDark,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: gridRows
          .animate(interval: 40.ms)
          .slideY(begin: 0.12, curve: Curves.easeOutCubic, duration: 320.ms)
          .fadeIn(duration: 320.ms),
    );
  }

  // ===========================================================================
  // TYPOLOGY 1: SHOWROOM FLIGHT-DECK HERO (Blueprint Bay & Tactical Matrix)
  // ===========================================================================
  Widget _buildShowroomFlightDeckHero(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final carsCount = game.ownedCars.length;
    final maxSlots = game.maxGarageSlots;
    final hasOffers = game.incomingOffers.isNotEmpty;
    final offersCount = game.incomingOffers.length;
    final branchName = game.getLocalizedBranchName(context);
    final displaySlots = math.min(maxSlots, 10);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(10),
      backgroundColor: isDark ? const Color(0xFF141926) : const Color(0xFFFFFDEB),
      borderColor: isDark ? const Color(0xFF384358) : const Color(0xFF0F172A),
      borderWidth: 2.5,
      borderRadius: 16,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/showroom');
        context.push('/showroom');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Technical Blueprint Hatch Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2638) : const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${context.tr("deck_showroom_hatch")} // LVL ${game.level}',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                  ),
                ),
              ),
              const Spacer(),
              Transform.rotate(
                angle: -0.035,
                child: NeoBrutalBadge(
                  text: context.tr('deck_showroom_flagship'),
                  backgroundColor: const Color(0xFFFFDE59),
                  textColor: const Color(0xFF0F172A),
                  borderWidth: 1.8,
                  fontSize: 9,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                ),
              ),
              if (game.isFeatureNew('/showroom')) ...[
                const SizedBox(width: 6),
                _buildNotificationDot(isDark),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Main Showroom Title & Identity Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 2.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF0F172A),
                      offset: Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  size: 26,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('service_showroom'),
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      branchName,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              // Live Revenue Telemetry
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E575).withValues(alpha: isDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00E575),
                    width: 1.6,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E575),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final totalPassiveDaily = game.sideBusinesses.fold<double>(
                          0.0,
                          (sum, b) => sum + (b.isOwned && !b.isUnderConstruction ? b.effectiveDailyIncome : 0.0),
                        );
                        return Text(
                          totalPassiveDaily > 0
                              ? '+₺${totalPassiveDaily.toStringAsFixed(0)} / d'
                              : '₺${game.balance.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFF00E575) : const Color(0xFF047857),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tactical Visual Parking Matrix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D111A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1),
                width: 1.8,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('deck_parking_matrix'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '$carsCount / $maxSlots ${context.tr("bento_capacity_track").toUpperCase()}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: carsCount >= maxSlots
                            ? const Color(0xFFEF4444)
                            : (isDark ? const Color(0xFFFFDE59) : const Color(0xFFB45309)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                // Parking Bay Slots
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    for (int i = 0; i < displaySlots; i++)
                      Container(
                        width: 28,
                        height: 20,
                        decoration: BoxDecoration(
                          color: i < carsCount
                              ? (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFBFDBFE))
                              : (isDark ? const Color(0xFF1E2536) : Colors.white),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: i < carsCount
                                ? const Color(0xFF3B82F6)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            width: 1.4,
                          ),
                        ),
                        child: Center(
                          child: i < carsCount
                              ? Icon(
                                  Icons.directions_car_rounded,
                                  size: 13,
                                  color: isDark ? Colors.white : const Color(0xFF1D4ED8),
                                )
                              : Text(
                                  'P${i + 1}',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                  ),
                                ),
                        ),
                      ),
                    if (maxSlots > 10)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2536) : Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            width: 1.4,
                          ),
                        ),
                        child: Text(
                          '+${maxSlots - 10}',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Action Strip & Incoming Offers
          Row(
            children: [
              if (hasOffers)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.25 : 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFEF4444),
                        width: 1.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 16,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr('telemetry_offers_count', {'count': '$offersCount'}),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              NeoBrutalButton(
                label: context.tr('deck_enter_showroom'),
                backgroundColor: const Color(0xFFFFDE59),
                textColor: const Color(0xFF0F172A),
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                onPressed: () {
                  ref.read(gameProvider.notifier).markFeatureSeen('/showroom');
                  context.push('/showroom');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPOLOGY 2: SANAYİ ENDÜSTRİYEL MEGA-HANGARI (Unified 3-Zone Deck)
  // ===========================================================================
  Widget _buildSanayiMegaHangar({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required ThemePaletteModel palette,
    required bool isDark,
    required bool isWorkshopUnlocked,
    required bool isWashUnlocked,
    required bool isTuningUnlocked,
  }) {
    final damagedCars = game.ownedCars
        .where((c) => c.expertise.bodyParts.values.contains(PartStatus.damaged))
        .length;
    final dirtyCars = game.ownedCars.where((c) => !c.isWashed).length;

    return NeoBrutalCard(
      padding: EdgeInsets.zero,
      backgroundColor: isDark ? const Color(0xFF131722) : const Color(0xFFF8FAFC),
      borderColor: isDark ? const Color(0xFF384358) : const Color(0xFF0F172A),
      borderWidth: 2.5,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Industrial Hazard Warning Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF384358) : const Color(0xFF0F172A),
                  width: 2.2,
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                  color: Colors.black,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.tr('deck_hangar_header'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Middle Asymmetric Split: 58% Lift Bay vs 42% Tuning Stage
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ZONE A: Lift & Tamir Atölyesi (58%)
                    if (isWorkshopUnlocked)
                      Expanded(
                        flex: 58,
                        child: InkWell(
                          onTap: () {
                            ref.read(gameProvider.notifier).markFeatureSeen('/workshop');
                            context.push('/workshop');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2536) : const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFF7A00),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF0F172A),
                                  offset: Offset(2.5, 2.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF7A00),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.build_circle_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (game.isFeatureNew('/workshop'))
                                      _buildNotificationDot(isDark),
                                    const Spacer(),
                                    NeoBrutalBadge(
                                      text: damagedCars > 0
                                          ? context.tr('telemetry_damaged_count', {'count': '$damagedCars'})
                                          : context.tr('deck_lift_ready'),
                                      backgroundColor: damagedCars > 0
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF00E575),
                                      textColor: damagedCars > 0 ? Colors.white : Colors.black,
                                      fontSize: 8.5,
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  context.tr('service_workshop'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.tr('service_workshop_sub'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 5),
                                NeoBrutalButton(
                                  label: context.tr('deck_action_lift'),
                                  fontSize: 9.5,
                                  backgroundColor: const Color(0xFFFF7A00),
                                  textColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  onPressed: () {
                                    ref.read(gameProvider.notifier).markFeatureSeen('/workshop');
                                    context.push('/workshop');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (isWorkshopUnlocked && isTuningUnlocked)
                      const SizedBox(width: 8),

                    // ZONE B: Dyno & Tuning Stage (42%)
                    if (isTuningUnlocked)
                      Expanded(
                        flex: 42,
                        child: InkWell(
                          onTap: () {
                            ref.read(gameProvider.notifier).markFeatureSeen('/tuning-studio');
                            context.push('/tuning-studio');
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF261938) : const Color(0xFFFAF5FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFA855F7),
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF0F172A),
                                  offset: Offset(2.5, 2.5),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA855F7),
                                        borderRadius: BorderRadius.circular(7),
                                      ),
                                      child: const Icon(
                                        Icons.speed_rounded,
                                        size: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    if (game.isFeatureNew('/tuning-studio'))
                                      _buildNotificationDot(isDark),
                                    const Spacer(),
                                    NeoBrutalBadge(
                                      text: 'STAGE 3',
                                      backgroundColor: const Color(0xFFA855F7),
                                      textColor: Colors.white,
                                      fontSize: 8.5,
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  context.tr('service_tuning'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.tr('service_tuning_sub'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: isDark ? const Color(0xFFA855F7) : const Color(0xFF7E22CE),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // ZONE C: Detailing & Oto Yıkama (Full Width Bottom Ribbon)
                if (isWashUnlocked) ...[
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/car-wash');
                      context.push('/car-wash');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0C2A3A) : const Color(0xFFE0F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF00F0FF),
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0xFF0F172A),
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F0FF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.local_car_wash_rounded,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      context.tr('service_car_wash'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                    if (game.isFeatureNew('/car-wash')) ...[
                                      const SizedBox(width: 6),
                                      _buildNotificationDot(isDark),
                                    ],
                                  ],
                                ),
                                Text(
                                  dirtyCars > 0
                                      ? context.tr('telemetry_dirty_count', {'count': '$dirtyCars'})
                                      : context.tr('deck_clean_all'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: dirtyCars > 0
                                        ? const Color(0xFFEF4444)
                                        : (isDark ? const Color(0xFF00F0FF) : const Color(0xFF0369A1)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NeoBrutalButton(
                            label: context.tr('deck_action_detail'),
                            fontSize: 9.5,
                            backgroundColor: const Color(0xFF00F0FF),
                            textColor: const Color(0xFF0F172A),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            onPressed: () {
                              ref.read(gameProvider.notifier).markFeatureSeen('/car-wash');
                              context.push('/car-wash');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPOLOGY 3: AÇIK OTO PAZARI & VASITA BOULEVARD DOCK
  // ===========================================================================
  Widget _buildMarketBoulevardVasitaDock({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required ThemePaletteModel palette,
    required bool isDark,
    required bool isMarketplaceUnlocked,
    required bool isVasitaUnlocked,
    required bool isHistoryUnlocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Full-Width Boulevard Banner (Pazar Yeri)
        if (isMarketplaceUnlocked)
          NeoBrutalCard(
            padding: const EdgeInsets.all(10),
            backgroundColor: isDark ? const Color(0xFF0F2338) : const Color(0xFFF0F9FF),
            borderColor: const Color(0xFF38BDF8),
            borderWidth: 2.4,
            borderRadius: 14,
            onTap: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
              context.push('/marketplace');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 1.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('service_buy_car'),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (game.isFeatureNew('/marketplace')) ...[
                            const SizedBox(width: 6),
                            _buildNotificationDot(isDark),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('deck_market_boulevard'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF7DD3FC) : const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: context.tr('bento_action_market'),
                  fontSize: 10.5,
                  backgroundColor: const Color(0xFF38BDF8),
                  textColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: () {
                    ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
                    context.push('/marketplace');
                  },
                ),
              ],
            ),
          ),

        // Bottom Asymmetric Dock (Vasıta 60% vs Satış Raporları 40%)
        if (isVasitaUnlocked || isHistoryUnlocked) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vasıta Pazarı Pod (60%)
              if (isVasitaUnlocked)
                Expanded(
                  flex: 60,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    backgroundColor: isDark ? const Color(0xFF0E2833) : const Color(0xFFE0F7FA),
                    borderColor: const Color(0xFF06B6D4),
                    borderWidth: 2.2,
                    borderRadius: 12,
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/vasita');
                      context.push('/vasita');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF06B6D4),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.directions_boat_filled_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (game.isFeatureNew('/vasita'))
                              _buildNotificationDot(isDark),
                            const Spacer(),
                            NeoBrutalBadge(
                              text: 'Yat • Karavan',
                              backgroundColor: const Color(0xFF06B6D4),
                              textColor: Colors.white,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          context.tr('service_vasita_market'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('service_vasita_market_sub'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              if (isVasitaUnlocked && isHistoryUnlocked)
                const SizedBox(width: 10),

              // Satış & Ciro Raporları Pod (40%)
              if (isHistoryUnlocked)
                Expanded(
                  flex: 40,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark ? const Color(0xFF282312) : const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFF59E0B),
                    borderWidth: 2.2,
                    borderRadius: 12,
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/history');
                      context.push('/history');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF59E0B),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.history_edu_rounded,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (game.isFeatureNew('/history'))
                              _buildNotificationDot(isDark),
                            const Spacer(),
                            NeoBrutalBadge(
                              text: context.tr('telemetry_sales_count', {'count': '${game.carsSold}'}),
                              backgroundColor: const Color(0xFFF59E0B),
                              textColor: Colors.black,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('service_history'),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('service_history_sub'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // TYPOLOGY 4: CANLI İHALE & FİNANS WALL STREET TERMINALİ
  // ===========================================================================
  Widget _buildAuctionFinanceTerminal({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required ThemePaletteModel palette,
    required bool isDark,
    required bool isAuctionUnlocked,
    required bool isFinanceUnlocked,
    required bool isStocksUnlocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Red Alert Live Auction Ticker
        if (isAuctionUnlocked)
          NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
            borderColor: const Color(0xFFEF4444),
            borderWidth: 2.4,
            borderRadius: 14,
            onTap: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/auction');
              context.push('/auction');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 1.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('service_auction'),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (game.isFeatureNew('/auction')) ...[
                            const SizedBox(width: 6),
                            _buildNotificationDot(isDark),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Transform.rotate(
                        angle: -0.03,
                        alignment: Alignment.centerLeft,
                        child: NeoBrutalBadge(
                          text: context.tr('deck_auction_ticker'),
                          backgroundColor: const Color(0xFFEF4444),
                          textColor: Colors.white,
                          fontSize: 9,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: context.tr('bento_action_bid'),
                  fontSize: 10.5,
                  backgroundColor: const Color(0xFFEF4444),
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: () {
                    ref.read(gameProvider.notifier).markFeatureSeen('/auction');
                    context.push('/auction');
                  },
                ),
              ],
            ),
          ),

        // Bottom Asymmetric Financial Terminal (Kasa 54% vs Borsa 46%)
        if (isFinanceUnlocked || isStocksUnlocked) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Finans & Kasa Pod (54%)
              if (isFinanceUnlocked)
                Expanded(
                  flex: 54,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark ? const Color(0xFF0F261B) : const Color(0xFFECFDF5),
                    borderColor: const Color(0xFF00E575),
                    borderWidth: 2.2,
                    borderRadius: 12,
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/finance');
                      context.push('/finance');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E575),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (game.isFeatureNew('/finance'))
                              _buildNotificationDot(isDark),
                            const Spacer(),
                            NeoBrutalBadge(
                              text: context.tr('bento_badge_debt_clean'),
                              backgroundColor: const Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('service_finance'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('service_finance_sub'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        NeoBrutalButton(
                          label: context.tr('bento_action_bank'),
                          fontSize: 9.5,
                          backgroundColor: const Color(0xFF00E575),
                          textColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          onPressed: () {
                            ref.read(gameProvider.notifier).markFeatureSeen('/finance');
                            context.push('/finance');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              if (isFinanceUnlocked && isStocksUnlocked)
                const SizedBox(width: 10),

              // Borsa Portföyü Pod (46%)
              if (isStocksUnlocked)
                Expanded(
                  flex: 46,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark ? const Color(0xFF181B38) : const Color(0xFFEEF2FF),
                    borderColor: const Color(0xFF6366F1),
                    borderWidth: 2.2,
                    borderRadius: 12,
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/stock-market');
                      context.push('/stock-market');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (game.isFeatureNew('/stock-market'))
                              _buildNotificationDot(isDark),
                            const Spacer(),
                            NeoBrutalBadge(
                              text: '${game.ownedStocks.length} Hisse',
                              backgroundColor: const Color(0xFF6366F1),
                              textColor: Colors.white,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('service_stocks'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('service_stocks_sub'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        NeoBrutalButton(
                          label: context.tr('deck_action_portfolio'),
                          fontSize: 9.5,
                          backgroundColor: const Color(0xFF6366F1),
                          textColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          onPressed: () {
                            ref.read(gameProvider.notifier).markFeatureSeen('/stock-market');
                            context.push('/stock-market');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // TYPOLOGY 5: HOLDİNG & MÜLK İMPARATORLUĞU EXECUTIVE DOSSIER
  // ===========================================================================
  Widget _buildHoldingExecutiveDossier({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required ThemePaletteModel palette,
    required bool isDark,
    required bool isBranchesUnlocked,
    required bool isRealEstateUnlocked,
    required bool isStaffUnlocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Imperial Branches Prestige Banner
        if (isBranchesUnlocked)
          NeoBrutalCard(
            padding: const EdgeInsets.all(10),
            backgroundColor: isDark ? const Color(0xFF23143B) : const Color(0xFFF5F3FF),
            borderColor: const Color(0xFF8B5CF6),
            borderWidth: 2.4,
            borderRadius: 14,
            onTap: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/branches');
              context.push('/branches');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 1.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('service_branches'),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (game.isFeatureNew('/branches')) ...[
                            const SizedBox(width: 6),
                            _buildNotificationDot(isDark),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('deck_holding_header'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFFC4B5FD) : const Color(0xFF6D28D9),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: context.tr('bento_action_branches'),
                  fontSize: 10.5,
                  backgroundColor: const Color(0xFF8B5CF6),
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: () {
                    ref.read(gameProvider.notifier).markFeatureSeen('/branches');
                    context.push('/branches');
                  },
                ),
              ],
            ),
          ),

        // Bottom Dual-Dossier (Emlak 50% vs Personel 50%)
        if (isRealEstateUnlocked || isStaffUnlocked) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Emlak Pazarı Pod (50%)
              if (isRealEstateUnlocked)
                Expanded(
                  flex: 50,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    backgroundColor: isDark ? const Color(0xFF102B21) : const Color(0xFFECFDF5),
                    borderColor: const Color(0xFF10B981),
                    borderWidth: 2.2,
                    borderRadius: 12,
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/emlak');
                      context.push('/emlak');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.domain_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (game.isFeatureNew('/emlak'))
                              _buildNotificationDot(isDark),
                            const Spacer(),
                            NeoBrutalBadge(
                              text: context.tr('telemetry_real_estate_count', {'count': '${game.ownedRealEstates.length}'}),
                              backgroundColor: const Color(0xFF10B981),
                              textColor: Colors.white,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          context.tr('service_real_estate'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('service_real_estate_sub'),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              if (isRealEstateUnlocked && isStaffUnlocked)
                const SizedBox(width: 8),

              // Personel Kadrosu Pod (50%)
              if (isStaffUnlocked)
                Expanded(
                  flex: 50,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    backgroundColor: isDark ? const Color(0xFF2C1425) : const Color(0xFFFDF2F8),
                    borderColor: const Color(0xFFEC4899),
                    borderWidth: 2.2,
                    borderRadius: 12,
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/staff');
                      context.push('/staff');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Icon(
                                Icons.people_alt_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (game.isFeatureNew('/staff'))
                              _buildNotificationDot(isDark),
                            const Spacer(),
                            NeoBrutalBadge(
                              text: '${game.hiredStaff.length} Uzman',
                              backgroundColor: const Color(0xFFEC4899),
                              textColor: Colors.white,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('service_staff'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr('service_staff_sub', {'count': game.hiredStaff.length}),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // TYPOLOGY 6: YERALTI & KARABORSA NOIR CLASSIFIED FOLDER
  // ===========================================================================
  Widget _buildClassifiedUndergroundFolder({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required ThemePaletteModel palette,
    required bool isDark,
    required bool isBlackMarketUnlocked,
    required bool isScrapyardUnlocked,
    required bool isReviewsUnlocked,
    required bool isDecorUnlocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Karaborsa Kelepir Şeridi
        if (isBlackMarketUnlocked)
          NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF17131A) : const Color(0xFF1E1B24),
            borderColor: const Color(0xFFDC2626),
            borderWidth: 2.4,
            borderRadius: 14,
            onTap: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/black-market');
              context.push('/black-market');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                      width: 1.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.masks_rounded,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.tr('service_black_market'),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          if (game.isFeatureNew('/black-market')) ...[
                            const SizedBox(width: 6),
                            _buildNotificationDot(isDark),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Transform.rotate(
                        angle: 0.03,
                        alignment: Alignment.centerLeft,
                        child: NeoBrutalBadge(
                          text: context.tr('deck_classified_stamp'),
                          backgroundColor: const Color(0xFFDC2626),
                          textColor: Colors.white,
                          fontSize: 8.5,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.lock_open_rounded,
                  size: 20,
                  color: Color(0xFFDC2626),
                ),
              ],
            ),
          ),

        // 3-Item Micro-Dock (Hurdalık, Yorumlar, Dekor)
        if (isScrapyardUnlocked || isReviewsUnlocked || isDecorUnlocked) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (isScrapyardUnlocked)
                Expanded(
                  child: _buildTactileMicroPedal(
                    context: context,
                    ref: ref,
                    isDark: isDark,
                    route: '/scrapyard',
                    title: context.tr('service_scrapyard'),
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFF64748B),
                    badgeText: context.tr('telemetry_parts_count', {'count': '${game.salvagedParts.length}'}),
                    isNew: game.isFeatureNew('/scrapyard'),
                  ),
                ),
              if (isScrapyardUnlocked && (isReviewsUnlocked || isDecorUnlocked))
                const SizedBox(width: 8),
              if (isReviewsUnlocked)
                Expanded(
                  child: _buildTactileMicroPedal(
                    context: context,
                    ref: ref,
                    isDark: isDark,
                    route: '/reviews',
                    title: context.tr('service_reviews'),
                    icon: Icons.reviews_rounded,
                    color: const Color(0xFFF59E0B),
                    badgeText: '${game.reputationScore} XP',
                    isNew: game.isFeatureNew('/reviews'),
                  ),
                ),
              if (isReviewsUnlocked && isDecorUnlocked)
                const SizedBox(width: 8),
              if (isDecorUnlocked)
                Expanded(
                  child: _buildTactileMicroPedal(
                    context: context,
                    ref: ref,
                    isDark: isDark,
                    route: '/showroom-decor',
                    title: context.tr('service_decor'),
                    icon: Icons.palette_rounded,
                    color: const Color(0xFF06B6D4),
                    badgeText: 'Dekor',
                    isNew: game.isFeatureNew('/showroom-decor'),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTactileMicroPedal({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required String route,
    required String title,
    required IconData icon,
    required Color color,
    required String badgeText,
    required bool isNew,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      backgroundColor: isDark ? const Color(0xFF171B26) : Colors.white,
      borderColor: color,
      borderWidth: 2,
      borderRadius: 10,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(route);
        context.push(route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 14, color: Colors.white),
              ),
              if (isNew) ...[
                const SizedBox(width: 4),
                _buildNotificationDot(isDark),
              ],
              const Spacer(),
              NeoBrutalBadge(
                text: badgeText,
                backgroundColor: color.withValues(alpha: isDark ? 0.3 : 0.2),
                textColor: isDark ? color : const Color(0xFF0F172A),
                fontSize: 8,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPOLOGY 7: SECONDARY & EXPANSION SECTORS
  // ===========================================================================
  Widget _buildSecondaryExpansionStrip(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    ThemePaletteModel palette,
    bool isDark,
    List<_ServiceItem> expansionItems,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < expansionItems.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildExpansionTile(context, ref, game, isDark, expansionItems[i]),
              ),
              if (i + 1 < expansionItems.length) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildExpansionTile(context, ref, game, isDark, expansionItems[i + 1]),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildExpansionTile(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    bool isDark,
    _ServiceItem item,
  ) {
    final isNew = game.isFeatureNew(item.route);

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      backgroundColor: isDark ? const Color(0xFF1E2536) : Colors.white,
      borderColor: item.color,
      borderWidth: 2,
      borderRadius: 10,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: item.color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 4),
                      _buildNotificationDot(isDark),
                    ],
                  ],
                ),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDot(bool isDark) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? Colors.white : const Color(0xFF0F172A),
          width: 1.4,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99EF4444),
            blurRadius: 4,
            spreadRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

/// Dynamic Heartbeat & Rotating Next Target Banner
class _DynamicNextTargetBanner extends StatefulWidget {
  final List<_ServiceItem> lockedItems;
  final DealershipModel game;
  final ThemePaletteModel palette;
  final bool isDark;

  const _DynamicNextTargetBanner({
    required this.lockedItems,
    required this.game,
    required this.palette,
    required this.isDark,
  });

  @override
  State<_DynamicNextTargetBanner> createState() =>
      _DynamicNextTargetBannerState();
}

class _DynamicNextTargetBannerState extends State<_DynamicNextTargetBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowAnimation;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Gentle Heartbeat Pulse & Glow Animation Loop (2.2s Cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    // Double-beat Cardiac Pulse Tween Sequence (lub-dub rhythm)
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.06)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.06, end: 0.98)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.98, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 14,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 50,
      ),
    ]).animate(_pulseController);

    // Glowing Neon Border & Badge Shimmer
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.35, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 26,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.35)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 24,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.35),
        weight: 50,
      ),
    ]).animate(_pulseController);

    // Auto-advance rotating targets every 4.5 seconds
    _startAutoRotation();
  }

  void _startAutoRotation() {
    _timer?.cancel();
    if (widget.lockedItems.length > 1) {
      _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.lockedItems.length;
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant _DynamicNextTargetBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lockedItems.length != oldWidget.lockedItems.length) {
      if (_currentIndex >= widget.lockedItems.length) {
        _currentIndex = 0;
      }
      _startAutoRotation();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _nextTargetManually() {
    HapticFeedback.selectionClick();
    if (widget.lockedItems.length > 1) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.lockedItems.length;
      });
      _startAutoRotation(); // Reset timer so it doesn't flip immediately
    }
  }

  String _getMotivationalBenefit(
      BuildContext context, String route, int reqLevel) {
    switch (route) {
      case '/car-wash':
        return context.tr('benefit_car_wash');
      case '/workshop':
        return context.tr('benefit_workshop');
      case '/tuning-studio':
        return context.tr('benefit_tuning');
      case '/emlak':
      case '/emlak-market':
        return context.tr('benefit_real_estate');
      case '/staff':
        return context.tr('benefit_staff');
      case '/history':
        return context.tr('benefit_history');
      case '/auction':
        return context.tr('benefit_auction');
      case '/finance':
        return context.tr('benefit_finance');
      case '/stock-market':
        return context.tr('benefit_stocks');
      case '/reviews':
        return context.tr('benefit_reviews');
      case '/showroom-decor':
        return context.tr('benefit_decor');
      case '/scrapyard':
        return context.tr('benefit_scrapyard');
      case '/rent-a-car':
        return context.tr('benefit_rent_car');
      case '/black-market':
        return context.tr('benefit_black_market');
      case '/side-businesses':
        return context.tr('benefit_side_biz');
      case '/districts':
        return context.tr('benefit_districts');
      case '/gossip':
        return context.tr('benefit_gossip');
      case '/consignment':
        return context.tr('benefit_consignment');
      case '/casino':
        return context.tr('benefit_casino');
      default:
        return context.tr('benefit_auto_branch', {'level': reqLevel});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.lockedItems.isEmpty) return const SizedBox.shrink();

    final currentItem =
        widget.lockedItems[_currentIndex % widget.lockedItems.length];
    final reqLevel = DealershipModel.getRequiredLevel(currentItem.route);
    final benefit =
        _getMotivationalBenefit(context, currentItem.route, reqLevel);
    final isDark = widget.isDark;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final glowColor = Color.lerp(
          const Color(0xFF6366F1),
          const Color(0xFFA5B4FC),
          _glowAnimation.value,
        )!;

        return SizedBox(
          height: 74,
          child: NeoBrutalCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            backgroundColor:
                isDark ? const Color(0xFF111424) : const Color(0xFFEEF2FF),
            borderColor: isDark ? glowColor : const Color(0xFF4F46E5),
            borderWidth: 2.3,
            borderRadius: 12,
            shadowColor: isDark
                ? const Color(0xFF6366F1)
                    .withValues(alpha: 0.25 * _glowAnimation.value)
                : const Color(0xFF0F172A),
            onTap: _nextTargetManually,
            child: Row(
              children: [
                // Heartbeat Animated Lock Icon Box
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isDark ? Colors.white24 : const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1)
                              .withValues(alpha: 0.4 * _glowAnimation.value),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 11),

                // Rotating Content Switcher with Slide & Fade Animation
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.0, 0.4),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey<String>(
                          '${currentItem.route}_$_currentIndex'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                currentItem.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            NeoBrutalBadge(
                              text: context.tr('next_target'),
                              backgroundColor: const Color(0xFF6366F1),
                              textColor: Colors.white,
                              fontSize: 8.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                            ),
                            if (widget.lockedItems.length > 1) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${_currentIndex + 1}/${widget.lockedItems.length}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? const Color(0xFF818CF8)
                                      : const Color(0xFF6366F1),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          benefit,
                          style: TextStyle(
                            fontSize: 10.8,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFA5B4FC)
                                : const Color(0xFF4338CA),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ŞUBELER Action Button
                NeoBrutalButton(
                  label: context.tr('branches_btn'),
                  fontSize: 10.5,
                  backgroundColor: const Color(0xFF6366F1),
                  textColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    context.push('/branches');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
