import 'dart:math';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/black_market_car_model.dart';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/game_event_model.dart';

import '../../core/constants/game_constants.dart';

/// Result data structure for black market raid evaluations
class BlackMarketRaidResult {
  final double fine;
  final int reputationLoss;
  final bool shouldSeizeCar;
  final CarModel? updatedCar;
  final GameEventModel event;

  const BlackMarketRaidResult({
    required this.fine,
    required this.reputationLoss,
    required this.shouldSeizeCar,
    this.updatedCar,
    required this.event,
  });
}

/// Pure domain usecase for black market transactions, notary risks, and police raids
class BlackMarketEngine {
  static final List<String> _sellerAliases = [
    'Karanlık Kenan',
    'Gece Kuşu Selim',
    'Gölge İbrahim',
    'Çıkmacı Vahit',
    'Gümrükçü Haydar',
    'Tefeci Mahmut',
    'Şasi Ustası Bedri',
    'Perte Çıkaran Nuri',
    'Gümrük Kaçakçısı Rıza',
    'Kaportacı Sırrı',
    'Gizemli Faruk',
    'Kurt Salih',
    'Sanayi Tilkisi Cevdet',
    'Yeraltı Komisyoncusu Tayfun',
  ];

  static final List<Map<String, String>> _riskProfiles = [
    {
      'type': 'change_vin',
      'tag': 'Change Şasi',
      'desc': 'Şasi numarası pert bir araçtan aktarılmış. Asayiş incelemesinde tespit edilirse araç yediemin otoparkına çekilir.',
    },
    {
      'type': 'stolen_paperwork',
      'tag': 'Sahte Evrak / Çalıntı Şüphesi',
      'desc': 'Ruhsat ve tescil evraklarında sahtecilik şüphesi bulunuyor. Asıl hak sahibi veya savcılık kararıyla el konulabilir.',
    },
    {
      'type': 'smuggled_exotic',
      'tag': 'Gümrük Kaçakçılığı',
      'desc': 'Yurt dışından kaçak sokulmuş tescilsiz araç. Gümrük Muhafaza denetiminde yüklü para cezası ve müsadere riski taşır.',
    },
    {
      'type': 'salvage_hidden',
      'tag': 'Ortadan Kaynaklı Kasa',
      'desc': 'İki farklı kazalı aracın ortadan kaynakla birleştirilmesiyle toplanmış. Ağır mekanik ve şasi kusuru riski yüksektir.',
    },
    {
      'type': 'mafia_debt',
      'tag': 'Tefeci Şerhli',
      'desc': 'Önceki sahibinin gayriresmi borçları ve senet şerhi nedeniyle ihtilaflı. Gece baskını ve rehin riski mevcuttur.',
    },
  ];

  /// Generates dynamic black market vehicle listings with realistic base pricing and risk-reward scaling
  static List<BlackMarketCarModel> generateBlackMarketCars({
    required int day,
    int count = 3,
    int playerLevel = 1,
    Random? random,
  }) {
    final rng = random ?? Random();
    final List<BlackMarketCarModel> cars = [];

    // Filter brands from game constants, prioritizing interesting segments
    final allBrands = List<CarBrandData>.from(GameConstants.carBrands);
    allBrands.shuffle(rng);

    final aliases = List<String>.from(_sellerAliases)..shuffle(rng);
    final profiles = List<Map<String, String>>.from(_riskProfiles)..shuffle(rng);

    for (int i = 0; i < count; i++) {
      final brandData = allBrands[i % allBrands.length];
      final modelName = brandData.models[rng.nextInt(brandData.models.length)];

      final isClassic = brandData.segment == 'klasik' || brandData.segment == 'efsane';
      final year = isClassic
          ? (1985 + rng.nextInt(20))
          : (2012 + rng.nextInt(12)); // 2012-2024 for modern cars

      // Calculate realistic base market value
      final double realMarketValue = _calculateEstimatedMarketValue(brandData.segment, year, isClassic, rng);

      // Dynamic discount between 18% and 52%
      final int discountInt = 18 + rng.nextInt(35); // 18% to 52%
      final double discountRate = discountInt / 100.0;
      final double askingPrice = (realMarketValue * (1.0 - discountRate) / 1000).round() * 1000.0;

      // Dynamic risk formula: higher discount = higher risk
      final int jitter = rng.nextInt(7) - 3; // -3 to +3
      final int riskPercent = ((discountInt * 0.95) + jitter).clamp(15, 60).round();

      final profile = profiles[i % profiles.length];
      final seller = aliases[i % aliases.length];

      final title = '${brandData.name} $modelName • %$discountInt İndirim - ${profile['tag']}';
      final riskDescription = '$seller tarafından el altından sunulan araç. ${profile['desc']} Satış ve muhafaza esnasında %$riskPercent risk taşımaktadır.';

      cars.add(BlackMarketCarModel(
        id: 'bm_${day}_${i + 1}_${rng.nextInt(9999)}',
        brand: brandData.name,
        modelName: title,
        modelYear: year,
        askingPrice: askingPrice,
        realMarketValue: realMarketValue,
        riskType: profile['type']!,
        riskLevelPercent: riskPercent,
        sellerAlias: seller,
        riskDescription: riskDescription,
      ));
    }

    return cars;
  }

