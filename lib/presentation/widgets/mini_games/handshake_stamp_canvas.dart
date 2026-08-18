import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

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
    )..addListener(() {
        if (_controller.value > 0.65 && !_hasStamped) {
          _hasStamped = true;
          HapticFeedback.heavyImpact();
        }
        setState(() {});
      })..forward();
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
                  children: const [
                    Icon(Icons.handshake_rounded, color: Color(0xFFFFDE59), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'PAZARLIK BİTTİ & EL SIKIŞILDI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const NeoBrutalBadge(
                  text: 'HAYIRLI OLSUN',
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
                        'Satıcı: ${widget.sellerName}',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                      ),
                      Text(
                        widget.carModel,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                  Text(
                    CurrencyFormatter.format(widget.agreedPrice),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
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
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: NeoBrutalButton(
                label: 'RUHSATI TESLİM AL & PARAYI ÖDE',
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

  _HandshakePainter({
    required this.progress,
    required this.hasStamped,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF161E2E)
      ..strokeWidth = 1.0;
    for (double x = 0; x < w; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), gridPaint);
    }

    // Handshake animation: Left hand comes from left, right hand from right
    final handProgress = progress.clamp(0.0, 0.65) / 0.65;
    final shakeOffset = (progress > 0.65) ? math.sin(progress * math.pi * 12) * 5.0 : 0.0;

    final leftHandX = -50 + handProgress * (w * 0.45);
    final rightHandX = w + 50 - handProgress * (w * 0.45);
    final handY = h * 0.50 + shakeOffset;

    // Draw Left Hand (Alıcı / Galerici)
    final leftHandPaint = Paint()..color = const Color(0xFFFFDE59);
    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(leftHandX, handY - 15, 60, 30), const Radius.circular(8)), leftHandPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(leftHandX, handY - 15, 60, 30), const Radius.circular(8)), borderPaint);

    // Draw Right Hand (Satıcı)
    final rightHandPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rightHandX - 60, handY - 15, 60, 30), const Radius.circular(8)), rightHandPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rightHandX - 60, handY - 15, 60, 30), const Radius.circular(8)), borderPaint);

    // Big Red Notary Stamp Slam (after progress > 0.65)
    if (progress > 0.65) {
      final stampProgress = ((progress - 0.65) / 0.35).clamp(0.0, 1.0);
      final stampScale = 2.0 - stampProgress * 1.0;
      final stampAlpha = stampProgress;

      canvas.save();
      canvas.translate(w * 0.50, h * 0.50);
      canvas.scale(stampScale);
      canvas.rotate(-0.12);

      final stampRect = Rect.fromCenter(center: Offset.zero, width: 140, height: 44);
      final stampFill = Paint()..color = AppColors.errorRed.withValues(alpha: stampAlpha * 0.2);
      final stampBorder = Paint()
        ..color = AppColors.errorRed.withValues(alpha: stampAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawRRect(RRect.fromRectAndRadius(stampRect, const Radius.circular(6)), stampFill);
      canvas.drawRRect(RRect.fromRectAndRadius(stampRect, const Radius.circular(6)), stampBorder);

      final textPainter = TextPainter(
        text: TextSpan(
          text: 'T.C. NOTERİ\nDEVİR ONAYLANDI',
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

      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _HandshakePainter oldDelegate) => true;
}
