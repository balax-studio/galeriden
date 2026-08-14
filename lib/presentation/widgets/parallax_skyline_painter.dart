import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// CustomPainter for rendering a cinematic night city skyline with parallax depth,
/// glowing skyscraper windows, and atmospheric night gradients.
class ParallaxSkylinePainter extends CustomPainter {
  final Offset cameraOffset;
  final double parallaxFactor;

  ParallaxSkylinePainter({
    required this.cameraOffset,
    this.parallaxFactor = 0.25,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base Night Sky Gradient
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF030508),
        const Color(0xFF0A0F1A),
        const Color(0xFF141A29),
      ],
    );
    canvas.drawRect(skyRect, Paint()..shader = skyGradient.createShader(skyRect));

    // Parallax Shift offset
    final shiftedX = cameraOffset.dx * parallaxFactor;

    // 2. Distant Skyscraper Silhouette Layer (Slower parallax)
    final distantPaint = Paint()..color = const Color(0xFF0E1320);
    final windowPaint = Paint()..color = AppColors.primaryAmber.withValues(alpha: 0.35);

    double startX = (shiftedX % 120.0) - 120.0;
    while (startX < size.width + 120.0) {
      final buildingWidth = 55.0 + math.sin(startX) * 15.0;
      final buildingHeight = 160.0 + math.cos(startX * 0.5) * 60.0;
      final topY = size.height * 0.45 - buildingHeight;

      final rect = Rect.fromLTWH(startX, topY, buildingWidth, size.height - topY);
      canvas.drawRect(rect, distantPaint);

      // Glowing Windows
      for (double wy = topY + 15; wy < topY + buildingHeight - 20; wy += 18) {
        for (double wx = startX + 8; wx < startX + buildingWidth - 12; wx += 14) {
          if ((wx + wy).toInt() % 3 != 0) {
            canvas.drawRect(Rect.fromLTWH(wx, wy, 6, 8), windowPaint);
          }
        }
      }

      startX += buildingWidth + 15.0;
    }

    // 3. Ambient Gold Horizon Glow
    final horizonGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          AppColors.primaryAmber.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3), horizonGlow);
  }

  @override
  bool shouldRepaint(covariant ParallaxSkylinePainter oldDelegate) {
    return oldDelegate.cameraOffset != cameraOffset || oldDelegate.parallaxFactor != parallaxFactor;
  }
}
