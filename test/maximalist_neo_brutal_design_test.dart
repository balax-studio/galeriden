import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/expertise/expertise_screen.dart';
import 'package:galeriden/presentation/screens/night_market/night_market_screen.dart';
import 'package:galeriden/presentation/screens/showroom/widgets/showroom_car_card.dart';
import 'package:galeriden/presentation/widgets/dot_grid_background.dart';
import 'package:galeriden/presentation/widgets/game_hud_widget.dart';
import 'package:galeriden/presentation/widgets/hazard_stripe_widget.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_card.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_stamp.dart';
import 'package:galeriden/presentation/widgets/windshield_price_sticker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTheme = ThemeData.dark().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    toastification.dismissAll(delayForAnimation: false);
  });

  CarModel createSampleCar({
    String id = 'max_test_car_1',
    double price = 650000,
    bool isListed = true,
    bool isDoped = true,
    bool isLockedInShowcase = true,
  }) {
    return CarModel(
      id: id,
      brand: 'Mercedes-Benz',
      modelName: 'C200 AMG',
      modelYear: 2021,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: price,
      currentPurchasePrice: price,
      customListingPrice: isListed ? price : null,
      isDoped: isDoped,
      isLockedInShowcase: isLockedInShowcase,
      expertise: ExpertiseReport(
        engineCondition: 92,
        transmissionCondition: 88,
        tramerAmount: 0,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: const {
          'Kaput': PartStatus.original,
          'Tavan': PartStatus.original,
          'Ön Tampon': PartStatus.painted,
        },
      ),
    );
  }

  group('Maximalist Neo-Brutalist & Industrial UI/UX Test Suite', () {
    testWidgets('1. NeoBrutalStamp and WindshieldPriceSticker Render Correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NeoBrutalStamp(text: 'BOYASIZ HATASIZ', color: Color(0xFF00E575)),
                  SizedBox(height: 10),
                  WindshieldPriceSticker(priceText: '₺750.000', isBargain: true),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BOYASIZ HATASIZ'), findsOneWidget);
      expect(find.text('₺750.000'), findsOneWidget);
      expect(find.text('KELEPİR FİYAT'), findsOneWidget);
    });

    testWidgets('2. HazardStripeWidget and DotGridBackground Paint without Assertion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: DotGridBackground(
              child: Center(
                child: HazardStripeWidget(
                  height: 14,
                  width: 200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HazardStripeWidget), findsOneWidget);
      expect(find.byType(DotGridBackground), findsOneWidget);
    });

    testWidgets('3. NeoBrutalCard with Hazard Header and Dot Grid Displays Tactile Response', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: Scaffold(
            body: Center(
              child: NeoBrutalCard(
                showHazardHeader: true,
                showDotGrid: true,
                onTap: () => tapped = true,
                child: const Text('MAXIMALIST INDUSTRIAL CARD'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MAXIMALIST INDUSTRIAL CARD'), findsOneWidget);
      expect(find.byType(HazardStripeWidget), findsOneWidget);

      await tester.tap(find.text('MAXIMALIST INDUSTRIAL CARD'));
      await tester.pumpAndSettle();
      expect(tapped, true);
    });

    testWidgets('4. ShowroomCarCard Renders with Maximalist Stamps and Badges', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final car = createSampleCar();
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: ShowroomCarCard(
                  car: car,
                  game: DealershipModel.initial(),
                  palette: ThemePaletteModel.defaultPalettes.first,
                  hasSalesman: false,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KOLEKSİYONDA'), findsOneWidget);
      expect(find.text('DOPİNGLİ'), findsOneWidget);
      expect(find.text('Mercedes-Benz C200 AMG'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('5. ExpertiseScreen with DotGrid and Rubber Stamp Inspection Layout', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final car = createSampleCar();
      final listing = ListingModel(
        id: 'list_test_1',
        car: car,
        sellerName: 'Ahmet Galeri',
        askingPrice: 620000,
        sellerTrait: 'Standart',
        title: 'Temiz C200',
        description: 'Temiz dosta gider',
        sellerCity: 'İstanbul',
        createdAt: DateTime.now(),
        isExpertiseCompleted: true,
      );

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(balance: 1000000);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: ExpertiseScreen(listing: listing),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DETAYLI EKSPERTİZ RAPORU'), findsOneWidget);
      expect(find.byType(DotGridBackground), findsWidgets);
      expect(find.textContaining('RAPOR #EXP-'), findsOneWidget);
      expect(find.byType(NeoBrutalStamp), findsAtLeastNWidgets(1));

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('6. NightMarketScreen Renders with Cyber Hazard Aesthetics', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final car = createSampleCar();
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 1000000,
        ownedCars: [car],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const NightMarketScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GECE SANAYİSİ & YARIŞ'), findsOneWidget);
      expect(find.text('GECE MEZATI & DRAG YARIŞI'), findsOneWidget);
      expect(find.byType(HazardStripeWidget), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('7. Season Modal Renders with Neo-Brutalist Cards, Badges and Progress', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const Scaffold(
              body: GameHudHeaderWidget(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the season pill
      final seasonFinder = find.text('İLKBAHAR ');
      expect(seasonFinder, findsOneWidget);
      await tester.tap(seasonFinder);
      await tester.pumpAndSettle();

      // Verify Neo-Brutalist Season Dialog elements
      expect(find.text('28 GÜNLÜK MEVSİM DÖNGÜSÜ'), findsOneWidget);
      expect(find.text('AKTİF MEVSİM'), findsOneWidget);
      expect(find.text('MEVSİM İLERLEMESİ'), findsOneWidget);
      expect(find.text('MEVSİMSEL PİYASA TALEPLERİ & DEĞER FARKLARI'), findsOneWidget);
      expect(find.text('İlkbahar'), findsOneWidget);
      expect(find.text('Yaz'), findsOneWidget);
      expect(find.text('Sonbahar'), findsOneWidget);
      expect(find.text('Kış'), findsOneWidget);
      expect(find.text('+%15 Talep'), findsWidgets);
      expect(find.text('+%30 Değer'), findsOneWidget);
      expect(find.text('PİYASA ETKİSİNİ ANLADIM'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('PİYASA ETKİSİNİ ANLADIM'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('8. Weather Modal Renders with Neo-Brutalist Live Impact Cards and Badges', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const Scaffold(
              body: GameHudHeaderWidget(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and tap the weather pill
      final weatherFinder = find.text('HAVA ');
      expect(weatherFinder, findsOneWidget);
      await tester.tap(weatherFinder);
      await tester.pumpAndSettle();

      // Verify Neo-Brutalist Weather Dialog elements
      expect(find.text('HAVA DURUMU & PİYASA'), findsOneWidget);
      expect(find.text('CANLI ETKİ'), findsOneWidget);
      expect(find.text('GÜNCEL PİYASA ÇARPANLARI'), findsOneWidget);
      expect(find.text('Ziyaretçi Trafiği'), findsOneWidget);
      expect(find.text('Oto Yıkama Talebi'), findsOneWidget);
      expect(find.text('SUV & 4x4 Talebi'), findsOneWidget);
      expect(find.text('Spor Araç Talebi'), findsOneWidget);
      expect(find.text('Oto Çekici Çağrıları'), findsOneWidget);
      expect(find.text('Kusur Sezgi Doğruluğu'), findsOneWidget);
      expect(find.text('TAMAM'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('TAMAM'));
      await tester.pumpAndSettle();

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
