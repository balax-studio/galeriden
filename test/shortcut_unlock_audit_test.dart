import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';

void main() {
  group('Feature Unlock & Shortcut Access Audit Tests', () {
    test('Tier 1 (Initial Dealership) has only base features unlocked', () {
      final tier1Dealership = DealershipModel.initial();

      // Tier 1 Base Routes
      expect(tier1Dealership.isFeatureUnlocked('/marketplace'), isTrue);
      expect(tier1Dealership.isFeatureUnlocked('/showroom'), isTrue);
      expect(tier1Dealership.isFeatureUnlocked('/branches'), isTrue);
      expect(tier1Dealership.isFeatureUnlocked('/character-growth'), isTrue);
      expect(tier1Dealership.isFeatureUnlocked('/settings'), isTrue);

      // Higher Tier Routes MUST be locked at Tier 1
      expect(tier1Dealership.isFeatureUnlocked('/car-wash'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/history'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/workshop'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/staff'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/staff-academy'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/tuning-studio'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/showroom-decor'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/auction'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/finance'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/reviews'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/bank-investments'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/stock-market'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/rent-a-car'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/black-market'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/districts'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/gossip'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/scrapyard'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/side-businesses'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/consignment-market'), isFalse);
      expect(tier1Dealership.isFeatureUnlocked('/consignment'), isFalse);
    });

    test('Tier 3 unlocks Car Wash, History, Workshop, Staff, and Staff Academy', () {
      final tier3Dealership = DealershipModel.initial().copyWith(
        unlockedBuildings: {
          'property_tier_1',
          '/marketplace',
          '/showroom',
          '/expertise',
          '/branches',
          '/character-growth',
          '/settings',
          '/dealership-identity',
          '/theme-store',
          'property_tier_2',
          '/car-wash',
          '/history',
          'property_tier_3',
          '/workshop',
          '/staff',
          '/staff-academy',
        },
      );

      expect(tier3Dealership.isFeatureUnlocked('/car-wash'), isTrue);
      expect(tier3Dealership.isFeatureUnlocked('/history'), isTrue);
      expect(tier3Dealership.isFeatureUnlocked('/workshop'), isTrue);
      expect(tier3Dealership.isFeatureUnlocked('/staff'), isTrue);
      expect(tier3Dealership.isFeatureUnlocked('/staff-academy'), isTrue);

      // Higher Tiers still locked
      expect(tier3Dealership.isFeatureUnlocked('/tuning-studio'), isFalse);
      expect(tier3Dealership.isFeatureUnlocked('/bank-investments'), isFalse);
      expect(tier3Dealership.isFeatureUnlocked('/scrapyard'), isFalse);
      expect(tier3Dealership.isFeatureUnlocked('/side-businesses'), isFalse);
    });

    test('DealershipModel level mapping matches level requirements', () {
      expect(DealershipModel.getRequiredLevel('/car-wash'), 2);
      expect(DealershipModel.getRequiredLevel('/history'), 2);
      expect(DealershipModel.getRequiredLevel('/workshop'), 3);
      expect(DealershipModel.getRequiredLevel('/staff'), 3);
      expect(DealershipModel.getRequiredLevel('/staff-academy'), 3);
      expect(DealershipModel.getRequiredLevel('/tuning-studio'), 4);
      expect(DealershipModel.getRequiredLevel('/showroom-decor'), 4);
      expect(DealershipModel.getRequiredLevel('/auction'), 5);
      expect(DealershipModel.getRequiredLevel('/finance'), 5);
      expect(DealershipModel.getRequiredLevel('/reviews'), 5);
      expect(DealershipModel.getRequiredLevel('/bank-investments'), 6);
      expect(DealershipModel.getRequiredLevel('/stock-market'), 6);
      expect(DealershipModel.getRequiredLevel('/rent-a-car'), 7);
      expect(DealershipModel.getRequiredLevel('/black-market'), 7);
      expect(DealershipModel.getRequiredLevel('/districts'), 7);
      expect(DealershipModel.getRequiredLevel('/gossip'), 7);
      expect(DealershipModel.getRequiredLevel('/scrapyard'), 8);
      expect(DealershipModel.getRequiredLevel('/side-businesses'), 8);
      expect(DealershipModel.getRequiredLevel('/consignment-market'), 8);
    });

    test('DealershipModel branch names and aliases work as expected', () {
      expect(DealershipModel.getRequiredBranchName('/car-wash'), 'Mahalle Tipi Açık Oto Galeri (Seviye 2)');
      expect(DealershipModel.getRequiredBranchName('/workshop'), 'Sanayi Sitesi Esnaf Galerisi (Seviye 3)');
      expect(DealershipModel.getRequiredBranchName('/tuning-studio'), 'Cadde Üstü Butik Oto Galeri (Seviye 4)');
      expect(DealershipModel.getRequiredBranchName('/auction'), 'Oto Center Kurumsal Galeri (Seviye 5)');
      expect(DealershipModel.getRequiredBranchName('/stock-market'), 'Premium Cam Showroom Plaza (Seviye 6)');
      expect(DealershipModel.getRequiredBranchName('/rent-a-car'), 'Lüks Koleksiyoner VIP Galeri (Seviye 7)');
      expect(DealershipModel.getRequiredBranchName('/scrapyard'), 'Mega Otomotiv Holding Plazası (Seviye 8)');

      // Aliases
      expect(DealershipModel.getRequiredLevel('/gossip-hotline'), 7);
      expect(DealershipModel.getRequiredLevel('/consignment'), 8);
      expect(DealershipModel.getRequiredLevel('/district-market'), 7);
    });
  });
}
