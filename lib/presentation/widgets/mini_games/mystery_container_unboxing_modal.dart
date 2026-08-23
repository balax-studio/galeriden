import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/black_market_container_engine.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import '../app_vector_icons.dart';

enum _UnboxingStage {
  sealed,
  opening,
  revealed,
}

class MysteryContainerUnboxingModal extends StatefulWidget {
  final MysteryContainerResult result;
  final VoidCallback onClaim;

  const MysteryContainerUnboxingModal({
    super.key,
    required this.result,
    required this.onClaim,
  });

  static Future<void> show(
    BuildContext context, {
    required MysteryContainerResult result,
    required VoidCallback onClaim,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'ContainerUnboxing',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (ctx, anim1, anim2) => MysteryContainerUnboxingModal(
        result: result,
        onClaim: onClaim,
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack).value,
          child: child,
        );
      },
    );
  }

  @override
  State<MysteryContainerUnboxingModal> createState() => _MysteryContainerUnboxingModalState();
}

class _MysteryContainerUnboxingModalState extends State<MysteryContainerUnboxingModal>
    with TickerProviderStateMixin {
  _UnboxingStage _stage = _UnboxingStage.sealed;

  late AnimationController _idlePulseController;
  late AnimationController _shakeController;
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _idlePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
  }

  @override
  void dispose() {
    _idlePulseController.dispose();
    _shakeController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _triggerBreakSeal() async {
    if (_stage != _UnboxingStage.sealed) return;

    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    setState(() {
      _stage = _UnboxingStage.opening;
    });

    // Escalating suspense haptic pulses
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted && _stage == _UnboxingStage.opening) {
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted && _stage == _UnboxingStage.opening) {
        try {
          HapticFeedback.heavyImpact();
        } catch (_) {}
      }
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _stage == _UnboxingStage.opening) {
        try {
          HapticFeedback.vibrate();
        } catch (_) {}
      }
    });

    await _shakeController.forward(from: 0.0);

    try {
      HapticFeedback.vibrate();
    } catch (_) {}

    _idlePulseController.stop();
    setState(() {
      _stage = _UnboxingStage.revealed;
    });

    _revealController.forward(from: 0.0);
  }

  Color _getRarityColor() {
    switch (widget.result.tier) {
      case MysteryContainerTier.standard:
        return const Color(0xFF38BDF8); // Sky / Cyan
      case MysteryContainerTier.rare:
        return const Color(0xFFF59E0B); // Amber / Gold
      case MysteryContainerTier.exotic:
        return const Color(0xFF10B981); // Emerald Green
      case MysteryContainerTier.legendaryHyper:
        return const Color(0xFFA855F7); // Purple / Violet
    }
  }

  String _getRarityBadgeText(BuildContext context) {
    switch (widget.result.tier) {
      case MysteryContainerTier.standard:
        return context.tr('bm_container_rate_standard');
      case MysteryContainerTier.rare:
        return context.tr('bm_container_rate_rare');
      case MysteryContainerTier.exotic:
        return context.tr('bm_container_rate_exotic');
      case MysteryContainerTier.legendaryHyper:
        return context.tr('bm_container_rate_legendary');
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top title & Port banner
              NeoBrutalCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                backgroundColor: const Color(0xFF0F172A),
                borderColor: rarityColor,
                borderRadius: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.anchor_rounded, color: AppColors.brutalYellow, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('bm_container_unboxing_title'),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Main Animation Area
              if (_stage == _UnboxingStage.sealed || _stage == _UnboxingStage.opening)
                _buildSealedContainerView(rarityColor)
              else
                _buildRevealedCarCard(context, rarityColor),

              const SizedBox(height: 16),

              // Action button area
              if (_stage == _UnboxingStage.sealed)
                NeoBrutalButton(
                  label: context.tr('bm_container_btn_break_seal'),
                  icon: Icons.flash_on_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 13,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  onPressed: _triggerBreakSeal,
                )
              else if (_stage == _UnboxingStage.opening)
                NeoBrutalCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  backgroundColor: const Color(0xFF1E293B),
                  borderColor: AppColors.brutalYellow,
                  borderRadius: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.brutalYellow),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('bm_container_unboxing_opening'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
                      ),
                    ],
                  ),
                )
              else
                NeoBrutalButton(
                  label: context.tr('bm_container_unboxing_claim'),
                  icon: Icons.directions_car_rounded,
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onClaim();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSealedContainerView(Color rarityColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_idlePulseController, _shakeController]),
      builder: (context, child) {
        final shakeVal = _shakeController.value;
        final isOpening = _stage == _UnboxingStage.opening;
        final frequency = isOpening ? (12.0 + shakeVal * 38.0) : 12.0;
        final amplitude = isOpening ? (3.0 + shakeVal * 13.0) : 0.0;
        final shakeOffset = isOpening
            ? math.sin(shakeVal * math.pi * frequency) * amplitude
            : 0.0;
        final pulseScale = 1.0 + (_idlePulseController.value * 0.03) + (isOpening ? (shakeVal * 0.05) : 0.0);

        return Transform.translate(
          offset: Offset(shakeOffset, 0),
          child: Transform.scale(
            scale: pulseScale,
            child: Container(
              width: 310,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF131826),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isOpening
                      ? (shakeVal > 0.7 ? rarityColor : AppColors.brutalYellow)
                      : const Color(0xFF0F172A),
                  width: isOpening ? (3.5 + shakeVal * 2.0) : 3.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.6),
                    offset: const Offset(6, 6),
                    blurRadius: 0,
                  ),
                  if (isOpening) ...[
                    BoxShadow(
                      color: rarityColor.withValues(alpha: 0.3 + (shakeVal * 0.6)),
                      blurRadius: 16.0 + (shakeVal * 32.0),
                      spreadRadius: 2.0 + (shakeVal * 8.0),
                    ),
                    BoxShadow(
                      color: AppColors.brutalYellow.withValues(alpha: 0.2 + (shakeVal * 0.4)),
                      blurRadius: 8.0 + (shakeVal * 16.0),
                      spreadRadius: 1.0 + (shakeVal * 3.0),
                    ),
                  ],
                ],
              ),
              child: Stack(
                children: [
                  // Hazard caution stripes banner
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 18,
                    child: CustomPaint(
                      painter: _HazardStripePainter(),
                    ),
                  ),

                  // Container corrugated body ribs
                  Positioned.fill(
                    top: 18,
                    bottom: 18,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        7,
                        (i) => Container(
                          width: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: const Color(0xFF0F172A), width: 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Central Heavy Padlock & Customs Seal
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _stage == _UnboxingStage.opening ? AppColors.brutalYellow : const Color(0xFF0F172A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 3.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        _stage == _UnboxingStage.opening ? Icons.lock_open_rounded : Icons.lock_rounded,
                        color: _stage == _UnboxingStage.opening ? Colors.black : AppColors.brutalYellow,
                        size: 40,
                      ),
                    ),
                  ),

                  // Shipping Serial Stamp
                  Positioned(
                    left: 12,
                    bottom: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        'SEVKİYAT #774-K',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Hazard Stripes
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 18,
                    child: CustomPaint(
                      painter: _HazardStripePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRevealedCarCard(BuildContext context, Color rarityColor) {
    final car = widget.result.car;

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        final animVal = CurvedAnimation(
          parent: _revealController,
          curve: Curves.elasticOut,
        ).value;

        return Transform.scale(
          scale: animVal.clamp(0.0, 1.0),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: const Color(0xFF0F172A),
            borderColor: rarityColor,
            borderRadius: 16,
            child: SizedBox(
              width: 320,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Rarity badge
                  NeoBrutalBadge(
                    text: _getRarityBadgeText(context),
                    backgroundColor: rarityColor,
                    textColor: Colors.black,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  ),
                  const SizedBox(height: 12),

                  // Car Icon Illustration
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      shape: BoxShape.circle,
                      border: Border.all(color: rarityColor, width: 2.5),
                    ),
                    child: Center(
                      child: VectorIconWidget(
                        type: 'rare',
                        size: 36,
                        color: rarityColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Car Year, Brand & Model
                  Text(
                    '${car.modelYear} ${car.brand}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    car.modelName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Color and Plate badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NeoBrutalBadge(
                        text: car.colorDisplayName,
                        backgroundColor: const Color(0xFF334155),
                        textColor: Colors.white,
                        fontSize: 9,
                      ),
                      const SizedBox(width: 6),
                      NeoBrutalBadge(
                        text: car.plateNumber,
                        backgroundColor: const Color(0xFF334155),
                        textColor: Colors.white,
                        fontSize: 9,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Valuation & Profit Breakdown Bento
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                context.tr('bm_container_valuation_label'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatShort(car.baseMarketValue),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ],
                        ),
                        const Divider(color: Color(0xFF334155), height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                context.tr('bm_container_cost_label'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatShort(BlackMarketContainerEngine.containerCost),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                context.tr('bm_container_roi_profit'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                              ),
                            ),
                            Text(
                              widget.result.profitMargin >= 0
                                  ? '+${CurrencyFormatter.formatShort(widget.result.profitMargin)}'
                                  : '-${CurrencyFormatter.formatShort(widget.result.profitMargin.abs())}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: widget.result.profitMargin >= 0 ? AppColors.brutalGreen : AppColors.errorRed,
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
          ),
        );
      },
    );
  }
}

class _HazardStripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final stripePaint = Paint()
      ..color = AppColors.brutalYellow
      ..style = PaintingStyle.fill;

    const stripeWidth = 12.0;
    const stripeSpacing = 20.0;

    final path = Path();
    for (double x = -size.height; x < size.width + size.height; x += stripeSpacing) {
      path.moveTo(x, size.height);
      path.lineTo(x + stripeWidth, size.height);
      path.lineTo(x + stripeWidth + size.height, 0);
      path.lineTo(x + size.height, 0);
      path.close();
    }

    canvas.drawPath(path, stripePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
