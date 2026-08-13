import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme_extension.dart';

/// Double-Bezel (Doppelrand) Hardware Architecture Container
/// Provides physical tactile depth like a luxury watch or titanium chassis.
class AppDoubleBezelCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? accentColor;
  final double outerRadius;
  final VoidCallback? onTap;

  const AppDoubleBezelCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.accentColor,
    this.outerRadius = 20.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final shellColor = isDark ? AppColors.surfaceShellDark : AppColors.surfaceBorderLight;
    final coreColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = accentColor?.withValues(alpha: 0.4) ?? (isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight);
    final innerRadius = outerRadius > 6 ? outerRadius - 6 : outerRadius;

    final cardContent = Container(
      margin: margin,
      padding: const EdgeInsets.all(AppSpacing.xs), // Shell padding
      decoration: BoxDecoration(
        color: shellColor,
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Container(
        padding: padding ?? const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: coreColor,
          borderRadius: BorderRadius.circular(innerRadius),
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    coreColor.withValues(alpha: 0.95),
                    coreColor,
                  ],
                )
              : null,
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(outerRadius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(outerRadius),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
