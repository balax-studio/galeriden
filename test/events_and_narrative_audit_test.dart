import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/utils/color_parser.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Events & Narrative Audit Tests (Task 6: A6, B5, B7, C3)', () {
    test('B5: ColorParser parses hex codes robustly without exception', () {
      final c1 = ColorParser.parseCarColor('#D90429');
      expect(c1.r, greaterThan(0));

      final c2 = ColorParser.parseCarColor('0xFF112233');
      expect(c2.a, equals(1.0));

      final c3 = ColorParser.parseCarColor('AABBCC');
      expect(c3.b, greaterThan(0));

      final c4 = ColorParser.parseCarColor(null);
      expect(c4, equals(ColorParser.defaultCarFallbackColor));

      final c5 = ColorParser.parseCarColor('invalid_hex');
      expect(c5, equals(ColorParser.defaultCarFallbackColor));
    });

    test('C3 & game_event_model: GameEventChoice serialization with mechanics', () {
      const choice = GameEventChoice(
        label: 'Cezayı Kabul Et • -60.000 ₺',
        resultText: 'Yediemine çekildi',
        balanceChange: -60000.0,
        reputationChange: -20,
        targetCarEffect: 'impound',
        sideBusinessId: 'car_wash',
        sideBusinessDowntimeDays: 2,
        staffMoraleChange: -10,
      );

      final json = choice.toJson();
      expect(json['targetCarEffect'], equals('impound'));
      expect(json['sideBusinessId'], equals('car_wash'));
      expect(json['sideBusinessDowntimeDays'], equals(2));
      expect(json['staffMoraleChange'], equals(-10));

      final deserialized = GameEventChoice.fromJson(json);
      expect(deserialized.targetCarEffect, equals('impound'));
      expect(deserialized.sideBusinessId, equals('car_wash'));
      expect(deserialized.sideBusinessDowntimeDays, equals(2));
      expect(deserialized.staffMoraleChange, equals(-10));
    });

    test('A6 & C3: resolveRandomEvent guards insufficient funds & executes consequences', () {
      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      // Setup initial state: 10,000 balance, 1 car, 1 car wash side business, 1 staff
      final car = CarModel(
        id: 'test_car_1',
        brand: 'Vosgen',
        modelName: 'Polo',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '#FFFFFF',
        baseMarketValue: 200000,
        currentPurchasePrice: 190000,
        maintenanceCost: 0,
        isDetailedCleaned: true,
        isWashed: true,
        isPolished: false,
        isRare: false,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: {'Kaput': PartStatus.original},
        ),
        declarationType: ListingDeclarationType.honest,
      );

      final carWash = SideBusinessModel(
        id: 'sb_2',
        name: 'Oto Yıkama',
        type: SideBusinessType.carWash,
        dailyIncome: 1000,
        cost: 50000,
        isOwned: true,
      );

      final staff = StaffModel(
        id: 'staff_1',
        name: 'Ali Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        morale: 80,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        ownedCars: [car],
        sideBusinesses: [carWash],
        hiredStaff: [staff],
      );

      // 1. Guard check: Choice costs 25,000 but balance is 10,000 -> Should return without mutating
      const expensiveChoice = GameEventChoice(
        label: 'Ağır Ceza',
        resultText: 'Para yetmiyor',
        balanceChange: -25000.0,
        targetCarEffect: 'impound',
      );

      notifier.resolveRandomEvent(expensiveChoice);
      expect(notifier.state.balance, equals(10000.0));
      expect(notifier.state.ownedCars.length, equals(1));

      // 2. Mechanical consequence: side business downtime & staff morale
      const downtimeChoice = GameEventChoice(
        label: 'Tamiri Bekle',
        resultText: '2 gün kapalı',
        balanceChange: -2000.0,
        sideBusinessId: 'car_wash',
        sideBusinessDowntimeDays: 2,
        staffMoraleChange: -15,
      );

      notifier.resolveRandomEvent(downtimeChoice);
      expect(notifier.state.balance, equals(8000.0));
      final updatedWash = notifier.state.sideBusinesses.firstWhere((b) => b.type == SideBusinessType.carWash);
      expect(updatedWash.isUnderConstruction, isTrue);
      expect(updatedWash.constructionDaysRemaining, equals(2));
      expect(notifier.state.hiredStaff.first.morale, equals(65));

      // 3. Mechanical consequence: car impound
      const impoundChoice = GameEventChoice(
        label: 'Yediemin',
        resultText: 'Araca el konuldu',
        balanceChange: -1000.0,
        targetCarEffect: 'impound',
      );

      notifier.resolveRandomEvent(impoundChoice);
      expect(notifier.state.balance, equals(7000.0));
      expect(notifier.state.ownedCars.isEmpty, isTrue);
    });
  });
}
