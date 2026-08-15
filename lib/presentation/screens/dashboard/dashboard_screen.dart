import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/theme_palette_model.dart';
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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
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
                          child: _buildOfficeTab(context, game, p),
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
        const SizedBox(height: 14),

        // 2. Daily Streak Reward Block (if available)
        _buildDailyStreakBanner(context, game, p, isDark),

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

        // 7. Hızlı Finansal Durum Kartı
        _buildQuickFinancialSummary(context, game, p, isDark),
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
                'Toplam Kâr: ₺${CurrencyFormatter.formatShort(totalProfit)}',
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
                  '₺${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!',
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
                            '₺${CurrencyFormatter.formatShort(listing.askingPrice)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                            ),
                          ),
                          Text(
                            'Piyasa: ₺${CurrencyFormatter.formatShort(car.baseMarketValue)}',
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
                            text: '+₺${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} • +${mission.rewardXP}XP',
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
                if (progressRatio >= 1.0) ...[
                  const SizedBox(width: 10),
                  NeoBrutalButton(
                    label: 'AL',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: () {
                      ref.read(gameProvider.notifier).claimMissionReward(mission.id);
                      FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                        mission.rewardMoney.toDouble(),
                        label: 'Görev Tamam!',
                      );
                      NotificationService.showSuccess(
                        context,
                        '${mission.title} Tamamlandı! ₺${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} Kazandın.',
                      );
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

  /// 7. Quick Financial Summary Card
  Widget _buildQuickFinancialSummary(
    BuildContext context,
    DealershipModel game,
    ThemePaletteModel p,
    bool isDark,
  ) {
    final activeLoans = game.activeLoans;
    final totalLoanDebt = activeLoans.fold(0.0, (sum, l) => sum + l.remainingAmount);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeLoans.isNotEmpty ? const Color(0xFFFF7A00) : const Color(0xFF00E575),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Icon(
                  activeLoans.isNotEmpty ? Icons.account_balance_rounded : Icons.savings_rounded,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeLoans.isNotEmpty
                        ? 'Aktif Kredi Borcu (${activeLoans.length})'
                        : 'Banka Kredisi Hazır',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLoans.isNotEmpty
                        ? 'Kalan Borç: ₺${CurrencyFormatter.formatShort(totalLoanDebt)}'
                        : 'İhtiyaç anında ₺500.000 limitli kredi çek',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          NeoBrutalButton(
            label: activeLoans.isNotEmpty ? 'Yönet' : 'Kredi Çek',
            backgroundColor: activeLoans.isNotEmpty ? const Color(0xFFFF7A00) : p.primaryColor,
            textColor: Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: () => context.push('/finance'),
          ),
        ],
      ),
    );
  }

  /// Tab 3: Ofis & İstatistikler Tab
  Widget _buildOfficeTab(BuildContext context, DealershipModel game, ThemePaletteModel p) {
    final isDark = p.isDark;

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Reputation Block
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: const Icon(Icons.star_rounded, color: Colors.black, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bayi İtibarı & Puanı',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Müşteri memnuniyet skoru: %${game.reputationScore}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Financial Summary Card
        _buildQuickFinancialSummary(context, game, p, isDark),
        const SizedBox(height: 12),

        // Staff Management
        _buildOfficeItem(
          icon: Icons.people_alt_rounded,
          color: const Color(0xFFA855F7),
          title: 'Personel Kadrosu',
          subtitle: '${game.hiredStaff.length} Aktif Usta / Danışman',
          actionLabel: 'Yönet',
          onTap: () => context.push('/staff'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Customer Reviews
        _buildOfficeItem(
          icon: Icons.chat_bubble_rounded,
          color: const Color(0xFFFFDE59),
          title: 'Müşteri Yorumları',
          subtitle: '${game.customerReviews.length} Toplam Değerlendirme',
          actionLabel: 'İncele',
          onTap: () => context.push('/reviews'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Sales History
        _buildOfficeItem(
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF3B82F6),
          title: 'Satış & İşlem Geçmişi',
          subtitle: '${game.salesHistory.length} Tamamlanan Satış Defteri',
          actionLabel: 'Görüntüle',
          onTap: () => context.push('/history'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Character Growth
        _buildOfficeItem(
          icon: Icons.bolt_rounded,
          color: const Color(0xFF00E575),
          title: 'Yetenek Ağacı & Başarımlar',
          subtitle: 'Seviye ${game.level} • Yetenek Puanlarını Yönet',
          actionLabel: 'Geliştir',
          onTap: () => context.push('/character-growth'),
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // Theme Store
        _buildOfficeItem(
          icon: Icons.palette_rounded,
          color: const Color(0xFFFF54B0),
          title: 'Tema Mağazası',
          subtitle: 'Görsel paletleri ve stilleri özelleştir',
          actionLabel: 'Mağaza',
          onTap: () => context.push('/theme-store'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildOfficeItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionLabel,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Icon(icon, size: 20, color: Colors.black),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          NeoBrutalButton(
            label: actionLabel,
            backgroundColor: color,
            textColor: Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: onTap,
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
