import 'car_model.dart';
import 'offer_model.dart';

class DealershipModel {
  final double balance;
  final int level;
  final int maxGarageSlots;
  final List<CarModel> ownedCars;
  final List<OfferModel> incomingOffers;
  final double totalProfit;
  final int carsSold;
  final DateTime lastActiveTime;

  DealershipModel({
    required this.balance,
    required this.level,
    required this.maxGarageSlots,
    required this.ownedCars,
    required this.incomingOffers,
    required this.totalProfit,
    required this.carsSold,
    required this.lastActiveTime,
  });

  factory DealershipModel.initial() {
    return DealershipModel(
      balance: 50000.0,
      level: 1,
      maxGarageSlots: 3,
      ownedCars: [],
      incomingOffers: [],
      totalProfit: 0.0,
      carsSold: 0,
      lastActiveTime: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'level': level,
      'maxGarageSlots': maxGarageSlots,
      'ownedCars': ownedCars.map((c) => c.toJson()).toList(),
      'incomingOffers': incomingOffers.map((o) => o.toJson()).toList(),
      'totalProfit': totalProfit,
      'carsSold': carsSold,
      'lastActiveTime': lastActiveTime.toIso8601String(),
    };
  }

  factory DealershipModel.fromJson(Map<String, dynamic> json) {
    return DealershipModel(
      balance: (json['balance'] as num).toDouble(),
      level: json['level'] as int,
      maxGarageSlots: json['maxGarageSlots'] as int,
      ownedCars: (json['ownedCars'] as List<dynamic>?)
              ?.map((c) => CarModel.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      incomingOffers: (json['incomingOffers'] as List<dynamic>?)
              ?.map((o) => OfferModel.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
      totalProfit: (json['totalProfit'] as num).toDouble(),
      carsSold: json['carsSold'] as int,
      lastActiveTime: DateTime.parse(json['lastActiveTime'] as String),
    );
  }

  DealershipModel copyWith({
    double? balance,
    int? level,
    int? maxGarageSlots,
    List<CarModel>? ownedCars,
    List<OfferModel>? incomingOffers,
    double? totalProfit,
    int? carsSold,
    DateTime? lastActiveTime,
  }) {
    return DealershipModel(
      balance: balance ?? this.balance,
      level: level ?? this.level,
      maxGarageSlots: maxGarageSlots ?? this.maxGarageSlots,
      ownedCars: ownedCars ?? this.ownedCars,
      incomingOffers: incomingOffers ?? this.incomingOffers,
      totalProfit: totalProfit ?? this.totalProfit,
      carsSold: carsSold ?? this.carsSold,
      lastActiveTime: lastActiveTime ?? this.lastActiveTime,
    );
  }
}
