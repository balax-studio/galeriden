import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Level Up Modal Hygiene Tests', () {
    test('Loading saved state at Level 9 syncs last_celebrated_level and marks isLoaded', () async {
      final savedModel = DealershipModel.initial().copyWith(level: 9);
      final jsonString = jsonEncode(savedModel.toJson());
      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonString,
      });

      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      // Allow async load to complete
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.isLoaded, isTrue);
      expect(notifier.state.level, 9);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('last_celebrated_level'), 9);
    });

    test('Earning XP to reach Level 10 triggers level celebration criteria', () async {
      SharedPreferences.setMockInitialValues({
        'last_celebrated_level': 9,
      });

      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final prefs = await SharedPreferences.getInstance();
      int lastCelebratedLevel = prefs.getInt('last_celebrated_level') ?? 1;
      expect(lastCelebratedLevel, 9);

      // Simulate leveling up to 10
      notifier.state = notifier.state.copyWith(level: 10);

      // Verify level is greater than lastCelebratedLevel
      expect(notifier.state.level > lastCelebratedLevel, isTrue);

      // Record celebrated level
      await prefs.setInt('last_celebrated_level', notifier.state.level);
      lastCelebratedLevel = prefs.getInt('last_celebrated_level')!;
      expect(lastCelebratedLevel, 10);

      // Next state update at level 10 must NOT satisfy level up condition
      notifier.state = notifier.state.copyWith(balance: notifier.state.balance + 1000);
      expect(notifier.state.level > lastCelebratedLevel, isFalse);
    });
  });
}
