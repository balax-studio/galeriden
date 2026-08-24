import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/casino_game_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';

class SanayiBarbutuModal extends ConsumerStatefulWidget {
  const SanayiBarbutuModal({super.key});

  @override
  ConsumerState<SanayiBarbutuModal> createState() => _SanayiBarbutuModalState();
}

class _SanayiBarbutuModalState extends ConsumerState<SanayiBarbutuModal>
    with TickerProviderStateMixin {
  double _selectedBet = 50000.0;
  CarModel? _selectedWagerCar;
  BarbutBetChoice _selectedChoice = BarbutBetChoice.duses;

  bool _isRolling = false;
  BarbutResult? _lastResult;

  int _displayDie1 = 6;
  int _displayDie2 = 6;

  late AnimationController _cupShakeController;
  late AnimationController _diceRollController;
  late AnimationController _stampController;
  late AnimationController _idleBreathingController;

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

    _cupShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _diceRollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _stampController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _idleBreathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cupShakeController.dispose();
    _diceRollController.dispose();
    _stampController.dispose();
    _idleBreathingController.dispose();
    super.dispose();
  }

  void _rollDice() async {
    if (_isRolling) return;
    final game = ref.read(gameProvider);

    if (_selectedWagerCar == null && game.balance < _selectedBet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('insufficient_balance')),
          backgroundColor: AppColors.brutalRed,
        ),
      );
      return;
    }

    setState(() {
      _isRolling = true;
      _lastResult = null;
    });

    // 1. Shake the leather cup with haptic vibration
    HapticFeedback.mediumImpact();
    await _cupShakeController.forward(from: 0);

    // 2. Compute barbut dice result and update state
    final result = ref.read(gameProvider.notifier).playCasinoSanayiBarbutu(
          betAmount: _selectedBet,
          choice: _selectedChoice,
          wageredCar: _selectedWagerCar,
        );

    if (result == null) {
      setState(() => _isRolling = false);
      return;
    }

    // 3. Roll dice onto the oily table
    _diceRollController.reset();
    _diceRollController.forward();

    // Randomize face flashing during flight
    for (int i = 0; i < 7; i++) {
      await Future.delayed(const Duration(milliseconds: 90));
      if (!mounted) return;
      setState(() {
        _displayDie1 = math.Random().nextInt(6) + 1;
        _displayDie2 = math.Random().nextInt(6) + 1;
      });
      HapticFeedback.selectionClick();
    }

    if (!mounted) return;
    setState(() {
      _displayDie1 = result.die1;
      _displayDie2 = result.die2;
      _lastResult = result;
      _isRolling = false;
    });

    if (result.isWin) {
      _stampController.forward(from: 0);
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.vibrate();
    }
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
              // Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFFF7A00),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                  border: Border(
                      bottom: BorderSide(color: Color(0xFF0F172A), width: 2.5)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.casino_rounded,
                          size: 20, color: Color(0xFFFF7A00)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('casino_barbut_title'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            context.tr('casino_barbut_subtitle'),
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
                      icon:
                          const Icon(Icons.close_rounded, color: Colors.black),
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
                    // Industrial Table Felt & Cup Arena (RepaintBoundary isolated for 60 FPS dice physics)
                    RepaintBoundary(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1913),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF0F172A), width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF0F172A),
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Table Felt Markings
                            Positioned(
                              top: 8,
                              left: 12,
                              child: Text(
                                context.tr('barbut_table_felt_label'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brutalGreen
                                      .withValues(alpha: 0.4),
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),

                            // Leather Shaking Cup and Rolling Dice
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Leather Dice Cup
                                AnimatedBuilder(
                                  animation: _cupShakeController,
                                  builder: (context, child) {
                                    final shakeVal = math.sin(
                                            _cupShakeController.value *
                                                math.pi *
                                                8) *
                                        12.0;
                                    final tiltVal = math.sin(
                                            _cupShakeController.value *
                                                math.pi *
                                                4) *
                                        0.2;
                                    return Transform.translate(
                                      offset: Offset(shakeVal, 0),
                                      child: Transform.rotate(
                                        angle: tiltVal,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 60,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5C3317),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                        bottom: Radius.circular(18),
                                      ),
                                      border: Border.all(
                                          color: const Color(0xFF0F172A),
                                          width: 2.5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black45,
                                          offset: Offset(0, 4),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 44,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDE59),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Two Tumbling Dice
                                AnimatedBuilder(
                                  animation: _diceRollController,
                                  builder: (context, child) {
                                    final rollVal = _diceRollController.value;
                                    final rot1 = _isRolling
                                        ? (rollVal * math.pi * 4)
                                        : 0.0;
                                    final rot2 = _isRolling
                                        ? -(rollVal * math.pi * 4)
                                        : 0.0;
                                    final bounce = _isRolling
                                        ? math.sin(rollVal * math.pi) * 20.0
                                        : 0.0;

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Transform.translate(
                                          offset: Offset(0, -bounce),
                                          child: Transform.rotate(
                                            angle: rot1,
                                            child:
                                                _buildDieWidget(_displayDie1),
                                          ),
                                        ),
                                        const SizedBox(width: 24),
                                        Transform.translate(
                                          offset: Offset(0, -bounce),
                                          child: Transform.rotate(
                                            angle: rot2,
                                            child:
                                                _buildDieWidget(_displayDie2),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),

                            // Stamp Banner on Win / Loss
                            if (_lastResult != null)
                              Positioned(
                                bottom: 10,
                                child: ScaleTransition(
                                  scale: CurvedAnimation(
                                    parent: _stampController,
                                    curve: Curves.elasticOut,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: _lastResult!.isWin
                                          ? AppColors.brutalGreen
                                          : AppColors.brutalRed,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.black, width: 2),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black54,
                                          offset: Offset(2, 2),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _lastResult!.isWin
                                          ? context.tr('barbut_stamp_win', {
                                              'combo': _lastResult!.comboName,
                                              'amount': _formatCurrency(
                                                  _lastResult!.payoutAmount),
                                            })
                                          : context.tr('barbut_stamp_loss', {
                                              'combo': _lastResult!.comboName,
                                            }),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                        color: _lastResult!.isWin
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bet Choice Grid (Düşeş • 5x, Çiftler • 2.5x, Barbut • 2x, Yüksek • 2x)
                    Text(
                      context.tr('barbut_choose_bet_mode'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildChoiceCard(
                          title: context.tr('barbut_choice_duses'),
                          mult: '5.0x',
                          choice: BarbutBetChoice.duses,
                          color: const Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 6),
                        _buildChoiceCard(
                          title: context.tr('barbut_choice_ciftler'),
                          mult: '2.5x',
                          choice: BarbutBetChoice.ciftler,
                          color: const Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 6),
                        _buildChoiceCard(
                          title: context.tr('barbut_choice_barbut'),
                          mult: '2.0x',
                          choice: BarbutBetChoice.barbut,
                          color: const Color(0xFF00E575),
                        ),
                        const SizedBox(width: 6),
                        _buildChoiceCard(
                          title: context.tr('barbut_choice_high_roll'),
                          mult: '2.0x',
                          choice: BarbutBetChoice.highRoll,
                          color: const Color(0xFFA855F7),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Wager Type Selector: Cash vs Pink Slip
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedWagerCar = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedWagerCar == null
                                    ? AppColors.brutalYellow
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF0F172A), width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                context.tr('wager_type_cash'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: _selectedWagerCar == null
                                      ? Colors.black
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (ownedCars.isNotEmpty) {
                                setState(
                                    () => _selectedWagerCar = ownedCars.first);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(context.tr('no_cars_for_wager')),
                                    backgroundColor: AppColors.brutalRed,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _selectedWagerCar != null
                                    ? const Color(0xFFFF7A00)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: const Color(0xFF0F172A), width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                context.tr('wager_type_pink_slip'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  color: _selectedWagerCar != null
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    if (_selectedWagerCar == null) ...[
                      // Quick Bet Pills
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _quickBets.map((bet) {
                          final isSelected = _selectedBet == bet;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedBet = bet),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFF7A00)
                                    : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : (isDark
                                          ? Colors.white24
                                          : Colors.black26),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                _formatCurrency(bet),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: isSelected
                                      ? Colors.black
                                      : (isDark ? Colors.white : Colors.black),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      // Car Selection Banner
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFFF7A00), width: 2),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_car_rounded,
                                color: Color(0xFFFF7A00), size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_selectedWagerCar!.brand} ${_selectedWagerCar!.modelName} • ${_formatCurrency(_selectedWagerCar!.price)}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Roll Dice Action Button
                    NeoBrutalButton(
                      label: _isRolling
                          ? context.tr('barbut_btn_shaking')
                          : context.tr('barbut_btn_roll'),
                      backgroundColor: const Color(0xFFFF7A00),
                      textColor: Colors.black,
                      minHeight: 50,
                      fullWidth: true,
                      onPressed: _isRolling ? null : _rollDice,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String mult,
    required BarbutBetChoice choice,
    required Color color,
  }) {
    final isSelected = _selectedChoice == choice;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedChoice = choice),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.black : const Color(0xFF64748B),
              width: isSelected ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mult,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDieWidget(int value) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF0F172A), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF0F172A),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: _buildPips(value),
    );
  }

  Widget _buildPips(int value) {
    Widget pip() => Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            shape: BoxShape.circle,
          ),
        );

    switch (value) {
      case 1:
        return Center(child: pip());
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topLeft, child: pip()),
            Align(alignment: Alignment.bottomRight, child: pip()),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topLeft, child: pip()),
            Center(child: pip()),
            Align(alignment: Alignment.bottomRight, child: pip()),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
            Center(child: pip()),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
          ],
        );
      case 6:
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [pip(), pip()]),
          ],
        );
    }
  }
}
