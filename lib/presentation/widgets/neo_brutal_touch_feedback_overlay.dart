import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../core/services/game_sound_haptic_service.dart';

class TouchParticle {
  final Offset position;
  final Color color;
  final DateTime createdAt;
  final double size;
  final double rotation;

  TouchParticle({
    required this.position,
    required this.color,
    required this.createdAt,
    this.size = 32.0,
    this.rotation = 0.0,
  });
}

class NeoBrutalTouchFeedbackOverlay extends StatefulWidget {
  final Widget child;
  final bool enableHaptics;
  final bool enableUnfocusOnTap;

  const NeoBrutalTouchFeedbackOverlay({
    super.key,
    required this.child,
    this.enableHaptics = false,
    this.enableUnfocusOnTap = true,
  });

  @override
  State<NeoBrutalTouchFeedbackOverlay> createState() => NeoBrutalTouchFeedbackOverlayState();
}

class NeoBrutalTouchFeedbackOverlayState extends State<NeoBrutalTouchFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  final List<TouchParticle> _activeParticles = [];
  Ticker? _ticker;
  static const int _particleLifetimeMs = 240;

  List<TouchParticle> get activeParticles => List.unmodifiable(_activeParticles);

  static const List<Color> _accentColors = [
    Color(0xFF00E575), // Neo Brutal Green
    Color(0xFFFFDE59), // Neo Brutal Gold / Yellow
    Color(0xFF38BDF8), // Neo Brutal Sky Blue
    Color(0xFFFF5C8D), // Neo Brutal Pink
  ];
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    if (_activeParticles.isEmpty) {
      _ticker?.stop();
      return;
    }

    final now = DateTime.now();
    _activeParticles.removeWhere((p) => now.difference(p.createdAt).inMilliseconds >= _particleLifetimeMs);

    if (mounted) {
      setState(() {});
    }

    if (_activeParticles.isEmpty) {
      _ticker?.stop();
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    // 1. Global Keyboard Unfocus on Tap Outside
    if (widget.enableUnfocusOnTap) {
      final currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    }

    // 2. Tactile Haptic Vibration
    if (widget.enableHaptics) {
      GameSoundHapticService.playTapImpact();
    }

    // 3. Spawn Neo-Brutalist Tactile Touch Particle
    final selectedColor = _accentColors[_colorIndex % _accentColors.length];
    _colorIndex++;

    _activeParticles.add(
      TouchParticle(
        position: event.position,
        color: selectedColor,
        createdAt: DateTime.now(),
        size: 30.0,
        rotation: (event.position.dx % 4) * (math.pi / 4),
      ),
    );

    if (_ticker != null && !_ticker!.isTicking) {
      _ticker!.start();
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          RepaintBoundary(child: widget.child),
          if (_activeParticles.isNotEmpty)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _NeoBrutalTouchPainter(
                      particles: _activeParticles,
                      lifetimeMs: _particleLifetimeMs,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NeoBrutalTouchPainter extends CustomPainter {
  final List<TouchParticle> particles;
  final int lifetimeMs;

  _NeoBrutalTouchPainter({
    required this.particles,
    required this.lifetimeMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final now = DateTime.now();

    for (final particle in particles) {
      final elapsed = now.difference(particle.createdAt).inMilliseconds;
      if (elapsed >= lifetimeMs) continue;

      final progress = (elapsed / lifetimeMs).clamp(0.0, 1.0);
      final curve = Curves.easeOutCubic.transform(progress);

      // Expansion from scale 0.3 to 1.35
      final currentRadius = particle.size * (0.3 + (curve * 0.95));
      final opacity = (1.0 - curve).clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation + (curve * 0.35));

      // 1. Shadow Stroke (Neo-Brutalist offset shadow)
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;

      final rect = Rect.fromCircle(center: const Offset(1.5, 1.5), radius: currentRadius);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(currentRadius * 0.28));
      canvas.drawRRect(rrect, shadowPaint);

      // 2. Primary Vibrant Stroke
      final primaryPaint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4;

      final mainRect = Rect.fromCircle(center: Offset.zero, radius: currentRadius);
      final mainRRect = RRect.fromRectAndRadius(mainRect, Radius.circular(currentRadius * 0.28));
      canvas.drawRRect(mainRRect, primaryPaint);

      // 3. Center Punch Dot
      if (curve < 0.6) {
        final dotOpacity = (1.0 - (curve / 0.6)).clamp(0.0, 1.0);
        final dotPaint = Paint()
          ..color = Colors.black.withValues(alpha: dotOpacity * 0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset.zero, 2.5 * (1.0 - curve), dotPaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NeoBrutalTouchPainter oldDelegate) => true;
}
