import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

class ScrapyardScreen extends ConsumerStatefulWidget {
  const ScrapyardScreen({super.key});

  @override
  ConsumerState<ScrapyardScreen> createState() => _ScrapyardScreenState();
}

class _ScrapyardScreenState extends ConsumerState<ScrapyardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final scrapCars = game.scrapyardCars;
    final salvagedParts = game.salvagedParts;

    return Scaffold(
      backgroundColor: p.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'HURDALIK & PARÇA SÖKÜM TESİSİ',
            style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.minor_crash_rounded),
              text: 'Pert Araçlar (${scrapCars.where((c) => !c.isPurchased).length})',
            ),
            Tab(
              icon: const Icon(Icons.handyman_rounded),
              text: 'Sökülen Parçalar (${salvagedParts.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Pert Hurda Araçlar
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Header Card
                AppGlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderColor: Colors.orange.withValues(alpha: 0.5),
                  glowColor: Colors.orange.withValues(alpha: 0.15),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.car_crash_rounded, color: Colors.orange, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Oto Hurdalığı & Demontaj', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              'Kazalı pert araçları ucuza satın alıp sağlam parçalarını sök, yedek parça pazarında yüksek kârla sat!',
                              style: AppTypography.bodyMedium(p.isDark).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text('SATILIK PERT VE HURDA ARAÇLAR', style: AppTypography.labelSmall(p.isDark)),
                const SizedBox(height: 12),

                if (scrapCars.isEmpty || scrapCars.every((c) => c.isPurchased))
                  AppGlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Hurdalıkta şu an satılık pert araç kalmadı. Yeni hurda araçlar 3 gün içinde gelecek!',
                        style: AppTypography.bodyMedium(p.isDark),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scrapCars.length,
                    itemBuilder: (context, index) {
                      final car = scrapCars[index];
                      if (car.isPurchased) return const SizedBox.shrink();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AppDoubleBezelCard(
                          accentColor: Colors.orangeAccent,
                          outerRadius: 18,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${car.modelYear} ${car.brand} ${car.modelName}',
                                      style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      'AĞIR PERT',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Hasar Durumu: ${car.damageNote}', style: AppTypography.bodyMedium(p.isDark).copyWith(color: Colors.orangeAccent)),
                              const SizedBox(height: 12),
                              
                              // Estimated Parts Preview
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: p.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('SÖKÜLEBİLİR SAĞLAM PARÇALAR (${car.parts.length} Parça):', style: AppTypography.labelSmall(p.isDark)),
                                    const SizedBox(height: 6),
                                    ...car.parts.map((p) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('• ${p.name}', style: TextStyle(fontSize: 12, color: themeExt.palette.textSecondaryColor)),
                                          Text('~₺${CurrencyFormatter.formatShort(p.estimatedValue)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                                        ],
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Hurda Alış Fiyatı:', style: AppTypography.labelSmall(p.isDark)),
                                      Text(
                                        '₺${CurrencyFormatter.formatShort(car.scrapPrice)}',
                                        style: AppTypography.titleLarge(p.isDark).copyWith(color: p.primaryColor, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  AppTactileButton(
                                    onPressed: () {
                                      if (game.balance < car.scrapPrice) {
                                        NotificationService.showError(context, 'Yetersiz bakiye! ₺${CurrencyFormatter.formatShort(car.scrapPrice)} gerekli.');
                                        return;
                                      }

                                      final success = ref.read(gameProvider.notifier).buyScrapyardCar(car.id);
                                      if (success) {
                                        NotificationService.showSuccess(
                                          context,
                                          '${car.modelName} hurdalıktan alındı ve ${car.parts.length} sağlam parçaya söküldü!',
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.orangeAccent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(Icons.build_rounded, size: 16, color: Colors.black),
                                          SizedBox(width: 6),
                                          Text(
                                            'Satın Al & Parçala',
                                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Tab 2: Sökülen Parçalar Stoğu
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STOKTAKİ SÖKÜLEN YEDEK PARÇALAR', style: AppTypography.labelSmall(p.isDark)),
                const SizedBox(height: 12),

                if (salvagedParts.isEmpty)
                  AppGlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.inventory_2_rounded, color: p.textSecondaryColor, size: 48),
                          const SizedBox(height: 12),
                          Text('Yedek Parça Stoğun Boş!', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Pert araç sekmesinden araç satın alarak parçalarını sökebilirsin.', style: AppTypography.bodyMedium(p.isDark)),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: salvagedParts.length,
                    itemBuilder: (context, index) {
                      final part = salvagedParts[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: p.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: p.surfaceBorderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(part.name, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                                  const SizedBox(height: 2),
                                  Text('Kaynak: ${part.carModelName} | Kondisyon: %${part.conditionPercent}', style: AppTypography.bodyMedium(p.isDark)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Pazar Satış Değeri: ₺${CurrencyFormatter.formatShort(part.estimatedValue)}',
                                    style: TextStyle(color: p.successColor, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            AppTactileButton(
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).sellSalvagedPart(part.id);
                                if (success) {
                                  NotificationService.showSuccess(
                                    context,
                                    '${part.name} ₺${CurrencyFormatter.formatShort(part.estimatedValue)} fiyata yedek parça pazarına satıldı!',
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: p.primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Pazarda Sat',
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
