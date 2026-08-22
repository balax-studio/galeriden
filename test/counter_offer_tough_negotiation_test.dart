import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';

void main() {
  group('Counter Offer Tough Negotiation & Listing Ceiling Tests', () {
    late CarModel testCar;
    late OfferModel testOffer;

    setUp(() {
      testCar = CarModel(
        id: 'car_tough_test',
        brand: 'Renault',
        modelName: 'Megane',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 600000.0,
        currentPurchasePrice: 580000.0,
        customListingPrice: 650000.0,
        declarationType: ListingDeclarationType.honest,
        expertise: ExpertiseReport(
          engineCondition: 95,
          transmissionCondition: 95,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      testOffer = OfferModel(
        id: 'offer_tough_1',
        carId: testCar.id,
        buyerName: 'Ahmet Memur',
        offeredAmount: 600000.0,
        buyerMessage: 'Aracı beğendim, 600 bin TL nakit teklifimdir.',
        status: OfferStatus.pending,
        createdAt: DateTime.now(),
        counterCount: 0,
        maxCounters: 3,
        buyerCustomer: CustomerModel(
          id: 'cust_skeptical_1',
          name: 'Ahmet Memur',
          archetype: CustomerArchetype.skepticalOfficial,
          archetypeTitle: 'Titiz Memur',
          avatarType: 'official',
          personalityDescription: 'Hesabını bilen titiz kamu görevlisi',
          preferredDialogueTrait: 'Rapor & Belge',
        ),
      );
    });

    test('Strict Ceiling: Cannot counter-offer higher than advertised listingPrice', () {
      final outcome = NegotiationEngine.evaluateCounterOffer(
        currentOffer: testOffer,
        playerTargetPrice: 660000.0, // Above 650000 listingPrice
        car: testCar,
        negotiationSkillLevel: 1,
      );

      expect(outcome.isAccepted, isFalse);
      expect(outcome.isWalkaway, isTrue);
      expect(outcome.responseMessage, contains('camdaki ilana'));
    });

    test('Realistic Incremental Step: Customer does not jump unrealistically on counter-offer', () {
      final outcome = NegotiationEngine.evaluateCounterOffer(
        currentOffer: testOffer,
        playerTargetPrice: 630000.0, // 30k difference from 600k offer
        car: testCar,
        negotiationSkillLevel: 1,
        strategy: 'cay_soyle_satis',
      );

      if (!outcome.isWalkaway && !outcome.isAccepted) {
        // Step must move forward realistically
        expect(outcome.updatedOffer.offeredAmount, greaterThanOrEqualTo(600000.0));
        expect(outcome.updatedOffer.offeredAmount, lessThanOrEqualTo(630000.0));
        expect(outcome.updatedOffer.counterCount, equals(1));
      }
    });

    test('Zero Unicode Emojis and Zero Parentheses in all Generated Counter Dialogues', () {
      final archetypes = [
        CustomerArchetype.skepticalOfficial,
        CustomerArchetype.impatientYouth,
        CustomerArchetype.greedyFlipper,
        CustomerArchetype.familyMan,
      ];

      for (final arch in archetypes) {
        final cust = CustomerModel(
          id: 'cust_${arch.name}',
          name: 'Test ${arch.name}',
          archetype: arch,
          archetypeTitle: arch.name,
          avatarType: 'user',
          personalityDescription: 'Test',
          preferredDialogueTrait: 'Test',
        );

        final offer = testOffer.copyWith(buyerCustomer: cust);

        final outcome = NegotiationEngine.evaluateCounterOffer(
          currentOffer: offer,
          playerTargetPrice: 620000.0,
          car: testCar,
          negotiationSkillLevel: 2,
        );

        expect(outcome.responseMessage.contains('('), isFalse, reason: 'Parentheses found: ${outcome.responseMessage}');
        expect(outcome.responseMessage.contains(')'), isFalse, reason: 'Parentheses found: ${outcome.responseMessage}');
        expect(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true).hasMatch(outcome.responseMessage), isFalse,
            reason: 'Emoji found: ${outcome.responseMessage}');
      }
    });
  });
}
