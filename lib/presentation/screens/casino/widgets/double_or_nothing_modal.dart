import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/car_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';

class DoubleOrNothingModal extends ConsumerStatefulWidget {
  final double baseProfit;
  final CarModel? wageredCar;
  final VoidCallback? onFinished;

  const DoubleOrNothingModal({
    super.key,
    required this.baseProfit,
    this.wageredCar,
    this.onFinished,
  });

  @override
  ConsumerState<DoubleOrNothingModal> createState() => _DoubleOrNothingModalState();
}

class _DoubleOrNothingModalState extends ConsumerState<DoubleOrNothingModal> with TickerProviderStateMixin {
  bool _isFlipping = false;
  bool? _isWin;

  late AnimationController _flipController;
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _flip(bool guessHeads) {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
      _isWin = null;
    });

    HapticFeedback.heavyImpact();
    _flipController.reset();
    _flipController.forward();

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final win = ref.read(gameProvider.notifier).playCasinoDoubleOrNothing(
            baseProfit: widget.baseProfit,
            guessHeads: guessHeads,
            wageredCar: widget.wageredCar,
          );

      setState(() {
        _isFlipping = false;
        _isWin = win;
      });

      if (win) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveStake = widget.wageredCar != null ? widget.wageredCar!.price : widget.baseProfit;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 620),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
          boxShadow: const [
            BoxShadow(color: Color(0xFF0F172A), offset: Offset(6, 6), blurRadius: 0),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.brutalYellow,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on_rounded, color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_double_or_nothing_title'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.black),
                    ),
                  ),
                  if (_isWin != null || !_isFlipping)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onFinished?.call();
                      },
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

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    context.tr('double_stake_header', {'amount': _formatCurrency(effectiveStake)}),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.wageredCar != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.wageredCar!.modelName} • ${context.tr('casino_pink_slip_header')}',
                      style: const TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // 3D Animated Coin Toss with Arc
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_flipController, _idleController]),
                        builder: (context, child) {
                          if (_isFlipping) {
                            final val = _flipController.value;
                            final angle = val * 8 * math.pi;
                            final arcY = -math.sin(val * math.pi) * 35.0;

                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.002)
                                ..rotateX(angle),
                              child: Transform.translate(
                                offset: Offset(0, arcY),
                                child: _buildCoinView(),
                              ),
                            );
                          } else {
                            final idleFloat = math.sin(_idleController.value * math.pi) * 4.0;
                            return Transform.translate(
                              offset: Offset(0, idleFloat),
                              child: _buildCoinView(),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_isWin != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _isWin! ? AppColors.brutalGreen : AppColors.brutalRed,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isWin! ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                            color: _isWin! ? Colors.black : Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _isWin!
                                  ? context.tr('double_win_banner', {'amount': _formatCurrency(effectiveStake * 2.0)})
                                  : context.tr('double_loss_banner'),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: _isWin! ? Colors.black : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (_isWin == null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            label: context.tr('double_btn_heads'),
                            icon: Icons.face_rounded,
                            backgroundColor: const Color(0xFF38BDF8),
                            textColor: Colors.black,
                            fontSize: 13,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: _isFlipping ? null : () => _flip(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NeoBrutalButton(
                            label: context.tr('double_btn_tails'),
                            icon: Icons.shield_rounded,
                            backgroundColor: const Color(0xFFFF7A00),
                            textColor: Colors.black,
                            fontSize: 13,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: _isFlipping ? null : () => _flip(false),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    NeoBrutalButton(
                      label: context.tr('modal_btn_close'),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white : Colors.black,
                      fontSize: 13,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onFinished?.call();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinView() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.brutalYellow,
        border: Border.all(color: const Color(0xFF0F172A), width: 3.5),
        boxShadow: const [
          BoxShadow(color: Color(0xFF0F172A), offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Center(
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0F172A), width: 2),
          ),
          child: const Center(
            child: Icon(Icons.attach_money_rounded, size: 44, color: Colors.black),
          ),
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
