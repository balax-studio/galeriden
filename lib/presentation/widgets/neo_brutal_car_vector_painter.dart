import 'package:flutter/material.dart';

/// Neo-Brutalist 2D Blueprint & Cel-Shaded Vehicle Side-Profile Vector Painter.
///
/// Features:
/// 1. Bold 2.0px Ink Outlines for comic/neo-brutalist aesthetic.
/// 2. Body-Type Specific Geometry: Sedan, Hatchback, SUV, Sport/Coupe, Classic, Van/Commercial.
/// 3. Cel-Shaded Glass with Angular Gloss Reflection Highlights.
/// 4. Hard Offset Block Ground Shadow (zero fuzzy blur, true neo-brutalism).
/// 5. Distinct Headlight (amber/xenon) and Taillight (crimson) lenses.
/// 6. Heavy-Duty Custom Wheels with styled alloy rims and brake caliper accents.
class NeoBrutalCarVectorPainter extends CustomPainter {
  final Color bodyColor;
  final String bodyType;
  final bool isClean;
  final bool isTuned;
  final double damagePercent;
  final bool isDark;

  NeoBrutalCarVectorPainter({
    required this.bodyColor,
    this.bodyType = 'Sedan',
    this.isClean = false,
    this.isTuned = false,
    this.damagePercent = 0.0,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Coordinate space normalized to 100 x 50
    final double scaleX = size.width / 100.0;
    final double scaleY = size.height / 50.0;
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    final double offsetX = (size.width - (100.0 * scale)) / 2;
    final double offsetY = (size.height - (50.0 * scale)) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    _drawGroundShadow(canvas);
    _drawCarBody(canvas);
    _drawWindowsAndCabin(canvas);
    _drawLightsAndTrim(canvas);
    _drawWheels(canvas);
    if (isTuned) {
      _drawTuningSpoiler(canvas);
    }
    if (damagePercent > 20) {
      _drawDamageScratches(canvas);
    }
    if (isClean) {
      _drawCleanSparkles(canvas);
    }

    canvas.restore();
  }

  void _drawGroundShadow(Canvas canvas) {
    // Neo-Brutalist Hard Block Shadow underneath tires
    final shadowPaint = Paint()
      ..color = (isDark ? Colors.black : const Color(0xFF0F172A)).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final shadowRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 42, 84, 5),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(shadowRect, shadowPaint);
  }

