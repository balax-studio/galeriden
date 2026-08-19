enum CustomerArchetype {
  skepticalOfficial, // Şüpheci Memur - Needs transparency & reassurance
  impatientYouth,    // Sabırsız Genç - Wants HP, looks & fast deal, high price tolerance
  greedyFlipper,     // Açgözlü Al-Satçı - Lowballs heavily but pays cash instantly
  familyMan,         // Aile Babası - Safety, trunk space & clean tramer
}

class CustomerModel {
  final String id;
  final String name;
  final CustomerArchetype archetype;
  final String archetypeTitle;
  final String avatarType;
  final String personalityDescription;
  final String preferredDialogueTrait;

  CustomerModel({
    required this.id,
    required this.name,
    required this.archetype,
    required this.archetypeTitle,
    required this.avatarType,
    required this.personalityDescription,
    required this.preferredDialogueTrait,
  });

  /// Probability of buyer insisting on official expertise inspection before purchase
  double get inspectionProbability {
    switch (archetype) {
      case CustomerArchetype.skepticalOfficial:
        return 0.90;
      case CustomerArchetype.familyMan:
        return 0.75;
      case CustomerArchetype.greedyFlipper:
        return 0.60;
      case CustomerArchetype.impatientYouth:
        return 0.20;
    }
  }

