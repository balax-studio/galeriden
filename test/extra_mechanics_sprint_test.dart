import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/gossip_item_model.dart';
import 'package:galeriden/data/models/trade_in_offer_model.dart';
import 'package:galeriden/data/models/weather_model.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';
import 'package:galeriden/domain/usecases/gossip_engine.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';
import 'package:galeriden/domain/usecases/trade_in_engine.dart';
import 'package:galeriden/domain/usecases/weather_engine.dart';

void main() {
  group('Extra Mechanics Sprint Tests (§4.6)', () {
    late CarModel testCar;
    late DealershipModel baseGame;

    setUp(() {
      testCar = CarModel(
        id: 'car_test_1',
        brand: 'Renault',
        modelName: 'Megane 1.5 dCi',
        modelYear: 2018,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 650000.0,
        currentPurchasePrice: 580000.0,
        expertise: ExpertiseReport(
          engineCondition: 88.0,
          transmissionCondition: 90.0,
          tramerAmount: 5000,
          mileage: 95000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      baseGame = DealershipModel.initial().copyWith(
        balance: 200000.0,
        ownedCars: [testCar],
      );
    });

    test('DealershipModel Serialization with Extra Mechanics fields', () {
      final tradeOffer = TradeInOfferModel(
        id: 'trade_1',
        targetCarId: testCar.id,
        targetCarName: testCar.modelName,
        customerName: 'Ahmet Bey',
        offeredCar: testCar.copyWith(id: 'car_trade_offered'),
        cashDifference: 45000.0,
        dialogText: 'Üstüne nakit vereyim takaslayalım.',
      );

      final gossip = GossipItemModel(
        id: 'gossip_1',
        type: GossipType.bargainTip,
        sourceNpc: 'necati',
        sourceNpcName: 'Çaycı Necati',
        sourceAvatar: 'necati_avatar',
        title: 'Sanayi Çay Ocağı',
        teaser: 'Kelepir haber var...',
        content: '3 sokak ötede ucuza Passat var.',
        cost: 2500.0,
        accuracy: 0.85,
        inGameDay: 1,
      );

      final game = baseGame.copyWith(
        incomingTradeInOffers: [tradeOffer],
        activeGossips: [gossip],
        currentWeather: WeatherType.rainy,
        consignmentOffers: [testCar.copyWith(id: 'consignment_car_1', isConsignment: true)],
      );

      final json = game.toJson();
      final reconstructed = DealershipModel.fromJson(json);

      expect(reconstructed.incomingTradeInOffers.length, 1);
      expect(reconstructed.incomingTradeInOffers.first.customerName, 'Ahmet Bey');
      expect(reconstructed.activeGossips.length, 1);
      expect(reconstructed.activeGossips.first.cost, 2500.0);
      expect(reconstructed.currentWeather, WeatherType.rainy);
      expect(reconstructed.consignmentOffers.length, 1);
    });

    test('TradeInEngine generates realistic trade-in offers', () {
      final offer = TradeInEngine.generateTradeInOffer(targetCar: testCar, inGameDay: 3);

      expect(offer.targetCarId, testCar.id);
      expect(offer.customerName.isNotEmpty, true);
      expect(offer.offeredCar.id.isNotEmpty, true);
      expect(offer.dialogText.isNotEmpty, true);
      expect(offer.expiresInDays, greaterThanOrEqualTo(2));
    });

    test('GossipEngine generates daily gossip pool', () {
      final gossips = GossipEngine.generateDailyGossips(1);

      expect(gossips.length, 4);
      for (final g in gossips) {
        expect(g.sourceNpcName.isNotEmpty, true);
        expect(g.content.isNotEmpty, true);
        expect(g.cost, greaterThan(0));
      }
    });

    test('WeatherEngine cycles weather and returns correct multipliers', () {
      final wDay1 = WeatherEngine.getWeatherForDay(1);
      final wDay3 = WeatherEngine.getWeatherForDay(3);
      final wDay5 = WeatherEngine.getWeatherForDay(5);
      final wDay7 = WeatherEngine.getWeatherForDay(7);

      expect(wDay1, WeatherType.sunny);
      expect(wDay3, WeatherType.rainy);
      expect(wDay5, WeatherType.foggy);
      expect(wDay7, WeatherType.snowy);

      expect(WeatherType.rainy.carWashDemandMultiplier, greaterThan(1.0));
      expect(WeatherType.snowy.suvDemandMultiplier, greaterThan(1.0));
      expect(WeatherType.sunny.sportCarDemandMultiplier, greaterThan(1.0));
    });

    test('ConsignmentEngine generates consignment offers with zero capital', () {
      final offers = ConsignmentEngine.generateConsignmentOffers(inGameDay: 2);

      expect(offers.isNotEmpty, true);
      for (final offer in offers) {
        expect(offer.isConsignment, true);
        expect(offer.consignmentCommissionRate, greaterThan(0.05));
        expect(offer.consignmentOwnerName!.isNotEmpty, true);
        expect(offer.consignmentDaysRemaining, greaterThan(0));

        final commission = ConsignmentEngine.calculateCommissionEarnings(offer, offer.estimatedRealValue);
        expect(commission, greaterThan(0));
      }
    });

    test('NightMarketEngine simulates street race with hp & condition weights', () {
      final fastCar = testCar.copyWith(
        expertise: testCar.expertise.copyWith(engineCondition: 100.0),
      );

      final result = NightMarketEngine.simulateNightRace(fastCar);

      expect(result.raceLog.isNotEmpty, true);
      if (result.isWon) {
        expect(result.prizeMoney, greaterThanOrEqualTo(25000.0));
        expect(result.reputationBonus, greaterThan(0));
      }
    });
  });
}
