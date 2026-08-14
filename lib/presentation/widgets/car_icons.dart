import 'package:flutter/material.dart';
import 'isometric_3d_car_painter.dart';

class CarSilhouetteWidget extends StatelessWidget {
  final String bodyType;
  final Color color;
  final double width;
  final double height;
  final bool showBackgroundPod;

  const CarSilhouetteWidget({
    super.key,
    required this.bodyType,
    required this.color,
    this.width = 72.0,
    this.height = 36.0,
    this.showBackgroundPod = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color == Colors.transparent ? Colors.cyanAccent : color;
    
    Widget content = CustomPaint(
      size: Size(width, height),
      painter: Isometric3DCarPainter(
        bodyColor: effectiveColor,
        category: bodyType,
        isHeadlightOn: true,
      ),
    );

    if (!showBackgroundPod) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveColor.withValues(alpha: 0.25),
            effectiveColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: content,
    );
  }
}

