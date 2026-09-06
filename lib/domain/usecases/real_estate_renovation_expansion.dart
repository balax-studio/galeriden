import 'package:flutter/material.dart';

import '../../data/models/real_estate_category.dart';
import '../../data/models/real_estate_model.dart';

/// Single renovation stage milestone definition within an expansion package
class RenovationStageDefinition {
  final int stageNumber;
  final String titleKey;
  final String descKey;
  final IconData icon;
  final double costRatio;
  final int durationDays;

  const RenovationStageDefinition({
    required this.stageNumber,
    required this.titleKey,
    required this.descKey,
    required this.icon,
    this.costRatio = 0.333333,
    this.durationDays = 2,
  });
}

/// Themed craftsman renovation package providing specialized scopes, perks, and visual identity
class RenovationPackageDefinition {
  final String id;
  final String nameKey;
  final String descKey;
  final String badgeKey;
  final IconData icon;
  final Color accentColor;
  final double bonusMultiplier;
  final List<RealEstateCategory> applicableCategories;
  final List<RenovationStageDefinition> stages;

  const RenovationPackageDefinition({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.badgeKey,
    required this.icon,
    required this.accentColor,
    required this.bonusMultiplier,
    required this.applicableCategories,
    required this.stages,
  });
}

/// Domain engine managing randomized renovation variety and thematic expansion packages
class RealEstateRenovationExpansion {
  RealEstateRenovationExpansion._();

  static const String packageModernLivingId = 'package_modern_living';
  static const String packageSmartLuxuryId = 'package_smart_luxury';
  static const String packageEcoGreenId = 'package_eco_green';
  static const String packageHistoricWoodId = 'package_historic_wood';
  static const String packageCommercialFitoutId = 'package_commercial_fitout';
  static const String packageIndustrialLoftId = 'package_industrial_loft';
  static const String packageGardenOasisId = 'package_garden_oasis';
  static const String packageQuickFlipId = 'package_quick_flip';
  static const String packageLandDevelopmentId = 'package_land_development';
  static const String packageBuildingFaceliftId = 'package_building_facelift';

