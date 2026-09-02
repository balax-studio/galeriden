import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/stock_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';

class ForexTradeModal {
  static void show(BuildContext context, WidgetRef ref, ForexGoldModel forex,
      PlayerForexModel? owned) {
    final game = ref.read(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountController =
        TextEditingController(text: forex.symbol == 'GOLD' ? '5' : '100');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            final double amount = double.tryParse(amountController.text) ?? 0.0;
            final double buyCost = amount * forex.buyRate;
            final double sellRevenue = amount * forex.sellRate;
            final double maxBuyable = (game.balance / forex.buyRate);
            final double currentOwned = owned?.amount ?? 0.0;

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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${forex.symbol} • ${forex.name}',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              context.tr('forex_rate_label', {
                                'buy': forex.buyRate.toStringAsFixed(2),
                                'sell': forex.sellRate.toStringAsFixed(2),
                              }),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        NeoBrutalBadge(
                          text:
                              '${forex.isUp ? '+' : ''}${forex.changePercentage.toStringAsFixed(1)}%',
                          backgroundColor: forex.isUp
                              ? AppColors.brutalGreen
                              : AppColors.errorRed,
                          textColor: forex.isUp ? Colors.black : Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.tr('forex_amount_label', {
                        'unit': forex.symbol == 'GOLD'
                            ? context.tr('forex_unit_gram')
                            : context.tr('forex_unit_unit'),
                      }),
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
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: InputDecoration(
                        hintText: context.tr('forex_amount_hint'),
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
                        suffixText:
                            forex.symbol == 'GOLD' ? 'GR' : forex.symbol,
                        suffixStyle:
                            const TextStyle(fontWeight: FontWeight.w900),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildQuickChip(forex.symbol == 'GOLD' ? '+5' : '+100',
                            () {
                          final step = forex.symbol == 'GOLD' ? 5 : 100;
                          amountController.text =
                              (amount + step).toStringAsFixed(0);
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip(forex.symbol == 'GOLD' ? '+25' : '+500',
                            () {
                          final step = forex.symbol == 'GOLD' ? 25 : 500;
                          amountController.text =
                              (amount + step).toStringAsFixed(0);
                          setDialogState(() {});
                        }, isDark),
                        const SizedBox(width: 6),
                        _buildQuickChip(context.tr('forex_btn_max_buy'), () {
                          amountController.text = maxBuyable.toStringAsFixed(0);
                          setDialogState(() {});
                        }, isDark),
                        if (currentOwned > 0) ...[
                          const SizedBox(width: 6),
                          _buildQuickChip(context.tr('forex_btn_sell_all'), () {
                            amountController.text =
                                currentOwned.toStringAsFixed(0);
                            setDialogState(() {});
                          }, isDark),
                        ],
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
                                  child: Text(context.tr('stock_buy_cost'),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  child: Text(
                                      CurrencyFormatter.formatShort(buyCost),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brutalGreen))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(context.tr('stock_sell_revenue'),
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600))),
                              Expanded(
                                  child: Text(
                                      CurrencyFormatter.formatShort(
                                          sellRevenue),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.errorRed))),
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
                            label: context.tr('forex_btn_buy'),
                            icon: Icons.add_circle_outline_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            onPressed: () {
                              if (amount <= 0) {
                                NotificationService.showError(context,
                                    context.tr('forex_amount_invalid_toast'));
                                return;
                              }
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .buyForex(forex.symbol, amount);
                              if (success) {
                                Navigator.pop(dialogCtx);
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('forex_buy_success_toast', {
                                    'amount': amount.toStringAsFixed(0),
                                    'symbol': forex.symbol
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
                        if (currentOwned > 0) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: NeoBrutalButton(
                              label: context.tr('forex_btn_sell'),
                              icon: Icons.currency_exchange_rounded,
                              backgroundColor: AppColors.errorRed,
                              textColor: Colors.white,
                              onPressed: () {
                                final sellAmount = amount > currentOwned
                                    ? currentOwned
                                    : amount;
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .sellForex(forex.symbol, sellAmount);
                                if (success) {
                                  Navigator.pop(dialogCtx);
                                  NotificationService.showSuccess(
                                    context,
                                    context.tr('forex_sell_success_toast', {
                                      'amount': sellAmount.toStringAsFixed(0),
                                      'symbol': forex.symbol
                                    }),
                                  );
                                } else {
                                  NotificationService.showError(context,
                                      context.tr('forex_tx_failed_toast'));
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
).then((_) => amountController.dispose());
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
