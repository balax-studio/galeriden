import 'real_estate_category.dart';
import 'real_estate_offer_model.dart';
import 'tenant_model.dart';

enum DeedType {
  ownershipDeed, // Kat Mülkiyetli (Sorunsuz, temiz tapu)
  constructionServitude, // Kat İrtifaklı (Standart)
  sharedDeed, // Hisseli Tapu (Şufa riski • %20 indirimli)
  unlicensedBuilding, // İskansız Yapı (Şantiye elektriği • %30 indirimli)
}

extension DeedTypeExtension on DeedType {
  String get localizationKey {
    switch (this) {
      case DeedType.ownershipDeed:
        return 'deed_type_ownership';
      case DeedType.constructionServitude:
        return 'deed_type_servitude';
      case DeedType.sharedDeed:
        return 'deed_type_shared';
      case DeedType.unlicensedBuilding:
        return 'deed_type_unlicensed';
    }
  }

  double get valueMultiplier {
    switch (this) {
      case DeedType.ownershipDeed:
        return 1.0;
      case DeedType.constructionServitude:
        return 0.95;
      case DeedType.sharedDeed:
        return 0.80; // %20 indirimli
      case DeedType.unlicensedBuilding:
        return 0.70; // %30 indirimli
    }
  }
}

enum RealEstateSellerType {
  individual, // Sahibinden • 0% komisyon
  agency, // Emlak Ofisinden • 2% komisyon
  bankAuction, // Bankadan / İcradan • 0% komisyon • Kelepir
}

extension RealEstateSellerTypeExtension on RealEstateSellerType {
  String get localizationKey {
    switch (this) {
      case RealEstateSellerType.individual:
        return 'seller_type_individual';
      case RealEstateSellerType.agency:
        return 'seller_type_agency';
      case RealEstateSellerType.bankAuction:
        return 'seller_type_bank_auction';
    }
  }

  double get commissionRate {
    switch (this) {
      case RealEstateSellerType.individual:
        return 0.0;
      case RealEstateSellerType.agency:
        return 0.02; // %2 emlakçı komisyonu
      case RealEstateSellerType.bankAuction:
        return 0.0;
    }
  }
}

enum LandPhase {
  imar,
  modSecimi,
  muteahhitBekleme,
  etapHazir,
  etapCalisiyor,
  etapTeslimAlinir,
  teslimeHazir,
  tamamlandi,
}

class RealEstateModel {
  final String id;
  final String title;
  final RealEstateCategory category;
  final String city;
  final String district;
  final int squareMeters;
  final String roomCount; // 1+1, 2+1, 3+1, 4+2, Müstakil, Açık Alan
  final int buildingAge;
  final DeedType deedType;
  final RealEstateSellerType sellerType;
  final double baseMarketValue;
  final double currentPurchasePrice;
  final double deedFeePaid;
  final double commissionPaid;
  final bool isRenovated;
  final bool isRented;
  final List<String> provenanceLog;
  final bool isListed;
  final double? customListingPrice;
  final int daysListed;
  final int renovationStage; // 0: Başlanmadı, 1: Yıkım & Tesisat (%35), 2: Mutfak & Banyo (%70), 3: Tamamlandı (%100)
  final int renovationDaysRemaining; // Mevcut tadilat aşamasının tamamlanmasına kalan gün (standart 2 gün, acele 0 gün)
  final bool isRushedRenovation; // Usta aceleye getirdi
  final bool hasWaterLeakRisk; // Gizli su kaçağı riski
  final double pendingRentIncome; // Biriken tahsil edilmemiş kira havuzu
  final int uncollectedRentDays; // Tahsil edilmeden geçen gün sayısı (loss-aversion)
  final bool isPersonalResidence; // Kişisel ikametgah olarak atanmış mülk
  final int constructionStage; // 0: Başlanmadı, 1: Ruhsat, 2: Hafriyat, 3: Kaba Yapı, 4: Cephe/Çatı, 5: Tesisat, 6: İnce İşler, 7: Peyzaj, 8: İskan
  final String? constructionMode; // null, 'contractor' (Müteahhit Kat Karşılığı), 'selfBuild' (Öz-İnşaat)
  final int playerSharePercent; // Oyuncunun kat karşılığı daire payı (ör. 50, öz-inşaatta 100)
  int get contractorSharePercent => 100 - playerSharePercent; // Geriye dönük uyumluluk getter'ı
  final double totalConstructionSpent; // Öz-inşaatta kümülatif harcanan toplam inşaat bütçesi (C4)
  final bool hasPrimeFloorClause; // Üst katların tahsisi sözleşme şartı (A7, C3)
  final bool hasQualityUpgrade; // C35 lüks şartname (+%8 değer) (A7)
  final double contractorAdvancePaid; // Nakit avans (A7)
  final bool hasBankGuarantee; // Banka teminat mektubu (A7, A9)
  final int contractorStageDays; // Müteahhit etap süresi (A7, F1: çift vardiyada 11, standart 15)
  final int _totalProjectUnits; // Toplam daire adedi
  final int soldPreSaleUnits; // Topraktan satılmış daire adedi
  final int constructionDaysRemaining; // Mevcut şantiye etabına kalan gün
  final bool isConstructionWorking; // Şantiye etabı fiilen çalışıyor mu
  final String? activeSubcontractorName; // Çalışan taşeron ekibinin adı
  final int stageTotalDays; // Mevcut etabın toplam hedef günü
  final List<RealEstateOfferModel> activeOffers; // Vitrin teklif havuzu
  final TenantModel? currentTenant; // Mülkte oturan aktif kiracı
  final bool isRentalListed; // Kiralık vitrininde ilanda mı
  final Map<String, dynamic>? customUnitMix; // Projede yapılandırılan dinamik daire tipolojisi
  final String? listingHeadline; // Seçilen ilan başlığı
  final String? listingDescription; // İlan detay metni
  final List<String> listingFeatures; // Seçilen mülk özellikleri / etiketleri
  final String listingPackage; // 'standard', 'featured', 'super'
  final double qualityScore; // 0.0 - 100.0, default 75.0 (F3·3)
  final bool isMortgaged; // İpotekli mi (İnşaat kredisi teminatı • F2·6, F5)

