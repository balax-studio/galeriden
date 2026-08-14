import 'package:flutter/material.dart';
import '../../core/services/game_sound_haptic_service.dart';

/// Premium Metallic Glass Tactile Button with spring physics scaling (scale 0.95)
class AppTactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final BoxDecoration? decoration;
  final bool enableHaptics;
  final Color? color;
  final Color? glowColor;

  const AppTactileButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding,
    this.decoration,
    this.enableHaptics = true,
    this.color,
    this.glowColor,
  });

  /// Primary Metallic Gold / Amber Gradient Action Button
  factory AppTactileButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    required VoidCallback? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    Color color = const Color(0xFFE5B869),
  }) {
    return AppTactileButton(
      key: key,
      onPressed: onPressed,
      padding: padding,
      color: color,
      glowColor: color.withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Secondary Cyan / Emerald Action Button
  factory AppTactileButton.secondary({
    Key? key,
    required String label,
    IconData? icon,
    required VoidCallback? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    Color color = const Color(0xFF00E5FF),
  }) {
    return AppTactileButton(
      key: key,
      onPressed: onPressed,
      padding: padding,
      color: color,
      glowColor: color.withValues(alpha: 0.35),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.black),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  /// Success Metallic Green Button
  factory AppTactileButton.success({
    Key? key,
    required String label,
    IconData? icon,
    required VoidCallback? onPressed,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    return AppTactileButton.secondary(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      padding: padding,
      color: const Color(0xFF2ECC71),
    );
  }

  @override
  State<AppTactileButton> createState() => _AppTactileButtonState();
}

class _AppTactileButtonState extends State<AppTactileButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      if (widget.enableHaptics) {
        GameSoundHapticService.playClick();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _controller.reverse();
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    BoxDecoration effectiveDecoration;

    if (widget.decoration != null) {
      effectiveDecoration = widget.decoration!;
    } else if (widget.color != null) {
      final baseColor = widget.color!;
      final isDark = ThemeData.estimateBrightnessForColor(baseColor) == Brightness.dark;

      effectiveDecoration = BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(baseColor, Colors.white, 0.28)!,
            baseColor,
            Color.lerp(baseColor, Colors.black, 0.22)!,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.25 : 0.45),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.glowColor ?? baseColor).withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      );
    } else {
      effectiveDecoration = const BoxDecoration();
    }

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          padding: widget.padding,
          decoration: effectiveDecoration,
          child: widget.child,
        ),
      ),
    );
  }
}
