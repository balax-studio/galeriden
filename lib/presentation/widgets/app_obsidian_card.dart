import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Minimalist Swiss Luxury Obsidian Card
/// Features deep obsidian background, 1px precision gold/platinum border,
/// subtle glass reflection, and tactile press animation.
class AppObsidianCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderRadius;
  final bool hasGoldGlow;

  const AppObsidianCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.borderRadius = AppRadius.lg,
    this.hasGoldGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? (hasGoldGlow ? AppColors.primaryAmber.withValues(alpha: 0.6) : AppColors.surfaceBorderDark);
    final effectiveBg = backgroundColor ?? AppColors.surfaceDark;

    Widget cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: hasGoldGlow ? AppColors.primaryAmber.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.4),
            blurRadius: hasGoldGlow ? 12.0 : 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: AppColors.primaryAmber.withValues(alpha: 0.1),
          highlightColor: AppColors.primaryAmber.withValues(alpha: 0.05),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
