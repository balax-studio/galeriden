import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Lightweight procedural canvas textures providing authentic tactile grit,
/// retro-futuristic CRT scanlines, Bayer matrix dithering, and neo-brutalist stamps
/// while preserving a strict 60/120 FPS GPU render budget.
class CrtScanlinesOverlay extends StatelessWidget {
  final Widget? child;
  final double opacity;
  final double lineSpacing;
  final Color? scanlineColor;

  const CrtScanlinesOverlay({
    super.key,
    this.child,
    this.opacity = 0.07,
    this.lineSpacing = 3.0,
    this.scanlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _CrtScanlinesPainter(
        opacity: opacity,
        lineSpacing: lineSpacing,
        scanlineColor: scanlineColor ?? Colors.black,
      ),
      child: child,
    );
  }
}

class _CrtScanlinesPainter extends CustomPainter {
  final double opacity;
  final double lineSpacing;
  final Color scanlineColor;
  final Paint _paint = Paint()..strokeWidth = 1.0;

  _CrtScanlinesPainter({
    required this.opacity,
    required this.lineSpacing,
    required this.scanlineColor,
  }) {
    _paint.color = scanlineColor.withValues(alpha: opacity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    for (double y = 0; y < size.height; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CrtScanlinesPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.lineSpacing != lineSpacing ||
        oldDelegate.scanlineColor != scanlineColor;
  }
}

/// Algorithmic 4x4 Bayer Matrix ordered dithering pattern for thermal paper,
/// receipts, and financial statements without diffuse gradients.
class BayerDitherOverlay extends StatelessWidget {
  final Widget? child;
  final double dotSize;
  final double spacing;
  final double opacity;
  final Color? ditherColor;

  const BayerDitherOverlay({
    super.key,
    this.child,
    this.dotSize = 1.2,
    this.spacing = 4.0,
    this.opacity = 0.08,
    this.ditherColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _BayerDitherPainter(
        dotSize: dotSize,
        spacing: spacing,
        opacity: opacity,
        ditherColor: ditherColor ?? Colors.black,
      ),
      child: child,
    );
  }
}

class _BayerDitherPainter extends CustomPainter {
  final double dotSize;
  final double spacing;
  final double opacity;
  final Color ditherColor;
  final Paint _dotPaint = Paint()..style = PaintingStyle.fill;

  _BayerDitherPainter({
    required this.dotSize,
    required this.spacing,
    required this.opacity,
    required this.ditherColor,
  }) {
    _dotPaint.color = ditherColor.withValues(alpha: opacity);
  }

  // 4x4 normalized Bayer matrix weights
  static const List<double> _bayer4x4 = [
    0.0 / 16.0, 8.0 / 16.0, 2.0 / 16.0, 10.0 / 16.0,
    12.0 / 16.0, 4.0 / 16.0, 14.0 / 16.0, 6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0, 1.0 / 16.0, 9.0 / 16.0,
    15.0 / 16.0, 7.0 / 16.0, 13.0 / 16.0, 5.0 / 16.0,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    int col = 0;
    int row = 0;

    for (double y = 0; y < size.height; y += spacing) {
      col = 0;
      for (double x = 0; x < size.width; x += spacing) {
        final bayerIndex = (row % 4) * 4 + (col % 4);
        final threshold = _bayer4x4[bayerIndex];
        if (threshold > 0.45) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, dotSize, dotSize),
            _dotPaint,
          );
        }
        col++;
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(covariant _BayerDitherPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.dotSize != dotSize ||
        oldDelegate.spacing != spacing ||
        oldDelegate.ditherColor != ditherColor;
  }
}

/// Tactile Neo-Brutalist Rubber Stamp badge with tactile angled tilt,
/// heavy border and raw ink aesthetic.
class TactileBrutalStamp extends StatelessWidget {
  final String text;
  final Color color;
  final double angleRadians;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const TactileBrutalStamp({
    super.key,
    required this.text,
    this.color = AppColors.brutalRed,
    this.angleRadians = -0.10, // ~-6 degrees
    this.fontSize = 11.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angleRadians,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color, width: 2.2),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// CAD Blueprint architectural grid with millimeter cross ticks
/// for construction, real estate, and technical workshops.
class CadBlueprintOverlay extends StatelessWidget {
  final Widget? child;
  final double gridSpacing;
  final Color? gridColor;
  final double opacity;

  const CadBlueprintOverlay({
    super.key,
    this.child,
    this.gridSpacing = 16.0,
    this.gridColor,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _CadBlueprintPainter(
        gridSpacing: gridSpacing,
        gridColor: gridColor ?? AppColors.brutalCyan,
        opacity: opacity,
      ),
      child: child,
    );
  }
}

class _CadBlueprintPainter extends CustomPainter {
  final double gridSpacing;
  final Color gridColor;
  final double opacity;
  final Paint _linePaint = Paint()..strokeWidth = 0.75;
  final Paint _crossPaint = Paint()..strokeWidth = 1.25;

  _CadBlueprintPainter({
    required this.gridSpacing,
    required this.gridColor,
    required this.opacity,
  }) {
    _linePaint.color = gridColor.withValues(alpha: opacity * 0.7);
    _crossPaint.color = gridColor.withValues(alpha: opacity * 1.5);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), _linePaint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _linePaint);
    }

    // Corner cross ticks at major intervals (every 2 grid cells)
    final majorStep = gridSpacing * 2;
    for (double x = 0; x < size.width; x += majorStep) {
      for (double y = 0; y < size.height; y += majorStep) {
        canvas.drawLine(Offset(x - 2.5, y), Offset(x + 2.5, y), _crossPaint);
        canvas.drawLine(Offset(x, y - 2.5), Offset(x, y + 2.5), _crossPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CadBlueprintPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.gridSpacing != gridSpacing ||
        oldDelegate.gridColor != gridColor;
  }
}
