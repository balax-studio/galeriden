import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../domain/usecases/night_market_engine.dart';
import '../confetti_celebration_overlay.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../slam_stamp_widget.dart';

enum RacePhase {
  countdown, // 3, 2, 1, GO
  racing, // Multi-gear RPM climb, shift timing, nitro burst
  finished, // Victory / Defeat stamp
}

enum ParticleType {
  triangleFlame,
  smokePuff,
  sparkShard,
  nitroShockwave,
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double rotation;
  double rotationSpeed;
  final ParticleType type;
  int life;
  final int maxLife;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    this.rotation = 0.0,
    this.rotationSpeed = 0.0,
    required this.type,
    required this.maxLife,
  }) : life = maxLife;

  void update() {
    x += vx;
    y += vy;
    rotation += rotationSpeed;
    life--;
    if (type == ParticleType.smokePuff) {
      size += 0.35;
      vx *= 0.92;
    } else if (type == ParticleType.nitroShockwave) {
      size += 1.2;
    }
  }
}

class ComicActionPopup {
  double x;
  double y;
  final String text;
  final Color bgColor;
  final Color textColor;
  final double angle;
  int life;
  final int maxLife;

  ComicActionPopup({
    required this.x,
    required this.y,
    required this.text,
    required this.bgColor,
    required this.textColor,
    required this.angle,
    this.life = 35,
    this.maxLife = 35,
  });

  void update() {
    y -= 0.8;
    life--;
  }
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
  int _currentGear = 1; // 1: 1st, 2: 2nd, 3: 3rd, 4: Nitro
  final int _maxGears = 4;
  double _rpm = 2000.0; // 1000 to 8000
  double _playerDistance = 0.0; // 0.0 to 1.0
  double _rivalDistance = 0.0;
  double _trackScrollOffset = 0.0;

  // Camera Shake & Hit-stop
  double _cameraShakeX = 0.0;
  double _cameraShakeY = 0.0;
  int _hitStopFrames = 0;
  bool _shiftFlash = false;

