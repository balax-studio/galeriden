import 'package:flutter/material.dart';

/// Industrial 45-degree Hazard Safety Stripe Widget & CustomPainter
/// Used for urgency indicators, bargain banners, night market alerts, and workshop status bars.
class HazardStripeWidget extends StatelessWidget {
  final double height;
  final double? width;
  final Color color1;
  final Color color2;
  final double stripeWidth;
  final BorderRadius? borderRadius;
  final Border? border;
  final Widget? child;

  const HazardStripeWidget({
    super.key,
    this.height = 10.0,
    this.width,
    this.color1 = const Color(0xFFE5C158),
    this.color2 = const Color(0xFF0F172A),
    this.stripeWidth = 10.0,
    this.borderRadius,
    this.border,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: CustomPaint(
        painter: HazardStripePainter(
          color1: color1,
          color2: color2,
          stripeWidth: stripeWidth,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );

    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius!,
        child: content,
      );
    }

    if (border != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          border: border,
          borderRadius: borderRadius,
        ),
        child: content,
      );
    }

    return content;
  }
}

class HazardStripePainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double stripeWidth;

  HazardStripePainter({
    required this.color1,
    required this.color2,
    required this.stripeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint1);

    final path = Path();
    final totalWidth = size.width;
    final totalHeight = size.height;
    final step = stripeWidth * 2;

    for (double x = -totalHeight; x < totalWidth + totalHeight; x += step) {
      path.moveTo(x, totalHeight);
      path.lineTo(x + stripeWidth, totalHeight);
      path.lineTo(x + stripeWidth + totalHeight, 0);
      path.lineTo(x + totalHeight, 0);
      path.close();
    }

    canvas.drawPath(path, paint2);
  }

  @override
  bool shouldRepaint(covariant HazardStripePainter oldDelegate) =>
      oldDelegate.color1 != color1 ||
      oldDelegate.color2 != color2 ||
      oldDelegate.stripeWidth != stripeWidth;
}
