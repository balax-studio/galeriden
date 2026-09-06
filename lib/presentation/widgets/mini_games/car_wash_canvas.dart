import '../../../core/localization/app_localizations.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/color_parser.dart';
import '../../../data/models/car_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';
import 'neo_brutal_poly_painter.dart';

class CarWashMiniGameModal extends StatefulWidget {
  final CarModel car;
  final VoidCallback onCleanCompleted;

  const CarWashMiniGameModal({
    super.key,
    required this.car,
    required this.onCleanCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required CarModel car,
    required VoidCallback onCleanCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CarWashMiniGameModal(
        car: car,
        onCleanCompleted: onCleanCompleted,
      ),
    );
  }

  @override
  State<CarWashMiniGameModal> createState() => _CarWashMiniGameModalState();
}

class _CarWashMiniGameModalState extends State<CarWashMiniGameModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _sparkleController;
  final List<Offset> _cleanedPoints = [];
  final List<WashParticle> _waterParticles = [];
  final math.Random _random = math.Random();
  double _cleanlinessPercent = 0.0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    if (_isFinished) return;

    if (!_sparkleController.isAnimating) {
      _sparkleController.forward(from: 0.0);
    }

    final pos = details.localPosition;
    // Check if inside car boundary
    if (pos.dx >= 20 &&
        pos.dx <= canvasSize.width - 20 &&
        pos.dy >= 30 &&
        pos.dy <= canvasSize.height - 30) {
      _cleanedPoints.add(pos);

      // Spawn water spray particles
      for (int i = 0; i < 3; i++) {
        _waterParticles.add(
          WashParticle(
            x: pos.dx + _random.nextDouble() * 12 - 6,
            y: pos.dy + _random.nextDouble() * 12 - 6,
            vx: _random.nextDouble() * 4 - 2,
            vy: _random.nextDouble() * 4 - 2,
            color: _random.nextBool() ? const Color(0xFF38BDF8) : Colors.white,
          ),
        );
      }

      // Haptic tick
      if (_cleanedPoints.length % 5 == 0) {
        HapticFeedback.selectionClick();
      }

      // Compute rough coverage percentage
      final count = _cleanedPoints.length;
      final newPercent = (count / 65.0 * 100.0).clamp(0.0, 100.0);

      setState(() {
        _cleanlinessPercent = newPercent;
        if (_cleanlinessPercent >= 100.0 && !_isFinished) {
          _isFinished = true;
          HapticFeedback.heavyImpact();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F1420),
        borderColor: const Color(0xFF38BDF8),
        borderWidth: 2.6,
        borderRadius: 16,
        showHazardHeader: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cleaning_services_rounded,
                        color: Color(0xFF38BDF8), size: 22),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('car_wash_title'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: context.tr('car_wash_cleaned_pct',
                      {'pct': '${_cleanlinessPercent.toInt()}'}),
                  backgroundColor: _isFinished
                      ? AppColors.brutalGreen
                      : const Color(0xFF38BDF8),
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _isFinished
                  ? context.tr('car_wash_hint_finished')
                  : context.tr('car_wash_hint_in_progress'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _isFinished
                    ? AppColors.brutalGreen
                    : const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 12),

            // Scratch & Clean Canvas
            LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = Size(constraints.maxWidth, 170);

                return GestureDetector(
                  onPanUpdate: (details) => _onPanUpdate(details, canvasSize),
                  child: Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF090D15),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFF222D42), width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, child) {
                          // Update particles
                          for (final p in _waterParticles) {
                            p.update();
                          }
                          _waterParticles.removeWhere((p) => p.life <= 0);

                          return RepaintBoundary(
                            child: CustomPaint(
                              painter: _CarWashPainter(
                                cleanedPoints: _cleanedPoints,
                                waterParticles: _waterParticles,
                                carColorHex: widget.car.colorHex,
                                carModel: widget.car.modelName,
                                isFinished: _isFinished,
                                sparkleTick: _sparkleController.value,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            if (_isFinished) ...[
              SlamStampWidget(
                text: context.tr('car_wash_stamp_clean'),
                color: AppColors.brutalGreen,
                fontSize: 15,
                angle: -0.05,
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: NeoBrutalButton(
                label: _isFinished
                    ? context.tr('car_wash_btn_confirm')
                    : context.tr('car_wash_btn_cleaning'),
                icon: _isFinished
                    ? Icons.check_circle_rounded
                    : Icons.cleaning_services_rounded,
                backgroundColor: _isFinished
                    ? AppColors.brutalGreen
                    : const Color(0xFF475569),
                textColor: _isFinished ? Colors.black : Colors.white,
                fontSize: 12,
                onPressed: _isFinished
                    ? () {
                        Navigator.pop(context);
                        widget.onCleanCompleted();
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WashParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  int life = 10;

  WashParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
    life--;
  }
}

class _CarWashPainter extends CustomPainter {
  final List<Offset> cleanedPoints;
  final List<WashParticle> waterParticles;
  final String carColorHex;
  final String carModel;
  final bool isFinished;
  final double sparkleTick;

  _CarWashPainter({
    required this.cleanedPoints,
    required this.waterParticles,
    required this.carColorHex,
    required this.carModel,
    required this.isFinished,
    required this.sparkleTick,
  });

  Color _parseColor(String hex) {
    return ColorParser.parseCarColor(hex, const Color(0xFFFFDE59));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. CRT Technical Floor Grid
    NeoBrutalPolyPainter.drawCRTGrid(canvas, size, gridColor: const Color(0xFF161F30), spacing: 18.0);

    // Hazard Safety Striping at Top
    NeoBrutalPolyPainter.drawHazardStripes(
      canvas,
      Rect.fromLTWH(12, 10, w - 24, 12),
      stripeWidth: 8,
      borderWidth: 1.5,
    );

    // 2. Volumetric Low-Poly Isometric Car Body
    final carCenter = Offset(w * 0.50, h * 0.52);
    final carColor = _parseColor(carColorHex);
    NeoBrutalPolyPainter.drawLowPolyIsometricCar(
      canvas,
      carCenter,
      1.85,
      bodyColor: carColor,
      isHeadlightsOn: true,
    );

    // 3. Faceted Mud Encrustation Plates (Low-Poly Dirt Crust)
    if (!isFinished) {
      final mudColor = const Color(0xFF78350F);

      for (double mx = w * 0.20; mx < w * 0.80; mx += 22) {
        for (double my = h * 0.35; my < h * 0.70; my += 20) {
          final isCleaned = cleanedPoints.any((pt) => (pt - Offset(mx, my)).distance < 24);
          if (!isCleaned) {
            final mudVertices = [
              Offset(mx - 8, my - 6),
              Offset(mx + 9, my - 7),
              Offset(mx + 7, my + 8),
              Offset(mx - 7, my + 6),
            ];
            NeoBrutalPolyPainter.drawFacetedPolygon(
              canvas,
              mudVertices,
              color: mudColor,
              lightFactor: 0.9 + ((mx + my) % 5) * 0.05,
              strokeWidth: 1.6,
              strokeColor: Colors.black,
            );
          }
        }
      }
    }

    // 4. Prismatic Water Spray Droplets
    for (final p in waterParticles) {
      final alpha = (p.life / 10.0).clamp(0.0, 1.0);
      if (alpha > 0) {
        NeoBrutalPolyPainter.drawPrismaticDiamond(
          canvas,
          Offset(p.x, p.y),
          7.0 * alpha,
          p.color.withValues(alpha: alpha),
          strokeWidth: 1.0,
        );
      }
    }

    // 5. Prismatic Diamond Glints when Finished
    if (isFinished) {
      final glintOffset1 = Offset(w * 0.32, h * 0.44);
      final glintOffset2 = Offset(w * 0.52, h * 0.32);
      final glintOffset3 = Offset(w * 0.72, h * 0.48);

      NeoBrutalPolyPainter.drawPrismaticDiamond(
        canvas,
        glintOffset1,
        14.0 * (0.6 + 0.4 * math.sin(sparkleTick * math.pi)),
        Colors.white,
      );
      NeoBrutalPolyPainter.drawPrismaticDiamond(
        canvas,
        glintOffset2,
        16.0 * (0.6 + 0.4 * math.sin((sparkleTick + 0.3) * math.pi)),
        AppColors.brutalYellow,
      );
      NeoBrutalPolyPainter.drawPrismaticDiamond(
        canvas,
        glintOffset3,
        14.0 * (0.6 + 0.4 * math.sin((sparkleTick + 0.6) * math.pi)),
        AppColors.brutalGreen,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CarWashPainter oldDelegate) => true;
}
