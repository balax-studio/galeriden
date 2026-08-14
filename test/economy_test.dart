import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Economy and Passive Income System Tests', () {
    late GameNotifier gameNotifier;
    late CarModel testCar;
    
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      
      // Wait for async load to finish
      await Future.delayed(const Duration(milliseconds: 100));
      
      testCar = CarModel(
        id: 'test_car_1',
        brand: 'TestBrand',
        modelName: 'TestModel',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: 'FFFFFF',
        baseMarketValue: 100000,
        currentPurchasePrice: 50000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        customListingPrice: 120000,
      );
      // Give initial state
      gameNotifier.completeTutorial(); // complete tutorial to avoid 50k bonus
      gameNotifier.buyCarDirectly(testCar, 50000);
    });
    
    tearDown(() {
      gameNotifier.dispose();
    });

    test('accepting an installment offer creates a contract', () {
      final offer = OfferModel(
        id: 'offer_inst',
        carId: testCar.id,
        buyerName: 'Ahmet',
        offeredAmount: 100000,
        buyerMessage: 'Test',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        offerType: OfferType.installment,
      );
      
      final initialBalance = gameNotifier.state.balance;
      
      gameNotifier.acceptOffer(offer);
      
      final state = gameNotifier.state;
      
      expect(state.ownedCars.any((c) => c.id == testCar.id), isFalse);
      expect(state.activeInstallments.length, 1);
      final contract = state.activeInstallments.first;
      expect(contract.totalAmount, 100000);
      expect(contract.installmentAmount, 20000); 
      expect(contract.daysUntilNextPayment, 30);
      expect(state.balance, initialBalance);
    });

    test('accepting a cheque offer creates a cheque', () {
      final offer = OfferModel(
        id: 'offer_cheque',
        carId: testCar.id,
        buyerName: 'Mehmet',
        offeredAmount: 95000,
        buyerMessage: 'Test',
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        offerType: OfferType.cheque,
      );
      
      final initialBalance = gameNotifier.state.balance;
      
      gameNotifier.acceptOffer(offer);
      
      final state = gameNotifier.state;
      
      expect(state.ownedCars.any((c) => c.id == testCar.id), isFalse);
      expect(state.activeCheques.length, 1);
      final cheque = state.activeCheques.first;
      expect(cheque.amount, 95000);
      expect(cheque.daysUntilDue, 30);
      expect(state.balance, initialBalance);
    });

    test('renting a car', () {
      final success = gameNotifier.rentCar(testCar.id, 1000.0);
      expect(success, isTrue);
      
      expect(gameNotifier.state.activeRentals.length, 1);
      final rental = gameNotifier.state.activeRentals.first;
      expect(rental.carId, testCar.id);
      expect(rental.dailyRate, 600.0);
      
      final car = gameNotifier.state.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(car.isRented, isTrue);
    });
    
    test('returning a rented car', () {
      gameNotifier.rentCar(testCar.id, 1000.0);
      final rentalId = gameNotifier.state.activeRentals.first.id;

      final success = gameNotifier.returnRentedCar(rentalId);
      expect(success, isTrue);

      expect(gameNotifier.state.activeRentals.isEmpty, isTrue);

      final car = gameNotifier.state.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(car.isRented, isFalse);
    });

    test('returning an orphan rented car cleans up agreement', () {
      gameNotifier.rentCar(testCar.id, 1000.0);
      final rentalId = gameNotifier.state.activeRentals.first.id;

      // Remove car from ownedCars to simulate car deletion/sale
      gameNotifier.state = gameNotifier.state.copyWith(
        ownedCars: gameNotifier.state.ownedCars.where((c) => c.id != testCar.id).toList(),
      );

      final success = gameNotifier.returnRentedCar(rentalId);
      expect(success, isTrue);
      expect(gameNotifier.state.activeRentals.isEmpty, isTrue);
    });

    test('syncRentalState auto-heals desynced car flags', () {
      final carId = gameNotifier.state.ownedCars.first.id;
      gameNotifier.rentCar(carId, 1000.0);
      
      // Manually tamper isRented to false
      final car = gameNotifier.state.ownedCars.firstWhere((c) => c.id == carId);
      final tamperedCar = car.copyWith(isRented: false);
      gameNotifier.state = gameNotifier.state.copyWith(ownedCars: [tamperedCar]);

      // Call syncRentalState
      gameNotifier.syncRentalState();

      final healedCar = gameNotifier.state.ownedCars.firstWhere((c) => c.id == carId);
      expect(healedCar.isRented, isTrue);
    });

    test('purchasing and upgrading side business level', () {
      // Find sb_9 (Kurumsal Oto Ekspertiz Bayii)
      final business = gameNotifier.state.sideBusinesses.firstWhere((b) => b.id == 'sb_9');
      expect(business.isOwned, isFalse);
      expect(business.level, 1);

      // Add enough money to buy and upgrade
      gameNotifier.state = gameNotifier.state.copyWith(balance: 1000000.0);

      final buySuccess = gameNotifier.buySideBusiness('sb_9');
      expect(buySuccess, isTrue);

      var updated = gameNotifier.state.sideBusinesses.firstWhere((b) => b.id == 'sb_9');
      expect(updated.isOwned, isTrue);
      expect(updated.level, 1);

      // Verify Net Income (Gross minus 15% maintenance)
      expect(updated.grossDailyIncome, 7500.0);
      expect(updated.dailyMaintenanceExpense, 1125.0);
      expect(updated.effectiveDailyIncome, 6375.0);

      // Upgrade level to 2
      final upgradeSuccess = gameNotifier.upgradeSideBusiness('sb_9');
      expect(upgradeSuccess, isTrue);

      updated = gameNotifier.state.sideBusinesses.firstWhere((b) => b.id == 'sb_9');
      expect(updated.level, 2);
      expect(updated.grossDailyIncome, 10125.0); // 7500 * (1 + 0.35)
      expect(updated.effectiveDailyIncome, 8606.25); // 10125 * 0.85
    });
  });
}
