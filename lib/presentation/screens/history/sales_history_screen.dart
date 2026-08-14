import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/sale_record_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

class SalesHistoryScreen extends ConsumerStatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  ConsumerState<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends ConsumerState<SalesHistoryScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Profitable, 2: Loss/Break-even

  @override
  Widget build(BuildContext meContext) {
    final game = ref.watch(gameProvider);
    final history = game.salesHistory;

    final totalRevenue = history.fold<double>(0.0, (sum, s) => sum + s.salePrice);
    final totalProfit = game.totalProfit;
    final avgProfit = history.isNotEmpty ? totalProfit / history.length : 0.0;

    List<SaleRecordModel> filteredHistory = history;
    if (_selectedFilterIndex == 1) {
      filteredHistory = history.where((s) => s.netProfit > 0).toList();
    } else if (_selectedFilterIndex == 2) {
      filteredHistory = history.where((s) => s.netProfit <= 0).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildAppBar(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KPI Overview Bento Cards
                    _buildOverviewMetrics(
                      carsSold: game.carsSold,
                      totalRevenue: totalRevenue,
                      totalProfit: totalProfit,
                      avgProfit: avgProfit,
                    ),
                    const SizedBox(height: 20),

                    // Filter Tabs & Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Geçmiş Satış Kayıtları',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _buildFilterChip('Tümü (${history.length})', 0),
                              const SizedBox(width: 4),
                              _buildFilterChip('Kârlı', 1),
                              const SizedBox(width: 4),
                              _buildFilterChip('Zarar/Maliyet', 2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Sales History List
                    if (filteredHistory.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredHistory.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final item = filteredHistory[index];
                          return _buildSaleCard(item);
                        },
                      ),

                    const SizedBox(height: 24),
                    // Deliveries & Workshop Activity Summary
                    _buildWorkshopActivitySection(game),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          AppTactileButton(
            onPressed: () => context.pop(),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SATIŞ VE FİNANSAL GEÇMİŞ',
                style: TextStyle(
                  color: AppColors.primaryAmber,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Galeri Ticaret Dökümü',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryAmber.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.history_edu, color: AppColors.primaryAmber, size: 16),
                SizedBox(width: 6),
                Text(
                  'Kayıtlı',
                  style: TextStyle(
                    color: AppColors.primaryAmber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewMetrics({
    required int carsSold,
    required double totalRevenue,
    required double totalProfit,
    required double avgProfit,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Toplam Satılan',
                value: '$carsSold Araç',
                icon: Icons.directions_car,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Toplam Hasılat',
                value: CurrencyFormatter.format(totalRevenue),
                icon: Icons.account_balance_wallet,
                color: Colors.amberAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Net Toplam Kâr',
                value: CurrencyFormatter.format(totalProfit),
                icon: Icons.trending_up,
                color: totalProfit >= 0 ? Colors.greenAccent : Colors.redAccent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricCard(
                title: 'Araç Başı Kâr',
                value: CurrencyFormatter.format(avgProfit),
                icon: Icons.query_stats,
                color: avgProfit >= 0 ? AppColors.primaryAmber : Colors.orangeAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return AppGlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      borderColor: color.withValues(alpha: 0.25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAmber : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSaleCard(SaleRecordModel sale) {
    final isProfitable = sale.netProfit >= 0;
    final profitPercentage = sale.purchasePrice > 0
        ? (sale.netProfit / sale.purchasePrice) * 100
        : 0.0;
    final formattedDate = DateFormat('dd.MM.yyyy HH:mm').format(sale.saleDate);

    return AppGlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      borderColor: isProfitable
          ? Colors.green.withValues(alpha: 0.3)
          : Colors.red.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isProfitable
                      ? Colors.green.withValues(alpha: 0.15)
                      : Colors.red.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isProfitable ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isProfitable ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.carTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Alıcı: ${sale.buyerName} • Gün ${sale.saleDay}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isProfitable ? Colors.green : Colors.red).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (isProfitable ? Colors.green : Colors.red).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  '${isProfitable ? '+' : ''}${profitPercentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isProfitable ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceDetail('Alış Fiyatı', CurrencyFormatter.format(sale.purchasePrice)),
              _buildPriceDetail('Satış Fiyatı', CurrencyFormatter.format(sale.salePrice)),
              _buildPriceDetail(
                'Net Kâr',
                CurrencyFormatter.format(sale.netProfit),
                valueColor: isProfitable ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              formattedDate,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetail(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return AppGlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: 16,
      child: Center(
        child: Column(
          children: [
            Icon(Icons.directions_car_outlined, color: Colors.white.withValues(alpha: 0.3), size: 48),
            const SizedBox(height: 12),
            Text(
              'Henüz kayıtlı satış bulunmuyor',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Araç alım satımı yaptıkça geçmişiniz buraya eklenecektir.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkshopActivitySection(DealershipModel game) {
    final pendingCount = game.pendingOrders.length;

    return AppGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: AppColors.primaryAmber.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.build_circle, color: AppColors.primaryAmber, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Atölye & Parça Sipariş Durumu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pendingCount > 0
                      ? Colors.amber.withValues(alpha: 0.2)
                      : Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pendingCount > 0 ? '$pendingCount Parça Yolda' : 'Atölye Hazır',
                  style: TextStyle(
                    color: pendingCount > 0 ? Colors.amberAccent : Colors.greenAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            pendingCount > 0
                ? 'Sipariş verilen yedek parçaların kargo teslimat süreleri Oyun Takvimi ile senkronize ilerler.'
                : 'Şu anda kargoda bekleyen yedek parça siparişi bulunmuyor.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
