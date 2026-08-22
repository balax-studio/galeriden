import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
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
                  Text(context.tr('finance_factoring_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
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
                        Text(context.tr('finance_cheque_nominal'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(CurrencyFormatter.format(cheque.amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('finance_factoring_fee'), style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w700)),
                        Text('-${CurrencyFormatter.format(fee)}', style: const TextStyle(fontSize: 12, color: Color(0xFFEF4444), fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('finance_net_cash'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
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
                label: context.tr('finance_cash_cheque_btn'),
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
                  Text(context.tr('finance_promissory_early_close'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
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
                        Text(context.tr('finance_remaining_debt'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        Text(CurrencyFormatter.format(contract.remainingAmount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('finance_early_close_discount'), style: const TextStyle(fontSize: 12, color: AppColors.brutalOrange, fontWeight: FontWeight.w700)),
                        Text('-${CurrencyFormatter.format(discount)}', style: const TextStyle(fontSize: 12, color: AppColors.brutalOrange, fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const Divider(height: 16, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.tr('finance_lump_sum_cash'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
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
                label: context.tr('finance_close_contract_btn'),
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
      appBar: NeoBrutalAppBar(
        title: context.tr('finance_title'),
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
                    Text(context.tr('finance_liquidity_badge'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
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
                            Text(context.tr('finance_bank_balance_label'), style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
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
                            Text(context.tr('finance_receivables_summary_label'), style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('bank_deposit_account_title'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('bank_deposit_desc'),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: game.isFeatureUnlocked('/bank-investments') ? context.tr('finance_open_bank_btn') : 'KİLİTLİ',
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
                        context.tr('cashflow_locked_feature_toast', {'branch': DealershipModel.getRequiredBranchName('/bank-investments')}),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('cashflow_title'),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('cashflow_advice_burn_title'),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: context.tr('finance_open_cashflow_btn'),
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
          _buildSummary(isDark, game, context),
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
                        Text(
                          context.tr('finance_daily_tax_title'),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          context.tr('finance_daily_tax_desc'),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                NeoBrutalBadge(
                  text: context.tr('finance_daily_tax_label', {'amount': CurrencyFormatter.format(game.dailyTaxRate)}),
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
                context.tr('bank_active_loans_header', {'count': game.activeLoans.length}),
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
                      context.tr('cashflow_locked_feature_toast', {'branch': DealershipModel.getRequiredBranchName('/bank-investments')}),
                    );
                  }
                },
                child: Text(
                  context.tr('finance_take_credit_btn'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
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
              child: Center(
                child: Text(
                  context.tr('finance_no_active_loans'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                            text: context.tr('finance_loan_installments_badge', {'remaining': loan.remainingInstallments, 'total': loan.totalInstallments}),
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
                            context.tr('finance_loan_remaining', {'amount': CurrencyFormatter.formatShort(loan.remainingAmount)}),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
                          ),
                          Text(
                            context.tr('finance_loan_monthly', {'amount': CurrencyFormatter.formatShort(loan.monthlyPayment)}),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brutalYellow),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.tr('finance_loan_principal', {'amount': CurrencyFormatter.formatShort(loan.principalAmount)}),
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          NeoBrutalButton(
                            label: context.tr('finance_pay_installment_btn'),
                            icon: Icons.payments_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            onPressed: () {
                              if (game.balance < loan.monthlyPayment) {
                                NotificationService.showError(
                                  context,
                                  context.tr('finance_insufficient_funds_loan', {'amount': CurrencyFormatter.format(loan.monthlyPayment)}),
                                );
                                return;
                              }

                              final success = ref.read(gameProvider.notifier).payLoanInstallment(loan.id);
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('finance_loan_paid_success', {'bank': loan.bankName}),
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
            context.tr('finance_active_installments_header', {'count': game.activeInstallments.length}),
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
              child: Center(
                child: Text(
                  context.tr('finance_no_active_installments'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...game.activeInstallments.map((c) => _buildInstallmentCard(context, ref, isDark, c)),

          const SizedBox(height: 16),

          // 5. Pending Cheques
          Text(
            context.tr('finance_pending_cheques_header', {'count': game.activeCheques.length}),
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
              child: Center(
                child: Text(
                  context.tr('finance_no_pending_cheques'),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            ...game.activeCheques.map((ch) => _buildChequeCard(context, ref, isDark, ch, game.currentDay)),
        ],
      ),
    );
  }

  Widget _buildSummary(bool isDark, DealershipModel game, BuildContext context) {
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
                NeoBrutalBadge(
                  text: context.tr('finance_summary_promissory'),
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
                NeoBrutalBadge(
                  text: context.tr('finance_summary_cheque'),
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
                NeoBrutalBadge(
                  text: context.tr('finance_summary_loan_debt'),
                  backgroundColor: const Color(0xFFEF4444),
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
                  text: context.tr('finance_installment_days_left', {'days': contract.daysUntilNextPayment}),
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
                  context.tr('finance_installment_collected', {'amount': CurrencyFormatter.formatShort(contract.paidAmount)}),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                ),
                Text(
                  context.tr('finance_installment_remaining', {'amount': CurrencyFormatter.formatShort(contract.remainingAmount)}),
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
                  context.tr('finance_installment_paid_badge', {'paid': contract.paidInstallments, 'total': contract.totalInstallments, 'amount': CurrencyFormatter.formatShort(contract.installmentAmount)}),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                if (contract.lateFee > 0)
                  NeoBrutalBadge(
                    text: context.tr('finance_installment_late_fee', {'amount': CurrencyFormatter.formatShort(contract.lateFee)}),
                    backgroundColor: AppColors.errorRed,
                    textColor: Colors.white,
                    fontSize: 9,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            NeoBrutalButton(
              label: context.tr('finance_early_settlement_btn'),
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
                        context.tr('finance_cheque_amount', {'amount': CurrencyFormatter.formatShort(cheque.amount)}),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.brutalGreen),
                      ),
                    ],
                  ),
                ),
                if (cheque.inLegalCollection)
                  NeoBrutalBadge(
                    icon: Icons.gavel_rounded,
                    text: context.tr('finance_cheque_in_legal', {'days': cheque.legalCollectionDaysRemaining}),
                    backgroundColor: AppColors.brutalOrange,
                    textColor: Colors.black,
                    fontSize: 10,
                  )
                else if (cheque.isDefaulted)
                  NeoBrutalBadge(
                    icon: Icons.warning_amber_rounded,
                    text: context.tr('finance_cheque_defaulted'),
                    backgroundColor: AppColors.errorRed,
                    textColor: Colors.white,
                    fontSize: 10,
                  )
                else
                  NeoBrutalBadge(
                    text: daysLeft > 0 ? context.tr('finance_cheque_days_due', {'days': daysLeft}) : context.tr('finance_cheque_due_today'),
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
                        context.tr('finance_cheque_legal_desc', {'days': cheque.legalCollectionDaysRemaining}),
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (cheque.isDefaulted) ...[
              NeoBrutalButton(
                label: context.tr('finance_cheque_send_lawyer_btn'),
                icon: Icons.gavel_rounded,
                backgroundColor: AppColors.brutalOrange,
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 6),
                fullWidth: true,
                onPressed: () {
                  final success = ref.read(gameProvider.notifier).sendChequeToLegalCollection(cheque.id);
                  if (success) {
                    NotificationService.showSuccess(context, context.tr('finance_cheque_legal_success'));
                  } else {
                    NotificationService.showError(context, context.tr('finance_cheque_legal_insufficient'));
                  }
                },
              ),
            ] else ...[
              NeoBrutalButton(
                label: context.tr('finance_cheque_factoring_btn'),
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
