import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';

/// Ağır hasarlı / tavanı boyalı araçlarda beliren çatlak cam dokusu ve mikro titreme rozeti.
class CrackedGlassBadge extends StatefulWidget {
  final double size;
  final bool showLabel;

  const CrackedGlassBadge({
    super.key,
    this.size = 28,
    this.showLabel = false,
  });

  @override
  State<CrackedGlassBadge> createState() => _CrackedGlassBadgeState();
}

class _CrackedGlassBadgeState extends State<CrackedGlassBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = math.sin(_shakeAnimation.value * math.pi * 6) * 3;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(1.5, 1.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                size: Size(widget.size * 0.7, widget.size * 0.7),
                painter: _CrackedGlassPainter(),
              ),
              if (widget.showLabel) ...[
                const SizedBox(width: 4),
                Text(
                  context.tr('sticker_cracked_glass'),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CrackedGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Cracked glass spider web lines
    final path = Path()
      ..moveTo(w * 0.1, h * 0.2)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.9, h * 0.3)
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.4, h * 0.9)
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.85, h * 0.8)
      ..moveTo(w * 0.3, h * 0.35)
      ..lineTo(w * 0.2, h * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
