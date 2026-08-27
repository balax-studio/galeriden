import '../../../core/localization/app_localizations.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/car_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';
import 'neo_brutal_poly_painter.dart';

class EngineTimingModal extends StatefulWidget {
  final CarModel car;
  final Function(bool isPerfect, int hpBonus, String resultMessage)
      onTimingCalibrated;

  const EngineTimingModal({
    super.key,
    required this.car,
    required this.onTimingCalibrated,
  });

  static Future<void> show(
    BuildContext context, {
    required CarModel car,
    required Function(bool isPerfect, int hpBonus, String resultMessage)
        onTimingCalibrated,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => EngineTimingModal(
        car: car,
        onTimingCalibrated: onTimingCalibrated,
      ),
    );
  }

  @override
  State<EngineTimingModal> createState() => _EngineTimingModalState();
}

class _EngineTimingModalState extends State<EngineTimingModal>
    with TickerProviderStateMixin {
  late AnimationController _sweepController;

  // Phase 0: Sente Hizalama (Timing Alignment), Phase 1: Tork Sıkma (Torque Wrench), Phase 2: Bitiş
  int _phase = 0;

  // Camshaft alignment angle (in radians)
  double _camAngle = 0.8;
  double _crankAngle = 0.0;
  bool _isAligned = false;

  // Torque calibration
  int _torqueNm = 0;
  bool _isPerfect = false;
  int _hpBonus = 0;
  String _stampText = 'SENTE KUSURSUZ AYARLANDI';

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _onRotateCam(double delta) {
    if (_phase != 0 || _isAligned) return;

    setState(() {
      _camAngle = (_camAngle + delta) % (math.pi * 2);
      _crankAngle = (_camAngle * 2) % (math.pi * 2);

      // Check alignment to top notch (around 0 / 2pi)
      final normalizedDiff = (_camAngle % (math.pi * 2));
      final diffFromZero =
          math.min(normalizedDiff, math.pi * 2 - normalizedDiff);

      if (diffFromZero < 0.12) {
        _camAngle = 0.0;
        _crankAngle = 0.0;
        _isAligned = true;
        _phase = 1;
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    });
  }

  void _onLockTorque() {
    if (_phase != 1) return;

    final sweep = _sweepController.value; // 0.0 to 1.0
    _torqueNm = (70 + sweep * 60).round(); // 70 to 130 Nm

    _sweepController.stop();

    // Target green zone: 105 to 118 Nm
    if (_torqueNm >= 105 && _torqueNm <= 118) {
      HapticFeedback.heavyImpact();
      _isPerfect = true;
      _hpBonus = math.max(6, (widget.car.baseMarketValue / 80000).round());
      _stampText =
          context.tr('engine_timing_stamp_perfect', {'hp': '$_hpBonus'});
    } else {
      HapticFeedback.vibrate();
      _isPerfect = false;
      _hpBonus = 2;
      _stampText =
          context.tr('engine_timing_stamp_standard', {'hp': '$_hpBonus'});
    }

    setState(() {
      _phase = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F1420),
        borderColor: _phase == 2
            ? (_isPerfect ? AppColors.brutalGreen : AppColors.brutalYellow)
            : AppColors.brutalOrange,
        borderWidth: 2.6,
        borderRadius: 16,
        showHazardHeader: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('engine_timing_title'),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('engine_timing_subtitle', {
                          'brand': widget.car.brand,
                          'model': widget.car.modelName
                        }),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: _phase == 0
                      ? context.tr('engine_timing_step_align')
                      : (_phase == 1
                          ? context.tr('engine_timing_step_torque')
                          : context.tr('engine_timing_step_calibrated')),
                  backgroundColor: _phase == 2
                      ? AppColors.brutalGreen
                      : AppColors.brutalOrange,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Canvas Display Area
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xFF070A10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF242C3D), width: 2.0),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _sweepController,
                    builder: (context, _) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          size: const Size(double.infinity, 210),
                          painter: _EngineTimingPainter(
                            camAngle: _camAngle,
                            crankAngle: _crankAngle,
                            isAligned: _isAligned,
                            phase: _phase,
                            sweepProgress: _sweepController.value,
                            camshaftLabel: context.tr('timing_camshaft_label'),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_phase == 2)
                    Positioned.fill(
                      child: Center(
                        child: SlamStampWidget(
                          text: _stampText,
                          color: _isPerfect
                              ? AppColors.brutalGreen
                              : AppColors.brutalYellow,
                          fontSize: 20,
                          angle: -0.06,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Status message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161C2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3449)),
              ),
              child: Text(
                _phase == 0
                    ? context.tr('engine_timing_msg_align')
                    : (_phase == 1
                        ? context.tr('engine_timing_msg_torque')
                        : context.tr('engine_timing_msg_calibrated',
                            {'hp': '$_hpBonus'})),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Controls
            if (_phase == 0) ...[
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('engine_timing_btn_rotate_left'),
                      icon: Icons.rotate_left_rounded,
                      backgroundColor: const Color(0xFF1E293B),
                      textColor: Colors.white,
                      fontSize: 11.5,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      onPressed: () => _onRotateCam(-0.2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('engine_timing_btn_rotate_right'),
                      icon: Icons.rotate_right_rounded,
                      backgroundColor: AppColors.brutalOrange,
                      textColor: Colors.black,
                      fontSize: 11.5,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      onPressed: () => _onRotateCam(0.2),
                    ),
                  ),
                ],
              ),
            ] else if (_phase == 1) ...[
              NeoBrutalButton(
                label: context.tr('engine_timing_btn_tighten'),
                icon: Icons.build_circle_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: _onLockTorque,
              ),
            ] else ...[
              NeoBrutalButton(
                label: context.tr('timing_test_engine_btn'),
                icon: Icons.play_arrow_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  widget.onTimingCalibrated(_isPerfect, _hpBonus, _stampText);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EngineTimingPainter extends CustomPainter {
  final double camAngle;
  final double crankAngle;
  final bool isAligned;
  final int phase;
  final double sweepProgress;
  final String camshaftLabel;

  _EngineTimingPainter({
    required this.camAngle,
    required this.crankAngle,
    required this.isAligned,
    required this.phase,
    required this.sweepProgress,
    required this.camshaftLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // 1. CRT Technical Grid
    NeoBrutalPolyPainter.drawCRTGrid(canvas, size, gridColor: const Color(0xFF141926));

    if (phase == 0 || phase == 2) {
      // 2. Camshaft & Crankshaft Sprockets with Timing Belt
      final camCenter = Offset(cx, 58);
      final crankCenter = Offset(cx, 148);

      final camRadius = 40.0;
      final crankRadius = 26.0;

      // Laser Alignment Reference Line (Vertical)
      final laserPaint = Paint()
        ..color = isAligned ? AppColors.brutalGreen : AppColors.errorRed
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.square;
      canvas.drawLine(Offset(cx, 10), Offset(cx, size.height - 10), laserPaint);

      // Low-Poly Faceted Timing Belt
      final beltPath = Path()
        ..moveTo(camCenter.dx - camRadius - 2, camCenter.dy)
        ..lineTo(crankCenter.dx - crankRadius - 2, crankCenter.dy)
        ..lineTo(crankCenter.dx + crankRadius + 2, crankCenter.dy)
        ..lineTo(camCenter.dx + camRadius + 2, camCenter.dy)
        ..close();
      canvas.drawPath(
        beltPath,
        Paint()
          ..color = const Color(0xFF0F172A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8.0,
      );

      // Draw Faceted Sprockets
      _drawLowPolySprocket(canvas, camCenter, camRadius, camAngle, 12, camshaftLabel);
      _drawLowPolySprocket(canvas, crankCenter, crankRadius, crankAngle, 8, 'KRANK');
    } else {
      // Phase 1: Torque Scale Wrench View
      final scaleY = size.height / 2;
      final scaleLeft = 28.0;
      final scaleRight = size.width - 28.0;
      final scaleWidth = scaleRight - scaleLeft;

      // Hazard Header Banner
      NeoBrutalPolyPainter.drawHazardStripes(
        canvas,
        Rect.fromLTWH(scaleLeft, scaleY - 45, scaleWidth, 14),
        stripeWidth: 8,
      );

      // Outer Gauge Frame Box
      final boxRect = Rect.fromLTWH(scaleLeft, scaleY - 10, scaleWidth, 20);
      canvas.drawRect(boxRect, Paint()..color = const Color(0xFF0F172A));
      canvas.drawRect(
        boxRect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4,
      );

      // Green target torque zone (58% to 80%)
      final greenRect = Rect.fromLTWH(
        scaleLeft + scaleWidth * 0.58,
        scaleY - 10,
        scaleWidth * 0.22,
        20,
      );
      canvas.drawRect(greenRect, Paint()..color = AppColors.brutalGreen);
      canvas.drawRect(
        greenRect,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      // Sweep Needle (Low-Poly Triangle Pointer)
      final needleX = scaleLeft + scaleWidth * sweepProgress;
      NeoBrutalPolyPainter.drawFacetedPolygon(
        canvas,
        [
          Offset(needleX - 7, scaleY - 18),
          Offset(needleX + 7, scaleY - 18),
          Offset(needleX, scaleY + 16),
        ],
        color: AppColors.brutalOrange,
        lightFactor: 1.2,
        strokeWidth: 2.0,
      );
    }
  }

  void _drawLowPolySprocket(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    int toothCount,
    String label,
  ) {
    // Generate faceted tooth vertices
    final pts = <Offset>[];
    final step = (2 * math.pi) / toothCount;
    for (int i = 0; i < toothCount; i++) {
      final a1 = angle + (i * step);
      final a2 = a1 + step * 0.35;
      final a3 = a1 + step * 0.65;
      final a4 = a1 + step;

      pts.add(Offset(center.dx + (radius + 4) * math.sin(a1), center.dy - (radius + 4) * math.cos(a1)));
      pts.add(Offset(center.dx + (radius + 4) * math.sin(a2), center.dy - (radius + 4) * math.cos(a2)));
      pts.add(Offset(center.dx + radius * math.sin(a3), center.dy - radius * math.cos(a3)));
      pts.add(Offset(center.dx + radius * math.sin(a4), center.dy - radius * math.cos(a4)));
    }

    // Sprocket Body Fill
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      pts,
      color: const Color(0xFF334155),
      lightFactor: 1.1,
      strokeWidth: 2.4,
      strokeColor: Colors.black,
      showHardShadow: true,
      shadowOffset: const Offset(3, 3),
    );

    // Central 3D Hex Hub
    NeoBrutalPolyPainter.draw3DHexBolt(
      canvas,
      center,
      radius * 0.40,
      rotation: angle,
      boltColor: const Color(0xFF64748B),
      depth: 3.0,
      strokeWidth: 1.8,
    );

    // Timing Notch (Prismatic diamond indicator)
    final notchPos = Offset(
      center.dx + math.sin(angle) * (radius + 2),
      center.dy - math.cos(angle) * (radius + 2),
    );
    NeoBrutalPolyPainter.drawPrismaticDiamond(
      canvas,
      notchPos,
      10.0,
      AppColors.brutalYellow,
    );
  }

  @override
  bool shouldRepaint(covariant _EngineTimingPainter oldDelegate) => true;
}
