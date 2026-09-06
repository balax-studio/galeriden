import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/tenant_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/rental_agreement_model.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/cashflow_engine.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  group('Task 5 • Cashflow and Finance Audit Tests (B3)', () {
    test('effectiveDailyTax calculates dynamic progressive tax from LoanSettlementEngine', () {
      final baseDealer = DealershipModel.initial();
      expect(baseDealer.level, 1);
      // Level 1 base tax is 250.0 (wealth tax = 0 since balance <= 500k)
      expect(baseDealer.effectiveDailyTax, 250.0);
      expect(baseDealer.dailyTaxRate, 250.0);

      // Level 8 top tier corporate tax (5000.0) + wealth tax on 1.5M liquid assets (1.5M - 500k = 1M * 0.001 = 1000.0)
      final wealthyPlaza = baseDealer.copyWith(
        level: 8,
        balance: 1000000.0,
        bankDepositBalance: 500000.0,
      );
      expect(wealthyPlaza.effectiveDailyTax, 5000.0 + 1000.0);
      expect(wealthyPlaza.dailyTaxRate, wealthyPlaza.effectiveDailyTax);
    });

    test('CashflowEngine computes weekly loan proration, real estate rent, consignment parking, and deeds', () {
      final baseDealer = DealershipModel.initial();

      final activeLoan = LoanModel(
        id: 'loan_1',
        bankName: 'Girişimci Bankası',
        principalAmount: 70000.0,
        remainingAmount: 70000.0,
        totalRepayment: 70000.0,
        totalInstallments: 10,
        monthlyPayment: 7000.0, // Weekly installment is 7000, so daily proration is 1000.0
        remainingInstallments: 10,
        interestRate: 0.1,
      );

      final rentedProperty = RealEstateModel(
        id: 'prop_apt_1',
        title: 'Lüks Rezidans Dairesi',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Merkez',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        currentPurchasePrice: 2500000.0,
        baseMarketValue: 2500000.0,
        currentTenant: const TenantModel(
          id: 'tenant_1',
          name: 'Ahmet Bey',
          profession: 'Mühendis',
          monthlyRent: 30000.0, // dailyRentIncome = 1000.0
          reliabilityScore: 90,
          evictionRiskScore: 10,
          depositAmount: 60000.0,
        ),
        isRented: true,
      );

      final consignmentCar = CarModel(
        id: 'car_consignment_1',
        brand: 'Mercedo',
        modelName: 'C200',
        modelYear: 2021,
        bodyType: 'Sedan',
        currentPurchasePrice: 0.0,
        baseMarketValue: 1500000.0,
        colorHex: '#FFFFFF',
        isConsignment: true,
        consignmentCommissionRate: 0.08,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final rentalAgreement = RentalAgreement(
        id: 'rental_1',
        carId: 'car_rent_1',
        renterName: 'Kiralık Müşteri',
        dailyRate: 1500.0,
      );

      final testDealer = baseDealer.copyWith(
        activeLoans: [activeLoan],
        ownedRealEstates: [rentedProperty],
        ownedCars: [consignmentCar],
        activeRentals: [rentalAgreement],
        ownedBranchDeeds: {'branch_1'},
      );

      final summary = CashflowEngine.calculate(testDealer);

      // Loan daily payment must be 7000 / 7 = 1000.0
      expect(summary.loanDailyPayment, 1000.0);

      // Real estate rent income must be 1000.0
      expect(summary.realEstateRentIncome, 1000.0);

      // Vehicle rental is 1500.0, combined rental is 2500.0
      expect(summary.rentalDailyIncome, 2500.0);

      // Consignment parking fee for Tier 1 branch is 300.0
      expect(summary.consignmentParkingIncome, ConsignmentEngine.calculateDailyParkingFee(1));
      expect(summary.consignmentParkingIncome, 300.0);

      // Deed dues must be 1 * 1250.0 = 1250.0
      expect(summary.deedDues, 1250.0);

      // Daily tax estimate must match effectiveDailyTax
      expect(summary.dailyTaxEstimate, testDealer.effectiveDailyTax);
    });

    test('All 7 translation files include new cashflow keys without emojis or parentheses', () {
      final requiredKeys = [
        'cashflow_income_real_estate_title',
        'cashflow_income_real_estate_desc',
        'cashflow_income_consignment_title',
        'cashflow_income_consignment_desc',
        'cashflow_expense_deed_dues_title',
        'cashflow_expense_deed_dues_desc',
        'cashflow_expense_loans_desc',
      ];

      final maps = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'es': esTranslations,
        'pt': ptTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final emojiRegex = RegExp(
          r'[\u{1F300}-\u{1F6FF}\u{1F900}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
          unicode: true);

      for (final entry in maps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in requiredKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Language $lang is missing translation key $key');
          final value = map[key]!;
          expect(value.isNotEmpty, isTrue,
              reason: 'Translation for $key in $lang is empty');
          expect(emojiRegex.hasMatch(value), isFalse,
              reason: 'Invariant violation: emoji found in $lang for key $key: $value');
          expect(value.contains('(') || value.contains(')'), isFalse,
              reason: 'Invariant violation: parentheses found in $lang for key $key: $value');
        }
      }
    });
  });
}
