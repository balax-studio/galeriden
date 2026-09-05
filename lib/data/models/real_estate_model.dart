import 'real_estate_category.dart';
import 'real_estate_offer_model.dart';

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
  final int constructionStage; // 0: Başlanmadı, 1: Hafriyat %25, 2: Kaba İnşaat %50, 3: Çatı & Cephe %75, 4: Tamamlandı & İskanlı %100
  final String? constructionMode; // null, 'contractor' (Müteahhit Kat Karşılığı), 'selfBuild' (Öz-İnşaat)
  final int contractorSharePercent; // Müteahhit anlaşmasında 50, öz-inşaatta 0
  final int _totalProjectUnits; // Toplam daire adedi
  final int soldPreSaleUnits; // Topraktan satılmış daire adedi
  final int constructionDaysRemaining; // Mevcut şantiye etabına kalan gün
  final List<RealEstateOfferModel> activeOffers; // Vitrin teklif havuzu

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
    this.contractorSharePercent = 50,
    int totalProjectUnits = 0,
    this.soldPreSaleUnits = 0,
    this.constructionDaysRemaining = 0,
    this.activeOffers = const [],
  }) : _totalProjectUnits = totalProjectUnits;

  /// Dynamic fair market value accounting for deed status, renovations, and defects
  double get estimatedRealValue {
    double value = baseMarketValue * deedType.valueMultiplier;
    if (isRenovated || renovationStage >= 3) {
      value *= 1.15; // +%15 flipping tadilat primi
    }
    if (hasWaterLeakRisk) {
      value *= 0.90; // -%10 gizli su kaçağı hasar kırımı
    }
    return value.roundToDouble();
  }

  /// Daily rent passive yield if property is placed on rent
  double get dailyRentIncome {
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

  /// Arsa inşaat durumu hesaplanan özellikleri (FAZ 4)
  bool get isConstructionActive => constructionMode != null;
  double get constructionProgress => (constructionStage / 4.0).clamp(0.0, 1.0);
  int get constructionPercent => (constructionProgress * 100).round();

  int get totalProjectUnits {
    if (_totalProjectUnits > 0) return _totalProjectUnits;
    if (category != RealEstateCategory.land) return 0;
    if (squareMeters >= 800) return 8;
    if (squareMeters >= 500) return 6;
    return 4;
  }

  int get playerShareUnits {
    if (totalProjectUnits <= 0) return 0;
    final totalShare = (totalProjectUnits * (100 - contractorSharePercent) ~/ 100);
    return (totalShare - soldPreSaleUnits).clamp(0, totalProjectUnits);
  }

  bool get canPreSell =>
      isConstructionActive &&
      constructionMode == 'selfBuild' &&
      constructionStage >= 1 &&
      constructionStage < 4 &&
      playerShareUnits > 1;

  double get preSaleUnitPrice => totalProjectUnits > 0
      ? ((baseMarketValue * 2.2 / totalProjectUnits) * 0.75).roundToDouble()
      : 0.0;

  double get turnkeyUnitPrice => totalProjectUnits > 0
      ? (baseMarketValue * 2.5 / totalProjectUnits).roundToDouble()
      : 0.0;

  /// Whether property can be leased out to tenants
  bool get canBeRented => !isPersonalResidence && !isUnderRenovation && !isConstructionActive;

  /// Whether property can be sold or listed on the market
  bool get canBeSold => !isRented && !isPersonalResidence && !isUnderRenovation && !isConstructionActive;

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
      'contractorSharePercent': contractorSharePercent,
      'totalProjectUnits': totalProjectUnits,
      'soldPreSaleUnits': soldPreSaleUnits,
      'constructionDaysRemaining': constructionDaysRemaining,
      'activeOffers': activeOffers.map((e) => e.toJson()).toList(),
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
      contractorSharePercent: json['contractorSharePercent'] as int? ?? 50,
      totalProjectUnits: json['totalProjectUnits'] as int? ?? 0,
      soldPreSaleUnits: json['soldPreSaleUnits'] as int? ?? 0,
      constructionDaysRemaining: json['constructionDaysRemaining'] as int? ?? 0,
      activeOffers: (json['activeOffers'] as List<dynamic>?)
              ?.map((e) => RealEstateOfferModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
    int? contractorSharePercent,
    int? totalProjectUnits,
    int? soldPreSaleUnits,
    int? constructionDaysRemaining,
    List<RealEstateOfferModel>? activeOffers,
    bool clearCustomPrice = false,
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
      constructionMode: constructionMode ?? this.constructionMode,
      contractorSharePercent: contractorSharePercent ?? this.contractorSharePercent,
      totalProjectUnits: totalProjectUnits ?? this.totalProjectUnits,
      soldPreSaleUnits: soldPreSaleUnits ?? this.soldPreSaleUnits,
      constructionDaysRemaining: constructionDaysRemaining ?? this.constructionDaysRemaining,
      activeOffers: activeOffers ?? this.activeOffers,
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
