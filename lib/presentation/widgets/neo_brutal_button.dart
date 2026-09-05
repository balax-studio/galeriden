import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';

enum NeoHapticType { selection, light, medium, heavy, none }

/// Neo-Brutalist Tactile Button Widget (Maximalist Industrial Edition)
/// Features heavy-duty borders, solid 0-blur offset shadow, and mechanical click-down compression feedback.
/// Includes hardware-grade anti-spam debouncing, loading spinner, and applied/success state transitions.
class NeoBrutalButton extends StatefulWidget {
  final String label;
  final String? appliedLabel;
  final IconData? icon;
  final IconData? appliedIcon;
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
  final bool isLoading;
  final bool isApplied;
  final Duration? debounceDuration;
  final IconData? loadingIcon;
  final String? loadingLabel;

  const NeoBrutalButton({
    super.key,
    String? label,
    String? text,
    this.appliedLabel,
    this.icon,
    this.appliedIcon = Icons.check_circle_rounded,
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
    this.isLoading = false,
    this.isApplied = false,
    this.debounceDuration = const Duration(milliseconds: 350),
    this.loadingIcon,
    this.loadingLabel,
  }) : label = label ?? text ?? '';

  @override
  State<NeoBrutalButton> createState() => _NeoBrutalButtonState();
}

class _NeoBrutalButtonState extends State<NeoBrutalButton> {
  bool _isPressed = false;
  bool _isDebouncing = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onPressed == null ||
        widget.isLoading ||
        widget.isApplied ||
        _isDebouncing) {
      return;
    }

    if (widget.debounceDuration != null) {
      _isDebouncing = true;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(widget.debounceDuration!, () {
        if (mounted) {
          setState(() {
            _isDebouncing = false;
          });
        }
      });
    }

    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled =
        widget.onPressed != null && !widget.isLoading && !widget.isApplied;

    Color effectiveBg;
    if (widget.isApplied) {
      effectiveBg = AppColors.brutalGreen;
    } else if (isEnabled) {
      effectiveBg = widget.backgroundColor ??
          (isDark ? const Color(0xFFE5C158) : const Color(0xFF0F172A));
    } else {
      effectiveBg = isDark ? Colors.white12 : Colors.black12;
    }

    Color effectiveText;
    if (widget.isApplied) {
      effectiveText = Colors.black;
    } else if (isEnabled) {
      effectiveText =
          widget.textColor ?? (isDark ? const Color(0xFF07090E) : Colors.white);
    } else {
      effectiveText = Colors.grey;
    }

    final effectiveBorder = widget.borderColor ??
        (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A));
    final effectiveShadow =
        isDark ? const Color(0xFF000000) : const Color(0xFF0F172A);

    final currentOffset = (_isPressed && isEnabled)
        ? const Offset(1.0, 1.0)
        : widget.shadowOffset;

    final effectiveMinHeight =
        widget.minHeight ?? (widget.fontSize < 12 ? 38.0 : 48.0);

    final displayLabel = widget.isApplied
        ? (widget.appliedLabel ?? 'UYGULANDI')
        : (widget.uppercase ? widget.label.toUpperCase() : widget.label);

    final displayIcon = widget.isApplied ? widget.appliedIcon : widget.icon;

    final buttonContent = ConstrainedBox(
      constraints: BoxConstraints(minHeight: effectiveMinHeight),
      child: Container(
        padding: widget.padding,
        decoration: BoxDecoration(
          color: effectiveBg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: (isEnabled || widget.isApplied)
                ? effectiveBorder
                : Colors.transparent,
            width: widget.borderWidth,
          ),
          boxShadow: (isEnabled || widget.isApplied)
              ? [
                  BoxShadow(
                    color: effectiveShadow,
                    offset: currentOffset,
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: widget.isLoading
            ? Row(
                mainAxisSize:
                    widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loadingIcon != null)
                    Icon(
                      widget.loadingIcon,
                      color: effectiveText,
                      size: widget.fontSize + 4,
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .rotate(duration: 1200.ms, curve: Curves.linear)
                        .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 600.ms, curve: Curves.easeInOutSine)
                        .then(delay: 0.ms)
                        .scale(begin: const Offset(1.1, 1.1), end: const Offset(0.8, 0.8), duration: 600.ms, curve: Curves.easeInOutSine)
                  else
                    SizedBox(
                      width: widget.fontSize + 2,
                      height: widget.fontSize + 2,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.loadingLabel ?? context.tr('btn_processing'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: effectiveText,
                          fontSize: widget.fontSize,
                          fontWeight: widget.fontWeight,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisSize:
                    widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (displayIcon != null) ...[
                    Icon(
                      displayIcon,
                      size: widget.fontSize + 4,
                      color: effectiveText,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        displayLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: effectiveText,
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

    if (widget.isApplied) {
      Widget appliedResult = buttonContent.animate(key: const ValueKey('applied'))
          .scale(begin: const Offset(0.85, 0.85), end: const Offset(1.0, 1.0), duration: 500.ms, curve: Curves.elasticOut)
          .shimmer(duration: 800.ms, color: Colors.white54);
      return widget.fullWidth
          ? SizedBox(width: double.infinity, child: appliedResult)
          : appliedResult;
    }

    if (!isEnabled) {
      return widget.fullWidth
          ? SizedBox(width: double.infinity, child: buttonContent)
          : buttonContent;
    }

    Widget result = buttonContent.animate(target: _isPressed ? 1 : 0)
        .move(end: const Offset(2.5, 2.5), duration: 100.ms, curve: Curves.easeOutQuad)
        .scale(end: const Offset(0.97, 0.97), duration: 100.ms, curve: Curves.easeOutQuad);

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
          case NeoHapticType.medium:
            HapticFeedback.mediumImpact();
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
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: result,
    );
  }
}
