import 'package:flutter/material.dart';

/// Neo-Brutalist Potentiometer Rectangular Thumb Shape
/// Features a chunky rectangular block thumb with a 2px solid black border,
/// a hard 0-blur drop shadow, and tactile center grip notches.
class NeoBrutalRectangularThumbShape extends SliderComponentShape {
  final double thumbWidth;
  final double thumbHeight;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;
  final double shadowOffsetDistance;

  const NeoBrutalRectangularThumbShape({
    this.thumbWidth = 20.0,
    this.thumbHeight = 26.0,
    this.fillColor = const Color(0xFFFFDE59),
    this.borderColor = Colors.black,
    this.borderWidth = 2.2,
    this.shadowOffsetDistance = 2.5,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size(thumbWidth, thumbHeight);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final rect = Rect.fromCenter(
      center: center,
      width: thumbWidth,
      height: thumbHeight,
    );

    // Hard 0-blur black shadow
    final shadowRect = rect.shift(Offset(shadowOffsetDistance, shadowOffsetDistance));
    final shadowPaint = Paint()..color = Colors.black;
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, const Radius.circular(4)),
      shadowPaint,
    );

    // Thumb Body
    final fillPaint = Paint()..color = fillColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(rrect, fillPaint);
    canvas.drawRRect(rrect, borderPaint);

    // Center tactile grip notches
    final gripPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - 3.5, center.dy - 6.5),
      Offset(center.dx - 3.5, center.dy + 6.5),
      gripPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 6.5),
      Offset(center.dx, center.dy + 6.5),
      gripPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 3.5, center.dy - 6.5),
      Offset(center.dx + 3.5, center.dy + 6.5),
      gripPaint,
    );
  }
}

/// Neo-Brutalist Chunky Slider Track Shape with Black Border
class NeoBrutalSliderTrackShape extends RoundedRectSliderTrackShape {
  final double trackBorderWidth;
  final Color trackBorderColor;

  const NeoBrutalSliderTrackShape({
    this.trackBorderWidth = 1.8,
    this.trackBorderColor = Colors.black,
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isDiscrete = false,
    bool isEnabled = false,
    double additionalActiveTrackHeight = 0,
  }) {
    super.paint(
      context,
      offset,
      parentBox: parentBox,
      sliderTheme: sliderTheme,
      enableAnimation: enableAnimation,
      textDirection: textDirection,
      thumbCenter: thumbCenter,
      secondaryOffset: secondaryOffset,
      isDiscrete: isDiscrete,
      isEnabled: isEnabled,
      additionalActiveTrackHeight: additionalActiveTrackHeight,
    );

    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final borderPaint = Paint()
      ..color = trackBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackBorderWidth;

    canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, const Radius.circular(4)),
      borderPaint,
    );
  }
}
