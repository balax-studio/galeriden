import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../providers/game/game_finance_mixin.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  void _showFactoringSheet(BuildContext context, WidgetRef ref, Cheque cheque) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const discountRate = 0.08;
    final double netCash = cheque.calculateFactoringCash(discountRate: discountRate);
    final double fee = cheque.calculateFactoringDiscount(discountRate: discountRate);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ÇEK KIRDIRMA / FAKTORİNG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                  NeoBrutalBadge(text: '%8 Komisyon', backgroundColor: AppColors.brutalYellow, textColor: Colors.black, fontSize: 10),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${cheque.customerName} adına kayıtlı ${cheque.daysUntilDue} gün vadeli ${CurrencyFormatter.format(cheque.amount)} tutarındaki çeki beklemeden anında nakde çevirebilirsin.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Çek Nominal Tutarı:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(CurrencyFormatter.format(cheque.amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Faktoring & İskonto Kesintisi (%8):', style: TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                        Text('-${CurrencyFormatter.format(fee)}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kasaya Geçecek Net Nakit:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        Text(
                          CurrencyFormatter.format(netCash),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: 'ÇEKİ KIRDIR & NAKDİ AL',
                icon: Icons.currency_exchange_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  final success = ref.read(gameProvider.notifier).cashOutChequeEarly(cheque.id, discountRate: discountRate);
                  Navigator.pop(ctx);
                  if (success) {
                    NotificationService.showSuccess(context, '${CurrencyFormatter.format(netCash)} kasaya aktarıldı!');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showInstallmentSettlementSheet(BuildContext context, WidgetRef ref, InstallmentContract contract) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const discountRate = 0.05;
    final double netCash = contract.calculateEarlySettlementCash(discountRate: discountRate);
    final double discount = contract.calculateEarlySettlementDiscount(discountRate: discountRate);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SENET ERKEN KAPAMA İNDİRİMİ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  NeoBrutalBadge(text: '%5 İskonto', backgroundColor: AppColors.brutalGreen, textColor: Colors.black, fontSize: 10),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '${contract.customerName} adına kalan ${contract.totalInstallments - contract.paidInstallments} taksidi tek seferde peşin tahsil etmek için müşteriye %5 erken kapama indirimi sunulur.',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kalan Toplam Borç:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(CurrencyFormatter.format(contract.remainingAmount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Müşteriye Erken Kapama İndirimi (%5):', style: TextStyle(fontSize: 12, color: AppColors.brutalOrange, fontWeight: FontWeight.w700)),
                        Text('-${CurrencyFormatter.format(discount)}', style: const TextStyle(fontSize: 12, color: AppColors.brutalOrange, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Tek Seferde Alınacak Nakit:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        Text(
                          CurrencyFormatter.format(netCash),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: 'SÖZLEŞMEYİ PEŞİN KAPAT',
                icon: Icons.done_all_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  final success = ref.read(gameProvider.notifier).settleInstallmentEarly(contract.id, discountRate: discountRate);
                  Navigator.pop(ctx);
                  if (success) {
                    NotificationService.showSuccess(context, 'Senet kapatıldı, ${CurrencyFormatter.format(netCash)} tahsil edildi!');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final liquidity = ref.read(gameProvider.notifier).calculateLiquidityStatus();

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'FİNANS & TAHSİLAT MERKEZİ',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 0. CARİ LİKİDİTE & FİNANSAL SAĞLIK KARTI
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
                    const Text('CARİ LİKİDİTE & FİNANSAL GÜVENLİK', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                    NeoBrutalBadge(
                      text: liquidity.badgeLabel,
                      backgroundColor: liquidity.level == LiquidityLevel.strong
                          ? AppColors.brutalGreen
                          : (liquidity.level == LiquidityLevel.moderate ? AppColors.brutalYellow : AppColors.errorRed),
                      textColor: liquidity.level == LiquidityLevel.tight ? Colors.white : Colors.black,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  liquidity.description,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: isDark ? Colors.white70 : Colors.black87),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Toplam Dönen Varlık:', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                            Text(CurrencyFormatter.formatShort(liquidity.totalLiquidAssets), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F1118) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Kısa Vadeli Yükümlülük:', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                            Text(CurrencyFormatter.formatShort(liquidity.totalShortTermDebts), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
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
                  label: game.isFeatureUnlocked('/bank-investments') ? 'YÖNET' : 'KİLİTLİ',
                  backgroundColor: game.isFeatureUnlocked('/bank-investments')
                      ? AppColors.brutalGreen
                      : const Color(0xFF64748B),
                  textColor: game.isFeatureUnlocked('/bank-investments') ? Colors.black : Colors.white,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () {
                    if (game.isFeatureUnlocked('/bank-investments')) {
                      context.push('/bank-investments');
                    } else {
                      NotificationService.showInfo(
                        context,
                        'Kilitli Özellik! Vadeli Mevduat & Krediler ${DealershipModel.getRequiredBranchName('/bank-investments')} satın alındığında açılır.',
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 1.1 Daily Cashflow Breakdown Nav Banner
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
                          color: const Color(0xFFFFDE59),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Günlük Net Nakit Akışı',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Gelir-Gider Dökümü, Maaşlar & Sabit Masraflar',
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
                  label: 'İNCELE',
                  backgroundColor: const Color(0xFFFFDE59),
                  textColor: Colors.black,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () => context.push('/finance/daily-cashflow'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Summary Receivables & Liabilities Cards
          _buildSummary(isDark, game),
          const SizedBox(height: 16),

          // 2.1 Daily Tax & Overhead Info Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: AppColors.brutalOrange, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Günlük Kurumsal & Belediye Vergisi',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Günlük gece devrinde otomatik kesilir (${CurrencyFormatter.format(game.dailyTaxRate)}/gün)',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: '${CurrencyFormatter.format(game.dailyTaxRate)} / Gün',
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Active Bank Loans & Debt Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AKTİF BANKA KREDİLERİ (${game.activeLoans.length})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  if (game.isFeatureUnlocked('/bank-investments')) {
                    context.push('/bank-investments');
                  } else {
                    NotificationService.showInfo(
                      context,
                      'Kilitli Özellik! Kredi çekebilmek için ${DealershipModel.getRequiredBranchName('/bank-investments')} satın alınmalıdır.',
                    );
                  }
                },
                child: const Text(
                  '+ KREDİ ÇEK',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (game.activeLoans.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(16),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: const Center(
                child: Text(
                  'Aktif banka kredisi borcunuz bulunmuyor.',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...game.activeLoans.map((loan) {
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
                            loan.bankName,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                          ),
                          NeoBrutalBadge(
                            text: '${loan.remainingInstallments}/${loan.totalInstallments} Taksit',
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
                            'Kalan: ${CurrencyFormatter.formatShort(loan.remainingAmount)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                          ),
                          Text(
                            'Aylık: ${CurrencyFormatter.formatShort(loan.monthlyPayment)}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Anapara: ${CurrencyFormatter.formatShort(loan.principalAmount)}',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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

          const SizedBox(height: 16),

          // 4. Active Installments
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
            ...game.activeInstallments.map((c) => _buildInstallmentCard(context, ref, isDark, c)),

          const SizedBox(height: 16),

          // 5. Pending Cheques
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
            ...game.activeCheques.map((ch) => _buildChequeCard(context, ref, isDark, ch, game.currentDay)),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark, DealershipModel game) {
    final double totalInstallmentReceivables =
        game.activeInstallments.fold(0.0, (sum, c) => sum + c.remainingAmount);
    final double totalChequeReceivables = game.activeCheques.fold(0.0, (sum, c) => sum + c.amount);
    final double totalLoanLiabilities = game.activeLoans.fold(0.0, (sum, l) => sum + l.remainingAmount);

    return Row(
      children: [
        Expanded(
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeoBrutalBadge(
                  text: 'SENET',
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 9,
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.formatShort(totalInstallmentReceivables),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeoBrutalBadge(
                  text: 'ÇEK',
                  backgroundColor: AppColors.brutalOrange,
                  textColor: Colors.black,
                  fontSize: 9,
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.formatShort(totalChequeReceivables),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.brutalOrange),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const NeoBrutalBadge(
                  text: 'KREDİ BORCU',
                  backgroundColor: Color(0xFFEF4444),
                  textColor: Colors.white,
                  fontSize: 9,
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.formatShort(totalLoanLiabilities),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstallmentCard(BuildContext context, WidgetRef ref, bool isDark, InstallmentContract contract) {
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
                  'Kalan: ${CurrencyFormatter.formatShort(contract.remainingAmount)}',
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
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 1.5,
                ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${contract.paidInstallments}/${contract.totalInstallments} Taksit Ödendi (Aylık: ${CurrencyFormatter.formatShort(contract.installmentAmount)})',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                if (contract.lateFee > 0)
                  NeoBrutalBadge(
                    text: 'Vade Farkı: +${CurrencyFormatter.formatShort(contract.lateFee)}',
                    backgroundColor: AppColors.errorRed,
                    textColor: Colors.white,
                    fontSize: 9,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            NeoBrutalButton(
              label: 'ERKEN KAPAT & PEŞİN AL (%5 İndirim)',
              icon: Icons.done_all_rounded,
              backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white : Colors.black,
              fontSize: 10.5,
              padding: const EdgeInsets.symmetric(vertical: 6),
              fullWidth: true,
              onPressed: () => _showInstallmentSettlementSheet(context, ref, contract),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChequeCard(BuildContext context, WidgetRef ref, bool isDark, Cheque cheque, int currentDay) {
    final int daysLeft = cheque.dueDay - currentDay;

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
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cheque.isDefaulted ? AppColors.errorRed : AppColors.brutalOrange,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    cheque.isDefaulted ? Icons.warning_amber_rounded : Icons.receipt_rounded,
                    color: cheque.isDefaulted ? Colors.white : Colors.black,
                    size: 22,
                  ),
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
                if (cheque.inLegalCollection)
                  NeoBrutalBadge(
                    icon: Icons.gavel_rounded,
                    text: 'İcrada (${cheque.legalCollectionDaysRemaining} Gün)',
                    backgroundColor: AppColors.brutalOrange,
                    textColor: Colors.black,
                    fontSize: 10,
                  )
                else if (cheque.isDefaulted)
                  const NeoBrutalBadge(
                    icon: Icons.warning_amber_rounded,
                    text: 'KARŞILIKSIZ',
                    backgroundColor: AppColors.errorRed,
                    textColor: Colors.white,
                    fontSize: 10,
                  )
                else
                  NeoBrutalBadge(
                    text: daysLeft > 0 ? '$daysLeft Gün Vade' : 'Bugün Tahsil',
                    backgroundColor: daysLeft <= 1 ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (cheque.inLegalCollection) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brutalOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalOrange, width: 1.2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gavel_rounded, color: AppColors.brutalOrange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Hukuk bürosu icra işlemlerini yürütüyor. ${cheque.legalCollectionDaysRemaining} gün sonra tahsil edilecek.',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (cheque.isDefaulted) ...[
              NeoBrutalButton(
                label: 'AVUKATA VER / İCRAYA KOY (₺1.500)',
                icon: Icons.gavel_rounded,
                backgroundColor: AppColors.brutalOrange,
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 6),
                fullWidth: true,
                onPressed: () {
                  final success = ref.read(gameProvider.notifier).sendChequeToLegalCollection(cheque.id);
                  if (success) {
                    NotificationService.showSuccess(context, 'Çek icra takibine alındı!');
                  } else {
                    NotificationService.showError(context, 'Yetersiz bakiye (Avukat masrafı: ₺1.500)!');
                  }
                },
              ),
            ] else ...[
              NeoBrutalButton(
                label: 'ÇEKİ KIRDIR / ERKEN TAHSİL ET (%8 İskonto)',
                icon: Icons.currency_exchange_rounded,
                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 6),
                fullWidth: true,
                onPressed: () => _showFactoringSheet(context, ref, cheque),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
