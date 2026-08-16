import 'car_model.dart';

class TradeInOfferModel {
  final String id;
  final String customerName;
  final String targetCarId;
  final String targetCarName;
  final CarModel offeredCar;
  final double cashDifference; // Positive: Customer pays extra cash; Negative: Player must pay cash
  final String dialogueText;
  final int inGameDay;
  final int expiresInDays;
  final bool isAccepted;
  final bool isExpired;

  String get dialogText => dialogueText;

  TradeInOfferModel({
    required this.id,
    required this.customerName,
    required this.targetCarId,
    required this.targetCarName,
    required this.offeredCar,
    required this.cashDifference,
    String? dialogueText,
    String? dialogText,
    this.inGameDay = 1,
    this.expiresInDays = 3,
    this.isAccepted = false,
    this.isExpired = false,
  }) : dialogueText = dialogueText ?? dialogText ?? 'Mantıklı takasa açığım usta.';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'targetCarId': targetCarId,
      'targetCarName': targetCarName,
      'offeredCar': offeredCar.toJson(),
      'cashDifference': cashDifference,
      'dialogueText': dialogueText,
      'inGameDay': inGameDay,
      'expiresInDays': expiresInDays,
      'isAccepted': isAccepted,
      'isExpired': isExpired,
    };
  }

  factory TradeInOfferModel.fromJson(Map<String, dynamic> json) {
    return TradeInOfferModel(
      id: json['id'] as String? ?? 'trade_${DateTime.now().millisecondsSinceEpoch}',
      customerName: json['customerName'] as String? ?? 'Müşteri',
      targetCarId: json['targetCarId'] as String? ?? '',
      targetCarName: json['targetCarName'] as String? ?? 'Vitrin Aracı',
      offeredCar: CarModel.fromJson(json['offeredCar'] as Map<String, dynamic>),
      cashDifference: (json['cashDifference'] as num?)?.toDouble() ?? 0.0,
      dialogueText: json['dialogueText'] as String? ?? json['dialogText'] as String? ?? 'Mantıklı takasa açığım usta.',
      inGameDay: json['inGameDay'] as int? ?? 1,
      expiresInDays: json['expiresInDays'] as int? ?? 3,
      isAccepted: json['isAccepted'] as bool? ?? false,
      isExpired: json['isExpired'] as bool? ?? false,
    );
  }

  TradeInOfferModel copyWith({
    String? id,
    String? customerName,
    String? targetCarId,
    String? targetCarName,
    CarModel? offeredCar,
    double? cashDifference,
    String? dialogueText,
    int? inGameDay,
    int? expiresInDays,
    bool? isAccepted,
    bool? isExpired,
  }) {
    return TradeInOfferModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      targetCarId: targetCarId ?? this.targetCarId,
      targetCarName: targetCarName ?? this.targetCarName,
      offeredCar: offeredCar ?? this.offeredCar,
      cashDifference: cashDifference ?? this.cashDifference,
      dialogueText: dialogueText ?? this.dialogueText,
      inGameDay: inGameDay ?? this.inGameDay,
      expiresInDays: expiresInDays ?? this.expiresInDays,
      isAccepted: isAccepted ?? this.isAccepted,
      isExpired: isExpired ?? this.isExpired,
    );
  }
}
