import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../providers/game_provider.dart';

/// 2.5D Isometric Coordinate Helper
class IsometricMath {
  static Offset isoToScreen(double row, double col, double tileWidth, double tileHeight, Offset origin) {
    final x = (col - row) * (tileWidth / 2) + origin.dx;
    final y = (col + row) * (tileHeight / 2) + origin.dy;
    return Offset(x, y);
  }

  static MathIsoPoint screenToIso(Offset pt, double tileWidth, double tileHeight, Offset origin) {
    final relX = pt.dx - origin.dx;
    final relY = pt.dy - origin.dy;
    final col = (relX / (tileWidth / 2) + relY / (tileHeight / 2)) / 2;
    final row = (relY / (tileHeight / 2) - relX / (tileWidth / 2)) / 2;
    return MathIsoPoint(row: row.roundToDouble(), col: col.roundToDouble());
  }
}

class MathIsoPoint {
  final double row;
  final double col;
  const MathIsoPoint({required this.row, required this.col});
}

/// Interactive 2D Isometric Dealership Showroom Canvas Widget
class IsometricShowroomCanvas extends ConsumerStatefulWidget {
  const IsometricShowroomCanvas({super.key});

  @override
  ConsumerState<IsometricShowroomCanvas> createState() => _IsometricShowroomCanvasState();
}

class _IsometricShowroomCanvasState extends ConsumerState<IsometricShowroomCanvas>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapUp(TapUpDetails details, Size canvasSize, int maxSlots, List<CarModel> cars) {
    final origin = Offset(canvasSize.width / 2, 40);
    const tileWidth = 110.0;
    const tileHeight = 55.0;

    final touchPoint = details.localPosition;
    final isoPt = IsometricMath.screenToIso(touchPoint, tileWidth, tileHeight, origin);

    // Map 2D grid matrix to slot index (3 columns layout)
    final col = isoPt.col.toInt();
    final row = isoPt.row.toInt();

