import 'package:flutter/material.dart';

import '../../core/utils/color_parser.dart';
import '../../data/models/real_estate_category.dart';
import '../../data/models/vehicle_category.dart';

/// Neo-Brutalist Listing Thumbnail Expansion Pack for Vehicles (Vasıta) and Real Estate (Emlak).
///
/// Features:
/// - Diversified visual library with 45+ distinct vector blueprint variants.
/// - Dynamic vehicle body color blending using actual listing hex colors.
/// - Deterministic seed-based variant selection ensuring stable yet diverse feed aesthetics.
/// - Warm parchment/lemon cream neo-brutal tactile pod (comfortable for the eyes).
/// - Bold 2.0px solid border with zero-blur offset block shadow.
class VasitaListingThumbnail extends StatelessWidget {
  final VehicleCategory category;
  final String? bodyType;
  final String? colorHex;
  final String? seed;
  final bool isDark;
  final double width;
  final double height;

  const VasitaListingThumbnail({
    super.key,
    required this.category,
    this.bodyType,
    this.colorHex,
    this.seed,
    this.isDark = false,
    this.width = 62.0,
    this.height = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    Color? parsedColor;
    if (colorHex != null && colorHex!.trim().isNotEmpty) {
      final c = ColorParser.parseCarColor(colorHex);
      if (c != ColorParser.defaultCarFallbackColor) {
        parsedColor = c;
      }
    }

    final variantIndex = _resolveVariantIndex(seed ?? bodyType, 12);

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
            bodyColor: parsedColor,
            variant: variantIndex,
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
  final Color? bodyColor;
  final int variant;
  final bool isDark;

  _VasitaVectorPainter({
    required this.category,
    required this.accentColor,
    this.bodyColor,
    required this.variant,
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

    final baseFill = bodyColor != null
        ? Color.alphaBlend(
            bodyColor!.withValues(alpha: isDark ? 0.65 : 0.85),
            accentColor.withValues(alpha: 0.25),
          )
        : accentColor;

    final fillPaint = Paint()
      ..color = baseFill
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

    // Background Dot Matrix for Blueprint Aesthetics
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
        _drawMotorcycleVariants(
            canvas, w, h, strokePaint, fillPaint, tirePaint, rimPaint, variant);
        break;
      case VehicleCategory.minivan:
        _drawMinivanVariants(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint, variant);
        break;
      case VehicleCategory.commercial:
        _drawCommercialVariants(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint, variant);
        break;
      case VehicleCategory.marine:
        _drawMarineVariants(
            canvas, w, h, strokePaint, fillPaint, glassPaint, variant);
        break;
      case VehicleCategory.caravan:
        _drawCaravanVariants(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint, variant);
        break;
      case VehicleCategory.aircraft:
        _drawAircraftVariants(
            canvas, w, h, strokePaint, fillPaint, glassPaint, variant);
        break;
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        _drawOffRoadVariants(
            canvas, w, h, strokePaint, fillPaint, tirePaint, rimPaint, variant);
        break;
      case VehicleCategory.damaged:
        _drawDamagedVariants(
            canvas, w, h, strokePaint, fillPaint, tirePaint, variant);
        break;
      case VehicleCategory.classic:
        _drawClassicVariants(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint, variant);
        break;
      case VehicleCategory.car:
      case VehicleCategory.rentalFleet:
        _drawCarVariants(canvas, w, h, strokePaint, fillPaint, tirePaint,
            rimPaint, glassPaint, variant);
        break;
    }
  }

  // 1. Minivan & Panelvan Variations (Kombi, Kapalı Kasa Panelvan, Maxi Uzun Şasi)
  void _drawMinivanVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    final van = Path()
      ..moveTo(w * 0.10, h * 0.68)
      ..lineTo(w * 0.10, h * 0.36)
      ..lineTo(w * 0.64, h * 0.36)
      ..lineTo(w * 0.82, h * 0.52)
      ..lineTo(w * 0.90, h * 0.56)
      ..lineTo(w * 0.90, h * 0.68)
      ..close();
    canvas.drawPath(van, fill);
    canvas.drawPath(van, stroke);

    if (subVar == 0) {
      // Kombi: Yan çift pencereler + tavan rayları
      canvas.drawLine(
          Offset(w * 0.16, h * 0.31), Offset(w * 0.60, h * 0.31), stroke);
      canvas.drawLine(
          Offset(w * 0.22, h * 0.31), Offset(w * 0.22, h * 0.36), stroke);
      canvas.drawLine(
          Offset(w * 0.54, h * 0.31), Offset(w * 0.54, h * 0.36), stroke);

      final w1 = Rect.fromLTWH(w * 0.18, h * 0.42, w * 0.18, h * 0.12);
      final w2 = Rect.fromLTWH(w * 0.40, h * 0.42, w * 0.18, h * 0.12);
      canvas.drawRect(w1, glass);
      canvas.drawRect(w1, stroke);
      canvas.drawRect(w2, glass);
      canvas.drawRect(w2, stroke);
    } else if (subVar == 1) {
      // Panelvan: Sürgülü kapı dikey oluk çizgisi + tek ön cam + üst rüzgarlık
      canvas.drawLine(
          Offset(w * 0.44, h * 0.36), Offset(w * 0.44, h * 0.68), stroke);
      // Sürgülü ray hattı
      canvas.drawLine(
          Offset(w * 0.12, h * 0.54), Offset(w * 0.44, h * 0.54), stroke);

      final frontWindow = Path()
        ..moveTo(w * 0.48, h * 0.40)
        ..lineTo(w * 0.62, h * 0.40)
        ..lineTo(w * 0.74, h * 0.52)
        ..lineTo(w * 0.48, h * 0.52)
        ..close();
      canvas.drawPath(frontWindow, glass);
      canvas.drawPath(frontWindow, stroke);
    } else {
      // Maxi Kasa: Arka çift kanat kapı çizgisi + yan yüksek tavan kabartması
      canvas.drawLine(
          Offset(w * 0.10, h * 0.36), Offset(w * 0.64, h * 0.36), stroke);
      canvas.drawLine(
          Offset(w * 0.20, h * 0.36), Offset(w * 0.20, h * 0.68), stroke);
      final wFront = Rect.fromLTWH(w * 0.46, h * 0.41, w * 0.22, h * 0.13);
      canvas.drawRect(wFront, glass);
      canvas.drawRect(wFront, stroke);
      // Arka basamak
      canvas.drawLine(
          Offset(w * 0.06, h * 0.68), Offset(w * 0.10, h * 0.68), stroke);
    }

    _drawWheel(canvas, Offset(w * 0.28, h * 0.68), w * 0.10, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.74, h * 0.68), w * 0.10, tire, rim, stroke);
  }

