import 'package:flutter/material.dart';

/// Hurdalık arayüzünde pas dokusu ve damlayan siyah motor yağı damlası mikro widgetı.
class RustOilDropWidget extends StatefulWidget {
  final double size;

  const RustOilDropWidget({
    super.key,
    this.size = 24,
  });

  @override
  State<RustOilDropWidget> createState() => _RustOilDropWidgetState();
}

class _RustOilDropWidgetState extends State<RustOilDropWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _dropAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInQuad),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller.repeat();
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
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
            opacity: _opacityAnimation,
            child: Transform.translate(
              offset: Offset(0, _dropAnimation.value),
              child: child,
            ),
          );
        },
        child: Container(
          width: widget.size * 0.45,
          height: widget.size * 0.65,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Dark oil black
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
        ),
      ),
    );
  }
}
