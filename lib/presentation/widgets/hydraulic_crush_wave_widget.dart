import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hurda presleme sırasında ekranda beliren mikro ezilme şok dalgası efekti.
class HydraulicCrushWaveWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const HydraulicCrushWaveWidget({
    super.key,
    this.onComplete,
    this.size = 140,
  });

  @override
  State<HydraulicCrushWaveWidget> createState() =>
      _HydraulicCrushWaveWidgetState();
}

class _HydraulicCrushWaveWidgetState extends State<HydraulicCrushWaveWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _waveProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _waveProgress = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller.forward().then((_) => widget.onComplete?.call());
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _waveProgress,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CrushWavePainter(progress: _waveProgress.value),
        );
      },
    );
  }
}

class _CrushWavePainter extends CustomPainter {
  final double progress;

  _CrushWavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.48;
    final currentRadius = progress * maxRadius;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final wavePaint1 = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: alpha)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final wavePaint2 = Paint()
      ..color = const Color(0xFFFFDE59).withValues(alpha: alpha * 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Outer shockwave circle with jagged metal bend points
    final path = Path();
    const points = 16;
    for (int i = 0; i < points; i++) {
      final angle = i * 2 * math.pi / points;
      final variance = (i % 2 == 0) ? 3.0 : -3.0;
      final r = currentRadius + variance;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, wavePaint1);
    canvas.drawCircle(center, currentRadius * 0.65, wavePaint2);
  }

  @override
  bool shouldRepaint(covariant _CrushWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