  const RealEstateModel({
    required this.id,
    required this.title,
    required this.category,
    required this.city,
    required this.district,
    required this.squareMeters,
    required this.roomCount,
    required this.buildingAge,
    required this.deedType,
    required this.sellerType,
    required this.baseMarketValue,
    required this.currentPurchasePrice,
    this.deedFeePaid = 0.0,
    this.commissionPaid = 0.0,
    this.isRenovated = false,
    this.isRented = false,
    this.provenanceLog = const [],
    this.isListed = false,
    this.customListingPrice,
    this.daysListed = 0,
    this.renovationStage = 0,
    this.renovationDaysRemaining = 0,
    this.isRushedRenovation = false,
    this.hasWaterLeakRisk = false,
    this.pendingRentIncome = 0.0,
    this.uncollectedRentDays = 0,
    this.isPersonalResidence = false,
    this.constructionStage = 0,
    this.constructionMode,
    int? playerSharePercent,
    int? contractorSharePercent,
    this.totalConstructionSpent = 0.0,
    this.hasPrimeFloorClause = false,
    this.hasQualityUpgrade = false,
    this.contractorAdvancePaid = 0.0,
    this.hasBankGuarantee = false,
    this.contractorStageDays = 15,
    int totalProjectUnits = 0,
    this.soldPreSaleUnits = 0,
    this.constructionDaysRemaining = 0,
    this.isConstructionWorking = false,
    this.activeSubcontractorName,
    this.stageTotalDays = 0,
    this.activeOffers = const [],
    this.currentTenant,
    this.isRentalListed = false,
    this.customUnitMix,
    this.listingHeadline,
    this.listingDescription,
    this.listingFeatures = const [],
    this.listingPackage = 'standard',
    this.qualityScore = 75.0,
    this.isMortgaged = false,
  })  : _totalProjectUnits = totalProjectUnits,
        playerSharePercent = playerSharePercent ??
            (contractorSharePercent != null
                ? 100 - contractorSharePercent
                : 50);

  /// Dynamic fair market value accounting for deed status, renovations, defects, and construction quality
  double get estimatedRealValue {
    double value = baseMarketValue * deedType.valueMultiplier;
    if (isRenovated || renovationStage >= 3) {
      value *= 1.15; // +%15 flipping tadilat primi
    }
    if (hasWaterLeakRisk) {
      value *= 0.90; // -%10 gizli su kaçağı hasar kırımı
    }
    if (category != RealEstateCategory.land) {
      // F3·3: Kalite skoru ±%15 değerleme etkisi (75 taban)
      final qualityDelta = ((qualityScore - 75.0) / 25.0).clamp(-1.0, 1.0);
      value *= (1.0 + (qualityDelta * 0.15));
    }
    return value.roundToDouble();
  }

