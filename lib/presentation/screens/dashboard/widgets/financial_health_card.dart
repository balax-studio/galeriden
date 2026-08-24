import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/mega_systems_extensions_model.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class FinancialHealthCard extends StatelessWidget {
  final DealershipModel dealership;
  final VoidCallback onSiftahTapped;

  const FinancialHealthCard({
    super.key,
    required this.dealership,
    required this.onSiftahTapped,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ?? true;

    final totalInventoryValue = dealership.ownedCars.fold<double>(
      0.0,
      (sum, car) => sum + car.estimatedRealValue,
    );
    final totalDebt = dealership.activeLoans.fold<double>(
      0.0,
      (sum, loan) => sum + loan.remainingAmount,
    );

    final grade = HealthGrade.calculate(
      balance: dealership.balance,
      totalDebt: totalDebt,
      totalInventoryValue: totalInventoryValue,
      dailyExpenses: 2500.0,
    );

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(3, 3),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: grade.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: grade.color, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              grade.grade,
              style: TextStyle(
                  color: grade.color,
                  fontWeight: FontWeight.w900,
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BİLANÇO & FİNANSAL SAĞLIK',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  grade.getLocalizedLabel(lang),
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: 'SİFTAH ET',
            icon: Icons.monetization_on_rounded,
            backgroundColor: AppColors.brutalYellow,
            textColor: Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: onSiftahTapped,
          ),
        ],
      ),
    );
  }
}
