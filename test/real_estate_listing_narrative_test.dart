import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/real_estate_listing_narrative_engine.dart';

void main() {
  group('RealEstateListingNarrativeEngine Tests', () {
    test('Returns tailored feature groups for all property categories', () {
      final residentialGroups = RealEstateListingNarrativeEngine.getFeatureGroups(
        RealEstateCategory.housing,
      );
      expect(residentialGroups.isNotEmpty, isTrue);
      expect(residentialGroups.any((g) => g.groupId == 'facade'), isTrue);

      final commercialGroups = RealEstateListingNarrativeEngine.getFeatureGroups(
        RealEstateCategory.commercial,
      );
      expect(commercialGroups.isNotEmpty, isTrue);
      expect(commercialGroups.any((g) => g.groupId == 'commercial_location'), isTrue);

      final landGroups = RealEstateListingNarrativeEngine.getFeatureGroups(
        RealEstateCategory.land,
      );
      expect(landGroups.isNotEmpty, isTrue);
      expect(landGroups.any((g) => g.groupId == 'land_zoning'), isTrue);

      final buildingGroups = RealEstateListingNarrativeEngine.getFeatureGroups(
        RealEstateCategory.building,
      );
      expect(buildingGroups.isNotEmpty, isTrue);
      expect(buildingGroups.any((g) => g.groupId == 'commercial_architecture'), isTrue);
    });

    test('Returns category-appropriate headline presets', () {
      for (final cat in RealEstateCategory.values) {
        final headlines = RealEstateListingNarrativeEngine.getHeadlinePresets(cat);
        expect(headlines.length, greaterThanOrEqualTo(5));
        for (final h in headlines) {
          expect(h.contains('('), isFalse, reason: 'Headline must not contain (');
          expect(h.contains(')'), isFalse, reason: 'Headline must not contain )');
        }
      }
    });

    test('Generates rich domain narrative description without parentheses or emojis', () {
      const property = RealEstateModel(
        id: 'prop_test_1',
        title: 'Cadde Üstü Geniş Dükkan',
        category: RealEstateCategory.commercial,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 140,
        roomCount: 'Açık Alan',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6500000.0,
        currentPurchasePrice: 6500000.0,
        deedFeePaid: 260000.0,
        commissionPaid: 0.0,
        isRenovated: true,
        isRented: false,
        provenanceLog: [],
      );

      final description = RealEstateListingNarrativeEngine.generateDescription(
        property: property,
        headline: 'Kurumsal Kiracı Adaylı • Yüksek Tabela Değerli Dükkan',
        selectedFeatureIds: ['com_signage', 'com_showcase', 'com_chimney'],
      );

      expect(description.isNotEmpty, isTrue);
      expect(description.contains('Kadıköy'), isTrue);
      expect(description.contains('140 m²'), isTrue);
      expect(description.contains('('), isFalse, reason: 'Zero parentheses invariant');
      expect(description.contains(')'), isFalse, reason: 'Zero parentheses invariant');
    });

    test('Generates high-intent super vitrin offer', () {
      const property = RealEstateModel(
        id: 'prop_building_test',
        title: 'Komple Satılık Bina',
        category: RealEstateCategory.building,
        city: 'Bursa',
        district: 'Nilüfer',
        squareMeters: 380,
        roomCount: '5+2',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 18000000.0,
        currentPurchasePrice: 18000000.0,
        deedFeePaid: 720000.0,
        commissionPaid: 0.0,
        isRenovated: true,
        isRented: false,
        provenanceLog: [],
      );

      final offer = RealEstateListingNarrativeEngine.generateInitialSuperOffer(
        property: property,
        askingPrice: 20000000.0,
      );

      expect(offer.buyerName.isNotEmpty, isTrue);
      expect(offer.buyerNote.isNotEmpty, isTrue);
      expect(offer.offeredAmount, greaterThan(18000000.0));
      expect(offer.daysRemaining, 4);
      expect(offer.buyerNote.contains('('), isFalse);
      expect(offer.buyerNote.contains(')'), isFalse);
    });

    test('Ensures 7-language synchronization for all new real estate keys', () {
      final keysToCheck = [
        'real_estate_listing_features_header',
        'real_estate_listing_features_desc',
        'real_estate_listing_headline_header',
        'real_estate_listing_headline_preset_label',
        'real_estate_listing_desc_header',
        'real_estate_listing_desc_auto_generate',
        'real_estate_listing_strategy_header',
        'real_estate_strategy_kelepir',
        'real_estate_strategy_market',
        'real_estate_strategy_premium',
        'real_estate_strategy_tok_satici',
        'real_estate_listing_package_header',
        'real_estate_pkg_standard_title',
        'real_estate_pkg_standard_desc',
        'real_estate_pkg_featured_title',
        'real_estate_pkg_featured_desc',
        'real_estate_pkg_super_title',
        'real_estate_pkg_super_desc',
        'real_estate_expected_arrival_label',
        'real_estate_btn_manage_listing',
        'real_estate_btn_list_for_sale',
        'real_estate_btn_view_offers',
        'real_estate_insufficient_balance_package',
      ];

      final allMaps = [
        trTranslations,
        enTranslations,
        deTranslations,
        esTranslations,
        ptTranslations,
        ruTranslations,
        arTranslations,
      ];

      for (final map in allMaps) {
        for (final key in keysToCheck) {
          expect(map.containsKey(key), isTrue, reason: 'Key $key must exist in all languages');
          final val = map[key]!;
          expect(val.isNotEmpty, isTrue);
          expect(val.contains('('), isFalse, reason: 'Key $key: value "$val" must not contain (');
          expect(val.contains(')'), isFalse, reason: 'Key $key: value "$val" must not contain )');
        }
      }
    });
  });
}
