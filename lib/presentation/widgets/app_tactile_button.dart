import 'package:flutter/material.dart';
import '../../core/services/game_sound_haptic_service.dart';

/// Premium Tactile Push Button with subtle spring physics scaling (scale 0.97)
class AppTactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final bool enableHaptics;

  const AppTactileButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.decoration,
    this.enableHaptics = true,
  });

  @override
  State<AppTactileButton> createState() => _AppTactileButtonState();
}

class _AppTactileButtonState extends State<AppTactileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      if (widget.enableHaptics) {
        GameSoundHapticService.playClick();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: widget.padding,
          decoration: widget.decoration,
          child: widget.child,
        ),
      ),
    );
  }
}
