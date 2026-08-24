import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Neo-Brutalist Geometric Shape Enum
enum ConfettiShape {
  square,
  rectangle,
  triangle,
  diamond,
  cross,
}

/// Neo-Brutal Flat Geometric Confetti Celebration Overlay
/// Renders crisp bordered geometric shapes (squares, rectangles, triangles, diamonds, crosses)
/// with physics-based gravity, 3D tumbling, wind wobble, and hard offset drop shadows.
class ConfettiCelebrationOverlay extends StatefulWidget {
  final Duration duration;
  final int particleCount;
  final VoidCallback? onFinished;

  const ConfettiCelebrationOverlay({
    super.key,
    this.duration = const Duration(milliseconds: 2400),
    this.particleCount = 65,
    this.onFinished,
  });

  /// Static helper to trigger confetti overlay on top of current navigator overlay
  static void show(BuildContext context,
      {Duration duration = const Duration(milliseconds: 2400)}) {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => IgnorePointer(
        child: ConfettiCelebrationOverlay(
          duration: duration,
          onFinished: () {
            if (entry.mounted) {
              entry.remove();
            }
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

  static const List<Color> _palette = [
    Color(0xFFFFDE59), // Cyber Brutal Yellow
    Color(0xFF00FF66), // Toxic Mint / Acid Green
    Color(0xFFFF0055), // Hot Magenta
    Color(0xFF00F0FF), // Neon Cyan
    Color(0xFFFF6B00), // Industrial Orange
    Color(0xFF8B5CF6), // Electric Purple
    Color(0xFF3B82F6), // Royal Blue
    Colors.white,      // Monolith White
  ];

  static const List<ConfettiShape> _shapes = [
    ConfettiShape.square,
    ConfettiShape.rectangle,
    ConfettiShape.triangle,
    ConfettiShape.diamond,
    ConfettiShape.cross,
  ];

  @override
  void initState() {
    super.initState();
    final random = math.Random();

    _particles = List.generate(widget.particleCount, (index) {
      final shape = _shapes[index % _shapes.length];
      final color = _palette[index % _palette.length];
      final baseSize = 8.0 + (random.nextDouble() * 9.0);

      return _ConfettiParticle(
        shape: shape,
        color: color,
        size: baseSize,
        startX: 0.1 + (random.nextDouble() * 0.8),
        startY: -0.08 - (random.nextDouble() * 0.35),
        speedY: 0.75 + (random.nextDouble() * 0.9),
        speedX: (random.nextDouble() - 0.5) * 0.4,
        wobbleSpeed: 2.0 + (random.nextDouble() * 4.5),
        wobbleAmplitude: 15.0 + (random.nextDouble() * 25.0),
        rotationSpeed: 2.5 + (random.nextDouble() * 6.0),
        tiltSpeed: 1.5 + (random.nextDouble() * 4.0),
        initialAngle: random.nextDouble() * math.pi * 2,
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
          painter: _NeoBrutalConfettiPainter(
            progress: _controller.value,
            particles: _particles,
          ),
        );
      },
    );
  }
}

class _ConfettiParticle {
  final ConfettiShape shape;
  final Color color;
  final double size;
  final double startX;
  final double startY;
  final double speedY;
  final double speedX;
  final double wobbleSpeed;
  final double wobbleAmplitude;
  final double rotationSpeed;
  final double tiltSpeed;
  final double initialAngle;

  _ConfettiParticle({
    required this.shape,
    required this.color,
    required this.size,
    required this.startX,
    required this.startY,
    required this.speedY,
    required this.speedX,
    required this.wobbleSpeed,
    required this.wobbleAmplitude,
    required this.rotationSpeed,
    required this.tiltSpeed,
    required this.initialAngle,
  });
}

class _NeoBrutalConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _NeoBrutalConfettiPainter({
    required this.progress,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Smooth quadratic fade out near end of life
    final double opacity = (1.0 - math.pow(progress, 2.4)).clamp(0.0, 1.0).toDouble();
    if (opacity <= 0.0) return;

    for (final p in particles) {
      final double currentY = (p.startY + (progress * p.speedY * 1.45)) * size.height;
      if (currentY > size.height + 30 || currentY < -40) continue;

      final double wave = math.sin((progress * p.wobbleSpeed * math.pi) + p.initialAngle) * p.wobbleAmplitude;
      final double currentX = (p.startX * size.width) + (progress * p.speedX * size.width) + wave;

      final double rotation = p.initialAngle + (progress * p.rotationSpeed * math.pi);
      final double tilt = math.cos((progress * p.tiltSpeed * math.pi) + p.initialAngle);
      final double scaleX = tilt.abs().clamp(0.12, 1.0);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(rotation);
      canvas.scale(scaleX, 1.0);

      _drawNeoBrutalShape(canvas, p, opacity);

      canvas.restore();
    }
  }

  void _drawNeoBrutalShape(Canvas canvas, _ConfettiParticle p, double opacity) {
    final fillPaint = Paint()
      ..color = p.color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final shadowPaint = Paint()
      ..color = const Color(0xFF000000).withValues(alpha: opacity * 0.65)
      ..style = PaintingStyle.fill;

    const shadowOffset = Offset(2.0, 2.0);

    switch (p.shape) {
      case ConfettiShape.square:
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size,
          height: p.size,
        );
        final shadowRect = rect.shift(shadowOffset);
        canvas.drawRect(shadowRect, shadowPaint);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
        break;

      case ConfettiShape.rectangle:
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: p.size * 2.0,
          height: p.size * 0.75,
        );
        final shadowRect = rect.shift(shadowOffset);
        canvas.drawRect(shadowRect, shadowPaint);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, borderPaint);
        break;

      case ConfettiShape.triangle:
        final path = _createTrianglePath(p.size * 1.15);
        final shadowPath = path.shift(shadowOffset);
        canvas.drawPath(shadowPath, shadowPaint);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case ConfettiShape.diamond:
        final path = _createDiamondPath(p.size * 1.1);
        final shadowPath = path.shift(shadowOffset);
        canvas.drawPath(shadowPath, shadowPaint);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;

      case ConfettiShape.cross:
        final path = _createCrossPath(p.size * 1.1);
        final shadowPath = path.shift(shadowOffset);
        canvas.drawPath(shadowPath, shadowPaint);
        canvas.drawPath(path, fillPaint);
        canvas.drawPath(path, borderPaint);
        break;
    }
  }

  Path _createTrianglePath(double size) {
    final half = size / 2;
    return Path()
      ..moveTo(0, -half * 1.15)
      ..lineTo(half, half * 0.9)
      ..lineTo(-half, half * 0.9)
      ..close();
  }

  Path _createDiamondPath(double size) {
    final half = size / 2;
    return Path()
      ..moveTo(0, -half * 1.2)
      ..lineTo(half * 0.85, 0)
      ..lineTo(0, half * 1.2)
      ..lineTo(-half * 0.85, 0)
      ..close();
  }

  Path _createCrossPath(double size) {
    final arm = size * 0.45;
    final thick = size * 0.16;

    final path = Path();
    // Top arm
    path.moveTo(-thick, -arm);
    path.lineTo(thick, -arm);
    path.lineTo(thick, -thick);
    // Right arm
    path.lineTo(arm, -thick);
    path.lineTo(arm, thick);
    path.lineTo(thick, thick);
    // Bottom arm
    path.lineTo(thick, arm);
    path.lineTo(-thick, arm);
    path.lineTo(-thick, thick);
    // Left arm
    path.lineTo(-arm, thick);
    path.lineTo(-arm, -thick);
    path.lineTo(-thick, -thick);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant _NeoBrutalConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
