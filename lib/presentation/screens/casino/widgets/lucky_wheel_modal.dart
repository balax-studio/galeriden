import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/casino_game_model.dart';
import '../../../../domain/usecases/casino_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';

class LuckyWheelModal extends ConsumerStatefulWidget {
  const LuckyWheelModal({super.key});

  @override
  ConsumerState<LuckyWheelModal> createState() => _LuckyWheelModalState();
}

class _LuckyWheelModalState extends ConsumerState<LuckyWheelModal>
    with TickerProviderStateMixin {
  double _selectedBet = 100000.0;
  CarModel? _selectedWagerCar;
  bool _isSpinning = false;
  LuckyWheelSpinResult? _lastResult;

  late AnimationController _spinController;
  late AnimationController _idleController;
  double _currentAngle = 0.0;
  double _tickerOffset = 0.0;

  final List<double> _quickBets = [
    50000.0,
    100000.0,
    250000.0,
    750000.0,
    2000000.0
  ];

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spinController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _spin() {
    if (_isSpinning) return;
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

    final result = ref.read(gameProvider.notifier).spinCasinoWheel(
          betAmount: _selectedBet,
          wageredCar: _selectedWagerCar,
        );

    if (result == null) return;

    setState(() {
      _isSpinning = true;
      _lastResult = null;
    });

    HapticFeedback.heavyImpact();

    final sliceCount = CasinoEngine.wheelSlices.length;
    final sliceAngle = (2 * math.pi) / sliceCount;
    final targetSliceAngle = (result.sliceIndex * sliceAngle);
    final totalRotations = (6 * 2 * math.pi) + (2 * math.pi - targetSliceAngle);

    final startAngle = _currentAngle;
    _spinController.reset();

    final curve =
        CurvedAnimation(parent: _spinController, curve: Curves.easeOutCubic);

    _spinController.addListener(() {
      final newAngle = startAngle + (curve.value * totalRotations);
      // Ticker vibration based on slice crossing
      final sliceFraction = (newAngle / sliceAngle);
      final deflection =
          math.sin(sliceFraction * math.pi * 2) * (_isSpinning ? 0.35 : 0.0);

      setState(() {
        _currentAngle = newAngle;
        _tickerOffset = deflection;
      });

      if (_spinController.value % 0.08 < 0.015) {
        HapticFeedback.selectionClick();
      }
    });

    _spinController.forward().then((_) {
      if (!mounted) return;
      setState(() {
        _isSpinning = false;
        _tickerOffset = 0.0;
        _lastResult = result;
        _selectedWagerCar = null;
      });

      if (result.awardedCar != null || result.slice.multiplier >= 5.0) {
        HapticFeedback.vibrate();
      } else if (result.isBankrupt) {
        HapticFeedback.heavyImpact();
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
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 750),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
          boxShadow: const [
            BoxShadow(
                color: Color(0xFF0F172A), offset: Offset(6, 6), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFDE59),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(
                    bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded,
                      color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_wheel_title'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: Colors.black),
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
                      child: const Icon(Icons.close_rounded,
                          color: Colors.white, size: 18),
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
                  // Rotating Wheel Visual with Light Bulbs (RepaintBoundary isolated for 60 FPS rotation)
                  Center(
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: 250,
                        height: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Outer Bulb Ring
                            AnimatedBuilder(
                              animation: _idleController,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: const Size(250, 250),
                                  painter: _WheelRimPainter(
                                    idleValue: _idleController.value,
                                    isSpinning: _isSpinning,
                                  ),
                                );
                              },
                            ),

                            // Slices Canvas
                            Transform.rotate(
                              angle: _currentAngle,
                              child: CustomPaint(
                                size: const Size(220, 220),
                                painter: _LuckyWheelPainter(),
                              ),
                            ),

                            // Center Golden Crown Pivot
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.brutalYellow, width: 3.0),
                                boxShadow: const [
                                  BoxShadow(
                                      color: Colors.black54,
                                      offset: Offset(2, 2),
                                      blurRadius: 0),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.stars_rounded,
                                    color: AppColors.brutalYellow, size: 24),
                              ),
                            ),

                            // Deflecting Top Pointer Needle
                            Positioned(
                              top: 4,
                              child: Transform.rotate(
                                angle: _tickerOffset,
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: 22,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                    boxShadow: const [
                                      BoxShadow(
                                          color: Colors.black,
                                          offset: Offset(2, 2),
                                          blurRadius: 0),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.arrow_drop_down,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (_lastResult != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _lastResult!.isBankrupt
                            ? AppColors.brutalRed
                            : (_lastResult!.slice.multiplier >= 1.0
                                ? AppColors.brutalGreen
                                : const Color(0xFFFF7A00)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF0F172A), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _lastResult!.isBankrupt
                                ? Icons.dangerous_rounded
                                : Icons.emoji_events_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _lastResult!.isBankrupt
                                  ? context.tr('wheel_status_bankrupt')
                                  : context.tr('casino_win_banner', {
                                      'amount': _formatCurrency(
                                          _lastResult!.payoutAmount)
                                    }),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                  color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_lastResult!.awardedCar != null) ...[
                      const SizedBox(height: 8),
                      NeoBrutalBadge(
                        label: context.tr('wheel_supercar_won',
                            {'model': _lastResult!.awardedCar!.modelName}),
                        color: AppColors.brutalYellow,
                        textColor: Colors.black,
                      ),
                    ],
                    const SizedBox(height: 14),
                  ],

                  // Pink Slip / Garage Vehicle Wager Picker
                  if (ownedCars.isNotEmpty) ...[
                    Text(
                      context.tr('casino_pink_slip_header'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12),
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
                            onSelected: (_) =>
                                setState(() => _selectedWagerCar = null),
                          ),
                          const SizedBox(width: 8),
                          ...ownedCars.map((car) {
                            final isSel = _selectedWagerCar?.id == car.id;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(
                                    '${car.modelName} • ${_formatCurrency(car.price)}'),
                                selected: isSel,
                                selectedColor: const Color(0xFFA855F7),
                                onSelected: (_) =>
                                    setState(() => _selectedWagerCar = car),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Bet selector (if not pink slip)
                  if (_selectedWagerCar == null) ...[
                    Text(
                      context.tr('casino_bet_amount_label'),
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 12),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? AppColors.brutalYellow
                                      : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFF0F172A),
                                      width: 1.5),
                                ),
                                child: Text(
                                  _formatCurrency(bet),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: isSel
                                        ? Colors.black
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black87),
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

                  // Spin Action Button
                  NeoBrutalButton(
                    label: _isSpinning
                        ? context.tr('wheel_btn_spinning')
                        : context.tr('wheel_btn_spin'),
                    icon: Icons.refresh_rounded,
                    backgroundColor: const Color(0xFFFFDE59),
                    textColor: Colors.black,
                    fontSize: 14,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: _isSpinning ? null : _spin,
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _WheelRimPainter extends CustomPainter {
  final double idleValue;
  final bool isSpinning;

  _WheelRimPainter({required this.idleValue, required this.isSpinning});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rimRadius = (size.width / 2) - 4;

    final rimPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, rimRadius, rimPaint);

    // Draw Light Bulbs
    const bulbCount = 16;
    for (int i = 0; i < bulbCount; i++) {
      final angle = (i * 2 * math.pi) / bulbCount;
      final bulbX = center.dx + math.cos(angle) * rimRadius;
      final bulbY = center.dy + math.sin(angle) * rimRadius;

      final isLit =
          isSpinning ? (i % 2 == (idleValue * 10).toInt() % 2) : (i % 2 == 0);
      final bulbColor =
          isLit ? AppColors.brutalYellow : const Color(0xFF64748B);

      canvas.drawCircle(Offset(bulbX, bulbY), 3.5, Paint()..color = bulbColor);
    }
  }

  @override
  bool shouldRepaint(_WheelRimPainter oldDelegate) =>
      oldDelegate.isSpinning != isSpinning ||
      (isSpinning && oldDelegate.idleValue != idleValue);
}

class _LuckyWheelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final slices = CasinoEngine.wheelSlices;
    final sliceAngle = (2 * math.pi) / slices.length;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final paint = Paint()
        ..color = Color(slice.colorHex)
        ..style = PaintingStyle.fill;

      final startAngle = i * sliceAngle - (math.pi / 2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        paint,
      );

      final linePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        true,
        linePaint,
      );

      // Draw Slice Text
      final midAngle = startAngle + (sliceAngle / 2);
      final textRadius = radius * 0.65;
      final textX = center.dx + math.cos(midAngle) * textRadius;
      final textY = center.dy + math.sin(midAngle) * textRadius;

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(midAngle + (math.pi / 2));

      final isCar = slice.type == WheelSliceType.legendaryCarKey;
      final isBankrupt = slice.type == WheelSliceType.bankrupt;
      final textSpan = TextSpan(
        text: isCar ? 'CAR' : (isBankrupt ? '0x' : '${slice.multiplier}x'),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
