import 'package:flutter/material.dart';
import '../../core/services/game_sound_haptic_service.dart';
import 'neo_brutal_stamp.dart';

/// Animated Stamp widget that slams down with tactile haptics and spring physics
class SlamStampWidget extends StatefulWidget {
  final String text;
  final Color color;
  final double angle;
  final double fontSize;
  final bool autoPlay;
  final Duration duration;
  final Duration delay;
  final VoidCallback? onSlamComplete;

  const SlamStampWidget({
    super.key,
    required this.text,
    this.color = const Color(0xFF00E575),
    this.angle = -0.15,
    this.fontSize = 11,
    this.autoPlay = true,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.onSlamComplete,
  });

  @override
  State<SlamStampWidget> createState() => _SlamStampWidgetState();
}

class _SlamStampWidgetState extends State<SlamStampWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _hapticFired = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(begin: 1.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _controller.addListener(() {
      if (_controller.value >= 0.85 && !_hapticFired) {
        _hapticFired = true;
        GameSoundHapticService.playStampSlam();
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onSlamComplete?.call();
      }
    });

    if (widget.autoPlay) {
      if (widget.delay != Duration.zero) {
        Future.delayed(widget.delay, () {
          if (mounted) _controller.forward();
        });
      } else {
        _controller.forward();
      }
    } else {
      _controller.value = 1.0;
    }
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: NeoBrutalStamp(
              text: widget.text,
              color: widget.color,
              angle: widget.angle,
              fontSize: widget.fontSize,
            ),
          ),
        );
      },
    );
  }
}
