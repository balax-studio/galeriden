import 'dart:math' as math;
import 'package:flutter/material.dart';

/// High-contrast vector automotive illustrations for the City Hub Bento cards.
/// Hardware-accelerated with [CustomPainter], pure vector paths, 0 image asset dependencies.
class HubServiceIllustration extends StatelessWidget {
  final String route;
  final Color color;
  final double opacity;
  final double strokeWidth;

  const HubServiceIllustration({
    super.key,
    required this.route,
    required this.color,
    this.opacity = 0.28,
    this.strokeWidth = 1.6,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _HubIllustrationPainter(
          route: route,
          color: color.withValues(alpha: opacity),
          accentColor: color.withValues(alpha: (opacity * 1.5).clamp(0.0, 1.0)),
          strokeWidth: strokeWidth,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _HubIllustrationPainter extends CustomPainter {
  final String route;
  final Color color;
  final Color accentColor;
  final double strokeWidth;

  _HubIllustrationPainter({
    required this.route,
    required this.color,
    required this.accentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    switch (route) {
      case '/rent-a-car':
        _drawSportCoupe(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/scrapyard':
        _drawEngineBlock(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/showroom-decor':
        _drawShowroomArchitecture(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/consignment':
        _drawCarOnPodium(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/night-market':
        _drawTunedRacer(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/gossip':
        _drawRadarAntenna(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/districts':
        _drawIsometricCityGrid(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/reviews':
        _drawReputationCrest(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/side-businesses':
        _drawIndustrialConglomerate(canvas, size, paint, accentPaint, fillPaint);
        break;
      case '/casino':
        _drawCasinoSpade(canvas, size, paint, accentPaint, fillPaint);
        break;
      default:
        _drawTechnicalGrid(canvas, size, paint);
    }
  }

  /// Rent-a-Car: High-contrast aerodynamic luxury sports coupe profile with speedlines
  void _drawSportCoupe(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Background speed lines
    for (int i = 0; i < 3; i++) {
      final y = h * (0.28 + i * 0.16);
      canvas.drawLine(
        Offset(w * 0.05, y),
        Offset(w * (0.35 + i * 0.15), y),
        paint..strokeWidth = 1.0,
      );
    }

    // Car silhouette path
    final path = Path();
    path.moveTo(w * 0.15, h * 0.72); // Rear bumper lower
    path.lineTo(w * 0.12, h * 0.60); // Rear trunk curve
    path.lineTo(w * 0.22, h * 0.52); // Rear deck
    path.lineTo(w * 0.38, h * 0.34); // Rear windshield slope
    path.lineTo(w * 0.62, h * 0.32); // Roofline
    path.lineTo(w * 0.76, h * 0.48); // Front windshield slope
    path.lineTo(w * 0.90, h * 0.54); // Hood
    path.lineTo(w * 0.95, h * 0.65); // Front nose/grille
    path.lineTo(w * 0.88, h * 0.72); // Front chin

    // Wheels cutouts
    // Front wheel
    path.lineTo(w * 0.82, h * 0.72);
    path.arcToPoint(
      Offset(w * 0.68, h * 0.72),
      radius: Radius.circular(w * 0.07),
      clockwise: false,
    );
    // Underbody
    path.lineTo(w * 0.38, h * 0.72);
    // Rear wheel
    path.arcToPoint(
      Offset(w * 0.24, h * 0.72),
      radius: Radius.circular(w * 0.07),
      clockwise: false,
    );
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, accentPaint);

    // Wheels circles
    canvas.drawCircle(Offset(w * 0.75, h * 0.72), w * 0.055, paint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.72), w * 0.025, accentPaint);
    canvas.drawCircle(Offset(w * 0.31, h * 0.72), w * 0.055, paint);
    canvas.drawCircle(Offset(w * 0.31, h * 0.72), w * 0.025, accentPaint);

    // Window line
    final windowPath = Path();
    windowPath.moveTo(w * 0.40, h * 0.38);
    windowPath.lineTo(w * 0.60, h * 0.36);
    windowPath.lineTo(w * 0.72, h * 0.50);
    windowPath.lineTo(w * 0.52, h * 0.50);
    windowPath.close();
    canvas.drawPath(windowPath, paint);

    // Key fob outline accent
    final keyCenter = Offset(w * 0.88, h * 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: keyCenter, width: w * 0.12, height: h * 0.28),
        const Radius.circular(6),
      ),
      paint,
    );
    canvas.drawCircle(keyCenter.translate(0, -h * 0.05), 3, accentPaint);
  }

  /// Scrapyard: Heavy-duty mechanical engine block & turbocharger wireframe
  void _drawEngineBlock(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Main cylinder block
    final blockRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.25, h * 0.35, w * 0.55, h * 0.48),
      const Radius.circular(6),
    );
    canvas.drawRRect(blockRect, fillPaint);
    canvas.drawRRect(blockRect, accentPaint);

    // Cylinder head valve covers
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.30, h * 0.22, w * 0.45, h * 0.13),
        const Radius.circular(4),
      ),
      paint,
    );

    // Piston cylinder lines
    canvas.drawLine(Offset(w * 0.38, h * 0.35), Offset(w * 0.38, h * 0.70), paint);
    canvas.drawLine(Offset(w * 0.52, h * 0.35), Offset(w * 0.52, h * 0.70), paint);
    canvas.drawLine(Offset(w * 0.66, h * 0.35), Offset(w * 0.66, h * 0.70), paint);

    // Crankshaft pulley circle
    canvas.drawCircle(Offset(w * 0.52, h * 0.86), w * 0.08, accentPaint);
    canvas.drawCircle(Offset(w * 0.52, h * 0.86), w * 0.03, paint);

    // Turbocharger snail shell on the right
    final turboCenter = Offset(w * 0.82, h * 0.36);
    canvas.drawCircle(turboCenter, w * 0.14, paint);
    canvas.drawCircle(turboCenter, w * 0.07, accentPaint);
    // Exhaust pipe
    canvas.drawLine(Offset(w * 0.82, h * 0.22), Offset(w * 0.94, h * 0.18), paint);

    // Wrench tool cross
    canvas.drawLine(Offset(w * 0.12, h * 0.25), Offset(w * 0.28, h * 0.45), paint);
    canvas.drawLine(Offset(w * 0.12, h * 0.45), Offset(w * 0.28, h * 0.25), paint);
  }

  /// Showroom Mimari: Architectural minimalist showroom facade with spotlights
  void _drawShowroomArchitecture(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Ground platform / turntable
    final turntable = Path();
    turntable.addOval(Rect.fromCenter(
      center: Offset(w * 0.55, h * 0.82),
      width: w * 0.75,
      height: h * 0.24,
    ));
    canvas.drawPath(turntable, fillPaint);
    canvas.drawPath(turntable, paint);

    // Architectural pillar lines
    canvas.drawLine(Offset(w * 0.18, h * 0.18), Offset(w * 0.18, h * 0.80), accentPaint);
    canvas.drawLine(Offset(w * 0.50, h * 0.14), Offset(w * 0.50, h * 0.74), paint);
    canvas.drawLine(Offset(w * 0.85, h * 0.18), Offset(w * 0.85, h * 0.80), accentPaint);

    // Roof cantilever beam
    final roof = Path();
    roof.moveTo(w * 0.10, h * 0.22);
    roof.lineTo(w * 0.50, h * 0.12);
    roof.lineTo(w * 0.92, h * 0.22);
    canvas.drawPath(roof, accentPaint);

    // Glass panel diagonals
    canvas.drawLine(Offset(w * 0.18, h * 0.45), Offset(w * 0.50, h * 0.32), paint..strokeWidth = 1.0);
    canvas.drawLine(Offset(w * 0.50, h * 0.32), Offset(w * 0.85, h * 0.45), paint..strokeWidth = 1.0);

    // Spotlights cone beams
    canvas.drawLine(Offset(w * 0.25, h * 0.18), Offset(w * 0.45, h * 0.78), paint);
    canvas.drawLine(Offset(w * 0.75, h * 0.18), Offset(w * 0.55, h * 0.78), paint);
  }

  /// Consignment: Supercar on showroom podium with contract wax seal
  void _drawCarOnPodium(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Stepped podium
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.76, w * 0.76, h * 0.12), fillPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.12, h * 0.76, w * 0.76, h * 0.12), accentPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.22, h * 0.68, w * 0.56, h * 0.08), paint);

    // Stylized car top shape on podium
    final car = Path();
    car.moveTo(w * 0.26, h * 0.68);
    car.lineTo(w * 0.35, h * 0.48);
    car.lineTo(w * 0.55, h * 0.46);
    car.lineTo(w * 0.72, h * 0.68);
    car.close();
    canvas.drawPath(car, fillPaint);
    canvas.drawPath(car, paint);

    // Commission deal seal badge in corner
    final sealCenter = Offset(w * 0.78, h * 0.30);
    canvas.drawCircle(sealCenter, w * 0.13, accentPaint);
    canvas.drawCircle(sealCenter, w * 0.08, paint);
    // Handshake checkmark inside seal
    final check = Path();
    check.moveTo(sealCenter.dx - 6, sealCenter.dy);
    check.lineTo(sealCenter.dx - 1, sealCenter.dy + 5);
    check.lineTo(sealCenter.dx + 8, sealCenter.dy - 4);
    canvas.drawPath(check, accentPaint);
  }

