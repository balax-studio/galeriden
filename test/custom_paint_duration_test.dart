import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/workshop_job_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Workshop Custom Paint 1-Day Duration & Oven Curing Suite', () {
    late ProviderContainer container;
    late CarModel testCar;
    late CustomPaintColor testPaint;

    setUp(() {
      container = ProviderContainer();

      testCar = CarModel(
        id: 'car_paint_test_001',
        brand: 'Bimmer',
        modelName: 'M3 Competition',
        modelYear: 2023,
        bodyType: 'Sedan',
        colorHex: '#000000',
        colorDisplayName: 'Metalik Siyah',
        baseMarketValue: 500000,
        currentPurchasePrice: 420000,
        expertise: ExpertiseReport(
          bodyParts: {
            'Kaput': PartStatus.original,
            'Tavan': PartStatus.original,
          },
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
        ),
      );

      testPaint = CustomPaintColor.palette.firstWhere(
        (p) => p.name.contains('Nardo') || p.name.contains('Gri'),
        orElse: () => CustomPaintColor.palette.first,
      );

      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(
                currentDay: 10,
                balance: 200000,
                ownedCars: [testCar],
              );
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('1. Starting custom paint respray puts vehicle in oven without instant color change', () {
      final notifier = container.read(gameProvider.notifier);
      final initialBalance = container.read(gameProvider).balance;

      final success = notifier.applyCustomPaintRespray(testCar.id, testPaint);
      expect(success, isTrue);

      final updatedState = container.read(gameProvider);
      expect(updatedState.balance, equals(initialBalance - testPaint.cost));

      final updatedCar = updatedState.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(updatedCar.isPainting, isTrue);
      expect(updatedCar.paintReadyDay, equals(11)); // currentDay (10) + 1
      expect(updatedCar.pendingPaintHex, equals(testPaint.hex));
      expect(updatedCar.pendingPaintName, equals(testPaint.name));

      // Color MUST NOT be changed yet on day 0
      expect(updatedCar.colorHex, equals('#000000'));
      expect(updatedCar.colorDisplayName, equals('Metalik Siyah'));
    });

    test('2. Duplicate paint order on a vehicle currently in oven is rejected', () {
      final notifier = container.read(gameProvider.notifier);

      final firstCall = notifier.applyCustomPaintRespray(testCar.id, testPaint);
      expect(firstCall, isTrue);

      // Attempt to repaint the same car while curing in oven
      final anotherPaint = CustomPaintColor.palette.last;
      final secondCall = notifier.applyCustomPaintRespray(testCar.id, anotherPaint);
      expect(secondCall, isFalse);

      final car = container.read(gameProvider).ownedCars.first;
      expect(car.pendingPaintName, equals(testPaint.name));
    });

    test('3. Advancing calendar day (advanceGameDay) completes paint, applies new color, and resets oven status', () {
      final notifier = container.read(gameProvider.notifier);

      notifier.applyCustomPaintRespray(testCar.id, testPaint);
      expect(container.read(gameProvider).ownedCars.first.isPainting, isTrue);

      final initialXP = container.read(gameProvider).skills.xp;

      // Advance game day from Day 10 to Day 11
      notifier.advanceGameDay();

      final newState = container.read(gameProvider);
      expect(newState.currentDay, equals(11));

      final curedCar = newState.ownedCars.firstWhere((c) => c.id == testCar.id);
      expect(curedCar.isPainting, isFalse);
      expect(curedCar.paintReadyDay, equals(0));
      expect(curedCar.pendingPaintHex, isNull);
      expect(curedCar.pendingPaintName, isNull);

      // New color is now officially applied
      expect(curedCar.colorHex, equals(testPaint.hex));
      expect(curedCar.colorDisplayName, equals(testPaint.name));

      // XP is awarded on paint completion
      expect(newState.skills.xp, greaterThan(initialXP));
    });

    test('4. JSON serialization and deserialization preserves pending paint status', () {
      final paintingCar = testCar.copyWith(
        paintReadyDay: 14,
        pendingPaintHex: '#E11D48',
        pendingPaintName: 'Lansman Kırmızı',
        pendingPaintRarity: 'rare',
      );

      final json = paintingCar.toJson();
      final deserialized = CarModel.fromJson(json);

      expect(deserialized.isPainting, isTrue);
      expect(deserialized.paintReadyDay, equals(14));
      expect(deserialized.pendingPaintHex, equals('#E11D48'));
      expect(deserialized.pendingPaintName, equals('Lansman Kırmızı'));
      expect(deserialized.pendingPaintRarity, equals('rare'));
    });
  });
}
