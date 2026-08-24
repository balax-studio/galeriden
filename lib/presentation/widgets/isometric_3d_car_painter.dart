import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Multi-Angle 3D Volumetric Metallic Isometric Car Painter
/// Renders 3D metallic bodies with custom paint colors, chrome highlights,
/// LED headlight glow, glass reflections, and kaporta damage overlays.
class Isometric3DCarPainter extends CustomPainter {
  final Color bodyColor;
  final String category; // sedan, suv, sport, classic, electric
  final double damagePercent; // 0 to 100
  final bool isHeadlightOn;
  final double animationProgress;

  Isometric3DCarPainter({
    required this.bodyColor,
    this.category = 'sedan',
    this.damagePercent = 0,
    this.isHeadlightOn = true,
    this.animationProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scale = size.width / 100.0;

    // 1. Vehicle Drop Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    final shadowPath = Path()
      ..addOval(Rect.fromCenter(
          center: center + Offset(0, 18 * scale),
          width: 75 * scale,
          height: 35 * scale));
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Headlight Beam Reflection (Isometric Forward Left)
    if (isHeadlightOn) {
      final beamPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            AppColors.primaryAmber.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(
            center.dx - 60 * scale, center.dy, 45 * scale, 30 * scale));

      final beamPath = Path()
        ..moveTo(center.dx - 15 * scale, center.dy + 8 * scale)
        ..lineTo(center.dx - 55 * scale, center.dy + 25 * scale)
        ..lineTo(center.dx - 45 * scale, center.dy - 5 * scale)
        ..close();
      canvas.drawPath(beamPath, beamPaint);
    }

    // 3. Volumetric 3D Car Body Base Colors
    Color topColor = bodyColor;
    Color sideColor = HSLColor.fromColor(bodyColor)
        .withLightness(
            math.max(0.1, HSLColor.fromColor(bodyColor).lightness - 0.15))
        .toColor();
    Color frontColor = HSLColor.fromColor(bodyColor)
        .withLightness(
            math.max(0.05, HSLColor.fromColor(bodyColor).lightness - 0.25))
        .toColor();

    // 4. Side Face (Isometric Right-Down)
    final sidePath = Path()
      ..moveTo(center.dx - 5 * scale, center.dy - 12 * scale)
      ..lineTo(center.dx + 28 * scale, center.dy + 5 * scale)
      ..lineTo(center.dx + 25 * scale, center.dy + 18 * scale)
      ..lineTo(center.dx - 8 * scale, center.dy + 2 * scale)
      ..close();
    canvas.drawPath(sidePath, Paint()..color = sideColor);

    // 5. Front Face (Isometric Left-Down)
    final frontPath = Path()
      ..moveTo(center.dx - 28 * scale, center.dy + 2 * scale)
      ..lineTo(center.dx - 5 * scale, center.dy + 16 * scale)
      ..lineTo(center.dx - 8 * scale, center.dy + 22 * scale)
      ..lineTo(center.dx - 30 * scale, center.dy + 8 * scale)
      ..close();
    canvas.drawPath(frontPath, Paint()..color = frontColor);

    // 6. Roof & Hood Top Face (Isometric Top Sheen)
    final topPath = Path()
      ..moveTo(center.dx - 12 * scale, center.dy - 22 * scale)
      ..lineTo(center.dx + 15 * scale, center.dy - 8 * scale)
      ..lineTo(center.dx - 5 * scale, center.dy + 16 * scale)
      ..lineTo(center.dx - 28 * scale, center.dy + 2 * scale)
      ..close();

    final metallicGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        topColor,
        HSLColor.fromColor(topColor)
            .withLightness(
                math.min(0.9, HSLColor.fromColor(topColor).lightness + 0.2))
            .toColor(),
        topColor,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawPath(
        topPath,
        Paint()
          ..shader = metallicGradient.createShader(Rect.fromLTWH(
              center.dx - 30 * scale,
              center.dy - 25 * scale,
              50 * scale,
              45 * scale)));

    // 7. Glass Windows (Cyan Obsidian Tint)
    final windshieldPath = Path()
      ..moveTo(center.dx - 10 * scale, center.dy - 14 * scale)
      ..lineTo(center.dx + 5 * scale, center.dy - 6 * scale)
      ..lineTo(center.dx - 3 * scale, center.dy + 2 * scale)
      ..lineTo(center.dx - 18 * scale, center.dy - 6 * scale)
      ..close();
    final glassPaint = Paint()
      ..color = const Color(0xFF0F2B48).withValues(alpha: 0.85);
    canvas.drawPath(windshieldPath, glassPaint);

    // 8. Wheels (3D Isometric Cylinder Rims)
    final wheelPaint = Paint()..color = const Color(0xFF1E2430);
    final rimPaint = Paint()..color = AppColors.primaryAmber;

    // Front-Left Wheel
    canvas.drawCircle(
        center + Offset(-18 * scale, 16 * scale), 5 * scale, wheelPaint);
    canvas.drawCircle(
        center + Offset(-18 * scale, 16 * scale), 2.5 * scale, rimPaint);

    // Rear-Left Wheel
    canvas.drawCircle(
        center + Offset(15 * scale, 14 * scale), 5 * scale, wheelPaint);
    canvas.drawCircle(
        center + Offset(15 * scale, 14 * scale), 2.5 * scale, rimPaint);

    // 9. Kaporta Damage Scratch Layer (if damaged)
    if (damagePercent > 20) {
      final scratchPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center + Offset(-10 * scale, 0),
          center + Offset(-2 * scale, 8 * scale), scratchPaint);
      if (damagePercent > 50) {
        canvas.drawLine(center + Offset(2 * scale, -5 * scale),
            center + Offset(12 * scale, 2 * scale), scratchPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant Isometric3DCarPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.category != category ||
        oldDelegate.damagePercent != damagePercent ||
        oldDelegate.isHeadlightOn != isHeadlightOn ||
        oldDelegate.animationProgress != animationProgress;
  }
}
