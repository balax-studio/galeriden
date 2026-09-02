import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_typography.dart';
import '../providers/game/game_time_mixin.dart';

/// Micro Time-of-Day Phase enum
enum DayTimePhase {
  morning,
  noon,
  evening,
  night,
}

/// Full-Width Bottom Gauge Neo-Brutalist Day Pill Widget.
/// Combines a clean square micro-phase icon badge with a full-width 3px progress bar.
class DayProgressHudPill extends StatefulWidget {
  final int currentDay;
  final bool isDark;
  final DateTime? dayStartTime;
  final VoidCallback onTap;

  const DayProgressHudPill({
    super.key,
    required this.currentDay,
    required this.isDark,
    this.dayStartTime,
    required this.onTap,
  });

  @override
  State<DayProgressHudPill> createState() => _DayProgressHudPillState();
}

class _DayProgressHudPillState extends State<DayProgressHudPill>
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
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
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
      final startValue = ((elapsedMs % totalMs) / totalMs).clamp(0.0, 1.0);
      _progressController.value = startValue;
    }

    _progressController.repeat();
  }

  @override
  void didUpdateWidget(covariant DayProgressHudPill oldWidget) {
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
    final isDark = widget.isDark;
    final bgColor = isDark ? const Color(0xFF141721) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);
    final shadowColor =
        isDark ? const Color(0xFF000000) : const Color(0xFF0F172A);
    final trackColor =
        isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0);

    return RepaintBoundary(
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              widget.onTap();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    offset: const Offset(2.0, 2.0),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: borderColor,
                    width: 2.0,
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final progress = _progressController.value;
                    final phase = _getPhase(progress);
                    final (icon, accentColor) = _getPhaseVisuals(phase);

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Centered Content Row (Matches height of all other HUD pills)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: accentColor,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF333B4F)
                                        : const Color(0xFF0F172A),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(
                                  icon,
                                  size: 12,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${context.tr('hud_day')} ',
                                style: AppTypography.labelSmall(isDark).copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              Text(
                                '${widget.currentDay}',
                                style: AppTypography.monoSpec(isDark).copyWith(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Full-Width Bottom Progress Gauge Bar
                        Positioned(
                          left: -4,
                          right: -4,
                          bottom: -4,
                          child: Container(
                            height: 2.5,
                            decoration: BoxDecoration(
                              color: trackColor,
                              borderRadius: BorderRadius.circular(1.25),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress.clamp(0.02, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(1.25),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fallback / standalone Radial Clock Progress Widget
class RadialDayProgressWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return DayProgressHudPill(
      currentDay: currentDay,
      isDark: isDark,
      dayStartTime: dayStartTime,
      onTap: () {},
    );
  }
}
