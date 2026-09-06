enum GameEventType { income, expense, badEvent, neutral, meme, goodEvent }

class GameEventChoice {
  final String label;
  final String resultText;
  final double balanceChange;
  final int reputationChange;
  final int xpGain;
  final String? targetCarEffect;
  final String? sideBusinessId;
  final int? sideBusinessDowntimeDays;
  final int? staffMoraleChange;
  final String? unlockFlag;

  const GameEventChoice({
    required this.label,
    required this.resultText,
    this.balanceChange = 0.0,
    this.reputationChange = 0,
    this.xpGain = 0,
    this.targetCarEffect,
    this.sideBusinessId,
    this.sideBusinessDowntimeDays,
    this.staffMoraleChange,
    this.unlockFlag,
  });

  Map<String, dynamic> toJson() => {
        'label': label,
        'resultText': resultText,
        'balanceChange': balanceChange,
        'reputationChange': reputationChange,
        'xpGain': xpGain,
        if (targetCarEffect != null) 'targetCarEffect': targetCarEffect,
        if (sideBusinessId != null) 'sideBusinessId': sideBusinessId,
        if (sideBusinessDowntimeDays != null)
          'sideBusinessDowntimeDays': sideBusinessDowntimeDays,
        if (staffMoraleChange != null) 'staffMoraleChange': staffMoraleChange,
        if (unlockFlag != null) 'unlockFlag': unlockFlag,
      };

  factory GameEventChoice.fromJson(Map<String, dynamic> json) => GameEventChoice(
        label: json['label'] as String? ?? 'Tamam',
        resultText: json['resultText'] as String? ?? '',
        balanceChange: (json['balanceChange'] as num?)?.toDouble() ?? 0.0,
        reputationChange: json['reputationChange'] as int? ?? 0,
        xpGain: json['xpGain'] as int? ?? 0,
        targetCarEffect: json['targetCarEffect'] as String?,
        sideBusinessId: json['sideBusinessId'] as String?,
        sideBusinessDowntimeDays: json['sideBusinessDowntimeDays'] as int?,
        staffMoraleChange: json['staffMoraleChange'] as int?,
        unlockFlag: json['unlockFlag'] as String?,
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
  final Map<String, dynamic>? params;

  GameEventModel({
    required this.id,
    required this.title,
    required this.description,
    this.iconEmoji = 'megaphone',
    required this.amount,
    required this.type,
    required this.date,
    this.choices = const [],
    this.params,
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
        if (params != null) 'params': params,
      };

  factory GameEventModel.fromJson(Map<String, dynamic> json) => GameEventModel(
        id: json['id'] as String? ?? 'event_${DateTime.now().millisecondsSinceEpoch}',
        title: json['title'] as String? ?? 'Olay',
        description: json['description'] as String? ?? '',
        iconEmoji: json['iconEmoji'] as String? ?? 'megaphone',
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
        params: json['params'] != null ? Map<String, dynamic>.from(json['params'] as Map) : null,
      );
}
