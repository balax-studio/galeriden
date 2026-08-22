class LifestyleItemModel {
  final String id;
  final String category; // 'suit' (apparel), 'accessory'
  final String theme; // 'classic_baron', 'traditional_artisan', 'street_modern', 'motorsport'
  final String name;
  final String description;
  final double price;
  final int reputationBonus;
  final double negotiationBonus; // e.g. 0.05 (+%5)
  final double richCustomerBonus; // e.g. 0.10 (+%10)
  final double interestDiscount; // e.g. 0.05 (+%5)
  final String iconType;

  const LifestyleItemModel({
    required this.id,
    required this.category,
    required this.theme,
    required this.name,
    required this.description,
    required this.price,
    required this.reputationBonus,
    this.negotiationBonus = 0.0,
    this.richCustomerBonus = 0.0,
    this.interestDiscount = 0.0,
    required this.iconType,
  });

  bool get isApparel => category == 'suit' || category == 'apparel';
  bool get isAccessory => category == 'accessory';

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'theme': theme,
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
      category: json['category'] as String? ?? 'suit',
      theme: json['theme'] as String? ?? 'classic_baron',
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

  /// Curated High-End Lifestyle, Wardrobe & Multi-Cultural Prestige Collection
  static const List<LifestyleItemModel> allItems = [
    // ════════════════════════════════════════════════════════════════════════
    // TEMA 1: PROTOKOL & BARON (CLASSIC EXECUTIVE / BARON)
    // ════════════════════════════════════════════════════════════════════════
    LifestyleItemModel(
      id: 'suit_italian_double_breasted',
      category: 'suit',
      theme: 'classic_baron',
      name: 'İtalyan Kruvaze Takım Elbise',
      description: 'Milano kesim saf yün kumaş • Müşteriler üzerinde güçlü esnaf otoritesi kurar.',
      price: 250000.0,
      reputationBonus: 30,
      negotiationBonus: 0.04,
      iconType: 'suit',
    ),
    LifestyleItemModel(
      id: 'suit_bespoke_vested',
      category: 'suit',
      theme: 'classic_baron',
      name: 'Özel Dikim Damatlık Yelekli Takım',
      description: 'İngiliz tarzı yelekli asil kumaş • Prestijli pazarlıklarda alıcı direncini kırar.',
      price: 500000.0,
      reputationBonus: 50,
      negotiationBonus: 0.06,
      richCustomerBonus: 0.08,
      iconType: 'suit',
    ),
    LifestyleItemModel(
      id: 'suit_royal_smoking',
      category: 'suit',
      theme: 'classic_baron',
      name: 'Kraliyet Protokol İpek Smokini',
      description: 'Özel davet ve VIP müzayede smokini • Otomotiv baronu karizması kazandırır.',
      price: 1200000.0,
      reputationBonus: 100,
      negotiationBonus: 0.08,
      richCustomerBonus: 0.15,
      iconType: 'suit',
    ),
    LifestyleItemModel(
      id: 'suit_diplomat_cashmere',
      category: 'suit',
      theme: 'classic_baron',
      name: 'Diplomat Kaşmir Palto',
      description: 'Ağır kış pazarlıklarında soğuk kanlı duruş • Kurumsal müşterilerde tam güven yaratır.',
      price: 800000.0,
      reputationBonus: 75,
      negotiationBonus: 0.05,
      richCustomerBonus: 0.10,
      iconType: 'coat',
    ),
    LifestyleItemModel(
      id: 'acc_gold_chronograph',
      category: 'accessory',
      theme: 'classic_baron',
      name: '18K Altın Kronograf Kol Saati',
      description: 'İsviçre mekanizmalı saf altın saat • Banka görüşmelerinde ve ihalelerde güven tazeler.',
      price: 850000.0,
      reputationBonus: 70,
      richCustomerBonus: 0.12,
      interestDiscount: 0.04,
      iconType: 'watch',
    ),
    LifestyleItemModel(
      id: 'acc_diamond_tourbillon',
      category: 'accessory',
      theme: 'classic_baron',
      name: 'Pırlanta Taşlı Tourbillon Saat',
      description: 'Nadir şaheser koleksiyon saati • Zengin alıcıları galeriye mıknatıs gibi çeker.',
      price: 2000000.0,
      reputationBonus: 150,
      richCustomerBonus: 0.20,
      interestDiscount: 0.08,
      negotiationBonus: 0.06,
      iconType: 'watch',
    ),

    // ════════════════════════════════════════════════════════════════════════
    // TEMA 2: AĞIR ESNAF & ANADOLU (TRADITIONAL ARTISAN & HERITAGE)
    // ════════════════════════════════════════════════════════════════════════
    LifestyleItemModel(
      id: 'app_artisan_leather_vest',
      category: 'suit',
      theme: 'traditional_artisan',
      name: 'Ağır Abi Hakiki Deri Yelek',
      description: 'El dikişi kalın manda derisi • Sanayi ortamında ve sokak pazarlığında ağırlık koyar.',
      price: 200000.0,
      reputationBonus: 25,
      negotiationBonus: 0.05,
      iconType: 'vest',
    ),
    LifestyleItemModel(
      id: 'app_anatolian_wool_jacket',
      category: 'suit',
      theme: 'traditional_artisan',
      name: 'Anadolu Beyefendisi Yün Ceket',
      description: 'Doğal dokuma kalın kumaş • Aile babası ve tutumlu alıcıların kalbini fetheder.',
      price: 380000.0,
      reputationBonus: 40,
      negotiationBonus: 0.06,
      iconType: 'jacket',
    ),
    LifestyleItemModel(
      id: 'acc_amber_silver_tasbih',
      category: 'accessory',
      theme: 'traditional_artisan',
      name: 'Osmanlı Damla Kehribar Tesbih',
      description: 'Gümüş el örmesi püsküllü orijinal damla kehribar • Masada ağır esnaf saygısı yaratır.',
      price: 350000.0,
      reputationBonus: 45,
      negotiationBonus: 0.06,
      iconType: 'tasbih',
    ),
    LifestyleItemModel(
      id: 'acc_erzurum_oltu_tasbih',
      category: 'accessory',
      theme: 'traditional_artisan',
      name: 'Gümüş Kakmalı Erzurum Oltu Tesbih',
      description: 'Geleneksel motifli hakiki oltu taşı • Samimi çay sohbetlerinde alıcı inadını çözer.',
      price: 180000.0,
      reputationBonus: 25,
      negotiationBonus: 0.04,
      iconType: 'tasbih',
    ),
    LifestyleItemModel(
      id: 'acc_sapphire_seal_ring',
      category: 'accessory',
      theme: 'traditional_artisan',
      name: 'Safir Taşlı Gümüş Mühür Yüzük',
      description: 'Özel usta el işlemesi asil yüzük • Sözleşme imzalanırken saygınlık yayar.',
      price: 280000.0,
      reputationBonus: 35,
      negotiationBonus: 0.04,
      richCustomerBonus: 0.05,
      iconType: 'ring',
    ),

    // ════════════════════════════════════════════════════════════════════════
    // TEMA 3: ŞEHİRLİ GENÇ & GİRİŞİMCİ (MODERN STREETWEAR & TECH PIONEER)
    // ════════════════════════════════════════════════════════════════════════
    LifestyleItemModel(
      id: 'app_street_bomber_jacket',
      category: 'suit',
      theme: 'street_modern',
      name: 'Tasarım Siyah Bomber Ceket',
      description: 'Özel tasarım oversize su geçirmez bomber • Genç ve dinamik araç alıcılarıyla bağ kurar.',
      price: 220000.0,
      reputationBonus: 30,
      negotiationBonus: 0.05,
      iconType: 'bomber',
    ),
    LifestyleItemModel(
      id: 'app_minimalist_hoodie_suit',
      category: 'suit',
      theme: 'street_modern',
      name: 'Neopren Lüks Şehirli Kombin',
      description: 'Teknoloji girişimcisi rahatlığı • Dijital kanallardan gelen müşterilere modern görünür.',
      price: 450000.0,
      reputationBonus: 50,
      negotiationBonus: 0.05,
      richCustomerBonus: 0.06,
      iconType: 'hoodie',
    ),
    LifestyleItemModel(
      id: 'acc_smart_titanium_watch',
      category: 'accessory',
      theme: 'street_modern',
      name: 'Titanyum Akıllı Lüks Saat',
      description: 'Hafif titanyum gövde ve safir cam • İleri teknoloji araç pazarında prestij kazandırır.',
      price: 400000.0,
      reputationBonus: 45,
      richCustomerBonus: 0.06,
      interestDiscount: 0.04,
      iconType: 'smartwatch',
    ),
    LifestyleItemModel(
      id: 'acc_polarized_retro_glasses',
      category: 'accessory',
      theme: 'street_modern',
      name: 'Polarize Retro Güneş Gözlüğü',
      description: 'İtalyan asetat çerçeveli camlar • Test sürüşlerinde karizmatik bir hava katar.',
      price: 150000.0,
      reputationBonus: 20,
      negotiationBonus: 0.03,
      iconType: 'glasses',
    ),
    LifestyleItemModel(
      id: 'acc_carbon_cardholder',
      category: 'accessory',
      theme: 'street_modern',
      name: 'Karbon Fiber Deri Kartlık',
      description: 'RFID korumalı ince tasarım • Kapora alırken profesyonel bir intiba bırakır.',
      price: 90000.0,
      reputationBonus: 15,
      negotiationBonus: 0.02,
      iconType: 'wallet',
    ),

    // ════════════════════════════════════════════════════════════════════════
    // TEMA 4: PİST & MOTORSPORLARI (MOTORSPORT & RACING ICON)
    // ════════════════════════════════════════════════════════════════════════
    LifestyleItemModel(
      id: 'app_racing_fireproof_suit',
      category: 'suit',
      theme: 'motorsport',
      name: 'Alev Geçirmez Pilot Tulumu & Mont',
      description: 'FIA standartlarında profesyonel yarış montu • Spor araç ve modifiye tutkunlarını büyüler.',
      price: 650000.0,
      reputationBonus: 65,
      negotiationBonus: 0.06,
      richCustomerBonus: 0.10,
      iconType: 'racing',
    ),
    LifestyleItemModel(
      id: 'app_track_paddock_jacket',
      category: 'suit',
      theme: 'motorsport',
      name: 'Pist Şampiyonu Karbon Ceket',
      description: 'Hafif nefes alan aerodinamik rüzgarlık • Drag yarışlarında ve sanayide saygı görür.',
      price: 420000.0,
      reputationBonus: 45,
      negotiationBonus: 0.05,
      iconType: 'jacket',
    ),
    LifestyleItemModel(
      id: 'acc_carbon_chronometer',
      category: 'accessory',
      theme: 'motorsport',
      name: 'Karbon Fiber Yarış Kronometresi',
      description: 'Milisaniyelik tur sayacı mekanizma • Hızlı karar veren alıcılarda heyecan uyandırır.',
      price: 950000.0,
      reputationBonus: 80,
      negotiationBonus: 0.06,
      richCustomerBonus: 0.10,
      iconType: 'watch',
    ),
    LifestyleItemModel(
      id: 'acc_alcantara_keychain',
      category: 'accessory',
      theme: 'motorsport',
      name: 'Alcantara Titanyum Anahtarlık',
      description: 'İtalyan dikişli süper spor anahtarlık • Araç teslim törenlerinde şık bir son dokunuş.',
      price: 120000.0,
      reputationBonus: 15,
      negotiationBonus: 0.02,
      iconType: 'keychain',
    ),
  ];
}
