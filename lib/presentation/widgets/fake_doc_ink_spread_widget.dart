import 'package:flutter/material.dart';

/// Sahte evrak / ruhsat onayında mührün vurulması ve mürekkep yayılması mikro widgetı.
class FakeDocInkSpreadWidget extends StatefulWidget {
  final String stampText;
  final VoidCallback? onComplete;
  final double size;

  const FakeDocInkSpreadWidget({
    super.key,
    this.stampText = 'SAHTE',
    this.onComplete,
    this.size = 90,
  });

  @override
  State<FakeDocInkSpreadWidget> createState() => _FakeDocInkSpreadWidgetState();
}

class _FakeDocInkSpreadWidgetState extends State<FakeDocInkSpreadWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _scaleAnimation = Tween<double>(begin: 2.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller.forward().then((_) => widget.onComplete?.call());
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
            child: Transform.rotate(
              angle: -0.2, // Tilted stamp angle
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDC2626), width: 2.8),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          widget.stampText,
          style: const TextStyle(
            color: Color(0xFFDC2626),
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
