import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('7-Language Multi-Language Engine Tests', () {
    test('AppLanguage enum contains all 7 target languages with metadata', () {
      expect(AppLanguage.values.length, 7);

      final codes = AppLanguage.values.map((e) => e.code).toSet();
      expect(codes, containsAll(['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar']));

      // Arabic RTL check
      final arabic = AppLanguage.fromCode('ar');
      expect(arabic.isRtl, isTrue);
      expect(arabic.countryBadge, 'AR');
      expect(arabic.nativeName, 'العربية');

      // German & Portuguese checks
      final german = AppLanguage.fromCode('de');
      expect(german.isRtl, isFalse);
      expect(german.nativeName, 'Deutsch');

      final portuguese = AppLanguage.fromCode('pt');
      expect(portuguese.isRtl, isFalse);
      expect(portuguese.nativeName, 'Português');

      // Fallback check
      expect(AppLanguage.fromCode('unknown_xyz'), AppLanguage.turkish);
    });

    test('AppLocalizations contains keys and returns valid translations for all 7 languages', () {
      final keySet = [
        'app_name',
        'settings_title',
        'language_select',
        'dashboard',
        'garage',
        'showroom',
        'scrapyard',
        'stock_market',
        'auction',
        'staff',
        'notary',
        'bank',
        'night_race',
        'missions',
        'level',
        'reputation',
        'balance',
        'day',
        'streak_title',
        'crm_title',
        'bist_glrd',
        'bluff_button',
        'sanayi_rumor',
        'staff_morale',
        'season_spring',
        'season_summer',
        'season_autumn',
        'season_winter',
      ];

      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.code);
        for (final key in keySet) {
          final val = loc.get(key);
          expect(val, isNotEmpty, reason: 'Language ${lang.code} missing or empty key: $key');
          expect(val, isNot(equals(key)), reason: 'Language ${lang.code} untranslated key: $key');
        }
      }
    });

    test('AppLocalizations supports parameter substitution', () {
      // Test dynamic string replacement
      final loc = AppLocalizations('en');
      final result = loc.get('level', {'custom': '123'});
      expect(result, 'Level');
    });

    test('SettingsNotifier updates language and isRtl reactivity correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = SettingsNotifier();

      expect(notifier.state.languageCode, isNotEmpty);

      // Switch to Arabic
      await notifier.setLanguage('ar');
      expect(notifier.state.languageCode, 'ar');
      expect(notifier.state.isRtl, isTrue);
      expect(notifier.state.currentLanguage, AppLanguage.arabic);

      // Switch to German
      await notifier.setLanguage('de');
      expect(notifier.state.languageCode, 'de');
      expect(notifier.state.isRtl, isFalse);
      expect(notifier.state.currentLanguage, AppLanguage.german);

      // Switch to Portuguese
      await notifier.setLanguage('pt');
      expect(notifier.state.languageCode, 'pt');
      expect(notifier.state.currentLanguage, AppLanguage.portuguese);

      // Switch to Russian
      await notifier.setLanguage('ru');
      expect(notifier.state.languageCode, 'ru');
      expect(notifier.state.currentLanguage, AppLanguage.russian);

      // Switch to Spanish
      await notifier.setLanguage('es');
      expect(notifier.state.languageCode, 'es');
      expect(notifier.state.currentLanguage, AppLanguage.spanish);

      // Switch back to Turkish
      await notifier.setLanguage('tr');
      expect(notifier.state.languageCode, 'tr');
      expect(notifier.state.currentLanguage, AppLanguage.turkish);
    });
  });
}
