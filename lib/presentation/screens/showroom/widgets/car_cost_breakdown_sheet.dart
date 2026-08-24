import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class CarCostBreakdownSheet extends StatelessWidget {
  final CarModel car;

  const CarCostBreakdownSheet({super.key, required this.car});

  static void show(BuildContext context, CarModel car) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CarCostBreakdownSheet(car: car),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate itemized investments
    final purchaseCost = car.currentPurchasePrice > 0
        ? car.currentPurchasePrice
        : car.estimatedRealValue * 0.85;

    double detailingCost = 0;
    final List<Map<String, dynamic>> extraCosts = [];

    if (car.hasScent) {
      detailingCost += 250;
      extraCosts.add({'title': context.tr('cost_item_scent'), 'cost': 250.0});
    }
    if (car.hasRestoredHeadlights) {
      detailingCost += 850;
      extraCosts
          .add({'title': context.tr('cost_item_headlight'), 'cost': 850.0});
    }
    if (car.hasIronDecon) {
      detailingCost += 450;
      extraCosts
          .add({'title': context.tr('cost_item_iron_decon'), 'cost': 450.0});
    }
    if (car.hasPdrRepaired) {
      detailingCost += 3200;
      extraCosts.add({'title': context.tr('cost_item_pdr'), 'cost': 3200.0});
    }
    if (car.hasTuvturkCertified) {
      detailingCost += 1500;
      extraCosts
          .add({'title': context.tr('cost_item_tuvturk'), 'cost': 1500.0});
    }
    if (car.isWashed) {
      detailingCost += 250;
      extraCosts.add({'title': context.tr('cost_item_wash'), 'cost': 250.0});
    }
    if (car.isPolished) {
      detailingCost += 2500;
      extraCosts.add({'title': context.tr('cost_item_polish'), 'cost': 2500.0});
    }
    if (car.isCeramicCoated) {
      detailingCost += 8000;
      extraCosts
          .add({'title': context.tr('cost_item_ceramic'), 'cost': 8000.0});
    }

    final totalCost = purchaseCost + detailingCost;
    final targetPrice =
        car.isListed ? car.listingPrice : car.estimatedRealValue * 1.10;
    final netProfit = targetPrice - totalCost;
    final roiPercent = totalCost > 0 ? (netProfit / totalCost) * 100 : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: const Icon(Icons.calculate_rounded,
                    color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.modelName}',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.tr('cost_breakdown_subtitle'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Itemized Cost Card
          NeoBrutalCard(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            borderRadius: 12,
            borderWidth: 2.0,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _buildCostRow(context.tr('cost_item_purchase_price'),
                    purchaseCost, isDark),
                if (extraCosts.isNotEmpty) ...[
                  const Divider(height: 14),
                  ...extraCosts.map((item) => _buildCostRow(
                      item['title'] as String, item['cost'] as double, isDark,
                      isSubItem: true)),
                ],
                const Divider(height: 16),
                _buildCostRow(context.tr('cost_total_cost'), totalCost, isDark,
                    isBold: true),
                const SizedBox(height: 6),
                _buildCostRow(
                    context.tr('cost_target_price'), targetPrice, isDark,
                    isHighlight: true),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Summary ROI Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: netProfit >= 0
                  ? const Color(0xFF00E575).withValues(alpha: 0.15)
                  : const Color(0xFFEF4444).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: netProfit >= 0
                    ? const Color(0xFF00E575)
                    : const Color(0xFFEF4444),
                width: 2.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('cost_estimated_net_profit'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: netProfit >= 0
                            ? const Color(0xFF00E575)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatShort(netProfit),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: netProfit >= 0
                            ? const Color(0xFF00E575)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: '%${roiPercent.toStringAsFixed(1)} ROI',
                  backgroundColor: netProfit >= 0
                      ? const Color(0xFF00E575)
                      : const Color(0xFFEF4444),
                  textColor: Colors.black,
                  fontSize: 11,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          NeoBrutalButton(
            label: context.tr('ok_button'),
            icon: Icons.check_rounded,
            backgroundColor: const Color(0xFFFFDE59),
            textColor: Colors.black,
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, double amount, bool isDark,
      {bool isBold = false, bool isHighlight = false, bool isSubItem = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isSubItem ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Text(
            isSubItem ? '  ↳ $title' : title,
            style: TextStyle(
              fontSize: isBold || isHighlight ? 12 : 11,
              fontWeight:
                  isBold || isHighlight ? FontWeight.w900 : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF38BDF8)
                  : (isDark
                      ? (isSubItem ? Colors.white60 : Colors.white)
                      : (isSubItem ? Colors.black54 : Colors.black87)),
            ),
          )),
          Expanded(
              child: Text(
            CurrencyFormatter.formatShort(amount),
            style: TextStyle(
              fontSize: isBold || isHighlight ? 12.5 : 11,
              fontWeight:
                  isBold || isHighlight ? FontWeight.w900 : FontWeight.w700,
              color: isHighlight
                  ? const Color(0xFF38BDF8)
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          )),
        ],
      ),
    );
  }
}
