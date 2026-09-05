import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/real_estate_offer_model.dart';
import 'package:galeriden/data/models/tenant_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Showroom Real Estate Offer Acceptance & Cross-Navigation Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('Rental offer on listed property can be accepted directly from Showroom', () {
      final notifier = container.read(gameProvider.notifier);

      final tenant = TenantModel(
        id: 'tenant-1',
        name: 'Eczacı Murat Aydın',
        profession: 'Mahalle Esnafı',
        monthlyRent: 12250.0,
        depositAmount: 24500.0,
        evictionRiskScore: 21,
        reliabilityScore: 85,
      );

      final rentalOffer = RealEstateOfferModel(
        id: 'offer-rent-1',
        realEstateId: 'prop-bodrum-villa',
        buyerName: 'Eczacı Murat Aydın',
        buyerNote: 'Hemen kiralamak istiyorum',
        offeredAmount: 12250.0,
        depositAmount: 24500.0,
        daysRemaining: 3,
        createdAt: DateTime.now(),
        isRentalOffer: true,
        tenant: tenant,
      );

      final testProp = RealEstateModel(
        id: 'prop-bodrum-villa',
        title: 'İmarlı Villa Parseli - Muğla Bodrum',
        category: RealEstateCategory.land,
        district: 'Bodrum',
        city: 'Muğla',
        squareMeters: 500,
        roomCount: 'Arsa',
        buildingAge: 0,
        baseMarketValue: 500000.0,
        currentPurchasePrice: 500000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        isRentalListed: true,
        activeOffers: [rentalOffer],
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [testProp],
        balance: 100000.0,
      );

      final accepted = notifier.acceptRealEstateRentalOffer(
        realEstateId: 'prop-bodrum-villa',
        offerId: 'offer-rent-1',
      );

      expect(accepted, isTrue);
      final updatedProp = container.read(gameProvider).ownedRealEstates.first;
      expect(updatedProp.isRented, isTrue);
      expect(updatedProp.currentTenant?.name, 'Eczacı Murat Aydın');
      expect(updatedProp.activeOffers.isEmpty, isTrue);
      expect(container.read(gameProvider).balance, 124500.0);
    });

    test('Sale offer on listed property can be accepted directly from Showroom', () {
      final notifier = container.read(gameProvider.notifier);

      final saleOffer = RealEstateOfferModel(
        id: 'offer-sale-1',
        realEstateId: 'prop-kadikoy-flat',
        buyerName: 'Ahmet Yılmaz',
        buyerNote: 'Nakit hemen alırım',
        offeredAmount: 1180000.0,
        daysRemaining: 2,
        createdAt: DateTime.now(),
        isRentalOffer: false,
      );

      final testProp = RealEstateModel(
        id: 'prop-kadikoy-flat',
        title: 'Kadıköy Moda Daire',
        category: RealEstateCategory.housing,
        district: 'Kadıköy',
        city: 'İstanbul',
        squareMeters: 100,
        roomCount: '2+1',
        buildingAge: 5,
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 1000000.0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        isListed: true,
        customListingPrice: 1200000.0,
        activeOffers: [saleOffer],
      );

      notifier.state = notifier.state.copyWith(
        ownedRealEstates: [testProp],
        balance: 50000.0,
      );

      final accepted = notifier.acceptRealEstateOffer(
        realEstateId: 'prop-kadikoy-flat',
        offerId: 'offer-sale-1',
      );

      expect(accepted, isTrue);
      expect(container.read(gameProvider).ownedRealEstates.isEmpty, isTrue);
      expect(container.read(gameProvider).balance, 50000.0 + 1180000.0);
    });

    test('7-Language localization keys exist, contain zero emojis, and zero parentheses', () {
      final keysToCheck = [
        'real_estate_nav_listing_desk',
        'real_estate_nav_rental_desk',
        'real_estate_nav_construction_site',
        'real_estate_nav_showroom_offers',
        'real_estate_nav_sale_desk',
        'real_estate_sale_blocked_warning',
        'real_estate_lease_blocked_warning',
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1FA70}-\u{1FAFF}]',
        unicode: true,
      );

      for (final lang in AppLocalizations.supportedLanguageCodes) {
        final translations = AppLocalizations.getAllKeysFor(lang);
        for (final key in keysToCheck) {
          expect(
            translations.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in language "$lang"',
          );
          final text = translations[key]!;
          expect(
            emojiRegex.hasMatch(text),
            isFalse,
            reason: 'Emoji found in key "$key" for lang "$lang": "$text"',
          );
          expect(
            text.contains('(') || text.contains(')'),
            isFalse,
            reason: 'Parenthesis found in key "$key" for lang "$lang": "$text"',
          );
        }
      }
    });
  });
}
