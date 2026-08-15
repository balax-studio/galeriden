import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

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

  Color _getTierColor(PartQualityTier tier) {
    switch (tier) {
      case PartQualityTier.worn:
        return const Color(0xFFEF4444); // Red
      case PartQualityTier.usable:
        return const Color(0xFFF59E0B); // Amber
      case PartQualityTier.good:
        return const Color(0xFF3B82F6); // Blue
      case PartQualityTier.pristine:
        return const Color(0xFF10B981); // Emerald
    }
  }

  void _showInstallPartDialog(BuildContext context, SalvagedPart part) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (game.ownedCars.isEmpty) {
      NotificationService.showError(context, 'Garajında parça takabileceğin hiç araç yok!');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(18),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PARÇAYI ARACA MONTE ET',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${part.name} (%${part.conditionPercent} kondisyon) hangi araca takılsın?',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: game.ownedCars.length,
                    itemBuilder: (cCtx, i) {
                      final car = game.ownedCars[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            final success = ref.read(gameProvider.notifier).installPartToCar(part.id, car.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                '${part.name}, ${car.brand} ${car.modelName} aracına başarıyla takıldı!',
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.2),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${car.modelYear} ${car.brand} ${car.modelName}',
                                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                                    ),
                                    Text(
                                      'Motor: %${car.expertise.engineCondition.round()} • Şanzıman: %${car.expertise.transmissionCondition.round()}',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final scrapCars = game.scrapyardCars;
    final salvagedParts = game.salvagedParts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: 'HURDALIK & SÖKÜM TESİSİ',
        bottom: NeoBrutalTabBar(
          controller: _tabController,
          tabs: [
            'PERT ARAÇLAR (${scrapCars.where((c) => !c.isPurchased).length})',
            'ÇIKMA PARÇALAR (${salvagedParts.length})',
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Pert Hurda Araçlar
          Builder(
            builder: (context) {
              final activeScrapCars = scrapCars.where((c) => !c.isPurchased).toList();
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                physics: const BouncingScrollPhysics(),
                itemCount: activeScrapCars.isEmpty ? 2 : activeScrapCars.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(14),
                        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                        borderRadius: 14,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.brutalOrange,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: const Icon(Icons.car_crash_rounded, color: Colors.black, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'KAZALI & PERT ARAÇ SÖKÜMÜ',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pert araçları satın alıp sağlam parçalarını sökün. Pazarda satın veya atölyede araçlarınıza takın!',
                                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (activeScrapCars.isEmpty) {
                    return NeoBrutalCard(
                      padding: const EdgeInsets.all(24),
                      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                      borderRadius: 14,
                      child: const Center(
                        child: Text(
                          'Hurdalıkta şu an satılık pert araç kalmadı. Yeni hurda araçlar 3 gün içinde gelecek!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    );
                  }

                  final car = activeScrapCars[index - 1];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                      borderRadius: 14,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${car.modelYear} ${car.brand} ${car.modelName}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              const NeoBrutalBadge(
                                text: 'AĞIR PERT',
                                backgroundColor: AppColors.errorRed,
                                textColor: Colors.white,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Hasar Notu: ${car.damageNote}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.brutalOrange),
                          ),
                          const SizedBox(height: 10),

                          // Parts Preview
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.black, width: 1.2),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SÖKÜLEBİLİR PARÇALAR (${car.parts.length} Parça):',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 6),
                                ...car.parts.map((p) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: _getTierColor(p.tier),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                p.name,
                                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '~${CurrencyFormatter.formatShort(p.estimatedValue)}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'HURDA ALIŞ FİYATI',
                                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatShort(car.scrapPrice),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalOrange),
                                  ),
                                ],
                              ),
                              NeoBrutalButton(
                                label: 'SATIN AL & PARÇALA',
                                icon: Icons.build_rounded,
                                backgroundColor: AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 11.5,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                onPressed: () {
                                  if (game.balance < car.scrapPrice) {
                                    NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.formatShort(car.scrapPrice)} gerekli.');
                                    return;
                                  }
                                  final success = ref.read(gameProvider.notifier).buyAndDismantleScrapCar(car.id);
                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      '${car.modelName} satın alındı ve parçalarına ayrılarak depoya aktarıldı!',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Tab 2: Sökülen Parçalar Stoğu
          ListView.builder(
            padding: const EdgeInsets.all(14),
            physics: const BouncingScrollPhysics(),
            itemCount: salvagedParts.isEmpty ? 2 : salvagedParts.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'ÇIKMA YEDEK PARÇA DEPOSU (${salvagedParts.length} Parça)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                    ),
                  ),
                );
              }

              if (salvagedParts.isEmpty) {
                return NeoBrutalCard(
                  padding: const EdgeInsets.all(28),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 14,
                  child: const Column(
                    children: [
                      Icon(Icons.inventory_2_rounded, color: Color(0xFF64748B), size: 40),
                      SizedBox(height: 10),
                      Text(
                        'Yedek Parça Stoğun Boş!',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pert araç sekmesinden araç satın alıp parçalayarak deponu doldurabilirsin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                );
              }

              final part = salvagedParts[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              part.name,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          NeoBrutalBadge(
                            text: part.tierName,
                            backgroundColor: _getTierColor(part.tier),
                            textColor: Colors.white,
                            fontSize: 9.5,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Model: ${part.carModelName} • Kondisyon: %${part.conditionPercent}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.formatShort(part.estimatedValue),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                          Row(
                            children: [
                              NeoBrutalButton(
                                label: 'ARACA TAK',
                                icon: Icons.handyman_rounded,
                                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                textColor: isDark ? Colors.white : Colors.black,
                                fontSize: 10.5,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                onPressed: () => _showInstallPartDialog(context, part),
                              ),
                              const SizedBox(width: 6),
                              NeoBrutalButton(
                                label: 'PAZARDA SAT',
                                icon: Icons.attach_money_rounded,
                                backgroundColor: AppColors.brutalGreen,
                                textColor: Colors.black,
                                fontSize: 10.5,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                onPressed: () {
                                  final success = ref.read(gameProvider.notifier).sellSalvagedPart(part.id);
                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      '${part.name} ${CurrencyFormatter.formatShort(part.estimatedValue)} karşılığı satıldı!',
                                    );
                                  }
                                },
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
        ],
      ),
    );
  }
}
