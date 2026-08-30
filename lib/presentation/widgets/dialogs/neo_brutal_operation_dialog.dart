import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../domain/usecases/operation_suspense_engine.dart';
import '../neo_brutal_badge.dart';

class NeoBrutalOperationDialog extends StatefulWidget {
  final OperationSuspenseType operationType;
  final String carName;
  final String? customTitle;
  final VoidCallback onComplete;
  final Random? rng;

  const NeoBrutalOperationDialog({
    super.key,
    required this.operationType,
    required this.carName,
    required this.onComplete,
    this.customTitle,
    this.rng,
  });

  static Future<bool?> show(
    BuildContext context, {
    required OperationSuspenseType operationType,
    required String carName,
    required VoidCallback onComplete,
    String? customTitle,
    Random? rng,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NeoBrutalOperationDialog(
        operationType: operationType,
        carName: carName,
        onComplete: onComplete,
        customTitle: customTitle,
        rng: rng,
      ),
    );
  }

  @override
  State<NeoBrutalOperationDialog> createState() =>
      _NeoBrutalOperationDialogState();
}

class _NeoBrutalOperationDialogState extends State<NeoBrutalOperationDialog>
    with SingleTickerProviderStateMixin {
  late final List<int> _stageDurations;
  late final List<String> _stageKeys;
  late final AnimationController _pulseController;

  int _currentStage = 0;
  double _progress = 0.0;
  Timer? _stageTimer;
  Timer? _progressTicker;
  int _elapsedMs = 0;
  int _totalDurationMs = 0;

  @override
  void initState() {
    super.initState();
    _stageDurations =
        widget.operationType.generateStageDurations(rng: widget.rng);
    _stageKeys = widget.operationType.stageKeys;
    _totalDurationMs =
        _stageDurations.fold(0, (sum, duration) => sum + duration);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _startOperationFlow();
  }

  void _startOperationFlow() {
    GameSoundHapticService.playClick();

    // Progress ticker updating every 50ms
    _progressTicker =
        Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedMs += 50;
        _progress = (_elapsedMs / _totalDurationMs).clamp(0.0, 1.0);
      });
    });

    _executeStage(0);
  }

  void _executeStage(int stageIndex) {
    if (!mounted) return;
    setState(() {
      _currentStage = stageIndex;
    });

    // Tactile escalation per stage
    if (stageIndex == 1) {
      GameSoundHapticService.playRestorationProgress();
    } else if (stageIndex == 2) {
      GameSoundHapticService.playNotaryStamp();
    }

    final duration = _stageDurations[stageIndex];
    _stageTimer = Timer(Duration(milliseconds: duration), () {
      if (!mounted) return;
      if (stageIndex < _stageDurations.length - 1) {
        _executeStage(stageIndex + 1);
      } else {
        _finishOperation();
      }
    });
  }

  void _finishOperation() {
    _progressTicker?.cancel();
    _stageTimer?.cancel();
    setState(() {
      _progress = 1.0;
    });

    GameSoundHapticService.playCashSuccess();

    widget.onComplete();

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  void dispose() {
    _stageTimer?.cancel();
    _progressTicker?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = widget.operationType.accentColor;
    final title = widget.customTitle ??
        context.tr(widget.operationType.titleKey);
    final activeStageText = _currentStage < _stageKeys.length
        ? context.tr(_stageKeys[_currentStage])
        : context.tr('op_status_complete');

    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF12151F) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black : const Color(0xFF0F172A),
                offset: const Offset(5, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Icon(
                        widget.operationType.icon,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              NeoBrutalBadge(
                                text: widget.carName,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0),
                                textColor: isDark ? Colors.white : Colors.black,
                                fontSize: 10,
                              ),
                              const SizedBox(width: 6),
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (ctx, child) {
                                  return Opacity(
                                    opacity: 0.6 + (_pulseController.value * 0.4),
                                    child: NeoBrutalBadge(
                                      text: context.tr('op_status_progress'),
                                      backgroundColor: accent,
                                      textColor: Colors.black,
                                      fontSize: 9.5,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Stepped Progress Bar with Percentage Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${context.tr('op_stage_prefix')} ${_currentStage + 1} / ${_stageKeys.length}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '%${(_progress * 100).toInt()}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Custom Neo-Brutalist Progress Track
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Dynamic Status Log Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0A0C12)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.6),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            activeStageText,
                            key: ValueKey<String>(activeStageText),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
