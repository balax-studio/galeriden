import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class CharacterGrowthScreen extends ConsumerWidget {
  const CharacterGrowthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final skills = game.skills;
    final currentLvl = skills.currentLevel;

    // Exponential XP calculations
    final xpInCurrentLevel = skills.xpInCurrentLevel;
    final targetXpForLevel = skills.currentLevelTargetXp;
    final xpProgress = (xpInCurrentLevel / targetXpForLevel).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('growth_screen_title'),
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
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
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
                              Flexible(
                                child: Text(
                                  game.rpgTitle,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              NeoBrutalBadge(
                                text: context.tr('growth_level_badge', {'lvl': '$currentLvl'}),
                                backgroundColor: const Color(0xFFA855F7),
                                textColor: Colors.white,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.tr('growth_origin_label', {'origin': game.originTitle}),
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                context.tr('growth_reputation_label', {'score': '${game.reputationScore}'}),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                context.tr('growth_balance_label', {'balance': CurrencyFormatter.formatShort(game.balance)}),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalBlue),
                              ),
                            ],
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
                    Text(
                      context.tr('growth_xp_progress_title'),
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
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
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
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

          // 2. Specialization Class Selection Section (§2.2)
          _buildSpecializationSection(context, ref, game, isDark),
          const SizedBox(height: 16),

          // 3. Skill Tree Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.tr('growth_skill_tree_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              Text(
                context.tr('growth_sp_available', {'sp': '${skills.availableSkillPoints}'}),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Skill Cards
          _buildSkillCard(
            context,
            ref: ref,
            title: context.tr('skill_negotiation_title'),
            desc: context.tr('skill_negotiation_desc'),
            perk: context.tr('skill_negotiation_perk', {'val': (skills.negotiationMultiplier * 100).toStringAsFixed(0)}),
            level: skills.negotiationLevel,
            skillKey: 'negotiation',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: context.tr('skill_detail_title'),
            desc: context.tr('skill_detail_desc'),
            perk: context.tr('skill_detail_perk', {'val': (skills.expertiseCostDiscount * 100).toStringAsFixed(0)}),
            level: skills.eyeForDetail,
            skillKey: 'eyeForDetail',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: context.tr('skill_market_title'),
            desc: context.tr('skill_market_desc'),
            perk: context.tr('skill_market_perk', {'val': (skills.marketingDopingBonus * 100).toStringAsFixed(0)}),
            level: skills.marketSense,
            skillKey: 'marketSense',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: context.tr('skill_network_title'),
            desc: context.tr('skill_network_desc'),
            perk: skills.reputation >= 5 ? context.tr('skill_network_perk_active') : context.tr('skill_network_perk_locked'),
            level: skills.reputation,
            skillKey: 'reputation',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          _buildSkillCard(
            context,
            ref: ref,
            title: context.tr('skill_finance_title'),
            desc: context.tr('skill_finance_desc'),
            perk: context.tr('skill_finance_perk', {'discount': (skills.financeInterestDiscount * 100).toStringAsFixed(0), 'risk': (skills.chequeRiskReduction * 100).toStringAsFixed(1)}),
            level: skills.financeSense,
            skillKey: 'financeSense',
            isDark: isDark,
            hasPoints: skills.availableSkillPoints > 0,
          ),
          const SizedBox(height: 16),

          // 4. Esnaf Çevresi & NPC İlişkileri (§2.4)
          _buildNpcRelationshipsSection(context, ref, game, isDark),
          const SizedBox(height: 16),

          // 5. Achievements Section
          Text(
            context.tr('growth_achievements_title', {'unlocked': '${game.achievements.where((a) => a.isUnlocked).length}', 'total': '${game.achievements.length}'}),
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
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
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
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    if (item.isUnlocked)
                      NeoBrutalBadge(
                        text: context.tr('growth_badge_unlocked'),
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 9.5,
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

  Widget _buildSpecializationSection(BuildContext context, WidgetRef ref, DealershipModel game, bool isDark) {
    final hasClass = game.specializationPath != SpecializationPath.none;
    final isUnlocked = game.level >= 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('growth_spec_title'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            NeoBrutalBadge(
              text: isUnlocked ? (hasClass ? game.specializationTitle : context.tr('growth_spec_pending')) : context.tr('growth_spec_locked_badge'),
              backgroundColor: hasClass ? AppColors.brutalGreen : (isUnlocked ? AppColors.brutalYellow : const Color(0xFF64748B)),
              textColor: Colors.black,
              fontSize: 10,
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (!isUnlocked)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr('growth_spec_locked_desc'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          )
        else ...[
          _buildSpecializationCard(
            context,
            ref,
            game: game,
            path: SpecializationPath.restorer,
            title: context.tr('spec_restorer_title'),
            icon: Icons.auto_fix_high_rounded,
            color: const Color(0xFFF97316),
            desc: context.tr('spec_restorer_desc'),
            perks: context.tr('spec_restorer_perks'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSpecializationCard(
            context,
            ref,
            game: game,
            path: SpecializationPath.trader,
            title: context.tr('spec_trader_title'),
            icon: Icons.trending_up_rounded,
            color: AppColors.brutalGreen,
            desc: context.tr('spec_trader_desc'),
            perks: context.tr('spec_trader_perks'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSpecializationCard(
            context,
            ref,
            game: game,
            path: SpecializationPath.boss,
            title: context.tr('spec_boss_title'),
            icon: Icons.domain_rounded,
            color: const Color(0xFF3B82F6),
            desc: context.tr('spec_boss_desc'),
            perks: context.tr('spec_boss_perks'),
            isDark: isDark,
          ),
        ],
      ],
    );
  }

  Widget _buildSpecializationCard(
    BuildContext context,
    WidgetRef ref, {
    required DealershipModel game,
    required SpecializationPath path,
    required String title,
    required IconData icon,
    required Color color,
    required String desc,
    required String perks,
    required bool isDark,
  }) {
    final isSelected = game.specializationPath == path;

    return InkWell(
      onTap: () {
        if (!isSelected) {
          ref.read(gameProvider.notifier).chooseSpecialization(path);
          NotificationService.showSuccess(context, '$title • ${context.tr('growth_spec_active_badge')}');
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: isSelected
            ? (isDark ? const Color(0xFF1E2638) : const Color(0xFFFEF9C3))
            : (isDark ? const Color(0xFF141721) : Colors.white),
        borderColor: isSelected ? AppColors.brutalYellow : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
                if (isSelected)
                  NeoBrutalBadge(
                    text: context.tr('growth_spec_active_badge'),
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Text(
                perks,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNpcRelationshipsSection(BuildContext context, WidgetRef ref, DealershipModel game, bool isDark) {
    final npcs = [
      {
        'id': 'haydar_usta',
        'name': 'Haydar Usta • Ekspertiz',
        'role': 'Oto Ekspertiz & Diagnostik',
        'icon': Icons.car_repair_rounded,
        'color': const Color(0xFFF97316),
        'perk': 'Güven >= 70: %50 Ekspertiz İndirimi!',
      },
      {
        'id': 'cikmaci_ibo',
        'name': 'Çıkmacı İbo • Yedek Parça',
        'role': 'Oto Sanayi Çıkma Parçacısı',
        'icon': Icons.settings_input_component_rounded,
        'color': const Color(0xFF8B5CF6),
        'perk': 'Güven >= 70: %25 Çıkma Parça İndirimi!',
      },
      {
        'id': 'golge_ibrahim',
        'name': 'Gölge İbrahim • Karaborsa',
        'role': 'Gizli İhaleler & Acil Nakit',
        'icon': Icons.visibility_off_rounded,
        'color': const Color(0xFFEF4444),
        'perk': 'Güven >= 70: Kaçak ve Özel Sandık Parçaları!',
      },
      {
        'id': 'vlogger_berk',
        'name': 'Vlogger Berk • Oto Medya',
        'role': 'YouTube & Sosyal Medya İncelemesi',
        'icon': Icons.video_camera_front_rounded,
        'color': const Color(0xFF06B6D4),
        'perk': 'Güven >= 70: Galeriye +%25 Ekstra Müşteri Trafiği!',
      },
      {
        'id': 'necati',
        'name': 'Necati Dayı • Kahvehane',
        'role': 'Sanayi & Mahalle İstihbaratı',
        'icon': Icons.coffee_rounded,
        'color': const Color(0xFFEAB308),
        'perk': 'Güven >= 70: Ucuza Düşen Kelepir Araç İhbarları!',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              context.tr('growth_npc_title'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            NeoBrutalBadge(
              text: context.tr('growth_npc_dynamic_badge'),
              backgroundColor: AppColors.brutalCyan,
              textColor: Colors.black,
              fontSize: 9.5,
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...npcs.map((npc) {
          final id = npc['id'] as String;
          final trust = game.getNpcRelation(id);
          final hasHighTrust = game.hasHighNpcTrust(id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              onTap: () => _showNpcInteractionSheet(context, ref, npc, trust, hasHighTrust, isDark),
              borderRadius: BorderRadius.circular(12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: hasHighTrust ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderRadius: 12,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: npc['color'] as Color,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(npc['icon'] as IconData, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                npc['name'] as String,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                npc['role'] as String,
                                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        NeoBrutalBadge(
                          text: '$trust / 100',
                          backgroundColor: hasHighTrust ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                          textColor: hasHighTrust ? Colors.black : (isDark ? Colors.white : Colors.black),
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Trust Progress Bar
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (trust / 100.0).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: hasHighTrust ? AppColors.brutalGreen : (npc['color'] as Color),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          npc['perk'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: hasHighTrust ? AppColors.brutalGreen : const Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          children: [
                            if (hasHighTrust)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Text(
                                  context.tr('active_badge'),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                ),
                              ),
                            Text(
                              context.tr('growth_npc_btn_interact'),
                              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.brutalYellow),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  void _showNpcInteractionSheet(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> npc,
    int currentTrust,
    bool hasHighTrust,
    bool isDark,
  ) {
    final id = npc['id'] as String;
    final name = npc['name'] as String;
    final role = npc['role'] as String;
    final icon = npc['icon'] as IconData;
    final color = npc['color'] as Color;

    String moodDialogue;
    if (id == 'haydar_usta') {
      if (currentTrust < 40) {
        moodDialogue = 'Dükkan yoğun usta, acil bir işin yoksa liftleri meşgul etmeyelim.';
      } else if (currentTrust < 70) {
        moodDialogue = 'Aleykümselam usta, diagnostik cihazını açık tutuyorum. Ekspertizlik araç varsa getir bakarız.';
      } else {
        moodDialogue = 'Eyvallah canım kardeşim! Senin getirdiğin arabanın vidasına kadar kefilim, eksper yarı fiyatına feda olsun!';
      }
    } else if (id == 'cikmaci_ibo') {
      if (currentTrust < 40) {
        moodDialogue = 'Hurdaya bedava bakılmaz usta, parçayı söken parasını sayar.';
      } else if (currentTrust < 70) {
        moodDialogue = 'Hoş geldin, taze pert kasa indirdik. İşine yarar parça olursa kenara ayırırım.';
      } else {
        moodDialogue = 'Sanayinin kralı gelmiş! Çıkma parçada sana liste fiyatı sökmez, %25 dost indirimi helaldir!';
      }
    } else if (id == 'golge_ibrahim') {
      if (currentTrust < 40) {
        moodDialogue = 'Fazla soru sorma, polis devriyesi geziyor. Paran varsa konuşalım.';
      } else if (currentTrust < 70) {
        moodDialogue = 'Gece yarısı limana iki özel makine düşecek. Sessizce payını alırsın.';
      } else {
        moodDialogue = 'Biz artık kader ortağıyız. En temiz change ve gizli ihaleleri önce sana açıyorum, %15 komisyon indirimi sana feda!';
      }
    } else if (id == 'vlogger_berk') {
      if (currentTrust < 40) {
        moodDialogue = 'Kanka kanalda 500 bin abone var, bedavaya hikaye atmamı beklemiyorsun herhalde?';
      } else if (currentTrust < 70) {
        moodDialogue = 'Selamlar! Vitrindeki spor kasayı reels videosunda arka plana koydum, etkileşim güzel gidiyor.';
      } else {
        moodDialogue = 'Kankam benim! Yeni videoda senin galeriyi ana sponsor gibi övdüm, vitrinine müşteri yağacak hazır ol!';
      }
    } else {
      if (currentTrust < 40) {
        moodDialogue = 'Çay ₺10 usta, veresiye defterimiz kapalıdır.';
      } else if (currentTrust < 70) {
        moodDialogue = 'Afiyet olsun usta. Sanayide yine fısıltılar dönüyor, kulisleri takip etmeyi unutma.';
      } else {
        moodDialogue = 'Ooo galerici dostum! Maslakta ucuza düşen kelepirleri ilk sana fısıldıyorum, çayın da her zaman benden!';
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Consumer(
          builder: (context, modalRef, _) {
            final liveGame = modalRef.watch(gameProvider);
            final liveTrust = liveGame.getNpcRelation(id);
            final liveHasHighTrust = liveGame.hasHighNpcTrust(id);

            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: Colors.black, width: 2.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 2.0),
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              role,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      NeoBrutalBadge(
                        text: '$liveTrust / 100',
                        backgroundColor: liveHasHighTrust ? AppColors.brutalGreen : AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Mood Quote Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote_rounded, size: 18, color: AppColors.brutalYellow),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            moodDialogue,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.tr('growth_npc_options_title'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 1. Çay Ismarla (₺250 • +3 Güven)
                  _buildInteractionRow(
                    title: context.tr('growth_npc_tea_title'),
                    subtitle: context.tr('growth_npc_tea_subtitle'),
                    cost: 250,
                    trustGain: 3,
                    icon: Icons.coffee_rounded,
                    buttonColor: AppColors.brutalYellow,
                    isDark: isDark,
                    canAfford: liveGame.balance >= 250,
                    onTap: () {
                      final ok = ref.read(gameProvider.notifier).interactWithNpc(
                        npcId: id,
                        cost: 250,
                        trustGain: 3,
                      );
                      if (ok) {
                        GameSoundHapticService.playCashSuccess();
                        NotificationService.showSuccess(context, '$name • +3');
                      } else {
                        NotificationService.showError(context, context.tr('insufficient_balance'));
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // 2. İş Pasla (₺1.500 • +8 Güven)
                  _buildInteractionRow(
                    title: context.tr('growth_npc_job_title'),
                    subtitle: context.tr('growth_npc_job_subtitle'),
                    cost: 1500,
                    trustGain: 8,
                    icon: Icons.handshake_rounded,
                    buttonColor: AppColors.brutalCyan,
                    isDark: isDark,
                    canAfford: liveGame.balance >= 1500,
                    onTap: () {
                      final ok = ref.read(gameProvider.notifier).interactWithNpc(
                        npcId: id,
                        cost: 1500,
                        trustGain: 8,
                      );
                      if (ok) {
                        GameSoundHapticService.playCashSuccess();
                        NotificationService.showSuccess(context, '$name • +8');
                      } else {
                        NotificationService.showError(context, context.tr('insufficient_balance'));
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  // 3. Özel Hediye / Jest Yap (₺5.000 • +18 Güven)
                  _buildInteractionRow(
                    title: context.tr('growth_npc_gift_title'),
                    subtitle: context.tr('growth_npc_gift_subtitle'),
                    cost: 5000,
                    trustGain: 18,
                    icon: Icons.card_giftcard_rounded,
                    buttonColor: AppColors.brutalGreen,
                    isDark: isDark,
                    canAfford: liveGame.balance >= 5000,
                    onTap: () {
                      final ok = ref.read(gameProvider.notifier).interactWithNpc(
                        npcId: id,
                        cost: 5000,
                        trustGain: 18,
                      );
                      if (ok) {
                        GameSoundHapticService.playCashSuccess();
                        NotificationService.showSuccess(context, '$name • +18');
                      } else {
                        NotificationService.showError(context, context.tr('insufficient_balance'));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractionRow({
    required String title,
    required String subtitle,
    required double cost,
    required int trustGain,
    required IconData icon,
    required Color buttonColor,
    required bool isDark,
    required bool canAfford,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: buttonColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.8),
            ),
            child: Icon(icon, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
                Text(
                  '$subtitle • +$trustGain',
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: CurrencyFormatter.format(cost),
            backgroundColor: canAfford ? buttonColor : const Color(0xFF64748B),
            textColor: Colors.black,
            fontSize: 10.5,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: onTap,
          ),
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
    final isMax = level >= 10;

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(width: 8),
                          NeoBrutalBadge(
                            text: isMax ? context.tr('max_badge') : 'LV $level/10',
                            backgroundColor: isMax ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                            textColor: isMax ? Colors.black : (isDark ? Colors.white : Colors.black),
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                if (!isMax)
                  NeoBrutalButton(
                    label: '+1 SP',
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backgroundColor: hasPoints ? AppColors.brutalYellow : const Color(0xFF64748B),
                    textColor: Colors.black,
                    onPressed: hasPoints
                        ? () {
                            ref.read(gameProvider.notifier).upgradeSkill(skillKey);
                          }
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Text(
                perk,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
