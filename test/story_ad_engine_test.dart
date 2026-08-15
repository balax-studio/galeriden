import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/story_card_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Story-Driven Rewarded Encounter Engine Tests', () {
    late GameNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('StoryCardModel default list contains exactly 8 unique narrative cards', () {
      final defaultCards = StoryCardModel.defaultCards;
      expect(defaultCards.length, equals(8));

      final ids = defaultCards.map((c) => c.id).toSet();
      expect(ids.length, equals(8), reason: 'All story cards must have unique IDs');
    });

    test('GameState advances story ad counter and triggers pendingStoryCard between 7 and 21 days', () {
      // Initial state
      expect(notifier.state.daysSinceLastStoryAd, equals(0));
      expect(notifier.state.nextStoryAdTargetDays, inInclusiveRange(7, 21));
      expect(notifier.state.pendingStoryCard, isNull);

      final targetDays = notifier.state.nextStoryAdTargetDays;

      // Advance days until target is reached
      for (int i = 0; i < targetDays - 1; i++) {
        notifier.advanceGameDay();
        expect(notifier.state.pendingStoryCard, isNull, reason: 'Should not trigger before target day');
      }

      // Reaching the exact target day
      notifier.advanceGameDay();
      expect(notifier.state.pendingStoryCard, isNotNull, reason: 'Must trigger story encounter on target day');
      expect(notifier.state.daysSinceLastStoryAd, equals(0));
      expect(notifier.state.nextStoryAdTargetDays, inInclusiveRange(7, 21));
    });

    test('Cycle protection: seen cards are not repeated until all 8 cards have been encountered', () {
      final encounteredIds = <String>{};

      for (int cycle = 0; cycle < 8; cycle++) {
        final card = notifier.selectNextStoryCard();
        expect(card, isNotNull);
        expect(encounteredIds.contains(card!.id), isFalse, reason: 'Card ${card.id} repeated before cycle completion');
        encounteredIds.add(card.id);
        notifier.resolveStoryCard(card: card, accepted: false);
      }

      expect(encounteredIds.length, equals(8));
      expect(notifier.state.seenStoryCardIds.length, equals(8));

      // 9th selection should reset cycle and pick a fresh card
      final freshCard = notifier.selectNextStoryCard();
      expect(freshCard, isNotNull);
    });

    test('Resolving Haydar Usta card grants instant vehicle inspection and repair insights', () {
      final haydarCard = StoryCardModel.defaultCards.firstWhere((c) => c.id == 'haydar_usta');

      // Add a test car with damages
      final testCar = CarModel(
        id: 'test_car_1',
        brand: 'BMW',
        modelName: '320i Sedan',
        modelYear: 2018,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 300000.0,
        currentPurchasePrice: 280000.0,
        expertise: ExpertiseReport(
          engineCondition: 40.0,
          transmissionCondition: 50.0,
          tramerAmount: 15000,
          mileage: 120000,
          isMileageTampered: false,
          bodyParts: const {
            'Kaput': PartStatus.damaged,
          },
        ),
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [testCar],
      );

      notifier.resolveStoryCard(card: haydarCard, accepted: true);

      final updatedCar = notifier.state.ownedCars.firstWhere((c) => c.id == 'test_car_1');
      expect(updatedCar.expertise.engineCondition, equals(100.0));
      expect(updatedCar.expertise.transmissionCondition, equals(100.0));
    });

    test('Resolving Zengin Sofor card spawns a bargain collector car in garage or grants bonus', () {
      final soforCard = StoryCardModel.defaultCards.firstWhere((c) => c.id == 'zengin_sofor');

      final initialCarCount = notifier.state.ownedCars.length;
      notifier.resolveStoryCard(card: soforCard, accepted: true);

      expect(notifier.state.ownedCars.length, equals(initialCarCount + 1));
      final bargainCar = notifier.state.ownedCars.last;
      expect(bargainCar.currentPurchasePrice, lessThanOrEqualTo(bargainCar.baseMarketValue * 0.6));
    });

    test('Resolving Gece Boyaci card boosts selected car condition and vitrin value', () {
      final boyaciCard = StoryCardModel.defaultCards.firstWhere((c) => c.id == 'gece_boyaci');

      final testCar = CarModel(
        id: 'test_car_detailing',
        brand: 'Mercedes',
        modelName: 'C200 AMG',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 480000.0,
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
        expertise: ExpertiseReport(
          engineCondition: 85.0,
          transmissionCondition: 85.0,
          tramerAmount: 0,
          mileage: 65000,
          isMileageTampered: false,
          bodyParts: const {
            'Kaput': PartStatus.painted,
          },
        ),
      );

      notifier.state = notifier.state.copyWith(ownedCars: [testCar]);
      notifier.resolveStoryCard(card: boyaciCard, accepted: true);

      final updatedCar = notifier.state.ownedCars.firstWhere((c) => c.id == 'test_car_detailing');
      expect(updatedCar.isWashed, isTrue);
      expect(updatedCar.isPolished, isTrue);
      expect(updatedCar.isDetailedCleaned, isTrue);
      expect(updatedCar.baseMarketValue, greaterThan(500000.0));
    });

    test('Resolving Cikmaci Ibo card grants auto parts subsidy credit to balance', () {
      final iboCard = StoryCardModel.defaultCards.firstWhere((c) => c.id == 'cikmaci_ibo');

      final initialMoney = notifier.state.balance;
      notifier.resolveStoryCard(card: iboCard, accepted: true);

      expect(notifier.state.balance, equals(initialMoney + 35000));
    });
  });
}
