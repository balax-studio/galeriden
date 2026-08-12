import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skills = game.skills;

    return Scaffold(
      appBar: AppBar(
        title: Text('GALERİSİNDEN', style: AppTypography.titleLarge(isDark).copyWith(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: const Icon(Icons.stars_rounded, color: AppColors.primaryAmber),
            tooltip: 'Karakter Gelişimi & Yetenekler',
            onPressed: () => _showSkillTreeSheet(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Daily Streak & Reward Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.secondarySage.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.secondarySage.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${game.loginStreak} Günlük Seri!', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                          Text('Günlük giriş bonusunu almak için tıkla', style: AppTypography.labelSmall(isDark)),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondarySage,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('🎉 ₺${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü ve 50 XP Kazanıldı!')),
                      );
                    },
                    child: const Text('Topla', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Balance & Level Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAmber.withOpacity(0.25),
                    AppColors.surfaceDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryAmber.withOpacity(0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MEVCUT SERMAYE', style: AppTypography.labelSmall(isDark)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAmber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Seviye ${game.level}',
                              style: AppTypography.labelSmall(false).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.infoBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${skills.xp} XP',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(game.balance),
                    style: AppTypography.moneyLarge(isDark).copyWith(fontSize: 32),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat('Toplam Kâr', CurrencyFormatter.formatShort(game.totalProfit), isDark),
                      _buildStat('Satılan Araç', '${game.carsSold} Adet', isDark),
                      _buildStat('Galeri Kapasitesi', '${game.ownedCars.length}/${game.maxGarageSlots}', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Menu Hub Grid
            Text('HIZLI MENÜ', style: AppTypography.labelSmall(isDark)),
            const SizedBox(height: 12),

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
                  icon: Icons.storefront_rounded,
                  color: AppColors.primaryAmber,
                  onTap: () => context.push('/marketplace'),
                ),
                _buildActionCard(
                  context,
                  title: 'Showroom / İlanlarım',
                  subtitle: 'Gelen Teklifler (${game.incomingOffers.length})',
                  icon: Icons.garage_rounded,
                  color: AppColors.secondarySage,
                  badge: game.incomingOffers.isNotEmpty ? '${game.incomingOffers.length}' : null,
                  onTap: () => context.push('/showroom'),
                ),
                _buildActionCard(
                  context,
                  title: 'Tamir Atölyesi',
                  subtitle: 'Araç Değerini Artır',
                  icon: Icons.build_rounded,
                  color: AppColors.infoBlue,
                  onTap: () => context.push('/workshop'),
                ),
                _buildActionCard(
                  context,
                  title: 'Ekspertiz Merkezi',
                  subtitle: 'Kusurları Tespiti Et',
                  icon: Icons.verified_user_rounded,
                  color: AppColors.warningOrange,
                  onTap: () => context.push('/marketplace'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Achievements & Badges List
            Text('BAŞARIMLAR & ROLLER', style: AppTypography.labelSmall(isDark)),
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
                      color: ach.isUnlocked
                          ? AppColors.primaryAmber.withOpacity(0.15)
                          : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ach.isUnlocked ? AppColors.primaryAmber : (isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight),
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
                              color: ach.isUnlocked ? AppColors.primaryAmber : AppColors.textMutedDark,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                ach.title,
                                style: AppTypography.titleLarge(isDark).copyWith(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(ach.description, style: AppTypography.labelSmall(isDark).copyWith(fontSize: 10), maxLines: 2),
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

  void _showSkillTreeSheet(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final game = ref.watch(gameProvider);
            final skills = game.skills;

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('KARAKTER YETENEK AĞACI', style: AppTypography.titleLarge(isDark)),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  Text('Kullanılabilir Beceri Puanı: ${skills.availableSkillPoints}', style: AppTypography.moneyMedium(isDark).copyWith(fontSize: 15)),
                  const SizedBox(height: 20),

                  _buildSkillRow('Pazarlık Gücü', 'Alıcılardan daha yüksek teklif almanı sağlar.', skills.negotiationLevel, () {
                    ref.read(gameProvider.notifier).upgradeSkill('negotiation');
                  }, isDark),
                  _buildSkillRow('Ekspertiz Sezgisi', 'Rapor almadan kusurları sezme şansı.', skills.eyeForDetail, () {
                    ref.read(gameProvider.notifier).upgradeSkill('eyeForDetail');
                  }, isDark),
                  _buildSkillRow('Piyasa Tahmini', 'Aracın gerçek piyasa değer aralığını görme.', skills.marketSense, () {
                    ref.read(gameProvider.notifier).upgradeSkill('marketSense');
                  }, isDark),
                  _buildSkillRow('Galerici İtibarı', 'Daha zengin ve hızlı alıcıların gelmesi.', skills.reputation, () {
                    ref.read(gameProvider.notifier).upgradeSkill('reputation');
                  }, isDark),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkillRow(String title, String desc, int level, VoidCallback onUpgrade, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title (Seviye $level/10)', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                Text(desc, style: AppTypography.labelSmall(isDark)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAmber, foregroundColor: AppColors.backgroundDark),
            onPressed: level >= 10 ? null : onUpgrade,
            child: const Text('Yükselt'),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall(isDark)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.monoSpec(isDark).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    String? badge,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorRed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.labelSmall(isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
