import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

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
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final skills = game.skills;
    final currentLvl = skills.currentLevel;
    final title = _getCharacterTitle(currentLvl);

    // Exponential XP calculations
    final xpInCurrentLevel = skills.xpInCurrentLevel;
    final targetXpForLevel = skills.currentLevelTargetXp;
    final xpProgress = (xpInCurrentLevel / targetXpForLevel).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'KARAKTER GELİŞİMİ & PERKLER',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Profile Header Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(Icons.military_tech_rounded, color: Colors.black, size: 32),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 8),
                              NeoBrutalBadge(
                                text: 'SEVİYE $currentLvl',
                                backgroundColor: const Color(0xFFA855F7),
                                textColor: Colors.white,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sermaye: ${CurrencyFormatter.formatShort(game.balance)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                    ),
                    NeoBrutalBadge(
                      text: '${skills.availableSkillPoints} SP',
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 13,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // XP Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SEVİYE İLERLEMESİ',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                    ),
                    Text(
                      '$xpInCurrentLevel / $targetXpForLevel XP',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1.4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: xpProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.brutalYellow,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Skill Tree Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YETENEK AĞACI & PERKLER',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              Text(
                '${skills.availableSkillPoints} SP Mevcut',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Skill Cards
          _buildSkillCard(
            context,
            ref: ref,
            title: 'Pazarlık Gücü',
            desc: 'Alıcılardan daha yüksek teklif almanı & ucuza araç kapatmanı sağlar.',
            perk: 'Alım İndirimi / Kâr Marjı: +%${(skills.negotiationMultiplier * 100).toStringAsFixed(0)}',
            level: skills.negotiationLevel,
            skillKey: 'negotiation',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: 'Ekspertiz Sezgisi',
            desc: 'Rapor almadan araçlardaki gizli ayıpları sezme ve rapor indirimi.',
            perk: 'Ekspertiz Maliyet İndirimi: -%${(skills.expertiseCostDiscount * 100).toStringAsFixed(0)}',
            level: skills.eyeForDetail,
            skillKey: 'eyeForDetail',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: 'Piyasa Tahmini',
            desc: 'İlan teklif sıklığını ve doping etkinliğini artırma.',
            perk: 'Doping & Teklif Bonusu: +%${(skills.marketingDopingBonus * 100).toStringAsFixed(0)}',
            level: skills.marketSense,
            skillKey: 'marketSense',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: 'Galerici İtibarı',
            desc: 'Daha prestijli koleksiyonluk araçların ve zengin alıcıların gelmesi.',
            perk: skills.reputation >= 5 ? 'Nadir Araç Düşme Şansı +%15' : 'Lv 5: Nadir Koleksiyon Düşüşü %15 Artar',
            level: skills.reputation,
            skillKey: 'reputation',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: 'Finansal Zeka',
            desc: 'Banka kredi faizlerini düşürme ve karşılıksız çek riskini azaltma.',
            perk: 'Faiz İndirimi: -%${(skills.financeInterestDiscount * 100).toStringAsFixed(0)} | Çek Riski -%${(skills.chequeRiskReduction * 100).toStringAsFixed(1)}',
            level: skills.financeSense,
            skillKey: 'financeSense',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          const SizedBox(height: 16),

          // 3. Achievements Section
          Text(
            'BAŞARIMLAR (${game.achievements.where((a) => a.isUnlocked).length}/${game.achievements.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          ...game.achievements.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: item.isUnlocked
                    ? (isDark ? const Color(0xFF16241D) : const Color(0xFFF0FDF4))
                    : (isDark ? const Color(0xFF141721) : Colors.white),
                borderColor: item.isUnlocked ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderRadius: 12,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.isUnlocked ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black, width: 1.2),
                      ),
                      child: Icon(
                        item.isUnlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                        color: item.isUnlocked ? Colors.black : const Color(0xFF64748B),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 6),
                              NeoBrutalBadge(
                                text: 'T${item.tier}',
                                backgroundColor: const Color(0xFFA855F7),
                                textColor: Colors.white,
                                fontSize: 9,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ödül: ${CurrencyFormatter.formatShort(item.rewardMoney.toDouble())} + ${item.rewardSkillPoints} SP',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                    ),
                    if (item.isUnlocked && !item.isClaimed)
                      NeoBrutalButton(
                        label: 'AL',
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        onPressed: () => ref.read(gameProvider.notifier).claimAchievementReward(item.id),
                      )
                    else if (item.isClaimed)
                      const NeoBrutalBadge(
                        text: 'ALINDI ✓',
                        backgroundColor: Color(0xFF22C55E),
                        textColor: Colors.white,
                        fontSize: 10,
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
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
    required bool isDark,
    required bool hasPoints,
  }) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title (Lv $level/10)',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                ),
                NeoBrutalButton(
                  label: level >= 10 ? 'MAX' : '+1 SP',
                  backgroundColor: (hasPoints && level < 10) ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                  textColor: (hasPoints && level < 10) ? Colors.black : const Color(0xFF64748B),
                  fontSize: 10.5,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  onPressed: (hasPoints && level < 10)
                      ? () => ref.read(gameProvider.notifier).upgradeSkill(skillKey)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 8),

            // Level Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black, width: 1.2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (level / 10.0).clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),

            NeoBrutalBadge(
              text: perk,
              backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
              textColor: isDark ? Colors.white70 : const Color(0xFF334155),
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }
}
