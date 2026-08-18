import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/car_model.dart';
import '../../../domain/usecases/night_market_engine.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';

enum RacePhase {
  countdown, // 3, 2, 1, GO
  racing,    // RPM climb, shift timing, nitro burst
  finished,  // Victory / Defeat stamp
}

class DragRaceMiniGameModal extends StatefulWidget {
  final CarModel car;
  final NightRivalModel rival;
  final NightRaceResult raceResult;
  final VoidCallback onFinished;

  const DragRaceMiniGameModal({
    super.key,
    required this.car,
    required this.rival,
    required this.raceResult,
    required this.onFinished,
  });

  static Future<void> show(
    BuildContext context, {
    required CarModel car,
    required NightRivalModel rival,
    required NightRaceResult raceResult,
    required VoidCallback onFinished,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DragRaceMiniGameModal(
        car: car,
        rival: rival,
        raceResult: raceResult,
        onFinished: onFinished,
      ),
    );
  }

  @override
  State<DragRaceMiniGameModal> createState() => _DragRaceMiniGameModalState();
}

class _DragRaceMiniGameModalState extends State<DragRaceMiniGameModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  RacePhase _phase = RacePhase.countdown;

  int _countdownStep = 3; // 3, 2, 1, 0 (GO)
  Timer? _countdownTimer;

  double _rpm = 1000.0; // 1000 to 8000
  bool _hasShifted = false;
  String _shiftFeedback = '';
  Color _shiftFeedbackColor = Colors.transparent;
  double _playerDistance = 0.0; // 0.0 to 1.0
  double _rivalDistance = 0.0;

  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_gameLoop);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownStep = 3;
    _countdownTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      if (_countdownStep > 1) {
        setState(() {
          _countdownStep--;
        });
      } else if (_countdownStep == 1) {
        setState(() {
          _countdownStep = 0; // GO!
          _phase = RacePhase.racing;
        });
        HapticFeedback.heavyImpact();
        _controller.forward(from: 0.0);
      } else {
        timer.cancel();
      }
    });
  }

  void _gameLoop() {
    if (!mounted || _phase != RacePhase.racing) return;

    setState(() {
      // RPM climbing
      if (!_hasShifted) {
        _rpm = (_rpm + 95.0).clamp(1000.0, 8000.0);
      } else {
        _rpm = (_rpm - 40.0).clamp(4000.0, 8000.0);
      }

      // Distances progress
      final playerSpeed = widget.raceResult.isWon ? 0.016 : 0.012;
      final rivalSpeed = widget.raceResult.isWon ? 0.013 : 0.017;

      _playerDistance = (_playerDistance + playerSpeed).clamp(0.0, 1.0);
      _rivalDistance = (_rivalDistance + rivalSpeed).clamp(0.0, 1.0);

      // Spawn flame / exhaust particles
      if (_random.nextDouble() < 0.6) {
        _particles.add(
          Particle(
            x: _playerDistance * 260.0,
            y: 50.0 + _random.nextDouble() * 10 - 5,
            vx: -2.0 - _random.nextDouble() * 3,
            vy: _random.nextDouble() * 2 - 1,
            color: _hasShifted ? AppColors.brutalPink : AppColors.brutalYellow,
            maxLife: 18,
          ),
        );
      }

      // Update particles
      for (final p in _particles) {
        p.update();
      }
      _particles.removeWhere((p) => p.life <= 0);

      // Finish condition
      if (_playerDistance >= 1.0 || _rivalDistance >= 1.0) {
        _phase = RacePhase.finished;
        _controller.stop();
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _onShiftPressed() {
    if (_hasShifted || _phase != RacePhase.racing) return;

    HapticFeedback.heavyImpact();
    _hasShifted = true;

    if (_rpm >= 6500 && _rpm <= 7600) {
      _shiftFeedback = 'MÜKEMMEL VİTES • NITRO AKTİF';
      _shiftFeedbackColor = AppColors.brutalGreen;
      _playerDistance += 0.12; // Boost
    } else if (_rpm < 6500) {
      _shiftFeedback = 'ERKEN VİTES • DÜŞÜK DEVİR';
      _shiftFeedbackColor = AppColors.brutalOrange;
    } else {
      _shiftFeedback = 'DEVİR KESİCİDE KALDI';
      _shiftFeedbackColor = AppColors.errorRed;
    }

    setState(() {});
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWon = widget.raceResult.isWon;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(16),
        backgroundColor: const Color(0xFF0F121C),
        borderColor: isWon ? AppColors.brutalGreen : AppColors.brutalPink,
        borderWidth: 2.8,
        borderRadius: 16,
        shadowOffset: const Offset(5, 5),
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
                    Icon(Icons.sports_score_rounded, color: AppColors.brutalPink, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'GECE MEZATI DRAG ARENASI',
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
                  text: widget.rival.badge,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Christmas Tree Countdown
            if (_phase == RacePhase.countdown) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2030),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333D56), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLightBox('3', _countdownStep <= 3 && _countdownStep > 0, const Color(0xFFEAB308)),
                    _buildLightBox('2', _countdownStep <= 2 && _countdownStep > 0, const Color(0xFFEAB308)),
                    _buildLightBox('1', _countdownStep <= 1 && _countdownStep > 0, const Color(0xFFEAB308)),
                    _buildLightBox('GO!', _countdownStep == 0, AppColors.brutalGreen),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 2D Track Canvas
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF07090E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF263047), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: _DragTrackPainter(
                    playerDistance: _playerDistance,
                    rivalDistance: _rivalDistance,
                    particles: _particles,
                    playerCarName: widget.car.modelName,
                    rivalCarName: widget.rival.carName,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Tachometer & RPM Gauge
            if (_phase == RacePhase.racing) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A28),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2B364F), width: 1.8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'DEVİR GÖSTERGESİ:',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF94A3B8)),
                        ),
                        Text(
                          '${_rpm.toInt()} RPM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _rpm >= 6500 && _rpm <= 7600
                                ? AppColors.brutalGreen
                                : (_rpm > 7600 ? AppColors.errorRed : AppColors.brutalYellow),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 12,
                        child: Stack(
                          children: [
                            Container(color: const Color(0xFF222B3F)),
                            // Ideal shift zone
                            Positioned(
                              left: (6500 / 8000) * 260,
                              right: ((8000 - 7600) / 8000) * 260,
                              top: 0,
                              bottom: 0,
                              child: Container(color: AppColors.brutalGreen.withValues(alpha: 0.5)),
                            ),
                            // Current RPM fill
                            FractionallySizedBox(
                              widthFactor: (_rpm / 8000.0).clamp(0.0, 1.0),
                              child: Container(
                                color: _rpm >= 6500 && _rpm <= 7600
                                    ? AppColors.brutalGreen
                                    : (_rpm > 7600 ? AppColors.errorRed : AppColors.brutalYellow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              if (_shiftFeedback.isNotEmpty)
                Text(
                  _shiftFeedback,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _shiftFeedbackColor,
                  ),
                ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: NeoBrutalButton(
                  label: _hasShifted ? 'VİTES ATILDI • NITRO AKTİF' : 'TAM ZAMANINDA VİTES AT',
                  icon: _hasShifted ? Icons.bolt_rounded : Icons.speed_rounded,
                  backgroundColor: _hasShifted ? const Color(0xFF475569) : AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 12,
                  onPressed: _hasShifted ? null : _onShiftPressed,
                ),
              ),
            ],

            // Finished Results
            if (_phase == RacePhase.finished) ...[
              const SizedBox(height: 8),
              SlamStampWidget(
                text: isWon ? 'ŞAMPİYON' : 'ELENDİ',
                color: isWon ? AppColors.brutalGreen : AppColors.errorRed,
                fontSize: 16,
                angle: isWon ? -0.06 : 0.06,
              ),
              const SizedBox(height: 12),
              Text(
                widget.raceResult.raceSummary,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: NeoBrutalButton(
                  label: isWon ? 'ÖDÜLÜ VE İTİBARI AL' : 'GARACA GERİ DÖN',
                  backgroundColor: isWon ? AppColors.brutalGreen : AppColors.errorRed,
                  textColor: isWon ? Colors.black : Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onFinished();
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLightBox(String label, bool isActive, Color color) {
    return Container(
      width: 44,
      height: 38,
      decoration: BoxDecoration(
        color: isActive ? color : const Color(0xFF0F131D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.white : const Color(0xFF333E59),
          width: 2.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: isActive ? Colors.black : const Color(0xFF64748B),
        ),
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  int life;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.maxLife,
  }) : life = maxLife;

  final int maxLife;

  void update() {
    x += vx;
    y += vy;
    life--;
  }
}

class _DragTrackPainter extends CustomPainter {
  final double playerDistance;
  final double rivalDistance;
  final List<Particle> particles;
  final String playerCarName;
  final String rivalCarName;

  _DragTrackPainter({
    required this.playerDistance,
    required this.rivalDistance,
    required this.particles,
    required this.playerCarName,
    required this.rivalCarName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0B0E17);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Track divider grid line
    final linePaint = Paint()
      ..color = const Color(0xFF232C40)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), linePaint);

    // Finish line (Zebra checkerboard)
    final finishX = size.width - 24;
    final checkPaint1 = Paint()..color = Colors.white;
    final checkPaint2 = Paint()..color = Colors.black;

    for (int i = 0; i < size.height ~/ 10; i++) {
      canvas.drawRect(
        Rect.fromLTWH(finishX, i * 10.0, 10, 10),
        i.isEven ? checkPaint1 : checkPaint2,
      );
      canvas.drawRect(
        Rect.fromLTWH(finishX + 10, i * 10.0, 10, 10),
        i.isOdd ? checkPaint1 : checkPaint2,
      );
    }

    // Draw Particles
    for (final p in particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final pPaint = Paint()..color = p.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(p.x, p.y), 3.0 * alpha, pPaint);
    }

    // Player Car (Lane 1 - Top)
    final playerX = 10 + playerDistance * (size.width - 70);
    const playerY = 22.0;
    _drawPixelCar(
      canvas,
      Offset(playerX, playerY),
      const Color(0xFF00E575),
      'SEN: $playerCarName',
    );

    // Rival Car (Lane 2 - Bottom)
    final rivalX = 10 + rivalDistance * (size.width - 70);
    const rivalY = 82.0;
    _drawPixelCar(
      canvas,
      Offset(rivalX, rivalY),
      const Color(0xFFFF007F),
      'RAKİP: $rivalCarName',
    );
  }

  void _drawPixelCar(Canvas canvas, Offset pos, Color color, String label) {
    final bodyPaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final windowPaint = Paint()..color = const Color(0xFF0F172A);
    final wheelPaint = Paint()..color = const Color(0xFF1E293B);

    // Wheels
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + 6, pos.dy + 22, 10, 6), const Radius.circular(2)), wheelPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + 34, pos.dy + 22, 10, 6), const Radius.circular(2)), wheelPaint);

    // Car Body Box
    final carRect = Rect.fromLTWH(pos.dx, pos.dy + 6, 50, 18);
    canvas.drawRRect(RRect.fromRectAndRadius(carRect, const Radius.circular(4)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(carRect, const Radius.circular(4)), borderPaint);

    // Cabin
    final cabinRect = Rect.fromLTWH(pos.dx + 12, pos.dy, 22, 10);
    canvas.drawRRect(RRect.fromRectAndRadius(cabinRect, const Radius.circular(3)), windowPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(cabinRect, const Radius.circular(3)), borderPaint);

    // Text Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(pos.dx, pos.dy - 11));
  }

  @override
  bool shouldRepaint(covariant _DragTrackPainter oldDelegate) => true;
}
