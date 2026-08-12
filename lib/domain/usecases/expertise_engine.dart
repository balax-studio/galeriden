import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

class ExpertiseEngine {
  static final Random _random = Random();

  /// Check if player's eyeForDetail skill detects hidden defects without full expertise
  static bool detectHiddenTampering(CarModel car, int eyeForDetailLevel) {
    if (!car.expertise.isMileageTampered) return false;
    double chance = eyeForDetailLevel * 0.10; // Level 1 = 10%, Level 10 = 100%
    return _random.nextDouble() < chance;
  }

  /// Evaluates true market value after detailed inspection
  static Map<String, dynamic> evaluateVehicle(CarModel car) {
    final exp = car.expertise;
    int paintedCount = 0;
    int changedCount = 0;
    int damagedCount = 0;

    exp.bodyParts.forEach((part, status) {
      if (status == PartStatus.painted) paintedCount++;
      if (status == PartStatus.changed) changedCount++;
      if (status == PartStatus.damaged) damagedCount++;
    });

    double damagePercentage = (changedCount * 12.0) + (damagedCount * 20.0) + (paintedCount * 5.0);
    damagePercentage += (100.0 - exp.engineCondition) * 0.4;
    damagePercentage += (100.0 - exp.transmissionCondition) * 0.3;

    double fairMarketValue = car.baseMarketValue * (1.0 - (damagePercentage / 100.0).clamp(0.0, 0.65));

    String overallGrade;
    if (damagePercentage < 10) {
      overallGrade = 'A+ (Koleksiyonluk / Geliştirici Bile Hayran Kaldı)';
    } else if (damagePercentage < 25) {
      overallGrade = 'B (Temiz / Garanti Banko Araç)';
    } else if (damagePercentage < 45) {
      overallGrade = 'C (Masraflı / Sanayi Yolları Göründü)';
    } else {
      overallGrade = 'D (Ağır Hasarlı / Oyunu Yazan Yazılımcı Bile Şaşkın)';
    }

    final developerNotes = [
      'Geliştirici Notu: Bu aracı alanın kafasına meteor düşme ihtimali %0.01.',
      'Usta Notu: Valla oyunu yazan yazılımcı bile bu arabanın kazasız olduğuna inanmıyor!',
      'Ekspertiz Notu: Şasisi saat gibi ama saat de bozuk olabilir.',
      'Geliştirici Notu: Araçta sıfır boya var ama güneş yanığından renk görünmüyor.'
    ];
    final note = developerNotes[_random.nextInt(developerNotes.length)];

    return {
      'paintedCount': paintedCount,
      'changedCount': changedCount,
      'damagedCount': damagedCount,
      'damagePercentage': damagePercentage.clamp(0.0, 100.0),
      'fairMarketValue': fairMarketValue,
      'overallGrade': overallGrade,
      'developerNote': note,
    };
  }
}