  static const List<RenovationPackageDefinition> allPackages = [
    // 1. Standart & Modern Yaşam
    RenovationPackageDefinition(
      id: packageModernLivingId,
      nameKey: 'renov_pkg_modern_name',
      descKey: 'renov_pkg_modern_desc',
      badgeKey: 'renov_pkg_modern_badge',
      icon: Icons.weekend_rounded,
      accentColor: Color(0xFF3B82F6),
      bonusMultiplier: 1.20,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.housingProjects,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_modern_s1_t',
          descKey: 'renov_pkg_modern_s1_d',
          icon: Icons.plumbing_rounded,
          costRatio: 0.30,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_modern_s2_t',
          descKey: 'renov_pkg_modern_s2_d',
          icon: Icons.countertops_rounded,
          costRatio: 0.40,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_modern_s3_t',
          descKey: 'renov_pkg_modern_s3_d',
          icon: Icons.format_paint_rounded,
          costRatio: 0.30,
        ),
      ],
    ),

    // 2. Akıllı Ev & Lüks Otomasyon
    RenovationPackageDefinition(
      id: packageSmartLuxuryId,
      nameKey: 'renov_pkg_smart_name',
      descKey: 'renov_pkg_smart_desc',
      badgeKey: 'renov_pkg_smart_badge',
      icon: Icons.smart_toy_rounded,
      accentColor: Color(0xFF8B5CF6),
      bonusMultiplier: 1.28,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.housingProjects,
        RealEstateCategory.commercial,
        RealEstateCategory.building,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_smart_s1_t',
          descKey: 'renov_pkg_smart_s1_d',
          icon: Icons.settings_remote_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_smart_s2_t',
          descKey: 'renov_pkg_smart_s2_d',
          icon: Icons.kitchen_rounded,
          costRatio: 0.40,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_smart_s3_t',
          descKey: 'renov_pkg_smart_s3_d',
          icon: Icons.hvac_rounded,
          costRatio: 0.25,
        ),
      ],
    ),

    // 3. Ekolojik & A+ Enerji Tasarrufu
    RenovationPackageDefinition(
      id: packageEcoGreenId,
      nameKey: 'renov_pkg_eco_name',
      descKey: 'renov_pkg_eco_desc',
      badgeKey: 'renov_pkg_eco_badge',
      icon: Icons.eco_rounded,
      accentColor: Color(0xFF10B981),
      bonusMultiplier: 1.22,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.housingProjects,
        RealEstateCategory.building,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_eco_s1_t',
          descKey: 'renov_pkg_eco_s1_d',
          icon: Icons.shield_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_eco_s2_t',
          descKey: 'renov_pkg_eco_s2_d',
          icon: Icons.heat_pump_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_eco_s3_t',
          descKey: 'renov_pkg_eco_s3_d',
          icon: Icons.solar_power_rounded,
          costRatio: 0.30,
        ),
      ],
    ),

    // 4. Tarihi Doku & Masif Ahşap
    RenovationPackageDefinition(
      id: packageHistoricWoodId,
      nameKey: 'renov_pkg_historic_name',
      descKey: 'renov_pkg_historic_desc',
      badgeKey: 'renov_pkg_historic_badge',
      icon: Icons.carpenter_rounded,
      accentColor: Color(0xFFB45309),
      bonusMultiplier: 1.25,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.building,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_historic_s1_t',
          descKey: 'renov_pkg_historic_s1_d',
          icon: Icons.construction_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_historic_s2_t',
          descKey: 'renov_pkg_historic_s2_d',
          icon: Icons.table_bar_rounded,
          costRatio: 0.40,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_historic_s3_t',
          descKey: 'renov_pkg_historic_s3_d',
          icon: Icons.brush_rounded,
          costRatio: 0.25,
        ),
      ],
    ),

    // 5. Kurumsal Ofis Fit-Out
    RenovationPackageDefinition(
      id: packageCommercialFitoutId,
      nameKey: 'renov_pkg_comm_name',
      descKey: 'renov_pkg_comm_desc',
      badgeKey: 'renov_pkg_comm_badge',
      icon: Icons.business_center_rounded,
      accentColor: Color(0xFF0284C7),
      bonusMultiplier: 1.26,
      applicableCategories: [
        RealEstateCategory.commercial,
        RealEstateCategory.building,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_comm_s1_t',
          descKey: 'renov_pkg_comm_s1_d',
          icon: Icons.layers_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_comm_s2_t',
          descKey: 'renov_pkg_comm_s2_d',
          icon: Icons.lan_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_comm_s3_t',
          descKey: 'renov_pkg_comm_s3_d',
          icon: Icons.meeting_room_rounded,
          costRatio: 0.30,
        ),
      ],
    ),

    // 6. Endüstriyel Loft & Atölye Dönüşüm
    RenovationPackageDefinition(
      id: packageIndustrialLoftId,
      nameKey: 'renov_pkg_loft_name',
      descKey: 'renov_pkg_loft_desc',
      badgeKey: 'renov_pkg_loft_badge',
      icon: Icons.apartment_rounded,
      accentColor: Color(0xFF64748B),
      bonusMultiplier: 1.23,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.commercial,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_loft_s1_t',
          descKey: 'renov_pkg_loft_s1_d',
          icon: Icons.hardware_rounded,
          costRatio: 0.30,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_loft_s2_t',
          descKey: 'renov_pkg_loft_s2_d',
          icon: Icons.stairs_rounded,
          costRatio: 0.40,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_loft_s3_t',
          descKey: 'renov_pkg_loft_s3_d',
          icon: Icons.lightbulb_rounded,
          costRatio: 0.30,
        ),
      ],
    ),

    // 7. Peyzaj & Bahçe Yaşamı
    RenovationPackageDefinition(
      id: packageGardenOasisId,
      nameKey: 'renov_pkg_garden_name',
      descKey: 'renov_pkg_garden_desc',
      badgeKey: 'renov_pkg_garden_badge',
      icon: Icons.yard_rounded,
      accentColor: Color(0xFF059669),
      bonusMultiplier: 1.24,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.land,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_garden_s1_t',
          descKey: 'renov_pkg_garden_s1_d',
          icon: Icons.grass_rounded,
          costRatio: 0.30,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_garden_s2_t',
          descKey: 'renov_pkg_garden_s2_d',
          icon: Icons.deck_rounded,
          costRatio: 0.40,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_garden_s3_t',
          descKey: 'renov_pkg_garden_s3_d',
          icon: Icons.outdoor_grill_rounded,
          costRatio: 0.30,
        ),
      ],
    ),

    // 8. Hızlı Kozmetik Yenileme (Quick Flip)
    RenovationPackageDefinition(
      id: packageQuickFlipId,
      nameKey: 'renov_pkg_flip_name',
      descKey: 'renov_pkg_flip_desc',
      badgeKey: 'renov_pkg_flip_badge',
      icon: Icons.speed_rounded,
      accentColor: Color(0xFFEAB308),
      bonusMultiplier: 1.15,
      applicableCategories: [
        RealEstateCategory.housing,
        RealEstateCategory.commercial,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_flip_s1_t',
          descKey: 'renov_pkg_flip_s1_d',
          icon: Icons.build_rounded,
          costRatio: 0.30,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_flip_s2_t',
          descKey: 'renov_pkg_flip_s2_d',
          icon: Icons.sanitizer_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_flip_s3_t',
          descKey: 'renov_pkg_flip_s3_d',
          icon: Icons.toggle_on_rounded,
          costRatio: 0.35,
        ),
      ],
    ),

    // 9. Zemin Etüdü & Altyapı Parselasyon (Arsa)
    RenovationPackageDefinition(
      id: packageLandDevelopmentId,
      nameKey: 'renov_pkg_land_name',
      descKey: 'renov_pkg_land_desc',
      badgeKey: 'renov_pkg_land_badge',
      icon: Icons.landscape_rounded,
      accentColor: Color(0xFF15803D),
      bonusMultiplier: 1.25,
      applicableCategories: [
        RealEstateCategory.land,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_land_s1_t',
          descKey: 'renov_pkg_land_s1_d',
          icon: Icons.analytics_rounded,
          costRatio: 0.30,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_land_s2_t',
          descKey: 'renov_pkg_land_s2_d',
          icon: Icons.fence_rounded,
          costRatio: 0.35,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_land_s3_t',
          descKey: 'renov_pkg_land_s3_d',
          icon: Icons.power_rounded,
          costRatio: 0.35,
        ),
      ],
    ),

    // 10. Komple Dış Cephe & Mekanik Dönüşüm (Bina)
    RenovationPackageDefinition(
      id: packageBuildingFaceliftId,
      nameKey: 'renov_pkg_bldg_name',
      descKey: 'renov_pkg_bldg_desc',
      badgeKey: 'renov_pkg_bldg_badge',
      icon: Icons.domain_rounded,
      accentColor: Color(0xFFC026D3),
      bonusMultiplier: 1.27,
      applicableCategories: [
        RealEstateCategory.building,
      ],
      stages: [
        RenovationStageDefinition(
          stageNumber: 1,
          titleKey: 'renov_pkg_bldg_s1_t',
          descKey: 'renov_pkg_bldg_s1_d',
          icon: Icons.foundation_rounded,
          costRatio: 0.40,
        ),
        RenovationStageDefinition(
          stageNumber: 2,
          titleKey: 'renov_pkg_bldg_s2_t',
          descKey: 'renov_pkg_bldg_s2_d',
          icon: Icons.elevator_rounded,
          costRatio: 0.30,
        ),
        RenovationStageDefinition(
          stageNumber: 3,
          titleKey: 'renov_pkg_bldg_s3_t',
          descKey: 'renov_pkg_bldg_s3_d',
          icon: Icons.roofing_rounded,
          costRatio: 0.30,
        ),
      ],
    ),
  ];

  /// Returns packages applicable to a specific category
  static List<RenovationPackageDefinition> getAvailablePackages(RealEstateCategory category) {
    final list = allPackages
        .where((pkg) => pkg.applicableCategories.contains(category))
        .toList();
    if (list.isEmpty) {
      return [allPackages.first];
    }
    return list;
  }

  /// Looks up package by its unique identifier
  static RenovationPackageDefinition? getPackageById(String? id) {
    if (id == null) return null;
    try {
      return allPackages.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Resolves the renovation package for a property.
  /// If [renovationPackageId] is assigned, uses that package.
  /// Otherwise, deterministically hashes the property ID to pick an applicable package
  /// so every property has an immediately distinct, varied renovation track without broken state.
  static RenovationPackageDefinition getPackageForProperty(RealEstateModel property) {
    if (property.renovationPackageId != null) {
      final found = getPackageById(property.renovationPackageId);
      if (found != null) return found;
    }

    final pool = getAvailablePackages(property.category);
    // ponytail: deterministic hash derivation ensures non-destructive diversity across all properties
    final seed = property.id.hashCode.abs();
    return pool[seed % pool.length];
  }

  /// Calculates dynamic stage cost based on property base cost and package cost ratio
  static double getStageCost(RealEstateModel property, int stageNumber) {
    final package = getPackageForProperty(property);
    final stageIndex = (stageNumber - 1).clamp(0, package.stages.length - 1);
    final ratio = package.stages[stageIndex].costRatio;

    double baseTotal = property.category.renovationBaseCost;
    // Scale slightly for larger properties
    if (property.squareMeters > 100) {
      final extraScale = 1.0 + ((property.squareMeters - 100) / 400.0).clamp(0.0, 0.5);
      baseTotal *= extraScale;
    }

    return (baseTotal * ratio).roundToDouble();
  }
}
