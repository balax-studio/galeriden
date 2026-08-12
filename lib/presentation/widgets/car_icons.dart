import 'package:flutter/material.dart';

class CarSilhouetteWidget extends StatelessWidget {
  final String bodyType;
  final Color color;
  final double width;
  final double height;

  const CarSilhouetteWidget({
    super.key,
    required this.bodyType,
    required this.color,
    this.width = 64.0,
    this.height = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CarSilhouettePainter(bodyType: bodyType, carColor: color),
    );
  }
}

class _CarSilhouettePainter extends CustomPainter {
  final String bodyType;
  final Color carColor;

  _CarSilhouettePainter({required this.bodyType, required this.carColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = carColor
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final wheelPaint = Paint()
      ..color = const Color(0xFF222225)
      ..style = PaintingStyle.fill;

    final wheelRimPaint = Paint()
      ..color = const Color(0xFF888888)
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    switch (bodyType.toLowerCase()) {
      case 'spor':
        path.moveTo(w * 0.05, h * 0.70);
        path.quadraticBezierTo(w * 0.15, h * 0.45, w * 0.35, h * 0.40);
        path.quadraticBezierTo(w * 0.50, h * 0.25, w * 0.70, h * 0.35);
        path.quadraticBezierTo(w * 0.85, h * 0.50, w * 0.95, h * 0.70);
        path.lineTo(w * 0.05, h * 0.70);
        break;

      case 'suv':
        path.moveTo(w * 0.05, h * 0.75);
        path.lineTo(w * 0.10, h * 0.40);
        path.lineTo(w * 0.35, h * 0.25);
        path.lineTo(w * 0.75, h * 0.25);
        path.lineTo(w * 0.90, h * 0.45);
        path.lineTo(w * 0.95, h * 0.75);
        path.close();
        break;

      case 'hatchback':
        path.moveTo(w * 0.05, h * 0.70);
        path.quadraticBezierTo(w * 0.15, h * 0.40, w * 0.35, h * 0.30);
        path.lineTo(w * 0.70, h * 0.30);
        path.lineTo(w * 0.85, h * 0.45);
        path.lineTo(w * 0.92, h * 0.70);
        path.close();
        break;

      case 'klasik':
        path.moveTo(w * 0.05, h * 0.70);
        path.quadraticBezierTo(w * 0.10, h * 0.50, w * 0.25, h * 0.45);
        path.quadraticBezierTo(w * 0.45, h * 0.25, w * 0.65, h * 0.40);
        path.quadraticBezierTo(w * 0.80, h * 0.45, w * 0.95, h * 0.70);
        path.close();
        break;

      case 'sedan':
      default:
        path.moveTo(w * 0.05, h * 0.70);
        path.quadraticBezierTo(w * 0.15, h * 0.45, w * 0.30, h * 0.35);
        path.lineTo(w * 0.65, h * 0.35);
        path.quadraticBezierTo(w * 0.78, h * 0.45, w * 0.95, h * 0.70);
        path.close();
        break;
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(path, outlinePaint);

    // Draw wheels
    final wheelRadius = h * 0.22;
    canvas.drawCircle(Offset(w * 0.25, h * 0.75), wheelRadius, wheelPaint);
    canvas.drawCircle(Offset(w * 0.25, h * 0.75), wheelRadius * 0.5, wheelRimPaint);

    canvas.drawCircle(Offset(w * 0.75, h * 0.75), wheelRadius, wheelPaint);
    canvas.drawCircle(Offset(w * 0.75, h * 0.75), wheelRadius * 0.5, wheelRimPaint);
  }

  @override
  bool shouldRepaint(covariant _CarSilhouettePainter oldDelegate) =>
      oldDelegate.bodyType != bodyType || oldDelegate.carColor != carColor;
}
