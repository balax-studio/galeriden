import 'package:flutter/material.dart';

enum VehicleCategory {
  car,
  motorcycle,
  minivan,
  commercial,
  rentalFleet,
  marine,
  damaged,
  caravan,
  classic,
  aircraft,
  atv,
  utv;

  String get localizationKey {
    switch (this) {
      case VehicleCategory.car:
        return 'vehicle_cat_car';
      case VehicleCategory.motorcycle:
        return 'vehicle_cat_motorcycle';
      case VehicleCategory.minivan:
        return 'vehicle_cat_minivan';
      case VehicleCategory.commercial:
        return 'vehicle_cat_commercial';
      case VehicleCategory.rentalFleet:
        return 'vehicle_cat_rental';
      case VehicleCategory.marine:
        return 'vehicle_cat_marine';
      case VehicleCategory.damaged:
        return 'vehicle_cat_damaged';
      case VehicleCategory.caravan:
        return 'vehicle_cat_caravan';
      case VehicleCategory.classic:
        return 'vehicle_cat_classic';
      case VehicleCategory.aircraft:
        return 'vehicle_cat_aircraft';
      case VehicleCategory.atv:
        return 'vehicle_cat_atv';
      case VehicleCategory.utv:
        return 'vehicle_cat_utv';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleCategory.car:
        return Icons.directions_car_rounded;
      case VehicleCategory.motorcycle:
        return Icons.two_wheeler_rounded;
      case VehicleCategory.minivan:
        return Icons.airport_shuttle_rounded;
      case VehicleCategory.commercial:
        return Icons.local_shipping_rounded;
      case VehicleCategory.rentalFleet:
        return Icons.car_rental_rounded;
      case VehicleCategory.marine:
        return Icons.directions_boat_filled_rounded;
      case VehicleCategory.damaged:
        return Icons.car_crash_rounded;
      case VehicleCategory.caravan:
        return Icons.rv_hookup_rounded;
      case VehicleCategory.classic:
        return Icons.stars_rounded;
      case VehicleCategory.aircraft:
        return Icons.flight_takeoff_rounded;
      case VehicleCategory.atv:
        return Icons.terrain_rounded;
      case VehicleCategory.utv:
        return Icons.agriculture_rounded;
    }
  }

  /// Official marketplace listing count based on real market distribution
  int get catalogCount {
    switch (this) {
      case VehicleCategory.car:
        return 485200;
      case VehicleCategory.motorcycle:
        return 125979;
      case VehicleCategory.minivan:
        return 75097;
      case VehicleCategory.commercial:
        return 48944;
      case VehicleCategory.rentalFleet:
        return 10539;
      case VehicleCategory.marine:
        return 10929;
      case VehicleCategory.damaged:
        return 4391;
      case VehicleCategory.caravan:
        return 5814;
      case VehicleCategory.classic:
        return 1848;
      case VehicleCategory.aircraft:
        return 13;
      case VehicleCategory.atv:
        return 3217;
      case VehicleCategory.utv:
        return 443;
    }
  }

  String get rarityKey {
    switch (this) {
      case VehicleCategory.car:
      case VehicleCategory.motorcycle:
      case VehicleCategory.minivan:
      case VehicleCategory.commercial:
        return 'vasita_rarity_common';
      case VehicleCategory.rentalFleet:
      case VehicleCategory.marine:
      case VehicleCategory.caravan:
        return 'vasita_rarity_uncommon';
      case VehicleCategory.damaged:
      case VehicleCategory.atv:
        return 'vasita_rarity_rare';
      case VehicleCategory.classic:
      case VehicleCategory.utv:
        return 'vasita_rarity_epic';
      case VehicleCategory.aircraft:
        return 'vasita_rarity_mythic';
    }
  }

