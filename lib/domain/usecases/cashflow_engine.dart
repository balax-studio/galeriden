import '../../core/utils/iterable_extensions.dart';
import '../../data/models/dealership_model.dart';

class CashflowSummary {
  final double sideBusinessIncome;
  final double rentalDailyIncome;
  final double depositDailyInterest;
  final double stockPortfolioValue;
  final double stockDailyDividend;
  final double totalDailyIncome;

  final double staffSalaries;
  final double propertyDailyBurn;
  final String propertyTierName;
  final double loanDailyPayment;
  final double dailyTaxEstimate;
  final double totalDailyExpense;

  final double netDailyCashflow;
  final bool isProfitable;
  final bool isNeutral;

  const CashflowSummary({
    required this.sideBusinessIncome,
    required this.rentalDailyIncome,
    required this.depositDailyInterest,
    required this.stockPortfolioValue,
    required this.stockDailyDividend,
    required this.totalDailyIncome,
    required this.staffSalaries,
    required this.propertyDailyBurn,
    required this.propertyTierName,
    required this.loanDailyPayment,
    required this.dailyTaxEstimate,
    required this.totalDailyExpense,
    required this.netDailyCashflow,
    required this.isProfitable,
    required this.isNeutral,
  });
}

class CashflowEngine {
  CashflowEngine._();

  static CashflowSummary calculate(DealershipModel game) {
    final double businessMultiplier = game.specializationPath == SpecializationPath.boss ? 1.30 : 1.0;

    // 1. Incomes
    final ownedBusinesses = game.sideBusinesses.where((b) => b.isOwned).toList();
    final double sideBusinessIncome = ownedBusinesses.fold<double>(
      0.0,
      (sum, b) => sum + (b.effectiveDailyIncome * businessMultiplier),
    );

    final double rentalDailyIncome = game.activeRentals.fold<double>(
      0.0,
      (sum, r) => sum + r.dailyRate,
    );

    final double depositDailyInterest = (game.bankDepositBalance * 0.24) / 365.0;

    final double stockPortfolioValue = game.ownedStocks.fold<double>(
      0.0,
      (sum, s) {
        final currentStock = findFirstWhere(game.marketStocks, (m) => m.symbol == s.symbol);
        final price = currentStock?.currentPrice ?? s.averageCost;
        return sum + (s.quantity * price);
      },
    );
    final double stockDailyDividend = (stockPortfolioValue * 0.05) / 365.0;
    final double totalDailyIncome = sideBusinessIncome + rentalDailyIncome + depositDailyInterest + stockDailyDividend;

    // 2. Expenses
    double staffSalaries = game.hiredStaff.fold<double>(
      0.0,
      (sum, s) => sum + s.dailySalary,
    );
    if (game.specializationPath == SpecializationPath.boss) {
      staffSalaries *= 0.80; // 20% staff salary discount for Boss specialization
    }

    double propertyDailyBurn = 300.0;
    String propertyTierName = 'Kaldırım Başı Ayakçı Galerisi • Tier 1';
    if (game.unlockedBuildings.contains('property_tier_8')) {
      propertyDailyBurn = 75000.0;
      propertyTierName = 'Mega Otomotiv Holding Plazası • Tier 8';
    } else if (game.unlockedBuildings.contains('property_tier_7')) {
      propertyDailyBurn = 40000.0;
      propertyTierName = 'Lüks Koleksiyoner VIP Galeri • Tier 7';
    } else if (game.unlockedBuildings.contains('property_tier_6')) {
      propertyDailyBurn = 20000.0;
      propertyTierName = 'Premium Cam Showroom Plaza • Tier 6';
    } else if (game.unlockedBuildings.contains('property_tier_5')) {
      propertyDailyBurn = 9500.0;
      propertyTierName = 'Oto Center Kurumsal Galeri • Tier 5';
    } else if (game.unlockedBuildings.contains('property_tier_4')) {
      propertyDailyBurn = 4200.0;
      propertyTierName = 'Cadde Üstü Butik Oto Galeri • Tier 4';
    } else if (game.unlockedBuildings.contains('property_tier_3')) {
      propertyDailyBurn = 1800.0;
      propertyTierName = 'Sanayi Sitesi Esnaf Galerisi • Tier 3';
    } else if (game.unlockedBuildings.contains('property_tier_2')) {
      propertyDailyBurn = 750.0;
      propertyTierName = 'Mahalle Tipi Açık Oto Galeri • Tier 2';
    }

    final double loanDailyPayment = game.activeLoans.fold<double>(
      0.0,
      (sum, l) => sum + l.monthlyPayment,
    );

    final double dailyTaxEstimate = game.dailyTaxRate;
    final double totalDailyExpense = staffSalaries + propertyDailyBurn + loanDailyPayment + dailyTaxEstimate;

    final double netDailyCashflow = totalDailyIncome - totalDailyExpense;

    return CashflowSummary(
      sideBusinessIncome: sideBusinessIncome,
      rentalDailyIncome: rentalDailyIncome,
      depositDailyInterest: depositDailyInterest,
      stockPortfolioValue: stockPortfolioValue,
      stockDailyDividend: stockDailyDividend,
      totalDailyIncome: totalDailyIncome,
      staffSalaries: staffSalaries,
      propertyDailyBurn: propertyDailyBurn,
      propertyTierName: propertyTierName,
      loanDailyPayment: loanDailyPayment,
      dailyTaxEstimate: dailyTaxEstimate,
      totalDailyExpense: totalDailyExpense,
      netDailyCashflow: netDailyCashflow,
      isProfitable: netDailyCashflow > 0,
      isNeutral: netDailyCashflow == 0,
    );
  }
}
