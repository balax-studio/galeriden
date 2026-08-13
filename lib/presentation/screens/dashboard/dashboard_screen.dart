import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/auction_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

import 'widgets/dashboard_game_time_card.dart';
import 'widgets/dashboard_status_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final trend = game.marketTrend;

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // Daily Streak & Reward Card
            // Daily Login Streak Bonus Card with Premium Dismissal Animation
            _AnimatedDailyBonusCard(
              game: game,
              p: p,
              onClaim: () {
                final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('₺${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!')),
                );
              },
            ),

            // Main Dealership Status Card
            DashboardStatusCard(game: game),
            const SizedBox(height: 24),

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${mission.title} Tamamlandı! Ödüller Hesaba Eklendi.')),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Quick Menu Hub Grid
            Text('HIZLI MENÜ', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            // Financial Health & Bank Loans Summary Card
            _buildFinancialSummaryCard(context, ref, game, p),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildActionCard(
                  context,
                  title: 'İkinci El Pazarı',
                  subtitle: 'Araç İlanlarını İncele',
                  vectorType: 'car',
                  color: p.primaryColor,
                  onTap: () => context.push('/marketplace'),
                ),
                _buildActionCard(
                  context,
                  title: 'Showroom / İlanlarım',
                  subtitle: 'Gelen Teklifler (${game.incomingOffers.length})',
                  vectorType: 'negotiation',
                  color: p.secondaryColor,
                  badge: game.incomingOffers.isNotEmpty ? '${game.incomingOffers.length}' : null,
                  onTap: () => context.push('/showroom'),
                ),
                Builder(
                  builder: (context) {
                    final isAuctionLive = AuctionEngine.isAuctionActiveNow();
                    final remainingSec = AuctionEngine.getSecondsUntilNextAuction();
                    final mins = remainingSec ~/ 60;
                    final secs = remainingSec % 60;
                    final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

                    return _buildActionCard(
                      context,
                      title: 'Canlı İhale',
                      subtitle: isAuctionLive ? 'Gümrük İcraları Açık!' : 'Sonraki: $timeStr',
                      vectorType: 'flash',
                      color: isAuctionLive ? p.errorColor : Colors.grey,
                      badge: isAuctionLive ? 'CANLI' : 'KAPALI',
                      onTap: () {
                        if (isAuctionLive) {
                          context.push('/auction');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('İhale şu an kapalı! Sonraki gümrük ihalesi $timeStr dakika sonra açılacak.'),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                _buildActionCard(
                  context,
                  title: 'Şube İmparatorluğu',
                  subtitle: 'Kapasite Genişlet',
                  vectorType: 'rare',
                  color: p.secondaryColor,
                  onTap: () => context.push('/branches'),
                ),
                _buildActionCard(
                  context,
                  title: 'Tamir Atölyesi',
                  subtitle: 'Araç Değerini Artır',
                  vectorType: 'workshop',
                  color: p.primaryColor,
                  onTap: () => context.push('/workshop'),
                ),
                _buildActionCard(
                  context,
                  title: 'Ekspertiz Merkezi',
                  subtitle: 'Kusurları Tespiti Et',
                  vectorType: 'expertise',
                  color: p.warningColor,
                  onTap: () => context.push('/marketplace'),
                ),
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
    );
  }





  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String vectorType,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: VectorIconWidget(type: vectorType, color: color, size: 20),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.errorColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.labelSmall(p.isDark)),
              ],
            ),
          ],
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
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'Taksit başarıyla ödendi!' : 'Bakiye yetersiz!'),
                                      ),
                                    );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? '₺100.000 kredi hesabınıza aktarıldı!' : 'Kredi limiti dolu!'),
                                  ),
                                );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? '₺250.000 kredi hesabınıza aktarıldı!' : 'Kredi limiti dolu!'),
                                  ),
                                );
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? '₺500.000 kredi hesabınıza aktarıldı!' : 'Kredi limiti dolu!'),
                                  ),
                                );
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
