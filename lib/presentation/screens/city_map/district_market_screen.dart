import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../domain/usecases/district_economy_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class DistrictInfo {
  final String key;
  final String name;
  final IconData icon;
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

  String getLocalizedName(BuildContext context) =>
      context.tr('district_${key}_name');
  String getLocalizedSegment(BuildContext context) =>
      context.tr('district_${key}_segment');
  String getLocalizedPerk(BuildContext context) =>
      context.tr('district_${key}_perk');
}

const List<DistrictInfo> kDistricts = [
  DistrictInfo(
    key: 'ikitelli_sanayi',
    name: 'İkitelli Sanayi',
    icon: Icons.build_rounded,
    segment: 'Ticari & Orta Segment',
    perk: 'Yedek Parça & Onarım Maliyeti -%15',
    minReputation: 0,
    accentColor: Color(0xFFF59E0B),
  ),
  DistrictInfo(
    key: 'bagcilar_oto_pazari',
    name: 'Bağcılar Oto Pazarı',
    icon: Icons.bolt_rounded,
    segment: 'Hızlı Sirkülasyon & Fırsat',
    perk: 'Müşteri Teklif Trafiği +%25',
    minReputation: 25,
    accentColor: Color(0xFFEF4444),
  ),
  DistrictInfo(
    key: 'kadikoy_klasik',
    name: 'Kadıköy Klasik Sokağı',
    icon: Icons.radio_rounded,
    segment: 'Klasik & Koleksiyon',
    perk: 'Yadigâr & Klasik Araç Değeri +%15',
    minReputation: 50,
    accentColor: Color(0xFF8B5CF6),
  ),
  DistrictInfo(
    key: 'etiler_galericiler',
    name: 'Etiler Galericiler Sitesi',
    icon: Icons.star_rounded,
    segment: 'Premium & SUV',
    perk: 'Satış Kar Marjı +%10',
    minReputation: 100,
    accentColor: Color(0xFF00E575),
  ),
  DistrictInfo(
    key: 'ankara_kizilay',
    name: 'Ankara Kızılay Hattı',
    icon: Icons.apartment_rounded,
    segment: 'Memur & Sedan Araçlar',
    perk: 'İhtilafsız Temiz Satış Oranı +%20',
    minReputation: 75,
    accentColor: Color(0xFF3B82F6),
  ),
  DistrictInfo(
    key: 'maslak_plaza',
    name: 'Maslak Plaza',
    icon: Icons.location_city_rounded,
    segment: 'Lüks & Premium',
    perk: 'Gelen Teklif Fiyatları +%8',
    minReputation: 120,
    accentColor: Color(0xFF00E575),
  ),
  DistrictInfo(
    key: 'nisantasi_vitrin',
    name: 'Nişantaşı Vitrin',
    icon: Icons.diamond_rounded,
    segment: 'Süper Spor & Egzotik',
    perk: 'Esnaf İtibarı Çarpanı +%20',
    minReputation: 200,
    accentColor: Color(0xFFFFD700),
  ),
];

class DistrictMarketScreen extends ConsumerWidget {
  const DistrictMarketScreen({super.key});