  /// Daily rent passive yield if property is placed on rent
  double get dailyRentIncome {
    if (isRented && currentTenant != null) {
      return currentTenant!.dailyRent;
    }
    return (estimatedRealValue * category.dailyRentYieldRate).roundToDouble();
  }

  /// Zeigarnik effect renovation progress fraction (0.0 to 1.0)
  double get renovationProgress {
    if (isRenovated || renovationStage >= 3) return 1.0;
    if (renovationStage == 2) return 0.70;
    if (renovationStage == 1) return 0.35;
    return 0.0;
  }

  int get renovationPercent => (renovationProgress * 100).round();

  bool get isUnderRenovation =>
      !isRenovated &&
      ((renovationStage > 0 && renovationStage < 3) ||
          renovationDaysRemaining > 0);

  /// Arsa inşaat durumu hesaplanan özellikleri (8 Aşamalı Döngü)
  bool get isConstructionActive =>
      constructionMode != null || (constructionStage > 0 && constructionStage <= 8);
  double get constructionProgress => (constructionStage / 8.0).clamp(0.0, 1.0);
  int get constructionPercent => (constructionProgress * 100).round();

  /// Şantiye tamamen bitti mi (Etap 8 tamamlandı ve gün 0)
  bool get isConstructionComplete =>
      category == RealEstateCategory.land &&
      isConstructionActive &&
      constructionStage >= 8 &&
      constructionDaysRemaining <= 0 &&
      !isConstructionWorking;

  /// Durum makinesi fazı (Tek birincil buton mimarisi • E0)
  LandPhase get landPhase {
    if (category != RealEstateCategory.land) return LandPhase.tamamlandi;
    if (isConstructionComplete) return LandPhase.teslimeHazir;
    if (!isConstructionActive) {
      if (customUnitMix == null) return LandPhase.imar;
      return LandPhase.modSecimi;
    }
    if (constructionMode == 'contractor') {
      return LandPhase.muteahhitBekleme;
    }
    if (constructionMode == 'selfBuild') {
      if (isConstructionWorking) return LandPhase.etapCalisiyor;
      if (constructionDaysRemaining == 0 &&
          constructionStage > 1 &&
          constructionStage <= 8 &&
          activeSubcontractorName != null &&
          activeSubcontractorName!.isNotEmpty) {
        return LandPhase.etapTeslimAlinir;
      }
      return LandPhase.etapHazir;
    }
    return LandPhase.modSecimi;
  }

  int get totalProjectUnits {
    if (customUnitMix != null) {
      final u0 = (customUnitMix!['units1Plus0'] as num?)?.toInt() ?? 0;
      final u1 = (customUnitMix!['units1Plus1'] as num?)?.toInt() ?? 0;
      final u2_0 = (customUnitMix!['units2Plus0'] as num?)?.toInt() ?? 0;
      final u2 = (customUnitMix!['units2Plus1'] as num?)?.toInt() ?? 0;
      final u3 = (customUnitMix!['units3Plus1'] as num?)?.toInt() ?? 0;
      final u4 = (customUnitMix!['units4Plus1'] as num?)?.toInt() ?? 0;
      final sum = u0 + u1 + u2_0 + u2 + u3 + u4;
      if (sum > 0) return sum;
    }
    if (_totalProjectUnits > 0) return _totalProjectUnits;
    if (category != RealEstateCategory.land) return 0;
    if (squareMeters >= 800) return 8;
    if (squareMeters >= 500) return 6;
    return 4;
  }

  int get playerShareUnits {
    if (totalProjectUnits <= 0) return 0;
    final totalShare = (totalProjectUnits * playerSharePercent ~/ 100);
    return (totalShare - soldPreSaleUnits).clamp(0, totalProjectUnits);
  }

  bool get canPreSell =>
      isConstructionActive &&
      constructionMode == 'selfBuild' &&
      constructionStage >= 2 &&
      constructionStage <= 7 &&
      playerShareUnits > 1;

