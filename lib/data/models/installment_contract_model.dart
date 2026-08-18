class InstallmentContract {
  final String id;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double installmentAmount;
  final int totalInstallments;
  final int paidInstallments;
  final int daysUntilNextPayment;
  final bool isDefaulted;
  final double lateFee;

  InstallmentContract({
    required this.id,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.installmentAmount,
    required this.totalInstallments,
    required this.paidInstallments,
    required this.daysUntilNextPayment,
    this.isDefaulted = false,
    this.lateFee = 0.0,
  });

  /// Total principal remaining plus any late penalty fees
  double get remainingAmount =>
      (totalAmount - paidAmount + lateFee).clamp(0.0, double.infinity);

  /// Net cash collected if customer settles all remaining installments early
  double calculateEarlySettlementCash({double discountRate = 0.05}) =>
      remainingAmount * (1.0 - discountRate);

  /// Early settlement discount amount given to customer
  double calculateEarlySettlementDiscount({double discountRate = 0.05}) =>
      remainingAmount * discountRate;

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerName': customerName,
        'totalAmount': totalAmount,
        'paidAmount': paidAmount,
        'installmentAmount': installmentAmount,
        'totalInstallments': totalInstallments,
        'paidInstallments': paidInstallments,
        'daysUntilNextPayment': daysUntilNextPayment,
        'isDefaulted': isDefaulted,
        'lateFee': lateFee,
      };

  String get carModelName => 'Taksitli Satış • $customerName';
  int get nextPaymentDay => daysUntilNextPayment;

  factory InstallmentContract.fromJson(Map<String, dynamic> json) =>
      InstallmentContract(
        id: json['id'] as String? ??
            'inst_${DateTime.now().millisecondsSinceEpoch}',
        customerName: json['customerName'] as String? ?? 'Müşteri',
        totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
        installmentAmount:
            (json['installmentAmount'] as num?)?.toDouble() ?? 0.0,
        totalInstallments: json['totalInstallments'] as int? ?? 1,
        paidInstallments: json['paidInstallments'] as int? ?? 0,
        daysUntilNextPayment: json['daysUntilNextPayment'] as int? ?? 30,
        isDefaulted: json['isDefaulted'] as bool? ?? false,
        lateFee: (json['lateFee'] as num?)?.toDouble() ?? 0.0,
      );

  InstallmentContract copyWith({
    String? id,
    String? customerName,
    double? totalAmount,
    double? paidAmount,
    double? installmentAmount,
    int? totalInstallments,
    int? paidInstallments,
    int? daysUntilNextPayment,
    bool? isDefaulted,
    double? lateFee,
  }) {
    return InstallmentContract(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      installmentAmount: installmentAmount ?? this.installmentAmount,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      daysUntilNextPayment: daysUntilNextPayment ?? this.daysUntilNextPayment,
      isDefaulted: isDefaulted ?? this.isDefaulted,
      lateFee: lateFee ?? this.lateFee,
    );
  }
}
