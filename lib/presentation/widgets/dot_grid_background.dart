import 'package:flutter/material.dart';

/// Engineering Blueprint Dot-Grid Background Widget
/// Adds a subtle, high-performance matrix of technical dots across container backgrounds.
class DotGridBackground extends StatelessWidget {
  final Widget child;
  final Color? dotColor;
  final double spacing;
  final double dotRadius;

  const DotGridBackground({
    super.key,
    required this.child,
    this.dotColor,
    this.spacing = 16.0,
    this.dotRadius = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveDotColor = dotColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05));

    return RepaintBoundary(
      child: CustomPaint(
        isComplex: true,
        willChange: false,
        painter: _DotGridPainter(
          dotColor: effectiveDotColor,
          spacing: spacing,
          dotRadius: dotRadius,
        ),
        child: child,
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double dotRadius;

  _DotGridPainter({
    required this.dotColor,
    required this.spacing,
    required this.dotRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor ||
      oldDelegate.spacing != spacing ||
      oldDelegate.dotRadius != dotRadius;
}
