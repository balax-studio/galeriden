import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/expertise_model.dart';

/// Halil Usta Tavsiye Türleri
enum SmartMentorAdviceType {
  stuckBrokeNoCar,
  stuckNoListing,
  stuckOverpriced,
  branchUpgradedCelebration,
  branchUpgradeReady,
  featureUnlocked,
  dirtyCarValueLoss,
  damagedCarRepairOpportunity,
  idleCashSurplus,
  rivalDominanceNudge,
}

/// Halil Usta Akıllı Tavsiye Veri Modeli
class SmartMentorAdvice {
  final SmartMentorAdviceType type;
  final String titleKey;
  final String quoteKey;
  final String tacticalKey;
  final String actionBtnKey;
  final String targetRoute;
  final IconData iconData;
  final Color accentColor;
  final Map<String, String> params;

  const SmartMentorAdvice({
    required this.type,
    required this.titleKey,
    required this.quoteKey,
    required this.tacticalKey,
    required this.actionBtnKey,
    required this.targetRoute,
    required this.iconData,
    required this.accentColor,
    this.params = const {},
  });
}

/// Halil Usta Derin Akıllı Esnaf Motoru
/// Oyuncunun finansal dengesini, vitrinini, araç kondisyonunu, şube ve pazar durumunu
/// çok boyutlu analiz ederek en isabetli yönlendirmeyi üretir.
class SmartMentorEngine {
  /// Kritik oyun özellikleri öncelik sırası (Yeni açılanlar için)
  static const List<String> _keyFeatureRoutes = [
    '/car-wash',
    '/workshop',
    '/staff',
    '/tuning-studio',
    '/vasita',
    '/emlak',
    '/auction',
    '/bank-investments',
    '/stock-market',
  ];

  static SmartMentorAdvice? evaluateAdvice(
    DealershipModel game, {
    int? lastCelebratedBranchTier,
  }) {
    // Sadece öğretici bittikten sonra mentorluk devreye girer
    if (!game.tutorialCompleted) return null;

    // 1. Durum: Kasa tamtakır ve garajda satılacak hiç araç yok (En kritik darboğaz)
    if (game.balance < 25000 && game.ownedCars.isEmpty) {
      return const SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckBrokeNoCar,
        titleKey: 'mentor_title_broke_no_car',
        quoteKey: 'mentor_quote_broke_no_car',
        tacticalKey: 'mentor_tactical_broke_no_car',
        actionBtnKey: 'mentor_action_go_marketplace',
        targetRoute: '/marketplace',
        iconData: Icons.storefront_rounded,
        accentColor: AppColors.brutalRed,
      );
    }

    // 2. Durum: Yeni bir şubeye geçildi kutlaması & çarpan rehberliği
    if (lastCelebratedBranchTier != null &&
        game.currentBranchTier > lastCelebratedBranchTier) {
      final currentBranchName = game.currentBranchName;
      return SmartMentorAdvice(
        type: SmartMentorAdviceType.branchUpgradedCelebration,
        titleKey: 'mentor_title_branch_celebrated',
        quoteKey: 'mentor_quote_branch_celebrated',
        tacticalKey: 'mentor_tactical_branch_celebrated',
        actionBtnKey: 'mentor_action_explore_branch',
        targetRoute: '/branches',
        iconData: Icons.apartment_rounded,
        accentColor: AppColors.toxicLime,
        params: {'branchName': currentBranchName},
      );
    }

