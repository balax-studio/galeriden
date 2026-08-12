import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final skills = game.skills;
    final trend = game.marketTrend;

    return Scaffold(
      appBar: AppBar(
        title: Text('GALERİSİNDEN', style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 2)),
        actions: [
          IconButton(
            icon: VectorIconWidget(type: 'streak', color: p.primaryColor, size: 22),
            tooltip: 'Karakter Gelişimi & Yetenekler',
            onPressed: () => _showSkillTreeSheet(context, ref),
          ),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: p.secondaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.secondaryColor.withValues(alpha: 0.4)),
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
                          Text('Günlük giriş bonusunu almak için tıkla', style: AppTypography.labelSmall(p.isDark)),
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
                    onPressed: () {
                      final reward = ref.read(gameProvider.notifier).claimDailyStreak();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('₺${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü ve 50 XP Kazanıldı!')),
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
                    p.primaryColor.withValues(alpha: 0.25),
                    p.surfaceColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.primaryColor.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('MEVCUT SERMAYE', style: AppTypography.labelSmall(p.isDark)),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Seviye ${game.level}',
                              style: AppTypography.labelSmall(false).copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: p.secondaryColor,
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
                    style: AppTypography.moneyLarge(p.isDark).copyWith(fontSize: 32, color: p.textPrimaryColor),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat('Toplam Kâr', CurrencyFormatter.formatShort(game.totalProfit), p.isDark),
                      _buildStat('Satılan Araç', '${game.carsSold} Adet', p.isDark),
                      _buildStat('Galeri Kapasitesi', '${game.ownedCars.length}/${game.maxGarageSlots}', p.isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Missions Section
            Text('GÜNÜN GÖREVLERİ', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),
            Column(
              children: game.activeMissions.map((mission) {
                final double progressRatio = (mission.currentProgress / mission.targetGoal).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surfaceColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: mission.isCompleted ? p.primaryColor : p.surfaceBorderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(mission.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                                const SizedBox(width: 8),
                                Text(
                                  '+₺${CurrencyFormatter.formatShort(mission.rewardMoney.toDouble())} / +${mission.rewardXP}XP',
                                  style: TextStyle(color: p.primaryColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(mission.description, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
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
                          backgroundColor: mission.isCompleted ? Colors.grey : p.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        onPressed: (!mission.isCompleted && progressRatio >= 1.0)
                            ? () {
                                ref.read(gameProvider.notifier).claimMissionReward(mission.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${mission.title} Tamamlandı! Ödüller Hesaba Eklendi.')),
                                );
                              }
                            : null,
                        child: Text(mission.isCompleted ? 'Alındı' : 'Topla', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Quick Menu Hub Grid
            Text('HIZLI MENÜ', style: AppTypography.labelSmall(p.isDark)),
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

  void _showSkillTreeSheet(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    showModalBottomSheet(
      context: context,
      backgroundColor: p.backgroundColor,
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
                      Text('KARAKTER YETENEK AĞACI', style: AppTypography.titleLarge(p.isDark)),
                      IconButton(icon: Icon(Icons.close, color: p.textPrimaryColor), onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                  Text('Kullanılabilir Beceri Puanı: ${skills.availableSkillPoints}', style: AppTypography.moneyMedium(p.isDark).copyWith(fontSize: 15)),
                  const SizedBox(height: 20),

                  _buildSkillRow('Pazarlık Gücü', 'Alıcılardan daha yüksek teklif almanı sağlar.', skills.negotiationLevel, () {
                    ref.read(gameProvider.notifier).upgradeSkill('negotiation');
                  }, p),
                  _buildSkillRow('Ekspertiz Sezgisi', 'Rapor almadan kusurları sezme şansı.', skills.eyeForDetail, () {
                    ref.read(gameProvider.notifier).upgradeSkill('eyeForDetail');
                  }, p),
                  _buildSkillRow('Piyasa Tahmini', 'Aracın gerçek piyasa değer aralığını görme.', skills.marketSense, () {
                    ref.read(gameProvider.notifier).upgradeSkill('marketSense');
                  }, p),
                  _buildSkillRow('Galerici İtibarı', 'Daha zengin ve hızlı alıcıların gelmesi.', skills.reputation, () {
                    ref.read(gameProvider.notifier).upgradeSkill('reputation');
                  }, p),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkillRow(String title, String desc, int level, VoidCallback onUpgrade, ThemePaletteModel p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$title (Seviye $level/10)', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                Text(desc, style: AppTypography.labelSmall(p.isDark)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: p.primaryColor, foregroundColor: Colors.black),
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
}
