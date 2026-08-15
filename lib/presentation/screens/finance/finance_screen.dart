import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'FİNANS & TAHSİLAT MERKEZİ',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Bank Investments Nav Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.brutalGreen,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black, width: 1.5),
                        ),
                        child: const Icon(Icons.account_balance_rounded, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vadeli Mevduat & Kredi Skoru',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Faiz Getirisi, Altın/Döviz & Limit Artırma',
                              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: 'YÖNET',
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () => context.push('/bank-investments'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Summary Receivables Cards
          _buildSummary(isDark, game),
          const SizedBox(height: 16),

          // 3. Active Installments
          Text(
            'AKTİF SENETLİ / TAKSİTLİ SÖZLEŞMELER (${game.activeInstallments.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          if (game.activeInstallments.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: const Center(
                child: Text(
                  'Şu an aktif vadeli senet sözleşmeniz bulunmuyor.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...game.activeInstallments.map((c) => _buildInstallmentCard(isDark, c)),

          const SizedBox(height: 16),

          // 4. Pending Cheques
          Text(
            'BEKLEYEN TİCARİ ÇEKLER (${game.activeCheques.length})',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          if (game.activeCheques.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: const Center(
                child: Text(
                  'Şu an bekleyen şirket çeki bulunmuyor.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...game.activeCheques.map((ch) => _buildChequeCard(isDark, ch, game.currentDay)),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark, DealershipModel game) {
    final double totalInstallmentReceivables =
        game.activeInstallments.fold(0.0, (sum, c) => sum + (c.totalAmount - c.paidAmount));
    final double totalChequeReceivables = game.activeCheques.fold(0.0, (sum, c) => sum + c.amount);

    return Row(
      children: [
        Expanded(
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeoBrutalBadge(
                  text: 'SENET ALACAĞI',
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatShort(totalInstallmentReceivables),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeoBrutalBadge(
                  text: 'ÇEK ALACAĞI',
                  backgroundColor: AppColors.brutalOrange,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatShort(totalChequeReceivables),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalOrange),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentCard(bool isDark, InstallmentContract contract) {
    final double progress = (contract.paidAmount / contract.totalAmount).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
                Text(
                  contract.carModelName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                ),
                NeoBrutalBadge(
                  text: '${contract.daysUntilNextPayment} Gün Kaldı',
                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                  textColor: isDark ? Colors.white : Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tahsil: ${CurrencyFormatter.formatShort(contract.paidAmount)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                ),
                Text(
                  'Kalan: ${CurrencyFormatter.formatShort(contract.totalAmount - contract.paidAmount)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.brutalOrange),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.brutalGreen,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${contract.paidInstallments}/${contract.totalInstallments} Taksit Ödendi (Aylık: ${CurrencyFormatter.formatShort(contract.installmentAmount)})',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChequeCard(bool isDark, Cheque cheque, int currentDay) {
    final int daysLeft = cheque.dueDay - currentDay;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brutalOrange,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(Icons.receipt_rounded, color: Colors.black, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cheque.carModelName,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tutar: ${CurrencyFormatter.formatShort(cheque.amount)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                  ),
                ],
              ),
            ),
            NeoBrutalBadge(
              text: daysLeft > 0 ? '$daysLeft Gün Vade' : 'Bugün Tahsil',
              backgroundColor: daysLeft <= 1 ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
              textColor: Colors.black,
              fontSize: 10,
            ),
          ],
        ),
      ),
    );
  }
}
