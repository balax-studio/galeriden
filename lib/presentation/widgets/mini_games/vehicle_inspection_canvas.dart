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

class VehicleInspectionModal extends StatefulWidget {
  final CarModel car;
  final Function(bool passed, double brakeScore, double headlightScore,
      String reportBadge) onInspectionFinished;

  const VehicleInspectionModal({
    super.key,
    required this.car,
    required this.onInspectionFinished,
  });

  static Future<void> show(
    BuildContext context, {
    required CarModel car,
    required Function(bool passed, double brakeScore, double headlightScore,
            String reportBadge)
        onInspectionFinished,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => VehicleInspectionModal(
        car: car,
        onInspectionFinished: onInspectionFinished,
      ),
    );
  }

  @override
  State<VehicleInspectionModal> createState() => _VehicleInspectionModalState();
}

class _VehicleInspectionModalState extends State<VehicleInspectionModal>
    with TickerProviderStateMixin {
  late AnimationController _rollerController;
  late AnimationController _pulseController;

  // Stage 0: Fren Testi, Stage 1: Far Testi, Stage 2: Sonuç Raporu
  int _currentStage = 0;

  // Brake Stage State
  bool _isBraking = false;
  double _brakeProgress = 0.0; // 0 to 1.0
  double _leftBrakeForce = 2.4; // kN
  double _rightBrakeForce = 2.3; // kN
  double _brakeImbalancePercent = 4.0; // %

  // Headlight Stage State
  final Offset _headlightTarget = const Offset(0.0, 0.0);
  Offset _currentBeamOffset = const Offset(-25.0, 30.0);
  double _headlightAccuracy = 0.0;
  bool _isHeadlightAligned = false;

  // Final Evaluation
  bool _isPassed = false;
  String? _stampText;

  @override
  void initState() {
    super.initState();
    _rollerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();
    _rollerController.addListener(_onBrakeTick);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rollerController.removeListener(_onBrakeTick);
    _rollerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onBrakeTick() {
    if (_currentStage != 0 || !_isBraking) return;

    setState(() {
      _brakeProgress = (_brakeProgress + 0.04).clamp(0.0, 1.0);

      // Simulating hydraulic stabilization
      _leftBrakeForce = 3.2 + math.sin(_brakeProgress * 10) * 0.15;
      _rightBrakeForce = 3.1 + math.cos(_brakeProgress * 8) * 0.18;
      _brakeImbalancePercent =
          ((_leftBrakeForce - _rightBrakeForce).abs() / _leftBrakeForce * 100.0)
              .clamp(2.0, 15.0);

      if (_brakeProgress >= 1.0) {
        _isBraking = false;
        HapticFeedback.heavyImpact();
        // Advance to Stage 1: Far Testi
        _currentStage = 1;
      }
    });
  }

  void _onBeamPanUpdate(DragUpdateDetails details, Size canvasSize) {
    if (_currentStage != 1 || _isHeadlightAligned) return;

    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final touchPos = details.localPosition;
    final newOffset = Offset(touchPos.dx - center.dx, touchPos.dy - center.dy);

    final dist = (newOffset - _headlightTarget).distance;
    final accuracy = (1.0 - (dist / 80.0)).clamp(0.0, 1.0);

    setState(() {
      _currentBeamOffset = newOffset;
      _headlightAccuracy = accuracy;

      if (dist < 12.0) {
        _isHeadlightAligned = true;
        HapticFeedback.heavyImpact();
        _evaluateFinalReport();
      } else if (dist < 25.0) {
        HapticFeedback.selectionClick();
      }
    });
  }

  void _evaluateFinalReport() {
    _isPassed = _brakeImbalancePercent < 20.0 && _headlightAccuracy >= 0.85;
    _stampText = _isPassed
        ? context.tr('inspection_stamp_passed')
        : context.tr('inspection_stamp_minor');
    _currentStage = 2;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F1420),
        borderColor: _currentStage == 2
            ? (_isPassed ? AppColors.brutalGreen : AppColors.brutalYellow)
            : const Color(0xFF38BDF8),
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
                        context.tr('inspection_title'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.car.modelYear} ${widget.car.brand} ${widget.car.modelName}',
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
                  text: _currentStage == 0
                      ? context.tr('inspection_step_brake')
                      : (_currentStage == 1
                          ? context.tr('inspection_step_light')
                          : context.tr('inspection_step_finished')),
                  backgroundColor: _currentStage == 2
                      ? AppColors.brutalGreen
                      : const Color(0xFF38BDF8),
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Canvas Stage Area
            Container(
              height: 210,
              decoration: BoxDecoration(
                color: const Color(0xFF070A10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF242C3D), width: 2.0),
              ),
              child: Stack(
                children: [
                  if (_currentStage == 0) ...[
                    AnimatedBuilder(
                      animation: _rollerController,
                      builder: (context, _) {
                        return RepaintBoundary(
                          child: CustomPaint(
                            size: const Size(double.infinity, 210),
                            painter: _BrakeRollerPainter(
                              rollerProgress: _rollerController.value,
                              leftForce: _leftBrakeForce,
                              rightForce: _rightBrakeForce,
                              imbalance: _brakeImbalancePercent,
                              isBraking: _isBraking,
                              progress: _brakeProgress,
                              rightForceLabel:
                                  context.tr('inspection_right_force'),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else if (_currentStage == 1) ...[
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanUpdate: (details) => _onBeamPanUpdate(
                            details,
                            Size(constraints.maxWidth, constraints.maxHeight),
                          ),
                          child: RepaintBoundary(
                            child: CustomPaint(
                              size: Size(
                                  constraints.maxWidth, constraints.maxHeight),
                              painter: _HeadlightBeamPainter(
                                beamOffset: _currentBeamOffset,
                                targetOffset: _headlightTarget,
                                accuracy: _headlightAccuracy,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    Positioned.fill(
                      child: Center(
                        child: SlamStampWidget(
                          text: _stampText ??
                              context.tr('inspection_passed_perfect'),
                          color: _isPassed
                              ? AppColors.brutalGreen
                              : AppColors.brutalYellow,
                          fontSize: 22,
                          angle: -0.06,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Stage instructions / status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF161C2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3449)),
              ),
              child: Text(
                _currentStage == 0
                    ? (_isBraking
                        ? context.tr('inspection_msg_brake_active',
                            {'pct': _brakeImbalancePercent.toStringAsFixed(1)})
                        : context.tr('inspection_msg_brake_idle'))
                    : (_currentStage == 1
                        ? context.tr('inspection_msg_light_drag')
                        : context.tr('inspection_msg_finished')),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Stage Controls
            if (_currentStage == 0) ...[
              GestureDetector(
                onTapDown: (_) {
                  setState(() {
                    _isBraking = true;
                  });
                  HapticFeedback.selectionClick();
                },
                onTapUp: (_) {
                  setState(() {
                    _isBraking = false;
                  });
                },
                onTapCancel: () {
                  setState(() {
                    _isBraking = false;
                  });
                },
                child: NeoBrutalButton(
                  label: _isBraking
                      ? '${context.tr('inspection_brake_lock_hold')} • %${(_brakeProgress * 100).round()}'
                      : context.tr('inspection_btn_brake_hold'),
                  icon: Icons.airline_stops_rounded,
                  backgroundColor: _isBraking
                      ? AppColors.brutalGreen
                      : AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 13,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    setState(() {
                      _isBraking = false;
                      _brakeProgress = 1.0;
                      _currentStage = 1;
                    });
                  },
                ),
              ),
            ] else if (_currentStage == 1) ...[
              NeoBrutalButton(
                label: _isHeadlightAligned
                    ? context.tr('inspection_btn_light_aligned')
                    : context.tr('inspection_btn_light_drag'),
                icon: Icons.center_focus_strong_rounded,
                backgroundColor: _isHeadlightAligned
                    ? AppColors.brutalGreen
                    : const Color(0xFF38BDF8),
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  // Fallback snap align
                  setState(() {
                    _currentBeamOffset = Offset.zero;
                    _headlightAccuracy = 1.0;
                    _isHeadlightAligned = true;
                    _evaluateFinalReport();
                  });
                },
              ),
            ] else ...[
              NeoBrutalButton(
                label: context.tr('inspection_btn_save'),
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  widget.onInspectionFinished(
                    _isPassed,
                    _brakeImbalancePercent,
                    _headlightAccuracy,
                    _stampText ?? context.tr('inspection_passed_perfect'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BrakeRollerPainter extends CustomPainter {
  final double rollerProgress;
  final double leftForce;
  final double rightForce;
  final double imbalance;
  final bool isBraking;
  final double progress;
  final String rightForceLabel;

  _BrakeRollerPainter({
    required this.rollerProgress,
    required this.leftForce,
    required this.rightForce,
    required this.imbalance,
    required this.isBraking,
    required this.progress,
    required this.rightForceLabel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // 1. Technical CRT Grid
    NeoBrutalPolyPainter.drawCRTGrid(
      canvas,
      size,
      gridColor: const Color(0xFF141926),
      spacing: 16.0,
      drawCrosshair: true,
    );

    // Hazard Safety Striping Top and Bottom
    NeoBrutalPolyPainter.drawHazardStripes(
      canvas,
      Rect.fromLTWH(8, 8, size.width - 16, 8),
      stripeWidth: 6,
      borderWidth: 1.0,
    );

    // 2. Dual Low-Poly 3D Brake Rollers (Left & Right)
    final rollerWidth = 74.0;
    final rollerHeight = 46.0;
    final leftRollerRect = Rect.fromLTWH(cx - 105, 26, rollerWidth, rollerHeight);
    final rightRollerRect = Rect.fromLTWH(cx + 31, 26, rollerWidth, rollerHeight);

    _drawFacetedRollerBox(canvas, leftRollerRect, rollerProgress, isBraking);
    _drawFacetedRollerBox(canvas, rightRollerRect, rollerProgress, isBraking);

    // 3. Digital Gauges (Left / Right Force)
    final gaugeY = 118.0;
    _drawNeoBrutalDial(
      canvas,
      Offset(cx - 65, gaugeY),
      'SOL: ${leftForce.toStringAsFixed(1)} kN',
      leftForce / 5.0,
      AppColors.brutalGreen,
    );
    _drawNeoBrutalDial(
      canvas,
      Offset(cx + 65, gaugeY),
      '$rightForceLabel ${rightForce.toStringAsFixed(1)} kN',
      rightForce / 5.0,
      AppColors.brutalOrange,
    );

    // 4. Low-Poly Segmented Progress Bar
    final barRect = Rect.fromLTWH(24, size.height - 22, size.width - 48, 12);
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      [
        Offset(barRect.left, barRect.top),
        Offset(barRect.right, barRect.top),
        Offset(barRect.right, barRect.bottom),
        Offset(barRect.left, barRect.bottom),
      ],
      color: const Color(0xFF1E283D),
      lightFactor: 1.0,
      strokeWidth: 1.5,
    );

    final fillWidth = (barRect.width * progress).clamp(0.0, barRect.width);
    if (fillWidth > 4) {
      NeoBrutalPolyPainter.drawFacetedPolygon(
        canvas,
        [
          Offset(barRect.left, barRect.top),
          Offset(barRect.left + fillWidth, barRect.top),
          Offset(barRect.left + fillWidth, barRect.bottom),
          Offset(barRect.left, barRect.bottom),
        ],
        color: isBraking ? AppColors.brutalGreen : AppColors.brutalYellow,
        lightFactor: 1.1,
        strokeWidth: 1.5,
      );
    }
  }

  void _drawFacetedRollerBox(
    Canvas canvas,
    Rect rect,
    double spinProgress,
    bool brakingActive,
  ) {
    // 3D Beveled Box Frame
    final chamfer = 6.0;
    final vertices = [
      Offset(rect.left + chamfer, rect.top),
      Offset(rect.right - chamfer, rect.top),
      Offset(rect.right, rect.top + chamfer),
      Offset(rect.right, rect.bottom - chamfer),
      Offset(rect.right - chamfer, rect.bottom),
      Offset(rect.left + chamfer, rect.bottom),
      Offset(rect.left, rect.bottom - chamfer),
      Offset(rect.left, rect.top + chamfer),
    ];

    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      vertices,
      color: const Color(0xFF1E283D),
      lightFactor: brakingActive ? 1.15 : 1.0,
      strokeWidth: 2.0,
      strokeColor: brakingActive ? AppColors.brutalGreen : const Color(0xFF384A6E),
    );

    // Rotating faceted ribs
    final stripeOffset = (spinProgress * 24.0);
    final stripePaint = Paint()
      ..color = brakingActive
          ? AppColors.brutalGreen.withValues(alpha: 0.75)
          : const Color(0xFF64748B)
      ..strokeWidth = 2.4;

    for (double x = rect.left + 8; x < rect.right - 4; x += 16) {
      final dx = rect.left + ((x - rect.left + stripeOffset) % (rect.width - 10));
      canvas.drawLine(
        Offset(dx, rect.top + 5),
        Offset(dx, rect.bottom - 5),
        stripePaint,
      );
    }

    // Hex Bolt in corner
    NeoBrutalPolyPainter.draw3DHexBolt(
      canvas,
      Offset(rect.left + 8, rect.top + 8),
      3.5,
      baseColor: const Color(0xFF94A3B8),
      isLoosened: false,
    );
  }

  void _drawNeoBrutalDial(
    Canvas canvas,
    Offset center,
    String label,
    double ratio,
    Color activeColor,
  ) {
    // Segmented Background Gauge Arc
    final arcPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.butt;

    final fillArc = Paint()
      ..color = isBraking ? activeColor : const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 26),
      math.pi * 0.8,
      math.pi * 1.4,
      false,
      arcPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 26),
      math.pi * 0.8,
      math.pi * 1.4 * ratio.clamp(0.0, 1.0),
      false,
      fillArc,
    );

    // Diamond Needle Indicator at Tip of Dial
    final tipAngle = math.pi * 0.8 + math.pi * 1.4 * ratio.clamp(0.0, 1.0);
    final tipOffset = Offset(
      center.dx + 26 * math.cos(tipAngle),
      center.dy + 26 * math.sin(tipAngle),
    );
    NeoBrutalPolyPainter.drawPrismaticDiamond(
      canvas,
      tipOffset,
      5.0,
      Colors.white,
      strokeWidth: 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _BrakeRollerPainter oldDelegate) => true;
}

class _HeadlightBeamPainter extends CustomPainter {
  final Offset beamOffset;
  final Offset targetOffset;
  final double accuracy;

  _HeadlightBeamPainter({
    required this.beamOffset,
    required this.targetOffset,
    required this.accuracy,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Technical CRT Grid with Crosshairs
    NeoBrutalPolyPainter.drawCRTGrid(
      canvas,
      size,
      gridColor: const Color(0xFF131B2A),
      spacing: 16.0,
      drawCrosshair: true,
    );

    // 2. Octagonal Target Reticle
    final targetCenter = center + targetOffset;
    final isLocked = accuracy > 0.8;
    final targetColor = isLocked ? AppColors.brutalGreen : const Color(0xFF38BDF8);

    // Outer Octagon
    final numSides = 8;
    final outerRadius = 38.0;
    final outerVertices = <Offset>[];
    for (int i = 0; i < numSides; i++) {
      final a = (i * 2 * math.pi / numSides) + (math.pi / 8);
      outerVertices.add(Offset(
        targetCenter.dx + outerRadius * math.cos(a),
        targetCenter.dy + outerRadius * math.sin(a),
      ));
    }
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      outerVertices,
      color: targetColor.withValues(alpha: 0.15),
      lightFactor: 1.0,
      strokeWidth: 2.0,
      strokeColor: targetColor,
    );

    // Center Prismatic Diamond Target
    NeoBrutalPolyPainter.drawPrismaticDiamond(
      canvas,
      targetCenter,
      12.0,
      targetColor,
      strokeWidth: 1.8,
    );

    // 3. Optical Headlight Beam Flare (Draggable)
    final beamCenter = center + beamOffset;

    // Outer Prismatic Flare Polygon
    final beamRadius = 46.0;
    final beamVertices = <Offset>[];
    for (int i = 0; i < 6; i++) {
      final a = (i * 2 * math.pi / 6);
      beamVertices.add(Offset(
        beamCenter.dx + beamRadius * math.cos(a),
        beamCenter.dy + beamRadius * math.sin(a),
      ));
    }
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      beamVertices,
      color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
      lightFactor: 1.2,
      strokeWidth: 1.5,
      strokeColor: Colors.cyanAccent,
    );

    // Core White Prismatic Diamond
    NeoBrutalPolyPainter.drawPrismaticDiamond(
      canvas,
      beamCenter,
      10.0,
      Colors.white,
      strokeWidth: 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _HeadlightBeamPainter oldDelegate) => true;
}
