import 'package:flutter/material.dart';
import 'app_vector_icons.dart';

/// Interactive & Customizable Dealership Logo Badge
/// Supports 5 badge frame shapes, 8 brand accent colors, and 18 vector emblems
class DealershipLogoBadge extends StatelessWidget {
  final String emblemId;
  final String badgeShape; // 'square', 'circle', 'shield', 'hexagon', 'laurel'
  final String badgeColor; // 'yellow', 'blue', 'red', 'green', 'purple', 'dark', 'cyan', 'orange'
  final double size;
  final Color? iconColor;
  final bool showBorder;
  final bool showShadow;

  const DealershipLogoBadge({
    super.key,
    required this.emblemId,
    this.badgeShape = 'square',
    this.badgeColor = 'yellow',
    this.size = 48.0,
    this.iconColor,
    this.showBorder = true,
    this.showShadow = true,
  });

  static Color getBackgroundColor(String colorKey) {
    switch (colorKey) {
      case 'blue':
        return const Color(0xFF3B82F6);
      case 'red':
        return const Color(0xFFEF4444);
      case 'green':
        return const Color(0xFF10B981);
      case 'purple':
        return const Color(0xFFA855F7);
      case 'dark':
        return const Color(0xFF1E293B);
      case 'cyan':
        return const Color(0xFF06B6D4);
      case 'orange':
        return const Color(0xFFF97316);
      case 'yellow':
      default:
        return const Color(0xFFFFDE59);
    }
  }

  static Color getContrastIconColor(String colorKey) {
    switch (colorKey) {
      case 'blue':
      case 'red':
      case 'purple':
      case 'dark':
      case 'orange':
        return Colors.white;
      case 'green':
      case 'cyan':
      case 'yellow':
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = getBackgroundColor(badgeColor);
    final effectiveIconColor = iconColor ?? getContrastIconColor(badgeColor);
    final iconSize = size * 0.56;

    Widget emblemChild = Center(
      child: VectorIconWidget(
        type: emblemId,
        color: effectiveIconColor,
        size: iconSize,
      ),
    );

    switch (badgeShape) {
      case 'circle':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: showBorder ? Border.all(color: Colors.black, width: 2.2) : null,
            boxShadow: showShadow
                ? const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: emblemChild,
        );

      case 'shield':
        return ClipPath(
          clipper: _ShieldBadgeClipper(),
          child: Container(
            width: size,
            height: size * 1.08,
            decoration: BoxDecoration(
              color: bg,
              border: showBorder ? Border.all(color: Colors.black, width: 2.2) : null,
              boxShadow: showShadow
                  ? const [
                      BoxShadow(
                        color: Colors.black,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
            child: emblemChild,
          ),
        );

      case 'hexagon':
        return ClipPath(
          clipper: _HexagonBadgeClipper(),
          child: Container(
            width: size,
            height: size,
            color: bg,
            child: emblemChild,
          ),
        );

      case 'laurel':
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bg,
            border: Border.all(color: const Color(0xFFFFDE59), width: 2.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF0F172A),
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _LaurelWreathPainter(color: effectiveIconColor.withValues(alpha: 0.3)),
              ),
              emblemChild,
            ],
          ),
        );

      case 'square':
      default:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(size * 0.22),
            border: showBorder ? Border.all(color: Colors.black, width: 2.2) : null,
            boxShadow: showShadow
                ? const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: emblemChild,
        );
    }
  }
}

class _ShieldBadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.50, 0);
    path.lineTo(w, h * 0.18);
    path.lineTo(w, h * 0.62);
    path.quadraticBezierTo(w * 0.50, h, w * 0.50, h);
    path.quadraticBezierTo(0, h * 0.62, 0, h * 0.62);
    path.lineTo(0, h * 0.18);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _HexagonBadgeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(w * 0.50, 0);
    path.lineTo(w, h * 0.25);
    path.lineTo(w, h * 0.75);
    path.lineTo(w * 0.50, h);
    path.lineTo(0, h * 0.75);
    path.lineTo(0, h * 0.25);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _LaurelWreathPainter extends CustomPainter {
  final Color color;
  _LaurelWreathPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _LaurelWreathPainter oldDelegate) => oldDelegate.color != color;
}
