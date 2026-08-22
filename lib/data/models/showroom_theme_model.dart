import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ShowroomThemeModel {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color accentColor;
  final Color wallColor;
  final Color floorColor;
  final Color spotColor;
  final double cost;
  final double reputationBonus;
  final int minDealershipLevel;

  const ShowroomThemeModel({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.accentColor,
    required this.wallColor,
    required this.floorColor,
    required this.spotColor,
    required this.cost,
    required this.reputationBonus,
    required this.minDealershipLevel,
  });

  static List<ShowroomThemeModel> getAllThemes() {
    return const [
      ShowroomThemeModel(
        id: 'theme_standard',
        titleKey: 'theme_standard_title',
        descriptionKey: 'theme_standard_desc',
        icon: Icons.store_rounded,
        accentColor: AppColors.brutalYellow,
        wallColor: Color(0xFF141721),
        floorColor: Color(0xFF0C0E14),
        spotColor: Colors.white70,
        cost: 0,
        reputationBonus: 0,
        minDealershipLevel: 1,
      ),
      ShowroomThemeModel(
        id: 'theme_maslak_glass',
        titleKey: 'theme_maslak_title',
        descriptionKey: 'theme_maslak_desc',
        icon: Icons.apartment_rounded,
        accentColor: AppColors.brutalCyan,
        wallColor: Color(0xFF111827),
        floorColor: Color(0xFF0F172A),
        spotColor: Color(0xFF38BDF8),
        cost: 250000.0,
        reputationBonus: 15.0,
        minDealershipLevel: 3,
      ),
      ShowroomThemeModel(
        id: 'theme_90s_sanayi',
        titleKey: 'theme_90s_title',
        descriptionKey: 'theme_90s_desc',
        icon: Icons.precision_manufacturing_rounded,
        accentColor: AppColors.brutalOrange,
        wallColor: Color(0xFF1C140E),
        floorColor: Color(0xFF170E08),
        spotColor: Color(0xFFF97316),
        cost: 120000.0,
        reputationBonus: 8.0,
        minDealershipLevel: 2,
      ),
      ShowroomThemeModel(
        id: 'theme_cyberpunk_neon',
        titleKey: 'theme_cyber_title',
        descriptionKey: 'theme_cyber_desc',
        icon: Icons.nightlife_rounded,
        accentColor: AppColors.brutalPink,
        wallColor: Color(0xFF180A2A),
        floorColor: Color(0xFF0F041D),
        spotColor: Color(0xFFE879F9),
        cost: 450000.0,
        reputationBonus: 22.0,
        minDealershipLevel: 4,
      ),
      ShowroomThemeModel(
        id: 'theme_vintage_loft',
        titleKey: 'theme_vintage_title',
        descriptionKey: 'theme_vintage_desc',
        icon: Icons.villa_rounded,
        accentColor: Color(0xFFD97706),
        wallColor: Color(0xFF221610),
        floorColor: Color(0xFF190F0A),
        spotColor: Color(0xFFFBBF24),
        cost: 320000.0,
        reputationBonus: 18.0,
        minDealershipLevel: 3,
      ),
    ];
  }
}

class CustomPaintFinishModel {
  final String id;
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color previewColor;
  final double cost;
  final double valueMultiplier; // Market value boost

  const CustomPaintFinishModel({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.previewColor,
    required this.cost,
    required this.valueMultiplier,
  });

  static List<CustomPaintFinishModel> getAllPaintFinishes() {
    return const [
      CustomPaintFinishModel(
        id: 'paint_chameleon',
        titleKey: 'paint_chameleon_title',
        descriptionKey: 'paint_chameleon_desc',
        icon: Icons.auto_awesome_rounded,
        previewColor: Color(0xFF8B5CF6),
        cost: 65000.0,
        valueMultiplier: 1.15,
      ),
      CustomPaintFinishModel(
        id: 'paint_carbon_fiber',
        titleKey: 'paint_carbon_title',
        descriptionKey: 'paint_carbon_desc',
        icon: Icons.texture_rounded,
        previewColor: Color(0xFF1E293B),
        cost: 85000.0,
        valueMultiplier: 1.20,
      ),
      CustomPaintFinishModel(
        id: 'paint_gold_leaf',
        titleKey: 'paint_gold_title',
        descriptionKey: 'paint_gold_desc',
        icon: Icons.stars_rounded,
        previewColor: Color(0xFFF59E0B),
        cost: 150000.0,
        valueMultiplier: 1.30,
      ),
      CustomPaintFinishModel(
        id: 'paint_matte_military',
        titleKey: 'paint_military_title',
        descriptionKey: 'paint_military_desc',
        icon: Icons.shield_rounded,
        previewColor: Color(0xFF3F6212),
        cost: 45000.0,
        valueMultiplier: 1.10,
      ),
    ];
  }
}
