import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class BlackMarketScreen extends ConsumerWidget {
  const BlackMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/black-market')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'KARABORSA & YASA DIŞI PAZAR'),
        body: const NeoBrutalLockedFeatureView(
          route: '/black-market',
          featureTitle: 'KARABORSA PAZARI',
          icon: Icons.masks_rounded,
        ),
      );
    }

    final bmCars = game.blackMarketCars;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'KARABORSA & YASA DIŞI PAZAR',
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
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
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
            const NeoBrutalEmptyState(
              icon: Icons.nightlight_round,
              accentColor: AppColors.errorRed,
              badgeText: 'GECE DEVRİYESİ BEKLENİYOR',
              title: 'Karaborsada Satılık Araç Yok',
              description: 'Karaborsada şu an satılık soruşturmalı araç kalmadı. Gece yarısı devriyesiyle yeni gizli ilanlar piyasaya düşecek.',
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
                              Row(
                                children: [
                                  Text(
                                    CurrencyFormatter.formatShort(
                                      game.hasHighNpcTrust('golge_ibrahim')
                                          ? (car.askingPrice * 0.85).roundToDouble()
                                          : car.askingPrice,
                                    ),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                  ),
                                  if (game.hasHighNpcTrust('golge_ibrahim')) ...[
                                    const SizedBox(width: 6),
                                    const NeoBrutalBadge(
                                      text: 'GÖLGE İNDİRİMİ -%15',
                                      backgroundColor: AppColors.brutalYellow,
                                      textColor: Colors.black,
                                      fontSize: 9,
                                    ),
                                  ],
                                ],
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
                              final effectiveCost = game.hasHighNpcTrust('golge_ibrahim')
                                  ? (car.askingPrice * 0.85).roundToDouble()
                                  : car.askingPrice;
                              if (game.balance < effectiveCost) {
                                NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.formatShort(effectiveCost)} gerekli.');
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
