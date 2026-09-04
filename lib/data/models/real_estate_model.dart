import 'real_estate_category.dart';

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
  });

  /// Dynamic fair market value accounting for deed status and renovations
  double get estimatedRealValue {
    double value = baseMarketValue * deedType.valueMultiplier;
    if (isRenovated) {
      value *= 1.15; // +%15 flipping tadilat primi
    }
    return value.roundToDouble();
  }

  /// Daily rent passive yield if property is placed on rent
  double get dailyRentIncome {
    return (estimatedRealValue * category.dailyRentYieldRate).roundToDouble();
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
    };
  }

  factory RealEstateModel.fromJson(Map<String, dynamic> json) {
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
      isRenovated: json['isRenovated'] as bool? ?? false,
      isRented: json['isRented'] as bool? ?? false,
      provenanceLog: (json['provenanceLog'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isListed: json['isListed'] as bool? ?? false,
      customListingPrice: (json['customListingPrice'] as num?)?.toDouble(),
      daysListed: json['daysListed'] as int? ?? 0,
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
    bool clearCustomPrice = false,
  }) {
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
      isRenovated: isRenovated ?? this.isRenovated,
      isRented: isRented ?? this.isRented,
      provenanceLog: provenanceLog ?? this.provenanceLog,
      isListed: isListed ?? this.isListed,
      customListingPrice: clearCustomPrice ? null : (customListingPrice ?? this.customListingPrice),
      daysListed: daysListed ?? this.daysListed,
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
