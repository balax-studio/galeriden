import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/stock_market/stock_market_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StockMarketScreen Widget Render & Error-Free Mount Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('StockMarketScreen renders tabs, market stocks and owned stocks without error', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      final container = ProviderContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData.dark().copyWith(
              extensions: [
                AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
              ],
            ),
            home: const StockMarketScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        unlockedBuildings: {'/stock-market', 'property_tier_6'},
        marketStocks: StockModel.defaultStocks,
        ownedStocks: [
          PlayerStockModel(
            symbol: 'FROTO',
            quantity: 50,
            averageCost: 800.0,
          ),
        ],
        ownedForex: [
          PlayerForexModel(
            symbol: 'USD/TRY',
            amount: 1000.0,
            averageRate: 32.5,
          ),
        ],
      );

      await tester.pumpAndSettle();

      // Screen title and tabs exist
      expect(find.text('BİST Hisseleri'), findsOneWidget);
      expect(find.text('Portföyüm'), findsOneWidget);
      expect(find.text('Döviz & Altın'), findsOneWidget);
      expect(find.text('HALKA ARZ • IPO'), findsOneWidget);

      expect(tester.takeException(), isNull);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
