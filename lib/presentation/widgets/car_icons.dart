import 'package:flutter/material.dart';
import 'isometric_3d_car_painter.dart';

class CarSilhouetteWidget extends StatelessWidget {
  final String bodyType;
  final Color color;
  final double width;
  final double height;
  final bool showBackgroundPod;

  const CarSilhouetteWidget({
    super.key,
    required this.bodyType,
    required this.color,
    this.width = 72.0,
    this.height = 36.0,
    this.showBackgroundPod = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color == Colors.transparent ? Colors.cyanAccent : color;
    
    Widget content = CustomPaint(
      size: Size(width, height),
      painter: Isometric3DCarPainter(
        bodyColor: effectiveColor,
        category: bodyType,
        isHeadlightOn: true,
      ),
    );

    if (!showBackgroundPod) return content;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveColor.withValues(alpha: 0.25),
            effectiveColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.4), width: 1),
        boxShadow: [
          BoxShadow(
            color: effectiveColor.withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: content,
    );
  }
}

class _CarSilhouettePainter extends CustomPainter {
  final String bodyType;
  final Color carColor;

  _CarSilhouettePainter({required this.bodyType, required this.carColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    final glassPath = Path();

    switch (bodyType.toLowerCase()) {
      case 'spor':
        path.moveTo(w * 0.04, h * 0.70);
        path.quadraticBezierTo(w * 0.15, h * 0.48, w * 0.32, h * 0.42);
        path.quadraticBezierTo(w * 0.48, h * 0.22, w * 0.68, h * 0.35);
        path.quadraticBezierTo(w * 0.85, h * 0.48, w * 0.96, h * 0.70);
        path.lineTo(w * 0.04, h * 0.70);

        // Windshield
        glassPath.moveTo(w * 0.35, h * 0.42);
        glassPath.lineTo(w * 0.48, h * 0.26);
        glassPath.lineTo(w * 0.64, h * 0.34);
        glassPath.close();
        break;

      case 'suv':
        path.moveTo(w * 0.05, h * 0.72);
        path.lineTo(w * 0.08, h * 0.42);
        path.lineTo(w * 0.32, h * 0.26);
        path.lineTo(w * 0.74, h * 0.26);
        path.lineTo(w * 0.90, h * 0.46);
        path.lineTo(w * 0.95, h * 0.72);
        path.close();

        // Windshield
        glassPath.moveTo(w * 0.34, h * 0.28);
        glassPath.lineTo(w * 0.52, h * 0.28);
        glassPath.lineTo(w * 0.52, h * 0.44);
        glassPath.lineTo(w * 0.14, h * 0.44);
        glassPath.close();
        break;

      case 'hatchback':
        path.moveTo(w * 0.05, h * 0.70);
        path.quadraticBezierTo(w * 0.15, h * 0.42, w * 0.34, h * 0.32);
        path.lineTo(w * 0.72, h * 0.32);
        path.lineTo(w * 0.86, h * 0.46);
        path.lineTo(w * 0.94, h * 0.70);
        path.close();

        // Windshield
        glassPath.moveTo(w * 0.36, h * 0.34);
        glassPath.lineTo(w * 0.54, h * 0.34);
        glassPath.lineTo(w * 0.54, h * 0.46);
        glassPath.lineTo(w * 0.20, h * 0.46);
        glassPath.close();
        break;

      case 'klasik':
        path.moveTo(w * 0.04, h * 0.70);
        path.quadraticBezierTo(w * 0.12, h * 0.50, w * 0.26, h * 0.46);
        path.quadraticBezierTo(w * 0.46, h * 0.26, w * 0.66, h * 0.42);
        path.quadraticBezierTo(w * 0.82, h * 0.46, w * 0.96, h * 0.70);
        path.close();

        // Windshield
        glassPath.moveTo(w * 0.30, h * 0.44);
        glassPath.lineTo(w * 0.46, h * 0.28);
        glassPath.lineTo(w * 0.62, h * 0.42);
        glassPath.close();
        break;

      case 'sedan':
      default:
        path.moveTo(w * 0.04, h * 0.70);
        path.quadraticBezierTo(w * 0.14, h * 0.46, w * 0.28, h * 0.36);
        path.lineTo(w * 0.66, h * 0.36);
        path.quadraticBezierTo(w * 0.80, h * 0.46, w * 0.96, h * 0.70);
        path.close();

        // Windshield
        glassPath.moveTo(w * 0.30, h * 0.38);
        glassPath.lineTo(w * 0.46, h * 0.26);
        glassPath.lineTo(w * 0.62, h * 0.38);
        glassPath.close();
        break;
    }

    // Body Metallic Gradient Paint
    final metallicPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(carColor, Colors.white, 0.45)!,
          carColor,
          Color.lerp(carColor, Colors.black, 0.5)!,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Glass tint paint
    final glassPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Headlight glow
    final headlightPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4);

    final taillightPaint = Paint()
      ..color = Colors.redAccent
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);

    // Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF151518)
      ..style = PaintingStyle.fill;

    final wheelRimPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    // Draw Body & Glass
    canvas.drawPath(path, metallicPaint);
    canvas.drawPath(glassPath, glassPaint);
    canvas.drawPath(path, outlinePaint);

    // Draw Headlights & Taillights
    canvas.drawCircle(Offset(w * 0.07, h * 0.62), 2.5, headlightPaint);
    canvas.drawCircle(Offset(w * 0.93, h * 0.62), 2.5, taillightPaint);

    // Draw Alloy Wheels
    final wheelRadius = h * 0.22;
    final frontWheelCenter = Offset(w * 0.24, h * 0.74);
    final rearWheelCenter = Offset(w * 0.76, h * 0.74);

    canvas.drawCircle(frontWheelCenter, wheelRadius, wheelPaint);
    canvas.drawCircle(frontWheelCenter, wheelRadius * 0.55, wheelRimPaint);
    canvas.drawCircle(frontWheelCenter, wheelRadius * 0.25, wheelPaint);

    canvas.drawCircle(rearWheelCenter, wheelRadius, wheelPaint);
    canvas.drawCircle(rearWheelCenter, wheelRadius * 0.55, wheelRimPaint);
    canvas.drawCircle(rearWheelCenter, wheelRadius * 0.25, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant _CarSilhouettePainter oldDelegate) =>
      oldDelegate.bodyType != bodyType || oldDelegate.carColor != carColor;
}
