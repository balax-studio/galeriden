import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/daily_login_reward_model.dart';
import 'package:galeriden/data/models/customer_crm_event_model.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/domain/usecases/side_business_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Module 1: 28-Day Esnaf Calendar Streak Cycle Tests', () {
    test('Returns 28 distinct daily rewards with 4 milestone tiers', () {
      final rewards = DailyLoginRewardModel.get28DaysCycle();
      expect(rewards.length, 28);
      expect(rewards[0].dayNumber, 1);
      expect(rewards[27].dayNumber, 28);

      final milestones = rewards.where((r) => r.isMilestone).toList();
      expect(milestones.length, 4); // Days 7, 14, 21, 28
      expect(milestones.map((m) => m.dayNumber), [7, 14, 21, 28]);
    });

    test('Claiming daily reward advances streak and loops back at day 28', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      final initialStreak = notifier.state.currentStreakDay;
      expect(initialStreak, 1);

      // Claim Day 1
      final reward = notifier.claimDailyLoginReward(customNow: DateTime(2026, 8, 22));
      expect(reward, isNotNull);
      expect(reward!.dayNumber, 1);
      expect(notifier.state.currentStreakDay, 2);
      expect(notifier.state.streakCycleCount, 0);

      // Advance to Day 28 and test monthly cycle loop
      notifier.state = notifier.state.copyWith(currentStreakDay: 28, lastRealLoginDateStr: '2026-08-21');
      final day28Reward = notifier.claimDailyLoginReward(customNow: DateTime(2026, 8, 22));
      expect(day28Reward, isNotNull);
      expect(day28Reward!.dayNumber, 28);
      expect(notifier.state.currentStreakDay, 1); // Loops to day 1!
      expect(notifier.state.streakCycleCount, 1); // Cycle count incremented!
      expect(notifier.state.claimedStreakDays.isEmpty, true); // Reset for new month!

      notifier.stopPeriodicOrganicOfferTimer();
    });
  });

  group('Module 2: Customer CRM & Karma Loop Tests', () {
    test('Customer CRM events generate with valid choices and correct trigger days', () {
      final event = CustomerCrmEventModel.generateRandom(carName: 'Tofaşk Şahin', currentDay: 10);
      expect(event.carModelName, 'Tofaşk Şahin');
      expect(event.triggerDay, greaterThanOrEqualTo(10));
    });

    test('Accepting CRM dispute resolution updates balance, reputation and clears event', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      const testEvent = CustomerCrmEventModel(
        id: 'crm_dispute_1',
        type: CustomerCrmEventType.hiddenDefectDispute,
        customerName: 'Ahmet Bey',
        carModelName: 'Honda Civic',
        title: 'Gizli Arıza Bildirimi',
        description: 'Araçta yağ kaçağı çıktı.',
        financialImpact: 0.0,
        reputationImpact: -20,
        triggerDay: 1,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        reputationScore: 50,
        activeCrmEvent: testEvent,
      );

      notifier.resolveCustomerDispute(
        event: testEvent,
        choice: CrmResolutionChoice.generousRepair,
      );

      expect(notifier.state.balance, 85000.0);
      expect(notifier.state.reputationScore, 75);
      expect(notifier.state.activeCrmEvent, isNull);

      notifier.stopPeriodicOrganicOfferTimer();
    });
  });

  group('Module 4: Scrapyard Strategic Zones Tests', () {
    test('Scrapyard zones provide distinct titles and costs', () {
      expect(ScrapyardZoneType.ostim.title, contains('Ostim'));
      expect(ScrapyardZoneType.maslak.cost, 6000.0);
      expect(ScrapyardZoneType.harabe.cost, 12000.0);
    });

    test('Searching scrap with specific zone consumes fee and adds treasures', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 50000.0,
        scrapyardSearchesToday: 0,
        lastScrapyardSearchDay: 0,
        currentDay: 1,
      );

      final found = notifier.searchScrapForTreasures(zone: ScrapyardZoneType.maslak);
      expect(found, isNotNull);
      expect(notifier.state.scrapyardSearchesToday, 1);
      expect(notifier.state.lastScrapyardSearchDay, 1);

      notifier.stopPeriodicOrganicOfferTimer();
    });
  });

  group('Module 6: Side Business Dynamic Operational Bonuses Tests', () {
    test('Active utilization yields operational bonuses strictly for owned businesses', () {
      final washBusiness = SideBusinessModel(
        id: 'wash_1',
        name: 'Oto Yıkama',
        type: SideBusinessType.carWash,
        dailyIncome: 500.0,
        cost: 15000.0,
        isOwned: true,
      );

      final (newBalance, updated) = SideBusinessEngine.processDailyEarnings(
        balance: 1000.0,
        cars: [],
        businesses: [washBusiness],
        specializationPath: SpecializationPath.none,
        carsWashedLast7Days: 8, // High utilization!
        expertisesPerformedLast7Days: 0,
        partsRepairedLast7Days: 0,
        towedCarsLast7Days: 0,
        activeRentalsCount: 0,
      );

      // Should include dailyIncome (500) + operational bonus (1500) = 2000
      expect(newBalance, greaterThanOrEqualTo(3000.0));
      expect(updated.first.totalEarned, greaterThanOrEqualTo(2000.0));
    });
  });

  group('Module 7: Player Company IPO BIST Listing Tests', () {
    test('Company IPO is gated and grants substantial capital influx upon listing', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      // Not eligible yet
      notifier.state = notifier.state.copyWith(
        level: 2,
        carsSold: 5,
        isCompanyListedOnBist: false,
      );
      expect(notifier.launchPlayerCompanyIpo(), isNull);

      // Eligible
      notifier.state = notifier.state.copyWith(
        level: 5,
        carsSold: 15,
        balance: 1000000.0,
        isCompanyListedOnBist: false,
      );

      final raisedCapital = notifier.launchPlayerCompanyIpo();
      expect(raisedCapital, isNotNull);
      expect(raisedCapital!, greaterThanOrEqualTo(250000.0));
      expect(notifier.state.isCompanyListedOnBist, true);
      expect(notifier.state.marketStocks.any((s) => s.symbol == 'GLRD'), true);

      notifier.stopPeriodicOrganicOfferTimer();
    });
  });
}
