import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/floating_money_overlay.dart';

import '../../widgets/isometric_showroom_canvas.dart';
import '../../widgets/app_glass_container.dart';

import 'widgets/dashboard_game_time_card.dart';


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
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final trend = game.marketTrend;

    // Dynamically display title and actions on AppBar based on active tab index
    final PreferredSizeWidget? appBar = _selectedIndex == 0
        ? AppBar(
            title: Row(
              children: [
                VectorIconWidget(
                  type: game.logoEmblemId,
                  color: p.primaryColor,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    game.dealershipName.toUpperCase(),
                    style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.5),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.settings, color: p.textPrimaryColor),
                onPressed: () => context.push('/settings'),
              ),
            ],
          )
        : null; // Let nested screens render their own AppBars to prevent duplication

    return Scaffold(
      appBar: appBar,
      body: FloatingMoneyOverlay(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // Tab 0: Simplified Dashboard (Ana Ekran)
            SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top 3 Important Stats
                  Row(
                    children: [
                      Expanded(child: _buildStatCard(p, 'Bakiye', '₺${CurrencyFormatter.formatShort(game.balance)}', Icons.account_balance_wallet_rounded, p.successColor)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard(p, 'Araçlar', '${game.ownedCars.length}/${game.maxGarageSlots}', Icons.directions_car_rounded, p.primaryColor)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildStatCard(p, 'İtibar', '%${game.reputationScore}', Icons.star_rounded, Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2.5D Interactive Isometric Showroom & Parking Canvas
                  const IsometricShowroomCanvas(),
                  const SizedBox(height: 20),

                  // Game Day & Time Progress Card
                  DashboardGameTimeCard(game: game),

                  // Market Trend Banner
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: p.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.trending_up_rounded, color: p.primaryColor, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GÜNCEL PİYASA TRENDİ', style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(trend.headline, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Daily Login Streak Bonus Card with Premium Dismissal Animation
                  _AnimatedDailyBonusCard(
                    game: game,
                    p: p,
                    onClaim: () {
                      final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                      FloatingMoneyOverlay.of(context)?.showMoneyPopUp(reward.toDouble(), label: 'Seri Ödülü!');
                      NotificationService.showSuccess(context, '₺${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!');
                    },
                  ),

                  // Daily Missions Section
                  Text('GÜNÜN GÖREVLERİ', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 12),
                  Column(
                    children: game.activeMissions.map((mission) {
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
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Minimalist Menu List
                  Text('İŞLEMLER', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 12),

                  Column(
                    children: [
                      _buildSimpleListItem(context, title: 'İkinci El Pazarı', subtitle: 'Araç İlanlarını İncele', icon: Icons.storefront_rounded, color: p.primaryColor, onTap: () => context.push('/marketplace')),
                      _buildSimpleListItem(context, title: 'Tamir Atölyesi', subtitle: 'Araç Değerini Artır', icon: Icons.build_rounded, color: Colors.orangeAccent, onTap: () => context.push('/workshop')),
                      _buildSimpleListItem(context, title: 'Oto Yıkama Stüdyosu', subtitle: 'Köpük & Pasta-Cila', icon: Icons.local_car_wash_rounded, color: Colors.blueAccent, onTap: () => context.push('/car-wash')),
                      _buildSimpleListItem(context, title: 'Şube İmparatorluğu', subtitle: 'Kapasite Genişlet', icon: Icons.domain_rounded, color: p.secondaryColor, onTap: () => context.push('/branches')),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Achievements List
                  Text('BAŞARIMLAR & ROLLER', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 10),

                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: game.achievements.length,
                      itemBuilder: (context, index) {
                        final ach = game.achievements[index];
                        return Container(
                          width: 170,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: ach.isUnlocked ? p.primaryColor.withValues(alpha: 0.15) : p.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: ach.isUnlocked ? p.primaryColor : p.surfaceBorderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    ach.isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                                    color: ach.isUnlocked ? p.primaryColor : p.textSecondaryColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      ach.title,
                                      style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(ach.description, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 10), maxLines: 2),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Tab 1: Showroom (Galeri)
            const ShowroomScreen(),

            // Tab 2: İhale (Live Auctions)
            const AuctionScreen(),

            // Tab 3: Ofis (Unified Operations)
            _buildOfficeTab(context, game, p),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: p.surfaceBorderColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: p.surfaceColor,
          selectedItemColor: p.primaryColor,
          unselectedItemColor: p.textSecondaryColor,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Ana Ekran',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Galeri',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.gavel_rounded),
              label: 'İhale',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_center_rounded),
              label: 'Ofis',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficeTab(BuildContext context, dynamic game, dynamic p) {
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
                  ElevatedButton(
                    onPressed: () => context.push('/staff'),
                    child: const Text('Yönet'),
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
                  ElevatedButton(
                    onPressed: () => context.push('/reviews'),
                    child: const Text('İncele'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }





  Widget _buildStatCard(dynamic p, String title, String value, IconData icon, Color color) {
    return AppGlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildSimpleListItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AppGlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.labelSmall(p.isDark)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: p.textSecondaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryCard(BuildContext context, WidgetRef ref, dynamic game, dynamic p) {
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
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: activeLoans.isNotEmpty ? p.warningColor : p.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(44, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: p.backgroundColor,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_rounded, color: p.primaryColor),
                          const SizedBox(width: 10),
                          Text('BANKA FİNANS SİSTEMİ', style: AppTypography.titleLarge(p.isDark)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Şu an ${activeLoans.length}/3 aktif banka krediniz var.',
                        style: AppTypography.bodyMedium(p.isDark),
                      ),
                      const SizedBox(height: 16),
                      if (activeLoans.isNotEmpty) ...[
                        Text('AKTİF KREDİLERİNİZ', style: AppTypography.labelSmall(p.isDark)),
                        const SizedBox(height: 8),
                        ...activeLoans.map((loan) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(Icons.credit_card_rounded, color: p.warningColor),
                                title: Text('${loan.bankName} - ${CurrencyFormatter.formatShort(loan.monthlyPayment)} / ay'),
                                subtitle: Text('Kalan Taksit: ${loan.remainingInstallments} ay | Kalan: ${CurrencyFormatter.formatShort(loan.remainingAmount)}'),
                                trailing: TextButton(
                                  onPressed: () {
                                    final success = ref.read(gameProvider.notifier).payLoanInstallment(loan.id);
                                    Navigator.pop(ctx);
                                    NotificationService.showError(context, success ? 'Taksit başarıyla ödendi!' : 'Bakiye yetersiz!');
                                  },
                                  child: const Text('Öde'),
                                ),
                              ),
                            )),
                        const SizedBox(height: 12),
                      ],
                      Text('YENİ KREDİ ÇEK', style: AppTypography.labelSmall(p.isDark)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).takeBankLoan(
                                      bankName: 'Ziraat Finans',
                                      amount: 100000.0,
                                      months: 6,
                                    );
                                Navigator.pop(ctx);
                                NotificationService.showSuccess(context, success ? '₺100.000 kredi hesabınıza aktarıldı!' : 'Kredi limiti dolu!');
                              },
                              child: const Text('₺100.000\n(6 Ay)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).takeBankLoan(
                                      bankName: 'Vakıf Finans',
                                      amount: 250000.0,
                                      months: 6,
                                    );
                                Navigator.pop(ctx);
                                NotificationService.showSuccess(context, success ? '₺250.000 kredi hesabınıza aktarıldı!' : 'Kredi limiti dolu!');
                              },
                              child: const Text('₺250.000\n(6 Ay)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).takeBankLoan(
                                      bankName: 'İş Galeri Finans',
                                      amount: 500000.0,
                                      months: 12,
                                    );
                                Navigator.pop(ctx);
                                NotificationService.showSuccess(context, success ? '₺500.000 kredi hesabınıza aktarıldı!' : 'Kredi limiti dolu!');
                              },
                              child: const Text('₺500.000\n(12 Ay)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Text(activeLoans.isNotEmpty ? 'Yönet' : 'Çek', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _AnimatedMissionCard extends StatefulWidget {
  final dynamic mission;
  final dynamic p;
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
  final dynamic game;
  final dynamic p;
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

    final p = widget.p;
    final game = widget.game;

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
