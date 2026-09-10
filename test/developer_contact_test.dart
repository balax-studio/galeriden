import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/game_constants.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/feedback_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Balax Studio Official Instagram Constants & Invariants', () {
    test('GameConstants contains valid Instagram official URL and handle', () {
      expect(GameConstants.developerInstagramUrl, 'https://www.instagram.com/balaxstudio');
      expect(GameConstants.developerInstagramHandle, '@balaxstudio');
    });

    test('All new keys exist in 7 languages and satisfy zero-emoji & zero-parentheses rules', () {
      final allTranslations = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final targetKeys = [
        'settings_dev_contact_badge',
        'settings_dev_contact_title',
        'settings_dev_contact_desc',
        'settings_dev_contact_btn',
        'feedback_alt_contact_strip',
        'splash_tagline',
        'splash_studio_present',
        'splash_loading_step1',
        'splash_loading_step2',
        'splash_loading_step3',
      ];

      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in targetKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Key $key missing in $lang');
          final val = map[key]!;
          expect(val.isNotEmpty, isTrue, reason: 'Value empty for $key in $lang');

          // Invariant Rule #1: Zero Unicode Emojis
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Found emoji in key $key for $lang: $val');

          // Invariant Rule #2: Zero Parentheses
          expect(val.contains('(') || val.contains(')'), isFalse,
              reason: 'Found parentheses in key $key for $lang: $val');
        }
      }
    });
  });

  group('FeedbackDialog Instagram Contact Strip Widget Test', () {
    testWidgets('FeedbackDialog displays alternative Instagram contact strip', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: ToastificationWrapper(
            child: MaterialApp(
              locale: const Locale('tr'),
              supportedLocales: const [
                Locale('tr'),
                Locale('en'),
              ],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: AppTheme.darkTheme,
              home: const Scaffold(
                body: FeedbackDialog(),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify the Instagram alternative contact strip is rendered
      expect(find.text(trTranslations['feedback_alt_contact_strip']!), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new_rounded), findsOneWidget);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      container.dispose();
    });
  });
}
