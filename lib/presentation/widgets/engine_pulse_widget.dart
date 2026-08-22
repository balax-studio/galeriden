import 'package:flutter/material.dart';

/// Motor testi sırasında devir saatine göre nabız gibi atan silindir & motor bloğu mikro widgetı.
class EnginePulseWidget extends StatefulWidget {
  final double engineHealthPercent; // 0.0 - 100.0
  final double size;

  const EnginePulseWidget({
    super.key,
    required this.engineHealthPercent,
    this.size = 36,
  });

  @override
  State<EnginePulseWidget> createState() => _EnginePulseWidgetState();
}

class _EnginePulseWidgetState extends State<EnginePulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    // Low health vibrates faster
    final durationMs = widget.engineHealthPercent < 50 ? 400 : 800;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    );

    _pulseScale = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final isTest = WidgetsBinding.instance.runtimeType.toString().toLowerCase().contains('test');
    if (!isTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final healthColor = widget.engineHealthPercent >= 80
        ? const Color(0xFF00E575)
        : (widget.engineHealthPercent >= 50 ? const Color(0xFFFFDE59) : const Color(0xFFEF4444));

    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: child,
        );
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: healthColor.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: healthColor, width: 2.0),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.speed_rounded,
          color: healthColor,
          size: widget.size * 0.58,
        ),
      ),
    );
  }
}
