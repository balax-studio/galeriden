import '../../../core/localization/app_localizations.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';
import 'neo_brutal_poly_painter.dart';

class ScrapyardTeardownModal extends StatefulWidget {
  final String partName;
  final String carName;
  final int initialCondition;
  final Function(bool isSuccessful, int finalCondition, String message)
      onCompleted;

  const ScrapyardTeardownModal({
    super.key,
    required this.partName,
    required this.carName,
    required this.initialCondition,
    required this.onCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required String partName,
    required String carName,
    required int initialCondition,
    required Function(bool isSuccessful, int finalCondition, String message)
        onCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ScrapyardTeardownModal(
        partName: partName,
        carName: carName,
        initialCondition: initialCondition,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<ScrapyardTeardownModal> createState() => _ScrapyardTeardownModalState();
}

class _ScrapyardTeardownModalState extends State<ScrapyardTeardownModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _sweepController;
  final math.Random _random = math.Random();

  int _activeBoltIndex = 0;
  final List<bool> _boltsLoosened = [false, false, false, false];
  final List<int> _boltHealth = [100, 100, 100, 100];
  final List<_TeardownSpark> _sparks = [];

  late int _currentCondition;
  int _failedStrikes = 0;
  bool _isFinished = false;
  bool _isSuccess = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _currentCondition = widget.initialCondition;
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _onApplyTorque() {
    if (_isFinished) return;

    final sweepValue = _sweepController.value * 100.0; // 0 to 100

    // Green zone: 65 to 88
    if (sweepValue >= 65.0 && sweepValue <= 88.0) {
      // Perfect crack
      HapticFeedback.heavyImpact();
      _boltsLoosened[_activeBoltIndex] = true;
      _spawnSparks(_activeBoltIndex);

      if (_boltsLoosened.every((b) => b)) {
        _sweepController.stop();
        _isFinished = true;
        _isSuccess = true;
        // Apply bonus condition
        _currentCondition = math.min(100, _currentCondition + 15);
        _statusMessage = context.tr('teardown_all_done');
      } else {
        // Advance to next unloosened bolt
        _activeBoltIndex = _boltsLoosened.indexOf(false);
        _statusMessage = context.tr('teardown_bolt_progress');
      }
    } else if (sweepValue > 88.0) {
      // Over-torque / Strip zone
      HapticFeedback.vibrate();
      _failedStrikes++;
      _boltHealth[_activeBoltIndex] =
          math.max(0, _boltHealth[_activeBoltIndex] - 40);
      _currentCondition = math.max(10, _currentCondition - 8);

      if (_failedStrikes >= 3 || _boltHealth[_activeBoltIndex] <= 0) {
        _sweepController.stop();
        _isFinished = true;
        _isSuccess = false;
        _statusMessage = context.tr('teardown_bolt_broken');
      } else {
        _statusMessage = context.tr('teardown_overtorque_warning');
      }
    } else {
      // Under-torque: Pas sökülmedi
      HapticFeedback.selectionClick();
      _statusMessage = context.tr('teardown_undertorque_warning');
    }

    setState(() {});
  }

  void _spawnSparks(int boltIndex) {
    for (int i = 0; i < 14; i++) {
      _sparks.add(
        _TeardownSpark(
          x: 0,
          y: 0,
          vx: _random.nextDouble() * 8 - 4,
          vy: _random.nextDouble() * 8 - 4,
          color: _random.nextBool()
              ? AppColors.brutalYellow
              : AppColors.brutalOrange,
          life: 1.0,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F1420),
        borderColor: _isFinished
            ? (_isSuccess ? AppColors.brutalGreen : AppColors.errorRed)
            : AppColors.brutalYellow,
        borderWidth: 2.6,
        borderRadius: 16,
        showHazardHeader: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('teardown_title'),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.carName} • ${widget.partName}',
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
                  text: context.tr('teardown_condition_badge',
                      {'cond': '$_currentCondition'}),
                  backgroundColor: _currentCondition >= 60
                      ? AppColors.brutalGreen
                      : AppColors.brutalOrange,
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Canvas Display Area
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF070A10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF242C3D),
                  width: 2.0,
                ),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _sweepController,
                    builder: (context, _) {
                      return RepaintBoundary(
                        child: CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: _ScrapyardTeardownPainter(
                            activeBoltIndex: _activeBoltIndex,
                            boltsLoosened: _boltsLoosened,
                            boltHealth: _boltHealth,
                            sweepProgress: _sweepController.value,
                            sparks: _sparks,
                          ),
                        ),
                      );
                    },
                  ),
                  if (_isFinished)
                    Positioned.fill(
                      child: Center(
                        child: SlamStampWidget(
                          text: _isSuccess
                              ? context.tr('teardown_stamp_perfect')
                              : context.tr('teardown_stamp_broken'),
                          color: _isSuccess
                              ? AppColors.brutalGreen
                              : AppColors.errorRed,
                          fontSize: 22,
                          angle: -0.08,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Status message
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF161C2A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A3449)),
              ),
              child: Text(
                _statusMessage ?? context.tr('teardown_instruction'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _isFinished
                      ? (_isSuccess
                          ? AppColors.brutalGreen
                          : AppColors.errorRed)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            if (!_isFinished) ...[
              NeoBrutalButton(
                label: context.tr('teardown_btn_apply'),
                icon: Icons.build_circle_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: _onApplyTorque,
              ),
            ] else ...[
              NeoBrutalButton(
                label: _isSuccess
                    ? context.tr('teardown_btn_store_part')
                    : context.tr('teardown_btn_finish_scrap'),
                icon: Icons.check_circle_rounded,
                backgroundColor:
                    _isSuccess ? AppColors.brutalGreen : AppColors.errorRed,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  widget.onCompleted(_isSuccess, _currentCondition,
                      _statusMessage ?? context.tr('teardown_instruction'));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TeardownSpark {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double life;

  _TeardownSpark({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.life,
  });
}

class _ScrapyardTeardownPainter extends CustomPainter {
  final int activeBoltIndex;
  final List<bool> boltsLoosened;
  final List<int> boltHealth;
  final double sweepProgress;
  final List<_TeardownSpark> sparks;

  _ScrapyardTeardownPainter({
    required this.activeBoltIndex,
    required this.boltsLoosened,
    required this.boltHealth,
    required this.sweepProgress,
    required this.sparks,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 - 18;

    // 1. CRT Technical Grid
    NeoBrutalPolyPainter.drawCRTGrid(canvas, size, gridColor: const Color(0xFF151C2C));

    // 2. Central Faceted Low-Poly Engine Block
    final engineVertices = [
      Offset(cx - 65, cy - 35),
      Offset(cx + 65, cy - 35),
      Offset(cx + 72, cy - 10),
      Offset(cx + 62, cy + 38),
      Offset(cx - 62, cy + 38),
      Offset(cx - 72, cy - 10),
    ];

    // Engine Base Shadow (0-blur)
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      engineVertices,
      color: const Color(0xFF1E283D),
      lightFactor: 1.0,
      strokeWidth: 2.8,
      strokeColor: Colors.black,
      showHardShadow: true,
      shadowOffset: const Offset(4, 4),
      shadowColor: Colors.black,
    );

    // Engine Block Facet Divisions
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      [Offset(cx - 40, cy - 25), Offset(cx + 40, cy - 25), Offset(cx + 35, cy + 20), Offset(cx - 35, cy + 20)],
      color: const Color(0xFF0F172A),
      lightFactor: 1.15,
      strokeWidth: 2.0,
    );

    // Hazard Stripes Badge on Block
    NeoBrutalPolyPainter.drawHazardStripes(
      canvas,
      Rect.fromCenter(center: Offset(cx, cy - 2), width: 50, height: 12),
      stripeWidth: 8,
      borderWidth: 1.5,
    );

    // 3. 4 Low-Poly 3D Hexagonal Bolts
    final boltOffsets = [
      Offset(cx - 50, cy - 24),
      Offset(cx + 50, cy - 24),
      Offset(cx + 46, cy + 24),
      Offset(cx - 46, cy + 24),
    ];

    for (int i = 0; i < boltOffsets.length; i++) {
      final pos = boltOffsets[i];
      final isLoosened = boltsLoosened[i];
      final isActive = i == activeBoltIndex && !isLoosened;

      final boltColor = isLoosened
          ? AppColors.brutalGreen
          : (isActive ? AppColors.brutalYellow : const Color(0xFF94A3B8));

      NeoBrutalPolyPainter.draw3DHexBolt(
        canvas,
        pos,
        12.0,
        rotation: i * 0.4,
        boltColor: boltColor,
        depth: isLoosened ? 1.0 : 4.5,
        strokeWidth: 2.2,
      );
    }

    // 4. Prismatic Diamond Sparks
    for (final spark in sparks) {
      if (spark.life > 0) {
        NeoBrutalPolyPainter.drawPrismaticDiamond(
          canvas,
          boltOffsets[activeBoltIndex] + Offset(spark.x, spark.y),
          8.0 * spark.life,
          spark.color,
        );
      }
    }

    // 5. Bottom Neo-Brutal Torque Gauge
    final meterY = size.height - 24;
    final meterLeft = 24.0;
    final meterRight = size.width - 24.0;
    final meterWidth = meterRight - meterLeft;

    // Outer Gauge Box
    final meterRect = Rect.fromLTWH(meterLeft, meterY - 8, meterWidth, 16);
    canvas.drawRect(meterRect, Paint()..color = const Color(0xFF0F172A));
    canvas.drawRect(
      meterRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4,
    );

    // Green Zone
    final greenRect = Rect.fromLTWH(
      meterLeft + meterWidth * 0.65,
      meterY - 8,
      meterWidth * 0.23,
      16,
    );
    canvas.drawRect(greenRect, Paint()..color = AppColors.brutalGreen);
    canvas.drawRect(
      greenRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Red Over-torque Zone
    final redRect = Rect.fromLTWH(
      meterLeft + meterWidth * 0.88,
      meterY - 8,
      meterWidth * 0.12,
      16,
    );
    canvas.drawRect(redRect, Paint()..color = AppColors.errorRed);

    // Sweep Pointer (Low-Poly Triangle)
    final needleX = meterLeft + meterWidth * sweepProgress;
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      [
        Offset(needleX - 6, meterY - 14),
        Offset(needleX + 6, meterY - 14),
        Offset(needleX, meterY + 12),
      ],
      color: Colors.white,
      lightFactor: 1.2,
      strokeWidth: 2.0,
    );
  }

  @override
  bool shouldRepaint(covariant _ScrapyardTeardownPainter oldDelegate) => true;
}
