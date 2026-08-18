import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/trade_in_engine.dart';

void main() {
  group('Trade-In Valuation Matching & Absurd Offer Rate Test Suite', () {
    final expensiveSuperCar = CarModel(
      id: 'super_car_1',
      brand: 'Lambor',
      modelName: 'Boğası V12 Egzotik',
      modelYear: 2023,
      bodyType: 'Spor',
      colorHex: '#FFD700',
      baseMarketValue: 12000000.0,
      currentPurchasePrice: 11500000.0,
      expertise: ExpertiseReport(
        engineCondition: 100.0,
        transmissionCondition: 100.0,
        tramerAmount: 0,
        mileage: 8000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    final midRangeSedan = CarModel(
      id: 'mid_car_1',
      brand: 'Volks',
      modelName: 'Pasat Dizel',
      modelYear: 2020,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: 900000.0,
      currentPurchasePrice: 850000.0,
      expertise: ExpertiseReport(
        engineCondition: 90.0,
        transmissionCondition: 92.0,
        tramerAmount: 5000,
        mileage: 65000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    test('1. Realistic trade-in offers match target vehicle price range (0.35x - 2.2x)', () {
      int realisticCount = 0;
      int absurdCount = 0;

      for (int i = 0; i < 100; i++) {
        final offer = TradeInEngine.generateTradeInOffer(
          targetCar: midRangeSedan,
          inGameDay: i + 1,
        );

        final targetVal = midRangeSedan.estimatedRealValue;
        final offeredVal = offer.offeredCar.estimatedRealValue;
        final ratio = offeredVal / targetVal;

        if (ratio >= 0.35 && ratio <= 2.2) {
          realisticCount++;
        } else {
          absurdCount++;
        }
      }

      // Vast majority of trades must be realistic and proportional
      expect(realisticCount, greaterThanOrEqualTo(80));
      expect(absurdCount, lessThanOrEqualTo(20));
    });

    test('2. Absurd trades generate special humorous dialogues without breaking invariants', () {
      bool sawHumorousDialogue = false;

      for (int i = 0; i < 100; i++) {
        final offer = TradeInEngine.generateTradeInOffer(
          targetCar: expensiveSuperCar,
          inGameDay: i + 1,
        );

        // Check for invariant rules: Zero parentheses and zero emojis
        expect(offer.dialogueText.contains('('), isFalse);
        expect(offer.dialogueText.contains(')'), isFalse);
        final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);
        expect(emojiRegex.hasMatch(offer.dialogueText), isFalse);

        if (offer.dialogueText.contains('dağa taşa') ||
            offer.dialogueText.contains('tank gibi') ||
            offer.dialogueText.contains('nostalji') ||
            offer.dialogueText.contains('parçası bedava')) {
          sawHumorousDialogue = true;
        }
      }

      expect(sawHumorousDialogue, isTrue);
    });

    test('3. Cash difference is calculated consistently with fair difference direction', () {
      for (int i = 0; i < 20; i++) {
        final offer = TradeInEngine.generateTradeInOffer(
          targetCar: midRangeSedan,
          inGameDay: i + 1,
        );

        final targetVal = midRangeSedan.listingPrice;
        final offeredVal = offer.offeredCar.estimatedRealValue;

        if (targetVal > offeredVal * 1.2) {
          // Player's car is worth more, player should receive cash
          expect(offer.cashDifference, greaterThan(0));
        } else if (offeredVal > targetVal * 1.2) {
          // Customer's car is worth more, customer expects extra cash from player
          expect(offer.cashDifference, lessThan(0));
        }
      }
    });
  });
}
