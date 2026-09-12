import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/listing_model.dart';

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
  bargainMarketRadar,
  unofferedListingStale,
  debtInstallmentWarning,
}

/// Halil Usta Duygu ve Ruh Hali Durumları (§SPEC-2026-09-12-HALIL-USTA-DEEP-MENTOR)
enum MentorMood {
  neutral,
  proud,
  worried,
  clever,
  teaSip,
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
  final bool isCriticalModal;
  final double utilityScore;
  final MentorMood mood;

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
    this.isCriticalModal = false,
    this.utilityScore = 0.50,
    this.mood = MentorMood.neutral,
  });

  SmartMentorAdvice copyWith({
    SmartMentorAdviceType? type,
    String? titleKey,
    String? quoteKey,
    String? tacticalKey,
    String? actionBtnKey,
    String? targetRoute,
    IconData? iconData,
    Color? accentColor,
    Map<String, String>? params,
    bool? isCriticalModal,
    double? utilityScore,
    MentorMood? mood,
  }) {
    return SmartMentorAdvice(
      type: type ?? this.type,
      titleKey: titleKey ?? this.titleKey,
      quoteKey: quoteKey ?? this.quoteKey,
      tacticalKey: tacticalKey ?? this.tacticalKey,
      actionBtnKey: actionBtnKey ?? this.actionBtnKey,
      targetRoute: targetRoute ?? this.targetRoute,
      iconData: iconData ?? this.iconData,
      accentColor: accentColor ?? this.accentColor,
      params: params ?? this.params,
      isCriticalModal: isCriticalModal ?? this.isCriticalModal,
      utilityScore: utilityScore ?? this.utilityScore,
      mood: mood ?? this.mood,
    );
  }
}

