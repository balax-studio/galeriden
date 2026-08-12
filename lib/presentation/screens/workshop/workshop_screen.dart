import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

class WorkshopScreen extends ConsumerStatefulWidget {
  const WorkshopScreen({super.key});

  @override
  ConsumerState<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends ConsumerState<WorkshopScreen> {
  CarModel? _selectedCar;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    if (game.ownedCars.isNotEmpty && _selectedCar == null) {
      _selectedCar = game.ownedCars.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TAMİR VE RESTORASYON ATÖLYESİ'),
      ),
      body: game.ownedCars.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Garajında henüz araç yok. İkinci el pazarından araç satın alarak tamir ve restorasyon yapabilirsin.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium(p.isDark),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('İŞLEM YAPILACAK ARACI SEÇ', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: game.ownedCars.length,
                      itemBuilder: (context, index) {
                        final car = game.ownedCars[index];
                        final isSelected = _selectedCar?.id == car.id;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedCar = car),
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? p.primaryColor.withValues(alpha: 0.2) : p.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? p.primaryColor : p.surfaceBorderColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 13), overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(CurrencyFormatter.formatShort(car.currentPurchasePrice), style: AppTypography.moneyMedium(p.isDark).copyWith(fontSize: 12)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (_selectedCar != null) ...[
                    // Repair Options Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: p.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.surfaceBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${_selectedCar!.brand} ${_selectedCar!.modelName}', style: AppTypography.titleLarge(p.isDark)),
                              Text('Tahmini Değer: ${CurrencyFormatter.formatShort(_selectedCar!.estimatedRealValue)}', style: AppTypography.moneyMedium(p.isDark)),
                            ],
                          ),
                          const Divider(height: 24),

                          // Engine Repair Button
                          _buildRepairOption(
                            title: 'Motor & Şanzıman Rektifiye',
                            subtitle: 'Mevcut Kondisyon: %${_selectedCar!.expertise.engineCondition.toInt()}',
                            cost: 8500.0,
                            vectorType: 'workshop',
                            p: p,
                            onPressed: _selectedCar!.expertise.engineCondition >= 100
                                ? null
                                : () {
                                    final restored = RepairEngine.repairEngine(_selectedCar!);
                                    ref.read(gameProvider.notifier).updateOwnedCar(restored, 8500.0);
                                    setState(() => _selectedCar = restored);
                                  },
                          ),
                          const SizedBox(height: 12),

                          // Detailing Clean Button
                          _buildRepairOption(
                            title: 'Pasta-Cila & Detaylı Temizlik',
                            subtitle: _selectedCar!.isDetailedCleaned ? 'Detaylı Temizlik Yapıldı (+%8 Değer)' : 'Değere +%8 Katkı Sağlar',
                            cost: RepairEngine.detailedCleanCost,
                            vectorType: 'workshop',
                            p: p,
                            onPressed: _selectedCar!.isDetailedCleaned
                                ? null
                                : () {
                                    final cleaned = RepairEngine.performDetailing(_selectedCar!);
                                    ref.read(gameProvider.notifier).updateOwnedCar(cleaned, RepairEngine.detailedCleanCost);
                                    setState(() => _selectedCar = cleaned);
                                  },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text('KAPORTA RESTORASYONU', style: AppTypography.labelSmall(p.isDark)),
                    const SizedBox(height: 8),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedCar!.expertise.bodyParts.length,
                      itemBuilder: (context, index) {
                        final partName = _selectedCar!.expertise.bodyParts.keys.elementAt(index);
                        final status = _selectedCar!.expertise.bodyParts.values.elementAt(index);

                        if (status == PartStatus.original) return const SizedBox.shrink();

                        double repairCost = status == PartStatus.painted ? RepairEngine.paintRepairCost : RepairEngine.bodyChangeCost;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('$partName Restorasyonu', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                            subtitle: Text(status == PartStatus.painted ? 'Lokal Boya Yapılacak' : 'Orijinal Parça ile Değişecek'),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: p.secondaryColor,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                final repairedCar = RepairEngine.repairBodyPart(_selectedCar!, partName);
                                ref.read(gameProvider.notifier).updateOwnedCar(repairedCar, repairCost);
                                setState(() => _selectedCar = repairedCar);
                              },
                              child: Text('₺${repairCost.toInt()} Onar'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildRepairOption({
    required String title,
    required String subtitle,
    required double cost,
    required String vectorType,
    required ThemePaletteModel p,
    required VoidCallback? onPressed,
  }) {
    return Row(
      children: [
        CircleAvatar(backgroundColor: p.primaryColor.withValues(alpha: 0.15), child: VectorIconWidget(type: vectorType, color: p.primaryColor, size: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
              Text(subtitle, style: AppTypography.labelSmall(p.isDark)),
            ],
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: p.primaryColor,
            foregroundColor: Colors.black,
          ),
          onPressed: onPressed,
          child: Text(onPressed == null ? 'Tamamlandı' : CurrencyFormatter.formatShort(cost)),
        ),
      ],
    );
  }
}
