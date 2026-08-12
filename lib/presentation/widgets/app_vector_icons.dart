import 'package:flutter/material.dart';

class VectorIconWidget extends StatelessWidget {
  final String type; // 'car', 'expertise', 'workshop', 'negotiation', 'theme_store', 'streak'
  final Color color;
  final double size;

  const VectorIconWidget({
    super.key,
    required this.type,
    required this.color,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VectorIconPainter(type: type, iconColor: color),
    );
  }
}

class _VectorIconPainter extends CustomPainter {
  final String type;
  final Color iconColor;

  _VectorIconPainter({required this.type, required this.iconColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case 'expertise':
        // Magnifying Glass + Inspection Badge
        canvas.drawCircle(Offset(w * 0.45, h * 0.45), w * 0.30, paint);
        canvas.drawLine(Offset(w * 0.65, h * 0.65), Offset(w * 0.90, h * 0.90), paint);
        canvas.drawCircle(Offset(w * 0.45, h * 0.45), w * 0.10, fillPaint);
        break;

      case 'workshop':
        // Wrench & Gear
        final path = Path();
        path.moveTo(w * 0.20, h * 0.80);
        path.lineTo(w * 0.60, h * 0.40);
        path.arcToPoint(Offset(w * 0.80, h * 0.20), radius: Radius.circular(w * 0.2));
        path.lineTo(w * 0.70, h * 0.30);
        path.lineTo(w * 0.50, h * 0.50);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'negotiation':
        // Handshake / Contract Document
        final path = Path();
        path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.10, w * 0.70, h * 0.80), const Radius.circular(4)));
        canvas.drawPath(path, paint);
        canvas.drawLine(Offset(w * 0.30, h * 0.35), Offset(w * 0.70, h * 0.35), paint);
        canvas.drawLine(Offset(w * 0.30, h * 0.55), Offset(w * 0.70, h * 0.55), paint);
        canvas.drawLine(Offset(w * 0.30, h * 0.70), Offset(w * 0.55, h * 0.70), paint);
        break;

      case 'theme_store':
        // Color Palette & Brush
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.40, paint);
        canvas.drawCircle(Offset(w * 0.35, h * 0.35), w * 0.08, fillPaint);
        canvas.drawCircle(Offset(w * 0.65, h * 0.35), w * 0.08, fillPaint);
        canvas.drawCircle(Offset(w * 0.30, h * 0.60), w * 0.08, fillPaint);
        break;

      case 'streak':
        // Flame Silhouette
        final path = Path();
        path.moveTo(w * 0.50, h * 0.10);
        path.quadraticBezierTo(w * 0.85, h * 0.45, w * 0.85, h * 0.70);
        path.arcToPoint(Offset(w * 0.15, h * 0.70), radius: Radius.circular(w * 0.35));
        path.quadraticBezierTo(w * 0.15, h * 0.45, w * 0.50, h * 0.10);
        canvas.drawPath(path, fillPaint);
        break;

      case 'car':
      default:
        // Minimalist Car Silhouette Icon
        final path = Path();
        path.moveTo(w * 0.10, h * 0.65);
        path.quadraticBezierTo(w * 0.25, h * 0.35, w * 0.40, h * 0.30);
        path.lineTo(w * 0.65, h * 0.30);
        path.quadraticBezierTo(w * 0.80, h * 0.35, w * 0.90, h * 0.65);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w * 0.28, h * 0.68), w * 0.10, fillPaint);
        canvas.drawCircle(Offset(w * 0.72, h * 0.68), w * 0.10, fillPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _VectorIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.iconColor != iconColor;
}
