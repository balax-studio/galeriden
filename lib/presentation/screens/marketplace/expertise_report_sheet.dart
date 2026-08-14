import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/expertise_engine.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/car_damage_schema_widget.dart';
import 'interactive_negotiation_sheet.dart';

class ExpertiseReportSheet extends StatelessWidget {
  final CarModel car;
  final ListingModel? listing;

  const ExpertiseReportSheet({
    super.key,
    required this.car,
    this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).extension<AppThemeExtension>()!.palette;
    final eval = ExpertiseEngine.evaluateVehicle(car);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.surfaceBorderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RESMİ EKSPERTİZ RAPORU', style: AppTypography.titleLarge(p.isDark)),
                    Text('${car.brand} ${car.modelName} (${car.modelYear})', style: AppTypography.labelSmall(p.isDark)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: p.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: p.primaryColor),
                  ),
                  child: Text(
                    eval['overallGrade'] as String,
                    style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4th Wall Developer Humor Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.secondaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: p.secondaryColor.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.psychology_rounded, color: p.secondaryColor, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      eval['developerNote'] as String,
                      style: AppTypography.bodyMedium(p.isDark).copyWith(
                        fontStyle: FontStyle.italic,
                        color: p.secondaryColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tramer & Mileage Specs
            Row(
              children: [
                Expanded(
                  child: _buildSpecTile(
                    'Tramer Kaydı',
                    car.expertise.tramerAmount > 0 ? '₺${CurrencyFormatter.formatShort(car.expertise.tramerAmount.toDouble())}' : 'Hasar Kayıtsız',
                    car.expertise.tramerAmount > 0 ? p.errorColor : p.successColor,
                    p,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSpecTile(
                    'Kilometre',
                    '${CurrencyFormatter.formatShort(car.expertise.mileage.toDouble())} km',
                    car.expertise.isMileageTampered ? p.errorColor : p.textPrimaryColor,
                    p,
                    subtitle: car.expertise.isMileageTampered ? 'Düşürülmüş KM' : 'Orijinal KM',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kaporta Damage Schema
            Text('KAPORTA / BOYA / HASAR ŞEMASI', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 8),
            CarDamageSchemaWidget(bodyParts: car.expertise.bodyParts),
            const SizedBox(height: 20),

            // Action Buttons
            if (listing != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: VectorIconWidget(type: 'negotiation', color: Colors.black, size: 18),
                  label: const Text('Pazarlık Et & Satın Al', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: p.primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final targetListing = listing!;
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => InteractiveNegotiationSheet(listing: targetListing),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.textPrimaryColor,
                  side: BorderSide(color: p.surfaceBorderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Raporu Kapat', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecTile(String title, String value, Color valueColor, ThemePaletteModel p, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.surfaceBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSmall(p.isDark)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 15)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: valueColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
