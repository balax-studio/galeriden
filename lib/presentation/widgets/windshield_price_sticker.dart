import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';

/// Turkish Oto Galeri Windshield Price Sticker Widget
/// Rendered with an angled, high-contrast tape/sticker aesthetic with bold monetary value and label.
class WindshieldPriceSticker extends StatelessWidget {
  final String priceText;
  final String? subtitle;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double angle;
  final double fontSize;
  final bool isBargain;

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
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor, width: 2.2),
          boxShadow: [
            BoxShadow(
              color: borderColor,
              offset: const Offset(3.0, 3.0),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (subtitle != null || isBargain) ...[
              Text(
                (subtitle ?? (isBargain ? context.tr('sticker_bargain_price') : context.tr('sticker_sale_price'))).toUpperCase(),
                style: TextStyle(
                  color: isBargain ? const Color(0xFFB91C1C) : textColor.withValues(alpha: 0.8),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 1),
            ],
            Text(
              priceText,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
