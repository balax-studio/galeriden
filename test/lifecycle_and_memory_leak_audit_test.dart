import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_review_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/sale_record_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';
import 'package:galeriden/presentation/providers/outsourced_tuning_provider.dart';
import 'package:galeriden/presentation/providers/real_estate_market_provider.dart';
import 'package:galeriden/presentation/providers/vasita_market_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

CarModel _createTestCar({
  required String id,
  required String brand,
  required String modelName,
  required double price,
}) {
  return CarModel(
    id: id,
    brand: brand,
    modelName: modelName,
    modelYear: 2020,
    bodyType: 'sedan',
    colorHex: '#FFFFFF',
    baseMarketValue: price,
    currentPurchasePrice: price,
    expertise: ExpertiseReport(
      engineCondition: 90,
      transmissionCondition: 90,
      tramerAmount: 0,
      mileage: 50000,
      isMileageTampered: false,
      bodyParts: const {},
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Lifecycle & Memory Leak Audits', () {
    test('Game clock resumes properly after app background and foreground', () async {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      // Simulate AppLifecycleState.paused
      notifier.onAppPaused();

      // Simulate AppLifecycleState.resumed
      notifier.onAppResumed();

      // Ensure stopPeriodicOrganicOfferTimer cleans up without error
      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('Vasita and Real Estate market notifiers pause and resume without leaking', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final vasitaNotifier = container.read(vasitaMarketProvider.notifier);
      final realEstateNotifier = container.read(realEstateMarketProvider.notifier);
      final marketNotifier = container.read(marketProvider.notifier);

      // App background pause
      vasitaNotifier.onAppPaused();
      realEstateNotifier.onAppPaused();
      marketNotifier.onAppPaused();

      // App foreground resume
      vasitaNotifier.onAppResumed();
      realEstateNotifier.onAppResumed();
      marketNotifier.onAppResumed();

      expect(container.read(vasitaMarketProvider).isNotEmpty, isTrue);
      expect(container.read(realEstateMarketProvider).isNotEmpty, isTrue);
      expect(container.read(marketProvider).isNotEmpty, isTrue);
    });

    test('Outsourced tuning ticker pauses on background and resumes on foreground', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final tuningNotifier = container.read(outsourcedTuningProvider.notifier);
      tuningNotifier.onAppPaused();
      tuningNotifier.onAppResumed();

      expect(container.read(outsourcedTuningProvider).activeOrders.isEmpty, isTrue);
    });

    test('Sales history is strictly bounded to prevent heap bloat over long sessions', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final initialSales = List.generate(
        160,
        (i) => SaleRecordModel(
          id: 'sale_$i',
          carTitle: 'Fiat Egea',
          buyerName: 'Müşteri $i',
          salePrice: 500000.0,
          purchasePrice: 450000.0,
          netProfit: 50000.0,
          saleDay: i + 1,
          saleDate: DateTime.now(),
        ),
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        salesHistory: initialSales,
      );

      final car = _createTestCar(
        id: 'test_bound_car',
        brand: 'Renault',
        modelName: 'Clio',
        price: 400000.0,
      );

      notifier.state = notifier.state.copyWith(
        ownedCars: [car],
      );

      final sold = notifier.sellCarAtAuction(
        carId: car.id,
        salePrice: 450000.0,
        commission: 10000.0,
        fixedFee: 2500.0,
        buyerName: 'Müzayede Alıcısı',
      );

      expect(sold, isTrue);
      expect(notifier.state.salesHistory.length <= 150, isTrue);
    });

    test('Customer reviews are bounded to 50 items to avoid unbounded memory retention', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final initialReviews = List.generate(
        60,
        (i) => CustomerReviewModel(
          id: 'review_$i',
          reviewerName: 'Customer $i',
          rating: 4.5,
          comment: 'Güzel araç',
          carTitle: 'Renault Megane',
          createdAt: DateTime.now(),
        ),
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        customerReviews: initialReviews,
        balance: 1000000.0,
      );

      // Trigger a bot review purchase which prepends to customerReviews
      final bought = notifier.buyBotReview();

      expect(bought, isTrue);
      expect(notifier.state.customerReviews.length <= 50, isTrue);
    });
  });
}
