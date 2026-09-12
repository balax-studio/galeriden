import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/sale_record_model.dart';
import 'package:galeriden/domain/usecases/mentor_quest_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';

void main() {
  group('Retention Recovery Roadmap Tests (§SPEC-2026-09-12-RETENTION-RECOVERY-ROADMAP)', () {
    late DealershipModel baseGame;

    setUp(() {
      baseGame = DealershipModel.initial().copyWith(tutorialCompleted: true);
    });

    test('Aşama 2: Seviye 1 oyuncusu çevrimdışıyken kira ve vergi kesilmez, bakiyesi korunur', () {
      final initialBalance = baseGame.balance;
      final now = DateTime.now();
      // Oyuncu 2 saat (120 dakika) çevrimdışı kalmış
      final pastTime = now.subtract(const Duration(minutes: 120));
      final testGame = baseGame.copyWith(
        lastActiveTime: pastTime,
        level: 1,
      );

      final result = OfflineProgression.processOfflineTime(testGame, currentTime: now);
      final updatedGame = result['updatedDealership'] as DealershipModel;

      expect(result['daysElapsed'], 3); // 120 dk / 30 = 3 gün
      expect(result['expensesPaid'], 0.0);
      expect(updatedGame.balance, initialBalance);
    });

    test('Aşama 2: Seviye 1 oyuncusunun vitrinde ilanı varsa 2 saatte en az 2 teklif birikir', () {
      final now = DateTime.now();
      final pastTime = now.subtract(const Duration(minutes: 120));

      final testCar = CarModel(
        id: 'test_car_1',
        brand: 'Renault',
        modelName: 'Clio',
        modelYear: 2020,
        bodyType: 'Hatchback',
        colorHex: '0xFFFFFFFF',
        colorDisplayName: 'Beyaz',
        colorRarity: 'common',
        plateNumber: '34 TEST 01',
        plateRarity: 'standard',
        baseMarketValue: 600000.0,
        currentPurchasePrice: 550000.0,
        customListingPrice: 620000.0, // isListed = true
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {'Kaput': PartStatus.original},
        ),
      );

      final testGame = baseGame.copyWith(
        lastActiveTime: pastTime,
        level: 1,
        ownedCars: [testCar],
      );

      final result = OfflineProgression.processOfflineTime(testGame, currentTime: now);
      final updatedGame = result['updatedDealership'] as DealershipModel;

      expect(result['newOffersCount'], greaterThanOrEqualTo(2));
      expect(updatedGame.incomingOffers.length, greaterThanOrEqualTo(2));
    });

    test('Aşama 3: Halil Usta anlatı görev zinciri Seviye 1-2 için erişilebilir şekilde akar', () {
      // 1. Görev: Pazardan ilk aracı alma görevi aktif olmalıdır
      var activeQuest = MentorQuestEngine.getActiveQuest(baseGame);
      expect(activeQuest, isNotNull);
      expect(activeQuest!.id, MentorQuestEngine.questFirstPurchase);
      expect(activeQuest.isCompleted, isFalse);

      // Pazardan araba alınınca ilk görev tamamlanır
      final boughtCar = CarModel(
        id: 'bought_car_1',
        brand: 'Fiat',
        modelName: 'Egea',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        colorDisplayName: 'Siyah',
        colorRarity: 'common',
        plateNumber: '34 EGEA 01',
        plateRarity: 'standard',
        baseMarketValue: 700000.0,
        currentPurchasePrice: 650000.0,
        expertise: ExpertiseReport(
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          mileage: 40000,
          isMileageTampered: false,
          bodyParts: const {'Kaput': PartStatus.original},
        ),
      );

      var updatedGame = MentorQuestEngine.onCarPurchased(baseGame, boughtCar, 650000.0);
      activeQuest = MentorQuestEngine.getActiveQuest(updatedGame);
      expect(activeQuest, isNotNull);
      expect(activeQuest!.id, MentorQuestEngine.questFirstPurchase);
      expect(activeQuest.isCompleted, isTrue);

      // 1. Görevin ödülü toplanır
      updatedGame = MentorQuestEngine.claimQuestReward(updatedGame, activeQuest.id);

      // 2. Görev: İlk kârlı satış görevi devreye girer
      activeQuest = MentorQuestEngine.getActiveQuest(updatedGame);
      expect(activeQuest, isNotNull);
      expect(activeQuest!.id, MentorQuestEngine.questFirstProfitSale);
      expect(activeQuest.isCompleted, isFalse);

      // Kârlı satış gerçekleştiğinde 2. görev tamamlanır
      final profitSale = SaleRecordModel(
        id: 'sale_1',
        carTitle: 'Fiat Egea',
        buyerName: 'Ahmet Bey',
        purchasePrice: 650000.0,
        salePrice: 720000.0,
        netProfit: 70000.0,
        saleDay: 1,
        saleDate: DateTime.now(),
      );

      updatedGame = updatedGame.copyWith(salesHistory: [profitSale]);
      updatedGame = MentorQuestEngine.checkAndPersistRestorationProgress(updatedGame);

      activeQuest = MentorQuestEngine.getActiveQuest(updatedGame);
      expect(activeQuest, isNotNull);
      expect(activeQuest!.id, MentorQuestEngine.questFirstProfitSale);
      expect(activeQuest.isCompleted, isTrue);

      // 2. Görevin ödülü toplanır
      updatedGame = MentorQuestEngine.claimQuestReward(updatedGame, activeQuest.id);

      // 3. Görev: Seviye 2'ye ulaşma görevi aktif olur
      activeQuest = MentorQuestEngine.getActiveQuest(updatedGame);
      expect(activeQuest, isNotNull);
      expect(activeQuest!.id, MentorQuestEngine.questReachLevelTwo);
      expect(activeQuest.isCompleted, isFalse);

      // Seviye 2'ye geçildiğinde görev tamamlanır
      updatedGame = updatedGame.copyWith(level: 2);
      updatedGame = MentorQuestEngine.checkAndPersistRestorationProgress(updatedGame);

      activeQuest = MentorQuestEngine.getActiveQuest(updatedGame);
      expect(activeQuest, isNotNull);
      expect(activeQuest!.id, MentorQuestEngine.questReachLevelTwo);
      expect(activeQuest.isCompleted, isTrue);
    });
  });
}
