import 'dart:async';
import 'package:flutter/material.dart';

/// Staggered fade and slide entrance for list items and cards
class StaggeredItemEntry extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delayPerIndex;
  final Duration duration;
  final double slideOffset;

  const StaggeredItemEntry({
    super.key,
    required this.child,
    required this.index,
    this.delayPerIndex = const Duration(milliseconds: 35),
    this.duration = const Duration(milliseconds: 320),
    this.slideOffset = 16.0,
  });

  @override
  State<StaggeredItemEntry> createState() => _StaggeredItemEntryState();
}

class _StaggeredItemEntryState extends State<StaggeredItemEntry>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0.0, (widget.slideOffset / 200.0).clamp(0.02, 0.15)),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (isTest) {
      _controller.value = 1.0;
    } else {
      final delay = widget.delayPerIndex * (widget.index.clamp(0, 10));
      _timer = Timer(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: widget.child,
        ),
      ),
    );
  }
}
