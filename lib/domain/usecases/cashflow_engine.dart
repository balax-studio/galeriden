import '../../core/utils/iterable_extensions.dart';
import '../../data/models/dealership_model.dart';
import 'consignment_engine.dart';
import 'side_business_engine.dart';

class CashflowSummary {
  final double sideBusinessIncome;
  final double rentalDailyIncome;
  final double realEstateRentIncome;
  final double consignmentParkingIncome;
  final double depositDailyInterest;
  final double stockPortfolioValue;
  final double stockDailyDividend;
  final double totalDailyIncome;

  final double staffSalaries;
  final double propertyDailyBurn;
  final double deedDues;
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
    required this.realEstateRentIncome,
    required this.consignmentParkingIncome,
    required this.depositDailyInterest,
    required this.stockPortfolioValue,
    required this.stockDailyDividend,
    required this.totalDailyIncome,
    required this.staffSalaries,
    required this.propertyDailyBurn,
    required this.deedDues,
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
    // 1. Incomes
    // Side businesses use single source of truth from SideBusinessEngine
    final double sideBusinessIncome = SideBusinessEngine.calculateDailyIncome(game);

    final double vehicleRentalDailyIncome = game.activeRentals.fold<double>(
      0.0,
      (sum, r) => sum + r.dailyRate,
    );

    final double realEstateRentIncome = game.ownedRealEstates
        .where((p) => p.isRented && p.currentTenant != null)
        .fold<double>(0.0, (sum, p) => sum + p.dailyRentIncome);

    final double rentalDailyIncome = vehicleRentalDailyIncome + realEstateRentIncome;

    final double consignmentParkingIncome = game.ownedCars
        .where((c) => c.isConsignment)
        .fold<double>(
          0.0,
          (sum, c) => sum + ConsignmentEngine.calculateDailyParkingFee(game.currentBranchTier),
        );

    final double depositDailyInterest = game.bankDepositBalance >= 100.0
        ? (game.bankDepositBalance * 0.0012).roundToDouble()
        : 0.0;

    final double stockPortfolioValue = game.ownedStocks.fold<double>(
      0.0,
      (sum, s) {
        final currentStock = findFirstWhere(game.marketStocks, (m) => m.symbol == s.symbol);
        final price = currentStock?.currentPrice ?? s.averageCost;
        return sum + (s.quantity * price);
      },
    );
    final double stockDailyDividend = (stockPortfolioValue * 0.05) / 365.0;
    final double totalDailyIncome = sideBusinessIncome +
        rentalDailyIncome +
        consignmentParkingIncome +
        depositDailyInterest +
        stockDailyDividend;

    // 2. Expenses
    double staffSalaries = game.hiredStaff.fold<double>(
      0.0,
      (sum, s) => sum + s.dailySalary,
    );
    if (game.specializationPath == SpecializationPath.boss) {
      staffSalaries *= 0.80; // 20% staff salary discount for Boss specialization
    }

    final double propertyDailyBurn = game.dailyPropertyRentBurn;
    final double deedDues = game.ownedBranchDeeds.length * 1250.0;
    final String propertyTierName = switch (game.currentBranchTier) {
      8 => 'Mega Otomotiv Holding Plazası • Tier 8',
      7 => 'Lüks Koleksiyoner VIP Galeri • Tier 7',
      6 => 'Premium Cam Showroom Plaza • Tier 6',
      5 => 'Oto Center Kurumsal Galeri • Tier 5',
      4 => 'Cadde Üstü Butik Oto Galeri • Tier 4',
      3 => 'Sanayi Sitesi Esnaf Galerisi • Tier 3',
      2 => 'Mahalle Tipi Açık Oto Galeri • Tier 2',
      _ => 'Kaldırım Başı Ayakçı Galerisi • Tier 1',
    };

    // Bank loan installments are deducted weekly (every 7 days)
    // Show daily equivalent for truthful cashflow representation (B3)
    final double loanDailyPayment = game.activeLoans.fold<double>(
      0.0,
      (sum, l) => sum + (l.monthlyPayment / 7.0),
    );

    final double dailyTaxEstimate = game.effectiveDailyTax;
    final double totalDailyExpense = staffSalaries + propertyDailyBurn + loanDailyPayment + dailyTaxEstimate;

    final double netDailyCashflow = totalDailyIncome - totalDailyExpense;

    return CashflowSummary(
      sideBusinessIncome: sideBusinessIncome,
      rentalDailyIncome: rentalDailyIncome,
      realEstateRentIncome: realEstateRentIncome,
      consignmentParkingIncome: consignmentParkingIncome,
      depositDailyInterest: depositDailyInterest,
      stockPortfolioValue: stockPortfolioValue,
      stockDailyDividend: stockDailyDividend,
      totalDailyIncome: totalDailyIncome,
      staffSalaries: staffSalaries,
      propertyDailyBurn: propertyDailyBurn,
      deedDues: deedDues,
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
