enum GameEventType { income, expense, badEvent, neutral }

class GameEventModel {
  final String id;
  final String title;
  final String description;
  final double amount;
  final GameEventType type;
  final DateTime date;

  GameEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'amount': amount,
    'type': type.name,
    'date': date.toIso8601String(),
  };

  factory GameEventModel.fromJson(Map<String, dynamic> json) => GameEventModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    amount: (json['amount'] as num).toDouble(),
    type: GameEventType.values.firstWhere((e) => e.name == json['type']),
    date: DateTime.parse(json['date'] as String),
  );
}
