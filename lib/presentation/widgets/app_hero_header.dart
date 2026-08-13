import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../data/models/dealership_model.dart';
import 'app_animated_counter.dart';
import 'app_vector_icons.dart';

/// Ultra-Premium Automotive Luxury Hero Header & HUD Bar
class AppHeroHeader extends StatelessWidget {
  final DealershipModel game;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap;

  const AppHeroHeader({
    super.key,
    required this.game,
    this.onSettingsTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceShellDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.primaryAmber.withValues(alpha: 0.25) : AppColors.surfaceBorderLight,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Row: Brand & Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onProfileTap,
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryAmber.withValues(alpha: 0.4),
                            width: 1.0,
                          ),
                        ),
                        child: VectorIconWidget(
                          type: game.logoEmblemId,
                          color: AppColors.primaryAmber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.dealershipName.toUpperCase(),
                            style: AppTypography.titleLarge(isDark).copyWith(
                              fontSize: 15,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'SEVİYE ${game.level} • YETENEKLER & PROFİL ›',
                            style: AppTypography.labelSmall(isDark).copyWith(
                              fontSize: 9,
                              color: AppColors.primaryAmber,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.tune_rounded, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, size: 22),
                  onPressed: onSettingsTap,
                  splashRadius: 20,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Bottom Row: Luxury HUD Gauges (Cash Counter & Status Indicators)
            Row(
              children: [
                // Cash Counter Badge
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.successGreen.withValues(alpha: 0.4),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.successGreen, size: 16),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KASA BAKİYESİ',
                                style: AppTypography.labelSmall(isDark).copyWith(fontSize: 9, letterSpacing: 0.8),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: AppAnimatedCounter(
                                  value: game.balance,
                                  style: AppTypography.moneyMedium(isDark).copyWith(
                                    color: AppColors.successGreen,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Garage Capacity Gauge
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primaryAmber.withValues(alpha: 0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car_filled_rounded, color: AppColors.primaryAmber, size: 16),
                        const SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('GARAJ', style: AppTypography.labelSmall(isDark).copyWith(fontSize: 8)),
                            Text(
                              '${game.ownedCars.length}/${game.maxGarageSlots}',
                              style: AppTypography.statValue(isDark).copyWith(fontSize: 14, color: AppColors.primaryAmber),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),

                // Reputation Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.primaryAmber.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.primaryAmber, size: 18),
                      const SizedBox(width: 2),
                      Text(
                        '%${game.reputationScore}',
                        style: AppTypography.statValue(isDark).copyWith(fontSize: 14, color: AppColors.primaryAmber),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