  /// Calculates dynamic exponential cost for acquiring +5% market share in a district
  static double calculateBoostCost(double currentShare) =>
      DistrictEconomyEngine.calculateBoostCost(currentShare);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/districts')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('district_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/districts',
          featureTitle: context.tr('district_screen_title'),
          icon: Icons.map_rounded,
        ),
      );
    }

    final districtShares = game.districtMarketShare;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('district_screen_title'),
        subtitle: context.tr('district_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.radarPulse,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          // Info Banner (§1.4 / Q8)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor:
                isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
            borderColor: const Color(0xFF3B82F6),
            borderRadius: 12,
            child: Row(
              children: [
                const Icon(Icons.map_rounded,
                    size: 28, color: Color(0xFF3B82F6)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('district_banner_title'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFF93C5FD)
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('district_banner_desc'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF334155),
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
            final rawShare = (districtShares[district.name] ??
                    districtShares[district.key] ??
                    0.05)
                .clamp(0.0, 1.0);
            final sharePercent = (rawShare * 100).round();
            final isMaxed = rawShare >= 1.0;
            final isUnlocked = game.reputation >= district.minReputation;
            final boostCost = calculateBoostCost(rawShare);

            final cardBorderColor = isMaxed
                ? AppColors.brutalYellow
                : (isUnlocked
                    ? district.accentColor
                    : (isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFFCBD5E1)));

            final cardBgColor = isMaxed
                ? (isDark ? const Color(0xFF1C190D) : const Color(0xFFFEFCE8))
                : (isDark ? const Color(0xFF161A24) : Colors.white);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: cardBgColor,
                borderColor: cardBorderColor,
                borderWidth: isMaxed ? 2.8 : (isUnlocked ? 2.0 : 1.2),
                borderRadius: 12,
                shadowOffset:
                    isMaxed ? const Offset(3.5, 3.5) : const Offset(2.5, 2.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              district.icon,
                              size: 22,
                              color: isMaxed
                                  ? AppColors.brutalYellow
                                  : (isUnlocked
                                      ? district.accentColor
                                      : (isDark
                                          ? Colors.white38
                                          : Colors.black38)),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  district.getLocalizedName(context),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isUnlocked
                                        ? (isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A))
                                        : (isDark
                                            ? Colors.white38
                                            : Colors.black38),
                                  ),
                                ),
                                Text(
                                  district.getLocalizedSegment(context),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (!isUnlocked)
                          NeoBrutalBadge(
                            text: context.tr('district_req_rep',
                                {'rep': '${district.minReputation}'}),
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black12,
                            textColor: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 9.5,
                          )
                        else if (isMaxed)
                          NeoBrutalBadge(
                            text: context.tr('district_badge_monopoly'),
                            icon: Icons.workspace_premium_rounded,
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 9.5,
                            borderWidth: 2.0,
                          )
                        else
                          NeoBrutalBadge(
                            text: context.tr('district_badge_share',
                                {'share': '$sharePercent'}),
                            backgroundColor: district.accentColor,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Perk Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isMaxed
                            ? (isDark
                                ? const Color(0xFF26220E)
                                : const Color(0xFFFEF08A))
                            : district.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isMaxed
                              ? AppColors.brutalYellow
                              : district.accentColor.withValues(alpha: 0.3),
                          width: isMaxed ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isMaxed
                                ? Icons.verified_rounded
                                : Icons.star_rounded,
                            size: 13,
                            color: isMaxed
                                ? const Color(0xFFCA8A04)
                                : district.accentColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            district.getLocalizedPerk(context),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isMaxed
                                  ? (isDark
                                      ? AppColors.brutalYellow
                                      : const Color(0xFF713F12))
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A)),
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
                        backgroundColor: isDark
                            ? const Color(0xFF232A3B)
                            : const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isMaxed
                              ? AppColors.brutalYellow
                              : district.accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Action: Either Boost Button or Full Dominance Stamp
                    if (isUnlocked)
                      if (isMaxed)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2E2405)
                                : const Color(0xFFFEF9C3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.brutalYellow,
                              width: 2.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black
                                    : const Color(0xFF0F172A),
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.brutalYellow,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.workspace_premium_rounded,
                                  size: 16,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('district_monopoly_stamp_title'),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                        color: isDark
                                            ? AppColors.brutalYellow
                                            : const Color(0xFF854D0E),
                                      ),
                                    ),
                                    Text(
                                      context.tr('district_monopoly_stamp_desc'),
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFFFDE047)
                                            : const Color(0xFFA16207),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              NeoBrutalBadge(
                                text: context.tr('badge_max'),
                                backgroundColor: AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 9,
                              ),
                            ],
                          ),
                        )
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            NeoBrutalButton(
                              label: context.tr('district_btn_boost', {
                                'cost': CurrencyFormatter.formatShort(boostCost)
                              }),
                              icon: Icons.campaign_rounded,
                              backgroundColor: isDark
                                  ? const Color(0xFF1E2330)
                                  : const Color(0xFFF1F5F9),
                              textColor: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              onPressed: () {
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .boostDistrictMarketShare(
                                      district.name,
                                      0.05,
                                      boostCost,
                                    );
                                if (success) {
                                  final updated =
                                      ((districtShares[district.name] ??
                                                      districtShares[
                                                          district.key] ??
                                                      0.05) +
                                                  0.05)
                                              .clamp(0.0, 1.0) *
                                          100;
                                  NotificationService.showSuccess(
                                    context,
                                    context.tr('district_toast_boost_success', {
                                      'district':
                                          district.getLocalizedName(context),
                                      'share': '${updated.round()}',
                                    }),
                                  );
                                } else {
                                  if (game.balance < boostCost) {
                                    NotificationService.showError(
                                      context,
                                      context.tr(
                                          'district_toast_boost_insufficient', {
                                        'cost': CurrencyFormatter.formatShort(
                                            boostCost),
                                      }),
                                    );
                                  } else {
                                    NotificationService.showInfo(
                                      context,
                                      context.tr('district_toast_boost_maxed'),
                                    );
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
