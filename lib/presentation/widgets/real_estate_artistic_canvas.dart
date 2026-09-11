import 'dart:math';
import 'package:flutter/material.dart';

/// Topografik Kot ve Harita İzohips Eğrileri Prosedürel Ressamı
/// (Topographic Elevation Contour Lines - Çizgisel harita & arsa tesviye kotları)
class TopographicContourPainter extends CustomPainter {
  final Color strokeColor;
  final double strokeWidth;
  final int contourCount;
  final bool isDark;

  const TopographicContourPainter({
    required this.strokeColor,
    this.strokeWidth = 1.0,
    this.contourCount = 5,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final basePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final indexPaint = Paint()
      ..color = strokeColor.withValues(alpha: strokeColor.a * 1.5)
      ..strokeWidth = strokeWidth * 1.6
      ..style = PaintingStyle.stroke;

    final textStyle = TextStyle(
      fontSize: 8.0,
      fontWeight: FontWeight.w700,
      fontFamily: 'monospace',
      color: strokeColor.withValues(alpha: strokeColor.a * 1.8),
    );

    final w = size.width;
    final h = size.height;

    for (int i = 0; i < contourCount; i++) {
      final t = (i + 1) / (contourCount + 1);
      final isIndexLine = i % 2 == 0;
      final currentPaint = isIndexLine ? indexPaint : basePaint;

      final path = Path();
      final baseY = h * (0.15 + t * 0.70);

      path.moveTo(0, baseY);

      // Trigonometrik akışkan topografya eğrisi
      final wave1 = 12.0 * sin(t * pi * 2);
      final wave2 = 18.0 * cos((1 - t) * pi);
      final wave3 = 8.0 * sin(t * pi * 3);

      final cp1x = w * 0.25;
      final cp1y = baseY - wave1;
      final cp2x = w * 0.50;
      final cp2y = baseY + wave2;
      final cp3x = w * 0.75;
      final cp3y = baseY - wave3;
      final endX = w;
      final endY = baseY + (wave1 * 0.5);

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, cp3x, cp3y);
      path.lineTo(endX, endY);

      canvas.drawPath(path, currentPaint);

      // İndeks eğrilerinde kot etiketleri (Örnek: +14.5m)
      if (isIndexLine && w > 140) {
        final elevation = (10.0 + (i * 2.5)).toStringAsFixed(1);
        final label = '+$elevation m';
        final textSpan = TextSpan(text: label, style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        final labelX = w * (0.60 + (i * 0.08) % 0.25);
        final labelY = (baseY - wave3 * 0.5) - 10;
        textPainter.paint(canvas, Offset(labelX, labelY.clamp(2.0, h - 14.0)));
      }
    }
  }

  @override
  bool shouldRepaint(covariant TopographicContourPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.contourCount != contourCount ||
        oldDelegate.isDark != isDark;
  }
}

/// Şantiye Telsizi Osiloskop & Ses Frekans Dalgası Ressamı
/// (Site Radio Acoustic Waveform Visualizer)
class RadioWaveformPainter extends CustomPainter {
  final Color primaryWaveColor;
  final Color secondaryWaveColor;
  final double phase;

  const RadioWaveformPainter({
    required this.primaryWaveColor,
    required this.secondaryWaveColor,
    this.phase = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final primaryPaint = Paint()
      ..color = primaryWaveColor
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final secondaryPaint = Paint()
      ..color = secondaryWaveColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;
    final w = size.width;

    final primaryPath = Path();
    final secondaryPath = Path();

    primaryPath.moveTo(0, midY);
    secondaryPath.moveTo(0, midY);

    const step = 4.0;
    for (double x = 0; x <= w; x += step) {
      final normalizedX = x / w;
      // Dış kenarlarda sönümlenen gaussian zarfı
      final envelope = sin(normalizedX * pi);

      final y1 = midY +
          sin(normalizedX * 14 * pi + phase) * 8.0 * envelope +
          cos(normalizedX * 28 * pi + phase * 1.5) * 3.0 * envelope;

      final y2 = midY +
          cos(normalizedX * 18 * pi - phase) * 5.0 * envelope +
          sin(normalizedX * 8 * pi + phase * 0.8) * 4.0 * envelope;

      primaryPath.lineTo(x, y1);
      secondaryPath.lineTo(x, y2);
    }

    canvas.drawPath(secondaryPath, secondaryPaint);
    canvas.drawPath(primaryPath, primaryPaint);
  }

  @override
  bool shouldRepaint(covariant RadioWaveformPainter oldDelegate) {
    return oldDelegate.primaryWaveColor != primaryWaveColor ||
        oldDelegate.secondaryWaveColor != secondaryWaveColor ||
        oldDelegate.phase != phase;
  }
}

/// İnşaat Şantiye Telsizi Canlı Frekans Göstergesi
class SiteRadioWaveformWidget extends StatefulWidget {
  final double height;
  final bool isDark;

  const SiteRadioWaveformWidget({
    super.key,
    this.height = 32,
    this.isDark = false,
  });

  @override
  State<SiteRadioWaveformWidget> createState() => _SiteRadioWaveformWidgetState();
}

class _SiteRadioWaveformWidgetState extends State<SiteRadioWaveformWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(
            painter: RadioWaveformPainter(
              primaryWaveColor: widget.isDark
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.85)
                  : const Color(0xFFD97706).withValues(alpha: 0.90),
              secondaryWaveColor: widget.isDark
                  ? const Color(0xFF38BDF8).withValues(alpha: 0.40)
                  : const Color(0xFF2563EB).withValues(alpha: 0.35),
              phase: _controller.value * pi * 2,
            ),
          ),
        );
      },
    );
  }
}

/// Lazer Nivo & Teodolit Kalibrasyon Hattı (Laser Leveling Alignment Beam)
class LaserLevelLineWidget extends StatelessWidget {
  final String label;
  final bool isDark;

  const LaserLevelLineWidget({
    super.key,
    this.label = 'LAZER NİVO KOT: 0.00',
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final laserColor = isDark ? const Color(0xFF10B981) : const Color(0xFF059669);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: laserColor.withValues(alpha: 0.15),
              border: Border.all(color: laserColor, width: 1.0),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.gps_fixed_rounded, size: 10, color: laserColor),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                    color: laserColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    laserColor.withValues(alpha: 0.8),
                    laserColor.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Taktil Neo-Brutalist Şantiye ve Ruhsat Mührü (Industrial Rubber Stamp)
class NeoBrutalStampWidget extends StatelessWidget {
  final String text;
  final Color stampColor;
  final double angle;

  const NeoBrutalStampWidget({
    super.key,
    required this.text,
    this.stampColor = const Color(0xFFDC2626),
    this.angle = -0.08,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: stampColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: stampColor, width: 2.0),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(color: stampColor.withValues(alpha: 0.6), width: 1.0),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: 9.0,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: stampColor,
            ),
          ),
        ),
      ),
    );
  }
}
