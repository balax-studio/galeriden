enum OfferStatus { pending, accepted, rejected, countered, expired }
enum OfferType { cash, installment, cheque }

class OfferModel {
  final String id;
  final String carId;
  final String buyerName;
  final double offeredAmount;
  final String buyerMessage;
  final OfferStatus status;
  final DateTime createdAt;
  final int counterCount;
  final int maxCounters;
  final DateTime expiresAt;
  final OfferType offerType;

  OfferModel({
    required this.id,
    required this.carId,
    required this.buyerName,
    required this.offeredAmount,
    required this.buyerMessage,
    this.status = OfferStatus.pending,
    required this.createdAt,
    this.counterCount = 0,
    this.maxCounters = 3,
    DateTime? expiresAt,
    this.offerType = OfferType.cash,
  }) : expiresAt = expiresAt ?? createdAt.add(const Duration(hours: 12));

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'buyerName': buyerName,
      'offeredAmount': offeredAmount,
      'buyerMessage': buyerMessage,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'counterCount': counterCount,
      'maxCounters': maxCounters,
      'expiresAt': expiresAt.toIso8601String(),
      'offerType': offerType.name,
    };
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now();
    return OfferModel(
      id: json['id'] as String? ?? 'offer_${DateTime.now().millisecondsSinceEpoch}',
      carId: json['carId'] as String? ?? '',
      buyerName: json['buyerName'] as String? ?? 'Teklif Sahibi',
      offeredAmount: (json['offeredAmount'] as num?)?.toDouble() ?? 0.0,
      buyerMessage: json['buyerMessage'] as String? ?? '',
      status: OfferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OfferStatus.pending,
      ),
      createdAt: created,
      counterCount: json['counterCount'] as int? ?? 0,
      maxCounters: json['maxCounters'] as int? ?? 3,
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ?? created.add(const Duration(hours: 12)),
      offerType: OfferType.values.firstWhere(
        (e) => e.name == json['offerType'],
        orElse: () => OfferType.cash,
      ),
    );
  }

  OfferModel copyWith({
    OfferStatus? status,
    double? offeredAmount,
    String? buyerMessage,
    int? counterCount,
    DateTime? expiresAt,
    OfferType? offerType,
  }) {
    return OfferModel(
      id: id,
      carId: carId,
      buyerName: buyerName,
      offeredAmount: offeredAmount ?? this.offeredAmount,
      buyerMessage: buyerMessage ?? this.buyerMessage,
      status: status ?? this.status,
      createdAt: createdAt,
      counterCount: counterCount ?? this.counterCount,
      maxCounters: maxCounters,
      expiresAt: expiresAt ?? this.expiresAt,
      offerType: offerType ?? this.offerType,
    );
  }
}