  /// Night Market: Tuned Japanese street racer with rear wing, diffuser and exhaust flames
  void _drawTunedRacer(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Rear wing spoiler
    final spoiler = Path();
    spoiler.moveTo(w * 0.10, h * 0.28);
    spoiler.lineTo(w * 0.42, h * 0.26);
    spoiler.lineTo(w * 0.40, h * 0.32);
    spoiler.lineTo(w * 0.12, h * 0.34);
    spoiler.close();
    canvas.drawPath(spoiler, accentPaint);

    // Spoiler upright mounts
    canvas.drawLine(Offset(w * 0.18, h * 0.34), Offset(w * 0.22, h * 0.52), paint);
    canvas.drawLine(Offset(w * 0.34, h * 0.32), Offset(w * 0.36, h * 0.52), paint);

    // Fastback body curve
    final body = Path();
    body.moveTo(w * 0.14, h * 0.52);
    body.lineTo(w * 0.52, h * 0.48);
    body.lineTo(w * 0.85, h * 0.62);
    body.lineTo(w * 0.92, h * 0.74);
    body.lineTo(w * 0.20, h * 0.78);
    body.close();
    canvas.drawPath(body, fillPaint);
    canvas.drawPath(body, paint);

    // Rear diffuser fins
    for (int i = 0; i < 4; i++) {
      final x = w * (0.24 + i * 0.08);
      canvas.drawLine(Offset(x, h * 0.78), Offset(x, h * 0.88), accentPaint);
    }

    // Exhaust pipe & twin flames
    final exhaustTip = Offset(w * 0.16, h * 0.82);
    canvas.drawCircle(exhaustTip, 4, accentPaint);
    // Flame dart
    final flame = Path();
    flame.moveTo(exhaustTip.dx, exhaustTip.dy);
    flame.lineTo(w * 0.04, h * 0.80);
    flame.lineTo(w * 0.08, h * 0.83);
    flame.lineTo(w * 0.02, h * 0.86);
    flame.lineTo(exhaustTip.dx, exhaustTip.dy + 3);
    canvas.drawPath(flame, accentPaint);
  }

