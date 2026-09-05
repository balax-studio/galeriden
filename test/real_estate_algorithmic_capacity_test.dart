import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/real_estate_offer_model.dart';
import 'package:galeriden/domain/usecases/real_estate_negotiation_engine.dart';

void main() {
  group('Real Estate Algorithmic Capacity & Offer Pool Tests', () {
    test('Real estate slot expansion cost formula scales exponentially by 1.8x', () {
      double calculateCost(int level) => (500000.0 * pow(1.8, level)).roundToDouble();

      final costLevel0 = calculateCost(0);
      final costLevel1 = calculateCost(1);
      final costLevel2 = calculateCost(2);

      expect(costLevel0, equals(500000.0));
      expect(costLevel1, equals(900000.0));
      expect(costLevel2, equals(1620000.0));
      expect(costLevel2 / costLevel1, closeTo(1.8, 0.01));
    });

    test('RealEstateOfferModel correctly serializes and deserializes', () {
      final offer = RealEstateOfferModel(
        id: 'off-1',
        realEstateId: 'prop-10',
        buyerName: 'Ahmet Bey',
        buyerNote: 'Yatırımlık düşünüyoruz.',
        offeredAmount: 4500000.0,
        daysRemaining: 5,
        createdAt: DateTime.now(),
      );

      final json = offer.toJson();
      final fromJson = RealEstateOfferModel.fromJson(json);

      expect(fromJson.id, equals('off-1'));
      expect(fromJson.realEstateId, equals('prop-10'));
      expect(fromJson.buyerName, equals('Ahmet Bey'));
      expect(fromJson.offeredAmount, equals(4500000.0));
      expect(fromJson.daysRemaining, equals(5));
    });

    test('RealEstateModel safely serializes with activeOffers and maintains backwards compatibility', () {
      final property = RealEstateModel(
        id: 'prop-1',
        title: 'Kadıköy 3+1 Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        baseMarketValue: 6000000.0,
        currentPurchasePrice: 5800000.0,
        squareMeters: 130,
        roomCount: '3+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        activeOffers: [
          RealEstateOfferModel(
            id: 'off-2',
            realEstateId: 'prop-1',
            buyerName: 'Selin Hanım',
            buyerNote: 'Peşin ödeme yapabilirim.',
            offeredAmount: 6200000.0,
            daysRemaining: 4,
            createdAt: DateTime.now(),
          ),
        ],
      );

      final json = property.toJson();
      expect(json['activeOffers'], isNotNull);

      final reconstructed = RealEstateModel.fromJson(json);
      expect(reconstructed.activeOffers.length, equals(1));
      expect(reconstructed.activeOffers.first.buyerName, equals('Selin Hanım'));

      // Test backwards compatibility with legacy JSON missing activeOffers key
      final legacyJson = Map<String, dynamic>.from(json)..remove('activeOffers');
      final legacyReconstructed = RealEstateModel.fromJson(legacyJson);
      expect(legacyReconstructed.activeOffers, isEmpty);
    });

    test('RealEstateNegotiationEngine category-specific tactics and bonuses', () {
      final tactics = RealEstateNegotiationEngine.allTactics;

      final arsaTactic = tactics.firstWhere((t) => t.id == 'arsa_imar_taks');
      expect(arsaTactic.preferredCategories, contains(RealEstateCategory.land));

      final ticariTactic = tactics.firstWhere((t) => t.id == 'ticari_tabela_ciro');
      expect(ticariTactic.preferredCategories, contains(RealEstateCategory.commercial));

      final plazaTactic = tactics.firstWhere((t) => t.id == 'plaza_amortisman');
      expect(plazaTactic.preferredCategories, contains(RealEstateCategory.building));

      final konutTactic = tactics.firstWhere((t) => t.id == 'konut_aidat_kredi');
      expect(konutTactic.preferredCategories, contains(RealEstateCategory.housing));
    });
  });
}
