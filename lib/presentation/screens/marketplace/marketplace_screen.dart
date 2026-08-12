import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listings = ref.watch(marketProvider);
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('İKİNCİ EL PAZARI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Pazarı Yenile',
            onPressed: () {
              ref.read(marketProvider.notifier).refreshMarket();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Satılık Araçlar (${listings.length})', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 15)),
                Text('Sermaye: ${CurrencyFormatter.formatShort(game.balance)}', style: AppTypography.moneyMedium(isDark)),
              ],
            ),
          ),
          Expanded(
            child: listings.isEmpty
                ? Center(
                    child: Text('Şu an pazarda araç kalmadı. Yenile butonuna bas.', style: AppTypography.bodyMedium(isDark)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final item = listings[index];
                      final car = item.car;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondarySage.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(car.bodyType, style: AppTypography.labelSmall(isDark).copyWith(color: AppColors.secondarySage)),
                                  ),
                                  Text('${item.sellerCity} • ${car.modelYear}', style: AppTypography.labelSmall(isDark)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(item.title, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Satıcı: ${item.sellerName}', style: AppTypography.bodyMedium(isDark).copyWith(fontSize: 12)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('İlan Fiyatı', style: AppTypography.labelSmall(isDark)),
                                      Text(CurrencyFormatter.format(item.askingPrice), style: AppTypography.moneyMedium(isDark)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.primaryAmber),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () {
                                          context.push('/expertise', extra: item);
                                        },
                                        child: Text(item.isExpertiseCompleted ? 'Ekspertiz Raporu' : 'Ekspertiz Yaptır (₺1.500)', style: const TextStyle(fontSize: 12)),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primaryAmber,
                                          foregroundColor: AppColors.backgroundDark,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: game.balance < item.askingPrice
                                            ? null
                                            : () {
                                                final success = ref.read(gameProvider.notifier).buyCar(car, item.askingPrice);
                                                if (success) {
                                                  ref.read(marketProvider.notifier).removeListing(item.id);
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(content: Text('${car.brand} ${car.modelName} satın alındı ve garajına eklendi!')),
                                                  );
                                                }
                                              },
                                        child: const Text('Satın Al', style: TextStyle(fontWeight: FontWeight.bold)),
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
          ),
        ],
      ),
    );
  }
}
