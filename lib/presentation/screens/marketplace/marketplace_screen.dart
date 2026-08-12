import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/car_icons.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(marketProvider);
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İKİNCİ EL PAZARI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Pazarı Yenile',
            onPressed: () {
              ref.read(marketProvider.notifier).refreshMarket();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.storefront_rounded, size: 18, color: AppColors.primaryAmber),
                    const SizedBox(width: 6),
                    Text('Satılık Araçlar (${listings.length})', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                  ],
                ),
                Text('Sermaye: ${CurrencyFormatter.formatShort(game.balance)}', style: AppTypography.moneyMedium(isDark)),
              ],
            ),
          ),
          Expanded(
            child: listings.isEmpty
                ? Center(
                    child: Text('Şu an pazarda araç kalmadı. Yenile butonuna bas.', style: AppTypography.bodyMedium(isDark)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      final car = item.car;
                      final exp = car.expertise;
                      final isFlash = item.sellerTrait.contains('Fırsat');
                      final viewerCount = PsychologyEngine.getLiveViewerCount();

                      // Convert hex string to Color
                      Color carColor;
                      try {
                        carColor = Color(int.parse(car.colorHex.replaceFirst('#', '0xFF')));
                      } catch (e) {
                        carColor = AppColors.primaryAmber;
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isFlash ? AppColors.warningOrange : (isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight),
                            width: isFlash ? 2.0 : 1.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Tag & Live Viewer FOMO
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondarySage.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(car.bodyType, style: AppTypography.labelSmall(isDark).copyWith(color: AppColors.secondarySage)),
                                      ),
                                      if (isFlash) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.warningOrange,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text('⚡ FIRSAT %30 İNDİRİM', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppColors.textSecondaryDark),
                                      const SizedBox(width: 4),
                                      Text('$viewerCount kişi bakıyor', style: AppTypography.labelSmall(isDark).copyWith(fontSize: 11)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Car Header: Silhouette Icon + Name
                              Row(
                                children: [
                                  CarSilhouetteWidget(
                                    bodyType: car.bodyType,
                                    color: carColor,
                                    width: 54,
                                    height: 28,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 17)),
                                        Text('${item.sellerCity} • ${car.modelYear} Model', style: AppTypography.labelSmall(isDark)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Color-Coded Stat Badges (KM, Engine, Tramer)
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _buildColorBadge(
                                    label: '${(exp.mileage / 1000).toStringAsFixed(0)}K KM',
                                    color: StatColors.getMileageColor(exp.mileage),
                                    tooltip: StatColors.getMileageLabel(exp.mileage),
                                  ),
                                  _buildColorBadge(
                                    label: exp.tramerAmount == 0 ? 'Tramer: 0 ₺' : 'Tramer: ₺${CurrencyFormatter.formatShort(exp.tramerAmount.toDouble())}',
                                    color: StatColors.getTramerColor(exp.tramerAmount),
                                    tooltip: StatColors.getTramerLabel(exp.tramerAmount),
                                  ),
                                  _buildColorBadge(
                                    label: 'Motor: %${exp.engineCondition.round()}',
                                    color: StatColors.getEngineColor(exp.engineCondition),
                                    tooltip: StatColors.getEngineLabel(exp.engineCondition),
                                  ),
                                  if (exp.isMileageTampered && item.isExpertiseCompleted)
                                    _buildColorBadge(
                                      label: '⚠️ ŞÜPHELİ KM!',
                                      color: AppColors.errorRed,
                                      tooltip: 'KM Düşürülmüş Olabilir!',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Price & Action Buttons
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('İlan Fiyatı', style: AppTypography.labelSmall(isDark)),
                                      Text(CurrencyFormatter.format(item.askingPrice), style: AppTypography.moneyMedium(isDark)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.primaryAmber),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          context.push('/expertise', extra: item);
                                        },
                                        child: Text(
                                          item.isExpertiseCompleted ? 'Rapor' : 'Ekspertiz (₺1.500)',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryAmber,
                                          foregroundColor: AppColors.backgroundDark,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: game.balance < item.askingPrice
                                            ? null
                                            : () {
                                                final success = ref.read(gameProvider.notifier).buyCar(car, item.askingPrice);
                                                if (success) {
                                                  ref.read(marketProvider.notifier).removeListing(item.id);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('${car.brand} ${car.modelName} satın alındı ve garajına eklendi!')),
                                                  );
                                                }
                                              },
                                        child: const Text('Satın Al', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorBadge({required String label, required Color color, required String tooltip}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
