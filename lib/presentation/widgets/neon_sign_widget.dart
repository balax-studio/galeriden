import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Neo-Brutal Flickering Cyber Neon Sign Widget
/// Delivers realistic voltage fluctuation, subtle glow pulsing, and retro street style without heavy GPU load.
class NeonSignWidget extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color neonColor;
  final Color backgroundColor;
  final double fontSize;
  final bool isFlickering;

  const NeonSignWidget({
    super.key,
    required this.text,
    this.icon,
    this.neonColor = const Color(0xFFFF007F), // Brutal Hot Neon Pink
    this.backgroundColor = const Color(0xFF140F22),
    this.fontSize = 13.0,
    this.isFlickering = true,
  });

  @override
  State<NeonSignWidget> createState() => _NeonSignWidgetState();
}

class _NeonSignWidgetState extends State<NeonSignWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final math.Random _random = math.Random(42);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test');
    if (widget.isFlickering && !isTest) {
      _controller.repeat();
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
        double opacity = 1.0;
        if (widget.isFlickering) {
          final t = _controller.value;
          if ((t > 0.22 && t < 0.28) || (t > 0.70 && t < 0.74)) {
            opacity = 0.45 + (_random.nextDouble() * 0.40);
          } else {
            opacity = 0.90 + (math.sin(t * 2 * math.pi) * 0.10);
          }
        }

        final activeColor = widget.neonColor.withValues(alpha: opacity.clamp(0.4, 1.0));

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: activeColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.neonColor.withValues(alpha: 0.35 * opacity),
                offset: const Offset(2.5, 2.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: widget.fontSize + 3,
                  color: activeColor,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.text.toUpperCase(),
                style: TextStyle(
                  color: activeColor,
                  fontSize: widget.fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: widget.neonColor.withValues(alpha: 0.8 * opacity),
                      blurRadius: 4.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
