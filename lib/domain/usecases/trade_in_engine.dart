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
  ];

  /// Generates a realistic customer trade-in offer for a vehicle in the showroom (§4.6.2)
  static TradeInOfferModel generateTradeInOffer({
    required CarModel targetCar,
    required int inGameDay,
  }) {
    final customerName = _customerNames[_random.nextInt(_customerNames.length)];

    // Generate customer's offered vehicle (typically slightly older or different segment)
    final candidateCar = MarketEngine.generateRandomListings(
      count: 1,
    ).first.car;

    // Create trade-in car model with unique ID
    final offeredCar = candidateCar.copyWith(
      currentPurchasePrice: candidateCar.estimatedRealValue * 0.85,
    );

    // Calculate cash difference: (Player's target car value) - (Offered car value)
    final targetValue = targetCar.listingPrice;
    final offeredValue = offeredCar.estimatedRealValue;
    final fairDiff = targetValue - offeredValue;

    // Customer negotiates slightly in their own favor (%88 to %108 of fair diff)
    final cashDiff = (fairDiff * (0.88 + _random.nextDouble() * 0.20)).roundToDouble();

    String dialogue;
    if (cashDiff > 0) {
      dialogue = 'Usta senin ${targetCar.modelName} tam bana göre. Benim ${offeredCar.modelName} üzerine ${CurrencyFormatter.formatShort(cashDiff)} nakit vereyim, el sıkışalım.';
    } else if (cashDiff < 0) {
      dialogue = 'Benim ${offeredCar.modelName} daha lüks. Senin ${targetCar.modelName} ile takaslarım ama ${CurrencyFormatter.formatShort(-cashDiff)} üste para alırım.';
    } else {
      dialogue = 'Kafa kafaya anahtar takası yapalım usta, iki araç da birbirine denk!';
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
