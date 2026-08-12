import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

class CharacterGrowthScreen extends ConsumerWidget {
  const CharacterGrowthScreen({super.key});

  String _getCharacterTitle(int level) {
    if (level < 3) return 'Stajyer Galerici';
    if (level < 6) return 'Çırak Al-Satçı';
    if (level < 10) return 'Usta Galerici';
    if (level < 15) return 'Oto Galeri Patronu';
    return 'Galerici Kralı';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final p = Theme.of(context).extension<AppThemeExtension>()!.palette;
    final skills = game.skills;
    final title = _getCharacterTitle(game.level);

    // XP calculation: 100 XP per level
    final xpInCurrentLevel = skills.xp % 100;
    final xpProgress = xpInCurrentLevel / 100.0;

    return Scaffold(
      backgroundColor: p.backgroundColor,
      appBar: AppBar(
        backgroundColor: p.surfaceColor,
        elevation: 0,
        title: Text('KARAKTER GELİŞİMİ', style: AppTypography.titleLarge(p.isDark)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: p.textPrimaryColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.surfaceBorderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar Icon Circle
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.primaryColor.withValues(alpha: 0.2),
                          border: Border.all(color: p.primaryColor, width: 2),
                        ),
                        child: Center(
                          child: VectorIconWidget(type: 'craftsman', color: p.primaryColor, size: 32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18)),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.secondaryColor,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('Seviye ${game.level}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('Mevcut Bakiye: ₺${CurrencyFormatter.formatShort(game.balance)}', style: AppTypography.labelSmall(p.isDark)),
                            const SizedBox(height: 4),
                            Text('Kullanılabilir SP: ${skills.availableSkillPoints}', style: AppTypography.moneyMedium(p.isDark).copyWith(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // XP Level Progress Indicator
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Seviye İlerlemesi (XP)', style: AppTypography.labelSmall(p.isDark)),
                          Text('$xpInCurrentLevel / 100 XP', style: AppTypography.labelSmall(p.isDark).copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: xpProgress,
                          minHeight: 10,
                          backgroundColor: p.surfaceBorderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(p.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. Skill Tree Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('YETENEK AĞACI & PERKLER', style: AppTypography.labelSmall(p.isDark)),
                Text('SP: ${skills.availableSkillPoints}', style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            _buildSkillCard(
              context,
              ref: ref,
              title: 'Pazarlık Gücü',
              desc: 'Alıcılardan daha yüksek ikna oranıyla teklif almanı sağlar.',
              perk: skills.negotiationLevel >= 5 ? 'İkna Şansı +%25 Artırıldı' : 'Lv 5 Perk: İkna Şansı +%25 Artacak',
              level: skills.negotiationLevel,
              skillKey: 'negotiation',
              p: p,
              hasPoints: skills.availableSkillPoints > 0,
            ),
            _buildSkillCard(
              context,
              ref: ref,
              title: 'Ekspertiz Sezgisi',
              desc: 'Rapor almadan araçlardaki gizli ayıpları sezme yeteneği.',
              perk: skills.eyeForDetail >= 5 ? 'Ekspertizsiz Risk Sezgisi %50' : 'Lv 5 Perk: Gizli Ayıp Sezgisi %50 Açılır',
              level: skills.eyeForDetail,
              skillKey: 'eyeForDetail',
              p: p,
              hasPoints: skills.availableSkillPoints > 0,
            ),
            _buildSkillCard(
              context,
              ref: ref,
              title: 'Piyasa Tahmini',
              desc: 'Aracın gerçek piyasa değerini ve trend kâr çarpanlarını görme.',
              perk: skills.marketSense >= 3 ? 'SUV & Spor Kâr Çarpanları Açık' : 'Lv 3 Perk: Segment Kâr Çarpanları Açılır',
              level: skills.marketSense,
              skillKey: 'marketSense',
              p: p,
              hasPoints: skills.availableSkillPoints > 0,
            ),
            _buildSkillCard(
              context,
              ref: ref,
              title: 'Galerici İtibarı',
              desc: 'Daha prestijli koleksiyonluk araçların ve zengin alıcıların gelmesi.',
              perk: skills.reputation >= 5 ? 'Nadir Araç Düşme Şansı +%15' : 'Lv 5 Perk: Nadir Koleksiyon Düşüşü %15 Artar',
              level: skills.reputation,
              skillKey: 'reputation',
              p: p,
              hasPoints: skills.availableSkillPoints > 0,
            ),

            const SizedBox(height: 24),

            // 3. Achievements Showcase Section
            Text('KAZANILAN BAŞARIMLAR (${game.achievements.where((a) => a.isUnlocked).length}/${game.achievements.length})', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: game.achievements.length,
              itemBuilder: (context, index) {
                final item = game.achievements[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.isUnlocked ? p.primaryColor.withValues(alpha: 0.12) : p.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.isUnlocked ? p.primaryColor : p.surfaceBorderColor,
                      width: item.isUnlocked ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                        color: item.isUnlocked ? p.primaryColor : p.textSecondaryColor,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: TextStyle(
                                color: item.isUnlocked ? p.textPrimaryColor : p.textSecondaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item.description,
                              style: TextStyle(color: p.textSecondaryColor, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillCard(
    BuildContext context, {
    required WidgetRef ref,
    required String title,
    required String desc,
    required String perk,
    required int level,
    required String skillKey,
    required dynamic p,
    required bool hasPoints,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.surfaceBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$title (Lv $level/10)', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (hasPoints && level < 10) ? p.primaryColor : p.surfaceBorderColor,
                  foregroundColor: (hasPoints && level < 10) ? Colors.black : p.textSecondaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: (hasPoints && level < 10)
                    ? () => ref.read(gameProvider.notifier).upgradeSkill(skillKey)
                    : null,
                child: Text(level >= 10 ? 'MAX' : 'Yükselt (1 SP)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: AppTypography.labelSmall(p.isDark)),
          const SizedBox(height: 8),

          // Level Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: level / 10.0,
              minHeight: 6,
              backgroundColor: p.surfaceBorderColor,
              valueColor: AlwaysStoppedAnimation<Color>(p.primaryColor),
            ),
          ),
          const SizedBox(height: 6),

          // Perk Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: p.secondaryColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Perk: $perk',
              style: TextStyle(color: p.secondaryColor, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
