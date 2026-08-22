import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/expertise_engine.dart';
import '../../widgets/car_damage_schema_widget.dart';
import '../../widgets/neo_brutal_button.dart';

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
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final eval = ExpertiseEngine.evaluateVehicle(car);

    return Container(
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: p.surfaceBorderColor, width: 3),
          left: BorderSide(color: p.surfaceBorderColor, width: 2),
          right: BorderSide(color: p.surfaceBorderColor, width: 2),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: p.textSecondaryColor.withValues(alpha: 0.3),
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
                    Text(context.tr('expertise_official_title'), style: AppTypography.titleLarge(p.isDark)),
                    Text('${car.brand} ${car.modelName} • ${car.modelYear}', style: AppTypography.labelSmall(p.isDark)),
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

            // Expert Inspection Note Card
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
                  Icon(Icons.fact_check_rounded, color: p.secondaryColor, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      eval['developerNote'] as String,
                      style: AppTypography.bodyMedium(p.isDark).copyWith(
                        fontWeight: FontWeight.w600,
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
                    context.tr('listing_tramer'),
                    car.expertise.tramerAmount > 0 ? CurrencyFormatter.formatShort(car.expertise.tramerAmount.toDouble()) : context.tr('listing_no_damage'),
                    car.expertise.tramerAmount > 0 ? p.errorColor : p.successColor,
                    p,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSpecTile(
                    context.tr('listing_mileage'),
                    '${NumberFormat('#,###', 'tr_TR').format(car.expertise.mileage)} km',
                    car.expertise.isMileageTampered ? p.errorColor : p.textPrimaryColor,
                    p,
                    subtitle: car.expertise.isMileageTampered ? context.tr('expertise_tampered_km') : context.tr('expertise_original_km'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kaporta Damage Schema
            Text(context.tr('expertise_schema_title'), style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 8),
            CarDamageSchemaWidget(bodyParts: car.expertise.bodyParts),
            const SizedBox(height: 20),

            // Action Buttons
            if (listing != null) ...[
              NeoBrutalButton(
                label: context.tr('expertise_negotiate_buy'),
                icon: Icons.handshake_rounded,
                backgroundColor: p.primaryColor,
                textColor: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 14),
                onPressed: () {
                  final targetListing = listing!;
                  Navigator.pop(context);
                  context.push('/negotiation', extra: targetListing);
                },
              ),
              const SizedBox(height: 10),
            ],
            NeoBrutalButton(
              label: context.tr('btn_close'),
              backgroundColor: p.isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              textColor: p.textPrimaryColor,
              borderColor: p.surfaceBorderColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fullWidth: true,
              padding: const EdgeInsets.symmetric(vertical: 13),
              onPressed: () => Navigator.pop(context),
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
