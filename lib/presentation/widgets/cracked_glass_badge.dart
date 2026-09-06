import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_localizations.dart';
import '../../data/models/expertise_model.dart';

/// Ağır hasarlı, değişenli, boyalı, mekanik kusurlu veya şasisi işlemli araçlarda
/// beliren dinamik kusur rozeti ve mikro titreme animasyonu.
class CrackedGlassBadge extends StatefulWidget {
  final double size;
  final bool showLabel;
  final String? customLabel;
  final ExpertiseReport? expertise;
  final bool isChassisRepaired;

  const CrackedGlassBadge({
    super.key,
    this.size = 28,
    this.showLabel = false,
    this.customLabel,
    this.expertise,
    this.isChassisRepaired = false,
  });

  @override
  State<CrackedGlassBadge> createState() => _CrackedGlassBadgeState();
}

class _CrackedGlassBadgeState extends State<CrackedGlassBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0.0);
  }

  _DefectBadgeInfo _resolveBadgeInfo(BuildContext context) {
    if (widget.customLabel != null && widget.customLabel!.isNotEmpty) {
      return _DefectBadgeInfo(
        label: widget.customLabel!,
        backgroundColor: const Color(0xFFEF4444),
        isSpiderWebIcon: true,
      );
    }

    final exp = widget.expertise;
    if (exp == null) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_cracked_glass'),
        backgroundColor: const Color(0xFFEF4444),
        isSpiderWebIcon: true,
      );
    }

    final changedCount = exp.bodyParts.values
        .where((s) => s == PartStatus.changed || s == PartStatus.damaged)
        .length;
    final paintedCount =
        exp.bodyParts.values.where((s) => s == PartStatus.painted).length;
    final isRoofDamaged = exp.bodyParts['Tavan'] == PartStatus.changed ||
        exp.bodyParts['Tavan'] == PartStatus.damaged;

    if (exp.tramerAmount >= 75000 || isRoofDamaged) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_heavy_damage'),
        backgroundColor: const Color(0xFFDC2626), // Deep Crimson Red
        icon: Icons.warning_amber_rounded,
        isSpiderWebIcon: false,
      );
    }

    if (widget.isChassisRepaired || !exp.isChassisAligned) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_chassis_flaw'),
        backgroundColor: const Color(0xFFE11D48), // Rose Red
        icon: Icons.dangerous_rounded,
        isSpiderWebIcon: false,
      );
    }

    if (changedCount >= 2) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_changed_parts'),
        backgroundColor: const Color(0xFFEA580C), // High-alert Orange
        icon: Icons.build_rounded,
        isSpiderWebIcon: false,
      );
    }

    if (exp.engineCondition < 50 || exp.transmissionCondition < 50) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_mechanical_flaw'),
        backgroundColor: const Color(0xFF7C3AED), // Warning Purple
        icon: Icons.settings_rounded,
        isSpiderWebIcon: false,
      );
    }

    if (paintedCount >= 2) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_painted_parts'),
        backgroundColor: const Color(0xFFD97706), // Amber Ochre
        icon: Icons.format_paint_rounded,
        isSpiderWebIcon: false,
      );
    }

    if (exp.tramerAmount > 30000) {
      return _DefectBadgeInfo(
        label: context.tr('sticker_high_tramer'),
        backgroundColor: const Color(0xFFE11D48),
        icon: Icons.receipt_long_rounded,
        isSpiderWebIcon: false,
      );
    }

    return _DefectBadgeInfo(
      label: context.tr('sticker_cracked_glass'),
      backgroundColor: const Color(0xFFEF4444),
      isSpiderWebIcon: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _resolveBadgeInfo(context);

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          final offset = math.sin(_shakeAnimation.value * math.pi * 6) * 3;
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
          decoration: BoxDecoration(
            color: info.backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black, width: 1.8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(1.5, 1.5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (info.isSpiderWebIcon)
                CustomPaint(
                  size: Size(widget.size * 0.7, widget.size * 0.7),
                  painter: _CrackedGlassPainter(),
                )
              else if (info.icon != null)
                Icon(
                  info.icon,
                  size: widget.size * 0.55,
                  color: Colors.white,
                ),
              if (widget.showLabel) ...[
                const SizedBox(width: 4.5),
                Flexible(
                  child: Text(
                    info.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DefectBadgeInfo {
  final String label;
  final Color backgroundColor;
  final IconData? icon;
  final bool isSpiderWebIcon;

  const _DefectBadgeInfo({
    required this.label,
    required this.backgroundColor,
    this.icon,
    this.isSpiderWebIcon = false,
  });
}

class _CrackedGlassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    // Cracked glass spider web lines
    final path = Path()
      ..moveTo(w * 0.1, h * 0.2)
      ..lineTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.9, h * 0.3)
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.4, h * 0.9)
      ..moveTo(w * 0.5, h * 0.5)
      ..lineTo(w * 0.85, h * 0.8)
      ..moveTo(w * 0.3, h * 0.35)
      ..lineTo(w * 0.2, h * 0.7);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
