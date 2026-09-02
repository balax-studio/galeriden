import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Neo-Brutalist Thermal Receipt Card with jagged sawtooth perforated edges,
/// barcode simulation, monospaced tabular accounting lines, and optional stamp overlay.
class ThermalReceiptCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? receiptNumber;
  final String? dateText;
  final List<ReceiptLineItem> items;
  final String? totalLabel;
  final String? totalAmount;
  final Widget? stampOverlay;
  final Widget? bottomAction;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double toothSize;
  final EdgeInsetsGeometry contentPadding;

  const ThermalReceiptCard({
    super.key,
    required this.title,
    this.subtitle,
    this.receiptNumber,
    this.dateText,
    this.items = const [],
    this.totalLabel,
    this.totalAmount,
    this.stampOverlay,
    this.bottomAction,
    this.backgroundColor = const Color(0xFFFBFBFA),
    this.textColor = const Color(0xFF0F172A),
    this.borderColor = const Color(0xFF000000),
    this.toothSize = 8.0,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paperBg = isDark ? const Color(0xFF1E2330) : backgroundColor;
    final paperText = isDark ? const Color(0xFFE2E8F0) : textColor;
    final paperMuted = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.25),
            offset: const Offset(4, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipPath(
        clipper: _SawtoothReceiptClipper(toothSize: toothSize),
        child: Container(
          decoration: BoxDecoration(
            color: paperBg,
            border: Border.symmetric(
              vertical: BorderSide(color: borderColor, width: 2.2),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: contentPadding.add(EdgeInsets.symmetric(vertical: toothSize)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Receipt Header
                    Center(
                      child: Column(
                        children: [
                          Text(
                            title.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: paperText,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: paperMuted,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Receipt Info Meta Line
                    if (receiptNumber != null || dateText != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (receiptNumber != null)
                            Text(
                              'NO: $receiptNumber',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: paperMuted,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          if (dateText != null)
                            Text(
                              dateText!,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: paperMuted,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    _buildDashedLine(isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                    const SizedBox(height: 8),

                    // Line Items
                    for (final item in items) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                item.label,
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: item.isBold ? FontWeight.w900 : FontWeight.w700,
                                  color: item.textColor ?? paperText,
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              item.value,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: item.isBold ? FontWeight.w900 : FontWeight.w800,
                                color: item.textColor ?? paperText,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (items.isNotEmpty) const SizedBox(height: 6),
                    _buildDashedLine(borderColor),
                    const SizedBox(height: 8),

                    // Total Row
                    if (totalAmount != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (totalLabel ?? 'NET TOPLAM').toUpperCase(),
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: paperText,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          Text(
                            totalAmount!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark ? const Color(0xFF00E575) : const Color(0xFF047857),
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Barcode Illustration
                    Center(
                      child: CustomPaint(
                        size: const Size(180, 24),
                        painter: _BarcodePainter(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                        ),
                      ),
                    ),

                    if (bottomAction != null) ...[
                      const SizedBox(height: 14),
                      bottomAction!,
                    ],
                  ],
                ),
              ),

              // Optional Stamp Overlay
              if (stampOverlay != null)
                Positioned(
                  right: 18,
                  bottom: 24,
                  child: stampOverlay!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine(Color color) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(math.max(1, dashCount), (_) {
            return SizedBox(
              width: dashWidth,
              height: 1.5,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class ReceiptLineItem {
  final String label;
  final String value;
  final bool isBold;
  final Color? textColor;

  const ReceiptLineItem({
    required this.label,
    required this.value,
    this.isBold = false,
    this.textColor,
  });
}

class _SawtoothReceiptClipper extends CustomClipper<Path> {
  final double toothSize;

  _SawtoothReceiptClipper({required this.toothSize});

  @override
  Path getClip(Size size) {
    final path = Path();
    final step = toothSize * 2;
    final topCount = (size.width / step).ceil();

    // Top sawtooth edge
    path.moveTo(0, toothSize);
    for (int i = 0; i < topCount; i++) {
      final x1 = i * step + toothSize;
      final x2 = (i + 1) * step;
      path.lineTo(x1, 0);
      path.lineTo(math.min(x2, size.width), toothSize);
    }
    path.lineTo(size.width, toothSize);

    // Right edge
    path.lineTo(size.width, size.height - toothSize);

    // Bottom sawtooth edge (right to left)
    for (int i = topCount - 1; i >= 0; i--) {
      final x1 = i * step + toothSize;
      final x2 = i * step;
      path.lineTo(math.min(x1, size.width), size.height);
      path.lineTo(math.max(x2, 0), size.height - toothSize);
    }

    // Left edge
    path.lineTo(0, toothSize);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _SawtoothReceiptClipper oldClipper) =>
      oldClipper.toothSize != toothSize;
}

class _BarcodePainter extends CustomPainter {
  final Color color;

  _BarcodePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Deterministic bar pattern (varying widths)
    final pattern = [
      3.0, 1.5, 2.0, 4.0, 1.0, 2.5, 1.5, 3.5, 1.0, 2.0, 4.0, 1.5, 2.0, 3.0,
      1.0, 2.5, 3.5, 1.5, 2.0, 1.0, 4.0, 2.5, 1.5, 3.0, 1.0, 2.0, 3.5, 1.5
    ];

    double currentX = 0;
    for (int i = 0; i < pattern.length && currentX < size.width; i++) {
      final barWidth = pattern[i];
      if (i % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(currentX, 0, math.min(barWidth, size.width - currentX), size.height),
          paint,
        );
      }
      currentX += barWidth + 2.0;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter oldDelegate) =>
      oldDelegate.color != color;
}
