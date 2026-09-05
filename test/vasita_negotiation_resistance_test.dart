import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/vasita_negotiation_engine.dart';

void main() {
  group('Vasita Negotiation Resistance & Expertise Tests', () {
    test('PartStatus enum includes localPainted and parses correctly', () {
      expect(PartStatus.values.contains(PartStatus.localPainted), isTrue);
      expect(PartStatus.localPainted.name, equals('localPainted'));
      expect(PartStatus.original.name, equals('original'));
      expect(PartStatus.painted.name, equals('painted'));
      expect(PartStatus.changed.name, equals('changed'));
    });

    test('ExpertiseReport condition maps and localPainted serialization', () {
      final report = ExpertiseReport(
        engineCondition: 90.0,
        transmissionCondition: 88.0,
        tramerAmount: 1500,
        mileage: 45000,
        isMileageTampered: false,
        bodyParts: {
          'solOnCamurluk': PartStatus.localPainted,
          'kaput': PartStatus.original,
        },
      );
      expect(report.bodyParts['solOnCamurluk'], equals(PartStatus.localPainted));
      expect(report.partConditions['solOnCamurluk'], equals(85.0));

      final json = report.toJson();
      final reconstructed = ExpertiseReport.fromJson(json);
      expect(reconstructed.bodyParts['solOnCamurluk'], equals(PartStatus.localPainted));
      expect(reconstructed.partConditions['solOnCamurluk'], equals(85.0));
    });

    test('VasitaNegotiationEngine seller tokluk score calculation', () {
      final urgentTokluk = VasitaNegotiationEngine.calculateSellerTokluk('Acil satılık');
      final normalTokluk = VasitaNegotiationEngine.calculateSellerTokluk('Tok satıcı');
      final esnafTokluk = VasitaNegotiationEngine.calculateSellerTokluk('Galerici esnaf');

      expect(urgentTokluk, equals(20));
      expect(normalTokluk, equals(75));
      expect(esnafTokluk, equals(55));
      expect(urgentTokluk, lessThan(normalTokluk));
    });

    test('Tactic success score factors in player charisma, tactic weight, and seller tokluk', () {
      final highCharismaScore = VasitaNegotiationEngine.calculateTacticSuccessScore(
        playerCharisma: 90,
        tacticWeight: 80,
        sellerTokluk: 20,
      );

      final toughSellerScore = VasitaNegotiationEngine.calculateTacticSuccessScore(
        playerCharisma: 30,
        tacticWeight: 40,
        sellerTokluk: 75,
      );

      expect(highCharismaScore, greaterThan(toughSellerScore));
    });

    test('calculateBuyerSuccessChance clamps tactic bonus to at most 35 percent', () {
      final chanceWith35Bonus = VasitaNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 500000.0,
        offeredPrice: 420000.0,
        playerLevel: 1,
        sellerTrait: 'Normal',
        extraBonusPercent: 0.35,
      );

      final chanceWithOvercappedBonus = VasitaNegotiationEngine.calculateBuyerSuccessChance(
        askingPrice: 500000.0,
        offeredPrice: 420000.0,
        playerLevel: 1,
        sellerTrait: 'Normal',
        extraBonusPercent: 0.90, // should be clamped to 0.35
      );

      expect(chanceWithOvercappedBonus, equals(chanceWith35Bonus));
    });
  });
}
