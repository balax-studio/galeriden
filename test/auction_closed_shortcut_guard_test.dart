import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/auction_session_provider.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/auction/auction_screen.dart';
import 'package:galeriden/presentation/screens/auction/widgets/auction_closed_window_view.dart';
import 'package:galeriden/presentation/screens/auction/widgets/auction_sell_tab.dart';

Widget _buildTestApp({required ProviderContainer container, required Widget child}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData.light().copyWith(
        extensions: [
          AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
        ],
      ),
      home: child,
    ),
  );
}

DealershipModel _createUnlockedGame() {
  final initial = DealershipModel.initial();
  return initial.copyWith(
    level: 10,
    reputationScore: 80,
    balance: 2000000,
    unlockedBuildings: {
      ...initial.unlockedBuildings,
      '/auction',
    },
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auction Closed Shortcut Guard - Localization & Invariants', () {
    final translationMaps = {
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    final requiredKeys = [
      'auction_closed_sell_redirect_toast',
      'auction_closed_badge',
      'btn_send_to_auction',
    ];

    test('1. All required keys exist simultaneously across all 7 supported languages', () {
      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;
        for (final key in requiredKeys) {
          expect(
            map.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in $lang translations',
          );
          expect(
            map[key]!.isNotEmpty,
            isTrue,
            reason: 'Empty translation for key "$key" in $lang',
          );
        }
      }
    });

    test('2. Invariant Rules 1 & 2: Zero Unicode emojis and zero parentheses in new keys', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;
        for (final key in ['auction_closed_sell_redirect_toast', 'auction_closed_badge']) {
          final value = map[key]!;
          expect(
            emojiRegex.hasMatch(value),
            isFalse,
            reason: 'Key "$key" in $lang contains forbidden Unicode emoji: "$value"',
          );
          expect(
            value.contains('(') || value.contains(')'),
            isFalse,
            reason: 'Key "$key" in $lang contains forbidden parentheses: "$value"',
          );
        }
      }
    });
  });

  group('AuctionScreen Closed Window & Tab 3 Shortcut Protection', () {
    testWidgets('3. Initial tab 3 redirects to tab 0 and displays closed view when auction is closed', (tester) async {
      final unlockedGame = _createUnlockedGame();
      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(unlockedGame.toJson()),
      });

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );

      addTearDown(() {
        try {
          container.read(auctionSessionProvider.notifier).stopTimer();
        } catch (_) {}
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final auctionNotifier = container.read(auctionSessionProvider.notifier);

      // Force auction closed window
      auctionNotifier.state = auctionNotifier.state.copyWith(
        isWindowOpen: false,
        closedCountdown: 300,
      );

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const AuctionScreen(initialTabIndex: 3),
        ),
      );
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(auctionSessionProvider.notifier).stopTimer();
      await tester.pump(const Duration(milliseconds: 100));

      // Must show closed window view rather than sell tab
      expect(find.byType(AuctionClosedWindowView), findsOneWidget);
      expect(find.byType(AuctionSellTab), findsNothing);

      // Drain toast timer
      await tester.pump(const Duration(seconds: 3));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('4. Tab 3 renders AuctionSellTab when auction window is open', (tester) async {
      final unlockedGame = _createUnlockedGame();
      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(unlockedGame.toJson()),
      });

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );

      addTearDown(() {
        try {
          container.read(auctionSessionProvider.notifier).stopTimer();
        } catch (_) {}
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final auctionNotifier = container.read(auctionSessionProvider.notifier);

      // Force auction open window
      auctionNotifier.state = auctionNotifier.state.copyWith(
        isWindowOpen: true,
        closedCountdown: 0,
      );

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const AuctionScreen(initialTabIndex: 3),
        ),
      );
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(auctionSessionProvider.notifier).stopTimer();
      await tester.pump(const Duration(milliseconds: 100));

      // Must show sell tab and not closed window view
      expect(find.byType(AuctionSellTab), findsOneWidget);
      expect(find.byType(AuctionClosedWindowView), findsNothing);

      // Drain timers
      await tester.pump(const Duration(seconds: 3));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('5. Tapping Tab 3 while closed is blocked and stays on closed view', (tester) async {
      final unlockedGame = _createUnlockedGame();
      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(unlockedGame.toJson()),
      });

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );

      addTearDown(() {
        try {
          container.read(auctionSessionProvider.notifier).stopTimer();
        } catch (_) {}
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final auctionNotifier = container.read(auctionSessionProvider.notifier);

      // Force auction closed
      auctionNotifier.state = auctionNotifier.state.copyWith(
        isWindowOpen: false,
        closedCountdown: 200,
      );

      await tester.pumpWidget(
        _buildTestApp(
          container: container,
          child: const AuctionScreen(initialTabIndex: 0),
        ),
      );
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(auctionSessionProvider.notifier).stopTimer();
      await tester.pump(const Duration(milliseconds: 100));

      // Find tab 3 lock clock icon
      final tab3Icon = find.byIcon(Icons.lock_clock_rounded);
      expect(tab3Icon, findsAtLeastNWidgets(1));

      await tester.tap(tab3Icon.first);
      await tester.pump(const Duration(milliseconds: 100));

      // Must still show closed window view and never mount AuctionSellTab
      expect(find.byType(AuctionClosedWindowView), findsOneWidget);
      expect(find.byType(AuctionSellTab), findsNothing);

      // Drain toast timer
      await tester.pump(const Duration(seconds: 3));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });
}
