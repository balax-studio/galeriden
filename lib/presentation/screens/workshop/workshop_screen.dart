import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
                              return _AnimatedOrderCard(
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
                          _IsometricHydraulicLiftWidget(car: _selectedCar!, p: p),
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
                            .where((e) => e.value != PartStatus.original)
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
                                    'Tüm kaporta parçaları orijinal kondisyonda! Onarılacak parça kalmadı.',
                                    style: AppTypography.labelSmall(p.isDark).copyWith(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: damagedParts.length,
                          itemBuilder: (context, index) {
                            final partName = damagedParts[index].key;
                            final status = damagedParts[index].value;

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
                            return _DisappearingDetailingTile(
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
                    NotificationService.showSuccess(context, 'Geçici tamir siparişi verildi! Montaj sekmesinden araca uygula.');
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
                    NotificationService.showSuccess(context, 'Sanayi usta tamir siparişi verildi! Kargoda bekleniyor.');
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
                    NotificationService.showSuccess(context, 'Sıfır OEM parça siparişi verildi! Kargo takibini kontrol et.');
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

class _AnimatedOrderCard extends StatefulWidget {
  final PartOrderModel order;
  final ThemePaletteModel p;
  final VoidCallback onInstall;

  const _AnimatedOrderCard({
    super.key,
    required this.order,
    required this.p,
    required this.onInstall,
  });

  @override
  State<_AnimatedOrderCard> createState() => _AnimatedOrderCardState();
}

class _AnimatedOrderCardState extends State<_AnimatedOrderCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _sizeAnimation;
  bool _isInstalling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInBack),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _triggerInstallation() {
    setState(() => _isInstalling = true);
    _controller.forward().then((_) {
      widget.onInstall();
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final p = widget.p;
    final isReady = order.isDelivered;
    final remainingSec = order.remainingSeconds;

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isInstalling ? p.successColor.withValues(alpha: 0.25) : p.surfaceColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isInstalling ? p.successColor : p.surfaceBorderColor,
                width: _isInstalling ? 2 : 1,
              ),
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
                        isReady ? (_isInstalling ? 'Monte Ediliyor...' : 'Teslimat Tamamlandı!') : 'Kargoda ($remainingSec sn kaldı)',
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
                  onPressed: (isReady && !_isInstalling) ? _triggerInstallation : null,
                  child: Text(isReady ? (_isInstalling ? '...' : 'Montaj Et') : 'Bekleniyor'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DisappearingDetailingTile extends StatefulWidget {
  final DetailingOption opt;
  final ThemePaletteModel p;
  final bool canAfford;
  final VoidCallback onApply;

  const _DisappearingDetailingTile({
    required super.key,
    required this.opt,
    required this.p,
    required this.canAfford,
    required this.onApply,
  });

  @override
  State<_DisappearingDetailingTile> createState() => _DisappearingDetailingTileState();
}

class _DisappearingDetailingTileState extends State<_DisappearingDetailingTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sizeAnimation;
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(_fadeAnimation);
    _sizeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleApply() async {
    if (_isAnimatingOut) return;
    setState(() => _isAnimatingOut = true);
    await _controller.forward();
    widget.onApply();
  }

  @override
  Widget build(BuildContext context) {
    final opt = widget.opt;
    final p = widget.p;

    return SizeTransition(
      sizeFactor: _sizeAnimation,
      alignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_fadeAnimation),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.surfaceColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: opt.isRisky ? p.secondaryColor : p.surfaceBorderColor,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: opt.isRisky
                      ? p.secondaryColor.withValues(alpha: 0.15)
                      : p.primaryColor.withValues(alpha: 0.15),
                  child: VectorIconWidget(
                    type: opt.vectorIcon,
                    color: opt.isRisky ? p.secondaryColor : p.primaryColor,
                    size: 20,
                  ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  onPressed: widget.canAfford && !_isAnimatingOut ? _handleApply : null,
                  child: Text(
                    CurrencyFormatter.formatShort(opt.cost),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IsometricHydraulicLiftWidget extends StatefulWidget {
  final CarModel car;
  final ThemePaletteModel p;

  const _IsometricHydraulicLiftWidget({required this.car, required this.p});

  @override
  State<_IsometricHydraulicLiftWidget> createState() => _IsometricHydraulicLiftWidgetState();
}

class _IsometricHydraulicLiftWidgetState extends State<_IsometricHydraulicLiftWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final carColor = Color(int.parse(widget.car.colorHex.replaceFirst('#', '0xff')));
    final p = widget.p;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          height: 110,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.isometricGridDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.primaryColor.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.08 + (_animController.value * 0.08)),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Isometric Hydraulic Lift Stand with Animated Sparks
              CustomPaint(
                size: const Size(double.infinity, 110),
                painter: _LiftPainter(
                  primaryColor: p.primaryColor,
                  carColor: carColor,
                  animProgress: _animController.value,
                ),
              ),
              Positioned(
                top: 10,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.neonCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.neonCyan, width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.build_circle_rounded, color: AppColors.neonCyan, size: 12),
                      SizedBox(width: 4),
                      Text('LİFTTE', style: TextStyle(color: AppColors.neonCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiftPainter extends CustomPainter {
  final Color primaryColor;
  final Color carColor;
  final double animProgress;

  _LiftPainter({required this.primaryColor, required this.carColor, required this.animProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // Hydraulic Lift Arms
    final armPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(center.dx - 40, center.dy + 20), Offset(center.dx - 40, center.dy - 10), armPaint);
    canvas.drawLine(Offset(center.dx + 40, center.dy + 20), Offset(center.dx + 40, center.dy - 10), armPaint);

    // Platform Base
    final platformPath = Path()
      ..moveTo(center.dx, center.dy - 20)
      ..lineTo(center.dx + 55, center.dy - 10)
      ..lineTo(center.dx, center.dy)
      ..lineTo(center.dx - 55, center.dy - 10)
      ..close();
    canvas.drawPath(platformPath, Paint()..color = primaryColor.withValues(alpha: 0.3));
    canvas.drawPath(platformPath, Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Car Silhouette elevated on hydraulic lift
    final carPath = Path()
      ..moveTo(center.dx, center.dy - 35)
      ..lineTo(center.dx + 28, center.dy - 23)
      ..lineTo(center.dx, center.dy - 11)
      ..lineTo(center.dx - 28, center.dy - 23)
      ..close();
    canvas.drawPath(carPath, Paint()..color = carColor);

    // Animated Repair Sparks (Juiciness effect)
    final sparkPaint = Paint()
      ..color = AppColors.neonCyan.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final spark1Offset = Offset(center.dx - 20 + (animProgress * 15), center.dy - 25 - (animProgress * 8));
    final spark2Offset = Offset(center.dx + 18 - (animProgress * 12), center.dy - 30 - (animProgress * 6));
    canvas.drawCircle(spark1Offset, 2.5, sparkPaint);
    canvas.drawCircle(spark2Offset, 2.0, sparkPaint);
  }

  @override
  bool shouldRepaint(covariant _LiftPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress || oldDelegate.carColor != carColor;
  }
}
