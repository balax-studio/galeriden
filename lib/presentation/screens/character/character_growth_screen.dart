import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      appBar: const NeoBrutalAppBar(
        title: 'KARAKTER GELİŞİMİ & ESNAF PERKLERİ',
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
                                text: 'SEVİYE $currentLvl',
                                backgroundColor: const Color(0xFFA855F7),
                                textColor: Colors.white,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Köken: ${game.originTitle}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'Esnaf İtibarı: ${game.reputationScore}/100',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Sermaye: ${CurrencyFormatter.formatShort(game.balance)}',
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
                'YETENEK AĞACI & ESNAF PERKLERİ',
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
            title: 'Çevre & Tanınırlık (Network)',
            desc: 'Daha prestijli koleksiyonluk araçların ve zengin alıcıların gelmesi.',
            perk: skills.reputation >= 5 ? 'Nadir Koleksiyon Düşme Şansı +%15' : 'Lv 5: Nadir Koleksiyon Düşüşü %15 Artar',
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

          // 4. Esnaf Çevresi & NPC İlişkileri (§2.4)
          _buildNpcRelationshipsSection(context, game, isDark),
          const SizedBox(height: 16),

          // 5. Achievements Section
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
                      const NeoBrutalBadge(
                        text: 'KAZANILDI',
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
              'UZMANLIK YOLU (PRESTİJ SINIFI)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            NeoBrutalBadge(
              text: isUnlocked ? (hasClass ? game.specializationTitle : 'SEÇİM BEKLİYOR') : 'SEVİYE 4 KİLİTLİ',
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
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, color: Color(0xFF64748B), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Seviye 4\'e ulaştığında galerici uzmanlık sınıfını seçebilirsin (Restoratör Usta, Pazar Kurdu veya Galeri Baronu).',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
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
            title: 'Restoratör Usta',
            icon: Icons.auto_fix_high_rounded,
            color: const Color(0xFFF97316),
            desc: 'Tamir ve restorasyonda efsanesin. Hurdalıktan topladığın araçlar altın değerinde yenilenir.',
            perks: '• Tamir Maliyeti -%20\n• Restorasyon Katma Değeri +%25\n• Çıkma Parça Montaj Başarısı +%20',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSpecializationCard(
            context,
            ref,
            game: game,
            path: SpecializationPath.trader,
            title: 'Pazar Kurdu (Trader)',
            icon: Icons.trending_up_rounded,
            color: AppColors.brutalGreen,
            desc: 'Pazarlığın kitabını yazdın. En ucuzdan alır, en yüksek teklifle masadan kalkarsın.',
            perks: '• Araç Alım İndirimi -%10\n• Karşı Teklif Kabul Oranı +%15\n• Doping Süresi ve Etkisi x1.5',
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildSpecializationCard(
            context,
            ref,
            game: game,
            path: SpecializationPath.boss,
            title: 'Oto Galeri Baronu (Boss)',
            icon: Icons.domain_rounded,
            color: const Color(0xFF3B82F6),
            desc: 'Büyük ölçekli imparatorluk kurdun. Yan işletmeler ve personel senin için çalışır.',
            perks: '• Personel Maaş Gideri -%20\n• Yan İşletmeler Pasif Geliri +%30\n• Yeni Şube Açılış İndirimi -%25',
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
          NotificationService.showSuccess(context, '$title uzmanlık yolu başarıyla seçildi!');
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
                  const NeoBrutalBadge(
                    text: 'AKTİF SINIF',
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

  Widget _buildNpcRelationshipsSection(BuildContext context, DealershipModel game, bool isDark) {
    final npcs = [
      {
        'id': 'haydar_usta',
        'name': 'Haydar Usta (Ekspertiz)',
        'role': 'Oto Ekspertiz & Diagnostik',
        'icon': Icons.car_repair_rounded,
        'color': const Color(0xFFF97316),
        'perk': 'Güven >= 70: %50 Ekspertiz İndirimi!',
      },
      {
        'id': 'cikmaci_ibo',
        'name': 'Çıkmacı İbo (Yedek Parça)',
        'role': 'Oto Sanayi Çıkma Parçacısı',
        'icon': Icons.settings_input_component_rounded,
        'color': const Color(0xFF8B5CF6),
        'perk': 'Güven >= 70: %25 Çıkma Parça İndirimi!',
      },
      {
        'id': 'golge_ibrahim',
        'name': 'Gölge İbrahim (Karaborsa)',
        'role': 'Gizli İhaleler & Acil Nakit',
        'icon': Icons.visibility_off_rounded,
        'color': const Color(0xFFEF4444),
        'perk': 'Güven >= 70: Kaçak ve Özel Sandık Parçaları!',
      },
      {
        'id': 'vlogger_berk',
        'name': 'Vlogger Berk (Oto Medya)',
        'role': 'YouTube & Sosyal Medya İncelemesi',
        'icon': Icons.video_camera_front_rounded,
        'color': const Color(0xFF06B6D4),
        'perk': 'Güven >= 70: Galeriye +%25 Ekstra Müşteri Trafiği!',
      },
      {
        'id': 'necati',
        'name': 'Necati Dayı (Kahvehane)',
        'role': 'Sanayi & Mahalle İstihbaratı',
        'icon': Icons.coffee_rounded,
        'color': const Color(0xFFEAB308),
        'perk': 'Güven >= 70: Ucuza Düşen Kelepir Araç İhbarları!',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ESNAF ÇEVRESİ & NPC İLİŞKİLERİ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        ...npcs.map((npc) {
          final id = npc['id'] as String;
          final trust = game.getNpcRelation(id);
          final hasHighTrust = game.hasHighNpcTrust(id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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
                      if (hasHighTrust)
                        const Text(
                          'AKTİF',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
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
                            text: isMax ? 'MAX' : 'LV $level/10',
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
