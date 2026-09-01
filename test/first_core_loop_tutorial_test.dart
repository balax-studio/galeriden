import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/tutorial_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('60-Second First Core Loop FTUE & Lifecycle Tests', () {
    test('1. DealershipModel.initial starts with Heritage Car, 75k TL, and tutorial incomplete', () {
      final initialGame = DealershipModel.initial();

      expect(initialGame.tutorialCompleted, isFalse);
      expect(initialGame.level, equals(1));
      expect(initialGame.balance, equals(75000.0));
      expect(initialGame.ownedCars.length, equals(1));
      expect(initialGame.ownedCars.first.id, equals('car_heritage_dede'));
      expect(initialGame.ownedCars.first.brand, equals('Tofaşk'));
      expect(initialGame.ownedCars.first.isListed, isFalse);
      expect(initialGame.incomingOffers, isEmpty);
      expect(initialGame.carsSold, equals(0));
    });

    test('2. TutorialProvider manages 5 focused steps without bloat', () {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final initialStep = container.read(tutorialProvider).step;
      expect(initialStep, equals(TutorialStep.inspectHeritageCar));

      container.read(tutorialProvider.notifier).setStep(TutorialStep.repairEnginePart);
      expect(container.read(tutorialProvider).step, equals(TutorialStep.repairEnginePart));

      container.read(tutorialProvider.notifier).setStep(TutorialStep.listCarForSale);
      expect(container.read(tutorialProvider).step, equals(TutorialStep.listCarForSale));

      container.read(tutorialProvider.notifier).setStep(TutorialStep.acceptFirstOffer);
      expect(container.read(tutorialProvider).step, equals(TutorialStep.acceptFirstOffer));

      container.read(tutorialProvider.notifier).completeTutorial();
      expect(container.read(tutorialProvider).step, equals(TutorialStep.completed));
      expect(container.read(tutorialProvider).isCompleted, isTrue);

      container.dispose();
    });

    test('3. Listing the heritage car during tutorial immediately generates an instant buyer offer', () {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final notifier = container.read(gameProvider.notifier);
      final initialGame = container.read(gameProvider);

      expect(initialGame.tutorialCompleted, isFalse);
      expect(initialGame.incomingOffers, isEmpty);

      // Player lists the heritage car
      notifier.updateCarListingDetails('car_heritage_dede', customPrice: 250000.0);

      final updatedGame = container.read(gameProvider);
      final listedCar = updatedGame.ownedCars.firstWhere((c) => c.id == 'car_heritage_dede');

      expect(listedCar.isListed, isTrue);
      expect(listedCar.customListingPrice, equals(250000.0));
      // Instant offer generated for seamless FTUE experience
      expect(updatedGame.incomingOffers.length, equals(1));
      expect(updatedGame.incomingOffers.first.carId, equals('car_heritage_dede'));
      expect(updatedGame.incomingOffers.first.offeredAmount, greaterThan(0));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('4. Accepting the first offer completes the sale, unlocks Level 2 and awards 50k bonus capital', () {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final notifier = container.read(gameProvider.notifier);

      // 1. List the car to get instant offer
      notifier.updateCarListingDetails('car_heritage_dede', customPrice: 250000.0);
      var game = container.read(gameProvider);
      expect(game.incomingOffers.isNotEmpty, isTrue);

      final offer = game.incomingOffers.first;
      final offerAmount = offer.offeredAmount;

      // 2. Accept offer and complete sale
      notifier.acceptOffer(offer);

      game = container.read(gameProvider);

      // Assertions on completed state
      expect(game.carsSold, equals(1));
      expect(game.tutorialCompleted, isTrue);
      expect(game.level, greaterThanOrEqualTo(2));
      expect(game.ownedCars.any((c) => c.id == 'car_heritage_dede'), isFalse);
      expect(game.salesHistory.length, equals(1));
      expect(game.salesHistory.first.salePrice, equals(offerAmount));
      // Balance includes initial 75k + sale cash + 50k tutorial bonus
      expect(game.balance, greaterThanOrEqualTo(125000.0));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('5. completeTutorial is idempotent and does not award bonus twice', () {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final notifier = container.read(gameProvider.notifier);

      notifier.completeTutorial();
      final balanceAfterFirst = container.read(gameProvider).balance;

      // Call again
      notifier.completeTutorial();
      final balanceAfterSecond = container.read(gameProvider).balance;

      expect(balanceAfterSecond, equals(balanceAfterFirst));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