  static final List<CustomerModel> _allArchetypePool = [
    // Şüpheci & Titizler (skepticalOfficial)
    CustomerModel(
      id: 'cust_1',
      name: 'Mustafa Bey',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Emekli Şube Müdürü',
      avatarType: 'shield',
      personalityDescription: 'Aracın en ufak çizik ve ekspertiz detayına takılır. Dürüstlük ve şeffaflık ister.',
      preferredDialogueTrait: 'Şeffaflık & Güven',
    ),
    CustomerModel(
      id: 'cust_5',
      name: 'Avukat Deniz Hanım',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Ceza Hukukçusu',
      avatarType: 'shield',
      personalityDescription: 'Tüm noter ve ruhsat evraklarını satır satır inceler. Hukuki risk kabul etmez.',
      preferredDialogueTrait: 'Hukuki Şeffaflık',
    ),
    CustomerModel(
      id: 'cust_10',
      name: 'Koleksiyoner Ekrem Bey',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Klasik Otomobil Gurmesi',
      avatarType: 'shield',
      personalityDescription: 'Orijinal boya mikronuna bakar. Nadir kupon araçlara rekor teklifler verir.',
      preferredDialogueTrait: 'Orijinallik & Geçmiş',
    ),
    CustomerModel(
      id: 'cust_13',
      name: 'Müfettiş Tarık Bey',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Hesap Uzmanı',
      avatarType: 'shield',
      personalityDescription: 'Aracın servis kayıt faturalarını ve kilometre tutarlılığını titizlikle denetler.',
      preferredDialogueTrait: 'Kayıtlı Geçmiş',
    ),
    CustomerModel(
      id: 'cust_14',
      name: 'Bankacı Serdar Bey',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Kredi Risk Uzmanı',
      avatarType: 'shield',
      personalityDescription: 'Piyasa değerlemesini kuruşu kuruşuna bilir. Rapor harici sürprize tahammülü yoktur.',
      preferredDialogueTrait: 'Finansal Netlik',
    ),
    CustomerModel(
      id: 'cust_15',
      name: 'Sigortacı Fuat Bey',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Kıdemli Eksper',
      avatarType: 'shield',
      personalityDescription: 'Tramer ve boya kalınlığını gözü kapalı anlar. Orijinal parça hassasiyeti yüksektir.',
      preferredDialogueTrait: 'Teknik Detay',
    ),
    CustomerModel(
      id: 'cust_16',
      name: 'Emekli Albay Rıza Bey',
      archetype: CustomerArchetype.skepticalOfficial,
      archetypeTitle: 'Disiplinli Asker',
      avatarType: 'shield',
      personalityDescription: 'Sözleşme şartlarına ve verilen sözlere harfiyen uyulmasını bekler.',
      preferredDialogueTrait: 'Disiplin & Netlik',
    ),

    // Sabırsız & Genç & Prestij Arayanlar (impatientYouth)
    CustomerModel(
      id: 'cust_2',
      name: 'Mertcan Yıldız',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'Genç Yazılımcı',
      avatarType: 'flash',
      personalityDescription: 'Beygir gücü ve karizmaya bakar. Bütçesi esnektir, beğendiyse fazla öder.',
      preferredDialogueTrait: 'Performans & Karizma',
    ),
    CustomerModel(
      id: 'cust_6',
      name: 'Müteahhit Burhan Bey',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'Şantiye Patronu',
      avatarType: 'flash',
      personalityDescription: '4x4 ve SUV hastasıdır. Paraya bakmaz, araba diri dursun ve heybetli olsun yeter.',
      preferredDialogueTrait: 'Prestij & Heybet',
    ),
    CustomerModel(
      id: 'cust_9',
      name: 'Yazılımcı Batuhan',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'Teknoloji Meraklısı',
      avatarType: 'flash',
      personalityDescription: 'Multimedya ekranı, ses sistemi ve sürüş asistanlarına bayılır.',
      preferredDialogueTrait: 'Donanım & Teknoloji',
    ),
    CustomerModel(
      id: 'cust_17',
      name: 'Caner Eren',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'E-Ticaret Girişimcisi',
      avatarType: 'flash',
      personalityDescription: 'Premium spor araçlarla prestij kazanmak ister. İşlemler hemen bitsin ister.',
      preferredDialogueTrait: 'Hızlı Teslimat',
    ),
    CustomerModel(
      id: 'cust_18',
      name: 'Üniversiteli Can',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'Mühendislik Öğrencisi',
      avatarType: 'flash',
      personalityDescription: 'Genç işi modifiyeli ve çekici hatchback modellerin hayranıdır.',
      preferredDialogueTrait: 'Tarz & Görsellik',
    ),
    CustomerModel(
      id: 'cust_19',
      name: 'Kuaför Murat',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'Stil Danışmanı',
      avatarType: 'flash',
      personalityDescription: 'Jant, egzoz ve boya kondisyonuna aşık olur. Vitrin arabası arar.',
      preferredDialogueTrait: 'Estetik Çizgiler',
    ),
    CustomerModel(
      id: 'cust_20',
      name: 'Prodüktör Arda',
      archetype: CustomerArchetype.impatientYouth,
      archetypeTitle: 'Medya Yöneticisi',
      avatarType: 'flash',
      personalityDescription: 'Şehir içi dikkat çeken spor ve egzotik kasaların peşindedir.',
      preferredDialogueTrait: 'Hava & Karizma',
    ),

    // Açgözlü & Esnaf & Al-Satçılar (greedyFlipper)
    CustomerModel(
      id: 'cust_3',
      name: 'Çakal Selim',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Oto Al-Satçı',
      avatarType: 'craftsman',
      personalityDescription: 'Ölücü teklifler verir ama anında nakit kapatmak ister.',
      preferredDialogueTrait: 'Hızlı Nakit Kapatma',
    ),
    CustomerModel(
      id: 'cust_7',
      name: 'Gurbetçi Şükrü',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Almanya Emeklisi',
      avatarType: 'craftsman',
      personalityDescription: 'Döviz hesabını iyi bilir. Kelepir yakaladı mı affetmez, peşin sayar.',
      preferredDialogueTrait: 'Sıkı Pazarlık',
    ),
    CustomerModel(
      id: 'cust_11',
      name: 'Taksici Rasim Usta',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Eski Kurt Taksici',
      avatarType: 'craftsman',
      personalityDescription: 'Motorun sesinden subap ayarını anlar. Esnafa hızlı devir yapar.',
      preferredDialogueTrait: 'Mekanik Sağlamlık',
    ),
    CustomerModel(
      id: 'cust_21',
      name: 'Çıkmacı Vahit',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Yedek Parça Tüccarı',
      avatarType: 'craftsman',
      personalityDescription: 'Hasarlı veya masraflı araçları ucuza toplayıp sanayide ayağa kaldırır.',
      preferredDialogueTrait: 'Kelepir Fiyat',
    ),
    CustomerModel(
      id: 'cust_22',
      name: 'Galerici Cengiz',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Oto Galericiler Sitesi Esnafı',
      avatarType: 'craftsman',
      personalityDescription: 'Piyasa dalgalanmalarını takip eder, toplu araç alımlarında sert kırar.',
      preferredDialogueTrait: 'Toptan Alım',
    ),
    CustomerModel(
      id: 'cust_23',
      name: 'Emlakçı Vedat Bey',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Takas & Ticaret Uzmanı',
      avatarType: 'craftsman',
      personalityDescription: 'Nakit ve takas fırsatlarını iyi koklar. Hızlı elden çıkarma ustasıdır.',
      preferredDialogueTrait: 'Takas Esnekliği',
    ),
    CustomerModel(
      id: 'cust_24',
      name: 'Nakliyeci Dursun Usta',
      archetype: CustomerArchetype.greedyFlipper,
      archetypeTitle: 'Filo İşletmecisi',
      avatarType: 'craftsman',
      personalityDescription: 'Ticari ve dayanıklı araçları peşin parayla ucuza kapatır.',
      preferredDialogueTrait: 'Peşin İndirim',
    ),

    // Hassas Aile & Güvenlik Odaklılar (familyMan)
    CustomerModel(
      id: 'cust_4',
      name: 'Ahmet Bey',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Hassas Aile Babası',
      avatarType: 'rare',
      personalityDescription: 'Bagaj hacmi, tramer temizliği ve aile güvenliği arar.',
      preferredDialogueTrait: 'Aile Güvenliği & Konfor',
    ),
    CustomerModel(
      id: 'cust_8',
      name: 'Öğretmen Emre Bey',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Tasarruflu Eğitimci',
      avatarType: 'rare',
      personalityDescription: 'Yakıt tüketimi az, kronik arızası olmayan temiz sedanların peşindedir.',
      preferredDialogueTrait: 'Ekonomik Güven',
    ),
    CustomerModel(
      id: 'cust_12',
      name: 'Doktor Nazlı Hanım',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Güvenlik Odaklı Hekim',
      avatarType: 'rare',
      personalityDescription: 'Hava yastıkları ve fren sistemleri kusursuz olmalı. Pazarlıkta nettir.',
      preferredDialogueTrait: 'Maksimum Güvenlik',
    ),
    CustomerModel(
      id: 'cust_25',
      name: 'Eczacı Kemal Bey',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Mahalle Eczacısı',
      avatarType: 'rare',
      personalityDescription: 'Konforlu, temiz iç mekanlı ve sessiz sürüş sunan aile araçlarını tercih eder.',
      preferredDialogueTrait: 'Konfor & Sessizlik',
    ),
    CustomerModel(
      id: 'cust_26',
      name: 'Mimar Selin Hanım',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Tasarımcı & Anne',
      avatarType: 'rare',
      personalityDescription: 'Geniş görüş açısı, ferah kabin ve çocuk güvenliği donanımlarına önem verir.',
      preferredDialogueTrait: 'Ergonomi & Güvenlik',
    ),
    CustomerModel(
      id: 'cust_27',
      name: 'Çiftçi Halil Ağa',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Toprak Sahibi',
      avatarType: 'rare',
      personalityDescription: 'Geniş bagajlı, köy yoluna dayanıklı ve masrafsız araç arar.',
      preferredDialogueTrait: 'Sağlam Şasi',
    ),
    CustomerModel(
      id: 'cust_28',
      name: 'Diş Hekimi Beren Hanım',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Titiz Sağlıkçı',
      avatarType: 'rare',
      personalityDescription: 'İçi dışı tertemiz, sigara içilmemiş ve düzenli yetkili servis bakımlı araç ister.',
      preferredDialogueTrait: 'Temiz Geçmiş',
    ),
    CustomerModel(
      id: 'cust_29',
      name: 'Veteriner Tarık Bey',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Doğa Dostu Hekim',
      avatarType: 'rare',
      personalityDescription: 'Geniş bagajlı station wagon ve SUV modelleriyle hafta sonu seyahatlerini sever.',
      preferredDialogueTrait: 'Hacim & Dayanıklılık',
    ),
    CustomerModel(
      id: 'cust_30',
      name: 'Sanayici Kerem Bey',
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'İş İnsanı',
      avatarType: 'rare',
      personalityDescription: 'Ailesi için üst düzey konforlu ve prestijli Alman kasalarını tercih eder.',
      preferredDialogueTrait: 'Maksimum Konfor',
    ),
  ];

