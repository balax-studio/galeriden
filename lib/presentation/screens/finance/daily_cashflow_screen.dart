import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../../data/models/staff_model.dart';
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

    // 1. GELİR HESAPLAMALARI
    final double businessMultiplier = game.specializationPath == SpecializationPath.boss ? 1.30 : 1.0;
    
    // Yan İşletme Gelirleri
    final ownedBusinesses = game.sideBusinesses.where((b) => b.isOwned).toList();
    final double sideBusinessIncome = ownedBusinesses.fold<double>(
      0.0,
      (sum, b) => sum + (b.effectiveDailyIncome * businessMultiplier),
    );

    // Rent a Car Günlük Kira Gelirleri
    final double rentalDailyIncome = game.activeRentals.fold<double>(
      0.0,
      (sum, r) => sum + r.dailyRate,
    );

    // Vadeli Mevduat Günlük Faiz Getirisi (%24 yıllık -> ~%0.065 günlük)
    final double depositDailyInterest = (game.bankDepositBalance * 0.24) / 365.0;

    // Borsa Günlük Temettü/Değer Artış Tahmini (Ortalama %0.15 günlük)
    final double stockPortfolioValue = game.ownedStocks.fold<double>(
      0.0,
      (sum, s) {
        final currentStock = game.marketStocks.where((m) => m.symbol == s.symbol).firstOrNull;
        final price = currentStock?.currentPrice ?? s.averageCost;
        return sum + (s.quantity * price);
      },
    );
    final double stockDailyDividend = (stockPortfolioValue * 0.05) / 365.0;

    final double totalDailyIncome = sideBusinessIncome + rentalDailyIncome + depositDailyInterest + stockDailyDividend;

    // 2. GİDER HESAPLAMALARI
    // Personel Maaşları
    double staffSalaries = game.hiredStaff.fold<double>(
      0.0,
      (sum, s) => sum + s.dailySalary,
    );
    if (game.specializationPath == SpecializationPath.boss) {
      staffSalaries *= 0.80; // %20 personel maaş indirimi
    }

    // Galeri Mülk Genel Giderleri / Kira (Burn-Rate)
    double propertyDailyBurn = 500.0;
    String propertyTierName = 'Başlangıç Garajı (Tier 1)';
    if (game.unlockedBuildings.contains('property_tier_4')) {
      propertyDailyBurn = 45000.0;
      propertyTierName = 'Oto Plaza & Showroom (Tier 4)';
    } else if (game.unlockedBuildings.contains('property_tier_3')) {
      propertyDailyBurn = 12000.0;
      propertyTierName = 'Büyük Galeri Kompleksi (Tier 3)';
    } else if (game.unlockedBuildings.contains('property_tier_2')) {
      propertyDailyBurn = 3000.0;
      propertyTierName = 'Orta Ölçekli Galeri (Tier 2)';
    }

    // Aktif Krediler Günlük Ödeme Yükü
    final double loanDailyPayment = game.activeLoans.fold<double>(
      0.0,
      (sum, l) => sum + l.monthlyPayment,
    );

    // İşletme Stopaj / Sabit Ticari Vergi
    final double dailyTaxEstimate = game.dailyTaxRate;

    final double totalDailyExpense = staffSalaries + propertyDailyBurn + loanDailyPayment + dailyTaxEstimate;

    // 3. NET NAKİT AKIŞI
    final double netDailyCashflow = totalDailyIncome - totalDailyExpense;
    final bool isProfitable = netDailyCashflow > 0;
    final bool isNeutral = netDailyCashflow == 0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'GÜNLÜK NET NAKİT AKIŞI',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Ana Özet & Durum Kartı
          _buildHeroSummaryCard(
            context: context,
            isDark: isDark,
            totalIncome: totalDailyIncome,
            totalExpense: totalDailyExpense,
            netCashflow: netDailyCashflow,
            isProfitable: isProfitable,
            isNeutral: isNeutral,
            currentDay: game.currentDay,
          ),
          const SizedBox(height: 14),

          // 2. 7 Günlük Kümülatif Projeksiyon & Muhasebeci Tavsiyesi
          _buildProjectionAndAdviceCard(
            isDark: isDark,
            netDaily: netDailyCashflow,
            hasLoans: game.activeLoans.isNotEmpty,
            hasExcessStaff: staffSalaries > (totalDailyIncome * 0.6) && !isProfitable,
            bankBalance: game.balance,
          ),
          const SizedBox(height: 16),

          // 3. Gelir Kalemleri Başlığı & Listesi
          _buildSectionHeader(
            title: 'DİNAMİK GÜNLÜK GELİRLER',
            totalAmount: totalDailyIncome,
            isIncome: true,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildIncomeBreakdownList(
            context: context,
            isDark: isDark,
            sideBusinesses: ownedBusinesses,
            businessMultiplier: businessMultiplier,
            sideBusinessIncome: sideBusinessIncome,
            rentalsCount: game.activeRentals.length,
            rentalIncome: rentalDailyIncome,
            depositInterest: depositDailyInterest,
            depositBalance: game.bankDepositBalance,
            stockDividend: stockDailyDividend,
            stockPortfolioValue: stockPortfolioValue,
          ),
          const SizedBox(height: 16),

          // 4. Gider Kalemleri Başlığı & Listesi
          _buildSectionHeader(
            title: 'DİNAMİK GÜNLÜK GİDERLER',
            totalAmount: totalDailyExpense,
            isIncome: false,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildExpenseBreakdownList(
            context: context,
            isDark: isDark,
            staffList: game.hiredStaff,
            staffSalaries: staffSalaries,
            hasBossPerk: game.specializationPath == SpecializationPath.boss,
            propertyTierName: propertyTierName,
            propertyDailyBurn: propertyDailyBurn,
            activeLoans: game.activeLoans,
            loanDailyPayment: loanDailyPayment,
            dailyTaxEstimate: dailyTaxEstimate,
            dailyTaxRate: game.dailyTaxRate,
          ),
          const SizedBox(height: 16),

          // 5. Hızlı Finans & Yönetim Eylemleri
          _buildQuickActionButtons(context, isDark),
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
        ? 'POZİTİF KÂR AKIŞI'
        : (isNeutral ? 'BAŞABAŞ (NÖTR)' : 'NAKİT AÇIĞI (ZARAR)');

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
                          : (isNeutral ? Icons.drag_handle_rounded : Icons.trending_down_rounded),
                      color: statusColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GÜN $currentDay NAKİT DENGESİ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                text: '2 DK / GÜN',
                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
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
                color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'NET GÜNLÜK NAKİT AKIŞI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${netCashflow >= 0 ? '+' : ''}${CurrencyFormatter.format(netCashflow)} / gün',
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
                    border: Border.all(color: const Color(0xFF00E575).withValues(alpha: 0.3), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, size: 14, color: Color(0xFF00E575)),
                          SizedBox(width: 4),
                          Text(
                            'Toplam Gelir',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF00E575)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${CurrencyFormatter.format(totalIncome)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF00E575)),
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
                    border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, size: 14, color: Color(0xFFEF4444)),
                          SizedBox(width: 4),
                          Text(
                            'Toplam Gider',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '-${CurrencyFormatter.format(totalExpense)}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFEF4444)),
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
    required bool isDark,
    required double netDaily,
    required bool hasLoans,
    required bool hasExcessStaff,
    required double bankBalance,
  }) {
    final double weekProjection = netDaily * 7;
    final double monthProjection = netDaily * 30;

    String adviceTitle = 'Finansal Durum Mükemmel';
    String adviceBody = 'Günlük nakit akışın pozitif. Fazla nakdini vadeli mevduata veya borsa hisselerine yönlendirerek bileşik getiri elde edebilirsin.';
    IconData adviceIcon = Icons.verified_rounded;
    Color adviceColor = const Color(0xFF00E575);

    if (netDaily < 0) {
      adviceColor = const Color(0xFFEF4444);
      adviceIcon = Icons.warning_amber_rounded;
      if (hasLoans) {
        adviceTitle = 'Kredi Yükü Kasanı Zorluyor';
        adviceBody = 'Yüksek kredi taksitleri günlük kasanı eritiyor. Erken kredi kapatma yaparak sabit faiz giderlerini düşür.';
      } else if (hasExcessStaff) {
        adviceTitle = 'Personel Gideri Yüksek';
        adviceBody = 'Maaş giderleri yan gelirleri aşıyor. Yan işletmelerini yükselt veya atıl personelleri gözden geçir.';
      } else {
        adviceTitle = 'Sabit Gider Uyarısı';
        adviceBody = 'Mülk ve stopaj giderlerini karşılamak için yeni yan işletmeler satın al veya oto kiralama araçlarını artır.';
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
              Icon(Icons.query_stats_rounded, size: 18, color: isDark ? const Color(0xFFFFDE59) : const Color(0xFFD97706)),
              const SizedBox(width: 8),
              const Text(
                '7 & 30 GÜNLÜK PROJEKSİYON',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProjectionPill(
                  title: 'Haftalık Beklenti (7g)',
                  amount: weekProjection,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildProjectionPill(
                  title: 'Aylık Beklenti (30g)',
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
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
        Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: 0.5,
          ),
        ),
        NeoBrutalBadge(
          text: '${isIncome ? '+' : '-'}${CurrencyFormatter.format(totalAmount)}/g',
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
          title: 'Yan İşletmeler (${sideBusinesses.length} Aktif)',
          subtitle: sideBusinesses.isEmpty
              ? 'Henüz satın alınmış yan işletme yok'
              : sideBusinesses.map((b) => '${b.name} (Sv.${b.level})').join(', '),
          amount: sideBusinessIncome,
          isIncome: true,
          badgeText: businessMultiplier > 1.0 ? '+%30 Patron Bonusu' : null,
          onTap: () => context.push('/side-businesses'),
        ),
        const SizedBox(height: 8),

        // 2. Rent a Car Kiralama Gelirleri
        _buildItemCard(
          isDark: isDark,
          icon: Icons.car_rental_rounded,
          iconColor: const Color(0xFF38BDF8),
          title: 'Rent a Car Kiralamaları ($rentalsCount Araç)',
          subtitle: rentalsCount == 0
              ? 'Kirada olan araç bulunmuyor'
              : '$rentalsCount adet sözleşmeli kiralık araç günlük tarifesi',
          amount: rentalIncome,
          isIncome: true,
          onTap: () => context.push('/rent-a-car'),
        ),
        const SizedBox(height: 8),

        // 3. Banka Vadeli Mevduat Faizi
        _buildItemCard(
          isDark: isDark,
          icon: Icons.account_balance_rounded,
          iconColor: const Color(0xFFFFDE59),
          title: 'Vadeli Mevduat Faiz Getirisi',
          subtitle: depositBalance > 0
              ? '${CurrencyFormatter.format(depositBalance)} mevduat bakiyesi (%24 Yıllık Faiz)'
              : 'Vadeli hesapta para bulunmuyor',
          amount: depositInterest,
          isIncome: true,
          onTap: () => context.push('/bank-investments'),
        ),
        const SizedBox(height: 8),

        // 4. Borsa Hisse Senedi Getirileri
        if (stockPortfolioValue > 0)
          _buildItemCard(
            isDark: isDark,
            icon: Icons.candlestick_chart_rounded,
            iconColor: const Color(0xFFA855F7),
            title: 'Borsa & Hisse Portföyü',
            subtitle: '${CurrencyFormatter.format(stockPortfolioValue)} hisse senedi günlük getiri projeksiyonu',
            amount: stockDividend,
            isIncome: true,
            onTap: () => context.push('/stock-market'),
          ),
      ],
    );
  }

  Widget _buildExpenseBreakdownList({
    required BuildContext context,
    required bool isDark,
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
          title: 'Personel Maaşları (${staffList.length} Çalışan)',
          subtitle: staffList.isEmpty
              ? 'İşe alınmış personel bulunmuyor'
              : staffList.map((s) => '${s.name} (${s.role.title})').join(', '),
          amount: staffSalaries,
          isIncome: false,
          badgeText: hasBossPerk ? '-%20 Patron İndirimi' : null,
          onTap: () => context.push('/staff'),
        ),
        const SizedBox(height: 8),

        // 2. Galeri & Mülk Sabit Giderleri (Kira / Elektrik / Isınma)
        _buildItemCard(
          isDark: isDark,
          icon: Icons.apartment_rounded,
          iconColor: const Color(0xFFF97316),
          title: 'Galeri Sabit Genel Gideri',
          subtitle: '$propertyTierName kira, aidat, elektrik ve işletme gideri',
          amount: propertyDailyBurn,
          isIncome: false,
          onTap: () => context.push('/branches'),
        ),
        const SizedBox(height: 8),

        // 3. Banka Kredileri Günlük Ödeme Yükü
        if (activeLoans.isNotEmpty) ...[
          _buildItemCard(
            isDark: isDark,
            icon: Icons.credit_score_rounded,
            iconColor: const Color(0xFFEF4444),
            title: 'Banka Kredisi Geri Ödemeleri (${activeLoans.length} Kredi)',
            subtitle: 'Aktif ticari kredilerin günlük faiz ve anapara taksit payı',
            amount: loanDailyPayment,
            isIncome: false,
            onTap: () => context.push('/bank-investments'),
          ),
          const SizedBox(height: 8),
        ],

        // 4. Vergi & Stopaj
        _buildItemCard(
          isDark: isDark,
          icon: Icons.receipt_long_rounded,
          iconColor: const Color(0xFF94A3B8),
          title: 'İşletme Stopajı & Ticari Vergi',
          subtitle: 'Günlük belediye & kurumsal sabit vergi kesintisi',
          amount: dailyTaxEstimate,
          isIncome: false,
        ),
      ],
    );
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
    final color = isIncome ? const Color(0xFF00E575) : const Color(0xFFEF4444);

    return NeoBrutalCard(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap();
            }
          : null,
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1.2),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badgeText != null) ...[
                      const SizedBox(width: 6),
                      NeoBrutalBadge(
                        text: badgeText,
                        backgroundColor: const Color(0xFFFFDE59),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(amount)}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const Text(
                '/gün',
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HIZLI YÖNETİM & GELİR ARTIRMA',
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
                label: 'YAN İŞLETME',
                icon: Icons.storefront_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/side-businesses');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalButton(
                label: 'PERSONEL',
                icon: Icons.badge_rounded,
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/staff');
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NeoBrutalButton(
                label: 'BANKA',
                icon: Icons.account_balance_rounded,
                backgroundColor: const Color(0xFF38BDF8),
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.push('/bank-investments');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
