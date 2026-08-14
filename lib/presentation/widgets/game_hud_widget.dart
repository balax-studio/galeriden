import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/game_provider.dart';
import 'app_glass_container.dart';

/// Floating Game HUD overlay widget - Beneloil Tycoon Style
class GameHudHeaderWidget extends ConsumerWidget {
  const GameHudHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // GÜN Pill
          _buildPill(
            icon: Icons.calendar_today_rounded,
            iconColor: Colors.amber.shade700,
            label: 'GÜN ${game.currentDay}',
          ),
          const SizedBox(width: 6),

          // KASA Pill
          _buildPill(
            icon: Icons.account_balance_wallet_rounded,
            iconColor: Colors.green.shade700,
            label: 'KASA ${CurrencyFormatter.formatShort(game.balance)}',
            bold: true,
          ),
          const SizedBox(width: 6),

          // GARAJ STOK Pill
          _buildPill(
            icon: Icons.directions_car_rounded,
            iconColor: Colors.blue.shade700,
            label: 'GARAJ ${game.ownedCars.length}/${game.maxGarageSlots}',
          ),
          const SizedBox(width: 6),

          // İTİBAR Pill
          _buildPill(
            icon: Icons.star_rounded,
            iconColor: Colors.amber.shade600,
            label: 'İTİBAR ${game.reputationScore.toStringAsFixed(1)}',
          ),
          const SizedBox(width: 6),

          // GÖREV Pill
          _buildPill(
            icon: Icons.assignment_turned_in_rounded,
            iconColor: Colors.purple.shade600,
            label: 'GÖREV 0/15',
          ),
          const SizedBox(width: 10),

          // Red Action Pill Button: Araç Al (Pazaryeri)
          _buildRedActionPill(
            context,
            icon: Icons.shopping_bag_rounded,
            label: 'Araç Al',
            onTap: () => context.push('/marketplace'),
          ),
          const SizedBox(width: 6),

          // Red Action Pill Button: İnşaat / Şube
          _buildRedActionPill(
            context,
            icon: Icons.domain_rounded,
            label: 'İnşaat / Şube',
            onTap: () => context.push('/branches'),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required Color iconColor,
    required String label,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.beneloilPillBg,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w900 : FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRedActionPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.beneloilRed,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
