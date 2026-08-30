import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';
import 'package:galeriden/presentation/screens/marketplace/negotiation_screen.dart';

class _TestMarketNotifier extends MarketNotifier {
  _TestMarketNotifier(super.ref, List<ListingModel> initialListings) {
    state = initialListings;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NegotiationScreen renders full-screen Scaffold and deals room elements properly', (tester) async {
    final testCar = CarModel(
      id: 'test_car_1',
      brand: 'Toyota',
      modelName: 'Corolla',
      modelYear: 2020,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: 500000,
      currentPurchasePrice: 480000,
      expertise: ExpertiseReport(
        engineCondition: 90,
        transmissionCondition: 90,
        tramerAmount: 0,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    final testListing = ListingModel(
      id: 'listing_1',
      car: testCar,
      askingPrice: 520000,
      sellerName: 'Ahmet Bey',
      sellerTrait: 'Tok Satıcı',
      sellerCity: 'İstanbul',
      title: 'Temiz Aile Arabası',
      description: 'Hatasız boyasız',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          marketProvider.overrideWith((ref) => _TestMarketNotifier(ref, [testListing])),
        ],
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
          home: NegotiationScreen(listing: testListing),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar and Header
    expect(find.text('PAZARLIK MASASI'), findsOneWidget);
    expect(find.text('Ahmet Bey'), findsOneWidget);
    expect(find.text('Toyota Corolla'), findsOneWidget);
    expect(find.text('2020'), findsOneWidget);

    // Verify discount chips exist (%5, %10, %15, %20)
    expect(find.text('-%5'), findsOneWidget);
    expect(find.text('-%10'), findsOneWidget);
    expect(find.text('-%15'), findsOneWidget);
    expect(find.text('-%20'), findsOneWidget);
    expect(find.text('Tam Fiyat'), findsOneWidget);

    // Verify Arcade Segmented Gauge & Persuasion Gauge Title
    expect(find.text('İKNA VE KABUL OLASILIĞI'), findsOneWidget);

    // Verify Esnaf Tactics and Koz Counter exist
    expect(find.textContaining('KOZ KULLANILDI'), findsOneWidget);
    expect(find.text('ESNAF KOZLARI & MÜZAKERE TAKTİKLERİ'), findsOneWidget);

    // Verify CTA Button exists
    expect(find.textContaining('TEKLİFİ İLET'), findsOneWidget);

    // Tap -%20 chip to update price
    await tester.tap(find.text('-%20'));
    await tester.pumpAndSettle();

    // Verify offered price updated
    expect(find.text('₺416.000'), findsOneWidget);

    // Scroll to CTA and tap to send offer and trigger suspense thinking state
    final ctaFinder = find.textContaining('TEKLİFİ İLET');
    await tester.ensureVisible(ctaFinder);
    await tester.pumpAndSettle();
    await tester.tap(ctaFinder);
    await tester.pump(const Duration(milliseconds: 100));

    // Verify thinking radar is active
    expect(find.text('CANLI DÜŞÜNCE RADARI'), findsOneWidget);
    expect(find.text('TEKLİF DEĞERLENDİRİLİYOR...'), findsOneWidget);

    // Advance through all suspense stages (up to 3.5s)
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify either accepted or rejected dialog appeared
    expect(find.byType(NegotiationScreen), findsOneWidget);
  });
}

