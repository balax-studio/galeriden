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

    final trapType = _random.nextInt(23);

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
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Ağır Hasarlı Çıktı!',
          description: 'Ekspertiz yaptırmadan aldığın araç meğer pertten dönmeymiş! Şasisi eğik ve ₺185.000 tramer kaydı çıktı (-%35 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.65),
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
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'KM Düşürülmüş!',
          description: 'Araç beyin taranınca gerçek kilometrenin +120.000 daha fazla olduğu anlaşıldı (-%20 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.80),
        );

      case 2:
        // Taksi Çıkması
        final newExp = ExpertiseReport(
          engineCondition: 30.0,
          transmissionCondition: 35.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage + 450000,
          isMileageTampered: true,
          bodyParts: car.expertise.bodyParts.map((k, v) => MapEntry(k, PartStatus.painted)), // All painted
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Taksi Çıkması!',
          description: 'Orijinal boyanın altından sarı boya çıktı! Araç 5 yıl takside çalışmış (-%45 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.55),
        );

      case 3:
        // Hacizli / Yakalamalı
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Hacizli Araç!',
          description: 'Notere gidince aracın üzerinde haciz ve yakalama kararı olduğu ortaya çıktı. Cezaları ödemek zorunda kaldın (-%25 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.75),
        );

      case 4:
        // Çalıntı Motor
        final newExp = ExpertiseReport(
          engineCondition: 20.0,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Çalıntı Motor Bloğu!',
          description: 'Motor numarasının kazındığı ve çalıntı bir blok takıldığı tespit edildi. Yasal süreç ve değişim masrafı yıktı geçti (-%40 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.60),
        );

      case 5:
        // Tramer Gizlenmiş (Yanlış Şasi)
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount + 250000,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Yanlış Şasi Numarasıyla Sorgu!',
          description: 'Satıcı plakadan hasar kaydı yok demişti, şasi numarasından sorgulatınca ₺250.000 Ağır Hasar Kaydı çıktı! (-%30 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.70),
        );

      case 6:
        // Airbag İşlemli
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Airbagler İşlemli!',
          description: 'Direksiyon ve torpido kaplanmış, hava yastıkları iptal edilip direnç atılmış! Ölüm tehlikesi ve ciddi değer kaybı (-%35 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.65),
        );

      case 7:
        // Şanzıman Dağıldı
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: 15.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Eve Giderken Şanzıman Dağıldı!',
          description: 'Aracı alıp yola çıktın, 10 km sonra şanzıman kendini kilitledi. Komple revizyon gerekiyor (-%20 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.80),
        );

      case 8:
        // Conta Yanık
        final newExp = ExpertiseReport(
          engineCondition: 10.0,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Conta Yanık & Su Eksiltme!',
          description: 'Motora kalın yağ koyup sesi kesmişler. Galeriye dönerken hararet yaptı, motor rektifiye istiyor (-%25 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.75),
        );

      case 9:
        // Çekme Belgeli
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Çekme Belgeli Çıktı!',
          description: 'Araç trafikten men edilmiş ve çekme belgeli! Muayene, vergi borçları ve tekrar trafiğe sokma masrafları belini büktü (-%15 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.85),
        );

      case 10:
        // İkiz Plaka (Change Araç)
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Change (İkiz) Araç!',
          description: 'Aynı renk ve model başka bir aracın şasi numarası kopyalanmış (Change). Emniyet araca el koydu, zor kurtardın (-%55 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.45),
        );

      case 11:
        // Komple Boyalı - Macun Yığını
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody.updateAll((key, value) => PartStatus.changed);
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Yürüyen Macun Yığını!',
          description: '"Güneş yanığından boyalı" dedikleri araç komple değişenli ve macun yığını çıktı (-%30 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.70),
        );

      case 12:
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Gizli Vergi Borcu!',
          description: 'Noter devrinden sonra aracın sistemde gizlenmiş ciddi vergi ve trafik cezası borcu çıktı. Mecburen sen ödedin (-%15 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.85),
        );

      case 13:
        final newExp = ExpertiseReport(
          engineCondition: 15.0,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Kayıt Dışı Motor Değişimi!',
          description: 'Ruhsattaki motor numarasıyla araçtaki birbirini tutmuyor. Proje çizdirip ruhsata işletmek aylarca sürdü (-%25 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.75),
        );

      case 14:
        final newExp = ExpertiseReport(
          engineCondition: 25.0,
          transmissionCondition: 30.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isEcuCleaned: false,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Sel Hasarlı!',
          description: 'Araç içi taban halısının altı çamur dolu ve tüm elektronik beyinler paslanmış. Araç sel hasarlı çıktı! (-%40 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.60),
        );

      case 15:
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody['Şasi/Podye'] = PartStatus.damaged;
        updatedBody['Tavan'] = PartStatus.changed;
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Ekleme Araç (İki Araç Birleşmiş)!',
          description: 'İki farklı kazalı aracın şasisi ortadan kaynatılıp birleştirilmiş! Araç tam bir saatli bomba (-%50 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.50),
        );

      case 16:
        final newExp = ExpertiseReport(
          engineCondition: 35.0,
          transmissionCondition: 35.0,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage + 300000,
          isMileageTampered: true,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Filo Kiralama Çıkması!',
          description: 'Tertemiz sandığın araç, yıllarca rent-a-car şirketinde yüzlerce farklı kişide hor kullanılmış (-%20 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.80),
        );

      case 17:
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody.updateAll((key, value) => value == PartStatus.original ? PartStatus.original : PartStatus.changed);
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Yan Sanayi Parça Tuzağı!',
          description: '"Orijinal" denilen tüm parçalar en ucuz yan sanayi plastikleriyle değiştirilmiş (-%20 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.80),
        );

      case 18:
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Banka Rehni Kalkmamış!',
          description: 'Eski sahibinin banka kredisi rehni sistemde kalmış. Satışı geri almak için günlerce mahkemede uğraştın (-%10 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.90),
        );

      case 19:
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Kaçakçılık Zulası Çıktı!',
          description: 'Bagaj pandizotunda gizli zula bulundu! Polis aracı günlerce kriminal incelemede tuttu, her yeri söküldü (-%30 değer kaybı).',
          updatedCar: car.copyWith(baseMarketValue: car.baseMarketValue * 0.70),
        );

      case 20:
        final newExp = ExpertiseReport(
          engineCondition: 20.0,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isEcuCleaned: false,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: car.expertise.bodyParts,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Kronik Beyin (ECU) Arızası!',
          description: 'Kontağı kapattıktan sonra motor beyninin sıfırlandığı ve kronik arızası olduğu ortaya çıktı (-%15 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.85),
        );

      case 21:
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody.updateAll((key, value) => value == PartStatus.original ? PartStatus.painted : value);
        final newExp = ExpertiseReport(
          engineCondition: car.expertise.engineCondition,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Kusurlu Boya İşçiliği (Portakal Kabuğu)!',
          description: 'Güneş altında bakınca aracın boyasının çok kötü atıldığı ve portakal kabuğu görünümü yaptığı anlaşıldı (-%10 değer kaybı).',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.90),
        );

      case 22:
      default:
        // 4. Duvarı Yıkan Sürpriz
        final updatedBody = Map<String, PartStatus>.from(car.expertise.bodyParts);
        updatedBody['Kaput'] = PartStatus.damaged;
        updatedBody['Şasi/Podye'] = PartStatus.damaged;

        final newExp = ExpertiseReport(
          engineCondition: 40.0,
          transmissionCondition: car.expertise.transmissionCondition,
          tramerAmount: car.expertise.tramerAmount + 95000,
          mileage: car.expertise.mileage,
          isMileageTampered: car.expertise.isMileageTampered,
          bodyParts: updatedBody,
        );
        return PurchaseRiskOutcome(
          isTrapped: true,
          title: 'Satıcı Telefonu Kapattı!',
          description: 'Geliştirici Notu: "Usta ekspertiz yaptırmadan araç aldın, satıcı hattı çıkarıp attı! Araç sel hasarlı çıktı!"',
          updatedCar: car.copyWith(expertise: newExp, baseMarketValue: car.baseMarketValue * 0.70),
        );
    }
  }
}
