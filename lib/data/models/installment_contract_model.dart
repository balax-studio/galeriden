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

  factory InstallmentContract.fromJson(Map<String, dynamic> json) => InstallmentContract(
    id: json['id'] as String,
    customerName: json['customerName'] as String,
    totalAmount: (json['totalAmount'] as num).toDouble(),
    paidAmount: (json['paidAmount'] as num).toDouble(),
    installmentAmount: (json['installmentAmount'] as num).toDouble(),
    totalInstallments: json['totalInstallments'] as int,
    paidInstallments: json['paidInstallments'] as int,
    daysUntilNextPayment: json['daysUntilNextPayment'] as int,
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
