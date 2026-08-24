import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_empty_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTheme = ThemeData.light().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  group('NeoBrutalEmptyState & Lifecycle Battery Optimization Tests', () {
    testWidgets('1. NeoBrutalEmptyState renders icon, title, description, badge and responds to action button', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          theme: testTheme,
          home: Scaffold(
            body: NeoBrutalEmptyState(
              icon: Icons.directions_car_filled_rounded,
              badgeText: 'VİTRİN BOŞ',
              title: 'Galerinde Satılık Araç Yok',
              description: 'Galerini doldurmak ve kâr elde etmek için ikinci el pazarından veya ihale salonundan fırsat araçları satın alabilirsin.',
              actionLabel: 'Pazara Git',
              actionIcon: Icons.storefront_rounded,
              onActionPressed: () {
                actionTapped = true;
              },
            ),
          ),
        ),
      );

      // Verify empty state visual elements
      expect(find.byType(NeoBrutalEmptyState), findsOneWidget);
      expect(find.text('VİTRİN BOŞ'), findsOneWidget);
      expect(find.text('Galerinde Satılık Araç Yok'), findsOneWidget);
      expect(find.textContaining('ikinci el pazarından'), findsOneWidget);
      expect(find.text('Pazara Git'), findsOneWidget);

      // Tap action button and verify callback
      await tester.tap(find.text('Pazara Git'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(actionTapped, isTrue);
    });

    test('2. GameNotifier and MarketNotifier pause and resume timers on app lifecycle transitions', () {
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      final gameNotifier = container.read(gameProvider.notifier);
      final marketNotifier = container.read(marketProvider.notifier);

      // Trigger app paused
      expect(() => gameNotifier.onAppPaused(), returnsNormally);
      expect(() => marketNotifier.onAppPaused(), returnsNormally);

      // Trigger app resumed
      expect(() => gameNotifier.onAppResumed(), returnsNormally);
      expect(() => marketNotifier.onAppResumed(), returnsNormally);

      // Clean up / pause timers before test completion
      gameNotifier.onAppPaused();
      marketNotifier.onAppPaused();
      container.dispose();
    });
  });
}