  /// Gossip: Radar receiver antenna mast with radio frequency wave pulses
  void _drawRadarAntenna(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    final mastBase = Offset(w * 0.35, h * 0.88);
    final mastTop = Offset(w * 0.35, h * 0.24);

    // Tower legs
    canvas.drawLine(mastBase.translate(-w * 0.14, 0), mastTop, accentPaint);
    canvas.drawLine(mastBase.translate(w * 0.14, 0), mastTop, accentPaint);
    // Tower cross bracing
    canvas.drawLine(Offset(w * 0.25, h * 0.70), Offset(w * 0.45, h * 0.50), paint);
    canvas.drawLine(Offset(w * 0.45, h * 0.70), Offset(w * 0.25, h * 0.50), paint);
    canvas.drawLine(Offset(w * 0.28, h * 0.50), Offset(w * 0.42, h * 0.36), paint);
    canvas.drawLine(Offset(w * 0.42, h * 0.50), Offset(w * 0.28, h * 0.36), paint);

    // Antenna transmitter sphere
    canvas.drawCircle(mastTop, 5, accentPaint);

    // Concentric pulsed radio waves
    for (int i = 1; i <= 3; i++) {
      final r = w * (0.18 * i);
      canvas.drawArc(
        Rect.fromCircle(center: mastTop, radius: r),
        -math.pi * 0.35,
        math.pi * 0.70,
        false,
        paint..strokeWidth = strokeWidth * (1.2 - i * 0.2),
      );
    }
  }

