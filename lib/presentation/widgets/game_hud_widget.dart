import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/theme_palette_model.dart';
import '../providers/dashboard_provider.dart';
import '../providers/game_provider.dart';
import '../screens/dashboard/widgets/dashboard_missions_section.dart';
import 'animated_rolling_counter.dart';
import 'neo_brutal_button.dart';

/// Floating Game HUD overlay widget - Neo-Brutalist Monolithic Stats Bar
class GameHudHeaderWidget extends ConsumerWidget {
  const GameHudHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette ?? ThemePaletteModel.defaultPalettes.first;
    final isDark = p.isDark;

    return RepaintBoundary(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            // GÜN Pill (Interactive -> Sales & Day Ledger History)
            _buildPill(
              context,
              icon: Icons.calendar_month_rounded,
              accentColor: const Color(0xFFFFB703),
              title: 'GÜN',
              value: '${game.currentDay}',
              onTap: () {
                HapticFeedback.lightImpact();
                context.push('/history');
              },
              isDark: isDark,
            ),
          const SizedBox(width: 8),

          // MEVSİM Pill (Interactive -> Season Details & Market Multipliers)
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
            title: game.currentSeasonName.toUpperCase(),
            value: '${game.daysRemainingInSeason}g',
            onTap: () {
              HapticFeedback.lightImpact();
              _showSeasonInfo(context, game, isDark);
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // HAVA DURUMU Pill (Interactive -> Dynamic Weather & Market Multipliers §4.6.5)
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
            title: 'HAVA',
            value: game.currentWeather.displayName,
            onTap: () {
              HapticFeedback.lightImpact();
              _showWeatherInfo(context, game, isDark);
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // KASA Pill (Interactive -> Finance & Banking with Smooth Rolling Counter §4.2)
          _buildPill(
            context,
            icon: Icons.account_balance_wallet_rounded,
            accentColor: const Color(0xFF00E575),
            title: 'KASA',
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

          // GARAJ STOK Pill (Interactive -> Showroom / Garage)
          _buildPill(
            context,
            icon: Icons.directions_car_rounded,
            accentColor: const Color(0xFF00F0FF),
            title: 'GARAJ',
            value: '${game.ownedCars.length}/${game.maxGarageSlots}',
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(dashboardTabProvider.notifier).state = 1;
              bool popped = false;
              try {
                if (context.canPop()) {
                  context.pop();
                  popped = true;
                }
              } catch (_) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                  popped = true;
                }
              }
              if (!popped) {
                try {
                  context.go('/dashboard');
                } catch (_) {}
              }
            },
            isDark: isDark,
          ),
          const SizedBox(width: 8),

          // İTİBAR Pill (Interactive -> Customer Reviews & Dealer Rating)
          _buildPill(
            context,
            icon: Icons.star_rounded,
            accentColor: const Color(0xFFFFDE59),
            title: 'İTİBAR',
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
            title: 'GÖREV',
            value: '${game.activeMissions.where((m) => m.isCompleted).length}/${game.activeMissions.length}',
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
            title: 'SEVİYE ${game.level}',
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
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            titlePadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            title: Row(
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
                const Expanded(
                  child: Text(
                    'GÜNLÜK GÖREVLER',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
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
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: DashboardMissionsList(game: game, palette: p),
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

  void _showSeasonInfo(BuildContext context, dynamic game, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            width: 2.0,
          ),
        ),
        title: Text(
          '28 Günlük Mevsim Döngüsü (${game.currentSeasonName})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Her mevsim 7 gün sürer. Mevsimsel koşullar araç türlerinin piyasa talebini ve fiyatlarını doğrudan etkiler:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            _buildSeasonDemandRow('🌸 İlkbahar', 'Sedan & Hatchback: +%15 Talep', isDark),
            _buildSeasonDemandRow('☀️ Yaz', 'Spor, Klasik & Cabrio: +%30 Değer', isDark),
            _buildSeasonDemandRow('🍂 Sonbahar', 'Aile Sedanları: +%15 Talep', isDark),
            _buildSeasonDemandRow('❄️ Kış', 'SUV & 4x4: +%35 Talep / Spor: -%25', isDark),
            const SizedBox(height: 12),
            Text(
              'Kalan Mevsim Süresi: ${game.daysRemainingInSeason} gün',
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.brutalGreen),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: 'ANLADIM',
            backgroundColor: AppColors.brutalYellow,
            textColor: Colors.black,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonDemandRow(String title, String desc, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              desc,
              style: TextStyle(fontSize: 11, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeatherInfo(BuildContext context, DealershipModel game, bool isDark) {
    final w = game.currentWeather;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            width: 2.0,
          ),
        ),
        title: Row(
          children: [
            Icon(w.icon, color: AppColors.brutalYellow, size: 24),
            const SizedBox(width: 8),
            Text(
              'Hava Durumu: ${w.displayName}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              w.flavorDescription,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
            ),
            const SizedBox(height: 12),
            _buildSeasonDemandRow('👥 Ziyaretçi Oranı', '%${(w.visitorMultiplier * 100).round()}', isDark),
            _buildSeasonDemandRow('🧽 Oto Yıkama Talebi', '%${(w.carWashDemandMultiplier * 100).round()}', isDark),
            _buildSeasonDemandRow('🚙 SUV / 4x4 Talebi', '%${(w.suvDemandMultiplier * 100).round()}', isDark),
            _buildSeasonDemandRow('🏎️ Spor Araç Talebi', '%${(w.sportCarDemandMultiplier * 100).round()}', isDark),
            _buildSeasonDemandRow('🔍 Kusur Fark Etme', '%${(w.eyeForDetailAccuracyMultiplier * 100).round()}', isDark),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: 'TAMAM',
            backgroundColor: AppColors.brutalYellow,
            textColor: Colors.black,
            fontSize: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }
}
