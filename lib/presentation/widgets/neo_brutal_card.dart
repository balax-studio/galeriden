import 'package:flutter/material.dart';

/// Neo-Brutalist Monolithic Card Widget
/// Features high-contrast solid borders, hard offset shadows, and tactile press animation.
class NeoBrutalCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final Color? shadowColor;
  final VoidCallback? onTap;
  final bool animateOnTap;

  const NeoBrutalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.borderRadius = 12.0,
    this.shadowOffset = const Offset(3.5, 3.5),
    this.shadowColor,
    this.onTap,
    this.animateOnTap = true,
  });

  @override
  State<NeoBrutalCard> createState() => _NeoBrutalCardState();
}

class _NeoBrutalCardState extends State<NeoBrutalCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveBg = widget.backgroundColor ??
        (isDark ? const Color(0xFF161922) : Colors.white);
    final effectiveBorder = widget.borderColor ??
        (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A));
    final effectiveShadow = widget.shadowColor ??
        (isDark ? const Color(0xFF07090E) : const Color(0xFF0F172A));

    final currentOffset = (_isPressed && widget.onTap != null && widget.animateOnTap)
        ? const Offset(1.0, 1.0)
        : widget.shadowOffset;

    Widget result = Container(
      margin: widget.margin,
      child: Transform.translate(
        offset: (_isPressed && widget.onTap != null && widget.animateOnTap)
            ? const Offset(2.0, 2.0)
            : Offset.zero,
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: effectiveBg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: effectiveBorder,
              width: widget.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveShadow,
                offset: currentOffset,
                blurRadius: 0,
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );

    if (widget.onTap != null) {
      result = GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    return result;
  }
}
