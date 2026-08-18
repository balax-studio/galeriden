import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Background Isolate Save & State Persistence Tests', () {
    late GameNotifier notifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
      // Allow async initial load to settle
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('flushSaveNow serializes state to SharedPreferences asynchronously without errors', () async {
      notifier.state = notifier.state.copyWith(
        balance: 350000.0,
        reputationScore: 75,
      );

      await notifier.flushSaveNow();

      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('dealership_state_v2');

      expect(jsonStr, isNotNull);
      final decoded = jsonDecode(jsonStr!) as Map<String, dynamic>;
      final loaded = DealershipModel.fromJson(decoded);

      expect(loaded.balance, equals(350000.0));
      expect(loaded.reputationScore, equals(75));
    });

    test('saveState debounces multiple rapid calls safely', () async {
      notifier.state = notifier.state.copyWith(balance: 100.0);
      notifier.saveState();
      notifier.state = notifier.state.copyWith(balance: 200.0);
      notifier.saveState();
      notifier.state = notifier.state.copyWith(balance: 300.0);
      notifier.saveState();

      // Wait for debounce timer (350ms) to complete
      await Future.delayed(const Duration(milliseconds: 500));

      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('dealership_state_v2');

      expect(jsonStr, isNotNull);
      final decoded = jsonDecode(jsonStr!) as Map<String, dynamic>;
      expect(decoded['balance'], equals(300.0));
    });
  });
}
