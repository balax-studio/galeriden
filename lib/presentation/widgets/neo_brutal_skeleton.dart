import 'package:flutter/material.dart';
import '../../core/theme/app_theme_extension.dart';

/// Neo-Brutalist Pure Flutter Zero-Dependency Skeleton / Shimmer Box
class NeoBrutalSkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const NeoBrutalSkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  @override
  State<NeoBrutalSkeletonBox> createState() => _NeoBrutalSkeletonBoxState();
}

class _NeoBrutalSkeletonBoxState extends State<NeoBrutalSkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _animation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ?? Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark ? const Color(0xFF1B202E) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF2C354B) : const Color(0xFFF8FAFC);
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle ? null : BorderRadius.circular(widget.borderRadius),
            border: Border.all(color: borderColor, width: 2.0),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor,
                offset: const Offset(2.0, 2.0),
                blurRadius: 0,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Neo-Brutalist Skeleton Car Card matching Showroom & Marketplace layout
class NeoBrutalSkeletonCarCard extends StatelessWidget {
  const NeoBrutalSkeletonCarCard({super.key});

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ?? Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF141721) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title & badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const NeoBrutalSkeletonBox(width: 150, height: 18),
              NeoBrutalSkeletonBox(width: 60, height: 16, borderRadius: 6),
            ],
          ),
          const SizedBox(height: 12),

          // Center Image / Vehicle Placeholder Box
          const NeoBrutalSkeletonBox(
            width: double.infinity,
            height: 90,
            borderRadius: 10,
          ),
          const SizedBox(height: 12),

          // Specs / Financials Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              NeoBrutalSkeletonBox(width: 80, height: 14),
              NeoBrutalSkeletonBox(width: 90, height: 14),
              NeoBrutalSkeletonBox(width: 80, height: 14),
            ],
          ),
          const SizedBox(height: 12),

          // Action Buttons Row
          Row(
            children: const [
              Expanded(child: NeoBrutalSkeletonBox(width: double.infinity, height: 36, borderRadius: 8)),
              SizedBox(width: 8),
              Expanded(child: NeoBrutalSkeletonBox(width: double.infinity, height: 36, borderRadius: 8)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton List View for instant placeholder rendering
class NeoBrutalSkeletonList extends StatelessWidget {
  final int itemCount;

  const NeoBrutalSkeletonList({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      itemBuilder: (context, index) => const NeoBrutalSkeletonCarCard(),
    );
  }
}
