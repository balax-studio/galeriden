import '../../../core/localization/app_localizations.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';
import 'neo_brutal_poly_painter.dart';

class HandshakeStampModal extends StatefulWidget {
  final String sellerName;
  final String carModel;
  final double agreedPrice;
  final VoidCallback onConfirmed;

  const HandshakeStampModal({
    super.key,
    required this.sellerName,
    required this.carModel,
    required this.agreedPrice,
    required this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required String sellerName,
    required String carModel,
    required double agreedPrice,
    required VoidCallback onConfirmed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => HandshakeStampModal(
        sellerName: sellerName,
        carModel: carModel,
        agreedPrice: agreedPrice,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<HandshakeStampModal> createState() => _HandshakeStampModalState();
}

class _HandshakeStampModalState extends State<HandshakeStampModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _hasStamped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )
      ..addListener(() {
        if (_controller.value > 0.65 && !_hasStamped) {
          _hasStamped = true;
          HapticFeedback.heavyImpact();
        }
        setState(() {});
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: const Color(0xFF0F131E),
        borderColor: const Color(0xFFFFDE59),
        borderWidth: 2.8,
        borderRadius: 16,
        showHazardHeader: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handshake_rounded,
                        color: Color(0xFFFFDE59), size: 24),
                    const SizedBox(width: 8),
                    Text(
                      context.tr('handshake_title'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: context.tr('handshake_badge_deal'),
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Deal Info Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF182030),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2B3852), width: 1.8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('handshake_seller_label',
                            {'seller': widget.sellerName}),
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        widget.carModel,
                        style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(widget.agreedPrice),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalGreen),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2D Handshake & Notary Stamp Canvas
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF090C14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF222C42), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomPaint(
                  painter: _HandshakePainter(
                    progress: _controller.value,
                    hasStamped: _hasStamped,
                    notaryStampText: context.tr('handshake_notary_stamp'),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: NeoBrutalButton(
                label: context.tr('handshake_btn_pay'),
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 12,
                onPressed: () {
                  Navigator.pop(context);
                  widget.onConfirmed();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HandshakePainter extends CustomPainter {
  final double progress;
  final bool hasStamped;
  final String notaryStampText;

  _HandshakePainter({
    required this.progress,
    required this.hasStamped,
    required this.notaryStampText,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Technical CRT Grid
    NeoBrutalPolyPainter.drawCRTGrid(
      canvas,
      size,
      gridColor: const Color(0xFF161E2E),
      spacing: 16.0,
      drawCrosshair: true,
    );

    // Hazard Safety Striping at Top
    NeoBrutalPolyPainter.drawHazardStripes(
      canvas,
      Rect.fromLTWH(8, 6, w - 16, 8),
      stripeWidth: 6,
      borderWidth: 1.0,
    );

    // 2. Faceted Handshake Animation
    final handProgress = progress.clamp(0.0, 0.65) / 0.65;
    final shakeOffset =
        (progress > 0.65) ? math.sin(progress * math.pi * 12) * 5.0 : 0.0;

    final leftHandX = -50 + handProgress * (w * 0.45);
    final rightHandX = w + 50 - handProgress * (w * 0.45);
    final handY = h * 0.50 + shakeOffset;

    // Draw Left Low-Poly Hand & Sleeve (Buyer / Dealer)
    _drawLowPolyHand(canvas, Offset(leftHandX, handY), true, AppColors.brutalYellow);

    // Draw Right Low-Poly Hand & Sleeve (Seller)
    _drawLowPolyHand(canvas, Offset(rightHandX, handY), false, const Color(0xFF38BDF8));

    // 3. Octagonal Notary Brass Stamp Slam
    if (progress > 0.65) {
      final stampProgress = ((progress - 0.65) / 0.35).clamp(0.0, 1.0);
      final stampScale = 2.0 - stampProgress * 1.0;
      final stampAlpha = stampProgress;

      canvas.save();
      canvas.translate(w * 0.50, h * 0.50);
      canvas.scale(stampScale);
      canvas.rotate(-0.09);

      // Octagonal Stamp Border
      final numSides = 8;
      final stampRadius = 48.0;
      final stampVertices = <Offset>[];
      for (int i = 0; i < numSides; i++) {
        final a = (i * 2 * math.pi / numSides) + (math.pi / 8);
        stampVertices.add(Offset(
          stampRadius * math.cos(a),
          stampRadius * 0.65 * math.sin(a),
        ));
      }

      NeoBrutalPolyPainter.drawFacetedPolygon(
        canvas,
        stampVertices,
        color: AppColors.errorRed.withValues(alpha: stampAlpha * 0.25),
        lightFactor: 1.1,
        strokeWidth: 3.0,
        strokeColor: AppColors.errorRed.withValues(alpha: stampAlpha),
      );

      // 3D Hex Bolt rivets on stamp corners
      NeoBrutalPolyPainter.draw3DHexBolt(
        canvas,
        const Offset(-38, 0),
        4.0,
        baseColor: AppColors.errorRed.withValues(alpha: stampAlpha),
        isLoosened: false,
      );
      NeoBrutalPolyPainter.draw3DHexBolt(
        canvas,
        const Offset(38, 0),
        4.0,
        baseColor: AppColors.errorRed.withValues(alpha: stampAlpha),
        isLoosened: false,
      );

      // Prismatic Diamond Ink Splatters
      if (hasStamped) {
        NeoBrutalPolyPainter.drawPrismaticDiamond(
          canvas,
          const Offset(-46, -18),
          6.0,
          AppColors.errorRed,
        );
        NeoBrutalPolyPainter.drawPrismaticDiamond(
          canvas,
          const Offset(48, 16),
          8.0,
          AppColors.errorRed,
        );
        NeoBrutalPolyPainter.drawPrismaticDiamond(
          canvas,
          const Offset(0, -26),
          5.0,
          AppColors.brutalYellow,
        );
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: notaryStampText,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.errorRed.withValues(alpha: stampAlpha),
            letterSpacing: 0.8,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  void _drawLowPolyHand(Canvas canvas, Offset center, bool isLeft, Color skinColor) {
    final sign = isLeft ? 1.0 : -1.0;

    // Sleeve Casing
    final sleeveVertices = [
      Offset(center.dx - sign * 50, center.dy - 18),
      Offset(center.dx - sign * 15, center.dy - 16),
      Offset(center.dx - sign * 15, center.dy + 16),
      Offset(center.dx - sign * 50, center.dy + 18),
    ];
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      sleeveVertices,
      color: const Color(0xFF1E293B),
      lightFactor: 1.0,
      strokeWidth: 2.2,
    );

    // Faceted Palm & Fingers
    final handVertices = [
      Offset(center.dx - sign * 15, center.dy - 14),
      Offset(center.dx + sign * 15, center.dy - 10),
      Offset(center.dx + sign * 20, center.dy),
      Offset(center.dx + sign * 15, center.dy + 12),
      Offset(center.dx - sign * 15, center.dy + 14),
    ];
    NeoBrutalPolyPainter.drawFacetedPolygon(
      canvas,
      handVertices,
      color: skinColor,
      lightFactor: 1.1,
      strokeWidth: 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant _HandshakePainter oldDelegate) => true;
}
