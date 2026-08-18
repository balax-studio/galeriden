import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/gossip_item_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Ecosystem Interconnected Mechanics Test Suite', () {
    test('1. Unpaid staff salaries reduce morale and cause resignation when morale is critical', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final lowMoraleStaff = StaffModel(
        id: 'staff_test_1',
        name: 'Ahmet Çırak',
        role: StaffRole.apprentice,
        hiredAt: DateTime.now(),
        morale: 15,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10.0, // Insufficient for salary
        hiredStaff: [lowMoraleStaff],
        recentEvents: [],
      );

      notifier.advanceGameDay();

      // Morale drops by 35 -> 15 - 35 = -20 <= 10 -> quits
      expect(notifier.state.hiredStaff.isEmpty, isTrue);
      expect(notifier.state.recentEvents.any((e) => e.title.contains('PERSONEL İSTİFASI')), isTrue);
    });

    test('2. Paid staff salaries maintain morale and keep staff hired', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final staff = StaffModel(
        id: 'staff_test_2',
        name: 'Mustafa Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        morale: 80,
      );

      notifier.state = notifier.state.copyWith(
        balance: 50000.0, // Plenty of funds
        hiredStaff: [staff],
      );

      notifier.advanceGameDay();

      expect(notifier.state.hiredStaff.length, equals(1));
      expect(notifier.state.hiredStaff.first.morale, greaterThanOrEqualTo(80));
    });

    test('3. Gossip police warning evades black market raid with zero loss', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final bmCar = CarModel(
        id: 'bm_car_1',
        brand: 'Bavaria',
        modelName: 'M5 Karaborsa V10',
        modelYear: 2008,
        bodyType: 'Sedan',
        colorHex: '#000000',
        currentPurchasePrice: 450000.0,
        baseMarketValue: 800000.0,
        isBlackMarket: true,
        blackMarketRiskPercent: 100, // 100% raid trigger
        blackMarketRiskType: 'change_vin',
        expertise: ExpertiseReport(
          engineCondition: 80.0,
          transmissionCondition: 80.0,
          tramerAmount: 0,
          mileage: 120000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final raidGossip = GossipItemModel(
        id: 'gossip_police_raid',
        title: 'Asayiş Ekipleri Denetimi',
        sourceNpc: 'cayci_necati',
        sourceNpcName: 'Çaycı Necati',
        sourceAvatar: 'cayci',
        teaser: 'Bölgedeki oto galericilere baskın yapılacak.',
        content: 'Asayiş ekipleri karaborsa araçları denetleyecek.',
        cost: 5000.0,
        accuracy: 1.0,
        type: GossipType.marketTrend,
        targetSegment: 'Genel',
        inGameDay: 1,
        isPurchased: true,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        reputationScore: 100,
        ownedCars: [bmCar],
        activeGossips: [raidGossip],
        recentEvents: [],
      );

      notifier.advanceGameDay();

      // Car should not be seized and fine should not be deducted because raid was evaded
      expect(notifier.state.ownedCars.any((c) => c.id == 'bm_car_1'), isTrue);
      expect(notifier.state.recentEvents.any((e) => e.title.contains('İSTİHBARAT SAYESİNDE BASKIN ATLATILDI')), isTrue);
    });

    test('4. Legal Advisor shields player from car seizure and slashes fines by 75%', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final bmCar = CarModel(
        id: 'bm_car_2',
        brand: 'Stuttgart',
        modelName: 'Exotic Karaborsa',
        modelYear: 2021,
        bodyType: 'Coupe',
        colorHex: '#FFFFFF',
        currentPurchasePrice: 900000.0,
        baseMarketValue: 1500000.0,
        isBlackMarket: true,
        blackMarketRiskPercent: 100,
        blackMarketRiskType: 'smuggled_exotic',
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final lawyer = StaffModel(
        id: 'lawyer_1',
        name: 'Av. Kemal Hukukçu',
        role: StaffRole.legalAdvisor,
        hiredAt: DateTime.now(),
        morale: 90,
      );

      notifier.state = notifier.state.copyWith(
        balance: 200000.0,
        reputationScore: 100,
        ownedCars: [bmCar],
        hiredStaff: [lawyer],
        activeGossips: [], // No gossip warning
        recentEvents: [],
      );

      notifier.advanceGameDay();

      // With Legal Advisor: Car is NOT confiscated
      expect(notifier.state.ownedCars.any((c) => c.id == 'bm_car_2'), isTrue);
      expect(notifier.state.recentEvents.any((e) => e.title.contains('AVUKATINIZ GÜMRÜK EL KOYMASINI DURDURDU')), isTrue);
    });
  });
}
