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

  static CustomerModel generateRandomCustomer() {
    final archetypes = [
      CustomerModel(
        id: 'cust_1',
        name: 'Mustafa Bey',
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Şüpheci Emekli Memur',
        avatarType: 'shield',
        personalityDescription: 'Aracın en ufak çizik ve ekspertiz detayına takılır. Dürüstlük ve şeffaflık ister.',
        preferredDialogueTrait: 'Şeffaflık & Güven',
      ),
      CustomerModel(
        id: 'cust_2',
        name: 'Mertcan',
        archetype: CustomerArchetype.impatientYouth,
        archetypeTitle: 'Sabırsız Genç Sürücü',
        avatarType: 'flash',
        personalityDescription: 'Beygir gücü ve karizmaya bakar. Bütçesi esnektir, beğendiyse %15 fazla öder!',
        preferredDialogueTrait: 'Performans & Karizma',
      ),
      CustomerModel(
        id: 'cust_3',
        name: 'Çakal Selim',
        archetype: CustomerArchetype.greedyFlipper,
        archetypeTitle: 'Açgözlü Oto Al-Satçı',
        avatarType: 'craftsman',
        personalityDescription: 'Ölücü teklifler verir ama anında nakit kapatmak ister.',
        preferredDialogueTrait: 'Hızlı Nakit Kapatma',
      ),
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
        id: 'cust_5',
        name: 'Avukat Deniz Hanım',
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Titiz Hukukçu',
        avatarType: 'shield',
        personalityDescription: 'Tüm noter ve ruhsat evraklarını satır satır inceler. Masrafsız araç arar.',
        preferredDialogueTrait: 'Hukuki Şeffaflık',
      ),
      CustomerModel(
        id: 'cust_6',
        name: 'Müteahhit Burhan',
        archetype: CustomerArchetype.impatientYouth,
        archetypeTitle: 'Agresif Şantiye Patronu',
        avatarType: 'flash',
        personalityDescription: '4x4 ve SUV hastasıdır. Paraya bakmaz, araba diri dursun yeter.',
        preferredDialogueTrait: 'Prestij & Heybet',
      ),
      CustomerModel(
        id: 'cust_7',
        name: 'Gurbetçi Şükrü',
        archetype: CustomerArchetype.greedyFlipper,
        archetypeTitle: 'Almanya Emeklisi',
        avatarType: 'craftsman',
        personalityDescription: 'Euro hesabını iyi bilir. Kelepir yakaladı mı affetmez, peşin sayar.',
        preferredDialogueTrait: 'Sıkı Pazarlık',
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
        id: 'cust_9',
        name: 'Yazılımcı Batuhan',
        archetype: CustomerArchetype.impatientYouth,
        archetypeTitle: 'Teknoloji Meraklısı',
        avatarType: 'flash',
        personalityDescription: 'Multimedya ekranı, ses sistemi ve sürüş asistanlarına bayılır.',
        preferredDialogueTrait: 'Donanım & Teknoloji',
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
        id: 'cust_11',
        name: 'Taksici Rasim Usta',
        archetype: CustomerArchetype.greedyFlipper,
        archetypeTitle: 'Eski Kurt Taksici',
        avatarType: 'craftsman',
        personalityDescription: 'Motorun sesinden subap ayarını anlar. Esnafa hızlı devir yapar.',
        preferredDialogueTrait: 'Mekanik Sağlamlık',
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
    ];

    archetypes.shuffle();
    return archetypes.first;
  }

  static CustomerModel generate(CustomerArchetype archetype) {
    switch (archetype) {
      case CustomerArchetype.skepticalOfficial:
        return CustomerModel(
          id: 'cust_official_${DateTime.now().microsecondsSinceEpoch}',
          name: 'Mustafa Bey',
          archetype: CustomerArchetype.skepticalOfficial,
          archetypeTitle: 'Şüpheci Emekli Memur',
          avatarType: 'shield',
          personalityDescription: 'Aracın en ufak çizik ve ekspertiz detayına takılır. Dürüstlük ve şeffaflık ister.',
          preferredDialogueTrait: 'Şeffaflık & Güven',
        );
      case CustomerArchetype.impatientYouth:
        return CustomerModel(
          id: 'cust_youth_${DateTime.now().microsecondsSinceEpoch}',
          name: 'Mertcan',
          archetype: CustomerArchetype.impatientYouth,
          archetypeTitle: 'Sabırsız Genç Sürücü',
          avatarType: 'flash',
          personalityDescription: 'Beygir gücü ve karizmaya bakar. Bütçesi esnektir, beğendiyse %15 fazla öder!',
          preferredDialogueTrait: 'Performans & Karizma',
        );
      case CustomerArchetype.greedyFlipper:
        return CustomerModel(
          id: 'cust_flipper_${DateTime.now().microsecondsSinceEpoch}',
          name: 'Çakal Selim',
          archetype: CustomerArchetype.greedyFlipper,
          archetypeTitle: 'Açgözlü Oto Al-Satçı',
          avatarType: 'craftsman',
          personalityDescription: 'Ölücü teklifler verir ama anında nakit kapatmak ister.',
          preferredDialogueTrait: 'Hızlı Nakit Kapatma',
        );
      case CustomerArchetype.familyMan:
        return CustomerModel(
          id: 'cust_family_${DateTime.now().microsecondsSinceEpoch}',
          name: 'Ahmet Bey',
          archetype: CustomerArchetype.familyMan,
          archetypeTitle: 'Hassas Aile Babası',
          avatarType: 'rare',
          personalityDescription: 'Bagaj hacmi, tramer temizliği ve aile güvenliği arar.',
          preferredDialogueTrait: 'Aile Güvenliği & Konfor',
        );
    }
  }

  static CustomerModel generateSellerFromListing(String sellerName) {
    final lower = sellerName.toLowerCase();
    
    if (lower.contains('doktor')) {
      return CustomerModel(
        id: 'seller_doc',
        name: sellerName,
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Titiz Doktor',
        avatarType: 'shield',
        personalityDescription: 'Aracına gözü gibi bakmış, pazarlığı pek sevmez, saygı bekler.',
        preferredDialogueTrait: 'Saygı & Şeffaflık',
      );
    } else if (lower.contains('memur') || lower.contains('öğretmen')) {
      return CustomerModel(
        id: 'seller_memur',
        name: sellerName,
        archetype: CustomerArchetype.skepticalOfficial,
        archetypeTitle: 'Düzenli Memur',
        avatarType: 'shield',
        personalityDescription: 'Tüm bakımları yetkili serviste yapmış, her şeyin kaydı var.',
        preferredDialogueTrait: 'Güven & Şeffaflık',
      );
    } else if (lower.contains('al-sat') || lower.contains('galeri')) {
      return CustomerModel(
        id: 'seller_alsat',
        name: sellerName,
        archetype: CustomerArchetype.greedyFlipper,
        archetypeTitle: 'Oto Al-Satçı',
        avatarType: 'craftsman',
        personalityDescription: 'Piyasayı iyi bilir, ucuza bırakmaz ama peşin paraya zaafı vardır.',
        preferredDialogueTrait: 'Hızlı Nakit',
      );
    } else if (lower.contains('genç') || lower.contains('yazılımcı')) {
      return CustomerModel(
        id: 'seller_genc',
        name: sellerName,
        archetype: CustomerArchetype.impatientYouth,
        archetypeTitle: 'Sabırsız Genç',
        avatarType: 'flash',
        personalityDescription: 'Acil paraya sıkışmış, modeli yükseltmek için hızlıca elden çıkarmak istiyor.',
        preferredDialogueTrait: 'Hızlı İşlem',
      );
    } else if (lower.contains('aile') || lower.contains('emekli')) {
      return CustomerModel(
        id: 'seller_aile',
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
      id: 'seller_def',
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