  // 2. Motosiklet Variations (Naked, Scooter, Chopper, Enduro)
  void _drawMotorcycleVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    int v,
  ) {
    final subVar = v % 4;

    if (subVar == 0) {
      // Naked / Street: Keskin far kafası, açık kafes şasi, açılı kuyruk
      _drawWheel(canvas, Offset(w * 0.24, h * 0.68), w * 0.12, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.76, h * 0.68), w * 0.12, tire, rim, stroke);

      final tank = Path()
        ..moveTo(w * 0.42, h * 0.44)
        ..lineTo(w * 0.60, h * 0.44)
        ..lineTo(w * 0.54, h * 0.58)
        ..lineTo(w * 0.36, h * 0.54)
        ..close();
      canvas.drawPath(tank, fill);
      canvas.drawPath(tank, stroke);

      // Şasi ve gidon
      canvas.drawLine(
          Offset(w * 0.76, h * 0.68), Offset(w * 0.62, h * 0.32), stroke);
      canvas.drawLine(
          Offset(w * 0.62, h * 0.32), Offset(w * 0.56, h * 0.30), stroke);
      // Sivri far vizörü
      canvas.drawLine(
          Offset(w * 0.62, h * 0.36), Offset(w * 0.70, h * 0.42), stroke);
      // Kuyruk
      canvas.drawLine(
          Offset(w * 0.42, h * 0.44), Offset(w * 0.26, h * 0.40), stroke);
    } else if (subVar == 1) {
      // Maxi Scooter: Ön rüzgarlık, geniş ayak basamağı, arka topcase çanta
      _drawWheel(canvas, Offset(w * 0.24, h * 0.70), w * 0.10, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.76, h * 0.70), w * 0.10, tire, rim, stroke);

      // Ön kalkan ve rüzgarlık
      final frontFairing = Path()
        ..moveTo(w * 0.62, h * 0.28)
        ..lineTo(w * 0.76, h * 0.48)
        ..lineTo(w * 0.64, h * 0.68)
        ..lineTo(w * 0.50, h * 0.68)
        ..close();
      canvas.drawPath(frontFairing, fill);
      canvas.drawPath(frontFairing, stroke);

      // Arka topcase çanta
      final topCase = Rect.fromLTWH(w * 0.18, h * 0.36, w * 0.14, h * 0.16);
      canvas.drawRect(topCase, fill);
      canvas.drawRect(topCase, stroke);

      // Sele
      canvas.drawLine(
          Offset(w * 0.32, h * 0.52), Offset(w * 0.54, h * 0.52), stroke);
    } else if (subVar == 2) {
      // Chopper / Cruiser: Uzun eğimli ön çatal, yüksek 'ape' gidon, damla depo
      _drawWheel(canvas, Offset(w * 0.22, h * 0.68), w * 0.12, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.82, h * 0.68), w * 0.11, tire, rim, stroke);

      // Damla depo
      final dropTank = Path()
        ..moveTo(w * 0.44, h * 0.48)
        ..quadraticBezierTo(w * 0.56, h * 0.36, w * 0.64, h * 0.46)
        ..lineTo(w * 0.50, h * 0.56)
        ..close();
      canvas.drawPath(dropTank, fill);
      canvas.drawPath(dropTank, stroke);

      // Uzun ön çatal & yüksek gidon
      canvas.drawLine(
          Offset(w * 0.82, h * 0.68), Offset(w * 0.60, h * 0.24), stroke);
      canvas.drawLine(
          Offset(w * 0.60, h * 0.24), Offset(w * 0.54, h * 0.22), stroke);
      // Alçak sele & sissy bar
      canvas.drawLine(
          Offset(w * 0.44, h * 0.54), Offset(w * 0.30, h * 0.54), stroke);
      canvas.drawLine(
          Offset(w * 0.24, h * 0.68), Offset(w * 0.22, h * 0.30), stroke);
    } else {
      // Adventure / Enduro: Gagalı ön çamurluk, yüksek süspansiyon, dik cam
      _drawWheel(canvas, Offset(w * 0.22, h * 0.70), w * 0.12, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.78, h * 0.70), w * 0.12, tire, rim, stroke);

      // Şasi
      final advBody = Path()
        ..moveTo(w * 0.34, h * 0.46)
        ..lineTo(w * 0.56, h * 0.42)
        ..lineTo(w * 0.68, h * 0.32)
        ..lineTo(w * 0.76, h * 0.48)
        ..lineTo(w * 0.58, h * 0.58)
        ..close();
      canvas.drawPath(advBody, fill);
      canvas.drawPath(advBody, stroke);

      // Ön gagalı çamurluk
      canvas.drawLine(
          Offset(w * 0.72, h * 0.46), Offset(w * 0.86, h * 0.46), stroke);
      // Yüksek gidon
      canvas.drawLine(
          Offset(w * 0.64, h * 0.34), Offset(w * 0.60, h * 0.24), stroke);
    }
  }

  // 3. Ticari Araç Variations (Kapalı Kutu Kamyon, Açık Kasa Damperli, Çekici Tır)
  void _drawCommercialVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Kapalı Kutu Kamyonet: Yüksek kare kargo kutusu + burunsuz kabin
      final box = Rect.fromLTWH(w * 0.08, h * 0.30, w * 0.52, h * 0.40);
      canvas.drawRect(box, fill);
      canvas.drawRect(box, stroke);
      // Kutu kapı kilit çizgisi
      canvas.drawLine(
          Offset(w * 0.34, h * 0.30), Offset(w * 0.34, h * 0.70), stroke);

      final cab = Path()
        ..moveTo(w * 0.60, h * 0.70)
        ..lineTo(w * 0.60, h * 0.38)
        ..lineTo(w * 0.80, h * 0.38)
        ..lineTo(w * 0.88, h * 0.54)
        ..lineTo(w * 0.88, h * 0.70)
        ..close();
      canvas.drawPath(cab, fill);
      canvas.drawPath(cab, stroke);

      final cabWindow = Rect.fromLTWH(w * 0.64, h * 0.44, w * 0.16, h * 0.12);
      canvas.drawRect(cabWindow, glass);
      canvas.drawRect(cabWindow, stroke);

      _drawWheel(canvas, Offset(w * 0.22, h * 0.72), w * 0.09, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.42, h * 0.72), w * 0.09, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.76, h * 0.72), w * 0.09, tire, rim, stroke);
    } else if (subVar == 1) {
      // Açık Kasa Damperli Kamyonet: Açık sac kasa kapakları + koruma demiri
      final flatbed = Rect.fromLTWH(w * 0.08, h * 0.50, w * 0.54, h * 0.20);
      canvas.drawRect(flatbed, fill);
      canvas.drawRect(flatbed, stroke);
      // Kasa destek dikmeleri
      canvas.drawLine(
          Offset(w * 0.26, h * 0.50), Offset(w * 0.26, h * 0.70), stroke);
      canvas.drawLine(
          Offset(w * 0.44, h * 0.50), Offset(w * 0.44, h * 0.70), stroke);
      // Kabin arkası koruma demiri
      canvas.drawLine(
          Offset(w * 0.60, h * 0.34), Offset(w * 0.60, h * 0.50), stroke);

      final cab = Path()
        ..moveTo(w * 0.62, h * 0.70)
        ..lineTo(w * 0.62, h * 0.38)
        ..lineTo(w * 0.82, h * 0.38)
        ..lineTo(w * 0.88, h * 0.52)
        ..lineTo(w * 0.88, h * 0.70)
        ..close();
      canvas.drawPath(cab, fill);
      canvas.drawPath(cab, stroke);

      final cabWindow = Rect.fromLTWH(w * 0.66, h * 0.44, w * 0.14, h * 0.12);
      canvas.drawRect(cabWindow, glass);
      canvas.drawRect(cabWindow, stroke);

      _drawWheel(canvas, Offset(w * 0.24, h * 0.72), w * 0.09, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.76, h * 0.72), w * 0.09, tire, rim, stroke);
    } else {
      // Çekici Tır (Semi Truck): Yüksek tavan rüzgarlık, dikey egzoz, 5. teker
      final truck = Path()
        ..moveTo(w * 0.36, h * 0.70)
        ..lineTo(w * 0.36, h * 0.38)
        ..lineTo(w * 0.64, h * 0.26)
        ..lineTo(w * 0.78, h * 0.28)
        ..lineTo(w * 0.86, h * 0.50)
        ..lineTo(w * 0.86, h * 0.70)
        ..close();
      canvas.drawPath(truck, fill);
      canvas.drawPath(truck, stroke);

      // Dikey krom egzoz
      canvas.drawLine(
          Offset(w * 0.32, h * 0.65), Offset(w * 0.32, h * 0.22), stroke);
      canvas.drawLine(
          Offset(w * 0.32, h * 0.22), Offset(w * 0.28, h * 0.24), stroke);

      // Şasi & 5. tekerlek tablası
      canvas.drawLine(
          Offset(w * 0.10, h * 0.64), Offset(w * 0.36, h * 0.64), stroke);
      canvas.drawLine(
          Offset(w * 0.20, h * 0.60), Offset(w * 0.28, h * 0.60), stroke);

      final win = Rect.fromLTWH(w * 0.56, h * 0.36, w * 0.20, h * 0.15);
      canvas.drawRect(win, glass);
      canvas.drawRect(win, stroke);

      _drawWheel(canvas, Offset(w * 0.18, h * 0.72), w * 0.09, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.74, h * 0.72), w * 0.09, tire, rim, stroke);
    }
  }

  // 4. Deniz Araçları Variations (Motor Yat, Sürat Teknesi, Yelkenli)
  void _drawMarineVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Motor Yat: Çift katlı kabin, flybridge üst köprü, radar direği
      final hull = Path()
        ..moveTo(w * 0.08, h * 0.60)
        ..lineTo(w * 0.20, h * 0.72)
        ..lineTo(w * 0.74, h * 0.72)
        ..lineTo(w * 0.92, h * 0.54)
        ..lineTo(w * 0.80, h * 0.54)
        ..lineTo(w * 0.08, h * 0.56)
        ..close();
      canvas.drawPath(hull, fill);
      canvas.drawPath(hull, stroke);

      final cabin = Path()
        ..moveTo(w * 0.24, h * 0.56)
        ..lineTo(w * 0.24, h * 0.38)
        ..lineTo(w * 0.54, h * 0.38)
        ..lineTo(w * 0.68, h * 0.54)
        ..close();
      canvas.drawPath(cabin, glass);
      canvas.drawPath(cabin, stroke);

      // Flybridge üst siperlik & radar kemeri
      canvas.drawLine(
          Offset(w * 0.30, h * 0.38), Offset(w * 0.30, h * 0.28), stroke);
      canvas.drawLine(
          Offset(w * 0.28, h * 0.28), Offset(w * 0.44, h * 0.28), stroke);

      // Su dalga çizgileri
      canvas.drawLine(
          Offset(w * 0.12, h * 0.78), Offset(w * 0.88, h * 0.78), stroke);
    } else if (subVar == 1) {
      // Sürat Motoru: Düşük profilli aerodinamik gövde, ön spor cam, dıştan motor
      final hull = Path()
        ..moveTo(w * 0.12, h * 0.56)
        ..lineTo(w * 0.18, h * 0.70)
        ..lineTo(w * 0.76, h * 0.70)
        ..lineTo(w * 0.94, h * 0.48)
        ..lineTo(w * 0.12, h * 0.56)
        ..close();
      canvas.drawPath(hull, fill);
      canvas.drawPath(hull, stroke);

      // Spor rüzgarlık camı
      final windshield = Path()
        ..moveTo(w * 0.44, h * 0.56)
        ..lineTo(w * 0.58, h * 0.42)
        ..lineTo(w * 0.70, h * 0.56)
        ..close();
      canvas.drawPath(windshield, glass);
      canvas.drawPath(windshield, stroke);

      // Dıştan takma çift motor (Outboard motor)
      final outboard = Rect.fromLTWH(w * 0.04, h * 0.50, w * 0.08, h * 0.24);
      canvas.drawRect(outboard, fill);
      canvas.drawRect(outboard, stroke);

      canvas.drawLine(
          Offset(w * 0.16, h * 0.76), Offset(w * 0.90, h * 0.76), stroke);
    } else {
      // Yelkenli Tekne: Kavisli gövde, dikey direk, üçgen ana ve ön yelken
      final hull = Path()
        ..moveTo(w * 0.12, h * 0.68)
        ..lineTo(w * 0.24, h * 0.78)
        ..lineTo(w * 0.76, h * 0.78)
        ..lineTo(w * 0.90, h * 0.62)
        ..lineTo(w * 0.12, h * 0.68)
        ..close();
      canvas.drawPath(hull, fill);
      canvas.drawPath(hull, stroke);

      // Direk
      canvas.drawLine(
          Offset(w * 0.52, h * 0.68), Offset(w * 0.52, h * 0.18), stroke);

      // Ana yelken (arkada üçgen)
      final mainSail = Path()
        ..moveTo(w * 0.50, h * 0.22)
        ..lineTo(w * 0.28, h * 0.62)
        ..lineTo(w * 0.50, h * 0.62)
        ..close();
      canvas.drawPath(mainSail, glass);
      canvas.drawPath(mainSail, stroke);

      // Ön flok yelken
      final jibSail = Path()
        ..moveTo(w * 0.54, h * 0.24)
        ..lineTo(w * 0.78, h * 0.62)
        ..lineTo(w * 0.54, h * 0.62)
        ..close();
      canvas.drawPath(jibSail, fill);
      canvas.drawPath(jibSail, stroke);
    }
  }

  // 5. Karavan Variations (Motokaravan, Çekme Karavan, Alkovenli RV)
  void _drawCaravanVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Motokaravan: Tavan kliması + yan tente + büyük yan pencere
      final body = Path()
        ..moveTo(w * 0.10, h * 0.68)
        ..lineTo(w * 0.10, h * 0.36)
        ..lineTo(w * 0.64, h * 0.36)
        ..lineTo(w * 0.82, h * 0.50)
        ..lineTo(w * 0.90, h * 0.56)
        ..lineTo(w * 0.90, h * 0.68)
        ..close();
      canvas.drawPath(body, fill);
      canvas.drawPath(body, stroke);

      // Tavan klima ünitesi
      final ac = Rect.fromLTWH(w * 0.28, h * 0.28, w * 0.20, h * 0.08);
      canvas.drawRect(ac, fill);
      canvas.drawRect(ac, stroke);

      // Yan tente çizgisi
      canvas.drawLine(
          Offset(w * 0.14, h * 0.40), Offset(w * 0.56, h * 0.40), stroke);

      final camperWin = Rect.fromLTWH(w * 0.18, h * 0.46, w * 0.22, h * 0.12);
      canvas.drawRect(camperWin, glass);
      canvas.drawRect(camperWin, stroke);

      _drawWheel(canvas, Offset(w * 0.28, h * 0.68), w * 0.10, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.74, h * 0.68), w * 0.10, tire, rim, stroke);
    } else if (subVar == 1) {
      // Çekme Karavan (Trailer): Yuvarlak tavan, ön çeki oku demiri, tek aks ortada
      final trailer = Path()
        ..moveTo(w * 0.22, h * 0.68)
        ..lineTo(w * 0.22, h * 0.42)
        ..quadraticBezierTo(w * 0.24, h * 0.32, w * 0.40, h * 0.32)
        ..lineTo(w * 0.70, h * 0.32)
        ..quadraticBezierTo(w * 0.84, h * 0.34, w * 0.86, h * 0.46)
        ..lineTo(w * 0.86, h * 0.68)
        ..close();
      canvas.drawPath(trailer, fill);
      canvas.drawPath(trailer, stroke);

      // Ön çeki oku demiri (Tow hitch)
      canvas.drawLine(
          Offset(w * 0.86, h * 0.64), Offset(w * 0.96, h * 0.68), stroke);
      canvas.drawCircle(Offset(w * 0.96, h * 0.68), 2.0, stroke);

      final trailerWin =
          Rect.fromLTWH(w * 0.36, h * 0.40, w * 0.32, h * 0.14);
      canvas.drawRect(trailerWin, glass);
      canvas.drawRect(trailerWin, stroke);

      _drawWheel(canvas, Offset(w * 0.54, h * 0.68), w * 0.11, tire, rim, stroke);
    } else {
      // Alkovenli Aile Karavanı: Sürücü kabini üstü yatak çıkıntısı + arka bisiklet askısı
      final alkoven = Path()
        ..moveTo(w * 0.12, h * 0.68)
        ..lineTo(w * 0.12, h * 0.30)
        ..lineTo(w * 0.74, h * 0.30)
        ..lineTo(w * 0.74, h * 0.48)
        ..lineTo(w * 0.88, h * 0.54)
        ..lineTo(w * 0.88, h * 0.68)
        ..close();
      canvas.drawPath(alkoven, fill);
      canvas.drawPath(alkoven, stroke);

      // Alkoven penceresi
      final alkovenWin =
          Rect.fromLTWH(w * 0.52, h * 0.34, w * 0.16, h * 0.10);
      canvas.drawRect(alkovenWin, glass);
      canvas.drawRect(alkovenWin, stroke);

      // Arka bisiklet taşıyıcı rafı
      canvas.drawLine(
          Offset(w * 0.06, h * 0.46), Offset(w * 0.12, h * 0.46), stroke);
      canvas.drawLine(
          Offset(w * 0.06, h * 0.54), Offset(w * 0.12, h * 0.54), stroke);

      _drawWheel(canvas, Offset(w * 0.28, h * 0.68), w * 0.10, tire, rim, stroke);
      _drawWheel(canvas, Offset(w * 0.74, h * 0.68), w * 0.10, tire, rim, stroke);
    }
  }

  // 6. Hava Araçları Variations (Tek Motorlu Pervaneli, Çift Motorlu Pırpır, Helikopter)
  void _drawAircraftVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Tek Motorlu Pervaneli Uçak: Burun pervanesi, kanatlar, dikey dümen
      final fuselage = Path()
        ..moveTo(w * 0.10, h * 0.44)
        ..lineTo(w * 0.16, h * 0.30)
        ..lineTo(w * 0.22, h * 0.46)
        ..lineTo(w * 0.82, h * 0.46)
        ..lineTo(w * 0.88, h * 0.54)
        ..lineTo(w * 0.10, h * 0.54)
        ..close();
      canvas.drawPath(fuselage, fill);
      canvas.drawPath(fuselage, stroke);

      // Kokpit
      final cockpit = Path()
        ..moveTo(w * 0.50, h * 0.46)
        ..lineTo(w * 0.62, h * 0.36)
        ..lineTo(w * 0.72, h * 0.46)
        ..close();
      canvas.drawPath(cockpit, glass);
      canvas.drawPath(cockpit, stroke);

      // Burun pervanesi (Dönen 2 palli)
      canvas.drawLine(
          Offset(w * 0.88, h * 0.38), Offset(w * 0.88, h * 0.62), stroke);

      // İniş takımları
      canvas.drawLine(
          Offset(w * 0.58, h * 0.54), Offset(w * 0.54, h * 0.66), stroke);
      canvas.drawCircle(Offset(w * 0.54, h * 0.66), 2.5, stroke);
    } else if (subVar == 1) {
      // Çift Motorlu Pırpır / Jet: Kanat motorları, yüksek T-kuyruk
      final fuselage = Path()
        ..moveTo(w * 0.10, h * 0.48)
        ..lineTo(w * 0.16, h * 0.26)
        ..lineTo(w * 0.26, h * 0.26)
        ..lineTo(w * 0.24, h * 0.48)
        ..lineTo(w * 0.86, h * 0.48)
        ..lineTo(w * 0.92, h * 0.56)
        ..lineTo(w * 0.10, h * 0.56)
        ..close();
      canvas.drawPath(fuselage, fill);
      canvas.drawPath(fuselage, stroke);

      // Kanat altı motor gondolu
      final engine = Rect.fromLTWH(w * 0.46, h * 0.56, w * 0.18, h * 0.10);
      canvas.drawRect(engine, fill);
      canvas.drawRect(engine, stroke);

      final cockpit = Rect.fromLTWH(w * 0.68, h * 0.42, w * 0.14, h * 0.08);
      canvas.drawRect(cockpit, glass);
      canvas.drawRect(cockpit, stroke);
    } else {
      // Helikopter: Ana rotor pervanesi, kabin, kuyruk bumu ve kuyruk rotoru, kızaklar
      final cabin = Path()
        ..moveTo(w * 0.32, h * 0.62)
        ..lineTo(w * 0.32, h * 0.40)
        ..lineTo(w * 0.62, h * 0.40)
        ..lineTo(w * 0.74, h * 0.52)
        ..lineTo(w * 0.68, h * 0.62)
        ..close();
      canvas.drawPath(cabin, fill);
      canvas.drawPath(cabin, stroke);

      // Kuyruk bumu
      canvas.drawLine(
          Offset(w * 0.32, h * 0.46), Offset(w * 0.10, h * 0.46), stroke);
      // Kuyruk rotoru
      canvas.drawLine(
          Offset(w * 0.10, h * 0.38), Offset(w * 0.10, h * 0.54), stroke);

      // Ana rotor mili & pervanesi
      canvas.drawLine(
          Offset(w * 0.48, h * 0.40), Offset(w * 0.48, h * 0.26), stroke);
      canvas.drawLine(
          Offset(w * 0.24, h * 0.26), Offset(w * 0.76, h * 0.26), stroke);

      // İniş kızağı (Skid)
      canvas.drawLine(
          Offset(w * 0.34, h * 0.70), Offset(w * 0.68, h * 0.70), stroke);
      canvas.drawLine(
          Offset(w * 0.40, h * 0.62), Offset(w * 0.40, h * 0.70), stroke);
      canvas.drawLine(
          Offset(w * 0.60, h * 0.62), Offset(w * 0.60, h * 0.70), stroke);
    }
  }

  // 7. ATV & UTV Variations (Sport Racing ATV, Utility Çiftlik ATV, Roll-cage Buggy UTV)
  void _drawOffRoadVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Spor ATV: Sivri çamurluklar, açık gidon, yarış yayları
      _drawBigWheel(canvas, Offset(w * 0.24, h * 0.68), w * 0.14, tire, rim, stroke);
      _drawBigWheel(canvas, Offset(w * 0.76, h * 0.68), w * 0.14, tire, rim, stroke);

      final body = Path()
        ..moveTo(w * 0.34, h * 0.52)
        ..lineTo(w * 0.48, h * 0.42)
        ..lineTo(w * 0.68, h * 0.44)
        ..lineTo(w * 0.78, h * 0.52)
        ..lineTo(w * 0.58, h * 0.58)
        ..close();
      canvas.drawPath(body, fill);
      canvas.drawPath(body, stroke);

      // Gidon
      canvas.drawLine(
          Offset(w * 0.64, h * 0.44), Offset(w * 0.62, h * 0.30), stroke);
      canvas.drawLine(
          Offset(w * 0.56, h * 0.30), Offset(w * 0.68, h * 0.30), stroke);
    } else if (subVar == 1) {
      // Utility ATV: Ön ve arka metal taşıma ızgaraları
      _drawBigWheel(canvas, Offset(w * 0.24, h * 0.68), w * 0.14, tire, rim, stroke);
      _drawBigWheel(canvas, Offset(w * 0.76, h * 0.68), w * 0.14, tire, rim, stroke);

      final body = Rect.fromLTWH(w * 0.30, h * 0.46, w * 0.40, h * 0.14);
      canvas.drawRect(body, fill);
      canvas.drawRect(body, stroke);

      // Arka taşıma sepeti
      canvas.drawLine(
          Offset(w * 0.14, h * 0.44), Offset(w * 0.30, h * 0.44), stroke);
      // Ön taşıma sepeti
      canvas.drawLine(
          Offset(w * 0.70, h * 0.44), Offset(w * 0.86, h * 0.44), stroke);
      // Gidon
      canvas.drawLine(
          Offset(w * 0.64, h * 0.46), Offset(w * 0.62, h * 0.32), stroke);
    } else {
      // UTV / Buggy: Boru takla kafesi (Roll-cage) + tavan LED barı
      _drawBigWheel(canvas, Offset(w * 0.22, h * 0.68), w * 0.14, tire, rim, stroke);
      _drawBigWheel(canvas, Offset(w * 0.78, h * 0.68), w * 0.14, tire, rim, stroke);

      final hull = Rect.fromLTWH(w * 0.20, h * 0.52, w * 0.60, h * 0.16);
      canvas.drawRect(hull, fill);
      canvas.drawRect(hull, stroke);

      // Roll cage boru kafesi
      final cage = Path()
        ..moveTo(w * 0.26, h * 0.52)
        ..lineTo(w * 0.32, h * 0.28)
        ..lineTo(w * 0.66, h * 0.28)
        ..lineTo(w * 0.74, h * 0.52);
      canvas.drawPath(cage, stroke);

      // Tavan LED spot ışık barı
      final ledBar = Rect.fromLTWH(w * 0.36, h * 0.24, w * 0.26, h * 0.05);
      canvas.drawRect(ledBar, fill);
      canvas.drawRect(ledBar, stroke);
    }
  }

  // 8. Klasik Araç Variations (1950s Tail-fin Coupe, Vintage Roadster, 70s Muscle Fastback)
  void _drawClassicVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // 1950'ler Amerikan Coupe: Kanatlı arka çamurluk (Tail-fin) & yuvarlak tavan
      final classic = Path()
        ..moveTo(w * 0.10, h * 0.64)
        ..quadraticBezierTo(w * 0.14, h * 0.44, w * 0.30, h * 0.48)
        ..quadraticBezierTo(w * 0.44, h * 0.28, w * 0.66, h * 0.36)
        ..quadraticBezierTo(w * 0.78, h * 0.46, w * 0.90, h * 0.64)
        ..close();
      canvas.drawPath(classic, fill);
      canvas.drawPath(classic, stroke);

      final window = Path()
        ..moveTo(w * 0.42, h * 0.48)
        ..quadraticBezierTo(w * 0.52, h * 0.34, w * 0.64, h * 0.40)
        ..close();
      canvas.drawPath(window, glass);
      canvas.drawPath(window, stroke);
    } else if (subVar == 1) {
      // Vintage Roadster: Açık tavan, yuvarlak gövde, rüzgarlık camı
      final roadster = Path()
        ..moveTo(w * 0.10, h * 0.64)
        ..lineTo(w * 0.12, h * 0.50)
        ..lineTo(w * 0.34, h * 0.50)
        ..lineTo(w * 0.50, h * 0.46)
        ..lineTo(w * 0.78, h * 0.48)
        ..lineTo(w * 0.90, h * 0.64)
        ..close();
      canvas.drawPath(roadster, fill);
      canvas.drawPath(roadster, stroke);

      // Dik küçük rüzgarlık camı
      final screen = Path()
        ..moveTo(w * 0.48, h * 0.46)
        ..lineTo(w * 0.52, h * 0.34)
        ..lineTo(w * 0.58, h * 0.46)
        ..close();
      canvas.drawPath(screen, glass);
      canvas.drawPath(screen, stroke);

      // Arkada yarım stepne tekerlek yuvası
      canvas.drawArc(
          Rect.fromLTWH(w * 0.04, h * 0.44, w * 0.12, h * 0.20),
          1.57,
          3.14,
          false,
          stroke);
    } else {
      // 1970'ler Klasik Muscle Car: Fastback eğik tavan, kaput hava yarığı
      final muscle = Path()
        ..moveTo(w * 0.08, h * 0.64)
        ..lineTo(w * 0.12, h * 0.48)
        ..lineTo(w * 0.28, h * 0.38)
        ..lineTo(w * 0.60, h * 0.38)
        ..lineTo(w * 0.72, h * 0.48)
        ..lineTo(w * 0.92, h * 0.52)
        ..lineTo(w * 0.92, h * 0.64)
        ..close();
      canvas.drawPath(muscle, fill);
      canvas.drawPath(muscle, stroke);

      // Kaput hava girişi (Hood scoop)
      canvas.drawLine(
          Offset(w * 0.76, h * 0.46), Offset(w * 0.84, h * 0.46), stroke);

      final fastbackWin = Path()
        ..moveTo(w * 0.32, h * 0.48)
        ..lineTo(w * 0.42, h * 0.40)
        ..lineTo(w * 0.58, h * 0.40)
        ..lineTo(w * 0.68, h * 0.48)
        ..close();
      canvas.drawPath(fastbackWin, glass);
      canvas.drawPath(fastbackWin, stroke);
    }

    _drawWheel(canvas, Offset(w * 0.26, h * 0.66), w * 0.10, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.76, h * 0.66), w * 0.10, tire, rim, stroke);
  }

  // 9. Rental Fleet / Car Variations (Executive Sedan, Crossover SUV, Sport Hatchback)
  void _drawCarVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    Paint rim,
    Paint glass,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Executive Sedan: Akıcı aerodinamik tavan, ön/arka tampon hatları
      final body = Path()
        ..moveTo(w * 0.08, h * 0.66)
        ..lineTo(w * 0.14, h * 0.52)
        ..lineTo(w * 0.30, h * 0.52)
        ..lineTo(w * 0.44, h * 0.34)
        ..lineTo(w * 0.68, h * 0.34)
        ..lineTo(w * 0.80, h * 0.50)
        ..lineTo(w * 0.92, h * 0.54)
        ..lineTo(w * 0.92, h * 0.66)
        ..close();
      canvas.drawPath(body, fill);
      canvas.drawPath(body, stroke);

      final window = Path()
        ..moveTo(w * 0.34, h * 0.50)
        ..lineTo(w * 0.46, h * 0.38)
        ..lineTo(w * 0.66, h * 0.38)
        ..lineTo(w * 0.76, h * 0.50)
        ..close();
      canvas.drawPath(window, glass);
      canvas.drawPath(window, stroke);

      canvas.drawLine(
          Offset(w * 0.56, h * 0.38), Offset(w * 0.56, h * 0.50), stroke);
    } else if (subVar == 1) {
      // Crossover SUV: Yüksek omuz, tavan rayları, köşeli çamurluk
      final suv = Path()
        ..moveTo(w * 0.08, h * 0.66)
        ..lineTo(w * 0.10, h * 0.44)
        ..lineTo(w * 0.36, h * 0.34)
        ..lineTo(w * 0.68, h * 0.34)
        ..lineTo(w * 0.80, h * 0.48)
        ..lineTo(w * 0.92, h * 0.52)
        ..lineTo(w * 0.92, h * 0.66)
        ..close();
      canvas.drawPath(suv, fill);
      canvas.drawPath(suv, stroke);

      // Tavan rayları
      canvas.drawLine(
          Offset(w * 0.36, h * 0.30), Offset(w * 0.68, h * 0.30), stroke);

      final win = Rect.fromLTWH(w * 0.38, h * 0.38, w * 0.28, h * 0.14);
      canvas.drawRect(win, glass);
      canvas.drawRect(win, stroke);
    } else {
      // Sport Hatchback: Dik arka bagaj, arka tavan spoyleri
      final hatch = Path()
        ..moveTo(w * 0.12, h * 0.66)
        ..lineTo(w * 0.14, h * 0.44)
        ..lineTo(w * 0.36, h * 0.36)
        ..lineTo(w * 0.64, h * 0.36)
        ..lineTo(w * 0.80, h * 0.52)
        ..lineTo(w * 0.90, h * 0.56)
        ..lineTo(w * 0.90, h * 0.66)
        ..close();
      canvas.drawPath(hatch, fill);
      canvas.drawPath(hatch, stroke);

      // Arka tavan spoyleri
      canvas.drawLine(
          Offset(w * 0.08, h * 0.42), Offset(w * 0.18, h * 0.42), stroke);

      final win = Path()
        ..moveTo(w * 0.26, h * 0.52)
        ..lineTo(w * 0.38, h * 0.40)
        ..lineTo(w * 0.62, h * 0.40)
        ..lineTo(w * 0.74, h * 0.52)
        ..close();
      canvas.drawPath(win, glass);
      canvas.drawPath(win, stroke);
    }

    _drawWheel(canvas, Offset(w * 0.26, h * 0.68), w * 0.09, tire, rim, stroke);
    _drawWheel(canvas, Offset(w * 0.74, h * 0.68), w * 0.09, tire, rim, stroke);
  }

  // 10. Hasarlı Araç Variations (Önden Kaza, Yandan Göçük, Tavan Çökmesi)
  void _drawDamagedVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint tire,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Önden Darbeli: Buruşmuş ön burun, açılmış kaput, kırık far
      final wrecked = Path()
        ..moveTo(w * 0.10, h * 0.66)
        ..lineTo(w * 0.16, h * 0.50)
        ..lineTo(w * 0.44, h * 0.36)
        ..lineTo(w * 0.66, h * 0.36)
        ..lineTo(w * 0.74, h * 0.48)
        ..lineTo(w * 0.84, h * 0.44) // Kalkmış kırık kaput
        ..lineTo(w * 0.82, h * 0.56)
        ..lineTo(w * 0.86, h * 0.66)
        ..close();
      canvas.drawPath(wrecked, fill);
      canvas.drawPath(wrecked, stroke);

      // Ön buruşukluk zikzakları
      canvas.drawLine(
          Offset(w * 0.78, h * 0.50), Offset(w * 0.84, h * 0.58), stroke);
      canvas.drawLine(
          Offset(w * 0.84, h * 0.58), Offset(w * 0.80, h * 0.64), stroke);

      canvas.drawCircle(Offset(w * 0.28, h * 0.68), w * 0.09, tire);
      canvas.drawCircle(Offset(w * 0.28, h * 0.68), w * 0.09, stroke);
      // Eğrilmiş ön tekerlek
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * 0.76, h * 0.68),
              width: w * 0.20,
              height: w * 0.14),
          tire);
    } else if (subVar == 1) {
      // Yandan Darbeli: Göçük kapı sacı, kaza hasar çizgisi
      final body = Path()
        ..moveTo(w * 0.10, h * 0.66)
        ..lineTo(w * 0.16, h * 0.52)
        ..lineTo(w * 0.40, h * 0.36)
        ..lineTo(w * 0.68, h * 0.36)
        ..lineTo(w * 0.80, h * 0.52)
        ..lineTo(w * 0.90, h * 0.66)
        ..close();
      canvas.drawPath(body, fill);
      canvas.drawPath(body, stroke);

      // Göçük zikzak kapı hattı
      final dent = Path()
        ..moveTo(w * 0.46, h * 0.42)
        ..lineTo(w * 0.52, h * 0.50)
        ..lineTo(w * 0.48, h * 0.58)
        ..lineTo(w * 0.56, h * 0.64);
      canvas.drawPath(dent, stroke);

      _drawWheel(canvas, Offset(w * 0.26, h * 0.68), w * 0.09, tire, stroke, stroke);
      _drawWheel(canvas, Offset(w * 0.76, h * 0.68), w * 0.09, tire, stroke, stroke);
    } else {
      // Taklalı / Tavan Çökmesi: Ezik A-sütunu, dalgalı tavan
      final rolled = Path()
        ..moveTo(w * 0.10, h * 0.66)
        ..lineTo(w * 0.14, h * 0.52)
        ..lineTo(w * 0.36, h * 0.48) // Çökmüş tavan
        ..lineTo(w * 0.58, h * 0.42)
        ..lineTo(w * 0.74, h * 0.50)
        ..lineTo(w * 0.90, h * 0.66)
        ..close();
      canvas.drawPath(rolled, fill);
      canvas.drawPath(rolled, stroke);

      canvas.drawLine(
          Offset(w * 0.34, h * 0.48), Offset(w * 0.46, h * 0.62), stroke);

      _drawWheel(canvas, Offset(w * 0.24, h * 0.68), w * 0.09, tire, stroke, stroke);
      _drawWheel(canvas, Offset(w * 0.76, h * 0.68), w * 0.09, tire, stroke, stroke);
    }
  }

  void _drawWheel(Canvas canvas, Offset center, double radius, Paint tire,
      Paint rim, Paint stroke) {
    canvas.drawCircle(center, radius, tire);
    canvas.drawCircle(center, radius, stroke);
    canvas.drawCircle(center, radius * 0.45, rim);
    canvas.drawCircle(center, radius * 0.45, stroke);
  }

  void _drawBigWheel(Canvas canvas, Offset center, double radius, Paint tire,
      Paint rim, Paint stroke) {
    canvas.drawCircle(center, radius, tire);
    canvas.drawCircle(center, radius, stroke);
    canvas.drawCircle(center, radius * 0.50, rim);
    canvas.drawCircle(center, radius * 0.50, stroke);
    // Dişli lastik çizgileri
    canvas.drawLine(
        Offset(center.dx - radius, center.dy), Offset(center.dx - radius + 3, center.dy), stroke);
    canvas.drawLine(
        Offset(center.dx + radius - 3, center.dy), Offset(center.dx + radius, center.dy), stroke);
  }

  @override
  bool shouldRepaint(covariant _VasitaVectorPainter oldDelegate) =>
      oldDelegate.category != category ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.bodyColor != bodyColor ||
      oldDelegate.variant != variant ||
      oldDelegate.isDark != isDark;
}

