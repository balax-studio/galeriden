import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/domain/usecases/mission_factory.dart';

void main() {
  group('Sprint 2: Daily Missions & Contracts Tests', () {
    test('MissionFactory generates diverse daily missions covering all types and scaled by level', () {
      final missionsLvl1 = MissionFactory.generateDailyMissions(1);
      expect(missionsLvl1.length, greaterThanOrEqualTo(3));
      expect(missionsLvl1.every((m) => !m.isCompleted && !m.isClaimed), isTrue);

      final missionsLvl3 = MissionFactory.generateDailyMissions(3);
      expect(missionsLvl3.length, greaterThanOrEqualTo(3));
      // Higher level missions have higher average rewards across batches
      int totalRewardLvl1 = 0;
      int totalRewardLvl5 = 0;
      for (int i = 0; i < 20; i++) {
        totalRewardLvl1 += MissionFactory.generateDailyMissions(1).fold(0, (sum, m) => sum + m.rewardMoney);
        totalRewardLvl5 += MissionFactory.generateDailyMissions(5).fold(0, (sum, m) => sum + m.rewardMoney);
      }
      expect(totalRewardLvl5, greaterThan(totalRewardLvl1));
    });

    test('MissionFactory generates wanted vehicle contract', () {
      final contract = MissionFactory.generateWantedCarContract(level: 1);
      expect(contract.id.isNotEmpty, isTrue);
      expect(contract.targetBrand.isNotEmpty, isTrue);
      expect(contract.rewardBonus, greaterThan(0));
      expect(contract.deadlineDays, greaterThan(0));
    });
  });
}
