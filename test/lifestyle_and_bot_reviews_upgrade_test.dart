import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/lifestyle_item_model.dart';
import 'package:galeriden/data/models/offer_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/review_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
  });

  tearDown(() {
    container.dispose();
  });

  group('Lifestyle Multi-Cultural Themes & Diminishing Returns Tests', () {
    test('All items are organized across 4 distinct cultural themes with no office decor', () {
      final allItems = LifestyleItemModel.allItems;
      expect(allItems.length, greaterThanOrEqualTo(16));

      final themes = allItems.map((i) => i.theme).toSet();
      expect(themes, containsAll(['classic_baron', 'traditional_artisan', 'street_modern', 'motorsport']));

      // Office decor category should no longer exist in any curated item
      final officeDecors = allItems.where((i) => i.category == 'officeDecor').toList();
      expect(officeDecors, isEmpty);

      // Verify all items are either apparel or accessory
      for (final item in allItems) {
        expect(item.isApparel || item.isAccessory, isTrue);
      }
    });

    test('Diminishing returns soft-caps lifestyle negotiation bonus', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.addMoney(50000000.0);

      // Equip Royal Smoking (+0.08) and Diamond Tourbillon (+0.06)
      final suit = LifestyleItemModel.allItems.firstWhere((i) => i.id == 'suit_royal_smoking');
      final acc = LifestyleItemModel.allItems.firstWhere((i) => i.id == 'acc_diamond_tourbillon');

      notifier.buyLifestyleItem(suit);
      notifier.buyLifestyleItem(acc);

      final state = container.read(gameProvider);
      expect(state.lifestyleNegotiationBonus, lessThanOrEqualTo(0.12));
      expect(state.lifestyleNegotiationBonus, greaterThan(0.08));
    });
  });

  group('Customer Reviews Algorithmic Bot Cost Scaling Tests', () {
    test('Bot review cost increases exponentially and reputation gain diminishes', () {
      final notifier = container.read(gameProvider.notifier);
      notifier.addMoney(1000000.0);

      var state = container.read(gameProvider);
      expect(state.botReviewCount, equals(0));
      expect(state.botReviewCost, equals(2500));

      final initialReputation = state.reputationScore;

      // 1st purchase: ₺2.500 cost, +5 reputation
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(1));
      expect(state.botReviewCost, equals(5000));
      expect(state.reputationScore, equals(initialReputation + 5));

      // 2nd purchase: ₺5.000 cost, +5 reputation
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(2));
      expect(state.botReviewCost, equals(10000));

      // 3rd purchase: ₺10.000 cost, +5 reputation
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(3));
      expect(state.botReviewCost, equals(20000));

      // 4th purchase: ₺20.000 cost, +3 reputation (diminishing return starts)
      final repBefore4th = state.reputationScore;
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(4));
      expect(state.botReviewCost, equals(40000));
      expect(state.reputationScore, equals(repBefore4th + 3));

      // 5th purchase: ₺40.000 cost
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(5));
      expect(state.botReviewCost, equals(75000));

      // 6th purchase: ₺75.000 cost
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(6));
      expect(state.botReviewCost, equals(125000));

      // 7th purchase: +1 reputation (high spam detection penalty)
      final repBefore7th = state.reputationScore;
      expect(notifier.buyBotReview(), isTrue);
      state = container.read(gameProvider);
      expect(state.botReviewCount, equals(7));
      expect(state.reputationScore, equals(repBefore7th + 1));
    });
  });

  group('Negotiation Engine Diminishing Returns Integration Tests', () {
    test('calculateMarketplaceBuyerSuccessChance incorporates lifestyle bonus with soft cap', () {
      final withoutBonus = NegotiationEngine.calculateMarketplaceBuyerSuccessChance(
        askingPrice: 500000,
        offeredPrice: 450000,
        negotiationSkillLevel: 1,
        lifestyleBonusPercent: 0.0,
      );

      final withBonus = NegotiationEngine.calculateMarketplaceBuyerSuccessChance(
        askingPrice: 500000,
        offeredPrice: 450000,
        negotiationSkillLevel: 1,
        lifestyleBonusPercent: 0.12,
      );

      expect(withBonus, greaterThan(withoutBonus));
      expect(withBonus - withoutBonus, lessThanOrEqualTo(8)); // Soft-capped at 8% gain
    });

    test('evaluateCounterOffer with lifestylePersuasionBonus maintains buyer resistance integrity', () {
      final sampleCar = CarModel(
        id: 'test_car_1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1000000,
        currentPurchasePrice: 900000,
        customListingPrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      final customer = CustomerModel(
        id: 'cust_1',
        name: 'Sert Galeri Sahibi',
        archetype: CustomerArchetype.greedyFlipper,
        archetypeTitle: 'Açgözlü Al-Satçı',
        avatarType: 'man_1',
        personalityDescription: 'Hızlı alım yapar ama öldürür.',
        preferredDialogueTrait: 'agresif',
      );

      final offer = OfferModel(
        id: 'off_1',
        carId: sampleCar.id,
        buyerName: customer.name,
        offeredAmount: 920000,
        buyerMessage: 'Nakit bu kadar çıkar.',
        buyerCustomer: customer,
        createdAt: DateTime.now(),
      );

      final outcome = NegotiationEngine.evaluateCounterOffer(
        currentOffer: offer,
        playerTargetPrice: 1050000,
        car: sampleCar,
        negotiationSkillLevel: 3,
        customer: customer,
        lifestylePersuasionBonus: 0.12,
      );

      expect(outcome, isNotNull);
      // Greedy flipper should not instantly accept an extreme price step even with lifestyle bonus
      if (!outcome.isWalkaway) {
        expect(outcome.updatedOffer.offeredAmount, greaterThanOrEqualTo(920000));
        expect(outcome.updatedOffer.offeredAmount, lessThanOrEqualTo(1050000));
      }
    });
  });

  group('Müşteri Profili ve Anti-Repetition Testleri', () {
    test('Müşteri üretimi peş peşe aynı isimleri hemen tekrarlamamalı', () {
      final generatedNames = <String>[];
      for (int i = 0; i < 6; i++) {
        final customer = CustomerModel.generateRandomCustomer();
        generatedNames.add(customer.name);
      }

      // 6 çağrıda en az 4 farklı müşteri ismi gelmeli (anti-repetition)
      final uniqueCount = generatedNames.toSet().length;
      expect(uniqueCount, greaterThanOrEqualTo(4));
    });

    test('Arketipe göre müşteri üretimi doğru çalışmalı', () {
      final skeptical = CustomerModel.generate(CustomerArchetype.skepticalOfficial);
      expect(skeptical.archetype, equals(CustomerArchetype.skepticalOfficial));
      expect(skeptical.inspectionProbability, equals(0.90));

      final youth = CustomerModel.generate(CustomerArchetype.impatientYouth);
      expect(youth.archetype, equals(CustomerArchetype.impatientYouth));
      expect(youth.inspectionProbability, equals(0.20));
    });

    test('İlan satıcı başlığına göre gerçekçi satıcı profili üretilmeli', () {
      final doc = CustomerModel.generateSellerFromListing('Doktordan Temiz Merso');
      expect(doc.archetype, equals(CustomerArchetype.skepticalOfficial));
      expect(doc.archetypeTitle, contains('Doktor'));

      final flipper = CustomerModel.generateSellerFromListing('Oto Al-Satçı Hasan');
      expect(flipper.archetype, equals(CustomerArchetype.greedyFlipper));
    });
  });

  group('Dinamik Müşteri Yorum Motoru Testleri', () {
    final cleanExpertise = ExpertiseReport(
      engineCondition: 90.0,
      transmissionCondition: 88.0,
      tramerAmount: 0,
      mileage: 50000,
      isMileageTampered: false,
      bodyParts: const {},
    );

    final flawlessCar = CarModel(
      id: 'car_test_1',
      brand: 'Merso',
      modelName: 'C-200 Makam AMG',
      modelYear: 2022,
      bodyType: 'Sedan',
      colorHex: '0xFF000000',
      colorDisplayName: 'Obsidyen Siyah',
      colorRarity: 'rare',
      plateNumber: '34 GKT 01',
      plateRarity: 'rare',
      baseMarketValue: 1800000.0,
      currentPurchasePrice: 1500000.0,
      isWashed: true,
      declarationType: ListingDeclarationType.honest,
      expertise: cleanExpertise,
    );

    test('Dürüst ve hatasız araç satışında 5 yıldız ve yüksek itibar üretmeli', () {
      final result = ReviewEngine.generateSaleReview(
        car: flawlessCar,
        buyerName: 'Ahmet Bey',
        hasVipLounge: true,
        hasTrophy: true,
      );

      expect(result.review.rating, equals(5.0));
      expect(result.reputationChange, greaterThanOrEqualTo(5));
      expect(result.review.comment.isNotEmpty, isTrue);

      // Sıfır Parantez kuralı
      expect(result.review.comment.contains('('), isFalse);
      expect(result.review.comment.contains(')'), isFalse);
    });

    test('Kusurlu/yanıltıcı beyanda düşük puan ve itibar kaybı üretmeli', () {
      final dishonestCar = flawlessCar.copyWith(
        declarationType: ListingDeclarationType.minorFlawHidden,
      );

      final result = ReviewEngine.generateSaleReview(
        car: dishonestCar,
        buyerName: 'Mustafa Bey',
      );

      expect(result.review.rating, lessThanOrEqualTo(2.5));
      expect(result.reputationChange, lessThan(0));
      expect(result.review.comment.contains('('), isFalse);
    });
  });
}
