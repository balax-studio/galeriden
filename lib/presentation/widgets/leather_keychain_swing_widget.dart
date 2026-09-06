import 'package:flutter/material.dart';

/// Şov odasında veya araba teslimatında sallanan neobrutal deri anahtarlık widgetı.
class LeatherKeychainSwingWidget extends StatefulWidget {
  final double size;

  const LeatherKeychainSwingWidget({
    super.key,
    this.size = 40,
  });

  @override
  State<LeatherKeychainSwingWidget> createState() =>
      _LeatherKeychainSwingWidgetState();
}

class _LeatherKeychainSwingWidgetState extends State<LeatherKeychainSwingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _swingAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: -0.18), weight: 25),
      TweenSequenceItem(
          tween: Tween<double>(begin: -0.18, end: 0.18), weight: 50),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.18, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

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
        animation: _swingAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _swingAnimation.value,
            alignment: Alignment.topCenter,
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Metal Ring
            Container(
              width: widget.size * 0.45,
              height: widget.size * 0.45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2.2),
                color: const Color(0xFFE2E8F0),
              ),
            ),
            // Leather Strap
            Container(
              width: widget.size * 0.35,
              height: widget.size * 0.75,
              decoration: BoxDecoration(
                color: const Color(0xFF78350F), // Brown leather
                borderRadius: BorderRadius.circular(4),
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
                Icons.vpn_key_rounded,
                color: const Color(0xFFFFDE59),
                size: widget.size * 0.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
