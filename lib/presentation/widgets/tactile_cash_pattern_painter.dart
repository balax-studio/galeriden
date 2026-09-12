import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Prosedürel taktil esnaf banknot dokusu ve mikro dither örgü çizicisi
/// (£SPEC-2026-09-12-TACTILE-CASH-PATTERNS / generative-art-shaders)
/// GPU bütçesini tüketmeden zengin bir fiziksel para bereketi ve dokunsallık hissi sunar.
class TactileCashPatternOverlay extends StatelessWidget {
  final Widget? child;
  final double opacity;
  final Color primaryColor;
  final Color secondaryColor;
  final double waveSpacing;

  const TactileCashPatternOverlay({
    super.key,
    this.child,
    this.opacity = 0.12,
    this.primaryColor = AppColors.toxicLime,
    this.secondaryColor = AppColors.brutalYellow,
    this.waveSpacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _TactileCashPainter(
        opacity: opacity,
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
        waveSpacing: waveSpacing,
      ),
      child: child,
    );
  }
}

class _TactileCashPainter extends CustomPainter {
  final double opacity;
  final Color primaryColor;
  final Color secondaryColor;
  final double waveSpacing;

  final Paint _wavePaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.0;

  final Paint _dotPaint = Paint()..style = PaintingStyle.fill;

  _TactileCashPainter({
    required this.opacity,
    required this.primaryColor,
    required this.secondaryColor,
    required this.waveSpacing,
  }) {
    _wavePaint.color = primaryColor.withValues(alpha: opacity * 1.2);
    _dotPaint.color = secondaryColor.withValues(alpha: opacity * 0.8);
  }

  // 4x4 Bayer dither matrisi eşik değerleri
  static const List<double> _bayerMatrix = [
    0.0 / 16.0, 8.0 / 16.0, 2.0 / 16.0, 10.0 / 16.0,
    12.0 / 16.0, 4.0 / 16.0, 14.0 / 16.0, 6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0, 1.0 / 16.0, 9.0 / 16.0,
    15.0 / 16.0, 7.0 / 16.0, 13.0 / 16.0, 5.0 / 16.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Katman: Guilloché benzeri sinüs dalgaları (Banknot güvenlik filigranı)
    final path = Path();
    for (double y = 4; y < size.height; y += waveSpacing) {
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 12) {
        final waveY = y + math.sin((x / 16.0) + (y / 8.0)) * 2.5;
        path.lineTo(x, waveY);
      }
    }
    canvas.drawPath(path, _wavePaint);

    // 2. Katman: Mikro Bayer Dither Noktaları (Para lifi ve dokusu)
    int row = 0;
    for (double y = 0; y < size.height; y += 6.0) {
      int col = 0;
      for (double x = 0; x < size.width; x += 6.0) {
        final index = (row % 4) * 4 + (col % 4);
        if (_bayerMatrix[index] > 0.60) {
          canvas.drawRect(Rect.fromLTWH(x, y, 1.4, 1.4), _dotPaint);
        }
        col++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _TactileCashPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.waveSpacing != waveSpacing;
  }
}
