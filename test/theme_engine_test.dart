import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Tycoon Theme Engine Tests', () {
    test('ThemePaletteModel contains 2 curated preset palettes with prices', () {
      final palettes = ThemePaletteModel.defaultPalettes;
      expect(palettes.length, equals(2));

      final freePalette = palettes.firstWhere((p) => p.id == 'sanayi_ciragi_light');
      expect(freePalette.price, equals(0));
      expect(freePalette.isUnlocked, isTrue);

      final nightPalette = palettes.firstWhere((p) => p.id == 'gece_vardiyasi_dark');
      expect(nightPalette.price, equals(50000));
      expect(nightPalette.isUnlocked, isFalse);
    });

    test('ThemePaletteModel serializes and deserializes to JSON correctly', () {
      final original = ThemePaletteModel.defaultPalettes[1]; // gece_vardiyasi_dark
      final jsonMap = original.toJson();
      final restored = ThemePaletteModel.fromJson(jsonMap);

      expect(restored.id, equals(original.id));
      expect(restored.name, equals(original.name));
      expect(restored.price, equals(original.price));
      expect(restored.primaryColor.toARGB32(), equals(original.primaryColor.toARGB32()));
    });

    test('ThemeNotifier unlocks palette and deducts price logic correctly', () {
      final notifier = ThemeNotifier();
      final initialBalance = 60000.0;

      // Unlocking gece_vardiyasi_dark palette (price: 50.000 TL)
      final success = notifier.unlockPalette('gece_vardiyasi_dark', initialBalance);
      expect(success, isTrue);
      expect(notifier.state.activePalette.id, equals('gece_vardiyasi_dark'));
    });
  });
}