  static final List<String> _recentGeneratedIds = [];

  static CustomerModel generateRandomCustomer() {
    final pool = List<CustomerModel>.from(_allArchetypePool);
    pool.shuffle();

    // Anti-repetition: avoid the last 6 generated customers
    for (final customer in pool) {
      if (!_recentGeneratedIds.contains(customer.id)) {
        _trackRecentCustomer(customer.id);
        return customer;
      }
    }

    // Fallback if all were recently used
    final selected = pool.first;
    _trackRecentCustomer(selected.id);
    return selected;
  }

  static void _trackRecentCustomer(String id) {
    _recentGeneratedIds.add(id);
    if (_recentGeneratedIds.length > 8) {
      _recentGeneratedIds.removeAt(0);
    }
  }

  static CustomerModel generate(CustomerArchetype archetype) {
    final matching = _allArchetypePool.where((c) => c.archetype == archetype).toList();
    matching.shuffle();

    for (final customer in matching) {
      if (!_recentGeneratedIds.contains(customer.id)) {
        _trackRecentCustomer(customer.id);
        return customer;
      }
    }

    final selected = matching.isNotEmpty ? matching.first : generateRandomCustomer();
    _trackRecentCustomer(selected.id);
    return selected;
  }

  static CustomerModel generateSellerFromListing(String sellerName) {
    final lower = sellerName.toLowerCase();
    
    if (lower.contains('doktor') || lower.contains('hekim')) {
      return CustomerModel(
        id: 'seller_doc_${DateTime.now().microsecondsSinceEpoch}',
        name: sellerName,
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Titiz Doktor',
        avatarType: 'shield',
        personalityDescription: 'Aracına gözü gibi bakmış, pazarlığı pek sevmez, saygı bekler.',
        preferredDialogueTrait: 'Saygı & Şeffaflık',
      );
    } else if (lower.contains('memur') || lower.contains('öğretmen') || lower.contains('albay') || lower.contains('müfettiş')) {
      return CustomerModel(
        id: 'seller_memur_${DateTime.now().microsecondsSinceEpoch}',
        name: sellerName,
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Düzenli Memur',
        avatarType: 'shield',
        personalityDescription: 'Tüm bakımları yetkili serviste yapmış, her şeyin kaydı var.',
        preferredDialogueTrait: 'Güven & Şeffaflık',
      );
    } else if (lower.contains('al-sat') || lower.contains('galeri') || lower.contains('taksici') || lower.contains('çıkmacı')) {
      return CustomerModel(
        id: 'seller_alsat_${DateTime.now().microsecondsSinceEpoch}',
        name: sellerName,
        archetype: CustomerArchetype.greedyFlipper,
        archetypeTitle: 'Oto Al-Satçı',
        avatarType: 'craftsman',
        personalityDescription: 'Piyasayı iyi bilir, ucuza bırakmaz ama peşin paraya zaafı vardır.',
        preferredDialogueTrait: 'Hızlı Nakit',
      );
    } else if (lower.contains('genç') || lower.contains('yazılımcı') || lower.contains('müteahhit') || lower.contains('öğrenci')) {
      return CustomerModel(
        id: 'seller_genc_${DateTime.now().microsecondsSinceEpoch}',
        name: sellerName,
        archetype: CustomerArchetype.impatientYouth,
        archetypeTitle: 'Sabırsız Genç',
        avatarType: 'flash',
        personalityDescription: 'Acil paraya sıkışmış, modeli yükseltmek için hızlıca elden çıkarmak istiyor.',
        preferredDialogueTrait: 'Hızlı İşlem',
      );
    } else if (lower.contains('aile') || lower.contains('emekli') || lower.contains('çiftçi') || lower.contains('eczacı')) {
      return CustomerModel(
        id: 'seller_aile_${DateTime.now().microsecondsSinceEpoch}',
        name: sellerName,
        archetype: CustomerArchetype.familyMan,
        archetypeTitle: 'Aile Babası',
        avatarType: 'rare',
        personalityDescription: 'Araç hep kılıflarla kullanılmış, sigara içilmemiş, gözü gibi bakılmış.',
        preferredDialogueTrait: 'Samimiyet',
      );
    }
    
    // Default fallback
    return CustomerModel(
      id: 'seller_def_${DateTime.now().microsecondsSinceEpoch}',
      name: sellerName,
      archetype: CustomerArchetype.familyMan,
      archetypeTitle: 'Bireysel Satıcı',
      avatarType: 'rare',
      personalityDescription: 'Aracını satmak isteyen normal bir vatandaş.',
      preferredDialogueTrait: 'Karşılıklı Pazarlık',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'archetype': archetype.name,
        'archetypeTitle': archetypeTitle,
        'avatarType': avatarType,
        'personalityDescription': personalityDescription,
        'preferredDialogueTrait': preferredDialogueTrait,
      };

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        id: json['id'] as String? ?? 'cust_${DateTime.now().millisecondsSinceEpoch}',
        name: json['name'] as String? ?? 'Müşteri',
        archetype: CustomerArchetype.values.firstWhere(
          (e) => e.name == json['archetype'],
          orElse: () => CustomerArchetype.familyMan,
        ),
        archetypeTitle: json['archetypeTitle'] as String? ?? 'Müşteri',
        avatarType: json['avatarType'] as String? ?? 'shield',
        personalityDescription: json['personalityDescription'] as String? ?? '',
        preferredDialogueTrait: json['preferredDialogueTrait'] as String? ?? '',
      );

  CustomerModel copyWith({
    String? name,
    CustomerArchetype? archetype,
    String? archetypeTitle,
    String? avatarType,
    String? personalityDescription,
    String? preferredDialogueTrait,
  }) {
    return CustomerModel(
      id: id,
      name: name ?? this.name,
      archetype: archetype ?? this.archetype,
      archetypeTitle: archetypeTitle ?? this.archetypeTitle,
      avatarType: avatarType ?? this.avatarType,
      personalityDescription: personalityDescription ?? this.personalityDescription,
      preferredDialogueTrait: preferredDialogueTrait ?? this.preferredDialogueTrait,
    );
  }
}
