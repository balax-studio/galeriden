import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/expertise_engine.dart';
import '../../providers/market_provider.dart';

class ExpertiseScreen extends ConsumerWidget {
  final ListingModel listing;

  const ExpertiseScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final car = listing.car;
    final exp = car.expertise;
    final eval = ExpertiseEngine.evaluateVehicle(car);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('EKSPERTİZ RAPORU — ${car.brand} ${car.modelName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Overall Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryAmber.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GENEL DERECELENDİRME', style: AppTypography.labelSmall(isDark)),
                      Text(eval['overallGrade'] as String, style: AppTypography.titleLarge(isDark).copyWith(color: AppColors.primaryAmber, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Motor Kondisyonu', '%${exp.engineCondition.toInt()}', isDark),
                      _buildMetric('Şanzıman', '%${exp.transmissionCondition.toInt()}', isDark),
                      _buildMetric('Tramer Kaydı', exp.tramerAmount > 0 ? '₺${exp.tramerAmount}' : 'Yok', isDark),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetric('Kilometre', '${exp.mileage} km', isDark),
                      _buildMetric('KM Orijinalliği', exp.isMileageTampered ? 'DÜŞÜRÜLMÜŞ (!)' : 'Orijinal', isDark),
                      _buildMetric('Tahmini Piyasa Değeri', CurrencyFormatter.formatShort(eval['fairMarketValue'] as double), isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('KAPORTA & BOYA ŞEMASI', style: AppTypography.labelSmall(isDark)),
            const SizedBox(height: 12),

            // Body Parts Status List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: exp.bodyParts.length,
              itemBuilder: (context, index) {
                final partName = exp.bodyParts.keys.elementAt(index);
                final status = exp.bodyParts.values.elementAt(index);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(partName, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 14)),
                    trailing: _buildStatusBadge(status),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAmber,
                  foregroundColor: AppColors.backgroundDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  ref.read(marketProvider.notifier).markExpertiseCompleted(listing.id);
                  Navigator.of(context).pop();
                },
                child: const Text('Raporu Onayla & Pazara Dön', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(String label, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.labelSmall(isDark)),
        const SizedBox(height: 2),
        Text(value, style: AppTypography.monoSpec(isDark).copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(PartStatus status) {
    Color color;
    String text;

    switch (status) {
      case PartStatus.original:
        color = AppColors.partOriginal;
        text = 'ORİJİNAL';
        break;
      case PartStatus.painted:
        color = AppColors.partPainted;
        text = 'BOYALI';
        break;
      case PartStatus.changed:
        color = AppColors.partChanged;
        text = 'DEĞİŞEN';
        break;
      case PartStatus.damaged:
        color = AppColors.partDamaged;
        text = 'HASARLI';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
