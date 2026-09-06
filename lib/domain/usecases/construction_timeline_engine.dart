import 'dart:math';

import '../../data/models/real_estate_model.dart';

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

  /// B7: Taşeron kademesi risk dengesi (Hızlı ekip aceleci/hata riskli, standart güvenli, bütçe ucuz/eksik iş riskli)
  double get riskMultiplier {
    switch (tier) {
      case SubcontractorTier.speed:
        return 1.25;
      case SubcontractorTier.standard:
        return 0.80;
      case SubcontractorTier.budget:
        return 1.10;
    }
  }
}

enum MunicipalDocStatus {
  approved,
  inReview,
  pendingFee,
  locked,
}

class MunicipalDocumentItem {
  final String id;
  final String titleKey;
  final String authorityKey;
  final String descriptionKey;
  final int requiredStage; // 1 to 8
  final double officialFee;
  final MunicipalDocStatus status;

  const MunicipalDocumentItem({
    required this.id,
    required this.titleKey,
    required this.authorityKey,
    required this.descriptionKey,
    required this.requiredStage,
    required this.officialFee,
    required this.status,
  });
}

class ConstructionTimelineEngine {
  /// 8 Aşamalı Türk İmar ve Şantiye Yaşam Döngüsü (A'dan Z'ye Belediye Ruhsatı ve İskan)
  static const List<ConstructionStageDetails> stages = [
    ConstructionStageDetails(
      stageNumber: 1,
      titleKey: 'construction_stage_permits_title',
      descriptionKey: 'construction_stage_permits_desc',
      baseDays: 8,
      costPercentage: 0.10,
    ),
    ConstructionStageDetails(
      stageNumber: 2,
      titleKey: 'construction_stage_excavation_title',
      descriptionKey: 'construction_stage_excavation_desc',
      baseDays: 10,
      costPercentage: 0.12,
    ),
    ConstructionStageDetails(
      stageNumber: 3,
      titleKey: 'construction_stage_rough_concrete_title',
      descriptionKey: 'construction_stage_rough_concrete_desc',
      baseDays: 16,
      costPercentage: 0.22,
    ),
    ConstructionStageDetails(
      stageNumber: 4,
      titleKey: 'construction_stage_facade_roof_title',
      descriptionKey: 'construction_stage_facade_roof_desc',
      baseDays: 14,
      costPercentage: 0.16,
    ),
    ConstructionStageDetails(
      stageNumber: 5,
      titleKey: 'construction_stage_mep_installation_title',
      descriptionKey: 'construction_stage_mep_installation_desc',
      baseDays: 12,
      costPercentage: 0.14,
    ),
    ConstructionStageDetails(
      stageNumber: 6,
      titleKey: 'construction_stage_interior_finishing_title',
      descriptionKey: 'construction_stage_interior_finishing_desc',
      baseDays: 12,
      costPercentage: 0.12,
    ),
    ConstructionStageDetails(
      stageNumber: 7,
      titleKey: 'construction_stage_landscape_infra_title',
      descriptionKey: 'construction_stage_landscape_infra_desc',
      baseDays: 8,
      costPercentage: 0.08,
    ),
    ConstructionStageDetails(
      stageNumber: 8,
      titleKey: 'construction_stage_occupancy_handover_title',
      descriptionKey: 'construction_stage_occupancy_handover_desc',
      baseDays: 6,
      costPercentage: 0.06,
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
    double? durationMultiplier,
  }) {
    final stage = getStageDetails(stageNumber);

    double scale = 1.0;
    if (parcelSquareMeters >= 2000) {
      scale = 1.35;
    } else if (parcelSquareMeters >= 1200) {
      scale = 1.18;
    }

    final mult = durationMultiplier ??
        (tier == SubcontractorTier.speed
            ? 0.75
            : (tier == SubcontractorTier.budget ? 1.25 : 1.0));

    return max(4, (stage.baseDays * scale * mult).round());
  }

