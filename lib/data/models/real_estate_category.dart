import 'package:flutter/material.dart';

enum RealEstateCategory {
  housing, // Konut (779.231)
  commercial, // İş Yeri (152.000)
  land, // Arsa (255.603)
  housingProjects, // Konut Projeleri (1.376)
  building, // Bina (8.867)
  timeshare, // Devre Mülk (2.562)
  tourismFacility, // Turistik Tesis (1.470)
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
      case RealEstateCategory.timeshare:
        return 2562;
      case RealEstateCategory.tourismFacility:
        return 1470;
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
      case RealEstateCategory.timeshare:
        return 'real_estate_cat_timeshare';
      case RealEstateCategory.tourismFacility:
        return 'real_estate_cat_tourism';
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
      case RealEstateCategory.timeshare:
        return Icons.holiday_village_rounded;
      case RealEstateCategory.tourismFacility:
        return Icons.hotel_rounded;
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
      case RealEstateCategory.timeshare:
        return const Color(0xFF06B6D4);
      case RealEstateCategory.tourismFacility:
        return const Color(0xFFEF4444);
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
      case RealEstateCategory.timeshare:
        return 'real_estate_renovation_timeshare';
      case RealEstateCategory.tourismFacility:
        return 'real_estate_renovation_tourism';
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
      case RealEstateCategory.timeshare:
        return 25000.0;
      case RealEstateCategory.tourismFacility:
        return 250000.0;
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
        return 0.0003; // ~0.9% monthly
      case RealEstateCategory.housingProjects:
        return 0.0010; // ~3.0% monthly
      case RealEstateCategory.building:
        return 0.0014; // ~4.2% monthly
      case RealEstateCategory.timeshare:
        return 0.0018; // ~5.4% seasonal high yield
      case RealEstateCategory.tourismFacility:
        return 0.0020; // ~6.0% commercial resort yield
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