/// Neo-Brutalist Listing Thumbnail Expansion Pack for Real Estate (Emlak)
class RealEstateListingThumbnail extends StatelessWidget {
  final RealEstateCategory category;
  final String? seed;
  final int? squareMeters;
  final String? roomCount;
  final bool isDark;
  final double width;
  final double height;

  const RealEstateListingThumbnail({
    super.key,
    required this.category,
    this.seed,
    this.squareMeters,
    this.roomCount,
    this.isDark = false,
    this.width = 62.0,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    final variantIndex =
        _resolveVariantIndex(seed ?? '$squareMeters $roomCount', 10);

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
            variant: variantIndex,
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
  final int variant;
  final bool isDark;

  _RealEstateVectorPainter({
    required this.category,
    required this.accentColor,
    required this.variant,
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
        _drawHousingVariants(
            canvas, w, h, strokePaint, fillPaint, windowPaint, variant);
        break;
      case RealEstateCategory.commercial:
        _drawCommercialVariants(
            canvas, w, h, strokePaint, fillPaint, windowPaint, variant);
        break;
      case RealEstateCategory.land:
        _drawLandVariants(canvas, w, h, strokePaint, fillPaint, variant);
        break;
      case RealEstateCategory.housingProjects:
        _drawProjectVariants(
            canvas, w, h, strokePaint, fillPaint, windowPaint, variant);
        break;
      case RealEstateCategory.building:
        _drawBuildingVariants(
            canvas, w, h, strokePaint, fillPaint, windowPaint, variant);
        break;
    }
  }

  // 1. Konut Variations (Müstakil Eğimli Villa, Modern Kübik Villa, Çatı Dubleksi, İkiz Sıra Ev)
  void _drawHousingVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint win,
    int v,
  ) {
    final subVar = v % 4;

    if (subVar == 0) {
      // Eğimli Çatılı Müstakil Villa (Geleneksel üçgen çatı, baca, kapı)
      final house = Rect.fromLTWH(w * 0.16, h * 0.44, w * 0.68, h * 0.42);
      canvas.drawRect(house, fill);
      canvas.drawRect(house, stroke);

      final roof = Path()
        ..moveTo(w * 0.10, h * 0.44)
        ..lineTo(w * 0.50, h * 0.16)
        ..lineTo(w * 0.90, h * 0.44)
        ..close();
      canvas.drawPath(roof, fill);
      canvas.drawPath(roof, stroke);

      // Baca
      final chimney = Rect.fromLTWH(w * 0.66, h * 0.18, w * 0.10, h * 0.16);
      canvas.drawRect(chimney, stroke);

      // Kapı ve pencereler
      final door = Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.28);
      canvas.drawRect(door, stroke);

      final w1 = Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.14, h * 0.14);
      final w2 = Rect.fromLTWH(w * 0.64, h * 0.52, w * 0.14, h * 0.14);
      canvas.drawRect(w1, win);
      canvas.drawRect(w1, stroke);
      canvas.drawRect(w2, win);
      canvas.drawRect(w2, stroke);
    } else if (subVar == 1) {
      // Modern Kübik Düz Çatılı Villa (Geniş teras, yatay pencereler, ahşap lamel)
      final mainBlock = Rect.fromLTWH(w * 0.14, h * 0.36, w * 0.50, h * 0.50);
      final upperBlock = Rect.fromLTWH(w * 0.36, h * 0.22, w * 0.50, h * 0.34);
      canvas.drawRect(mainBlock, fill);
      canvas.drawRect(mainBlock, stroke);
      canvas.drawRect(upperBlock, fill);
      canvas.drawRect(upperBlock, stroke);

      // Üst kat teras korkuluğu
      canvas.drawLine(
          Offset(w * 0.14, h * 0.32), Offset(w * 0.36, h * 0.32), stroke);
      canvas.drawLine(
          Offset(w * 0.20, h * 0.32), Offset(w * 0.20, h * 0.36), stroke);
      canvas.drawLine(
          Offset(w * 0.28, h * 0.32), Offset(w * 0.28, h * 0.36), stroke);

      // Yatay geniş camlar
      final wideWin1 = Rect.fromLTWH(w * 0.42, h * 0.28, w * 0.38, h * 0.14);
      final wideWin2 = Rect.fromLTWH(w * 0.20, h * 0.48, w * 0.38, h * 0.18);
      canvas.drawRect(wideWin1, win);
      canvas.drawRect(wideWin1, stroke);
      canvas.drawRect(wideWin2, win);
      canvas.drawRect(wideWin2, stroke);
    } else if (subVar == 2) {
      // Çatı Dubleksi / Penthouse: Mansart eğik tavan pencereleri, balkon
      final base = Rect.fromLTWH(w * 0.14, h * 0.52, w * 0.72, h * 0.34);
      canvas.drawRect(base, fill);
      canvas.drawRect(base, stroke);

      final mansard = Path()
        ..moveTo(w * 0.12, h * 0.52)
        ..lineTo(w * 0.26, h * 0.24)
        ..lineTo(w * 0.74, h * 0.24)
        ..lineTo(w * 0.88, h * 0.52)
        ..close();
      canvas.drawPath(mansard, fill);
      canvas.drawPath(mansard, stroke);

      // Çatı pencereleri (Dormer)
      final d1 = Rect.fromLTWH(w * 0.34, h * 0.28, w * 0.12, h * 0.14);
      final d2 = Rect.fromLTWH(w * 0.54, h * 0.28, w * 0.12, h * 0.14);
      canvas.drawRect(d1, win);
      canvas.drawRect(d1, stroke);
      canvas.drawRect(d2, win);
      canvas.drawRect(d2, stroke);

      // Balkon korkuluğu
      canvas.drawLine(
          Offset(w * 0.20, h * 0.66), Offset(w * 0.80, h * 0.66), stroke);
    } else {
      // 2 Katlı İkiz Sıra Ev (Simetrik ikiz cephe)
      final block = Rect.fromLTWH(w * 0.12, h * 0.40, w * 0.76, h * 0.46);
      canvas.drawRect(block, fill);
      canvas.drawRect(block, stroke);

      // İkiz bölme çizgisi
      canvas.drawLine(
          Offset(w * 0.50, h * 0.18), Offset(w * 0.50, h * 0.86), stroke);

      // İkiz çift çatı kalkanı
      final roof1 = Path()
        ..moveTo(w * 0.10, h * 0.40)
        ..lineTo(w * 0.30, h * 0.18)
        ..lineTo(w * 0.50, h * 0.40);
      final roof2 = Path()
        ..moveTo(w * 0.50, h * 0.40)
        ..lineTo(w * 0.70, h * 0.18)
        ..lineTo(w * 0.90, h * 0.40);
      canvas.drawPath(roof1, stroke);
      canvas.drawPath(roof2, stroke);

      // Çift kapı
      canvas.drawRect(Rect.fromLTWH(w * 0.24, h * 0.64, w * 0.12, h * 0.22), stroke);
      canvas.drawRect(Rect.fromLTWH(w * 0.64, h * 0.64, w * 0.12, h * 0.22), stroke);
    }
  }

  // 2. İş Yeri Variations (Tenteli Dükkan, Cam Plaza Ofis, Sanayi Hangarı)
  void _drawCommercialVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint win,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Çizgili Tenteli Dükkan / Butik Kafe (Geniş vitrin, tente saçakları)
      final shop = Rect.fromLTWH(w * 0.12, h * 0.42, w * 0.76, h * 0.44);
      canvas.drawRect(shop, fill);
      canvas.drawRect(shop, stroke);

      // Çizgili tente
      final awning = Path()
        ..moveTo(w * 0.08, h * 0.42)
        ..lineTo(w * 0.16, h * 0.26)
        ..lineTo(w * 0.84, h * 0.26)
        ..lineTo(w * 0.92, h * 0.42)
        ..close();
      canvas.drawPath(awning, fill);
      canvas.drawPath(awning, stroke);

      // Tente dilimleri
      for (double x = 0.26; x < 0.84; x += 0.14) {
        canvas.drawLine(
            Offset(w * x, h * 0.26), Offset(w * (x - 0.04), h * 0.42), stroke);
      }

      final glassFront = Rect.fromLTWH(w * 0.18, h * 0.50, w * 0.42, h * 0.30);
      canvas.drawRect(glassFront, win);
      canvas.drawRect(glassFront, stroke);

      final door = Rect.fromLTWH(w * 0.66, h * 0.50, w * 0.16, h * 0.36);
      canvas.drawRect(door, stroke);
    } else if (subVar == 1) {
      // Kurumsal Cam Plaza Ofisi (Tam perde cephe gridi, çelik giriş)
      final plaza = Rect.fromLTWH(w * 0.14, h * 0.22, w * 0.72, h * 0.64);
      canvas.drawRect(plaza, fill);
      canvas.drawRect(plaza, stroke);

      // Cam perde cephe ızgarası
      for (double x = 0.28; x < 0.86; x += 0.18) {
        canvas.drawLine(
            Offset(w * x, h * 0.22), Offset(w * x, h * 0.86), stroke);
      }
      for (double y = 0.36; y < 0.86; y += 0.16) {
        canvas.drawLine(
            Offset(w * 0.14, h * y), Offset(w * 0.86, h * y), stroke);
      }

      // Giriş döner kapısı
      final entrance = Rect.fromLTWH(w * 0.40, h * 0.68, w * 0.20, h * 0.18);
      canvas.drawRect(entrance, win);
      canvas.drawRect(entrance, stroke);
    } else {
      // Sanayi Hangarı / Atölye / Depo: Eğimli makas çatı + dev kepenk kapı
      final hangar = Rect.fromLTWH(w * 0.10, h * 0.42, w * 0.80, h * 0.44);
      canvas.drawRect(hangar, fill);
      canvas.drawRect(hangar, stroke);

      // Çelik makas çatı
      final truss = Path()
        ..moveTo(w * 0.08, h * 0.42)
        ..lineTo(w * 0.50, h * 0.22)
        ..lineTo(w * 0.92, h * 0.42)
        ..close();
      canvas.drawPath(truss, fill);
      canvas.drawPath(truss, stroke);

      // Geniş sarmal kepenk kapı
      final rollDoor = Rect.fromLTWH(w * 0.26, h * 0.48, w * 0.48, h * 0.38);
      canvas.drawRect(rollDoor, stroke);
      for (double y = 0.54; y < 0.86; y += 0.08) {
        canvas.drawLine(
            Offset(w * 0.26, h * y), Offset(w * 0.74, h * y), stroke);
      }
    }
  }

  // 3. Arsa Variations (Kadastro Kazıklı Parsel, İmar Planlı Ada, Tarla/Zeytinlik)
  void _drawLandVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Kadastro Parseli & Aplikasyon Kazıkları (İzometrik arsa, köşe kazıkları)
      final parcel = Path()
        ..moveTo(w * 0.14, h * 0.52)
        ..lineTo(w * 0.50, h * 0.26)
        ..lineTo(w * 0.86, h * 0.46)
        ..lineTo(w * 0.50, h * 0.78)
        ..close();
      canvas.drawPath(parcel, fill);
      canvas.drawPath(parcel, stroke);

      // İç kadastro çapraz ölçü çizgisi
      canvas.drawLine(
          Offset(w * 0.14, h * 0.52), Offset(w * 0.86, h * 0.46), stroke);

      // Köşe sınır kazıkları & bayrak
      for (final pt in [
        Offset(w * 0.14, h * 0.52),
        Offset(w * 0.50, h * 0.26),
        Offset(w * 0.86, h * 0.46),
        Offset(w * 0.50, h * 0.78),
      ]) {
        canvas.drawCircle(pt, 2.5, stroke);
      }

      // Sınır aplikasyon bayrağı
      canvas.drawLine(
          Offset(w * 0.50, h * 0.26), Offset(w * 0.50, h * 0.12), stroke);
      final flag = Path()
        ..moveTo(w * 0.50, h * 0.12)
        ..lineTo(w * 0.62, h * 0.18)
        ..lineTo(w * 0.50, h * 0.24)
        ..close();
      canvas.drawPath(flag, stroke);
    } else if (subVar == 1) {
      // İmar Planlı Ada Parsel (Yol sınırları, ada numarası, pusula kuzey oku)
      final plot = Rect.fromLTWH(w * 0.14, h * 0.32, w * 0.58, h * 0.46);
      canvas.drawRect(plot, fill);
      canvas.drawRect(plot, stroke);

      // İmar yol çizgisi
      canvas.drawLine(
          Offset(w * 0.14, h * 0.55), Offset(w * 0.72, h * 0.55), stroke);
      canvas.drawLine(
          Offset(w * 0.43, h * 0.32), Offset(w * 0.43, h * 0.78), stroke);

      // Kuzey pusula oku (North arrow)
      canvas.drawLine(
          Offset(w * 0.84, h * 0.68), Offset(w * 0.84, h * 0.26), stroke);
      final arrow = Path()
        ..moveTo(w * 0.84, h * 0.26)
        ..lineTo(w * 0.80, h * 0.36)
        ..lineTo(w * 0.88, h * 0.36)
        ..close();
      canvas.drawPath(arrow, stroke);
    } else {
      // Tarla / Bahçe / Zeytinlik (Dalgalı tepe kontürü, sıralı ağaçlar)
      final field = Path()
        ..moveTo(w * 0.10, h * 0.78)
        ..quadraticBezierTo(w * 0.34, h * 0.48, w * 0.56, h * 0.56)
        ..quadraticBezierTo(w * 0.74, h * 0.64, w * 0.90, h * 0.46)
        ..lineTo(w * 0.90, h * 0.78)
        ..close();
      canvas.drawPath(field, fill);
      canvas.drawPath(field, stroke);

      // Ağaç / fidan silüetleri
      for (final x in [0.28, 0.48, 0.72]) {
        canvas.drawLine(
            Offset(w * x, h * 0.74), Offset(w * x, h * 0.42), stroke);
        canvas.drawCircle(Offset(w * x, h * 0.42), 4.0, fill);
        canvas.drawCircle(Offset(w * x, h * 0.42), 4.0, stroke);
      }
    }
  }

  // 4. Konut Projeleri Variations (Gökyüzü Köprülü İkiz Kule, Kademeli Rezidans, Çok Bloklu Site)
  void _drawProjectVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint win,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // Gökyüzü Köprülü İkiz Rezidans Kuleleri
      final t1 = Rect.fromLTWH(w * 0.14, h * 0.24, w * 0.28, h * 0.62);
      final t2 = Rect.fromLTWH(w * 0.58, h * 0.18, w * 0.28, h * 0.68);
      canvas.drawRect(t1, fill);
      canvas.drawRect(t1, stroke);
      canvas.drawRect(t2, fill);
      canvas.drawRect(t2, stroke);

      // Gökyüzü bağlantı köprüsü (Skybridge)
      final bridge = Rect.fromLTWH(w * 0.42, h * 0.38, w * 0.16, h * 0.12);
      canvas.drawRect(bridge, win);
      canvas.drawRect(bridge, stroke);

      // Pencereler
      for (double y = 0.32; y < 0.80; y += 0.12) {
        canvas.drawRect(
            Rect.fromLTWH(w * 0.20, h * y, w * 0.16, h * 0.06), win);
        canvas.drawRect(
            Rect.fromLTWH(w * 0.64, h * y, w * 0.16, h * 0.06), win);
      }
    } else if (subVar == 1) {
      // Kademeli Lüks Kule: Aşağıdan yukarı daralan kat terasları
      final b1 = Rect.fromLTWH(w * 0.18, h * 0.64, w * 0.64, h * 0.22);
      final b2 = Rect.fromLTWH(w * 0.28, h * 0.42, w * 0.44, h * 0.22);
      final b3 = Rect.fromLTWH(w * 0.38, h * 0.22, w * 0.24, h * 0.20);
      canvas.drawRect(b1, fill);
      canvas.drawRect(b1, stroke);
      canvas.drawRect(b2, fill);
      canvas.drawRect(b2, stroke);
      canvas.drawRect(b3, fill);
      canvas.drawRect(b3, stroke);

      // Çatı seyir tacı / anten
      canvas.drawLine(
          Offset(w * 0.50, h * 0.22), Offset(w * 0.50, h * 0.12), stroke);
      canvas.drawCircle(Offset(w * 0.50, h * 0.12), 2.0, stroke);
    } else {
      // Çok Bloklu Site Projesi: 3 adet modern blok silüeti
      final bLeft = Rect.fromLTWH(w * 0.10, h * 0.42, w * 0.22, h * 0.44);
      final bCenter = Rect.fromLTWH(w * 0.38, h * 0.24, w * 0.24, h * 0.62);
      final bRight = Rect.fromLTWH(w * 0.68, h * 0.36, w * 0.22, h * 0.50);
      canvas.drawRect(bLeft, fill);
      canvas.drawRect(bLeft, stroke);
      canvas.drawRect(bCenter, fill);
      canvas.drawRect(bCenter, stroke);
      canvas.drawRect(bRight, fill);
      canvas.drawRect(bRight, stroke);

      canvas.drawRect(Rect.fromLTWH(w * 0.44, h * 0.32, w * 0.12, h * 0.08), win);
    }
  }

  // 5. Bina Variations (4 Katlı Klasik Apartman, Zemin Dükkanlı Cadde Binası, Tarihi Cumbahı Konak)
  void _drawBuildingVariants(
    Canvas canvas,
    double w,
    double h,
    Paint stroke,
    Paint fill,
    Paint win,
    int v,
  ) {
    final subVar = v % 3;

    if (subVar == 0) {
      // 4 Katlı Klasik Apartman (Kentsel dönüşüm / apartman)
      final building = Rect.fromLTWH(w * 0.18, h * 0.16, w * 0.64, h * 0.70);
      canvas.drawRect(building, fill);
      canvas.drawRect(building, stroke);

      // Kat silmeleri (Kornişler)
      canvas.drawLine(
          Offset(w * 0.18, h * 0.34), Offset(w * 0.82, h * 0.34), stroke);
      canvas.drawLine(
          Offset(w * 0.18, h * 0.52), Offset(w * 0.82, h * 0.52), stroke);
      canvas.drawLine(
          Offset(w * 0.18, h * 0.70), Offset(w * 0.82, h * 0.70), stroke);

      // Pencereler
      for (double y = 0.20; y < 0.70; y += 0.18) {
        final leftW = Rect.fromLTWH(w * 0.26, h * y, w * 0.16, h * 0.10);
        final rightW = Rect.fromLTWH(w * 0.58, h * y, w * 0.16, h * 0.10);
        canvas.drawRect(leftW, win);
        canvas.drawRect(leftW, stroke);
        canvas.drawRect(rightW, win);
        canvas.drawRect(rightW, stroke);
      }

      // Giriş kapısı
      final door = Rect.fromLTWH(w * 0.42, h * 0.72, w * 0.16, h * 0.14);
      canvas.drawRect(door, stroke);
    } else if (subVar == 1) {
      // Zemin Dükkanlı Cadde Binası: Altta cam dükkan vitrini, üstte 3 kat konut
      final building = Rect.fromLTWH(w * 0.16, h * 0.18, w * 0.68, h * 0.68);
      canvas.drawRect(building, fill);
      canvas.drawRect(building, stroke);

      // Zemin dükkan vitrini
      final shopFront = Rect.fromLTWH(w * 0.20, h * 0.64, w * 0.60, h * 0.22);
      canvas.drawRect(shopFront, win);
      canvas.drawRect(shopFront, stroke);
      canvas.drawLine(
          Offset(w * 0.50, h * 0.64), Offset(w * 0.50, h * 0.86), stroke);

      // Üst kat pencereleri ve balkon çıkıntısı
      for (double y = 0.24; y < 0.60; y += 0.18) {
        final w1 = Rect.fromLTWH(w * 0.24, h * y, w * 0.16, h * 0.10);
        final w2 = Rect.fromLTWH(w * 0.60, h * y, w * 0.16, h * 0.10);
        canvas.drawRect(w1, win);
        canvas.drawRect(w1, stroke);
        canvas.drawRect(w2, win);
        canvas.drawRect(w2, stroke);
      }
    } else {
      // Tarihi Taş/Ahşap Konak: Orta cumba çıkıntısı, kavisli pencereler
      final mansion = Rect.fromLTWH(w * 0.14, h * 0.24, w * 0.72, h * 0.62);
      canvas.drawRect(mansion, fill);
      canvas.drawRect(mansion, stroke);

      // Orta cumba (Bay window çıkıntısı)
      final cumba = Rect.fromLTWH(w * 0.36, h * 0.20, w * 0.28, h * 0.36);
      canvas.drawRect(cumba, fill);
      canvas.drawRect(cumba, stroke);

      final cumbaWin = Rect.fromLTWH(w * 0.40, h * 0.26, w * 0.20, h * 0.16);
      canvas.drawRect(cumbaWin, win);
      canvas.drawRect(cumbaWin, stroke);

      // Giriş kemerli kapı
      final entrance = Rect.fromLTWH(w * 0.42, h * 0.66, w * 0.16, h * 0.20);
      canvas.drawRect(entrance, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _RealEstateVectorPainter oldDelegate) =>
      oldDelegate.category != category ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.variant != variant ||
      oldDelegate.isDark != isDark;
}

int _resolveVariantIndex(String? seed, int modulo) {
  if (seed == null || seed.isEmpty || modulo <= 1) return 0;
  return seed.hashCode.abs() % modulo;
}
