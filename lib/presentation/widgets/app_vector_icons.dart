import 'package:flutter/material.dart';

class VectorIconWidget extends StatelessWidget {
  final String type; // 'car', 'expertise', 'workshop', 'negotiation', 'theme_store', 'streak', 'rare', 'flash', 'craftsman'
  final Color color;
  final double size;

  const VectorIconWidget({
    super.key,
    required this.type,
    required this.color,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VectorIconPainter(type: type, iconColor: color),
    );
  }
}

class _VectorIconPainter extends CustomPainter {
  final String type;
  final Color iconColor;

  _VectorIconPainter({required this.type, required this.iconColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = iconColor
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    switch (type) {
      case 'rare':
        // Diamond Vector
        final path = Path();
        path.moveTo(w * 0.50, h * 0.10);
        path.lineTo(w * 0.85, h * 0.40);
        path.lineTo(w * 0.50, h * 0.90);
        path.lineTo(w * 0.15, h * 0.40);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawLine(Offset(w * 0.15, h * 0.40), Offset(w * 0.85, h * 0.40), paint);
        canvas.drawLine(Offset(w * 0.50, h * 0.10), Offset(w * 0.50, h * 0.90), paint);
        break;

      case 'flash':
        // Lightning Bolt Vector
        final path = Path();
        path.moveTo(w * 0.55, h * 0.10);
        path.lineTo(w * 0.20, h * 0.55);
        path.lineTo(w * 0.50, h * 0.55);
        path.lineTo(w * 0.45, h * 0.90);
        path.lineTo(w * 0.80, h * 0.45);
        path.lineTo(w * 0.50, h * 0.45);
        path.close();
        canvas.drawPath(path, fillPaint);
        break;

      case 'craftsman':
        // Hammer Vector
        final path = Path();
        path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.30, h * 0.15, w * 0.40, h * 0.20), const Radius.circular(3)));
        path.moveTo(w * 0.50, h * 0.35);
        path.lineTo(w * 0.50, h * 0.85);
        canvas.drawPath(path, paint);
        break;

      case 'expertise':
        // Magnifying Glass + Inspection Badge
        canvas.drawCircle(Offset(w * 0.45, h * 0.45), w * 0.30, paint);
        canvas.drawLine(Offset(w * 0.65, h * 0.65), Offset(w * 0.90, h * 0.90), paint);
        canvas.drawCircle(Offset(w * 0.45, h * 0.45), w * 0.10, fillPaint);
        break;

      case 'workshop':
        // Wrench & Gear
        final path = Path();
        path.moveTo(w * 0.20, h * 0.80);
        path.lineTo(w * 0.60, h * 0.40);
        path.arcToPoint(Offset(w * 0.80, h * 0.20), radius: Radius.circular(w * 0.2));
        path.lineTo(w * 0.70, h * 0.30);
        path.lineTo(w * 0.50, h * 0.50);
        path.close();
        canvas.drawPath(path, paint);
        break;

