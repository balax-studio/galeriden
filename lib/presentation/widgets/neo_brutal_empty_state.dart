import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../core/theme/app_typography.dart';
import 'neo_brutal_button.dart';

/// Reusable Neo-Brutalist Empty State view with thematic badge, icon, description, and call to action.
class NeoBrutalEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? badgeText;
  final Color? badgeColor;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onActionPressed;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;

  const NeoBrutalEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.badgeText,
    this.badgeColor,
    this.actionLabel,
    this.actionIcon,
    this.onActionPressed,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final isDark = p?.isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final effectiveAccent = accentColor ?? p?.primaryColor ?? AppColors.brutalYellow;
    final borderColor = isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A);

    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Illustration Box with Neo-Brutalist Hard Shadow
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: effectiveAccent.withValues(alpha: isDark ? 0.25 : 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black54 : Colors.black,
                    offset: const Offset(3.5, 3.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 40,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Optional Badge
            if (badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (badgeColor ?? effectiveAccent).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: badgeColor ?? effectiveAccent,
                    width: 1.4,
                  ),
                ),
                child: Text(
                  badgeText!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            // Description
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium(isDark).copyWith(
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),
            ),

            // Action Button
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, minHeight: 48),
                child: NeoBrutalButton(
                  label: actionLabel!,
                  icon: actionIcon ?? Icons.arrow_forward_rounded,
                  backgroundColor: effectiveAccent,
                  textColor: Colors.black,
                  fontSize: 13,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onActionPressed!();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
