import 'package:flutter/material.dart';

enum RealEstateCategory {
  housing, // Konut (779.231)
  commercial, // İş Yeri (152.000)
  land, // Arsa (255.603)
  housingProjects, // Konut Projeleri (1.376)
  building, // Bina (8.867)
}

extension RealEstateCategoryExtension on RealEstateCategory {
  int get catalogCount {
    switch (this) {
      case RealEstateCategory.housing:
        return 779231;
      case RealEstateCategory.commercial:
        return 152000;
      case RealEstateCategory.land:
        return 255603;
      case RealEstateCategory.housingProjects:
        return 1376;
      case RealEstateCategory.building:
        return 8867;
    }
  }

  String get localizationKey {
    switch (this) {
      case RealEstateCategory.housing:
        return 'real_estate_cat_housing';
      case RealEstateCategory.commercial:
        return 'real_estate_cat_commercial';
      case RealEstateCategory.land:
        return 'real_estate_cat_land';
      case RealEstateCategory.housingProjects:
        return 'real_estate_cat_projects';
      case RealEstateCategory.building:
        return 'real_estate_cat_building';
    }
  }

  IconData get icon {
    switch (this) {
      case RealEstateCategory.housing:
        return Icons.home_rounded;
      case RealEstateCategory.commercial:
        return Icons.store_rounded;
      case RealEstateCategory.land:
        return Icons.landscape_rounded;
      case RealEstateCategory.housingProjects:
        return Icons.apartment_rounded;
      case RealEstateCategory.building:
        return Icons.domain_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case RealEstateCategory.housing:
        return const Color(0xFF3B82F6);
      case RealEstateCategory.commercial:
        return const Color(0xFFF59E0B);
      case RealEstateCategory.land:
        return const Color(0xFF10B981);
      case RealEstateCategory.housingProjects:
        return const Color(0xFF8B5CF6);
      case RealEstateCategory.building:
        return const Color(0xFFEC4899);
    }
  }

  String get renovationTitleKey {
    switch (this) {
      case RealEstateCategory.housing:
        return 'real_estate_renovation_housing';
      case RealEstateCategory.commercial:
        return 'real_estate_renovation_commercial';
      case RealEstateCategory.land:
        return 'real_estate_renovation_land';
      case RealEstateCategory.housingProjects:
        return 'real_estate_renovation_projects';
      case RealEstateCategory.building:
        return 'real_estate_renovation_building';
    }
  }

  double get renovationBaseCost {
    switch (this) {
      case RealEstateCategory.housing:
        return 35000.0;
      case RealEstateCategory.commercial:
        return 65000.0;
      case RealEstateCategory.land:
        return 40000.0;
      case RealEstateCategory.housingProjects:
        return 120000.0;
      case RealEstateCategory.building:
        return 180000.0;
    }
  }

  /// Daily rental income multiplier based on market value
  double get dailyRentYieldRate {
    switch (this) {
      case RealEstateCategory.housing:
        return 0.0008; // ~2.4% monthly
      case RealEstateCategory.commercial:
        return 0.0012; // ~3.6% monthly
      case RealEstateCategory.land:
        return 0.0; // Arsa doğrudan kiraya verilemez • Yapı gereklidir
      case RealEstateCategory.housingProjects:
        return 0.0010; // ~3.0% monthly
      case RealEstateCategory.building:
        return 0.0014; // ~4.2% monthly
    }
  }

  static RealEstateCategory fromString(String? val) {
    if (val == null) return RealEstateCategory.housing;
    return RealEstateCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase(),
      orElse: () => RealEstateCategory.housing,
    );
  }
}
