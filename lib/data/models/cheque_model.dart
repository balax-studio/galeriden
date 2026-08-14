class Cheque {
  final String id;
  final String customerName;
  final double amount;
  final int daysUntilDue;
  final bool isDefaulted;

  Cheque({
    required this.id,
    required this.customerName,
    required this.amount,
    required this.daysUntilDue,
    this.isDefaulted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'amount': amount,
    'daysUntilDue': daysUntilDue,
    'isDefaulted': isDefaulted,
  };

  String get carModelName => 'Çekli Satış ($customerName)';
  int get dueDay => daysUntilDue;

  factory Cheque.fromJson(Map<String, dynamic> json) => Cheque(
    id: json['id'] as String? ?? 'chq_${DateTime.now().millisecondsSinceEpoch}',
    customerName: json['customerName'] as String? ?? 'Müşteri',
    amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    daysUntilDue: json['daysUntilDue'] as int? ?? 0,
    isDefaulted: json['isDefaulted'] as bool? ?? false,
  );
  
  Cheque copyWith({int? daysUntilDue, bool? isDefaulted}) {
      return Cheque(
          id: id,
          customerName: customerName,
          amount: amount,
          daysUntilDue: daysUntilDue ?? this.daysUntilDue,
          isDefaulted: isDefaulted ?? this.isDefaulted,
      );
  }
}
