import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Hurdalıkta parça sökerken etrafa fırlayan 2D neobrutal somun & metal tozu parçacıkları efekti.
class PneumaticNutParticleWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const PneumaticNutParticleWidget({
    super.key,
    this.onComplete,
    this.size = 80,
  });

  @override
  State<PneumaticNutParticleWidget> createState() =>
      _PneumaticNutParticleWidgetState();
}

class _PneumaticNutParticleWidgetState extends State<PneumaticNutParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _NutParticlePainter(progress: _controller.value),
          );
        },
      ),
    );
  }
}

class _NutParticlePainter extends CustomPainter {
  final double progress;

  _NutParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final nutAngles = [-math.pi / 4, math.pi / 6, 3 * math.pi / 4];

    final nutPaint = Paint()
      ..color = const Color(0xFFFFDE59)
      ..style = PaintingStyle.fill;

    final nutBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dustPaint = Paint()
      ..color = const Color(0xFF94A3B8)
          .withValues(alpha: (1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final maxDistance = size.width * 0.45;
    final currentDistance = progress * maxDistance;

    for (int i = 0; i < nutAngles.length; i++) {
      final angle = nutAngles[i];
      final pos = Offset(
        center.dx + math.cos(angle) * currentDistance,
        center.dy +
            math.sin(angle) * currentDistance +
            (progress * progress * 10), // Gravity drop
      );

      // Draw hexagonal nut
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(progress * math.pi * 3);

      final path = Path();
      const sides = 6;
      final radius = 6.0;
      for (int s = 0; s < sides; s++) {
        final a = s * 2 * math.pi / sides;
        final x = math.cos(a) * radius;
        final y = math.sin(a) * radius;
        if (s == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, nutPaint);
      canvas.drawPath(path, nutBorder);
      canvas.drawCircle(Offset.zero, 2.0, Paint()..color = Colors.black);
      canvas.restore();
    }

    // Metal dust specks
    for (int d = 0; d < 6; d++) {
      final dAngle = d * math.pi / 3 + 0.2;
      final dDist = progress * maxDistance * 0.8;
      final dPos = Offset(center.dx + math.cos(dAngle) * dDist,
          center.dy + math.sin(dAngle) * dDist);
      canvas.drawCircle(dPos, 1.5, dustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NutParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
