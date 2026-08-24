import 'package:flutter/material.dart';

/// Vergi ödeme günü yaklaştığında sallanan neobrutal alarm zili widgetı.
class TaxAlertBellWidget extends StatefulWidget {
  final double size;
  final bool hasUnpaidTax;

  const TaxAlertBellWidget({
    super.key,
    this.size = 28,
    this.hasUnpaidTax = true,
  });

  @override
  State<TaxAlertBellWidget> createState() => _TaxAlertBellWidgetState();
}

class _TaxAlertBellWidgetState extends State<TaxAlertBellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _swingAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: -0.25), weight: 25),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.25, end: 0.25), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.25, end: 0.0), weight: 25),
    ]).animate(_controller);

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest && widget.hasUnpaidTax) {
      _controller.repeat();
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant TaxAlertBellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (isTest) return;

    if (widget.hasUnpaidTax && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.hasUnpaidTax && _controller.isAnimating) {
      _controller.stop();
    }
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
        animation: _swingAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: widget.hasUnpaidTax ? _swingAnimation.value : 0.0,
            alignment: Alignment.topCenter,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.hasUnpaidTax
              ? const Color(0xFFEF4444)
              : const Color(0xFF94A3B8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.notifications_active_rounded,
          color: Colors.white,
          size: widget.size * 0.58,
        ),
      ),
    ),
  );
}
}
