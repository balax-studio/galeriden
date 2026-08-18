import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/notary_event_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/dialogs/notary_transfer_dialog.dart';
import 'package:galeriden/presentation/widgets/zeigarnik_progress_bar.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Zeigarnik Curve & Progress Bar Tests', () {
    test('ZeigarnikProgressCurve accelerates 0-50% and decelerates 50-100%', () {
      const curve = ZeigarnikProgressCurve();

      expect(curve.transform(0.0), equals(0.0));
      expect(curve.transform(1.0), equals(1.0));

      // At 25% time, progress should be significantly > 25% (accelerated gratification)
      final atQuarter = curve.transform(0.25);
      expect(atQuarter, greaterThan(0.35));

      // At 50% time, progress reaches exactly 50%
      final atHalf = curve.transform(0.50);
      expect(atHalf, closeTo(0.50, 0.01));

      // At 75% time, remaining growth is slower (easing into 1.0)
      final atThreeQuarter = curve.transform(0.75);
      expect(atThreeQuarter, greaterThan(0.85));
    });

    testWidgets('ZeigarnikProgressBar renders properly with custom values', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeigarnikProgressBar(
              progress: 0.65,
              height: 14,
              fillColor: Color(0xFF00E575),
              backgroundColor: Color(0xFF1E2330),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ZeigarnikProgressBar), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 900));
    });
  });

  group('Notary System & Random Events Tests', () {
    CarModel createCar() {
      return CarModel(
        id: 'car_notary_1',
        brand: 'Volkswagen',
        modelName: 'Passat',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFFFFFFFF',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 65000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );
    }

    test('NotaryEventResult evaluateNotaryEvent returns compliant title and descriptions', () {
      for (int i = 0; i < 50; i++) {
        final result = NotaryEventResult.evaluateNotaryEvent(
          buyerName: 'Ahmet Bey',
          carTitle: 'Volkswagen Passat',
          price: 1250000,
          dealershipReputation: 75,
        );

        expect(result.title.isNotEmpty, isTrue);
        expect(result.description.isNotEmpty, isTrue);
        // Zero parentheses rule
        expect(result.title.contains('('), isFalse);
        expect(result.title.contains(')'), isFalse);
        expect(result.description.contains('('), isFalse);
        expect(result.description.contains(')'), isFalse);
      }
    });

    test('processNotarySale completes sale and awards XP or handles cancellation', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      final car = createCar();

      notifier.state = notifier.state.copyWith(
        balance: 500000,
        ownedCars: [car],
      );

      final offer = OfferModel(
        id: 'offer_test_1',
        carId: car.id,
        buyerName: 'Hakan Usta',
        buyerMessage: 'Aracı çok beğendim, nakit hemen alabilirim.',
        offeredAmount: 1220000,
        createdAt: DateTime.now(),
      );

      final customer = CustomerModel.generateRandomCustomer();
      final result = notifier.processNotarySale(offer, customer);

      if (!result.isCancelled) {
        expect(notifier.state.ownedCars.any((c) => c.id == car.id), isFalse);
        expect(notifier.state.balance, greaterThan(500000));
      } else {
        expect(notifier.state.ownedCars.any((c) => c.id == car.id), isTrue);
      }
    });

    testWidgets('NotaryTransferDialog mounts and animates stamp properly', (tester) async {
      final car = createCar();
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NotaryTransferDialog.show(
                    context: context,
                    car: car,
                    buyerName: 'Mert Yılmaz',
                    sellerName: 'Örnek Galeri • Ali Usta',
                    salePrice: 1250000,
                    isBuying: false,
                    eventResult: const NotaryEventResult(
                      type: NotaryEventType.smoothDeal,
                      title: 'NOTER TASDİK EDİLDİ • DEVİR TAMAMLANDI',
                      description: 'Ruhsat devri başarıyla tamamlandı.',
                      bonusXp: 5,
                    ),
                    onComplete: () => completed = true,
                  );
                },
                child: const Text('Aç'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Aç'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('T.C. NOTERLİĞİ • ARAÇ DEVİR TESCİLİ'), findsOneWidget);
      expect(find.text('MÜHÜRLENDİ'), findsOneWidget);

      await tester.tap(find.text('DEVİR VE TESCİLİ TAMAMLA'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });
  });
}
