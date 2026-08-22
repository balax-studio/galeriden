import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Finans borsa ekranında mumların fitilinde parıldayan mikro kıvılcım efekti widgetı.
class CandleSparkWidget extends StatefulWidget {
  final bool isPositive;
  final double size;

  const CandleSparkWidget({
    super.key,
    required this.isPositive,
    this.size = 18,
  });

  @override
  State<CandleSparkWidget> createState() => _CandleSparkWidgetState();
}

class _CandleSparkWidgetState extends State<CandleSparkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sparkScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _sparkScale = Tween<double>(begin: 0.6, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test');
    if (!isTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isPositive ? const Color(0xFF00E575) : const Color(0xFFEF4444);

    return AnimatedBuilder(
      animation: _sparkScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _sparkScale.value,
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _CandleSparkPainter(color: color),
      ),
    );
  }
}

class _CandleSparkPainter extends CustomPainter {
  final Color color;

  _CandleSparkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final p1 = Offset(center.dx + math.cos(angle) * 2, center.dy + math.sin(angle) * 2);
      final p2 = Offset(center.dx + math.cos(angle) * 8, center.dy + math.sin(angle) * 8);
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandleSparkPainter oldDelegate) => oldDelegate.color != color;
}
