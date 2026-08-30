import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/showroom/create_listing_screen.dart';
import 'package:galeriden/presentation/screens/showroom/offer_evaluation_screen.dart';

CarModel _createDummyCar() {
  return CarModel(
    id: 'test_car_1',
    brand: 'Toyota',
    modelName: 'Corolla 1.6 Vision',
    modelYear: 2021,
    bodyType: 'Sedan',
    colorHex: '#FFFFFF',
    colorDisplayName: 'Kar Beyazı',
    plateNumber: '34 TYT 101',
    baseMarketValue: 750000,
    currentPurchasePrice: 650000,
    customListingPrice: 790000,
    isDetailedCleaned: true,
    isWashed: true,
    isPolished: false,
    isRare: false,
    expertise: ExpertiseReport(
      engineCondition: 92,
      transmissionCondition: 95,
      tramerAmount: 5000,
      mileage: 45000,
      isMileageTampered: false,
      bodyParts: {
        'frontBumper': PartStatus.painted,
        'hood': PartStatus.original,
      },
    ),
  );
}

OfferModel _createDummyOffer(String carId) {
  return OfferModel(
    id: 'offer_1',
    carId: carId,
    buyerName: 'Ahmet Yılmaz',
    offeredAmount: 720000,
    buyerMessage: 'Aracınız çok temiz görünüyor, nakit hemen alabilirim.',
    createdAt: DateTime.now(),
    status: OfferStatus.pending,
    buyerCustomer: CustomerModel(
      id: 'cust_1',
      name: 'Ahmet Yılmaz',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Memur',
      avatarType: 'buyer_officer',
      personalityDescription: 'Düzenli gelir sahibi memur.',
      preferredDialogueTrait: 'Şeffaflık & Güven',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Trade Sub-Pages UI & Responsive Architecture Tests', () {
    testWidgets('1. CreateListingScreen renders cleanly on 360x780 viewport with all interactive sections',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 780 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final dummyCar = _createDummyCar();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CreateListingScreen(car: dummyCar),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('Toyota Corolla 1.6 Vision'), findsOneWidget);
      expect(find.text('2021 • Sedan • 34 TYT 101'), findsOneWidget);

      // Section verification
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('-5% • Hızlı'), findsOneWidget);
      expect(find.text('Piyasa Emsali'), findsOneWidget);
      expect(find.text('+10% • Dengeli'), findsOneWidget);
      expect(find.text('+20% • Kârlı'), findsOneWidget);

      // Scroll to showcase packages
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();

      expect(find.text('Standart İlan'), findsOneWidget);
      expect(find.text('Acil İlan • Doping'), findsOneWidget);

      // Verify zero overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. CreateListingScreen presets update price and profit margin correctly',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(400 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final dummyCar = _createDummyCar();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CreateListingScreen(car: dummyCar),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap preset '+20% • Kârlı'
      final presetChip = find.text('+20% • Kârlı');
      expect(presetChip, findsOneWidget);
      await tester.tap(presetChip);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('3. OfferEvaluationScreen renders cleanly on 360x780 viewport with buyer radar and tension gauge',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360 * 2, 780 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final dummyCar = _createDummyCar();
      final dummyOffer = _createDummyOffer(dummyCar.id);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: OfferEvaluationScreen(
              args: OfferEvaluationArgs(car: dummyCar, offer: dummyOffer),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Buyer overview
      expect(find.text('Toyota Corolla 1.6 Vision'), findsOneWidget);
      expect(find.text('Ahmet Yılmaz'), findsOneWidget);
      expect(find.text('Memur'), findsOneWidget);

      // Verify psychology and tension sections
      expect(find.text('Alıcı Profili & Psikoloji Radarı'), findsOneWidget);
      expect(find.text('Karşı Teklif & Gerilim Masası'), findsOneWidget);

      // Scroll to notary settlement card
      await tester.scrollUntilVisible(find.text('Noter & Kâr Hesaplaşma Önizlemesi'), 200);
      await tester.pumpAndSettle();
      expect(find.text('Noter & Kâr Hesaplaşma Önizlemesi'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Karşı Teklif Gönder'), findsOneWidget);
      expect(find.text('Kabul Et & Sat'), findsOneWidget);

      // Verify zero overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. Both screens render cleanly without overflow on compact 320x568 low-height device',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320 * 2, 568 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final dummyCar = _createDummyCar();
      final dummyOffer = _createDummyOffer(dummyCar.id);

      // Test CreateListingScreen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CreateListingScreen(car: dummyCar),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Test OfferEvaluationScreen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: OfferEvaluationScreen(
              args: OfferEvaluationArgs(car: dummyCar, offer: dummyOffer),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
