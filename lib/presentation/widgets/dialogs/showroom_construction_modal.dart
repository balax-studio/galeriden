import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

/// Neo-Brutalist Construction & Renovation Suspense Dialog
/// Features a dynamic 3s / 5s / 10s countdown, phased status text,
/// pulsing/rotating tool animations, and instant speed-up capability.
class ShowroomConstructionModal extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final int durationSeconds;
  final VoidCallback onComplete;
  final IconData icon;
  final Color accentColor;

  const ShowroomConstructionModal({
    super.key,
    required this.title,
    required this.subtitle,
    required this.durationSeconds,
    required this.onComplete,
    this.icon = Icons.architecture_rounded,
    this.accentColor = AppColors.brutalYellow,
  });

  /// Static helper to display the modal with a dynamic mixed duration
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    int? customDurationSeconds,
    required VoidCallback onComplete,
    IconData icon = Icons.architecture_rounded,
    Color accentColor = AppColors.brutalYellow,
  }) {
    // Dynamic random selection among 3, 5, 10 seconds if not specified
    final durations = [3, 5, 10];
    final selectedDuration = customDurationSeconds ??
        durations[Random().nextInt(durations.length)];

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ShowroomConstructionModal(
        title: title,
        subtitle: subtitle,
        durationSeconds: selectedDuration,
        onComplete: onComplete,
        icon: icon,
        accentColor: accentColor,
      ),
    );
  }

  @override
  ConsumerState<ShowroomConstructionModal> createState() =>
      _ShowroomConstructionModalState();
}

class _ShowroomConstructionModalState
    extends ConsumerState<ShowroomConstructionModal>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _progressController.addListener(() {
      if (mounted) setState(() {});
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finishConstruction();
      }
    });

    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _finishConstruction() {
    if (_isCompleted) return;
    _isCompleted = true;

    HapticFeedback.heavyImpact();
    widget.onComplete();

    if (mounted && Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  String _getPhaseText(double progress) {
    if (progress < 0.30) {
      return context.tr('construction_phase_1');
    } else if (progress < 0.65) {
      return context.tr('construction_phase_2');
    } else if (progress < 0.90) {
      return context.tr('construction_phase_3');
    } else {
      return context.tr('construction_phase_4');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final progress = _progressController.value;
    final remainingSec =
        ((1.0 - progress) * widget.durationSeconds).ceil().clamp(0, widget.durationSeconds);
    final percent = (progress * 100).toInt();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 16,
          borderWidth: 2.8,
          shadowOffset: const Offset(5, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Status Badge & Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: context.tr('construction_badge_active'),
                    icon: Icons.construction_rounded,
                    backgroundColor: widget.accentColor,
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
                  Text(
                    context.tr('construction_seconds_remaining', {
                      'seconds': '$remainingSec',
                    }),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. Animated Construction Icon Container
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: widget.accentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 2.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.icon,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // 3. Header Texts
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),

              // 4. Progress Bar & Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _getPhaseText(progress),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFF93C5FD)
                                : const Color(0xFF1E40AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 1.8,
                      ),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: widget.accentColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. Rush / Instant Completion Action
              NeoBrutalButton(
                label: context.tr('construction_btn_hurry'),
                icon: Icons.bolt_rounded,
                fullWidth: true,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 12,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  _progressController.stop();
                  _finishConstruction();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
