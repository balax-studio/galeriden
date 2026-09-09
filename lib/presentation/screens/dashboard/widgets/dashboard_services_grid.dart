import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
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
  final Color bgLight;
  final Color bgDark;
  final String route;
  final String? actionLabel;
  final String? telemetry;
  final IconData? telemetryIcon;

  const _ServiceItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.color,
    this.bgLight = Colors.white,
    this.bgDark = const Color(0xFF182030),
    required this.route,
    this.actionLabel,
    this.telemetry,
    this.telemetryIcon,
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
    final isRentUnlocked = game.isFeatureUnlocked('/rent-a-car');
    final isSideBizUnlocked = game.isFeatureUnlocked('/side-businesses');
    final isConsignmentUnlocked = game.isFeatureUnlocked('/consignment');
    final isNightMarketUnlocked = game.isFeatureUnlocked('/night-market');
    final isGossipUnlocked = game.isFeatureUnlocked('/gossip');
    final isDistrictsUnlocked = game.isFeatureUnlocked('/districts');
    final isCasinoUnlocked = game.isFeatureUnlocked('/casino');

    final bool useHangar = isWorkshopUnlocked || isWashUnlocked || isTuningUnlocked;
    final bool useBoulevard = isMarketplaceUnlocked || isVasitaUnlocked;
    final bool useAuctionFinance = isAuctionUnlocked || isFinanceUnlocked || isStocksUnlocked || isHistoryUnlocked;
    final bool useExecutiveDossier = isBranchesUnlocked || isRealEstateUnlocked || isStaffUnlocked;
    final bool hasAnyHubService = isReviewsUnlocked ||
        isSideBizUnlocked ||
        isRentUnlocked ||
        isScrapyardUnlocked ||
        isDecorUnlocked ||
        isNightMarketUnlocked ||
        isGossipUnlocked ||
        isConsignmentUnlocked ||
        isDistrictsUnlocked ||
        isCasinoUnlocked;

    final lockedItems = allServices.where((s) => !game.isFeatureUnlocked(s.route)).toList();

    final List<Widget> gridRows = [];

    // =========================================================================
    // GRİD 1: ÜST GRİD • GALERİ & OPERASYONEL ARAÇ YÖNETİMİ
    // (Showroom, Maslak Sanayi Mega Hangar, Açık Oto Pazarı & Vasıta)
    // =========================================================================
    final bool useCoreOps = isShowroomUnlocked || useHangar || useBoulevard;
    if (useCoreOps) {
      gridRows.add(_buildCategoryBanner(
        title: context.tr('section_core_operations'),
        subtitle: context.tr('section_core_operations_sub'),
        badgeText: 'DECK-01',
        badgeColor: const Color(0xFFFFDE59),
        isDark: isDark,
      ));
      gridRows.add(const SizedBox(height: 8));

      // 1. Showroom Flight-Deck Hero
      if (isShowroomUnlocked) {
        gridRows.add(_buildShowroomFlightDeckHero(context, ref, game, palette, isDark));
        gridRows.add(const SizedBox(height: 8));
      }

      // 2. Sanayi Endüstriyel Mega-Hangarı (Lift + Tuning + Oto Yıkama)
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

      // 3. Açık Oto Pazarı & Vasıta Boulevard Dock (Pazar Yeri + Vasıta)
      if (useBoulevard) {
        gridRows.add(_buildMarketBoulevardVasitaDock(
          context: context,
          ref: ref,
          game: game,
          palette: palette,
          isDark: isDark,
          isMarketplaceUnlocked: isMarketplaceUnlocked,
          isVasitaUnlocked: isVasitaUnlocked,
        ));
        gridRows.add(const SizedBox(height: 12));
      }
    }

    // =========================================================================
    // GRİD 2: FİNANS, BORSA & MÜZAYEDE TERMİNALİ
    // (Canlı İhale, Finans & Kasa, Borsa & Yatırım, Satış & Ciro Raporları)
    // =========================================================================
    if (useAuctionFinance) {
      gridRows.add(_buildCategoryBanner(
        title: context.tr('section_finance_terminal'),
        subtitle: context.tr('section_finance_terminal_sub'),
        badgeText: 'WALL STREET',
        badgeColor: const Color(0xFF00E575),
        isDark: isDark,
      ));
      gridRows.add(const SizedBox(height: 8));

      gridRows.add(_buildAuctionFinanceTerminal(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isAuctionUnlocked: isAuctionUnlocked,
        isFinanceUnlocked: isFinanceUnlocked,
        isStocksUnlocked: isStocksUnlocked,
        isHistoryUnlocked: isHistoryUnlocked,
      ));
      gridRows.add(const SizedBox(height: 12));
    }

    // =========================================================================
    // GRİD 3: MÜLK & HOLDİNG İMPARATORLUĞU
    // (Şubeler, Gayrimenkul Emlak, Personel Kadrosu)
    // =========================================================================
    if (useExecutiveDossier) {
      gridRows.add(_buildCategoryBanner(
        title: context.tr('section_holding_estate'),
        subtitle: context.tr('section_holding_estate_sub'),
        badgeText: 'EXECUTIVE',
        badgeColor: const Color(0xFF8B5CF6),
        isDark: isDark,
      ));
      gridRows.add(const SizedBox(height: 8));

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
      gridRows.add(const SizedBox(height: 12));
    }

    // =========================================================================
    // GRİD 4: KARABORSA NOIR HERO (Özel Kelepir Kaçak Fırsatlar)
    // =========================================================================
    if (isBlackMarketUnlocked) {
      gridRows.add(_buildCategoryBanner(
        title: context.tr('service_black_market'),
        subtitle: context.tr('service_black_market_sub'),
        badgeText: 'CLASSIFIED',
        badgeColor: const Color(0xFFEF4444),
        isDark: isDark,
      ));
      gridRows.add(const SizedBox(height: 8));
      gridRows.add(_buildBlackMarketNoirHero(context, ref, game, isDark));
      gridRows.add(const SizedBox(height: 12));
    }

    // =========================================================================
    // GRİD 5: ŞEHİR & YAN SEKTÖRLER OPERASYONEL HUB KUTUSU
    // (Fotoğraf 2'deki 10 Servis Tek Bir Kutu İçinde, Büyütülmüş Hero & Bento Matrisi)
    // =========================================================================
    if (hasAnyHubService) {
      gridRows.add(_buildCityOperationsHubBox(
        context: context,
        ref: ref,
        game: game,
        palette: palette,
        isDark: isDark,
        isReviewsUnlocked: isReviewsUnlocked,
        isSideBizUnlocked: isSideBizUnlocked,
        isRentUnlocked: isRentUnlocked,
        isScrapyardUnlocked: isScrapyardUnlocked,
        isDecorUnlocked: isDecorUnlocked,
        isNightMarketUnlocked: isNightMarketUnlocked,
        isGossipUnlocked: isGossipUnlocked,
        isConsignmentUnlocked: isConsignmentUnlocked,
        isDistrictsUnlocked: isDistrictsUnlocked,
        isCasinoUnlocked: isCasinoUnlocked,
      ));
      gridRows.add(const SizedBox(height: 10));
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

  Widget _buildCategoryBanner({
    required String title,
    required String subtitle,
    required String badgeText,
    required Color badgeColor,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1),
          width: 1.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
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
          NeoBrutalBadge(
            text: badgeText,
            backgroundColor: badgeColor,
            textColor: Colors.black,
            fontSize: 8.5,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          ),
        ],
      ),
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
                // Middle Equal-Height Asymmetric Split: 58% Lift Bay vs 42% Tuning Stage
                if (isWorkshopUnlocked || isTuningUnlocked)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFF7A00),
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              child: const Icon(
                                                Icons.build_circle_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
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
                                              fontSize: 8,
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
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
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Custom Workshop Telemetry Pill
                                        Row(
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: damagedCars > 0
                                                    ? const Color(0xFFEF4444)
                                                    : const Color(0xFF00E575),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                damagedCars > 0
                                                    ? context.tr('deck_workshop_lift_active')
                                                    : context.tr('deck_workshop_lift_empty'),
                                                style: TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: damagedCars > 0
                                                      ? const Color(0xFFEF4444)
                                                      : const Color(0xFF00E575),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    NeoBrutalButton(
                                      label: context.tr('deck_action_lift'),
                                      fontSize: 9.5,
                                      backgroundColor: const Color(0xFFFF7A00),
                                      textColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFA855F7),
                                                borderRadius: BorderRadius.circular(7),
                                              ),
                                              child: const Icon(
                                                Icons.speed_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            if (game.isFeatureNew('/tuning-studio'))
                                              _buildNotificationDot(isDark),
                                            const Spacer(),
                                            NeoBrutalBadge(
                                              text: context.tr('deck_tuning_stage_active'),
                                              backgroundColor: const Color(0xFFA855F7),
                                              textColor: Colors.white,
                                              fontSize: 8,
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
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
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Custom Tuning Telemetry Pill
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.bolt_rounded,
                                              size: 11,
                                              color: Color(0xFFA855F7),
                                            ),
                                            const SizedBox(width: 3),
                                            Expanded(
                                              child: Text(
                                                context.tr('deck_tuning_hp_boost'),
                                                style: const TextStyle(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFA855F7),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    NeoBrutalButton(
                                      label: context.tr('deck_action_tuning'),
                                      fontSize: 9.5,
                                      backgroundColor: const Color(0xFFA855F7),
                                      textColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                      onPressed: () {
                                        ref.read(gameProvider.notifier).markFeatureSeen('/tuning-studio');
                                        context.push('/tuning-studio');
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                // ZONE C: Detailing & Oto Yıkama (Full Width Bottom Ribbon)
                if (isWashUnlocked) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      ref.read(gameProvider.notifier).markFeatureSeen('/car-wash');
                      context.push('/car-wash');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                                      : context.tr('deck_wash_foam_ready'),
                                  style: TextStyle(
                                    fontSize: 9.5,
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
  }) {
    // Both items paired side-by-side with equal height
    if (isMarketplaceUnlocked && isVasitaUnlocked) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pazar Yeri Card (56%)
            Expanded(
              flex: 56,
              child: _buildMarketplaceCard(
                context: context,
                ref: ref,
                game: game,
                isDark: isDark,
                isStandalone: false,
              ),
            ),
            const SizedBox(width: 8),
            // Vasıta Card (44%)
            Expanded(
              flex: 44,
              child: _buildVasitaCard(context, ref, game, isDark),
            ),
          ],
        ),
      );
    } else if (isMarketplaceUnlocked) {
      return _buildMarketplaceCard(
        context: context,
        ref: ref,
        game: game,
        isDark: isDark,
        isStandalone: true,
      );
    } else if (isVasitaUnlocked) {
      return _buildVasitaCard(context, ref, game, isDark);
    }
    return const SizedBox.shrink();
  }

  Widget _buildMarketplaceCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required bool isStandalone,
  }) {
    final freshBadgeText = context.tr('bento_badge_fresh');
    final safeFreshBadge =
        freshBadgeText == 'bento_badge_fresh' ? 'YENİ İLANLAR' : freshBadgeText;

    if (isStandalone) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor:
            isDark ? const Color(0xFF0F2338) : const Color(0xFFF0F9FF),
        borderColor: const Color(0xFF38BDF8),
        borderWidth: 2.4,
        borderRadius: 14,
        onTap: () {
          ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
          context.push('/marketplace');
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
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
                    size: 20,
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
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF7DD3FC)
                              : const Color(0xFF0369A1),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: safeFreshBadge,
                  backgroundColor: const Color(0xFF38BDF8),
                  textColor: const Color(0xFF0F172A),
                  fontSize: 9,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF081827) : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E3A5F)
                      : const Color(0xFFBAE6FD),
                  width: 1.4,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_car_filled_rounded,
                          size: 13,
                          color: Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            context.tr('deck_market_live_ads'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFBAE6FD)
                                  : const Color(0xFF0369A1),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 14,
                    color: isDark
                        ? const Color(0xFF1E3A5F)
                        : const Color(0xFFBAE6FD),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_offer_rounded,
                        size: 12,
                        color: Color(0xFF38BDF8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        context.tr('deck_market_opportunity_tag'),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF7DD3FC)
                              : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            NeoBrutalButton(
              label: context.tr('deck_action_go_market'),
              fontSize: 11,
              backgroundColor: const Color(0xFF38BDF8),
              textColor: const Color(0xFF0F172A),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              onPressed: () {
                ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
                context.push('/marketplace');
              },
            ),
          ],
        ),
      );
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.all(9),
      backgroundColor:
          isDark ? const Color(0xFF0F2338) : const Color(0xFFF0F9FF),
      borderColor: const Color(0xFF38BDF8),
      borderWidth: 2.2,
      borderRadius: 14,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
        context.push('/marketplace');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38BDF8),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (game.isFeatureNew('/marketplace'))
                    _buildNotificationDot(isDark),
                  const Spacer(),
                  NeoBrutalBadge(
                    text: safeFreshBadge,
                    backgroundColor: const Color(0xFF38BDF8),
                    textColor: const Color(0xFF0F172A),
                    fontSize: 8,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('service_buy_car'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.tr('deck_market_boulevard'),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF7DD3FC)
                      : const Color(0xFF0369A1),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.directions_car_filled_rounded,
                    size: 11,
                    color: Color(0xFF38BDF8),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      context.tr('deck_market_live_ads'),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFF7DD3FC)
                            : const Color(0xFF0284C7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          NeoBrutalButton(
            label: context.tr('bento_action_market'),
            fontSize: 9.5,
            backgroundColor: const Color(0xFF38BDF8),
            textColor: const Color(0xFF0F172A),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
              context.push('/marketplace');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVasitaCard(BuildContext context, WidgetRef ref, DealershipModel game, bool isDark) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(9),
      backgroundColor: isDark ? const Color(0xFF0E2833) : const Color(0xFFE0F7FA),
      borderColor: const Color(0xFF06B6D4),
      borderWidth: 2.2,
      borderRadius: 14,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/vasita');
        context.push('/vasita');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_boat_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (game.isFeatureNew('/vasita'))
                    _buildNotificationDot(isDark),
                  const Spacer(),
                  NeoBrutalBadge(
                    text: context.tr('deck_vasita_luxury_badge'),
                    backgroundColor: const Color(0xFF06B6D4),
                    textColor: Colors.white,
                    fontSize: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.sailing_rounded,
                    size: 11,
                    color: Color(0xFF06B6D4),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      context.tr('deck_vasita_luxury_badge'),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0891B2),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          NeoBrutalButton(
            label: context.tr('deck_action_vasita'),
            fontSize: 9.5,
            backgroundColor: const Color(0xFF06B6D4),
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/vasita');
              context.push('/vasita');
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPOLOGY 4: CANLI İHALE, FİNANS & BORSA WALL STREET TERMİNALİ
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
    required bool isHistoryUnlocked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Red Alert Live Auction Ticker
        if (isAuctionUnlocked)
          NeoBrutalCard(
            padding: const EdgeInsets.all(11),
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
                  padding: const EdgeInsets.all(7),
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
                    size: 20,
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
                              fontSize: 14,
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
                        angle: -0.02,
                        alignment: Alignment.centerLeft,
                        child: NeoBrutalBadge(
                          text: context.tr('deck_auction_ticker'),
                          backgroundColor: const Color(0xFFEF4444),
                          textColor: Colors.white,
                          fontSize: 8.5,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: context.tr('bento_action_bid'),
                  fontSize: 10,
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

        // Middle Equal-Height Split: Finans (52%) vs Borsa (48%)
        if (isFinanceUnlocked || isStocksUnlocked) ...[
          if (isAuctionUnlocked) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Finans & Kasa Pod (52%)
                if (isFinanceUnlocked)
                  Expanded(
                    flex: 52,
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(9),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E575),
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: const Color(0xFF0F172A),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.account_balance_rounded,
                                      size: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (game.isFeatureNew('/finance'))
                                    _buildNotificationDot(isDark),
                                  const Spacer(),
                                  NeoBrutalBadge(
                                    text: context.tr('bento_badge_debt_clean'),
                                    backgroundColor: const Color(0xFF00E575),
                                    textColor: Colors.black,
                                    fontSize: 8,
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
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
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 11,
                                    color: Color(0xFF00E575),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      context.tr('deck_finance_cashflow_positive'),
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          NeoBrutalButton(
                            label: context.tr('bento_action_bank'),
                            fontSize: 9.5,
                            backgroundColor: const Color(0xFF00E575),
                            textColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                  const SizedBox(width: 8),

                // Borsa Portföyü Pod (48%)
                if (isStocksUnlocked)
                  Expanded(
                    flex: 48,
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(9),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1),
                                      borderRadius: BorderRadius.circular(7),
                                      border: Border.all(
                                        color: const Color(0xFF0F172A),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  if (game.isFeatureNew('/stock-market'))
                                    _buildNotificationDot(isDark),
                                  const Spacer(),
                                  NeoBrutalBadge(
                                    text: '${game.ownedStocks.length} Hisse',
                                    backgroundColor: const Color(0xFF6366F1),
                                    textColor: Colors.white,
                                    fontSize: 8,
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
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
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.query_stats_rounded,
                                    size: 11,
                                    color: Color(0xFF6366F1),
                                  ),
                                  const SizedBox(width: 3),
                                  Expanded(
                                    child: Text(
                                      context.tr('deck_stocks_bist_trend'),
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          NeoBrutalButton(
                            label: context.tr('deck_action_portfolio'),
                            fontSize: 9.5,
                            backgroundColor: const Color(0xFF6366F1),
                            textColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
          ),
        ],

        // Bottom Full-Width Satış & Ciro Raporları Şeridi
        if (isHistoryUnlocked) ...[
          const SizedBox(height: 8),
          NeoBrutalCard(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            backgroundColor: isDark ? const Color(0xFF282312) : const Color(0xFFFFFBEB),
            borderColor: const Color(0xFFF59E0B),
            borderWidth: 2.2,
            borderRadius: 12,
            onTap: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/history');
              context.push('/history');
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.history_edu_rounded,
                    size: 18,
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
                            context.tr('service_history'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          if (game.isFeatureNew('/history')) ...[
                            const SizedBox(width: 5),
                            _buildNotificationDot(isDark),
                          ],
                          const SizedBox(width: 6),
                          NeoBrutalBadge(
                            text: context.tr('telemetry_sales_count', {'count': '${game.carsSold}'}),
                            backgroundColor: const Color(0xFFF59E0B),
                            textColor: Colors.black,
                            fontSize: 8,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('deck_sales_revenue_track'),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: context.tr('deck_action_history'),
                  fontSize: 9.5,
                  backgroundColor: const Color(0xFFF59E0B),
                  textColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  onPressed: () {
                    ref.read(gameProvider.notifier).markFeatureSeen('/history');
                    context.push('/history');
                  },
                ),
              ],
            ),
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
        // 1. Top Imperial Branches Prestige Hero
        if (isBranchesUnlocked)
          _buildBranchNetworkHero(context, ref, game, palette, isDark),

        // 2. Asymmetric Tier 1: Emlak Pazarı (52%) vs Personel Kadrosu (48%)
        if (isRealEstateUnlocked || isStaffUnlocked) ...[
          if (isBranchesUnlocked) const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isRealEstateUnlocked)
                  Expanded(
                    flex: isStaffUnlocked ? 52 : 100,
                    child: _buildRealEstateCard(context, ref, game, isDark),
                  ),
                if (isRealEstateUnlocked && isStaffUnlocked)
                  const SizedBox(width: 8),
                if (isStaffUnlocked)
                  Expanded(
                    flex: isRealEstateUnlocked ? 48 : 100,
                    child: _buildStaffCard(context, ref, game, isDark),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBranchNetworkHero(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    ThemePaletteModel palette,
    bool isDark,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(11),
      backgroundColor:
          isDark ? const Color(0xFF23143B) : const Color(0xFFF5F3FF),
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
            padding: const EdgeInsets.all(7),
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
              size: 20,
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
                        fontSize: 14,
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
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFC4B5FD)
                        : const Color(0xFF6D28D9),
                  ),
                ),
              ],
            ),
          ),
          NeoBrutalButton(
            label: context.tr('bento_action_branches'),
            fontSize: 10,
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
    );
  }

  Widget _buildRealEstateCard(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    bool isDark,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(9),
      backgroundColor:
          isDark ? const Color(0xFF102B21) : const Color(0xFFECFDF5),
      borderColor: const Color(0xFF10B981),
      borderWidth: 2.2,
      borderRadius: 12,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/emlak');
        context.push('/emlak');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.domain_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (game.isFeatureNew('/emlak'))
                    _buildNotificationDot(isDark),
                  const Spacer(),
                  NeoBrutalBadge(
                    text: '${game.ownedRealEstates.length} Mülk',
                    backgroundColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                    fontSize: 8,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.real_estate_agent_rounded,
                    size: 11,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      context.tr('deck_real_estate_income'),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFF6EE7B7)
                            : const Color(0xFF047857),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          NeoBrutalButton(
            label: context.tr('deck_action_real_estate'),
            fontSize: 9.5,
            backgroundColor: const Color(0xFF10B981),
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/emlak');
              context.push('/emlak');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    bool isDark,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(9),
      backgroundColor:
          isDark ? const Color(0xFF2C1425) : const Color(0xFFFDF2F8),
      borderColor: const Color(0xFFEC4899),
      borderWidth: 2.2,
      borderRadius: 12,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/staff');
        context.push('/staff');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (game.isFeatureNew('/staff'))
                    _buildNotificationDot(isDark),
                  const Spacer(),
                  NeoBrutalBadge(
                    text: '${game.hiredStaff.length} Personel',
                    backgroundColor: const Color(0xFFEC4899),
                    textColor: Colors.white,
                    fontSize: 8,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  ),
                ],
              ),
              const SizedBox(height: 6),
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
                context.tr('service_staff_sub',
                    {'count': game.hiredStaff.length}),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    size: 11,
                    color: Color(0xFFEC4899),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      context.tr('deck_staff_efficiency'),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFF472B6)
                            : const Color(0xFFDB2777),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          NeoBrutalButton(
            label: context.tr('deck_action_staff'),
            fontSize: 9.5,
            backgroundColor: const Color(0xFFEC4899),
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen('/staff');
              context.push('/staff');
            },
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPOLOGY 6: ŞEHİR & YAN SEKTÖRLER OPERASYONEL HUB KUTUSU
  // ===========================================================================
  Widget _buildCityOperationsHubBox({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required ThemePaletteModel palette,
    required bool isDark,
    required bool isReviewsUnlocked,
    required bool isSideBizUnlocked,
    required bool isRentUnlocked,
    required bool isScrapyardUnlocked,
    required bool isDecorUnlocked,
    required bool isNightMarketUnlocked,
    required bool isGossipUnlocked,
    required bool isConsignmentUnlocked,
    required bool isDistrictsUnlocked,
    required bool isCasinoUnlocked,
  }) {
    final unlockedHubServices = <_ServiceItem>[
      if (isReviewsUnlocked)
        _ServiceItem(
          icon: Icons.reviews_rounded,
          color: const Color(0xFFF59E0B),
          bgLight: const Color(0xFFFFFBEB),
          bgDark: const Color(0xFF261D07),
          title: context.tr('service_reviews'),
          subtitle: context.tr('service_reviews_sub',
              {'rep': game.reputationScore}),
          telemetry: context.tr('deck_reviews_telemetry'),
          telemetryIcon: Icons.star_rounded,
          actionLabel: context.tr('deck_action_reviews'),
          route: '/reviews',
          badge: '${game.reputationScore} İtibar',
        ),
      if (isSideBizUnlocked)
        _ServiceItem(
          icon: Icons.business_center_rounded,
          color: const Color(0xFF10B981),
          bgLight: const Color(0xFFF0FDF4),
          bgDark: const Color(0xFF072418),
          title: context.tr('service_side_biz'),
          subtitle: context.tr('service_side_biz_sub'),
          telemetry: context.tr('deck_biz_passive'),
          telemetryIcon: Icons.trending_up_rounded,
          actionLabel: context.tr('deck_action_businesses'),
          route: '/side-businesses',
          badge:
              '${game.sideBusinesses.where((b) => b.isOwned).length}/11 Tesis',
        ),
      if (isRentUnlocked)
        _ServiceItem(
          icon: Icons.car_rental_rounded,
          color: const Color(0xFF0284C7),
          bgLight: const Color(0xFFF0F9FF),
          bgDark: const Color(0xFF082236),
          title: context.tr('service_rent_car'),
          subtitle: context.tr('service_rent_car_sub'),
          telemetry: context.tr('deck_rent_status'),
          telemetryIcon: Icons.key_rounded,
          actionLabel: context.tr('deck_action_rent'),
          route: '/rent-a-car',
          badge: '${game.activeRentals.length} Kirada',
        ),
      if (isScrapyardUnlocked)
        _ServiceItem(
          icon: Icons.delete_sweep_rounded,
          color: const Color(0xFF64748B),
          bgLight: const Color(0xFFF1F5F9),
          bgDark: const Color(0xFF151E2B),
          title: context.tr('service_scrapyard'),
          subtitle: context.tr('service_scrapyard_sub'),
          telemetry: context.tr('deck_scrapyard_telemetry'),
          telemetryIcon: Icons.build_rounded,
          actionLabel: context.tr('deck_action_salvage'),
          route: '/scrapyard',
          badge: '${game.salvagedParts.length} Parça',
        ),
      if (isDecorUnlocked)
        _ServiceItem(
          icon: Icons.palette_rounded,
          color: const Color(0xFF8B5CF6),
          bgLight: const Color(0xFFF5F3FF),
          bgDark: const Color(0xFF1E1535),
          title: context.tr('service_decor'),
          subtitle: context.tr('service_decor_sub'),
          telemetry: context.tr('deck_decor_telemetry'),
          telemetryIcon: Icons.palette_rounded,
          actionLabel: context.tr('deck_action_decor'),
          route: '/showroom-decor',
          badge: '${game.unlockedDecorIds.length + 1} Tema',
        ),
      if (isConsignmentUnlocked)
        _ServiceItem(
          icon: Icons.handshake_rounded,
          color: const Color(0xFF059669),
          bgLight: const Color(0xFFECFDF5),
          bgDark: const Color(0xFF07261C),
          title: context.tr('service_consignment'),
          subtitle: context.tr('service_consignment_sub'),
          telemetry: context.tr('deck_consignment_badge'),
          telemetryIcon: Icons.handshake_rounded,
          actionLabel: context.tr('deck_action_consignment'),
          route: '/consignment',
          badge: '${game.consignmentOffers.length} Teklif',
        ),
      if (isNightMarketUnlocked)
        _ServiceItem(
          icon: Icons.sports_score_rounded,
          color: const Color(0xFFF43F5E),
          bgLight: const Color(0xFFFFF1F2),
          bgDark: const Color(0xFF2B0A14),
          title: context.tr('service_night_market'),
          subtitle: context.tr('service_night_market_sub'),
          telemetry: context.tr('deck_night_drag_telemetry'),
          telemetryIcon: Icons.local_fire_department_rounded,
          actionLabel: context.tr('deck_action_night_market'),
          route: '/night-market',
          badge: 'Drag & Modifiye',
        ),
      if (isGossipUnlocked)
        _ServiceItem(
          icon: Icons.record_voice_over_rounded,
          color: const Color(0xFFEAB308),
          bgLight: const Color(0xFFFEF9C3),
          bgDark: const Color(0xFF262005),
          title: context.tr('service_gossip'),
          subtitle: context.tr('service_gossip_sub'),
          telemetry: context.tr('deck_gossip_telemetry'),
          telemetryIcon: Icons.campaign_rounded,
          actionLabel: context.tr('deck_action_gossip'),
          route: '/gossip',
          badge: '${game.activeGossips.length} Fısıltı',
        ),
      if (isDistrictsUnlocked)
        _ServiceItem(
          icon: Icons.map_rounded,
          color: const Color(0xFF0284C7),
          bgLight: const Color(0xFFF0FDF9),
          bgDark: const Color(0xFF0A2422),
          title: context.tr('service_district'),
          subtitle: context.tr('service_district_sub'),
          telemetry: context.tr('deck_districts_telemetry'),
          telemetryIcon: Icons.pie_chart_rounded,
          actionLabel: context.tr('deck_action_districts'),
          route: '/districts',
          badge:
              '${game.districtMarketShare.values.where((v) => v >= 0.05).length} Semt',
        ),
      if (isCasinoUnlocked)
        _ServiceItem(
          icon: Icons.casino_rounded,
          color: const Color(0xFFFFD700),
          bgLight: const Color(0xFFFEFCE8),
          bgDark: const Color(0xFF261D04),
          title: context.tr('service_casino'),
          subtitle: context.tr('service_casino_sub'),
          telemetry: context.tr('deck_casino_telemetry'),
          telemetryIcon: Icons.casino_rounded,
          actionLabel: context.tr('deck_action_casino'),
          route: '/casino',
          badge: 'VIP Masalar',
        ),
    ];

    if (unlockedHubServices.isEmpty) return const SizedBox.shrink();

    // Extract dedicated VIP Casino Strip if unlocked (keeps the bottom anchored like in the layout)
    _ServiceItem? casinoItem;
    if (isCasinoUnlocked) {
      final idx = unlockedHubServices.indexWhere((s) => s.route == '/casino');
      if (idx != -1) {
        casinoItem = unlockedHubServices[idx];
      }
    }

    final nonCasinoServices = unlockedHubServices
        .where((s) => s.route != '/casino')
        .toList();

    // Determine Hero Feature Slot ("dinamik seviyeye göre bunları büyüt")
    _ServiceItem? heroService;
    List<_ServiceItem> gridServices = [];

    if (isSideBizUnlocked) {
      final idx = nonCasinoServices.indexWhere((s) => s.route == '/side-businesses');
      if (idx != -1) {
        heroService = nonCasinoServices[idx];
        gridServices = nonCasinoServices
            .where((s) => s.route != '/side-businesses')
            .toList();
      } else {
        heroService = nonCasinoServices.firstOrNull;
        gridServices = nonCasinoServices.skip(1).toList();
      }
    } else {
      heroService = nonCasinoServices.firstOrNull;
      gridServices = nonCasinoServices.skip(1).toList();
    }

    final double totalPassive = game.sideBusinesses
        .where((b) => b.isOwned)
        .fold(0.0, (sum, b) => sum + b.dailyIncome);

    String? nextUnlockText;
    if (!isSideBizUnlocked ||
        !isRentUnlocked ||
        !isScrapyardUnlocked ||
        !isDecorUnlocked) {
      nextUnlockText = context
          .tr('hub_next_unlock_teaser', {'level': '2', 'name': 'Yan İşletmeler'});
    } else if (!isConsignmentUnlocked ||
        !isNightMarketUnlocked ||
        !isGossipUnlocked) {
      nextUnlockText = context
          .tr('hub_next_unlock_teaser', {'level': '3', 'name': 'Gece Sanayisi'});
    } else if (!isDistrictsUnlocked) {
      nextUnlockText = context
          .tr('hub_next_unlock_teaser', {'level': '4', 'name': 'Semt Hakimiyeti'});
    } else if (!isCasinoUnlocked) {
      nextUnlockText = context
          .tr('hub_next_unlock_teaser', {'level': '5', 'name': 'Yeraltı Casino'});
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101726) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : const Color(0xFF0F172A),
            offset: const Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFF0F172A), width: 1.5),
                ),
                child:
                    const Icon(Icons.hub_rounded, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('hub_city_operations_title'),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      context.tr('hub_city_operations_sub'),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (totalPassive > 0) ...[
                NeoBrutalBadge(
                  text: '+${CurrencyFormatter.formatShort(totalPassive)} / gün',
                  backgroundColor: const Color(0xFF00E575),
                  textColor: Colors.black,
                  fontSize: 8.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                ),
                const SizedBox(width: 5),
              ],
              NeoBrutalBadge(
                text: context.tr('hub_active_badge',
                    {'count': '${unlockedHubServices.length}'}),
                backgroundColor: const Color(0xFF10B981),
                textColor: Colors.white,
                fontSize: 8.5,
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Enlarge Hero Feature Slot ("dinamik seviyeye göre bunları büyüt")
          if (heroService != null) ...[
            _buildHubHeroCard(
              context: context,
              ref: ref,
              game: game,
              isDark: isDark,
              item: heroService,
            ),
            if (gridServices.isNotEmpty) const SizedBox(height: 8),
          ],

          // 2-Column Proportional Bento Grid (Not long horizontal strips!)
          for (int i = 0; i < gridServices.length; i += 2) ...[
            if (i > 0) const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildHubBentoTile(
                      context: context,
                      ref: ref,
                      game: game,
                      isDark: isDark,
                      item: gridServices[i],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (i + 1 < gridServices.length)
                    Expanded(
                      child: _buildHubBentoTile(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: gridServices[i + 1],
                      ),
                    )
                  else
                    const Expanded(child: SizedBox.shrink()),
                ],
              ),
            ),
          ],

          // Dedicated VIP Casino Strip (Anchors the bottom in High-Roller Gold/Noir)
          if (casinoItem != null) ...[
            const SizedBox(height: 8),
            _buildHubCasinoStrip(
              context: context,
              ref: ref,
              game: game,
              isDark: isDark,
              item: casinoItem,
            ),
          ],

          // Next Level Target Teaser (bilişsel yükü azaltan kademeli hedef)
          if (nextUnlockText != null) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                    : const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 11,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    nextUnlockText,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHubHeroCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
  }) {
    final isNew = game.isFeatureNew(item.route);
    final isSideBiz = item.route == '/side-businesses';
    final double passiveIncome = game.sideBusinesses
        .where((b) => b.isOwned)
        .fold(0.0, (sum, b) => sum + b.dailyIncome);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(11),
      backgroundColor: isDark ? item.bgDark : item.bgLight,
      borderColor: item.color,
      borderWidth: 2.5,
      borderRadius: 14,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.6,
                  ),
                ),
                child: Icon(item.icon, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        if (isNew) ...[
                          const SizedBox(width: 5),
                          _buildNotificationDot(isDark),
                        ],
                      ],
                    ),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (item.badge != null)
                NeoBrutalBadge(
                  text: item.badge!,
                  backgroundColor: item.color,
                  textColor: Colors.white,
                  fontSize: 8.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Rich Telemetry & Matrix
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: item.color.withValues(alpha: isDark ? 0.6 : 0.4),
                width: 1.3,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      item.telemetryIcon ?? Icons.auto_graph_rounded,
                      size: 14,
                      color: item.color,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        item.telemetry ?? context.tr('deck_biz_passive'),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSideBiz && passiveIncome > 0)
                      Text(
                        '+${CurrencyFormatter.formatShort(passiveIncome)} / gün',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF047857),
                        ),
                      ),
                  ],
                ),
                if (isSideBiz) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (int i = 0; i < game.sideBusinesses.length; i++)
                        Container(
                          width: 20,
                          height: 15,
                          decoration: BoxDecoration(
                            color: game.sideBusinesses[i].isOwned
                                ? (isDark
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF86EFAC))
                                : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(3.5),
                            border: Border.all(
                              color: game.sideBusinesses[i].isOwned
                                  ? const Color(0xFF10B981)
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFCBD5E1)),
                              width: 1.1,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              game.sideBusinesses[i].isOwned
                                  ? Icons.check_rounded
                                  : Icons.domain_rounded,
                              size: 9,
                              color: game.sideBusinesses[i].isOwned
                                  ? (isDark
                                      ? Colors.white
                                      : const Color(0xFF047857))
                                  : (isDark
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          NeoBrutalButton(
            label: item.actionLabel ?? context.tr('deck_action_businesses'),
            fontSize: 10.5,
            backgroundColor: item.color,
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen(item.route);
              context.push(item.route);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHubBentoTile({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
  }) {
    final isNew = game.isFeatureNew(item.route);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(9),
      backgroundColor: isDark ? item.bgDark : item.bgLight,
      borderColor: item.color,
      borderWidth: 2.2,
      borderRadius: 12,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.4,
                      ),
                    ),
                    child: Icon(item.icon, size: 15, color: Colors.black),
                  ),
                  const SizedBox(width: 5),
                  if (isNew) _buildNotificationDot(isDark),
                  const Spacer(),
                  if (item.badge != null && item.badge!.isNotEmpty)
                    NeoBrutalBadge(
                      text: item.badge!,
                      backgroundColor: item.color,
                      textColor: Colors.black,
                      fontSize: 7.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              // Dedicated Live Telemetry Box (eliminates "sönük" feel)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.35)
                      : Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.color.withValues(alpha: isDark ? 0.5 : 0.4),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.telemetryIcon ?? Icons.bolt_rounded,
                      size: 11,
                      color: item.color,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.telemetry ?? item.subtitle,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          NeoBrutalButton(
            label: item.actionLabel ?? 'İNCELE',
            fontSize: 9.5,
            backgroundColor: item.color,
            textColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen(item.route);
              context.push(item.route);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHubCasinoStrip({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
  }) {
    final isNew = game.isFeatureNew(item.route);

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      backgroundColor:
          isDark ? const Color(0xFF261D04) : const Color(0xFFFEFCE8),
      borderColor: const Color(0xFFFFD700),
      borderWidth: 2.4,
      borderRadius: 13,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF0F172A),
                width: 1.6,
              ),
            ),
            child: const Icon(Icons.casino_rounded, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 5),
                      _buildNotificationDot(isDark),
                    ],
                    const SizedBox(width: 6),
                    NeoBrutalBadge(
                      text: 'VIP',
                      backgroundColor: const Color(0xFFFFD700),
                      textColor: Colors.black,
                      fontSize: 8,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1.5),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.subtitle,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFFDE68A)
                        : const Color(0xFF92400E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: item.actionLabel ?? 'MASALARA OTUR',
            fontSize: 9.5,
            backgroundColor: const Color(0xFFFFD700),
            textColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: () {
              ref.read(gameProvider.notifier).markFeatureSeen(item.route);
              context.push(item.route);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBlackMarketNoirHero(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    bool isDark,
  ) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(11),
      backgroundColor:
          isDark ? const Color(0xFF17131A) : const Color(0xFF1E1B24),
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
            padding: const EdgeInsets.all(7),
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
              size: 20,
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
                        fontSize: 14,
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
                  angle: 0.02,
                  alignment: Alignment.centerLeft,
                  child: NeoBrutalBadge(
                    text: context.tr('deck_classified_stamp'),
                    backgroundColor: const Color(0xFFDC2626),
                    textColor: Colors.white,
                    fontSize: 8.5,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
