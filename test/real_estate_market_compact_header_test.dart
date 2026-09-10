import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/real_estate/real_estate_market_screen.dart';

Widget _buildTestApp({
  required Widget child,
  required ProviderContainer container,
  Size size = const Size(360, 700),
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('tr'),
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
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: child,
      ),
    ),
  );
}

void main() {
  group('RealEstateMarketScreen Compact Terminal Console Tests', () {
    testWidgets('1. Renders unified compact terminal header with segmented tabs and telemetry pips',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(level: 5);

      await tester.pumpWidget(
        _buildTestApp(
          child: const RealEstateMarketScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Check segmented tabs
      expect(find.text('İlanlar'), findsOneWidget);
      expect(find.textContaining('Portföyüm • 0'), findsOneWidget);

      // Check search toggle button
      expect(find.byIcon(Icons.search_rounded), findsWidgets);

      // Check category chips
      expect(find.text('Tümü'), findsOneWidget);

      container.dispose();
    });

    testWidgets('2. Tab switching between İlanlar and Portföy updates view',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(level: 5);

      await tester.pumpWidget(
        _buildTestApp(
          child: const RealEstateMarketScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Tap Portföy tab
      final portfolioTab = find.textContaining('Portföyüm • 0');
      expect(portfolioTab, findsOneWidget);
      await tester.tap(portfolioTab);
      await tester.pumpAndSettle();

      // Empty portfolio state should be visible
      expect(find.byIcon(Icons.domain_disabled_rounded), findsOneWidget);

      // Tap İlanlar tab to switch back
      final marketTab = find.text('İlanlar');
      await tester.tap(marketTab);
      await tester.pumpAndSettle();

      // Market category chips should be visible again
      expect(find.text('Tümü'), findsOneWidget);

      container.dispose();
    });

    testWidgets('3. Compact search button expands search dock into text input',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(level: 5);

      await tester.pumpWidget(
        _buildTestApp(
          child: const RealEstateMarketScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Initially no search TextField is active (it's a compact button)
      expect(find.byType(TextField), findsNothing);

      // Tap search icon button
      final searchButton = find.byIcon(Icons.search_rounded).first;
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // TextField should now be visible
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap close button to collapse search
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // TextField is collapsed again
      expect(find.byType(TextField), findsNothing);

      container.dispose();
    });

    testWidgets('4. Compact screen (320px width) renders without overflow',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(level: 5);

      await tester.pumpWidget(
        _buildTestApp(
          child: const RealEstateMarketScreen(),
          container: container,
          size: const Size(320, 600),
        ),
      );
      await tester.pumpAndSettle();

      // Ensure no exceptions or overflows
      expect(tester.takeException(), isNull);
      expect(find.text('İlanlar'), findsOneWidget);

      container.dispose();
    });

    testWidgets('5. Invariant check: zero unicode emojis and zero parentheses in UI strings',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state =
          container.read(gameProvider).copyWith(level: 5);

      await tester.pumpWidget(
        _buildTestApp(
          child: const RealEstateMarketScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]',
        unicode: true,
      );

      for (final tw in textWidgets) {
        final content = tw.data ?? tw.textSpan?.toPlainText() ?? '';
        expect(emojiRegex.hasMatch(content), isFalse,
            reason: 'Found emoji in UI text: "$content"');
        expect(content.contains('(') || content.contains(')'), isFalse,
            reason: 'Found parentheses in UI text: "$content"');
      }

      container.dispose();
    });
  });
}