  static double _calculateEstimatedMarketValue(String segment, int year, bool isClassic, Random rng) {
    if (isClassic) {
      return (85000.0 + rng.nextInt(250000)).roundToDouble();
    }
    final int yearBonus = (year - 2010).clamp(0, 15) * 35000;
    switch (segment) {
      case 'süperspor':
      case 'egzotik':
        return (2800000.0 + yearBonus * 4.0 + rng.nextInt(900000)).roundToDouble();
      case 'lüks':
      case 'premium':
        return (1100000.0 + yearBonus * 2.5 + rng.nextInt(500000)).roundToDouble();
      case 'popüler':
      case 'halk':
        return (350000.0 + yearBonus * 1.5 + rng.nextInt(200000)).roundToDouble();
      case 'ekonomi':
      default:
        return (220000.0 + yearBonus * 1.0 + rng.nextInt(120000)).roundToDouble();
    }
  }

  /// Evaluates notary block probability based on vehicle risk level
  static bool isNotaryBlocked(int riskLevelPercent, {Random? random}) {
    final rng = random ?? Random();
    final blockChance = (riskLevelPercent / 100.0).clamp(0.0, 0.95);
    return rng.nextDouble() < blockChance;
  }

  /// Processes raid outcome for a black market vehicle in garage
  static BlackMarketRaidResult processRaid({
    required CarModel car,
    required bool hasLegalAdvisor,
    Random? random,
  }) {
    final rng = random ?? Random();
    final riskType = car.blackMarketRiskType ?? 'change_vin';

    switch (riskType) {
      case 'change_vin':
        if (rng.nextDouble() < 0.80) {
          const rawFine = 35000.0;
          final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
          final repLoss = hasLegalAdvisor ? 5 : 20;
          final shouldSeize = !hasLegalAdvisor;

          final event = GameEventModel(
            id: 'police_raid_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: hasLegalAdvisor ? 'HUKUK DANIŞMANI CHANGE DAVASINI KURTARDI!' : 'ASAYİŞ KRİMİNAL • SAHTE ŞASİ TESPİTİ!',
            description: hasLegalAdvisor
                ? 'Avukatınız savcılık kararına yürütmeyi durdurma alarak ${car.brand} ${car.modelName} aracının otoparka çekilmesini engelledi! İdari ceza %75 indirildi: ₺${CurrencyFormatter.formatShort(fine)}.'
                : '${car.brand} ${car.modelName} aracının şasisinin başka bir pert araçtan kopyalandığı tespit edildi. Araç yediemin otoparkına çekildi! ₺35.000 idari para cezası ve -20 İtibar!',
            type: GameEventType.expense,
            amount: -fine,
            date: DateTime.now(),
          );

          return BlackMarketRaidResult(
            fine: fine,
            reputationLoss: repLoss,
            shouldSeizeCar: shouldSeize,
            event: event,
          );
        } else {
          // Chassis crack / physical defect
          final updatedParts = Map<String, PartStatus>.from(car.expertise.bodyParts);
          updatedParts['Şasi/Podye'] = PartStatus.damaged;
          updatedParts['Kaput'] = PartStatus.damaged;
          final updatedCar = car.copyWith(
            expertise: car.expertise.copyWith(
              engineCondition: 25.0,
              transmissionCondition: 30.0,
              tramerAmount: car.expertise.tramerAmount + 140000,
              bodyParts: updatedParts,
            ),
          );

          final event = GameEventModel(
            id: 'chassis_crack_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'MERDİVEN ALTI KAYNAK ÇÖKTÜ!',
            description: '${car.brand} ${car.modelName} ortadan ikiye eklenmiş kaynaklı araç çıktı! Gece vitrinde dururken şasi kaynağından koptu ve motor bloğu çatladı. Araç ağır hasara düştü!',
            type: GameEventType.expense,
            amount: 0.0,
            date: DateTime.now(),
          );

          return BlackMarketRaidResult(
            fine: 0.0,
            reputationLoss: 0,
            shouldSeizeCar: false,
            updatedCar: updatedCar,
            event: event,
          );
        }

      case 'smuggled_exotic':
        const rawFine = 60000.0;
        final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
        final repLoss = hasLegalAdvisor ? 8 : 25;
        final shouldSeize = !hasLegalAdvisor;

        final event = GameEventModel(
          id: 'interpol_customs_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: hasLegalAdvisor ? 'AVUKATINIZ GÜMRÜK EL KOYMASINI DURDURDU!' : 'GÜMRÜK MUHAFAZA & İNTERPOL BASKINI!',
          description: hasLegalAdvisor
              ? 'Gümrük Muhafaza müfettişlerine karşı Hukuk Danışmanınız uluslararası tescil itirazında bulunarak araca el konulmasını önledi. Cezayı ₺${CurrencyFormatter.formatShort(fine)}\'ye düşürdü.'
              : '${car.brand} ${car.modelName} yurt dışından sahte evrakla kaçak sokulduğu için Gümrük Muhafaza ekiplerince el konuldu! ₺60.000 kaçakçılık cezası uygulandı ve -25 İtibar!',
          type: GameEventType.expense,
          amount: -fine,
          date: DateTime.now(),
        );

        return BlackMarketRaidResult(
          fine: fine,
          reputationLoss: repLoss,
          shouldSeizeCar: shouldSeize,
          event: event,
        );

      case 'stolen_paperwork':
        const rawFine = 25000.0;
        final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
        final repLoss = hasLegalAdvisor ? 5 : 15;
        final shouldSeize = !hasLegalAdvisor;

        final event = GameEventModel(
          id: 'stolen_court_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: hasLegalAdvisor ? 'HUKUK DANIŞMANINIZ RUHSAT İHTİLAFINI ÇÖZDÜ!' : 'ASIL RUHSAT SAHİBİ & POLİS BASKINI!',
          description: hasLegalAdvisor
              ? 'Avukatınız iyi niyetli üçüncü kişi savunması yaparak aracın teslimini durdurdu. Mahkeme masrafı ₺${CurrencyFormatter.formatShort(fine)} olarak sınırlandı.'
              : 'Asıl araç sahibi savcılık kararıyla galerinize geldi! ${car.brand} ${car.modelName} çalıntı kaydı nedeniyle sahibine teslim edildi. ₺25.000 hukuki masraf ödendi ve -15 İtibar.',
          type: GameEventType.expense,
          amount: -fine,
          date: DateTime.now(),
        );

        return BlackMarketRaidResult(
          fine: fine,
          reputationLoss: repLoss,
          shouldSeizeCar: shouldSeize,
          event: event,
        );

      case 'mafia_debt':
      case 'salvage_hidden':
      default:
        const rawFine = 30000.0;
        final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
        final repLoss = hasLegalAdvisor ? 3 : 10;

        final event = GameEventModel(
          id: 'mafia_debt_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
          title: hasLegalAdvisor ? 'AVUKATINIZ TEFECİ ŞANTAJINI SAVCILIĞA BİLDİRDİ!' : 'YERALTI HESAPLAŞMASI & TEFECİ BASKINI!',
          description: hasLegalAdvisor
              ? 'Hukuk danışmanınız tefecilerin tehditlerini savcılığa ve organize şubeye bildirerek olayı adli boyuta taşıdı. Güvenlik masrafı ₺${CurrencyFormatter.formatShort(fine)}.'
              : 'Önceki sahibinin tefeci borcu nedeniyle galerinizi bastılar! Galerideki vitrin camları kırıldı ve araca zorla rehin konuldu. ₺30.000 zarar ve -10 İtibar.',
          type: GameEventType.expense,
          amount: -fine,
          date: DateTime.now(),
        );

        return BlackMarketRaidResult(
          fine: fine,
          reputationLoss: repLoss,
          shouldSeizeCar: false,
          event: event,
        );
    }
  }
}
