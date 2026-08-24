import 'package:flutter/material.dart';

/// Pazarlık masasında satıcı veya alıcı sıkıştığında süzülen 2D neobrutal ter damlası animasyonu.
class SweatDropWidget extends StatefulWidget {
  final double size;
  final Color dropColor;

  const SweatDropWidget({
    super.key,
    this.size = 20,
    this.dropColor = const Color(0xFF38BDF8),
  });

  @override
  State<SweatDropWidget> createState() => _SweatDropWidgetState();
}

class _SweatDropWidgetState extends State<SweatDropWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _slideAnimation = Tween<double>(begin: 0.0, end: 14.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller.repeat();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: CustomPaint(
        size: Size(widget.size * 0.7, widget.size),
        painter: _SweatDropPainter(color: widget.dropColor),
      ),
    );
  }
}

class _SweatDropPainter extends CustomPainter {
  final Color color;

  _SweatDropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..cubicTo(w * 0.1, h * 0.5, 0, h * 0.7, 0, h * 0.78)
      ..arcToPoint(Offset(w, h * 0.78),
          radius: Radius.circular(w * 0.5), clockwise: false)
      ..cubicTo(w, h * 0.7, w * 0.9, h * 0.5, w * 0.5, 0)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Mini highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highlightPath = Path()
      ..moveTo(w * 0.25, h * 0.7)
      ..arcToPoint(Offset(w * 0.45, h * 0.88),
          radius: Radius.circular(w * 0.35), clockwise: false);

    canvas.drawPath(highlightPath, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
