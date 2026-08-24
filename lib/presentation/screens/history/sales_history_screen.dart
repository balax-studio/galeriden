import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/sale_record_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Profitable, 2: Loss/Break-even

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/history')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('history_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/history',
          featureTitle: context.tr('history_screen_title'),
          icon: Icons.receipt_long_rounded,
        ),
      );
    }

    final history = game.salesHistory;

    final totalRevenue =
        history.fold<double>(0.0, (sum, s) => sum + s.salePrice);
    final totalProfit = game.totalProfit;
    final avgProfit = history.isNotEmpty ? totalProfit / history.length : 0.0;

    List<SaleRecordModel> filteredHistory = history;
    if (_selectedFilterIndex == 1) {
      filteredHistory = history.where((s) => s.netProfit > 0).toList();
    } else if (_selectedFilterIndex == 2) {
      filteredHistory = history.where((s) => s.isConsignment).toList();
    } else if (_selectedFilterIndex == 3) {
      filteredHistory = history.where((s) => s.netProfit <= 0).toList();
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('history_screen_title'),
        subtitle: context.tr('sales_history_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.receiptPrint,
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. KPI Overview Metrics
          Row(
            children: [
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFF0F172A),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('history_total_sold'),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('history_sold_count',
                            {'count': '${game.carsSold}'}),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFF0F172A),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('history_total_revenue'),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatShort(totalRevenue),
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFF0F172A),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('history_total_profit'),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatShort(totalProfit),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: totalProfit >= 0
                              ? AppColors.brutalGreen
                              : AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFF0F172A),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('history_avg_profit'),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatShort(avgProfit),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: avgProfit >= 0
                              ? AppColors.brutalYellow
                              : AppColors.errorRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Filter Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                context.tr('history_sales_records_count',
                    {'count': '${filteredHistory.length}'}),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              )),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterBtn(
                        context.tr('history_filter_all'), 0, isDark),
                    const SizedBox(width: 4),
                    _buildFilterBtn(
                        context.tr('history_filter_profitable'), 1, isDark),
                    const SizedBox(width: 4),
                    _buildFilterBtn(
                        context.tr('history_filter_consignment'), 2, isDark),
                    const SizedBox(width: 4),
                    _buildFilterBtn(
                        context.tr('history_filter_loss'), 3, isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3. Sales History List
          if (filteredHistory.isEmpty)
            NeoBrutalEmptyState(
              icon: Icons.receipt_long_rounded,
              accentColor: AppColors.brutalGreen,
              badgeText: context.tr('history_empty_badge'),
              title: context.tr('history_empty_title'),
              description: context.tr('history_empty_desc'),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            )
          else
            ...filteredHistory.map((sale) {
              final isProfitable = sale.netProfit >= 0;
              final profitPercentage = sale.purchasePrice > 0
                  ? (sale.netProfit / sale.purchasePrice) * 100
                  : 0.0;
              final formattedDate =
                  DateFormat('dd.MM.yyyy HH:mm').format(sale.saleDate);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor:
                      isProfitable ? AppColors.brutalGreen : AppColors.errorRed,
                  borderRadius: 14,
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
                                Text(
                                  sale.carTitle,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.tr('history_buyer_day', {
                                    'buyer': sale.buyerName,
                                    'day': '${sale.saleDay}'
                                  }),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          NeoBrutalBadge(
                            text:
                                '${isProfitable ? '+' : ''}${profitPercentage.toStringAsFixed(1)}%',
                            backgroundColor: isProfitable
                                ? AppColors.brutalGreen
                                : AppColors.errorRed,
                            textColor:
                                isProfitable ? Colors.black : Colors.white,
                            fontSize: 11,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF2A3142)
                              : const Color(0xFFE2E8F0)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildPriceColumn(
                              context.tr('history_purchase_price'),
                              CurrencyFormatter.formatShort(sale.purchasePrice),
                              const Color(0xFF64748B)),
                          _buildPriceColumn(
                              context.tr('history_sale_price'),
                              CurrencyFormatter.formatShort(sale.salePrice),
                              isDark ? Colors.white : Colors.black),
                          _buildPriceColumn(
                            context.tr('history_net_profit'),
                            CurrencyFormatter.formatShort(sale.netProfit),
                            isProfitable
                                ? AppColors.brutalGreen
                                : AppColors.errorRed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          formattedDate,
                          style: const TextStyle(
                              fontSize: 10, color: Color(0xFF64748B)),
                        ),
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

  Widget _buildFilterBtn(String label, int index, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilterIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brutalYellow
              : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: isSelected
                ? Colors.black
                : (isDark ? Colors.white70 : const Color(0xFF334155)),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w900, color: valueColor),
        ),
      ],
    );
  }
}
