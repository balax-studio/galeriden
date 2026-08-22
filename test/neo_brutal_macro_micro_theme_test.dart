import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/theme_provider.dart';
import 'package:galeriden/presentation/screens/settings/theme_store_screen.dart';
import 'package:galeriden/presentation/widgets/blueprint_grid_background.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_badge.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_card.dart';
import 'package:galeriden/presentation/widgets/windshield_price_sticker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Neo-Brutalist Macro & Micro Design & Absurd Theme Tests', () {
    test('1. AppSpacing 8-point grid tokens are defined consistently', () {
      expect(AppSpacing.xxs, 2.0);
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 24.0);
      expect(AppSpacing.xxl, 32.0);
      expect(AppSpacing.xxxl, 48.0);
    });

    test('2. Toksik Asit & Siber Galeri palette exists in defaultPalettes with correct tokens', () {
      final palettes = ThemePaletteModel.defaultPalettes;
      final cyberPalette = palettes.firstWhere((p) => p.id == 'toksik_asit_cyber');

      expect(cyberPalette.name, contains('Toksik Asit'));
      expect(cyberPalette.price, 150000);
      expect(cyberPalette.isDark, isTrue);
      expect(cyberPalette.primaryColor, const Color(0xFFCCFF00));
      expect(cyberPalette.secondaryColor, const Color(0xFFFF007F));
      expect(cyberPalette.backgroundColor, const Color(0xFF09060F));
      expect(cyberPalette.surfaceColor, const Color(0xFF140D24));
    });

    test('3. ThemeNotifier can unlock and equip Toksik Asit & Siber Galeri palette', () {
      final notifier = ThemeNotifier();
      expect(notifier.state.activePalette.id, 'sanayi_ciragi_light');

      // Attempt unlock with insufficient funds
      final failResult = notifier.unlockPalette('toksik_asit_cyber', 50000);
      expect(failResult, isFalse);

      // Attempt unlock with sufficient funds
      final successResult = notifier.unlockPalette('toksik_asit_cyber', 200000);
      expect(successResult, isTrue);
      expect(notifier.state.activePalette.id, 'toksik_asit_cyber');
      expect(notifier.state.activePalette.isUnlocked, isTrue);
    });

    testWidgets('4. BlueprintGridBackground renders all pattern types cleanly', (tester) async {
      for (final type in BlueprintPatternType.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlueprintGridBackground(
                patternType: type,
                child: const Text('Pattern Test'),
              ),
            ),
          ),
        );
        expect(find.text('Pattern Test'), findsOneWidget);
      }
    });

    testWidgets('5. NeoBrutalCard with showBlueprintGrid renders and compresses on press', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalCard(
              showBlueprintGrid: true,
              patternType: BlueprintPatternType.cyberGrid,
              onTap: () => tapped = true,
              child: const Text('Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Card Content'), findsOneWidget);

      // Tap card
      await tester.tap(find.text('Card Content'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('6. WindshieldPriceSticker and NeoBrutalBadge render without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                WindshieldPriceSticker(
                  priceText: '₺450.000',
                  subtitle: 'KELEPİR',
                  isBargain: true,
                ),
                NeoBrutalBadge(
                  text: 'ABSÜRT SİBER',
                  backgroundColor: AppColors.hotMagenta,
                  showHardShadow: true,
                  angle: -0.05,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('₺450.000'), findsOneWidget);
      expect(find.text('ABSÜRT SİBER'), findsOneWidget);
    });

    testWidgets('7. ThemeStoreScreen renders theme cards and ABSÜRT badge', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, _) {
              final theme = ref.watch(themeProvider).buildThemeData();
              return MaterialApp(
                locale: const Locale('tr'),
                supportedLocales: const [Locale('tr'), Locale('en')],
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                theme: theme,
                home: const ThemeStoreScreen(),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TEMA & GÖRÜNÜM MAĞAZASI'), findsOneWidget);
      expect(find.text('MEVCUT TEMA PALETLERİ'), findsOneWidget);
      expect(find.text('ABSÜRT'), findsOneWidget);
      expect(find.text('AKTİF TEMA ÖNİZLEMESİ'), findsOneWidget);
    });
  });
}
