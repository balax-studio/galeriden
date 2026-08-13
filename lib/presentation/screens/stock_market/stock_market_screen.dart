import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';

class StockMarketScreen extends ConsumerWidget {
  const StockMarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'BORSA',
          style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: game.marketStocks.length,
        itemBuilder: (context, index) {
          final stock = game.marketStocks[index];
          final owned = game.ownedStocks.where((s) => s.symbol == stock.symbol).firstOrNull;
          final int sharesOwned = owned?.quantity ?? 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.show_chart_rounded, color: p.primaryColor),
                          const SizedBox(width: 8),
                          Text('${stock.name} (${stock.symbol})', style: AppTypography.titleLarge(p.isDark)),
                        ],
                      ),
                      Text(
                        '₺${CurrencyFormatter.formatShort(stock.currentPrice)}',
                        style: AppTypography.titleLarge(p.isDark).copyWith(color: p.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (sharesOwned > 0) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sahip Olunan: $sharesOwned Adet', style: AppTypography.labelSmall(p.isDark)),
                        Text(
                          'Ortalama Maliyet: ₺${CurrencyFormatter.formatShort(owned!.averageCost)}',
                          style: AppTypography.labelSmall(p.isDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Toplam Değer:', style: AppTypography.labelSmall(p.isDark)),
                        Text(
                          '₺${CurrencyFormatter.formatShort(sharesOwned * stock.currentPrice)}',
                          style: AppTypography.titleLarge(p.isDark).copyWith(color: (stock.currentPrice >= owned.averageCost) ? p.successColor : p.warningColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final success = ref.read(gameProvider.notifier).buyStock(stock.symbol, 10);
                            if (success) {
                              NotificationService.showSuccess(context, '10 Lot ${stock.symbol} satın alındı!');
                            } else {
                              NotificationService.showError(context, 'Yetersiz bakiye!');
                            }
                          },
                          child: const Text('10 Al'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            final success = ref.read(gameProvider.notifier).buyStock(stock.symbol, 100);
                            if (success) {
                              NotificationService.showSuccess(context, '100 Lot ${stock.symbol} satın alındı!');
                            } else {
                              NotificationService.showError(context, 'Yetersiz bakiye!');
                            }
                          },
                          child: const Text('100 Al'),
                        ),
                      ),
                      if (sharesOwned > 0) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: p.errorColor, foregroundColor: Colors.white),
                            onPressed: () {
                              final success = ref.read(gameProvider.notifier).sellStock(stock.symbol, sharesOwned);
                              if (success) {
                                NotificationService.showSuccess(context, 'Tüm ${stock.symbol} hisseleri satıldı!');
                              } else {
                                NotificationService.showError(context, 'Hata oluştu!');
                              }
                            },
                            child: const Text('Tümünü Sat'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
