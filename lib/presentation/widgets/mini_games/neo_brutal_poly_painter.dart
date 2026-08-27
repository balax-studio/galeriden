import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Neo-Brutalist Low-Poly 2.5D Polygonal Vector Drawing Engine
/// Provides high-performance faceted polygon rendering, directional flat shading,
/// crisp 2.5px-3.5px black contours, zero-blur hard offset shadows, and industrial decals.
class NeoBrutalPolyPainter {
  const NeoBrutalPolyPainter._();

  /// Calculates a shaded color from base color using directional light multiplier.
  static Color shadeColor(Color base, double factor) {
    final hsl = HSLColor.fromColor(base);
    final newLightness = (hsl.lightness * factor).clamp(0.02, 0.98);
    return hsl.withLightness(newLightness).toColor();
  }

  /// Draws a single faceted polygon with optional flat-shading, stroke contour and hard shadow.
  static void drawFacetedPolygon(
    Canvas canvas,
    List<Offset> vertices, {
    required Color color,
    double lightFactor = 1.0,
    double strokeWidth = 2.4,
    Color strokeColor = Colors.black,
    bool showHardShadow = false,
    Offset shadowOffset = const Offset(3.0, 3.0),
    Color shadowColor = Colors.black,
  }) {
    if (vertices.length < 3) return;

    final path = Path()..moveTo(vertices[0].dx, vertices[0].dy);
    for (int i = 1; i < vertices.length; i++) {
      path.lineTo(vertices[i].dx, vertices[i].dy);
    }
    path.close();

    // 1. Hard Offset Shadow
    if (showHardShadow) {
      final shadowPath = path.shift(shadowOffset);
      canvas.drawPath(shadowPath, Paint()..color = shadowColor);
    }

    // 2. Facet Fill
    final effectiveFill = shadeColor(color, lightFactor);
    canvas.drawPath(path, Paint()..color = effectiveFill);

    // 3. Crisp Black Contour
    if (strokeWidth > 0) {
      final borderPaint = Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.miter;
      canvas.drawPath(path, borderPaint);
    }
  }

  /// Draws a 3D Low-Poly Hexagonal Bolt with faceted depth and socket drive.
  static void draw3DHexBolt(
    Canvas canvas,
    Offset center,
    double radius, {
    double rotation = 0.0,
    Color boltColor = const Color(0xFF94A3B8),
    Color? baseColor,
    bool isLoosened = false,
    double depth = 4.0,
    double strokeWidth = 2.0,
    Color strokeColor = Colors.black,
  }) {
    final effectiveColor = baseColor ?? (isLoosened ? const Color(0xFF00E575) : boltColor);
    List<Offset> computeHexPoints(Offset c, double r, double rot) {
      final pts = <Offset>[];
      for (int i = 0; i < 6; i++) {
        final angle = rot + (i * math.pi / 3);
        pts.add(Offset(c.dx + r * math.cos(angle), c.dy + r * math.sin(angle)));
      }
      return pts;
    }

    // 1. Bottom / Depth Facets
    if (depth > 0) {
      final topPts = computeHexPoints(center, radius, rotation);
      final botPts = computeHexPoints(center + Offset(0, depth), radius, rotation);

      // Side wall facets
      for (int i = 0; i < 6; i++) {
        final next = (i + 1) % 6;
        final wall = [topPts[i], topPts[next], botPts[next], botPts[i]];
        final light = 0.60 + 0.35 * math.cos(rotation + i * math.pi / 3);
        drawFacetedPolygon(
          canvas,
          wall,
          color: effectiveColor,
          lightFactor: light,
          strokeWidth: strokeWidth,
          strokeColor: strokeColor,
        );
      }
    }

    // 2. Top Hexagon Head
    final topPts = computeHexPoints(center, radius, rotation);
    drawFacetedPolygon(
      canvas,
      topPts,
      color: effectiveColor,
      lightFactor: 1.15,
      strokeWidth: strokeWidth,
      strokeColor: strokeColor,
    );

    // 3. Inner Socket / Drive Indentation
    final innerPts = computeHexPoints(center, radius * 0.45, rotation + math.pi / 6);
    drawFacetedPolygon(
      canvas,
      innerPts,
      color: const Color(0xFF0F172A),
      lightFactor: 0.5,
      strokeWidth: 1.5,
      strokeColor: strokeColor,
    );
  }

