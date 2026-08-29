import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom curve that accelerates quickly through the first 50%
/// and decelerates as it approaches 100% to generate the psychological
/// Zeigarnik (Goal Gradient) effect.
class ZeigarnikProgressCurve extends Curve {
  const ZeigarnikProgressCurve();

  @override
  double transformInternal(double t) {
    if (t <= 0.0) return 0.0;
    if (t >= 1.0) return 1.0;
    // Accelerated initial leap (0 -> 0.5), decelerating glide (0.5 -> 1.0)
    if (t < 0.5) {
      // Quad ease-out for fast early gratification
      final subT = t * 2.0;
      return 0.5 * (1.0 - (1.0 - subT) * (1.0 - subT));
    } else {
      // Cubic ease-out for prolonged near-completion tension
      final subT = (t - 0.5) * 2.0;
      return 0.5 + 0.5 * (1.0 - math.pow(1.0 - subT, 3).toDouble());
    }
  }
}

/// Neo-Brutalist Zeigarnik Progress Bar (Hazard & Industrial Stripe Capable)
class ZeigarnikProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final Duration animationDuration;
  final bool isHazardStriped;
  final Color? stripeColor;

  const ZeigarnikProgressBar({
    super.key,
    required this.progress,
    this.height = 12.0,
    required this.fillColor,
    required this.backgroundColor,
    this.borderColor = const Color(0xFF0F172A),
    this.borderWidth = 1.6,
    this.borderRadius = 6.0,
    this.animationDuration = const Duration(milliseconds: 900),
    this.isHazardStriped = false,
    this.stripeColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(math.max(0, borderRadius - 1)),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: clampedProgress),
          duration: animationDuration,
          curve: const ZeigarnikProgressCurve(),
          builder: (context, animatedValue, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: animatedValue,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius:
                          BorderRadius.circular(math.max(0, borderRadius - 2)),
                    ),
                  ),
                  if (isHazardStriped)
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(math.max(0, borderRadius - 2)),
                      child: CustomPaint(
                        painter: _HazardStripePainter(
                          stripeColor: stripeColor ??
                              Colors.black.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HazardStripePainter extends CustomPainter {
  final Color stripeColor;

  const _HazardStripePainter({
    required this.stripeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double stripeWidth = 3.5;
    const double gap = 3.5;
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = stripeWidth
      ..style = PaintingStyle.stroke;

    const total = stripeWidth + gap;
    final maxDist = size.width + size.height;
    for (double x = -size.height; x < maxDist; x += total) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HazardStripePainter oldDelegate) {
    return oldDelegate.stripeColor != stripeColor;
  }
}
