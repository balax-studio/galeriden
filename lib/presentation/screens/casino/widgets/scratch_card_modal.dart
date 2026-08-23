import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/casino_game_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';

class ScratchCardModal extends ConsumerStatefulWidget {
  const ScratchCardModal({super.key});

  @override
  ConsumerState<ScratchCardModal> createState() => _ScratchCardModalState();
}

class _ScratchCardModalState extends ConsumerState<ScratchCardModal> with SingleTickerProviderStateMixin {
  double _selectedCost = 25000.0;
  bool _hasActiveCard = false;
  ScratchCardResult? _currentCard;
  final Set<int> _scratchedIndices = {};

  late AnimationController _shimmerController;

  final List<double> _quickCosts = [10000.0, 25000.0, 100000.0, 500000.0];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _buyCard() {
    final game = ref.read(gameProvider);
    if (game.balance < _selectedCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('casino_insufficient_balance')),
          backgroundColor: AppColors.brutalRed,
        ),
      );
      return;
    }

    final result = ref.read(gameProvider.notifier).buyAndScratchCard(cardCost: _selectedCost);
    if (result == null) return;

    HapticFeedback.heavyImpact();
    setState(() {
      _hasActiveCard = true;
      _currentCard = result;
      _scratchedIndices.clear();
    });
  }

  void _scratchSpot(int index) {
    if (!_hasActiveCard || _scratchedIndices.contains(index)) return;

    HapticFeedback.selectionClick();
    setState(() {
      _scratchedIndices.add(index);
    });

    if (_scratchedIndices.length == 9) {
      if (_currentCard != null && _currentCard!.isWin) {
        HapticFeedback.vibrate();
      } else {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _scratchAll() {
    if (!_hasActiveCard) return;
    HapticFeedback.heavyImpact();
    setState(() {
      _scratchedIndices.addAll(List.generate(9, (i) => i));
    });

    if (_currentCard != null && _currentCard!.isWin) {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = _scratchedIndices.length == 9;

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
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFEC4899),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                border: Border(bottom: BorderSide(color: Color(0xFF0F172A), width: 3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.tr('casino_scratch_title'),
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
                  // 3x3 Scratch Board with Golden/Silver Holographic Grid
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A0F1D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFEC4899), width: 2.5),
                      boxShadow: const [
                        BoxShadow(color: Colors.black, offset: Offset(4, 4), blurRadius: 0),
                      ],
                    ),
                    child: _hasActiveCard && _currentCard != null
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: 9,
                            itemBuilder: (context, index) {
                              final spot = _currentCard!.grid[index];
                              final isScratched = _scratchedIndices.contains(index);

                              return GestureDetector(
                                onTap: () => _scratchSpot(index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  decoration: BoxDecoration(
                                    color: isScratched ? const Color(0xFFFFFBEB) : const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isScratched ? const Color(0xFFFFDE59) : const Color(0xFF94A3B8),
                                      width: 2.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 0),
                                    ],
                                  ),
                                  child: isScratched
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _buildSymbolIcon(spot.symbol),
                                              const SizedBox(height: 3),
                                              Text(
                                                spot.symbol.toUpperCase(),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 9.5,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Center(
                                          child: AnimatedBuilder(
                                            animation: _shimmerController,
                                            builder: (context, _) {
                                              return Icon(
                                                Icons.stars_rounded,
                                                color: Color.lerp(
                                                  const Color(0xFF94A3B8),
                                                  AppColors.brutalYellow,
                                                  _shimmerController.value,
                                                ),
                                                size: 28,
                                              );
                                            },
                                          ),
                                        ),
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                context.tr('scratch_buy_card_prompt'),
                                style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 13),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 14),

                  if (_hasActiveCard && isComplete && _currentCard != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _currentCard!.isWin ? AppColors.brutalGreen : AppColors.brutalRed,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0F172A), width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _currentCard!.isWin ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                            color: _currentCard!.isWin ? Colors.black : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _currentCard!.isWin
                                  ? context.tr('casino_win_banner', {'amount': _formatCurrency(_currentCard!.payoutAmount)})
                                  : context.tr('casino_loss_banner'),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                color: _currentCard!.isWin ? Colors.black : Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (!_hasActiveCard || isComplete) ...[
                    // Cost Selector
                    Text(
                      context.tr('casino_bet_amount_label'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _quickCosts.map((cost) {
                          final isSel = _selectedCost == cost;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => _selectedCost = cost);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                                ),
                                child: Text(
                                  _formatCurrency(cost),
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
                      label: context.tr('scratch_btn_buy_card', {'cost': _formatCurrency(_selectedCost)}),
                      icon: Icons.shopping_cart_rounded,
                      backgroundColor: const Color(0xFFEC4899),
                      textColor: Colors.white,
                      fontSize: 14,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      onPressed: _buyCard,
                    ),
                  ] else ...[
                    // Scratch All helper
                    NeoBrutalButton(
                      label: context.tr('scratch_btn_reveal_all'),
                      icon: Icons.auto_fix_high_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 13,
                      fullWidth: true,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onPressed: _scratchAll,
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

  Widget _buildSymbolIcon(String symbol) {
    switch (symbol) {
      case 'diamond':
        return const Icon(Icons.diamond_rounded, color: Color(0xFF38BDF8), size: 26);
      case 'seven':
        return const Icon(Icons.filter_7_rounded, color: Color(0xFFEF4444), size: 26);
      case 'crown':
        return const Icon(Icons.military_tech_rounded, color: Color(0xFFFFDE59), size: 26);
      case 'bell':
        return const Icon(Icons.notifications_active_rounded, color: Color(0xFFFF7A00), size: 26);
      case 'coin':
        return const Icon(Icons.monetization_on_rounded, color: Color(0xFF00E575), size: 26);
      case 'bar':
      default:
        return const Icon(Icons.view_headline_rounded, color: Color(0xFFA855F7), size: 26);
    }
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
