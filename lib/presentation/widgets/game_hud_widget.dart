import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
          const SizedBox(width: 8),

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
          const SizedBox(width: 8),

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
          const SizedBox(width: 8),

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
          const SizedBox(width: 8),

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
        borderRadius: BorderRadius.circular(14),
        splashColor: accentColor.withValues(alpha: 0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xEE0F172A)
                : const Color(0xF7FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.45 : 0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.15),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
              BoxShadow(
                color: isDark ? Colors.black38 : Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 13, color: accentColor),
              ),
              const SizedBox(width: 7),
              Text(
                '$title ',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: isDark ? Colors.grey.shade400 : const Color(0xFF64748B),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
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
