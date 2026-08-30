import 'package:flutter/material.dart';

/// Neo-Brutalist Duct Tape Corner Overlay
/// Simulates rugged industrial packing/electrical tape stuck onto cards or car photos
/// with jagged ripped ends, translucent matte tint, and bold uppercase text.
class DuctTapeCorner extends StatelessWidget {
  final String text;
  final Color tapeColor;
  final Color textColor;
  final double angle;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const DuctTapeCorner({
    super.key,
    required this.text,
    this.tapeColor = const Color(0xFFFFDE59),
    this.textColor = const Color(0xFF0F172A),
    this.angle = -0.15,
    this.fontSize = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 3.5),
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              offset: const Offset(2, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipPath(
          clipper: _JaggedTapeClipper(),
          child: Container(
            padding: padding,
            color: tapeColor.withValues(alpha: 0.95),
            child: Text(
              text.toUpperCase(),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: textColor,
                letterSpacing: 1.0,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JaggedTapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const ripDepth = 4.0;

    // Start top-left with torn zig-zag
    path.moveTo(0, 0);
    path.lineTo(ripDepth, size.height * 0.25);
    path.lineTo(0, size.height * 0.5);
    path.lineTo(ripDepth, size.height * 0.75);
    path.lineTo(0, size.height);

    // Bottom edge
    path.lineTo(size.width, size.height);

    // Right torn zig-zag
    path.lineTo(size.width - ripDepth, size.height * 0.75);
    path.lineTo(size.width, size.height * 0.5);
    path.lineTo(size.width - ripDepth, size.height * 0.25);
    path.lineTo(size.width, 0);

    // Top edge
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant _JaggedTapeClipper oldClipper) => false;
}
