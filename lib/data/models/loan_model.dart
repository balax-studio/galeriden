class LoanModel {
  final String id;
  final String bankName;
  final double principalAmount; // Anapara
  final double interestRate; // Faiz oranı (ör: 0.15 = %15)
  final double totalRepayment; // Toplam Geri Ödeme
  final double remainingAmount; // Kalan Borç
  final int totalInstallments; // Taksit Sayısı (3, 6, 12)
  final int remainingInstallments; // Kalan Taksit
  final double monthlyPayment; // Aylık Taksit Tutar

  const LoanModel({
    required this.id,
    required this.bankName,
    required this.principalAmount,
    required this.interestRate,
    required this.totalRepayment,
    required this.remainingAmount,
    required this.totalInstallments,
    required this.remainingInstallments,
    required this.monthlyPayment,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'bankName': bankName,
        'principalAmount': principalAmount,
        'interestRate': interestRate,
        'totalRepayment': totalRepayment,
        'remainingAmount': remainingAmount,
        'totalInstallments': totalInstallments,
        'remainingInstallments': remainingInstallments,
        'monthlyPayment': monthlyPayment,
      };

  factory LoanModel.fromJson(Map<String, dynamic> json) => LoanModel(
        id: json['id'] as String? ?? 'loan_${DateTime.now().millisecondsSinceEpoch}',
        bankName: json['bankName'] as String? ?? 'Banka',
        principalAmount: (json['principalAmount'] as num?)?.toDouble() ?? 0.0,
        interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
        totalRepayment: (json['totalRepayment'] as num?)?.toDouble() ?? 0.0,
        remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0.0,
        totalInstallments: json['totalInstallments'] as int? ?? 1,
        remainingInstallments: json['remainingInstallments'] as int? ?? 0,
        monthlyPayment: (json['monthlyPayment'] as num?)?.toDouble() ?? 0.0,
      );

  LoanModel copyWith({
    double? remainingAmount,
    int? remainingInstallments,
  }) =>
      LoanModel(
        id: id,
        bankName: bankName,
        principalAmount: principalAmount,
        interestRate: interestRate,
        totalRepayment: totalRepayment,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        totalInstallments: totalInstallments,
        remainingInstallments: remainingInstallments ?? this.remainingInstallments,
        monthlyPayment: monthlyPayment,
      );
}
