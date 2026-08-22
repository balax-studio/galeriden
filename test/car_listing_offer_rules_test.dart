import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/showroom/widgets/showroom_listing_modal.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final dummyExpertise = ExpertiseReport(
    engineCondition: 90,
    transmissionCondition: 90,
    tramerAmount: 0,
    mileage: 50000,
    isMileageTampered: false,
    bodyParts: {},
  );

  final unlistedCar = CarModel(
    id: 'car_unlisted',
    brand: 'BMW',
    modelName: '320i',
    modelYear: 2021,
    bodyType: 'Sedan',
    colorHex: '#000000',
    baseMarketValue: 1000000,
    currentPurchasePrice: 900000,
    customListingPrice: null, // Unlisted!
    expertise: dummyExpertise,
  );

  final listedCar = CarModel(
    id: 'car_listed',
    brand: 'Audi',
    modelName: 'A4',
    modelYear: 2022,
    bodyType: 'Sedan',
    colorHex: '#FFFFFF',
    baseMarketValue: 1200000,
    currentPurchasePrice: 1100000,
    customListingPrice: 1250000, // Listed!
    expertise: dummyExpertise,
  );

  group('Car Listing & Offer Rules Tests', () {
    late GameNotifier gameNotifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
    });

    test('car.isListed check', () {
      expect(unlistedCar.isListed, false);
      expect(listedCar.isListed, true);
    });

    test('Unlisted car cannot receive organic offers or doping', () {
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 100000,
        ownedCars: [unlistedCar],
      );

      // Try boostListingDoping on unlisted car
      final dopingSuccess = gameNotifier.boostListingDoping(unlistedCar.id);
      expect(dopingSuccess, false, reason: 'Doping must be rejected for unlisted car');

      // Trigger organic offers
      gameNotifier.triggerOrganicOffers();
      expect(gameNotifier.state.incomingOffers.length, 0, reason: 'Unlisted car must not receive organic offers');
    });

    test('Doping can only be applied ONCE per car', () {
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 100000,
        ownedCars: [listedCar],
      );

      // First doping purchase should succeed
      final firstDoping = gameNotifier.boostListingDoping(listedCar.id);
      expect(firstDoping, true);
      expect(gameNotifier.state.ownedCars.first.isDoped, true);

      // Second doping purchase on the same car must fail
      final secondDoping = gameNotifier.boostListingDoping(listedCar.id);
      expect(secondDoping, false, reason: 'Doping can only be purchased once per car');
    });

    test('Maximum 3 active offers per car limit enforced', () {
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 100000,
        ownedCars: [listedCar],
      );

      // Manually trigger organic offers up to limit
      gameNotifier.triggerOrganicOffers();
      gameNotifier.triggerOrganicOffers();
      gameNotifier.triggerOrganicOffers();

      expect(gameNotifier.state.incomingOffers.where((o) => o.carId == listedCar.id && !o.isExpired).length, 3);

      // Attempting 4th organic offer should be blocked
      gameNotifier.triggerOrganicOffers();
      expect(gameNotifier.state.incomingOffers.where((o) => o.carId == listedCar.id && !o.isExpired).length, 3);

      // Doping on car with 3 offers should also be rejected
      final dopingOnFull = gameNotifier.boostListingDoping(listedCar.id);
      expect(dopingOnFull, false, reason: 'Doping should be rejected when car has max 3 active offers');
    });

    testWidgets('showListingEditSheet renders safely with legacy car values (photoCount: 3, tone: honest)', (tester) async {
      final legacyCar = CarModel(
        id: 'car_legacy',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#333333',
        baseMarketValue: 600000,
        currentPurchasePrice: 500000,
        listingPhotoCount: 3, // Legacy non-matching value
        listingTone: 'honest', // Legacy non-matching value
        listingPhotoLocation: 'sanayi', // Legacy non-matching value
        expertise: dummyExpertise,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.darkTheme,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, _) {
                  return ElevatedButton(
                    onPressed: () => ShowroomListingModal.showListingEditSheet(context, ref, legacyCar),
                    child: const Text('Open Modal'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('İLAN AYARLARI'), findsOneWidget);
      expect(find.text('Fotoğraf Sayısı'), findsOneWidget);
      expect(find.text('İlan Tonu'), findsOneWidget);
    });
  });
}

