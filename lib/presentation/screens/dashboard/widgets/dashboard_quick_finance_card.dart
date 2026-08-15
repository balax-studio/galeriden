import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class DashboardQuickFinanceCard extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardQuickFinanceCard({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final activeLoans = game.activeLoans;
    final totalLoanDebt = activeLoans.fold(0.0, (sum, l) => sum + l.remainingAmount);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeLoans.isNotEmpty ? const Color(0xFFFF7A00) : const Color(0xFF00E575),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  activeLoans.isNotEmpty ? Icons.account_balance_rounded : Icons.savings_rounded,
                  size: 20,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeLoans.isNotEmpty
                        ? 'Aktif Kredi Borcu (${activeLoans.length})'
                        : 'Banka Kredisi Hazır',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeLoans.isNotEmpty
                        ? 'Kalan Borç: ${CurrencyFormatter.formatShort(totalLoanDebt)}'
                        : 'İhtiyaç anında ₺500.000 limitli kredi çek',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          NeoBrutalButton(
            label: activeLoans.isNotEmpty ? 'Yönet' : 'Kredi Çek',
            backgroundColor: activeLoans.isNotEmpty ? const Color(0xFFFF7A00) : palette.primaryColor,
            textColor: Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: () => context.push('/finance'),
          ),
        ],
      ),
    );
  }
}
