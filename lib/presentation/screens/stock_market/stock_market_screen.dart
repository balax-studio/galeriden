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

    // Calculate total portfolio value and overall profit/loss
    double totalPortfolioValue = 0.0;
    double totalCostBasis = 0.0;

    for (var owned in game.ownedStocks) {
      final currentStock = game.marketStocks.where((s) => s.symbol == owned.symbol).firstOrNull;
      final currentPrice = currentStock?.currentPrice ?? owned.averageCost;
      totalPortfolioValue += owned.quantity * currentPrice;
      totalCostBasis += owned.quantity * owned.averageCost;
    }

    final double totalProfitLoss = totalPortfolioValue - totalCostBasis;
    final bool isOverallProfitable = totalProfitLoss >= 0;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'BORSA İŞLEMLERİ (BİST-OTO)',
          style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Portfolio Summary Header Card
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isOverallProfitable ? p.successColor : p.errorColor).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isOverallProfitable ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: isOverallProfitable ? p.successColor : p.errorColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Toplam Portföy Değeri', style: AppTypography.labelSmall(p.isDark)),
                        const SizedBox(height: 4),
                        Text(
                          '₺${CurrencyFormatter.formatShort(totalPortfolioValue)}',
                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 20, color: p.primaryColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Net Kar/Zarar: ${isOverallProfitable ? '+' : ''}₺${CurrencyFormatter.formatShort(totalProfitLoss)}',
                          style: AppTypography.bodyMedium(p.isDark).copyWith(
                            color: isOverallProfitable ? p.successColor : p.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('HİSSE SENETLERİ PAZARI', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            ...game.marketStocks.map((stock) {
              final owned = game.ownedStocks.where((s) => s.symbol == stock.symbol).firstOrNull;
              final int sharesOwned = owned?.quantity ?? 0;
              final double changePercent = stock.previousPrice > 0
                  ? ((stock.currentPrice - stock.previousPrice) / stock.previousPrice) * 100.0
                  : 0.0;
              final bool isUp = changePercent >= 0;

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
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isUp ? p.successColor : p.errorColor).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isUp ? Icons.show_chart_rounded : Icons.south_east_rounded,
                                  color: isUp ? p.successColor : p.errorColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stock.name, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                                  Text(stock.symbol, style: AppTypography.labelSmall(p.isDark).copyWith(color: p.textSecondaryColor)),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '₺${CurrencyFormatter.formatShort(stock.currentPrice)}',
                                style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16, color: p.primaryColor),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: (isUp ? p.successColor : p.errorColor).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${isUp ? '+' : ''}${changePercent.toStringAsFixed(2)}%',
                                  style: AppTypography.labelSmall(p.isDark).copyWith(
                                    fontSize: 11,
                                    color: isUp ? p.successColor : p.errorColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      if (sharesOwned > 0) ...[
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Elinizdeki Lot: $sharesOwned', style: AppTypography.labelSmall(p.isDark)),
                            Text(
                              'Ort. Maliyet: ₺${CurrencyFormatter.formatShort(owned!.averageCost)}',
                              style: AppTypography.labelSmall(p.isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Portföy Değeri:', style: AppTypography.labelSmall(p.isDark)),
                            Text(
                              '₺${CurrencyFormatter.formatShort(sharesOwned * stock.currentPrice)}',
                              style: AppTypography.titleLarge(p.isDark).copyWith(
                                fontSize: 14,
                                color: (stock.currentPrice >= owned.averageCost) ? p.successColor : p.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: BorderSide(color: p.surfaceBorderColor),
                              ),
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).buyStock(stock.symbol, 10);
                                if (success) {
                                  NotificationService.showSuccess(context, '10 Lot ${stock.symbol} satın alındı!');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz bakiye!');
                                }
                              },
                              child: const Text('10 Lot Al'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                side: BorderSide(color: p.surfaceBorderColor),
                              ),
                              onPressed: () {
                                final success = ref.read(gameProvider.notifier).buyStock(stock.symbol, 100);
                                if (success) {
                                  NotificationService.showSuccess(context, '100 Lot ${stock.symbol} satın alındı!');
                                } else {
                                  NotificationService.showError(context, 'Yetersiz bakiye!');
                                }
                              },
                              child: const Text('100 Lot Al'),
                            ),
                          ),
                          if (sharesOwned > 0) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: p.errorColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  final success = ref.read(gameProvider.notifier).sellStock(stock.symbol, sharesOwned);
                                  if (success) {
                                    NotificationService.showSuccess(context, 'Tüm ${stock.symbol} hisseleri satıldı!');
                                  } else {
                                    NotificationService.showError(context, 'İşlem gerçekleştirilemedi!');
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
            }),
          ],
        ),
      ),
    );
  }
}
