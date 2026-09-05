import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/real_estate_market_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_negotiation_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RealEstateCategory & DeedType Tests', () {
    test('Verifies all 7 screenshot categories with authentic catalog counts', () {
      expect(RealEstateCategory.values.length, 7);
      expect(RealEstateCategory.housing.catalogCount, 779231);
      expect(RealEstateCategory.commercial.catalogCount, 152000);
      expect(RealEstateCategory.land.catalogCount, 255603);
      expect(RealEstateCategory.housingProjects.catalogCount, 1376);
      expect(RealEstateCategory.building.catalogCount, 8867);
      expect(RealEstateCategory.timeshare.catalogCount, 2562);
      expect(RealEstateCategory.tourismFacility.catalogCount, 1470);
    });

    test('Verifies DeedType valuation multipliers', () {
      expect(DeedType.ownershipDeed.valueMultiplier, 1.0);
      expect(DeedType.constructionServitude.valueMultiplier, 0.95);
      expect(DeedType.sharedDeed.valueMultiplier, 0.80);
      expect(DeedType.unlicensedBuilding.valueMultiplier, 0.70);
    });

    test('Verifies category renovation costs and daily rent yields', () {
      for (final cat in RealEstateCategory.values) {
        expect(cat.renovationBaseCost, greaterThan(0));
        expect(cat.dailyRentYieldRate, greaterThan(0));
        expect(cat.localizationKey.isNotEmpty, true);
        expect(cat.renovationTitleKey.isNotEmpty, true);
      }
    });
  });

  group('RealEstateListingModel Cost & Valuation Tests', () {
    test('Calculates individual seller acquisition costs with 0% commission', () {
      const property = RealEstateModel(
        id: 'prop_ind_1',
        title: 'Sahibinden Satılık 3+1 Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 3000000.0,
        currentPurchasePrice: 3000000.0,
      );

      const listing = RealEstateListingModel(
        id: 'test_listing_1',
        realEstate: property,
        askingPrice: 3000000.0,
        sellerName: 'Ahmet Yılmaz',
        sellerTrait: 'Tok Satıcı',
        description: 'Temiz aile apartmanı dairesi',
      );

      // Deed fee = 4% of 3,000,000 = 120,000
      expect(listing.estimatedDeedFee, 120000.0);
      // Fixed revolving capital fee = 2,500
      expect(RealEstateListingModel.revolvingFundFee, 2500.0);
      // Individual seller = 0% agency commission
      expect(listing.estimatedCommission, 0.0);
      // Total acquisition cost = 3,000,000 + 120,000 + 2,500 + 0 = 3,122,500
      expect(listing.totalAcquisitionCost, 3122500.0);
    });

    test('Calculates agency seller acquisition costs with 2% commission', () {
      const property = RealEstateModel(
        id: 'prop_agency_1',
        title: 'Remaks Emlaktan Cadde Üstü Dükkan',
        category: RealEstateCategory.commercial,
        city: 'İzmir',
        district: 'Bornova',
        squareMeters: 85,
        roomCount: 'Dükkan',
        buildingAge: 2,
        deedType: DeedType.constructionServitude,
        sellerType: RealEstateSellerType.agency,
        baseMarketValue: 5000000.0,
        currentPurchasePrice: 5000000.0,
      );

      const listing = RealEstateListingModel(
        id: 'test_listing_2',
        realEstate: property,
        askingPrice: 5000000.0,
        sellerName: 'Remaks Emlak',
        sellerAgencyName: 'Remaks',
        sellerTrait: 'Profesyonel Danışman',
        description: 'Cadde üstü yüksek tabelalı dükkan',
        discrepancyKey: 'mortgageEncumbrance',
      );

      // Deed fee = 4% of 5,000,000 = 200,000
      expect(listing.estimatedDeedFee, 200000.0);
      // Fixed revolving capital fee = 2,500
      expect(RealEstateListingModel.revolvingFundFee, 2500.0);
      // Agency seller = 2% commission = 100,000
      expect(listing.estimatedCommission, 100000.0);
      // Total acquisition cost = 5,000,000 + 200,000 + 2,500 + 100,000 = 5,302,500
      expect(listing.totalAcquisitionCost, 5302500.0);
    });

    test('Verifies RealEstateModel estimated value and flipping profit', () {
      const property = RealEstateModel(
        id: 'prop_1',
        title: 'Yatırımlık Arsa',
        category: RealEstateCategory.land,
        city: 'Antalya',
        district: 'Alanya',
        squareMeters: 600,
        roomCount: 'İmarlı Arsa',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 2000000.0,
        currentPurchasePrice: 2000000.0,
      );

      expect(property.dailyRentIncome, (2000000.0 * 1.0 * RealEstateCategory.land.dailyRentYieldRate).roundToDouble());
      expect(property.estimatedRealValue, 2000000.0 * 1.0); // ownershipDeed multiplier 1.0

      final renovated = property.copyWith(isRenovated: true);
      expect(renovated.estimatedRealValue, (2000000.0 * 1.0 * 1.15).roundToDouble()); // +15% from renovation
      expect(renovated.estimatedRealValue, greaterThan(property.currentPurchasePrice));
    });
  });

  group('RealEstateMarketEngine & NegotiationEngine Tests', () {
    test('Market engine generates dynamic listings with valid properties', () {
      final listings = RealEstateMarketEngine.generateListings(count: 14);

      expect(listings.isNotEmpty, true);
      expect(listings.length, 14);

      for (final l in listings) {
        expect(l.id.isNotEmpty, true);
        expect(l.realEstate.title.isNotEmpty, true);
        expect(l.askingPrice, greaterThan(0));
        expect(l.realEstate.city.isNotEmpty, true);
        expect(l.realEstate.district.isNotEmpty, true);
        expect(l.realEstate.squareMeters, greaterThan(0));
      }
    });

    test('Negotiation engine handles tactic execution and patience', () {
      const property = RealEstateModel(
        id: 'prop_neg',
        title: 'Sahibinden Dubleks',
        category: RealEstateCategory.housing,
        city: 'Ankara',
        district: 'Çankaya',
        squareMeters: 180,
        roomCount: '4+1',
        buildingAge: 10,
        deedType: DeedType.sharedDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4000000.0,
        currentPurchasePrice: 4000000.0,
      );

      const listing = RealEstateListingModel(
        id: 'test_listing_neg',
        realEstate: property,
        askingPrice: 4000000.0,
        sellerName: 'Mehmet Bey',
        sellerTrait: 'Tok Satıcı',
        description: 'Teraslı dubleks daire',
        discrepancyKey: 'illegalRoofDuplex',
      );

      expect(RealEstateNegotiationEngine.allTactics.length, 6);

      // Verify discrepancy detection for shared deed
      final discrepancy = RealEstateNegotiationEngine.evaluateDiscrepancy(listing);
      expect(discrepancy.hasDiscrepancy, true);
      expect(discrepancy.extraDiscountPercent, greaterThan(0));

      final imarTactic = RealEstateNegotiationEngine.allTactics.firstWhere((t) => t.id == 'imar_kusuru');
      final result = RealEstateNegotiationEngine.executeTactic(
        tactic: imarTactic,
        listing: listing,
        currentPatience: 80,
        playerLevel: 4,
      );

      expect(result.message.isNotEmpty, true);
      expect(result.tacticTitle, imarTactic.title);
    });

    test('Rescue coffee tactic handles rescue mechanics', () {
      const property = RealEstateModel(
        id: 'prop_coffee',
        title: 'Acil Satılık Daire',
        category: RealEstateCategory.housing,
        city: 'Bursa',
        district: 'Nilüfer',
        squareMeters: 110,
        roomCount: '2+1',
        buildingAge: 8,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 2500000.0,
        currentPurchasePrice: 2500000.0,
      );

      const listing = RealEstateListingModel(
        id: 'test_listing_coffee',
        realEstate: property,
        askingPrice: 2500000.0,
        sellerName: 'Hasan Usta',
        sellerTrait: 'Aceleci',
        description: 'Geniş ara kat daire',
      );

      final coffeeTactic = RealEstateNegotiationEngine.allTactics.firstWhere((t) => t.id == 'sozlesme_kahvesi');
      expect(coffeeTactic.isRescue, true);

      final outcome = RealEstateNegotiationEngine.executeTactic(
        tactic: coffeeTactic,
        listing: listing,
        currentPatience: 20,
        playerLevel: 4,
      );

      expect(outcome.tacticTitle, 'Sözleşme Kahvesi & Kapora');
      expect(outcome.message.isNotEmpty, true);
    });
  });

  group('DealershipModel Real Estate Integration Tests', () {
    test('DealershipModel handles ownedRealEstates serialization', () {
      final initialDealership = DealershipModel.initial();
      expect(initialDealership.ownedRealEstates, isEmpty);
      expect(initialDealership.maxRealEstateSlots, 5);

      const property = RealEstateModel(
        id: 'p_save_1',
        title: 'Ticari Ofis',
        category: RealEstateCategory.commercial,
        city: 'İstanbul',
        district: 'Şişli',
        squareMeters: 90,
        roomCount: 'Ofis',
        buildingAge: 4,
        baseMarketValue: 4500000.0,
        currentPurchasePrice: 4500000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.agency,
        isRented: true,
        isRenovated: true,
      );

      final updated = initialDealership.copyWith(
        ownedRealEstates: [property],
        maxRealEstateSlots: 5,
      );

      final json = updated.toJson();
      final deserialized = DealershipModel.fromJson(json);

      expect(deserialized.ownedRealEstates.length, 1);
      expect(deserialized.ownedRealEstates.first.id, 'p_save_1');
      expect(deserialized.ownedRealEstates.first.title, 'Ticari Ofis');
      expect(deserialized.ownedRealEstates.first.isRented, true);
      expect(deserialized.ownedRealEstates.first.isRenovated, true);
      expect(deserialized.maxRealEstateSlots, 5);
    });

    test('Real Estate routes require Level 4', () {
      final dealershipLevel3 = DealershipModel.initial().copyWith(level: 3);
      final dealershipLevel4 = DealershipModel.initial().copyWith(level: 4);

      expect(dealershipLevel3.isFeatureUnlocked('/emlak'), false);
      expect(dealershipLevel3.isFeatureUnlocked('/emlak-market'), false);

      expect(dealershipLevel4.isFeatureUnlocked('/emlak'), true);
      expect(dealershipLevel4.isFeatureUnlocked('/emlak-market'), true);
    });
  });

  group('GameNotifier Real Estate Management Tests', () {
    late GameNotifier gameNotifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 50));
      gameNotifier.stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      gameNotifier.stopPeriodicOrganicOfferTimer();
    });

    test('expandRealEstateSlots adds 2 slots when player has sufficient balance', () {
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 1000000,
        maxRealEstateSlots: 5,
      );

      final success = gameNotifier.expandRealEstateSlots();
      expect(success, true);
      expect(gameNotifier.state.maxRealEstateSlots, 7);
      expect(gameNotifier.state.balance, 500000);
    });

    test('expandRealEstateSlots fails when player has insufficient balance', () {
      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 100000,
        maxRealEstateSlots: 5,
      );

      final success = gameNotifier.expandRealEstateSlots();
      expect(success, false);
      expect(gameNotifier.state.maxRealEstateSlots, 5);
      expect(gameNotifier.state.balance, 100000);
    });

    test('toggleRealEstateRent and daily rental processing credit income on nextDay', () {
      const property = RealEstateModel(
        id: 'prop_rental_test',
        title: 'Kiralık Daire',
        category: RealEstateCategory.housing,
        city: 'İzmir',
        district: 'Karşıyaka',
        squareMeters: 100,
        roomCount: '2+1',
        buildingAge: 3,
        baseMarketValue: 3000000.0,
        currentPurchasePrice: 3000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        isRented: false,
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 500000,
        ownedRealEstates: [property],
      );

      // Toggle rent to active
      final toggleSuccess = gameNotifier.toggleRealEstateRent('prop_rental_test');
      expect(toggleSuccess, true);
      expect(gameNotifier.state.ownedRealEstates.first.isRented, true);

      final dailyRent = gameNotifier.state.ownedRealEstates.first.dailyRentIncome;
      expect(dailyRent, greaterThan(0));

      final balanceBefore = gameNotifier.state.balance;
      // Advance to next day
      gameNotifier.advanceGameDay();

      // Verify rental income was credited and logged
      expect(gameNotifier.state.balance, greaterThan(balanceBefore));
      expect(
        gameNotifier.state.recentEvents.any((e) => e.title == 'Gayrimenkul Kira Geliri'),
        true,
      );
    });

    test('sellRealEstate removes property, credits fair value, and adds profit and XP', () {
      const property = RealEstateModel(
        id: 'prop_sell_test',
        title: 'Satılık Arsa',
        category: RealEstateCategory.land,
        city: 'Muğla',
        district: 'Bodrum',
        squareMeters: 500,
        roomCount: 'Arsa',
        buildingAge: 0,
        baseMarketValue: 2000000.0,
        currentPurchasePrice: 2000000.0,
        deedFeePaid: 80000.0,
        commissionPaid: 0.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 100000,
        totalProfit: 50000,
        ownedRealEstates: [property],
      );

      final success = gameNotifier.sellRealEstate(
        realEstateId: 'prop_sell_test',
        salePrice: 2500000.0,
      );

      expect(success, true);
      expect(gameNotifier.state.ownedRealEstates, isEmpty);
      expect(gameNotifier.state.balance, 2600000.0);
      // Net profit = 2,500,000 - (2,000,000 + 80,000 + 0) = 420,000
      expect(gameNotifier.state.totalProfit, 50000 + 420000.0);
    });
  });
}
