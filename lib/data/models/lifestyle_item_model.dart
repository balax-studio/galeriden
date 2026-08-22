class LifestyleItemModel {
  final String id;
  final String category; // 'suit', 'accessory', 'officeDecor'
  final String name;
  final String description;
  final double price;
  final int reputationBonus;
  final double negotiationBonus; // e.g. 0.08 (+%8)
  final double richCustomerBonus; // e.g. 0.15 (+%15)
  final double interestDiscount; // e.g. 0.05 (+%5)
  final String iconType;

  const LifestyleItemModel({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.reputationBonus,
    this.negotiationBonus = 0.0,
    this.richCustomerBonus = 0.0,
    this.interestDiscount = 0.0,
    required this.iconType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'name': name,
        'description': description,
        'price': price,
        'reputationBonus': reputationBonus,
        'negotiationBonus': negotiationBonus,
        'richCustomerBonus': richCustomerBonus,
        'interestDiscount': interestDiscount,
        'iconType': iconType,
      };

  factory LifestyleItemModel.fromJson(Map<String, dynamic> json) {
    return LifestyleItemModel(
      id: json['id'] as String,
      category: json['category'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      reputationBonus: json['reputationBonus'] as int? ?? 0,
      negotiationBonus: (json['negotiationBonus'] as num?)?.toDouble() ?? 0.0,
      richCustomerBonus: (json['richCustomerBonus'] as num?)?.toDouble() ?? 0.0,
      interestDiscount: (json['interestDiscount'] as num?)?.toDouble() ?? 0.0,
      iconType: json['iconType'] as String? ?? 'suit',
    );
  }

  /// Curated High-End Lifestyle & Wardrobe Collection
  static const List<LifestyleItemModel> allItems = [
    // 1. TAKIM ELBİSELER & KIYAFET (SUITS)
    LifestyleItemModel(
      id: 'suit_italian_double_breasted',
      category: 'suit',
      name: 'İtalyan Kruvaze Takım Elbise',
      description: 'Milano kesim saf yün kumaş • Müşteriler üzerinde güçlü esnaf otoritesi kurar.',
      price: 250000.0,
      reputationBonus: 35,
      negotiationBonus: 0.08,
      iconType: 'suit',
    ),
    LifestyleItemModel(
      id: 'suit_bespoke_vested',
      category: 'suit',
      name: 'Özel Dikim Damatlık Yelekli Takım',
      description: 'İngiliz tarzı yelekli asil kumaş • Prestijli pazarlıklarda alıcı direncini kırar.',
      price: 500000.0,
      reputationBonus: 60,
      negotiationBonus: 0.12,
      richCustomerBonus: 0.10,
      iconType: 'suit',
    ),
    LifestyleItemModel(
      id: 'suit_royal_smoking',
      category: 'suit',
      name: 'Kraliyet Protokol İpek Smokini',
      description: 'Özel davet ve VIP müzayede smokini • Otomotiv baronu karizması kazandırır.',
      price: 1200000.0,
      reputationBonus: 120,
      negotiationBonus: 0.18,
      richCustomerBonus: 0.25,
      iconType: 'suit',
    ),

    // 2. SAATLER & LÜKS AKSESUARLAR (ACCESSORIES)
    LifestyleItemModel(
      id: 'acc_amber_silver_tasbih',
      category: 'accessory',
      name: 'Osmanlı Damla Kehribar Tesbih',
      description: 'Gümüş el örmesi püsküllü orijinal damla kehribar • Masada ağır esnaf saygısı yaratır.',
      price: 350000.0,
      reputationBonus: 45,
      negotiationBonus: 0.10,
      iconType: 'tasbih',
    ),
    LifestyleItemModel(
      id: 'acc_gold_chronograph',
      category: 'accessory',
      name: '18K Altın Kronograf Kol Saati',
      description: 'İsviçre mekanizmalı saf altın saat • Banka görüşmelerinde ve ihalelerde güven tazeler.',
      price: 850000.0,
      reputationBonus: 85,
      richCustomerBonus: 0.15,
      interestDiscount: 0.05,
      iconType: 'watch',
    ),
    LifestyleItemModel(
      id: 'acc_diamond_tourbillon',
      category: 'accessory',
      name: 'Pırlanta Taşlı Tourbillon Saat',
      description: 'Nadir şaheser koleksiyon saati • Zengin alıcıları galeriye mıknatıs gibi çeker.',
      price: 2000000.0,
      reputationBonus: 180,
      richCustomerBonus: 0.30,
      interestDiscount: 0.10,
      negotiationBonus: 0.15,
      iconType: 'watch',
    ),

    // 3. MAKAM & OFİS LÜKSÜ (OFFICE DECOR)
    LifestyleItemModel(
      id: 'decor_leather_patron_chair',
      category: 'officeDecor',
      name: 'Hakiki Deri Masajlı Patron Koltuğu',
      description: 'El yapımı İtalyan deri makam koltuğu • Ofiste geçen her gün enerji ve saygı kazandırır.',
      price: 450000.0,
      reputationBonus: 50,
      negotiationBonus: 0.08,
      iconType: 'chair',
    ),
    LifestyleItemModel(
      id: 'decor_gold_espresso_bar',
      category: 'officeDecor',
      name: 'Altın Kaplama İtalyan Espresso İstasyonu',
      description: 'Müşterilere sunulan elit ikramlar • Pazarlık esnasında satış kapanış hızını ikiye katlar.',
      price: 750000.0,
      reputationBonus: 75,
      richCustomerBonus: 0.20,
      iconType: 'coffee',
    ),
    LifestyleItemModel(
      id: 'decor_mahogany_executive_desk',
      category: 'officeDecor',
      name: 'Masif Maun Ağacı El Oyması Makam Masası',
      description: 'Devasa toplantı ve sözleşme masası • Galeriye gelen tüm kurumsal müşterileri büyüler.',
      price: 1800000.0,
      reputationBonus: 160,
      negotiationBonus: 0.15,
      richCustomerBonus: 0.25,
      interestDiscount: 0.08,
      iconType: 'desk',
    ),
  ];
}
