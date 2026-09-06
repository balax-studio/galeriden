import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/home_interior_design_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Home Interior Design Flow & Economics Tests', () {
    test('calculateAppraisedInteriorBonus satisfies soft-cap and diminishing returns', () {
      final sampleProperty = RealEstateModel(
        id: 'prop_villa_1',
        title: 'Lüks Boğaz Villası',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Beşiktaş',
        squareMeters: 350,
        roomCount: '5+2',
        buildingAge: 3,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 5000000.0,
        currentPurchasePrice: 5000000.0,
        isPersonalResidence: true,
        interiorDesignItemIds: const ['carpet_tier_3', 'appliance_tier_2'],
      );

      final bonus = HomeInteriorDesignCatalog.calculateAppraisedInteriorBonus(sampleProperty);
      final nominalSum = HomeInteriorDesignCatalog.items
          .where((i) => sampleProperty.interiorDesignItemIds.contains(i.id))
          .fold<double>(0.0, (sum, i) => sum + i.nominalValueContribution);

      expect(bonus, greaterThan(0));
      // Bonus should never exceed 35% soft cap of baseMarketValue
      expect(bonus, lessThanOrEqualTo(sampleProperty.baseMarketValue * 0.35));
      // Diminishing returns curve ensures bonus is <= nominalSum
      expect(bonus, lessThanOrEqualTo(nominalSum));
    });

    test('Purchase interior item updates balance, itemIds and reputationScore in GameNotifier', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final residence = RealEstateModel(
        id: 'home_residence_1',
        title: 'Modern Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 120,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 1000000.0,
        isPersonalResidence: true,
      );

      // Inject state with high balance and the owned residence
      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        reputationScore: 100,
        ownedRealEstates: [residence],
      );

      final testItem = HomeInteriorDesignCatalog.items.first;
      final initialBalance = notifier.state.balance;
      final initialReputation = notifier.state.reputationScore;

      final success = notifier.purchaseHomeInteriorItem(
        realEstateId: residence.id,
        item: testItem,
      );

      expect(success, isTrue);
      expect(notifier.state.balance, equals(initialBalance - testItem.basePrice));
      expect(notifier.state.reputationScore, equals(initialReputation + testItem.prestigeBonus));

      final updatedResidence = notifier.state.ownedRealEstates.first;
      expect(updatedResidence.interiorDesignItemIds, contains(testItem.id));
    });
  });
}

