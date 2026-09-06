import 'customer_model.dart';

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
  final int expiresOnDay;
  final OfferType offerType;
  final int customerCreditScore; // 0 - 100
  final int installmentMonths;    // e.g. 6 or 12
  final CustomerModel? buyerCustomer;
  final bool requestedTestDrive;
  final String? testDriveResult;
  final String? counterStrategy;

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
    this.expiresOnDay = 0,
    this.offerType = OfferType.cash,
    this.customerCreditScore = 85,
    this.installmentMonths = 0,
    this.buyerCustomer,
    this.requestedTestDrive = false,
    this.testDriveResult,
    this.counterStrategy,
  }) : expiresAt = expiresAt ?? createdAt.add(const Duration(hours: 12));

  bool get isExpired => (expiresOnDay > 0) ? false : DateTime.now().isAfter(expiresAt);
  bool isExpiredForDay(int currentDay) => (expiresOnDay > 0) ? (currentDay > expiresOnDay) : DateTime.now().isAfter(expiresAt);
  int remainingDays(int currentDay) => (expiresOnDay > currentDay) ? (expiresOnDay - currentDay) : 0;

  /// Credit Risk Level: safe (80+), moderate (50-79), risky (30-49), severe (<30)
  String get riskLevel {
    if (customerCreditScore >= 80) return 'Düşük Risk';
    if (customerCreditScore >= 50) return 'Orta Risk';
    if (customerCreditScore >= 30) return 'Yüksek Risk';
    return 'Batık / Çok Riskli';
  }

  /// Payment Guarantee Probability based on credit score
  double get paymentProbability {
    if (customerCreditScore >= 80) return 0.95;
    if (customerCreditScore >= 50) return 0.70;
    if (customerCreditScore >= 30) return 0.40;
    return 0.15;
  }

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
      'expiresOnDay': expiresOnDay,
      'offerType': offerType.name,
      'customerCreditScore': customerCreditScore,
      'installmentMonths': installmentMonths,
      'buyerCustomer': buyerCustomer?.toJson(),
      'requestedTestDrive': requestedTestDrive,
      'testDriveResult': testDriveResult,
      'counterStrategy': counterStrategy,
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
      expiresOnDay: json['expiresOnDay'] as int? ?? 0,
      offerType: OfferType.values.firstWhere(
        (e) => e.name == json['offerType'],
        orElse: () => OfferType.cash,
      ),
      customerCreditScore: json['customerCreditScore'] as int? ?? 85,
      installmentMonths: json['installmentMonths'] as int? ?? 0,
      buyerCustomer: json['buyerCustomer'] != null
          ? CustomerModel.fromJson(Map<String, dynamic>.from(json['buyerCustomer'] as Map))
          : null,
      requestedTestDrive: json['requestedTestDrive'] as bool? ?? false,
      testDriveResult: json['testDriveResult'] as String?,
      counterStrategy: json['counterStrategy'] as String?,
    );
  }

  OfferModel copyWith({
    OfferStatus? status,
    double? offeredAmount,
    String? buyerMessage,
    int? counterCount,
    DateTime? expiresAt,
    int? expiresOnDay,
    OfferType? offerType,
    int? customerCreditScore,
    int? installmentMonths,
    CustomerModel? buyerCustomer,
    bool? requestedTestDrive,
    String? testDriveResult,
    String? counterStrategy,
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
      expiresOnDay: expiresOnDay ?? this.expiresOnDay,
      offerType: offerType ?? this.offerType,
      customerCreditScore: customerCreditScore ?? this.customerCreditScore,
      installmentMonths: installmentMonths ?? this.installmentMonths,
      buyerCustomer: buyerCustomer ?? this.buyerCustomer,
      requestedTestDrive: requestedTestDrive ?? this.requestedTestDrive,
      testDriveResult: testDriveResult ?? this.testDriveResult,
      counterStrategy: counterStrategy ?? this.counterStrategy,
    );
  }
}
