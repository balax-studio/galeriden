import 'package:intl/intl.dart';
import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/car_damage_schema_widget.dart';
import '../../widgets/car_icons.dart';
import '../../widgets/neo_brutal_button.dart';
import 'expertise_report_sheet.dart';
import 'interactive_negotiation_sheet.dart';

class ListingDetailScreen extends ConsumerWidget {
  final ListingModel listing;

  const ListingDetailScreen({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final car = listing.car;
    final exp = car.expertise;
    final viewerCount = PsychologyEngine.getLiveViewerCount();

    Color carColor;
    try {
      carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      carColor = p.primaryColor;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              NotificationService.showSuccess(context, 'İlan bağlantısı kopyalandı!');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Visual Banner Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: p.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: p.surfaceBorderColor),
              ),
              child: Column(
                children: [
                  CarSilhouetteWidget(
                    bodyType: car.bodyType,
                    color: carColor,
                    width: 140,
                    height: 70,
                  ),
                  const SizedBox(height: 16),
                  Text(listing.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 20), textAlign: TextAlign.center),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(listing.askingPrice),
                    style: AppTypography.moneyLarge(p.isDark).copyWith(fontSize: 30, color: p.primaryColor),
                  ),
                  const SizedBox(height: 10),

                  // FOMO Viewer Counter
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.remove_red_eye_rounded, size: 16, color: p.textSecondaryColor),
                      const SizedBox(width: 6),
                      Text(
                        'Şu an $viewerCount kişi bu ilanı inceliyor',
                        style: AppTypography.labelSmall(p.isDark).copyWith(color: p.textSecondaryColor, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sahibinden İlan Bilgi Tablosu
            Text('İLAN BİLGİLERİ', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: p.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: p.surfaceBorderColor),
              ),
              child: Column(
                children: [
                  _buildSpecRow('İlan No', '#${listing.id.hashCode.abs().toString().padLeft(10, '0')}', p),
                  _buildSpecRow('İlan Tarihi', 'Bugün (Canlı Akış)', p),
                  _buildSpecRow('Konum / Şehir', listing.sellerCity, p),
                  _buildSpecRow('Marka / Model', '${car.brand} ${car.modelName}', p),
                  _buildSpecRow('Model Yılı', '${car.modelYear}', p),
                  _buildSpecRow('Kilometre', '${NumberFormat('#,###', 'tr_TR').format(exp.mileage)} KM', p, valueColor: StatColors.getMileageColor(exp.mileage)),
                  _buildSpecRow('Motor Kondisyonu', '%${exp.engineCondition.round()}', p, valueColor: StatColors.getEngineColor(exp.engineCondition)),
                  _buildSpecRow('Tramer Kaydı', exp.tramerAmount == 0 ? 'Hasar Kayıtsız' : CurrencyFormatter.formatShort(exp.tramerAmount.toDouble()), p, valueColor: StatColors.getTramerColor(exp.tramerAmount)),
                  _buildSpecRow('Satıcı Profil', listing.sellerName, p),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sahibinden Görsel Kaporta Hasar Şeması & Ekspertiz Raporu Butonu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('KAPORTA & EKSPERTİZ RAPORU', style: AppTypography.labelSmall(p.isDark)),
                TextButton.icon(
                  icon: VectorIconWidget(type: 'expertise', color: p.primaryColor, size: 16),
                  label: Text('Detaylı Rapor', style: TextStyle(color: p.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => ExpertiseReportSheet(car: car, listing: listing),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            CarDamageSchemaWidget(bodyParts: exp.bodyParts),
            const SizedBox(height: 24),

            // Seller Description
            Text('SATICI AÇIKLAMASI', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: p.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: p.surfaceBorderColor),
              ),
              child: Text(
                '"${listing.description}"',
                style: AppTypography.bodyMedium(p.isDark).copyWith(fontStyle: FontStyle.italic, height: 1.4),
              ),
            ),
            const SizedBox(height: 100), // Spacing for Sticky Bottom Bar
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surfaceColor,
          border: Border(top: BorderSide(color: p.surfaceBorderColor, width: 2)),
        ),
        child: SafeArea(
          child: NeoBrutalButton(
            label: 'PAZARLIK ET & SATIN AL',
            icon: Icons.handshake_rounded,
            backgroundColor: p.primaryColor,
            textColor: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fullWidth: true,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => InteractiveNegotiationSheet(listing: listing),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value, ThemePaletteModel p, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.surfaceBorderColor.withValues(alpha: 0.5), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: p.textSecondaryColor, fontSize: 13)),
          Text(
            value,
            style: TextStyle(color: valueColor ?? p.textPrimaryColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
