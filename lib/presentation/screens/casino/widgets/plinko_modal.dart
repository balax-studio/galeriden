import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/casino_game_model.dart';
import '../../../../domain/usecases/casino_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_button.dart';

class PlinkoModal extends ConsumerStatefulWidget {
  const PlinkoModal({super.key});

  @override
  ConsumerState<PlinkoModal> createState() => _PlinkoModalState();
}

class _PlinkoModalState extends ConsumerState<PlinkoModal> with TickerProviderStateMixin {
  double _selectedBet = 50000.0;
  bool _isDropping = false;
  PlinkoDropResult? _lastResult;
  int? _highlightedSlot;

  late AnimationController _dropController;
  late AnimationController _idleController;

  List<int> _currentPath = [];
  final List<Offset> _impactPoints = [];

  final List<double> _quickBets = [25000.0, 50000.0, 150000.0, 500000.0, 1000000.0];

  @override
  void initState() {
    super.initState();
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dropController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _drop() {
    if (_isDropping) return;
    final game = ref.read(gameProvider);

    if (game.balance < _selectedBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('casino_insufficient_balance')),
          backgroundColor: AppColors.brutalRed,
        ),
      );
      return;
    }

    final result = ref.read(gameProvider.notifier).playCasinoPlinko(betAmount: _selectedBet);
    if (result == null) return;

    // Generate path to target slot
    final targetSlot = result.slotIndex;
    final path = _generatePathToSlot(targetSlot);

    setState(() {
      _isDropping = true;
      _lastResult = null;
      _highlightedSlot = null;
      _currentPath = path;
      _impactPoints.clear();
    });

    HapticFeedback.heavyImpact();
    _dropController.forward(from: 0.0).then((_) {
      if (!mounted) return;
      setState(() {
        _isDropping = false;
        _lastResult = result;
        _highlightedSlot = result.slotIndex;
      });

      if (result.multiplier >= 10.0) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.mediumImpact();
      }
    });
  }

  List<int> _generatePathToSlot(int targetSlot) {
    final rand = math.Random();
    List<int> path = [0];
    int currentCol = 0;

    int remainingRights = targetSlot;

    for (int r = 1; r <= 7; r++) {
      int remainingSteps = 8 - r;
      bool goRight;
      if (remainingRights >= remainingSteps) {
        goRight = true;
      } else if (remainingRights <= 0) {
        goRight = false;
      } else {
        goRight = rand.nextBool();
      }

      if (goRight) {
        currentCol++;
        remainingRights--;
      }
      path.add(currentCol);
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            BoxShadow(color: Color(0xFF0F172A), offset: Offset(6, 6), blurRadius: 0),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF00E575),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const VectorIconWidget(type: 'piston', color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_plinko_title'),
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
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    height: 270,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF00E575), width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_dropController, _idleController]),
                        builder: (context, _) {
                          return RepaintBoundary(
                            child: CustomPaint(
                              size: const Size(double.infinity, 270),
                              painter: _PlinkoPhysicsPainter(
                                dropProgress: _dropController.value,
                                idleProgress: _idleController.value,
                                isDropping: _isDropping,
                                path: _currentPath,
                                highlightedSlot: _highlightedSlot,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: CasinoEngine.plinkoMultipliers.asMap().entries.map((e) {
                      final idx = e.key;
                      final mult = e.value;
                      final isLanded = _highlightedSlot == idx;

                      Color bg;
                      if (mult >= 10.0) {
                        bg = const Color(0xFFFFDE59);
                      } else if (mult >= 2.0) {
                        bg = const Color(0xFFFF7A00);
                      } else if (mult >= 1.0) {
                        bg = const Color(0xFF38BDF8);
                      } else {
                        bg = const Color(0xFF64748B);
                      }

                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          transform: isLanded ? Matrix4.diagonal3Values(1.1, 1.15, 1.0) : Matrix4.identity(),
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: isLanded ? AppColors.brutalGreen : bg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isLanded ? Colors.white : Colors.black,
                              width: isLanded ? 2.5 : 1.5,
                            ),
                            boxShadow: isLanded
                                ? [const BoxShadow(color: AppColors.brutalGreen, blurRadius: 8, spreadRadius: 1)]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              '${mult}x',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: (bg == const Color(0xFFFFDE59) || isLanded) ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (_lastResult != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _lastResult!.multiplier >= 1.0 ? AppColors.brutalGreen : AppColors.brutalRed,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _lastResult!.multiplier >= 1.0 ? Icons.emoji_events_rounded : Icons.trending_down_rounded,
                            color: _lastResult!.multiplier >= 1.0 ? Colors.black : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _lastResult!.multiplier >= 1.0
                                  ? context.tr('plinko_win_banner', {
                                      'mult': '${_lastResult!.multiplier}x',
                                      'amount': _formatCurrency(_lastResult!.payoutAmount),
                                    })
                                  : context.tr('plinko_loss_banner', {'amount': _formatCurrency(_lastResult!.payoutAmount)}),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                color: _lastResult!.multiplier >= 1.0 ? Colors.black : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],
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
                  NeoBrutalButton(
                    label: _isDropping ? context.tr('plinko_btn_dropping') : context.tr('plinko_btn_drop'),
                    icon: Icons.south_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 14,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    onPressed: _isDropping ? null : _drop,
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

class _PlinkoPhysicsPainter extends CustomPainter {
  final double dropProgress;
  final double idleProgress;
  final bool isDropping;
  final List<int> path;
  final int? highlightedSlot;

  _PlinkoPhysicsPainter({
    required this.dropProgress,
    required this.idleProgress,
    required this.isDropping,
    required this.path,
    this.highlightedSlot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pinPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;

    final pinGlowPaint = Paint()
      ..color = const Color(0xFF00E575).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    const totalRows = 8;
    final rowSpacing = (size.height - 40) / (totalRows - 1);
    final topOffset = 24.0;

    for (int r = 0; r < totalRows; r++) {
      final pinCount = r + 1;
      final y = topOffset + r * rowSpacing;
      final spacing = size.width / (pinCount + 1);

      for (int c = 0; c < pinCount; c++) {
        final x = (c + 1) * spacing;
        final pinPos = Offset(x, y);
        canvas.drawCircle(pinPos, 5.0 + math.sin(idleProgress * math.pi + r) * 0.8, pinGlowPaint);
        canvas.drawCircle(pinPos, 3.2, pinPaint);
      }
    }

    final dispenserX = size.width / 2;
    final dispenserY = topOffset - 12;
    final dispenserPaint = Paint()
      ..color = isDropping ? AppColors.brutalYellow : const Color(0xFF00E575)
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(dispenserX - 8, dispenserY - 4)
      ..lineTo(dispenserX + 8, dispenserY - 4)
      ..lineTo(dispenserX, dispenserY + 5)
      ..close();
    canvas.drawPath(arrowPath, dispenserPaint);

    if (isDropping && path.isNotEmpty) {
      final stepCount = path.length - 1;
      final scaledT = (dropProgress * stepCount).clamp(0.0, stepCount.toDouble());
      final currentStep = scaledT.floor();
      final stepFraction = scaledT - currentStep;

      final fromRow = currentStep.clamp(0, totalRows - 1);
      final toRow = (currentStep + 1).clamp(0, totalRows - 1);

      final fromCol = path[fromRow];
      final toCol = path[toRow];

      final fromSpacing = size.width / (fromRow + 2);
      final toSpacing = size.width / (toRow + 2);

      final fromX = (fromCol + 1) * fromSpacing;
      final fromY = topOffset + fromRow * rowSpacing;

      final toX = (toCol + 1) * toSpacing;
      final toY = topOffset + toRow * rowSpacing;

      final ballX = fromX + (toX - fromX) * stepFraction;
      final arcHeight = math.sin(stepFraction * math.pi) * 14.0;
      final ballY = fromY + (toY - fromY) * stepFraction - arcHeight;

      final ballPos = Offset(ballX, ballY);

      final sparkPaint = Paint()..color = const Color(0xFFFFDE59).withValues(alpha: 0.6);
      canvas.drawCircle(ballPos.translate(0, -6), 4.0, sparkPaint);
      canvas.drawCircle(ballPos.translate(0, -12), 2.5, sparkPaint);

      final ballPaint = Paint()..color = const Color(0xFFFFDE59);
      final ballShadowPaint = Paint()..color = const Color(0xFFFF7A00).withValues(alpha: 0.7);

      canvas.drawCircle(ballPos, 9.5, ballShadowPaint);
      canvas.drawCircle(ballPos, 7.5, ballPaint);
      canvas.drawCircle(ballPos.translate(-2, -2), 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_PlinkoPhysicsPainter oldDelegate) => true;
}
