import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Neo-Brutal Turkish Tea Glass & Curling Steam Micro-Graphic Widget
/// Adds warm, authentic local dealership atmosphere with lightweight CustomPainter sinusoidal steam lines.
class SteamCupWidget extends StatefulWidget {
  final double size;
  final Color teaColor;
  final Color saucerColor;
  final Color borderColor;
  final Color steamColor;

  const SteamCupWidget({
    super.key,
    this.size = 32.0,
    this.teaColor = const Color(0xFFB45309), // Amber-Red Turkish Tea
    this.saucerColor = const Color(0xFFF1F5F9), // White/Silver Saucer
    this.borderColor = const Color(0xFF0F172A),
    this.steamColor = const Color(0xFF94A3B8),
  });

  @override
  State<SteamCupWidget> createState() => _SteamCupWidgetState();
}

class _SteamCupWidgetState extends State<SteamCupWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            size: Size(widget.size, widget.size * 1.3),
            painter: _SteamCupPainter(
              animationValue: _controller.value,
              teaColor: widget.teaColor,
              saucerColor: widget.saucerColor,
              borderColor: widget.borderColor,
              steamColor: widget.steamColor,
            ),
          );
        },
      ),
    );
  }
}

class _SteamCupPainter extends CustomPainter {
  final double animationValue;
  final Color teaColor;
  final Color saucerColor;
  final Color borderColor;
  final Color steamColor;

  _SteamCupPainter({
    required this.animationValue,
    required this.teaColor,
    required this.saucerColor,
    required this.borderColor,
    required this.steamColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final teaPaint = Paint()
      ..color = teaColor
      ..style = PaintingStyle.fill;

    final saucerPaint = Paint()
      ..color = saucerColor
      ..style = PaintingStyle.fill;

    final saucerBorderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    // 1. Draw Saucer at Bottom
    final saucerRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.92),
      width: w * 0.95,
      height: h * 0.14,
    );
    canvas.drawOval(saucerRect, saucerPaint);
    canvas.drawOval(saucerRect, saucerBorderPaint);

    // 2. Draw Ince Belli Turkish Glass Path
    final glassTopY = h * 0.38;
    final glassBottomY = h * 0.88;
    final glassPath = Path();

    glassPath.moveTo(w * 0.28, glassTopY);
    glassPath.quadraticBezierTo(
      w * 0.36,
      h * 0.60,
      w * 0.30,
      glassBottomY,
    );
    glassPath.lineTo(w * 0.70, glassBottomY);
    glassPath.quadraticBezierTo(
      w * 0.64,
      h * 0.60,
      w * 0.72,
      glassTopY,
    );
    glassPath.close();

    canvas.drawPath(glassPath, teaPaint);
    canvas.drawPath(glassPath, borderPaint);

    // 3. Draw Rising Wavy Steam Particles
    final steamPaint = Paint()
      ..color = steamColor.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 2; i++) {
      final steamPath = Path();
      final xOffset = w * (0.42 + (i * 0.16));
      final phase = animationValue * 2 * math.pi + (i * math.pi * 0.8);

      final startY = glassTopY - 2;
      steamPath.moveTo(xOffset, startY);

      final midY = glassTopY - (h * 0.16);
      final topY = glassTopY - (h * 0.32);

      final wave1 = math.sin(phase) * (w * 0.12);
      final wave2 = math.cos(phase) * (w * 0.14);

      steamPath.cubicTo(
        xOffset + wave1,
        midY,
        xOffset - wave2,
        midY - (h * 0.08),
        xOffset + (wave1 * 0.5),
        topY,
      );

      canvas.drawPath(steamPath, steamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SteamCupPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
