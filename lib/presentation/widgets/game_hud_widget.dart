import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../providers/game_provider.dart';
import 'app_glass_container.dart';
import 'app_vector_icons.dart';

/// Floating Game HUD overlay widget
class GameHudHeaderWidget extends ConsumerWidget {
  const GameHudHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: p.surfaceColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.15),
            blurRadius: 14,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dealership Emblem & Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: p.primaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: p.primaryColor, width: 1.5),
                ),
                child: VectorIconWidget(
                  type: game.logoEmblemId,
                  color: p.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.dealershipName,
                    style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.arcadeGold, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${game.reputationScore} İtibar',
                        style: const TextStyle(color: AppColors.arcadeGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Cash Balance Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.laserGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.laserGreen.withValues(alpha: 0.6), width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet_rounded, color: AppColors.laserGreen, size: 16),
                const SizedBox(width: 6),
                Text(
                  CurrencyFormatter.formatShort(game.balance),
                  style: AppTypography.moneyMedium(p.isDark).copyWith(
                    fontSize: 14,
                    color: AppColors.laserGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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
