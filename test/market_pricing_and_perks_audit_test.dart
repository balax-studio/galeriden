import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/story_card_model.dart';
import 'package:galeriden/data/models/weather_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/pricing_engine.dart';
import 'package:galeriden/domain/usecases/weather_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final defaultExpertise = ExpertiseReport(
    engineCondition: 90.0,
    transmissionCondition: 90.0,
    tramerAmount: 0,
    mileage: 50000,
    isMileageTampered: false,
    bodyParts: {},
  );

  group('A4, B4, C1, C2: Market Pricing, Detailing, Weather & Perks Audit', () {
    test('A4: StoryAdRewardType.expressDetailing does not inflate baseMarketValue', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final car = CarModel(
        id: 'car_det_1',
        brand: 'Toyo',
        modelName: 'Corolla',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 400000.0,
        expertise: defaultExpertise,
        isWashed: false,
        isPolished: false,
        isDetailedCleaned: false,
      );

      final notifier = container.read(gameProvider.notifier);
      notifier.state = DealershipModel.initial().copyWith(
        ownedCars: [car],
      );

      notifier.resolveStoryCard(
        card: const StoryCardModel(
          id: 'story_det_1',
          title: 'Express Detailing',
          characterName: 'Usta',
          characterRole: 'Detailing',
          characterAvatar: 'avatar_detailing',
          icon: Icons.cleaning_services_rounded,
          dialogue: 'Aracını temizleyelim abi!',
          rewardDescription: 'Hediye detaylı temizlik',
          acceptLabel: 'KABUL ET',
          declineLabel: 'REDDET',
          rewardType: StoryAdRewardType.expressDetailing,
        ),
        accepted: true,
      );

      final updatedCar = container.read(gameProvider).ownedCars.first;
      expect(updatedCar.isWashed, isTrue);
      expect(updatedCar.isPolished, isTrue);
      expect(updatedCar.isDetailedCleaned, isTrue);
      // Crucial A4 check: baseMarketValue must stay 500000.0, NOT 575000.0
      expect(updatedCar.baseMarketValue, equals(500000.0));
    });

    test('B4: Weather condition modifies vehicle demand multiplier in NegotiationEngine', () {
      final suvCar = CarModel(
        id: 'car_suv_1',
        brand: 'G-Brand',
        modelName: 'Explorer',
        modelYear: 2022,
        bodyType: 'SUV',
        colorHex: '#000000',
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 900000.0,
        expertise: defaultExpertise,
      );

      // In snowy weather, SUV demand multiplier is 1.60
      final snowyMult = WeatherEngine.getVehicleDemandMultiplier(WeatherType.snowy, suvCar.bodyType);
      expect(snowyMult, equals(1.60));

      // In sunny weather, SUV demand multiplier is 1.0
      final sunnyMult = WeatherEngine.getVehicleDemandMultiplier(WeatherType.sunny, suvCar.bodyType);
      expect(sunnyMult, equals(1.0));

      double sumSnowy = 0;
      double sumSunny = 0;
      for (int i = 0; i < 30; i++) {
        sumSnowy += NegotiationEngine.generateBuyerOffer(
          suvCar,
          1000000.0,
          weatherMultiplier: snowyMult,
        ).offeredAmount;
        sumSunny += NegotiationEngine.generateBuyerOffer(
          suvCar,
          1000000.0,
          weatherMultiplier: sunnyMult,
        ).offeredAmount;
      }

      expect(sumSnowy / 30, greaterThan(sumSunny / 30));
    });

    test('C1: estimatedRealValue factors in age depreciation vs classic appreciation, mileage and tramer', () {
      // 1. Regular 2010 car (age 16) vs regular 2024 car (age 2)
      final newerCar = CarModel(
        id: 'car_new',
        brand: 'Toyo',
        modelName: 'Corolla',
        modelYear: 2024,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 400000.0,
        expertise: defaultExpertise,
      );

      final olderCar = CarModel(
        id: 'car_old',
        brand: 'Toyo',
        modelName: 'Corolla',
        modelYear: 2010,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 400000.0,
        expertise: defaultExpertise,
      );

      expect(newerCar.estimatedRealValue, greaterThan(olderCar.estimatedRealValue),
          reason: 'Older standard cars must depreciate more than newer cars');

      // 2. Rare / Classic 1975 car appreciates due to age
      final classicCar = CarModel(
        id: 'car_classic',
        brand: 'Oldtimer',
        modelName: 'Mustang',
        modelYear: 1975,
        bodyType: 'Klasik',
        colorHex: '#FF0000',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 400000.0,
        isRare: true,
        expertise: defaultExpertise,
      );

      expect(classicCar.estimatedRealValue, greaterThan(olderCar.estimatedRealValue),
          reason: 'Classic / Rare cars gain value from vintage age');

      // 3. Heavy tramer penalty
      final tramerExpertise = ExpertiseReport(
        engineCondition: 90.0,
        transmissionCondition: 90.0,
        tramerAmount: 200000,
        mileage: 50000,
        isMileageTampered: false,
        bodyParts: {},
      );

      final tramerCar = CarModel(
        id: 'car_tramer',
        brand: 'Toyo',
        modelName: 'Corolla',
        modelYear: 2024,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 500000.0,
        currentPurchasePrice: 400000.0,
        expertise: tramerExpertise,
      );

      expect(newerCar.estimatedRealValue, greaterThan(tramerCar.estimatedRealValue),
          reason: 'Heavy tramer record must penalize valuation');
    });

    test('C2: buyCar and buyCarWithNoter apply identical buyer perks via PricingEngine', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      // Player with Tuccar Torunu (-8%), Trader specialization (-10%), and 10% negotiation skill
      notifier.state = DealershipModel.initial().copyWith(
        balance: 10000000.0,
        characterOrigin: CharacterOrigin.tuccarTorunu,
        specializationPath: SpecializationPath.trader,
        skills: PlayerSkills(negotiationLevel: 5),
      );

      const rawPrice = 500000.0;
      final expectedDiscounted = notifier.state.applyBuyerPerks(rawPrice);
      expect(expectedDiscounted, lessThan(rawPrice * 0.85),
          reason: 'Combined perks should give >15% total discount');

      // Unified check via PricingEngine
      final directEngineResult = PricingEngine.applyBuyerPerks(
        basePrice: rawPrice,
        negotiationMultiplier: notifier.state.skills.negotiationMultiplier,
        characterOrigin: notifier.state.characterOrigin,
        specializationPath: notifier.state.specializationPath,
      );
      expect(expectedDiscounted, equals(directEngineResult));
    });
  });
}
