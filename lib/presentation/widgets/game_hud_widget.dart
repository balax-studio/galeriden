import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/game_provider.dart';
import 'app_glass_container.dart';

/// Floating Game HUD overlay widget - Premium Glassmorphic Cyber-Tycoon Bar
class GameHudHeaderWidget extends ConsumerWidget {
  const GameHudHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        children: [
          // GÜN Pill
          _buildPill(
            context,
            icon: Icons.calendar_today_rounded,
            accentColor: const Color(0xFFF59E0B),
            title: 'GÜN',
            value: '${game.currentDay}',
            onTap: () {},
            isDark: isDark,
          ),
          const SizedBox(width: 6),

          // KASA Pill (Interactive -> Finance)
          _buildPill(
            context,
            icon: Icons.account_balance_wallet_rounded,
            accentColor: const Color(0xFF10B981),
            title: 'KASA',
            value: CurrencyFormatter.formatShort(game.balance),
            bold: true,
            onTap: () => context.push('/finance'),
            isDark: isDark,
          ),
          const SizedBox(width: 6),

          // GARAJ STOK Pill (Interactive -> Showroom)
          _buildPill(
            context,
            icon: Icons.directions_car_rounded,
            accentColor: const Color(0xFF06B6D4),
            title: 'GARAJ',
            value: '${game.ownedCars.length}/${game.maxGarageSlots}',
            onTap: () => context.push('/showroom'),
            isDark: isDark,
          ),
          const SizedBox(width: 6),

          // İTİBAR Pill (Interactive -> Branch Empire)
          _buildPill(
            context,
            icon: Icons.star_rounded,
            accentColor: const Color(0xFFFBBF24),
            title: 'İTİBAR',
            value: game.reputationScore.toStringAsFixed(1),
            onTap: () => context.push('/branch'),
            isDark: isDark,
          ),
          const SizedBox(width: 6),

          // GÖREV Pill
          _buildPill(
            context,
            icon: Icons.assignment_turned_in_rounded,
            accentColor: const Color(0xFFA855F7),
            title: 'GÖREV',
            value: '${game.activeMissions.where((m) => m.isCompleted).length}/${game.activeMissions.length}',
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required IconData icon,
    required Color accentColor,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool isDark,
    bool bold = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: accentColor.withValues(alpha: 0.15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xCC0F172A)
                : const Color(0xEEFFFFFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? accentColor.withValues(alpha: 0.35)
                  : accentColor.withValues(alpha: 0.45),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 12, color: accentColor),
              ),
              const SizedBox(width: 6),
              Text(
                '$title ',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Floating Tycoon Quick Dock Bar Widget
class GameHudDockWidget extends StatelessWidget {
  const GameHudDockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return AppGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 24.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDockButton(
            context,
            icon: Icons.storefront_rounded,
            label: 'Showroom',
            color: p.primaryColor,
            onTap: () => context.push('/showroom'),
          ),
          _buildDockButton(
            context,
            icon: Icons.shopping_bag_rounded,
            label: 'Pazaryeri',
            color: Colors.lightBlueAccent,
            onTap: () => context.push('/marketplace'),
          ),
          _buildDockButton(
            context,
            icon: Icons.build_circle_rounded,
            label: 'Atölye',
            color: Colors.orangeAccent,
            onTap: () => context.push('/workshop'),
          ),
          _buildDockButton(
            context,
            icon: Icons.people_alt_rounded,
            label: 'Kadrom',
            color: Colors.purpleAccent,
            onTap: () => context.push('/staff'),
          ),
          _buildDockButton(
            context,
            icon: Icons.palette_rounded,
            label: 'Tema',
            color: p.secondaryColor,
            onTap: () => context.push('/theme-store'),
          ),
        ],
      ),
    );
  }

  Widget _buildDockButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
