import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../../domain/usecases/repair_engine.dart';

class RepairTierSelectionSheet extends StatelessWidget {
  final CarModel car;
  final String repairType;
  final double baseCost;
  final Function(RepairTier tier, double cost) onTierSelected;

  const RepairTierSelectionSheet({
    super.key,
    required this.car,
    required this.repairType,
    required this.baseCost,
    required this.onTierSelected,
  });

  static void show({
    required BuildContext context,
    required CarModel car,
    required String repairType,
    required double baseCost,
    required Function(RepairTier tier, double cost) onTierSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return RepairTierSelectionSheet(
          car: car,
          repairType: repairType,
          baseCost: baseCost,
          onTierSelected: (tier, cost) {
            Navigator.pop(ctx);
            onTierSelected(tier, cost);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String titleText = repairType == 'engine'
        ? context.tr('repair_tier_engine_title')
        : (repairType == 'transmission'
            ? context.tr('repair_tier_transmission_title')
            : (repairType == 'ecu'
                ? context.tr('repair_tier_ecu_title')
                : (repairType == 'chassis'
                    ? context.tr('repair_tier_chassis_title')
                    : context.tr('repair_tier_body_title'))));

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(18),
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
                  child: Text(
                titleText,
                style: const TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w900),
              )),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTierOption(
            title: context.tr('repair_tier_apprentice_title'),
            subtitle: context.tr('repair_tier_apprentice_desc'),
            cost: baseCost * 0.55,
            successRate: '%68',
            color: const Color(0xFFFF7A00),
            isDark: isDark,
            onTap: () => onTierSelected(RepairTier.apprentice, baseCost * 0.55),
          ),
          const SizedBox(height: 8),
          _buildTierOption(
            title: context.tr('repair_tier_journeyman_title'),
            subtitle: context.tr('repair_tier_journeyman_desc'),
            cost: baseCost * 1.0,
            successRate: '%88',
            color: const Color(0xFF38BDF8),
            isDark: isDark,
            onTap: () => onTierSelected(RepairTier.journeyman, baseCost * 1.0),
          ),
          const SizedBox(height: 8),
          _buildTierOption(
            title: context.tr('repair_tier_master_title'),
            subtitle: context.tr('repair_tier_master_desc'),
            cost: baseCost * 1.75,
            successRate: '%100',
            color: const Color(0xFF00E575),
            isDark: isDark,
            onTap: () => onTierSelected(RepairTier.master, baseCost * 1.75),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  ),
);
}

  Widget _buildTierOption({
    required String title,
    required String subtitle,
    required double cost,
    required String successRate,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w900),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          successRate,
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  CurrencyFormatter.formatShort(cost),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.brutalGreen),
                  textAlign: TextAlign.end,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
