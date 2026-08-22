import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum StoreBundleType {
  starterPack,     // Çırak Galericilik Paketi
  scrapyardPack,   // Hurdalık İmparatoru Paketi
  plazaPack,       // Maslak Plaza Patronu Paketi
  noAdsLicense,    // No-Ads & Pro Galeri Lisansı
}

class StoreBundleModel {
  final String id;
  final StoreBundleType type;
  final String titleKey;
  final String subtitleKey;
  final String badgeKey;
  final double inGameCashCost;
  final double realPriceUsd;
  final IconData icon;
  final Color accentColor;
  final double cashBonus;
  final int reputationBonus;
  final List<String> perkKeys;

  const StoreBundleModel({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.subtitleKey,
    required this.badgeKey,
    required this.inGameCashCost,
    required this.realPriceUsd,
    required this.icon,
    required this.accentColor,
    required this.cashBonus,
    required this.reputationBonus,
    required this.perkKeys,
  });

  static List<StoreBundleModel> getAllBundles() {
    return const [
      StoreBundleModel(
        id: 'bundle_starter_apprentice',
        type: StoreBundleType.starterPack,
        titleKey: 'bundle_starter_title',
        subtitleKey: 'bundle_starter_subtitle',
        badgeKey: 'bundle_starter_badge',
        inGameCashCost: 50000.0,
        realPriceUsd: 1.99,
        icon: Icons.directions_car_filled_rounded,
        accentColor: AppColors.brutalYellow,
        cashBonus: 150000.0,
        reputationBonus: 10,
        perkKeys: [
          'bundle_starter_perk_1',
          'bundle_starter_perk_2',
          'bundle_starter_perk_3',
        ],
      ),
      StoreBundleModel(
        id: 'bundle_scrapyard_master',
        type: StoreBundleType.scrapyardPack,
        titleKey: 'bundle_scrapyard_title',
        subtitleKey: 'bundle_scrapyard_subtitle',
        badgeKey: 'bundle_scrapyard_badge',
        inGameCashCost: 150000.0,
        realPriceUsd: 4.99,
        icon: Icons.hardware_rounded,
        accentColor: AppColors.brutalCyan,
        cashBonus: 400000.0,
        reputationBonus: 18,
        perkKeys: [
          'bundle_scrapyard_perk_1',
          'bundle_scrapyard_perk_2',
          'bundle_scrapyard_perk_3',
        ],
      ),
      StoreBundleModel(
        id: 'bundle_plaza_tycoon',
        type: StoreBundleType.plazaPack,
        titleKey: 'bundle_plaza_title',
        subtitleKey: 'bundle_plaza_subtitle',
        badgeKey: 'bundle_plaza_badge',
        inGameCashCost: 500000.0,
        realPriceUsd: 9.99,
        icon: Icons.apartment_rounded,
        accentColor: AppColors.brutalPurple,
        cashBonus: 1500000.0,
        reputationBonus: 35,
        perkKeys: [
          'bundle_plaza_perk_1',
          'bundle_plaza_perk_2',
          'bundle_plaza_perk_3',
        ],
      ),
      StoreBundleModel(
        id: 'bundle_no_ads_pro',
        type: StoreBundleType.noAdsLicense,
        titleKey: 'bundle_no_ads_title',
        subtitleKey: 'bundle_no_ads_subtitle',
        badgeKey: 'bundle_no_ads_badge',
        inGameCashCost: 0.0,
        realPriceUsd: 2.99,
        icon: Icons.verified_rounded,
        accentColor: AppColors.brutalGreen,
        cashBonus: 100000.0,
        reputationBonus: 15,
        perkKeys: [
          'bundle_no_ads_perk_1',
          'bundle_no_ads_perk_2',
          'bundle_no_ads_perk_3',
        ],
      ),
    ];
  }
}
