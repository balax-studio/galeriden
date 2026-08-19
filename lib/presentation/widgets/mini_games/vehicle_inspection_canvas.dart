import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/car_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';

class VehicleInspectionModal extends StatefulWidget {
  final CarModel car;
  final Function(bool passed, double brakeScore, double headlightScore, String reportBadge) onInspectionFinished;

  const VehicleInspectionModal({
    super.key,
    required this.car,
    required this.onInspectionFinished,
  });

  static Future<void> show(
    BuildContext context, {
    required CarModel car,
    required Function(bool passed, double brakeScore, double headlightScore, String reportBadge) onInspectionFinished,
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
  String _stampText = 'KUSURSUZ GEÇTİ';

  @override
  void initState() {
    super.initState();
    _rollerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rollerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onBrakeTick() {
    if (_currentStage != 0 || !_isBraking) return;

    setState(() {
      _brakeProgress = (_brakeProgress + 0.02).clamp(0.0, 1.0);

      // Simulating hydraulic stabilization
      _leftBrakeForce = 3.2 + math.sin(_brakeProgress * 10) * 0.15;
      _rightBrakeForce = 3.1 + math.cos(_brakeProgress * 8) * 0.18;
      _brakeImbalancePercent = ((_leftBrakeForce - _rightBrakeForce).abs() / _leftBrakeForce * 100.0).clamp(2.0, 15.0);

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
    _stampText = _isPassed ? 'KUSURSUZ ONAYLANDI' : 'HAFİF KUSURLU GEÇTİ';
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
                      const Text(
                        'ARAÇ MUAYENE VE KUSUR TESTİ',
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
                      ? 'AŞAMA 1/2 • FREN'
                      : (_currentStage == 1 ? 'AŞAMA 2/2 • FAR' : 'TEST TAMAMLANDI'),
                  backgroundColor: _currentStage == 2 ? AppColors.brutalGreen : const Color(0xFF38BDF8),
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
                        return CustomPaint(
                          size: const Size(double.infinity, 210),
                          painter: _BrakeRollerPainter(
                            rollerProgress: _rollerController.value,
                            leftForce: _leftBrakeForce,
                            rightForce: _rightBrakeForce,
                            imbalance: _brakeImbalancePercent,
                            isBraking: _isBraking,
                            progress: _brakeProgress,
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
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: _HeadlightBeamPainter(
                              beamOffset: _currentBeamOffset,
                              targetOffset: _headlightTarget,
                              accuracy: _headlightAccuracy,
                            ),
                          ),
                        );
                      },
                    ),
                  ] else ...[
                    Positioned.fill(
                      child: Center(
                        child: SlamStampWidget(
                          text: _stampText,
                          color: _isPassed ? AppColors.brutalGreen : AppColors.brutalYellow,
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
                        ? 'Pedala basılıyor • Fren kuvvet dengesi ölçülüyor: %${_brakeImbalancePercent.toStringAsFixed(1)} sapma'
                        : 'Fren test silindirleri devrede • Butona basılı tutarak hidroliği kilitle!')
                    : (_currentStage == 1
                        ? 'Far huzmesini parmağınla sürükleyerek merkez hedef artı işaretine oturt!'
                        : 'Muayene raporu düzenlendi • Aracın resmi kayıtları güncellendi.'),
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
                  _isBraking = true;
                  HapticFeedback.selectionClick();
                  _startBrakeLoop();
                },
                onTapUp: (_) => _isBraking = false,
                onTapCancel: () => _isBraking = false,
                child: NeoBrutalButton(
                  label: _isBraking ? 'FREN KİLİTLENİYOR • BASILI TUT' : 'FREN PEDALINA BASILI TUT',
                  icon: Icons.airline_stops_rounded,
                  backgroundColor: _isBraking ? AppColors.brutalGreen : AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 13,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    // For tap fallback / testing
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
                label: _isHeadlightAligned ? 'HİZALAMA BAŞARILI • RAPORU AL' : 'MERCEĞİ HİZALA • DOKUN & KAYDIR',
                icon: Icons.center_focus_strong_rounded,
                backgroundColor: _isHeadlightAligned ? AppColors.brutalGreen : const Color(0xFF38BDF8),
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
                label: 'MUAYENE RAPORUNU ONAYLA & KAYDET',
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
                    _stampText,
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startBrakeLoop() async {
    while (_isBraking && _brakeProgress < 1.0 && mounted) {
      _onBrakeTick();
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }
}

class _BrakeRollerPainter extends CustomPainter {
  final double rollerProgress;
  final double leftForce;
  final double rightForce;
  final double imbalance;
  final bool isBraking;
  final double progress;

  _BrakeRollerPainter({
    required this.rollerProgress,
    required this.leftForce,
    required this.rightForce,
    required this.imbalance,
    required this.isBraking,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // 1. Grid
    final gridPaint = Paint()..color = const Color(0xFF141926)..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Dual Brake Rollers (Left & Right)
    final rollerWidth = 70.0;
    final rollerHeight = 44.0;
    final leftRollerRect = Rect.fromLTWH(cx - 100, 30, rollerWidth, rollerHeight);
    final rightRollerRect = Rect.fromLTWH(cx + 30, 30, rollerWidth, rollerHeight);

    final rollerPaint = Paint()..color = const Color(0xFF1E283D);
    final rollerBorder = Paint()
      ..color = const Color(0xFF384A6E)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(leftRollerRect, const Radius.circular(6)), rollerPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(leftRollerRect, const Radius.circular(6)), rollerBorder);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRollerRect, const Radius.circular(6)), rollerPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRollerRect, const Radius.circular(6)), rollerBorder);

    // Roller spin stripes
    final stripePaint = Paint()
      ..color = isBraking ? AppColors.brutalGreen.withValues(alpha: 0.6) : const Color(0xFF475569)
      ..strokeWidth = 3.0;

    final stripeOffset = (rollerProgress * 20.0);
    for (double x = leftRollerRect.left + 8; x < leftRollerRect.right - 4; x += 16) {
      final dx = leftRollerRect.left + ((x - leftRollerRect.left + stripeOffset) % (rollerWidth - 10));
      canvas.drawLine(Offset(dx, leftRollerRect.top + 4), Offset(dx, leftRollerRect.bottom - 4), stripePaint);
    }
    for (double x = rightRollerRect.left + 8; x < rightRollerRect.right - 4; x += 16) {
      final dx = rightRollerRect.left + ((x - rightRollerRect.left + stripeOffset) % (rollerWidth - 10));
      canvas.drawLine(Offset(dx, rightRollerRect.top + 4), Offset(dx, rightRollerRect.bottom - 4), stripePaint);
    }

    // 3. Digital Gauges (Left / Right Force)
    final gaugeY = 120.0;
    _drawDigitalNeedle(canvas, Offset(cx - 65, gaugeY), 'SOL: ${leftForce.toStringAsFixed(1)} kN', leftForce / 5.0);
    _drawDigitalNeedle(canvas, Offset(cx + 65, gaugeY), 'SAĞ: ${rightForce.toStringAsFixed(1)} kN', rightForce / 5.0);

    // 4. Progress bar at bottom
    final barRect = Rect.fromLTWH(30, size.height - 24, size.width - 60, 10);
    final bgBarPaint = Paint()..color = const Color(0xFF1E283D);
    final fillBarPaint = Paint()..color = AppColors.brutalGreen;
    canvas.drawRRect(RRect.fromRectAndRadius(barRect, const Radius.circular(5)), bgBarPaint);
    final fillRect = Rect.fromLTWH(30, size.height - 24, (size.width - 60) * progress, 10);
    canvas.drawRRect(RRect.fromRectAndRadius(fillRect, const Radius.circular(5)), fillBarPaint);
  }

  void _drawDigitalNeedle(Canvas canvas, Offset center, String label, double ratio) {
    final arcPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    final fillArc = Paint()
      ..color = isBraking ? AppColors.brutalGreen : const Color(0xFF38BDF8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: 26), math.pi * 0.8, math.pi * 1.4, false, arcPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: 26),
      math.pi * 0.8,
      math.pi * 1.4 * ratio.clamp(0.0, 1.0),
      false,
      fillArc,
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

    // 1. Grid & Crosshair Target
    final targetPaint = Paint()
      ..color = accuracy > 0.8 ? AppColors.brutalGreen : const Color(0xFF38BDF8)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    // Crosshair target circle
    canvas.drawCircle(center + targetOffset, 18, targetPaint);
    canvas.drawCircle(center + targetOffset, 36, targetPaint);
    canvas.drawLine(Offset(center.dx - 50, center.dy), Offset(center.dx + 50, center.dy), targetPaint);
    canvas.drawLine(Offset(center.dx, center.dy - 50), Offset(center.dx, center.dy + 50), targetPaint);

    // 2. Optical Headlight Beam Flare (Draggable)
    final beamCenter = center + beamOffset;

    final flareOuter = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.7),
          const Color(0xFF0284C7).withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: beamCenter, radius: 45));

    final flareCore = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(beamCenter, 45, flareOuter);
    canvas.drawCircle(beamCenter, 8, flareCore);
  }

  @override
  bool shouldRepaint(covariant _HeadlightBeamPainter oldDelegate) => true;
}
