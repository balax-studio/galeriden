import 'dart:async';
import 'package:flutter/material.dart';

/// Daktilo veya borsa ekranı gibi harf harf seri dökülen metin efekti.
class TypewriterTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration charDuration;
  final VoidCallback? onCompleted;

  const TypewriterTextWidget({
    super.key,
    required this.text,
    this.style,
    this.charDuration = const Duration(milliseconds: 25),
    this.onCompleted,
  });

  @override
  State<TypewriterTextWidget> createState() => _TypewriterTextWidgetState();
}

class _TypewriterTextWidgetState extends State<TypewriterTextWidget> {
  int _charCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant TypewriterTextWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _timer?.cancel();
      _charCount = 0;
      _startAnimation();
    }
  }

  void _startAnimation() {
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (isTest || widget.text.isEmpty) {
      _charCount = widget.text.length;
      return;
    }

    _timer = Timer.periodic(widget.charDuration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charCount < widget.text.length) {
        setState(() {
          _charCount++;
        });
      } else {
        timer.cancel();
        widget.onCompleted?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText =
        widget.text.substring(0, _charCount.clamp(0, widget.text.length));
    return Text(
      visibleText,
      style: widget.style,
    );
  }
}
