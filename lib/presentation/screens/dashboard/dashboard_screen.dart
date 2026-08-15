import '../../../data/models/dealership_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/theme_palette_model.dart';
import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/floating_money_overlay.dart';
import '../../widgets/app_floating_dock.dart';
import '../../widgets/app_hero_header.dart';
import '../../widgets/app_tactile_button.dart';
import '../../widgets/threejs_city_view.dart';
import '../../widgets/app_glass_container.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../showroom/showroom_screen.dart';
import '../auction/auction_screen.dart';

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

    return Scaffold(
      backgroundColor: p.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: FloatingMoneyOverlay(
        child: Stack(
          children: [
            // Full-screen tab views
            Positioned.fill(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  // Tab 0: Full-Screen Isometric Tycoon World (Ana Ekran)
                  _buildWorldTab(context, game, p),

                  // Tab 1: Showroom (Galeri)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 54, bottom: 84),
                      child: const ShowroomScreen(),
                    ),
                  ),

                  // Tab 2: İhale (Live Auctions)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 54, bottom: 84),
                      child: const AuctionScreen(),
                    ),
                  ),

                  // Tab 3: Ofis (Unified Operations)
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 54, bottom: 84),
                      child: _buildOfficeTab(context, game, p),
                    ),
                  ),
                ],
              ),
            ),

            // Top Floating Glassmorphic HUD Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppHeroHeader(
                game: game,
                onSettingsTap: () => context.push('/settings'),
                onProfileTap: () => context.push('/character-growth'),
              ),
            ),

            // Bottom Floating Glass Dock Navigation
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
                    FloatingDockItem(icon: Icons.dashboard_rounded, label: 'Ana Ekran'),
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

  /// Full-screen isometric tycoon world with tappable buildings + floating overlays.
  Widget _buildWorldTab(BuildContext context, DealershipModel game, ThemePaletteModel p) {
    final trend = game.marketTrend;
    final completedMissions = game.activeMissions.where((m) => m.isCompleted).length;
    final claimableExists = game.activeMissions.any((m) => m.isCompleted);

    return Stack(
      children: [
        // The pannable / zoomable 3D Infinitown city (True edge-to-edge).
        const Positioned.fill(child: ThreeJsCityView()),

        // Top market-trend ribbon (Floating seamlessly beneath HUD).
        Positioned(
          top: 54,
          left: 12,
          right: 12,
          child: SafeArea(
            bottom: false,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: p.isDark
                      ? const Color(0xCC0F172A)
                      : const Color(0xEEFFFFFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: p.primaryColor.withValues(alpha: p.isDark ? 0.35 : 0.45),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: p.isDark ? 0.35 : 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.trending_up_rounded, color: p.primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        trend.headline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: p.isDark ? Colors.white : const Color(0xFF0F172A),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Floating right-side quick actions (Görevler & Galeri).
        Positioned(
          right: 12,
          bottom: 84,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _WorldActionButton(
                icon: Icons.assignment_turned_in_rounded,
                label: 'Görevler',
                badge: '$completedMissions/${game.activeMissions.length}',
                color: const Color(0xFFA855F7),
                highlight: claimableExists,
                onTap: () => _showTasksSheet(context, game, p),
              ),
              const SizedBox(height: 10),
              _WorldActionButton(
                icon: Icons.storefront_rounded,
                label: 'Galeri',
                color: p.primaryColor,
                onTap: () => context.push('/showroom'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom sheet listing the daily streak bonus + active missions.
  void _showTasksSheet(BuildContext context, DealershipModel game, ThemePaletteModel p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            final liveGame = ref.watch(gameProvider);
            return Container(
              decoration: BoxDecoration(
                color: p.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(color: p.surfaceBorderColor),
              ),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(color: p.surfaceBorderColor, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('GÜNLÜK ÖDÜL', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: AppSpacing.md),
                  _AnimatedDailyBonusCard(
                    game: liveGame,
                    p: p,
                    onClaim: () {
                      final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                      FloatingMoneyOverlay.of(context)?.showMoneyPopUp(reward.toDouble(), label: 'Seri Ödülü!');
                      NotificationService.showSuccess(context, '₺${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!');
                    },
                  ),
                  const SizedBox(height: 8),
                  Text('GÜNÜN GÖREVLERİ', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: AppSpacing.md),
                  ...liveGame.activeMissions.map((mission) {
                    return _AnimatedMissionCard(
                      key: ValueKey(mission.id),
                      mission: mission,
                      p: p,
                      onClaim: () {
                        ref.read(gameProvider.notifier).claimMissionReward(mission.id);
                        FloatingMoneyOverlay.of(context)?.showMoneyPopUp(mission.rewardMoney.toDouble(), label: 'Görev Ödülü!');
                        NotificationService.showSuccess(context, '${mission.title} Tamamlandı! ₺${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} Kazandın.');
                      },
                    );
                  }),
                  if (liveGame.activeMissions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('Şu an aktif görev yok.', style: AppTypography.labelSmall(p.isDark)),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOfficeTab(BuildContext context, DealershipModel game, ThemePaletteModel p) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OFİS VE İSTATİSTİKLER'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reputation Card
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.star_rounded, color: p.primaryColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Bayi İtibarı', style: AppTypography.titleLarge(p.isDark)),
                        const SizedBox(height: 4),
                        Text(
                          'Müşteri memnuniyet skoru: %${game.reputationScore}',
                          style: AppTypography.bodyMedium(p.isDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Financial Summary & Loans Management Card
            _buildFinancialSummaryCard(context, ref, game, p),
            const SizedBox(height: 16),

            // Staff Recruitment Button Card
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.purple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people_alt_rounded, color: Colors.purpleAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personel Kadrosu', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${game.hiredStaff.length} Aktif Usta / Danışman', style: AppTypography.labelSmall(p.isDark)),
                        ],
                      ),
                    ],
                  ),
                  AppTactileButton.primary(
                    label: 'Yönet',
                    color: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    onPressed: () => context.push('/staff'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Reviews Button Card
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chat_bubble_rounded, color: Colors.amber, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Müşteri Yorumları', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${game.customerReviews.length} Toplam Değerlendirme', style: AppTypography.labelSmall(p.isDark)),
                        ],
                      ),
                    ],
                  ),
                  AppTactileButton.primary(
                    label: 'İncele',
                    color: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    onPressed: () => context.push('/reviews'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sales History Button Card
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.blueAccent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Satış & İşlem Geçmişi', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('${game.salesHistory.length} Tamamlanan Satış Defteri', style: AppTypography.labelSmall(p.isDark)),
                        ],
                      ),
                    ],
                  ),
                  AppTactileButton.primary(
                    label: 'Görüntüle',
                    color: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    onPressed: () => context.push('/history'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Character Growth & Skill Tree Card
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: p.primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.bolt_rounded, color: p.primaryColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Yetenek Ağacı & Başarımlar', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text('Seviye ${game.level} • Yetenek Puanlarını Yönet', style: AppTypography.labelSmall(p.isDark)),
                        ],
                      ),
                    ],
                  ),
                  AppTactileButton.primary(
                    label: 'Geliştir',
                    color: p.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    onPressed: () => context.push('/character-growth'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }







  Widget _buildFinancialSummaryCard(BuildContext context, WidgetRef ref, DealershipModel game, ThemePaletteModel p) {
    final activeLoans = game.activeLoans;
    final totalLoanDebt = activeLoans.fold(0.0, (sum, l) => sum + l.remainingAmount);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: activeLoans.isNotEmpty ? p.warningColor : p.surfaceBorderColor, width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                activeLoans.isNotEmpty ? Icons.account_balance_rounded : Icons.savings_rounded,
                color: activeLoans.isNotEmpty ? p.warningColor : p.successColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeLoans.isNotEmpty ? 'Banka Kredileri (${activeLoans.length})' : 'Banka Kredisi Kullan',
                    style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLoans.isNotEmpty
                        ? 'Toplam Kalan Borç: ${CurrencyFormatter.formatShort(totalLoanDebt)}'
                        : 'Kasa yetersiz kaldığında ₺500.000 limitli kredi çek',
                    style: AppTypography.labelSmall(p.isDark),
                  ),
                ],
              ),
            ],
          ),
          AppTactileButton.primary(
            label: activeLoans.isNotEmpty ? 'Yönet' : 'Kredi Çek',
            color: activeLoans.isNotEmpty ? p.warningColor : p.primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            onPressed: () => context.push('/finance'),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMissionCard extends StatefulWidget {
  final MissionModel mission;
  final ThemePaletteModel p;
  final VoidCallback onClaim;

  const _AnimatedMissionCard({
    super.key,
    required this.mission,
    required this.p,
    required this.onClaim,
  });

  @override
  State<_AnimatedMissionCard> createState() => _AnimatedMissionCardState();
}

class _AnimatedMissionCardState extends State<_AnimatedMissionCard> {
  bool _isClaiming = false;

  void _handleClaim() {
    setState(() => _isClaiming = true);
    Future.delayed(const Duration(milliseconds: 350), () {
      widget.onClaim();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mission.isCompleted && !_isClaiming) {
      // Completed missions shrink completely so they don't take screen height
      return const SizedBox.shrink();
    }

    final double progressRatio = (widget.mission.currentProgress / widget.mission.targetGoal).clamp(0.0, 1.0);
    final p = widget.p;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 350),
      opacity: _isClaiming ? 0.0 : 1.0,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 350),
        curve: Curves.fastOutSlowIn,
        child: _isClaiming
            ? const SizedBox(width: double.infinity, height: 0)
            : Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: p.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.primaryColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(widget.mission.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                              const SizedBox(width: 8),
                              Text(
                                '+₺${CurrencyFormatter.formatShort(widget.mission.rewardMoney.toDouble())} / +${widget.mission.rewardXP}XP',
                                style: TextStyle(color: p.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(widget.mission.description, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 6,
                              backgroundColor: p.surfaceBorderColor,
                              valueColor: AlwaysStoppedAnimation<Color>(p.primaryColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onPressed: (progressRatio >= 1.0 && !_isClaiming) ? _handleClaim : null,
                      child: const Text('Topla', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _AnimatedDailyBonusCard extends StatefulWidget {
  final DealershipModel game;
  final ThemePaletteModel p;
  final VoidCallback onClaim;

  const _AnimatedDailyBonusCard({
    required this.game,
    required this.p,
    required this.onClaim,
  });

  @override
  State<_AnimatedDailyBonusCard> createState() => _AnimatedDailyBonusCardState();
}

class _AnimatedDailyBonusCardState extends State<_AnimatedDailyBonusCard> with SingleTickerProviderStateMixin {
  bool _isClaimed = false;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleClaim() {
    _animController.forward().then((_) {
      setState(() => _isClaimed = true);
      widget.onClaim();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isClaimed) return const SizedBox.shrink();

    final game = widget.game;
    final now = DateTime.now();
    if (game.lastRewardClaimDate != null) {
      final lastClaim = game.lastRewardClaimDate!;
      if (lastClaim.year == now.year && lastClaim.month == now.month && lastClaim.day == now.day) {
        return const SizedBox.shrink();
      }
    }
    final p = widget.p;

    return AnimatedSize(
      duration: const Duration(milliseconds: 350),
      curve: Curves.fastOutSlowIn,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.secondaryColor.withValues(alpha: 0.25), p.surfaceColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.secondaryColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: p.secondaryColor.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    VectorIconWidget(type: 'streak', color: p.primaryColor, size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${game.loginStreak} Günlük Seri!', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                        Text('Günlük giriş bonusunu al', style: AppTypography.labelSmall(p.isDark)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.secondaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _handleClaim,
                  child: const Text('Topla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating circular action button used as an overlay on the isometric world map.
class _WorldActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color color;
  final bool highlight;
  final VoidCallback onTap;

  const _WorldActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 62,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: highlight ? 0.9 : 0.5), width: highlight ? 2 : 1.2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: highlight ? 0.4 : 0.18), blurRadius: 12, offset: const Offset(0, 4)),
              const BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: highlight ? const Color(0xFF16A34A) : color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 9.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
