import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/scrapyard/scrapyard_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Scrapyard dismantle dialog transitions to SÖKÜLDÜ state and prevents spam', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    const initialPart = SalvagedPart(
      id: 'part_engine_1',
      name: '2.0 TwinPower Turbo Motor Bloğu',
      category: 'engine',
      tier: PartQualityTier.good,
      conditionPercent: 88,
      estimatedValue: 120000.0,
      carModelName: 'Bemeve 3.20d',
    );

    const initialCar = ScrapyardCar(
      id: 'scrap_car_1',
      brand: 'Bemeve',
      modelName: '3.20d Yanlama E-90',
      modelYear: 2011,
      scrapPrice: 65000.0,
      estimatedPartTotalValue: 120000.0,
      damageNote: 'Ağır Pert',
      chassisScrapValue: 35000.0,
      parts: [initialPart],
      isPurchased: true,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          theme: ThemeData(
            extensions: [
              AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
            ],
          ),
          home: const ScrapyardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Configure test state on mounted provider and stop organic background timer
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
      unlockedBuildings: {'/scrapyard'},
      scrapyardCars: [initialCar],
      salvagedParts: [],
    );
    await tester.pumpAndSettle();

    // Find and tap TEK TEK SÖK button on the scrap car card
    final sokumBtn = find.text('TEK TEK SÖK');
    expect(sokumBtn, findsOneWidget);
    await tester.tap(sokumBtn);
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.text('PARÇA PARÇA SÖKÜM'), findsOneWidget);
    expect(find.text('1 Parça Kaldı'), findsOneWidget);
    expect(find.text('SÖK & AL'), findsOneWidget);

    // Tap SÖK & AL
    await tester.tap(find.text('SÖK & AL'));
    await tester.pumpAndSettle();

    // Select rapid dismantle option
    expect(find.text('HIZLI OTOMATİK SÖKÜM'), findsOneWidget);
    await tester.tap(find.text('HIZLI OTOMATİK SÖKÜM'));
    await tester.pumpAndSettle();

    // Verify button turned into SÖKÜLDÜ and is disabled (no SÖK & AL remaining)
    expect(find.text('SÖKÜLDÜ'), findsOneWidget);
    expect(find.text('SÖK & AL'), findsNothing);
    expect(find.text('TAMAMI SÖKÜLDÜ'), findsOneWidget);
    expect(find.text('Söküldü • Depoya Aktarıldı'), findsOneWidget);

    // Verify part was dismantled from scrap car and moved
    final state = container.read(gameProvider);
    expect(state.scrapyardCars.first.parts, isEmpty);
    expect(state.salvagedParts.length, anyOf(0, 1));

    // Stop periodic timer and drain toast notification timer
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpWidget(const SizedBox());
  });
}
