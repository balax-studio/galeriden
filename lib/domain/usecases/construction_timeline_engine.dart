import 'dart:math';

enum SubcontractorTier {
  speed, // Hızlı Ekip • %20 daha hızlı, %25 daha pahalı
  standard, // Dengeli Usta • Standart süre ve maliyet
  budget, // Ekonomik Taşeron • %20 daha ucuz, %20 daha yavaş
}

extension SubcontractorTierExtension on SubcontractorTier {
  String get badgeKey {
    switch (this) {
      case SubcontractorTier.speed:
        return 'subcontractor_tier_speed_badge';
      case SubcontractorTier.standard:
        return 'subcontractor_tier_standard_badge';
      case SubcontractorTier.budget:
        return 'subcontractor_tier_budget_badge';
    }
  }
}

class ConstructionStageDetails {
  final int stageNumber; // 1 to 6
  final String titleKey;
  final String descriptionKey;
  final int baseDays;
  final double costPercentage; // Proportion of total self-build budget

  const ConstructionStageDetails({
    required this.stageNumber,
    required this.titleKey,
    required this.descriptionKey,
    required this.baseDays,
    required this.costPercentage,
  });
}

class SubcontractorProfile {
  final String id;
  final String name;
  final String specialtyKey;
  final SubcontractorTier tier;
  final double costMultiplier;
  final double durationMultiplier;
  final double reliabilityScore; // 0.0 - 1.0
  final String pitchKey;

  const SubcontractorProfile({
    required this.id,
    required this.name,
    required this.specialtyKey,
    required this.tier,
    required this.costMultiplier,
    required this.durationMultiplier,
    required this.reliabilityScore,
    required this.pitchKey,
  });
}

class ConstructionTimelineEngine {
  /// Asgari 120 günlük 6 ana şantiye evresi
  static const List<ConstructionStageDetails> stages = [
    ConstructionStageDetails(
      stageNumber: 1,
      titleKey: 'construction_stage_excavation_title',
      descriptionKey: 'construction_stage_excavation_desc',
      baseDays: 20,
      costPercentage: 0.10,
    ),
    ConstructionStageDetails(
      stageNumber: 2,
      titleKey: 'construction_stage_rough_concrete_title',
      descriptionKey: 'construction_stage_rough_concrete_desc',
      baseDays: 35,
      costPercentage: 0.35,
    ),
    ConstructionStageDetails(
      stageNumber: 3,
      titleKey: 'construction_stage_facade_roof_title',
      descriptionKey: 'construction_stage_facade_roof_desc',
      baseDays: 20,
      costPercentage: 0.20,
    ),
    ConstructionStageDetails(
      stageNumber: 4,
      titleKey: 'construction_stage_mep_installation_title',
      descriptionKey: 'construction_stage_mep_installation_desc',
      baseDays: 15,
      costPercentage: 0.15,
    ),
    ConstructionStageDetails(
      stageNumber: 5,
      titleKey: 'construction_stage_interior_finishing_title',
      descriptionKey: 'construction_stage_interior_finishing_desc',
      baseDays: 15,
      costPercentage: 0.10,
    ),
    ConstructionStageDetails(
      stageNumber: 6,
      titleKey: 'construction_stage_occupancy_handover_title',
      descriptionKey: 'construction_stage_occupancy_handover_desc',
      baseDays: 15,
      costPercentage: 0.10,
    ),
  ];

  /// Toplam standart şantiye süresi (En az 120 gün)
  static int get totalBaseDays =>
      stages.fold(0, (acc, stage) => acc + stage.baseDays);

  /// Arsa büyüklüğüne göre ölçeklenmiş etap süresi
  static int calculateStageDays({
    required int stageNumber,
    required double parcelSquareMeters,
    SubcontractorTier tier = SubcontractorTier.standard,
  }) {
    final stage = stages.firstWhere(
      (s) => s.stageNumber == stageNumber,
      orElse: () => stages.first,
    );

    double scale = 1.0;
    if (parcelSquareMeters >= 2000) {
      scale = 1.40;
    } else if (parcelSquareMeters >= 1200) {
      scale = 1.20;
    }

    double tierMultiplier = 1.0;
    switch (tier) {
      case SubcontractorTier.speed:
        tierMultiplier = 0.80; // %20 daha hızlı
        break;
      case SubcontractorTier.standard:
        tierMultiplier = 1.0;
        break;
      case SubcontractorTier.budget:
        tierMultiplier = 1.20; // %20 daha yavaş
        break;
    }

    return max(5, (stage.baseDays * scale * tierMultiplier).round());
  }

  /// Her evre için mevcut 3 alternatif taşeron profili
  static List<SubcontractorProfile> getSubcontractorsForStage(int stageNumber) {
    return [
      SubcontractorProfile(
        id: 'sub_speed_$stageNumber',
        name: 'Şimşek Yapı & Hızlı Ekip',
        specialtyKey: 'subcontractor_tier_speed_badge',
        tier: SubcontractorTier.speed,
        costMultiplier: 1.25,
        durationMultiplier: 0.80,
        reliabilityScore: 0.95,
        pitchKey: 'subcontractor_pitch_speed',
      ),
      SubcontractorProfile(
        id: 'sub_std_$stageNumber',
        name: 'Usta Eller Kollektif',
        specialtyKey: 'subcontractor_tier_standard_badge',
        tier: SubcontractorTier.standard,
        costMultiplier: 1.00,
        durationMultiplier: 1.00,
        reliabilityScore: 0.88,
        pitchKey: 'subcontractor_pitch_standard',
      ),
      SubcontractorProfile(
        id: 'sub_budget_$stageNumber',
        name: 'Ekonomik Taşeron Ekibi',
        specialtyKey: 'subcontractor_tier_budget_badge',
        tier: SubcontractorTier.budget,
        costMultiplier: 0.80,
        durationMultiplier: 1.20,
        reliabilityScore: 0.78,
        pitchKey: 'subcontractor_pitch_budget',
      ),
    ];
  }
}
