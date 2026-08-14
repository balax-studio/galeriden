class RentalAgreement {
  final String id;
  final String carId;
  final double dailyRate;
  final int rentedDays;
  final double totalEarned;

  RentalAgreement({
    required this.id,
    required this.carId,
    required this.dailyRate,
    this.rentedDays = 0,
    this.totalEarned = 0.0,
  });

  /// Fallback getters for safety
  @pragma('vm:entry-point')
  String get carModelName => 'Kiradaki Araç';
  @pragma('vm:entry-point')
  String get carTitle => 'Kiradaki Araç';
  @pragma('vm:entry-point')
  double get purchasePrice => 0.0;
  @pragma('vm:entry-point')
  double get currentPurchasePrice => 0.0;

  Map<String, dynamic> toJson() => {
    'id': id, 
    'carId': carId, 
    'dailyRate': dailyRate,
    'rentedDays': rentedDays, 
    'totalEarned': totalEarned,
  };

  factory RentalAgreement.fromJson(Map<String, dynamic> json) => RentalAgreement(
        id: json['id'] as String? ?? 'rent_${DateTime.now().millisecondsSinceEpoch}',
        carId: json['carId'] as String? ?? '',
        dailyRate: (json['dailyRate'] as num?)?.toDouble() ?? 0.0,
        rentedDays: (json['rentedDays'] as num?)?.toInt() ?? 0,
        totalEarned: (json['totalEarned'] as num?)?.toDouble() ?? 0.0,
      );
  
  RentalAgreement copyWith({int? rentedDays, double? totalEarned}) {
      return RentalAgreement(
          id: id, 
          carId: carId, 
          dailyRate: dailyRate,
          rentedDays: rentedDays ?? this.rentedDays,
          totalEarned: totalEarned ?? this.totalEarned,
      );
  }
}
