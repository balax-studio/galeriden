import 'dart:math';
import '../../../data/models/car_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import '../../../data/models/game_event_model.dart';
import '../../../data/models/offer_model.dart';

/// Pure domain usecase engine for daily rental progression, wear & tear,
/// traffic fines, accident damage, and tenant buyout proposals.
class RentalProgressionEngine {
  /// Processes daily rental income, incidents, and contract progression.
  static (double, List<CarModel>, List<RentalAgreement>, List<GameEventModel>, List<OfferModel>) processDailyRentals({
    required double balance,
    required List<CarModel> cars,
    required List<RentalAgreement> rentals,
    required List<GameEventModel> events,
    required List<OfferModel> incomingOffers,
    Random? random,
  }) {
    final rng = random ?? Random();
    final updatedCars = List<CarModel>.from(cars);
    final updatedRentals = List<RentalAgreement>.from(rentals);
    final updatedEvents = List<GameEventModel>.from(events);
    final updatedOffers = List<OfferModel>.from(incomingOffers);
    double currentBalance = balance;

    for (int i = updatedRentals.length - 1; i >= 0; i--) {
      final rental = updatedRentals[i];
      final insuranceFee = rental.hasInsurance ? rental.insuranceDailyFee : 0.0;
      final netDaily = (rental.dailyRate - insuranceFee).clamp(0.0, double.infinity);
      currentBalance += netDaily;

      final carIndex = updatedCars.indexWhere((c) => c.id == rental.carId);
      if (carIndex != -1) {
        CarModel car = updatedCars[carIndex];
        final riskMultiplier = rental.renterType == 'young_driver'
            ? 1.4
            : (rental.renterType == 'corporate' ? 0.2 : 0.6);
        final roll = rng.nextDouble();

        // EVENT ROLLS (Distinct rates & behaviors)
        // 1. EDS & Hız Radarı Cezası (%7.0 * multiplier)
        if (roll < 0.070 * riskMultiplier) {
          final fineBase = 4500.0 + rng.nextInt(4000);
          final actualCost = (rental.hasInsurance || rental.renterType == 'corporate')
              ? fineBase * 0.20
              : fineBase;
          currentBalance = (currentBalance - actualCost).clamp(0.0, double.infinity);
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_fine_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: RADAR & EDS CEZASI!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} ile hız sınırını aştı • ₺${fineBase.toInt()} ceza tebliğ edildi${rental.hasInsurance ? ' • Kasko ve kurumsal sözleşme sayesinde ₺${actualCost.toInt()} ödendi' : ''}.',
            type: GameEventType.expense,
            amount: -actualCost,
            date: DateTime.now(),
          ));
        }
        // 2. Düğün Konvoyu Yanlama & Şanzıman Hasarı (%4.5 * multiplier)
        else if (roll < 0.115 * riskMultiplier) {
          final repairDeductible = rental.hasInsurance ? 1000.0 : 4000.0;
          currentBalance = (currentBalance - repairDeductible).clamp(0.0, double.infinity);
          final newTrans = max(10.0, car.expertise.transmissionCondition - 20.0);
          final newEngine = max(10.0, car.expertise.engineCondition - 10.0);
          car = car.copyWith(
            isWashed: false,
            isPolished: false,
            expertise: car.expertise.copyWith(
              transmissionCondition: newTrans,
              engineCondition: newEngine,
            ),
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_drift_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KONVOYDA AŞIRI YIPRANMA!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} aracında debriyajı yakmış ve lastikleri eritmiş • -%20 Şanzıman, -%10 Motor • ₺${repairDeductible.toInt()} masraf.',
            type: GameEventType.expense,
            amount: -repairDeductible,
            date: DateTime.now(),
          ));
        }
        // 3. Ağır Kaza & Tramer Kaydı (%3.0 * multiplier)
        else if (roll < 0.145 * riskMultiplier) {
          final tramerAdd = 25000 + (rng.nextInt(5) * 5000);
          final outOfPocket = rental.hasInsurance ? 3000.0 : 12000.0;
          currentBalance = (currentBalance - outOfPocket).clamp(0.0, double.infinity);
          car = car.copyWith(
            expertise: car.expertise.copyWith(
              tramerAmount: car.expertise.tramerAmount + tramerAdd,
              engineCondition: max(10.0, car.expertise.engineCondition - 25.0),
              transmissionCondition: max(10.0, car.expertise.transmissionCondition - 15.0),
            ),
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_crash_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: TRAFİK KAZASI HASARI!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} ile refüje çarptı • +₺$tramerAdd Tramer işlendi${rental.hasInsurance ? ' • Ticari Kasko hasarı karşıladı • ₺3.000 muafiyet ödendi' : ' • Kasko olmadığı için ₺12.000 masraf yapıldı'}.',
            type: GameEventType.expense,
            amount: -outOfPocket,
            date: DateTime.now(),
          ));
        }
        // 4. Korsan Taşımacılık / Otoparka Çekilme (%1.5 * multiplier, kurumsal hariç)
        else if (roll < 0.160 * riskMultiplier && rental.renterType != 'corporate') {
          const impoundFine = 8000.0;
          currentBalance = (currentBalance - impoundFine).clamp(0.0, double.infinity);
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_impound_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KORSAN TAŞIMA & MEN!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} ile izinsiz yolcu taşırken polis çevirmesine girdi! Araç otoparka çekildi ve ₺8.000 idari ceza kesildi.',
            type: GameEventType.expense,
            amount: -impoundFine,
            date: DateTime.now(),
          ));
        }
        // 5. Bagajda Unutulan Değerli Eşya (%5.0 - Pozitif Ek Gelir)
        else if (roll < 0.210 * riskMultiplier) {
          const foundItemValue = 3500.0;
          currentBalance += foundItemValue;
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_found_item_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: BAGAJDA UNUTULAN EŞYA!',
            description: '${rental.renterName} bagajda lüks kol saati ve deri mont unuttu • Kiracıya ulaşılamadığı için eşyalar değerlendirildi • Kasaya +₺3.500 eklendi.',
            type: GameEventType.income,
            amount: foundItemValue,
            date: DateTime.now(),
          ));
        }
        // 6. Gelin Arabası Süslemesi & Bant İzleri (%5.0)
        else if (roll < 0.260 * riskMultiplier) {
          const cleanCost = 1200.0;
          currentBalance = (currentBalance - cleanCost).clamp(0.0, double.infinity);
          car = car.copyWith(
            isWashed: false,
            isPolished: false,
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_wedding_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: DÜĞÜN KONVOYU VE BANT İZİ!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} aracını gelin arabası yapmış • Çift taraflı bantlar verniğe yapışmış • ₺1.200 pasta cila masrafı yapıldı.',
            type: GameEventType.expense,
            amount: -cleanCost,
            date: DateTime.now(),
          ));
        }
        // 7. Geri Vites Yerine İleri Takıp Duvara Sürtme (%4.0)
        else if (roll < 0.300 * riskMultiplier) {
          final bumpCost = rental.hasInsurance ? 800.0 : 2500.0;
          currentBalance = (currentBalance - bumpCost).clamp(0.0, double.infinity);
          final newEngine = max(10.0, car.expertise.engineCondition - 5.0);
          car = car.copyWith(
            expertise: car.expertise.copyWith(engineCondition: newEngine),
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_wall_scrape_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: DUVARA SÜRTME KAZASI!',
            description: '${rental.renterName} AVM otoparkında geri vites yerine bire takıp ön tamponu duvara sürttü • ₺${bumpCost.toInt()} plastik onarım masrafı ödendi.',
            type: GameEventType.expense,
            amount: -bumpCost,
            date: DateTime.now(),
          ));
        }
        // 8. Köy Yolunda Karter Çatlağı (%3.5)
        else if (roll < 0.335 * riskMultiplier) {
          final sumpCost = rental.hasInsurance ? 1000.0 : 3800.0;
          currentBalance = (currentBalance - sumpCost).clamp(0.0, double.infinity);
          final newEngine = max(10.0, car.expertise.engineCondition - 15.0);
          car = car.copyWith(
            expertise: car.expertise.copyWith(engineCondition: newEngine),
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_sump_crack_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: TAŞLIK YOLDA KARTER HASARI!',
            description: '${rental.renterName} yayla yolunda altını taşa vurdu ve karteri patlattı • -%15 Motor • ₺${sumpCost.toInt()} karter ve yağ değişim masrafı.',
            type: GameEventType.expense,
            amount: -sumpCost,
            date: DateTime.now(),
          ));
        }
        // 9. Dalgınlıkla Yanlış Yakıt Doldurma (%2.5)
        else if (roll < 0.360 * riskMultiplier) {
          final fuelCost = rental.hasInsurance ? 1200.0 : 4200.0;
          currentBalance = (currentBalance - fuelCost).clamp(0.0, double.infinity);
          final newEngine = max(10.0, car.expertise.engineCondition - 10.0);
          car = car.copyWith(
            expertise: car.expertise.copyWith(engineCondition: newEngine),
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_wrong_fuel_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: YANLIŞ YAKIT FACİASI!',
            description: '${rental.renterName} yakıt alırken dalgınlıkla depoya yanlış yakıt doldurdu • Depo temizliği ve enjektör bakımı için ₺${fuelCost.toInt()} harcandı.',
            type: GameEventType.expense,
            amount: -fuelCost,
            date: DateTime.now(),
          ));
        }
        // 10. Valenin Sahilde Gazlaması (%3.0)
        else if (roll < 0.390 * riskMultiplier) {
          final newMileage = car.expertise.mileage + 250;
          final newTrans = max(10.0, car.expertise.transmissionCondition - 10.0);
          car = car.copyWith(
            expertise: car.expertise.copyWith(
              mileage: newMileage,
              transmissionCondition: newTrans,
            ),
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_valet_joyride_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: VALE GECE TURUNA ÇIKMIŞ!',
            description: '${rental.renterName} aracı restoranda valeye bırakmış • Vale gece sahilde turlayıp lastik yakmış • +250 KM yol, -%10 Şanzıman kondisyonu.',
            type: GameEventType.neutral,
            amount: 0,
            date: DateTime.now(),
          ));
        }
        // 11. Koltukta Çiğ Köfte Partisi & Nar Ekşisi (%4.0)
        else if (roll < 0.430 * riskMultiplier) {
          const detailCost = 1800.0;
          currentBalance = (currentBalance - detailCost).clamp(0.0, double.infinity);
          car = car.copyWith(
            isDetailedCleaned: false,
            isWashed: false,
          );
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_food_mess_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KOLTUKTA ÇİĞ KÖFTE LEKESİ!',
            description: '${rental.renterName} araç içinde çiğ köfte yerken koltuklara nar ekşisi dökmüş • Koltuk yıkama ve detaylı kuaför için ₺1.800 ödendi.',
            type: GameEventType.expense,
            amount: -detailCost,
            date: DateTime.now(),
          ));
        }
        // 12. Kiracının Kendi Cebinden Cam Filmi Taktırması (%3.5 - Pozitif Katkı)
        else if (roll < 0.465 * riskMultiplier) {
          final enhancedVal = car.baseMarketValue + 8000.0;
          car = car.copyWith(baseMarketValue: enhancedVal);
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_free_upgrade_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KİRACIDAN HEDİYE CAM FİLMİ!',
            description: '${rental.renterName} aracı çok beğenip kendi cebinden kaliteli Amerikan cam filmi çektirmiş • Araç piyasa değeri +₺8.000 arttı!',
            type: GameEventType.goodEvent,
            amount: 8000.0,
            date: DateTime.now(),
          ));
        }
        // 13. Çocukların Koltukları Pastel Boyayla Çizmesi (%3.5)
        else if (roll < 0.500 * riskMultiplier) {
          const leatherCost = 2200.0;
          currentBalance = (currentBalance - leatherCost).clamp(0.0, double.infinity);
          car = car.copyWith(isDetailedCleaned: false);
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_kids_drawing_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KOLTUKTA SANAT ESERİ!',
            description: '${rental.renterName} kiracısının çocukları arka deri koltukları pastel boyayla boyamış • Özel deri kimyasalları temizliği için ₺2.200 harcandı.',
            type: GameEventType.expense,
            amount: -leatherCost,
            date: DateTime.now(),
          ));
        }
        // 14. Trafikte Yan Ayna Kırılması (%3.0)
        else if (roll < 0.530 * riskMultiplier) {
          final mirrorCost = rental.hasInsurance ? 700.0 : 2900.0;
          currentBalance = (currentBalance - mirrorCost).clamp(0.0, double.infinity);
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_broken_mirror_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KIRIK YAN AYNA HASARI!',
            description: '${rental.renterName} dar sokakta geçerken sağ yan aynayı dubaya takıp kırdı • ₺${mirrorCost.toInt()} ayna değişim masrafı ödendi.',
            type: GameEventType.expense,
            amount: -mirrorCost,
            date: DateTime.now(),
          ));
        }
        // 15. Kiracının Aracı Satın Alma Teklifi (%6.0 şans)
        else if (roll > (1.0 - 0.060)) {
          final carVal = car.currentPurchasePrice > 0 ? car.currentPurchasePrice : car.baseMarketValue;
          final offerPrice = (carVal * 1.15).roundToDouble();
          final buyoutOffer = OfferModel(
            id: 'offer_rent_buyout_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            carId: car.id,
            buyerName: '${rental.renterName} • Kiracı',
            offeredAmount: offerPrice,
            buyerMessage: 'Aracınızdan son derece memnun kaldım. Kiralamayı bitirip aracı doğrudan satın almak istiyorum.',
            createdAt: DateTime.now(),
            offerType: OfferType.cash,
          );
          updatedOffers.insert(0, buyoutOffer);
          updatedEvents.insert(0, GameEventModel(
            id: 'rental_buyout_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRACIDAN SATIN ALMA TEKLİFİ!',
            description: '${rental.renterName}, kiraladığı ${car.brand} ${car.modelName} için piyasa değerinin %15 fazlasına • ₺${offerPrice.toInt()} peşin teklif sundu!',
            type: GameEventType.goodEvent,
            amount: offerPrice,
            date: DateTime.now(),
          ));
        }

        updatedCars[carIndex] = car;
      }
      updatedRentals[i] = rental.copyWith(
        rentedDays: rental.rentedDays + 1,
        totalEarned: rental.totalEarned + netDaily,
      );
    }
    return (currentBalance, updatedCars, updatedRentals, updatedEvents, updatedOffers);
  }
}
