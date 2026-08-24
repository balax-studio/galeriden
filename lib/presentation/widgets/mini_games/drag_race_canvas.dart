import '../../../core/localization/app_localizations.dart';
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
  racing, // Multi-gear RPM climb, shift timing, nitro burst
  finished, // Victory / Defeat stamp
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

  // Multi-gear Race Engine
  int _currentGear = 1; // 1: 1st gear, 2: 2nd gear, 3: 3rd gear, 4: Nitro
  final int _maxGears = 4;
  double _rpm = 2000.0; // 1000 to 8000
  double _playerDistance = 0.0; // 0.0 to 1.0
  double _rivalDistance = 0.0;

  // Player & Rival Speech Bubbles
  String _playerSpeech = '';
  int _playerSpeechTicks = 0;
  String _rivalSpeech = '';
  int _rivalSpeechTicks = 0;

  String _shiftFeedback = '';
  Color _shiftFeedbackColor = Colors.transparent;
  int _perfectShifts = 0;
  int _earlyShifts = 0;
  int _lateShifts = 0;

  final List<Particle> _particles = [];
  final math.Random _random = math.Random();

  List<String> get _perfectQuotes => [
        'Oley be!',
        context.tr('drag_voice_1'),
        context.tr('drag_voice_2'),
        context.tr('drag_voice_3'),
        'Harika devir!',
        'Kusursuz vites!',
      ];

  List<String> get _earlyQuotes => [
        'Hadi be!',
        context.tr('drag_voice_early_1'),
        context.tr('drag_voice_early_2'),
        'Acele ettik!',
      ];

  final List<String> _lateQuotes = [
    'Hadi be kesiciye girdi!',
    'Vitesi kaçırdık!',
    'Devir kesicide kaldı!',
    'Motor bağırdı!',
  ];

  final List<String> _nitroQuotes = [
    'Nitro devrede!',
    'Tutamazsınız beni!',
    'Uçuşa geçtik!',
    'Bas gaza bas!',
  ];

  final List<String> _rivalAheadQuotes = [
    'Tozumu yut!',
    'Bu kadar mıydın?',
    'Yetişemezsin!',
  ];

  final List<String> _rivalBehindQuotes = [
    'Olamaz!',
    'Nasıl geçti be!',
    'Bas usta bas!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(_gameLoop);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownStep = 3;
    _countdownTimer =
        Timer.periodic(const Duration(milliseconds: 700), (timer) {
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
          _playerSpeech = 'Hadi bakalım!';
          _playerSpeechTicks = 60;
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
      // RPM progression based on current gear
      if (_currentGear < _maxGears) {
        final rpmRate = 42.0 + (_currentGear * 6.0);
        _rpm = (_rpm + rpmRate).clamp(1000.0, 8000.0);
      } else {
        // Nitro stage - high sustained RPM
        _rpm = 7400.0 + _random.nextDouble() * 300.0;
      }

      // Base speeds calculated for realistic 5-7 second race
      double playerSpeed = 0.0028 + (_currentGear * 0.0007);
      double rivalSpeed = 0.0029 + (_currentGear * 0.00065);

      // Apply outcome bias based on precalculated raceResult
      if (widget.raceResult.isWon) {
        playerSpeed *= 1.08;
        rivalSpeed *= 0.96;
      } else {
        playerSpeed *= 0.94;
        rivalSpeed *= 1.06;
      }

      // Dynamic Rubber-banding: Player mistakes let rival surge forward
      if (_earlyShifts > 0 || _lateShifts > 0) {
        rivalSpeed *= (1.0 + (_earlyShifts + _lateShifts) * 0.12);
      }

      // Speed modifier from player shift performance
      if (_perfectShifts > 0) {
        playerSpeed += _perfectShifts * 0.00045;
      }
      if (_earlyShifts > 0) {
        playerSpeed -= _earlyShifts * 0.0003;
      }
      if (_lateShifts > 0) {
        playerSpeed -= _lateShifts * 0.0004; // Heavy rev-limit penalty
      }

      _playerDistance = (_playerDistance + playerSpeed).clamp(0.0, 1.0);
      _rivalDistance = (_rivalDistance + rivalSpeed).clamp(0.0, 1.0);

      // Speech bubble timers
      if (_playerSpeechTicks > 0) {
        _playerSpeechTicks--;
        if (_playerSpeechTicks == 0) {
          _playerSpeech = '';
        }
      }
      if (_rivalSpeechTicks > 0) {
        _rivalSpeechTicks--;
        if (_rivalSpeechTicks == 0) {
          _rivalSpeech = '';
        }
      }

      // Rival contextual chatter
      if (_rivalSpeechTicks == 0 && _random.nextDouble() < 0.015) {
        if (_rivalDistance > _playerDistance + 0.06) {
          _rivalSpeech =
              _rivalAheadQuotes[_random.nextInt(_rivalAheadQuotes.length)];
          _rivalSpeechTicks = 50;
        } else if (_playerDistance > _rivalDistance + 0.06) {
          _rivalSpeech =
              _rivalBehindQuotes[_random.nextInt(_rivalBehindQuotes.length)];
          _rivalSpeechTicks = 50;
        }
      }

      // Spawn flame / exhaust particles
      if (_random.nextDouble() < 0.7) {
        final isNitro = _currentGear == _maxGears;
        _particles.add(
          Particle(
            x: _playerDistance * 260.0,
            y: 46.0 + _random.nextDouble() * 8 - 4,
            vx: -2.5 - _random.nextDouble() * 4,
            vy: _random.nextDouble() * 2 - 1,
            color: isNitro
                ? AppColors.brutalPink
                : (_rpm > 6500
                    ? AppColors.brutalGreen
                    : AppColors.brutalYellow),
            maxLife: isNitro ? 24 : 16,
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

        if (widget.raceResult.isWon) {
          _playerSpeech = 'Oley be şampiyonuz!';
        } else {
          _playerSpeech = 'Hadi be rövanşta görüşeceğiz!';
        }
        _playerSpeechTicks = 120;
      }
    });
  }

  void _onShiftPressed() {
    if (_phase != RacePhase.racing || _currentGear >= _maxGears) return;

    HapticFeedback.heavyImpact();

    if (_currentGear < _maxGears - 1) {
      // Shifting gears 1 -> 2, 2 -> 3
      if (_rpm >= 6200 && _rpm <= 7500) {
        _perfectShifts++;
        _shiftFeedback = 'KUSURSUZ VİTES • HARİKA ZAMANLAMA';
        _shiftFeedbackColor = AppColors.brutalGreen;
        _playerDistance += 0.035; // Boost
        _playerSpeech = _perfectQuotes[_random.nextInt(_perfectQuotes.length)];
      } else if (_rpm < 6200) {
        _earlyShifts++;
        _shiftFeedback = 'ERKEN VİTES • DÜŞÜK DEVİR';
        _shiftFeedbackColor = AppColors.brutalOrange;
        _playerSpeech = _earlyQuotes[_random.nextInt(_earlyQuotes.length)];
      } else {
        _lateShifts++;
        _shiftFeedback = 'DEVİR KESİCİDE KALDI • GÜÇ KAYBI';
        _shiftFeedbackColor = AppColors.errorRed;
        _playerSpeech = _lateQuotes[_random.nextInt(_lateQuotes.length)];
      }

      _currentGear++;
      _rpm = 3200.0; // Reset RPM for next gear climb
      _playerSpeechTicks = 55;
    } else {
      // Activating Nitro (Gear 4)
      _currentGear = _maxGears;
      _shiftFeedback = 'NITRO ATEŞLENDİ • MAKSİMUM GÜÇ';
      _shiftFeedbackColor = AppColors.brutalPink;
      _playerDistance += 0.06;
      _playerSpeech = _nitroQuotes[_random.nextInt(_nitroQuotes.length)];
      _playerSpeechTicks = 70;
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
                    Icon(Icons.sports_score_rounded,
                        color: AppColors.brutalPink, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'GECE SANAYİSİ DRAG ARENASI',
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
            const SizedBox(height: 12),

            // Christmas Tree Countdown
            if (_phase == RacePhase.countdown) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2030),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF333D56), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildLightBox(
                        '3',
                        _countdownStep <= 3 && _countdownStep > 0,
                        const Color(0xFFEAB308)),
                    _buildLightBox(
                        '2',
                        _countdownStep <= 2 && _countdownStep > 0,
                        const Color(0xFFEAB308)),
                    _buildLightBox(
                        '1',
                        _countdownStep <= 1 && _countdownStep > 0,
                        const Color(0xFFEAB308)),
                    _buildLightBox(
                        'GO!', _countdownStep == 0, AppColors.brutalGreen),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // 2D Track Canvas with Driver Speech Bubbles
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF07090E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF263047), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _DragTrackPainter(
                      playerDistance: _playerDistance,
                      rivalDistance: _rivalDistance,
                      particles: _particles,
                      playerCarName: context
                          .tr('drag_race_you', {'name': widget.car.modelName}),
                      rivalCarName: context.tr(
                          'drag_race_rival', {'name': widget.rival.carName}),
                      playerSpeech: _playerSpeech,
                      rivalSpeech: _rivalSpeech,
                      currentGear: _currentGear,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tachometer & RPM Gauge & Multi-gear shifting
            if (_phase == RacePhase.racing) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A28),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF2B364F), width: 1.8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              _currentGear == _maxGears
                                  ? context.tr('drag_race_modal_nitro_mode')
                                  : context.tr('drag_race_modal_gear',
                                      {'gear': '$_currentGear'}),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${_rpm.toInt()} RPM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _rpm >= 6200 && _rpm <= 7500
                                ? AppColors.brutalGreen
                                : (_rpm > 7500
                                    ? AppColors.errorRed
                                    : AppColors.brutalYellow),
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
                            // Ideal shift zone (6200 - 7500 RPM)
                            Positioned(
                              left: (6200 / 8000) * 260,
                              right: ((8000 - 7500) / 8000) * 260,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                  color: AppColors.brutalGreen
                                      .withValues(alpha: 0.5)),
                            ),
                            // Current RPM fill
                            FractionallySizedBox(
                              widthFactor: (_rpm / 8000.0).clamp(0.0, 1.0),
                              child: Container(
                                color: _rpm >= 6200 && _rpm <= 7500
                                    ? AppColors.brutalGreen
                                    : (_rpm > 7500
                                        ? AppColors.errorRed
                                        : AppColors.brutalYellow),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_shiftFeedback.isNotEmpty)
                Text(
                  _shiftFeedback,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _shiftFeedbackColor,
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: NeoBrutalButton(
                  label: _getShiftButtonLabel(),
                  icon: _currentGear == _maxGears
                      ? Icons.local_fire_department_rounded
                      : (_currentGear == 3
                          ? Icons.bolt_rounded
                          : Icons.speed_rounded),
                  backgroundColor: _currentGear == _maxGears
                      ? const Color(0xFF475569)
                      : (_currentGear == 3
                          ? AppColors.brutalPink
                          : AppColors.brutalYellow),
                  textColor: _currentGear == 3 ? Colors.white : Colors.black,
                  fontSize: 12,
                  onPressed: _currentGear >= _maxGears ? null : _onShiftPressed,
                ),
              ),
            ],

            // Finished Results
            if (_phase == RacePhase.finished) ...[
              const SizedBox(height: 8),
              SlamStampWidget(
                text: isWon
                    ? context.tr('drag_race_stamp_win')
                    : context.tr('drag_race_stamp_lose'),
                color: isWon ? AppColors.brutalGreen : AppColors.errorRed,
                fontSize: 16,
                angle: isWon ? -0.06 : 0.06,
              ),
              const SizedBox(height: 10),
              if (!isWon) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F121C),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.errorRed, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.campaign_rounded,
                          color: AppColors.brutalPink, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${widget.rival.name}: "${NightMarketEngine.getRandomDefeatTaunt(widget.rival)}"',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFDA4AF),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                widget.raceResult.raceSummary,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFCBD5E1),
                    fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              if (!isWon) ...[
                SizedBox(
                  width: double.infinity,
                  child: NeoBrutalButton(
                    label: context.tr('drag_race_btn_revenge'),
                    icon: Icons.replay_rounded,
                    backgroundColor: AppColors.brutalOrange,
                    textColor: Colors.black,
                    onPressed: () {
                      setState(() {
                        _phase = RacePhase.countdown;
                        _playerDistance = 0.0;
                        _rivalDistance = 0.0;
                        _currentGear = 1;
                        _rpm = 2000.0;
                        _perfectShifts = 0;
                        _earlyShifts = 0;
                        _lateShifts = 0;
                        _shiftFeedback = '';
                        _particles.clear();
                      });
                      _startCountdown();
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: NeoBrutalButton(
                  label: isWon
                      ? context.tr('drag_race_btn_claim')
                      : context.tr('drag_race_btn_garage'),
                  backgroundColor:
                      isWon ? AppColors.brutalGreen : const Color(0xFF334155),
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

  String _getShiftButtonLabel() {
    if (_currentGear == 1) {
      return context.tr('drag_race_shift_btn_gear2');
    } else if (_currentGear == 2) {
      return context.tr('drag_race_shift_btn_gear3');
    } else if (_currentGear == 3) {
      return context.tr('drag_race_shift_btn_nitro');
    } else {
      return context.tr('drag_race_shift_btn_nitro_active');
    }
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
  final String playerSpeech;
  final String rivalSpeech;
  final int currentGear;

  _DragTrackPainter({
    required this.playerDistance,
    required this.rivalDistance,
    required this.particles,
    required this.playerCarName,
    required this.rivalCarName,
    required this.playerSpeech,
    required this.rivalSpeech,
    required this.currentGear,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0B0E17);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Track divider grid line
    final linePaint = Paint()
      ..color = const Color(0xFF232C40)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), linePaint);

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
      canvas.drawCircle(Offset(p.x, p.y), 3.2 * alpha, pPaint);
    }

    // Player Car (Lane 1 - Top)
    final playerX = 10 + playerDistance * (size.width - 70);
    const playerY = 32.0;
    _drawPixelCar(
      canvas,
      Offset(playerX, playerY),
      const Color(0xFF00E575),
      playerCarName,
      playerSpeech,
      true,
    );

    // Rival Car (Lane 2 - Bottom)
    final rivalX = 10 + rivalDistance * (size.width - 70);
    const rivalY = 102.0;
    _drawPixelCar(
      canvas,
      Offset(rivalX, rivalY),
      const Color(0xFFFF007F),
      rivalCarName,
      rivalSpeech,
      false,
    );
  }

  void _drawPixelCar(
    Canvas canvas,
    Offset pos,
    Color color,
    String label,
    String speechText,
    bool isPlayer,
  ) {
    final bodyPaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final windowPaint = Paint()..color = const Color(0xFF0F172A);
    final wheelPaint = Paint()..color = const Color(0xFF1E293B);

    // Wheels
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + 6, pos.dy + 22, 10, 6),
            const Radius.circular(2)),
        wheelPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(pos.dx + 34, pos.dy + 22, 10, 6),
            const Radius.circular(2)),
        wheelPaint);

    // Car Body Box
    final carRect = Rect.fromLTWH(pos.dx, pos.dy + 6, 50, 18);
    canvas.drawRRect(
        RRect.fromRectAndRadius(carRect, const Radius.circular(4)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(carRect, const Radius.circular(4)),
        borderPaint);

    // Cabin
    final cabinRect = Rect.fromLTWH(pos.dx + 12, pos.dy, 22, 10);
    canvas.drawRRect(
        RRect.fromRectAndRadius(cabinRect, const Radius.circular(3)),
        windowPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(cabinRect, const Radius.circular(3)),
        borderPaint);

    // Text Label above car
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.white),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(pos.dx, pos.dy - 10));

    // Dynamic Comic Speech Bubble if speaking
    if (speechText.isNotEmpty) {
      _drawSpeechBubble(
          canvas, Offset(pos.dx + 18, pos.dy - 13), speechText, isPlayer);
    }
  }

  void _drawSpeechBubble(
      Canvas canvas, Offset anchor, String text, bool isPlayer) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 9.0,
          fontWeight: FontWeight.w900,
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bubbleWidth = textPainter.width + 12.0;
    final bubbleHeight = textPainter.height + 6.0;
    final bubbleX = (anchor.dx - (bubbleWidth / 2)).clamp(6.0, 280.0);
    final bubbleY = anchor.dy - bubbleHeight - 4.0;

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bubbleX, bubbleY, bubbleWidth, bubbleHeight),
      const Radius.circular(6),
    );

    final bgPaint = Paint()
      ..color = isPlayer ? const Color(0xFFFEF08A) : Colors.white;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // Bubble body
    canvas.drawRRect(bubbleRect, bgPaint);
    canvas.drawRRect(bubbleRect, borderPaint);

    // Pointer tail
    final path = Path()
      ..moveTo(anchor.dx - 3, bubbleY + bubbleHeight)
      ..lineTo(anchor.dx, anchor.dy)
      ..lineTo(anchor.dx + 3, bubbleY + bubbleHeight)
      ..close();

    canvas.drawPath(path, bgPaint);
    canvas.drawPath(path, borderPaint);

    // Bubble text
    textPainter.paint(canvas, Offset(bubbleX + 6.0, bubbleY + 3.0));
  }

  @override
  bool shouldRepaint(covariant _DragTrackPainter oldDelegate) => true;
}
