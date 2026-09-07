import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Neo-Brutalist Tear-Off Receipt / Contract Card.
/// Simulates a physical printed paper receipt or official notary document with
/// saw-tooth serrated edges, perforated fold lines, and industrial barcode styling.
class NeoBrutalReceiptCard extends StatelessWidget {
  final Widget child;
  final String? receiptTitle;
  final String? serialNumber;
  final bool showBarcode;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Offset shadowOffset;

  const NeoBrutalReceiptCard({
    super.key,
    required this.child,
    this.receiptTitle,
    this.serialNumber,
    this.showBarcode = true,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.5,
    this.shadowOffset = const Offset(4.0, 4.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? const Color(0xFF141721) : const Color(0xFFFCFBF8));
    final border = borderColor ??
        (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A));
    final shadow = isDark ? Colors.black : const Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: shadow,
            offset: shadowOffset,
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10 - borderWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Receipt Header Bar
            if (receiptTitle != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C2230)
                      : const Color(0xFFE2E8F0),
                  border: Border(
                    bottom: BorderSide(color: border, width: borderWidth),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            size: 16, color: AppColors.brutalYellow),
                        const SizedBox(width: 6),
                        Text(
                          receiptTitle!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    if (serialNumber != null)
                      Text(
                        serialNumber!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            // Content Body
            Padding(
              padding: padding,
              child: child,
            ),

            // Perforated Cut Line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: List.generate(
                  25,
                  (index) => Expanded(
                    child: Container(
                      height: 1.5,
                      color: index.isEven
                          ? (isDark
                              ? Colors.white24
                              : Colors.black.withValues(alpha: 0.25))
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Barcode & Footer Strip
            if (showBarcode) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Visual Mock Barcode
                    Row(
                      children: [
                        _buildBar(3, 24, isDark),
                        _buildBar(1, 24, isDark),
                        _buildBar(4, 24, isDark),
                        _buildBar(2, 24, isDark),
                        _buildBar(1, 24, isDark),
                        _buildBar(5, 24, isDark),
                        _buildBar(2, 24, isDark),
                        _buildBar(4, 24, isDark),
                        _buildBar(1, 24, isDark),
                        _buildBar(3, 24, isDark),
                        _buildBar(2, 24, isDark),
                        _buildBar(4, 24, isDark),
                      ],
                    ),
                    Text(
                      serialNumber ?? '• GLR-RESMI-BELGE •',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBar(double width, double height, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      width: width,
      height: height,
      color: isDark ? Colors.white54 : Colors.black87,
    );
  }
}
