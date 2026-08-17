import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Sprint 4: Branch Prestige & Collection Showcase Tests', () {
    test('Showcase toggle locks a rare car and applies passive bonuses', () {
      final notifier = GameNotifier();
      final initialCar = notifier.state.ownedCars.first;
      expect(initialCar.isRare, isTrue);

      final success = notifier.toggleShowcaseLock(initialCar.id);
      expect(success, isTrue);

      final updatedCar = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(updatedCar.isLockedInShowcase, isTrue);

      // Cannot sell or scrap a locked showcase car directly without unlocking
      final sellAttempt = notifier.sellCar(updatedCar.id, 500000.0);
      expect(sellAttempt, isFalse);

      // Unlock again
      notifier.toggleShowcaseLock(initialCar.id);
      final unlockedCar = notifier.state.ownedCars.firstWhere((c) => c.id == initialCar.id);
      expect(unlockedCar.isLockedInShowcase, isFalse);
    });

    test('Purchasing Prestige Branch Tier expands garage slots and unlocks property tier', () {
      final notifier = GameNotifier();
      notifier.addCheatFunds(5000000.0);

      final slotsBefore = notifier.state.maxGarageSlots;
      final buyTier2 = notifier.upgradePrestigeBranch(2);
      expect(buyTier2, isTrue);
      expect(notifier.state.maxGarageSlots, equals(slotsBefore + 1));
      expect(notifier.state.unlockedBuildings.contains('property_tier_2'), isTrue);
    });
  });
}
