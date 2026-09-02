import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/game/game_time_mixin.dart';

/// Micro Time-of-Day Phase enum
enum DayTimePhase {
  morning,
  noon,
  evening,
  night,
}

/// High-performance, Neo-Brutalist Hardware-Accelerated Radial Clock Progress Widget.
/// Shows a live 7-minute circular sweep indicating elapsed day progress and time-of-day phases.
class RadialDayProgressWidget extends StatefulWidget {
  final int currentDay;
  final bool isDark;
  final double size;
  final DateTime? dayStartTime;

  const RadialDayProgressWidget({
    super.key,
    required this.currentDay,
    required this.isDark,
    this.size = 22.0,
    this.dayStartTime,
  });

  @override
  State<RadialDayProgressWidget> createState() => _RadialDayProgressWidgetState();
}

class _RadialDayProgressWidgetState extends State<RadialDayProgressWidget>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: GameTimeMixin.inGameDayDurationSeconds,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_pulseController);

    _syncAndStartProgress();
  }

  void _syncAndStartProgress() {
    if (widget.dayStartTime != null) {
      final elapsedMs =
          DateTime.now().difference(widget.dayStartTime!).inMilliseconds;
      const totalMs = GameTimeMixin.inGameDayDurationSeconds * 1000;
      final startValue =
          ((elapsedMs % totalMs) / totalMs).clamp(0.0, 1.0);
      _progressController.value = startValue;
    }

    _progressController.repeat();
  }

  @override
  void didUpdateWidget(covariant RadialDayProgressWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentDay != oldWidget.currentDay) {
      _pulseController.forward(from: 0.0);
      _progressController.reset();
      _progressController.repeat();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  DayTimePhase _getPhase(double progress) {
    if (progress < 0.25) return DayTimePhase.morning;
    if (progress < 0.595) return DayTimePhase.noon;
    if (progress < 0.869) return DayTimePhase.evening;
    return DayTimePhase.night;
  }

  (IconData, Color) _getPhaseVisuals(DayTimePhase phase) {
    switch (phase) {
      case DayTimePhase.morning:
        return (Icons.wb_sunny_rounded, const Color(0xFFFFB703));
      case DayTimePhase.noon:
        return (Icons.storefront_rounded, const Color(0xFF38BDF8));
      case DayTimePhase.evening:
        return (Icons.wb_twilight_rounded, const Color(0xFFF97316));
      case DayTimePhase.night:
        return (Icons.nightlight_round, const Color(0xFF818CF8));
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackColor = widget.isDark
        ? const Color(0xFF2A3142)
        : const Color(0xFFE2E8F0);
    final borderColor = widget.isDark
        ? const Color(0xFF333B4F)
        : const Color(0xFF0F172A);

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              final progress = _progressController.value;
              final phase = _getPhase(progress);
              final (icon, accentColor) = _getPhaseVisuals(phase);

              return Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Radial Sweep Arc & Background Track
                  CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RadialClockPainter(
                      progress: progress,
                      trackColor: trackColor,
                      progressColor: accentColor,
                      strokeWidth: 2.2,
                    ),
                  ),

                  // 2. Inner Icon Badge Box
                  Container(
                    width: widget.size - 6.0,
                    height: widget.size - 6.0,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(3.5),
                      border: Border.all(
                        color: borderColor,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 9.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// CustomPainter rendering high-contrast, crisp neo-brutalist circular sweep progress
class _RadialClockPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _RadialClockPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc
    if (progress > 0.0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start at 12 o'clock
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RadialClockPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
