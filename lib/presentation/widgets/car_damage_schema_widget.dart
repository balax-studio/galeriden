import '../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../data/models/theme_palette_model.dart';
import '../../core/theme/app_theme_extension.dart';
import '../../data/models/expertise_model.dart';

class CarDamageSchemaWidget extends StatelessWidget {
  final Map<String, PartStatus> bodyParts;

  const CarDamageSchemaWidget({
    super.key,
    required this.bodyParts,
  });

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 6,
          children: [
            Text(
              context.tr('damage_schema_title'),
              style: TextStyle(
                color: p.textPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _buildLegendItem(
                    context.tr('damage_status_original'), p.successColor, p),
                _buildLegendItem(
                    context.tr('damage_status_painted'), p.warningColor, p),
                _buildLegendItem(
                    context.tr('damage_status_changed'), p.errorColor, p),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Interactive 2D Top-Down Vehicle Diagram Grid
        RepaintBoundary(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.surfaceBorderColor, width: 2.0),
            ),
            child: Column(
              children: [
                // FRONT: Hood (Kaput) & Front Fenders
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: _buildPartBox(
                              context.tr('part_left_front_fender'),
                              bodyParts['Sol Ön Çamurluk'],
                              p,
                              context)),
                      const SizedBox(width: 6),
                      Expanded(
                          flex: 2,
                          child: _buildPartBox(context.tr('part_hood'),
                              bodyParts['Kaput'], p, context,
                              isHighlight: true)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildPartBox(
                              context.tr('part_right_front_fender'),
                              bodyParts['Sağ Ön Çamurluk'],
                              p,
                              context)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // MIDDLE: Doors & Roof (Tavan)
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildPartBox(context.tr('part_left_front_door'),
                                bodyParts['Sol Ön Kapı'], p, context),
                            const SizedBox(height: 6),
                            _buildPartBox(context.tr('part_left_rear_door'),
                                bodyParts['Sol Arka Kapı'], p, context),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        flex: 2,
                        child: _buildPartBox(
                          context.tr('part_roof_critical'),
                          bodyParts['Tavan'],
                          p,
                          context,
                          minHeight: 86,
                          isHighlight: true,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          children: [
                            _buildPartBox(context.tr('part_right_front_door'),
                                bodyParts['Sağ Ön Kapı'], p, context),
                            const SizedBox(height: 6),
                            _buildPartBox(context.tr('part_right_rear_door'),
                                bodyParts['Sağ Arka Kapı'], p, context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // REAR: Trunk (Bagaj) & Rear Fenders
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                          child: _buildPartBox(
                              context.tr('part_left_rear_fender'),
                              bodyParts['Sol Arka Çamurluk'],
                              p,
                              context)),
                      const SizedBox(width: 6),
                      Expanded(
                          flex: 2,
                          child: _buildPartBox(context.tr('part_trunk'),
                              bodyParts['Bagaj'], p, context,
                              isHighlight: true)),
                      const SizedBox(width: 6),
                      Expanded(
                          child: _buildPartBox(
                              context.tr('part_right_rear_fender'),
                              bodyParts['Sağ Arka Çamurluk'],
                              p,
                              context)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Chassis Status Warning Banner
                if (bodyParts.containsKey('Şasi/Podye') &&
                    bodyParts['Şasi/Podye'] != PartStatus.original)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: p.errorColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.errorColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: p.errorColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr('damage_chassis_warning'),
                            style: TextStyle(
                                color: p.errorColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPartBox(String label, PartStatus? status, ThemePaletteModel p,
      BuildContext context,
      {double minHeight = 46, bool isHighlight = false}) {
    Color statusColor;
    String statusText;

    switch (status) {
      case PartStatus.painted:
        statusColor = p.warningColor;
        statusText = context.tr('damage_status_painted');
        break;
      case PartStatus.localPainted:
        statusColor = const Color(0xFFA855F7);
        statusText = context.tr('vasita_expertise_local_painted');
        break;
      case PartStatus.changed:
        statusColor = p.errorColor;
        statusText = context.tr('damage_status_changed');
        break;
      case PartStatus.damaged:
        statusColor = const Color(0xFF8B0000);
        statusText = context.tr('damage_status_damaged');
        break;
      case PartStatus.original:
      default:
        statusColor = p.successColor;
        statusText = context.tr('damage_status_original');
        break;
    }

    return Container(
      constraints: BoxConstraints(minHeight: minHeight),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusColor,
          width: isHighlight ? 2.2 : 1.5,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: p.textPrimaryColor,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemePaletteModel p) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                color: p.textSecondaryColor,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
