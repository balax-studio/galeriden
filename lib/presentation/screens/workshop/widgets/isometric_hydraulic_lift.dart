import 'package:flutter/material.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../core/theme/app_colors.dart';

class IsometricHydraulicLiftWidget extends StatefulWidget {
  final CarModel car;
  final ThemePaletteModel p;

  const IsometricHydraulicLiftWidget({super.key, required this.car, required this.p});

  @override
  State<IsometricHydraulicLiftWidget> createState() => _IsometricHydraulicLiftWidgetState();
}

class _IsometricHydraulicLiftWidgetState extends State<IsometricHydraulicLiftWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carColor = Color(int.parse(widget.car.colorHex.replaceFirst('#', '0xff')));
    final p = widget.p;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.isometricGridDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: p.primaryColor.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.12),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Isometric Hydraulic Lift Stand with Animated Sparks
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 110),
                  painter: _LiftPainter(
                    primaryColor: p.primaryColor,
                    carColor: carColor,
                    animProgress: _animController.value,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.neonCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.neonCyan, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.build_circle_rounded, color: AppColors.neonCyan, size: 12),
                  SizedBox(width: 4),
                  Text('LİFTTE', style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftPainter extends CustomPainter {
  final Color primaryColor;
  final Color carColor;
  final double animProgress;

  _LiftPainter({required this.primaryColor, required this.carColor, required this.animProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // Hydraulic Lift Arms
    final armPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(center.dx - 40, center.dy + 20), Offset(center.dx - 40, center.dy - 10), armPaint);
    canvas.drawLine(Offset(center.dx + 40, center.dy + 20), Offset(center.dx + 40, center.dy - 10), armPaint);

    // Platform Base
    final platformPath = Path()
      ..moveTo(center.dx, center.dy - 20)
      ..lineTo(center.dx + 55, center.dy - 10)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx - 55, center.dy - 10)
      ..close();
    canvas.drawPath(platformPath, Paint()..color = primaryColor.withValues(alpha: 0.3));
    canvas.drawPath(platformPath, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Car Silhouette elevated on hydraulic lift
    final carPath = Path()
      ..moveTo(center.dx, center.dy - 35)
      ..lineTo(center.dx + 28, center.dy - 23)
      ..lineTo(center.dx, center.dy - 11)
      ..lineTo(center.dx - 28, center.dy - 23)
      ..close();
    canvas.drawPath(carPath, Paint()..color = carColor);

    // Animated Repair Sparks (Juiciness effect)
    final sparkPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final spark1Offset = Offset(center.dx - 20 + (animProgress * 15), center.dy - 25 - (animProgress * 8));
    final spark2Offset = Offset(center.dx + 18 - (animProgress * 12), center.dy - 30 - (animProgress * 6));
    canvas.drawCircle(spark1Offset, 2.5, sparkPaint);
    canvas.drawCircle(spark2Offset, 2.0, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _LiftPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress || oldDelegate.carColor != carColor;
  }
}
