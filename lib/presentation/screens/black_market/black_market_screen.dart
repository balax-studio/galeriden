import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

class BlackMarketScreen extends ConsumerWidget {
  const BlackMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final bmCars = game.blackMarketCars;

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
            'KARABORSA & YASA DIŞI OTO PAZARI',
            style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Danger Header Banner
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              borderColor: Colors.redAccent.withValues(alpha: 0.7),
              glowColor: Colors.redAccent.withValues(alpha: 0.2),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security_rounded, color: Colors.redAccent, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Yüksek Kâr / Yüksek Risk', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('RİSKLİ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Change, şasi soruşturmalı veya gümrük kaçakçısı araçlar yarı fiyatına satılır. Yakalanırsanız polis el koyabilir!',
                          style: AppTypography.bodyMedium(p.isDark).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text('GECE KUŞU SATICILARI & SORUŞTURMALI ARAÇLAR', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            if (bmCars.isEmpty || bmCars.every((c) => c.isPurchased))
              AppGlassContainer(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Karaborsada şu an satılık araç yok. Yeni teklifler gece 00:00 devriyesiyle gelecek!',
                    style: AppTypography.bodyMedium(p.isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bmCars.length,
                itemBuilder: (context, index) {
                  final car = bmCars[index];
                  if (car.isPurchased) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppDoubleBezelCard(
                      accentColor: Colors.redAccent,
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
                                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  'POLİS RİSKİ: %${car.riskLevelPercent}',
                                  style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Satıcı: ${car.sellerAlias}', style: AppTypography.labelSmall(p.isDark).copyWith(color: Colors.amber)),
                          const SizedBox(height: 4),
                          Text(car.riskDescription, style: AppTypography.bodyMedium(p.isDark).copyWith(color: Colors.red.shade300)),
                          const SizedBox(height: 14),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Piyasa Değeri: ₺${CurrencyFormatter.formatShort(car.realMarketValue)}',
                                    style: TextStyle(decoration: TextDecoration.lineThrough, color: p.textSecondaryColor, fontSize: 12),
                                  ),
                                  Text(
                                    'Teklif: ₺${CurrencyFormatter.formatShort(car.askingPrice)}',
                                    style: AppTypography.titleLarge(p.isDark).copyWith(color: Colors.greenAccent, fontSize: 18),
                                  ),
                                ],
                              ),
                              AppTactileButton(
                                onPressed: () {
                                  if (game.ownedCars.length >= game.maxGarageSlots) {
                                    NotificationService.showError(context, 'Garajında boş yer yok! Şubeni büyüt veya bir araç sat.');
                                    return;
                                  }
                                  if (game.balance < car.askingPrice) {
                                    NotificationService.showError(context, 'Yetersiz bakiye! ₺${CurrencyFormatter.formatShort(car.askingPrice)} gerekli.');
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.gavel_rounded, size: 16, color: Colors.white),
                                      SizedBox(width: 6),
                                      Text(
                                        'Riski Al & Satın Al',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
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
    );
  }
}
