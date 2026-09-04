import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/ad_reward_calculator.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Save Export & Import Persistent Save Tests', () {
    test('exportSaveCode returns GLRD_SAVE_V1 formatted Base64 string', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      final code = notifier.exportSaveCode();

      expect(code, startsWith('GLRD_SAVE_V1:'));
      final base64Part = code.substring('GLRD_SAVE_V1:'.length);
      expect(() => base64Decode(base64Part), returnsNormally);

      final jsonStr = utf8.decode(base64Decode(base64Part));
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
      expect(decoded.containsKey('balance'), isTrue);
      expect(decoded.containsKey('level'), isTrue);
      expect(decoded.containsKey('dealershipName'), isTrue);
    });

    test('importSaveCode successfully restores state from valid save code', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      // Mutate state with custom values
      notifier.addCheatFunds(750000.0);
      notifier.setLevel(6);
      final originalBalance = container.read(gameProvider).balance;
      final originalLevel = container.read(gameProvider).level;

      final exportedCode = notifier.exportSaveCode();

      // Reset or alter state in a new container
      final container2 = ProviderContainer();
      addTearDown(() {
        container2.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container2.dispose();
      });

      final notifier2 = container2.read(gameProvider.notifier);
      expect(container2.read(gameProvider).level, equals(1));

      final success = notifier2.importSaveCode(exportedCode);
      expect(success, isTrue);
      expect(container2.read(gameProvider).balance, equals(originalBalance));
      expect(container2.read(gameProvider).level, equals(originalLevel));
    });

    test('importSaveCode safely rejects invalid, corrupt or empty strings', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      expect(notifier.importSaveCode(''), isFalse);
      expect(notifier.importSaveCode('   '), isFalse);
      expect(notifier.importSaveCode('NOT_A_VALID_BASE64!@#%^&*'), isFalse);
      expect(notifier.importSaveCode('GLRD_SAVE_V1:INVALID_BASE64'), isFalse);
      expect(notifier.importSaveCode('GLRD_SAVE_V1:${base64Encode(utf8.encode('{"invalid": "data"}'))}'), isFalse);
    });
  });

  group('Dynamic Ad Reward Scaling Tests', () {
    test('Calculates level-based progressive rewards without hardcoded caps', () {
      final lowLevelOutcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 1,
        totalGarageValue: 0.0,
      );

      final midLevelOutcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 5,
        totalGarageValue: 500000.0,
      );

      final highLevelOutcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 15,
        totalGarageValue: 5000000.0,
      );

      expect(lowLevelOutcome.moneyAmount, greaterThanOrEqualTo(5000.0));
      expect(midLevelOutcome.moneyAmount, greaterThan(lowLevelOutcome.moneyAmount));
      expect(highLevelOutcome.moneyAmount, greaterThan(midLevelOutcome.moneyAmount));

      // Invariant: Zero parentheses in badge and title
      expect(lowLevelOutcome.badgeText.contains('(') || lowLevelOutcome.badgeText.contains(')'), isFalse);
      expect(midLevelOutcome.badgeText.contains('(') || midLevelOutcome.badgeText.contains(')'), isFalse);
      expect(highLevelOutcome.badgeText.contains('(') || highLevelOutcome.badgeText.contains(')'), isFalse);
    });
  });
}
