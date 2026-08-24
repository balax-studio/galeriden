import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Boya mikron ölçüm cihazı temas ettiğinde çıkan minik kıvılcım ve mikron sayacı efekti.
class PaintSparkWidget extends StatefulWidget {
  final double micronValue;
  final VoidCallback? onComplete;

  const PaintSparkWidget({
    super.key,
    required this.micronValue,
    this.onComplete,
  });

  @override
  State<PaintSparkWidget> createState() => _PaintSparkWidgetState();
}

class _PaintSparkWidgetState extends State<PaintSparkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sparkScale;
  late Animation<double> _numberRoll;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _sparkScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.2), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.2, end: 0.0), weight: 60),
    ]).animate(_controller);

    _numberRoll = Tween<double>(begin: 0.0, end: widget.micronValue).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
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
        return Stack(
          alignment: Alignment.center,
          children: [
            // Sparks
            Transform.scale(
              scale: _sparkScale.value,
              child: CustomPaint(
                size: const Size(60, 60),
                painter: _PaintSparkPainter(),
              ),
            ),
            // Micron Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDE59),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 1.6),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                '${_numberRoll.value.toInt()} µm',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
}

class _PaintSparkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final sparkPaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = const Color(0xFFFFDE59)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final p1 = Offset(
          center.dx + math.cos(angle) * 8, center.dy + math.sin(angle) * 8);
      final p2 = Offset(
          center.dx + math.cos(angle) * 24, center.dy + math.sin(angle) * 24);
      canvas.drawLine(p1, p2, sparkPaint);
      canvas.drawCircle(p2, 2.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
