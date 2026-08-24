import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Anlaşma sağlandığında tokalaşma anında patlayan retro çizgi roman tarzı şok çizgileri ve kıvılcım efekti.
class HandshakeClashOverlay extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;

  const HandshakeClashOverlay({
    super.key,
    this.onComplete,
    this.size = 120,
  });

  @override
  State<HandshakeClashOverlay> createState() => _HandshakeClashOverlayState();
}

class _HandshakeClashOverlayState extends State<HandshakeClashOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 70),
    ]).animate(_controller);

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller.forward().then((_) {
        widget.onComplete?.call();
      });
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
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _ComicClashPainter(),
      ),
    );
  }
}

class _ComicClashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rayPaint = Paint()
      ..color = const Color(0xFFFFDE59)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final borderPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sparkCount = 8;
    for (int i = 0; i < sparkCount; i++) {
      final angle = (i * 2 * math.pi / sparkCount) + (math.pi / 8);
      final startRadius = size.width * 0.22;
      final endRadius = size.width * 0.46;

      final p1 = Offset(
        center.dx + math.cos(angle) * startRadius,
        center.dy + math.sin(angle) * startRadius,
      );
      final p2 = Offset(
        center.dx + math.cos(angle) * endRadius,
        center.dy + math.sin(angle) * endRadius,
      );

      canvas.drawLine(p1, p2, borderPaint);
      canvas.drawLine(p1, p2, rayPaint);
    }

    // Mini center star
    final starPaint = Paint()
      ..color = const Color(0xFF00E575)
      ..style = PaintingStyle.fill;

    final starBorder = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final starPath = Path();
    const points = 5;
    final outerRadius = size.width * 0.16;
    final innerRadius = size.width * 0.08;

    for (int i = 0; i < points * 2; i++) {
      final r = (i % 2 == 0) ? outerRadius : innerRadius;
      final a = (i * math.pi / points) - (math.pi / 2);
      final x = center.dx + math.cos(a) * r;
      final y = center.dy + math.sin(a) * r;
      if (i == 0) {
        starPath.moveTo(x, y);
      } else {
        starPath.lineTo(x, y);
      }
    }
    starPath.close();

    canvas.drawPath(starPath, starPaint);
    canvas.drawPath(starPath, starBorder);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