  /// Her evre için mevcut 3 alternatif taşeron profili
  static List<SubcontractorProfile> getSubcontractorsForStage(int stageNumber) {
    final Map<int, List<String>> stageCrewNames = {
      1: ['Hızlı Ruhsat & Mimari Müşavirlik', 'Öz Mimarlık Proje Grubu', 'Hesaplı Mühendislik Bürosu'],
      2: ['Şimşek Hafriyat & Kazık İksa', 'Öz Dozer Hafriyat ve Temel', 'Kolektif Zemin & Kazı Ekibi'],
      3: ['C40 Hazır Betonarme & Hızlı Karkas', 'Öz Usta Kalıp & Beton Karkas', 'Hesaplı Demirci & Kalıpçılar'],
      4: ['Mega Mantolama & Alüminyum Cephe', 'Öz Duvar & Çatı Yalıtım Ustaları', 'Kardeşler Bims & Sıva Ekibi'],
      5: ['Akıllı Tesisat & Yangın MEP Çözümleri', 'Öz Sıhhi Tesisat & Elektrik Ltd.', 'Ekonomik Su & Elektrik Ustaları'],
      6: ['Lüks İç Mimari & Hızlı İnce İşçilik', 'Öz Seramik, Parke & Mutfak İmalat', 'Halk Tipi Şap & Alçı Ekibi'],
      7: ['Yeşil Vadi Peyzaj & Otopark Altyapı', 'Öz Çevre Düzenleme & Şebeke Bağlantı', 'Kardeşler Bahçe & Yol Parkesi'],
      8: ['Protokol İskan & Hızlı Tapu Takip', 'Öz İskan Danışmanlığı & Fenni Mesul', 'Ekonomik Kadastro ve Ruhsat Hizmeti'],
    };

    final names = stageCrewNames[stageNumber] ??
        ['Şimşek Hızlı Ekip', 'Öz Usta Mimarlık & İnşaat', 'Hesaplı Taşeron Kollektifi'];

    return [
      SubcontractorProfile(
        id: 'sub_speed_$stageNumber',
        name: names[0],
        specialtyKey: 'subcontractor_tier_speed_badge',
        tier: SubcontractorTier.speed,
        costMultiplier: 1.25,
        durationMultiplier: 0.75,
        reliabilityScore: 0.82,
        pitchKey: 'subcontractor_pitch_speed',
      ),
      SubcontractorProfile(
        id: 'sub_std_$stageNumber',
        name: names[1],
        specialtyKey: 'subcontractor_tier_standard_badge',
        tier: SubcontractorTier.standard,
        costMultiplier: 1.00,
        durationMultiplier: 1.00,
        reliabilityScore: 0.95,
        pitchKey: 'subcontractor_pitch_standard',
      ),
      SubcontractorProfile(
        id: 'sub_budget_$stageNumber',
        name: names[2],
        specialtyKey: 'subcontractor_tier_budget_badge',
        tier: SubcontractorTier.budget,
        costMultiplier: 0.80,
        durationMultiplier: 1.25,
        reliabilityScore: 0.74,
        pitchKey: 'subcontractor_pitch_budget',
      ),
    ];
  }

