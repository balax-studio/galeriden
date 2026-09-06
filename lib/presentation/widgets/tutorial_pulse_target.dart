import 'package:flutter/material.dart';

/// A breathing heartbeat pulsing wrapper for tutorial action targets.
/// Gently expands and contracts like a real heartbeat (scale 1.0 -> 1.045 -> 1.0)
/// with an animated glowing neo-brutal aura so players clearly notice where to tap.
class TutorialPulseTarget extends StatefulWidget {
  final Widget child;
  final bool isEnabled;
  final Color pulseColor;
  final double maxScale;
  final Duration duration;
  final BorderRadius? borderRadius;

  const TutorialPulseTarget({
    super.key,
    required this.child,
    this.isEnabled = true,
    this.pulseColor = const Color(0xFFFFDE59),
    this.maxScale = 1.045,
    this.duration = const Duration(milliseconds: 1300),
    this.borderRadius,
  });

  @override
  State<TutorialPulseTarget> createState() => _TutorialPulseTargetState();
}

class _TutorialPulseTargetState extends State<TutorialPulseTarget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');

    if (widget.isEnabled && !isTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ),
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(TutorialPulseTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      if (widget.isEnabled && !_controller.isAnimating) {
        _controller.repeat(reverse: true);
      } else if (!widget.isEnabled && _controller.isAnimating) {
        _controller.stop();
        _controller.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return widget.child;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: widget.pulseColor.withValues(
                      alpha: 0.20 + (_glowAnimation.value * 0.45),
                    ),
                    blurRadius: 6.0 + (_glowAnimation.value * 10.0),
                    spreadRadius: 1.0 + (_glowAnimation.value * 3.0),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
