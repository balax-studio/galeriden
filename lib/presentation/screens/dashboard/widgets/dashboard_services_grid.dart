import 'dart:async';
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
import '../../../widgets/blueprint_grid_background.dart';
import 'hub_service_illustrations.dart';

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
    // DECK 1: GALERİ & ARAÇ TİCARETİ HERO (Deck-01)
    // (Showroom Flight-Deck Hero & Market Boulevard Dock)
    // =========================================================================
    final bool useHeroOps = isShowroomUnlocked || useBoulevard;
    if (useHeroOps) {
      final List<Widget> deck1Cards = [];
      if (isShowroomUnlocked) {
        deck1Cards.add(_buildShowroomFlightDeckHero(context, ref, game, palette, isDark));
      }
      if (useBoulevard) {
        if (deck1Cards.isNotEmpty) deck1Cards.add(const SizedBox(height: 8));
        deck1Cards.add(_buildMarketBoulevardVasitaDock(
          context: context,
          ref: ref,
          game: game,
          palette: palette,
          isDark: isDark,
          isMarketplaceUnlocked: isMarketplaceUnlocked,
          isVasitaUnlocked: isVasitaUnlocked,
        ));
      }

      gridRows.add(_buildDeckContainer(
        context: context,
        isDark: isDark,
        icon: Icons.directions_car_rounded,
        iconBgColor: const Color(0xFFFFDE59),
        title: context.tr('section_core_operations'),
        subtitle: context.tr('section_hero_dealership_sub'),
        badgeText: 'HERO DECK',
        badgeColor: const Color(0xFFFFDE59),
        children: deck1Cards,
      ));
      gridRows.add(const SizedBox(height: 10));
    }

    // =========================================================================
    // DECK 2: MASLAK SANAYİ ENDÜSTRİYEL MEGA HANGAR (Deck-02)
    // (Oto Yıkama Tall Bento Pod, Tamir & Atölye, Tuning Stüdyosu)
    // =========================================================================
    if (useHangar) {
      gridRows.add(_buildDeckContainer(
        context: context,
        isDark: isDark,
        icon: Icons.build_circle_rounded,
        iconBgColor: const Color(0xFFFF7A00),
        title: context.tr('section_sanayi_hangar'),
        subtitle: context.tr('section_sanayi_hangar_sub'),
        badgeText: 'HANGAR',
        badgeColor: const Color(0xFFFF7A00),
        children: [
          _buildSanayiMegaHangar(
            context: context,
            ref: ref,
            game: game,
            palette: palette,
            isDark: isDark,
            isWorkshopUnlocked: isWorkshopUnlocked,
            isWashUnlocked: isWashUnlocked,
            isTuningUnlocked: isTuningUnlocked,
          ),
        ],
      ));
      gridRows.add(const SizedBox(height: 10));
    }

    // =========================================================================
    // DECK 3: FİNANS, BORSA & MÜZAYEDE TERMİNALİ (Deck-03)
    // (Canlı İhale, Finans & Kasa, Borsa & Yatırım, Satış & Ciro Raporları)
    // =========================================================================
    if (useAuctionFinance) {
      gridRows.add(_buildDeckContainer(
        context: context,
        isDark: isDark,
        icon: Icons.account_balance_rounded,
        iconBgColor: const Color(0xFF00E575),
        title: context.tr('section_finance_terminal'),
        subtitle: context.tr('section_finance_terminal_sub'),
        badgeText: 'WALL STREET',
        badgeColor: const Color(0xFF00E575),
        children: [
          _buildAuctionFinanceTerminal(
            context: context,
            ref: ref,
            game: game,
            palette: palette,
            isDark: isDark,
            isAuctionUnlocked: isAuctionUnlocked,
            isFinanceUnlocked: isFinanceUnlocked,
            isStocksUnlocked: isStocksUnlocked,
            isHistoryUnlocked: isHistoryUnlocked,
          ),
        ],
      ));
      gridRows.add(const SizedBox(height: 10));
    }

    // =========================================================================
    // DECK 4: MÜLK & HOLDİNG İMPARATORLUĞU (Deck-04)
    // (Şubeler, Gayrimenkul Emlak, Personel Kadrosu)
    // =========================================================================
    if (useExecutiveDossier) {
      gridRows.add(_buildDeckContainer(
        context: context,
        isDark: isDark,
        icon: Icons.domain_rounded,
        iconBgColor: const Color(0xFF8B5CF6),
        title: context.tr('section_holding_estate'),
        subtitle: context.tr('section_holding_estate_sub'),
        badgeText: 'EXECUTIVE',
        badgeColor: const Color(0xFF8B5CF6),
        children: [
          _buildHoldingExecutiveDossier(
            context: context,
            ref: ref,
            game: game,
            palette: palette,
            isDark: isDark,
            isBranchesUnlocked: isBranchesUnlocked,
            isRealEstateUnlocked: isRealEstateUnlocked,
            isStaffUnlocked: isStaffUnlocked,
          ),
        ],
      ));
      gridRows.add(const SizedBox(height: 10));
    }

    // =========================================================================
    // DECK: KARABORSA NOIR HERO (Özel Kelepir Kaçak Fırsatlar)
    // =========================================================================
    if (isBlackMarketUnlocked) {
      gridRows.add(_buildDeckContainer(
        context: context,
        isDark: isDark,
        icon: Icons.masks_rounded,
        iconBgColor: const Color(0xFFDC2626),
        title: context.tr('service_black_market'),
        subtitle: context.tr('service_black_market_sub'),
        badgeText: 'CLASSIFIED',
        badgeColor: const Color(0xFFEF4444),
        children: [
          _buildBlackMarketNoirHero(context, ref, game, isDark),
        ],
      ));
      gridRows.add(const SizedBox(height: 10));
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

  // ===========================================================================
  // TACTICAL DESIGN HELPERS: DUTCH ANGLE BADGE & DIRECTIONAL PILL
  // ===========================================================================
  Widget _buildDutchAngleBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
    double angle = -0.06, // ~ -3.5 degrees
    double fontSize = 8.5,
  }) {
    return Transform.rotate(
      angle: angle,
      child: NeoBrutalBadge(
        text: text,
        backgroundColor: backgroundColor,
        textColor: textColor,
        fontSize: fontSize,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      ),
    );
  }

  Widget _buildDirectionalPill({
    required bool isDark,
    Color? arrowColor,
    Color? bgColor,
    double size = 26,
    double iconSize = 15,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor ?? (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_forward_rounded,
          size: iconSize,
          color: arrowColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  // ===========================================================================
  // REUSABLE NEO-BRUTALIST DECK CONTAINER BOX
  // ===========================================================================
  Widget _buildDeckContainer({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required Color iconBgColor,
    required String title,
    String? subtitle,
    required String badgeText,
    required Color badgeColor,
    required List<Widget> children,
  }) {
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
          // Deck Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: Icon(icon, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
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
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NeoBrutalBadge(
                text: badgeText,
                backgroundColor: badgeColor,
                textColor: Colors.black,
                fontSize: 8.5,
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }



  // ===========================================================================
  // TYPOLOGY 1: SHOWROOM FLIGHT-DECK HERO (Sleek Minimalist Capacity Deck)
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
    final capacityRatio = maxSlots > 0 ? (carsCount / maxSlots).clamp(0.0, 1.0) : 0.0;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 14,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/showroom');
        context.push('/showroom');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Showroom Title & Identity Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF0F172A),
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  size: 24,
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
                        Flexible(
                          child: Text(
                            context.tr('service_showroom'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        if (game.isFeatureNew('/showroom')) ...[
                          const SizedBox(width: 6),
                          _buildNotificationDot(isDark),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      branchName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              if (hasOffers)
                NeoBrutalBadge(
                  text: context.tr('telemetry_offers_count', {'count': '$offersCount'}),
                  backgroundColor: const Color(0xFFEF4444),
                  textColor: Colors.white,
                  fontSize: 9.5,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                )
              else
                Builder(
                  builder: (context) {
                    final totalPassiveDaily = game.sideBusinesses.fold<double>(
                      0.0,
                      (sum, b) => sum + (b.isOwned && !b.isUnderConstruction ? b.effectiveDailyIncome : 0.0),
                    );
                    final displayVal = totalPassiveDaily > 0
                        ? '+${CurrencyFormatter.formatShort(totalPassiveDaily)} / d'
                        : CurrencyFormatter.formatShort(game.balance);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E575).withValues(alpha: isDark ? 0.2 : 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF00E575),
                          width: 1.4,
                        ),
                      ),
                      child: Text(
                        displayVal,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF00E575) : const Color(0xFF047857),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(width: 8),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.black,
                bgColor: const Color(0xFFFFDE59),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Minimalist Capacity Track Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D111A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF263248) : const Color(0xFFCBD5E1),
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_parking_rounded,
                  size: 14,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  context.tr('deck_parking_matrix'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: capacityRatio,
                      minHeight: 7,
                      backgroundColor: isDark ? const Color(0xFF1E2536) : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        capacityRatio >= 1.0
                            ? const Color(0xFFEF4444)
                            : (isDark ? const Color(0xFFFFDE59) : const Color(0xFFF59E0B)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$carsCount / $maxSlots',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                    color: carsCount >= maxSlots
                        ? const Color(0xFFEF4444)
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TYPOLOGY 2: SANAYİ ENDÜSTRİYEL MEGA-HANGARI (Bento 9:16 Vertical Pod Deck)
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

    // Asymmetric Bento Architecture (Reference Image 1 & 2):
    // Left Tall Pod: Oto Yıkama (46%)
    // Right Stacked Column: Tamir & Atölye (Top) + Tuning Stüdyosu (Bottom) (54%)
    if (isWashUnlocked && (isWorkshopUnlocked || isTuningUnlocked)) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Tall Bento Pod: Oto Yıkama (46%)
            Expanded(
              flex: 46,
              child: _buildCarWashTallCard(
                context: context,
                ref: ref,
                game: game,
                isDark: isDark,
                dirtyCars: dirtyCars,
              ),
            ),
            const SizedBox(width: 8),
            // Right Stacked Column: Atölye & Tuning (54%)
            Expanded(
              flex: 54,
              child: Column(
                children: [
                  if (isWorkshopUnlocked)
                    Expanded(
                      child: _buildWorkshopCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        damagedCars: damagedCars,
                      ),
                    ),
                  if (isWorkshopUnlocked && isTuningUnlocked)
                    const SizedBox(height: 8),
                  if (isTuningUnlocked)
                    Expanded(
                      child: _buildTuningCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Fallback: If wash is not unlocked or only wash is unlocked
    final List<Widget> hangarCards = [];
    if (isWorkshopUnlocked || isTuningUnlocked) {
      hangarCards.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isWorkshopUnlocked)
                Expanded(
                  child: _buildWorkshopCard(
                    context: context,
                    ref: ref,
                    game: game,
                    isDark: isDark,
                    damagedCars: damagedCars,
                  ),
                ),
              if (isWorkshopUnlocked && isTuningUnlocked)
                const SizedBox(width: 8),
              if (isTuningUnlocked)
                Expanded(
                  child: _buildTuningCard(
                    context: context,
                    ref: ref,
                    game: game,
                    isDark: isDark,
                  ),
                ),
            ],
          ),
        ),
      );
    }
    if (isWashUnlocked) {
      if (hangarCards.isNotEmpty) hangarCards.add(const SizedBox(height: 8));
      hangarCards.add(
        _buildCarWashStripCard(
          context: context,
          ref: ref,
          game: game,
          isDark: isDark,
          dirtyCars: dirtyCars,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: hangarCards,
    );
  }

  Widget _buildCarWashTallCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required int dirtyCars,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 14,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        bottomLeft: Radius.circular(22),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.dots,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/car-wash');
        context.push('/car-wash');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F0FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.6,
                  ),
                ),
                child: const Icon(
                  Icons.local_car_wash_rounded,
                  size: 19,
                  color: Colors.black,
                ),
              ),
              if (game.isFeatureNew('/car-wash')) ...[
                const SizedBox(width: 5),
                _buildNotificationDot(isDark),
              ],
              const SizedBox(width: 4),
              Flexible(
                child: NeoBrutalBadge(
                  text: dirtyCars > 0
                      ? context.tr('telemetry_dirty_count', {'count': '$dirtyCars'})
                      : context.tr('deck_wash_foam_ready'),
                  backgroundColor: dirtyCars > 0
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF00F0FF),
                  textColor: dirtyCars > 0 ? Colors.white : Colors.black,
                  fontSize: 8.5,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('service_car_wash'),
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                context.tr('service_car_wash_sub'),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0E7490),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E3D56) : const Color(0xFFCBD5E1),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 12,
                        color: Color(0xFF00F0FF),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          context.tr('deck_wash_boost_telemetry'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFF67E8F9) : const Color(0xFF0E7490),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.black,
                bgColor: const Color(0xFF00F0FF),
                size: 24,
                iconSize: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required int damagedCars,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(10),
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(22),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/workshop');
        context.push('/workshop');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.build_circle_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              if (game.isFeatureNew('/workshop')) ...[
                const SizedBox(width: 5),
                _buildNotificationDot(isDark),
              ],
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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('service_workshop'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('deck_workshop_lift_telemetry'),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFDBA74) : const Color(0xFFC2410C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.white,
                bgColor: const Color(0xFFFF7A00),
                size: 22,
                iconSize: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTuningCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(10),
      backgroundColor: isDark ? const Color(0xFF140D24) : const Color(0xFF1E1338),
      borderColor: isDark ? const Color(0xFF432A6D) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(22),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.crtScanlines,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/tuning-studio');
        context.push('/tuning-studio');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.speed_rounded,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              if (game.isFeatureNew('/tuning-studio')) ...[
                const SizedBox(width: 5),
                _buildNotificationDot(isDark),
              ],
              const Spacer(),
              _buildDutchAngleBadge(
                text: context.tr('deck_tuning_stage_active'),
                backgroundColor: const Color(0xFFA855F7),
                textColor: Colors.white,
                angle: -0.06,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('service_tuning'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('deck_tuning_dyno_telemetry'),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD8B4FE),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.white,
                bgColor: const Color(0xFFA855F7),
                size: 22,
                iconSize: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarWashStripCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required int dirtyCars,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.isometricBlueprint,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/car-wash');
        context.push('/car-wash');
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF00F0FF),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: const Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.local_car_wash_rounded,
              size: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Row(
              children: [
                Text(
                  context.tr('service_car_wash'),
                  style: TextStyle(
                    fontSize: 13.5,
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
          ),
          NeoBrutalBadge(
            text: dirtyCars > 0
                ? context.tr('telemetry_dirty_count', {'count': '$dirtyCars'})
                : context.tr('deck_wash_foam_ready'),
            backgroundColor: dirtyCars > 0
                ? const Color(0xFFEF4444)
                : const Color(0xFF00F0FF),
            textColor: dirtyCars > 0 ? Colors.white : Colors.black,
            fontSize: 8.5,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    final safeFreshBadge = context.tr('bento_badge_fresh');

    if (isStandalone) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFF0F172A),
        borderColor: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
        borderWidth: 2.2,
        borderRadius: 14,
        customBorderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
        ),
        showBlueprintGrid: true,
        patternType: BlueprintPatternType.blueprintGrid,
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
                  child: Row(
                    children: [
                      Text(
                        context.tr('service_buy_car'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      if (game.isFeatureNew('/marketplace')) ...[
                        const SizedBox(width: 6),
                        _buildNotificationDot(isDark),
                      ],
                    ],
                  ),
                ),
                _buildDutchAngleBadge(
                  text: safeFreshBadge,
                  backgroundColor: const Color(0xFF38BDF8),
                  textColor: const Color(0xFF0F172A),
                  angle: -0.05,
                ),
              ],
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
      padding: const EdgeInsets.all(11),
      backgroundColor: isDark ? const Color(0xFF0B132B) : const Color(0xFF0F172A),
      borderColor: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/marketplace');
        context.push('/marketplace');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
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
              _buildDutchAngleBadge(
                text: safeFreshBadge,
                backgroundColor: const Color(0xFF38BDF8),
                textColor: const Color(0xFF0F172A),
                angle: -0.05,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('service_buy_car'),
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: const Color(0xFF0F172A),
                bgColor: const Color(0xFF38BDF8),
                size: 22,
                iconSize: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVasitaCard(BuildContext context, WidgetRef ref, DealershipModel game, bool isDark) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(11),
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.bayerDither,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen('/vasita');
        context.push('/vasita');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
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
              if (game.isFeatureNew('/vasita')) ...[
                const SizedBox(width: 5),
                _buildNotificationDot(isDark),
              ],
              const SizedBox(width: 4),
              Flexible(
                child: NeoBrutalBadge(
                  text: context.tr('deck_vasita_luxury_badge'),
                  backgroundColor: const Color(0xFF06B6D4),
                  textColor: Colors.white,
                  fontSize: 8.5,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('service_vasita_market'),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.white,
                bgColor: const Color(0xFF06B6D4),
                size: 22,
                iconSize: 13,
              ),
            ],
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
            backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
            borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
            borderWidth: 2.2,
            borderRadius: 14,
            customBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            showBlueprintGrid: true,
            patternType: BlueprintPatternType.blueprintGrid,
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
                      _buildDutchAngleBadge(
                        text: context.tr('deck_auction_ticker'),
                        backgroundColor: const Color(0xFFEF4444),
                        textColor: Colors.white,
                        angle: -0.03,
                      ),
                    ],
                  ),
                ),
                _buildDirectionalPill(
                  isDark: isDark,
                  arrowColor: Colors.white,
                  bgColor: const Color(0xFFEF4444),
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
                      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
                      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
                      borderWidth: 2.2,
                      borderRadius: 12,
                      customBorderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(20),
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                      showBlueprintGrid: true,
                      patternType: BlueprintPatternType.blueprintGrid,
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
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.tr('service_finance'),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3),
                              _buildDirectionalPill(
                                isDark: isDark,
                                arrowColor: Colors.black,
                                bgColor: const Color(0xFF00E575),
                                size: 20,
                                iconSize: 12,
                              ),
                            ],
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
                    ),
                  ),
                if (isFinanceUnlocked && isStocksUnlocked)
                  const SizedBox(width: 8),

                // Borsa Portföyü Pod (48%) - INVERTED WALL STREET CONTRAST
                if (isStocksUnlocked)
                  Expanded(
                    flex: 48,
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(9),
                      backgroundColor: isDark ? const Color(0xFF061A14) : const Color(0xFF0A2218),
                      borderColor: isDark ? const Color(0xFF1E3D30) : const Color(0xFF0F172A),
                      borderWidth: 2.2,
                      borderRadius: 12,
                      customBorderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(20),
                      ),
                      showBlueprintGrid: true,
                      patternType: BlueprintPatternType.technicalCrosses,
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
                              _buildDutchAngleBadge(
                                text: '${game.ownedStocks.length} Hisse',
                                backgroundColor: const Color(0xFF00E575),
                                textColor: Colors.black,
                                angle: 0.05,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  context.tr('service_stocks'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 3),
                              _buildDirectionalPill(
                                isDark: isDark,
                                arrowColor: Colors.black,
                                bgColor: const Color(0xFF00E575),
                                size: 20,
                                iconSize: 12,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.query_stats_rounded,
                                size: 11,
                                color: Color(0xFF00E575),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  context.tr('deck_stocks_bist_trend'),
                                  style: const TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF86EFAC),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
            backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
            borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
            borderWidth: 2.2,
            borderRadius: 12,
            customBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            showBlueprintGrid: true,
            patternType: BlueprintPatternType.blueprintGrid,
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
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309),
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
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 14,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
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
          _buildDirectionalPill(
            isDark: isDark,
            arrowColor: Colors.white,
            bgColor: const Color(0xFF8B5CF6),
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
      backgroundColor: isDark ? const Color(0xFF220F12) : const Color(0xFF2D1217),
      borderColor: isDark ? const Color(0xFF4A252B) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(20),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(8),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
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
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
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
              _buildDutchAngleBadge(
                text: context.tr('telemetry_real_estate_count',
                    {'count': '${game.ownedRealEstates.length}'}),
                backgroundColor: const Color(0xFFEF4444),
                textColor: Colors.white,
                angle: -0.05,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('service_real_estate'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.white,
                bgColor: const Color(0xFFEF4444),
                size: 20,
                iconSize: 12,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.real_estate_agent_rounded,
                size: 11,
                color: Color(0xFFFCA5A5),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  context.tr('deck_real_estate_income'),
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFCA5A5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
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
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        bottomLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomRight: Radius.circular(20),
      ),
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
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
                text: context.tr('telemetry_staff_count',
                    {'count': '${game.hiredStaff.length}'}),
                backgroundColor: const Color(0xFFEC4899),
                textColor: Colors.white,
                fontSize: 8,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('service_staff'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: Colors.white,
                bgColor: const Color(0xFFEC4899),
                size: 20,
                iconSize: 12,
              ),
            ],
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
          badge: context.tr('telemetry_parts_count',
              {'count': '${game.salvagedParts.length}'}),
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
          badge: context.tr('telemetry_gossips_count',
              {'count': '${game.activeGossips.length}'}),
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
          badge: context.tr('service_reviews_sub',
              {'rep': '${game.reputationScore}'}),
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

    // Dynamic Asymmetrical Bento Grid processes all unlocked nonCasinoServices

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
                  text:
                      '+${CurrencyFormatter.formatShort(totalPassive)} ${context.tr('cashflow_per_day')}',
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

          // Dynamic Asymmetrical Bento Grid with Contrast Illustrations
          ..._buildAsymmetricBentoRows(
            context: context,
            ref: ref,
            game: game,
            isDark: isDark,
            services: nonCasinoServices,
          ),

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

  /// Deterministic Asymmetric Bento Composition with Tetris / Puzzle Interlocking Blocks
  List<Widget> _buildAsymmetricBentoRows({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required List<_ServiceItem> services,
  }) {
    final List<Widget> rows = [];
    if (services.isEmpty) return rows;

    if (services.length == 1) {
      // 1 Item: 100% Full Width Dominant Hero Card
      rows.add(
        _buildHubHeroCard(
          context: context,
          ref: ref,
          game: game,
          isDark: isDark,
          item: services[0],
          isFullWidth: true,
        ),
      );
      return rows;
    }

    // Role-based Card Slot Assignment matching reference visual hierarchy
    _ServiceItem? heroItem;
    _ServiceItem? tallInvertedItem;
    _ServiceItem? panoramicItem;
    final List<_ServiceItem> unassigned = [];

    for (final s in services) {
      if (s.route == '/side-businesses') {
        heroItem = s;
      } else if (s.route == '/rent-a-car') {
        tallInvertedItem = s;
      } else if (s.route == '/night-market') {
        panoramicItem = s;
      } else {
        unassigned.add(s);
      }
    }

    // Fallback assignment if preferred routes aren't present
    if (heroItem == null && unassigned.isNotEmpty) {
      heroItem = unassigned.removeAt(0);
    }
    if (tallInvertedItem == null && unassigned.isNotEmpty) {
      tallInvertedItem = unassigned.removeAt(0);
    }
    if (panoramicItem == null) {
      final dIdx = unassigned.indexWhere((s) => s.route == '/districts');
      if (dIdx != -1) {
        panoramicItem = unassigned.removeAt(dIdx);
      }
    }

    // ROW 1: Dominant Hero (62%) + Inverted Terracotta Card (38%)
    if (heroItem != null && tallInvertedItem != null) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 62,
                child: _buildHubHeroCard(
                  context: context,
                  ref: ref,
                  game: game,
                  isDark: isDark,
                  item: heroItem,
                  isFullWidth: false,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 38,
                child: (tallInvertedItem.route == '/rent-a-car')
                    ? _buildHubInvertedCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: tallInvertedItem,
                      )
                    : _buildHubVerticalPuzzleCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: tallInvertedItem,
                      ),
              ),
            ],
          ),
        ),
      );
    } else if (heroItem != null) {
      rows.add(
        _buildHubHeroCard(
          context: context,
          ref: ref,
          game: game,
          isDark: isDark,
          item: heroItem,
          isFullWidth: true,
        ),
      );
    }

    // TETRIS / PUZZLE BLOCK 1 (Left Puzzle: Left Vertical Card 40% + Right Stacked 2 Cards 60%)
    // Triggered when there are at least 3 unassigned items
    if (unassigned.length >= 3) {
      // Select vertical anchor for Block 1 (prefers /consignment or /scrapyard)
      _ServiceItem b1Tall;
      final cIdx = unassigned.indexWhere((s) => s.route == '/consignment');
      if (cIdx != -1) {
        b1Tall = unassigned.removeAt(cIdx);
      } else {
        b1Tall = unassigned.removeAt(0);
      }

      final b1StackTop = unassigned.removeAt(0);
      final b1StackBottom = unassigned.removeAt(0);

      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Tall Bento Pod (40%) - Soft outer left (22px), flat docking right (8px)
              Expanded(
                flex: 40,
                child: _buildHubVerticalPuzzleCard(
                  context: context,
                  ref: ref,
                  game: game,
                  isDark: isDark,
                  item: b1Tall,
                  customBorderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Right Stacked Column (60%) - Flat docking left (8px), dynamic outer right
              Expanded(
                flex: 60,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildHubCompactHorizontalCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: b1StackTop,
                        customBorderRadius: const BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomRight: Radius.circular(10),
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildHubCompactHorizontalCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: b1StackBottom,
                        customBorderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(18),
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(8),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // INSERT PANORAMIC DARK NOIR BANNER (Gece Sanayisi / Drag & Modifiye)
    if (panoramicItem != null) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        _buildHubPanoramicCard(
          context: context,
          ref: ref,
          game: game,
          isDark: isDark,
          item: panoramicItem,
        ),
      );
      panoramicItem = null;
    }

    // TETRIS / PUZZLE BLOCK 2 (Inverted Right Puzzle: Left Stacked 2 Cards 60% + Right Vertical Card 40%)
    // Triggered when there are at least 3 unassigned items
    if (unassigned.length >= 3) {
      // Select vertical anchor for Block 2 (prefers /districts or /reviews)
      _ServiceItem b2Tall;
      final dIdx = unassigned.indexWhere((s) => s.route == '/districts');
      if (dIdx != -1) {
        b2Tall = unassigned.removeAt(dIdx);
      } else {
        b2Tall = unassigned.removeLast();
      }

      final b2StackTop = unassigned.removeAt(0);
      final b2StackBottom = unassigned.removeAt(0);

      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Stacked Column (60%) - Flat docking right (8px), dynamic outer left
              Expanded(
                flex: 60,
                child: Column(
                  children: [
                    Expanded(
                      child: _buildHubCompactHorizontalCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: b2StackTop,
                        customBorderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          bottomLeft: Radius.circular(10),
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildHubCompactHorizontalCard(
                        context: context,
                        ref: ref,
                        game: game,
                        isDark: isDark,
                        item: b2StackBottom,
                        customBorderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(18),
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Right Tall Bento Pod (40%) - Soft outer right (22px), flat docking left (8px)
              Expanded(
                flex: 40,
                child: _buildHubVerticalPuzzleCard(
                  context: context,
                  ref: ref,
                  game: game,
                  isDark: isDark,
                  item: b2Tall,
                  customBorderRadius: const BorderRadius.only(
                    topRight: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // LEFTOVER ITEMS (Dynamic level progression fallback)
    if (unassigned.length >= 2) {
      final uA = unassigned.removeAt(0);
      final uB = unassigned.removeAt(0);
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 55,
                child: _buildHubCompactHorizontalCard(
                  context: context,
                  ref: ref,
                  game: game,
                  isDark: isDark,
                  item: uA,
                  customBorderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 45,
                child: _buildHubCompactHorizontalCard(
                  context: context,
                  ref: ref,
                  game: game,
                  isDark: isDark,
                  item: uB,
                  customBorderRadius: const BorderRadius.only(
                    topRight: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (unassigned.isNotEmpty) {
      final single = unassigned.removeAt(0);
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        _buildHubCleanUtilityTile(
          context: context,
          ref: ref,
          game: game,
          isDark: isDark,
          item: single,
          customBorderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
        ),
      );
    }

    // Fallback if panoramic wasn't placed yet
    if (panoramicItem != null) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: 8));
      rows.add(
        _buildHubPanoramicCard(
          context: context,
          ref: ref,
          game: game,
          isDark: isDark,
          item: panoramicItem,
        ),
      );
    }

    return rows;
  }

  /// Dominant Hero Card (Selective Illustration: Industrial Holding Blueprint)
  Widget _buildHubHeroCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
    bool isFullWidth = false,
  }) {
    final isNew = game.isFeatureNew(item.route);
    final isSideBiz = item.route == '/side-businesses';
    final double passiveIncome = game.sideBusinesses
        .where((b) => b.isOwned)
        .fold(0.0, (sum, b) => sum + b.dailyIncome);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141C2B) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.4,
      borderRadius: 14,
      customBorderRadius: isFullWidth
          ? const BorderRadius.only(
              topLeft: Radius.circular(22),
              bottomRight: Radius.circular(22),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            )
          : const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
              topRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.blueprintGrid,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background High-Contrast Holding/Automotive Illustration
          Positioned(
            right: -8,
            bottom: -6,
            width: isFullWidth ? 160 : 130,
            height: 95,
            child: IgnorePointer(
              child: HubServiceIllustration(
                route: item.route,
                color: item.color,
                opacity: isDark ? 0.38 : 0.22,
                strokeWidth: 1.8,
              ),
            ),
          ),
          // Foreground Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1.6,
                      ),
                    ),
                    child: Icon(item.icon, size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 7),
                  if (isNew) ...[
                    _buildNotificationDot(isDark),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badge != null && item.badge!.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    NeoBrutalBadge(
                      text: item.badge!,
                      backgroundColor: item.color,
                      textColor: Colors.black,
                      fontSize: 8.0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.5),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3D56)
                        : const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.telemetryIcon ?? Icons.bolt_rounded,
                      size: 13,
                      color: item.color,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        (isSideBiz && passiveIncome > 0)
                            ? '+${CurrencyFormatter.formatShort(passiveIncome)} ${context.tr('cashflow_per_day')}'
                            : (item.telemetry ?? item.subtitle),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: item.actionLabel ?? context.tr('deck_action_businesses'),
                fontSize: 10,
                backgroundColor: item.color,
                textColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6.5),
                onPressed: () {
                  ref.read(gameProvider.notifier).markFeatureSeen(item.route);
                  context.push(item.route);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Inverted Contrast Terracotta Card (Matching Reference Kiralama Box)
  Widget _buildHubInvertedCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
  }) {
    final isNew = game.isFeatureNew(item.route);

    // Warm rich terracotta / deep rust red
    final Color bgColor =
        isDark ? const Color(0xFF6C1F0D) : const Color(0xFF9A3412);
    final Color borderColor =
        isDark ? const Color(0xFF991B1B) : const Color(0xFF0F172A);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(10),
      backgroundColor: bgColor,
      borderColor: borderColor,
      borderWidth: 2.3,
      borderRadius: 14,
      customBorderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
        topLeft: Radius.circular(10),
        bottomRight: Radius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: false,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Vector Silhouette in translucent white
          Positioned(
            right: -10,
            bottom: -6,
            width: 100,
            height: 75,
            child: IgnorePointer(
              child: HubServiceIllustration(
                route: item.route,
                color: Colors.white,
                opacity: 0.28,
                strokeWidth: 1.5,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.40),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(item.icon, size: 16, color: Colors.white),
                  ),
                  if (isNew) _buildNotificationDot(isDark),
                  _buildDirectionalPill(
                    isDark: false,
                    arrowColor: Colors.black,
                    bgColor: Colors.white,
                    size: 20,
                    iconSize: 12,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (item.badge != null && item.badge!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.badge!,
                        style: const TextStyle(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.telemetryIcon ?? Icons.bolt_rounded,
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.telemetry ?? item.subtitle,
                        style: const TextStyle(
                          fontSize: 8.0,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
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
        ],
      ),
    );
  }

  /// Panoramic Dark Noir Banner (Matching Reference Roadside / Freight Bar)
  Widget _buildHubPanoramicCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
  }) {
    final isNew = game.isFeatureNew(item.route);

    // Deep Noir / Charcoal with crisp black border
    final Color bgColor =
        isDark ? const Color(0xFF0A0F1D) : const Color(0xFF0F172A);
    final Color borderColor =
        isDark ? const Color(0xFF1E293B) : const Color(0xFF0F172A);

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: bgColor,
      borderColor: borderColor,
      borderWidth: 2.3,
      borderRadius: 14,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        bottomRight: Radius.circular(22),
        topRight: Radius.circular(10),
        bottomLeft: Radius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.technicalCrosses,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Vector Silhouette on the right in bright accent
          Positioned(
            right: -6,
            bottom: -6,
            width: 140,
            height: 75,
            child: IgnorePointer(
              child: HubServiceIllustration(
                route: item.route,
                color: item.color,
                opacity: 0.35,
                strokeWidth: 1.6,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.black,
                    width: 1.5,
                  ),
                ),
                child: Icon(item.icon, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 9),
              if (isNew) ...[
                _buildNotificationDot(isDark),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.badge != null && item.badge!.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          NeoBrutalBadge(
                            text: item.badge!,
                            backgroundColor: item.color,
                            textColor: Colors.black,
                            fontSize: 7.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 9.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.telemetryIcon ?? Icons.bolt_rounded,
                            size: 10,
                            color: item.color,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.telemetry ?? item.subtitle,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              color: item.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildDirectionalPill(
                isDark: false,
                arrowColor: Colors.black,
                bgColor: item.color,
                size: 24,
                iconSize: 14,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Clean, Quiet Utility Tile (NO background illustration - calm breathing surface)
  Widget _buildHubCleanUtilityTile({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
    BorderRadiusGeometry? customBorderRadius,
  }) {
    final isNew = game.isFeatureNew(item.route);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(9),
      backgroundColor: isDark ? const Color(0xFF161E2C) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: customBorderRadius ??
          const BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(10),
          ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: false,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              const SizedBox(width: 4),
              if (isNew) _buildNotificationDot(isDark),
              const Spacer(),
              if (item.badge != null && item.badge!.isNotEmpty)
                NeoBrutalBadge(
                  text: item.badge!,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  textColor:
                      isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 7.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: isDark ? Colors.white : Colors.black,
                bgColor: isDark
                    ? const Color(0xFF2E3D56)
                    : const Color(0xFFE2E8F0),
                size: 18,
                iconSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 3.5),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF2E3D56)
                    : const Color(0xFFCBD5E1),
                width: 1.1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  item.telemetryIcon ?? Icons.bolt_rounded,
                  size: 10,
                  color: item.color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.telemetry ?? item.subtitle,
                    style: TextStyle(
                      fontSize: 8.0,
                      fontWeight: FontWeight.w800,
                      color:
                          isDark ? Colors.white : const Color(0xFF0F172A),
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
    );
  }

  /// Vertical 2-Row Puzzle Card (Tactical Pod for Tetris Blocks)
  Widget _buildHubVerticalPuzzleCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
    BorderRadiusGeometry? customBorderRadius,
  }) {
    final isNew = game.isFeatureNew(item.route);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(10),
      backgroundColor: isDark ? const Color(0xFF141C2B) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 13,
      customBorderRadius: customBorderRadius ??
          const BorderRadius.only(
            topLeft: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            topRight: Radius.circular(8),
            bottomRight: Radius.circular(8),
          ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.technicalCrosses,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Icon & Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: Icon(item.icon, size: 17, color: Colors.black),
              ),
              if (isNew) ...[
                const SizedBox(width: 4),
                _buildNotificationDot(isDark),
              ],
              const Spacer(),
              if (item.badge != null && item.badge!.isNotEmpty)
                NeoBrutalBadge(
                  text: item.badge!,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : item.color.withValues(alpha: 0.18),
                  textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 7.5,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2.5),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Middle Title & Subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Bottom Telemetry & Directional Action
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2E3D56)
                          : const Color(0xFFCBD5E1),
                      width: 1.1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.telemetryIcon ?? Icons.bolt_rounded,
                        size: 10,
                        color: item.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.telemetry ?? item.subtitle,
                          style: TextStyle(
                            fontSize: 8.0,
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
              ),
              const SizedBox(width: 5),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: isDark ? Colors.white : Colors.black,
                bgColor: isDark ? const Color(0xFF2E3D56) : item.color,
                size: 22,
                iconSize: 13,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Compact Horizontal Card for 2-Row Stacked Column in Tetris Blocks
  Widget _buildHubCompactHorizontalCard({
    required BuildContext context,
    required WidgetRef ref,
    required DealershipModel game,
    required bool isDark,
    required _ServiceItem item,
    BorderRadiusGeometry? customBorderRadius,
  }) {
    final isNew = game.isFeatureNew(item.route);

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      backgroundColor: isDark ? const Color(0xFF161E2C) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 12,
      customBorderRadius: customBorderRadius ??
          const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topLeft: Radius.circular(8),
            bottomLeft: Radius.circular(8),
          ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: false,
      onTap: () {
        ref.read(gameProvider.notifier).markFeatureSeen(item.route);
        context.push(item.route);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Icon & Badge Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4.5),
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF0F172A),
                    width: 1.3,
                  ),
                ),
                child: Icon(item.icon, size: 14, color: Colors.black),
              ),
              if (isNew) ...[
                const SizedBox(width: 4),
                _buildNotificationDot(isDark),
              ],
              const Spacer(),
              if (item.badge != null && item.badge!.isNotEmpty)
                NeoBrutalBadge(
                  text: item.badge!,
                  backgroundColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  textColor:
                      isDark ? Colors.white : const Color(0xFF0F172A),
                  fontSize: 7.5,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                ),
            ],
          ),
          const SizedBox(height: 5),
          // Title & Action Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color:
                            isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.telemetry ?? item.subtitle,
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
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
              const SizedBox(width: 4),
              _buildDirectionalPill(
                isDark: isDark,
                arrowColor: isDark ? Colors.white : Colors.black,
                bgColor: isDark
                    ? const Color(0xFF2E3D56)
                    : const Color(0xFFE2E8F0),
                size: 19,
                iconSize: 11,
              ),
            ],
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
      backgroundColor: isDark ? const Color(0xFF182030) : Colors.white,
      borderColor: isDark ? const Color(0xFF2E3D56) : const Color(0xFF0F172A),
      borderWidth: 2.2,
      borderRadius: 13,
      customBorderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      showBlueprintGrid: true,
      patternType: BlueprintPatternType.diagonalHatch,
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
