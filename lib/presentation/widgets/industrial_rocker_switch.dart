import 'package:flutter/material.dart';
import '../../core/services/game_sound_haptic_service.dart';

/// Neo-Brutalist Industrial Rocker Switch
/// A heavy-duty mechanical two-position toggle with 3D shadow displacement,
/// tactile grip ridges, and crisp haptic feedback.
class IndustrialRockerSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String onLabel;
  final String offLabel;
  final Color activeColor;
  final Color inactiveColor;
  final Color borderColor;
  final double width;
  final double height;
  final String? leadingTitle;
  final String? subtitle;

  const IndustrialRockerSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.onLabel = 'AÇIK',
    this.offLabel = 'KAPALI',
    this.activeColor = const Color(0xFF00E575),
    this.inactiveColor = const Color(0xFFEF4444),
    this.borderColor = const Color(0xFF000000),
    this.width = 110.0,
    this.height = 36.0,
    this.leadingTitle,
    this.subtitle,
  });

  @override
  State<IndustrialRockerSwitch> createState() => _IndustrialRockerSwitchState();
}

class _IndustrialRockerSwitchState extends State<IndustrialRockerSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      value: widget.value ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void didUpdateWidget(covariant IndustrialRockerSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    GameSoundHapticService.playSwitchToggle(!widget.value);
    widget.onChanged(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final switchCore = GestureDetector(
      onTap: _toggle,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: widget.borderColor, width: 2.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.7 : 0.4),
              offset: const Offset(2.5, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final thumbWidth = (widget.width - 8) / 2;
            final offset = _animation.value * thumbWidth;
            final isCurrentlyOn = _animation.value >= 0.5;

            return Stack(
              children: [
                // Labels underneath
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.offLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: !isCurrentlyOn
                                ? Colors.transparent
                                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          widget.onLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: isCurrentlyOn
                                ? Colors.transparent
                                : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Tactile Rocker Thumb
                Positioned(
                  left: 2 + offset,
                  top: 2,
                  bottom: 2,
                  width: thumbWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrentlyOn ? widget.activeColor : widget.inactiveColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: widget.borderColor, width: 1.8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ribbed tactile grip pattern
                        CustomPaint(
                          size: Size(thumbWidth * 0.5, widget.height * 0.4),
                          painter: _TactileRibPainter(
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ),
                        Text(
                          isCurrentlyOn ? widget.onLabel : widget.offLabel,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (widget.leadingTitle == null) {
      return switchCore;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.leadingTitle!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 12),
        switchCore,
      ],
    );
  }
}

class _TactileRibPainter extends CustomPainter {
  final Color color;

  _TactileRibPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final step = size.width / 4;
    for (int i = 0; i <= 4; i++) {
      final x = i * step;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TactileRibPainter oldDelegate) =>
      oldDelegate.color != color;
}
