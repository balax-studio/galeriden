import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';

void main() {
  group('Car Listing Payment Options & Price Ceiling Enforcement Tests', () {
    late CarModel cashOnlyCar;
    late CarModel installmentCar;

    setUp(() {
      final cleanExpertise = ExpertiseReport(
        engineCondition: 90.0,
        transmissionCondition: 90.0,
        bodyParts: {},
        tramerAmount: 0,
        mileage: 50000,
        isMileageTampered: false,
      );

      cashOnlyCar = CarModel(
        id: 'car_cash_1',
        brand: 'Bimmer',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'sedan',
        colorHex: '0xFF1E293B',
        baseMarketValue: 1200000.0,
        currentPurchasePrice: 1000000.0,
        customListingPrice: 1250000.0, // Set custom asking price
        allowsInstallments: false,    // Vadeli KAPALI
        expertise: cleanExpertise,
      );

      installmentCar = CarModel(
        id: 'car_inst_1',
        brand: 'Merso',
        modelName: 'C200',
        modelYear: 2021,
        bodyType: 'sedan',
        colorHex: '0xFF0F172A',
        baseMarketValue: 1500000.0,
        currentPurchasePrice: 1300000.0,
        customListingPrice: 1600000.0,
        allowsInstallments: true,     // Vadeli AÇIK
        expertise: cleanExpertise,
      );
    });

    test('When allowsInstallments is false, 100% of generated offers MUST be cash', () {
      for (int i = 0; i < 100; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(cashOnlyCar, cashOnlyCar.listingPrice);
        expect(offer.offerType, equals(OfferType.cash),
            reason: 'Offer #$i was ${offer.offerType} instead of cash when allowsInstallments is false');
        expect(offer.installmentMonths, equals(0));
      }
    });

    test('When allowsInstallments is false, cash offers NEVER exceed listing price', () {
      final asking = cashOnlyCar.listingPrice;
      for (int i = 0; i < 100; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(cashOnlyCar, asking);
        expect(offer.offeredAmount, lessThanOrEqualTo(asking),
            reason: 'Offer #$i (${offer.offeredAmount}) exceeded asking price ($asking)');
        expect(offer.offeredAmount, greaterThan(0));
      }
    });

    test('When allowsInstallments is true, installment & cheque offers are generated with valid premiums', () {
      int nonCashOffers = 0;
      for (int i = 0; i < 100; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(installmentCar, installmentCar.listingPrice);
        if (offer.offerType != OfferType.cash) {
          nonCashOffers++;
          expect(offer.offeredAmount, greaterThanOrEqualTo(installmentCar.listingPrice));
          expect(offer.buyerMessage, contains('vadeli'));
        }
      }
      expect(nonCashOffers, greaterThan(30),
          reason: 'Expected a good distribution of installment/cheque offers when enabled');
    });
  });
}
