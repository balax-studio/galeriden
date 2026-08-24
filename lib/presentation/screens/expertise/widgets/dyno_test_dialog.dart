import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/mega_systems_extensions_model.dart';
import '../../../widgets/neo_brutal_card.dart';

class DynoTestDialog extends StatelessWidget {
  final CarModel car;
  final Function(ExpertisePackageTier tier) onPackageSelected;

  const DynoTestDialog({
    super.key,
    required this.car,
    required this.onPackageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final dynoPreview = DynoTestReport.generate(car);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: const Color(0xFF0F172A),
        borderColor: const Color(0xFF333B4F),
        borderRadius: 12,
        borderWidth: 2.5,
        shadowOffset: const Offset(4, 4),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.brutalGreen,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF333B4F), width: 2.0),
                    ),
                    child: const Icon(Icons.speed_rounded,
                        color: Colors.black, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('dyno_dialog_title'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: const Color(0xFF141721),
                borderColor: const Color(0xFF333B4F),
                borderRadius: 10,
                borderWidth: 2.0,
                shadowOffset: const Offset(2, 2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildGaugeMetric(
                          label: context.tr('dyno_measured_power'),
                          value: '${dynoPreview.measuredHp} HP',
                          sub: context.tr('dyno_factory_power',
                              {'val': dynoPreview.factoryHp}),
                          color: AppColors.brutalGreen,
                        ),
                        Container(
                            width: 1.5,
                            height: 45,
                            color: const Color(0xFF333B4F)),
                        _buildGaugeMetric(
                          label: context.tr('dyno_measured_torque'),
                          value: '${dynoPreview.measuredTorque} Nm',
                          sub: context.tr('dyno_factory_torque',
                              {'val': dynoPreview.factoryTorque}),
                          color: const Color(0xFF38BDF8),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: dynoPreview.healthPercentage / 100.0,
                      backgroundColor: const Color(0xFF1E2330),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        dynoPreview.healthPercentage >= 85
                            ? AppColors.brutalGreen
                            : (dynoPreview.healthPercentage >= 65
                                ? AppColors.brutalYellow
                                : AppColors.errorRed),
                      ),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('dyno_efficiency_health', {
                        'val': dynoPreview.healthPercentage.toStringAsFixed(1)
                      }),
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  context.tr('dyno_select_package'),
                  style: const TextStyle(
                      color: AppColors.brutalYellow,
                      fontWeight: FontWeight.w900,
                      fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              ...ExpertisePackageTier.values.map((tier) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      onPackageSelected(tier);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: const Color(0xFF141721),
                      borderColor: tier.color,
                      borderRadius: 10,
                      borderWidth: 2.0,
                      shadowOffset: const Offset(3, 3),
                      child: Row(
                        children: [
                          Icon(tier.icon, color: tier.color, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tier.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12.5),
                                ),
                                Text(
                                  tier.description,
                                  style: const TextStyle(
                                      color: Color(0xFF94A3B8), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(tier.cost),
                            style: TextStyle(
                                color: tier.color,
                                fontWeight: FontWeight.w900,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGaugeMetric({
    required String label,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(sub,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
      ],
    );
  }
}
