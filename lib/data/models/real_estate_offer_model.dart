import 'tenant_model.dart';

class RealEstateOfferModel {
  final String id;
  final String realEstateId;
  final String buyerName;
  final String buyerNote;
  final double offeredAmount;
  final int daysRemaining;
  final DateTime createdAt;
  final bool isRentalOffer;
  final TenantModel? tenant;
  final double depositAmount;

  const RealEstateOfferModel({
    required this.id,
    required this.realEstateId,
    required this.buyerName,
    required this.buyerNote,
    required this.offeredAmount,
    this.daysRemaining = 3,
    required this.createdAt,
    this.isRentalOffer = false,
    this.tenant,
    this.depositAmount = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'realEstateId': realEstateId,
      'buyerName': buyerName,
      'buyerNote': buyerNote,
      'offeredAmount': offeredAmount,
      'daysRemaining': daysRemaining,
      'createdAt': createdAt.toIso8601String(),
      'isRentalOffer': isRentalOffer,
      'tenant': tenant?.toJson(),
      'depositAmount': depositAmount,
    };
  }

  factory RealEstateOfferModel.fromJson(Map<String, dynamic> json) {
    return RealEstateOfferModel(
      id: json['id'] as String? ?? 'offer_${DateTime.now().millisecondsSinceEpoch}',
      realEstateId: json['realEstateId'] as String? ?? '',
      buyerName: json['buyerName'] as String? ?? 'Alıcı Adayı',
      buyerNote: json['buyerNote'] as String? ?? 'Mülkünüzle ilgileniyorum.',
      offeredAmount: (json['offeredAmount'] as num?)?.toDouble() ?? 0.0,
      daysRemaining: json['daysRemaining'] as int? ?? 3,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isRentalOffer: json['isRentalOffer'] as bool? ?? false,
      tenant: json['tenant'] != null
          ? TenantModel.fromJson(json['tenant'] as Map<String, dynamic>)
          : null,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  RealEstateOfferModel copyWith({
    String? id,
    String? realEstateId,
    String? buyerName,
    String? buyerNote,
    double? offeredAmount,
    int? daysRemaining,
    DateTime? createdAt,
    bool? isRentalOffer,
    TenantModel? tenant,
    double? depositAmount,
  }) {
    return RealEstateOfferModel(
      id: id ?? this.id,
      realEstateId: realEstateId ?? this.realEstateId,
      buyerName: buyerName ?? this.buyerName,
      buyerNote: buyerNote ?? this.buyerNote,
      offeredAmount: offeredAmount ?? this.offeredAmount,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      createdAt: createdAt ?? this.createdAt,
      isRentalOffer: isRentalOffer ?? this.isRentalOffer,
      tenant: tenant ?? this.tenant,
      depositAmount: depositAmount ?? this.depositAmount,
    );
  }
}
