import '../../../core/localization/app_localizations.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';

class ScrapyardTeardownModal extends StatefulWidget {
  final String partName;
  final String carName;
  final int initialCondition;
  final Function(bool isSuccessful, int finalCondition, String message) onCompleted;

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
    required Function(bool isSuccessful, int finalCondition, String message) onCompleted,
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
  String _statusMessage = 'Tork ibresi yeşil bölgedeyken cıvatayı gevşet!';

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
        _statusMessage = 'Tüm cıvatalar hasarsız söküldü • +%15 Kondisyon Bonusu!';
      } else {
        // Advance to next unloosened bolt
        _activeBoltIndex = _boltsLoosened.indexOf(false);
        _statusMessage = '${_boltsLoosened.where((b) => b).length}/4 Cıvata gevşetildi! Sıradakine geç.';
      }
    } else if (sweepValue > 88.0) {
      // Over-torque / Strip zone
      HapticFeedback.vibrate();
      _failedStrikes++;
      _boltHealth[_activeBoltIndex] = math.max(0, _boltHealth[_activeBoltIndex] - 40);
      _currentCondition = math.max(10, _currentCondition - 8);

      if (_failedStrikes >= 3 || _boltHealth[_activeBoltIndex] <= 0) {
        _sweepController.stop();
        _isFinished = true;
        _isSuccess = false;
        _statusMessage = 'Aşırı tork yüzünden cıvata kırıldı • Parça hasar gördü!';
      } else {
        _statusMessage = 'DİKKAT: Fazla tork cıvatayı yalama yapıyor!';
      }
    } else {
      // Under-torque: Pas sökülmedi
      HapticFeedback.selectionClick();
      _statusMessage = 'Yetersiz kuvvet • Pas kırılamadı, tekrar dene.';
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
          color: _random.nextBool() ? AppColors.brutalYellow : AppColors.brutalOrange,
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
                  text: context.tr('teardown_condition_badge', {'cond': '$_currentCondition'}),
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
                      return CustomPaint(
                        size: const Size(double.infinity, 200),
                        painter: _ScrapyardTeardownPainter(
                          activeBoltIndex: _activeBoltIndex,
                          boltsLoosened: _boltsLoosened,
                          boltHealth: _boltHealth,
                          sweepProgress: _sweepController.value,
                          sparks: _sparks,
                        ),
                      );
                    },
                  ),
                  if (_isFinished)
                    Positioned.fill(
                      child: Center(
                        child: SlamStampWidget(
                          text: _isSuccess ? context.tr('teardown_stamp_perfect') : context.tr('teardown_stamp_broken'),
                          color: _isSuccess ? AppColors.brutalGreen : AppColors.errorRed,
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
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _isFinished
                      ? (_isSuccess ? AppColors.brutalGreen : AppColors.errorRed)
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
                label: _isSuccess ? 'PARÇAYI DEPOYA AL' : 'HURDAYI TAMAMLA',
                icon: Icons.check_circle_rounded,
                backgroundColor: _isSuccess ? AppColors.brutalGreen : AppColors.errorRed,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  widget.onCompleted(_isSuccess, _currentCondition, _statusMessage);
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
    final cy = size.height / 2 - 15;

    // 1. Grid Background
    final gridPaint = Paint()
      ..color = const Color(0xFF151C2C)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Central Mechanical Part Silhouette
    final partRect = Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 90);
    final partPaint = Paint()
      ..color = const Color(0xFF1E283D)
      ..style = PaintingStyle.fill;
    final partBorderPaint = Paint()
      ..color = const Color(0xFF384A6E)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(RRect.fromRectAndRadius(partRect, const Radius.circular(8)), partPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(partRect, const Radius.circular(8)), partBorderPaint);

    // Inner mechanical lines
    final innerPaint = Paint()
      ..color = const Color(0xFF283650)
      ..strokeWidth = 2.0;
    canvas.drawCircle(Offset(cx, cy), 22, innerPaint);
    canvas.drawLine(Offset(cx - 50, cy), Offset(cx + 50, cy), innerPaint);

    // 3. 4 Bolt Positions
    final boltOffsets = [
      Offset(cx - 50, cy - 30),
      Offset(cx + 50, cy - 30),
      Offset(cx + 50, cy + 30),
      Offset(cx - 50, cy + 30),
    ];

    for (int i = 0; i < boltOffsets.length; i++) {
      final pos = boltOffsets[i];
      final isLoosened = boltsLoosened[i];
      final isActive = i == activeBoltIndex && !isLoosened;

      // Active pulse glow
      if (isActive) {
        final glowPaint = Paint()
          ..color = AppColors.brutalYellow.withValues(alpha: 0.35)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, 16, glowPaint);
      }

      // Bolt outer hex
      final hexPaint = Paint()
        ..color = isLoosened
            ? AppColors.brutalGreen
            : (isActive ? AppColors.brutalYellow : const Color(0xFF64748B))
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 10, hexPaint);

      // Bolt inner thread
      final threadPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, 5, threadPaint);

      // Hex cross slot
      canvas.drawLine(Offset(pos.dx - 3, pos.dy), Offset(pos.dx + 3, pos.dy), threadPaint);
      canvas.drawLine(Offset(pos.dx, pos.dy - 3), Offset(pos.dx, pos.dy + 3), threadPaint);
    }

    // 4. Bottom Torque Meter Scale
    final meterY = size.height - 24;
    final meterLeft = 30.0;
    final meterRight = size.width - 30.0;
    final meterWidth = meterRight - meterLeft;

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0xFF1E283D)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(meterLeft, meterY), Offset(meterRight, meterY), trackPaint);

    // Green zone (65% to 88%)
    final greenZonePaint = Paint()
      ..color = AppColors.brutalGreen
      ..strokeWidth = 10.0;
    canvas.drawLine(
      Offset(meterLeft + meterWidth * 0.65, meterY),
      Offset(meterLeft + meterWidth * 0.88, meterY),
      greenZonePaint,
    );

    // Red zone (>88%)
    final redZonePaint = Paint()
      ..color = AppColors.errorRed
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(meterLeft + meterWidth * 0.88, meterY),
      Offset(meterRight, meterY),
      redZonePaint,
    );

    // Sweeping indicator needle
    final needleX = meterLeft + meterWidth * sweepProgress;
    final needlePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.2;
    canvas.drawLine(Offset(needleX, meterY - 10), Offset(needleX, meterY + 10), needlePaint);

    // Needle pointer cap
    final capPaint = Paint()..color = AppColors.brutalYellow;
    canvas.drawCircle(Offset(needleX, meterY - 10), 4, capPaint);
  }

  @override
  bool shouldRepaint(covariant _ScrapyardTeardownPainter oldDelegate) => true;
}
