import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
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

  @override
  void dispose() {
    _depositController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'BANKA & MEVDUAT YATIRIMLARI',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
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
                    Row(
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
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VADELİ MEVDUAT HESABI',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                            ),
                            Text(
                              '₺${CurrencyFormatter.formatShort(game.balance * 0.15)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const NeoBrutalBadge(
                      text: '%24.5 Günlük APY',
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 10.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Deposit Cash Input Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'MEVDUAT HESABINA AKTAR',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Kasa bakiyenden mevduata para aktararak günlük faiz geliri kazanabilirsin.',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _depositController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Miktar (₺)',
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
                            borderSide: const BorderSide(color: AppColors.brutalYellow, width: 2),
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
                          NotificationService.showError(context, 'Geçersiz miktar veya yetersiz bakiye!');
                          return;
                        }

                        ref.read(gameProvider.notifier).deductBalance(amount);
                        _depositController.clear();
                        NotificationService.showSuccess(
                          context,
                          '₺${CurrencyFormatter.formatShort(amount)} Vadeli Mevduat Hesabına Yatırıldı!',
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Credit Score & Line Upgrade
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Kredi Skoru: AAA (Mükemmel)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Mevcut Banka Kredi Limiti: ₺15,000,000',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                NeoBrutalButton(
                  label: 'LİMİTİ ₺25.000.000 SEVİYESİNE YÜKSELT',
                  icon: Icons.trending_up_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 11.5,
                  fullWidth: true,
                  onPressed: () {
                    NotificationService.showSuccess(context, 'Kredi Limiti Başarıyla ₺25,000,000 Seviyesine Yükseltildi!');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
