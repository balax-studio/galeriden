enum OrderType { quickPatch, masterRepair, newOemPart }

class PartOrderModel {
  final String id;
  final String carId;
  final String partName;
  final OrderType orderType;
  final double cost;
  final DateTime orderedAt;
  final int deliveryDurationSeconds; // e.g. 60s for simple, 180s for master repair
  final bool isInstalled;

  PartOrderModel({
    required this.id,
    required this.carId,
    required this.partName,
    required this.orderType,
    required this.cost,
    required this.orderedAt,
    required this.deliveryDurationSeconds,
    this.isInstalled = false,
  });

  bool get isDelivered {
    final elapsed = DateTime.now().difference(orderedAt).inSeconds;
    return elapsed >= deliveryDurationSeconds;
  }

  int get remainingSeconds {
    final elapsed = DateTime.now().difference(orderedAt).inSeconds;
    final remaining = deliveryDurationSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  double get progressPercentage {
    if (deliveryDurationSeconds <= 0) return 1.0;
    final elapsed = DateTime.now().difference(orderedAt).inSeconds;
    return (elapsed / deliveryDurationSeconds).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'carId': carId,
      'partName': partName,
      'orderType': orderType.name,
      'cost': cost,
      'orderedAt': orderedAt.toIso8601String(),
      'deliveryDurationSeconds': deliveryDurationSeconds,
      'isInstalled': isInstalled,
    };
  }

  factory PartOrderModel.fromJson(Map<String, dynamic> json) {
    return PartOrderModel(
      id: json['id'] as String,
      carId: json['carId'] as String,
      partName: json['partName'] as String,
      orderType: OrderType.values.firstWhere(
        (e) => e.name == json['orderType'],
        orElse: () => OrderType.masterRepair,
      ),
      cost: (json['cost'] as num).toDouble(),
      orderedAt: DateTime.tryParse(json['orderedAt'] as String? ?? '') ?? DateTime.now(),
      deliveryDurationSeconds: json['deliveryDurationSeconds'] as int? ?? 120,
      isInstalled: json['isInstalled'] as bool? ?? false,
    );
  }

  PartOrderModel copyWith({
    bool? isInstalled,
  }) {
    return PartOrderModel(
      id: id,
      carId: carId,
      partName: partName,
      orderType: orderType,
      cost: cost,
      orderedAt: orderedAt,
      deliveryDurationSeconds: deliveryDurationSeconds,
      isInstalled: isInstalled ?? this.isInstalled,
    );
  }
}
