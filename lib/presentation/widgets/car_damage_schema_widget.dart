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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('EKSPERTİZ KAPORTA ŞEMASI', style: TextStyle(color: p.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
            Row(
              children: [
                _buildLegendItem('Orijinal', p.successColor, p),
                const SizedBox(width: 8),
                _buildLegendItem('Boya', p.warningColor, p),
                const SizedBox(width: 8),
                _buildLegendItem('Değişen', p.errorColor, p),
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
                    Expanded(child: _buildPartBox('Sol Ön Çamurluk', bodyParts['Sol Ön Çamurluk'], p)),
                    const SizedBox(width: 6),
                    Expanded(flex: 2, child: _buildPartBox('KAPUT', bodyParts['Kaput'], p, isHighlight: true)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildPartBox('Sağ Ön Çamurluk', bodyParts['Sağ Ön Çamurluk'], p)),
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
                          _buildPartBox('Sol Ön Kapı', bodyParts['Sol Ön Kapı'], p),
                          const SizedBox(height: 6),
                          _buildPartBox('Sol Arka Kapı', bodyParts['Sol Arka Kapı'], p),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      flex: 2,
                      child: _buildPartBox(
                        'TAVAN\n• Tavan Boyasızlığı Kritik',
                        bodyParts['Tavan'],
                        p,
                        minHeight: 86,
                        isHighlight: true,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        children: [
                          _buildPartBox('Sağ Ön Kapı', bodyParts['Sağ Ön Kapı'], p),
                          const SizedBox(height: 6),
                          _buildPartBox('Sağ Arka Kapı', bodyParts['Sağ Arka Kapı'], p),
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
                    Expanded(child: _buildPartBox('Sol Arka Çamurluk', bodyParts['Sol Arka Çamurluk'], p)),
                    const SizedBox(width: 6),
                    Expanded(flex: 2, child: _buildPartBox('BAGAJ', bodyParts['Bagaj'], p, isHighlight: true)),
                    const SizedBox(width: 6),
                    Expanded(child: _buildPartBox('Sağ Arka Çamurluk', bodyParts['Sağ Arka Çamurluk'], p)),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Chassis Status Warning Banner
              if (bodyParts.containsKey('Şasi/Podye') && bodyParts['Şasi/Podye'] != PartStatus.original)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: p.errorColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.errorColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: p.errorColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Şasi / Podye Hasarlı veya İşlemli!',
                          style: TextStyle(color: p.errorColor, fontWeight: FontWeight.bold, fontSize: 12),
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

  Widget _buildPartBox(String label, PartStatus? status, ThemePaletteModel p, {double minHeight = 46, bool isHighlight = false}) {
    Color statusColor;
    String statusText;

    switch (status) {
      case PartStatus.painted:
        statusColor = p.warningColor;
        statusText = 'Boyalı';
        break;
      case PartStatus.changed:
        statusColor = p.errorColor;
        statusText = 'Değişen';
        break;
      case PartStatus.damaged:
        statusColor = const Color(0xFF8B0000);
        statusText = 'Hasarlı';
        break;
      case PartStatus.original:
      default:
        statusColor = p.successColor;
        statusText = 'Orijinal';
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
        Text(label, style: TextStyle(fontSize: 11, color: p.textSecondaryColor, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