    if (row >= 0 && row < 3 && col >= 0 && col < (maxSlots / 3).ceil()) {
      final slotIndex = row * 3 + col;
      if (slotIndex >= 0 && slotIndex < maxSlots) {
        if (slotIndex < cars.length) {
          final selectedCar = cars[slotIndex];
          _showCarDetailsSheet(context, selectedCar);
        } else {
          context.push('/marketplace');
        }
      }
    }
  }

  void _showCarDetailsSheet(BuildContext context, CarModel car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
        final p = themeExt.palette;
        return Container(
          decoration: BoxDecoration(
            color: p.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: p.surfaceBorderColor),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: p.surfaceBorderColor, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark)),
              const SizedBox(height: 8),
              Text(
                'Değer: ${CurrencyFormatter.format(car.estimatedRealValue)} | Yıl: ${car.modelYear}',
                style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/showroom');
                      },
                      icon: const Icon(Icons.storefront_rounded),
                      label: const Text('Vitrine Git'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: p.surfaceBorderColor),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/workshop');
                      },
                      icon: const Icon(Icons.build_rounded),
                      label: const Text('Atölyeye Al'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.view_in_ar_rounded, color: AppColors.neonCyan, size: 20),
                const SizedBox(width: 6),
                Text(
                  '2.5D İZOMETRİK GALERİ SAHNESİ',
                  style: AppTypography.labelSmall(isDark).copyWith(
                    color: AppColors.neonCyan,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.laserGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.laserGreen.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_filled_rounded, color: AppColors.laserGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${game.ownedCars.length}/${game.maxGarageSlots} Dolu',
                    style: const TextStyle(color: AppColors.laserGreen, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                const height = 280.0;
                final canvasSize = Size(width, height);

                return GestureDetector(
                  onTapUp: (details) => _handleTapUp(details, canvasSize, game.maxGarageSlots, game.ownedCars),
                  child: Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.isometricGridDark : AppColors.isometricGridLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: p.primaryColor.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: p.primaryColor.withValues(alpha: 0.1),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: canvasSize,
                            painter: _IsometricShowroomPainter(
                              ownedCars: game.ownedCars,
                              maxSlots: game.maxGarageSlots,
                              dealershipName: game.dealershipName,
                              inGameTime: game.inGameTime,
                              animProgress: _animController.value,
                              p: p,
                            ),
                          ),

                          // Dynamic Animated Customer Speech / Emotion Bubbles
                          if (game.ownedCars.isNotEmpty) ...[
                            // Customer 1: Buy Interest
                            Positioned(
                              top: 22 + math.sin(_animController.value * math.pi * 2) * 5,
                              left: width * 0.26,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.85),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.arcadeGold, width: 1.2),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('❤️', style: TextStyle(fontSize: 11)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Müşteri: "Temiz araç!"',
                                      style: TextStyle(color: AppColors.arcadeGold, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Customer 2: Offer Thinking (if 2+ cars)
                            if (game.ownedCars.length >= 2)
                              Positioned(
                                top: 85 + math.cos(_animController.value * math.pi * 2) * 5,
                                right: width * 0.22,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.85),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.neonCyan, width: 1.2),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('💭', style: TextStyle(fontSize: 11)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Alıcı: "Teklif var!"',
                                        style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// CustomPainter for rendering 2.5D Isometric Floor, Cars, Parking Lines & Dealership Signs
class _IsometricShowroomPainter extends CustomPainter {
  final List<CarModel> ownedCars;
  final int maxSlots;
  final String dealershipName;
  final DateTime inGameTime;
  final double animProgress;
  final ThemePaletteModel p;

  _IsometricShowroomPainter({
    required this.ownedCars,
    required this.maxSlots,
    required this.dealershipName,
    required this.inGameTime,
    required this.animProgress,
    required this.p,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Background Terrain
    final bgPaint = Paint()..color = p.isDark ? const Color(0xFF111827) : AppColors.beneloilGrassGreen;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Draw Bottom Asphalt Road
    final roadPaint = Paint()
      ..color = AppColors.beneloilAsphaltRoad
      ..style = PaintingStyle.fill;

    final roadPath = Path()
      ..moveTo(0, size.height * 0.76)
      ..lineTo(size.width, size.height * 0.84)
      ..lineTo(size.width, size.height * 0.98)
      ..lineTo(0, size.height * 0.90)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Road Yellow Center Dash Line
    final linePaint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final startPt = Offset(0, size.height * 0.83);
    final endPt = Offset(size.width, size.height * 0.91);

    const dashLength = 12.0;
    const gapLength = 8.0;
    final totalDist = (endPt - startPt).distance;
    final dx = (endPt.dx - startPt.dx) / totalDist;
    final dy = (endPt.dy - startPt.dy) / totalDist;

    double currentDist = 0.0;
    while (currentDist < totalDist) {
      final p1 = Offset(startPt.dx + dx * currentDist, startPt.dy + dy * currentDist);
      final p2 = Offset(
        startPt.dx + dx * math.min(currentDist + dashLength, totalDist),
        startPt.dy + dy * math.min(currentDist + dashLength, totalDist),
      );
      canvas.drawLine(p1, p2, linePaint);
      currentDist += dashLength + gapLength;
    }

    // 3. Draw Moving Cars on the Bottom Road
    _drawMovingCarsOnRoad(canvas, size, startPt, endPt);

    // 4. Calculate Showroom Isometric Dimensions
    const tileWidth = 78.0;
    const tileHeight = 39.0;
    final origin = Offset(size.width * 0.44, size.height * 0.28);

    final gridRows = (maxSlots / 3).ceil();
    const gridCols = 3;

    // Dynamically calculate tight Isometric Pad bounds using IsoToScreen math
    final padTop = IsometricMath.isoToScreen(-0.8, -0.6, tileWidth, tileHeight, origin);
    final padRight = IsometricMath.isoToScreen(-0.8, gridCols - 0.3, tileWidth, tileHeight, origin);
    final padBottom = IsometricMath.isoToScreen(gridRows - 0.3, gridCols - 0.3, tileWidth, tileHeight, origin);
    final padLeft = IsometricMath.isoToScreen(gridRows - 0.3, -0.6, tileWidth, tileHeight, origin);

    final padPath = Path()
      ..moveTo(padTop.dx, padTop.dy)
      ..lineTo(padRight.dx, padRight.dy)
      ..lineTo(padBottom.dx, padBottom.dy)
      ..lineTo(padLeft.dx, padLeft.dy)
      ..close();

    final padPaint = Paint()
      ..color = p.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    canvas.drawPath(padPath, padPaint);

    final padBorderPaint = Paint()
      ..color = p.primaryColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(padPath, padBorderPaint);

    // 5. Draw Dealership Main Building Block at back-right of pad
    final buildingPos = IsometricMath.isoToScreen(-0.8, 1.2, tileWidth, tileHeight, origin);
    _drawDealershipBuildingBlock(canvas, Offset(buildingPos.dx + 25, buildingPos.dy - 10));

    // 6. Draw Floor Tiles & Parking Bays for Showroom Cars
    for (int r = 0; r < gridRows; r++) {
      for (int c = 0; c < gridCols; c++) {
        final center = IsometricMath.isoToScreen(r.toDouble(), c.toDouble(), tileWidth, tileHeight, origin);
        final slotIndex = r * 3 + c;
        final hasCar = slotIndex < ownedCars.length;
        final isAvailableSlot = slotIndex < maxSlots;

        if (!isAvailableSlot) continue;

        final path = Path();
        path.moveTo(center.dx, center.dy - tileHeight / 2);
        path.lineTo(center.dx + tileWidth / 2, center.dy);
        path.lineTo(center.dx, center.dy + tileHeight / 2);
        path.lineTo(center.dx - tileWidth / 2, center.dy);
        path.close();

        // Floor fill
        final tilePaint = Paint()
          ..color = hasCar
              ? p.primaryColor.withValues(alpha: 0.25)
              : (p.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.85))
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, tilePaint);

        // Isometric Border Line
        final borderPaint = Paint()
          ..color = hasCar ? p.primaryColor : const Color(0xFF94A3B8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = hasCar ? 1.5 : 1.0;
        canvas.drawPath(path, borderPaint);

        // Draw Slot Label / Number
        final slotText = 'SLOT-${slotIndex + 1}';
        final textSpan = TextSpan(
          text: slotText,
          style: TextStyle(
            color: hasCar ? p.primaryColor : Colors.grey.shade600,
            fontSize: 8.0,
            fontWeight: FontWeight.bold,
          ),
        );
        final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
        tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy + tileHeight / 4 - 4));

        // Draw Object (Car or Empty Bay Marker)
        if (hasCar) {
          final car = ownedCars[slotIndex];
          _drawIsometricCar(canvas, center, car, p);
        } else {
          _drawEmptyBayPlus(canvas, center, p);
        }
      }
    }
  }

  void _drawMovingCarsOnRoad(Canvas canvas, Size size, Offset startPt, Offset endPt) {
    final t1 = (animProgress * 1.5) % 1.0;
    final pos1 = Offset(
      startPt.dx + (endPt.dx - startPt.dx) * t1,
      startPt.dy + (endPt.dy - startPt.dy) * t1,
    );

    final carPaint1 = Paint()..color = const Color(0xFFEF4444);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos1.dx, pos1.dy + 3), width: 22, height: 10),
      Paint()..color = Colors.black38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos1, width: 18, height: 10),
        const Radius.circular(3),
      ),
      carPaint1,
    );

    final t2 = ((animProgress + 0.5) * 1.2) % 1.0;
    final pos2 = Offset(
      startPt.dx + (endPt.dx - startPt.dx) * t2,
      startPt.dy + (endPt.dy - startPt.dy) * t2,
    );

    final carPaint2 = Paint()..color = const Color(0xFF3B82F6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(pos2.dx, pos2.dy + 3), width: 22, height: 10),
      Paint()..color = Colors.black38,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: pos2, width: 18, height: 10),
        const Radius.circular(3),
      ),
      carPaint2,
    );
  }

  void _drawDealershipBuildingBlock(Canvas canvas, Offset center) {
    final bldPath = Path()
      ..moveTo(center.dx, center.dy - 35)
      ..lineTo(center.dx + 40, center.dy - 15)
      ..lineTo(center.dx + 40, center.dy + 15)
      ..lineTo(center.dx, center.dy + 35)
      ..lineTo(center.dx - 40, center.dy + 15)
      ..lineTo(center.dx - 40, center.dy - 15)
      ..close();

    final bldPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawPath(bldPath, bldPaint);

    final roofPath = Path()
      ..moveTo(center.dx, center.dy - 35)
      ..lineTo(center.dx + 40, center.dy - 15)
      ..lineTo(center.dx, center.dy + 5)
      ..lineTo(center.dx - 40, center.dy - 15)
      ..close();

    final roofPaint = Paint()..color = const Color(0xFF334155);
    canvas.drawPath(roofPath, roofPaint);

    final textSpan = TextSpan(
      text: dealershipName.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primaryAmber,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - 48));
  }

  void _drawIsometricCar(Canvas canvas, Offset center, CarModel car, ThemePaletteModel p) {
    final carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xff')));

    // Car Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx, center.dy + 2), width: 50, height: 20),
      shadowPaint,
    );

    // Isometric 3D Car Body Box
    final carTopCenter = Offset(center.dx, center.dy - 12);
    final bodyPaint = Paint()..color = carColor;

    final bodyPath = Path()
      ..moveTo(carTopCenter.dx, carTopCenter.dy - 10)
      ..lineTo(carTopCenter.dx + 22, carTopCenter.dy + 1)
      ..lineTo(carTopCenter.dx, carTopCenter.dy + 12)
      ..lineTo(carTopCenter.dx - 22, carTopCenter.dy + 1)
      ..close();
    canvas.drawPath(bodyPath, bodyPaint);

    // Car Roof Highlight
    final roofPaint = Paint()..color = Colors.white.withValues(alpha: 0.3);
    final roofPath = Path()
      ..moveTo(carTopCenter.dx, carTopCenter.dy - 8)
      ..lineTo(carTopCenter.dx + 12, carTopCenter.dy - 1)
      ..lineTo(carTopCenter.dx, carTopCenter.dy + 6)
      ..lineTo(carTopCenter.dx - 12, carTopCenter.dy - 1)
      ..close();
    canvas.drawPath(roofPath, roofPaint);

    // Car Brand Title Text Badge
    final nameSpan = TextSpan(
      text: car.brand,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 3)],
      ),
    );
    final nameTp = TextPainter(text: nameSpan, textDirection: TextDirection.ltr)..layout();
    nameTp.paint(canvas, Offset(center.dx - nameTp.width / 2, center.dy - 28));
  }

  void _drawEmptyBayPlus(Canvas canvas, Offset center, ThemePaletteModel p) {
    final iconPaint = Paint()
      ..color = p.primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(center.dx - 6, center.dy - 4), Offset(center.dx + 6, center.dy - 4), iconPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 10), Offset(center.dx, center.dy + 2), iconPaint);
  }

  @override
  bool shouldRepaint(covariant _IsometricShowroomPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.ownedCars != ownedCars ||
        oldDelegate.inGameTime != inGameTime;
  }
}
