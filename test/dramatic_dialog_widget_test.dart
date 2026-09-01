import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_dramatic_dialog.dart';

Widget _buildTestApp({
  required Widget child,
  required ProviderContainer container,
  Locale locale = const Locale('tr'),
  Brightness brightness = Brightness.light,
  Size screenSize = const Size(360, 640),
}) {
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
      theme: brightness == Brightness.dark
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: MediaQuery(
        data: MediaQueryData(size: screenSize),
        child: Scaffold(
          body: Center(
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.height,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    // Widget Test Timer Hygiene
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
  });

  tearDown(() {
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    container.dispose();
  });

  group('NeoBrutalDramaticDialog Responsive & UI Audit Tests', () {
    testWidgets('1. Dialog renders cleanly without overflow on compact 320x568 screen', (tester) async {
      final state = DealershipModel.initial().copyWith(balance: 100000, currentDay: 1);
      container.read(gameProvider.notifier).state = state;

      final card = DramaticCardEngine.generateDailyDilemma(1, state);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          screenSize: const Size(320, 568),
          child: NeoBrutalDramaticDialog(card: card),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NeoBrutalDramaticDialog), findsOneWidget);
      expect(find.text(card.title), findsOneWidget);
      expect(find.text(card.choices.first.label), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Must not have layout or render overflows');
    });

    testWidgets('2. Dialog renders with high contrast in Dark Mode on 360x780 screen', (tester) async {
      final state = DealershipModel.initial().copyWith(balance: 100000, currentDay: 7);
      container.read(gameProvider.notifier).state = state;

      final card = DramaticCardEngine.generateDailyDilemma(7, state);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          brightness: Brightness.dark,
          screenSize: const Size(360, 780),
          child: NeoBrutalDramaticDialog(card: card),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(NeoBrutalDramaticDialog), findsOneWidget);
      expect(find.text(card.title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. Clicking affordable choice executes resolution and displays sealed stamp view', (tester) async {
      final state = DealershipModel.initial().copyWith(balance: 100000, currentDay: 1);
      container.read(gameProvider.notifier).state = state;

      final card = DramaticCardEngine.generateDailyDilemma(1, state);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          screenSize: const Size(360, 780),
          child: NeoBrutalDramaticDialog(card: card),
        ),
      );

      await tester.pumpAndSettle();

      // Tap the first choice (Affordable)
      final firstChoiceFinder = find.text(card.choices.first.label);
      expect(firstChoiceFinder, findsOneWidget);
      await tester.ensureVisible(firstChoiceFinder);
      await tester.tap(firstChoiceFinder);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Check Outcome View was rendered
      expect(find.text('KARAR MÜHÜRLENDİ'), findsOneWidget);
      expect(find.text('DEVAM ET'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Insufficient balance choices do not advance to outcome', (tester) async {
      // Set balance to 0 so costly choices cannot be afforded
      final state = DealershipModel.initial().copyWith(balance: 0, currentDay: 1);
      container.read(gameProvider.notifier).state = state;

      final card = DramaticCardEngine.generateDailyDilemma(1, state);

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          screenSize: const Size(360, 780),
          child: NeoBrutalDramaticDialog(card: card),
        ),
      );

      await tester.pumpAndSettle();

      // Find costly choice (m1_treat or m1_sign with upfrontCost > 0)
      final costlyChoice = card.choices.firstWhere((c) => c.upfrontCost > 0);
      final costlyChoiceFinder = find.text(costlyChoice.label);
      expect(costlyChoiceFinder, findsOneWidget);

      await tester.ensureVisible(costlyChoiceFinder);
      await tester.tap(costlyChoiceFinder);
      await tester.pumpAndSettle();

      // Outcome should NOT be visible since player cannot afford it
      expect(find.text('KARAR MÜHÜRLENDİ'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. Dialog renders across all 7 supported languages without errors', (tester) async {
      final state = DealershipModel.initial().copyWith(balance: 100000, currentDay: 14);
      container.read(gameProvider.notifier).state = state;

      final card = DramaticCardEngine.generateDailyDilemma(14, state);

      final locales = [
        const Locale('tr'),
        const Locale('en'),
        const Locale('de'),
        const Locale('es'),
        const Locale('pt'),
        const Locale('ru'),
        const Locale('ar'),
      ];

      for (final loc in locales) {
        await tester.pumpWidget(
          _buildTestApp(
            container: container,
            locale: loc,
            screenSize: const Size(360, 780),
            child: NeoBrutalDramaticDialog(card: card),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(NeoBrutalDramaticDialog), findsOneWidget);
        expect(tester.takeException(), isNull,
            reason: 'Language ${loc.languageCode} caused layout or render issue');
      }
    });
  });
}
