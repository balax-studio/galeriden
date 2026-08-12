class MarketTrendModel {
  final String headline;
  final Map<String, double> bodyTypeMultipliers; // e.g. 'Sedan': 1.15, 'SUV': 0.90
  final DateTime generatedAt;

  MarketTrendModel({
    required this.headline,
    required this.bodyTypeMultipliers,
    required this.generatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'headline': headline,
      'bodyTypeMultipliers': bodyTypeMultipliers,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }

  factory MarketTrendModel.fromJson(Map<String, dynamic> json) {
    final rawMap = json['bodyTypeMultipliers'] as Map<String, dynamic>? ?? {};
    final multipliers = rawMap.map((key, value) => MapEntry(key, (value as num).toDouble()));

    return MarketTrendModel(
      headline: json['headline'] as String? ?? 'Piyasa Stabil',
      bodyTypeMultipliers: multipliers,
      generatedAt: DateTime.tryParse(json['generatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  factory MarketTrendModel.defaultTrend() {
    return MarketTrendModel(
      headline: 'Piyasa Genel Olarak Durgun ve Dengeli Seyrediyor.',
      bodyTypeMultipliers: {
        'Sedan': 1.0,
        'Hatchback': 1.0,
        'SUV': 1.0,
        'Spor': 1.0,
        'Klasik': 1.0,
      },
      generatedAt: DateTime.now(),
    );
  }
}
