import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/domain/usecases/smart_office_hook_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CarModel createTestCar({
    required String id,
    required String brand,
    required String modelName,
    bool isWashed = true,
    bool isPolished = true,
    bool isDetailedCleaned = true,
    double engineCondition = 100.0,
    double transmissionCondition = 100.0,
    bool isListed = false,
  }) {
    return CarModel(
      id: id,
      brand: brand,
      modelName: modelName,
      modelYear: 2021,
      bodyType: 'Sedan',
      colorHex: '#000000',
      currentPurchasePrice: 500000.0,
      baseMarketValue: 500000.0,
      customListingPrice: isListed ? 550000.0 : null,
      isWashed: isWashed,
      isPolished: isPolished,
      isDetailedCleaned: isDetailedCleaned,
      expertise: ExpertiseReport(
        engineCondition: engineCondition,
        transmissionCondition: transmissionCondition,
        tramerAmount: 0,
        mileage: 50000,
        isMileageTampered: false,
        bodyParts: {'Kaput': PartStatus.original, 'Tavan': PartStatus.original},
      ),
    );
  }

  group('4th Exotic Neo-Pop Theme & Ad-Unlock Tests', () {
    test('ThemePaletteModel contains 4 curated palettes including egzotik_neo_pop', () {
      final palettes = ThemePaletteModel.defaultPalettes;
      expect(palettes.length, equals(4));

      final exotic = palettes.firstWhere((p) => p.id == 'egzotik_neo_pop');
      expect(exotic.name, contains('Egzotik Neo-Pop'));
      expect(exotic.isAdUnlockable, isTrue);
      expect(exotic.isUnlocked, isFalse);

      final cyber = palettes.firstWhere((p) => p.id == 'toksik_asit_cyber');
      expect(cyber.isAdUnlockable, isTrue);
    });

    test('ThemePaletteModel JSON serialization preserves exotic palette', () {
      final exotic = ThemePaletteModel.defaultPalettes.firstWhere((p) => p.id == 'egzotik_neo_pop');
      final json = exotic.toJson();
      final reconstructed = ThemePaletteModel.fromJson(json);

      expect(reconstructed.id, equals('egzotik_neo_pop'));
      expect(reconstructed.primaryColor.toARGB32(), equals(exotic.primaryColor.toARGB32()));
      expect(reconstructed.backgroundColor.toARGB32(), equals(exotic.backgroundColor.toARGB32()));
    });

    test('ThemeNotifier unlockPaletteViaAd unlocks both Theme 3 and Theme 4 instantly', () async {
      SharedPreferences.setMockInitialValues({});
      final themeNotifier = ThemeNotifier();

      // Unlock Theme 3 via Ad
      final cyberSuccess = themeNotifier.unlockPaletteViaAd('toksik_asit_cyber');
      expect(cyberSuccess, isTrue);
      expect(themeNotifier.state.activePalette.id, equals('toksik_asit_cyber'));
      expect(themeNotifier.state.availablePalettes.firstWhere((p) => p.id == 'toksik_asit_cyber').isUnlocked, isTrue);

      // Unlock Theme 4 via Ad
      final exoticSuccess = themeNotifier.unlockPaletteViaAd('egzotik_neo_pop');
      expect(exoticSuccess, isTrue);
      expect(themeNotifier.state.activePalette.id, equals('egzotik_neo_pop'));
      expect(themeNotifier.state.availablePalettes.firstWhere((p) => p.id == 'egzotik_neo_pop').isUnlocked, isTrue);
    });
  });

  group('Office +₺25.000 Rewarded Ad Grant Tests', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
      notifier.state = DealershipModel.initial().copyWith(balance: 10000.0);
    });

    test('claimOfficeAdGrant awards ₺25.000 cash and adds XP', () {
      final initialBalance = notifier.state.balance;
      final grant = notifier.claimOfficeAdGrant();

      expect(grant, equals(25000.0));
      expect(notifier.state.balance, equals(initialBalance + 25000.0));
      expect(notifier.state.experience, greaterThan(0));
    });
  });

  group('SmartOfficeHookEngine & Dynamic Reward Execution Tests', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
    });

    test('Evaluates dirtyCarsWash when unwashed cars exist and executes mass wash', () {
      final unwashedCar1 = createTestCar(id: 'c1', brand: 'BMW', modelName: '320i', isWashed: false, isPolished: false);
      final unwashedCar2 = createTestCar(id: 'c2', brand: 'Audi', modelName: 'A4', isWashed: false, isPolished: false);

      notifier.state = notifier.state.copyWith(
        balance: 150000.0,
        ownedCars: [unwashedCar1, unwashedCar2],
      );

      final hook = SmartOfficeHookEngine.evaluate(notifier.state);
      expect(hook.type, equals(SmartHookType.dirtyCarsWash));
      expect(hook.callerName, contains('Memo'));

      // Execute reward
      final success = notifier.executeSmartOfficeHook(hook.type);
      expect(success, isTrue);
      expect(notifier.state.ownedCars.every((c) => c.isWashed && c.isPolished && c.isDetailedCleaned), isTrue);
    });

    test('Evaluates damagedCarRepair when broken car exists and restores to 100%', () {
      final brokenCar = createTestCar(id: 'c1', brand: 'Ford', modelName: 'Mustang', engineCondition: 45.0, transmissionCondition: 50.0);
      final healthyCar = createTestCar(id: 'c2', brand: 'Toyota', modelName: 'Corolla');

      notifier.state = notifier.state.copyWith(
        balance: 150000.0,
        ownedCars: [brokenCar, healthyCar],
      );

      final hook = SmartOfficeHookEngine.evaluate(notifier.state);
      expect(hook.type, equals(SmartHookType.damagedCarRepair));
      expect(hook.callerName, contains('Kadir'));

      // Execute reward
      final success = notifier.executeSmartOfficeHook(hook.type);
      expect(success, isTrue);
      final repairedCar = notifier.state.ownedCars.firstWhere((c) => c.id == 'c1');
      expect(repairedCar.expertise.engineCondition, equals(100.0));
      expect(repairedCar.expertise.transmissionCondition, equals(100.0));
    });

    test('Evaluates lowBalanceGrant when capital is under ₺50.000 and grants ₺35.000', () {
      final healthyCar1 = createTestCar(id: 'c1', brand: 'Toyota', modelName: 'Corolla');
      final healthyCar2 = createTestCar(id: 'c2', brand: 'Honda', modelName: 'Civic');

      notifier.state = notifier.state.copyWith(
        balance: 12000.0,
        ownedCars: [healthyCar1, healthyCar2],
      );

      final hook = SmartOfficeHookEngine.evaluate(notifier.state);
      expect(hook.type, equals(SmartHookType.lowBalanceGrant));
      expect(hook.callerName, contains('İbo'));

      // Execute reward
      final initialBalance = notifier.state.balance;
      final success = notifier.executeSmartOfficeHook(hook.type);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(initialBalance + 35000.0));
    });

    test('Evaluates emptyGarageSpawn when garage has <= 1 car and grants subsidy', () {
      notifier.state = notifier.state.copyWith(
        balance: 200000.0,
        ownedCars: [],
      );

      final hook = SmartOfficeHookEngine.evaluate(notifier.state);
      expect(hook.type, equals(SmartHookType.emptyGarageSpawn));
      expect(hook.callerName, contains('Selim'));

      final initialBalance = notifier.state.balance;
      final success = notifier.executeSmartOfficeHook(hook.type);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(initialBalance + 10000.0));
    });

    test('Evaluates viralReputationBoost when dealership is flourishing and boosts prestige', () {
      final car1 = createTestCar(id: 'c1', brand: 'BMW', modelName: 'M4', isListed: true);
      final car2 = createTestCar(id: 'c2', brand: 'Mercedes', modelName: 'C63', isListed: true);

      notifier.state = notifier.state.copyWith(
        balance: 300000.0,
        reputationScore: 70,
        ownedCars: [car1, car2],
      );

      final hook = SmartOfficeHookEngine.evaluate(notifier.state);
      expect(hook.type, equals(SmartHookType.viralReputationBoost));
      expect(hook.callerName, contains('Berkcan'));

      final success = notifier.executeSmartOfficeHook(hook.type);
      expect(success, isTrue);
      expect(notifier.state.reputationScore, equals(95));
      expect(notifier.state.ownedCars.every((c) => c.isDoped), isTrue);
    });
  });
}
