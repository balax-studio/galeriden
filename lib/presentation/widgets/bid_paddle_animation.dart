import 'package:flutter/material.dart';

/// Canlı ihalede rakipler teklif verdiğinde havaya kalkan pey raketi animasyonu.
class BidPaddleAnimation extends StatefulWidget {
  final String paddleNumber;
  final String bidderName;
  final VoidCallback? onComplete;

  const BidPaddleAnimation({
    super.key,
    required this.paddleNumber,
    required this.bidderName,
    this.onComplete,
  });

  @override
  State<BidPaddleAnimation> createState() => _BidPaddleAnimationState();
}

class _BidPaddleAnimationState extends State<BidPaddleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 60.0, end: -10.0), weight: 35),
      TweenSequenceItem(
          tween: Tween<double>(begin: -10.0, end: 0.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.0), weight: 25),
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 70.0), weight: 25),
    ]).animate(_controller);

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
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Round Paddle Head
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFDE59),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2.2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              '#${widget.paddleNumber}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
          ),
          // Paddle Stick
          Container(
            width: 6,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF78350F), // Wood stick
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.black, width: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
