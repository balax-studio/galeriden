import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../domain/usecases/collection_album_engine.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../../domain/usecases/rival_leaderboard_engine.dart';
import '../../../domain/usecases/weekly_event_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_floating_dock.dart';
import '../../widgets/app_hero_header.dart';
import '../../widgets/floating_money_overlay.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../auction/auction_screen.dart';
import '../showroom/showroom_screen.dart';
import 'widgets/dashboard_office_view.dart';
import 'widgets/dashboard_quick_finance_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      final game = ref.read(gameProvider);
      if (!hasSeenOnboarding && !game.tutorialCompleted && mounted) {
        context.go('/onboarding');
        return;
      }

      // Check Offline Progression Recap
      final recap = ref.read(gameProvider.notifier).consumePendingOfflineRecap();
      if (recap != null && mounted) {
        _showOfflineRecapModal(context, recap);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitHookDialog(context, game);
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        body: FloatingMoneyOverlay(
          child: Stack(
            children: [
              // Body Content based on selected tab
              Positioned.fill(
                child: Column(
                  children: [
                    // Top Fixed Neo-Brutal HUD Bar
                    AppHeroHeader(
                      game: game,
                      onSettingsTap: () => context.push('/settings'),
                      onProfileTap: () => context.push('/character-growth'),
                    ),

                    // Main Tab View
                    Expanded(
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: [
                          // Tab 0: Sahibinden Style Neo-Brutal Monolithic Dashboard
                          _buildHomeDashboard(context, game, p),

                          // Tab 1: Showroom (Galerim)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 78),
                            child: ShowroomScreen(),
                          ),

                          // Tab 2: Canlı İhale
                          const Padding(
                            padding: EdgeInsets.only(bottom: 78),
                            child: AuctionScreen(),
                          ),

                          // Tab 3: Ofis & İstatistikler
                          Padding(
                            padding: const EdgeInsets.only(bottom: 78),
                            child: DashboardOfficeView(game: game, palette: p),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Fixed Neo-Brutalist Monolithic Navigation Dock
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  top: false,
                  child: AppFloatingDock(
                    currentIndex: _selectedIndex,
                    onTap: (index) => setState(() => _selectedIndex = index),
                    items: const [
                      FloatingDockItem(icon: Icons.dashboard_rounded, label: 'Ana Sayfa'),
                      FloatingDockItem(icon: Icons.storefront_rounded, label: 'Galeri'),
                      FloatingDockItem(icon: Icons.gavel_rounded, label: 'İhale'),
                      FloatingDockItem(icon: Icons.business_center_rounded, label: 'Ofis'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sahibinden.com Inspired Neo-Brutalist & Monolithic Dashboard
  Widget _buildHomeDashboard(BuildContext context, DealershipModel game, ThemePaletteModel p) {
    final isDark = p.isDark;
    final completedMissions = game.activeMissions.where((m) => m.isCompleted).length;
    final claimableExists = game.activeMissions.any((m) => m.isCompleted);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 90),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. Monolithic Dealership Profile Banner
        _buildProfileBanner(context, game, p, isDark),
        const SizedBox(height: 12),

        // 1.1 Weekly Dynamic Event Bulletin
        _buildWeeklyEventBanner(context, game, p, isDark),
        const SizedBox(height: 12),

        // 1.2 First-Day Quest Guide Banner (if player has not completed their first sale)
        if (game.carsSold == 0) ...[
          _buildFirstDayQuestBanner(context, game, p, isDark),
          const SizedBox(height: 12),
        ] else ...[
          // 1.3 Persistent Next Action / Advisor Advice (if carsSold > 0)
          _buildAdvisorGuidanceBanner(context, game, p, isDark),
          const SizedBox(height: 12),
        ],

        // 1.4 Emergency Bailout / Scrapyard Rescue Banner (if low balance)
        if (game.balance < 20000) ...[
          _buildEmergencyRescueBanner(context, game, p, isDark),
          const SizedBox(height: 12),
        ],

        // 2. Retention Hub: Rivals Leaderboard, Album, Prestige
        _buildRetentionHighlightsRow(context, game, p, isDark),
        const SizedBox(height: 12),

        // 2.1 Daily Streak Reward Block (if available)
        _buildDailyStreakBanner(context, game, p, isDark),

        // 2.2 Estimated Daily Cash Flow Breakdown
        _buildDailyCashFlowCard(context, game, p, isDark),
        const SizedBox(height: 18),

        // 3. Sahibinden-Style "Hızlı Hizmetler & Kategoriler" (Monolithic Block Grid)
        _buildSectionHeader(
          title: 'HIZLI İŞLEMLER & SERVİSLER',
          subtitle: 'Galerini yönet, alım-satım yap ve atölyeni işlet',
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        _buildServicesMonolithicGrid(context, game, p, isDark),
        const SizedBox(height: 18),

        // 4. "Günün Vitrin İlanları" (Sahibinden.com Vitrin Bölümü)
        _buildSectionHeader(
          title: 'GÜNÜN VİTRİN İLANLARI',
          subtitle: 'Pazardaki en kârlı ve kelepir araç fırsatları',
          actionText: 'Tümünü Gör',
          onActionTap: () => context.push('/marketplace'),
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        _buildMarketplaceVitrinList(context, game, p, isDark),
        const SizedBox(height: 18),

        // 5. Piyasa Trendi & Otomotiv Bülteni (Monolithic Market Pulse)
        _buildSectionHeader(
          title: 'PİYASA TRENDİ & OTOMOTİV BÜLTENİ',
          subtitle: 'Fiyat hareketleri ve pazar talep analizi',
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        _buildMarketTrendCard(context, game, p, isDark),
        const SizedBox(height: 18),

        // 6. Günün Görevleri & Hedefler
        _buildSectionHeader(
          title: 'GÜNÜN GÖREVLERİ & HEDEFLER',
          subtitle: '$completedMissions/${game.activeMissions.length} Tamamlandı',
          badgeText: claimableExists ? 'ÖDÜL VAR' : null,
          badgeColor: const Color(0xFF00E575),
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        _buildMissionsList(context, game, p, isDark),
        const SizedBox(height: 18),

        // 7. VIP Aranan Araç Siparişleri (Sözleşmeler)
        _buildWantedContractsSection(context, game, p, isDark),

        // 8. Hızlı Finansal Durum Kartı
        DashboardQuickFinanceCard(game: game, palette: p),
      ],
    );
  }

  /// Section Header with Monolithic Accent
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    String? actionText,
    VoidCallback? onActionTap,
    String? badgeText,
    Color? badgeColor,
    required bool isDark,
    required ThemePaletteModel p,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 14,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(
                      color: p.primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  if (badgeText != null) ...[
                    const SizedBox(width: 8),
                    NeoBrutalBadge(
                      text: badgeText,
                      backgroundColor: badgeColor ?? p.primaryColor,
                      textColor: Colors.black,
                      fontSize: 9.5,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? p.primaryColor : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: isDark ? p.primaryColor : const Color(0xFF0F172A),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 1. Profile & Dealership Banner
  Widget _buildProfileBanner(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final carsSold = game.carsSold;
    final totalProfit = game.totalProfit;
    final xpProgress = ((carsSold % 5) / 5.0).clamp(0.0, 1.0);

    return NeoBrutalCard(
      onTap: () => context.push('/settings'),
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        children: [
          Row(
            children: [
              // Dealership Avatar / Logo Box
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: p.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 26,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title & Level Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.dealershipName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: 'LVL ${game.level}',
                          backgroundColor: const Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${game.playerName} • Toplam Satış: $carsSold Araç',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Settings Icon
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  size: 22,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Level Progress Bar
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 1.4,
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: p.primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Toplam Kâr: ${CurrencyFormatter.formatShort(totalProfit)}',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 1.1 First-Day Quest Guide Banner for New Players
  Widget _buildFirstDayQuestBanner(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    String questTitle;
    String questSubtitle;
    IconData questIcon;
    VoidCallback onQuestTap;

    if (game.ownedCars.isNotEmpty) {
      final hasListedCar = game.ownedCars.any((c) => c.isListed);
      if (!hasListedCar) {
        questTitle = '1. HEDEF: Dede Yadigarı Aracı Vitrine Çıkar!';
        questSubtitle = 'Showroom\'a gir, Murat 124\'e fiyat biç ve ilana koy.';
        questIcon = Icons.storefront_rounded;
        onQuestTap = () => setState(() => _selectedIndex = 1);
      } else {
        questTitle = '2. HEDEF: Gelen Teklifleri İncele & İlk Satışını Yap!';
        questSubtitle = 'Showroom\'da müşterilerle pazarlık yap, kârını cebe koy.';
        questIcon = Icons.handshake_rounded;
        onQuestTap = () => setState(() => _selectedIndex = 1);
      }
    } else {
      questTitle = '1. HEDEF: Pazardan İlk Kelepir Aracını Satın Al!';
      questSubtitle = 'Pazara göz at, ekspertiz raporunu incele ve ilk arabanı al.';
      questIcon = Icons.shopping_cart_rounded;
      onQuestTap = () => context.push('/marketplace');
    }

    return NeoBrutalCard(
      onTap: onQuestTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: const Color(0xFFFEF3C7),
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDE59),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 1.8),
            ),
            child: Icon(questIcon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const NeoBrutalBadge(
                      text: 'BAŞLANGIÇ GÖREVİ',
                      backgroundColor: Colors.black,
                      textColor: Color(0xFFFFDE59),
                      fontSize: 9,
                    ),
                    const Spacer(),
                    const Text(
                      'Hemen Git ➔',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  questTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  questSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. Daily Streak Claim Banner
  Widget _buildDailyStreakBanner(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final now = DateTime.now();
    if (game.lastRewardClaimDate != null) {
      final lastClaim = game.lastRewardClaimDate!;
      if (lastClaim.year == now.year && lastClaim.month == now.month && lastClaim.day == now.day) {
        return const SizedBox.shrink();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: const Color(0xFFFFDE59),
        borderColor: const Color(0xFF0F172A),
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Color(0xFFFF7A00),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${game.loginStreak} Günlük Giriş Serisi!',
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Bugünün bonus ödülünü hemen kasana ekle.',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NeoBrutalButton(
              label: 'TOPLA',
              icon: Icons.attach_money_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              borderColor: const Color(0xFF0F172A),
              fontSize: 11.5,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onPressed: () {
                final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                FloatingMoneyOverlay.of(context)?.showMoneyPopUp(reward.toDouble(), label: 'Seri Ödülü!');
                NotificationService.showSuccess(
                  context,
                  '${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesMonolithicGrid(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final marketListings = ref.watch(marketProvider);
    final pendingOrdersCount = game.pendingOrders.length;

    // Full Service Modules List ordered by progression level
    final allServices = [
      // Level 1: Core Dealership
      _ServiceItem(
        icon: Icons.directions_car_filled_rounded,
        title: 'Araç Satın Al',
        subtitle: 'İkinci El Pazar',
        badge: '${marketListings.length} İlan',
        color: const Color(0xFF3B82F6),
        route: '/marketplace',
      ),
      _ServiceItem(
        icon: Icons.storefront_rounded,
        title: 'Showroom & Galerim',
        subtitle: 'Stoktaki Araçlar',
        badge: '${game.ownedCars.length}/${game.maxGarageSlots} Araç',
        color: const Color(0xFFFFDE59),
        route: '/showroom',
      ),
      _ServiceItem(
        icon: Icons.local_car_wash_rounded,
        title: 'Oto Yıkama',
        subtitle: 'Detailing & Parlatma',
        color: const Color(0xFF00F0FF),
        route: '/car-wash',
      ),

      // Level 2: Workshop & Staff (Oto Galericiler Sitesi Dükkânı)
      _ServiceItem(
        icon: Icons.build_circle_rounded,
        title: 'Tamir & Atölye',
        subtitle: 'Onarım & Servis',
        badge: pendingOrdersCount > 0 ? '$pendingOrdersCount Sipariş' : null,
        color: const Color(0xFFFF7A00),
        route: '/workshop',
      ),
      _ServiceItem(
        icon: Icons.speed_rounded,
        title: 'Tuning Stüdyosu',
        subtitle: 'Performans & Modifiye',
        color: const Color(0xFFA855F7),
        route: '/tuning-studio',
      ),
      _ServiceItem(
        icon: Icons.people_alt_rounded,
        title: 'Personel Kadrosu',
        subtitle: '${game.hiredStaff.length} Personel',
        color: const Color(0xFFEC4899),
        route: '/staff',
      ),
      _ServiceItem(
        icon: Icons.history_edu_rounded,
        title: 'Satış Raporları',
        subtitle: 'İşlem Geçmişi',
        color: const Color(0xFF14B8A6),
        route: '/history',
      ),

      // Level 3: Investment, Auction & Finance (Maslak Otomotiv Plazası)
      _ServiceItem(
        icon: Icons.gavel_rounded,
        title: 'Canlı İhale',
        subtitle: 'Kelepir Teklifler',
        badge: 'CANLI',
        color: const Color(0xFFEF4444),
        route: '/auction',
      ),
      _ServiceItem(
        icon: Icons.account_balance_rounded,
        title: 'Finans & Banka',
        subtitle: 'Krediler & Mevduat',
        color: const Color(0xFF00E575),
        route: '/finance',
      ),
      _ServiceItem(
        icon: Icons.trending_up_rounded,
        title: 'Borsa & Yatırım',
        subtitle: 'Hisseler & Fonlar',
        color: const Color(0xFF6366F1),
        route: '/stock-market',
      ),
      _ServiceItem(
        icon: Icons.reviews_rounded,
        title: 'Müşteri Yorumları',
        subtitle: '⭐ ${game.reputationScore} İtibar',
        color: const Color(0xFFF59E0B),
        route: '/reviews',
      ),
      _ServiceItem(
        icon: Icons.palette_rounded,
        title: 'Showroom Mimari',
        subtitle: 'Lüks Dekorasyon',
        color: const Color(0xFF06B6D4),
        route: '/showroom-decor',
      ),

      // Level 4+: Empire Expansion (Etiler & Bodrum Lüks Motor World)
      _ServiceItem(
        icon: Icons.delete_outline_rounded,
        title: 'Hurdalık & Parça',
        subtitle: 'Çıkma Yedek Parça',
        color: const Color(0xFF64748B),
        route: '/scrapyard',
      ),
      _ServiceItem(
        icon: Icons.car_rental_rounded,
        title: 'Rent-a-Car',
        subtitle: 'Günlük Kiralama',
        color: const Color(0xFF38BDF8),
        route: '/rent-a-car',
      ),
      _ServiceItem(
        icon: Icons.masks_rounded,
        title: 'Karaborsa',
        subtitle: 'Gizli Kelepirler',
        color: const Color(0xFFDC2626),
        route: '/black-market',
      ),
      _ServiceItem(
        icon: Icons.apartment_rounded,
        title: 'Şube Yönetimi',
        subtitle: 'Plaza & Mülkler',
        color: const Color(0xFF8B5CF6),
        route: '/branches',
      ),
      _ServiceItem(
        icon: Icons.business_center_rounded,
        title: 'Yan İşletmeler',
        subtitle: 'Pasif Gelirler',
        color: const Color(0xFF10B981),
        route: '/side-businesses',
      ),
    ];

    // Progressive Disclosure: Unlocked items + NEXT single locked preview item
    final unlockedItems = allServices.where((s) => game.isFeatureUnlocked(s.route)).toList();
    final nextLockedItem = allServices.where((s) => !game.isFeatureUnlocked(s.route)).firstOrNull;

    final displayItems = List<_ServiceItem>.from(unlockedItems);
    if (nextLockedItem != null) {
      displayItems.add(nextLockedItem);
    }

    // Build Dynamic 2-Column Span-2 Rows
    final List<Widget> gridRows = [];
    for (int i = 0; i < displayItems.length; i += 2) {
      if (i + 1 < displayItems.length) {
        // Symmetric Pair Row (1fr - 1fr)
        gridRows.add(
          Row(
            children: [
              Expanded(child: _buildServiceCard(context, game, p, isDark, displayItems[i])),
              const SizedBox(width: 10),
              Expanded(child: _buildServiceCard(context, game, p, isDark, displayItems[i + 1])),
            ],
          ),
        );
      } else {
        // Odd trailing item -> Dynamic Span-2 Full-Width Banner
        gridRows.add(
          _buildSpan2ServiceCard(context, game, p, isDark, displayItems[i]),
        );
      }
      if (i + 2 < displayItems.length) {
        gridRows.add(const SizedBox(height: 10));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: gridRows,
    );
  }

  /// Standard 1-Slot Service Card
  Widget _buildServiceCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
    _ServiceItem item,
  ) {
    final isUnlocked = game.isFeatureUnlocked(item.route);
    final reqLevel = DealershipModel.getRequiredLevel(item.route);

    return SizedBox(
      height: 96,
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        backgroundColor: isUnlocked
            ? (isDark ? const Color(0xFF141721) : Colors.white)
            : (isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0)),
        borderColor: isUnlocked
            ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
            : (isDark ? const Color(0xFF202636) : const Color(0xFF94A3B8)),
        borderRadius: 12,
        onTap: () {
          if (isUnlocked) {
            context.push(item.route);
          } else {
            NotificationService.showWarning(
              context,
              '🔒 Kilitli Alan! Bu özellik Seviye $reqLevel mülküne geçince açılır. (Mevcut: Seviye ${game.level})',
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isUnlocked ? item.color : const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                      width: 1.4,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? item.icon : Icons.lock_outline_rounded,
                    size: 18,
                    color: Colors.black,
                  ),
                ),
                if (!isUnlocked)
                  NeoBrutalBadge(
                    text: '🔒 Sev. $reqLevel',
                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    textColor: isDark ? Colors.white70 : const Color(0xFF334155),
                    borderColor: isDark ? const Color(0xFF475569) : const Color(0xFF64748B),
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  )
                else if (item.badge != null)
                  NeoBrutalBadge(
                    text: item.badge!,
                    backgroundColor: item.color.withValues(alpha: isDark ? 0.3 : 0.2),
                    textColor: isDark ? item.color : const Color(0xFF0F172A),
                    borderColor: item.color,
                    fontSize: 9,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isUnlocked
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  isUnlocked ? item.subtitle : 'Seviye $reqLevel Mülkü Gerekli',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Dynamic Span-2 Full-Width Service Card (Eliminates Asymmetric Gaps)
  Widget _buildSpan2ServiceCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
    _ServiceItem item,
  ) {
    final isUnlocked = game.isFeatureUnlocked(item.route);
    final reqLevel = DealershipModel.getRequiredLevel(item.route);

    return SizedBox(
      height: 72,
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: isUnlocked
            ? (isDark ? const Color(0xFF141721) : Colors.white)
            : (isDark ? const Color(0xFF121526) : const Color(0xFFEEF2F6)),
        borderColor: isUnlocked
            ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
            : (isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5)),
        borderWidth: isUnlocked ? 2.0 : 2.2,
        borderRadius: 12,
        onTap: () {
          if (isUnlocked) {
            context.push(item.route);
          } else {
            NotificationService.showInfo(
              context,
              '🔒 Kilitli Önizleme: Bu özellik Seviye $reqLevel mülkünü (Şube) açtığınızda kullanıma sunulacaktır.',
            );
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isUnlocked ? item.color : const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                  width: 1.4,
                ),
              ),
              child: Icon(
                isUnlocked ? item.icon : Icons.lock_outline_rounded,
                size: 20,
                color: isUnlocked ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: isUnlocked
                                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                : (isDark ? Colors.white70 : const Color(0xFF1E293B)),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isUnlocked) ...[
                        const SizedBox(width: 8),
                        const NeoBrutalBadge(
                          text: 'SIRADAKİ HEDEF',
                          backgroundColor: Color(0xFF6366F1),
                          textColor: Colors.white,
                          fontSize: 9,
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnlocked
                        ? item.subtitle
                        : '🔒 Seviye $reqLevel Şubesi (Ofis/Mülk) ile Otomatik Açılır',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                          : (isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (isUnlocked && item.badge != null)
              NeoBrutalBadge(
                text: item.badge!,
                backgroundColor: item.color.withValues(alpha: isDark ? 0.3 : 0.2),
                textColor: isDark ? item.color : const Color(0xFF0F172A),
                borderColor: item.color,
                fontSize: 10,
              )
            else if (!isUnlocked)
              NeoBrutalButton(
                label: 'ŞUBELER',
                fontSize: 10.5,
                backgroundColor: const Color(0xFF6366F1),
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                onPressed: () => context.push('/branches'),
              )
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
          ],
        ),
      ),
    );
  }

  /// 4. Sahibinden Style "Vitrin İlanları" Section
  Widget _buildMarketplaceVitrinList(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final allListings = ref.watch(marketProvider);
    final listings = allListings.take(4).toList();

    if (listings.isEmpty) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        child: const Center(
          child: Text(
            'Şu an pazarda aktif ilan bulunmuyor.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
                        color: isDark ? p.primaryColor : const Color(0xFF0F172A),
                      ),
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE59),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black, width: 1),
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
                            text: exp.engineCondition >= 80
                                ? 'Motor: %${exp.engineCondition.round()}'
                                : (exp.engineCondition >= 50
                                    ? 'Motor: %${exp.engineCondition.round()}'
                                    : 'Hasarlı'),
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
                            const NeoBrutalBadge(
                              text: 'Kelepir',
                              backgroundColor: Color(0xFF3B82F6),
                              textColor: Colors.white,
                              fontSize: 9.5,
                              padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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
                            'Piyasa: ${CurrencyFormatter.formatShort(car.baseMarketValue)}',
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

  /// 5. Market Trend Card (Monolithic Market Pulse)
  Widget _buildMarketTrendCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
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
                  border: Border.all(color: Colors.black, width: 1.2),
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

  /// 6. Missions & Tasks List
  Widget _buildMissionsList(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    if (game.activeMissions.isEmpty) {
      return NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        child: const Center(
          child: Text(
            'Tüm görevler tamamlandı! Yeni görevler yarın gelecek.',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Column(
      children: game.activeMissions.map((mission) {
        final progressRatio = (mission.currentProgress / mission.targetGoal).clamp(0.0, 1.0);
        final isCompleted = mission.isCompleted;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mission.title,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          NeoBrutalBadge(
                            text: '+${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} • +${mission.rewardXP}XP',
                            backgroundColor: const Color(0xFFFFDE59),
                            textColor: Colors.black,
                            fontSize: 9.5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.description,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressRatio,
                          minHeight: 6,
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isCompleted ? const Color(0xFF00E575) : p.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (mission.isClaimed) ...[
                  const SizedBox(width: 10),
                  const NeoBrutalBadge(
                    text: 'ALINDI',
                    backgroundColor: Color(0xFF10B981),
                    textColor: Colors.white,
                    fontSize: 10,
                  ),
                ] else if (progressRatio >= 1.0) ...[
                  const SizedBox(width: 10),
                  NeoBrutalButton(
                    label: 'AL',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: () {
                      final success = ref.read(gameProvider.notifier).claimMissionReward(mission.id);
                      if (success) {
                        FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                          mission.rewardMoney.toDouble(),
                          label: 'Görev Tamam!',
                        );
                        NotificationService.showSuccess(
                          context,
                          '${mission.title} Tamamlandı! ${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} Kazandın.',
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 7. VIP Wanted Car Orders (Sözleşmeler)
  Widget _buildWantedContractsSection(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    if (game.activeContracts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'VIP ARANAN ARAÇ SİPARİŞLERİ',
          subtitle: 'Müşteriler için özel araç temin et, prim kazan',
          badgeText: '${game.activeContracts.length} SİPARİŞ',
          badgeColor: const Color(0xFFFF7A00),
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        ...game.activeContracts.map((contract) {
          final matchingCars = game.ownedCars.where((car) {
            if (car.brand.toLowerCase() != contract.targetBrand.toLowerCase()) return false;
            if (contract.targetBodyType != null && car.bodyType != contract.targetBodyType) return false;
            if (car.modelYear < contract.minYear) return false;
            if (car.expertise.mileage > contract.maxMileage) return false;
            if (car.isLockedInShowcase) return false;
            return true;
          }).toList();

          final totalPayout = contract.budget + contract.rewardBonus;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: const Color(0xFFFF7A00),
                        child: Text(
                          contract.clientName.isNotEmpty ? contract.clientName[0] : 'V',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              contract.clientName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Aranan: ${contract.targetBrand} • Min. ${contract.minYear} • Max. ${contract.maxMileage ~/ 1000}k km',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      NeoBrutalBadge(
                        text: '${contract.deadlineDays} GÜN',
                        backgroundColor: contract.deadlineDays <= 2 ? const Color(0xFFEF4444) : const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fontSize: 9.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Toplam Ödeme',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            '${CurrencyFormatter.formatShort(totalPayout)} (+${CurrencyFormatter.formatShort(contract.rewardBonus)} Prim)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF00E575)),
                          ),
                        ],
                      ),
                      if (matchingCars.isNotEmpty)
                        NeoBrutalButton(
                          label: 'TESLİM ET (${matchingCars.length})',
                          icon: Icons.local_shipping_rounded,
                          backgroundColor: const Color(0xFF00E575),
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          onPressed: () => _showFulfillContractDialog(context, contract, matchingCars),
                        )
                      else
                        NeoBrutalButton(
                          label: 'PAZARDA BUL',
                          icon: Icons.search_rounded,
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                          textColor: isDark ? Colors.white : Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          onPressed: () => context.push('/marketplace'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
      ],
    );
  }

  void _showFulfillContractDialog(
    BuildContext context,
    WantedCarContract contract,
    List<CarModel> matchingCars,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${contract.clientName} İçin Teslim Edilecek Aracı Seç',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 12),
              ...matchingCars.map((car) {
                final profit = (contract.budget + contract.rewardBonus) - car.currentPurchasePrice;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    tileColor: const Color(0xFF1E2330),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: Text('${car.brand} ${car.modelName} (${car.modelYear})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text('Alış: ${CurrencyFormatter.formatShort(car.currentPurchasePrice)} • Tahmini Kâr: +${CurrencyFormatter.formatShort(profit)}', style: const TextStyle(color: Color(0xFF00E575), fontSize: 11)),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00E575)),
                      child: const Text('TESLİM ET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        final success = ref.read(gameProvider.notifier).fulfillWantedCarContract(contract.id, car.id);
                        if (success) {
                          FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                            contract.budget + contract.rewardBonus,
                            label: 'Sözleşme Tamamlandı!',
                          );
                          NotificationService.showSuccess(
                            context,
                            '${contract.clientName} aracını teslim aldı! ${CurrencyFormatter.formatShort(contract.budget + contract.rewardBonus)} kazandın.',
                          );
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// 1.1 Weekly Dynamic Event Bulletin
  Widget _buildWeeklyEventBanner(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final event = WeeklyEventEngine.getEventForDay(game.currentDay);
    final dayNames = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final dayName = dayNames[(event.dayOfWeek - 1).clamp(0, 6)];
    final icon = event.dayOfWeek == 1
        ? '💳'
        : (event.dayOfWeek == 2
            ? '🔍'
            : (event.dayOfWeek == 3
                ? '⚙️'
                : (event.dayOfWeek == 4
                    ? '🏢'
                    : (event.dayOfWeek == 5
                        ? '🔥'
                        : (event.dayOfWeek == 6
                            ? '🏆'
                            : '✨')))));

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF191D2B) : const Color(0xFFEFF6FF),
      borderColor: const Color(0xFF3B82F6),
      borderRadius: 12,
      borderWidth: 2.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NeoBrutalBadge(
                      text: '${dayName.toUpperCase()} ETKİNLİĞİ',
                      backgroundColor: const Color(0xFF3B82F6),
                      textColor: Colors.white,
                      fontSize: 9,
                    ),
                    const Spacer(),
                    Text(
                      '${game.currentDay}. Gün',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1.3 Persistent Next Action / Advisor Advice Banner (when carsSold > 0)
  Widget _buildAdvisorGuidanceBanner(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    String adviceTitle;
    String adviceSubtitle;
    IconData adviceIcon;
    VoidCallback onAdviceTap;

    final dirtyCars = game.ownedCars.where((c) => !c.isWashed || !c.isPolished).toList();
    final damagedCars = game.ownedCars.where((c) => c.expertise.engineCondition < 80 || c.expertise.transmissionCondition < 80 || c.expertise.bodyParts.values.any((s) => s == PartStatus.damaged)).toList();
    final unlistedCars = game.ownedCars.where((c) => !c.isListed).toList();
    final carsWithOffers = game.ownedCars.where((c) => game.incomingOffers.any((o) => o.carId == c.id && !o.isExpired)).toList();

    if (carsWithOffers.isNotEmpty) {
      adviceTitle = 'Müşteri Teklifleri Masada Bekliyor!';
      adviceSubtitle = '${carsWithOffers.length} araç için yeni alıcı teklifleri var. Showroom\'da pazarlığa otur.';
      adviceIcon = Icons.handshake_rounded;
      onAdviceTap = () => setState(() => _selectedIndex = 1);
    } else if (game.ownedCars.isEmpty) {
      adviceTitle = 'Galerin Boş Kaldı!';
      adviceSubtitle = 'İkinci El Pazarından kelepir araç bak, stoğunu güçlendir.';
      adviceIcon = Icons.shopping_cart_rounded;
      onAdviceTap = () => context.push('/marketplace');
    } else if (dirtyCars.isNotEmpty) {
      adviceTitle = '${dirtyCars.length} Araç Yıkama Bekliyor!';
      adviceSubtitle = 'Kirli araçlar satış hızını düşürür. Oto Yıkama\'da parlat ve vitrine koy.';
      adviceIcon = Icons.local_car_wash_rounded;
      onAdviceTap = () => context.push('/car-wash');
    } else if (damagedCars.isNotEmpty) {
      adviceTitle = 'Atölyede Onarım Fırsatı!';
      adviceSubtitle = '${damagedCars.length} aracın motor/kaporta masrafı var. Sanayide toparlayıp kâr marjını katla.';
      adviceIcon = Icons.build_circle_rounded;
      onAdviceTap = () => context.push('/workshop');
    } else if (unlistedCars.isNotEmpty) {
      adviceTitle = '${unlistedCars.length} Araç İlanda Değil!';
      adviceSubtitle = 'Showroom\'a gir, araçlarına fiyat biç ve ilana aç.';
      adviceIcon = Icons.storefront_rounded;
      onAdviceTap = () => setState(() => _selectedIndex = 1);
    } else {
      adviceTitle = 'Pazar Hareketli, İşler Yolunda!';
      adviceSubtitle = 'Piyasa trendlerini takip et, VIP siparişleri tamamla veya personele yatırım yap.';
      adviceIcon = Icons.trending_up_rounded;
      onAdviceTap = () => context.push('/marketplace');
    }

    return NeoBrutalCard(
      onTap: onAdviceTap,
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF19231D) : const Color(0xFFECFDF5),
      borderColor: const Color(0xFF10B981),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(adviceIcon, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const NeoBrutalBadge(
                      text: 'DANIŞMAN TAVSİYESİ',
                      backgroundColor: Color(0xFF10B981),
                      textColor: Colors.black,
                      fontSize: 8.5,
                    ),
                    const Spacer(),
                    const Text(
                      'İncele ➔',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  adviceTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  adviceSubtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1.4 Emergency Bailout / Scrapyard Rescue Banner (if low balance)
  Widget _buildEmergencyRescueBanner(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final totalOwnedValue = game.ownedCars.fold<double>(
      0.0,
      (sum, c) => sum + c.estimatedRealValue,
    );
    final totalAssets = game.balance + game.bankDepositBalance + totalOwnedValue;
    final canClaimBailout = totalAssets <= 15000;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF261818) : const Color(0xFFFEF2F2),
      borderColor: const Color(0xFFEF4444),
      borderRadius: 12,
      borderWidth: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
              const SizedBox(width: 8),
              Text(
                'ACİL DURUM & NAKİT DESTEĞİ',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Kasadaki nakit kritik seviyeye düştü (₺${CurrencyFormatter.formatShort(game.balance)}). Gelir yaratmak için aşağıdaki acil durum eylemlerini kullanabilirsin.',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 1. Scrapyard Gig
              Builder(
                builder: (context) {
                  final bool canWorkGig = game.lastScrapyardGigDate == null ||
                      DateTime.now().difference(game.lastScrapyardGigDate!).inHours >= 20;

                  return Expanded(
                    child: NeoBrutalButton(
                      label: canWorkGig ? 'Hurdalık Çıraklığı (+₺5.000)' : 'Çıraklık (Tamamlandı)',
                      icon: canWorkGig ? Icons.handyman_rounded : Icons.check_circle_rounded,
                      backgroundColor: canWorkGig
                          ? const Color(0xFFFFDE59)
                          : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                      textColor: canWorkGig ? Colors.black : (isDark ? Colors.white54 : Colors.black54),
                      fontSize: 10.5,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      onPressed: canWorkGig
                          ? () {
                              final success = ref.read(gameProvider.notifier).workScrapyardSideGig();
                              if (success) {
                                FloatingMoneyOverlay.of(context)?.showMoneyPopUp(5000, label: 'Çıraklık Yevmiyesi!');
                                NotificationService.showSuccess(
                                  context,
                                  'Hurdalıkta akşama kadar çıraklık yaptın. ₺5.000 yevmiye kasana girdi!',
                                );
                              } else {
                                NotificationService.showWarning(context, 'Bugün zaten çıraklık yaptın! Yarın tekrar gel.');
                              }
                            }
                          : null,
                    ),
                  );
                },
              ),
              if (canClaimBailout) ...[
                const SizedBox(width: 8),
                // 2. Emergency Bailout (Dede Mirası)
                Expanded(
                  child: NeoBrutalButton(
                    label: 'Dede Mirası (+₺50.000)',
                    icon: Icons.volunteer_activism_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 10.5,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onPressed: () {
                      final success = ref.read(gameProvider.notifier).claimEmergencyBailout();
                      if (success) {
                        FloatingMoneyOverlay.of(context)?.showMoneyPopUp(50000, label: 'Can Suyu Mirası!');
                        NotificationService.showSuccess(
                          context,
                          'Aile büyüklerinden gelen ₺50.000 can suyu desteği kasana eklendi!',
                        );
                      } else {
                        NotificationService.showWarning(context, 'Mevcut varlıkların ₺15.000 üzerinde olduğu için can suyu onaylanmadı.');
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Retention Hub: Rivals Leaderboard, Album, Prestige
  Widget _buildRetentionHighlightsRow(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final discoveredCount = game.discoveredCarModelIds.length;
    final canPrestige = game.level >= 4 || game.totalProfit >= 3000000;

    return Row(
      children: [
        // 1. Rivals Leaderboard
        Expanded(
          child: NeoBrutalCard(
            onTap: () => _showRivalLeaderboardModal(context, game),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.leaderboard_rounded, color: Colors.black, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ŞEHİR LİGİ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '5 Rakip Galeri',
                        style: TextStyle(
                          fontSize: 10,
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
        const SizedBox(width: 8),

        // 2. Collection Album
        Expanded(
          child: NeoBrutalCard(
            onTap: () => _showCollectionAlbumModal(context, game),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALBÜM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '$discoveredCount/30 Araç',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Prestige (If unlocked)
        if (canPrestige) ...[
          const SizedBox(width: 8),
          Expanded(
            child: NeoBrutalCard(
              onTap: () => _showPrestigeModal(context, game),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              backgroundColor: const Color(0xFFFFDE59),
              borderColor: Colors.black,
              borderRadius: 10,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.stars_rounded, color: Color(0xFFFFDE59), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEVRET',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                        Text(
                          'Yeni Sezon',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 2.2 Estimated Daily Cash Flow Breakdown
  Widget _buildDailyCashFlowCard(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final dailyPassiveIncome = game.sideBusinesses.where((b) => b.isOwned).fold<double>(
      0.0,
      (sum, b) => sum + b.grossDailyIncome,
    );
    final dailySalaries = game.hiredStaff.fold<double>(
      0.0,
      (sum, s) => sum + (s.role.dailySalary),
    );
    final dailyLoanPayment = game.activeLoans.fold<double>(
      0.0,
      (sum, l) => sum + (l.monthlyPayment),
    );
    final netDailyFlow = dailyPassiveIncome - dailySalaries - dailyLoanPayment;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GÜNLÜK NET NAKİT AKIŞI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Text(
                '${netDailyFlow >= 0 ? '+' : ''}${CurrencyFormatter.formatShort(netDailyFlow)}/gün',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: netDailyFlow >= 0 ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yan Gelirler: +${CurrencyFormatter.formatShort(dailyPassiveIncome)}',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00E575)),
              ),
              Text(
                'Maaşlar: -${CurrencyFormatter.formatShort(dailySalaries)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              if (dailyLoanPayment > 0)
                Text(
                  'Krediler: -${CurrencyFormatter.formatShort(dailyLoanPayment)}',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Offline Recap Dialog (T2)
  void _showOfflineRecapModal(BuildContext context, Map<String, dynamic> recap) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;

    final earnedIncome = (recap['earnedIncome'] as num?)?.toDouble() ?? 0.0;
    final bulletPoints = (recap['bulletPoints'] as List<String>?) ?? [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF00E575), width: 2.4),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E575),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wb_sunny_rounded, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                recap['title'] as String? ?? 'YOKLUĞUNDA NELER OLDU?',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (earnedIncome > 0) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00E575), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kazanılan Pasif Gelir:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(
                      '+${CurrencyFormatter.format(earnedIncome)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF00E575)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            ...bulletPoints.map(
              (bp) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  bp,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: 'Ödülleri Topla & Başla',
            icon: Icons.check_circle_rounded,
            backgroundColor: const Color(0xFF00E575),
            textColor: Colors.black,
            fullWidth: true,
            onPressed: () {
              Navigator.pop(ctx);
              if (earnedIncome > 0) {
                FloatingMoneyOverlay.of(context)?.showMoneyPopUp(earnedIncome, label: 'Pasif Gelir!');
              }
            },
          ),
        ],
      ),
    );
  }

  /// Exit Hook Dialog (T1)
  void _showExitHookDialog(BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;

    final openLoops = PsychologyEngine.getOpenLoopsSummary(
      pendingOrdersCount: game.pendingOrders.length,
      showroomListedCarsCount: game.ownedCars.where((c) => c.isListed).length,
      currentStreak: game.loginStreak,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A), width: 2),
        ),
        title: Text(
          openLoops['title'] as String? ?? 'DÖNÜŞÜNÜ BEKLEYENLER',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...((openLoops['items'] as List<String>?) ?? []).map(
              (bp) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  bp,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: 'Oyunda Kal',
            backgroundColor: const Color(0xFFFFDE59),
            textColor: Colors.black,
            onPressed: () => Navigator.pop(ctx),
          ),
          NeoBrutalButton(
            label: 'Çıkış Yap',
            backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
            textColor: isDark ? Colors.white70 : const Color(0xFF64748B),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  /// Rival Leaderboard Modal (R4)
  void _showRivalLeaderboardModal(BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final leaderboard = RivalLeaderboardEngine.getLeaderboard(
      playerDealership: game,
      currentDay: game.currentDay,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFDE59), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'ŞEHİR GALERİCİLERİ SIRALAMASI',
                        style: AppTypography.titleLarge(p.isDark),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Bölgedeki 5 rakip galeriye karşı ciro, itibar ve satış performansın',
                style: AppTypography.labelSmall(p.isDark),
              ),
              const SizedBox(height: 16),
              ...leaderboard.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final item = entry.value;
                final isPlayer = item.isPlayer;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isPlayer
                        ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFFEF3C7))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPlayer
                          ? const Color(0xFFFFDE59)
                          : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                      width: isPlayer ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rank == 1
                              ? const Color(0xFFFFDE59)
                              : (rank == 2 ? const Color(0xFFCBD5E1) : (rank == 3 ? const Color(0xFFF97316) : Colors.transparent)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: rank <= 3 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
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
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: isPlayer
                                        ? (isDark ? const Color(0xFFFFDE59) : const Color(0xFF0F172A))
                                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                ),
                                if (isPlayer) ...[
                                  const SizedBox(width: 6),
                                  const NeoBrutalBadge(
                                    text: 'SEN',
                                    backgroundColor: Color(0xFFFFDE59),
                                    textColor: Colors.black,
                                    fontSize: 8.5,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.carsSold} Araç • İtibar: ${item.reputation}',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatShort(item.turnoverScore),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  /// Collection Album Modal (R5)
  void _showCollectionAlbumModal(BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final progress = CollectionAlbumEngine.calculateAlbumProgress(
      discoveredCarIds: game.discoveredCarModelIds,
      totalCatalogCarsCount: 30,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded, color: Color(0xFFA855F7), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'KOLEKSİYON ALBÜMÜ (30 ARAÇ)',
                        style: AppTypography.titleLarge(p.isDark),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Galerinden geçen her farklı modeli albümüne kaydet ve kilometre taşı ödülleri kazan',
                style: AppTypography.labelSmall(p.isDark),
              ),
              const SizedBox(height: 14),

              // Progress Bar Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA855F7), width: 1.4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Keşif İlerlemesi:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF581C87)),
                        ),
                        Text(
                          '${progress.discoveredCount} / 30 Araç (%${(progress.completionPercentage * 100).toStringAsFixed(1)})',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFFA855F7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.completionPercentage,
                      backgroundColor: isDark ? const Color(0xFF333B4F) : const Color(0xFFE9D5FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA855F7)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'KİLOMETRE TAŞI ÖDÜLLERİ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? const Color(0xFFA855F7) : const Color(0xFF581C87)),
              ),
              const SizedBox(height: 8),
              _buildMilestoneRow(5, 'Çırak Koleksiyoner', '₺25.000 + 1 Yetenek Puanı', progress.discoveredCount >= 5, isDark),
              _buildMilestoneRow(10, 'Usta Koleksiyoner', '₺60.000 + 2 Yetenek Puanı', progress.discoveredCount >= 10, isDark),
              _buildMilestoneRow(20, 'Oto Gurmesi', '₺150.000 + 3 Yetenek Puanı', progress.discoveredCount >= 20, isDark),
              _buildMilestoneRow(30, 'Efsane Küratör', '₺500.000 + 5 Yetenek Puanı', progress.discoveredCount >= 30, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneRow(int targetCount, String title, String reward, bool isUnlocked, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF19231D) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF141721) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked ? const Color(0xFF10B981) : (isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
            color: isUnlocked ? const Color(0xFF10B981) : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$targetCount Araç: $title',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? (isDark ? Colors.white : const Color(0xFF0F172A)) : Colors.grey,
                  ),
                ),
                Text(
                  reward,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnlocked ? const Color(0xFF10B981) : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const NeoBrutalBadge(
              text: 'AÇILDI',
              backgroundColor: Color(0xFF10B981),
              textColor: Colors.white,
              fontSize: 8.5,
            ),
        ],
      ),
    );
  }

  /// Prestige / Galeri Devretme Modal (R6)
  void _showPrestigeModal(BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFFFDE59), width: 2.4),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDE59),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.stars_rounded, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'GALERİYİ DEVRET (YENİ SEZON)',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Galerini yüksek kârla bir holdinge devrederek yeni sezona başlayabilirsin.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFDE59), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🌟 Kalıcı Sezon Kazanımları:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  const SizedBox(height: 4),
                  Text('• +%15 Kalıcı Satış Kâr Çarpanı (Mevcut: Sezon ${game.prestigeLevel})', style: const TextStyle(fontSize: 11)),
                  const Text('• ₺150.000 Başlangıç Can Suyu Kasası', style: TextStyle(fontSize: 11)),
                  const Text('• Tüm Yetenekler & Başarımlar Korunur', style: TextStyle(fontSize: 11)),
                  const Text('• Araç ve bakiye sıfırlanır, yeni efsane başlar', style: TextStyle(fontSize: 11, color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: 'Vazgeç',
            backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
            textColor: isDark ? Colors.white70 : const Color(0xFF64748B),
            onPressed: () => Navigator.pop(ctx),
          ),
          NeoBrutalButton(
            label: 'Galeriyi Devret (Sezon Başlat)',
            icon: Icons.rocket_launch_rounded,
            backgroundColor: const Color(0xFFFFDE59),
            textColor: Colors.black,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(gameProvider.notifier).performPrestige();
              NotificationService.showSuccess(
                context,
                'Yeni sezona başladın! Sezon çarpanın yükseldi ve ₺150.000 eklendi.',
              );
            },
          ),
        ],
      ),
    );
  }

}

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
