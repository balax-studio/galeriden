import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FİNANS & TAHSİLAT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(p, game),
            const SizedBox(height: 24),
            Text('AKTİF TAKSİTLİ SÖZLEŞMELER', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),
            if (game.activeInstallments.isEmpty)
              Text('Şu an aktif taksitli satışınız bulunmuyor.', style: AppTypography.bodyMedium(p.isDark).copyWith(color: p.textSecondaryColor)),
            ...game.activeInstallments.map((contract) => _buildInstallmentCard(p, contract)),
            const SizedBox(height: 24),
            Text('BEKLEYEN ÇEKLER', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),
            if (game.activeCheques.isEmpty)
              Text('Şu an bekleyen çekiniz bulunmuyor.', style: AppTypography.bodyMedium(p.isDark).copyWith(color: p.textSecondaryColor)),
            ...game.activeCheques.map((cheque) => _buildChequeCard(p, cheque, game.currentDay)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(dynamic p, dynamic game) {
    double totalInstallmentReceivables = game.activeInstallments.fold(0.0, (sum, c) => sum + (c.totalAmount - c.paidAmount));
    double totalChequeReceivables = game.activeCheques.fold(0.0, (sum, c) => sum + c.amount);

    return Row(
      children: [
        Expanded(
          child: AppGlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.request_quote_rounded, color: p.primaryColor, size: 28),
                const SizedBox(height: 8),
                Text('Taksit Alacakları', style: AppTypography.labelSmall(p.isDark)),
                const SizedBox(height: 4),
                Text('₺${CurrencyFormatter.formatShort(totalInstallmentReceivables)}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppGlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.receipt_long_rounded, color: Colors.orangeAccent, size: 28),
                const SizedBox(height: 8),
                Text('Çek Alacakları', style: AppTypography.labelSmall(p.isDark)),
                const SizedBox(height: 4),
                Text('₺${CurrencyFormatter.formatShort(totalChequeReceivables)}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentCard(dynamic p, dynamic contract) {
    double progress = contract.paidAmount / contract.totalAmount;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.surfaceBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(contract.carModelName, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
              Text('Sonraki: Gün ${contract.nextPaymentDay}', style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ödenen: ₺${CurrencyFormatter.formatShort(contract.paidAmount)}', style: AppTypography.bodyMedium(p.isDark)),
              Text('Kalan: ₺${CurrencyFormatter.formatShort(contract.totalAmount - contract.paidAmount)}', style: AppTypography.bodyMedium(p.isDark)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: p.surfaceBorderColor,
              valueColor: AlwaysStoppedAnimation<Color>(p.primaryColor),
            ),
          ),
          const SizedBox(height: 8),
          Text('${contract.paidInstallments}/${contract.totalInstallments} Taksit Ödendi', style: AppTypography.labelSmall(p.isDark)),
        ],
      ),
    );
  }

  Widget _buildChequeCard(dynamic p, dynamic cheque, int currentDay) {
    int daysLeft = cheque.dueDay - currentDay;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.surfaceBorderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_rounded, color: Colors.orangeAccent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cheque.carModelName, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                const SizedBox(height: 2),
                Text('Tutar: ₺${CurrencyFormatter.formatShort(cheque.amount)}', style: AppTypography.bodyMedium(p.isDark)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Vade', style: AppTypography.labelSmall(p.isDark)),
              Text(daysLeft > 0 ? '$daysLeft Gün' : 'Bugün', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14, color: daysLeft <= 1 ? p.warningColor : p.primaryColor)),
            ],
          ),
        ],
      ),
    );
  }
}
