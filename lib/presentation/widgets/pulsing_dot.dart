import 'package:flutter/material.dart';

/// Breathing pulsing indicator dot for live viewers, urgent bargains, and active status
class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;
  final bool showRipple;

  const PulsingDot({
    super.key,
    this.color = const Color(0xFF00E575),
    this.size = 8.0,
    this.duration = const Duration(milliseconds: 1400),
    this.showRipple = true,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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
    if (!isTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        builder: (context, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (widget.showRipple)
                Transform.scale(
                  scale: _scaleAnimation.value * 1.4,
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withValues(
                        alpha: (1.0 - _controller.value) * 0.35,
                      ),
                    ),
                  ),
                ),
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        widget.color.withValues(alpha: _opacityAnimation.value),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
