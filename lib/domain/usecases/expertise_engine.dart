import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

enum ExpertiseTier {
  gozKarari,   // Tier 0: Ücretsiz, %40 belirsizlik riski
  sanayiUstasi, // Tier 1: %0.4 araç bedeli, %85 doğruluk
  kurumsal,    // Tier 2: %1.2 araç bedeli, %100 kesin rapor + tramer/şasi/km
}

class ExpertiseEngine {
  static final Random _random = Random();

  /// Calculates dynamic percentage-based expertise inspection fee (§1.3 / §2.3)
  static double calculateTierFee(CarModel car, ExpertiseTier tier) {
    final base = car.baseMarketValue;
    switch (tier) {
      case ExpertiseTier.gozKarari:
        return 0.0;
      case ExpertiseTier.sanayiUstasi:
        // %0.4 fee (min 500 TL)
        return max(500.0, (base * 0.004).roundToDouble());
      case ExpertiseTier.kurumsal:
        // %1.2 fee (min 1.500 TL)
        return max(1500.0, (base * 0.012).roundToDouble());
    }
  }

  /// Check if player's eyeForDetail skill detects hidden defects without full expertise
  static bool detectHiddenTampering(CarModel car, int eyeForDetailLevel) {
    if (!car.expertise.isMileageTampered) return false;
    double chance = eyeForDetailLevel * 0.10; // Level 1 = 10%, Level 10 = 100%
    return _random.nextDouble() < chance;
  }

  /// Performs tiered inspection returning accuracy-adjusted report view
  static Map<String, dynamic> performTieredInspection({
    required CarModel car,
    required ExpertiseTier tier,
    int eyeForDetailLevel = 0,
  }) {
    final exp = car.expertise;
    final fee = calculateTierFee(car, tier);
    final evaluation = evaluateVehicle(car);

    switch (tier) {
      case ExpertiseTier.gozKarari:
        // High uncertainty: Hidden chassis/tampering might not be revealed
        final detectedTampering = detectHiddenTampering(car, eyeForDetailLevel);
        return {
          'tier': tier,
          'tierTitle': 'Göz Kararı İnceleme',
          'fee': 0.0,
          'accuracyPercent': 45 + (eyeForDetailLevel * 5),
          'revealedMileage': detectedTampering ? exp.mileage : (exp.isMileageTampered ? exp.mileage - 75000 : exp.mileage),
          'isTamperingDetected': detectedTampering,
          'isChassisVerified': false,
          'tramerVerified': false,
          'confidenceMessage': 'Sadece dıştan yüzeysel bakıldı. Gizli hasar veya şasi kusuru olabilir.',
          'evaluation': evaluation,
        };

      case ExpertiseTier.sanayiUstasi:
        // 85% accuracy
        final detected = exp.isMileageTampered ? _random.nextDouble() < 0.85 : false;
        return {
          'tier': tier,
          'tierTitle': 'Sanayi Ustası Kontrolü',
          'fee': fee,
          'accuracyPercent': 85,
          'revealedMileage': exp.mileage,
          'isTamperingDetected': detected,
          'isChassisVerified': true,
          'tramerVerified': false,
          'confidenceMessage': 'Usta motor sesini dinledi, şasiye ve kaportaya baktı. Güvenilir.',
          'evaluation': evaluation,
        };

      case ExpertiseTier.kurumsal:
        // 100% full accuracy + Tramer + Dyno
        return {
          'tier': tier,
          'tierTitle': 'Kurumsal TSE Belgeli Ekspertiz',
          'fee': fee,
          'accuracyPercent': 100,
          'revealedMileage': exp.mileage,
          'isTamperingDetected': exp.isMileageTampered,
          'isChassisVerified': true,
          'tramerVerified': true,
          'confidenceMessage': 'Dyno, lift, şasi lazer ve beyin taraması yapıldı. Rapor %100 garantili.',
          'evaluation': evaluation,
        };
    }
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
