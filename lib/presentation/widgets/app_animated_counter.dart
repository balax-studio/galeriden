import 'package:flutter/material.dart';
import '../../core/utils/currency_formatter.dart';

class AppAnimatedCounter extends StatelessWidget {
  final double value;
  final TextStyle style;
  final bool isCurrency;
  final Duration duration;

  const AppAnimatedCounter({
    super.key,
    required this.value,
    required this.style,
    this.isCurrency = true,
    this.duration = const Duration(milliseconds: 600),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final text = isCurrency ? CurrencyFormatter.format(val) : val.toInt().toString();
        return Text(text, style: style);
      },
    );
  }
}
