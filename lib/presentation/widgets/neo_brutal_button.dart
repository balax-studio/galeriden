import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum NeoHapticType { selection, light, heavy, none }

/// Neo-Brutalist Tactile Button Widget (Maximalist Industrial Edition)
/// Features heavy-duty borders, solid 0-blur offset shadow, and mechanical click-down compression feedback.
class NeoBrutalButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final Offset shadowOffset;
  final EdgeInsetsGeometry padding;
  final bool fullWidth;
  final double fontSize;
  final FontWeight fontWeight;
  final bool uppercase;
  final NeoHapticType hapticType;
  final double? minHeight;

  const NeoBrutalButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 2.5,
    this.borderRadius = 8.0,
    this.shadowOffset = const Offset(3.5, 3.5),
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.fullWidth = false,
    this.fontSize = 13.0,
    this.fontWeight = FontWeight.w900,
    this.uppercase = false,
    this.hapticType = NeoHapticType.heavy,
    this.minHeight,
  });

  @override
  State<NeoBrutalButton> createState() => _NeoBrutalButtonState();
}

class _NeoBrutalButtonState extends State<NeoBrutalButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.onPressed != null;

    final effectiveBg = widget.backgroundColor ??
        (isDark ? const Color(0xFFE5C158) : const Color(0xFF0F172A));
    final effectiveText = widget.textColor ??
        (isDark ? const Color(0xFF07090E) : Colors.white);
    final effectiveBorder = widget.borderColor ??
        (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A));
    final effectiveShadow = isDark ? const Color(0xFF000000) : const Color(0xFF0F172A);

    final currentOffset = (_isPressed && isEnabled)
        ? const Offset(1.0, 1.0)
        : widget.shadowOffset;

    final effectiveMinHeight = widget.minHeight ?? (widget.fontSize < 12 ? 38.0 : 44.0);

    final buttonContent = ConstrainedBox(
      constraints: BoxConstraints(minHeight: effectiveMinHeight),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: isEnabled ? effectiveBg : (isDark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: isEnabled ? effectiveBorder : Colors.transparent,
            width: widget.borderWidth,
          ),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: effectiveShadow,
                    offset: currentOffset,
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: widget.fontSize + 4,
                color: isEnabled ? effectiveText : Colors.grey,
              ),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.uppercase ? widget.label.toUpperCase() : widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isEnabled ? effectiveText : Colors.grey,
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (!isEnabled) {
      return widget.fullWidth
          ? SizedBox(width: double.infinity, child: buttonContent)
          : buttonContent;
    }

    Widget result = Transform.translate(
      offset: _isPressed ? const Offset(2.5, 2.5) : Offset.zero,
      child: buttonContent,
    );

    if (widget.fullWidth) {
      result = SizedBox(width: double.infinity, child: result);
    }

    return GestureDetector(
      onTapDown: (_) {
        switch (widget.hapticType) {
          case NeoHapticType.selection:
            HapticFeedback.selectionClick();
            break;
          case NeoHapticType.light:
            HapticFeedback.lightImpact();
            break;
          case NeoHapticType.heavy:
            HapticFeedback.heavyImpact();
            break;
          case NeoHapticType.none:
            break;
        }
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: result,
    );
  }
}
