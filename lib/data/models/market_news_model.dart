class MarketNewsModel {
  final String id;
  final String title;
  final String description;
  final double priceMultiplier; // Örn: 1.15 = %15 fiyat artışı, 0.92 = %8 düşüş
  final String targetCategory; // Örn: 'all', 'suv', 'cabrio', 'sedan', 'luxury'

  const MarketNewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceMultiplier,
    required this.targetCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priceMultiplier': priceMultiplier,
      'targetCategory': targetCategory,
    };
  }

  factory MarketNewsModel.fromJson(Map<String, dynamic> json) {
    return MarketNewsModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priceMultiplier: (json['priceMultiplier'] as num).toDouble(),
      targetCategory: json['targetCategory'] as String,
    );
  }

  static const List<MarketNewsModel> newsList = [
    MarketNewsModel(
      id: 'news_1',
      title: '☀️ YAZ SEZONU BAŞLADI',
      description: 'Yaz aylarının gelmesiyle Cabrio ve Coupe araçlara talep patladı! (+%15 Pazar Değeri)',
      priceMultiplier: 1.15,
      targetCategory: 'cabrio',
    ),
    MarketNewsModel(
      id: 'news_2',
      title: '📉 ÖTV İNDİRİMİ BEKLENTİSİ',
      description: 'Piyasada ÖTV güncellemesi söylentileri ikinci el satışları yavaşlattı. (-%8 Pazar Değeri)',
      priceMultiplier: 0.92,
      targetCategory: 'all',
    ),
    MarketNewsModel(
      id: 'news_3',
      title: '❄️ ZORLU KIŞ ŞARTLARI',
      description: 'Yoğun kar yağışı ve kış mevsimi sebebiyle 4x4 SUV araç fiyatları uçuşa geçti! (+%18 Pazar Değeri)',
      priceMultiplier: 1.18,
      targetCategory: 'suv',
    ),
    MarketNewsModel(
      id: 'news_4',
      title: '⛽ YAKIT FİYATLARI DÜŞTÜ',
      description: 'Küresel petrol fiyatlarındaki düşüş sonrası sedan araç talebi yeniden arttı! (+%10 Pazar Değeri)',
      priceMultiplier: 1.10,
      targetCategory: 'sedan',
    ),
    MarketNewsModel(
      id: 'news_5',
      title: '🏆 LÜKS ARAÇ İTHALAT KOTASI',
      description: 'Gümrük kısıtlamaları sebebiyle lüks ve egzotik araç fiyatları rekor kırdı! (+%25 Pazar Değeri)',
      priceMultiplier: 1.25,
      targetCategory: 'luxury',
    ),
  ];
}