/// Halil Usta Derin Akıllı Esnaf Motoru
/// Oyuncunun finansal dengesini, vitrinini, araç kondisyonunu, şube ve pazar durumunu
/// çok boyutlu analiz ederek fayda tabanlı (utility-based) en isabetli yönlendirmeyi üretir.
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
    List<ListingModel>? marketListings,
  }) {
    // Sadece öğretici bittikten sonra mentorluk devreye girer
    if (!game.tutorialCompleted) return null;

    final candidates = <SmartMentorAdvice>[];

    // 1. Durum: Kasa tamtakır ve garajda satılacak hiç araç yok (En kritik darboğaz)
    if (game.balance < 25000 && game.ownedCars.isEmpty) {
      candidates.add(const SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckBrokeNoCar,
        titleKey: 'mentor_title_broke_no_car',
        quoteKey: 'mentor_quote_broke_no_car',
        tacticalKey: 'mentor_tactical_broke_no_car',
        actionBtnKey: 'mentor_action_go_marketplace',
        targetRoute: '/marketplace',
        iconData: Icons.storefront_rounded,
        accentColor: AppColors.brutalRed,
        isCriticalModal: true,
        utilityScore: 1.00,
        mood: MentorMood.worried,
      ));
    }

    // 2. Durum: Yeni bir şubeye geçildi kutlaması & çarpan rehberliği
    if (lastCelebratedBranchTier != null &&
        game.currentBranchTier > lastCelebratedBranchTier) {
      final currentBranchName = game.currentBranchName;
      candidates.add(SmartMentorAdvice(
        type: SmartMentorAdviceType.branchUpgradedCelebration,
        titleKey: 'mentor_title_branch_celebrated',
        quoteKey: 'mentor_quote_branch_celebrated',
        tacticalKey: 'mentor_tactical_branch_celebrated',
        actionBtnKey: 'mentor_action_explore_branch',
        targetRoute: '/branches',
        iconData: Icons.apartment_rounded,
        accentColor: AppColors.toxicLime,
        params: {'branchName': currentBranchName},
        isCriticalModal: true,
        utilityScore: 0.90,
        mood: MentorMood.proud,
      ));
    }

    // 3. Durum: Yeni bir oyun mekaniği açıldı ve henüz ziyaret edilmedi
    for (final route in _keyFeatureRoutes) {
      if (game.isFeatureNew(route)) {
        candidates.add(_buildFeatureUnlockAdvice(route));
        break; // İlk kilit açılışı adaylara eklenir
      }
    }

    // 4. Durum: Vitrindeki araca teklif gelmiyor (Teklif Tıkanıklığı & Tanıtım Çağrısı)
    final staleUnofferedCar = game.ownedCars.where((c) =>
        c.isListed &&
        !c.isRented &&
        !c.isLockedInShowcase &&
        (c.daysListed >= 2 || c.isStaleListing) &&
        !game.incomingOffers.any((o) => o.carId == c.id && !o.isExpiredForDay(game.currentDay))).firstOrNull;
    if (staleUnofferedCar != null) {
      final carTitle = '${staleUnofferedCar.brand} ${staleUnofferedCar.modelName}';
      candidates.add(SmartMentorAdvice(
        type: SmartMentorAdviceType.unofferedListingStale,
        titleKey: 'mentor_title_stale_unoffered',
        quoteKey: 'mentor_quote_stale_unoffered',
        tacticalKey: 'mentor_tactical_stale_unoffered',
        actionBtnKey: 'mentor_action_solve_stale',
        targetRoute: '/showroom',
        iconData: Icons.campaign_rounded,
        accentColor: AppColors.brutalOrange,
        params: {
          'carName': carTitle,
          'carId': staleUnofferedCar.id,
        },
        utilityScore: 0.75,
        mood: MentorMood.worried,
      ));
    }

    // 5. Durum: Garajda araç var ama vitrinde hiç ilan yok (Gelir akışı durmuş)
    final hasUnlistedCars = game.ownedCars.isNotEmpty &&
        !game.ownedCars.any((c) => c.isListed);
    if (hasUnlistedCars) {
      candidates.add(const SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckNoListing,
        titleKey: 'mentor_title_no_listing',
        quoteKey: 'mentor_quote_no_listing',
        tacticalKey: 'mentor_tactical_no_listing',
        actionBtnKey: 'mentor_action_go_showroom',
        targetRoute: '/showroom',
        iconData: Icons.directions_car_rounded,
        accentColor: AppColors.brutalYellow,
        utilityScore: 0.72,
        mood: MentorMood.teaSip,
      ));
    }

    // 6. Durum: Kasa sıkışıkken araç rayicinin %25 üstünde fiyatlanmış (Erimiyor)
    final overpricedCar = game.ownedCars.where((c) =>
        c.isListed &&
        c.customListingPrice != null &&
        c.customListingPrice! > c.baseMarketValue * 1.25).firstOrNull;
    if (game.balance < 60000 && overpricedCar != null) {
      final carTitle = '${overpricedCar.brand} ${overpricedCar.modelName}';
      candidates.add(SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckOverpriced,
        titleKey: 'mentor_title_overpriced',
        quoteKey: 'mentor_quote_overpriced',
        tacticalKey: 'mentor_tactical_overpriced',
        actionBtnKey: 'mentor_action_go_showroom',
        targetRoute: '/showroom',
        iconData: Icons.price_change_rounded,
        accentColor: AppColors.brutalOrange,
        params: {
          'carName': carTitle,
          'carId': overpricedCar.id,
        },
        utilityScore: 0.65,
        mood: MentorMood.worried,
      ));
    }

    // 7. Durum: Pazaryerinde kelepir araç radarı (Rayicinin %20+ altına satılan fırsat)
    if (marketListings != null && marketListings.isNotEmpty) {
      final lastSeenDay = (game.mentorMemory['lastBargainSeenDay'] as num?)?.toInt() ?? 0;
      final Set<String> seenBargainIds = (game.currentDay > lastSeenDay)
          ? const <String>{}
          : (game.mentorMemory['seenBargainCarIds'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toSet() ??
              const <String>{};

      final bargain = marketListings.where((l) =>
          !seenBargainIds.contains(l.car.id) &&
          l.askingPrice <= l.car.baseMarketValue * 0.80 &&
          game.balance >= l.askingPrice &&
          game.ownedCars.length < game.maxGarageSlots).firstOrNull;
      if (bargain != null) {
        final bargainCarName = '${bargain.car.brand} ${bargain.car.modelName}';
        candidates.add(SmartMentorAdvice(
          type: SmartMentorAdviceType.bargainMarketRadar,
          titleKey: 'mentor_title_bargain_radar',
          quoteKey: 'mentor_quote_bargain_radar',
          tacticalKey: 'mentor_tactical_bargain_radar',
          actionBtnKey: 'mentor_action_go_bargain',
          targetRoute: '/marketplace',
          iconData: Icons.radar_rounded,
          accentColor: AppColors.toxicLime,
          params: {
            'carName': bargainCarName,
            'carId': bargain.car.id,
          },
          utilityScore: 0.70,
          mood: MentorMood.clever,
        ));
      }
    }

    // 8. Durum: Aktif banka kredisi borcu ve taksit uyarısı
    if (game.activeLoans.isNotEmpty) {
      final bool isCriticalDebt = game.balance < 35000;
      if (isCriticalDebt || game.currentDay % 3 == 0 || game.balance < 50000) {
        candidates.add(SmartMentorAdvice(
          type: SmartMentorAdviceType.debtInstallmentWarning,
          titleKey: 'mentor_title_debt_warning',
          quoteKey: 'mentor_quote_debt_warning',
          tacticalKey: 'mentor_tactical_debt_warning',
          actionBtnKey: 'mentor_action_go_debt_finance',
          targetRoute: '/finance',
          iconData: Icons.account_balance_rounded,
          accentColor: AppColors.brutalRed,
          isCriticalModal: isCriticalDebt,
          utilityScore: isCriticalDebt ? 0.95 : 0.70,
          mood: MentorMood.worried,
        ));
      }
    }

    // 9. Durum: Oyuncu bir sonraki şube seviyesine geçecek güce ve paraya sahip
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
          candidates.add(SmartMentorAdvice(
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
            utilityScore: 0.68,
            mood: MentorMood.proud,
          ));
        }
      }
    }

    // 10. Durum: Garajda yıkanmamış / çamurlu araç var ve Yıkama Tesisi açık
    if (game.isFeatureUnlocked('/car-wash')) {
      final hasDirtyCar = game.ownedCars.any(
        (c) => !c.isWashed || c.hasMuddyPenalty,
      );
      if (hasDirtyCar) {
        candidates.add(const SmartMentorAdvice(
          type: SmartMentorAdviceType.dirtyCarValueLoss,
          titleKey: 'mentor_title_dirty_car',
          quoteKey: 'mentor_quote_dirty_car',
          tacticalKey: 'mentor_tactical_dirty_car',
          actionBtnKey: 'mentor_action_go_car_wash',
          targetRoute: '/car-wash',
          iconData: Icons.local_car_wash_rounded,
          accentColor: AppColors.brutalCyan,
          utilityScore: 0.72,
          mood: MentorMood.teaSip,
        ));
      }
    }

    // 11. Durum: Garajda hasarlı parçası olan araç var ve Atölye açık
    if (game.isFeatureUnlocked('/workshop')) {
      final hasDamagedCar = game.ownedCars.any((c) =>
          c.expertise.engineCondition < 70 ||
          c.expertise.transmissionCondition < 70 ||
          c.expertise.bodyParts.values.any((p) => p == PartStatus.damaged));
      if (hasDamagedCar) {
        candidates.add(const SmartMentorAdvice(
          type: SmartMentorAdviceType.damagedCarRepairOpportunity,
          titleKey: 'mentor_title_damaged_repair',
          quoteKey: 'mentor_quote_damaged_repair',
          tacticalKey: 'mentor_tactical_damaged_repair',
          actionBtnKey: 'mentor_action_go_workshop',
          targetRoute: '/workshop',
          iconData: Icons.build_circle_rounded,
          accentColor: AppColors.brutalOrange,
          utilityScore: 0.75,
          mood: MentorMood.clever,
        ));
      }
    }

    // 12. Durum: Kasada yüklü nakit yatıyor ama garaj slotları boş
    if (game.balance >= 150000 &&
        game.ownedCars.length < game.maxGarageSlots) {
      candidates.add(const SmartMentorAdvice(
        type: SmartMentorAdviceType.idleCashSurplus,
        titleKey: 'mentor_title_idle_cash',
        quoteKey: 'mentor_quote_idle_cash',
        tacticalKey: 'mentor_tactical_idle_cash',
        actionBtnKey: 'mentor_action_go_marketplace',
        targetRoute: '/marketplace',
        iconData: Icons.account_balance_wallet_rounded,
        accentColor: AppColors.toxicLime,
        utilityScore: 0.58,
        mood: MentorMood.clever,
      ));
    }

    // 13. Durum: Düzenli rekabet hatırlatması • Liderlik Tablosu
    if (game.currentDay > 1 &&
        game.currentDay % 5 == 0 &&
        game.carsSold > 0) {
      candidates.add(const SmartMentorAdvice(
        type: SmartMentorAdviceType.rivalDominanceNudge,
        titleKey: 'mentor_title_rival_nudge',
        quoteKey: 'mentor_quote_rival_nudge',
        tacticalKey: 'mentor_tactical_rival_nudge',
        actionBtnKey: 'mentor_action_go_leaderboard',
        targetRoute: '/leaderboard',
        iconData: Icons.leaderboard_rounded,
        accentColor: AppColors.brutalPurple,
        utilityScore: 0.35,
        mood: MentorMood.clever,
      ));
    }

    if (candidates.isEmpty) return null;

    // Yorulma, Hafıza Sönümlemesi (Fatigue Damping) ve Tıklama Cooldown Kontrolü
    final memory = game.mentorMemory;
    final lastAdvisedName = memory['lastAdvisedType'] as String?;
    final consecutiveDays = (memory['consecutiveDays'] as num?)?.toInt() ?? 0;
    final cooldowns = (memory['adviceCooldowns'] as Map<String, dynamic>?) ?? const {};

    final scoredCandidates = candidates.map((c) {
      double score = c.utilityScore;
      final cooldownDay = (cooldowns[c.type.name] as num?)?.toInt();
      final bool isOnCooldown = cooldownDay != null && cooldownDay == game.currentDay;

      if (isOnCooldown) {
        // Aynı gün içinde tıklandıysa anında soğumaya girer (skor %10'a çekilerek sıradaki tavsiye öne çıkar)
        score = score * 0.10;
      } else if (lastAdvisedName == c.type.name && consecutiveDays > 0) {
        // Her tekrar eden gün için %20 sönümleme (asgari 0.20)
        final dampingFactor = math.pow(0.80, consecutiveDays).toDouble();
        score = (score * dampingFactor).clamp(0.20, 1.00);
      }
      return c.copyWith(utilityScore: score);
    }).toList();

    // En yüksek fayda skoruna göre sırala
    scoredCandidates.sort((a, b) => b.utilityScore.compareTo(a.utilityScore));
    final winner = scoredCandidates.first;

    // 3'lü diyalog havuzu varyant anahtarı seçimi (_v1, _v2, _v3)
    // featureUnlocked gibi tesis açılışı kutlamaları sabit tekil anahtarlara sahiptir.
    final String dynamicQuoteKey;
    if (winner.type == SmartMentorAdviceType.featureUnlocked) {
      dynamicQuoteKey = winner.quoteKey;
    } else {
      final int variantIndex = ((game.currentDay + winner.type.index) % 3) + 1;
      dynamicQuoteKey = '${winner.quoteKey}_v$variantIndex';
    }

    return winner.copyWith(
      quoteKey: dynamicQuoteKey,
    );
  }

  /// Tavsiye sunulduğunda veya tıklandığında usta hafızasını güncelleyen yardımcı metot
  static DealershipModel recordAdviceGiven(DealershipModel game, SmartMentorAdvice advice) {
    final memory = Map<String, dynamic>.from(game.mentorMemory);
    final lastType = memory['lastAdvisedType'] as String?;
    final lastDay = (memory['lastAdvisedDay'] as num?)?.toInt() ?? 0;
    int consecutive = (memory['consecutiveDays'] as num?)?.toInt() ?? 0;

    if (lastType == advice.type.name) {
      if (game.currentDay > lastDay) {
        consecutive++;
      }
    } else {
      consecutive = 1;
    }

    memory['lastAdvisedType'] = advice.type.name;
    memory['lastAdvisedDay'] = game.currentDay;
    memory['consecutiveDays'] = consecutive;

    // Tıklanan tavsiye türü için o gün sürecek anında soğuma (cooldown)
    final cooldowns = Map<String, dynamic>.from(
      (memory['adviceCooldowns'] as Map<String, dynamic>?) ?? const {},
    );
    cooldowns[advice.type.name] = game.currentDay;
    memory['adviceCooldowns'] = cooldowns;

    // Kelepir araç tavsiyesi ise tıklanan aracın kimliğini hafızaya işle
    final carId = advice.params['carId'];
    if (carId != null && advice.type == SmartMentorAdviceType.bargainMarketRadar) {
      final lastBargainDay = (memory['lastBargainSeenDay'] as num?)?.toInt() ?? 0;
      final seenList = (game.currentDay > lastBargainDay)
          ? <String>[]
          : List<String>.from(
              (memory['seenBargainCarIds'] as List<dynamic>?)?.map((e) => e.toString()) ?? const [],
            );
      if (!seenList.contains(carId)) {
        seenList.add(carId);
      }
      memory['seenBargainCarIds'] = seenList;
      memory['lastBargainSeenDay'] = game.currentDay;
    }

    return game.copyWith(mentorMemory: memory);
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
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
          isCriticalModal: true,
          utilityScore: 0.82,
          mood: MentorMood.proud,
        );
    }
  }
}
