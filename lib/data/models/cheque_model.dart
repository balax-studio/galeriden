class Cheque {
  final String id;
  final String customerName;
  final double amount;
  final int daysUntilDue;
  final bool isDefaulted;
  final bool isFactored;
  final double factoringFee;
  final bool inLegalCollection;
  final int legalCollectionDaysRemaining;
  final double legalRecoveredAmount;

  Cheque({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.daysUntilDue,
    this.isDefaulted = false,
    this.isFactored = false,
    this.factoringFee = 0.0,
    this.inLegalCollection = false,
    this.legalCollectionDaysRemaining = 0,
    this.legalRecoveredAmount = 0.0,
  });

  /// Calculate net upfront cash if factored / discounted early
  double calculateFactoringCash({double discountRate = 0.08}) =>
      amount * (1.0 - discountRate);

  /// Calculate factoring fee / discount deduction
  double calculateFactoringDiscount({double discountRate = 0.08}) =>
      amount * discountRate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'amount': amount,
        'daysUntilDue': daysUntilDue,
        'isDefaulted': isDefaulted,
        'isFactored': isFactored,
        'factoringFee': factoringFee,
        'inLegalCollection': inLegalCollection,
        'legalCollectionDaysRemaining': legalCollectionDaysRemaining,
        'legalRecoveredAmount': legalRecoveredAmount,
      };

  String get carModelName => 'Çekli Satış • $customerName';
  int get dueDay => daysUntilDue;
  int get dueDays => daysUntilDue;

  factory Cheque.fromJson(Map<String, dynamic> json) => Cheque(
        id: json['id'] as String? ?? 'chq_${DateTime.now().millisecondsSinceEpoch}',
        customerName: json['customerName'] as String? ?? 'Müşteri',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        daysUntilDue: json['daysUntilDue'] as int? ?? 0,
        isDefaulted: json['isDefaulted'] as bool? ?? false,
        isFactored: json['isFactored'] as bool? ?? false,
        factoringFee: (json['factoringFee'] as num?)?.toDouble() ?? 0.0,
        inLegalCollection: json['inLegalCollection'] as bool? ?? false,
        legalCollectionDaysRemaining: json['legalCollectionDaysRemaining'] as int? ?? 0,
        legalRecoveredAmount: (json['legalRecoveredAmount'] as num?)?.toDouble() ?? 0.0,
      );

  Cheque copyWith({
    String? id,
    String? customerName,
    double? amount,
    int? daysUntilDue,
    bool? isDefaulted,
    bool? isFactored,
    double? factoringFee,
    bool? inLegalCollection,
    int? legalCollectionDaysRemaining,
    double? legalRecoveredAmount,
  }) {
    return Cheque(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      amount: amount ?? this.amount,
      daysUntilDue: daysUntilDue ?? this.daysUntilDue,
      isDefaulted: isDefaulted ?? this.isDefaulted,
      isFactored: isFactored ?? this.isFactored,
      factoringFee: factoringFee ?? this.factoringFee,
      inLegalCollection: inLegalCollection ?? this.inLegalCollection,
      legalCollectionDaysRemaining:
          legalCollectionDaysRemaining ?? this.legalCollectionDaysRemaining,
      legalRecoveredAmount: legalRecoveredAmount ?? this.legalRecoveredAmount,
    );
  }
}