  /// Districts: Isometric tactical city territory grid with map marker flag
  void _drawIsometricCityGrid(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Isometric 3D diamond ground plane
    final ground = Path();
    ground.moveTo(w * 0.50, h * 0.42);
    ground.lineTo(w * 0.88, h * 0.62);
    ground.lineTo(w * 0.50, h * 0.88);
    ground.lineTo(w * 0.12, h * 0.62);
    ground.close();
    canvas.drawPath(ground, fillPaint);
    canvas.drawPath(ground, paint);

    // Grid subdivision lines
    canvas.drawLine(Offset(w * 0.31, h * 0.52), Offset(w * 0.69, h * 0.75), paint..strokeWidth = 1.0);
    canvas.drawLine(Offset(w * 0.69, h * 0.52), Offset(w * 0.31, h * 0.75), paint..strokeWidth = 1.0);

    // 3D Isometric building box
    final bldgLeft = Path();
    bldgLeft.moveTo(w * 0.45, h * 0.65);
    bldgLeft.lineTo(w * 0.45, h * 0.42);
    bldgLeft.lineTo(w * 0.55, h * 0.47);
    bldgLeft.lineTo(w * 0.55, h * 0.70);
    bldgLeft.close();
    canvas.drawPath(bldgLeft, fillPaint);
    canvas.drawPath(bldgLeft, accentPaint);

    final bldgRight = Path();
    bldgRight.moveTo(w * 0.55, h * 0.70);
    bldgRight.lineTo(w * 0.55, h * 0.47);
    bldgRight.lineTo(w * 0.65, h * 0.42);
    bldgRight.lineTo(w * 0.65, h * 0.65);
    bldgRight.close();
    canvas.drawPath(bldgRight, paint);

    // Pinpoint flag at summit
    final pin = Offset(w * 0.55, h * 0.28);
    canvas.drawLine(Offset(w * 0.55, h * 0.47), pin, accentPaint);
    final flag = Path();
    flag.moveTo(pin.dx, pin.dy);
    flag.lineTo(pin.dx + w * 0.15, pin.dy + h * 0.05);
    flag.lineTo(pin.dx, pin.dy + h * 0.10);
    flag.close();
    canvas.drawPath(flag, accentPaint);
  }

