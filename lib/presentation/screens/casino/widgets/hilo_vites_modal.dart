import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/casino_game_model.dart';
import '../../../../domain/usecases/casino_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';

class HiLoVitesModal extends ConsumerStatefulWidget {
  const HiLoVitesModal({super.key});

  @override
  ConsumerState<HiLoVitesModal> createState() => _HiLoVitesModalState();
}

class _HiLoVitesModalState extends ConsumerState<HiLoVitesModal> with TickerProviderStateMixin {
  double _selectedBet = 50000.0;
  bool _isPlaying = false;
  bool _isGuessing = false;
  int _currentStreak = 0;
  double _currentMultiplier = 1.0;
  CasinoCard? _currentCard;
  CasinoCard? _nextCard;
  bool _isBust = false;

  late AnimationController _flipController;
  late AnimationController _pulseController;

  final List<double> _quickBets = [25000.0, 50000.0, 150000.0, 500000.0, 1000000.0];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame() {
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

    final success = ref.read(gameProvider.notifier).startHiLoGame(_selectedBet);
    if (!success) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _isPlaying = true;
      _isBust = false;
      _currentStreak = 0;
      _currentMultiplier = 1.0;
      _currentCard = CasinoEngine.drawRandomCard();
      _nextCard = null;
    });
  }

  void _guess(bool higher) {
    if (!_isPlaying || _isGuessing || _currentCard == null) return;

    setState(() => _isGuessing = true);
    HapticFeedback.mediumImpact();
    _flipController.forward(from: 0.0);

    Timer(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      final res = CasinoEngine.guessHiLo(
        currentCard: _currentCard!,
        guessHigher: higher,
        currentStreak: _currentStreak,
      );

      setState(() {
        _isGuessing = false;
        _nextCard = res.nextCard;
        _currentStreak = res.currentStreak;
        _currentMultiplier = res.currentMultiplier;
        _isBust = res.isBust;
      });

      if (res.isCorrect) {
        HapticFeedback.vibrate();
        Timer(const Duration(milliseconds: 700), () {
          if (mounted && !_isBust) {
            setState(() {
              _currentCard = res.nextCard;
              _nextCard = null;
            });
          }
        });
      } else {
        HapticFeedback.heavyImpact();
        ref.read(gameProvider.notifier).recordHiLoBust(_selectedBet);
        setState(() => _isPlaying = false);
      }
    });
  }

  void _cashOut() {
    if (!_isPlaying || _currentStreak == 0) return;
    final totalPayout = _selectedBet * _currentMultiplier;

    ref.read(gameProvider.notifier).cashOutHiLo(
          initialBet: _selectedBet,
          payoutAmount: totalPayout,
          streak: _currentStreak,
        );

    HapticFeedback.vibrate();
    setState(() {
      _isPlaying = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('hilo_cash_out_success', {'amount': _formatCurrency(totalPayout)})),
        backgroundColor: AppColors.brutalGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFA855F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.speed_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_hilo_title'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white),
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
                  // Multiplier Ladder Visual
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0F172A), width: 2.5),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: CasinoEngine.hiLoMultipliers.asMap().entries.map((e) {
                          final step = e.key;
                          final mult = e.value;
                          final isActive = _currentStreak == step && _isPlaying;
                          final isPassed = _currentStreak > step && _isPlaying;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.brutalYellow
                                  : (isPassed ? AppColors.brutalGreen : const Color(0xFF1E293B)),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive ? Colors.black : Colors.white24,
                                width: isActive ? 2.5 : 1,
                              ),
                              boxShadow: isActive
                                  ? const [BoxShadow(color: AppColors.brutalYellow, blurRadius: 8, spreadRadius: 1)]
                                  : null,
                            ),
                            child: Text(
                              '${mult}x',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: (isActive || isPassed) ? Colors.black : Colors.white60,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Active Card / Arena Display
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isBust ? AppColors.brutalRed : const Color(0xFFA855F7),
                        width: 3.0,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_currentCard != null) _buildLargeCard(_currentCard!, label: context.tr('hilo_current_gear')),
                            if (_isGuessing) ...[
                              const SizedBox(width: 14),
                              const Icon(Icons.arrow_forward_rounded, color: AppColors.brutalYellow, size: 24),
                              const SizedBox(width: 14),
                              _buildCardBackAnimated(),
                            ] else if (_nextCard != null) ...[
                              const SizedBox(width: 14),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 24),
                              const SizedBox(width: 14),
                              _buildLargeCard(_nextCard!, label: context.tr('hilo_next_gear')),
                            ],
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (_isPlaying && !_isBust) ...[
                          NeoBrutalBadge(
                            label: context.tr('hilo_current_win', {
                              'amount': _formatCurrency(_selectedBet * _currentMultiplier),
                              'mult': '${_currentMultiplier}x',
                            }),
                            color: AppColors.brutalGreen,
                            textColor: Colors.black,
                          ),
                        ] else if (_isBust) ...[
                          NeoBrutalBadge(
                            label: context.tr('hilo_gear_bust_label'),
                            color: AppColors.brutalRed,
                            textColor: Colors.white,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (!_isPlaying) ...[
                    // Bet Selector
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
                      label: context.tr('hilo_btn_start'),
                      icon: Icons.play_arrow_rounded,
                      backgroundColor: const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 14,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: _startGame,
                    ),
                  ] else ...[
                    // Guessing Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            label: context.tr('hilo_btn_higher'),
                            icon: Icons.arrow_upward_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 12,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: _isGuessing ? null : () => _guess(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NeoBrutalButton(
                            label: context.tr('hilo_btn_lower'),
                            icon: Icons.arrow_downward_rounded,
                            backgroundColor: const Color(0xFFEF4444),
                            textColor: Colors.white,
                            fontSize: 12,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: _isGuessing ? null : () => _guess(false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_currentStreak > 0)
                      NeoBrutalButton(
                        label: context.tr('hilo_btn_cash_out', {'amount': _formatCurrency(_selectedBet * _currentMultiplier)}),
                        icon: Icons.check_circle_rounded,
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 13,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: _cashOut,
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

  Widget _buildCardBackAnimated() {
    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, _) {
        final val = _flipController.value;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.002)
            ..rotateY(val * math.pi * 2),
          child: Column(
            children: [
              Text(
                context.tr('hilo_next_gear'),
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white70),
              ),
              const SizedBox(height: 4),
              Container(
                width: 68,
                height: 96,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalYellow, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black54, offset: Offset(3, 3), blurRadius: 0),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.style_rounded, color: AppColors.brutalYellow, size: 28),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLargeCard(CasinoCard card, {required String label}) {
    final isRed = card.suit == 'hearts' || card.suit == 'diamonds';
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Container(
          width: 68,
          height: 96,
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 2.5),
            boxShadow: const [
              BoxShadow(color: Colors.black, offset: Offset(3, 3), blurRadius: 0),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.label,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                  color: isRed ? const Color(0xFFEF4444) : Colors.black,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                isRed ? Icons.favorite_rounded : Icons.spa_rounded,
                size: 20,
                color: isRed ? const Color(0xFFEF4444) : Colors.black,
              ),
            ],
          ),
        ),
      ],
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
