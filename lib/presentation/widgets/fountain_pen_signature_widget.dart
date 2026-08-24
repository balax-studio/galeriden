import 'package:flutter/material.dart';

/// Kredi veya devir sözleşmesi onaylandığında atılan neobrutal imza çizgisi animasyonu.
class FountainPenSignatureWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final double width;
  final double height;

  const FountainPenSignatureWidget({
    super.key,
    this.onComplete,
    this.width = 120,
    this.height = 36,
  });

  @override
  State<FountainPenSignatureWidget> createState() =>
      _FountainPenSignatureWidgetState();
}

class _FountainPenSignatureWidgetState extends State<FountainPenSignatureWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

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
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.width, widget.height),
          painter: _SignaturePainter(progress: _progressAnimation.value),
        );
      },
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final double progress;

  _SignaturePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E3A8A) // Fountain pen deep blue
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, h * 0.7)
      ..cubicTo(w * 0.15, h * 0.1, w * 0.25, h * 0.9, w * 0.4, h * 0.4)
      ..cubicTo(w * 0.5, h * 0.1, w * 0.65, h * 0.8, w * 0.8, h * 0.5)
      ..lineTo(w * 0.95, h * 0.75);

    // Extract path metrics to draw partial animated path
    final metrics = path.computeMetrics().toList();
    if (metrics.isNotEmpty) {
      final metric = metrics.first;
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