  double get preSaleDiscountRate => switch (constructionStage) {
    <= 2 => 0.65, // Temel ve hafriyat aşaması en riskli
    3 => 0.70,
    4 => 0.75,
    5 => 0.80,
    6 => 0.85,
    7 => 0.92, // İnce işler bitmek üzere, neredeyse anahtar teslim
    _ => 1.00,
  };

  double get preSaleUnitPrice {
    if (totalProjectUnits <= 0) return 0.0;
    // F1·6: Etaba göre kademeli ön satış iskontosu (Risk azaldıkça fiyat artar)
    return ((baseMarketValue * 2.2 / totalProjectUnits) * preSaleDiscountRate).roundToDouble();
  }

  double get turnkeyUnitPrice => totalProjectUnits > 0
      ? (baseMarketValue * 2.5 / totalProjectUnits).roundToDouble()
      : 0.0;

  /// Whether property can be leased out to tenants (empty land / arsa cannot be rented as residential/commercial property)
  bool get canBeRented =>
      category != RealEstateCategory.land &&
      !isPersonalResidence &&
      !isUnderRenovation &&
      !isConstructionActive &&
      !isListed;

  /// Returns localization key for why this property cannot be rented out
  String? get rentalIneligibilityReasonKey {
    if (category == RealEstateCategory.land) {
      return 'rental_ineligible_land';
    }
    if (isConstructionActive || (constructionStage > 0 && constructionStage < 8)) {
      return 'rental_ineligible_construction';
    }
    if (isPersonalResidence) {
      return 'rental_ineligible_residence';
    }
    if (isUnderRenovation) {
      return 'rental_ineligible_renovation';
    }
    if (isListed) {
      return 'rental_ineligible_for_sale';
    }
    return null;
  }

  /// Returns detailed localization key explaining the algorithmic reason
  String? get rentalIneligibilityDescKey {
    if (category == RealEstateCategory.land) {
      return 'rental_ineligible_land_desc';
    }
    if (isConstructionActive || (constructionStage > 0 && constructionStage < 8)) {
      return 'rental_ineligible_construction_desc';
    }
    if (isPersonalResidence) {
      return 'rental_ineligible_residence_desc';
    }
    if (isUnderRenovation) {
      return 'rental_ineligible_renovation_desc';
    }
    if (isListed) {
      return 'rental_ineligible_for_sale_desc';
    }
    return null;
  }

  /// Whether property can be sold or listed on the market (F2·6: İpotekli mülk satılamaz)
  bool get canBeSold =>
      !isRented &&
      !isPersonalResidence &&
      !isUnderRenovation &&
      !isConstructionActive &&
      !isRentalListed &&
      !isMortgaged;

  /// Whether property can be set as personal residence (strictly housing category only)
  bool get canBePersonalResidence =>
      category == RealEstateCategory.housing &&
      !isRented &&
      !isUnderRenovation &&
      !isConstructionActive &&
      !isListed &&
      !isRentalListed;

  /// Prestige bonus granted when used as personal residence
  int get personalResidencePrestigeBonus {
    switch (category) {
      case RealEstateCategory.housing:
        return 15;
      case RealEstateCategory.commercial:
        return 10;
      case RealEstateCategory.building:
        return 25;
      case RealEstateCategory.housingProjects:
        return 20;
      case RealEstateCategory.timeshare:
        return 5;
      case RealEstateCategory.tourismFacility:
        return 40;
      case RealEstateCategory.land:
        return 5;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category.name,
      'city': city,
      'district': district,
      'squareMeters': squareMeters,
      'roomCount': roomCount,
      'buildingAge': buildingAge,
      'deedType': deedType.name,
      'sellerType': sellerType.name,
      'baseMarketValue': baseMarketValue,
      'currentPurchasePrice': currentPurchasePrice,
      'deedFeePaid': deedFeePaid,
      'commissionPaid': commissionPaid,
      'isRenovated': isRenovated,
      'isRented': isRented,
      'provenanceLog': provenanceLog,
      'isListed': isListed,
      'customListingPrice': customListingPrice,
      'daysListed': daysListed,
      'renovationStage': renovationStage,
      'renovationDaysRemaining': renovationDaysRemaining,
      'isRushedRenovation': isRushedRenovation,
      'hasWaterLeakRisk': hasWaterLeakRisk,
      'pendingRentIncome': pendingRentIncome,
      'uncollectedRentDays': uncollectedRentDays,
      'isPersonalResidence': isPersonalResidence,
      'constructionStage': constructionStage,
      'constructionMode': constructionMode,
      'playerSharePercent': playerSharePercent,
      'contractorSharePercent': 100 - playerSharePercent,
      'totalConstructionSpent': totalConstructionSpent,
      'hasPrimeFloorClause': hasPrimeFloorClause,
      'hasQualityUpgrade': hasQualityUpgrade,
      'contractorAdvancePaid': contractorAdvancePaid,
      'hasBankGuarantee': hasBankGuarantee,
      'contractorStageDays': contractorStageDays,
      'totalProjectUnits': totalProjectUnits,
      'soldPreSaleUnits': soldPreSaleUnits,
      'constructionDaysRemaining': constructionDaysRemaining,
      'isConstructionWorking': isConstructionWorking,
      'activeSubcontractorName': activeSubcontractorName,
      'stageTotalDays': stageTotalDays,
      'activeOffers': activeOffers.map((e) => e.toJson()).toList(),
      'currentTenant': currentTenant?.toJson(),
      'isRentalListed': isRentalListed,
      'customUnitMix': customUnitMix,
      'listingHeadline': listingHeadline,
      'listingDescription': listingDescription,
      'listingFeatures': listingFeatures,
      'listingPackage': listingPackage,
      'qualityScore': qualityScore,
      'isMortgaged': isMortgaged,
    };
  }

