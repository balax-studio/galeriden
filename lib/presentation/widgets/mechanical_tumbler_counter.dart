import 'package:flutter/material.dart';

/// Neo-Brutalist Mechanical Tumbler Counter
/// Simulates physical split-flap odometer / mechanical tally drums with horizontal
/// split-seam crease, dark border, and high-contrast numbers.
class MechanicalTumblerCounter extends StatelessWidget {
  final String valueText;
  final String? label;
  final Color cardBackgroundColor;
  final Color digitColor;
  final Color borderColor;
  final double digitFontSize;
  final double cellPadding;

  const MechanicalTumblerCounter({
    super.key,
    required this.valueText,
    this.label,
    this.cardBackgroundColor = const Color(0xFF0F172A),
    this.digitColor = const Color(0xFFFFDE59),
    this.borderColor = const Color(0xFF000000),
    this.digitFontSize = 18.0,
    this.cellPadding = 5.0,
  });

  @override
  Widget build(BuildContext context) {
    final characters = valueText.split('');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 3),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < characters.length; i++) ...[
                _buildDigitCell(characters[i]),
                if (i < characters.length - 1 && characters[i] != ' ' && characters[i + 1] != ' ')
                  const SizedBox(width: 2.5),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDigitCell(String char) {
    if (char == ' ') {
      return const SizedBox(width: 6);
    }
    if (char == '.' || char == ',' || char == '₺' || char == '\$' || char == '€' || char == 'K' || char == 'M') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          char,
          style: TextStyle(
            fontSize: digitFontSize * 0.9,
            fontWeight: FontWeight.w900,
            color: digitColor,
            fontFamily: 'monospace',
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: cellPadding + 1, vertical: cellPadding),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(1.5, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Middle Horizontal Split-Flap Seam
          Positioned(
            left: 0,
            right: 0,
            top: (digitFontSize * 1.3) / 2,
            child: Container(
              height: 1.0,
              color: Colors.black.withValues(alpha: 0.7),
            ),
          ),

          // Digit Character
          Text(
            char,
            style: TextStyle(
              fontSize: digitFontSize,
              fontWeight: FontWeight.w900,
              color: digitColor,
              letterSpacing: 0.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
