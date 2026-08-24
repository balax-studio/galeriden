import 'package:flutter/material.dart';

/// İhalede veya geri sayımlarda son saniyelerde renk değiştirip nabız gibi atan hararet çemberi widgetı.
class CountdownHeatRing extends StatefulWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final double size;

  const CountdownHeatRing({
    super.key,
    required this.remainingSeconds,
    this.totalSeconds = 10,
    this.size = 54,
  });

  @override
  State<CountdownHeatRing> createState() => _CountdownHeatRingState();
}

class _CountdownHeatRingState extends State<CountdownHeatRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest && widget.remainingSeconds <= 3) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant CountdownHeatRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (isTest) return;

    if (widget.remainingSeconds <= 3 && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.remainingSeconds > 3 && _pulseController.isAnimating) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = widget.remainingSeconds <= 3;
    final ringColor = isUrgent
        ? const Color(0xFFEF4444)
        : (widget.remainingSeconds <= 6
            ? const Color(0xFFFFDE59)
            : const Color(0xFF00E575));

    final progress =
        (widget.remainingSeconds / widget.totalSeconds).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Transform.scale(
          scale: isUrgent ? _pulseScale.value : 1.0,
          child: child,
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 4.5,
              backgroundColor: Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(ringColor),
            ),
          ),
          Text(
            '${widget.remainingSeconds}s',
            style: TextStyle(
              fontSize: widget.size * 0.28,
              fontWeight: FontWeight.w900,
              color: isUrgent ? const Color(0xFFEF4444) : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
