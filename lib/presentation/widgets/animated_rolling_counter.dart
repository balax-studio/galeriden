import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/services/game_sound_haptic_service.dart';

/// Mechanical animated rolling counter with tabular figures and delta color flash
class AnimatedRollingCounter extends StatefulWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final bool isShort;
  final bool isCurrency;
  final int decimalDigits;
  final bool enableDeltaFlash;
  final TextAlign textAlign;

  const AnimatedRollingCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 450),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix,
    this.suffix,
    this.isShort = false,
    this.isCurrency = true,
    this.decimalDigits = 0,
    this.enableDeltaFlash = true,
    this.textAlign = TextAlign.start,
  });

  @override
  State<AnimatedRollingCounter> createState() => _AnimatedRollingCounterState();
}

class _AnimatedRollingCounterState extends State<AnimatedRollingCounter>
    with SingleTickerProviderStateMixin {
  late double _previousValue;
  Color? _flashColor;
  late AnimationController _flashController;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedRollingCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _previousValue = oldWidget.value;
      GameSoundHapticService.playCounterTick();
      if (widget.enableDeltaFlash) {
        if (widget.value > oldWidget.value) {
          _flashColor = const Color(0xFF00E575); // Brutal green
        } else {
          _flashColor = const Color(0xFFFF3B30); // Brutal red
        }
        _flashController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  String _formatValue(double val) {
    if (widget.isShort) {
      return CurrencyFormatter.formatShort(val);
    }
    if (widget.isCurrency) {
      return CurrencyFormatter.format(val);
    }
    final formattedNum = widget.decimalDigits > 0
        ? val.toStringAsFixed(widget.decimalDigits)
        : val.round().toString();
    final p = widget.prefix ?? '';
    final s = widget.suffix ?? '';
    return '$p$formattedNum$s';
  }

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final targetStyle = (widget.style ?? defaultStyle).copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _flashController,
        builder: (context, child) {
          Color? effectiveColor = targetStyle.color;
          if (widget.enableDeltaFlash &&
              _flashColor != null &&
              _flashController.isAnimating) {
            final t = _flashController.value;
            effectiveColor =
                Color.lerp(_flashColor, targetStyle.color ?? Colors.black, t);
          }

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _previousValue, end: widget.value),
            duration: widget.duration,
            curve: widget.curve,
            builder: (context, animatedVal, _) {
              return Text(
                _formatValue(animatedVal),
                textAlign: widget.textAlign,
                style: targetStyle.copyWith(color: effectiveColor),
              );
            },
          );
        },
      ),
    );
  }
}
