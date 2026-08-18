import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'blueprint_grid_background.dart';
import 'dot_grid_background.dart';
import 'hazard_stripe_widget.dart';

/// Neo-Brutalist Monolithic Card Widget (Maximalist Industrial Edition)
/// Features high-contrast solid borders, hard 0-blur offset shadows, and tactile mechanical press animation.
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
  final bool showHazardHeader;
  final bool showDotGrid;
  final bool showBlueprintGrid;
  final BlueprintPatternType patternType;

  const NeoBrutalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.5,
    this.borderRadius = 10.0,
    this.shadowOffset = const Offset(4.0, 4.0),
    this.shadowColor,
    this.onTap,
    this.animateOnTap = true,
    this.showHazardHeader = false,
    this.showDotGrid = false,
    this.showBlueprintGrid = false,
    this.patternType = BlueprintPatternType.blueprintGrid,
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
        (isDark ? const Color(0xFF000000) : const Color(0xFF0F172A));

    final currentOffset = (_isPressed && widget.onTap != null && widget.animateOnTap)
        ? const Offset(1.0, 1.0)
        : widget.shadowOffset;

    Widget cardBody = widget.child;
    if (widget.showBlueprintGrid) {
      cardBody = BlueprintGridBackground(
        patternType: widget.patternType,
        child: cardBody,
      );
    } else if (widget.showDotGrid) {
      cardBody = DotGridBackground(
        dotColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        child: cardBody,
      );
    }

    Widget result = Container(
      margin: widget.margin,
      child: Transform.translate(
        offset: (_isPressed && widget.onTap != null && widget.animateOnTap)
            ? const Offset(2.5, 2.5)
            : Offset.zero,
        child: Container(
          clipBehavior: Clip.antiAlias,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showHazardHeader)
                const HazardStripeWidget(height: 6),
              Padding(
                padding: widget.padding ?? const EdgeInsets.all(16),
                child: cardBody,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.onTap != null) {
      result = GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
        },
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
