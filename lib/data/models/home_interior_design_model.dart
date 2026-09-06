import 'dart:math';
import 'package:flutter/material.dart';
import 'real_estate_model.dart';

enum HomeInteriorCategory {
  carpet, // Halı & Zemin Kaplama
  appliances, // Beyaz Eşya Grubu
  tvEntertainment, // Televizyon & Ses Sistemi
  curtains, // Perde & Stor Sistemleri
  furniture, // Mobilya & Oturma Grubu
  lightingClimate, // Aydınlatma & İklimlendirme
}

extension HomeInteriorCategoryExtension on HomeInteriorCategory {
  String get localizationKey {
    switch (this) {
      case HomeInteriorCategory.carpet:
        return 'interior_cat_carpet';
      case HomeInteriorCategory.appliances:
        return 'interior_cat_appliances';
      case HomeInteriorCategory.tvEntertainment:
        return 'interior_cat_tv';
      case HomeInteriorCategory.curtains:
        return 'interior_cat_curtains';
      case HomeInteriorCategory.furniture:
        return 'interior_cat_furniture';
      case HomeInteriorCategory.lightingClimate:
        return 'interior_cat_lighting';
    }
  }

  IconData get icon {
    switch (this) {
      case HomeInteriorCategory.carpet:
        return Icons.texture_rounded;
      case HomeInteriorCategory.appliances:
        return Icons.kitchen_rounded;
      case HomeInteriorCategory.tvEntertainment:
        return Icons.tv_rounded;
      case HomeInteriorCategory.curtains:
        return Icons.curtains_rounded;
      case HomeInteriorCategory.furniture:
        return Icons.chair_rounded;
      case HomeInteriorCategory.lightingClimate:
        return Icons.lightbulb_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case HomeInteriorCategory.carpet:
        return const Color(0xFFF59E0B);
      case HomeInteriorCategory.appliances:
        return const Color(0xFF06B6D4);
      case HomeInteriorCategory.tvEntertainment:
        return const Color(0xFF8B5CF6);
      case HomeInteriorCategory.curtains:
        return const Color(0xFFEC4899);
      case HomeInteriorCategory.furniture:
        return const Color(0xFF10B981);
      case HomeInteriorCategory.lightingClimate:
        return const Color(0xFFF43F5E);
    }
  }

  String get titleKey => localizationKey;
}

class HomeInteriorItem {
  final String id;
  final HomeInteriorCategory category;
  final int tier; // 1: Giriş, 2: Standart, 3: Lüks, 4: Başyapıt
  final String nameKey;
  final String descriptionKey;
  final double basePrice;
  final double nominalValueContribution;
  final int prestigeBonus;
  final IconData icon;

  const HomeInteriorItem({
    required this.id,
    required this.category,
    required this.tier,
    required this.nameKey,
    required this.descriptionKey,
    required this.basePrice,
    required this.nominalValueContribution,
    required this.prestigeBonus,
    required this.icon,
  });

  double get price => basePrice;
  double get appraisalValue => nominalValueContribution;