  // Driver Speech Bubbles
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
  final List<ComicActionPopup> _popups = [];
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
          // Revving engine during countdown
          _rpm = 3000.0 + _random.nextDouble() * 2500.0;
          _cameraShakeX = (_random.nextDouble() - 0.5) * 2.0;
          _cameraShakeY = (_random.nextDouble() - 0.5) * 2.0;
          _spawnLaunchPuff(isPlayer: true);
        });
      } else if (_countdownStep == 1) {
        setState(() {
          _countdownStep = 0; // GO!
          _phase = RacePhase.racing;
          _playerSpeech = 'Hadi bakalım!';
          _playerSpeechTicks = 60;
          _rpm = 4500.0;
        });
        HapticFeedback.heavyImpact();
        _addComicPopup(
          text: 'GAAAZ!',
          color: AppColors.brutalGreen,
          textColor: Colors.black,
          x: 120,
          y: 40,
        );
        _controller.forward(from: 0.0);
      } else {
        timer.cancel();
      }
    });
  }

  void _spawnLaunchPuff({required bool isPlayer}) {
    final startY = isPlayer ? 48.0 : 118.0;
    for (int i = 0; i < 4; i++) {
      _particles.add(
        Particle(
          x: 24.0 + _random.nextDouble() * 12,
          y: startY + _random.nextDouble() * 8 - 4,
          vx: -2.0 - _random.nextDouble() * 3,
          vy: (_random.nextDouble() - 0.5) * 1.5,
          color: const Color(0xFF64748B),
          size: 6.0 + _random.nextDouble() * 4,
          type: ParticleType.smokePuff,
          maxLife: 20,
        ),
      );
    }
  }

  void _addComicPopup({
    required String text,
    required Color color,
    required Color textColor,
    required double x,
    required double y,
  }) {
    _popups.add(
      ComicActionPopup(
        x: x,
        y: y,
        text: text,
        bgColor: color,
        textColor: textColor,
        angle: (_random.nextDouble() - 0.5) * 0.25,
      ),
    );
  }

  void _gameLoop() {
    if (!mounted || _phase != RacePhase.racing) return;

    // Hit-stop effect (micro-pause for impactful gear shifts)
    if (_hitStopFrames > 0) {
      _hitStopFrames--;
      return;
    }
    if (_shiftFlash) {
      _shiftFlash = false;
    }

    setState(() {
      // RPM progression based on current gear
      if (_currentGear < _maxGears) {
        final rpmRate = 46.0 + (_currentGear * 7.5);
        _rpm = (_rpm + rpmRate).clamp(1000.0, 8000.0);
      } else {
        // Nitro stage - high sustained RPM
        _rpm = 7400.0 + _random.nextDouble() * 400.0;
      }

      // Base speeds calculated for dynamic 5-7 second race
      double playerSpeed = 0.0030 + (_currentGear * 0.00075);
      double rivalSpeed = 0.0031 + (_currentGear * 0.00070);

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
        playerSpeed += _perfectShifts * 0.00055;
      }
      if (_earlyShifts > 0) {
        playerSpeed -= _earlyShifts * 0.00035;
      }
      if (_lateShifts > 0) {
        playerSpeed -= _lateShifts * 0.00045; // Heavy rev-limit penalty
      }

      _playerDistance = (_playerDistance + playerSpeed).clamp(0.0, 1.0);
      _rivalDistance = (_rivalDistance + rivalSpeed).clamp(0.0, 1.0);

      // Track parallax scroll speed
      final currentAvgSpeed = (playerSpeed + rivalSpeed) * 0.5;
      _trackScrollOffset = (_trackScrollOffset + (currentAvgSpeed * 1200)) % 40.0;

      // Dynamic Camera Shake based on RPM & Nitro
      if (_currentGear == _maxGears) {
        _cameraShakeX = (_random.nextDouble() - 0.5) * 3.5;
        _cameraShakeY = (_random.nextDouble() - 0.5) * 3.5;
      } else if (_rpm > 6800) {
        _cameraShakeX = (_random.nextDouble() - 0.5) * 2.2;
        _cameraShakeY = (_random.nextDouble() - 0.5) * 2.2;
      } else {
        _cameraShakeX = (_random.nextDouble() - 0.5) * 0.8;
        _cameraShakeY = (_random.nextDouble() - 0.5) * 0.8;
      }

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
      if (_rivalSpeechTicks == 0 && _random.nextDouble() < 0.018) {
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

      // Spawn Neo-Brutalist Geometric Particles (Triangular Flames, Shards, Sparks)
      final isNitro = _currentGear == _maxGears;
      final playerPixelX = 14 + _playerDistance * 240.0;

      if (_random.nextDouble() < (isNitro ? 0.95 : 0.7)) {
        _particles.add(
          Particle(
            x: playerPixelX + 4,
            y: 44.0 + _random.nextDouble() * 8 - 4,
            vx: -3.5 - _random.nextDouble() * 4.5,
            vy: (_random.nextDouble() - 0.5) * 2.5,
            color: isNitro
                ? AppColors.brutalPink
                : (_rpm > 6500
                    ? AppColors.brutalGreen
                    : AppColors.brutalYellow),
            size: isNitro ? 5.5 : 4.0,
            rotation: _random.nextDouble() * math.pi * 2,
            rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
            type: ParticleType.triangleFlame,
            maxLife: isNitro ? 24 : 16,
          ),
        );
      }

      // Spawn tire sparks
      if (_random.nextDouble() < 0.4) {
        _particles.add(
          Particle(
            x: playerPixelX + 12,
            y: 50.0 + _random.nextDouble() * 3,
            vx: -2.0 - _random.nextDouble() * 3,
            vy: -_random.nextDouble() * 2,
            color: AppColors.brutalYellow,
            size: 2.5,
            type: ParticleType.sparkShard,
            maxLife: 12,
          ),
        );
      }

      // Update particles & popups
      for (final p in _particles) {
        p.update();
      }
      _particles.removeWhere((p) => p.life <= 0);

      for (final pop in _popups) {
        pop.update();
      }
      _popups.removeWhere((pop) => pop.life <= 0);

      // Finish condition
      if (_playerDistance >= 1.0 || _rivalDistance >= 1.0) {
        _phase = RacePhase.finished;
        _controller.stop();
        HapticFeedback.heavyImpact();

        if (widget.raceResult.isWon) {
          _playerSpeech = 'Oley be şampiyonuz!';
          _addComicPopup(
            text: 'FİNİŞ! KAZANDIN!',
            color: AppColors.brutalGreen,
            textColor: Colors.black,
            x: 140,
            y: 35,
          );
        } else {
          _playerSpeech = 'Hadi be rövanşta görüşeceğiz!';
          _addComicPopup(
            text: 'ELENDİ!',
            color: AppColors.errorRed,
            textColor: Colors.white,
            x: 140,
            y: 35,
          );
        }
        _playerSpeechTicks = 120;
      }
    });
  }

  void _onShiftPressed() {
    if (_phase != RacePhase.racing || _currentGear >= _maxGears) return;

    HapticFeedback.heavyImpact();
    final playerPixelX = 14 + _playerDistance * 240.0;

    if (_currentGear < _maxGears - 1) {
      // Shifting gears 1 -> 2, 2 -> 3
      if (_rpm >= 6200 && _rpm <= 7500) {
        _perfectShifts++;
        _shiftFeedback = 'KUSURSUZ VİTES • HARİKA ZAMANLAMA';
        _shiftFeedbackColor = AppColors.brutalGreen;
        _playerDistance += 0.040; // High speed boost
        _playerSpeech = _perfectQuotes[_random.nextInt(_perfectQuotes.length)];

        // Hit-stop tactile punch
        _hitStopFrames = 2;
        _shiftFlash = true;

        // Comic Onomatopoeia Stamp
        _addComicPopup(
          text: 'KUSURSUZ! ÇAAAT!',
          color: AppColors.brutalGreen,
          textColor: Colors.black,
          x: playerPixelX + 10,
          y: 25,
        );

        // Explosive Flame & Shockwave
        _particles.add(
          Particle(
            x: playerPixelX,
            y: 44,
            vx: -1,
            vy: 0,
            color: AppColors.brutalGreen,
            size: 10,
            type: ParticleType.nitroShockwave,
            maxLife: 15,
          ),
        );
      } else if (_rpm < 6200) {
        _earlyShifts++;
        _shiftFeedback = 'ERKEN VİTES • DÜŞÜK DEVİR';
        _shiftFeedbackColor = AppColors.brutalOrange;
        _playerSpeech = _earlyQuotes[_random.nextInt(_earlyQuotes.length)];
        _addComicPopup(
          text: 'ERKEN! TIK!',
          color: AppColors.brutalOrange,
          textColor: Colors.black,
          x: playerPixelX + 10,
          y: 25,
        );
      } else {
        _lateShifts++;
        _shiftFeedback = 'DEVİR KESİCİDE KALDI • GÜÇ KAYBI';
        _shiftFeedbackColor = AppColors.errorRed;
        _playerSpeech = _lateQuotes[_random.nextInt(_lateQuotes.length)];
        _addComicPopup(
          text: 'KESİCİ! VUTUTU!',
          color: AppColors.errorRed,
          textColor: Colors.white,
          x: playerPixelX + 10,
          y: 25,
        );
      }

      _currentGear++;
      _rpm = 3200.0; // Reset RPM for next gear climb
      _playerSpeechTicks = 55;
    } else {
      // Activating Nitro (Gear 4)
      _currentGear = _maxGears;
      _shiftFeedback = 'NITRO ATEŞLENDİ • MAKSİMUM GÜÇ';
      _shiftFeedbackColor = AppColors.brutalPink;
      _playerDistance += 0.070;
      _playerSpeech = _nitroQuotes[_random.nextInt(_nitroQuotes.length)];
      _playerSpeechTicks = 70;

      _hitStopFrames = 3;
      _shiftFlash = true;

      _addComicPopup(
        text: 'NITRO BOOOST!',
        color: AppColors.brutalPink,
        textColor: Colors.white,
        x: playerPixelX + 10,
        y: 20,
      );

      for (int i = 0; i < 3; i++) {
        _particles.add(
          Particle(
            x: playerPixelX - (i * 6),
            y: 44,
            vx: -2,
            vy: 0,
            color: AppColors.brutalPink,
            size: 12 + (i * 4),
            type: ParticleType.nitroShockwave,
            maxLife: 20,
          ),
        );
      }
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
    final isIdealShift = _rpm >= 6200 && _rpm <= 7500;
    final isOverRev = _rpm > 7500;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: _shiftFlash
                ? const Color(0xFF1E293B)
                : const Color(0xFF0D1017),
            borderColor: isWon && _phase == RacePhase.finished
                ? AppColors.brutalGreen
                : AppColors.brutalPink,
            borderWidth: 2.8,
            borderRadius: 16,
            shadowOffset: const Offset(6, 6),
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
                            fontSize: 12.5,
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
                const SizedBox(height: 10),

                // Christmas Tree Countdown
                if (_phase == RacePhase.countdown) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B28),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFF333D56), width: 2),
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
                  const SizedBox(height: 10),
                ],

                // 2D High-Octane Parallax Track Canvas with Camera Shake
                Container(
                  height: 165,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF080B12),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFF263047), width: 2.2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Transform.translate(
                      offset: Offset(_cameraShakeX, _cameraShakeY),
                      child: RepaintBoundary(
                        child: CustomPaint(
                          painter: _DragTrackPainter(
                            playerDistance: _playerDistance,
                            rivalDistance: _rivalDistance,
                            particles: _particles,
                            popups: _popups,
                            playerCarName: context.tr('drag_race_you',
                                {'name': widget.car.modelName}),
                            rivalCarName: context.tr('drag_race_rival',
                                {'name': widget.rival.carName}),
                            playerSpeech: _playerSpeech,
                            rivalSpeech: _rivalSpeech,
                            currentGear: _currentGear,
                            maxGears: _maxGears,
                            trackScrollOffset: _trackScrollOffset,
                            isRacing: _phase == RacePhase.racing,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Maximalist Cockpit HUD: Segmented LED Rev Bar & Strobe Shift Light
                if (_phase == RacePhase.racing) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF121724),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isIdealShift
                            ? AppColors.brutalGreen
                            : (isOverRev
                                ? AppColors.errorRed
                                : const Color(0xFF2B364F)),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _currentGear == _maxGears
                                        ? AppColors.brutalPink
                                        : AppColors.brutalYellow,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    _currentGear == _maxGears
                                        ? context
                                            .tr('drag_race_modal_nitro_mode')
                                        : context.tr('drag_race_modal_gear',
                                            {'gear': '$_currentGear'}),
                                    style: const TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${(_playerDistance * 260 + _currentGear * 35).toInt()} KM/H',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ],
                            ),
                            // Real-time Gap Indicator
                            _buildGapBadge(),
                            // Strobe Shift Light
                            Row(
                              children: [
                                if (isIdealShift)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.brutalGreen,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(Icons.flash_on_rounded,
                                            size: 12, color: Colors.black),
                                        SizedBox(width: 2),
                                        Text(
                                          'VİTES AT!',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(width: 6),
                                Text(
                                  '${_rpm.toInt()} RPM',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isIdealShift
                                        ? AppColors.brutalGreen
                                        : (isOverRev
                                            ? AppColors.errorRed
                                            : AppColors.brutalYellow),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 18-Segment Neo-Brutalist LED Tachometer Bar
                        _buildSegmentedLedBar(_rpm),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (_shiftFeedback.isNotEmpty)
                    Text(
                      _shiftFeedback,
                      style: TextStyle(
                        fontSize: 10.5,
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
                              : (isIdealShift
                                  ? AppColors.brutalGreen
                                  : AppColors.brutalYellow)),
                      textColor: (_currentGear == 3 || isIdealShift)
                          ? (isIdealShift ? Colors.black : Colors.white)
                          : Colors.black,
                      fontSize: 12,
                      onPressed:
                          _currentGear >= _maxGears ? null : _onShiftPressed,
                    ),
                  ),
                ],

                // Finished Results Climax
                if (_phase == RacePhase.finished) ...[
                  const SizedBox(height: 8),
                  SlamStampWidget(
                    text: isWon
                        ? context.tr('drag_race_stamp_win')
                        : context.tr('drag_race_stamp_lose'),
                    color: isWon ? AppColors.brutalGreen : AppColors.errorRed,
                    fontSize: 17,
                    angle: isWon ? -0.06 : 0.06,
                  ),
                  const SizedBox(height: 8),
                  if (isWon) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.brutalGreen.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.brutalGreen, width: 1.5),
                      ),
                      child: Text(
                        context.tr('drag_race_prize_won', {
                          'amount': CurrencyFormatter.format(
                              widget.raceResult.prizeMoney)
                        }),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F121C),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: AppColors.errorRed, width: 1.5),
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
                                fontSize: 10.5,
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
                      fontSize: 11,
                      color: Color(0xFFCBD5E1),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                            _popups.clear();
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
                      backgroundColor: isWon
                          ? AppColors.brutalGreen
                          : const Color(0xFF334155),
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
          // Geometric Confetti Overlay on Victory
          if (_phase == RacePhase.finished && isWon)
            const Positioned.fill(
              child: IgnorePointer(
                child: ConfettiCelebrationOverlay(
                  particleCount: 60,
                  duration: Duration(milliseconds: 2600),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGapBadge() {
    final diff = _playerDistance - _rivalDistance;
    final isAhead = diff >= 0;
    final timeDiff = (diff.abs() * 0.85).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isAhead
            ? AppColors.brutalGreen.withValues(alpha: 0.2)
            : AppColors.errorRed.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isAhead ? AppColors.brutalGreen : AppColors.errorRed,
          width: 1.0,
        ),
      ),
      child: Text(
        isAhead
            ? context.tr('drag_race_gap_ahead', {'sec': timeDiff})
            : context.tr('drag_race_gap_behind', {'sec': timeDiff}),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isAhead ? AppColors.brutalGreen : AppColors.errorRed,
        ),
      ),
    );
  }

  Widget _buildSegmentedLedBar(double rpm) {
    const totalSegments = 18;
    final activeSegments = ((rpm / 8000.0) * totalSegments).clamp(0, totalSegments).round();

    return Row(
      children: List.generate(totalSegments, (index) {
        final isActive = index < activeSegments;
        Color segColor;
        if (index < 10) {
          segColor = const Color(0xFF38BDF8); // Cyan
        } else if (index < 15) {
          segColor = AppColors.brutalGreen; // Green (Sweet spot)
        } else {
          segColor = AppColors.errorRed; // Red (Rev-limiter)
        }

        return Expanded(
          child: Container(
            height: 10,
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            decoration: BoxDecoration(
              color: isActive ? segColor : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: isActive ? Colors.white : Colors.black,
                width: 0.8,
              ),
            ),
          ),
        );
      }),
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

class _DragTrackPainter extends CustomPainter {
  final double playerDistance;
  final double rivalDistance;
  final List<Particle> particles;
  final List<ComicActionPopup> popups;
  final String playerCarName;
  final String rivalCarName;
  final String playerSpeech;
  final String rivalSpeech;
  final int currentGear;
  final int maxGears;
  final double trackScrollOffset;
  final bool isRacing;

  _DragTrackPainter({
    required this.playerDistance,
    required this.rivalDistance,
    required this.particles,
    required this.popups,
    required this.playerCarName,
    required this.rivalCarName,
    required this.playerSpeech,
    required this.rivalSpeech,
    required this.currentGear,
    required this.maxGears,
    required this.trackScrollOffset,
    required this.isRacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Cyber Asphalt Background
    final bgPaint = Paint()..color = const Color(0xFF090C14);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Parallax Cyber Grid & Road Lines
    _drawCyberGridAndKerbs(canvas, size);

    // 3. Anime / Manga Speed Action Lines during Gear 3 & Nitro
    if (isRacing && currentGear >= 3) {
      _drawSpeedStreaks(canvas, size);
    }

    // 4. Track Distance Markers
    _drawDistanceMarkers(canvas, size);

    // 5. Finish Line
    _drawFinishLine(canvas, size);

    // 6. Geometric Particles (Flames, Sparks, Smoke)
    _drawParticles(canvas);

    // 7. Vehicles
    final playerX = 12 + playerDistance * (size.width - 72);
    const playerY = 32.0;
    _drawStylizedCar(
      canvas,
      Offset(playerX, playerY),
      const Color(0xFF00E575),
      playerCarName,
      playerSpeech,
      true,
    );

    final rivalX = 12 + rivalDistance * (size.width - 72);
    const rivalY = 100.0;
    _drawStylizedCar(
      canvas,
      Offset(rivalX, rivalY),
      const Color(0xFFFF007F),
      rivalCarName,
      rivalSpeech,
      false,
    );

    // 8. Comic Action Popups (Onomatopoeia Stamps)
    _drawComicPopups(canvas);
  }

  void _drawCyberGridAndKerbs(Canvas canvas, Size size) {
    // Top & Bottom Hazard Stripe Kerbs
    _drawHazardKerb(canvas, 0, size.width, 8);
    _drawHazardKerb(canvas, size.height - 8, size.width, 8);

    // Dashed Center Divider Line with scrolling offset
    final linePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 2.5;

    const dashWidth = 14.0;
    const dashSpace = 10.0;
    final totalDash = dashWidth + dashSpace;
    final startX = -trackScrollOffset;

    for (double x = startX; x < size.width; x += totalDash) {
      if (x + dashWidth > 0 && x < size.width) {
        final drawX = x.clamp(0.0, size.width);
        final drawW = (x + dashWidth).clamp(0.0, size.width) - drawX;
        canvas.drawRect(
          Rect.fromLTWH(drawX, size.height / 2 - 1.2, drawW, 2.4),
          linePaint,
        );
      }
    }
  }

  void _drawHazardKerb(Canvas canvas, double y, double width, double height) {
    final kerbPaint1 = Paint()..color = const Color(0xFFEAB308); // Yellow
    final kerbPaint2 = Paint()..color = Colors.black; // Black
    const stripeWidth = 12.0;
    final startX = -trackScrollOffset;

    for (double x = startX; x < width; x += stripeWidth) {
      final index = (x / stripeWidth).floor();
      final paint = index.isEven ? kerbPaint1 : kerbPaint2;
      canvas.drawRect(
        Rect.fromLTWH(x.clamp(0.0, width), y, stripeWidth, height),
        paint,
      );
    }
  }

  void _drawDistanceMarkers(Canvas canvas, Size size) {
    final markerPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..strokeWidth = 1.2;

    const markerInterval = 100.0;
    for (double x = 40.0; x < size.width - 40; x += markerInterval) {
      canvas.drawLine(
        Offset(x, 10),
        Offset(x, size.height - 10),
        markerPaint,
      );
    }
  }

  void _drawFinishLine(Canvas canvas, Size size) {
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

    // Finish Post Warning
    final postPaint = Paint()
      ..color = AppColors.brutalYellow
      ..strokeWidth = 3.0;
    canvas.drawLine(
      Offset(finishX, 0),
      Offset(finishX, size.height),
      postPaint,
    );
  }

  void _drawSpeedStreaks(Canvas canvas, Size size) {
    final streakPaint = Paint()
      ..color = (currentGear == maxGears ? AppColors.brutalPink : Colors.white)
          .withValues(alpha: 0.28)
      ..strokeWidth = 1.5;

    final random = math.Random(42);
    for (int i = 0; i < 8; i++) {
      final y = 16.0 + (i * 18.0) + random.nextDouble() * 8;
      final startX = size.width * (0.2 + random.nextDouble() * 0.4);
      final len = 40.0 + random.nextDouble() * 80.0;
      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + len, y),
        streakPaint,
      );
    }
  }

  void _drawParticles(Canvas canvas) {
    for (final p in particles) {
      final alpha = (p.life / p.maxLife).clamp(0.0, 1.0);
      final pPaint = Paint()..color = p.color.withValues(alpha: alpha);

      if (p.type == ParticleType.triangleFlame) {
        final path = Path();
        final h = p.size;
        path.moveTo(p.x, p.y - h);
        path.lineTo(p.x - h * 1.4, p.y + h * 0.6);
        path.lineTo(p.x + h * 0.4, p.y + h * 0.6);
        path.close();

        canvas.save();
        canvas.translate(p.x, p.y);
        canvas.rotate(p.rotation);
        canvas.translate(-p.x, -p.y);
        canvas.drawPath(path, pPaint);

        final strokePaint = Paint()
          ..color = Colors.black.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawPath(path, strokePaint);
        canvas.restore();
      } else if (p.type == ParticleType.smokePuff) {
        final rect = Rect.fromCenter(
          center: Offset(p.x, p.y),
          width: p.size,
          height: p.size,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          pPaint,
        );
      } else if (p.type == ParticleType.sparkShard) {
        final path = Path()
          ..moveTo(p.x, p.y - p.size)
          ..lineTo(p.x + p.size, p.y)
          ..lineTo(p.x, p.y + p.size)
          ..lineTo(p.x - p.size, p.y)
          ..close();
        canvas.drawPath(path, pPaint);
      } else if (p.type == ParticleType.nitroShockwave) {
        final ringPaint = Paint()
          ..color = p.color.withValues(alpha: alpha * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4;
        canvas.drawCircle(Offset(p.x, p.y), p.size, ringPaint);
      }
    }
  }

  void _drawStylizedCar(
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
      ..strokeWidth = 2.2;

    final windowPaint = Paint()..color = const Color(0xFF0F172A);
    final wheelPaint = Paint()..color = const Color(0xFF1E293B);
    final wheelRimPaint = Paint()..color = const Color(0xFFCBD5E1);
    final lightBeamPaint = Paint()
      ..color = const Color(0xFFFEF08A).withValues(alpha: 0.25);

    // Headlight Laser Beam (illuminating the road ahead)
    final beamPath = Path()
      ..moveTo(pos.dx + 52, pos.dy + 12)
      ..lineTo(pos.dx + 90, pos.dy + 4)
      ..lineTo(pos.dx + 90, pos.dy + 22)
      ..close();
    canvas.drawPath(beamPath, lightBeamPaint);

    // Hard Offset Shadow under car
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(pos.dx + 2, pos.dy + 24, 48, 5),
        const Radius.circular(3),
      ),
      shadowPaint,
    );

    // Wheels with alloy rims
    _drawWheel(canvas, Offset(pos.dx + 6, pos.dy + 19), wheelPaint, wheelRimPaint);
    _drawWheel(canvas, Offset(pos.dx + 36, pos.dy + 19), wheelPaint, wheelRimPaint);

    // Main Car Body Box
    final carRect = Rect.fromLTWH(pos.dx, pos.dy + 5, 52, 19);
    canvas.drawRRect(
        RRect.fromRectAndRadius(carRect, const Radius.circular(4)), bodyPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(carRect, const Radius.circular(4)), borderPaint);

    // Cabin / Windshield
    final cabinRect = Rect.fromLTWH(pos.dx + 12, pos.dy, 24, 11);
    canvas.drawRRect(
        RRect.fromRectAndRadius(cabinRect, const Radius.circular(3)),
        windowPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(cabinRect, const Radius.circular(3)),
        borderPaint);

    // Headlight bulb
    final bulbPaint = Paint()..color = const Color(0xFFFEF08A);
    canvas.drawRect(Rect.fromLTWH(pos.dx + 48, pos.dy + 10, 4, 6), bulbPaint);
    canvas.drawRect(Rect.fromLTWH(pos.dx + 48, pos.dy + 10, 4, 6), borderPaint);

    // Taillight bulb
    final tailBulbPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRect(Rect.fromLTWH(pos.dx, pos.dy + 10, 3, 5), tailBulbPaint);

    // Text Label above car
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 0.2,
        ),
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

  void _drawWheel(Canvas canvas, Offset pos, Paint tirePaint, Paint rimPaint) {
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    final wheelRect = Rect.fromLTWH(pos.dx, pos.dy, 10, 8);
    canvas.drawRRect(
        RRect.fromRectAndRadius(wheelRect, const Radius.circular(2)),
        tirePaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(wheelRect, const Radius.circular(2)),
        borderPaint);

    // Rim center dot
    canvas.drawCircle(Offset(pos.dx + 5, pos.dy + 4), 1.8, rimPaint);
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

    // Hard Shadow for Comic Bubble
    final shadowPaint = Paint()..color = Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(bubbleX + 2, bubbleY + 2, bubbleWidth, bubbleHeight),
        const Radius.circular(6),
      ),
      shadowPaint,
    );

    final bgPaint = Paint()
      ..color = isPlayer ? const Color(0xFFFEF08A) : Colors.white;
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

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

  void _drawComicPopups(Canvas canvas) {
    for (final pop in popups) {
      final alpha = (pop.life / pop.maxLife).clamp(0.0, 1.0);
      final textPainter = TextPainter(
        text: TextSpan(
          text: pop.text,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: pop.textColor,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final w = textPainter.width + 12.0;
      final h = textPainter.height + 6.0;

      canvas.save();
      canvas.translate(pop.x, pop.y);
      canvas.rotate(pop.angle);

      // Hard Shadow
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: const Offset(2.5, 2.5), width: w, height: h),
        const Radius.circular(4),
      );
      canvas.drawRRect(
          shadowRect, Paint()..color = Colors.black.withValues(alpha: alpha));

      // Main Badge Body
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        badgeRect,
        Paint()..color = pop.bgColor.withValues(alpha: alpha),
      );
      canvas.drawRRect(
        badgeRect,
        Paint()
          ..color = Colors.black.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _DragTrackPainter oldDelegate) => true;
}
