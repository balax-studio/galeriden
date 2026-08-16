import 'dart:math';
import '../../data/models/car_model.dart';

class NightRaceResult {
  final bool isWon;
  final double prizeMoney;
  final int reputationBonus;
  final String raceSummary;
  final String rivalName;
  final String rivalCarName;

  String get raceLog => raceSummary;

  const NightRaceResult({
    required this.isWon,
    required this.prizeMoney,
    required this.reputationBonus,
    required this.raceSummary,
    required this.rivalName,
    required this.rivalCarName,
  });
}

class NightMarketEngine {
  static final _random = Random();

  /// Checks if current real-world hour is within Night Shift (22:00 - 04:00) or simulation (§4.4)
  static bool isNightShiftActive({DateTime? customTime}) {
    final hour = (customTime ?? DateTime.now()).hour;
    return hour >= 22 || hour < 4;
  }

  /// Simulates an underground street modification race (§4.4)
  static NightRaceResult simulateNightRace(CarModel playerCar) {
    final rivals = [
      {'name': 'Gece Kuşu Kemal', 'car': 'Modifiyeli Bemeve 3.20d', 'power': 75},
      {'name': 'Vlogger Berk', 'car': 'Sahne Canavarı Golf GTI', 'power': 82},
      {'name': 'Gölge İbrahim', 'car': 'Karaborsa Merso E-55', 'power': 88},
      {'name': 'Çıkmacı İbo', 'car': 'Yüklenmiş Tofaşk Turbo', 'power': 70},
    ];

    final rival = rivals[_random.nextInt(rivals.length)];
    final rivalPower = rival['power'] as int;

    // Player power score: based on engine condition, transmission, detailing and tuning
    final playerPower = (playerCar.expertise.engineCondition * 0.40 +
            playerCar.expertise.transmissionCondition * 0.30 +
            (playerCar.isDoped ? 15 : 0) +
            (playerCar.appliedDetailingOptionIds.length * 5) +
            _random.nextInt(15))
        .toInt();

    final isWon = playerPower >= rivalPower;

    if (isWon) {
      final prize = 25000.0 + _random.nextInt(35000);
      return NightRaceResult(
        isWon: true,
        prizeMoney: prize,
        reputationBonus: 5,
        raceSummary: 'Tebrikler! ${playerCar.modelName} ile ${rival['name']} (${rival['car']}) aracını düzlükte geride bıraktın.',
        rivalName: rival['name'] as String,
        rivalCarName: rival['car'] as String,
      );
    } else {
      return NightRaceResult(
        isWon: false,
        prizeMoney: 0.0,
        reputationBonus: -2,
        raceSummary: 'Yarışı kaybettin! ${rival['name']} (${rival['car']}) viraj çıkışında öne geçti.',
        rivalName: rival['name'] as String,
        rivalCarName: rival['car'] as String,
      );
    }
  }
}
