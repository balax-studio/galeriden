import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Neo-Brutal Flat Geometric Confetti Celebration Overlay
/// Renders bordered geometric shapes (rectangles, squares, diamonds) with physics-based gravity and tumbling.
class ConfettiCelebrationOverlay extends StatefulWidget {
  final Duration duration;
  final int particleCount;
  final VoidCallback? onFinished;

  const ConfettiCelebrationOverlay({
    super.key,
    this.duration = const Duration(milliseconds: 2200),
    this.particleCount = 45,
    this.onFinished,
  });

  /// Static helper to trigger confetti overlay on top of current navigator overlay
  static void show(BuildContext context,
      {Duration duration = const Duration(milliseconds: 2200)}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => IgnorePointer(
        child: ConfettiCelebrationOverlay(
          duration: duration,
          onFinished: () {
            entry.remove();
          },
        ),
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<ConfettiCelebrationOverlay> createState() =>
      _ConfettiCelebrationOverlayState();
}

class _ConfettiCelebrationOverlayState extends State<ConfettiCelebrationOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_ConfettiParticle> _particles;

  final List<Color> _palette = const [
    Color(0xFFFFDE59), // Brutal Yellow
    Color(0xFF00FF66), // Toxic Mint
    Color(0xFFFF0055), // Hot Magenta
    Color(0xFF00F0FF), // Neon Cyan
    Color(0xFF3B82F6), // Electric Blue
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return _ConfettiParticle(
        x: random.nextDouble(),
        startX: random.nextDouble(),
        startY: -0.1 - (random.nextDouble() * 0.3),
        speedY: 0.8 + (random.nextDouble() * 0.8),
        oscillationSpeed: 2.0 + (random.nextDouble() * 4.0),
        rotationSpeed: 3.0 + (random.nextDouble() * 6.0),
        size: 8.0 + (random.nextDouble() * 8.0),
        color: _palette[index % _palette.length],
        isRectangle: index % 3 != 0,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.forward().then((_) {
      if (mounted && widget.onFinished != null) {
        widget.onFinished!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _ConfettiPainter(
            progress: _controller.value,
            particles: _particles,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double startX;
  final double startY;
  final double speedY;
  final double oscillationSpeed;
  final double rotationSpeed;
  final double size;
  final Color color;
  final bool isRectangle;

  _ConfettiParticle({
    required this.x,
    required this.startX,
    required this.startY,
    required this.speedY,
    required this.oscillationSpeed,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.isRectangle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = (1.0 - (progress * progress)).clamp(0.0, 1.0);

    for (final p in particles) {
      final currentY = (p.startY + (progress * p.speedY * 1.5)) * size.height;
      if (currentY > size.height + 20) continue;

      final wave = math.sin(
              (progress * p.oscillationSpeed * math.pi) + (p.startX * 10)) *
          25.0;
      final currentX = (p.startX * size.width) + wave;

      final rotation = progress * p.rotationSpeed * math.pi;
      final flip = math.cos(rotation);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation * 0.4);
      canvas.scale(flip.abs().clamp(0.15, 1.0), 1.0);

      final fillPaint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final halfW = (p.isRectangle ? p.size * 1.6 : p.size) / 2;
      final halfH = p.size / 2;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset.zero, width: halfW * 2, height: halfH * 2),
        const Radius.circular(2),
      );

      canvas.drawRRect(rrect, fillPaint);
      if (opacity > 0.3) {
        final currentBorderPaint = Paint()
          ..color = const Color(0xFF0F172A).withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        canvas.drawRRect(rrect, currentBorderPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
