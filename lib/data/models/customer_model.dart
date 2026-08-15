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
    ];

    archetypes.shuffle();
    return archetypes.first;
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
}
