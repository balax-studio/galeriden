enum GameEventType { income, expense, badEvent, neutral, meme, goodEvent }

class GameEventChoice {
  final String label;
  final String resultText;
  final double balanceChange;
  final int reputationChange;
  final int xpGain;

  const GameEventChoice({
    required this.label,
    required this.resultText,
    this.balanceChange = 0.0,
    this.reputationChange = 0,
    this.xpGain = 0,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'resultText': resultText,
        'balanceChange': balanceChange,
        'reputationChange': reputationChange,
        'xpGain': xpGain,
      };

  factory GameEventChoice.fromJson(Map<String, dynamic> json) => GameEventChoice(
        label: json['label'] as String? ?? 'Tamam',
        resultText: json['resultText'] as String? ?? '',
        balanceChange: (json['balanceChange'] as num?)?.toDouble() ?? 0.0,
        reputationChange: json['reputationChange'] as int? ?? 0,
        xpGain: json['xpGain'] as int? ?? 0,
      );
}

class GameEventModel {
  final String id;
  final String title;
  final String description;
  final String iconEmoji;
  final double amount;
  final GameEventType type;
  final DateTime date;
  final List<GameEventChoice> choices;

  GameEventModel({
    required this.id,
    required this.title,
    required this.description,
    this.iconEmoji = '📢',
    required this.amount,
    required this.type,
    required this.date,
    this.choices = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'iconEmoji': iconEmoji,
        'amount': amount,
        'type': type.name,
        'date': date.toIso8601String(),
        'choices': choices.map((c) => c.toJson()).toList(),
      };

  factory GameEventModel.fromJson(Map<String, dynamic> json) => GameEventModel(
        id: json['id'] as String? ?? 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title'] as String? ?? 'Olay',
        description: json['description'] as String? ?? '',
        iconEmoji: json['iconEmoji'] as String? ?? '📢',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        type: GameEventType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => GameEventType.neutral,
        ),
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        choices: (json['choices'] as List<dynamic>?)
                ?.map((c) => GameEventChoice.fromJson(Map<String, dynamic>.from(c as Map)))
                .toList() ??
            const [],
      );
}