    // 3. Durum: Garajda araç var ama vitrinde hiç ilan yok (Gelir akışı durmuş)
    final hasUnlistedCars = game.ownedCars.isNotEmpty &&
        !game.ownedCars.any((c) => c.isListed);
    if (hasUnlistedCars) {
      return const SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckNoListing,
        titleKey: 'mentor_title_no_listing',
        quoteKey: 'mentor_quote_no_listing',
        tacticalKey: 'mentor_tactical_no_listing',
        actionBtnKey: 'mentor_action_go_showroom',
        targetRoute: '/showroom',
        iconData: Icons.directions_car_rounded,
        accentColor: AppColors.brutalYellow,
      );
    }

    // 4. Durum: Kasa sıkışıkken araç rayicinin %25 üstünde fiyatlanmış (Erimiyor)
    final hasOverpricedCar = game.balance < 60000 &&
        game.ownedCars.any((c) =>
            c.isListed &&
            c.customListingPrice != null &&
            c.customListingPrice! > c.baseMarketValue * 1.25);
    if (hasOverpricedCar) {
      return const SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckOverpriced,
        titleKey: 'mentor_title_overpriced',
        quoteKey: 'mentor_quote_overpriced',
        tacticalKey: 'mentor_tactical_overpriced',
        actionBtnKey: 'mentor_action_go_showroom',
        targetRoute: '/showroom',
        iconData: Icons.price_change_rounded,
        accentColor: AppColors.brutalOrange,
      );
    }

    // 5. Durum: Oyuncu bir sonraki şube seviyesine geçecek güce ve paraya sahip
    if (game.currentBranchTier < 8) {
      final branches = BranchModel.getAllBranches(
        currentSlotCount: game.maxGarageSlots,
        currentLevel: game.level,
        unlockedBuildings: game.unlockedBuildings,
        ownedDeeds: game.ownedBranchDeeds,
      );
      final nextTierIndex = game.currentBranchTier;
      if (nextTierIndex < branches.length) {
        final nextBranch = branches[nextTierIndex];
        if (game.balance >= nextBranch.requiredBalance &&
            game.level >= nextBranch.targetLevel) {
          return SmartMentorAdvice(
            type: SmartMentorAdviceType.branchUpgradeReady,
            titleKey: 'mentor_title_branch_upgrade_ready',
            quoteKey: 'mentor_quote_branch_upgrade_ready',
            tacticalKey: 'mentor_tactical_branch_upgrade_ready',
            actionBtnKey: 'mentor_action_go_branch',
            targetRoute: '/branches',
            iconData: Icons.upgrade_rounded,
            accentColor: AppColors.brutalCyan,
            params: {
              'branchName': nextBranch.name,
              'slots': nextBranch.maxGarageSlots.toString(),
            },
          );
        }
      }
    }

    // 6. Durum: Yeni bir oyun mekaniği açıldı ve henüz ziyaret edilmedi
    for (final route in _keyFeatureRoutes) {
      if (game.isFeatureNew(route)) {
        return _buildFeatureUnlockAdvice(route);
      }
    }

    // 7. Durum: Garajda yıkanmamış / çamurlu araç var ve Yıkama Tesisi açık
    if (game.isFeatureUnlocked('/car-wash')) {
      final hasDirtyCar = game.ownedCars.any(
        (c) => !c.isWashed || c.hasMuddyPenalty,
      );
      if (hasDirtyCar) {
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.dirtyCarValueLoss,
          titleKey: 'mentor_title_dirty_car',
          quoteKey: 'mentor_quote_dirty_car',
          tacticalKey: 'mentor_tactical_dirty_car',
          actionBtnKey: 'mentor_action_go_car_wash',
          targetRoute: '/car-wash',
          iconData: Icons.local_car_wash_rounded,
          accentColor: AppColors.brutalCyan,
        );
      }
    }

    // 8. Durum: Garajda hasarlı parçası olan araç var ve Atölye açık
    if (game.isFeatureUnlocked('/workshop')) {
      final hasDamagedCar = game.ownedCars.any((c) =>
          c.expertise.engineCondition < 70 ||
          c.expertise.transmissionCondition < 70 ||
          c.expertise.bodyParts.values.any((p) => p == PartStatus.damaged));
      if (hasDamagedCar) {
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.damagedCarRepairOpportunity,
          titleKey: 'mentor_title_damaged_repair',
          quoteKey: 'mentor_quote_damaged_repair',
          tacticalKey: 'mentor_tactical_damaged_repair',
          actionBtnKey: 'mentor_action_go_workshop',
          targetRoute: '/workshop',
          iconData: Icons.build_circle_rounded,
          accentColor: AppColors.brutalOrange,
        );
      }
    }

    // 9. Durum: Kasada yüklü nakit yatıyor ama garaj slotları boş
    if (game.balance >= 150000 &&
        game.ownedCars.length < game.maxGarageSlots) {
      return const SmartMentorAdvice(
        type: SmartMentorAdviceType.idleCashSurplus,
        titleKey: 'mentor_title_idle_cash',
        quoteKey: 'mentor_quote_idle_cash',
        tacticalKey: 'mentor_tactical_idle_cash',
        actionBtnKey: 'mentor_action_go_marketplace',
        targetRoute: '/marketplace',
        iconData: Icons.account_balance_wallet_rounded,
        accentColor: AppColors.toxicLime,
      );
    }

    // 10. Durum: Düzenli rekabet hatırlatması • Liderlik Tablosu
    if (game.currentDay > 1 &&
        game.currentDay % 5 == 0 &&
        game.carsSold > 0) {
      return const SmartMentorAdvice(
        type: SmartMentorAdviceType.rivalDominanceNudge,
        titleKey: 'mentor_title_rival_nudge',
        quoteKey: 'mentor_quote_rival_nudge',
        tacticalKey: 'mentor_tactical_rival_nudge',
        actionBtnKey: 'mentor_action_go_leaderboard',
        targetRoute: '/leaderboard',
        iconData: Icons.leaderboard_rounded,
        accentColor: AppColors.brutalPurple,
      );
    }

    return null;
  }

  static SmartMentorAdvice _buildFeatureUnlockAdvice(String route) {
    switch (route) {
      case '/car-wash':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_wash_title',
          quoteKey: 'mentor_feat_wash_quote',
          tacticalKey: 'mentor_feat_wash_tactical',
          actionBtnKey: 'mentor_action_go_car_wash',
          targetRoute: '/car-wash',
          iconData: Icons.local_car_wash_rounded,
          accentColor: AppColors.brutalCyan,
        );
      case '/workshop':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_workshop_title',
          quoteKey: 'mentor_feat_workshop_quote',
          tacticalKey: 'mentor_feat_workshop_tactical',
          actionBtnKey: 'mentor_action_go_workshop',
          targetRoute: '/workshop',
          iconData: Icons.handyman_rounded,
          accentColor: AppColors.brutalOrange,
        );
      case '/staff':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_staff_title',
          quoteKey: 'mentor_feat_staff_quote',
          tacticalKey: 'mentor_feat_staff_tactical',
          actionBtnKey: 'mentor_action_go_staff',
          targetRoute: '/staff',
          iconData: Icons.badge_rounded,
          accentColor: AppColors.brutalYellow,
        );
      case '/tuning-studio':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_tuning_title',
          quoteKey: 'mentor_feat_tuning_quote',
          tacticalKey: 'mentor_feat_tuning_tactical',
          actionBtnKey: 'mentor_action_go_tuning',
          targetRoute: '/tuning-studio',
          iconData: Icons.speed_rounded,
          accentColor: AppColors.brutalPurple,
        );
      case '/vasita':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_vasita_title',
          quoteKey: 'mentor_feat_vasita_quote',
          tacticalKey: 'mentor_feat_vasita_tactical',
          actionBtnKey: 'mentor_action_go_vasita',
          targetRoute: '/vasita',
          iconData: Icons.local_shipping_rounded,
          accentColor: AppColors.brutalGreen,
        );
      case '/emlak':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_emlak_title',
          quoteKey: 'mentor_feat_emlak_quote',
          tacticalKey: 'mentor_feat_emlak_tactical',
          actionBtnKey: 'mentor_action_go_emlak',
          targetRoute: '/emlak',
          iconData: Icons.real_estate_agent_rounded,
          accentColor: AppColors.brutalYellow,
        );
      case '/auction':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_auction_title',
          quoteKey: 'mentor_feat_auction_quote',
          tacticalKey: 'mentor_feat_auction_tactical',
          actionBtnKey: 'mentor_action_go_auction',
          targetRoute: '/auction',
          iconData: Icons.gavel_rounded,
          accentColor: AppColors.brutalRed,
        );
      case '/bank-investments':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_bank_title',
          quoteKey: 'mentor_feat_bank_quote',
          tacticalKey: 'mentor_feat_bank_tactical',
          actionBtnKey: 'mentor_action_go_bank',
          targetRoute: '/bank-investments',
          iconData: Icons.savings_rounded,
          accentColor: AppColors.toxicLime,
        );
      case '/stock-market':
        return const SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_stock_title',
          quoteKey: 'mentor_feat_stock_quote',
          tacticalKey: 'mentor_feat_stock_tactical',
          actionBtnKey: 'mentor_action_go_stock',
          targetRoute: '/stock-market',
          iconData: Icons.trending_up_rounded,
          accentColor: AppColors.brutalGreen,
        );
      default:
        return SmartMentorAdvice(
          type: SmartMentorAdviceType.featureUnlocked,
          titleKey: 'mentor_feat_generic_title',
          quoteKey: 'mentor_feat_generic_quote',
          tacticalKey: 'mentor_feat_generic_tactical',
          actionBtnKey: 'mentor_action_go_explore',
          targetRoute: route,
          iconData: Icons.explore_rounded,
          accentColor: AppColors.brutalYellow,
        );
    }
  }
}
