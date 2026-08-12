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
        id: json['id'] as String,
        bankName: json['bankName'] as String,
        principalAmount: (json['principalAmount'] as num).toDouble(),
        interestRate: (json['interestRate'] as num).toDouble(),
        totalRepayment: (json['totalRepayment'] as num).toDouble(),
        remainingAmount: (json['remainingAmount'] as num).toDouble(),
        totalInstallments: json['totalInstallments'] as int,
        remainingInstallments: json['remainingInstallments'] as int,
        monthlyPayment: (json['monthlyPayment'] as num).toDouble(),
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
