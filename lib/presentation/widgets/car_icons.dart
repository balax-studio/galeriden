import 'package:flutter/material.dart';
import 'neo_brutal_car_vector_painter.dart';

class CarSilhouetteWidget extends StatelessWidget {
  final String bodyType;
  final Color color;
  final double width;
  final double height;
  final bool showBackgroundPod;
  final bool isClean;
  final bool isTuned;
  final double damagePercent;

  const CarSilhouetteWidget({
    super.key,
    required this.bodyType,
    required this.color,
    this.width = 64.0,
    this.height = 32.0,
    this.showBackgroundPod = false,
    this.isClean = false,
    this.isTuned = false,
    this.damagePercent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor =
        (color == Colors.transparent || color == Colors.black)
            ? (isDark ? const Color(0xFFFFDE59) : const Color(0xFFE11D48))
            : color;

    final Widget content = RepaintBoundary(
      child: CustomPaint(
        size: Size(width, height),
        isComplex: true,
        willChange: false,
        painter: NeoBrutalCarVectorPainter(
          bodyColor: effectiveColor,
          bodyType: bodyType,
          isClean: isClean,
          isTuned: isTuned,
          damagePercent: damagePercent,
          isDark: isDark,
        ),
      ),
    );

    if (!showBackgroundPod) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 1.8,
        ),
      ),
      child: content,
    );
  }
}
