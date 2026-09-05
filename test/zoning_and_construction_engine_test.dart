import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/construction_stages_model.dart';
import 'package:galeriden/domain/usecases/construction_negative_events_engine.dart';
import 'package:galeriden/domain/usecases/zoning_engine.dart';

void main() {
  group('Zoning Engine & Construction Stages Suite', () {
    test('ZoningEngine accurately computes TAKS, KAKS, unit distribution and duration', () {
      const landSqMeters = 1000;
      const landValue = 5000000.0;

      final profile = ZoningEngine.calculateZoning(
        parcelSquareMeters: landSqMeters.toDouble(),
        baseMarketValue: landValue,
      );

      expect(profile.footprintArea, equals(300.0));
      expect(profile.totalConstructionArea, equals(1800.0));
      expect(profile.maxFloors, equals(5));

      final units = profile.unitMix;
      expect(units.units1Plus0, greaterThanOrEqualTo(0));
      expect(units.units1Plus1, greaterThan(0));
      expect(units.units2Plus0, greaterThanOrEqualTo(0));
      expect(units.units2Plus1, greaterThan(0));
      expect(units.units3Plus1, greaterThan(0));
      expect(units.units4Plus1, greaterThanOrEqualTo(0));
      expect(
        units.totalUnits,
        equals(
          units.units1Plus0 +
              units.units1Plus1 +
              units.units2Plus0 +
              units.units2Plus1 +
              units.units3Plus1 +
              units.units4Plus1,
        ),
      );

      expect(profile.estimatedDurationDays, greaterThanOrEqualTo(120));
      expect(profile.estimatedProjectValue, greaterThan(landValue));
    });

    test('Standard contractors list has 3 distinct tiers with realistic ranges', () {
      final contractors = ZoningEngine.standardContractors;
      expect(contractors.length, equals(3));
      for (final c in contractors) {
        expect(c.minShare, greaterThanOrEqualTo(40));
        expect(c.maxShare, lessThanOrEqualTo(65));
        expect(c.rating, inInclusiveRange(3.0, 5.0));
      }
    });

    test('ConstructionStagesCatalog contains all 9 equity construction stages', () {
      final stages = ConstructionStagesCatalog.stages;
      expect(stages.length, equals(9));

      for (int i = 0; i < 9; i++) {
        expect(stages[i].stageNumber, equals(i + 1));
        expect(stages[i].title.isNotEmpty, isTrue);
        expect(stages[i].baseCostRatio, greaterThan(0));
      }

      final stage5 = ConstructionStagesCatalog.getStage(5);
      expect(stage5.id, equals('cati_izolasyon'));
    });

    test('Subcontractor tiers contain exactly 3 tiers', () {
      final tiers = ConstructionStagesCatalog.subcontractorTiers;
      expect(tiers.length, equals(3));
      expect(tiers.map((t) => t.id).toList(), containsAll(['ekonomik', 'usta', 'elit']));
    });

    test('ConstructionNegativeEventsEngine incident roll mechanics and text invariant checks', () {
      // Risk multiplier 0 should never trigger an incident
      final noIncident = ConstructionNegativeEventsEngine.rollStageIncident(
        stageNumber: 1,
        baseStageCost: 100000.0,
        riskMultiplier: 0.0,
      );
      expect(noIncident, isNull);

      // Verify incident templates don't violate zero parentheses rule
      for (int i = 0; i < 50; i++) {
        final incident = ConstructionNegativeEventsEngine.rollStageIncident(
          stageNumber: 2,
          baseStageCost: 100000.0,
          riskMultiplier: 10.0,
        );
        if (incident != null) {
          expect(incident.title.contains('('), isFalse, reason: 'Title must not contain parentheses');
          expect(incident.title.contains(')'), isFalse, reason: 'Title must not contain parentheses');
          expect(incident.costImpact, greaterThan(0));
        }
      }
    });
  });
}