  /// Draws industrial diagonal yellow/black or red/white hazard safety stripes.
  static void drawHazardStripes(
    Canvas canvas,
    Rect rect, {
    Color primaryColor = const Color(0xFFFFDE59),
    Color stripeColor = Colors.black,
    double stripeWidth = 12.0,
    double borderWidth = 2.0,
    Color borderColor = Colors.black,
  }) {
    canvas.save();
    canvas.clipRect(rect);

    // Base background
    canvas.drawRect(rect, Paint()..color = primaryColor);

    final stripePaint = Paint()..color = stripeColor;
    final totalW = rect.width + rect.height;
    final step = stripeWidth * 2;

    for (double x = -rect.height; x < totalW; x += step) {
      final path = Path()
        ..moveTo(rect.left + x, rect.top)
        ..lineTo(rect.left + x + stripeWidth, rect.top)
        ..lineTo(rect.left + x + stripeWidth + rect.height, rect.bottom)
        ..lineTo(rect.left + x + rect.height, rect.bottom)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    canvas.restore();

    // Outline
    if (borderWidth > 0) {
      canvas.drawRect(
        rect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
    }
  }

  /// Draws a CRT / Oscilloscope technical blueprint grid.
  static void drawCRTGrid(
    Canvas canvas,
    Size size, {
    Color gridColor = const Color(0xFF1E293B),
    double spacing = 16.0,
    double strokeWidth = 1.0,
    bool drawCrosshair = false,
  }) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = strokeWidth;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    if (drawCrosshair) {
      final crosshairPaint = Paint()
        ..color = gridColor.withValues(alpha: 0.8)
        ..strokeWidth = strokeWidth * 1.5;
      final cx = size.width / 2;
      final cy = size.height / 2;
      canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), crosshairPaint);
      canvas.drawLine(Offset(0, cy), Offset(size.width, cy), crosshairPaint);
    }
  }

  /// Draws a prismatic 4-facet sparkling diamond particle.
  static void drawPrismaticDiamond(
    Canvas canvas,
    Offset center,
    double size,
    Color color, {
    double rotation = 0.0,
    double strokeWidth = 1.2,
  }) {
    final half = size / 2;
    final pTop = Offset(center.dx, center.dy - half);
    final pBottom = Offset(center.dx, center.dy + half);
    final pLeft = Offset(center.dx - half, center.dy);
    final pRight = Offset(center.dx + half, center.dy);

    // Left Facet
    drawFacetedPolygon(
      canvas,
      [center, pTop, pLeft],
      color: color,
      lightFactor: 1.2,
      strokeWidth: strokeWidth,
    );
    drawFacetedPolygon(
      canvas,
      [center, pLeft, pBottom],
      color: color,
      lightFactor: 0.8,
      strokeWidth: strokeWidth,
    );

    // Right Facet
    drawFacetedPolygon(
      canvas,
      [center, pTop, pRight],
      color: color,
      lightFactor: 1.4,
      strokeWidth: strokeWidth,
    );
    drawFacetedPolygon(
      canvas,
      [center, pRight, pBottom],
      color: color,
      lightFactor: 0.95,
      strokeWidth: strokeWidth,
    );
  }

  /// Draws a volumetric Low-Poly 2.5D Isometric Car with faceted surfaces.
  static void drawLowPolyIsometricCar(
    Canvas canvas,
    Offset center,
    double scale, {
    required Color bodyColor,
    double damagePercent = 0.0,
    bool isSport = false,
    bool isHeadlightsOn = true,
  }) {
    final s = scale;

    // Hard drop shadow (0-blur)
    final shadowPath = Path()
      ..moveTo(center.dx - 35 * s, center.dy + 15 * s)
      ..lineTo(center.dx + 40 * s, center.dy + 25 * s)
      ..lineTo(center.dx + 48 * s, center.dy + 35 * s)
      ..lineTo(center.dx - 28 * s, center.dy + 30 * s)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()..color = Colors.black.withValues(alpha: 0.75),
    );

    // 1. Lower Chassis (Dark Underbody)
    drawFacetedPolygon(
      canvas,
      [
        Offset(center.dx - 38 * s, center.dy + 8 * s),
        Offset(center.dx + 35 * s, center.dy + 22 * s),
        Offset(center.dx + 32 * s, center.dy + 28 * s),
        Offset(center.dx - 35 * s, center.dy + 16 * s),
      ],
      color: const Color(0xFF0F172A),
      lightFactor: 0.7,
      strokeWidth: 2.4,
    );

    // 2. Wheels (Faceted Hexagonal Tires)
    draw3DHexBolt(
      canvas,
      Offset(center.dx - 22 * s, center.dy + 18 * s),
      10 * s,
      boltColor: const Color(0xFF1E293B),
      depth: 3.5 * s,
      strokeWidth: 2.0,
    );
    draw3DHexBolt(
      canvas,
      Offset(center.dx + 22 * s, center.dy + 25 * s),
      10 * s,
      boltColor: const Color(0xFF1E293B),
      depth: 3.5 * s,
      strokeWidth: 2.0,
    );

    // 3. Side Panels (Faceted Door & Skirt)
    drawFacetedPolygon(
      canvas,
      [
        Offset(center.dx - 36 * s, center.dy - 2 * s),
        Offset(center.dx + 34 * s, center.dy + 10 * s),
        Offset(center.dx + 34 * s, center.dy + 22 * s),
        Offset(center.dx - 36 * s, center.dy + 10 * s),
      ],
      color: bodyColor,
      lightFactor: 0.82,
      strokeWidth: 2.4,
    );

    // 4. Hood / Front Facet
    drawFacetedPolygon(
      canvas,
      [
        Offset(center.dx - 36 * s, center.dy - 2 * s),
        Offset(center.dx - 12 * s, center.dy - 12 * s),
        Offset(center.dx - 12 * s, center.dy + 2 * s),
        Offset(center.dx - 36 * s, center.dy + 10 * s),
      ],
      color: bodyColor,
      lightFactor: 1.15,
      strokeWidth: 2.4,
    );

    // 5. Cabin Roof & Pillars
    drawFacetedPolygon(
      canvas,
      [
        Offset(center.dx - 10 * s, center.dy - 14 * s),
        Offset(center.dx + 18 * s, center.dy - 8 * s),
        Offset(center.dx + 14 * s, center.dy - 22 * s),
        Offset(center.dx - 8 * s, center.dy - 26 * s),
      ],
      color: bodyColor,
      lightFactor: 1.25,
      strokeWidth: 2.4,
    );

    // 6. Faceted Glass / Windows
    drawFacetedPolygon(
      canvas,
      [
        Offset(center.dx - 8 * s, center.dy - 13 * s),
        Offset(center.dx + 16 * s, center.dy - 7 * s),
        Offset(center.dx + 12 * s, center.dy - 20 * s),
        Offset(center.dx - 6 * s, center.dy - 24 * s),
      ],
      color: const Color(0xFF0284C7),
      lightFactor: 1.0,
      strokeWidth: 2.0,
      strokeColor: Colors.black,
    );

    // 7. Headlight & Taillight Facets
    if (isHeadlightsOn) {
      drawFacetedPolygon(
        canvas,
        [
          Offset(center.dx - 36 * s, center.dy + 2 * s),
          Offset(center.dx - 32 * s, center.dy + 1 * s),
          Offset(center.dx - 32 * s, center.dy + 6 * s),
          Offset(center.dx - 36 * s, center.dy + 7 * s),
        ],
        color: const Color(0xFFFFE500),
        lightFactor: 1.5,
        strokeWidth: 1.5,
      );
    }
  }
}
