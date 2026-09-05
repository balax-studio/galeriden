import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/domain/usecases/architectural_yield_engine.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';

void main() {
  group('ArchitecturalYieldEngine Tests', () {
    test('generatePlan accurately calculates KAKS, TAKS, and unit distribution for standard parcel', () {
      final plan = ArchitecturalYieldEngine.generatePlan(
        parcelSquareMeters: 1000.0,
      );

      expect(plan.taks, 0.30);
      expect(plan.kaks, 1.80);
      expect(plan.footprintArea, 300.0);
      expect(plan.grossConstructionArea, 1800.0);
      expect(plan.netResidentialArea, 1800.0 * 0.85);
      expect(plan.totalUnits, greaterThanOrEqualTo(4));
      expect(plan.totalProjectGrossValue, greaterThan(0));
    });

    test('generatePlan scales KAKS and floors for large parcel (>= 1500m²)', () {
      final plan = ArchitecturalYieldEngine.generatePlan(
        parcelSquareMeters: 2000.0,
      );

      expect(plan.taks, 0.35);
      expect(plan.kaks, 2.10);
      expect(plan.grossConstructionArea, 4200.0);
      expect(plan.calculatedFloors, greaterThanOrEqualTo(5));
      expect(plan.calculatedFloors, lessThanOrEqualTo(7));
    });

    test('validateCustomMix returns false if user exceeds KAKS capacity', () {
      final valid = ArchitecturalYieldEngine.validateCustomMix(
        parcelSquareMeters: 500.0,
        kaks: 1.50,
        units1Plus1: 50, // Clearly impossible on 500m² * 1.50 = 750m² gross
        units2Plus1: 50,
        units3Plus1: 50,
      );

      expect(valid, isFalse);
    });
  });

  group('ConstructionTimelineEngine Tests', () {
    test('totalBaseDays equals exactly at least 120 days', () {
      final totalDays = ConstructionTimelineEngine.totalBaseDays;
      expect(totalDays, greaterThanOrEqualTo(120));
      expect(totalDays, 120);
    });

    test('calculateStageDays adjusts for subcontractor speed vs budget tier', () {
      final speedDays = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 2,
        parcelSquareMeters: 1000.0,
        tier: SubcontractorTier.speed,
      );
      final standardDays = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 2,
        parcelSquareMeters: 1000.0,
        tier: SubcontractorTier.standard,
      );
      final budgetDays = ConstructionTimelineEngine.calculateStageDays(
        stageNumber: 2,
        parcelSquareMeters: 1000.0,
        tier: SubcontractorTier.budget,
      );

      expect(speedDays, lessThan(standardDays));
      expect(budgetDays, greaterThan(standardDays));
    });

    test('getSubcontractorsForStage returns exactly 3 distinct tiers', () {
      final subs = ConstructionTimelineEngine.getSubcontractorsForStage(1);
      expect(subs.length, 3);
      expect(subs.map((s) => s.tier).toSet().length, 3);
    });
  });
}
