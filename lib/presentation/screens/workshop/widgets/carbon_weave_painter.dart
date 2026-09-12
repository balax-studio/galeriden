import 'package:flutter/material.dart';

/// Generative art shader painter generating a carbon twill weave with CRT scanline raster
class CarbonWeavePainter extends CustomPainter {
  final Color accentColor;
  final Color baseColor;
  final double scanlineOpacity;
  final double weaveDensity;

  const CarbonWeavePainter({
    this.accentColor = const Color(0xFF00E5FF),
    this.baseColor = const Color(0xFF121418),
    this.scanlineOpacity = 0.08,
    this.weaveDensity = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = baseColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    final darkWeavePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final lightWeavePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final step = weaveDensity;

    // Diagonal twill weave pattern (45 degrees)
    for (double x = -size.height; x < size.width + size.height; x += step) {
      final isAccentWeave = ((x / step).round() % 6 == 0);
      final p = isAccentWeave
          ? (Paint()
            ..color = accentColor.withValues(alpha: 0.08)
            ..strokeWidth = 1.8
            ..style = PaintingStyle.stroke)
          : (((x / step).round() % 2 == 0) ? darkWeavePaint : lightWeavePaint);

      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        p,
      );
    }

    // Counter-diagonal interlacing weave
    for (double x = 0; x < size.width + size.height * 2; x += step * 2) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        darkWeavePaint,
      );
    }

    // CRT telemetry raster scanlines
    final scanlinePaint = Paint()
      ..color = Colors.black.withValues(alpha: scanlineOpacity)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 4.0) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scanlinePaint);
    }

    // Technical grid crosshairs in corners
    final crosshairPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.25)
      ..strokeWidth = 1.2;

    const crossSize = 8.0;
    // Top-left
    canvas.drawLine(const Offset(6, 6), const Offset(6 + crossSize, 6), crosshairPaint);
    canvas.drawLine(const Offset(6, 6), const Offset(6, 6 + crossSize), crosshairPaint);
    // Top-right
    canvas.drawLine(Offset(size.width - 6, 6), Offset(size.width - 6 - crossSize, 6), crosshairPaint);
    canvas.drawLine(Offset(size.width - 6, 6), Offset(size.width - 6, 6 + crossSize), crosshairPaint);
    // Bottom-left
    canvas.drawLine(Offset(6, size.height - 6), Offset(6 + crossSize, size.height - 6), crosshairPaint);
    canvas.drawLine(Offset(6, size.height - 6), Offset(6, size.height - 6 - crossSize), crosshairPaint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - 6, size.height - 6), Offset(size.width - 6 - crossSize, size.height - 6), crosshairPaint);
    canvas.drawLine(Offset(size.width - 6, size.height - 6), Offset(size.width - 6, size.height - 6 - crossSize), crosshairPaint);
  }

  @override
  bool shouldRepaint(covariant CarbonWeavePainter oldDelegate) {
    return oldDelegate.accentColor != accentColor ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.scanlineOpacity != scanlineOpacity ||
        oldDelegate.weaveDensity != weaveDensity;
  }
}
