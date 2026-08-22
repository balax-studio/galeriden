import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/daily_login_reward_model.dart';
import 'package:galeriden/data/models/customer_crm_event_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/domain/usecases/stock_market_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Expansion Pack Anti-Repetition Tests', () {
    test('1. 28-Günlük Esnaf Takvimi 4 Sezonluk Döngü Doğrulaması', () {
      final season0 = DailyLoginRewardModel.getSeasonalCycle(cycleCount: 0);
      final season1 = DailyLoginRewardModel.getSeasonalCycle(cycleCount: 1);
      final season2 = DailyLoginRewardModel.getSeasonalCycle(cycleCount: 2);
      final season3 = DailyLoginRewardModel.getSeasonalCycle(cycleCount: 3);

      expect(season0.length, 28);
      expect(season1.length, 28);
      expect(season2.length, 28);
      expect(season3.length, 28);

      final title0 = DailyLoginRewardModel.getSeasonTitle(0);
      final title1 = DailyLoginRewardModel.getSeasonTitle(1);
      final title2 = DailyLoginRewardModel.getSeasonTitle(2);
      final title3 = DailyLoginRewardModel.getSeasonTitle(3);

      expect(title0.contains('İLKBAHAR'), isTrue);
      expect(title1.contains('YAZ'), isTrue);
      expect(title2.contains('SONBAHAR'), isTrue);
      expect(title3.contains('KIŞ'), isTrue);

      final desc0 = DailyLoginRewardModel.getSeasonDescription(0);
      expect(desc0.isNotEmpty, isTrue);

      // Verify scaling multiplier across cycles
      expect(season1[0].moneyAmount, greaterThan(season0[0].moneyAmount));
    });

    test('2. Segment & Arketip Odaklı 10+ CRM Olayı Üretimi', () {
      final classicEvent = CustomerCrmEventModel.generateRandom(
        carName: 'Murat 131 Klasik',
        currentDay: 5,
        isRare: true,
      );
      expect(classicEvent.title.isNotEmpty, isTrue);
      expect(classicEvent.carModelName, 'Murat 131 Klasik');
      expect(classicEvent.triggerDay, 5);

      final tunedEvent = CustomerCrmEventModel.generateRandom(
        carName: 'Supra Tuning',
        currentDay: 10,
        bodyType: 'Coupe',
        isOverTuned: true,
      );
      expect(tunedEvent.carModelName, 'Supra Tuning');

      final fleetEvent = CustomerCrmEventModel.generateRandom(
        carName: 'Transit Van',
        currentDay: 15,
        bodyType: 'Van',
      );
      expect(fleetEvent.carModelName, 'Transit Van');
    });

    test('3. Hurdalık Günlük Sanayi Tüyosu & Bölgesel Rapor', () {
      final rumorDay1 = ScrapyardZoneExtension.getDailySanayiRumor(1);
      final rumorDay2 = ScrapyardZoneExtension.getDailySanayiRumor(2);
      final rumorDay3 = ScrapyardZoneExtension.getDailySanayiRumor(3);

      expect(rumorDay1.isNotEmpty, isTrue);
      expect(rumorDay2.isNotEmpty, isTrue);
      expect(rumorDay3.isNotEmpty, isTrue);
      expect(rumorDay1 != rumorDay2, isTrue);
    });

    test('4. BIST GLRD Çeyreklik Bilanço Açıklaması (Day 30, 60...)', () {
      final List<StockModel> initialStocks = [
        StockModel(
          symbol: 'GLRD',
          name: 'Galeri Holding',
          currentPrice: 100.0,
          previousPrice: 100.0,
          priceHistory: [100.0],
          dividendYield: 0.10,
          sectorCategory: 'Otomotiv',
        ),
      ];

      // Day 29: No quarterly report
      final (stocksDay29, bal29, events29) = StockMarketEngine.processQuarterlyFinancialReport(
        nextDay: 29,
        balance: 100000.0,
        stocks: initialStocks,
        events: [],
        reputationScore: 80,
        totalProfit: 500000.0,
        isCompanyListed: true,
      );
      expect(stocksDay29[0].currentPrice, 100.0);
      expect(events29.isEmpty, isTrue);

      // Day 30: Quarterly report triggers price increase and dividend payout
      final (stocksDay30, bal30, events30) = StockMarketEngine.processQuarterlyFinancialReport(
        nextDay: 30,
        balance: 100000.0,
        stocks: initialStocks,
        events: [],
        reputationScore: 80,
        totalProfit: 500000.0,
        isCompanyListed: true,
      );
      expect(stocksDay30[0].currentPrice, greaterThan(100.0));
      expect(bal30, greaterThan(100000.0));
      expect(events30.isNotEmpty, isTrue);
      expect(events30.first.id.contains('glrd_quarterly_30'), isTrue);
    });

    test('5. Şirket Hisse Geri Alımı (Share Buyback) İşlemi', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // Setup company listing
      notifier.addMoney(1000000.0);
      notifier.addXP(10000); // Level up
      notifier.stopPeriodicOrganicOfferTimer();
      notifier.state = notifier.state.copyWith(carsSold: 15, level: 5);

      final ipoResult = notifier.launchPlayerCompanyIpo();
      notifier.stopPeriodicOrganicOfferTimer();
      expect(ipoResult, isNotNull);
      expect(container.read(gameProvider).isCompanyListedOnBist, isTrue);

      final glrdBefore = container.read(gameProvider).marketStocks.firstWhere((s) => s.symbol == 'GLRD');
      final buybackSuccess = notifier.buybackPlayerCompanyShares(amount: 50000.0);
      notifier.stopPeriodicOrganicOfferTimer();
      expect(buybackSuccess, isTrue);

      final glrdAfter = container.read(gameProvider).marketStocks.firstWhere((s) => s.symbol == 'GLRD');
      expect(glrdAfter.currentPrice, greaterThan(glrdBefore.currentPrice));

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
    });
  });
}