  Color get badgeColor {
    switch (this) {
      case VehicleCategory.car:
        return const Color(0xFF38BDF8);
      case VehicleCategory.motorcycle:
        return const Color(0xFFFFDE59);
      case VehicleCategory.minivan:
        return const Color(0xFF10B981);
      case VehicleCategory.commercial:
        return const Color(0xFFF97316);
      case VehicleCategory.rentalFleet:
        return const Color(0xFF6366F1);
      case VehicleCategory.marine:
        return const Color(0xFF06B6D4);
      case VehicleCategory.damaged:
        return const Color(0xFFEF4444);
      case VehicleCategory.caravan:
        return const Color(0xFF84CC16);
      case VehicleCategory.classic:
        return const Color(0xFFA855F7);
      case VehicleCategory.aircraft:
        return const Color(0xFFEC4899);
      case VehicleCategory.atv:
        return const Color(0xFFEAB308);
      case VehicleCategory.utv:
        return const Color(0xFFD946EF);
    }
  }

  String get washTitleKey {
    switch (this) {
      case VehicleCategory.marine:
        return 'wash_title_marine';
      case VehicleCategory.aircraft:
        return 'wash_title_aircraft';
      case VehicleCategory.motorcycle:
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return 'wash_title_bike_atv';
      case VehicleCategory.caravan:
        return 'wash_title_caravan';
      case VehicleCategory.commercial:
      case VehicleCategory.minivan:
        return 'wash_title_commercial';
      default:
        return 'tab_garage_wash';
    }
  }

  String get washDetailKey {
    switch (this) {
      case VehicleCategory.marine:
        return 'wash_detail_marine';
      case VehicleCategory.aircraft:
        return 'wash_detail_aircraft';
      case VehicleCategory.motorcycle:
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return 'wash_detail_bike_atv';
      case VehicleCategory.caravan:
        return 'wash_detail_caravan';
      case VehicleCategory.commercial:
      case VehicleCategory.minivan:
        return 'wash_detail_commercial';
      default:
        return 'car_wash_service_detailing';
    }
  }

  String get engineRepairKey {
    switch (this) {
      case VehicleCategory.marine:
        return 'repair_engine_marine';
      case VehicleCategory.aircraft:
        return 'repair_engine_aircraft';
      case VehicleCategory.motorcycle:
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return 'repair_engine_bike_atv';
      case VehicleCategory.caravan:
        return 'repair_engine_caravan';
      case VehicleCategory.commercial:
      case VehicleCategory.minivan:
        return 'repair_engine_commercial';
      default:
        return 'workshop_card_engine_title';
    }
  }

  String get transmissionRepairKey {
    switch (this) {
      case VehicleCategory.marine:
        return 'repair_transmission_marine';
      case VehicleCategory.aircraft:
        return 'repair_transmission_aircraft';
      case VehicleCategory.motorcycle:
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return 'repair_transmission_bike_atv';
      case VehicleCategory.caravan:
        return 'repair_transmission_caravan';
      case VehicleCategory.commercial:
      case VehicleCategory.minivan:
        return 'repair_transmission_commercial';
      default:
        return 'workshop_card_transmission_title';
    }
  }

  String get bodyworkRepairKey {
    switch (this) {
      case VehicleCategory.marine:
        return 'repair_body_marine';
      case VehicleCategory.aircraft:
        return 'repair_body_aircraft';
      case VehicleCategory.motorcycle:
      case VehicleCategory.atv:
      case VehicleCategory.utv:
        return 'repair_body_bike_atv';
      case VehicleCategory.caravan:
        return 'repair_body_caravan';
      case VehicleCategory.commercial:
      case VehicleCategory.minivan:
        return 'repair_body_commercial';
      default:
        return 'workshop_card_body_title';
    }
  }

  static VehicleCategory fromString(String? val) {
    if (val == null) return VehicleCategory.car;
    for (final cat in VehicleCategory.values) {
      if (cat.name.toLowerCase() == val.toLowerCase()) {
        return cat;
      }
    }
    return VehicleCategory.car;
  }
}
