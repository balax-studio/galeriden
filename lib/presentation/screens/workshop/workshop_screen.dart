
import 'package:galeriden/core/utils/notification_service.dart';
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
import 'widgets/animated_order_card.dart';
import 'widgets/disappearing_detailing_tile.dart';
import 'widgets/disappearing_repair_tile.dart';
import 'widgets/isometric_hydraulic_lift.dart';

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
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('TAMİR VE RESTORASYON ATÖLYESİ'),
        ),
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
                              return AnimatedOrderCard(
                                key: ValueKey(order.id),
                                order: order,
                                p: p,
                                onInstall: () {
                                  final success = ref.read(gameProvider.notifier).installDeliveredPart(order.id);
                                  if (success) {
                                    ref.read(tutorialProvider.notifier).nextStep();
                                    final updatedCars = ref.read(gameProvider).ownedCars;
                                    if (updatedCars.isNotEmpty && _selectedCar != null) {
                                      final updated = updatedCars.firstWhere(
                                        (c) => c.id == _selectedCar!.id,
                                        orElse: () => updatedCars.first,
                                      );
                                      setState(() => _selectedCar = updated);
                                    }
                                    NotificationService.showSuccess(context, '${order.partName} başarıyla monte edildi ve kondisyon yenilendi!');
                                  }
                                },
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
                          IsometricHydraulicLiftWidget(car: _selectedCar!, p: p),
                          const Divider(height: 16),

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
                                      NotificationService.showSuccess(context, 'Pasta-Cila & Detaylı Temizlik Tamamlandı! Araç Parıl Parıl Parlıyor (+%8 Değer Boost).');
                                    } else {
                                      NotificationService.showError(context, 'Yetersiz bakiye! Pasta-Cila için ₺2.500 gereklidir.');
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text('KAPORTA RESTORASYONU', style: AppTypography.labelSmall(p.isDark)),
                    const SizedBox(height: 8),

                    Builder(
                      builder: (context) {
                        final damagedParts = _selectedCar!.expertise.bodyParts.entries
                            .where((e) {
                              if (e.value == PartStatus.original) return false;
                              final hasPendingOrder = game.pendingOrders.any((o) => o.carId == _selectedCar!.id && o.partName == e.key);
                              return !hasPendingOrder;
                            })
                            .toList();

                        if (damagedParts.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Araçta onarım gerektiren hasarlı kaporta parçası bulunmuyor.',
                                    style: AppTypography.labelSmall(p.isDark).copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: damagedParts.map((entry) {
                            final partName = entry.key;
                            final status = entry.value;

                            return DisappearingRepairTile(
                              key: ValueKey('${_selectedCar!.id}_$partName'),
                              partName: partName,
                              status: status,
                              p: p,
                              onOpenOptions: (onSuccess) => _showCraftsmanSelectionSheet(
                                context,
                                isEngine: false,
                                partName: partName,
                                currentStatus: status,
                                onSuccess: onSuccess,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Detailing & Tuning Section
                    Text('MODİFİYE & DETAILING ATÖLYESİ', style: AppTypography.labelSmall(p.isDark)),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final unappliedOptions = DetailingOption.getAvailableOptions()
                            .where((opt) => !(_selectedCar?.appliedDetailingOptionIds.contains(opt.id) ?? false))
                            .toList();

                        if (unappliedOptions.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.stars_rounded, color: Colors.greenAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Tüm modifiye ve detaylı temizlik paketleri uygulandı! Araç parıl parıl parlıyor.',
                                    style: AppTypography.labelSmall(p.isDark).copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: unappliedOptions.map((opt) {
                            final canAfford = game.balance >= opt.cost;
                            return DisappearingDetailingTile(
                              key: ValueKey('${_selectedCar!.id}_${opt.id}'),
                              opt: opt,
                              p: p,
                              canAfford: canAfford,
                              onApply: () {
                                final success = ref.read(gameProvider.notifier).applyDetailingOption(_selectedCar!.id, opt);
                                if (success) {
                                  final updatedCars = ref.read(gameProvider).ownedCars;
                                  if (updatedCars.isNotEmpty) {
                                    final updated = updatedCars.firstWhere(
                                      (c) => c.id == _selectedCar!.id,
                                      orElse: () => updatedCars.first,
                                    );
                                    setState(() => _selectedCar = updated);
                                  }
                                  NotificationService.showSuccess(context, '${opt.badgeText} Yapıldı! Aracın İlan Çekiciliği Artırıldı.');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz Sermaye!');
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
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

  void _showCraftsmanSelectionSheet(
    BuildContext context, {
    required bool isEngine,
    String? partName,
    PartStatus? currentStatus,
    VoidCallback? onSuccess,
  }) {
    if (_selectedCar == null) return;
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final targetPart = isEngine ? 'Motor & Şanzıman' : (partName ?? 'Kaput');
    final canQuickPatch = !isEngine && currentStatus == PartStatus.damaged;

    final quickPatchCost = RepairEngine.calculatePartRepairCost(_selectedCar!, targetPart, OrderType.quickPatch);
    final masterRepairCost = RepairEngine.calculatePartRepairCost(_selectedCar!, targetPart, OrderType.masterRepair);
    final newOemCost = RepairEngine.calculatePartRepairCost(_selectedCar!, targetPart, OrderType.newOemPart);

    final quickPatchFormatted = CurrencyFormatter.formatShort(quickPatchCost);
    final masterRepairFormatted = CurrencyFormatter.formatShort(masterRepairCost);
    final newOemFormatted = CurrencyFormatter.formatShort(newOemCost);

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
              if (isEngine || canQuickPatch)
                _buildRepairDecisionTile(
                  context,
                  title: 'Geçici Lokal Tamir',
                  subtitle: 'Maliyet: ₺$quickPatchFormatted | Süre: Anında | Kondisyon: %60 Maksimum',
                  vectorType: 'workshop',
                  color: p.warningColor,
                  p: p,
                  onTap: () {
                    Navigator.pop(context);
                    if (_selectedCar == null) return;
                    final success = ref.read(gameProvider.notifier).instantRepair(
                      carId: _selectedCar!.id,
                      partName: targetPart,
                      orderType: OrderType.quickPatch,
                      cost: quickPatchCost,
                    );
                    if (success) {
                      ref.read(tutorialProvider.notifier).nextStep();
                      final updatedCars = ref.read(gameProvider).ownedCars;
                      if (updatedCars.isNotEmpty) {
                        final updated = updatedCars.firstWhere(
                          (c) => c.id == _selectedCar!.id,
                          orElse: () => updatedCars.first,
                        );
                        setState(() => _selectedCar = updated);
                      }
                      NotificationService.showSuccess(context, 'Geçici tamir anında uygulandı!');
                      onSuccess?.call();
                    } else {
                      NotificationService.showError(context, 'Yetersiz bakiye!');
                    }
                  },
                ),

              // Option 2: Master Craftsman (Ustaya Gönder) - 120s wait, 90% condition
              _buildRepairDecisionTile(
                context,
                title: 'Ustaya Gönder (Rektefiye & Sanayi)',
                subtitle: 'Maliyet: ₺$masterRepairFormatted | Süre: 2 dk (Real-Time) | Kondisyon: %90',
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
                    cost: masterRepairCost,
                    deliveryDurationSeconds: 120,
                  );
                  if (success) {
                    ref.read(tutorialProvider.notifier).nextStep();
                    NotificationService.showSuccess(context, 'Sanayi usta tamir siparişi verildi! Kargoda bekleniyor.');
                    onSuccess?.call();
                  }
                },
              ),

              // Option 3: New OEM Part (Sıfır Orijinal Parça) - 60s wait, 100% condition
              _buildRepairDecisionTile(
                context,
                title: 'Sıfır OEM Parça Siparişi',
                subtitle: 'Maliyet: ₺$newOemFormatted | Süre: 1 dk (Kargo) | Kondisyon: %100 Orijinal',
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
                    cost: newOemCost,
                    deliveryDurationSeconds: 60,
                  );
                  if (success) {
                    ref.read(tutorialProvider.notifier).nextStep();
                    NotificationService.showSuccess(context, 'Sıfır OEM parça siparişi verildi! Kargo takibini kontrol et.');
                    onSuccess?.call();
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
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          onPressed: onPressed,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(onPressed == null ? 'Tamamlandı' : costLabel),
          ),
        ),
      ],
    );
  }
}
