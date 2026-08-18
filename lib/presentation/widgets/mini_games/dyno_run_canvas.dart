import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/tuning_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

class DynoRunCanvasModal extends StatefulWidget {
  final CarModel car;
  final CarDynoStats dyno;

  const DynoRunCanvasModal({
    super.key,
    required this.car,
    required this.dyno,
  });

  static Future<void> show(BuildContext context, {required CarModel car, required CarDynoStats dyno}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DynoRunCanvasModal(car: car, dyno: dyno),
    );
  }

  @override
  State<DynoRunCanvasModal> createState() => _DynoRunCanvasModalState();
}

class _DynoRunCanvasModalState extends State<DynoRunCanvasModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _dynoController;
  double _currentRpm = 1000.0;
  double _rollerAngle = 0.0;
  bool _isComplete = false;
  final List<DynoFlameParticle> _sparks = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _dynoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(_onTick)..forward();
  }

  void _onTick() {
    if (!mounted) return;
    final progress = _dynoController.value;

    setState(() {
      _currentRpm = 1000.0 + progress * 6500.0;
      _rollerAngle += 0.2 + progress * 0.5;

      // Haptic rev pulses
      if (progress > 0.75 && _random.nextDouble() < 0.4) {
        HapticFeedback.mediumImpact();
      }

      // Exhaust flame sparks
      if (progress > 0.6) {
        _sparks.add(
          DynoFlameParticle(
            x: 60.0,
            y: 110.0,
            vx: -3.0 - _random.nextDouble() * 4.0,
            vy: _random.nextDouble() * 2.0 - 1.0,
            color: _random.nextBool() ? const Color(0xFFFF9529) : const Color(0xFFFF007F),
          ),
        );
      }

      for (final s in _sparks) {
        s.update();
      }
      _sparks.removeWhere((s) => s.life <= 0);

      if (progress >= 1.0 && !_isComplete) {
        _isComplete = true;
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _dynoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dyno = widget.dyno;
    final progress = _dynoController.value;
    final liveHp = (dyno.baseHp + (dyno.totalHp - dyno.baseHp) * progress).round();
    final liveNm = (dyno.baseNm + (dyno.totalNm - dyno.baseNm) * progress).round();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F121C),
        borderColor: AppColors.brutalYellow,
        borderWidth: 2.6,
        borderRadius: 16,
        showHazardHeader: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.speed_rounded, color: AppColors.brutalYellow, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'DYNO GÜÇ & TORK TESTİ',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: _isComplete ? 'TEST BİTTİ' : 'ÖLÇÜLÜYOR...',
                  backgroundColor: _isComplete ? AppColors.brutalGreen : AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Readout Row
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF161B26),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF283247), width: 1.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatPill('DEVİR', '${_currentRpm.toInt()} RPM', 'MAX 7500', const Color(0xFF38BDF8)),
                  _buildStatPill('GÜÇ', '$liveHp HP', '+${dyno.totalHp - dyno.baseHp} HP', AppColors.brutalGreen),
                  _buildStatPill('TORK', '$liveNm Nm', '+${dyno.totalNm - dyno.baseNm} Nm', AppColors.brutalOrange),
                  _buildStatPill('SES', '${dyno.exhaustDb} dB', dyno.exhaustDb > 95 ? 'YÜKSEK' : 'NORMAL', const Color(0xFFA855F7)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2D Dyno & Graph Canvas
            Container(
              height: 170,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF07090F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF20283A), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: _DynoPainter(
                    rollerAngle: _rollerAngle,
                    progress: progress,
                    sparks: _sparks,
                    carModel: widget.car.modelName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            if (_isComplete) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.brutalGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalGreen, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.brutalGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dyno testi başarıyla tamamlandı! Araç gücü ${dyno.totalHp} HP ve ${dyno.totalNm} Nm olarak onaylandı.',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: NeoBrutalButton(
                label: _isComplete ? 'TESTİ TAMAMLA VE KAYDET' : 'ÖLÇÜM DEVAM EDİYOR...',
                backgroundColor: _isComplete ? AppColors.brutalYellow : const Color(0xFF475569),
                textColor: Colors.black,
                fontSize: 12,
                onPressed: _isComplete ? () => Navigator.pop(context) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatPill(String label, String value, String sub, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: color)),
        Text(sub, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
      ],
    );
  }
}

class DynoFlameParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  int life = 14;

  DynoFlameParticle({
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

class _DynoPainter extends CustomPainter {
  final double rollerAngle;
  final double progress;
  final List<DynoFlameParticle> sparks;
  final String carModel;

  _DynoPainter({
    required this.rollerAngle,
    required this.progress,
    required this.sparks,
    required this.carModel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF141A28)
      ..strokeWidth = 1.0;

    for (double x = 0; x < w; x += 18) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }
    for (double y = 0; y < h; y += 18) {
      canvas.drawLine(Offset(0, y), Offset(w, y), gridPaint);
    }

    // Live HP / Torque Graph Curve
    final hpCurvePaint = Paint()
      ..color = AppColors.brutalGreen
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final nmCurvePaint = Paint()
      ..color = AppColors.brutalOrange
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final hpPath = Path();
    final nmPath = Path();

    hpPath.moveTo(0, h * 0.85);
    nmPath.moveTo(0, h * 0.85);

    final currentX = w * progress;
    for (double x = 0; x <= currentX; x += 4) {
      final normX = x / w;
      // Exponential curve for HP
      final curveYHp = h * 0.85 - (h * 0.70) * (math.pow(normX, 1.3));
      // Bell/plateau curve for Torque
      final curveYNm = h * 0.85 - (h * 0.60) * math.sin(normX * math.pi * 0.8);

      hpPath.lineTo(x, curveYHp);
      nmPath.lineTo(x, curveYNm);
    }

    canvas.drawPath(hpPath, hpCurvePaint);
    canvas.drawPath(nmPath, nmCurvePaint);

    // Dyno Rollers (Bottom Platform)
    final rollerPaint = Paint()..color = const Color(0xFF2B364F);
    final rollerBorder = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Front & Rear Rollers
    _drawRoller(canvas, Offset(w * 0.35, h * 0.78), rollerAngle, rollerPaint, rollerBorder);
    _drawRoller(canvas, Offset(w * 0.68, h * 0.78), rollerAngle, rollerPaint, rollerBorder);

    // Car Outline on Rollers
    final carPaint = Paint()..color = const Color(0xFFFFDE59);
    final carBorder = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final carBody = Rect.fromLTWH(w * 0.25, h * 0.48, w * 0.50, 24);
    canvas.drawRRect(RRect.fromRectAndRadius(carBody, const Radius.circular(5)), carPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(carBody, const Radius.circular(5)), carBorder);

    final cabin = Rect.fromLTWH(w * 0.38, h * 0.38, w * 0.22, 14);
    canvas.drawRRect(RRect.fromRectAndRadius(cabin, const Radius.circular(4)), Paint()..color = const Color(0xFF0F172A));
    canvas.drawRRect(RRect.fromRectAndRadius(cabin, const Radius.circular(4)), carBorder);

    // Wheels on Rollers
    canvas.drawCircle(Offset(w * 0.35, h * 0.65), 10, Paint()..color = const Color(0xFF1E293B));
    canvas.drawCircle(Offset(w * 0.68, h * 0.65), 10, Paint()..color = const Color(0xFF1E293B));

    // Exhaust flame sparks
    for (final s in sparks) {
      final sPaint = Paint()..color = s.color.withValues(alpha: s.life / 14.0);
      canvas.drawCircle(Offset(w * 0.24 + s.x * 0.2, h * 0.62 + s.y * 0.1), 3.0, sPaint);
    }
  }

  void _drawRoller(Canvas canvas, Offset center, double angle, Paint fill, Paint border) {
    canvas.drawCircle(center, 14, fill);
    canvas.drawCircle(center, 14, border);

    // Rotating spokes lines
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.8;

    final dx = math.cos(angle) * 12;
    final dy = math.sin(angle) * 12;
    canvas.drawLine(Offset(center.dx - dx, center.dy - dy), Offset(center.dx + dx, center.dy + dy), spokePaint);
  }

  @override
  bool shouldRepaint(covariant _DynoPainter oldDelegate) => true;
}
