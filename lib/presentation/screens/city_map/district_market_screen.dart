import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class DistrictInfo {
  final String key;
  final String name;
  final String icon;
  final String segment;
  final String perk;
  final int minReputation;
  final Color accentColor;

  const DistrictInfo({
    required this.key,
    required this.name,
    required this.icon,
    required this.segment,
    required this.perk,
    required this.minReputation,
    required this.accentColor,
  });
}

const List<DistrictInfo> kDistricts = [
  DistrictInfo(
    key: 'ikitelli_sanayi',
    name: 'İkitelli Sanayi',
    icon: '🔧',
    segment: 'Ticari & Orta Segment',
    perk: 'Yedek Parça & Onarım Maliyeti -%15',
    minReputation: 0,
    accentColor: Color(0xFFF59E0B),
  ),
  DistrictInfo(
    key: 'bagcilar_oto_pazari',
    name: 'Bağcılar Oto Pazarı',
    icon: '⚡',
    segment: 'Hızlı Sirkülasyon & Fırsat',
    perk: 'Müşteri Teklif Trafiği +%25',
    minReputation: 25,
    accentColor: Color(0xFFEF4444),
  ),
  DistrictInfo(
    key: 'kadikoy_klasik',
    name: 'Kadıköy Klasik Sokağı',
    icon: '📻',
    segment: 'Klasik & Koleksiyon',
    perk: 'Yadigâr & Klasik Araç Değeri +%15',
    minReputation: 50,
    accentColor: Color(0xFFA855F7),
  ),
  DistrictInfo(
    key: 'ankara_kizilay',
    name: 'Ankara Kızılay Hattı',
    icon: '🏢',
    segment: 'Memur & Sedan Araçlar',
    perk: 'İhtilafsız Temiz Satış Oranı +%20',
    minReputation: 75,
    accentColor: Color(0xFF3B82F6),
  ),
  DistrictInfo(
    key: 'maslak_plaza',
    name: 'Maslak Plaza',
    icon: '🏙️',
    segment: 'Lüks & Premium',
    perk: 'Gelen Teklif Fiyatları +%8',
    minReputation: 120,
    accentColor: Color(0xFF00E575),
  ),
  DistrictInfo(
    key: 'nisantasi_vitrin',
    name: 'Nişantaşı Vitrin',
    icon: '💎',
    segment: 'Süper Spor & Egzotik',
    perk: 'Esnaf İtibarı Çarpanı +%20',
    minReputation: 200,
    accentColor: Color(0xFFFFD700),
  ),
];

class DistrictMarketScreen extends ConsumerWidget {
  const DistrictMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final districtShares = game.districtMarketShare;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'SEMT HAKİMİYETİ & PAZAR PAYI',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          // Info Banner (§1.4 / Q8)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
            borderColor: const Color(0xFF3B82F6),
            borderRadius: 12,
            child: Row(
              children: [
                const Text('🗺️', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ŞEHİR İKİNCİ EL PİYASASI HAKİMİYETİ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Farklı semtlerde satış yaptıkça veya yerel reklam kampanyası verdikçe semt pazar payın artar ve kalıcı esnaf avantajları açılır.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // District Cards
          ...kDistricts.map((district) {
            final rawShare = districtShares[district.name] ?? districtShares[district.key] ?? 0.05;
            final sharePercent = (rawShare * 100).round();
            final isUnlocked = game.reputation >= district.minReputation;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF161A24) : Colors.white,
                borderColor: isUnlocked ? district.accentColor : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                borderWidth: isUnlocked ? 2.0 : 1.2,
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(district.icon, style: const TextStyle(fontSize: 22)),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  district.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked
                                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                        : (isDark ? Colors.white38 : Colors.black38),
                                  ),
                                ),
                                Text(
                                  district.segment,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!isUnlocked)
                          NeoBrutalBadge(
                            text: '${district.minReputation} İtibar Gerektirir',
                            backgroundColor: isDark ? Colors.white12 : Colors.black12,
                            textColor: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 9.5,
                          )
                        else
                          NeoBrutalBadge(
                            text: '%$sharePercent Pazar Payı',
                            backgroundColor: district.accentColor,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Perk Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: district.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: district.accentColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 13, color: district.accentColor),
                          const SizedBox(width: 4),
                          Text(
                            district.perk,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: rawShare.clamp(0.0, 1.0),
                        minHeight: 7,
                        backgroundColor: isDark ? const Color(0xFF232A3B) : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(district.accentColor),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Action to Boost Share via Local Campaign
                    if (isUnlocked)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          NeoBrutalButton(
                            label: 'Yerel El İlanı & Reklam (₺10.000 -> +%5 Pay)',
                            icon: Icons.campaign_rounded,
                            backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                            textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            onPressed: () {
                              final success = ref.read(gameProvider.notifier).boostDistrictMarketShare(district.name, 0.05, 10000);
                              if (success) {
                                final updated = ((districtShares[district.name] ?? 0.05) + 0.05) * 100;
                                NotificationService.showSuccess(
                                  context,
                                  '${district.name} semtinde el ilanları dağıtıldı! Pazar payı: %${updated.round()}',
                                );
                              } else {
                                if (game.balance < 10000) {
                                  NotificationService.showError(context, 'Reklam kampanyası için ₺10.000 bakiye gereklidir.');
                                } else {
                                  NotificationService.showInfo(context, 'Bu semtte maksimum hakimiyete (%100) ulaşıldı!');
                                }
                              }
                            },
                          ),
                        ],
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
}
