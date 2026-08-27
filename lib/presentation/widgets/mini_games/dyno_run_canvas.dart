import '../../../core/localization/app_localizations.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/tuning_model.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import 'neo_brutal_poly_painter.dart';

class DynoRunCanvasModal extends StatefulWidget {
  final CarModel car;
  final CarDynoStats dyno;

  const DynoRunCanvasModal({
    super.key,
    required this.car,
    required this.dyno,
  });

  static Future<void> show(BuildContext context,
      {required CarModel car, required CarDynoStats dyno}) {
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
    )
      ..addListener(_onTick)
      ..forward();
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
            color: _random.nextBool()
                ? const Color(0xFFFF9529)
                : const Color(0xFFFF007F),
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
    final liveHp =
        (dyno.baseHp + (dyno.totalHp - dyno.baseHp) * progress).round();
    final liveNm =
        (dyno.baseNm + (dyno.totalNm - dyno.baseNm) * progress).round();

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
                  children: [
                    const Icon(Icons.speed_rounded,
                        color: AppColors.brutalYellow, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('dyno_title'),
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
                  text: _isComplete
                      ? context.tr('dyno_status_finished')
                      : context.tr('dyno_status_measuring'),
                  backgroundColor: _isComplete
                      ? AppColors.brutalGreen
                      : AppColors.brutalYellow,
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
                  _buildStatPill(
                      context.tr('dyno_stat_rpm'),
                      '${_currentRpm.toInt()} RPM',
                      'MAX 7500',
                      const Color(0xFF38BDF8)),
                  _buildStatPill(
                      context.tr('dyno_stat_hp'),
                      '$liveHp HP',
                      '+${dyno.totalHp - dyno.baseHp} HP',
                      AppColors.brutalGreen),
                  _buildStatPill(
                      context.tr('dyno_stat_nm'),
                      '$liveNm Nm',
                      '+${dyno.totalNm - dyno.baseNm} Nm',
                      AppColors.brutalOrange),
                  _buildStatPill(
                      context.tr('dyno_stat_sound'),
                      '${dyno.exhaustDb} dB',
                      dyno.exhaustDb > 95
                          ? context.tr('dyno_sound_high')
                          : context.tr('dyno_sound_normal'),
                      const Color(0xFFA855F7)),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.brutalGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalGreen, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.brutalGreen, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.tr('dyno_result_success',
                            {'hp': '${dyno.totalHp}', 'nm': '${dyno.totalNm}'}),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.brutalGreen),
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
                label: _isComplete
                    ? context.tr('dyno_btn_save')
                    : context.tr('dyno_btn_measuring'),
                backgroundColor: _isComplete
                    ? AppColors.brutalYellow
                    : const Color(0xFF475569),
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
        Text(label,
            style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w900, color: color)),
        Text(sub,
            style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B))),
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

    // 1. Technical CRT Oscilloscope Grid
    NeoBrutalPolyPainter.drawCRTGrid(
      canvas,
      size,
      gridColor: const Color(0xFF141A28),
      spacing: 16.0,
      drawCrosshair: true,
    );

    // Hazard Safety Striping at Bottom Dyno Bed
    NeoBrutalPolyPainter.drawHazardStripes(
      canvas,
      Rect.fromLTWH(8, h * 0.88, w - 16, 12),
      stripeWidth: 8,
      borderWidth: 1.5,
    );

    // 2. Live Stepped Oscilloscope Curves (HP & NM)
    final hpCurvePaint = Paint()
      ..color = AppColors.brutalGreen
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke;

    final nmCurvePaint = Paint()
      ..color = AppColors.brutalOrange
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final hpPath = Path();
    final nmPath = Path();

    hpPath.moveTo(0, h * 0.82);
    nmPath.moveTo(0, h * 0.82);

    final currentX = w * progress;
    double lastHpY = h * 0.82;
    double lastNmY = h * 0.82;

    for (double x = 0; x <= currentX; x += 4) {
      final normX = x / w;
      final curveYHp = h * 0.82 - (h * 0.65) * (math.pow(normX, 1.3));
      final curveYNm = h * 0.82 - (h * 0.55) * math.sin(normX * math.pi * 0.8);

      hpPath.lineTo(x, curveYHp);
      nmPath.lineTo(x, curveYNm);
      lastHpY = curveYHp;
      lastNmY = curveYNm;
    }

    canvas.drawPath(hpPath, hpCurvePaint);
    canvas.drawPath(nmPath, nmCurvePaint);

    // Live Peak Prismatic Diamonds at leading edge of graph
    if (progress > 0.05) {
      NeoBrutalPolyPainter.drawPrismaticDiamond(
        canvas,
        Offset(currentX, lastHpY),
        7.0,
        AppColors.brutalGreen,
        strokeWidth: 1.5,
      );
      NeoBrutalPolyPainter.drawPrismaticDiamond(
        canvas,
        Offset(currentX, lastNmY),
        6.0,
        AppColors.brutalOrange,
        strokeWidth: 1.5,
      );
    }

    // 3. Low-Poly 3D Dyno Rollers (Left & Right)
    _drawLowPolyRoller(canvas, Offset(w * 0.35, h * 0.76), rollerAngle);
    _drawLowPolyRoller(canvas, Offset(w * 0.68, h * 0.76), rollerAngle);

    // 4. Low-Poly Faceted Car Side Profile
    _drawLowPolyCarSide(canvas, size);

    // 5. Prismatic Exhaust Flame Spark Bursts
    for (final s in sparks) {
      final alpha = (s.life / 14.0).clamp(0.0, 1.0);
      NeoBrutalPolyPainter.drawPrismaticDiamond(
        canvas,
        Offset(w * 0.20 + s.x * 0.25, h * 0.60 + s.y * 0.15),
        5.5 * alpha,
        s.color.withValues(alpha: alpha),
        strokeWidth: 1.0,
      );
    }
  }

  void _drawLowPolyRoller(Canvas canvas, Offset center, double angle) {
    // 8-faceted low-poly drum
    final numSides = 8;
    final radius = 16.0;
    final vertices = <Offset>[];
    for (int i = 0; i < numSides; i++) {
      final a = angle + (i * 2 * math.pi / numSides);
      vertices.add(Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      ));
    }

    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      vertices,
      color: const Color(0xFF334155),
      lightFactor: 1.0,
      strokeWidth: 2.0,
    );

    // Rotating segment lines
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0;
    final dx = math.cos(angle) * 12;
    final dy = math.sin(angle) * 12;
    canvas.drawLine(
      Offset(center.dx - dx, center.dy - dy),
      Offset(center.dx + dx, center.dy + dy),
      spokePaint,
    );

    // 3D Hex Bolt Hub at Center
    NeoBrutalPolyPainter.draw3DHexBolt(
      canvas,
      center,
      6.0,
      baseColor: const Color(0xFF64748B),
      isLoosened: false,
    );
  }

  void _drawLowPolyCarSide(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Faceted Lower Body Chassis
    final bodyVertices = [
      Offset(w * 0.22, h * 0.62),
      Offset(w * 0.28, h * 0.50),
      Offset(w * 0.40, h * 0.48),
      Offset(w * 0.70, h * 0.49),
      Offset(w * 0.78, h * 0.56),
      Offset(w * 0.78, h * 0.65),
      Offset(w * 0.22, h * 0.65),
    ];
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      bodyVertices,
      color: const Color(0xFFFFDE59),
      lightFactor: 1.0,
      strokeWidth: 2.2,
    );

    // Faceted Cockpit / Roof
    final cabinVertices = [
      Offset(w * 0.38, h * 0.48),
      Offset(w * 0.44, h * 0.36),
      Offset(w * 0.58, h * 0.36),
      Offset(w * 0.65, h * 0.48),
    ];
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      cabinVertices,
      color: const Color(0xFF0F172A),
      lightFactor: 0.85,
      strokeWidth: 2.0,
    );

    // Low-poly side glass
    final glassVertices = [
      Offset(w * 0.45, h * 0.46),
      Offset(w * 0.47, h * 0.39),
      Offset(w * 0.56, h * 0.39),
      Offset(w * 0.62, h * 0.46),
    ];
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      glassVertices,
      color: const Color(0xFF38BDF8),
      lightFactor: 1.2,
      strokeWidth: 1.2,
      strokeColor: Colors.black,
    );

    // Wheels (Octagonal Low-Poly)
    _drawOctaWheel(canvas, Offset(w * 0.35, h * 0.64));
    _drawOctaWheel(canvas, Offset(w * 0.68, h * 0.64));
  }

  void _drawOctaWheel(Canvas canvas, Offset center) {
    final numSides = 8;
    final radius = 11.0;
    final vertices = <Offset>[];
    for (int i = 0; i < numSides; i++) {
      final a = (i * 2 * math.pi / numSides);
      vertices.add(Offset(
        center.dx + radius * math.cos(a),
        center.dy + radius * math.sin(a),
      ));
    }
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      vertices,
      color: const Color(0xFF1E293B),
      lightFactor: 0.9,
      strokeWidth: 2.0,
    );

    // Hub center
    NeoBrutalPolyPainter.draw3DHexBolt(
      canvas,
      center,
      4.0,
      baseColor: const Color(0xFF94A3B8),
      isLoosened: false,
    );
  }

  @override
  bool shouldRepaint(covariant _DynoPainter oldDelegate) => true;
}
