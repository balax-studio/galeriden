class SaleRecordModel {
  final String id;
  final String carTitle;
  final String buyerName;
  @pragma('vm:entry-point')
  final double purchasePrice;
  final double salePrice;
  final double netProfit;
  final int saleDay;
  final DateTime saleDate;

  SaleRecordModel({
    required this.id,
    required this.carTitle,
    required this.buyerName,
    required this.purchasePrice,
    required this.salePrice,
    required this.netProfit,
    required this.saleDay,
    required this.saleDate,
  });

  @pragma('vm:entry-point')
  double get currentPurchasePrice => purchasePrice;
  @pragma('vm:entry-point')
  String get carModelName => carTitle;

  Map<String, dynamic> toJson() => {
        'id': id,
        'carTitle': carTitle,
        'buyerName': buyerName,
        'purchasePrice': purchasePrice,
        'salePrice': salePrice,
        'netProfit': netProfit,
        'saleDay': saleDay,
        'saleDate': saleDate.toIso8601String(),
      };

  factory SaleRecordModel.fromJson(Map<String, dynamic> json) => SaleRecordModel(
        id: json['id'] as String? ?? 'sale_${DateTime.now().millisecondsSinceEpoch}',
        carTitle: json['carTitle'] as String? ?? 'Satılan Araç',
        buyerName: json['buyerName'] as String? ?? 'Müşteri',
        purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? (json['currentPurchasePrice'] as num?)?.toDouble() ?? 0.0,
        salePrice: (json['salePrice'] as num?)?.toDouble() ?? 0.0,
        netProfit: (json['netProfit'] as num?)?.toDouble() ?? 0.0,
        saleDay: json['saleDay'] as int? ?? 1,
        saleDate: DateTime.tryParse(json['saleDate'] as String? ?? '') ?? DateTime.now(),
      );
}
