import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'helpers/invariant_test_helpers.dart';
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

  group('Home Interior Design 7-Language Localization & Invariant Guard', () {
    final interiorKeys = [
      // Office & Navigation
      'home_interior_office_title',
      'home_interior_office_desc_unlocked',
      'home_interior_office_desc_locked',
      'real_estate_btn_interior_design',
      'real_estate_market_refreshed',
      'vasita_market_refreshed',

      // Main Interior Screen
      'home_interior_title',
      'home_interior_subtitle',
      'home_interior_total_investment',
      'home_interior_appraised_bonus',
      'home_interior_prestige_bonus',
      'home_interior_sections_title',
      'home_interior_no_items_yet',

      // Category Detail Screen
      'home_interior_item_installed',
      'home_interior_item_stats',
      'home_interior_purchase_success',
      'home_interior_btn_buy_install',

      // Categories
      'interior_cat_carpet',
      'interior_cat_appliances',
      'interior_cat_tv',
      'interior_cat_curtains',
      'interior_cat_furniture',
      'interior_cat_lighting',
    ];

    for (final item in HomeInteriorDesignCatalog.allItems) {
      interiorKeys.add(item.nameKey);
      interiorKeys.add(item.descriptionKey);
    }

    test('All 71 interior design keys exist simultaneously in all 7 languages with zero emojis and zero parentheses', () {
      expect(interiorKeys.length, 71);
      expectInvariantKeys(interiorKeys);
    });

    test('Placeholder test: home_interior_item_stats correctly substitutes params', () {
      for (final lang in AppLanguage.values) {
        final loc = AppLocalizations(lang.code);
        final rendered = loc.get('home_interior_item_stats', {
          'appraisal': '₺50.000',
          'prestige': '25',
        });
        expect(rendered, contains('₺50.000'));
        expect(rendered, contains('25'));
        expect(rendered, isNot(contains('{appraisal}')));
        expect(rendered, isNot(contains('{prestige}')));
      }
    });
  });
}