  /// Belediye resmi evrak ve ruhsat takip defteri
  static List<MunicipalDocumentItem> getMunicipalDocuments(int currentStage, {bool isFinished = false}) {
    MunicipalDocStatus calcStatus(int reqStage) {
      if (isFinished || currentStage > reqStage) return MunicipalDocStatus.approved;
      if (currentStage == reqStage) return MunicipalDocStatus.inReview;
      if (currentStage == reqStage - 1) return MunicipalDocStatus.pendingFee;
      return MunicipalDocStatus.locked;
    }

    return [
      MunicipalDocumentItem(
        id: 'doc_zoning_sheet',
        titleKey: 'municipal_doc_zoning_title',
        authorityKey: 'municipal_authority_zoning_dept',
        descriptionKey: 'municipal_doc_zoning_desc',
        requiredStage: 1,
        officialFee: 24500.0,
        status: calcStatus(1),
      ),
      MunicipalDocumentItem(
        id: 'doc_geotech_survey',
        titleKey: 'municipal_doc_geotech_title',
        authorityKey: 'municipal_authority_environment_dept',
        descriptionKey: 'municipal_doc_geotech_desc',
        requiredStage: 1,
        officialFee: 38000.0,
        status: calcStatus(1),
      ),
      MunicipalDocumentItem(
        id: 'doc_blueprint_approval',
        titleKey: 'municipal_doc_blueprint_title',
        authorityKey: 'municipal_authority_urban_planning',
        descriptionKey: 'municipal_doc_blueprint_desc',
        requiredStage: 1,
        officialFee: 52000.0,
        status: calcStatus(1),
      ),
      MunicipalDocumentItem(
        id: 'doc_building_permit',
        titleKey: 'municipal_doc_permit_title',
        authorityKey: 'municipal_authority_municipality_mayor',
        descriptionKey: 'municipal_doc_permit_desc',
        requiredStage: 1,
        officialFee: 115000.0,
        status: calcStatus(1),
      ),
      MunicipalDocumentItem(
        id: 'doc_concrete_inspection',
        titleKey: 'municipal_doc_inspection_title',
        authorityKey: 'municipal_authority_building_inspection',
        descriptionKey: 'municipal_doc_inspection_desc',
        requiredStage: 3,
        officialFee: 42000.0,
        status: calcStatus(3),
      ),
      MunicipalDocumentItem(
        id: 'doc_fire_safety',
        titleKey: 'municipal_doc_fire_title',
        authorityKey: 'municipal_authority_fire_dept',
        descriptionKey: 'municipal_doc_fire_desc',
        requiredStage: 5,
        officialFee: 31000.0,
        status: calcStatus(5),
      ),
      MunicipalDocumentItem(
        id: 'doc_sgk_clearance',
        titleKey: 'municipal_doc_sgk_title',
        authorityKey: 'municipal_authority_sgk',
        descriptionKey: 'municipal_doc_sgk_desc',
        requiredStage: 7,
        officialFee: 68000.0,
        status: calcStatus(7),
      ),
      MunicipalDocumentItem(
        id: 'doc_occupancy_permit',
        titleKey: 'municipal_doc_iskan_title',
        authorityKey: 'municipal_authority_cadastre_dept',
        descriptionKey: 'municipal_doc_iskan_desc',
        requiredStage: 8,
        officialFee: 95000.0,
        status: calcStatus(8),
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

class ConstructionPricing {
  /// Tek doğruluk kaynağı etap maliyet hesabı (B4, F1·9, F3·2)
  static double stageCost(
    RealEstateModel land,
    int stageNumber, {
    SubcontractorProfile? subcontractor,
    double costIndex = 1.0,
  }) {
    final stage = ConstructionTimelineEngine.getStageDetails(stageNumber);
    final base = (land.baseMarketValue * stage.costPercentage * costIndex).roundToDouble();
    if (subcontractor != null) {
      return (base * subcontractor.costMultiplier).roundToDouble();
    }
    return base;
  }

  /// Dinamik Mimari Plan & Statik Proje ücreti (1 gün sürer)
  static double architecturalPlanCost(
    RealEstateModel land, {
    double costIndex = 1.0,
    bool hasArchitectStaff = false,
  }) {
    final discount = hasArchitectStaff ? 0.70 : 1.0;
    return (land.baseMarketValue * 0.04 * costIndex * discount).roundToDouble();
  }

  /// Dinamik Belediye Yapı Ruhsatı & Resmi Harçlar ücreti (1 gün sürer)
  static double municipalPermitCost(
    RealEstateModel land, {
    double costIndex = 1.0,
    bool hasLegalAdvisor = false,
  }) {
    final discount = hasLegalAdvisor ? 0.70 : 1.0;
    return (land.baseMarketValue * 0.06 * costIndex * discount).roundToDouble();
  }
}
