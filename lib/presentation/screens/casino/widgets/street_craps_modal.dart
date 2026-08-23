import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/casino_game_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';

class StreetCrapsModal extends ConsumerStatefulWidget {
  const StreetCrapsModal({super.key});

  @override
  ConsumerState<StreetCrapsModal> createState() => _StreetCrapsModalState();
}

class _StreetCrapsModalState extends ConsumerState<StreetCrapsModal> with TickerProviderStateMixin {
  double _selectedBet = 50000.0;
  CarModel? _selectedWagerCar;
  bool _isRolling = false;
  CrapsPhase _currentPhase = CrapsPhase.comeOut;
  int? _point;
  StreetCrapsRollResult? _lastResult;

  int _displayDie1 = 3;
  int _displayDie2 = 4;

  late AnimationController _rollController;
  late AnimationController _idleController;
  Timer? _diceFaceTimer;

  final List<double> _quickBets = [25000.0, 50000.0, 150000.0, 500000.0, 1000000.0];

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _diceFaceTimer?.cancel();
    _rollController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _roll() {
    if (_isRolling) return;
    final game = ref.read(gameProvider);

    if (_currentPhase == CrapsPhase.comeOut && _selectedWagerCar == null && game.balance < _selectedBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('casino_insufficient_balance')),
          backgroundColor: AppColors.brutalRed,
        ),
      );
      return;
    }

    final rand = math.Random();
    setState(() => _isRolling = true);
    HapticFeedback.heavyImpact();

    _rollController.forward(from: 0.0);

    // Rapidly change faces while tumbling
    _diceFaceTimer?.cancel();
    _diceFaceTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _displayDie1 = rand.nextInt(6) + 1;
        _displayDie2 = rand.nextInt(6) + 1;
      });
    });

    Timer(const Duration(milliseconds: 1200), () {
      _diceFaceTimer?.cancel();
      if (!mounted) return;

      final result = ref.read(gameProvider.notifier).playCasinoStreetCraps(
            currentPhase: _currentPhase,
            currentPoint: _point,
            betAmount: _selectedBet,
            wageredCar: _selectedWagerCar,
          );

      if (result != null) {
        setState(() {
          _isRolling = false;
          _lastResult = result;
          _displayDie1 = result.die1;
          _displayDie2 = result.die2;
          _currentPhase = result.nextPhase;
          _point = result.point;
          if (result.isWin || result.isLoss) {
            _selectedWagerCar = null;
          }
        });

        if (result.isWin) {
          HapticFeedback.vibrate();
        } else if (result.isLoss) {
          HapticFeedback.mediumImpact();
        }
      } else {
        setState(() => _isRolling = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final ownedCars = game.ownedCars;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 730),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
          boxShadow: const [
            BoxShadow(color: Color(0xFF0F172A), offset: Offset(6, 6), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            // Modal Header with hazard accent
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFF7A00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.casino_rounded, color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_craps_title'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Craps Table Felt / Arena
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFF7A00), width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Phase & Point Indicator
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            NeoBrutalBadge(
                              label: _currentPhase == CrapsPhase.comeOut
                                  ? context.tr('craps_phase_come_out')
                                  : context.tr('craps_phase_point'),
                              color: _currentPhase == CrapsPhase.comeOut ? AppColors.brutalYellow : const Color(0xFF38BDF8),
                              textColor: Colors.black,
                            ),
                            if (_point != null)
                              NeoBrutalBadge(
                                label: context.tr('craps_target_point', {'point': '$_point'}),
                                color: const Color(0xFFA855F7),
                                textColor: Colors.white,
                              ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Animated 3D Rolling Dice Arena
                        SizedBox(
                          height: 90,
                          child: AnimatedBuilder(
                            animation: Listenable.merge([_rollController, _idleController]),
                            builder: (context, _) {
                              final rollProgress = _rollController.value;
                              final idleProgress = _idleController.value;

                              final rot1 = _isRolling ? (rollProgress * math.pi * 6) : (math.sin(idleProgress * math.pi) * 0.05);
                              final rot2 = _isRolling ? -(rollProgress * math.pi * 6.5) : (-math.sin(idleProgress * math.pi) * 0.05);
                              final scale1 = _isRolling ? (1.0 + math.sin(rollProgress * math.pi) * 0.25) : 1.0;
                              final scale2 = _isRolling ? (1.0 + math.sin(rollProgress * math.pi * 1.2) * 0.22) : 1.0;

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.002)
                                      ..rotateZ(rot1)
                                      ..rotateX(_isRolling ? rot1 * 0.7 : 0),
                                    child: Transform.scale(
                                      scale: scale1,
                                      child: _buildDieWidget(_displayDie1),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.002)
                                      ..rotateZ(rot2)
                                      ..rotateY(_isRolling ? rot2 * 0.7 : 0),
                                    child: Transform.scale(
                                      scale: scale2,
                                      child: _buildDieWidget(_displayDie2),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        if (_lastResult != null && !_isRolling) ...[
                          Text(
                            context.tr('craps_total_rolled', {'sum': '${_lastResult!.sum}'}),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _lastResult!.isWin
                                  ? AppColors.brutalGreen
                                  : (_lastResult!.isLoss ? AppColors.brutalRed : const Color(0xFF334155)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF0F172A), width: 2),
                            ),
                            child: Text(
                              context.tr(_lastResult!.statusSummaryKey),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: (_lastResult!.isWin || _lastResult!.isLoss) ? Colors.black : Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ] else if (_isRolling) ...[
                          Text(
                            context.tr('craps_btn_rolling'),
                            style: const TextStyle(
                              color: AppColors.brutalYellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Pink Slip / Vehicle Wager Picker (Only in Come-out phase)
                  if (_currentPhase == CrapsPhase.comeOut && ownedCars.isNotEmpty) ...[
                    Text(
                      context.tr('casino_pink_slip_header'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text(context.tr('casino_chip_cash_only')),
                            selected: _selectedWagerCar == null,
                            selectedColor: AppColors.brutalYellow,
                            onSelected: (_) => setState(() => _selectedWagerCar = null),
                          ),
                          const SizedBox(width: 8),
                          ...ownedCars.map((car) {
                            final isSel = _selectedWagerCar?.id == car.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text('${car.modelName} • ${_formatCurrency(car.price)}'),
                                selected: isSel,
                                selectedColor: const Color(0xFFA855F7),
                                onSelected: (_) => setState(() => _selectedWagerCar = car),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Cash Bet selector (if Come-out and not pink slip)
                  if (_currentPhase == CrapsPhase.comeOut && _selectedWagerCar == null) ...[
                    Text(
                      context.tr('casino_bet_amount_label'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickBets.map((bet) {
                          final isSel = _selectedBet == bet;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedBet = bet);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                                ),
                                child: Text(
                                  _formatCurrency(bet),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isSel ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Roll Button
                  NeoBrutalButton(
                    label: _isRolling
                        ? context.tr('craps_btn_rolling')
                        : (_currentPhase == CrapsPhase.comeOut
                            ? context.tr('craps_btn_roll_come_out')
                            : context.tr('craps_btn_roll_point')),
                    icon: Icons.casino_rounded,
                    backgroundColor: const Color(0xFFFF7A00),
                    textColor: Colors.black,
                    fontSize: 14,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: _isRolling ? null : _roll,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDieWidget(int value) {
    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
        boxShadow: const [
          BoxShadow(color: Color(0xFF0F172A), offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: CustomPaint(
        painter: _DieDotsPainter(value),
      ),
    );
  }

  String _formatCurrency(double val) {
    if (val >= 1000000) {
      return '₺${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '₺${(val / 1000).toStringAsFixed(0)}K';
    }
    return '₺${val.toStringAsFixed(0)}';
  }
}

class _DieDotsPainter extends CustomPainter {
  final int value;
  _DieDotsPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = const Color(0xFF0F172A);
    final dotRadius = size.width * 0.085;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = size.width * 0.25;
    final right = size.width * 0.75;
    final top = size.height * 0.25;
    final bottom = size.height * 0.75;

    void draw(double x, double y) => canvas.drawCircle(Offset(x, y), dotRadius, dotPaint);

    if (value == 1 || value == 3 || value == 5) draw(cx, cy);
    if (value >= 2) {
      draw(left, top);
      draw(right, bottom);
    }
    if (value >= 4) {
      draw(right, top);
      draw(left, bottom);
    }
    if (value == 6) {
      draw(left, cy);
      draw(right, cy);
    }
  }

  @override
  bool shouldRepaint(_DieDotsPainter oldDelegate) => oldDelegate.value != value;
}