      case 'negotiation':
        // Handshake / Contract Document
        final path = Path();
        path.addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.15, h * 0.10, w * 0.70, h * 0.80), const Radius.circular(4)));
        canvas.drawPath(path, paint);
        canvas.drawLine(Offset(w * 0.30, h * 0.35), Offset(w * 0.70, h * 0.35), paint);
        canvas.drawLine(Offset(w * 0.30, h * 0.55), Offset(w * 0.70, h * 0.55), paint);
        canvas.drawLine(Offset(w * 0.30, h * 0.70), Offset(w * 0.55, h * 0.70), paint);
        break;

      case 'theme_store':
        // Color Palette & Brush
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.40, paint);
        canvas.drawCircle(Offset(w * 0.35, h * 0.35), w * 0.08, fillPaint);
        canvas.drawCircle(Offset(w * 0.65, h * 0.35), w * 0.08, fillPaint);
        canvas.drawCircle(Offset(w * 0.30, h * 0.60), w * 0.08, fillPaint);
        break;

      case 'streak':
        // Flame Silhouette
        final path = Path();
        path.moveTo(w * 0.50, h * 0.10);
        path.quadraticBezierTo(w * 0.85, h * 0.45, w * 0.85, h * 0.70);
        path.arcToPoint(Offset(w * 0.15, h * 0.70), radius: Radius.circular(w * 0.35));
        path.quadraticBezierTo(w * 0.15, h * 0.45, w * 0.50, h * 0.10);
        canvas.drawPath(path, fillPaint);
        break;

      case 'crown':
        // Crown Emblem
        final crownPath = Path();
        crownPath.moveTo(w * 0.15, h * 0.75);
        crownPath.lineTo(w * 0.15, h * 0.35);
        crownPath.lineTo(w * 0.35, h * 0.55);
        crownPath.lineTo(w * 0.50, h * 0.20);
        crownPath.lineTo(w * 0.65, h * 0.55);
        crownPath.lineTo(w * 0.85, h * 0.35);
        crownPath.lineTo(w * 0.85, h * 0.75);
        crownPath.close();
        canvas.drawPath(crownPath, fillPaint);
        break;

      case 'shield':
        // Shield Emblem
        final shieldPath = Path();
        shieldPath.moveTo(w * 0.50, h * 0.15);
        shieldPath.lineTo(w * 0.85, h * 0.25);
        shieldPath.lineTo(w * 0.85, h * 0.60);
        shieldPath.quadraticBezierTo(w * 0.50, h * 0.90, w * 0.50, h * 0.90);
        shieldPath.quadraticBezierTo(w * 0.50, h * 0.90, w * 0.15, h * 0.60);
        shieldPath.lineTo(w * 0.15, h * 0.25);
        shieldPath.close();
        canvas.drawPath(shieldPath, paint);
        break;

      case 'star':
        // Star Emblem
        final starPath = Path();
        starPath.moveTo(w * 0.50, h * 0.10);
        starPath.lineTo(w * 0.62, h * 0.38);
        starPath.lineTo(w * 0.90, h * 0.40);
        starPath.lineTo(w * 0.68, h * 0.60);
        starPath.lineTo(w * 0.75, h * 0.90);
        starPath.lineTo(w * 0.50, h * 0.73);
        starPath.lineTo(w * 0.25, h * 0.90);
        starPath.lineTo(w * 0.32, h * 0.60);
        starPath.lineTo(w * 0.10, h * 0.40);
        starPath.lineTo(w * 0.38, h * 0.38);
        starPath.close();
        canvas.drawPath(starPath, fillPaint);
        break;

      case 'eagle':
        // Eagle / Wings Emblem
        final wingPath = Path();
        wingPath.moveTo(w * 0.10, h * 0.30);
        wingPath.lineTo(w * 0.50, h * 0.50);
        wingPath.lineTo(w * 0.90, h * 0.30);
        wingPath.lineTo(w * 0.75, h * 0.75);
        wingPath.lineTo(w * 0.50, h * 0.60);
        wingPath.lineTo(w * 0.25, h * 0.75);
        wingPath.close();
        canvas.drawPath(wingPath, paint);
        break;

      case 'vintage':
        // Vintage Badge Crest
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.38, paint);
        canvas.drawRect(Rect.fromLTWH(w * 0.25, h * 0.42, w * 0.50, h * 0.16), fillPaint);
        break;

      case 'wash':
        // Car Wash / Pressure Foam Jet Vector
        final washPath = Path();
        washPath.moveTo(w * 0.20, h * 0.30);
        washPath.lineTo(w * 0.50, h * 0.50);
        washPath.lineTo(w * 0.40, h * 0.65);
        washPath.lineTo(w * 0.15, h * 0.45);
        washPath.close();
        canvas.drawPath(washPath, fillPaint);
        // Spray lines
        canvas.drawLine(Offset(w * 0.55, h * 0.45), Offset(w * 0.85, h * 0.30), paint);
        canvas.drawLine(Offset(w * 0.55, h * 0.55), Offset(w * 0.90, h * 0.55), paint);
        canvas.drawLine(Offset(w * 0.55, h * 0.65), Offset(w * 0.85, h * 0.80), paint);
        break;

      case 'trophy':
        // Championship Trophy Cup
        final trophyPath = Path();
        trophyPath.moveTo(w * 0.25, h * 0.15);
        trophyPath.lineTo(w * 0.75, h * 0.15);
        trophyPath.lineTo(w * 0.65, h * 0.55);
        trophyPath.quadraticBezierTo(w * 0.50, h * 0.70, w * 0.35, h * 0.55);
        trophyPath.close();
        canvas.drawPath(trophyPath, fillPaint);
        // Trophy base & stem
        canvas.drawLine(Offset(w * 0.50, h * 0.65), Offset(w * 0.50, h * 0.80), paint);
        canvas.drawRect(Rect.fromLTWH(w * 0.30, h * 0.80, w * 0.40, h * 0.10), fillPaint);
        break;

      case 'coin':
        // Coin Vector
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.38, paint);
        canvas.drawLine(Offset(w * 0.42, h * 0.28), Offset(w * 0.42, h * 0.72), paint);
        canvas.drawLine(Offset(w * 0.42, h * 0.42), Offset(w * 0.65, h * 0.35), paint);
        canvas.drawLine(Offset(w * 0.42, h * 0.52), Offset(w * 0.62, h * 0.45), paint);
        break;

      case 'turbo':
        // Turbocharger Turbine
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.38, paint);
        canvas.drawCircle(Offset(w * 0.50, h * 0.50), w * 0.15, fillPaint);
        final spiral = Path();
        spiral.moveTo(w * 0.50, h * 0.12);
        spiral.quadraticBezierTo(w * 0.88, h * 0.20, w * 0.88, h * 0.60);
        canvas.drawPath(spiral, paint);
        break;

      case 'check':
        // Sharp Neo-Brutalist Checkmark
        final checkPath = Path();
        checkPath.moveTo(w * 0.20, h * 0.50);
        checkPath.lineTo(w * 0.42, h * 0.72);
        checkPath.lineTo(w * 0.80, h * 0.25);
        canvas.drawPath(checkPath, paint);
        break;

      case 'car':
      default:
        // Minimalist Car Silhouette Icon
        final path = Path();
        path.moveTo(w * 0.10, h * 0.65);
        path.quadraticBezierTo(w * 0.25, h * 0.35, w * 0.40, h * 0.30);
        path.lineTo(w * 0.65, h * 0.30);
        path.quadraticBezierTo(w * 0.80, h * 0.35, w * 0.90, h * 0.65);
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(w * 0.28, h * 0.68), w * 0.10, fillPaint);
        canvas.drawCircle(Offset(w * 0.72, h * 0.68), w * 0.10, fillPaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _VectorIconPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.iconColor != iconColor;
}

