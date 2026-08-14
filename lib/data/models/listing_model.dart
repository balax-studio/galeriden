import 'car_model.dart';

class ListingModel {
  final String id;
  final CarModel car;
  final String sellerName;
  final String sellerTrait;
  final String sellerCity;
  final String title;
  final String description;
  final double askingPrice;
  final bool isExpertiseCompleted;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.car,
    required this.sellerName,
    required this.sellerTrait,
    required this.sellerCity,
    required this.title,
    required this.description,
    required this.askingPrice,
    this.isExpertiseCompleted = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car': car.toJson(),
      'sellerName': sellerName,
      'sellerTrait': sellerTrait,
      'sellerCity': sellerCity,
      'title': title,
      'description': description,
      'askingPrice': askingPrice,
      'isExpertiseCompleted': isExpertiseCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    return ListingModel(
      id: json['id'] as String? ?? 'list_${DateTime.now().millisecondsSinceEpoch}',
      car: json['car'] != null ? CarModel.fromJson(json['car'] as Map<String, dynamic>) : CarModel.fromJson(const {}),
      sellerName: json['sellerName'] as String? ?? 'Satıcı',
      sellerTrait: json['sellerTrait'] as String? ?? 'Sahibinden',
      sellerCity: json['sellerCity'] as String? ?? 'İstanbul',
      title: json['title'] as String? ?? 'İlan',
      description: json['description'] as String? ?? '',
      askingPrice: (json['askingPrice'] as num?)?.toDouble() ?? 0.0,
      isExpertiseCompleted: json['isExpertiseCompleted'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  ListingModel copyWith({bool? isExpertiseCompleted}) {
    return ListingModel(
      id: id,
      car: car,
      sellerName: sellerName,
      sellerTrait: sellerTrait,
      sellerCity: sellerCity,
      title: title,
      description: description,
      askingPrice: askingPrice,
      isExpertiseCompleted: isExpertiseCompleted ?? this.isExpertiseCompleted,
      createdAt: createdAt,
    );
  }
}
