import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/stock_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';

class StockTradeModal {
  static void show(BuildContext context, WidgetRef ref, StockModel stock,
      PlayerStockModel? owned) {
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
            final double grossCost = lotAmount * stock.currentPrice;
            final double commission = grossCost * 0.002;
            final double totalCost = grossCost + commission;
            final int maxBuyable =
                (game.balance / (stock.currentPrice * 1.002)).floor();
            final int sharesOwned = owned?.quantity ?? 0;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(dialogCtx).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF141721) : Colors.white,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.5,
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${stock.symbol} • ${stock.name}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                context.tr('stock_unit_price', {
                                  'price': CurrencyFormatter.formatShort(
                                      stock.currentPrice),
                                  'dividend': (stock.dividendYield * 100)
                                      .toStringAsFixed(1),
                                }),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        NeoBrutalBadge(
                          text:
                              '${stock.isUp ? '+' : ''}${stock.changePercentage.toStringAsFixed(1)}%',
                          backgroundColor: stock.isUp
                              ? AppColors.brutalGreen
                              : AppColors.errorRed,
                          textColor: stock.isUp ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('stock_lot_label'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lotController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 18),
                      decoration: InputDecoration(
                        hintText: context.tr('stock_lot_hint'),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF0F1118)
                            : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: AppColors.brutalYellow, width: 2.5),
                        ),
                        suffixText: 'LOT',
                        suffixStyle:
                            const TextStyle(fontWeight: FontWeight.w900),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    // Quick Percent / Lot Buttons
                    Row(
                      children: [
                        _buildQuickChip('%25', () {
                          final count = (maxBuyable * 0.25)
                              .floor()
                              .clamp(1, maxBuyable > 0 ? maxBuyable : 1);
                          lotController.text = count.toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('%50', () {
                          final count = (maxBuyable * 0.50)
                              .floor()
                              .clamp(1, maxBuyable > 0 ? maxBuyable : 1);
                          lotController.text = count.toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('%75', () {
                          final count = (maxBuyable * 0.75)
                              .floor()
                              .clamp(1, maxBuyable > 0 ? maxBuyable : 1);
                          lotController.text = count.toString();
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip('MAX • $maxBuyable', () {
                          lotController.text = maxBuyable.toString();
                          setDialogState(() {});
                        }, isDark),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F1118)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(context.tr('stock_amount_label'),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  child: Text(
                                      CurrencyFormatter.formatShort(grossCost),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(
                                      context.tr('stock_broker_commission'),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  child: Text(
                                      CurrencyFormatter.formatShort(commission),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w700))),
                            ],
                          ),
                          Divider(
                              height: 12,
                              thickness: 1,
                              color: isDark
                                  ? const Color(0xFF2A3142)
                                  : const Color(0xFFE2E8F0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(context.tr('stock_total_amount'),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800))),
                              Expanded(
                                  child: Text(
                                CurrencyFormatter.formatShort(totalCost),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brutalGreen),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            label: context.tr('stock_btn_buy_lot'),
                            icon: Icons.add_shopping_cart_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            onPressed: () {
                              if (lotAmount <= 0) {
                                NotificationService.showError(context,
                                    context.tr('stock_lot_invalid_toast'));
                                return;
                              }
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .buyStock(stock.symbol, lotAmount);
                              if (success) {
                                Navigator.pop(dialogCtx);
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('stock_buy_success_toast', {
                                    'count': lotAmount,
                                    'symbol': stock.symbol
                                  }),
                                );
                              } else {
                                NotificationService.showError(
                                    context,
                                    context
                                        .tr('stock_insufficient_funds_toast'));
                              }
                            },
                          ),
                        ),
                        if (sharesOwned > 0) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: NeoBrutalButton(
                              label: context.tr(
                                  'stock_btn_sell_lot', {'count': sharesOwned}),
                              icon: Icons.sell_rounded,
                              backgroundColor: AppColors.errorRed,
                              textColor: Colors.white,
                              onPressed: () {
                                final sellCount = lotAmount > sharesOwned
                                    ? sharesOwned
                                    : lotAmount;
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .sellStock(stock.symbol, sellCount);
                                if (success) {
                                  Navigator.pop(dialogCtx);
                                  NotificationService.showSuccess(
                                    context,
                                    context.tr('stock_sell_success_toast', {
                                      'count': sellCount,
                                      'symbol': stock.symbol
                                    }),
                                  );
                                } else {
                                  NotificationService.showError(context,
                                      context.tr('stock_sell_failed_toast'));
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
            ),
          ),
        );
      },
    );
  },
).then((_) => lotController.dispose());
}

  static Widget _buildQuickChip(String label, VoidCallback onTap, bool isDark) {
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
