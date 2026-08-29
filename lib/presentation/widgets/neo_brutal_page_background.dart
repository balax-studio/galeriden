import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme_extension.dart';

/// Thematic Watermark Silhouettes for Neo-Brutalist Screens
enum ThematicWatermarkType {
  none,
  dealership,
  workshop,
  carWash,
  scrapyard,
  stockMarket,
  finance,
  nightMarket,
  showroom,
  character,
}

/// Unified Theme-Reactive Page Background Widget
/// Combines:
/// 1. Dynamic Theme Solid Base (`ThemePaletteModel.backgroundColor`)
/// 2. Soft Radial Aurora Glow (matching `primaryColor` & `secondaryColor`)
/// 3. Procedural CAD Blueprint Dot Grid (Hardware-accelerated `CustomPaint`)
/// 4. Subtle Thematic Vector Watermark Silhouette
class NeoBrutalPageBackground extends StatelessWidget {
  final Widget child;
  final ThematicWatermarkType watermark;
  final bool showGlow;
  final bool showGrid;
  final double gridSpacing;
  final double watermarkOpacity;

  const NeoBrutalPageBackground({
    super.key,
    required this.child,
    this.watermark = ThematicWatermarkType.none,
    this.showGlow = true,
    this.showGrid = true,
    this.gridSpacing = 24.0,
    this.watermarkOpacity = 0.10,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = themeExt?.palette;

    final Color bgColor = palette?.backgroundColor ??
        (isDark ? const Color(0xFF0C0E14) : const Color(0xFFE9ECEF));

    final Color primary = palette?.primaryColor ??
        (isDark ? const Color(0xFFFACC15) : const Color(0xFFEAB308));

    final Color secondary = palette?.secondaryColor ??
        (isDark ? const Color(0xFF38BDF8) : const Color(0xFF2563EB));

    // Dynamic grid dot tint
    Color gridColor;
    if (palette?.id == 'toksik_asit_cyber') {
      gridColor = const Color(0xFFCCFF00).withValues(alpha: 0.14);
    } else if (palette?.id == 'egzotik_neo_pop') {
      gridColor = const Color(0xFF111827).withValues(alpha: 0.15);
    } else if (isDark) {
      gridColor = Colors.white.withValues(alpha: 0.10);
    } else {
      gridColor = const Color(0xFF0F172A).withValues(alpha: 0.12);
    }

    // Dynamic watermark tint
    Color watermarkColor;
    if (palette?.id == 'toksik_asit_cyber') {
      watermarkColor = primary.withValues(alpha: watermarkOpacity * 1.6);
    } else if (isDark) {
      watermarkColor = primary.withValues(alpha: watermarkOpacity * 1.3);
    } else {
      watermarkColor = const Color(0xFF0F172A).withValues(alpha: watermarkOpacity);
    }

    return Container(
      color: bgColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Soft Top-Center Radial Aurora Glow
          if (showGlow)
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              height: 420,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.3),
                      radius: 1.2,
                      colors: [
                        primary.withValues(alpha: isDark ? 0.12 : 0.10),
                        secondary.withValues(alpha: isDark ? 0.06 : 0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.60, 1.0],
                    ),
                  ),
                ),
              ),
            ),

          // 2. Procedural CAD Dot Matrix Grid
          if (showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: false,
                    painter: _CadDotGridPainter(
                      color: gridColor,
                      spacing: gridSpacing,
                    ),
                  ),
                ),
              ),
            ),

          // 3. Subtle Thematic Vector Silhouette
          if (watermark != ThematicWatermarkType.none)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    isComplex: true,
                    willChange: false,
                    painter: _ThematicWatermarkPainter(
                      type: watermark,
                      color: watermarkColor,
                    ),
                  ),
                ),
              ),
            ),

          // 4. Foreground Content
          child,
        ],
      ),
    );
  }
}

/// Hardware-Accelerated CAD Blueprint Dot Matrix
class _CadDotGridPainter extends CustomPainter {
  final Color color;
  final double spacing;

