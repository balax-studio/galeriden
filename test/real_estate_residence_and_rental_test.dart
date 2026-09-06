import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/real_estate_offer_model.dart';
import 'package:galeriden/data/models/tenant_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Personal Residence (İkametgah) Category Gating Tests', () {
    test('Housing category can be personal residence when vacant and not in renovation', () {
      const housingProp = RealEstateModel(
        id: 'prop_housing_1',
        title: 'Kadıköy 3+1 Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 4,
        baseMarketValue: 4000000.0,
        currentPurchasePrice: 4000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      expect(housingProp.canBePersonalResidence, true);
    });

    test('Non-housing categories cannot be designated as personal residence', () {
      final nonHousingCategories = [
        RealEstateCategory.commercial,
        RealEstateCategory.land,
        RealEstateCategory.building,
        RealEstateCategory.housingProjects,
      ];

      for (final cat in nonHousingCategories) {
        final prop = RealEstateModel(
          id: 'prop_${cat.name}',
          title: 'Test ${cat.name}',
          category: cat,
          city: 'İstanbul',
          district: 'Şişli',
          squareMeters: 150,
          roomCount: 'Dükkan',
          buildingAge: 2,
          baseMarketValue: 5000000.0,
          currentPurchasePrice: 5000000.0,
          deedType: DeedType.ownershipDeed,
          sellerType: RealEstateSellerType.individual,
        );

        expect(
          prop.canBePersonalResidence,
          false,
          reason: '${cat.name} must not be eligible for personal residence',
        );
      }
    });

    test('Housing cannot be personal residence if rented or under renovation', () {
      const rentedHousing = RealEstateModel(
        id: 'prop_housing_rented',
        title: 'Kiradaki Daire',
        category: RealEstateCategory.housing,
        city: 'Ankara',
        district: 'Çankaya',
        squareMeters: 100,
        roomCount: '2+1',
        buildingAge: 5,
        baseMarketValue: 3000000.0,
        currentPurchasePrice: 3000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        isRented: true,
      );
      expect(rentedHousing.canBePersonalResidence, false);

      const underRenovationHousing = RealEstateModel(
        id: 'prop_housing_renov',
        title: 'Tadilattaki Daire',
        category: RealEstateCategory.housing,
        city: 'İzmir',
        district: 'Konak',
        squareMeters: 90,
        roomCount: '2+1',
        buildingAge: 12,
        baseMarketValue: 2500000.0,
        currentPurchasePrice: 2500000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        renovationStage: 1,
      );
      expect(underRenovationHousing.canBePersonalResidence, false);
    });
  });

  group('TenantModel & Candidate Generation Tests', () {
    test('TenantModel grades correctly based on reliability score', () {
      final highTenant = TenantModel(
        id: 't1',
        name: 'Av. Zeynep Kaya',
        profession: 'Avukat',
        reliabilityScore: 96,
        monthlyRent: 35000.0,
        depositAmount: 70000.0,
        evictionRiskScore: 2,
        leaseStartDay: 10,
      );
      expect(highTenant.reliabilityGrade, 'A+');

      final aTenant = highTenant.copyWith(reliabilityScore: 88);
      expect(aTenant.reliabilityGrade, 'A');

      final bTenant = highTenant.copyWith(reliabilityScore: 78);
      expect(bTenant.reliabilityGrade, 'B');

      final cTenant = highTenant.copyWith(reliabilityScore: 55);
      expect(cTenant.reliabilityGrade, 'C');
    });

    test('TenantModel.generateCandidates creates requested number of candidates', () {
      final candidates = TenantModel.generateCandidates(
        baseMonthlyRent: 20000.0,
        count: 3,
      );
      expect(candidates.length, 3);
      for (final c in candidates) {
        expect(c.name.isNotEmpty, true);
        expect(c.profession.isNotEmpty, true);
        expect(c.monthlyRent, greaterThan(0));
        expect(c.depositAmount, greaterThanOrEqualTo(c.monthlyRent));
        expect(c.reliabilityScore, inInclusiveRange(50, 99));
        expect(c.evictionRiskScore, inInclusiveRange(1, 60));
      }
    });

    test('TenantModel serialization and deserialization matches', () {
      final tenant = TenantModel(
        id: 't_json_test',
        name: 'Dr. Mehmet Demir',
        profession: 'Doktor',
        reliabilityScore: 92,
        monthlyRent: 28000.0,
        depositAmount: 56000.0,
        evictionRiskScore: 4,
        leaseStartDay: 15,
        unpaidRentDays: 0,
      );

      final json = tenant.toJson();
      final restored = TenantModel.fromJson(json);

      expect(restored.id, tenant.id);
      expect(restored.name, tenant.name);
      expect(restored.profession, tenant.profession);
      expect(restored.reliabilityScore, tenant.reliabilityScore);
      expect(restored.monthlyRent, tenant.monthlyRent);
      expect(restored.depositAmount, tenant.depositAmount);
      expect(restored.evictionRiskScore, tenant.evictionRiskScore);
      expect(restored.leaseStartDay, tenant.leaseStartDay);
    });
  });

  group('GameNotifier Residence & Rental Workflow Tests', () {
    late GameNotifier gameNotifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
    });

    tearDown(() {
      gameNotifier.stopPeriodicOrganicOfferTimer();
    });

    test('setPersonalResidence allows housing and blocks commercial or land', () {
      const housingProp = RealEstateModel(
        id: 'prop_h1',
        title: 'Konut Dairesi',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Beşiktaş',
        squareMeters: 110,
        roomCount: '3+1',
        buildingAge: 2,
        baseMarketValue: 6000000.0,
        currentPurchasePrice: 6000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      const commercialProp = RealEstateModel(
        id: 'prop_c1',
        title: 'Merkezi Dükkan',
        category: RealEstateCategory.commercial,
        city: 'İstanbul',
        district: 'Şişli',
        squareMeters: 80,
        roomCount: 'Dükkan',
        buildingAge: 1,
        baseMarketValue: 8000000.0,
        currentPurchasePrice: 8000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        ownedRealEstates: [housingProp, commercialProp],
      );

      // Attempt to set commercial property as residence -> must fail
      final commercialResult = gameNotifier.setPersonalResidence('prop_c1');
      expect(commercialResult, false);
      expect(gameNotifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_c1').isPersonalResidence, false);

      // Attempt to set housing property as residence -> must succeed
      final housingResult = gameNotifier.setPersonalResidence('prop_h1');
      expect(housingResult, true);
      final updatedHousing = gameNotifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_h1');
      expect(updatedHousing.isPersonalResidence, true);

      // Vacating personal residence
      gameNotifier.vacatePersonalResidence('prop_h1');
      expect(gameNotifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_h1').isPersonalResidence, false);
    });

    test('leaseRealEstateToTenant deposits caution money into player balance and sets tenant', () {
      const prop = RealEstateModel(
        id: 'prop_lease_test',
        title: 'Kiralık Daire',
        category: RealEstateCategory.housing,
        city: 'İzmir',
        district: 'Bornova',
        squareMeters: 95,
        roomCount: '2+1',
        buildingAge: 3,
        baseMarketValue: 3000000.0,
        currentPurchasePrice: 3000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 100000.0,
        ownedRealEstates: [prop],
      );

      final tenant = TenantModel(
        id: 't_applicant_1',
        name: 'Selin Yıldız',
        profession: 'Yazılımcı',
        reliabilityScore: 94,
        monthlyRent: 25000.0,
        depositAmount: 50000.0,
        evictionRiskScore: 3,
        leaseStartDay: gameNotifier.state.currentDay,
      );

      final ok = gameNotifier.leaseRealEstateToTenant(
        realEstateId: 'prop_lease_test',
        tenant: tenant,
      );

      expect(ok, true);
      // Balance should be credited with 50,000 deposit
      expect(gameNotifier.state.balance, 150000.0);

      final rentedProp = gameNotifier.state.ownedRealEstates.first;
      expect(rentedProp.isRented, true);
      expect(rentedProp.currentTenant?.id, 't_applicant_1');
      expect(rentedProp.dailyRentIncome, (25000.0 / 30).roundToDouble());

      // Evict tenant: deposit refunded from balance
      final evictOk = gameNotifier.evictTenant('prop_lease_test');
      expect(evictOk, true);
      expect(gameNotifier.state.balance, 100000.0);

      final evictedProp = gameNotifier.state.ownedRealEstates.first;
      expect(evictedProp.isRented, false);
      expect(evictedProp.currentTenant, isNull);
    });

    test('Rental listing toggle operates cleanly on isRentalListed state', () {
      const prop = RealEstateModel(
        id: 'prop_toggle_test',
        title: 'Kiralık İlan Testi',
        category: RealEstateCategory.housing,
        city: 'Bursa',
        district: 'Nilüfer',
        squareMeters: 130,
        roomCount: '3+1',
        buildingAge: 1,
        baseMarketValue: 3500000.0,
        currentPurchasePrice: 3500000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        ownedRealEstates: [prop],
      );

      gameNotifier.listRealEstateForRent('prop_toggle_test');
      expect(gameNotifier.state.ownedRealEstates.first.isRentalListed, true);

      gameNotifier.unlistRealEstateFromRent('prop_toggle_test');
      expect(gameNotifier.state.ownedRealEstates.first.isRentalListed, false);
    });

    test('acceptRealEstateRentalOffer accepts incoming rental offer and signs lease', () {
      final tenant = TenantModel(
        id: 't_offer_1',
        name: 'Murat Arslan',
        profession: 'Mühendis',
        reliabilityScore: 91,
        monthlyRent: 30000.0,
        depositAmount: 60000.0,
        evictionRiskScore: 5,
        leaseStartDay: 1,
      );

      final rentalOffer = RealEstateOfferModel(
        id: 'offer_rent_1',
        realEstateId: 'prop_with_offers',
        buyerName: 'Murat Arslan',
        buyerNote: 'Hemen kiralamak istiyorum',
        offeredAmount: 30000.0,
        daysRemaining: 3,
        createdAt: DateTime.now(),
        isRentalOffer: true,
        tenant: tenant,
        depositAmount: 60000.0,
      );

      final prop = RealEstateModel(
        id: 'prop_with_offers',
        title: 'Manzaralı Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Sarıyer',
        squareMeters: 140,
        roomCount: '3+1',
        buildingAge: 2,
        baseMarketValue: 7000000.0,
        currentPurchasePrice: 7000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        isRentalListed: true,
        activeOffers: [rentalOffer],
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        balance: 50000.0,
        ownedRealEstates: [prop],
      );

      final accepted = gameNotifier.acceptRealEstateRentalOffer(
        realEstateId: 'prop_with_offers',
        offerId: 'offer_rent_1',
      );

      expect(accepted, true);
      // Deposit added to balance
      expect(gameNotifier.state.balance, 110000.0);

      final updatedProp = gameNotifier.state.ownedRealEstates.first;
      expect(updatedProp.isRented, true);
      expect(updatedProp.isRentalListed, false);
      expect(updatedProp.currentTenant?.name, 'Murat Arslan');
      expect(updatedProp.activeOffers, isEmpty);
    });

    test('applyRentIndexIncrease respects 365 in-game days cooldown and updates risk', () {
      final tenant = TenantModel(
        id: 'tenant_t1',
        name: 'Test Kiracı',
        profession: 'Mühendis',
        reliabilityScore: 85,
        monthlyRent: 20000.0,
        depositAmount: 40000.0,
        evictionRiskScore: 10,
        lastRentIncreaseDay: 0,
      );

      final property = RealEstateModel(
        id: 'prop_t1',
        title: 'Kadıköy 2+1 Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 95,
        roomCount: '2+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4500000.0,
        currentPurchasePrice: 4000000.0,
        isRented: true,
        currentTenant: tenant,
      );

      gameNotifier.state = gameNotifier.state.copyWith(
        currentDay: 100,
        ownedRealEstates: [property],
      );

      final okEarly = gameNotifier.applyRentIndexIncrease('prop_t1');
      expect(okEarly, isFalse, reason: 'Must block increase if less than 365 days since last increase');

      gameNotifier.state = gameNotifier.state.copyWith(currentDay: 400);

      final okValid = gameNotifier.applyRentIndexIncrease('prop_t1');
      expect(okValid, isTrue, reason: 'Must allow increase after 365 in-game days');

      final updatedProp = gameNotifier.state.ownedRealEstates.firstWhere((p) => p.id == 'prop_t1');
      if (updatedProp.isRented) {
        expect(updatedProp.currentTenant!.lastRentIncreaseDay, equals(400));
        expect(updatedProp.currentTenant!.monthlyRent, equals(25000.0));
        expect(updatedProp.currentTenant!.evictionRiskScore, equals(25));

        final okImmediate = gameNotifier.applyRentIndexIncrease('prop_t1');
        expect(okImmediate, isFalse, reason: 'Spam tap must be rejected immediately by 365-day cooldown');
      } else {
        expect(updatedProp.currentTenant, isNull);
      }
    });
  });
}