  /// Reviews: 5-Star reputation crest with radiant geometric rays
  void _drawReputationCrest(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    final center = Offset(w * 0.68, h * 0.50);
    final radius = w * 0.22;

    // Radiant rays
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi) / 4;
      final start = Offset(
        center.dx + (radius + 4) * math.cos(angle),
        center.dy + (radius + 4) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius + 12) * math.cos(angle),
        center.dy + (radius + 12) * math.sin(angle),
      );
      canvas.drawLine(start, end, paint..strokeWidth = 1.0);
    }

    // Outer polygon crest
    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, accentPaint);
    canvas.drawCircle(center, radius * 0.75, paint);

    // Big central star
    _drawStar(canvas, center, 5, radius * 0.55, radius * 0.25, accentPaint);
  }

  void _drawStar(Canvas canvas, Offset center, int points, double outerR, double innerR, Paint p) {
    final path = Path();
    final step = math.pi / points;
    double angle = -math.pi / 2;

    for (int i = 0; i < 2 * points; i++) {
      final r = (i % 2 == 0) ? outerR : innerR;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      angle += step;
    }
    path.close();
    canvas.drawPath(path, p);
  }

  /// Side Businesses: Industrial conglomerate skyline with ascending profit chart
  void _drawIndustrialConglomerate(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Factory rooftops / saw-tooth roof
    final sawRoof = Path();
    sawRoof.moveTo(w * 0.15, h * 0.85);
    sawRoof.lineTo(w * 0.15, h * 0.50);
    sawRoof.lineTo(w * 0.32, h * 0.62);
    sawRoof.lineTo(w * 0.32, h * 0.45);
    sawRoof.lineTo(w * 0.50, h * 0.58);
    sawRoof.lineTo(w * 0.50, h * 0.85);
    sawRoof.close();
    canvas.drawPath(sawRoof, fillPaint);
    canvas.drawPath(sawRoof, paint);

    // Tall office tower
    final tower = Rect.fromLTWH(w * 0.58, h * 0.28, w * 0.26, h * 0.57);
    canvas.drawRect(tower, fillPaint);
    canvas.drawRect(tower, accentPaint);

    // Office window grids
    canvas.drawLine(Offset(w * 0.67, h * 0.35), Offset(w * 0.67, h * 0.80), paint..strokeWidth = 1.0);
    canvas.drawLine(Offset(w * 0.76, h * 0.35), Offset(w * 0.76, h * 0.80), paint..strokeWidth = 1.0);

    // Ascending profit trendline
    final trend = Path();
    trend.moveTo(w * 0.08, h * 0.72);
    trend.lineTo(w * 0.35, h * 0.65);
    trend.lineTo(w * 0.55, h * 0.40);
    trend.lineTo(w * 0.92, h * 0.18);
    canvas.drawPath(trend, accentPaint..strokeWidth = 2.0);
    canvas.drawCircle(Offset(w * 0.92, h * 0.18), 4, accentPaint);
  }

  /// Casino: VIP Noir diamond / spade with golden roulette rim
  void _drawCasinoSpade(Canvas canvas, Size size, Paint paint, Paint accentPaint, Paint fillPaint) {
    final w = size.width;
    final h = size.height;

    // Roulette outer rim circle
    final center = Offset(w * 0.72, h * 0.50);
    final r = w * 0.20;
    canvas.drawCircle(center, r, fillPaint);
    canvas.drawCircle(center, r, accentPaint);

    // Sector tick marks
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi) / 6;
      final p1 = Offset(center.dx + (r - 5) * math.cos(angle), center.dy + (r - 5) * math.sin(angle));
      final p2 = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      canvas.drawLine(p1, p2, paint);
    }

    // Playing card spade silhouette
    final spade = Path();
    final sc = center;
    spade.moveTo(sc.dx, sc.dy - 14);
    spade.cubicTo(sc.dx - 12, sc.dy - 6, sc.dx - 12, sc.dy + 4, sc.dx, sc.dy + 8);
    spade.cubicTo(sc.dx + 12, sc.dy + 4, sc.dx + 12, sc.dy - 6, sc.dx, sc.dy - 14);
    // Spade stem
    spade.moveTo(sc.dx, sc.dy + 8);
    spade.lineTo(sc.dx - 4, sc.dy + 14);
    spade.lineTo(sc.dx + 4, sc.dy + 14);
    spade.close();
    canvas.drawPath(spade, accentPaint);
  }

  void _drawTechnicalGrid(Canvas canvas, Size size, Paint paint) {
    final w = size.width;
    final h = size.height;
    for (double x = 0; x < w; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint..strokeWidth = 0.5);
    }
    for (double y = 0; y < h; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(w, y), paint..strokeWidth = 0.5);
    }
  }

  @override
  bool shouldRepaint(covariant _HubIllustrationPainter oldDelegate) {
    return oldDelegate.route != route ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
