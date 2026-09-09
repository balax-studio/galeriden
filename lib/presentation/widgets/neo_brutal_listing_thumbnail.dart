import 'package:flutter/material.dart';

import '../../data/models/real_estate_category.dart';
import '../../data/models/vehicle_category.dart';

/// Neo-Brutalist Listing Thumbnail for Vehicles (Vasıta) and Real Estate (Emlak).
///
/// Features:
/// - Warm parchment/yellowish neo-brutal tactile pod (comfortable for the eyes).
/// - Bold 2.0px solid border with zero-blur offset block shadow.
/// - Type-specific 2D vector blueprint illustration for every category.
/// - 100% scalable vector geometry with zero external asset dependencies.
class VasitaListingThumbnail extends StatelessWidget {
  final VehicleCategory category;
  final String? bodyType;
  final String? colorHex;
  final bool isDark;
  final double width;
  final double height;

  const VasitaListingThumbnail({
    super.key,
    required this.category,
    this.bodyType,
    this.colorHex,
    this.isDark = false,
    this.width = 62.0,
    this.height = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    // Warm neo-brutalist parchment yellow with subtle category tint
    final bgColor = isDark
        ? const Color(0xFF181C26)
        : Color.alphaBlend(
            category.badgeColor.withValues(alpha: 0.12),
            const Color(0xFFFEF9C3),
          );

    final borderColor =
        isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A);
    final shadowColor = isDark ? Colors.black54 : const Color(0xFF0F172A);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(2.0, 2.0),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          size: Size(width, height),
          painter: _VasitaVectorPainter(
            category: category,
            accentColor: category.badgeColor,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// Custom Vector Painter for Vehicle Categories in Vasıta Pazarı
class _VasitaVectorPainter extends CustomPainter {
  final VehicleCategory category;
  final Color accentColor;
  final bool isDark;

  _VasitaVectorPainter({
    required this.category,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final inkColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final strokePaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final tirePaint = Paint()
      ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;

    final glassPaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: isDark ? 0.45 : 0.65)
      ..style = PaintingStyle.fill;

    // Background Dot Matrix
    final dotPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF0F172A))
          .withValues(alpha: 0.07)
      ..style = PaintingStyle.fill;
    for (double dx = 6; dx < w; dx += 8) {
      for (double dy = 6; dy < h; dy += 8) {
        canvas.drawCircle(Offset(dx, dy), 1.0, dotPaint);
      }
    }

    switch (category) {
      case VehicleCategory.motorcycle:
        _drawMotorcycle(
            canvas, w, h, strokePaint, fillPaint, tirePaint, rimPaint);
        break;
      case VehicleCategory.minivan:
        _drawMinivan(canvas, w, h, strokePaint, fillPaint, tirePaint, rimPaint,
            glassPaint);
        break;
      case VehicleCategory.commercial:
        _drawCommercialTruck(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint);
        break;
      case VehicleCategory.marine:
        _drawMarine(canvas, w, h, strokePaint, fillPaint, glassPaint);
        break;
      case VehicleCategory.caravan:
        _drawCaravan(canvas, w, h, strokePaint, fillPaint, tirePaint, rimPaint,
            glassPaint);
        break;
      case VehicleCategory.aircraft:
        _drawAircraft(canvas, w, h, strokePaint, fillPaint, glassPaint);
        break;
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        _drawOffRoad(canvas, w, h, strokePaint, fillPaint, tirePaint, rimPaint);
        break;
      case VehicleCategory.damaged:
        _drawDamagedVehicle(canvas, w, h, strokePaint, fillPaint, tirePaint);
        break;
      case VehicleCategory.classic:
        _drawClassicCar(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint);
        break;
      case VehicleCategory.car:
      case VehicleCategory.rentalFleet:
        _drawFleetSedan(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint);
        break;
    }
  }

  void _drawMinivan(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
  ) {
    // Minivan / Doblo / Transit boxy body
    final body = Path()
      ..moveTo(w * 0.12, h * 0.72)
      ..lineTo(w * 0.12, h * 0.28)
      ..lineTo(w * 0.65, h * 0.28)
      ..lineTo(w * 0.78, h * 0.48)
      ..lineTo(w * 0.88, h * 0.52)
      ..lineTo(w * 0.88, h * 0.72)
      ..close();

    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Front windshield & side window
    final window = Path()
      ..moveTo(w * 0.46, h * 0.32)
      ..lineTo(w * 0.63, h * 0.32)
      ..lineTo(w * 0.73, h * 0.48)
      ..lineTo(w * 0.46, h * 0.48)
      ..close();
    canvas.drawPath(window, glass);
    canvas.drawPath(window, stroke);

    // Rear cargo window
    final rearWindow = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.18, h * 0.32, w * 0.42, h * 0.48),
        const Radius.circular(2),
      ));
    canvas.drawPath(rearWindow, glass);
    canvas.drawPath(rearWindow, stroke);

    // Sliding door seam
    canvas.drawLine(
        Offset(w * 0.44, h * 0.30), Offset(w * 0.44, h * 0.70), stroke);

    // Wheels
    _drawWheel(canvas, Offset(w * 0.28, h * 0.72), w * 0.10, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.74, h * 0.72), w * 0.10, tire, rim, stroke);
  }

  void _drawMotorcycle(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
  ) {
    // Twin Wheels
    _drawWheel(canvas, Offset(w * 0.24, h * 0.68), w * 0.12, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.76, h * 0.68), w * 0.12, tire, rim, stroke);

    // Motorcycle Frame & Gas Tank
    final tank = Path()
      ..moveTo(w * 0.40, h * 0.38)
      ..lineTo(w * 0.64, h * 0.36)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.36, h * 0.48)
      ..close();
    canvas.drawPath(tank, fill);
    canvas.drawPath(tank, stroke);

    // Fork and Handlebars
    canvas.drawLine(
        Offset(w * 0.60, h * 0.36), Offset(w * 0.76, h * 0.68), stroke);
    canvas.drawLine(
        Offset(w * 0.60, h * 0.36), Offset(w * 0.64, h * 0.26), stroke);
    canvas.drawLine(
        Offset(w * 0.60, h * 0.26), Offset(w * 0.68, h * 0.26), stroke);

    // Seat & Swingarm
    canvas.drawLine(
        Offset(w * 0.36, h * 0.48), Offset(w * 0.24, h * 0.68), stroke);
    canvas.drawLine(
        Offset(w * 0.28, h * 0.42), Offset(w * 0.40, h * 0.42), stroke);

    // Engine block
    canvas.drawRect(
      Rect.fromLTRB(w * 0.40, h * 0.52, w * 0.54, h * 0.66),
      fill,
    );
    canvas.drawRect(
      Rect.fromLTRB(w * 0.40, h * 0.52, w * 0.54, h * 0.66),
      stroke,
    );
  }

  void _drawCommercialTruck(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
  ) {
    // Cargo Box
    final box = Rect.fromLTRB(w * 0.10, h * 0.22, w * 0.60, h * 0.68);
    canvas.drawRect(box, fill);
    canvas.drawRect(box, stroke);
    // Vertical Box Ribs
    canvas.drawLine(
        Offset(w * 0.26, h * 0.22), Offset(w * 0.26, h * 0.68), stroke);
    canvas.drawLine(
        Offset(w * 0.44, h * 0.22), Offset(w * 0.44, h * 0.68), stroke);

    // Cab
    final cab = Path()
      ..moveTo(w * 0.60, h * 0.34)
      ..lineTo(w * 0.82, h * 0.34)
      ..lineTo(w * 0.88, h * 0.48)
      ..lineTo(w * 0.88, h * 0.68)
      ..lineTo(w * 0.60, h * 0.68)
      ..close();
    canvas.drawPath(cab, fill);
    canvas.drawPath(cab, stroke);

    // Cab Windshield
    final windshield = Path()
      ..moveTo(w * 0.66, h * 0.38)
      ..lineTo(w * 0.80, h * 0.38)
      ..lineTo(w * 0.84, h * 0.48)
      ..lineTo(w * 0.66, h * 0.48)
      ..close();
    canvas.drawPath(windshield, glass);
    canvas.drawPath(windshield, stroke);

    // Wheels
    _drawWheel(canvas, Offset(w * 0.22, h * 0.72), w * 0.09, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.42, h * 0.72), w * 0.09, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.78, h * 0.72), w * 0.09, tire, rim, stroke);
  }

  void _drawMarine(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint glass,
  ) {
    // Water waves below
    final wave = Path()
      ..moveTo(w * 0.08, h * 0.78)
      ..quadraticBezierTo(w * 0.25, h * 0.70, w * 0.42, h * 0.78)
      ..quadraticBezierTo(w * 0.60, h * 0.86, w * 0.78, h * 0.78)
      ..quadraticBezierTo(w * 0.88, h * 0.72, w * 0.94, h * 0.76);
    canvas.drawPath(wave, stroke);

    // Yacht / Speedboat hull
    final hull = Path()
      ..moveTo(w * 0.10, h * 0.52)
      ..lineTo(w * 0.14, h * 0.70)
      ..lineTo(w * 0.72, h * 0.70)
      ..lineTo(w * 0.88, h * 0.46)
      ..lineTo(w * 0.68, h * 0.48)
      ..lineTo(w * 0.10, h * 0.52)
      ..close();
    canvas.drawPath(hull, fill);
    canvas.drawPath(hull, stroke);

    // Cabin
    final cabin = Path()
      ..moveTo(w * 0.28, h * 0.50)
      ..lineTo(w * 0.32, h * 0.36)
      ..lineTo(w * 0.58, h * 0.36)
      ..lineTo(w * 0.64, h * 0.48)
      ..close();
    canvas.drawPath(cabin, glass);
    canvas.drawPath(cabin, stroke);

    // Radar arch
    canvas.drawLine(
        Offset(w * 0.34, h * 0.36), Offset(w * 0.34, h * 0.24), stroke);
  }

  void _drawCaravan(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
  ) {
    // Caravan pod
    final pod = Path()
      ..addRRect(RRect.fromRectAndCorners(
        Rect.fromLTRB(w * 0.14, h * 0.24, w * 0.74, h * 0.68),
        topLeft: const Radius.circular(10),
        topRight: const Radius.circular(10),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      ));
    canvas.drawPath(pod, fill);
    canvas.drawPath(pod, stroke);

    // Front hitch
    canvas.drawLine(
        Offset(w * 0.74, h * 0.64), Offset(w * 0.88, h * 0.64), stroke);

    // Side window with curtain line
    final window = Rect.fromLTRB(w * 0.32, h * 0.34, w * 0.58, h * 0.48);
    canvas.drawRect(window, glass);
    canvas.drawRect(window, stroke);
    canvas.drawLine(
        Offset(w * 0.45, h * 0.34), Offset(w * 0.45, h * 0.48), stroke);

    // Wheel
    _drawWheel(canvas, Offset(w * 0.44, h * 0.70), w * 0.11, tire, rim, stroke);
  }

  void _drawAircraft(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint glass,
  ) {
    // Propeller airplane fuselage
    final fuselage = Path()
      ..moveTo(w * 0.12, h * 0.44)
      ..lineTo(w * 0.80, h * 0.44)
      ..quadraticBezierTo(w * 0.86, h * 0.50, w * 0.80, h * 0.56)
      ..lineTo(w * 0.14, h * 0.56)
      ..close();
    canvas.drawPath(fuselage, fill);
    canvas.drawPath(fuselage, stroke);

    // Cockpit canopy
    final canopy = Path()
      ..moveTo(w * 0.54, h * 0.44)
      ..quadraticBezierTo(w * 0.64, h * 0.32, w * 0.74, h * 0.44)
      ..close();
    canvas.drawPath(canopy, glass);
    canvas.drawPath(canopy, stroke);

    // Wing
    canvas.drawLine(
        Offset(w * 0.42, h * 0.48), Offset(w * 0.56, h * 0.22), stroke);
    canvas.drawLine(
        Offset(w * 0.44, h * 0.52), Offset(w * 0.58, h * 0.78), stroke);

    // Tail fin
    final tail = Path()
      ..moveTo(w * 0.14, h * 0.44)
      ..lineTo(w * 0.10, h * 0.26)
      ..lineTo(w * 0.20, h * 0.44)
      ..close();
    canvas.drawPath(tail, fill);
    canvas.drawPath(tail, stroke);

    // Front propeller
    canvas.drawLine(
        Offset(w * 0.86, h * 0.34), Offset(w * 0.86, h * 0.66), stroke);
  }

  void _drawOffRoad(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
  ) {
    // Oversized Knobby Tires
    _drawWheel(canvas, Offset(w * 0.25, h * 0.65), w * 0.13, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.75, h * 0.65), w * 0.13, tire, rim, stroke);

    // High chassis & roll-cage
    final chassis = Path()
      ..moveTo(w * 0.20, h * 0.54)
      ..lineTo(w * 0.38, h * 0.50)
      ..lineTo(w * 0.48, h * 0.32)
      ..lineTo(w * 0.66, h * 0.32)
      ..lineTo(w * 0.82, h * 0.52)
      ..lineTo(w * 0.78, h * 0.58)
      ..lineTo(w * 0.18, h * 0.58)
      ..close();
    canvas.drawPath(chassis, fill);
    canvas.drawPath(chassis, stroke);

    // Handlebars/Roll-bar
    canvas.drawLine(
        Offset(w * 0.48, h * 0.32), Offset(w * 0.42, h * 0.22), stroke);
    canvas.drawLine(
        Offset(w * 0.66, h * 0.32), Offset(w * 0.62, h * 0.22), stroke);
    canvas.drawLine(
        Offset(w * 0.40, h * 0.22), Offset(w * 0.64, h * 0.22), stroke);
  }

  void _drawDamagedVehicle(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
  ) {
    // Crushed car outline
    final crushed = Path()
      ..moveTo(w * 0.12, h * 0.68)
      ..lineTo(w * 0.15, h * 0.48)
      ..lineTo(w * 0.35, h * 0.36)
      ..lineTo(w * 0.55, h * 0.38)
      ..lineTo(w * 0.68, h * 0.54)
      ..lineTo(w * 0.84, h * 0.64)
      ..lineTo(w * 0.80, h * 0.68)
      ..close();
    canvas.drawPath(crushed, fill);
    canvas.drawPath(crushed, stroke);

    // Hazard collision burst lines
    canvas.drawLine(
        Offset(w * 0.68, h * 0.36), Offset(w * 0.78, h * 0.26), stroke);
    canvas.drawLine(
        Offset(w * 0.74, h * 0.42), Offset(w * 0.86, h * 0.40), stroke);
    canvas.drawLine(
        Offset(w * 0.70, h * 0.48), Offset(w * 0.82, h * 0.56), stroke);

    _drawWheel(
        canvas, Offset(w * 0.28, h * 0.68), w * 0.09, tire, stroke, stroke);
    _drawWheel(
        canvas, Offset(w * 0.72, h * 0.68), w * 0.09, tire, stroke, stroke);
  }

  void _drawClassicCar(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
  ) {
    // Rounded vintage fenders & roof
    final classic = Path()
      ..moveTo(w * 0.10, h * 0.64)
      ..quadraticBezierTo(w * 0.18, h * 0.46, w * 0.32, h * 0.50)
      ..quadraticBezierTo(w * 0.46, h * 0.26, w * 0.66, h * 0.36)
      ..quadraticBezierTo(w * 0.78, h * 0.44, w * 0.90, h * 0.64)
      ..close();
    canvas.drawPath(classic, fill);
    canvas.drawPath(classic, stroke);

    // Round windshield
    final window = Path()
      ..moveTo(w * 0.44, h * 0.48)
      ..quadraticBezierTo(w * 0.52, h * 0.32, w * 0.64, h * 0.40)
      ..close();
    canvas.drawPath(window, glass);
    canvas.drawPath(window, stroke);

    _drawWheel(canvas, Offset(w * 0.28, h * 0.66), w * 0.10, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.76, h * 0.66), w * 0.10, tire, rim, stroke);
  }

  void _drawFleetSedan(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
  ) {
    // Modern sedan body
    final body = Path()
      ..moveTo(w * 0.10, h * 0.66)
      ..lineTo(w * 0.16, h * 0.52)
      ..lineTo(w * 0.32, h * 0.52)
      ..lineTo(w * 0.46, h * 0.34)
      ..lineTo(w * 0.68, h * 0.34)
      ..lineTo(w * 0.80, h * 0.50)
      ..lineTo(w * 0.90, h * 0.54)
      ..lineTo(w * 0.90, h * 0.66)
      ..close();
    canvas.drawPath(body, fill);
    canvas.drawPath(body, stroke);

    // Windows
    final window = Path()
      ..moveTo(w * 0.36, h * 0.50)
      ..lineTo(w * 0.48, h * 0.38)
      ..lineTo(w * 0.66, h * 0.38)
      ..lineTo(w * 0.75, h * 0.50)
      ..close();
    canvas.drawPath(window, glass);
    canvas.drawPath(window, stroke);

    // Center pillar
    canvas.drawLine(
        Offset(w * 0.56, h * 0.38), Offset(w * 0.56, h * 0.50), stroke);

    _drawWheel(canvas, Offset(w * 0.28, h * 0.68), w * 0.09, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.74, h * 0.68), w * 0.09, tire, rim, stroke);
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, Paint tire,
      Paint rim, Paint stroke) {
    canvas.drawCircle(center, radius, tire);
    canvas.drawCircle(center, radius, stroke);
    canvas.drawCircle(center, radius * 0.45, rim);
    canvas.drawCircle(center, radius * 0.45, stroke);
  }

  @override
  bool shouldRepaint(covariant _VasitaVectorPainter oldDelegate) =>
      oldDelegate.category != category ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.isDark != isDark;
}

