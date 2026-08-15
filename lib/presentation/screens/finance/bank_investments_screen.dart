import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class BankInvestmentsScreen extends ConsumerStatefulWidget {
  const BankInvestmentsScreen({super.key});

  @override
  ConsumerState<BankInvestmentsScreen> createState() => _BankInvestmentsScreenState();
}

class _BankInvestmentsScreenState extends ConsumerState<BankInvestmentsScreen> {
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _withdrawController = TextEditingController();

  @override
  void dispose() {
    _depositController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  void _setDepositPercentage(double ratio, double balance) {
    final amount = (balance * ratio).floorToDouble();
    _depositController.text = amount.toStringAsFixed(0);
  }

  void _setWithdrawPercentage(double ratio, double depositBalance) {
    final amount = (depositBalance * ratio).floorToDouble();
    _withdrawController.text = amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final isMaxCreditLimit = game.bankCreditLimit >= 25000000.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'BANKA & MEVDUAT YATIRIMLARI',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Time Deposit Header Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
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
                            child: const Icon(Icons.account_balance_rounded, color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VADELİ MEVDUAT HESABI',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  CurrencyFormatter.format(game.bankDepositBalance),
                                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const NeoBrutalBadge(
                      text: '%24.5 Günlük APY',
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 10.5,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Kasa Nakit Bakiyen:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                      Text(
                        CurrencyFormatter.format(game.balance),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Deposit Cash Card (YATIR)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_downward_rounded, size: 16, color: AppColors.brutalGreen),
                    const SizedBox(width: 6),
                    const Text(
                      'MEVDUAT HESABINA PARA YATIR',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kasandaki nakiti faize yatırarak her gün düzenli bileşik getiri kazan.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                // Quick Percentages
                Row(
                  children: [
                    _buildPercentageChip('%25', () => _setDepositPercentage(0.25, game.balance), isDark),
                    const SizedBox(width: 6),
                    _buildPercentageChip('%50', () => _setDepositPercentage(0.50, game.balance), isDark),
                    const SizedBox(width: 6),
                    _buildPercentageChip('TÜMÜ (%100)', () => _setDepositPercentage(1.0, game.balance), isDark),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Yatırılacak Tutar (₺)',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.brutalGreen, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: 'YATIR',
                      icon: Icons.savings_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      onPressed: () {
                        final amount = double.tryParse(_depositController.text) ?? 0.0;
                        if (amount <= 0 || amount > game.balance) {
                          NotificationService.showError(context, 'Geçersiz miktar veya yetersiz kasa bakiyesi!');
                          return;
                        }

                        final success = ref.read(gameProvider.notifier).depositToBank(amount);
                        if (success) {
                          _depositController.clear();
                          NotificationService.showSuccess(
                            context,
                            '${CurrencyFormatter.formatShort(amount)} Vadeli Mevduat Hesabına Yatırıldı!',
                          );
                        } else {
                          NotificationService.showError(context, 'İşlem başarısız oldu.');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Withdraw Cash Card (ÇEK)
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.arrow_upward_rounded, size: 16, color: AppColors.brutalOrange),
                    const SizedBox(width: 6),
                    const Text(
                      'MEVDUATTAN KASAYA GERİ ÇEK',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bankada biriken ana para ve faiz kazancını dilediğin zaman anında kasana aktar.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                // Quick Percentages
                Row(
                  children: [
                    _buildPercentageChip('%25', () => _setWithdrawPercentage(0.25, game.bankDepositBalance), isDark),
                    const SizedBox(width: 6),
                    _buildPercentageChip('%50', () => _setWithdrawPercentage(0.50, game.bankDepositBalance), isDark),
                    const SizedBox(width: 6),
                    _buildPercentageChip('TÜMÜ (%100)', () => _setWithdrawPercentage(1.0, game.bankDepositBalance), isDark),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _withdrawController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Çekilecek Tutar (₺)',
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.brutalOrange, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: 'ÇEK',
                      icon: Icons.payments_rounded,
                      backgroundColor: AppColors.brutalOrange,
                      textColor: Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      onPressed: () {
                        final amount = double.tryParse(_withdrawController.text) ?? 0.0;
                        if (amount <= 0 || amount > game.bankDepositBalance) {
                          NotificationService.showError(context, 'Geçersiz miktar veya yetersiz banka mevduatı!');
                          return;
                        }

                        final success = ref.read(gameProvider.notifier).withdrawFromBank(amount);
                        if (success) {
                          _withdrawController.clear();
                          NotificationService.showSuccess(
                            context,
                            '${CurrencyFormatter.formatShort(amount)} Kasa Hesabına Çekildi!',
                          );
                        } else {
                          NotificationService.showError(context, 'İşlem başarısız oldu.');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Credit Score & Line Upgrade
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kredi Skoru: AAA (Mükemmel)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Mevcut Banka Kredi Limiti: ${CurrencyFormatter.format(game.bankCreditLimit)}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        label: isMaxCreditLimit
                            ? 'LİMİT MAKSİMUM'
                            : 'LİMİTİ ₺25M YAP (₺50.000)',
                        icon: isMaxCreditLimit ? Icons.check_circle_rounded : Icons.trending_up_rounded,
                        backgroundColor: isMaxCreditLimit ? (isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)) : AppColors.brutalYellow,
                        textColor: isMaxCreditLimit ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
                        fontSize: 10.5,
                        onPressed: isMaxCreditLimit
                            ? null
                            : () {
                                if (game.balance < 50000.0) {
                                  NotificationService.showError(context, 'Yetersiz bakiye! İşlem için ₺50,000 gereklidir.');
                                  return;
                                }

                                final success = ref.read(gameProvider.notifier).upgradeCreditLimit(
                                  newLimit: 25000000.0,
                                  fee: 50000.0,
                                );

                                if (success) {
                                  NotificationService.showSuccess(
                                    context,
                                    'Tebrikler! Kredi Limitin Başarıyla ₺25,000,000 Seviyesine Yükseltildi.',
                                  );
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeoBrutalButton(
                        label: 'KREDİ KULLAN',
                        icon: Icons.attach_money_rounded,
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 10.5,
                        onPressed: game.activeLoans.length >= 3
                            ? () => NotificationService.showError(context, 'En fazla 3 aktif kredi kullanabilirsiniz!')
                            : () => _showTakeLoanSheet(context, game, isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Active Bank Loans Section
          Text(
            'AKTİF BANKA KREDİLERİ & BORÇLAR (${game.activeLoans.length}/3)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          if (game.activeLoans.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: const Center(
                child: Text(
                  'Aktif banka krediniz bulunmuyor. Acil nakit ihtiyacında kredi kullanabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...game.activeLoans.map((loan) {
              final progress = (1.0 - (loan.remainingAmount / loan.totalRepayment)).clamp(0.0, 1.0);
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
                          Row(
                            children: [
                              const Icon(Icons.account_balance_rounded, size: 18, color: Color(0xFF38BDF8)),
                              const SizedBox(width: 6),
                              Text(
                                loan.bankName,
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          NeoBrutalBadge(
                            text: '${loan.remainingInstallments}/${loan.totalInstallments} Taksit Kaldı',
                            backgroundColor: AppColors.brutalOrange,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kalan Borç: ${CurrencyFormatter.formatShort(loan.remainingAmount)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                          ),
                          Text(
                            'Aylık Taksit: ${CurrencyFormatter.formatShort(loan.monthlyPayment)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: isDark ? Colors.white12 : Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brutalGreen),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Faiz: %${(loan.interestRate * 100).toStringAsFixed(1)} • Anapara: ${CurrencyFormatter.formatShort(loan.principalAmount)}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          NeoBrutalButton(
                            label: 'TAKSİT ÖDE',
                            icon: Icons.payments_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            onPressed: () {
                              if (game.balance < loan.monthlyPayment) {
                                NotificationService.showError(
                                  context,
                                  'Yetersiz Bakiye! ${CurrencyFormatter.format(loan.monthlyPayment)} gerekli.',
                                );
                                return;
                              }

                              final success = ref.read(gameProvider.notifier).payLoanInstallment(loan.id);
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  '${loan.bankName} taksiti başarıyla ödendi!',
                                );
                              }
                            },
                          ),
                        ],
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

  void _showTakeLoanSheet(BuildContext context, DealershipModel game, bool isDark) {
    double selectedAmount = 100000.0.clamp(10000.0, game.bankCreditLimit);
    int selectedMonths = 6;
    String selectedBank = 'Galeri Finansbank';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final baseInterestRate = selectedMonths == 3 ? 0.10 : (selectedMonths == 6 ? 0.18 : 0.28);
            final totalRepayment = selectedAmount * (1.0 + baseInterestRate);
            final monthlyPayment = totalRepayment / selectedMonths;

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'BANKA KREDİSİ KULLAN',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kredi Tutarı: ${CurrencyFormatter.format(selectedAmount)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [50000.0, 100000.0, 250000.0, 500000.0, 1000000.0]
                        .where((amt) => amt <= game.bankCreditLimit)
                        .map((amt) {
                      final isSel = selectedAmount == amt;
                      return InkWell(
                        onTap: () => setSheetState(() => selectedAmount = amt),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.4),
                          ),
                          child: Text(
                            CurrencyFormatter.formatShort(amt),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSel ? Colors.black : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vade Seçimi:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildMonthOption(3, '3 Ay (%10 Faiz)', selectedMonths, isDark, (m) => setSheetState(() => selectedMonths = m)),
                      const SizedBox(width: 8),
                      _buildMonthOption(6, '6 Ay (%18 Faiz)', selectedMonths, isDark, (m) => setSheetState(() => selectedMonths = m)),
                      const SizedBox(width: 8),
                      _buildMonthOption(12, '12 Ay (%28 Faiz)', selectedMonths, isDark, (m) => setSheetState(() => selectedMonths = m)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Aylık Ödeme:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            Text(CurrencyFormatter.format(monthlyPayment), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brutalGreen)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Toplam Geri Ödeme:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                            Text(CurrencyFormatter.format(totalRepayment), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  NeoBrutalButton(
                    label: 'KREDİYİ KULLAN (${CurrencyFormatter.formatShort(selectedAmount)})',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      final success = ref.read(gameProvider.notifier).takeBankLoan(
                        bankName: selectedBank,
                        amount: selectedAmount,
                        months: selectedMonths,
                      );
                      Navigator.pop(ctx);
                      if (success) {
                        NotificationService.showSuccess(
                          context,
                          '₺${CurrencyFormatter.format(selectedAmount)} kredi hesabınıza aktarıldı!',
                        );
                      } else {
                        NotificationService.showError(
                          context,
                          'Kredi kullanılamadı! Limit aşıldı veya maksimum kredi sayısına ulaşıldı.',
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMonthOption(int months, String label, int selectedMonths, bool isDark, Function(int) onSelect) {
    final isSel = selectedMonths == months;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(months),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSel ? AppColors.brutalGreen : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            '$months Ay',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isSel ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPercentageChip(String label, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 1.2),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