  factory RealEstateModel.fromJson(Map<String, dynamic> json) {
    final isRenovatedVal = json['isRenovated'] as bool? ?? false;
    final stageVal = json['renovationStage'] as int? ?? (isRenovatedVal ? 3 : 0);

    return RealEstateModel(
      id: json['id'] as String? ?? 're_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Gayrimenkul',
      category: RealEstateCategoryExtension.fromString(json['category'] as String?),
      city: json['city'] as String? ?? 'İstanbul',
      district: json['district'] as String? ?? 'Kadıköy',
      squareMeters: json['squareMeters'] as int? ?? 120,
      roomCount: json['roomCount'] as String? ?? '3+1',
      buildingAge: json['buildingAge'] as int? ?? 5,
      deedType: DeedType.values.firstWhere(
        (e) => e.name == json['deedType'],
        orElse: () => DeedType.ownershipDeed,
      ),
      sellerType: RealEstateSellerType.values.firstWhere(
        (e) => e.name == json['sellerType'],
        orElse: () => RealEstateSellerType.individual,
      ),
      baseMarketValue: (json['baseMarketValue'] as num?)?.toDouble() ?? 2500000.0,
      currentPurchasePrice: (json['currentPurchasePrice'] as num?)?.toDouble() ?? 2500000.0,
      deedFeePaid: (json['deedFeePaid'] as num?)?.toDouble() ?? 0.0,
      commissionPaid: (json['commissionPaid'] as num?)?.toDouble() ?? 0.0,
      isRenovated: isRenovatedVal || stageVal >= 3,
      isRented: json['isRented'] as bool? ?? false,
      provenanceLog: (json['provenanceLog'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isListed: json['isListed'] as bool? ?? false,
      customListingPrice: (json['customListingPrice'] as num?)?.toDouble(),
      daysListed: json['daysListed'] as int? ?? 0,
      renovationStage: stageVal,
      renovationDaysRemaining: json['renovationDaysRemaining'] as int? ?? 0,
      isRushedRenovation: json['isRushedRenovation'] as bool? ?? false,
      hasWaterLeakRisk: json['hasWaterLeakRisk'] as bool? ?? false,
      pendingRentIncome: (json['pendingRentIncome'] as num?)?.toDouble() ?? 0.0,
      uncollectedRentDays: json['uncollectedRentDays'] as int? ?? 0,
      isPersonalResidence: json['isPersonalResidence'] as bool? ?? false,
      constructionStage: json['constructionStage'] as int? ?? 0,
      constructionMode: json['constructionMode'] as String?,
      playerSharePercent: json['playerSharePercent'] as int? ??
          (json['contractorSharePercent'] != null
              ? (100 - (json['contractorSharePercent'] as num).toInt()).clamp(0, 100)
              : 50),
      totalConstructionSpent: (json['totalConstructionSpent'] as num?)?.toDouble() ?? 0.0,
      hasPrimeFloorClause: json['hasPrimeFloorClause'] as bool? ?? false,
      hasQualityUpgrade: json['hasQualityUpgrade'] as bool? ?? false,
      contractorAdvancePaid: (json['contractorAdvancePaid'] as num?)?.toDouble() ?? 0.0,
      hasBankGuarantee: json['hasBankGuarantee'] as bool? ?? false,
      contractorStageDays: json['contractorStageDays'] as int? ?? 15,
      totalProjectUnits: json['totalProjectUnits'] as int? ?? 0,
      soldPreSaleUnits: json['soldPreSaleUnits'] as int? ?? 0,
      constructionDaysRemaining: json['constructionDaysRemaining'] as int? ?? 0,
      isConstructionWorking: json['isConstructionWorking'] as bool? ?? false,
      activeSubcontractorName: json['activeSubcontractorName'] as String?,
      stageTotalDays: json['stageTotalDays'] as int? ?? 0,
      activeOffers: (json['activeOffers'] as List<dynamic>?)
              ?.map((e) => RealEstateOfferModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentTenant: json['currentTenant'] != null
          ? TenantModel.fromJson(json['currentTenant'] as Map<String, dynamic>)
          : null,
      isRentalListed: json['isRentalListed'] as bool? ?? false,
      customUnitMix: json['customUnitMix'] as Map<String, dynamic>?,
      listingHeadline: json['listingHeadline'] as String?,
      listingDescription: json['listingDescription'] as String?,
      listingFeatures: (json['listingFeatures'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      listingPackage: json['listingPackage'] as String? ?? 'standard',
      qualityScore: (json['qualityScore'] as num?)?.toDouble() ?? 75.0,
      isMortgaged: json['isMortgaged'] as bool? ?? false,
    );
  }

  RealEstateModel copyWith({
    String? id,
    String? title,
    RealEstateCategory? category,
    String? city,
    String? district,
    int? squareMeters,
    String? roomCount,
    int? buildingAge,
    DeedType? deedType,
    RealEstateSellerType? sellerType,
    double? baseMarketValue,
    double? currentPurchasePrice,
    double? deedFeePaid,
    double? commissionPaid,
    bool? isRenovated,
    bool? isRented,
    List<String>? provenanceLog,
    bool? isListed,
    double? customListingPrice,
    int? daysListed,
    int? renovationStage,
    int? renovationDaysRemaining,
    bool? isRushedRenovation,
    bool? hasWaterLeakRisk,
    double? pendingRentIncome,
    int? uncollectedRentDays,
    bool? isPersonalResidence,
    int? constructionStage,
    String? constructionMode,
    bool clearConstructionMode = false,
    int? playerSharePercent,
    int? contractorSharePercent,
    double? totalConstructionSpent,
    bool? hasPrimeFloorClause,
    bool? hasQualityUpgrade,
    double? contractorAdvancePaid,
    bool? hasBankGuarantee,
    int? contractorStageDays,
    int? totalProjectUnits,
    int? soldPreSaleUnits,
    int? constructionDaysRemaining,
    bool? isConstructionWorking,
    String? activeSubcontractorName,
    int? stageTotalDays,
    List<RealEstateOfferModel>? activeOffers,
    TenantModel? currentTenant,
    bool? isRentalListed,
    Map<String, dynamic>? customUnitMix,
    bool clearCustomPrice = false,
    bool clearCurrentTenant = false,
    bool clearActiveSubcontractor = false,
    bool clearCustomUnitMix = false,
    String? listingHeadline,
    String? listingDescription,
    List<String>? listingFeatures,
    String? listingPackage,
    double? qualityScore,
    bool? isMortgaged,
  }) {
    final nextRenovationStage = renovationStage ?? this.renovationStage;
    final nextIsRenovated = isRenovated ?? (nextRenovationStage >= 3 || this.isRenovated);

    return RealEstateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      city: city ?? this.city,
      district: district ?? this.district,
      squareMeters: squareMeters ?? this.squareMeters,
      roomCount: roomCount ?? this.roomCount,
      buildingAge: buildingAge ?? this.buildingAge,
      deedType: deedType ?? this.deedType,
      sellerType: sellerType ?? this.sellerType,
      baseMarketValue: baseMarketValue ?? this.baseMarketValue,
      currentPurchasePrice: currentPurchasePrice ?? this.currentPurchasePrice,
      deedFeePaid: deedFeePaid ?? this.deedFeePaid,
      commissionPaid: commissionPaid ?? this.commissionPaid,
      isRenovated: nextIsRenovated,
      isRented: isRented ?? this.isRented,
      provenanceLog: provenanceLog ?? this.provenanceLog,
      isListed: isListed ?? this.isListed,
      customListingPrice: clearCustomPrice ? null : (customListingPrice ?? this.customListingPrice),
      daysListed: daysListed ?? this.daysListed,
      renovationStage: nextRenovationStage,
      renovationDaysRemaining: renovationDaysRemaining ?? this.renovationDaysRemaining,
      isRushedRenovation: isRushedRenovation ?? this.isRushedRenovation,
      hasWaterLeakRisk: hasWaterLeakRisk ?? this.hasWaterLeakRisk,
      pendingRentIncome: pendingRentIncome ?? this.pendingRentIncome,
      uncollectedRentDays: uncollectedRentDays ?? this.uncollectedRentDays,
      isPersonalResidence: isPersonalResidence ?? this.isPersonalResidence,
      constructionStage: constructionStage ?? this.constructionStage,
      constructionMode: clearConstructionMode ? null : (constructionMode ?? this.constructionMode),
      playerSharePercent: playerSharePercent ??
          (contractorSharePercent != null
              ? 100 - contractorSharePercent
              : this.playerSharePercent),
      totalConstructionSpent: totalConstructionSpent ?? this.totalConstructionSpent,
      hasPrimeFloorClause: hasPrimeFloorClause ?? this.hasPrimeFloorClause,
      hasQualityUpgrade: hasQualityUpgrade ?? this.hasQualityUpgrade,
      contractorAdvancePaid: contractorAdvancePaid ?? this.contractorAdvancePaid,
      hasBankGuarantee: hasBankGuarantee ?? this.hasBankGuarantee,
      contractorStageDays: contractorStageDays ?? this.contractorStageDays,
      totalProjectUnits: totalProjectUnits ?? this.totalProjectUnits,
      soldPreSaleUnits: soldPreSaleUnits ?? this.soldPreSaleUnits,
      constructionDaysRemaining: constructionDaysRemaining ?? this.constructionDaysRemaining,
      isConstructionWorking: isConstructionWorking ?? this.isConstructionWorking,
      activeSubcontractorName: clearActiveSubcontractor
          ? null
          : (activeSubcontractorName ?? this.activeSubcontractorName),
      stageTotalDays: stageTotalDays ?? this.stageTotalDays,
      activeOffers: activeOffers ?? this.activeOffers,
      currentTenant: clearCurrentTenant ? null : (currentTenant ?? this.currentTenant),
      isRentalListed: isRentalListed ?? this.isRentalListed,
      customUnitMix: clearCustomUnitMix ? null : (customUnitMix ?? this.customUnitMix),
      listingHeadline: listingHeadline ?? this.listingHeadline,
      listingDescription: listingDescription ?? this.listingDescription,
      listingFeatures: listingFeatures ?? this.listingFeatures,
      listingPackage: listingPackage ?? this.listingPackage,
      qualityScore: qualityScore ?? this.qualityScore,
      isMortgaged: isMortgaged ?? this.isMortgaged,
    );
  }
}

class RealEstateListingModel {
  final String id;
  final RealEstateModel realEstate;
  final double askingPrice;
  final String sellerName;
  final String? sellerAgencyName;
  final String sellerTrait;
  final String description;
  final bool isHotDeal;
  final String? discrepancyKey;

  const RealEstateListingModel({
    required this.id,
    required this.realEstate,
    required this.askingPrice,
    required this.sellerName,
    this.sellerAgencyName,
    required this.sellerTrait,
    required this.description,
    this.isHotDeal = false,
    this.discrepancyKey,
  });

  /// Tapu harcı (%4)
  double get estimatedDeedFee => (askingPrice * 0.04).roundToDouble();

  /// Sabit döner sermaye bedeli
  static const double revolvingFundFee = 2500.0;

  /// Emlakçı komisyonu (Emlak ofisi ise %2, değilse 0)
  double get estimatedCommission =>
      realEstate.sellerType == RealEstateSellerType.agency
          ? (askingPrice * 0.02).roundToDouble()
          : 0.0;

  /// Toplam alım maliyeti
  double get totalAcquisitionCost =>
      askingPrice + estimatedDeedFee + revolvingFundFee + estimatedCommission;
}
