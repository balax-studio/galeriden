import 'dart:math' as math;
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/lucky_opportunity_model.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../../data/models/showroom_theme_model.dart';
import '../../../data/models/store_bundle_model.dart';
import 'game_base_notifier.dart';

mixin GameMonetizationMixin on GameBaseNotifier {
  final math.Random _monetizationRandom = math.Random();

  /// Evaluates and potentially triggers a surprise lucky opportunity (2.a)
  LuckyOpportunityModel? checkAndRollLuckyOpportunity({bool force = false}) {
    final nextPity = state.luckyOpportunityPityCounter + 1;

    if (force) {
      final list = LuckyOpportunityModel.getAllOpportunities();
      final opp = list[_monetizationRandom.nextInt(list.length)];
      state = state.copyWith(luckyOpportunityPityCounter: nextPity);
      saveState();
      return opp;
    }

    final opp = LuckyOpportunityModel.evaluateLuckyOpportunityRoll(
      pityCounter: nextPity,
      currentDay: state.currentDay,
      lastTriggerDay: state.lastLuckyOpportunityDay,
      random: _monetizationRandom,
    );

    state = state.copyWith(luckyOpportunityPityCounter: nextPity);
    saveState();
    return opp;
  }

  /// Claims reward from a triggered lucky opportunity
  bool claimLuckyOpportunity(LuckyOpportunityModel opp) {
    state = state.copyWith(
      balance: state.balance + opp.cashReward,
      reputationScore: (state.reputationScore + opp.reputationBonus).clamp(0, 100),
      luckyOpportunityPityCounter: 0,
      lastLuckyOpportunityDay: state.currentDay,
    );
    saveState();
    return true;
  }

  /// Purchases a store progression bundle or no-ads license (b.2)
  bool purchaseStoreBundle(StoreBundleModel bundle, {bool paidRealMoney = true}) {
    // 1. Check if single-purchase bundle already owned
    switch (bundle.type) {
      case StoreBundleType.starterPack:
        if (state.isStarterBundlePurchased) return false;
        break;
      case StoreBundleType.scrapyardPack:
        if (state.isScrapyardBundlePurchased) return false;
        break;
      case StoreBundleType.plazaPack:
        if (state.isPlazaBundlePurchased) return false;
        break;
      case StoreBundleType.noAdsLicense:
        if (state.hasNoAdsLicense) return false;
        break;
    }

    // 2. Grant Cash and Reputation Perks
    double newBalance = state.balance;
    int newReputation = state.reputationScore;
    if (bundle.cashBonus > 0) {
      newBalance += bundle.cashBonus;
    }
    if (bundle.reputationBonus > 0) {
      newReputation = (newReputation + bundle.reputationBonus).clamp(0, 100);
    }

    // 3. Grant Specific Bundle Contents
    final newCars = List<CarModel>.from(state.ownedCars);
    final newParts = List<SalvagedPart>.from(state.salvagedParts);
    final newThemes = List<String>.from(state.unlockedShowroomThemeIds);
    String activeTheme = state.activeShowroomThemeId;

    bool isStarter = state.isStarterBundlePurchased;
    bool isScrapyard = state.isScrapyardBundlePurchased;
    bool isPlaza = state.isPlazaBundlePurchased;
    bool hasNoAds = state.hasNoAdsLicense;

    switch (bundle.type) {
      case StoreBundleType.starterPack:
        isStarter = true;
        // Add Starter Car (Fiat Egea 1.4 Fire Clean Condition)
        newCars.add(
          CarModel(
            id: 'car_bundle_egea_${DateTime.now().millisecondsSinceEpoch}',
            brand: 'Fiat',
            modelName: 'Egea 1.4 Fire Urban',
            modelYear: 2021,
            bodyType: 'Sedan',
            colorHex: '0xFFFFFFFF',
            colorDisplayName: 'Bulut Beyazı',
            colorRarity: 'common',
            plateNumber: '34 STAR 01',
            plateRarity: 'rare',
            baseMarketValue: 480000.0,
            currentPurchasePrice: 0.0,
            expertise: ExpertiseReport(
              engineCondition: 92.0,
              transmissionCondition: 90.0,
              tramerAmount: 0,
              mileage: 42000,
              isMileageTampered: false,
              bodyParts: const {
                'Kaput': PartStatus.original,
                'Tavan': PartStatus.original,
                'Bagaj': PartStatus.original,
                'Ön Tampon': PartStatus.original,
                'Arka Tampon': PartStatus.original,
                'Sol Ön Kapı': PartStatus.original,
                'Sağ Ön Kapı': PartStatus.original,
                'Sol Arka Kapı': PartStatus.original,
                'Sağ Arka Kapı': PartStatus.original,
                'Sol Ön Çamurluk': PartStatus.original,
                'Sağ Ön Çamurluk': PartStatus.original,
                'Sol Arka Çamurluk': PartStatus.original,
                'Sağ Arka Çamurluk': PartStatus.original,
              },
            ),
          ),
        );
        break;

      case StoreBundleType.scrapyardPack:
        isScrapyard = true;
        // Add 3 high-tier pristine salvaged parts
        newParts.addAll([
          SalvagedPart(
            id: 'part_pristine_turbo_${DateTime.now().millisecondsSinceEpoch}_1',
            name: 'Pristine Billet Turbo Şarj Kiti',
            carModelName: 'Audi RS6',
            category: 'engine',
            tier: PartQualityTier.pristine,
            estimatedValue: 45000.0,
            conditionPercent: 96,
          ),
          SalvagedPart(
            id: 'part_pristine_gearbox_${DateTime.now().millisecondsSinceEpoch}_2',
            name: 'Pristine Çift Kavrama DSG Şanzıman',
            carModelName: 'Volkswagen Golf R',
            category: 'transmission',
            tier: PartQualityTier.pristine,
            estimatedValue: 60000.0,
            conditionPercent: 94,
          ),
          SalvagedPart(
            id: 'part_pristine_ecu_${DateTime.now().millisecondsSinceEpoch}_3',
            name: 'Pristine Standalone Yarış ECU Beyni',
            carModelName: 'Toyota Supra',
            category: 'ecu',
            tier: PartQualityTier.pristine,
            estimatedValue: 35000.0,
            conditionPercent: 99,
          ),
        ]);
        break;

      case StoreBundleType.plazaPack:
        isPlaza = true;
        if (!newThemes.contains('theme_maslak_glass')) {
          newThemes.add('theme_maslak_glass');
        }
        activeTheme = 'theme_maslak_glass';
        break;

      case StoreBundleType.noAdsLicense:
        hasNoAds = true;
        break;
    }

    state = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      ownedCars: newCars,
      salvagedParts: newParts,
      unlockedShowroomThemeIds: newThemes,
      activeShowroomThemeId: activeTheme,
      isStarterBundlePurchased: isStarter,
      isScrapyardBundlePurchased: isScrapyard,
      isPlazaBundlePurchased: isPlaza,
      hasNoAdsLicense: hasNoAds,
    );
    saveState();
    return true;
  }

  /// Unlocks a showroom visual theme (d)
  bool purchaseShowroomTheme(ShowroomThemeModel theme) {
    if (state.unlockedShowroomThemeIds.contains(theme.id)) {
      setActiveShowroomTheme(theme.id);
      return true;
    }

    if (state.level < theme.minDealershipLevel) return false;
    if (state.balance < theme.cost) return false;

    final newThemes = List<String>.from(state.unlockedShowroomThemeIds)..add(theme.id);
    state = state.copyWith(
      balance: state.balance - theme.cost,
      reputationScore: (state.reputationScore + theme.reputationBonus.toInt()).clamp(0, 100),
      unlockedShowroomThemeIds: newThemes,
      activeShowroomThemeId: theme.id,
    );
    saveState();
    return true;
  }

  /// Sets the active showroom visual theme (d)
  void setActiveShowroomTheme(String themeId) {
    if (state.unlockedShowroomThemeIds.contains(themeId)) {
      state = state.copyWith(activeShowroomThemeId: themeId);
      saveState();
    }
  }

  /// Unlocks a custom vehicle paint or finish (d)
  bool purchaseCustomPaint(CustomPaintFinishModel paint) {
    if (state.unlockedCustomPaintIds.contains(paint.id)) return true;
    if (state.balance < paint.cost) return false;

    final newPaints = List<String>.from(state.unlockedCustomPaintIds)..add(paint.id);
    state = state.copyWith(
      balance: state.balance - paint.cost,
      unlockedCustomPaintIds: newPaints,
    );
    saveState();
    return true;
  }
}
