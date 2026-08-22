import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/black_market_car_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';

class HiddenStashModal extends StatefulWidget {
  final BlackMarketCarModel car;
  final Function(bool stashFound, double rewardCash, String foundItemDescription) onInspectionCompleted;

  const HiddenStashModal({
    super.key,
    required this.car,
    required this.onInspectionCompleted,
  });

  static Future<void> show(
    BuildContext context, {
    required BlackMarketCarModel car,
    required Function(bool stashFound, double rewardCash, String foundItemDescription) onInspectionCompleted,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => HiddenStashModal(
        car: car,
        onInspectionCompleted: onInspectionCompleted,
      ),
    );
  }

  @override
  State<HiddenStashModal> createState() => _HiddenStashModalState();
}

class _HiddenStashModalState extends State<HiddenStashModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  Offset _flashlightPos = const Offset(50, 50);
  final List<Offset> _scannedSpots = [];

  // Hidden stash targets on the car
  final Offset _stashTarget = const Offset(190, 85); // Boot area
  double _stashDiscoveryProgress = 0.0;
  bool _isFound = false;
  bool _isFinished = false;

  double _rewardCash = 0.0;
  String _foundItemDescription = '';
  String _statusMessage = 'UV fenerini araba gövdesinde gezdirerek zulayı ara!';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _rewardCash = (widget.car.realMarketValue * 0.08).clamp(15000.0, 60000.0);
    _foundItemDescription = 'Bagaj döşemesi altında gizli ${widget.car.modelName} yarış beyni ve nakit para bulundu!';
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _processPointerPosition(Offset pos, Size size) {
    if (_isFinished) return;

    _scannedSpots.add(pos);

    // Target boot / chassis area
    final dist = (pos - _stashTarget).distance;

    if (dist < 65.0) {
      _stashDiscoveryProgress = (_stashDiscoveryProgress + 0.15).clamp(0.0, 1.0);
      HapticFeedback.selectionClick();

      if (_stashDiscoveryProgress >= 1.0 && !_isFound) {
        _isFound = true;
        _isFinished = true;
        HapticFeedback.heavyImpact();
        _statusMessage = 'Zula bulundu! +${_rewardCash.toInt()} TL Değerinde Kaçak Çip & Nakit!';
      } else {
        _statusMessage = 'Sinyal güçleniyor! Zula noktasını taramaya devam et (%${(_stashDiscoveryProgress * 100).round()})...';
      }
    } else {
      _statusMessage = 'Gövde taranıyor • UV dedektörünü gezdirerek zulayı yakala...';
    }

    setState(() {
      _flashlightPos = pos;
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
        borderColor: _isFinished ? AppColors.brutalGreen : AppColors.errorRed,
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
                        context.tr('stash_title'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('stash_subtitle', {'brand': widget.car.brand, 'model': widget.car.modelName}),
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
                  text: _isFound ? 'ZULA BULUNDU' : 'TARAMA: %${(_stashDiscoveryProgress * 100).round()}',
                  backgroundColor: _isFound ? AppColors.brutalGreen : AppColors.errorRed,
                  textColor: _isFound ? Colors.black : Colors.white,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Canvas Display
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF06080D),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF242C3D), width: 2.0),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) => _processPointerPosition(details.localPosition, size),
                        onPanStart: (details) => _processPointerPosition(details.localPosition, size),
                        onPanUpdate: (details) => _processPointerPosition(details.localPosition, size),
                        child: CustomPaint(
                          size: size,
                          painter: _HiddenStashPainter(
                            flashlightPos: _flashlightPos,
                            stashTarget: _stashTarget,
                            discoveryProgress: _stashDiscoveryProgress,
                            isFound: _isFound,
                          ),
                        ),
                      );
                    },
                  ),
                  if (_isFound)
                    Positioned.fill(
                      child: Center(
                        child: SlamStampWidget(
                          text: context.tr('stash_badge_found'),
                          color: AppColors.brutalGreen,
                          fontSize: 22,
                          angle: -0.07,
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
                _statusMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _isFound ? AppColors.brutalGreen : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Action Buttons
            if (!_isFinished) ...[
              NeoBrutalButton(
                label: context.tr('stash_btn_auto'),
                icon: Icons.flash_on_rounded,
                backgroundColor: const Color(0xFF1E293B),
                textColor: Colors.white,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(vertical: 11),
                onPressed: () {
                  setState(() {
                    _stashDiscoveryProgress = 1.0;
                    _isFound = true;
                    _isFinished = true;
                    _statusMessage = 'Zula bulundu! +${_rewardCash.toInt()} TL Değerinde Kaçak Çip & Nakit!';
                  });
                },
              ),
            ] else ...[
              NeoBrutalButton(
                label: context.tr('stash_btn_claim'),
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                  widget.onInspectionCompleted(_isFound, _rewardCash, _foundItemDescription);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HiddenStashPainter extends CustomPainter {
  final Offset flashlightPos;
  final Offset stashTarget;
  final double discoveryProgress;
  final bool isFound;

  _HiddenStashPainter({
    required this.flashlightPos,
    required this.stashTarget,
    required this.discoveryProgress,
    required this.isFound,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Grid
    final gridPaint = Paint()..color = const Color(0xFF0F1420)..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Car Blueprint Silhouette Outline
    final carPath = Path();
    final carLeft = cx - 110;
    final carTop = cy - 20;

    carPath.moveTo(carLeft, carTop + 35);
    carPath.lineTo(carLeft + 25, carTop + 35); // Front bumper
    carPath.lineTo(carLeft + 45, carTop + 10); // Hood
    carPath.lineTo(carLeft + 85, carTop - 15); // Windshield
    carPath.lineTo(carLeft + 155, carTop - 15); // Roof
    carPath.lineTo(carLeft + 185, carTop + 10); // Rear window
    carPath.lineTo(carLeft + 220, carTop + 15); // Trunk
    carPath.lineTo(carLeft + 220, carTop + 35); // Rear bumper
    carPath.lineTo(carLeft, carTop + 35); // Bottom

    final carPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(carPath, carPaint);

    // Wheels
    final wheelPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(carLeft + 45, carTop + 35), 14, wheelPaint);
    canvas.drawCircle(Offset(carLeft + 175, carTop + 35), 14, wheelPaint);

    // 3. Secret Stash Compartment
    if (discoveryProgress > 0.0) {
      final stashPaint = Paint()
        ..color = (isFound ? AppColors.brutalGreen : AppColors.errorRed).withValues(alpha: discoveryProgress)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: stashTarget, width: 28, height: 18),
          const Radius.circular(4),
        ),
        stashPaint,
      );

      final iconPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(stashTarget.dx - 6, stashTarget.dy), Offset(stashTarget.dx + 6, stashTarget.dy), iconPaint);
      canvas.drawLine(Offset(stashTarget.dx, stashTarget.dy - 5), Offset(stashTarget.dx, stashTarget.dy + 5), iconPaint);
    }

    // 4. UV Flashlight Beam
    final beamGradient = RadialGradient(
      colors: [
        const Color(0xFF818CF8).withValues(alpha: 0.65),
        const Color(0xFF6366F1).withValues(alpha: 0.25),
        Colors.transparent,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromCircle(center: flashlightPos, radius: 45));

    final uvPaint = Paint()..shader = beamGradient;
    canvas.drawCircle(flashlightPos, 45, uvPaint);

    // Flashlight center dot
    canvas.drawCircle(flashlightPos, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _HiddenStashPainter oldDelegate) => true;
}
