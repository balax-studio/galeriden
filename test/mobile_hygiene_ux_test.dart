import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:galeriden/presentation/screens/showroom/widgets/showroom_offers_tab.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_skeleton.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTheme = ThemeData.light().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  group('Mobile Hygiene UX Patterns Test Suite', () {
    testWidgets('1. NeoBrutalSkeleton renders shimmer boxes and cards properly', (tester) async {
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
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  NeoBrutalSkeletonBox(width: 200, height: 24),
                  NeoBrutalSkeletonBox(width: 50, height: 50, isCircle: true),
                  NeoBrutalSkeletonCarCard(),
                  NeoBrutalSkeletonList(itemCount: 2),
                ],
              ),
            ),
          ),
        ),
      );

      // Verify skeleton boxes render without errors
      expect(find.byType(NeoBrutalSkeletonBox), findsWidgets);
      expect(find.byType(NeoBrutalSkeletonCarCard), findsWidgets);
      expect(find.byType(NeoBrutalSkeletonList), findsOneWidget);

      // Advance timer for animation ticker
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('2. MarketplaceScreen has RefreshIndicator, Skeleton, and Debounced Search', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
            theme: testTheme,
            home: const MarketplaceScreen(),
          ),
        ),
      );

      // Advance past initial build
      await tester.pump(const Duration(milliseconds: 100));

      // Verify RefreshIndicator exists
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Verify search input field exists
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // Type in search bar
      await tester.enterText(searchField, 'Sedan');
      await tester.pump(const Duration(milliseconds: 300)); // debounce timer

      // Verify clear button appears when search text is present
      final clearButton = find.byIcon(Icons.clear_rounded);
      expect(clearButton, findsOneWidget);

      await tester.tap(clearButton);
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('3. ShowroomOffersTab has Dismissible swipe actions and RefreshIndicator', (tester) async {
      final sampleCar = CarModel(
        id: 'car_owned_1',
        brand: 'Mercedes',
        modelName: 'C200',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 2000000,
        currentPurchasePrice: 1900000,
        customListingPrice: 2100000,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 20000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final sampleOffer = OfferModel(
        id: 'offer_1',
        carId: 'car_owned_1',
        buyerName: 'Mehmet Yılmaz',
        offeredAmount: 2050000,
        status: OfferStatus.pending,
        buyerMessage: 'Aracınıza talibim, hemen nakit alırım.',
        createdAt: DateTime.now(),
      );

      final mockGame = DealershipModel.initial().copyWith(
        ownedCars: [sampleCar],
        incomingOffers: [sampleOffer],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
            theme: testTheme,
            home: Scaffold(
              body: ShowroomOffersTab(
                game: mockGame,
                palette: ThemePaletteModel.defaultPalettes.first,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      // Verify RefreshIndicator exists
      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Verify Dismissible widget exists for the offer
      expect(find.byType(Dismissible), findsOneWidget);
      expect(find.textContaining('Mehmet Yılmaz'), findsOneWidget);
      expect(find.text('Mercedes C200'), findsOneWidget);
    });
  });
}