  /// All catalog items available in the interior design system
  static const List<HomeInteriorItem> allItems = [
    // 1. Halı & Zemin Kaplama (Carpet & Flooring)
    HomeInteriorItem(
      id: 'carpet_tier_1',
      category: HomeInteriorCategory.carpet,
      tier: 1,
      nameKey: 'interior_item_carpet_1_name',
      descriptionKey: 'interior_item_carpet_1_desc',
      basePrice: 15000.0,
      nominalValueContribution: 18000.0,
      prestigeBonus: 5,
      icon: Icons.layers_rounded,
    ),
    HomeInteriorItem(
      id: 'carpet_tier_2',
      category: HomeInteriorCategory.carpet,
      tier: 2,
      nameKey: 'interior_item_carpet_2_name',
      descriptionKey: 'interior_item_carpet_2_desc',
      basePrice: 45000.0,
      nominalValueContribution: 55000.0,
      prestigeBonus: 15,
      icon: Icons.grid_view_rounded,
    ),
    HomeInteriorItem(
      id: 'carpet_tier_3',
      category: HomeInteriorCategory.carpet,
      tier: 3,
      nameKey: 'interior_item_carpet_3_name',
      descriptionKey: 'interior_item_carpet_3_desc',
      basePrice: 120000.0,
      nominalValueContribution: 150000.0,
      prestigeBonus: 35,
      icon: Icons.grain_rounded,
    ),
    HomeInteriorItem(
      id: 'carpet_tier_4',
      category: HomeInteriorCategory.carpet,
      tier: 4,
      nameKey: 'interior_item_carpet_4_name',
      descriptionKey: 'interior_item_carpet_4_desc',
      basePrice: 350000.0,
      nominalValueContribution: 420000.0,
      prestigeBonus: 80,
      icon: Icons.auto_awesome_rounded,
    ),

    // 2. Beyaz Eşya Grubu (Appliances)
    HomeInteriorItem(
      id: 'appliance_tier_1',
      category: HomeInteriorCategory.appliances,
      tier: 1,
      nameKey: 'interior_item_appliance_1_name',
      descriptionKey: 'interior_item_appliance_1_desc',
      basePrice: 35000.0,
      nominalValueContribution: 40000.0,
      prestigeBonus: 10,
      icon: Icons.kitchen_rounded,
    ),
    HomeInteriorItem(
      id: 'appliance_tier_2',
      category: HomeInteriorCategory.appliances,
      tier: 2,
      nameKey: 'interior_item_appliance_2_name',
      descriptionKey: 'interior_item_appliance_2_desc',
      basePrice: 90000.0,
      nominalValueContribution: 110000.0,
      prestigeBonus: 25,
      icon: Icons.inventory_2_rounded,
    ),
    HomeInteriorItem(
      id: 'appliance_tier_3',
      category: HomeInteriorCategory.appliances,
      tier: 3,
      nameKey: 'interior_item_appliance_3_name',
      descriptionKey: 'interior_item_appliance_3_desc',
      basePrice: 220000.0,
      nominalValueContribution: 270000.0,
      prestigeBonus: 50,
      icon: Icons.microwave_rounded,
    ),
    HomeInteriorItem(
      id: 'appliance_tier_4',
      category: HomeInteriorCategory.appliances,
      tier: 4,
      nameKey: 'interior_item_appliance_4_name',
      descriptionKey: 'interior_item_appliance_4_desc',
      basePrice: 550000.0,
      nominalValueContribution: 680000.0,
      prestigeBonus: 100,
      icon: Icons.local_dining_rounded,
    ),

    // 3. Televizyon & Ses Eğlence (TV & Entertainment)
    HomeInteriorItem(
      id: 'tv_tier_1',
      category: HomeInteriorCategory.tvEntertainment,
      tier: 1,
      nameKey: 'interior_item_tv_1_name',
      descriptionKey: 'interior_item_tv_1_desc',
      basePrice: 25000.0,
      nominalValueContribution: 28000.0,
      prestigeBonus: 8,
      icon: Icons.tv_rounded,
    ),
    HomeInteriorItem(
      id: 'tv_tier_2',
      category: HomeInteriorCategory.tvEntertainment,
      tier: 2,
      nameKey: 'interior_item_tv_2_name',
      descriptionKey: 'interior_item_tv_2_desc',
      basePrice: 70000.0,
      nominalValueContribution: 85000.0,
      prestigeBonus: 20,
      icon: Icons.speaker_group_rounded,
    ),
    HomeInteriorItem(
      id: 'tv_tier_3',
      category: HomeInteriorCategory.tvEntertainment,
      tier: 3,
      nameKey: 'interior_item_tv_3_name',
      descriptionKey: 'interior_item_tv_3_desc',
      basePrice: 180000.0,
      nominalValueContribution: 220000.0,
      prestigeBonus: 45,
      icon: Icons.connected_tv_rounded,
    ),
    HomeInteriorItem(
      id: 'tv_tier_4',
      category: HomeInteriorCategory.tvEntertainment,
      tier: 4,
      nameKey: 'interior_item_tv_4_name',
      descriptionKey: 'interior_item_tv_4_desc',
      basePrice: 480000.0,
      nominalValueContribution: 600000.0,
      prestigeBonus: 95,
      icon: Icons.surround_sound_rounded,
    ),

    // 4. Perde & Stor Sistemleri (Curtains & Blinds)
    HomeInteriorItem(
      id: 'curtains_tier_1',
      category: HomeInteriorCategory.curtains,
      tier: 1,
      nameKey: 'interior_item_curtains_1_name',
      descriptionKey: 'interior_item_curtains_1_desc',
      basePrice: 12000.0,
      nominalValueContribution: 14000.0,
      prestigeBonus: 5,
      icon: Icons.curtains_closed_rounded,
    ),
    HomeInteriorItem(
      id: 'curtains_tier_2',
      category: HomeInteriorCategory.curtains,
      tier: 2,
      nameKey: 'interior_item_curtains_2_name',
      descriptionKey: 'interior_item_curtains_2_desc',
      basePrice: 38000.0,
      nominalValueContribution: 45000.0,
      prestigeBonus: 15,
      icon: Icons.curtains_rounded,
    ),
    HomeInteriorItem(
      id: 'curtains_tier_3',
      category: HomeInteriorCategory.curtains,
      tier: 3,
      nameKey: 'interior_item_curtains_3_name',
      descriptionKey: 'interior_item_curtains_3_desc',
      basePrice: 110000.0,
      nominalValueContribution: 135000.0,
      prestigeBonus: 35,
      icon: Icons.blinds_rounded,
    ),
    HomeInteriorItem(
      id: 'curtains_tier_4',
      category: HomeInteriorCategory.curtains,
      tier: 4,
      nameKey: 'interior_item_curtains_4_name',
      descriptionKey: 'interior_item_curtains_4_desc',
      basePrice: 290000.0,
      nominalValueContribution: 360000.0,
      prestigeBonus: 75,
      icon: Icons.roller_shades_rounded,
    ),

    // 5. Mobilya & Oturma Grubu (Furniture)
    HomeInteriorItem(
      id: 'furniture_tier_1',
      category: HomeInteriorCategory.furniture,
      tier: 1,
      nameKey: 'interior_item_furniture_1_name',
      descriptionKey: 'interior_item_furniture_1_desc',
      basePrice: 40000.0,
      nominalValueContribution: 48000.0,
      prestigeBonus: 12,
      icon: Icons.chair_alt_rounded,
    ),
    HomeInteriorItem(
      id: 'furniture_tier_2',
      category: HomeInteriorCategory.furniture,
      tier: 2,
      nameKey: 'interior_item_furniture_2_name',
      descriptionKey: 'interior_item_furniture_2_desc',
      basePrice: 120000.0,
      nominalValueContribution: 150000.0,
      prestigeBonus: 30,
      icon: Icons.chair_rounded,
    ),
    HomeInteriorItem(
      id: 'furniture_tier_3',
      category: HomeInteriorCategory.furniture,
      tier: 3,
      nameKey: 'interior_item_furniture_3_name',
      descriptionKey: 'interior_item_furniture_3_desc',
      basePrice: 320000.0,
      nominalValueContribution: 390000.0,
      prestigeBonus: 65,
      icon: Icons.weekend_rounded,
    ),
    HomeInteriorItem(
      id: 'furniture_tier_4',
      category: HomeInteriorCategory.furniture,
      tier: 4,
      nameKey: 'interior_item_furniture_4_name',
      descriptionKey: 'interior_item_furniture_4_desc',
      basePrice: 750000.0,
      nominalValueContribution: 950000.0,
      prestigeBonus: 120,
      icon: Icons.king_bed_rounded,
    ),

    // 6. Aydınlatma & İklimlendirme (Lighting & Climate)
    HomeInteriorItem(
      id: 'lighting_tier_1',
      category: HomeInteriorCategory.lightingClimate,
      tier: 1,
      nameKey: 'interior_item_lighting_1_name',
      descriptionKey: 'interior_item_lighting_1_desc',
      basePrice: 18000.0,
      nominalValueContribution: 22000.0,
      prestigeBonus: 6,
      icon: Icons.lightbulb_outline_rounded,
    ),
    HomeInteriorItem(
      id: 'lighting_tier_2',
      category: HomeInteriorCategory.lightingClimate,
      tier: 2,
      nameKey: 'interior_item_lighting_2_name',
      descriptionKey: 'interior_item_lighting_2_desc',
      basePrice: 55000.0,
      nominalValueContribution: 68000.0,
      prestigeBonus: 18,
      icon: Icons.lightbulb_rounded,
    ),
    HomeInteriorItem(
      id: 'lighting_tier_3',
      category: HomeInteriorCategory.lightingClimate,
      tier: 3,
      nameKey: 'interior_item_lighting_3_name',
      descriptionKey: 'interior_item_lighting_3_desc',
      basePrice: 160000.0,
      nominalValueContribution: 200000.0,
      prestigeBonus: 40,
      icon: Icons.ac_unit_rounded,
    ),
    HomeInteriorItem(
      id: 'lighting_tier_4',
      category: HomeInteriorCategory.lightingClimate,
      tier: 4,
      nameKey: 'interior_item_lighting_4_name',
      descriptionKey: 'interior_item_lighting_4_desc',
      basePrice: 420000.0,
      nominalValueContribution: 530000.0,
      prestigeBonus: 85,
      icon: Icons.hvac_rounded,
    ),
  ];

