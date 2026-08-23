import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/car_model.dart';
import '../../../../domain/usecases/casino_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';

enum AviatorState {
  idle,
  flying,
  cashedOut,
  crashed,
}

class AviatorCrashModal extends ConsumerStatefulWidget {
  const AviatorCrashModal({super.key});

  @override
  ConsumerState<AviatorCrashModal> createState() => _AviatorCrashModalState();
}

class _AviatorCrashModalState extends ConsumerState<AviatorCrashModal> with TickerProviderStateMixin {
  double _selectedBet = 50000.0;
  CarModel? _selectedWagerCar;

  AviatorState _state = AviatorState.idle;
  double _currentMultiplier = 1.00;
  double _targetCrashMultiplier = 2.00;
  double _cashedOutAt = 1.00;

  late AnimationController _flightController;
  late AnimationController _idleGlowController;
  late AnimationController _shakeController;

  final List<double> _quickBets = [50000.0, 100000.0, 250000.0, 750000.0, 2000000.0];

  @override
  void initState() {
    super.initState();
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _idleGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _flightController.addListener(_onFlightTick);
  }

  @override
  void dispose() {
    _flightController.removeListener(_onFlightTick);
    _flightController.dispose();
    _idleGlowController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onFlightTick() {
    if (_state != AviatorState.flying) return;

    final progress = _flightController.value;
    // Exponential multiplier progression formula
    final mult = 1.00 + math.pow(progress * 4.5, 2.3);
    final formatted = double.parse(mult.toStringAsFixed(2));

    if (formatted >= _targetCrashMultiplier) {
      // Rocket exploded
      _flightController.stop();
      setState(() {
        _currentMultiplier = _targetCrashMultiplier;
        _state = AviatorState.crashed;
      });
      _shakeController.forward(from: 0);
      HapticFeedback.heavyImpact();

      // Register loss in game provider
      ref.read(gameProvider.notifier).playCasinoAviatorCrash(
        betAmount: _selectedBet,
        wageredCar: _selectedWagerCar,
      );
    } else {
      setState(() {
        _currentMultiplier = formatted;
      });
    }
  }

  void _startFlight() {
    if (_state == AviatorState.flying) return;
    final game = ref.read(gameProvider);

    if (_selectedWagerCar == null && game.balance < _selectedBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('casino_insufficient_balance')),
          backgroundColor: AppColors.brutalRed,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    final crashPoint = CasinoEngine.generateAviatorCrashMultiplier();

    // Deduct wager initially
    ref.read(gameProvider.notifier).playCasinoAviatorDeductWager(
      betAmount: _selectedBet,
      wageredCar: _selectedWagerCar,
    );

    setState(() {
      _targetCrashMultiplier = crashPoint;
      _currentMultiplier = 1.00;
      _cashedOutAt = 1.00;
      _state = AviatorState.flying;
    });

    _flightController.reset();
    _flightController.forward();
  }

  void _cashOut() {
    if (_state != AviatorState.flying) return;

    _flightController.stop();
    final cashedMult = _currentMultiplier;

    setState(() {
      _cashedOutAt = cashedMult;
      _state = AviatorState.cashedOut;
    });

    HapticFeedback.heavyImpact();
    final effectiveBet = _selectedWagerCar != null ? _selectedWagerCar!.price : _selectedBet;
    final result = CasinoEngine.playAviatorCashout(
      betAmount: effectiveBet,
      cashedOutMultiplier: cashedMult,
      crashMultiplier: _targetCrashMultiplier,
      wageredCar: _selectedWagerCar,
    );

    ref.read(gameProvider.notifier).playCasinoAviatorCashout(
      betAmount: _selectedBet,
      multiplier: cashedMult,
      wageredCar: _selectedWagerCar,
      isWin: result.isWin,
    );
  }

  void _resetFlight() {
    setState(() {
      _state = AviatorState.idle;
      _currentMultiplier = 1.00;
      _cashedOutAt = 1.00;
    });
    _flightController.reset();
  }

  Color _getMultiplierColor() {
    if (_state == AviatorState.crashed) return AppColors.brutalRed;
    if (_state == AviatorState.cashedOut) return AppColors.brutalGreen;
    if (_currentMultiplier >= 10.0) return const Color(0xFFFFD700);
    if (_currentMultiplier >= 5.0) return const Color(0xFFA855F7);
    if (_currentMultiplier >= 2.0) return const Color(0xFF38BDF8);
    return Colors.white;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₺${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₺${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '₺${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final ownedCars = game.ownedCars;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final shake = math.sin(_shakeController.value * math.pi * 6) * 6.0 * (1.0 - _shakeController.value);
          return Transform.translate(
            offset: Offset(shake, 0),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0F172A), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0F172A),
                offset: Offset(6, 6),
                blurRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Modal Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF3366),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                    border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 2.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.rocket_launch_rounded, size: 20, color: Color(0xFFFF3366)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('casino_aviator_title'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              context.tr('casino_aviator_subtitle'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Aviator Radar Canvas Display
                      Container(
                        height: 220,
                        decoration: BoxDecoration(
                          color: const Color(0xFF070B14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF0F172A), width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF0F172A),
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            children: [
                              // Radar Canvas Flight Curve (RepaintBoundary isolated for 60 FPS performance)
                              Positioned.fill(
                                child: RepaintBoundary(
                                  child: CustomPaint(
                                    painter: _AviatorRadarPainter(
                                      progress: _flightController.value,
                                      state: _state,
                                      pulse: _idleGlowController.value,
                                    ),
                                  ),
                                ),
                              ),

                              // Central Digital Multiplier Text
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${_currentMultiplier.toStringAsFixed(2)}x',
                                      style: TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                        color: _getMultiplierColor(),
                                        letterSpacing: -1,
                                        shadows: [
                                          Shadow(
                                            color: _getMultiplierColor().withValues(alpha: 0.6),
                                            blurRadius: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_state == AviatorState.crashed) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.brutalRed,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        child: Text(
                                          context.tr('aviator_status_crashed'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ] else if (_state == AviatorState.cashedOut) ...[
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.brutalGreen,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.black, width: 2),
                                        ),
                                        child: Text(
                                          context.tr('aviator_status_cashed_out', {
                                            'mult': '${_cashedOutAt.toStringAsFixed(2)}x',
                                          }),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Real-Time Potential Profit Indicator during Flight
                              if (_state == AviatorState.flying)
                                Positioned(
                                  top: 10,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(200),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFF3366), width: 1.5),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.trending_up_rounded, color: Color(0xFFFF3366), size: 14),
                                        const SizedBox(width: 4),
                                        Text(
                                          _formatCurrency((_selectedWagerCar != null ? _selectedWagerCar!.price : _selectedBet) * _currentMultiplier),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Wager Type Selector: Cash vs Pink Slip (Car Wager)
                      if (_state == AviatorState.idle) ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildWagerTypeTab(
                                title: context.tr('wager_type_cash'),
                                isSelected: _selectedWagerCar == null,
                                onTap: () => setState(() => _selectedWagerCar = null),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildWagerTypeTab(
                                title: context.tr('wager_type_pink_slip'),
                                isSelected: _selectedWagerCar != null,
                                onTap: () {
                                  if (ownedCars.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(context.tr('no_cars_for_wager')),
                                        backgroundColor: AppColors.brutalRed,
                                      ),
                                    );
                                    return;
                                  }
                                  setState(() => _selectedWagerCar = ownedCars.first);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Bet Selector or Car Selector
                        if (_selectedWagerCar == null) ...[
                          Row(
                            children: _quickBets.map((amount) {
                              final isSelected = _selectedBet == amount;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 2),
                                  child: GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _selectedBet = amount);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFFF3366) : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? Colors.black : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                                          width: isSelected ? 2 : 1.5,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _formatCurrency(amount),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 11,
                                            color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF3366).withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFF3366), width: 2),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.directions_car_rounded, color: Color(0xFFFF3366), size: 22),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_selectedWagerCar!.brand} ${_selectedWagerCar!.modelName} • ${_formatCurrency(_selectedWagerCar!.price)}',
                                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],

                      const SizedBox(height: 16),

                      // Main Action Button (Launch vs Cash Out vs Play Again)
                      if (_state == AviatorState.flying) ...[
                        NeoBrutalButton(
                          label: context.tr('aviator_btn_cash_out', {
                            'amount': _formatCurrency((_selectedWagerCar != null ? _selectedWagerCar!.price : _selectedBet) * _currentMultiplier),
                          }),
                          backgroundColor: AppColors.brutalGreen,
                          textColor: Colors.black,
                          minHeight: 52,
                          fullWidth: true,
                          onPressed: _cashOut,
                        ),
                      ] else if (_state == AviatorState.idle) ...[
                        NeoBrutalButton(
                          label: context.tr('aviator_btn_launch'),
                          backgroundColor: const Color(0xFFFF3366),
                          textColor: Colors.white,
                          minHeight: 50,
                          fullWidth: true,
                          onPressed: _startFlight,
                        ),
                      ] else ...[
                        NeoBrutalButton(
                          label: context.tr('aviator_btn_play_again'),
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          minHeight: 50,
                          fullWidth: true,
                          onPressed: _resetFlight,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWagerTypeTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF3366) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            width: isSelected ? 2 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }
}

/// Custom Canvas Painter for Aviator Bezier Trajectory, Particle Sparks & Rocket
class _AviatorRadarPainter extends CustomPainter {
  final double progress;
  final AviatorState state;
  final double pulse;

  _AviatorRadarPainter({
    required this.progress,
    required this.state,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    // Draw Grid Lines
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (state == AviatorState.idle) {
      // Idle ground rocket position
      _drawRocket(canvas, const Offset(30, 180), 0.0, pulse);
      return;
    }

    // Trajectory Path
    final start = Offset(20, size.height - 20);
    final currentX = 20 + progress * (size.width - 60);
    // Quadratic flight curve
    final currentY = (size.height - 20) - math.pow(progress, 1.6) * (size.height - 50);
    final currentPos = Offset(currentX, currentY);

    final controlPoint = Offset(start.dx + (currentX - start.dx) * 0.5, size.height - 20);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(controlPoint.dx, controlPoint.dy, currentPos.dx, currentPos.dy);

    // Gradient Area under curve
    final fillPath = Path.from(path)
      ..lineTo(currentPos.dx, size.height - 20)
      ..lineTo(start.dx, size.height - 20)
      ..close();

    final fillGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: state == AviatorState.crashed
          ? [
              const Color(0xFFFF3366).withValues(alpha: 0.4),
              Colors.transparent,
            ]
          : [
              const Color(0xFFFF3366).withValues(alpha: 0.5),
              const Color(0xFFFF7A00).withValues(alpha: 0.05),
            ],
    );

    canvas.drawPath(
      fillPath,
      Paint()..shader = fillGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Glowing Trajectory Line
    final linePaint = Paint()
      ..color = state == AviatorState.crashed ? AppColors.brutalRed : const Color(0xFFFF3366)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    if (state != AviatorState.crashed) {
      // Angle calculation
      final angle = -math.atan2((size.height - 20) - currentPos.dy, currentPos.dx - start.dx) * 0.6;
      _drawRocket(canvas, currentPos, angle, pulse);
    } else {
      // Explosion Shockwave
      _drawExplosion(canvas, currentPos);
    }
  }

  void _drawRocket(Canvas canvas, Offset pos, double angle, double pulseVal) {
    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(angle);

    // Exhaust flame
    final flamePaint = Paint()
      ..color = Color.lerp(const Color(0xFFFF7A00), const Color(0xFFFFDE59), pulseVal)!
      ..style = PaintingStyle.fill;

    final flamePath = Path()
      ..moveTo(-8, -3)
      ..lineTo(-20 - (pulseVal * 8), 0)
      ..lineTo(-8, 3)
      ..close();

    canvas.drawPath(flamePath, flamePaint);

    // Rocket Body
    final bodyPaint = Paint()..color = Colors.white;
    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rocketPath = Path()
      ..moveTo(14, 0)
      ..lineTo(-6, -8)
      ..lineTo(-8, -4)
      ..lineTo(-8, 4)
      ..lineTo(-6, 8)
      ..close();

    canvas.drawPath(rocketPath, bodyPaint);
    canvas.drawPath(rocketPath, strokePaint);

    // Red Fin & Nosecone
    final finPaint = Paint()..color = const Color(0xFFFF3366);
    final finPath = Path()
      ..moveTo(14, 0)
      ..lineTo(4, -4)
      ..lineTo(4, 4)
      ..close();

    canvas.drawPath(finPath, finPaint);

    canvas.restore();
  }

  void _drawExplosion(Canvas canvas, Offset pos) {
    final blastPaint = Paint()
      ..color = AppColors.brutalRed.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 22, blastPaint);

    final innerBlast = Paint()
      ..color = AppColors.brutalYellow
      ..style = PaintingStyle.fill;

    canvas.drawCircle(pos, 12, innerBlast);

    final sparkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final rad = i * (math.pi / 4);
      final p1 = Offset(pos.dx + math.cos(rad) * 12, pos.dy + math.sin(rad) * 12);
      final p2 = Offset(pos.dx + math.cos(rad) * 26, pos.dy + math.sin(rad) * 26);
      canvas.drawLine(p1, p2, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _AviatorRadarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.state != state || oldDelegate.pulse != pulse;
  }
}
