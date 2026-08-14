import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// CustomPainter for rendering a cinematic city skyline with parallax depth,
/// time-of-day sky transitions (day/sunset/night), glowing skyscraper windows, and atmospheric horizon glow.
class ParallaxSkylinePainter extends CustomPainter {
  final Offset cameraOffset;
  final double parallaxFactor;
  final int hour;

  ParallaxSkylinePainter({
    required this.cameraOffset,
    this.parallaxFactor = 0.25,
    this.hour = 21,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isDay = hour >= 7 && hour < 17;
    final isSunset = hour >= 17 && hour < 20;

    // 1. Base Sky Gradient depending on in-game time
    final skyRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final List<Color> skyColors;
    if (isDay) {
      skyColors = [
        const Color(0xFF1E3A8A), // Deep Sky Blue
        const Color(0xFF3B82F6), // Azure Blue
        const Color(0xFF93C5FD), // Soft Horizon Blue
      ];
    } else if (isSunset) {
      skyColors = [
        const Color(0xFF311042), // Deep Sunset Violet
        const Color(0xFF831843), // Crimson Magenta
        const Color(0xFFF97316), // Golden Sunset Amber
      ];
    } else {
      skyColors = [
        const Color(0xFF030508), // Obsidian Night
        const Color(0xFF0A0F1A), // Deep Midnight Navy
        const Color(0xFF141A29), // Horizon Slate
      ];
    }

    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: skyColors,
    );
    canvas.drawRect(skyRect, Paint()..shader = skyGradient.createShader(skyRect));

    // Parallax Shift offset
    final shiftedX = cameraOffset.dx * parallaxFactor;

    // 2. Distant Skyscraper Silhouette Layer (Slower parallax)
    final distantColor = isDay
        ? const Color(0xFF1E293B).withValues(alpha: 0.85)
        : (isSunset ? const Color(0xFF26122F) : const Color(0xFF0E1320));
    final distantPaint = Paint()..color = distantColor;

    final windowColor = isDay
        ? Colors.white.withValues(alpha: 0.25)
        : (isSunset
            ? const Color(0xFFFDE047).withValues(alpha: 0.5)
            : AppColors.primaryAmber.withValues(alpha: 0.45));
    final windowPaint = Paint()..color = windowColor;

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

    // 3. Ambient Horizon Glow
    final glowColor = isDay
        ? Colors.white.withValues(alpha: 0.12)
        : (isSunset
            ? const Color(0xFFF97316).withValues(alpha: 0.2)
            : AppColors.primaryAmber.withValues(alpha: 0.08));

    final horizonGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          glowColor,
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3));
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.35, size.width, size.height * 0.3), horizonGlow);
  }

  @override
  bool shouldRepaint(covariant ParallaxSkylinePainter oldDelegate) {
    return oldDelegate.cameraOffset != cameraOffset ||
        oldDelegate.parallaxFactor != parallaxFactor ||
        oldDelegate.hour != hour;
  }
}

