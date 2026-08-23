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

class ValetBaccaratModal extends ConsumerStatefulWidget {
  const ValetBaccaratModal({super.key});

  @override
  ConsumerState<ValetBaccaratModal> createState() => _ValetBaccaratModalState();
}

class _ValetBaccaratModalState extends ConsumerState<ValetBaccaratModal> with TickerProviderStateMixin {
  double _selectedBet = 50000.0;
  CarModel? _selectedWagerCar;
  bool _isDealing = false;
  BaccaratResult? _lastResult;

  late AnimationController _dealController;
  late AnimationController _idleController;

  final List<double> _quickBets = [25000.0, 50000.0, 150000.0, 500000.0, 1000000.0];

  @override
  void initState() {
    super.initState();
    _dealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _dealController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  void _play(BaccaratBetChoice choice) {
    if (_isDealing) return;
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

    setState(() {
      _isDealing = true;
      _lastResult = null;
    });

    HapticFeedback.heavyImpact();
    _dealController.forward(from: 0.0);

    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      final result = ref.read(gameProvider.notifier).playCasinoBaccarat(
            betAmount: _selectedBet,
            choice: choice,
            wageredCar: _selectedWagerCar,
          );

      setState(() {
        _isDealing = false;
        _lastResult = result;
        _selectedWagerCar = null;
      });

      if (result != null && result.isWin) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.mediumImpact();
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
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF38BDF8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.style_rounded, color: Colors.black, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_baccarat_title'),
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
                  // Table felt
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF064E3B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF0F172A), width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Hands display
                        Row(
                          children: [
                            // Player Side
                            Expanded(
                              child: _buildHandBox(
                                title: context.tr('baccarat_player_label'),
                                score: _lastResult?.playerTotal,
                                cards: _lastResult?.playerCards,
                                isDealing: _isDealing,
                                isWinner: _lastResult?.winningChoice == BaccaratBetChoice.player,
                                color: const Color(0xFF38BDF8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Banker Side
                            Expanded(
                              child: _buildHandBox(
                                title: context.tr('baccarat_banker_label'),
                                score: _lastResult?.bankerTotal,
                                cards: _lastResult?.bankerCards,
                                isDealing: _isDealing,
                                isWinner: _lastResult?.winningChoice == BaccaratBetChoice.banker,
                                color: const Color(0xFFFF7A00),
                              ),
                            ),
                          ],
                        ),

                        if (_lastResult != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _lastResult!.isWin ? AppColors.brutalGreen : AppColors.brutalRed,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF0F172A), width: 2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _lastResult!.isWin ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                                  color: _lastResult!.isWin ? Colors.black : Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _lastResult!.isWin
                                        ? context.tr('casino_win_banner', {'amount': _formatCurrency(_lastResult!.payoutAmount)})
                                        : context.tr('casino_loss_banner'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: _lastResult!.isWin ? Colors.black : Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_lastResult!.wonCar != null) ...[
                            const SizedBox(height: 8),
                            NeoBrutalBadge(
                              label: context.tr('baccarat_trophy_car_won', {'model': _lastResult!.wonCar!.modelName}),
                              color: AppColors.brutalYellow,
                              textColor: Colors.black,
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Pink Slip / Vehicle Wager Picker
                  if (ownedCars.isNotEmpty) ...[
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

                  // Cash Bet Selector
                  if (_selectedWagerCar == null) ...[
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

                  // 3 Betting Choice Buttons
                  Text(
                    context.tr('baccarat_choose_side_label'),
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('baccarat_btn_player'),
                          backgroundColor: const Color(0xFF38BDF8),
                          textColor: Colors.black,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: _isDealing ? null : () => _play(BaccaratBetChoice.player),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('baccarat_btn_tie'),
                          backgroundColor: AppColors.brutalGreen,
                          textColor: Colors.black,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: _isDealing ? null : () => _play(BaccaratBetChoice.tie),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('baccarat_btn_banker'),
                          backgroundColor: const Color(0xFFFF7A00),
                          textColor: Colors.black,
                          fontSize: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onPressed: _isDealing ? null : () => _play(BaccaratBetChoice.banker),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandBox({
    required String title,
    int? score,
    List<CasinoCard>? cards,
    required bool isDealing,
    required bool isWinner,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isWinner ? AppColors.brutalYellow : color,
          width: isWinner ? 3.0 : 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: color),
              ),
              if (score != null && !isDealing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$score',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: isDealing
                ? AnimatedBuilder(
                    animation: _dealController,
                    builder: (context, _) {
                      final val = _dealController.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(val * math.pi * 2),
                            child: _buildCardBack(),
                          ),
                          const SizedBox(width: 4),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.002)
                              ..rotateY(val * math.pi * 2.5),
                            child: _buildCardBack(),
                          ),
                        ],
                      );
                    },
                  )
                : (cards != null && cards.isNotEmpty)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: cards.map((c) => _buildCardView(c)).toList(),
                      )
                    : const Center(
                        child: Text(
                          '-- --',
                          style: TextStyle(color: Colors.white38, fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      width: 36,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.brutalYellow, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.style_rounded, size: 16, color: AppColors.brutalYellow),
      ),
    );
  }

  Widget _buildCardView(CasinoCard card) {
    final isRed = card.suit == 'hearts' || card.suit == 'diamonds';
    return Container(
      width: 36,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: isRed ? const Color(0xFFEF4444) : Colors.black,
              height: 1.0,
            ),
          ),
          Icon(
            isRed ? Icons.favorite_rounded : Icons.spa_rounded,
            size: 12,
            color: isRed ? const Color(0xFFEF4444) : Colors.black,
          ),
        ],
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
