import 'package:flutter/material.dart';

/// Neo-Brutalist Segmented Arcade Gauge
/// Renders discrete chunky tactile block segments with 1.5px solid black borders
/// and vibrant neon active fill, providing an authentic retro tycoon arcade meter.
class SegmentedArcadeGauge extends StatelessWidget {
  final int totalSegments;
  final int activeSegments;
  final Color activeColor;
  final double height;
  final double gap;

  const SegmentedArcadeGauge({
    super.key,
    this.totalSegments = 6,
    required this.activeSegments,
    this.activeColor = const Color(0xFFFFDE59),
    this.height = 12.0,
    this.gap = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: List.generate(totalSegments, (index) {
        final isActive = index < activeSegments;
        return Expanded(
          child: Container(
            height: height,
            margin: EdgeInsets.only(right: index == totalSegments - 1 ? 0 : gap),
            decoration: BoxDecoration(
              color: isActive
                  ? activeColor
                  : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: isDark ? const Color(0xFF475569) : Colors.black,
                width: 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.5),
                        offset: const Offset(1.0, 1.0),
                        blurRadius: 0,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