/// Neo-Brutalist Listing Thumbnail for Real Estate (Emlak)
class RealEstateListingThumbnail extends StatelessWidget {
  final RealEstateCategory category;
  final bool isDark;
  final double width;
  final double height;

  const RealEstateListingThumbnail({
    super.key,
    required this.category,
    this.isDark = false,
    this.width = 62.0,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark
        ? const Color(0xFF181C26)
        : Color.alphaBlend(
            category.accentColor.withValues(alpha: 0.12),
            const Color(0xFFFEF9C3),
          );

    final borderColor =
        isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A);
    final shadowColor = isDark ? Colors.black54 : const Color(0xFF0F172A);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(2.0, 2.0),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: CustomPaint(
          size: Size(width, height),
          painter: _RealEstateVectorPainter(
            category: category,
            accentColor: category.accentColor,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

/// Custom Vector Painter for Real Estate Categories in Emlak Pazarı
class _RealEstateVectorPainter extends CustomPainter {
  final RealEstateCategory category;
  final Color accentColor;
  final bool isDark;

  _RealEstateVectorPainter({
    required this.category,
    required this.accentColor,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final inkColor = isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final strokePaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    final windowPaint = Paint()
      ..color = isDark ? const Color(0xFF38BDF8) : const Color(0xFFFFDE59)
      ..style = PaintingStyle.fill;

    // Background Architectural Grid
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF0F172A))
          .withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    for (double dx = 6; dx < w; dx += 10) {
      canvas.drawLine(Offset(dx, 0), Offset(dx, h), gridPaint);
    }
    for (double dy = 6; dy < h; dy += 10) {
      canvas.drawLine(Offset(0, dy), Offset(w, dy), gridPaint);
    }

    switch (category) {
      case RealEstateCategory.housing:
        _drawHousing(canvas, w, h, strokePaint, fillPaint, windowPaint);
        break;
      case RealEstateCategory.commercial:
        _drawStorefront(canvas, w, h, strokePaint, fillPaint, windowPaint);
        break;
      case RealEstateCategory.land:
        _drawLandParcel(canvas, w, h, strokePaint, fillPaint);
        break;
      case RealEstateCategory.housingProjects:
        _drawTowers(canvas, w, h, strokePaint, fillPaint, windowPaint);
        break;
      case RealEstateCategory.building:
        _drawMultiStoryBuilding(
            canvas, w, h, strokePaint, fillPaint, windowPaint);
        break;
    }
  }

  void _drawHousing(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint window,
  ) {
    // Ground Baseline
    canvas.drawLine(
        Offset(w * 0.08, h * 0.86), Offset(w * 0.92, h * 0.86), stroke);

    // Chimney
    final chimney = Rect.fromLTRB(w * 0.65, h * 0.16, w * 0.74, h * 0.38);
    canvas.drawRect(chimney, fill);
    canvas.drawRect(chimney, stroke);

    // House Walls
    final house = Rect.fromLTRB(w * 0.20, h * 0.44, w * 0.80, h * 0.86);
    canvas.drawRect(
      house,
      Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(house, stroke);

    // Pitched Roof
    final roof = Path()
      ..moveTo(w * 0.14, h * 0.46)
      ..lineTo(w * 0.50, h * 0.14)
      ..lineTo(w * 0.86, h * 0.46)
      ..close();
    canvas.drawPath(roof, fill);
    canvas.drawPath(roof, stroke);

    // Front Door
    final door = Rect.fromLTRB(w * 0.42, h * 0.60, w * 0.58, h * 0.86);
    canvas.drawRect(door, fill);
    canvas.drawRect(door, stroke);

    // Window Left
    final win1 = Rect.fromLTRB(w * 0.24, h * 0.56, w * 0.36, h * 0.70);
    canvas.drawRect(win1, window);
    canvas.drawRect(win1, stroke);
    canvas.drawLine(
        Offset(w * 0.30, h * 0.56), Offset(w * 0.30, h * 0.70), stroke);

    // Window Right
    final win2 = Rect.fromLTRB(w * 0.64, h * 0.56, w * 0.76, h * 0.70);
    canvas.drawRect(win2, window);
    canvas.drawRect(win2, stroke);
    canvas.drawLine(
        Offset(w * 0.70, h * 0.56), Offset(w * 0.70, h * 0.70), stroke);
  }

  void _drawStorefront(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint window,
  ) {
    // Ground Baseline
    canvas.drawLine(
        Offset(w * 0.08, h * 0.86), Offset(w * 0.92, h * 0.86), stroke);

    // Building façade
    final wall = Rect.fromLTRB(w * 0.12, h * 0.20, w * 0.88, h * 0.86);
    canvas.drawRect(
      wall,
      Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(wall, stroke);

    // Awning Striped Canopy
    final awning = Path()
      ..moveTo(w * 0.10, h * 0.28)
      ..lineTo(w * 0.90, h * 0.28)
      ..lineTo(w * 0.86, h * 0.44)
      ..lineTo(w * 0.14, h * 0.44)
      ..close();
    canvas.drawPath(awning, fill);
    canvas.drawPath(awning, stroke);

    // Awning Stripes
    canvas.drawLine(
        Offset(w * 0.30, h * 0.28), Offset(w * 0.30, h * 0.44), stroke);
    canvas.drawLine(
        Offset(w * 0.50, h * 0.28), Offset(w * 0.50, h * 0.44), stroke);
    canvas.drawLine(
        Offset(w * 0.70, h * 0.28), Offset(w * 0.70, h * 0.44), stroke);

    // Store Display Window
    final display = Rect.fromLTRB(w * 0.18, h * 0.52, w * 0.58, h * 0.80);
    canvas.drawRect(display, window);
    canvas.drawRect(display, stroke);

    // Glass Reflection Line
    canvas.drawLine(
        Offset(w * 0.24, h * 0.74), Offset(w * 0.42, h * 0.58), stroke);

    // Entrance Glass Door
    final door = Rect.fromLTRB(w * 0.64, h * 0.50, w * 0.82, h * 0.86);
    canvas.drawRect(door, fill);
    canvas.drawRect(door, stroke);
    canvas.drawLine(
        Offset(w * 0.68, h * 0.68), Offset(w * 0.68, h * 0.74), stroke);
  }

  void _drawLandParcel(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
  ) {
    // 3D Isometric Cadastral Polygon
    final parcel = Path()
      ..moveTo(w * 0.14, h * 0.38)
      ..lineTo(w * 0.76, h * 0.24)
      ..lineTo(w * 0.88, h * 0.62)
      ..lineTo(w * 0.26, h * 0.78)
      ..close();

    canvas.drawPath(
      parcel,
      Paint()
        ..color = fill.color.withValues(alpha: 0.35)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(parcel, stroke);

    // Internal Grid Division Line
    canvas.drawLine(
        Offset(w * 0.45, h * 0.31), Offset(w * 0.57, h * 0.70), stroke);
    canvas.drawLine(
        Offset(w * 0.20, h * 0.58), Offset(w * 0.82, h * 0.43), stroke);

    // Survey Corner Pins / Flags
    _drawSurveyPin(canvas, Offset(w * 0.14, h * 0.38), fill, stroke);
    _drawSurveyPin(canvas, Offset(w * 0.76, h * 0.24), fill, stroke);
    _drawSurveyPin(canvas, Offset(w * 0.88, h * 0.62), fill, stroke);
    _drawSurveyPin(canvas, Offset(w * 0.26, h * 0.78), fill, stroke);
  }

  void _drawSurveyPin(Canvas canvas, Offset pt, Paint fill, Paint stroke) {
    canvas.drawLine(pt, Offset(pt.dx, pt.dy - 7), stroke);
    final flag = Path()
      ..moveTo(pt.dx, pt.dy - 7)
      ..lineTo(pt.dx + 4, pt.dy - 5)
      ..lineTo(pt.dx, pt.dy - 3)
      ..close();
    canvas.drawPath(flag, fill);
    canvas.drawPath(flag, stroke);
  }

  void _drawTowers(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint window,
  ) {
    // Ground Baseline
    canvas.drawLine(
        Offset(w * 0.08, h * 0.88), Offset(w * 0.92, h * 0.88), stroke);

    // Left Tower (Taller)
    final tower1 = Rect.fromLTRB(w * 0.18, h * 0.16, w * 0.48, h * 0.88);
    canvas.drawRect(
      tower1,
      Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(tower1, stroke);

    // Spire
    canvas.drawLine(
        Offset(w * 0.33, h * 0.16), Offset(w * 0.33, h * 0.08), stroke);

    // Right Tower (Staggered)
    final tower2 = Rect.fromLTRB(w * 0.52, h * 0.28, w * 0.82, h * 0.88);
    canvas.drawRect(tower2, fill);
    canvas.drawRect(tower2, stroke);

    // Connecting Skybridge
    final bridge = Rect.fromLTRB(w * 0.44, h * 0.48, w * 0.56, h * 0.56);
    canvas.drawRect(bridge, fill);
    canvas.drawRect(bridge, stroke);

    // Windows Grid in Tower 1
    for (double wy = h * 0.24; wy < h * 0.80; wy += h * 0.12) {
      canvas.drawRect(
          Rect.fromLTWH(w * 0.22, wy, w * 0.08, h * 0.06), window);
      canvas.drawRect(
          Rect.fromLTWH(w * 0.36, wy, w * 0.08, h * 0.06), window);
    }
  }

  void _drawMultiStoryBuilding(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint window,
  ) {
    // Ground Baseline
    canvas.drawLine(
        Offset(w * 0.08, h * 0.88), Offset(w * 0.92, h * 0.88), stroke);

    // Main 4-story Building Block
    final block = Rect.fromLTRB(w * 0.16, h * 0.14, w * 0.84, h * 0.88);
    canvas.drawRect(
      block,
      Paint()
        ..color = isDark ? const Color(0xFF1E293B) : Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawRect(block, stroke);

    // Roof Cornice
    final roofCornice = Rect.fromLTRB(w * 0.13, h * 0.10, w * 0.87, h * 0.14);
    canvas.drawRect(roofCornice, fill);
    canvas.drawRect(roofCornice, stroke);

    // 3 Floor Cornice Dividing Lines
    canvas.drawLine(
        Offset(w * 0.16, h * 0.32), Offset(w * 0.84, h * 0.32), stroke);
    canvas.drawLine(
        Offset(w * 0.16, h * 0.50), Offset(w * 0.84, h * 0.50), stroke);
    canvas.drawLine(
        Offset(w * 0.16, h * 0.68), Offset(w * 0.84, h * 0.68), stroke);

    // Windows on Floors 2, 3, 4
    for (double wy = h * 0.18; wy <= h * 0.56; wy += h * 0.18) {
      final w1 = Rect.fromLTWH(w * 0.26, wy, w * 0.14, h * 0.08);
      final w2 = Rect.fromLTWH(w * 0.60, wy, w * 0.14, h * 0.08);
      canvas.drawRect(w1, window);
      canvas.drawRect(w1, stroke);
      canvas.drawRect(w2, window);
      canvas.drawRect(w2, stroke);
    }

    // Central Ground Entrance Door
    final door = Rect.fromLTRB(w * 0.42, h * 0.72, w * 0.58, h * 0.88);
    canvas.drawRect(door, fill);
    canvas.drawRect(door, stroke);
  }

  @override
  bool shouldRepaint(covariant _RealEstateVectorPainter oldDelegate) =>
      oldDelegate.category != category ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.isDark != isDark;
}