class AvatarIconWidget extends StatelessWidget {
  final String avatar;
  final Color color;
  final double size;

  const AvatarIconWidget({
    super.key,
    required this.avatar,
    required this.color,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    // Map avatar semantic key to vector icon
    switch (avatar) {
      case 'wrench':
      case 'mechanic':
      case 'workshop':
        return VectorIconWidget(type: 'workshop', color: color, size: size);
      case 'expert':
      case 'magnifier':
      case 'detective':
      case 'detective_man':
      case 'inspector':
        return VectorIconWidget(type: 'expertise', color: color, size: size);
      case 'deal':
      case 'contract':
      case 'briefcase':
      case 'handshake':
      case 'negotiation':
        return VectorIconWidget(type: 'negotiation', color: color, size: size);
      case 'rare':
      case 'diamond':
        return VectorIconWidget(type: 'rare', color: color, size: size);
      case 'flash':
      case 'lightning':
      case 'bolt':
        return VectorIconWidget(type: 'flash', color: color, size: size);
      case 'flame':
      case 'fire':
      case 'streak':
        return VectorIconWidget(type: 'streak', color: color, size: size);
      case 'crown':
      case 'vip':
      case 'sunglasses':
        return VectorIconWidget(type: 'crown', color: color, size: size);
      case 'shield':
      case 'security':
      case 'flashlight':
      case 'guard':
        return VectorIconWidget(type: 'shield', color: color, size: size);
      case 'trophy':
      case 'champion':
      case 'award':
        return VectorIconWidget(type: 'trophy', color: color, size: size);
      case 'star':
        return VectorIconWidget(type: 'star', color: color, size: size);
      case 'craftsman':
      case 'hammer':
      case 'grandpa':
        return VectorIconWidget(type: 'craftsman', color: color, size: size);
      case 'heritage':
      case 'vintage':
      case 'rose':
        return VectorIconWidget(type: 'vintage', color: color, size: size);
      case 'wash':
      case 'cleaning':
      case 'sponge':
      case 'soap':
        return VectorIconWidget(type: 'wash', color: color, size: size);
      case 'turbo':
      case 'dyno':
      case 'engine_boost':
        return VectorIconWidget(type: 'turbo', color: color, size: size);
      case 'coin':
      case 'cash':
      case 'money':
      case 'lira':
        return VectorIconWidget(type: 'coin', color: color, size: size);
      case 'check':
      case 'verified':
        return VectorIconWidget(type: 'check', color: color, size: size);
      case 'sparkles':
      case 'sparkle':
        return Icon(Icons.auto_awesome_rounded, color: color, size: size);
      case 'coffee':
        return Icon(Icons.local_cafe_rounded, color: color, size: size);
      case 'camera':
      case 'video':
        return Icon(Icons.videocam_rounded, color: color, size: size);
      case 'clipboard':
      case 'letter':
      case 'mail':
        return Icon(Icons.assignment_rounded, color: color, size: size);
      case 'parts':
      case 'bolt_part':
        return Icon(Icons.settings_rounded, color: color, size: size);
      case 'truck':
      case 'tow':
      case 'shipping':
        return Icon(Icons.local_shipping_rounded, color: color, size: size);
      case 'banker':
      case 'suit':
      case 'bank':
        return Icon(Icons.account_balance_rounded, color: color, size: size);
      case 'couple':
      case 'family':
      case 'people':
        return Icon(Icons.people_alt_rounded, color: color, size: size);
      case 'elder':
      case 'grandma':
        return Icon(Icons.person_rounded, color: color, size: size);
      case 'rival':
      case 'smirk':
        return Icon(Icons.psychology_rounded, color: color, size: size);
      case 'dice':
      case 'risk':
        return Icon(Icons.casino_rounded, color: color, size: size);
      case 'slot':
      case 'casino':
        return Icon(Icons.monetization_on_rounded, color: color, size: size);
      case 'siren':
        return Icon(Icons.warning_amber_rounded, color: color, size: size);
      case 'rain':
        return Icon(Icons.water_drop_rounded, color: color, size: size);
      case 'cat':
      case 'dog':
        return Icon(Icons.pets_rounded, color: color, size: size);
      case 'pothole':
        return Icon(Icons.construction_rounded, color: color, size: size);
      case 'eagle':
        return Icon(Icons.flight_rounded, color: color, size: size);
      case 'phone':
        return Icon(Icons.phone_android_rounded, color: color, size: size);
      case 'party':
        return Icon(Icons.celebration_rounded, color: color, size: size);
      case 'clown':
        return Icon(Icons.theater_comedy_rounded, color: color, size: size);
      case 'ghost':
        return Icon(Icons.auto_fix_high_rounded, color: color, size: size);
      case 'sandwich':
        return Icon(Icons.lunch_dining_rounded, color: color, size: size);
      case 'megaphone':
        return Icon(Icons.campaign_rounded, color: color, size: size);
      default:
        return Icon(Icons.person_rounded, color: color, size: size);
    }
  }
}

