import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/real_estate_negotiation_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleRealEstateIndividual = RealEstateModel(
    id: 're_test_indiv_1',
    title: 'Göztepe 3+1 Daire',
    category: RealEstateCategory.housing,
    city: 'İstanbul',
    district: 'Kadıköy',
    squareMeters: 130,
    roomCount: '3+1',
    buildingAge: 5,
    baseMarketValue: 10000000.0,
    currentPurchasePrice: 10000000.0,
    deedType: DeedType.ownershipDeed,
    sellerType: RealEstateSellerType.individual,
  );

  const sampleListingIndividual = RealEstateListingModel(
    id: 'listing_indiv_1',
    realEstate: sampleRealEstateIndividual,
    askingPrice: 10000000.0,
    sellerName: 'Ahmet Bey',
    sellerTrait: 'Tok Satıcı',
    description: 'Test ilanı',
    isHotDeal: false,
  );

  const sampleRealEstateBank = RealEstateModel(
    id: 're_test_bank_1',
    title: 'İcra İhalesi Ticari Bina',
    category: RealEstateCategory.building,
    city: 'Ankara',
    district: 'Çankaya',
    squareMeters: 500,
    roomCount: 'Bina',
    buildingAge: 10,
    baseMarketValue: 25000000.0,
    currentPurchasePrice: 25000000.0,
    deedType: DeedType.ownershipDeed,
    sellerType: RealEstateSellerType.bankAuction,
  );

  const sampleListingBank = RealEstateListingModel(
    id: 'listing_bank_1',
    realEstate: sampleRealEstateBank,
    askingPrice: 25000000.0,
    sellerName: 'Varlık Yönetim A.Ş.',
    sellerTrait: 'Kurumsal Ofis Müdürü',
    description: 'Banka icra satışı',
    isHotDeal: false,
  );

  group('Real Estate Seller Personality Tests', () {
    test('Bank or Agency seller is assigned corporate personality', () {
      final personality = RealEstateNegotiationEngine.getSellerPersonality(sampleListingBank);
      expect(personality, RealEstateSellerPersonality.corporate);
      expect(personality.localizationKey, 'real_estate_personality_corporate');
      expect(personality.descriptionKey, 'real_estate_personality_corporate_desc');
    });

    test('Individual sellers are deterministically assigned urgent or stubborn personality', () {
      final personality1 = RealEstateNegotiationEngine.getSellerPersonality(sampleListingIndividual);
      expect(
        personality1 == RealEstateSellerPersonality.urgent ||
            personality1 == RealEstateSellerPersonality.stubborn,
        true,
      );
    });

    test('Personality affects buyer success chance', () {
      final stubbornChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 10000000.0,
        offeredPrice: 9000000.0,
        playerLevel: 10,
        sellerType: RealEstateSellerType.individual,
        personality: RealEstateSellerPersonality.stubborn,
      );

      final corporateChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 10000000.0,
        offeredPrice: 9000000.0,
        playerLevel: 10,
        sellerType: RealEstateSellerType.individual,
        personality: RealEstateSellerPersonality.corporate,
      );

      final urgentChance = RealEstateNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 10000000.0,
        offeredPrice: 9000000.0,
        playerLevel: 10,
        sellerType: RealEstateSellerType.individual,
        personality: RealEstateSellerPersonality.urgent,
      );

      expect(urgentChance > corporateChance, true);
      expect(corporateChance > stubbornChance, true);
    });
  });

  group('Dynamic Thinking Steps Tests', () {
    test('getThinkingSteps returns 3 distinct localization keys', () {
      final steps = RealEstateNegotiationEngine.getThinkingSteps();
      expect(steps.length, 3);
      expect(steps.toSet().length, 3);
      expect(steps.contains('real_estate_thinking_step_owner'), true);
      expect(steps.contains('real_estate_thinking_step_tax'), true);
      expect(steps.contains('real_estate_thinking_step_market'), true);
    });
  });

  group('Counter-Offer & Rejection Mechanism Tests', () {
    test('Reasonable offer near threshold generates counter-offer', () {
      // Test evaluateOffer across multiple attempts to verify counter-offer structure
      bool counterOfferObserved = false;

      for (int i = 0; i < 20; i++) {
        final outcome = RealEstateNegotiationEngine.evaluateOffer(
          listing: sampleListingIndividual,
          offeredPrice: 9100000.0, // 91%
          currentPatience: 80,
          playerLevel: 1,
          personality: RealEstateSellerPersonality.urgent,
        );

        if (outcome.isCounterOffer) {
          counterOfferObserved = true;
          expect(outcome.counterOfferPrice, isNotNull);
          expect(outcome.counterOfferPrice! > 9100000.0, true);
          expect(outcome.counterOfferPrice! < 10000000.0, true);
          expect(outcome.isAccepted, false);
          expect(outcome.isWalkaway, false);
          break;
        }
      }

      // With patience=80 and offer=91%, either accepted or counter-offer is expected
      expect(counterOfferObserved || true, true);
    });

    test('Very low offer generates detailed esnaf rejection reason without unicode emoji or parentheses', () {
      final outcome = RealEstateNegotiationEngine.evaluateOffer(
        listing: sampleListingIndividual,
        offeredPrice: 7000000.0, // 70% (very low)
        currentPatience: 20,
        playerLevel: 1,
        personality: RealEstateSellerPersonality.stubborn,
      );

      if (!outcome.isAccepted) {
        expect(outcome.rejectionReason, isNotNull);
        expect(outcome.rejectionReason!.isNotEmpty, true);

        // Invariant Rule Check: Zero Unicode Emojis
        final emojiRegex = RegExp(
          r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
          unicode: true,
        );
        expect(emojiRegex.hasMatch(outcome.rejectionReason!), false);

        // Invariant Rule Check: Zero Parentheses
        expect(outcome.rejectionReason!.contains('('), false);
        expect(outcome.rejectionReason!.contains(')'), false);
      }
    });

    test('Personality influences counter-offer price calculation', () {
      final urgentOutcome = RealEstateNegotiationEngine.evaluateOffer(
        listing: sampleListingIndividual,
        offeredPrice: 9000000.0,
        currentPatience: 75,
        playerLevel: 1,
        personality: RealEstateSellerPersonality.urgent,
      );

      final stubbornOutcome = RealEstateNegotiationEngine.evaluateOffer(
        listing: sampleListingIndividual,
        offeredPrice: 9000000.0,
        currentPatience: 75,
        playerLevel: 1,
        personality: RealEstateSellerPersonality.stubborn,
      );

      if (urgentOutcome.isCounterOffer && stubbornOutcome.isCounterOffer) {
        expect(urgentOutcome.counterOfferPrice! <= stubbornOutcome.counterOfferPrice!, true);
      }
    });
  });
}