  void _drawCarBody(Canvas canvas) {
    final Path bodyPath = Path();
    final normalizedType = bodyType.toLowerCase();

    if (normalizedType.contains('suv') || normalizedType.contains('4x4') || normalizedType.contains('jeep')) {
      // SUV: Tall, rugged, boxy hood, high roof
      bodyPath.moveTo(6, 38);
      bodyPath.lineTo(14, 38);
      // Front Wheel Arch
      bodyPath.arcToPoint(const Offset(30, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(68, 38);
      // Rear Wheel Arch
      bodyPath.arcToPoint(const Offset(84, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(94, 38);
      bodyPath.lineTo(94, 22); // Tall flat rear
      bodyPath.lineTo(91, 14); // Rear roof edge
      bodyPath.lineTo(44, 14); // Flat roof
      bodyPath.lineTo(26, 23); // Windshield slope
      bodyPath.lineTo(6, 24);  // High boxy hood
      bodyPath.lineTo(5, 34);  // Front bumper
      bodyPath.close();
    } else if (normalizedType.contains('hatch') || normalizedType.contains('kompakt')) {
      // Hatchback: Compact 2-box, steep rear slope
      bodyPath.moveTo(7, 38);
      bodyPath.lineTo(15, 38);
      // Front Wheel Arch
      bodyPath.arcToPoint(const Offset(31, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(67, 38);
      // Rear Wheel Arch
      bodyPath.arcToPoint(const Offset(83, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(93, 38);
      bodyPath.lineTo(93, 27); // Rear bumper
      bodyPath.lineTo(84, 18); // Steep hatch slope
      bodyPath.lineTo(42, 17); // Roof
      bodyPath.lineTo(24, 25); // Windshield
      bodyPath.lineTo(7, 26);  // Hood
      bodyPath.lineTo(6, 35);  // Front nose
      bodyPath.close();
    } else if (normalizedType.contains('spor') || normalizedType.contains('sport') || normalizedType.contains('coupe') || normalizedType.contains('cabrio')) {
      // Sport / Coupe: Low wedge profile, aerodynamic sweep
      bodyPath.moveTo(6, 38);
      bodyPath.lineTo(14, 38);
      // Front Wheel Arch
      bodyPath.arcToPoint(const Offset(30, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(69, 38);
      // Rear Wheel Arch
      bodyPath.arcToPoint(const Offset(85, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(95, 38);
      bodyPath.lineTo(95, 30); // Low rear bumper
      bodyPath.lineTo(87, 26); // Short trunk lip
      bodyPath.lineTo(70, 19); // Fastback slope
      bodyPath.lineTo(45, 18); // Low roof
      bodyPath.lineTo(28, 26); // Long rake windshield
      bodyPath.lineTo(6, 29);  // Low pointed nose
      bodyPath.lineTo(5, 36);
      bodyPath.close();
    } else if (normalizedType.contains('klasik') || normalizedType.contains('classic')) {
      // Classic: Curved vintage fenders, rounded roof
      bodyPath.moveTo(6, 38);
      bodyPath.lineTo(13, 38);
      bodyPath.arcToPoint(const Offset(31, 38), radius: const Radius.circular(9), clockwise: false);
      bodyPath.lineTo(67, 38);
      bodyPath.arcToPoint(const Offset(85, 38), radius: const Radius.circular(9), clockwise: false);
      bodyPath.lineTo(94, 38);
      bodyPath.lineTo(94, 28);
      bodyPath.lineTo(86, 26); // Vintage rounded boot
      bodyPath.lineTo(72, 17); // Rounded C pillar
      bodyPath.lineTo(40, 16); // High dome roof
      bodyPath.lineTo(26, 24); // Windshield
      bodyPath.lineTo(7, 27);  // Long straight classic hood
      bodyPath.lineTo(5, 35);
      bodyPath.close();
    } else if (normalizedType.contains('van') || normalizedType.contains('station') || normalizedType.contains('ticari')) {
      // Commercial Van / Station: High long roof, maximal cargo box
      bodyPath.moveTo(6, 38);
      bodyPath.lineTo(14, 38);
      bodyPath.arcToPoint(const Offset(30, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(68, 38);
      bodyPath.arcToPoint(const Offset(84, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(94, 38);
      bodyPath.lineTo(95, 14); // Tall vertical van rear
      bodyPath.lineTo(40, 13); // High flat roof
      bodyPath.lineTo(22, 23); // Short van nose slope
      bodyPath.lineTo(6, 25);
      bodyPath.lineTo(5, 35);
      bodyPath.close();
    } else {
      // Standard Sedan (Default 3-Box): Balanced Hood, Cabin & Boot
      bodyPath.moveTo(6, 38);
      bodyPath.lineTo(14, 38);
      // Front Wheel Arch
      bodyPath.arcToPoint(const Offset(30, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(68, 38);
      // Rear Wheel Arch
      bodyPath.arcToPoint(const Offset(84, 38), radius: const Radius.circular(8), clockwise: false);
      bodyPath.lineTo(94, 38);
      bodyPath.lineTo(94, 29); // Rear bumper
      bodyPath.lineTo(85, 25); // Sedan trunk decklid
      bodyPath.lineTo(72, 17); // Rear windshield slope
      bodyPath.lineTo(42, 17); // Roof
      bodyPath.lineTo(25, 25); // Front windshield rake
      bodyPath.lineTo(6, 27);  // Sedan hood
      bodyPath.lineTo(5, 35);  // Front grill nose
      bodyPath.close();
    }

    // 1. Paint Body Fill
    final fillPaint = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, fillPaint);

    // 2. Subtle Lower Skirt Shadow (Adds Depth without blur)
    final skirtPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final skirtPath = Path()
      ..moveTo(6, 34)
      ..lineTo(94, 34)
      ..lineTo(94, 38)
      ..lineTo(6, 38)
      ..close();
    canvas.drawPath(skirtPath, skirtPaint);

    // 3. Bold Neo-Brutalist Black Ink Outline
    final outlinePaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : Colors.black
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(bodyPath, outlinePaint);
  }

  void _drawWindowsAndCabin(Canvas canvas) {
    final normalizedType = bodyType.toLowerCase();

    final windowPaint = Paint()
      ..color = const Color(0xFF1E293B) // Dark obsidian tinted glass
      ..style = PaintingStyle.fill;

    final windowOutline = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : Colors.black
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final glossHighlight = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.75) // Cyan Cel-Shaded highlight
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    if (normalizedType.contains('suv') || normalizedType.contains('4x4')) {
      // SUV Front & Rear Windows
      final frontWin = Path()
        ..moveTo(28, 23)
        ..lineTo(44, 16)
        ..lineTo(44, 25)
        ..lineTo(27, 25)
        ..close();
      final rearWin = Path()
        ..moveTo(47, 16)
        ..lineTo(86, 16)
        ..lineTo(86, 25)
        ..lineTo(47, 25)
        ..close();

      canvas.drawPath(frontWin, windowPaint);
      canvas.drawPath(rearWin, windowPaint);
      canvas.drawPath(frontWin, windowOutline);
      canvas.drawPath(rearWin, windowOutline);
      // Cel-Shading Gloss
      canvas.drawLine(const Offset(31, 23), const Offset(42, 17), glossHighlight);
      canvas.drawLine(const Offset(52, 23), const Offset(62, 17), glossHighlight);
    } else if (normalizedType.contains('spor') || normalizedType.contains('coupe') || normalizedType.contains('cabrio')) {
      // Sport Coupe Sleek Curved Glass
      final sportWin = Path()
        ..moveTo(30, 26)
        ..lineTo(47, 20)
        ..lineTo(68, 20)
        ..lineTo(68, 26)
        ..close();
      canvas.drawPath(sportWin, windowPaint);
      canvas.drawPath(sportWin, windowOutline);
      canvas.drawLine(const Offset(34, 25), const Offset(46, 21), glossHighlight);
      canvas.drawLine(const Offset(52, 25), const Offset(64, 21), glossHighlight);
    } else {
      // Standard Sedan / Hatch / Classic Dual Windows
      final frontWin = Path()
        ..moveTo(28, 24)
        ..lineTo(43, 19)
        ..lineTo(43, 26)
        ..lineTo(26, 26)
        ..close();

      final rearWin = Path()
        ..moveTo(46, 19)
        ..lineTo(70, 19)
        ..lineTo(70, 26)
        ..lineTo(46, 26)
        ..close();

      canvas.drawPath(frontWin, windowPaint);
      canvas.drawPath(rearWin, windowPaint);
      canvas.drawPath(frontWin, windowOutline);
      canvas.drawPath(rearWin, windowOutline);

      // Cel-Shading Gloss
      canvas.drawLine(const Offset(30, 24), const Offset(41, 20), glossHighlight);
      canvas.drawLine(const Offset(50, 24), const Offset(61, 20), glossHighlight);
    }

    // Door Handle Accent
    final handlePaint = Paint()
      ..color = isDark ? Colors.white : Colors.black
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(47, 28), const Offset(53, 28), handlePaint);
  }

  void _drawLightsAndTrim(Canvas canvas) {
    // 1. Headlight (Amber/Neon Front Lamp)
    final headLightPaint = Paint()
      ..color = const Color(0xFFFFDE59) // Neon Esnaf Yellow
      ..style = PaintingStyle.fill;
    final headLightOutline = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final headLightRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(5, 27, 4, 4),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(headLightRect, headLightPaint);
    canvas.drawRRect(headLightRect, headLightOutline);

    // 2. Taillight (Crimson Rear Lamp)
    final tailLightPaint = Paint()
      ..color = const Color(0xFFFF3366) // Brutal Crimson Red
      ..style = PaintingStyle.fill;
    final tailLightOutline = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final tailLightRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(91, 27, 4, 4),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(tailLightRect, tailLightPaint);
    canvas.drawRRect(tailLightRect, tailLightOutline);
  }

  void _drawWheels(Canvas canvas) {
    const frontCenter = Offset(22, 38);
    const rearCenter = Offset(76, 38);
    const radius = 7.5;

    final tirePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;

    final tireOutline = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final rimPaint = Paint()
      ..color = const Color(0xFFE2E8F0) // Clean Silver Rim
      ..style = PaintingStyle.fill;

    final hubPaint = Paint()
      ..color = const Color(0xFFFFDE59) // Esnaf Gold Hub
      ..style = PaintingStyle.fill;

    // Draw Front Wheel
    canvas.drawCircle(frontCenter, radius, tirePaint);
    canvas.drawCircle(frontCenter, radius, tireOutline);
    canvas.drawCircle(frontCenter, radius * 0.55, rimPaint);
    canvas.drawCircle(frontCenter, radius * 0.22, hubPaint);

    // Draw Rear Wheel
    canvas.drawCircle(rearCenter, radius, tirePaint);
    canvas.drawCircle(rearCenter, radius, tireOutline);
    canvas.drawCircle(rearCenter, radius * 0.55, rimPaint);
    canvas.drawCircle(rearCenter, radius * 0.22, hubPaint);
  }

  void _drawTuningSpoiler(Canvas canvas) {
    // Sport Tuning Wing on Trunk
    final spoilerPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    final spoilerOutline = Paint()
      ..color = Colors.black
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final spoilerPath = Path()
      ..moveTo(88, 24)
      ..lineTo(97, 20)
      ..lineTo(98, 22)
      ..lineTo(90, 26)
      ..close();

    canvas.drawPath(spoilerPath, spoilerPaint);
    canvas.drawPath(spoilerPath, spoilerOutline);
    canvas.drawLine(const Offset(89, 25), const Offset(89, 28), spoilerOutline);
  }

  void _drawDamageScratches(Canvas canvas) {
    final scratchPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(12, 30), const Offset(18, 35), scratchPaint);
    if (damagePercent > 50) {
      canvas.drawLine(const Offset(54, 30), const Offset(62, 34), scratchPaint);
    }
  }

  void _drawCleanSparkles(Canvas canvas) {
    // Detailed & Clean 4-Point Star Sparkle
    _drawSparkle(canvas, const Offset(10, 20), 4.0);
    _drawSparkle(canvas, const Offset(82, 12), 5.0);
  }

  void _drawSparkle(Canvas canvas, Offset center, double size) {
    final sparklePaint = Paint()
      ..color = const Color(0xFFFFDE59)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size)
      ..close();

    canvas.drawPath(path, sparklePaint);
    canvas.drawPath(path, Paint()..color = Colors.black..strokeWidth = 1.0..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(covariant NeoBrutalCarVectorPainter oldDelegate) {
    return oldDelegate.bodyColor != bodyColor ||
        oldDelegate.bodyType != bodyType ||
        oldDelegate.isClean != isClean ||
        oldDelegate.isTuned != isTuned ||
        oldDelegate.damagePercent != damagePercent ||
        oldDelegate.isDark != isDark;
  }
}
