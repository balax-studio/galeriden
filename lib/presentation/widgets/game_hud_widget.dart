import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/theme_palette_model.dart';
import '../providers/game_provider.dart';
import '../screens/dashboard/widgets/dashboard_missions_section.dart';
import 'animated_rolling_counter.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

/// Floating Game HUD overlay widget - Neo-Brutalist Monolithic Stats Bar
class GameHudHeaderWidget extends ConsumerWidget {
  const GameHudHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette ?? ThemePaletteModel.defaultPalettes.first;
    final isDark = p.isDark;
    final lang = Localizations.localeOf(context).languageCode;

    return RepaintBoundary(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            // 1. KASA Pill (Interactive -> Finance & Banking with Smooth Rolling Counter) - EN SOLDA
            _buildPill(
              context,
              icon: Icons.account_balance_wallet_rounded,
              accentColor: const Color(0xFF00E575),
              title: context.tr('hud_balance'),
              valueWidget: AnimatedRollingCounter(
                value: game.balance,
                isShort: true,
                style: AppTypography.monoSpec(isDark).copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              bold: true,
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/finance');
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // 2. GÜN Pill (Interactive -> Sales & Day Ledger History)
            _buildPill(
              context,
              icon: Icons.calendar_month_rounded,
              accentColor: const Color(0xFFFFB703),
              title: context.tr('hud_day'),
              value: '${game.currentDay}',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/history');
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // 3. MEVSİM Pill (Interactive -> Season Details & Market Multipliers)
            _buildPill(
              context,
              icon: game.currentSeason == GameSeason.spring
                  ? Icons.local_florist_rounded
                  : (game.currentSeason == GameSeason.summer
                      ? Icons.wb_sunny_rounded
                      : (game.currentSeason == GameSeason.autumn
                          ? Icons.park_rounded
                          : Icons.ac_unit_rounded)),
              accentColor: game.currentSeason == GameSeason.spring
                  ? const Color(0xFF10B981)
                  : (game.currentSeason == GameSeason.summer
                      ? const Color(0xFFF59E0B)
                      : (game.currentSeason == GameSeason.autumn
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF38BDF8))),
              title: game.getLocalizedSeasonName(lang).toUpperCase(),
              value: '${game.daysRemainingInSeason}d',
              onTap: () {
                HapticFeedback.lightImpact();
                _showSeasonInfo(context, game, isDark, lang);
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // 4. HAVA DURUMU Pill (Interactive -> Dynamic Weather & Market Multipliers §4.6.5)
            _buildPill(
              context,
              icon: game.currentWeather.icon,
              accentColor: game.currentWeather == WeatherType.sunny
                  ? const Color(0xFFFBBF24)
                  : (game.currentWeather == WeatherType.rainy
                      ? const Color(0xFF60A5FA)
                      : (game.currentWeather == WeatherType.snowy
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF94A3B8))),
              title: context.tr('hud_weather'),
              value: game.currentWeather.getLocalizedTitle(langCode: lang),
              onTap: () {
                HapticFeedback.lightImpact();
                _showWeatherInfo(context, game, isDark, lang);
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // GARAJ STOK Pill (Interactive -> Showroom / Garage)
            _buildPill(
              context,
              icon: Icons.directions_car_rounded,
              accentColor: const Color(0xFF00F0FF),
              title: context.tr('hud_garage'),
              value: '${game.ownedCars.length}/${game.maxGarageSlots}',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/showroom');
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // İTİBAR Pill (Interactive -> Customer Reviews & Dealer Rating)
            _buildPill(
              context,
              icon: Icons.star_rounded,
              accentColor: const Color(0xFFFFDE59),
              title: context.tr('hud_reputation'),
              value: '%${game.reputationScore}',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/reviews');
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // GÖREV Pill (Interactive -> Daily Missions Modal)
            _buildPill(
              context,
              icon: Icons.task_alt_rounded,
              accentColor: const Color(0xFFA855F7),
              title: context.tr('hud_missions'),
              value: '${game.activeMissions.where((m) => m.isCompleted == true).length}/${game.activeMissions.length}',
              onTap: () {
                HapticFeedback.lightImpact();
                _showMissionsModal(context, isDark, p);
              },
              isDark: isDark,
            ),
            const SizedBox(width: 8),

            // SEVİYE & XP Pill (Goal Gradient §2.2)
            _buildPill(
              context,
              icon: Icons.military_tech_rounded,
              accentColor: const Color(0xFFFF7A00),
              title: '${context.tr('hud_level')} ${game.level}',
              value: '${(game.skills.currentLevelTargetXp - game.skills.xpInCurrentLevel).clamp(0, game.skills.currentLevelTargetXp)} XP',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/character-growth');
              },
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  void _showMissionsModal(BuildContext context, bool isDark, ThemePaletteModel p) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final game = ref.watch(gameProvider);
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              borderRadius: 12,
              borderWidth: 2.5,
              shadowOffset: const Offset(4, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA855F7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.task_alt_rounded, color: Colors.black, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          context.tr('daily_missions'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 22),
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.6,
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: DashboardMissionsList(game: game, palette: p),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    String? value,
    Widget? valueWidget,
    required VoidCallback onTap,
    required bool isDark,
    bool bold = false,
  }) {
    final bgColor = isDark ? const Color(0xFF141721) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);
    final shadowColor = isDark ? const Color(0xFF000000) : const Color(0xFF0F172A);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                offset: const Offset(2.0, 2.0),
                blurRadius: 0,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: borderColor,
                width: 2.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(icon, size: 12, color: Colors.black),
                ),
                const SizedBox(width: 6),
                Text(
                  '$title ',
                  style: AppTypography.labelSmall(isDark).copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                if (valueWidget != null)
                  valueWidget
                else
                  Text(
                    value ?? '',
                    style: AppTypography.monoSpec(isDark).copyWith(
                      fontSize: 11.5,
                      fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSeasonInfo(BuildContext context, DealershipModel game, bool isDark, String lang) {
    Color seasonAccentColor;
    IconData seasonIcon;

    switch (game.currentSeason) {
      case GameSeason.spring:
        seasonAccentColor = const Color(0xFF10B981);
        seasonIcon = Icons.local_florist_rounded;
        break;
      case GameSeason.summer:
        seasonAccentColor = const Color(0xFFF59E0B);
        seasonIcon = Icons.wb_sunny_rounded;
        break;
      case GameSeason.autumn:
        seasonAccentColor = const Color(0xFFEA580C);
        seasonIcon = Icons.park_rounded;
        break;
      case GameSeason.winter:
        seasonAccentColor = const Color(0xFF38BDF8);
        seasonIcon = Icons.ac_unit_rounded;
        break;
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 16,
          borderWidth: 2.8,
          shadowOffset: const Offset(4, 4),
          showDotGrid: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: seasonAccentColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(seasonIcon, color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('season_cycle_title'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              game.getLocalizedSeasonName(lang).toUpperCase(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: context.tr('season_active'),
                      backgroundColor: seasonAccentColor,
                      textColor: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Season Progress & Countdown Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('season_progress'),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                          ),
                          Text(
                            context.tr('remaining_time', {'days': game.daysRemainingInSeason}),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: ((7 - game.daysRemainingInSeason) / 7.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: seasonAccentColor,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Section Title
                Text(
                  context.tr('market_demands_title'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                // 4. Season Cards
                _buildSeasonCard(
                  name: GameSeason.spring.getLocalizedName(lang),
                  targetVehicles: 'Sedan & Hatchback',
                  effectBadge: '+%15',
                  icon: Icons.local_florist_rounded,
                  accentColor: const Color(0xFF10B981),
                  isCurrent: game.currentSeason == GameSeason.spring,
                  isDark: isDark,
                ),
                _buildSeasonCard(
                  name: GameSeason.summer.getLocalizedName(lang),
                  targetVehicles: 'Sports, Classic & Cabrio',
                  effectBadge: '+%30',
                  icon: Icons.wb_sunny_rounded,
                  accentColor: const Color(0xFFF59E0B),
                  isCurrent: game.currentSeason == GameSeason.summer,
                  isDark: isDark,
                ),
                _buildSeasonCard(
                  name: GameSeason.autumn.getLocalizedName(lang),
                  targetVehicles: 'Family Sedans & Commercial',
                  effectBadge: '+%15',
                  icon: Icons.park_rounded,
                  accentColor: const Color(0xFFEA580C),
                  isCurrent: game.currentSeason == GameSeason.autumn,
                  isDark: isDark,
                ),
                _buildSeasonCard(
                  name: GameSeason.winter.getLocalizedName(lang),
                  targetVehicles: 'SUV & 4x4 Offroad',
                  effectBadge: '+%35',
                  icon: Icons.ac_unit_rounded,
                  accentColor: const Color(0xFF38BDF8),
                  isCurrent: game.currentSeason == GameSeason.winter,
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // 5. Bottom Button
                NeoBrutalButton(
                  label: context.tr('understood_button'),
                  icon: Icons.check_circle_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 12,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeasonCard({
    required String name,
    required String targetVehicles,
    required String effectBadge,
    required IconData icon,
    required Color accentColor,
    required bool isCurrent,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFEFCE8))
            : (isDark ? const Color(0xFF141721) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? accentColor
              : (isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1)),
          width: isCurrent ? 2.2 : 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
            child: Icon(icon, size: 16, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  targetVehicles,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          NeoBrutalBadge(
            text: effectBadge,
            backgroundColor: isCurrent ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
            textColor: isCurrent ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
          ),
        ],
      ),
    );
  }

  void _showWeatherInfo(BuildContext context, DealershipModel game, bool isDark, String lang) {
    final w = game.currentWeather;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 16,
          borderWidth: 2.8,
          shadowOffset: const Offset(4, 4),
          showDotGrid: true,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.brutalYellow,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(w.icon, color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('weather_market_title'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              w.getLocalizedTitle(langCode: lang).toUpperCase(),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: context.tr('weather_live_impact'),
                      icon: Icons.sensors_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 2. Flavor Description Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1),
                      width: 1.8,
                    ),
                  ),
                  child: Text(
                    w.getLocalizedDescription(langCode: lang),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Section Title
                Text(
                  context.tr('current_multipliers_title'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),

                // 4. Metric rows
                _buildWeatherImpactRow(
                  icon: Icons.people_rounded,
                  title: context.tr('visitor_traffic'),
                  multiplierPercent: (w.visitorMultiplier * 100).round(),
                  iconBgColor: AppColors.brutalBlue,
                  isDark: isDark,
                ),
                _buildWeatherImpactRow(
                  icon: Icons.local_car_wash_rounded,
                  title: context.tr('car_wash_demand'),
                  multiplierPercent: (w.carWashDemandMultiplier * 100).round(),
                  iconBgColor: AppColors.brutalGreen,
                  isDark: isDark,
                ),
                _buildWeatherImpactRow(
                  icon: Icons.terrain_rounded,
                  title: context.tr('suv_demand'),
                  multiplierPercent: (w.suvDemandMultiplier * 100).round(),
                  iconBgColor: AppColors.brutalYellow,
                  isDark: isDark,
                ),
                _buildWeatherImpactRow(
                  icon: Icons.speed_rounded,
                  title: context.tr('sport_demand'),
                  multiplierPercent: (w.sportCarDemandMultiplier * 100).round(),
                  iconBgColor: AppColors.brutalOrange,
                  isDark: isDark,
                ),
                _buildWeatherImpactRow(
                  icon: Icons.car_crash_rounded,
                  title: context.tr('tow_truck_calls'),
                  multiplierPercent: (w.towTruckBonusMultiplier * 100).round(),
                  iconBgColor: AppColors.brutalCyan,
                  isDark: isDark,
                ),
                _buildWeatherImpactRow(
                  icon: Icons.search_rounded,
                  title: context.tr('eye_detail_accuracy'),
                  multiplierPercent: (w.eyeForDetailAccuracyMultiplier * 100).round(),
                  iconBgColor: const Color(0xFFA855F7),
                  isDark: isDark,
                ),
                const SizedBox(height: 14),

                // 5. Action Button
                NeoBrutalButton(
                  label: context.tr('ok_button'),
                  icon: Icons.thumb_up_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 12,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherImpactRow({
    required IconData icon,
    required String title,
    required int multiplierPercent,
    required Color iconBgColor,
    required bool isDark,
  }) {
    final isPositive = multiplierPercent > 100;
    final isNegative = multiplierPercent < 100;
    final badgeColor = isPositive
        ? AppColors.brutalGreen
        : (isNegative ? AppColors.brutalOrange : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)));
    final badgeTextColor = (isPositive || isNegative) ? Colors.black : (isDark ? Colors.white70 : Colors.black87);
    final badgeText = isPositive
        ? '+%${multiplierPercent - 100}'
        : (isNegative ? '-%${100 - multiplierPercent}' : '100%');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 1.2,
              ),
            ),
            child: Icon(icon, size: 14, color: Colors.black),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            '%$multiplierPercent ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 4),
          NeoBrutalBadge(
            text: badgeText,
            backgroundColor: badgeColor,
            textColor: badgeTextColor,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ],
      ),
    );
  }
}
