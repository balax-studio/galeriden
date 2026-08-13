enum SideBusinessType { carWash, vendingMachine, towTruck, billboard }

class SideBusinessModel {
  final String id;
  final String name;
  final String description;
  final SideBusinessType type;
  final double dailyIncome;
  final double cost;
  final bool isOwned;
  final int level;

  SideBusinessModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.type,
    required this.dailyIncome,
    required this.cost,
    this.isOwned = false,
    this.level = 1,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'dailyIncome': dailyIncome,
    'cost': cost,
    'isOwned': isOwned,
    'level': level,
  };

  factory SideBusinessModel.fromJson(Map<String, dynamic> json) => SideBusinessModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    type: SideBusinessType.values.firstWhere((e) => e.name == json['type']),
    dailyIncome: (json['dailyIncome'] as num).toDouble(),
    cost: (json['cost'] as num?)?.toDouble() ?? (json['purchaseCost'] as num?)?.toDouble() ?? 0.0,
    isOwned: json['isOwned'] as bool? ?? false,
    level: json['level'] as int? ?? 1,
  );

  SideBusinessModel copyWith({
    String? id,
    String? name,
    String? description,
    SideBusinessType? type,
    double? dailyIncome,
    double? cost,
    bool? isOwned,
    int? level,
  }) {
    return SideBusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      dailyIncome: dailyIncome ?? this.dailyIncome,
      cost: cost ?? this.cost,
      isOwned: isOwned ?? this.isOwned,
      level: level ?? this.level,
    );
  }
}
