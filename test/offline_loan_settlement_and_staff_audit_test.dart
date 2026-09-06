import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';

void main() {
  final defaultExpertise = ExpertiseReport(
    engineCondition: 90.0,
    transmissionCondition: 90.0,
    tramerAmount: 0,
    mileage: 50000,
    isMileageTampered: false,
    bodyParts: {},
  );

  group('A2 & A3: Offline Progression Loan Settlement & Staff Automation Parity', () {
    test('A3: Advancing from day 6 to day 9 via offline catch-up deducts day 7 loan installment', () {
      final now = DateTime.now();
      final loan = LoanModel(
        id: 'loan_1',
        bankName: 'Halk Finans',
        principalAmount: 70000.0,
        remainingAmount: 70000.0,
        interestRate: 0.10,
        totalRepayment: 70000.0,
        totalInstallments: 7,
        monthlyPayment: 10000.0,
        remainingInstallments: 7,
      );

      final initialDealership = DealershipModel.initial().copyWith(
        currentDay: 6,
        balance: 50000.0,
        activeLoans: [loan],
        lastActiveTime: now.subtract(const Duration(minutes: 90)), // 90 min = 3 simulated days -> Day 9
      );

      final result = OfflineProgression.processOfflineTime(initialDealership, currentTime: now);
      final updatedDealership = result['updatedDealership'] as DealershipModel;

      expect(updatedDealership.currentDay, equals(9));
      // Loan installment of 10000 must be deducted on day 7
      expect(updatedDealership.activeLoans.first.remainingInstallments, equals(6));
      expect(updatedDealership.activeLoans.first.remainingAmount, equals(60000.0));
    });

    test('A2: Staff automation respects simulatedDays and daily limits (no instant whole-garage fix)', () {
      final now = DateTime.now();
      final washer = StaffModel(
        id: 'staff_w',
        name: 'Yıkamacı Ali',
        role: StaffRole.washer,
        hiredAt: now,
        energy: 100,
      );

      // Create 6 dirty unpolished cars
      final dirtyCars = List.generate(
        6,
        (i) => CarModel(
          id: 'car_$i',
          brand: 'Toyo',
          modelName: 'Corolla',
          modelYear: 2015,
          bodyType: 'Sedan',
          colorHex: '#FFFFFF',
          colorDisplayName: 'Beyaz',
          colorRarity: 'common',
          plateNumber: '34 ABC 0$i',
          plateRarity: 'common',
          currentPurchasePrice: 100000.0,
          baseMarketValue: 120000.0,
          isWashed: false,
          isPolished: false,
          isDetailedCleaned: false,
          expertise: defaultExpertise,
        ),
      );

      final dealership = DealershipModel.initial().copyWith(
        currentDay: 1,
        hiredStaff: [washer],
        ownedCars: dirtyCars,
        lastActiveTime: now.subtract(const Duration(minutes: 30)), // 30 min = 1 simulated day
      );

      final result = OfflineProgression.processOfflineTime(dealership, currentTime: now);
      final updatedDealership = result['updatedDealership'] as DealershipModel;

      // In 1 simulated day, without car wash side business, max 2 cars washed
      final washedCount = updatedDealership.ownedCars.where((c) => c.isWashed).length;
      expect(washedCount, equals(2), reason: 'Washer can wash at most 2 cars per simulated day');
      expect(updatedDealership.ownedCars.where((c) => !c.isWashed).length, equals(4));
    });

    test('A2: Zero simulated days (< 2 min) runs NO staff automation', () {
      final now = DateTime.now();
      final washer = StaffModel(
        id: 'staff_w',
        name: 'Yıkamacı Ali',
        role: StaffRole.washer,
        hiredAt: now,
        energy: 100,
      );

      final dirtyCar = CarModel(
        id: 'car_1',
        brand: 'Toyo',
        modelName: 'Corolla',
        modelYear: 2015,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        colorDisplayName: 'Beyaz',
        colorRarity: 'common',
        plateNumber: '34 ABC 01',
        plateRarity: 'common',
        currentPurchasePrice: 100000.0,
        baseMarketValue: 120000.0,
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        expertise: defaultExpertise,
      );

      final dealership = DealershipModel.initial().copyWith(
        currentDay: 1,
        hiredStaff: [washer],
        ownedCars: [dirtyCar],
        lastActiveTime: now.subtract(const Duration(seconds: 45)), // < 2 min
      );

      final result = OfflineProgression.processOfflineTime(dealership, currentTime: now);
      final updatedDealership = result['updatedDealership'] as DealershipModel;

      expect(updatedDealership.ownedCars.first.isWashed, isFalse, reason: 'No staff action if < 2 mins');
    });
  });
}
