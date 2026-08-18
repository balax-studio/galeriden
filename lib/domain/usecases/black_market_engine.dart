import 'dart:math';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';
import '../../data/models/game_event_model.dart';

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
