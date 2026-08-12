import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/stat_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/expertise_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';

class ExpertiseScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const ExpertiseScreen({super.key, required this.listing});

  @override
  ConsumerState<ExpertiseScreen> createState() => _ExpertiseScreenState();
}

class _ExpertiseScreenState extends ConsumerState<ExpertiseScreen> {
  bool _isInspected = false;

  @override
  void initState() {
    super.initState();
    _isInspected = widget.listing.isExpertiseCompleted;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final car = widget.listing.car;
    final exp = car.expertise;
    final eval = ExpertiseEngine.evaluateVehicle(car);
    final game = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DETAYLI EKSPERTİZ RAPORU'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Title Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryAmber.withValues(alpha: 0.2),
                    child: const Icon(Icons.directions_car_rounded, color: AppColors.primaryAmber, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 18)),
                        Text('${car.modelYear} • ${car.bodyType} • ${widget.listing.sellerCity}', style: AppTypography.labelSmall(isDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            if (!_isInspected) ...[
              // Locked State Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock_clock_rounded, size: 48, color: AppColors.warningOrange),
                    const SizedBox(height: 12),
                    Text('Ekspertiz Raporu Kilitli', style: AppTypography.titleLarge(isDark)),
                    const SizedBox(height: 6),
                    Text(
                      'Bu aracın kaporta, motor, tramer ve kilometre orijinalliğini görmek için ₺1.500 ödeyerek detaylı ekspertiz yaptırmalısın.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(isDark),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAmber,
                        foregroundColor: AppColors.backgroundDark,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: game.balance < 1500
                          ? null
                          : () {
                              ref.read(marketProvider.notifier).markExpertiseCompleted(widget.listing.id);
                              setState(() {
                                _isInspected = true;
                              });
                            },
                      child: const Text('Ekspertiz Yaptır (₺1.500)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Full Inspection Report Unlocked
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('GENEL DERECELENDİRME', style: AppTypography.labelSmall(isDark)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      eval['overallGrade'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Color-Coded Engine & Transmission Bars
              _buildProgressStat('Motor Sağlığı', exp.engineCondition, StatColors.getEngineColor(exp.engineCondition), isDark),
              const SizedBox(height: 10),
              _buildProgressStat('Şanzıman Sağlığı', exp.transmissionCondition, StatColors.getEngineColor(exp.transmissionCondition), isDark),
              const SizedBox(height: 20),

              // Mileage & Tramer Info Cards
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Kilometre',
                      '${CurrencyFormatter.formatShort(exp.mileage.toDouble())} KM',
                      exp.isMileageTampered ? 'Şüpheli KM' : 'Orijinal',
                      StatColors.getMileageColor(exp.mileage),
                      isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Tramer Kaydı',
                      CurrencyFormatter.format(exp.tramerAmount.toDouble()),
                      StatColors.getTramerLabel(exp.tramerAmount),
                      StatColors.getTramerColor(exp.tramerAmount),
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Body Part Inspection Grid Map
              Text('KAPORTA VE BOYA ŞEMASI', style: AppTypography.labelSmall(isDark)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.surfaceBorderDark : AppColors.surfaceBorderLight),
                ),
                child: Column(
                  children: exp.bodyParts.entries.map((entry) {
                    final color = StatColors.getPartColor(entry.value.name);
                    final label = StatColors.getPartLabel(entry.value.name);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: AppTypography.bodyMedium(isDark).copyWith(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: color.withValues(alpha: 0.6)),
                            ),
                            child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Fair Market Value vs Asking Price Summary Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryAmber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GERÇEK PİYASA DEĞERİ', style: AppTypography.labelSmall(isDark)),
                        Text(CurrencyFormatter.format(eval['fairMarketValue'] as double), style: AppTypography.moneyMedium(isDark)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('İLAN FİYATI', style: AppTypography.labelSmall(isDark)),
                        Text(CurrencyFormatter.format(widget.listing.askingPrice), style: AppTypography.moneyMedium(isDark)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String title, double value, Color color, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.bodyMedium(isDark)),
            Text('%${value.round()}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value / 100.0,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, String sub, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSmall(isDark)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 16)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
