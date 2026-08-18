import 'dart:math';
import '../../core/utils/currency_formatter.dart';
import '../../data/models/car_model.dart';
import '../../data/models/trade_in_offer_model.dart';
import 'market_engine.dart';

class TradeInEngine {
  static final _random = Random();

  static const List<String> _customerNames = [
    'Taksici Selim Abi',
    'Müteahhit Ekrem Bey',
    'Esnaf Rıza Usta',
    'Genç Memur Emre',
    'Koleksiyoner Tarık Bey',
    'Doktor Cihan',
    'Galerici Kardeşler Halil',
    'Sanayici Muzaffer Usta',
    'Öğretmen Burak Bey',
    'Mimar Selen Hanım',
  ];

  static const List<String> _absurdDialoguesHighDiff = [
    'Usta bendeki araba dağa taşa gelir, sanayide parçası bedava! Senin araçla takaslayalım, üstüne de kalan farkı nakit bağlayalım.',
    'Usta araba dediğin ayağını yerden kessin yeter. Bendeki tank gibidir! Senin araç ile kafa kafaya ya da ufak bir farkla anlaşalım.',
    'Bendeki nostalji klasiğidir, değeri her gün artar! Senin araç ile takas teklif ediyorum, üstüne kalan farkı nakit veririm.',
    'Usta motoru canavar gibi, dağa taşa tırmanır! Senin araçla takaslayalım, farkını da tatlıya bağlarız.',
  ];

  /// Generates a realistic customer trade-in offer for a vehicle in the showroom (§4.6.2)
  static TradeInOfferModel generateTradeInOffer({
    required CarModel targetCar,
    required int inGameDay,
  }) {
    final customerName = _customerNames[_random.nextInt(_customerNames.length)];

    // 8% chance of an absurd / humorous low-tier trade offer (e.g. Toros for Lambo)
    final isAbsurdTrade = _random.nextDouble() < 0.08;

    CarModel candidateCar;

    if (isAbsurdTrade) {
      // Pick a random budget or starter listing regardless of target car value
      final listings = MarketEngine.generateRandomListings(
        count: 5,
        playerBalance: 60000.0,
      );
      candidateCar = listings.isNotEmpty ? listings[_random.nextInt(listings.length)].car : listings.first.car;
    } else {
      // 92% Realistic Trade: match target vehicle value range (0.40x to 1.80x)
      final targetRealVal = targetCar.estimatedRealValue;
      final listings = MarketEngine.generateRandomListings(
        count: 10,
        playerBalance: targetRealVal,
      );

      final minAcceptable = targetRealVal * 0.40;
      final maxAcceptable = targetRealVal * 1.80;

      final matchedCars = listings
          .map((l) => l.car)
          .where((c) => c.estimatedRealValue >= minAcceptable && c.estimatedRealValue <= maxAcceptable)
          .toList();

      if (matchedCars.isNotEmpty) {
        candidateCar = matchedCars[_random.nextInt(matchedCars.length)];
      } else {
        // Fallback to the car closest to the target vehicle's real value
        listings.sort((a, b) =>
            (a.car.estimatedRealValue - targetRealVal).abs().compareTo((b.car.estimatedRealValue - targetRealVal).abs()));
        candidateCar = listings.first.car;
      }
    }

    // Create trade-in car model with unique ID
    final offeredCar = candidateCar.copyWith(
      currentPurchasePrice: candidateCar.estimatedRealValue * 0.85,
    );

    // Calculate cash difference: (Player's target car asking price) - (Offered car estimated real value)
    final targetValue = targetCar.isListed && targetCar.listingPrice > 0 ? targetCar.listingPrice : targetCar.estimatedRealValue;
    final offeredValue = offeredCar.estimatedRealValue;
    final fairDiff = targetValue - offeredValue;

    // Customer negotiates slightly in their own favor (%88 to %108 of fair diff)
    final cashDiff = (fairDiff * (0.88 + _random.nextDouble() * 0.20)).roundToDouble();

    String dialogue;
    if (isAbsurdTrade && fairDiff > 250000) {
      final template = _absurdDialoguesHighDiff[_random.nextInt(_absurdDialoguesHighDiff.length)];
      dialogue = template
          .replaceAll('bendeki araba', 'bendeki ${offeredCar.modelName}')
          .replaceAll('Bendeki', 'Bendeki ${offeredCar.modelName}')
          .replaceAll('Senin araçla', 'Senin ${targetCar.modelName} ile')
          .replaceAll('Senin araç', 'Senin ${targetCar.modelName}');
    } else if (cashDiff > 0) {
      dialogue = 'Usta senin ${targetCar.modelName} tam bana göre. Benim ${offeredCar.modelName} üzerine ${CurrencyFormatter.formatShort(cashDiff)} nakit vereyim, el sıkışalım.';
    } else if (cashDiff < 0) {
      dialogue = 'Benim ${offeredCar.modelName} daha lüks. Senin ${targetCar.modelName} ile takaslarım ama ${CurrencyFormatter.formatShort(-cashDiff)} üste para alırım.';
    } else {
      dialogue = 'Kafa kafaya anahtar takası yapalım usta • İki araç da birbirine denk!';
    }

    return TradeInOfferModel(
      id: 'trade_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}',
      customerName: customerName,
      targetCarId: targetCar.id,
      targetCarName: targetCar.modelName,
      offeredCar: offeredCar,
      cashDifference: cashDiff,
      dialogueText: dialogue,
      inGameDay: inGameDay,
    );
  }
}
