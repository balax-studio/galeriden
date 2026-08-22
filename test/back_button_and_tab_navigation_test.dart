import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/presentation/providers/dashboard_provider.dart';
import 'package:galeriden/presentation/widgets/game_hud_widget.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_app_bar.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Back Button & Bottom Nav Tab Redirection Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Tapping NeoBrutalAppBar back button resets dashboardTabProvider to 0 (Home)', (tester) async {
      final container = ProviderContainer();
      container.read(dashboardTabProvider.notifier).state = 1; // User is in Showroom tab

      expect(container.read(dashboardTabProvider), equals(1));

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
            theme: ThemeData(
              extensions: [
                AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
              ],
            ),
            home: const Scaffold(
              appBar: NeoBrutalAppBar(
                title: 'GARAJ',
              ),
              body: SizedBox(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the back button and tap it
      final backButtonFinder = find.byType(GestureDetector).first;
      expect(backButtonFinder, findsOneWidget);

      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      // Verify dashboardTabProvider is reset to 0 (Ana Sayfa)
      expect(container.read(dashboardTabProvider), equals(0));
      container.dispose();
    });

    testWidgets('Tapping NeoBrutalAppBar back button from Auction/Office tabs resets tab to 0', (tester) async {
      final container = ProviderContainer();
      container.read(dashboardTabProvider.notifier).state = 2; // User is in Auction tab

      expect(container.read(dashboardTabProvider), equals(2));

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
            theme: ThemeData(
              extensions: [
                AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
              ],
            ),
            home: const Scaffold(
              appBar: NeoBrutalAppBar(
                title: 'İHALE SALONU',
              ),
              body: SizedBox(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final backButtonFinder = find.byType(GestureDetector).first;
      await tester.tap(backButtonFinder);
      await tester.pumpAndSettle();

      expect(container.read(dashboardTabProvider), equals(0));
      container.dispose();
    });

    testWidgets('GameHudHeaderWidget renders all status pills and opens modals on tap', (tester) async {
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
            theme: ThemeData(
              extensions: [
                AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
              ],
            ),
            home: const Scaffold(
              body: GameHudHeaderWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify all pills are rendered
      expect(find.textContaining('GÜN'), findsOneWidget);
      expect(find.textContaining('KASA'), findsOneWidget);
      expect(find.textContaining('GARAJ'), findsOneWidget);
      expect(find.textContaining('İTİBAR'), findsOneWidget);
      expect(find.textContaining('GÖREV'), findsOneWidget);

      // Tap Görev pill to open daily missions modal
      await tester.ensureVisible(find.textContaining('GÖREV'));
      await tester.tap(find.textContaining('GÖREV'));
      await tester.pumpAndSettle();

      expect(find.text('GÜNLÜK GÖREVLER'), findsOneWidget);

      container.dispose();
    });
  });
}
