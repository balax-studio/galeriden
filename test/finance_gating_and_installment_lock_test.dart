import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';

void main() {
  group('Finance Gating & Installment Lock Test Suite', () {
    final testCar = CarModel(
      id: 'car_install_test',
      brand: 'Bemeve',
      modelName: 'Üç Yirmi Dizel',
      modelYear: 2021,
      bodyType: 'Sedan',
      colorHex: '#FFFFFF',
      baseMarketValue: 1200000,
      currentPurchasePrice: 1100000,
      allowsInstallments: true,
      expertise: ExpertiseReport(
        engineCondition: 100.0,
        transmissionCondition: 100.0,
        tramerAmount: 0,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: {},
      ),
    );

    test('1. DealershipModel required level for /finance is 5; unlockedBuildings controls feature access', () {
      expect(DealershipModel.getRequiredLevel('/finance'), equals(5));

      final earlyGame = DealershipModel.initial();
      expect(earlyGame.isFeatureUnlocked('/finance'), isFalse);

      final financeGame = DealershipModel.initial().copyWith(unlockedBuildings: {'/finance'});
      expect(financeGame.isFeatureUnlocked('/finance'), isTrue);
    });

    test('2. When finance is locked (isFinanceUnlocked: false), offers are 100% CASH only', () {
      for (int i = 0; i < 50; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(
          testCar,
          testCar.listingPrice,
          isFinanceUnlocked: false,
        );

        expect(offer.offerType, equals(OfferType.cash));
        expect(offer.installmentMonths, equals(0));
        expect(offer.buyerMessage.contains('senetle'), isFalse);
        expect(offer.buyerMessage.contains('çekle'), isFalse);
      }
    });

    test('3. When finance is unlocked (isFinanceUnlocked: true), installment and cheque offers generate', () {
      int installmentOrChequeCount = 0;
      for (int i = 0; i < 50; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(
          testCar,
          testCar.listingPrice,
          isFinanceUnlocked: true,
        );

        if (offer.offerType == OfferType.installment || offer.offerType == OfferType.cheque) {
          installmentOrChequeCount++;
        }
      }

      expect(installmentOrChequeCount, greaterThan(15));
    });

    test('4. Invariant checks: zero parentheses and zero emojis in generated messages', () {
      for (int i = 0; i < 20; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(
          testCar,
          testCar.listingPrice,
          isFinanceUnlocked: true,
        );

        expect(offer.buyerMessage.contains('('), isFalse);
        expect(offer.buyerMessage.contains(')'), isFalse);

        final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);
        expect(emojiRegex.hasMatch(offer.buyerMessage), isFalse);
      }
    });
  });
}