  static HomeInteriorItem? getItemById(String id) {
    for (final item in allItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<HomeInteriorItem> getItemsByCategory(HomeInteriorCategory category) {
    return allItems.where((item) => item.category == category).toList();
  }

  /// Calculates the controlled appreciation value added to a property.
  /// Anti-inflation mechanism: Sums nominal value contributions and applies a soft cap
  /// based on baseMarketValue (max 35% appreciation cap) so high-tier items
  /// do not compound exponentially or distort the economy.
  static double calculateAppraisedInteriorBonus(RealEstateModel property) {
    if (property.interiorDesignItemIds.isEmpty) return 0.0;

    double nominalSum = 0.0;
    for (final itemId in property.interiorDesignItemIds) {
      final item = getItemById(itemId);
      if (item != null) {
        nominalSum += item.nominalValueContribution;
      }
    }

    if (nominalSum <= 0) return 0.0;

    // Diminishing returns curve against base market value:
    // Soft cap at 35% of the property base value
    final maxAllowedCap = property.baseMarketValue * 0.35;
    if (maxAllowedCap <= 0) return nominalSum * 0.5;

    // Exponential saturation curve: cap * (1 - e^(-raw / cap))
    final ratio = nominalSum / maxAllowedCap;
    final saturatedMultiplier = 1.0 - exp(-ratio);
    final finalContribution = maxAllowedCap * saturatedMultiplier;

    return finalContribution.roundToDouble();
  }

  /// Total cumulative prestige granted by installed items
  static int calculateTotalPrestige(RealEstateModel property) {
    int total = 0;
    for (final itemId in property.interiorDesignItemIds) {
      final item = getItemById(itemId);
      if (item != null) {
        total += item.prestigeBonus;
      }
    }
    return total;
  }
}

abstract class HomeInteriorDesignCatalog {
  static List<HomeInteriorItem> get items => HomeInteriorItem.allItems;
  static List<HomeInteriorItem> get allItems => HomeInteriorItem.allItems;
  static HomeInteriorItem? getItemById(String id) => HomeInteriorItem.getItemById(id);
  static List<HomeInteriorItem> getItemsByCategory(HomeInteriorCategory category) =>
      HomeInteriorItem.getItemsByCategory(category);
  static List<HomeInteriorItem> getItemsForCategory(HomeInteriorCategory category) =>
      HomeInteriorItem.getItemsByCategory(category);
  static double calculateAppraisedInteriorBonus(RealEstateModel property) =>
      HomeInteriorItem.calculateAppraisedInteriorBonus(property);
  static int calculateTotalPrestige(RealEstateModel property) =>
      HomeInteriorItem.calculateTotalPrestige(property);
}

typedef HomeInteriorDesignModel = HomeInteriorDesignCatalog;
