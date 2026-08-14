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
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'totalAmount': totalAmount,
    'paidAmount': paidAmount,
    'installmentAmount': installmentAmount,
    'totalInstallments': totalInstallments,
    'paidInstallments': paidInstallments,
    'daysUntilNextPayment': daysUntilNextPayment,
    'isDefaulted': isDefaulted
  };

  String get carModelName => 'Taksitli Satış ($customerName)';
  int get nextPaymentDay => daysUntilNextPayment;

  factory InstallmentContract.fromJson(Map<String, dynamic> json) => InstallmentContract(
    id: json['id'] as String? ?? 'inst_${DateTime.now().millisecondsSinceEpoch}',
    customerName: json['customerName'] as String? ?? 'Müşteri',
    totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
    installmentAmount: (json['installmentAmount'] as num?)?.toDouble() ?? 0.0,
    totalInstallments: json['totalInstallments'] as int? ?? 1,
    paidInstallments: json['paidInstallments'] as int? ?? 0,
    daysUntilNextPayment: json['daysUntilNextPayment'] as int? ?? 30,
    isDefaulted: json['isDefaulted'] as bool? ?? false,
  );
  
  InstallmentContract copyWith({
    double? paidAmount, 
    int? paidInstallments, 
    int? daysUntilNextPayment, 
    bool? isDefaulted
  }) {
      return InstallmentContract(
          id: id, 
          customerName: customerName, 
          totalAmount: totalAmount,
          paidAmount: paidAmount ?? this.paidAmount,
          installmentAmount: installmentAmount,
          totalInstallments: totalInstallments,
          paidInstallments: paidInstallments ?? this.paidInstallments,
          daysUntilNextPayment: daysUntilNextPayment ?? this.daysUntilNextPayment,
          isDefaulted: isDefaulted ?? this.isDefaulted,
      );
  }
}
