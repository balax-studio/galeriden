import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class BlackMarketScreen extends ConsumerWidget {
  const BlackMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final bmCars = game.blackMarketCars;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'KARABORSA & YASA DIŞI PAZAR',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Warning Danger Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF241414) : const Color(0xFFFEF2F2),
            borderColor: AppColors.errorRed,
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YÜKSEK KÂR / YÜKSEK RİSK',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.errorRed),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Change, şasi soruşturmalı veya hacizli araçlar yarı fiyatına satılır. Polis denetiminde yakalanma riski vardır!',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'GECE KUŞU & SORUŞTURMALI ARAÇLAR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Black Market Vehicles List
          if (bmCars.isEmpty || bmCars.every((c) => c.isPurchased))
            NeoBrutalCard(
              padding: const EdgeInsets.all(24),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 14,
              child: const Center(
                child: Column(
                  children: [
                    Icon(Icons.nightlight_round, size: 36, color: Color(0xFF64748B)),
                    SizedBox(height: 8),
                    Text(
                      'Karaborsada şu an satılık araç yok. Gece yarısı devriyesiyle yeni ilanlar düşecek!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...bmCars.where((c) => !c.isPurchased).map((car) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: AppColors.errorRed,
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
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                          ),
                          NeoBrutalBadge(
                            text: 'POLİS RİSKİ: %${car.riskLevelPercent}',
                            backgroundColor: AppColors.errorRed,
                            textColor: Colors.white,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Satıcı: ${car.sellerAlias}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.riskDescription,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFEF4444)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Piyasa: ${CurrencyFormatter.formatShort(car.realMarketValue)}',
                                style: const TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.formatShort(car.askingPrice),
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                              ),
                            ],
                          ),
                          NeoBrutalButton(
                            label: 'RİSKİ AL & SATIN AL',
                            icon: Icons.gavel_rounded,
                            backgroundColor: AppColors.errorRed,
                            textColor: Colors.white,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            onPressed: () {
                              if (game.ownedCars.length >= game.maxGarageSlots) {
                                NotificationService.showError(context, 'Garajında boş yer yok! Şubeni büyüt veya bir araç sat.');
                                return;
                              }
                              if (game.balance < car.askingPrice) {
                                NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.formatShort(car.askingPrice)} gerekli.');
                                return;
                              }

                              final success = ref.read(gameProvider.notifier).buyBlackMarketCar(car.id);
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  '${car.modelName} karaborsadan satın alındı! Garajına eklendi.',
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
            }),
        ],
      ),
    );
  }
}
