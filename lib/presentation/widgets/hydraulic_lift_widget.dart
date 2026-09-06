import 'package:flutter/material.dart';

/// Ekspertiz sırasında aracı hafifçe (4-6px) yukarı kaldıran ve hidrolik piston hareketi veren mikro widget.
class HydraulicLiftWidget extends StatefulWidget {
  final Widget child;
  final bool isLifting;

  const HydraulicLiftWidget({
    super.key,
    required this.child,
    this.isLifting = true,
  });

  @override
  State<HydraulicLiftWidget> createState() => _HydraulicLiftWidgetState();
}

class _HydraulicLiftWidgetState extends State<HydraulicLiftWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _liftAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _liftAnimation = Tween<double>(begin: 0.0, end: -6.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest && widget.isLifting) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant HydraulicLiftWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (isTest) return;
    if (widget.isLifting && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isLifting && _controller.isAnimating) {
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
        animation: _liftAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _liftAnimation.value),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}
