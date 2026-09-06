import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

/// Turkish Oto Galeri Windshield Price Sticker Widget
/// Rendered with an angled, high-contrast tape/sticker aesthetic with bold monetary value and tactile spring wobble physics on tap.
class WindshieldPriceSticker extends StatefulWidget {
  final String priceText;
  final String? subtitle;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double angle;
  final double fontSize;
  final bool isBargain;
  final bool isWobbly;

  const WindshieldPriceSticker({
    super.key,
    required this.priceText,
    this.subtitle,
    this.backgroundColor = const Color(0xFFFFDE59),
    this.textColor = const Color(0xFF0F172A),
    this.borderColor = const Color(0xFF000000),
    this.angle = -0.04,
    this.fontSize = 15.0,
    this.isBargain = false,
    this.isWobbly = false,
  });

  @override
  State<WindshieldPriceSticker> createState() => _WindshieldPriceStickerState();
}

class _WindshieldPriceStickerState extends State<WindshieldPriceSticker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _wobbleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _wobbleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 0.04)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: 0.04, end: -0.03)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 35),
      TweenSequenceItem(
          tween: Tween(begin: -0.03, end: 0.015)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 25),
      TweenSequenceItem(
          tween: Tween(begin: 0.015, end: 0.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 15),
    ]).animate(_controller);

    if (widget.isWobbly) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WindshieldPriceSticker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isWobbly && !oldWidget.isWobbly) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerTapKick() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _triggerTapKick,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _wobbleAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: widget.angle + _wobbleAnimation.value,
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: widget.borderColor, width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: widget.borderColor,
                  offset: const Offset(3.0, 3.0),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (widget.subtitle != null || widget.isBargain) ...[
                  Text(
                    (widget.subtitle ??
                            (widget.isBargain
                                ? context.tr('sticker_bargain_price')
                                : context.tr('sticker_sale_price')))
                        .toUpperCase(),
                    style: TextStyle(
                      color: widget.isBargain
                          ? const Color(0xFFB91C1C)
                          : widget.textColor.withValues(alpha: 0.8),
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
                Text(
                  widget.priceText,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: widget.fontSize,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
