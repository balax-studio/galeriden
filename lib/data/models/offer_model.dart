enum OfferStatus { pending, accepted, rejected, countered }

class OfferModel {
  final String id;
  final String carId;
  final String buyerName;
  final double offeredAmount;
  final String buyerMessage;
  final OfferStatus status;
  final DateTime createdAt;

  OfferModel({
    required this.id,
    required this.carId,
    required this.buyerName,
    required this.offeredAmount,
    required this.buyerMessage,
    this.status = OfferStatus.pending,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'buyerName': buyerName,
      'offeredAmount': offeredAmount,
      'buyerMessage': buyerMessage,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String,
      carId: json['carId'] as String,
      buyerName: json['buyerName'] as String,
      offeredAmount: (json['offeredAmount'] as num).toDouble(),
      buyerMessage: json['buyerMessage'] as String,
      status: OfferStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OfferStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  OfferModel copyWith({OfferStatus? status, double? offeredAmount}) {
    return OfferModel(
      id: id,
      carId: carId,
      buyerName: buyerName,
      offeredAmount: offeredAmount ?? this.offeredAmount,
      buyerMessage: buyerMessage,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
