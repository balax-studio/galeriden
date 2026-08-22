import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum LuckyOpportunityType {
  vipSponsorDeal,      // TV & Reklam Sponsorluk Çeki
  masterRestorationKit, // Ustanın Gizli Restorasyon Kiti
  secretBarnLead,       // Kayıp Ahır Buluntusu İhbarı
  insiderStockTip,      // Sanayi Borsası Gizli Fısıltısı
  wealthyCollectorOffer,// Zengin Koleksiyoncu Teklifi
}

class LuckyOpportunityModel {
  final String id;
  final LuckyOpportunityType type;
  final String titleKey;
  final String descriptionKey;
  final String perkSummaryKey;
  final IconData icon;
  final Color accentColor;
  final double cashReward;
  final int reputationBonus;

  const LuckyOpportunityModel({
    required this.id,
    required this.type,
    required this.titleKey,
    required this.descriptionKey,
    required this.perkSummaryKey,
    required this.icon,
    required this.accentColor,
    this.cashReward = 0.0,
    this.reputationBonus = 0,
  });

  static List<LuckyOpportunityModel> getAllOpportunities() {
    return const [
      LuckyOpportunityModel(
        id: 'lucky_sponsor_deal',
        type: LuckyOpportunityType.vipSponsorDeal,
        titleKey: 'lucky_sponsor_title',
        descriptionKey: 'lucky_sponsor_desc',
        perkSummaryKey: 'lucky_sponsor_perk',
        icon: Icons.campaign_rounded,
        accentColor: AppColors.brutalYellow,
        cashReward: 75000.0,
        reputationBonus: 8,
      ),
      LuckyOpportunityModel(
        id: 'lucky_restoration_kit',
        type: LuckyOpportunityType.masterRestorationKit,
        titleKey: 'lucky_resto_title',
        descriptionKey: 'lucky_resto_desc',
        perkSummaryKey: 'lucky_resto_perk',
        icon: Icons.auto_fix_high_rounded,
        accentColor: AppColors.brutalCyan,
        cashReward: 35000.0,
        reputationBonus: 6,
      ),
      LuckyOpportunityModel(
        id: 'lucky_barn_lead',
        type: LuckyOpportunityType.secretBarnLead,
        titleKey: 'lucky_barn_title',
        descriptionKey: 'lucky_barn_desc',
        perkSummaryKey: 'lucky_barn_perk',
        icon: Icons.explore_rounded,
        accentColor: AppColors.brutalOrange,
        cashReward: 50000.0,
        reputationBonus: 10,
      ),
      LuckyOpportunityModel(
        id: 'lucky_insider_stock',
        type: LuckyOpportunityType.insiderStockTip,
        titleKey: 'lucky_stock_title',
        descriptionKey: 'lucky_stock_desc',
        perkSummaryKey: 'lucky_stock_perk',
        icon: Icons.trending_up_rounded,
        accentColor: AppColors.brutalGreen,
        cashReward: 90000.0,
        reputationBonus: 5,
      ),
      LuckyOpportunityModel(
        id: 'lucky_collector_offer',
        type: LuckyOpportunityType.wealthyCollectorOffer,
        titleKey: 'lucky_collector_title',
        descriptionKey: 'lucky_collector_desc',
        perkSummaryKey: 'lucky_collector_perk',
        icon: Icons.military_tech_rounded,
        accentColor: AppColors.brutalPurple,
        cashReward: 120000.0,
        reputationBonus: 12,
      ),
    ];
  }

  /// Determines if a lucky opportunity should trigger based on pity counter and random roll
  static LuckyOpportunityModel? evaluateLuckyOpportunityRoll({
    required int pityCounter,
    required int currentDay,
    required int lastTriggerDay,
    required math.Random random,
  }) {
    // 1. Cooldown rule: Must not trigger multiple times in the same in-game day
    if (currentDay == lastTriggerDay) {
      return null;
    }

    // 2. Minimum actions before eligible (at least 3 actions)
    if (pityCounter < 3) {
      return null;
    }

    // 3. Pity probability scaling:
    // Count 3: 20%
    // Count 4: 40%
    // Count 5: 60%
    // Count 6: 80%
    // Count >= 7: 100% (Guaranteed)
    double chance = 0.20 + (pityCounter - 3) * 0.20;
    if (pityCounter >= 7 || random.nextDouble() < chance) {
      final list = getAllOpportunities();
      return list[random.nextInt(list.length)];
    }

    return null;
  }
}
