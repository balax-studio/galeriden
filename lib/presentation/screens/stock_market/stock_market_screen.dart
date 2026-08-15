import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/stock_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class StockMarketScreen extends ConsumerWidget {
  const StockMarketScreen({super.key});

  void _openTradeDialog(BuildContext context, WidgetRef ref, StockModel stock, PlayerStockModel? owned) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lotController = TextEditingController(text: '10');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final int lotAmount = int.tryParse(lotController.text) ?? 0;
            final double totalCost = lotAmount * stock.currentPrice;
            final int maxBuyable = (game.balance / stock.currentPrice).floor();
            final int sharesOwned = owned?.quantity ?? 0;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(dialogCtx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141721) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border.all(color: Colors.black, width: 2.5),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${stock.symbol} • ${stock.name}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              'Birim Fiyat: ${CurrencyFormatter.formatShort(stock.currentPrice)}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        NeoBrutalBadge(
                          text: '${stock.isUp ? '+' : ''}${stock.changePercentage.toStringAsFixed(1)}%',
                          backgroundColor: stock.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                          textColor: stock.isUp ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'İŞLEM ADEDİ (LOT):',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lotController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: 'Lot Miktarı Giriniz',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2.5),
                        ),
                        suffixText: 'LOT',
                        suffixStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    // Quick amount chips
                    Row(
                      children: [
                        _buildQuickChip('+10', () {
                          lotController.text = (lotAmount + 10).toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('+50', () {
                          lotController.text = (lotAmount + 50).toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('+100', () {
                          lotController.text = (lotAmount + 100).toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('MAX AL ($maxBuyable)', () {
                          lotController.text = maxBuyable.toString();
                          setDialogState(() {});
                        }, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Toplam Tutar:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          Text(
                            CurrencyFormatter.formatShort(totalCost),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            label: 'LOT SATIN AL',
                            icon: Icons.add_shopping_cart_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            onPressed: () {
                              if (lotAmount <= 0) {
                                NotificationService.showError(context, 'Lütfen geçerli bir lot miktarı girin.');
                                return;
                              }
                              final success = ref.read(gameProvider.notifier).buyStock(stock.symbol, lotAmount);
                              if (success) {
                                Navigator.pop(dialogCtx);
                                NotificationService.showSuccess(context, '$lotAmount Lot ${stock.symbol} satın alındı!');
                              } else {
                                NotificationService.showError(context, 'Yetersiz bakiye!');
                              }
                            },
                          ),
                        ),
                        if (sharesOwned > 0) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: NeoBrutalButton(
                              label: 'SAT ($sharesOwned)',
                              icon: Icons.sell_rounded,
                              backgroundColor: AppColors.errorRed,
                              textColor: Colors.white,
                              onPressed: () {
                                final sellCount = lotAmount > sharesOwned ? sharesOwned : lotAmount;
                                final success = ref.read(gameProvider.notifier).sellStock(stock.symbol, sellCount);
                                if (success) {
                                  Navigator.pop(dialogCtx);
                                  NotificationService.showSuccess(context, '$sellCount Lot ${stock.symbol} satıldı!');
                                } else {
                                  NotificationService.showError(context, 'Satış işlemi yapılamadı!');
                                }
                              },
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
        );
      },
    );
  }

  static Widget _buildQuickChip(String label, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black, width: 1.2),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

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
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'BORSA & YATIRIM (BİST-OTO)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: NeoBrutalBadge(
                text: 'Günlük ±%10 Limit',
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Monolithic Portfolio Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isOverallProfitable ? AppColors.brutalGreen : AppColors.errorRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Icon(
                    isOverallProfitable ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: isOverallProfitable ? Colors.black : Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOPLAM PORTFÖY DEĞERİ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.formatShort(totalPortfolioValue),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      NeoBrutalBadge(
                        text: 'Kâr/Zarar: ${isOverallProfitable ? '+' : ''}${CurrencyFormatter.formatShort(totalProfitLoss)}',
                        backgroundColor: isOverallProfitable ? AppColors.brutalGreen : AppColors.errorRed,
                        textColor: isOverallProfitable ? Colors.black : Colors.white,
                        fontSize: 10.5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'HİSSE SENETLERİ LİSTESİ (${game.marketStocks.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Stocks List
          ...game.marketStocks.map((stock) {
            final owned = game.ownedStocks.where((s) => s.symbol == stock.symbol).firstOrNull;
            final int sharesOwned = owned?.quantity ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  NeoBrutalBadge(
                                    text: stock.symbol,
                                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                    textColor: isDark ? Colors.white : Colors.black,
                                    fontSize: 11,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      stock.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w800,
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.formatShort(stock.currentPrice),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            NeoBrutalBadge(
                              text: '${stock.isUp ? '+' : ''}${stock.changePercentage.toStringAsFixed(1)}%',
                              backgroundColor: stock.isUp ? AppColors.brutalGreen : AppColors.errorRed,
                              textColor: stock.isUp ? Colors.black : Colors.white,
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (sharesOwned > 0) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Eldeki: $sharesOwned Lot',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Değer: ${CurrencyFormatter.formatShort(sharesOwned * stock.currentPrice)}',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    NeoBrutalButton(
                      label: 'AL / SAT & İŞLEM YAP',
                      icon: Icons.candlestick_chart_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      fullWidth: true,
                      onPressed: () => _openTradeDialog(context, ref, stock, owned),
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
