import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/detailing_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/part_order_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/tutorial_provider.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/tutorial_overlay.dart';

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
    } else if (game.ownedCars.isNotEmpty && _selectedCar != null) {
      // Refresh reference
      _selectedCar = game.ownedCars.firstWhere((c) => c.id == _selectedCar!.id, orElse: () => game.ownedCars.first);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('TAMİR VE RESTORASYON ATÖLYESİ'),
      ),
      body: Stack(
        children: [
          game.ownedCars.isEmpty
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
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pending Part Orders & Master Repairs Tracker Section
                      if (game.pendingOrders.isNotEmpty) ...[
                        Text('PARÇA SİPARİŞİ VE KARGO TAKİBİ', style: AppTypography.labelSmall(p.isDark)),
                        const SizedBox(height: 8),
                        AppGlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderColor: p.primaryColor.withValues(alpha: 0.4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: game.pendingOrders.map((order) {
                              final isReady = order.isDelivered;
                              final remainingSec = order.remainingSeconds;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: p.surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: p.surfaceBorderColor),
                                ),
                                child: Row(
                                  children: [
                                    VectorIconWidget(
                                      type: order.orderType == OrderType.masterRepair ? 'craftsman' : 'workshop',
                                      size: 24,
                                      color: isReady ? p.successColor : p.primaryColor,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${order.partName} (${order.orderType == OrderType.quickPatch ? 'Geçici' : order.orderType == OrderType.masterRepair ? 'Usta Tamiri' : 'Yeni Parça'})',
                                            style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: order.progressPercentage,
                                              backgroundColor: p.surfaceBorderColor,
                                              valueColor: AlwaysStoppedAnimation<Color>(isReady ? p.successColor : p.primaryColor),
                                              minHeight: 6,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            isReady ? 'Teslimat Tamamlandı!' : 'Kargoda ($remainingSec sn kaldı)',
                                            style: AppTypography.labelSmall(p.isDark).copyWith(
                                              color: isReady ? p.successColor : p.warningColor,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isReady ? p.successColor : p.surfaceBorderColor,
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: isReady
                                          ? () {
                                              final success = ref.read(gameProvider.notifier).installDeliveredPart(order.id);
                                              if (success) {
                                                ref.read(tutorialProvider.notifier).nextStep();
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('${order.partName} başarıyla monte edildi ve kondisyon yenilendi!')),
                                                );
                                              }
                                            }
                                          : null,
                                      child: Text(isReady ? 'Montaj Et' : 'Bekleniyor'),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
                            costLabel: 'Usta Seç',
                            vectorType: 'workshop',
                            p: p,
                            onPressed: _selectedCar!.expertise.engineCondition >= 100
                                ? null
                                : () => _showCraftsmanSelectionSheet(context, isEngine: true),
                          ),
                          const SizedBox(height: 12),

                          // Detailing Clean Button
                          _buildRepairOption(
                            title: 'Pasta-Cila & Detaylı Temizlik',
                            subtitle: _selectedCar!.isDetailedCleaned ? 'Detaylı Temizlik Yapıldı (+%8 Değer)' : 'Değere +%8 Katkı Sağlar',
                            costLabel: CurrencyFormatter.formatShort(RepairEngine.detailedCleanCost),
                            vectorType: 'workshop',
                            p: p,
                            onPressed: _selectedCar!.isDetailedCleaned
                                ? null
                                : () {
                                    final success = ref.read(gameProvider.notifier).detailCleanCar(_selectedCar!.id);
                                    if (success) {
                                      final updated = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id);
                                      setState(() => _selectedCar = updated);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Pasta-Cila & Detaylı Temizlik Tamamlandı! Araç Parıl Parıl Parlıyor (+%8 Değer Boost).')),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Yetersiz bakiye! Pasta-Cila için ₺2.500 gereklidir.')),
                                      );
                                    }
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
                              onPressed: () => _showCraftsmanSelectionSheet(context, isEngine: false, partName: partName),
                              child: const Text('Usta Seç & Onar'),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Detailing & Tuning Section
                    Text('MODİFİYE & DETAILING ATÖLYESİ', style: AppTypography.labelSmall(p.isDark)),
                    const SizedBox(height: 12),
                    Column(
                      children: DetailingOption.getAvailableOptions().map((opt) {
                        final canAfford = game.balance >= opt.cost;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: p.surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: opt.isRisky ? p.secondaryColor : p.surfaceBorderColor),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: opt.isRisky ? p.secondaryColor.withValues(alpha: 0.15) : p.primaryColor.withValues(alpha: 0.15),
                                child: VectorIconWidget(type: opt.vectorIcon, color: opt.isRisky ? p.secondaryColor : p.primaryColor, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(opt.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                                    const SizedBox(height: 2),
                                    Text(opt.description, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: opt.isRisky ? p.secondaryColor : p.primaryColor,
                                  foregroundColor: opt.isRisky ? Colors.white : Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                onPressed: canAfford
                                    ? () {
                                        final success = ref.read(gameProvider.notifier).detailCleanCar(_selectedCar!.id);
                                        if (success) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${opt.badgeText} Yapıldı! Aracın İlan Çekiciliği Artırıldı.')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Yetersiz Sermaye!')),
                                          );
                                        }
                                      }
                                    : null,
                                child: Text('₺${CurrencyFormatter.formatShort(opt.cost)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          const TutorialOverlayBanner(),
        ],
      ),
    );
  }

  void _showCraftsmanSelectionSheet(BuildContext context, {required bool isEngine, String? partName}) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final targetPart = isEngine ? 'Motor & Şanzıman' : (partName ?? 'Kaput');

    showModalBottomSheet(
      context: context,
      backgroundColor: p.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RESTORASYON VE PARÇA SEÇİMİ', style: AppTypography.titleLarge(p.isDark)),
              const SizedBox(height: 4),
              Text('$targetPart için bütçene ve zamanına uygun yöntemi seç:', style: AppTypography.labelSmall(p.isDark)),
              const SizedBox(height: 16),

              // Option 1: Quick Patch (Geçici Tamir) - Instant, cheaper, caps at 60% condition
              _buildRepairDecisionTile(
                context,
                title: 'Geçici Lokal Tamir',
                subtitle: 'Maliyet: ₺1.500 | Süre: Anında | Kondisyon: %60 Maksimum',
                vectorType: 'workshop',
                color: p.warningColor,
                p: p,
                onTap: () {
                  Navigator.pop(context);
                  if (_selectedCar == null) return;
                  final success = ref.read(gameProvider.notifier).orderPart(
                    carId: _selectedCar!.id,
                    partName: targetPart,
                    orderType: OrderType.quickPatch,
                    cost: 1500.0,
                    deliveryDurationSeconds: 1, // Instant 1 second
                  );
                  if (success) {
                    ref.read(tutorialProvider.notifier).nextStep();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Geçici tamir siparişi verildi! Montaj sekmesinden araca uygula.')),
                    );
                  }
                },
              ),

              // Option 2: Master Craftsman (Ustaya Gönder) - 120s wait, 90% condition
              _buildRepairDecisionTile(
                context,
                title: 'Ustaya Gönder (Rektefiye & Sanayi)',
                subtitle: 'Maliyet: ₺4.500 | Süre: 2 dk (Real-Time) | Kondisyon: %90',
                vectorType: 'craftsman',
                color: p.primaryColor,
                p: p,
                onTap: () {
                  Navigator.pop(context);
                  if (_selectedCar == null) return;
                  final success = ref.read(gameProvider.notifier).orderPart(
                    carId: _selectedCar!.id,
                    partName: targetPart,
                    orderType: OrderType.masterRepair,
                    cost: 4500.0,
                    deliveryDurationSeconds: 120,
                  );
                  if (success) {
                    ref.read(tutorialProvider.notifier).nextStep();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sanayi usta tamir siparişi verildi! Kargoda bekleniyor.')),
                    );
                  }
                },
              ),

              // Option 3: New OEM Part (Sıfır Orijinal Parça) - 60s wait, 100% condition
              _buildRepairDecisionTile(
                context,
                title: 'Sıfır OEM Parça Siparişi',
                subtitle: 'Maliyet: ₺9.000 | Süre: 1 dk (Kargo) | Kondisyon: %100 Orijinal',
                vectorType: 'car',
                color: p.successColor,
                p: p,
                onTap: () {
                  Navigator.pop(context);
                  if (_selectedCar == null) return;
                  final success = ref.read(gameProvider.notifier).orderPart(
                    carId: _selectedCar!.id,
                    partName: targetPart,
                    orderType: OrderType.newOemPart,
                    cost: 9000.0,
                    deliveryDurationSeconds: 60,
                  );
                  if (success) {
                    ref.read(tutorialProvider.notifier).nextStep();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sıfır OEM parça siparişi verildi! Kargo takibini kontrol et.')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepairDecisionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String vectorType,
    required Color color,
    required ThemePaletteModel p,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.surfaceBorderColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: VectorIconWidget(type: vectorType, color: color, size: 20),
        ),
        title: Text(title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
        subtitle: Text(subtitle, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 11)),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRepairOption({
    required String title,
    required String subtitle,
    required String costLabel,
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
          child: Text(onPressed == null ? 'Tamamlandı' : costLabel),
        ),
      ],
    );
  }
}
