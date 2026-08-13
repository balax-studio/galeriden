import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Tycoon Theme Engine Tests', () {
    test('ThemePaletteModel contains 5 default preset palettes with prices', () {
      final palettes = ThemePaletteModel.defaultPalettes;
      expect(palettes.length, equals(5));

      final freePalette = palettes.firstWhere((p) => p.id == 'quiet_luxury_dark');
      expect(freePalette.price, equals(0));
      expect(freePalette.isUnlocked, isTrue);

      final cyberPalette = palettes.firstWhere((p) => p.id == 'neon_cyber');
      expect(cyberPalette.price, equals(25000));
      expect(cyberPalette.isUnlocked, isFalse);
    });

    test('ThemePaletteModel serializes and deserializes to JSON correctly', () {
      final original = ThemePaletteModel.defaultPalettes[2]; // neon_cyber
      final jsonMap = original.toJson();
      final restored = ThemePaletteModel.fromJson(jsonMap);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.price, equals(original.price));
      expect(restored.primaryColor.toARGB32(), equals(original.primaryColor.toARGB32()));
    });

    test('ThemeNotifier unlocks palette and deducts price logic correctly', () {
      final notifier = ThemeNotifier();
      final initialBalance = 30000.0;

      // Unlocking neon_cyber palette (price: 25.000 TL)
      final success = notifier.unlockPalette('neon_cyber', initialBalance);
      expect(success, isTrue);
      expect(notifier.state.activePalette.id, equals('neon_cyber'));
    });
  });
}
