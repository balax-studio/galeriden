import 'package:flutter/material.dart';
import '../../core/theme/app_theme_extension.dart';

enum BlueprintPatternType {
  dots,
  blueprintGrid,
  cyberGrid,
  technicalCrosses,
}

/// Dynamic Neo-Brutalist Background Canvas Widget
/// Renders hardware-accelerated technical blueprints, dot matrices, and cyber grids.
class BlueprintGridBackground extends StatelessWidget {
  final Widget child;
  final BlueprintPatternType patternType;
  final Color? patternColor;
  final double spacing;
  final double strokeWidth;
  final double opacity;

  const BlueprintGridBackground({
    super.key,
    required this.child,
    this.patternType = BlueprintPatternType.blueprintGrid,
    this.patternColor,
    this.spacing = 24.0,
    this.strokeWidth = 1.0,
    this.opacity = 0.05,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activePalette = themeExt?.palette;

    Color effectiveColor;
    if (patternColor != null) {
      effectiveColor = patternColor!.withValues(alpha: opacity);
    } else if (activePalette != null && activePalette.id == 'toksik_asit_cyber') {
      // Absurd theme uses glowing neon acid / magenta grid
      effectiveColor = const Color(0xFFCCFF00).withValues(alpha: 0.08);
    } else if (activePalette != null && activePalette.id == 'egzotik_neo_pop') {
      // Exotic pop theme uses crisp neo-brutalist pop dots/grid
      effectiveColor = const Color(0xFF111827).withValues(alpha: 0.09);
    } else if (isDark) {
      effectiveColor = Colors.white.withValues(alpha: opacity);
    } else {
      effectiveColor = const Color(0xFF0F172A).withValues(alpha: opacity);
    }

    return CustomPaint(
      painter: _BlueprintPatternPainter(
        patternType: patternType,
        color: effectiveColor,
        spacing: spacing,
        strokeWidth: strokeWidth,
      ),
      child: child,
    );
  }
}

class _BlueprintPatternPainter extends CustomPainter {
  final BlueprintPatternType patternType;
  final Color color;
  final double spacing;
  final double strokeWidth;

  _BlueprintPatternPainter({
    required this.patternType,
    required this.color,
    required this.spacing,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    switch (patternType) {
      case BlueprintPatternType.dots:
        final dotPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        for (double x = spacing / 2; x < size.width; x += spacing) {
          for (double y = spacing / 2; y < size.height; y += spacing) {
            canvas.drawCircle(Offset(x, y), strokeWidth * 1.2, dotPaint);
          }
        }
        break;

      case BlueprintPatternType.blueprintGrid:
        for (double x = 0; x <= size.width; x += spacing) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (double y = 0; y <= size.height; y += spacing) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
        break;

      case BlueprintPatternType.cyberGrid:
        // Dual Grid: Minor and Major Accent grid for Cyberpunk Neo-Brutalism
        final majorPaint = Paint()
          ..color = color.withValues(alpha: (color.a * 2.2).clamp(0.0, 1.0))
          ..strokeWidth = strokeWidth * 1.5
          ..style = PaintingStyle.stroke;

        int col = 0;
        for (double x = 0; x <= size.width; x += spacing, col++) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), (col % 4 == 0) ? majorPaint : paint);
        }
        int row = 0;
        for (double y = 0; y <= size.height; y += spacing, row++) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), (row % 4 == 0) ? majorPaint : paint);
        }
        break;

      case BlueprintPatternType.technicalCrosses:
        final crossSize = spacing * 0.25;
        for (double x = spacing; x < size.width; x += spacing) {
          for (double y = spacing; y < size.height; y += spacing) {
            canvas.drawLine(Offset(x - crossSize, y), Offset(x + crossSize, y), paint);
            canvas.drawLine(Offset(x, y - crossSize), Offset(x, y + crossSize), paint);
          }
        }
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BlueprintPatternPainter oldDelegate) {
    return oldDelegate.patternType != patternType ||
        oldDelegate.color != color ||
        oldDelegate.spacing != spacing ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
