import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/services/daily_loan_processor.dart';
import 'package:galeriden/domain/services/daily_rental_processor.dart';
import 'package:galeriden/domain/services/daily_staff_processor.dart';

void main() {
  group('Modül 4: Substates & Daily Processors Tests', () {
    test('DealershipModel exposes logical substates correctly', () {
      final defaultModel = DealershipModel.initial();

      // Test InventorySubstate
      final inv = defaultModel.inventory;
      expect(inv.ownedCars.length, 1);
      expect(inv.salesHistory, isEmpty);
      final updatedInv = inv.copyWith(ownedCars: [
        CarModel(
          id: 'test_car',
          brand: 'Fiat',
          modelName: 'Egea',
          modelYear: 2022,
          bodyType: 'Sedan',
          colorHex: '#FFFFFF',
          baseMarketValue: 600000,
          currentPurchasePrice: 550000,
          expertise: ExpertiseReport(
            engineCondition: 100,
            transmissionCondition: 100,
            tramerAmount: 0,
            mileage: 20000,
            isMileageTampered: false,
            bodyParts: {},
          ),
        ),
      ]);
      expect(updatedInv.ownedCars.length, 1);

      // Test RealEstateSubstate
      final re = defaultModel.realEstate;
      expect(re.ownedRealEstates, isEmpty);
      expect(re.maxRealEstateSlots, 5);

      // Test FinanceSubstate
      final fin = defaultModel.finance;
      expect(fin.balance, defaultModel.balance);
      expect(fin.bankCreditLimit, defaultModel.bankCreditLimit);
      expect(fin.activeLoans, isEmpty);

      // Test CompanySubstate
      final comp = defaultModel.company;
      expect(comp.playerName, defaultModel.playerName);
      expect(comp.dealershipName, defaultModel.dealershipName);
      expect(comp.reputationScore, 100);
      expect(comp.hiredStaff, isEmpty);
    });

    test('DailyStaffProcessor processes salaries and boss specialization discount', () {
      final staff = <StaffModel>[
        StaffModel(
          id: 'staff_1',
          name: 'Ali Usta',
          role: StaffRole.washer,
          hiredAt: DateTime.now(),
          energy: 100,
          morale: 80,
        ),
      ];
      final events = <GameEventModel>[];
      final washerSalary = staff.first.dailySalary; // e.g. 150.0

      // Normal salary processing (balance - washerSalary)
      final res1 = DailyStaffProcessor.processSalaries(
        balance: 50000.0,
        staff: staff,
        events: events,
        specializationPath: SpecializationPath.none,
      );
      expect(res1.$1, 50000.0 - washerSalary);
      expect(res1.$2.first.morale, 81); // Morale increases by 1 when paid

      // Boss specialization discount (-%20 salary: washerSalary * 0.80)
      final res2 = DailyStaffProcessor.processSalaries(
        balance: 50000.0,
        staff: staff,
        events: events,
        specializationPath: SpecializationPath.boss,
      );
      expect(res2.$1, 50000.0 - (washerSalary * 0.80));
    });

    test('DailyStaffProcessor handles staff automation: washing & repair', () {
      final washer = StaffModel(
        id: 'washer_1',
        name: 'Veli',
        role: StaffRole.washer,
        hiredAt: DateTime.now(),
        energy: 100,
        morale: 100,
      );

      final mechanic = StaffModel(
        id: 'mech_1',
        name: 'Hasan Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        energy: 100,
        morale: 100,
      );

      final dirtyCar = CarModel(
        id: 'dirty_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2021,
        bodyType: 'Hatchback',
        colorHex: '#000000',
        baseMarketValue: 400000,
        currentPurchasePrice: 380000,
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        expertise: ExpertiseReport(
          engineCondition: 60,
          transmissionCondition: 60,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final processedCars = DailyStaffProcessor.processStaffAutomation(
        staff: [washer, mechanic],
        cars: [dirtyCar],
        hasCarWashBusiness: false,
      );

      expect(processedCars.first.isWashed, isTrue);
      expect(processedCars.first.isPolished, isTrue);
      expect(processedCars.first.isDetailedCleaned, isTrue);
      expect(processedCars.first.expertise.engineCondition, 80.0);
      expect(processedCars.first.expertise.transmissionCondition, 80.0);
    });

    test('DailyLoanProcessor delegates loans and calculates weekly installments correctly', () {
      final loan = LoanModel(
        id: 'loan_1',
        bankName: 'Esnaf Bankası',
        principalAmount: 100000.0,
        interestRate: 0.10,
        totalRepayment: 110000.0,
        remainingAmount: 110000.0,
        totalInstallments: 7,
        remainingInstallments: 7,
        monthlyPayment: 15714.0,
      );

      // On day 7, loan processes installment
      final res = DailyLoanProcessor.processLoans(
        nextDay: 7,
        balance: 150000.0,
        loans: [loan],
      );

      expect(res.$1, lessThan(150000.0));
    });

    test('DailyRentalProcessor processes fleet rentals with no exceptions', () {
      final res = DailyRentalProcessor.processRentals(
        balance: 50000.0,
        cars: [],
        rentals: [],
        events: [],
        incomingOffers: [],
        random: Random(42),
      );

      expect(res.$1, 50000.0);
      expect(res.$2, isEmpty);
      expect(res.$3, isEmpty);
    });
  });
}
