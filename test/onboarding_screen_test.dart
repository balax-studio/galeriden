import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

Widget buildOnboardingApp({
  required Locale locale,
  required ProviderContainer container,
  Size screenSize = const Size(360, 640),
}) {
  final testTheme = ThemeData.light().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('de'),
        Locale('pt'),
        Locale('es'),
        Locale('ru'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: testTheme,
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: const OnboardingScreen(),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Onboarding Screen & Localization Tests', () {
    testWidgets('1. OnboardingScreen renders Page 1 with localized Turkish strings and no raw keys with underscores',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        buildOnboardingApp(locale: const Locale('tr'), container: container),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check that all Turkish strings exist and are displayed
      expect(find.text('TİCARET VE YÜKSELİŞ'), findsOneWidget);
      expect(find.text('Kendi Oto Galeri İmparatorluğunu Kur'), findsOneWidget);
      expect(find.text('İleri'), findsOneWidget);
      expect(find.text('Atla'), findsOneWidget);

      // Verify no raw keys with underscores are displayed as text on screen
      expect(find.text('onboarding_tag_story'), findsNothing);
      expect(find.text('onboarding_title_story'), findsNothing);
      expect(find.text('onboarding_desc_story'), findsNothing);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      container.dispose();
    });

    testWidgets('2. OnboardingScreen navigation sweeps through all 3 pages cleanly',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        buildOnboardingApp(locale: const Locale('tr'), container: container),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Page 1
      expect(find.text('TİCARET VE YÜKSELİŞ'), findsOneWidget);

      // Advance to Page 2
      await tester.tap(find.text('İleri'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('SANAYİ VE USTA REKABETİ'), findsOneWidget);
      expect(find.text('Araçları Onar, Modifiye Et ve Değerini Katla'), findsOneWidget);

      // Advance to Page 3
      await tester.tap(find.text('İleri'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.text('FİNANS VE YATIRIM'), findsOneWidget);
      expect(find.text('Borsa, Banka ve Gayrimenkul ile Büyü'), findsOneWidget);
      expect(find.text('Galeriye Başla'), findsOneWidget);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      container.dispose();
    });

    testWidgets('3. All 7 languages have complete onboarding translations without parentheses',
        (WidgetTester tester) async {
      final maps = [
        trTranslations,
        enTranslations,
        deTranslations,
        ptTranslations,
        esTranslations,
        ruTranslations,
        arTranslations,
      ];

      final expectedKeys = [
        'onboarding_tycoon_subtitle',
        'onboarding_skip_btn',
        'onboarding_start_btn',
        'onboarding_next_btn',
        'onboarding_tag_story',
        'onboarding_title_story',
        'onboarding_desc_story',
        'onboarding_tag_workshop',
        'onboarding_title_workshop',
        'onboarding_desc_workshop',
        'onboarding_tag_market',
        'onboarding_title_market',
        'onboarding_desc_market',
      ];

      for (final map in maps) {
        for (final key in expectedKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Key $key missing in translation');
          final value = map[key]!;
          expect(value.contains('('), isFalse, reason: 'Key $key contains ( in $value');
          expect(value.contains(')'), isFalse, reason: 'Key $key contains ) in $value');
          expect(value.trim().isNotEmpty, isTrue, reason: 'Key $key is empty');
        }
      }
    });

    testWidgets('4. OnboardingScreen does not overflow in compact height viewport',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        buildOnboardingApp(
          locale: const Locale('de'),
          container: container,
          screenSize: const Size(320, 520),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('HANDEL UND AUFSTIEG'), findsOneWidget);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      container.dispose();
    });
  });
}
