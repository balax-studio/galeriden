import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_floating_dock.dart';
import '../../widgets/app_hero_header.dart';
import '../../widgets/floating_money_overlay.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_story_ad_dialog.dart';
import '../../widgets/neo_brutal_dramatic_dialog.dart';
import '../../widgets/neo_brutal_random_event_dialog.dart';
import '../auction/auction_screen.dart';
import '../showroom/showroom_screen.dart';
import 'widgets/dashboard_banners.dart';
import 'widgets/dashboard_missions_section.dart';
import 'widgets/dashboard_office_view.dart';
import 'widgets/dashboard_quick_finance_card.dart';
import 'widgets/dashboard_retention_modals.dart';
import 'widgets/dashboard_services_grid.dart';
import 'widgets/dashboard_vitrin_section.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
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

      // Check Reciprocity Starter Gift (§4.3)
      final hasSeenReciprocity = prefs.getBool('has_seen_reciprocity_gift') ?? false;
      if (!hasSeenReciprocity && game.currentDay <= 1) {
        await prefs.setBool('has_seen_reciprocity_gift', true);
        if (mounted) {
          DashboardRetentionModals.showReciprocityStarterGiftModal(context, ref);
        }
      }

      // Check Offline Progression Recap
      final recap = ref.read(gameProvider.notifier).consumePendingOfflineRecap();
      if (recap != null && mounted) {
        DashboardRetentionModals.showOfflineRecapModal(context, recap);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final selectedIndex = ref.watch(dashboardTabProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    // Listen for level-ups, story ad encounters, dramatic decision cards & random events
    ref.listen<DealershipModel>(gameProvider, (previous, next) {
      if (previous != null && next.level > previous.level) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            DashboardRetentionModals.showLevelUpModal(
              context,
              next.level,
              onExplore: () => context.push('/character-growth'),
            );
          }
        });
      }

      if (next.pendingStoryCard != null && (previous?.pendingStoryCard?.id != next.pendingStoryCard?.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NeoBrutalStoryAdDialog.show(context, next.pendingStoryCard!);
          }
        });
      }

      if (next.pendingDramaticCard != null && (previous?.pendingDramaticCard?.id != next.pendingDramaticCard?.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NeoBrutalDramaticDialog.show(context, next.pendingDramaticCard!);
          }
        });
      }

      if (next.pendingRandomEvent != null && (previous?.pendingRandomEvent?.id != next.pendingRandomEvent?.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            NeoBrutalRandomEventDialog.show(context, next.pendingRandomEvent!);
          }
        });
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final currentTab = ref.read(dashboardTabProvider);
        if (currentTab != 0) {
          ref.read(dashboardTabProvider.notifier).state = 0;
          return;
        }
        DashboardRetentionModals.showExitHookDialog(context, game);
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
                        index: selectedIndex,
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
                    currentIndex: selectedIndex,
                    onTap: (index) => ref.read(dashboardTabProvider.notifier).state = index,
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
        DashboardProfileBanner(game: game, palette: p),
        const SizedBox(height: 12),

        // 1.1 Weekly Dynamic Event Bulletin
        DashboardWeeklyEventBanner(game: game, palette: p),
        const SizedBox(height: 12),

        // 1.2 First-Day Quest Guide Banner (if player has not completed their first sale)
        if (game.carsSold == 0) ...[
          DashboardFirstDayQuestBanner(
            game: game,
            onGoToShowroom: () => ref.read(dashboardTabProvider.notifier).state = 1,
          ),
          const SizedBox(height: 12),
        ] else ...[
          // 1.3 Persistent Next Action / Advisor Advice (if carsSold > 0)
          DashboardAdvisorGuidanceBanner(
            game: game,
            palette: p,
            onGoToShowroom: () => ref.read(dashboardTabProvider.notifier).state = 1,
          ),
          const SizedBox(height: 12),
        ],

        // 1.4 Emergency Bailout / Scrapyard Rescue Banner (if low balance)
        if (game.balance < 20000) ...[
          DashboardEmergencyRescueBanner(game: game, palette: p),
          const SizedBox(height: 12),
        ],

        // 2. Retention Hub: Rivals Leaderboard, Album, Prestige
        DashboardRetentionHighlightsRow(game: game, palette: p, ref: ref),
        const SizedBox(height: 12),

        // 2.1 Daily Streak Reward Block (if available)
        DashboardDailyStreakBanner(game: game),

        // 2.2 Estimated Daily Cash Flow Breakdown
        DashboardDailyCashFlowCard(game: game, palette: p),
        const SizedBox(height: 18),

        // 3. Sahibinden-Style "Hızlı Hizmetler & Kategoriler" (Monolithic Block Grid)
        _buildSectionHeader(
          title: 'HIZLI İŞLEMLER & SERVİSLER',
          subtitle: 'Galerini yönet, alım-satım yap ve atölyeni işlet',
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        DashboardServicesGrid(game: game, palette: p),
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
        DashboardMarketplaceVitrinList(game: game, palette: p),
        const SizedBox(height: 18),

        // 5. Piyasa Trendi & Otomotiv Bülteni (Monolithic Market Pulse)
        _buildSectionHeader(
          title: 'PİYASA TRENDİ & OTOMOTİV BÜLTENİ',
          subtitle: 'Fiyat hareketleri ve pazar talep analizi',
          isDark: isDark,
          p: p,
        ),
        const SizedBox(height: 10),
        DashboardMarketTrendCard(game: game, palette: p),
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
        DashboardMissionsList(game: game, palette: p),
        const SizedBox(height: 18),

        // 7. VIP Aranan Araç Siparişleri (Sözleşmeler)
        DashboardWantedContractsSection(game: game, palette: p),

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
}
