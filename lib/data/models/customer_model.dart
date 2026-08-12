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
}
