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
  final int stageNumber; // 1 to 4
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
  /// 4 Ana İnşaat Etabı (Hafriyat, Kaba Yapı, Çatı & Cephe, İnce İşçilik & İskan)
  static const List<ConstructionStageDetails> stages = [
    ConstructionStageDetails(
      stageNumber: 1,
      titleKey: 'construction_stage_excavation_title',
      descriptionKey: 'construction_stage_excavation_desc',
      baseDays: 14,
      costPercentage: 0.15,
    ),
    ConstructionStageDetails(
      stageNumber: 2,
      titleKey: 'construction_stage_rough_concrete_title',
      descriptionKey: 'construction_stage_rough_concrete_desc',
      baseDays: 28,
      costPercentage: 0.25,
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
      titleKey: 'construction_stage_interior_finishing_title',
      descriptionKey: 'construction_stage_interior_finishing_desc',
      baseDays: 18,
      costPercentage: 0.15,
    ),
  ];

  /// Toplam standart şantiye süresi
  static int get totalBaseDays =>
      stages.fold(0, (acc, stage) => acc + stage.baseDays);

  static ConstructionStageDetails getStageDetails(int stageNumber) {
    return stages.firstWhere(
      (s) => s.stageNumber == stageNumber,
      orElse: () => stages.first,
    );
  }

  /// Arsa büyüklüğüne ve taşeron ekibine göre hesaplanan gün sayısı
  static int calculateStageDays({
    required int stageNumber,
    required double parcelSquareMeters,
    SubcontractorTier tier = SubcontractorTier.standard,
  }) {
    final stage = getStageDetails(stageNumber);

    double scale = 1.0;
    if (parcelSquareMeters >= 2000) {
      scale = 1.35;
    } else if (parcelSquareMeters >= 1200) {
      scale = 1.18;
    }

    double tierMultiplier = 1.0;
    switch (tier) {
      case SubcontractorTier.speed:
        tierMultiplier = 0.75; // %25 daha hızlı
        break;
      case SubcontractorTier.standard:
        tierMultiplier = 1.0;
        break;
      case SubcontractorTier.budget:
        tierMultiplier = 1.25; // %25 daha yavaş
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
        durationMultiplier: 0.75,
        reliabilityScore: 0.95,
        pitchKey: 'subcontractor_pitch_speed',
      ),
      SubcontractorProfile(
        id: 'sub_std_$stageNumber',
        name: 'Öz Usta Mimarlık & İnşaat',
        specialtyKey: 'subcontractor_tier_standard_badge',
        tier: SubcontractorTier.standard,
        costMultiplier: 1.00,
        durationMultiplier: 1.00,
        reliabilityScore: 0.88,
        pitchKey: 'subcontractor_pitch_standard',
      ),
      SubcontractorProfile(
        id: 'sub_budget_$stageNumber',
        name: 'Hesaplı Taşeron Kollektifi',
        specialtyKey: 'subcontractor_tier_budget_badge',
        tier: SubcontractorTier.budget,
        costMultiplier: 0.80,
        durationMultiplier: 1.25,
        reliabilityScore: 0.76,
        pitchKey: 'subcontractor_pitch_budget',
      ),
    ];
  }

  /// Komik ve özgün Türk şantiye diyalog ve telsiz anonsları havuzu
  static const List<String> humorousAnecdoteKeys = [
    'construction_anecdote_concrete_power_cut',
    'construction_anecdote_wedding_dozer',
    'construction_anecdote_police_tea',
    'construction_anecdote_inverted_blueprint',
    'construction_anecdote_broken_laser_level',
    'construction_anecdote_raw_meatball_rumor',
    'construction_anecdote_c35_atomic_bomb',
    'construction_anecdote_water_leak_plumber',
    'construction_anecdote_crane_cat',
  ];

  static const Map<String, String> anecdoteTurkishTexts = {
    'construction_anecdote_concrete_power_cut': 'Ustam hazır beton santralinde elektrikler gitmiş, mikserler yolda kaldı!',
    'construction_anecdote_wedding_dozer': 'Hafriyatçı dozeri düğün konvoyuna götürmüş, yarın sabah çift vardiya gireriz.',
    'construction_anecdote_police_tea': 'Zabıta geldi şikayet var diye, çay ocağında çay ısmarladık meseleyi tatlıya bağladık.',
    'construction_anecdote_inverted_blueprint': 'Demirci ustası projeyi ters tutmuş, neyse ki kolonları doğru yere bağlamış.',
    'construction_anecdote_broken_laser_level': 'Fayans ustası lazer terazi bozuktu göz kararı dizdim diyor, banyoya giren deniz tuttu sanıyor.',
    'construction_anecdote_raw_meatball_rumor': 'Müteahhit kaçtı dedikodusu çıktı, ustalara çiğ köfte yoğurup işin başına döndürdük.',
    'construction_anecdote_c35_atomic_bomb': 'Şantiye şefi C35 beton döktük, atom bombası gelse çizilmez diyerek teselli etti.',
    'construction_anecdote_water_leak_plumber': 'Sıhhi tesisat ustası vanayı ters bağlamış, şantiyede havuz partisi başladı.',
    'construction_anecdote_crane_cat': 'Kule vinçin tepesine kedi çıkmış, itfaiye gelene kadar kalıp işleri durdu.',
  };

  static String getRandomAnecdoteKey(Random random) {
    return humorousAnecdoteKeys[random.nextInt(humorousAnecdoteKeys.length)];
  }

  static String getRandomAnecdoteText(Random random) {
    final key = getRandomAnecdoteKey(random);
    return anecdoteTurkishTexts[key] ?? key;
  }
}
