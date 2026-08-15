import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
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
                NeoBrutalButton(
                  label: isMaxCreditLimit
                      ? 'MAKSİMUM KREDİ LİMİTİNDESİNİZ (₺25.000.000)'
                      : 'LİMİTİ ₺25.000.000 SEVİYESİNE YÜKSELT (Ücret: ₺50.000)',
                  icon: isMaxCreditLimit ? Icons.check_circle_rounded : Icons.trending_up_rounded,
                  backgroundColor: isMaxCreditLimit ? (isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)) : AppColors.brutalYellow,
                  textColor: isMaxCreditLimit ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
                  fontSize: 11,
                  fullWidth: true,
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
              ],
            ),
          ),
        ],
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
