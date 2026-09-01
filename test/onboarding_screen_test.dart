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

  group('Onboarding Screen & Single-Card FTUE Tests', () {
    testWidgets('1. OnboardingScreen renders single punchy welcome card with Turkish localized strings',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        buildOnboardingApp(locale: const Locale('tr'), container: container),
      );
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Check single card strings
      expect(find.text('DEDE MİRASI GARAJ'), findsOneWidget);
      expect(find.text('Hasan Usta Yadigarı Garaj Seni Bekliyor'), findsOneWidget);
      expect(find.text('Garajın Başına Geç'), findsOneWidget);

      // Verify no raw keys with underscores are displayed
      expect(find.text('onboarding_single_tag'), findsNothing);
      expect(find.text('onboarding_single_title'), findsNothing);
      expect(find.text('onboarding_single_start_btn'), findsNothing);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      container.dispose();
    });

    testWidgets('2. All 7 languages have complete FTUE & onboarding translations without parentheses',
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
        'onboarding_single_tag',
        'onboarding_single_title',
        'onboarding_single_bullet_1',
        'onboarding_single_bullet_2',
        'onboarding_single_bullet_3',
        'onboarding_single_start_btn',
        'tut_step_inspect_title',
        'tut_step_repair_title',
        'tut_step_list_title',
        'tut_step_sell_title',
        'tut_celebration_title',
        'tut_celebration_desc',
        'tut_celebration_btn',
        'tut_dashboard_guide_title',
        'tut_dashboard_guide_desc',
        'tut_dashboard_guide_btn',
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

    testWidgets('3. OnboardingScreen does not overflow in compact height viewport',
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
      expect(find.text('GROSSVATER ERBE GARAGE'), findsOneWidget);

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
      container.dispose();
    });
  });
}
