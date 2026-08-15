import 'package:flutter/material.dart';

/// Neo-Brutalist Tag / Badge Widget
/// Compact monolithic pill with crisp borders and high-contrast styling.
class NeoBrutalBadge extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const NeoBrutalBadge({
    super.key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 1.5,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.fontSize = 11.0,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ??
        (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9));
    final effectiveText = textColor ??
        (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));
    final effectiveBorder = borderColor ??
        (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A));

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: effectiveText),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: effectiveText,
              fontSize: fontSize,
              fontWeight: fontWeight,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
