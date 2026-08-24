import 'package:flutter/material.dart';

/// Neo-Brutalist Rubber Ink Stamp Widget
/// Simulates official automotive inspection & trade stamps ("BOYASIZ", "DEĞİŞENSİZ", "KELEPİR", "NOTER ONAYLI", "KOLEKSİYONDA", etc.)
class NeoBrutalStamp extends StatelessWidget {
  final String text;
  final Color color;
  final double angle;
  final double fontSize;
  final EdgeInsetsGeometry padding;
  final bool showDoubleBorder;

  const NeoBrutalStamp({
    super.key,
    required this.text,
    this.color = const Color(0xFFE61919),
    this.angle = -0.12,
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    this.showDoubleBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: showDoubleBorder
            ? BoxDecoration(
                border:
                    Border.all(color: color.withValues(alpha: 0.5), width: 1.0),
                borderRadius: BorderRadius.circular(4),
              )
            : null,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.2),
            borderRadius: BorderRadius.circular(3),
            color: color.withValues(alpha: 0.12),
          ),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: fontSize,
              letterSpacing: 1.4,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
    );
  }
}
