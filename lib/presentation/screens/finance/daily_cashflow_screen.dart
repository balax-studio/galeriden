import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../domain/usecases/cashflow_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

/// Günlük Dinamik Gelir & Gider / Nakit Akışı Detay Ekranı
class DailyCashflowScreen extends ConsumerWidget {
  const DailyCashflowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette;
    final isDark = p?.isDark ?? true;

    // Domain usecase call for cashflow calculation
    final summary = CashflowEngine.calculate(game);
    final ownedBusinesses =
        game.sideBusinesses.where((b) => b.isOwned).toList();
    final double businessMultiplier =
        game.specializationPath == SpecializationPath.boss ? 1.30 : 1.0;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('cashflow_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Ana Özet & Durum Kartı
          _buildHeroSummaryCard(
            context: context,
            isDark: isDark,
            totalIncome: summary.totalDailyIncome,
            totalExpense: summary.totalDailyExpense,
            netCashflow: summary.netDailyCashflow,
            isProfitable: summary.isProfitable,
            isNeutral: summary.isNeutral,
            currentDay: game.currentDay,
          ),
          const SizedBox(height: 14),

          // 2. 7 Günlük Kümülatif Projeksiyon & Muhasebeci Tavsiyesi
          _buildProjectionAndAdviceCard(
            context: context,
            isDark: isDark,
            netDaily: summary.netDailyCashflow,
            hasLoans: game.activeLoans.isNotEmpty,
            hasExcessStaff:
                summary.staffSalaries > (summary.totalDailyIncome * 0.6) &&
                    !summary.isProfitable,
            bankBalance: game.balance,
          ),
          const SizedBox(height: 16),

          // 3. Gelir Kalemleri Başlığı & Listesi
          _buildSectionHeader(
            title: context.tr('cashflow_section_incomes'),
            totalAmount: summary.totalDailyIncome,
            isIncome: true,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildIncomeBreakdownList(
            context: context,
            isDark: isDark,
            game: game,
            sideBusinesses: ownedBusinesses,
            businessMultiplier: businessMultiplier,
            sideBusinessIncome: summary.sideBusinessIncome,
            rentalsCount: game.activeRentals.length,
            rentalIncome: summary.rentalDailyIncome,
            depositInterest: summary.depositDailyInterest,
            depositBalance: game.bankDepositBalance,
            stockDividend: summary.stockDailyDividend,
            stockPortfolioValue: summary.stockPortfolioValue,
          ),
          const SizedBox(height: 16),

          // 4. Gider Kalemleri Başlığı & Listesi
          _buildSectionHeader(
            title: context.tr('cashflow_section_expenses'),
            totalAmount: summary.totalDailyExpense,
            isIncome: false,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildExpenseBreakdownList(
            context: context,
            isDark: isDark,
            game: game,
            staffList: game.hiredStaff,
            staffSalaries: summary.staffSalaries,
            hasBossPerk: game.specializationPath == SpecializationPath.boss,
            propertyTierName: summary.propertyTierName,
            propertyDailyBurn: summary.propertyDailyBurn,
            activeLoans: game.activeLoans,
            loanDailyPayment: summary.loanDailyPayment,
            dailyTaxEstimate: summary.dailyTaxEstimate,
            dailyTaxRate: game.dailyTaxRate,
          ),
          const SizedBox(height: 16),

          // 5. Hızlı Finans & Yönetim Eylemleri
          _buildQuickActionButtons(context, game, isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildHeroSummaryCard({
    required BuildContext context,
    required bool isDark,
    required double totalIncome,
    required double totalExpense,
    required double netCashflow,
    required bool isProfitable,
    required bool isNeutral,
    required int currentDay,
  }) {
    final Color statusColor = isProfitable
        ? const Color(0xFF00E575)
        : (isNeutral ? const Color(0xFFFFDE59) : const Color(0xFFEF4444));

    final String statusText = isProfitable
        ? context.tr('cashflow_status_profit')
        : (isNeutral
            ? context.tr('cashflow_status_neutral')
            : context.tr('cashflow_status_loss'));

    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Icon(
                      isProfitable
                          ? Icons.trending_up_rounded
                          : (isNeutral
                              ? Icons.drag_handle_rounded
                              : Icons.trending_down_rounded),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                            'cashflow_day_balance_label', {'day': currentDay}),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: context.tr('cashflow_time_badge'),
                backgroundColor:
                    isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                textColor:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Net Tutar Vurgusu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  context.tr('cashflow_net_flow_label'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${netCashflow >= 0 ? '+' : ''}${CurrencyFormatter.format(netCashflow)} ${context.tr('cashflow_per_day')}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Gelir & Gider Karşılaştırma Çubukları
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E575).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF00E575).withValues(alpha: 0.3),
                        width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward_rounded,
                              size: 14, color: Color(0xFF00E575)),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('cashflow_total_income_label'),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00E575)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${CurrencyFormatter.format(totalIncome)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00E575)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.3),
                        width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.arrow_downward_rounded,
                              size: 14, color: Color(0xFFEF4444)),
                          const SizedBox(width: 4),
                          Text(
                            context.tr('cashflow_total_expense_label'),
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '-${CurrencyFormatter.format(totalExpense)}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFEF4444)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionAndAdviceCard({
    required BuildContext context,
    required bool isDark,
    required double netDaily,
    required bool hasLoans,
    required bool hasExcessStaff,
    required double bankBalance,
  }) {
    final double weekProjection = netDaily * 7;
    final double monthProjection = netDaily * 30;

    String adviceTitle = context.tr('cashflow_advice_perfect_title');
    String adviceBody = context.tr('cashflow_advice_perfect_body');
    IconData adviceIcon = Icons.verified_rounded;
    Color adviceColor = const Color(0xFF00E575);

    if (netDaily < 0) {
      adviceColor = const Color(0xFFEF4444);
      adviceIcon = Icons.warning_amber_rounded;
      if (hasLoans) {
        adviceTitle = context.tr('cashflow_advice_loans_title');
        adviceBody = context.tr('cashflow_advice_loans_body');
      } else if (hasExcessStaff) {
        adviceTitle = context.tr('cashflow_advice_staff_title');
        adviceBody = context.tr('cashflow_advice_staff_body');
      } else {
        adviceTitle = context.tr('cashflow_advice_burn_title');
        adviceBody = context.tr('cashflow_advice_burn_body');
      }
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.query_stats_rounded,
                  size: 18,
                  color: isDark
                      ? const Color(0xFFFFDE59)
                      : const Color(0xFFD97706)),
              const SizedBox(width: 8),
              Text(
                context.tr('cashflow_projection_title'),
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProjectionPill(
                  title: context.tr('cashflow_weekly_projection'),
                  amount: weekProjection,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProjectionPill(
                  title: context.tr('cashflow_monthly_projection'),
                  amount: monthProjection,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Haydar Usta / Muhasebeci Tavsiyesi
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: adviceColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(adviceIcon, size: 16, color: adviceColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adviceTitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      adviceBody,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionPill({
    required String title,
    required double amount,
    required bool isDark,
  }) {
    final isPos = amount >= 0;
    final color = isPos ? const Color(0xFF00E575) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${isPos ? '+' : ''}${CurrencyFormatter.formatShort(amount)}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required double totalAmount,
    required bool isIncome,
    required bool isDark,
  }) {
    final color = isIncome ? const Color(0xFF00E575) : const Color(0xFFEF4444);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
            child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        )),
        NeoBrutalBadge(
          text:
              '${isIncome ? '+' : '-'}${CurrencyFormatter.format(totalAmount)}/g',
          backgroundColor: color.withValues(alpha: 0.15),
          textColor: color,
          fontSize: 11,
          borderColor: color.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  Widget _buildIncomeBreakdownList({
    required BuildContext context,
    required bool isDark,
    required DealershipModel game,
    required List<SideBusinessModel> sideBusinesses,
    required double businessMultiplier,
    required double sideBusinessIncome,
    required int rentalsCount,
    required double rentalIncome,
    required double depositInterest,
    required double depositBalance,
    required double stockDividend,
    required double stockPortfolioValue,
  }) {
    return Column(
      children: [
        // 1. Yan İşletmeler Kartı
        _buildItemCard(
          isDark: isDark,
          icon: Icons.storefront_rounded,
          iconColor: const Color(0xFF00E575),
          title: context.tr('cashflow_income_side_business_title',
              {'count': sideBusinesses.length}),
          subtitle: sideBusinesses.isEmpty
              ? context.tr('cashflow_income_no_side_business')
              : sideBusinesses
                  .map((b) => '${b.name} • Sv.${b.level}')
                  .join(', '),
          amount: sideBusinessIncome,
          isIncome: true,
          badgeText: businessMultiplier > 1.0
              ? context.tr('cashflow_boss_bonus_badge')
              : null,
          onTap: () => _handleShortcut(context, game, '/side-businesses'),
        ),
        const SizedBox(height: 8),

        // 2. Rent a Car Kiralama Gelirleri
        _buildItemCard(
          isDark: isDark,
          icon: Icons.car_rental_rounded,
          iconColor: const Color(0xFF38BDF8),
          title: context
              .tr('cashflow_income_rentals_title', {'count': rentalsCount}),
          subtitle: rentalsCount == 0
              ? context.tr('cashflow_income_no_rentals')
              : context
                  .tr('cashflow_income_rentals_desc', {'count': rentalsCount}),
          amount: rentalIncome,
          isIncome: true,
          onTap: () => _handleShortcut(context, game, '/rent-a-car'),
        ),
        const SizedBox(height: 8),

        // 3. Banka Vadeli Mevduat Faizi
        _buildItemCard(
          isDark: isDark,
          icon: Icons.account_balance_rounded,
          iconColor: const Color(0xFFFFDE59),
          title: context.tr('cashflow_income_deposit_title'),
          subtitle: depositBalance > 0
              ? context.tr('cashflow_income_deposit_desc',
                  {'balance': CurrencyFormatter.format(depositBalance)})
              : context.tr('cashflow_income_no_deposit'),
          amount: depositInterest,
          isIncome: true,
          onTap: () => _handleShortcut(context, game, '/bank-investments'),
        ),
        const SizedBox(height: 8),

        // 4. Borsa Hisse Senedi Getirileri
        if (stockPortfolioValue > 0)
          _buildItemCard(
            isDark: isDark,
            icon: Icons.candlestick_chart_rounded,
            iconColor: const Color(0xFFA855F7),
            title: context.tr('cashflow_income_stocks_title'),
            subtitle: context.tr('cashflow_income_stocks_desc',
                {'value': CurrencyFormatter.format(stockPortfolioValue)}),
            amount: stockDividend,
            isIncome: true,
            onTap: () => _handleShortcut(context, game, '/stock-market'),
          ),
      ],
    );
  }

  Widget _buildExpenseBreakdownList({
    required BuildContext context,
    required bool isDark,
    required DealershipModel game,
    required List<StaffModel> staffList,
    required double staffSalaries,
    required bool hasBossPerk,
    required String propertyTierName,
    required double propertyDailyBurn,
    required List<dynamic> activeLoans,
    required double loanDailyPayment,
    required double dailyTaxEstimate,
    required double dailyTaxRate,
  }) {
    return Column(
      children: [
        // 1. Personel Maaşları
        _buildItemCard(
          isDark: isDark,
          icon: Icons.badge_rounded,
          iconColor: const Color(0xFFEF4444),
          title: context
              .tr('cashflow_expense_staff_title', {'count': staffList.length}),
          subtitle: staffList.isEmpty
              ? context.tr('cashflow_expense_no_staff')
              : staffList.map((s) => '${s.name} • ${s.role.title}').join(', '),
          amount: staffSalaries,
          isIncome: false,
          badgeText:
              hasBossPerk ? context.tr('cashflow_boss_discount_badge') : null,
          onTap: () => _handleShortcut(context, game, '/staff'),
        ),
        const SizedBox(height: 8),

        // 2. Galeri & Mülk Sabit Giderleri (Kira / Elektrik / Isınma)
        _buildItemCard(
          isDark: isDark,
          icon: Icons.apartment_rounded,
          iconColor: const Color(0xFFF97316),
          title: context.tr('cashflow_expense_property_title'),
          subtitle: context
              .tr('cashflow_expense_property_desc', {'tier': propertyTierName}),
          amount: propertyDailyBurn,
          isIncome: false,
          onTap: () => _handleShortcut(context, game, '/branches'),
        ),
        const SizedBox(height: 8),

        // 3. Banka Kredileri Günlük Ödeme Yükü
        if (activeLoans.isNotEmpty) ...[
          _buildItemCard(
            isDark: isDark,
            icon: Icons.credit_score_rounded,
            iconColor: const Color(0xFFEF4444),
            title: context.tr(
                'cashflow_expense_loans_title', {'count': activeLoans.length}),
            subtitle: context.tr('cashflow_expense_loans_desc'),
            amount: loanDailyPayment,
            isIncome: false,
            onTap: () => _handleShortcut(context, game, '/bank-investments'),
          ),
          const SizedBox(height: 8),
        ],

        // 4. Vergi & Stopaj
        _buildItemCard(
          isDark: isDark,
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF94A3B8),
          title: context.tr('cashflow_expense_tax_title'),
          subtitle: context.tr('cashflow_expense_tax_desc'),
          amount: dailyTaxEstimate,
          isIncome: false,
        ),
      ],
    );
  }

  void _handleShortcut(
      BuildContext context, DealershipModel game, String route) {
    if (game.isFeatureUnlocked(route)) {
      context.push(route);
    } else {
      NotificationService.showInfo(
        context,
        context.tr('cashflow_locked_feature_toast',
            {'branch': DealershipModel.getRequiredBranchName(route)}),
      );
    }
  }

  Widget _buildItemCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double amount,
    required bool isIncome,
    String? badgeText,
    VoidCallback? onTap,
  }) {
    final amountFormatted = CurrencyFormatter.format(amount);
    final prefix = isIncome ? '+' : '-';
    final amountColor = isIncome ? AppColors.brutalGreen : AppColors.errorRed;

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: iconColor,
                width: 1.4,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      NeoBrutalBadge(
                        text: badgeText,
                        backgroundColor: isIncome
                            ? AppColors.brutalGreen
                            : AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 9,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix$amountFormatted',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '/gün',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(
      BuildContext context, DealershipModel game, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('cashflow_quick_actions_title'),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: NeoBrutalButton(
                label: context.tr('cashflow_btn_side_business'),
                icon: Icons.storefront_rounded,
                backgroundColor: game.isFeatureUnlocked('/side-businesses')
                    ? AppColors.brutalGreen
                    : const Color(0xFF64748B),
                textColor: game.isFeatureUnlocked('/side-businesses')
                    ? Colors.black
                    : Colors.white,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _handleShortcut(context, game, '/side-businesses');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalButton(
                label: context.tr('cashflow_btn_staff'),
                icon: Icons.badge_rounded,
                backgroundColor: game.isFeatureUnlocked('/staff')
                    ? const Color(0xFFFFDE59)
                    : const Color(0xFF64748B),
                textColor: game.isFeatureUnlocked('/staff')
                    ? Colors.black
                    : Colors.white,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _handleShortcut(context, game, '/staff');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalButton(
                label: context.tr('cashflow_btn_bank'),
                icon: Icons.account_balance_rounded,
                backgroundColor: game.isFeatureUnlocked('/bank-investments')
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF64748B),
                textColor: game.isFeatureUnlocked('/bank-investments')
                    ? Colors.black
                    : Colors.white,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _handleShortcut(context, game, '/bank-investments');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
