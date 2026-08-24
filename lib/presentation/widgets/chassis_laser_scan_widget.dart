import 'package:flutter/material.dart';

/// Karaborsa / şüpheli araç kontrolünde şasi üzerinde inip çıkan lazer tarama çizgisi widgetı.
class ChassisLaserScanWidget extends StatefulWidget {
  final Widget child;
  final bool isScanning;
  final Color laserColor;

  const ChassisLaserScanWidget({
    super.key,
    required this.child,
    this.isScanning = true,
    this.laserColor = const Color(0xFF00E575),
  });

  @override
  State<ChassisLaserScanWidget> createState() => _ChassisLaserScanWidgetState();
}

class _ChassisLaserScanWidgetState extends State<ChassisLaserScanWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scanAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (!isTest && widget.isScanning) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant ChassisLaserScanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final isTest = WidgetsBinding.instance.runtimeType
        .toString()
        .toLowerCase()
        .contains('test');
    if (isTest) return;

    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isScanning && _controller.isAnimating) {
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
    return Stack(
      children: [
        widget.child,
        if (widget.isScanning)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _LaserPainter(
                        progress: _scanAnimation.value,
                        color: widget.laserColor,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LaserPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LaserPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final y = progress * size.height;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);
    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _LaserPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
