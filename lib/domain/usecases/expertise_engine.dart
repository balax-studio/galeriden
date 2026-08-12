import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

class ExpertiseEngine {
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
      overallGrade = 'A+ (Koleksiyonluk / Çil Çil)';
    } else if (damagePercentage < 25) {
      overallGrade = 'B (Temiz / Düzgün)';
    } else if (damagePercentage < 45) {
      overallGrade = 'C (Masraflı / Bakım İster)';
    } else {
      overallGrade = 'D (Ağır Hasarlı / Toplanmalı)';
    }

    return {
      'paintedCount': paintedCount,
      'changedCount': changedCount,
      'damagedCount': damagedCount,
      'damagePercentage': damagePercentage.clamp(0.0, 100.0),
      'fairMarketValue': fairMarketValue,
      'overallGrade': overallGrade,
    };
  }
}
