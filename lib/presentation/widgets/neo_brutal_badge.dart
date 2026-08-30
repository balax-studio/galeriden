import 'package:flutter/material.dart';

/// Neo-Brutalist Tag / Badge Widget (Maximalist Industrial Edition)
/// Compact monolithic pill with crisp borders, optional sticker tilt, and hard offset shadow.
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
  final double angle;
  final bool showHardShadow;
  final Offset shadowOffset;

  const NeoBrutalBadge({
    super.key,
    String? text,
    String? label,
    this.icon,
    Color? backgroundColor,
    Color? color,
    this.textColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 6.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
    this.fontSize = 11.0,
    this.fontWeight = FontWeight.w800,
    this.angle = 0.0,
    this.showHardShadow = false,
    this.shadowOffset = const Offset(2.0, 2.0),
  })  : text = text ?? label ?? '',
        backgroundColor = backgroundColor ?? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = backgroundColor ??
        (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9));
    final effectiveText = textColor ??
        (isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A));
    final effectiveBorder = borderColor ??
        (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A));

    Widget badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: effectiveBorder,
          width: borderWidth,
        ),
        boxShadow: showHardShadow
            ? [
                BoxShadow(
                  color: isDark ? Colors.black : const Color(0xFF0F172A),
                  offset: shadowOffset,
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: icon == null
          ? Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: effectiveText,
                fontSize: fontSize,
                fontWeight: fontWeight,
                letterSpacing: 0.3,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: fontSize + 2, color: effectiveText),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: effectiveText,
                      fontSize: fontSize,
                      fontWeight: fontWeight,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
    );

    if (angle != 0.0) {
      badge = Transform.rotate(
        angle: angle,
        child: badge,
      );
    }

    return badge;
  }
}
