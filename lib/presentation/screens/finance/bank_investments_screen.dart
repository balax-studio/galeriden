import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      backgroundColor: p.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'BANKA & MEVDUAT YATIRIMLARI',
            style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Investment Summary Card
            AppGlassContainer(
              padding: const EdgeInsets.all(18),
              borderColor: p.successColor.withValues(alpha: 0.5),
              glowColor: p.successColor.withValues(alpha: 0.15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.account_balance_rounded, color: p.successColor, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('VADELİ MEVDUAT HESABI', style: AppTypography.labelSmall(p.isDark)),
                              Text(
                                '₺${CurrencyFormatter.formatShort(game.balance * 0.15)} Biriken Mevduat',
                                style: AppTypography.titleLarge(p.isDark).copyWith(color: p.successColor, fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.successColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: p.successColor),
                        ),
                        child: const Text(
                          '%24.5 Günlük APY',
                          style: TextStyle(color: AppColors.laserGreen, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Deposit Cash Section
            Text('MEVDUAT YATIR / ÇEK', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            AppDoubleBezelCard(
              accentColor: p.primaryColor,
              outerRadius: 18,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kasa Bakiyenden Mevduat Hesabına Para Aktar', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                  const SizedBox(height: 6),
                  Text('Aktarılan mevduat her oyun gününde faiz getirisi kazandırır.', style: AppTypography.bodyMedium(p.isDark)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _depositController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: p.textPrimaryColor),
                          decoration: InputDecoration(
                            hintText: 'Miktar (₺)',
                            hintStyle: TextStyle(color: p.textSecondaryColor),
                            filled: true,
                            fillColor: p.surfaceBorderColor.withValues(alpha: 0.3),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppTactileButton(
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: p.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Yatır', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Credit Score & Extended Credit Line Card
            Text('KREDİ SCORE & LİMİT YÜKSELTME', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            AppGlassContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.verified_user_rounded, color: Colors.blueAccent, size: 28),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kredi Skoru: AAA (Mükemmel)', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                              Text('Mevcut Banka Kredi Limiti: ₺15,000,000', style: AppTypography.bodyMedium(p.isDark)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Limiti ₺25.000.000 Yap:', style: AppTypography.bodyMedium(p.isDark)),
                      AppTactileButton(
                        onPressed: () {
                          NotificationService.showSuccess(context, 'Kredi Limiti Başarıyla ₺25,000,000 Seviyesine Yükseltildi!');
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Limiti Yükselt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