  _CadDotGridPainter({required this.color, required this.spacing});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final crossPaint = Paint()
      ..color = color.withValues(alpha: (color.a * 1.5).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    int col = 0;
    for (double x = spacing / 2; x < size.width; x += spacing, col++) {
      int row = 0;
      for (double y = spacing / 2; y < size.height; y += spacing, row++) {
        if (col % 4 == 0 && row % 4 == 0) {
          canvas.drawLine(Offset(x - 3.5, y), Offset(x + 3.5, y), crossPaint);
          canvas.drawLine(Offset(x, y - 3.5), Offset(x, y + 3.5), crossPaint);
        } else {
          canvas.drawCircle(Offset(x, y), 1.25, dotPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CadDotGridPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}

/// Renders procedural low-opacity thematic vector watermarks
class _ThematicWatermarkPainter extends CustomPainter {
  final ThematicWatermarkType type;
  final Color color;

  _ThematicWatermarkPainter({required this.type, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.5)
      ..style = PaintingStyle.fill;

    switch (type) {
      case ThematicWatermarkType.dealership:
        _drawCarChassisWatermark(canvas, size, strokePaint, fillPaint);
        break;
      case ThematicWatermarkType.workshop:
        _drawWorkshopGearsWatermark(canvas, size, strokePaint);
        break;
      case ThematicWatermarkType.carWash:
        _drawCarWashWatermark(canvas, size, strokePaint, fillPaint);
        break;
      case ThematicWatermarkType.scrapyard:
        _drawScrapyardWatermark(canvas, size, strokePaint);
        break;
      case ThematicWatermarkType.stockMarket:
        _drawStockMarketWatermark(canvas, size, strokePaint, fillPaint);
        break;
      case ThematicWatermarkType.finance:
        _drawFinanceWatermark(canvas, size, strokePaint);
        break;
      case ThematicWatermarkType.nightMarket:
        _drawNightMarketWatermark(canvas, size, strokePaint);
        break;
      case ThematicWatermarkType.showroom:
        _drawShowroomWatermark(canvas, size, strokePaint, fillPaint);
        break;
      case ThematicWatermarkType.character:
        _drawCharacterWatermark(canvas, size, strokePaint);
        break;
      case ThematicWatermarkType.none:
        break;
    }
  }

  /// Aerodynamic Sports Coupe Silhouette (Centered & scaled across background)
  void _drawCarChassisWatermark(
      Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    const double carWidth = 310.0;
    final double scale = (size.width < 380) ? size.width / 400 : 1.0;
    final double originX = (size.width - (carWidth * scale)) / 2;
    final double originY = size.height * 0.46;

    canvas.save();
    canvas.translate(originX, originY);
    canvas.scale(scale);

    final path = Path();
    path.moveTo(0, 80);
    // Front splitter & hood
    path.lineTo(30, 80);
    path.quadraticBezierTo(45, 80, 50, 70);
    path.lineTo(90, 45);
    // Windshield & roof
    path.quadraticBezierTo(115, 20, 150, 18);
    path.lineTo(210, 18);
    // Fastback & rear wing
    path.quadraticBezierTo(250, 22, 280, 55);
    path.lineTo(305, 60);
    path.lineTo(310, 80);
    // Ground base line
    path.lineTo(0, 80);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Wheel arches & wheels
    canvas.drawCircle(const Offset(70, 80), 24, strokePaint);
    canvas.drawCircle(const Offset(250, 80), 24, strokePaint);
    canvas.drawCircle(const Offset(70, 80), 11, fillPaint);
    canvas.drawCircle(const Offset(250, 80), 11, fillPaint);
    canvas.drawCircle(const Offset(70, 80), 5, strokePaint);
    canvas.drawCircle(const Offset(250, 80), 5, strokePaint);

    canvas.restore();
  }

  /// Mechanical Cogwheel & Piston Vectors (Anchored top right)
  void _drawWorkshopGearsWatermark(Canvas canvas, Size size, Paint strokePaint) {
    final center = Offset(size.width - 60, 160);
    const double radius = 70.0;
    const int teeth = 10;

    final gearPath = Path();
    for (int i = 0; i < teeth; i++) {
      final double angle1 = (i * 2 * math.pi) / teeth;
      final double angle2 = ((i + 0.35) * 2 * math.pi) / teeth;
      final double angle3 = ((i + 0.65) * 2 * math.pi) / teeth;
      final double angle4 = ((i + 1.0) * 2 * math.pi) / teeth;

      final double rOuter = radius + 14;
      final double rInner = radius;

      if (i == 0) {
        gearPath.moveTo(
            center.dx + rInner * math.cos(angle1),
            center.dy + rInner * math.sin(angle1));
      } else {
        gearPath.lineTo(
            center.dx + rInner * math.cos(angle1),
            center.dy + rInner * math.sin(angle1));
      }

      gearPath.lineTo(
          center.dx + rOuter * math.cos(angle2),
          center.dy + rOuter * math.sin(angle2));
      gearPath.lineTo(
          center.dx + rOuter * math.cos(angle3),
          center.dy + rOuter * math.sin(angle3));
      gearPath.lineTo(
          center.dx + rInner * math.cos(angle4),
          center.dy + rInner * math.sin(angle4));
    }
    gearPath.close();

    canvas.drawPath(gearPath, strokePaint);
    canvas.drawCircle(center, 30, strokePaint);
    canvas.drawCircle(center, 12, strokePaint);

    // Secondary smaller intertwined cog
    final smallCenter = Offset(size.width - 155, 235);
    canvas.drawCircle(smallCenter, 38, strokePaint);
    canvas.drawCircle(smallCenter, 14, strokePaint);
  }

  /// Water Droplet Arcs & Foam Waves (Anchored center right)
  void _drawCarWashWatermark(
      Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final dropletCenter = Offset(size.width - 70, size.height - 220);

    // Oversized stylised water drop
    final dropPath = Path();
    dropPath.moveTo(dropletCenter.dx, dropletCenter.dy - 70);
    dropPath.quadraticBezierTo(
        dropletCenter.dx + 45,
        dropletCenter.dy - 10,
        dropletCenter.dx + 45,
        dropletCenter.dy + 35);
    dropPath.arcToPoint(
      Offset(dropletCenter.dx - 45, dropletCenter.dy + 35),
      radius: const Radius.circular(45),
      clockwise: true,
    );
    dropPath.quadraticBezierTo(
        dropletCenter.dx - 45,
        dropletCenter.dy - 10,
        dropletCenter.dx,
        dropletCenter.dy - 70);
    dropPath.close();

    canvas.drawPath(dropPath, fillPaint);
    canvas.drawPath(dropPath, strokePaint);

    // Ripple arcs
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(dropletCenter.dx, dropletCenter.dy + 35), radius: 65),
      0.2,
      2.7,
      false,
      strokePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(
          center: Offset(dropletCenter.dx, dropletCenter.dy + 35), radius: 85),
      0.3,
      2.5,
      false,
      strokePaint,
    );
  }

  /// Industrial Salvage Crane & Metal Lattice (Anchored bottom right)
  void _drawScrapyardWatermark(Canvas canvas, Size size, Paint strokePaint) {
    final double originX = size.width - 160;
    final double originY = size.height - 180;

    final cranePath = Path();
    cranePath.moveTo(originX, originY + 120);
    cranePath.lineTo(originX + 30, originY);
    cranePath.lineTo(originX + 60, originY + 120);
    cranePath.lineTo(originX + 130, originY - 40);
    cranePath.lineTo(originX + 140, originY + 30);
    cranePath.lineTo(originX + 45, originY + 120);

    // Internal lattice trusses
    cranePath.moveTo(originX + 15, originY + 60);
    cranePath.lineTo(originX + 45, originY + 60);
    cranePath.moveTo(originX + 75, originY + 20);
    cranePath.lineTo(originX + 105, originY + 20);

    canvas.drawPath(cranePath, strokePaint);
  }

  /// Candlestick Financial Graph Wave (Anchored bottom center/right)
  void _drawStockMarketWatermark(
      Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final double baseY = size.height - 130;
    final double startX = size.width - 220;

    // Trend line
    final trendPath = Path();
    trendPath.moveTo(startX, baseY);
    trendPath.lineTo(startX + 40, baseY - 25);
    trendPath.lineTo(startX + 80, baseY + 10);
    trendPath.lineTo(startX + 130, baseY - 50);
    trendPath.lineTo(startX + 180, baseY - 35);
    trendPath.lineTo(startX + 220, baseY - 95);

    canvas.drawPath(trendPath, strokePaint);

    // Candlesticks (rectangles with wicks)
    void drawCandle(double x, double top, double bottom, double high, double low) {
      canvas.drawLine(Offset(x, high), Offset(x, low), strokePaint);
      final r = Rect.fromLTRB(x - 5, top, x + 5, bottom);
      canvas.drawRect(r, fillPaint);
      canvas.drawRect(r, strokePaint);
    }

    drawCandle(startX + 30, baseY - 20, baseY - 5, baseY - 30, baseY);
    drawCandle(startX + 75, baseY - 5, baseY + 8, baseY - 12, baseY + 15);
    drawCandle(startX + 125, baseY - 45, baseY - 25, baseY - 55, baseY - 20);
    drawCandle(startX + 175, baseY - 30, baseY - 15, baseY - 40, baseY - 10);
    drawCandle(startX + 215, baseY - 90, baseY - 60, baseY - 100, baseY - 50);
  }

  /// Classic Vault Column & Scales (Anchored top right)
  void _drawFinanceWatermark(Canvas canvas, Size size, Paint strokePaint) {
    final double originX = size.width - 130;
    const double originY = 120.0;

    final bankPath = Path();
    // Pediment triangle
    bankPath.moveTo(originX - 50, originY);
    bankPath.lineTo(originX, originY - 30);
    bankPath.lineTo(originX + 50, originY);
    bankPath.close();

    // Base
    bankPath.moveTo(originX - 55, originY + 60);
    bankPath.lineTo(originX + 55, originY + 60);
    bankPath.lineTo(originX + 55, originY + 70);
    bankPath.lineTo(originX - 55, originY + 70);
    bankPath.close();

    // Columns
    for (int i = -40; i <= 40; i += 26) {
      bankPath.moveTo(originX + i - 4, originY + 5);
      bankPath.lineTo(originX + i + 4, originY + 5);
      bankPath.lineTo(originX + i + 4, originY + 55);
      bankPath.lineTo(originX + i - 4, originY + 55);
      bankPath.close();
    }

    canvas.drawPath(bankPath, strokePaint);
  }

  /// Retro Neon Diamond Star & Casino Dice (Anchored bottom right)
  void _drawNightMarketWatermark(Canvas canvas, Size size, Paint strokePaint) {
    final center = Offset(size.width - 80, size.height - 150);

    // 4-pointed diamond star
    final starPath = Path();
    starPath.moveTo(center.dx, center.dy - 65);
    starPath.quadraticBezierTo(
        center.dx, center.dy, center.dx + 55, center.dy);
    starPath.quadraticBezierTo(
        center.dx, center.dy, center.dx, center.dy + 65);
    starPath.quadraticBezierTo(
        center.dx, center.dy, center.dx - 55, center.dy);
    starPath.quadraticBezierTo(
        center.dx, center.dy, center.dx, center.dy - 65);
    starPath.close();

    canvas.drawPath(starPath, strokePaint);

    // Mini companion sparkle
    final miniCenter = Offset(size.width - 150, size.height - 190);
    final miniStar = Path();
    miniStar.moveTo(miniCenter.dx, miniCenter.dy - 25);
    miniStar.quadraticBezierTo(
        miniCenter.dx, miniCenter.dy, miniCenter.dx + 20, miniCenter.dy);
    miniStar.quadraticBezierTo(
        miniCenter.dx, miniCenter.dy, miniCenter.dx, miniCenter.dy + 25);
    miniStar.quadraticBezierTo(
        miniCenter.dx, miniCenter.dy, miniCenter.dx - 20, miniCenter.dy);
    miniStar.quadraticBezierTo(
        miniCenter.dx, miniCenter.dy, miniCenter.dx, miniCenter.dy - 25);
    miniStar.close();

    canvas.drawPath(miniStar, strokePaint);
  }

  /// Showroom Pedestal & Spotlight Rays (Anchored top center/right)
  void _drawShowroomWatermark(
      Canvas canvas, Size size, Paint strokePaint, Paint fillPaint) {
    final double originX = size.width - 110;
    const double originY = 100.0;

    // Spotlight beam trapezoid
    final beamPath = Path();
    beamPath.moveTo(originX, originY);
    beamPath.lineTo(originX - 70, originY + 160);
    beamPath.lineTo(originX + 70, originY + 160);
    beamPath.close();

    canvas.drawPath(beamPath, fillPaint);
    canvas.drawPath(beamPath, strokePaint);

    // Elliptical showroom turntable
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(originX, originY + 160), width: 140, height: 36),
      strokePaint,
    );
  }

  /// Laurel Wreath & Trophy Contour (Anchored top right)
  void _drawCharacterWatermark(Canvas canvas, Size size, Paint strokePaint) {
    final center = Offset(size.width - 75, 150);

    // Cup outline
    final cupPath = Path();
    cupPath.moveTo(center.dx - 25, center.dy - 35);
    cupPath.lineTo(center.dx + 25, center.dy - 35);
    cupPath.lineTo(center.dx + 20, center.dy + 5);
    cupPath.quadraticBezierTo(
        center.dx, center.dy + 25, center.dx - 20, center.dy + 5);
    cupPath.close();

    // Stem & base
    cupPath.moveTo(center.dx - 5, center.dy + 22);
    cupPath.lineTo(center.dx + 5, center.dy + 22);
    cupPath.lineTo(center.dx + 5, center.dy + 38);
    cupPath.lineTo(center.dx - 5, center.dy + 38);
    cupPath.close();

    cupPath.moveTo(center.dx - 22, center.dy + 38);
    cupPath.lineTo(center.dx + 22, center.dy + 38);
    cupPath.lineTo(center.dx + 22, center.dy + 46);
    cupPath.lineTo(center.dx - 22, center.dy + 46);
    cupPath.close();

    // Handles
    cupPath.moveTo(center.dx - 25, center.dy - 25);
    cupPath.quadraticBezierTo(
        center.dx - 45, center.dy - 15, center.dx - 20, center.dy + 2);
    cupPath.moveTo(center.dx + 25, center.dy - 25);
    cupPath.quadraticBezierTo(
        center.dx + 45, center.dy - 15, center.dx + 20, center.dy + 2);

    canvas.drawPath(cupPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _ThematicWatermarkPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.color != color;
}
