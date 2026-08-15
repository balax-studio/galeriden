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
    
    // Tavan veya Şasi boyalı/değişen ise Türk pazarında özel takla/ağır hasar algısı oluşur
    final roofStatus = exp.bodyParts['Tavan'];
    if (roofStatus != null && roofStatus != PartStatus.original) {
      damagePercentage += (roofStatus == PartStatus.painted ? 10.0 : 20.0);
    }

    damagePercentage += (100.0 - exp.engineCondition) * 0.4;
    damagePercentage += (100.0 - exp.transmissionCondition) * 0.3;

    double fairMarketValue = car.baseMarketValue * (1.0 - (damagePercentage / 100.0).clamp(0.0, 0.65));

    String overallGrade;
    if (damagePercentage < 10) {
      overallGrade = 'A+ (Kusursuz / Koleksiyonluk)';
    } else if (damagePercentage < 22) {
      overallGrade = 'A (Temiz / Masrafsız)';
    } else if (damagePercentage < 35) {
      overallGrade = 'B (İyi Durumda / Lokal Boyalı)';
    } else if (damagePercentage < 50) {
      overallGrade = 'C (Orta / Bakım Gerekli)';
    } else {
      overallGrade = 'D (Ağır Hasarlı / Onarım Gerekli)';
    }

    final developerNotes = [
      'Ekspertiz Notu: Motor ve şanzıman performansı iyi durumda, mekanik masrafı bulunmamaktadır.',
      'Ekspertiz Notu: Kaporta aksamında parçalı boyalar mevcut, şasi ve podyeler tamamen orijinaldir.',
      'Ekspertiz Notu: Hasar geçmişi nedeniyle değer kaybı mevcut, yürüyen aksam bakımı tavsiye edilir.',
      'Ekspertiz Notu: Detaylı kaporta onarımı ve periyodik bakım sonrasında değer artışı sağlanabilir.'
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
