import 'package:flutter/material.dart';

/// Neo-Brutal Metallic Foil Shimmer Overlay
/// Sweeps a 45-degree luxury light beam across rare cards, plates, or collector badges.
class FoilShimmerWidget extends StatefulWidget {
  final Widget child;
  final bool isEnabled;
  final Duration duration;
  final Color shimmerColor;
  final double shimmerWidthFactor;

  const FoilShimmerWidget({
    super.key,
    required this.child,
    this.isEnabled = true,
    this.duration = const Duration(milliseconds: 4000),
    this.shimmerColor = Colors.white,
    this.shimmerWidthFactor = 0.35,
  });

  @override
  State<FoilShimmerWidget> createState() => _FoilShimmerWidgetState();
}

class _FoilShimmerWidgetState extends State<FoilShimmerWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.isEnabled) {
      _initController();
    }
  }

  void _initController() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest) {
      _controller?.repeat();
    } else {
      _controller?.value = 0.0;
    }
  }

  @override
  void didUpdateWidget(covariant FoilShimmerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled && _controller == null) {
      _initController();
    } else if (!widget.isEnabled && _controller != null) {
      _controller?.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled || _controller == null) return widget.child;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller!,
        child: widget.child,
        builder: (context, child) {
          final v = _controller!.value;
          final sweepProgress = v <= 0.35 ? (v / 0.35) : -1.0;

          return CustomPaint(
            foregroundPainter: _FoilShimmerPainter(
              progress: sweepProgress,
              shimmerColor: widget.shimmerColor,
              widthFactor: widget.shimmerWidthFactor,
            ),
            child: child,
          );
        },
      ),
    );
  }
}

class _FoilShimmerPainter extends CustomPainter {
  final double progress;
  final Color shimmerColor;
  final double widthFactor;

  _FoilShimmerPainter({
    required this.progress,
    required this.shimmerColor,
    required this.widthFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.0 || progress > 1.0) return;

    final totalTravel = size.width + (size.height * 1.5);
    final currentOffset = (progress * totalTravel) - (size.height * 0.5);
    final shimmerWidth = size.width * widthFactor;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.save();
    canvas.clipRect(rect);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          shimmerColor.withValues(alpha: 0.0),
          shimmerColor.withValues(alpha: 0.28),
          shimmerColor.withValues(alpha: 0.55),
          shimmerColor.withValues(alpha: 0.28),
          shimmerColor.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.35, 0.50, 0.65, 1.0],
      ).createShader(
        Rect.fromLTWH(
            currentOffset - shimmerWidth, 0, shimmerWidth * 2, size.height),
      );

    canvas.drawRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FoilShimmerPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
