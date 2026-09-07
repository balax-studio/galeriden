import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';

enum NeoBrutalStampType {
  approved, // Yeşil ONAYLANDI / DEVİR TAMAM
  rejected, // Kırmızı REDDEDİLDİ / TEKLİF DÜŞÜK
  bargain,  // Asit Sarısı / Toksik Yeşil KELEPİR FIRSAT
  notary,   // Turuncu NOTER TASDİKLİ
  inspected,// Siber Camgöbeği KUSURSUZ EKSPERTİZ
  pert,     // Bordo / Kırmızı AĞIR HASARLI
}

/// Neo-Brutalist Tactile Rubber Ink Stamp.
/// Simulates an authentic, physical industrial / notary ink seal slammed down on paper.
/// Features double-line borders, angled rotational tilt, and slam-down entrance animation.
class NeoBrutalStamp extends StatelessWidget {
  final String text;
  final String? subtext;
  final IconData? icon;
  final Color? color;
  final NeoBrutalStampType type;
  final double angle;
  final bool animate;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const NeoBrutalStamp({
    super.key,
    required this.text,
    this.subtext,
    this.icon,
    this.color,
    this.type = NeoBrutalStampType.approved,
    this.angle = -0.06, // approx -3.5 degrees
    this.animate = true,
    this.fontSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  });

  const NeoBrutalStamp.approved({
    super.key,
    this.text = 'ONAYLANDI',
    this.subtext = 'NOTER TASDİKLİ',
    this.icon = Icons.verified_rounded,
    this.color,
    this.angle = -0.05,
    this.animate = true,
    this.fontSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  }) : type = NeoBrutalStampType.approved;

  const NeoBrutalStamp.rejected({
    super.key,
    this.text = 'REDDEDİLDİ',
    this.subtext = 'TEKLİF YETERSİZ',
    this.icon = Icons.cancel_outlined,
    this.color,
    this.angle = 0.05,
    this.animate = true,
    this.fontSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  }) : type = NeoBrutalStampType.rejected;

  const NeoBrutalStamp.bargain({
    super.key,
    this.text = 'KELEPİR FIRSAT',
    this.subtext = 'PİYASA ALTI',
    this.icon = Icons.local_fire_department_rounded,
    this.color,
    this.angle = -0.07,
    this.animate = true,
    this.fontSize = 13.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  }) : type = NeoBrutalStampType.bargain;

  Color _getColor() {
    if (color != null) return color!;
    switch (type) {
      case NeoBrutalStampType.approved:
        return AppColors.brutalGreen;
      case NeoBrutalStampType.rejected:
      case NeoBrutalStampType.pert:
        return const Color(0xFFEF4444);
      case NeoBrutalStampType.bargain:
        return AppColors.toxicLime;
      case NeoBrutalStampType.notary:
        return AppColors.brutalOrange;
      case NeoBrutalStampType.inspected:
        return AppColors.brutalCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stampColor = _getColor();

    Widget stamp = Transform.rotate(
      angle: angle,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: stampColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: stampColor,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: stampColor.withValues(alpha: 0.25),
              offset: const Offset(2.5, 2.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: stampColor.withValues(alpha: 0.6),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: stampColor, size: fontSize + 3),
                const SizedBox(width: 6),
              ],
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      color: stampColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      height: 1.1,
                    ),
                  ),
                  if (subtext != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtext!.toUpperCase(),
                      style: TextStyle(
                        color: stampColor.withValues(alpha: 0.85),
                        fontSize: (fontSize * 0.65).clamp(8.0, 11.0),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (animate) {
      stamp = stamp
          .animate()
          .scale(
            begin: const Offset(1.5, 1.5),
            end: const Offset(1.0, 1.0),
            duration: 220.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 150.ms);
    }

    return stamp;
  }
}
