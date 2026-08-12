import 'dart:math';
import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

class PurchaseRiskOutcome {
  final bool isTrapped;
  final String title;
  final String description;
  final CarModel updatedCar;

  const PurchaseRiskOutcome({
    required this.isTrapped,
    required this.title,
    required this.description,
    required this.updatedCar,
  });
}

class RiskEngine {
  static final Random _random = Random();

  /// Evaluates risk when a car is bought WITHOUT an expertise inspection.
  /// 30% chance of a hidden trap / defect.
  static PurchaseRiskOutcome evaluateUninspectedPurchaseRisk(CarModel car) {
    // 30% chance of trap
    final roll = _random.nextDouble();
    if (roll > 0.30) {
      return PurchaseRiskOutcome(
        isTrapped: false,
        title: 'Temiz Çıktı!',
        description: 'Şanslısın! Araçta herhangi bir gizli kusur bulunamadı.',
        updatedCar: car,
      );
    }

    final trapType = _random.nextInt(3);

    switch (trapType) {
      case 0:
        // Ağır Hasarlı / Şasi Eğik
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody['Şasi/Podye'] = PartStatus.damaged;
        updatedBody['Tavan'] = PartStatus.changed;

        final newExp = ExpertiseReport(
          engineCondition: (car.expertise.engineCondition * 0.70).clamp(20.0, 100.0),
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount + 185000,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );

        final newMarketPrice = (car.baseMarketValue * 0.65);

        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Ağır Hasarlı Çıktı!',
          description: 'Ekspertiz yaptırmadan aldığın araç meğer pertten dönmeymiş! Şasisi eğik ve ₺185.000 tramer kaydı çıktı (-%35 değer kaybı).',
          updatedCar: car.copyWith(
            expertise: newExp,
            baseMarketValue: newMarketPrice,
          ),
        );

      case 1:
        // Sahte KM / Sayaç Düşürülmüş
        final tamperedKm = car.expertise.mileage + 120000;
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: tamperedKm,
          isMileageTampered: true,
          bodyParts: car.expertise.bodyParts,
        );

        final newMarketPrice = (car.baseMarketValue * 0.80);

        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'KM Düşürülmüş!',
          description: 'Araç beyin taranınca gerçek kilometrenin +120.000 daha fazla olduğu anlaşıldı (-%20 değer kaybı).',
          updatedCar: car.copyWith(
            expertise: newExp,
            baseMarketValue: newMarketPrice,
          ),
        );

      case 2:
      default:
        // 4. Duvarı Yıkan Sürpriz
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody['Kaput'] = PartStatus.damaged;
        updatedBody['Motor'] = PartStatus.damaged;

        final newExp = ExpertiseReport(
          engineCondition: 40.0,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount + 95000,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );

        final newMarketPrice = (car.baseMarketValue * 0.70);

        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Satıcı Telefonu Kapattı!',
          description: 'Geliştirici Notu: "Usta ekspertiz yaptırmadan araç aldın, satıcı hattı çıkarıp attı! Araç sel hasarlı çıktı!"',
          updatedCar: car.copyWith(
            expertise: newExp,
            baseMarketValue: newMarketPrice,
          ),
        );
    }
  }
}
