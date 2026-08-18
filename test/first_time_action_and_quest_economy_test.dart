import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/first_time_action_keys.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/mission_model.dart';
import 'package:galeriden/domain/usecases/mission_factory.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('First-Time Action Motivation Rewards', () {
    test('Initial DealershipModel starts with empty completedFirstTimeActions', () {
      final dealer = DealershipModel.initial();
      expect(dealer.completedFirstTimeActions, isEmpty);
    });

    test('completedFirstTimeActions serializes and deserializes correctly via JSON', () {
      final dealer = DealershipModel.initial().copyWith(
        completedFirstTimeActions: {
          FirstTimeActionKeys.firstCarBuy,
          FirstTimeActionKeys.firstCarWash,
          FirstTimeActionKeys.firstExpertise,
        },
      );

      final json = dealer.toJson();
      expect(json['completedFirstTimeActions'], isA<List>());
      expect(json['completedFirstTimeActions'], contains(FirstTimeActionKeys.firstCarBuy));
      expect(json['completedFirstTimeActions'], contains(FirstTimeActionKeys.firstCarWash));
      expect(json['completedFirstTimeActions'], contains(FirstTimeActionKeys.firstExpertise));

      final deserialized = DealershipModel.fromJson(json);
      expect(deserialized.completedFirstTimeActions.length, equals(3));
      expect(deserialized.completedFirstTimeActions.contains(FirstTimeActionKeys.firstCarBuy), isTrue);
      expect(deserialized.completedFirstTimeActions.contains(FirstTimeActionKeys.firstCarWash), isTrue);
      expect(deserialized.completedFirstTimeActions.contains(FirstTimeActionKeys.firstExpertise), isTrue);
    });

    test('checkAndAwardFirstTimeAction awards 5.000 TL + 5 XP exactly once', () async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final initialBalance = container.read(gameProvider).balance;
      final initialXP = container.read(gameProvider).skills.xp;

      // 1st Trigger: should award 5.000 TL and 5 XP
      final awarded = notifier.checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarBuy);
      expect(awarded, isTrue);

      final stateAfterFirst = container.read(gameProvider);
      expect(stateAfterFirst.balance, equals(initialBalance + 5000.0));
      expect(stateAfterFirst.skills.xp, equals(initialXP + 5));
      expect(stateAfterFirst.completedFirstTimeActions.contains(FirstTimeActionKeys.firstCarBuy), isTrue);

      // 2nd Trigger: should be rejected with 0 extra money and 0 extra XP
      final repeatAwarded = notifier.checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstCarBuy);
      expect(repeatAwarded, isFalse);

      final stateAfterRepeat = container.read(gameProvider);
      expect(stateAfterRepeat.balance, equals(initialBalance + 5000.0));
      expect(stateAfterRepeat.skills.xp, equals(initialXP + 5));
    });
  });

  group('Rebalanced XP Economy & Mission Rewards', () {
    test('Daily Mission XP is strictly capped between 5 and 15 XP across all generated missions', () {
      for (int level = 1; level <= 5; level++) {
        for (int i = 0; i < 20; i++) {
          final missions = MissionFactory.generateDailyMissions(
            level,
            unlockedBuildings: {'/car-wash', '/workshop'},
          );

          expect(missions.length, equals(3));
          for (final m in missions) {
            expect(m.rewardXP, greaterThanOrEqualTo(5), reason: 'XP should be at least 5 for ${m.title}');
            expect(m.rewardXP, lessThanOrEqualTo(15), reason: 'XP should be at most 15 for ${m.title}');
            expect(m.rewardMoney, greaterThanOrEqualTo(2500.0));
            expect(m.rewardMoney, lessThanOrEqualTo(15000.0));
          }
        }
      }
    });

    test('Chained Career Milestones provide massive XP progression (50 to 250 XP)', () {
      for (int stage = 1; stage <= 4; stage++) {
        final milestone = MissionFactory.generateChainedCampaignMission(step: stage, level: 1);
        expect(milestone.rewardXP, greaterThanOrEqualTo(50), reason: 'Milestone XP should be substantial (>=50 XP)');
        expect(milestone.rewardXP, lessThanOrEqualTo(250), reason: 'Milestone XP should be capped at 250 XP');
      }
    });
  });

  group('Soft-Lock Free Dynamic Daily Quest Pool', () {
    test('Level 1 players with no unlocked buildings NEVER receive locked Sanayi or Oto Yıkama missions', () {
      for (int seed = 0; seed < 50; seed++) {
        final missions = MissionFactory.generateDailyMissions(
          1,
          unlockedBuildings: {},
        );

        expect(missions.length, equals(3));
        for (final m in missions) {
          expect(
            m.type,
            isNot(isIn([
              MissionType.washCars,
              MissionType.repairParts,
              MissionType.tuneCar,
              MissionType.hireStaff,
            ])),
            reason: 'Level 1 player received locked mission: ${m.title} (${m.type})',
          );
        }
      }
    });

    test('Level 2 players or players with car-wash building CAN receive washCars mission', () {
      bool foundWash = false;
      for (int seed = 0; seed < 100; seed++) {
        final missions = MissionFactory.generateDailyMissions(
          2,
          unlockedBuildings: {'/car-wash'},
        );
        if (missions.any((m) => m.type == MissionType.washCars)) {
          foundWash = true;
          break;
        }
      }
      expect(foundWash, isTrue, reason: 'Level 2 players should eventually receive wash quests');
    });

    test('Level 3+ players or players with workshop CAN receive repair, tune, and staff missions', () {
      bool foundRepairOrTune = false;
      for (int seed = 0; seed < 100; seed++) {
        final missions = MissionFactory.generateDailyMissions(
          3,
          unlockedBuildings: {'/workshop', '/car-wash'},
        );
        if (missions.any((m) => m.type == MissionType.repairParts || m.type == MissionType.tuneCar)) {
          foundRepairOrTune = true;
          break;
        }
      }
      expect(foundRepairOrTune, isTrue, reason: 'Level 3 players should receive repair/tuning quests');
    });

    test('Generated daily missions never have duplicate mission types', () {
      for (int seed = 0; seed < 50; seed++) {
        final missions = MissionFactory.generateDailyMissions(
          3,
          unlockedBuildings: {'/workshop', '/car-wash'},
        );
        final types = missions.map((m) => m.type).toSet();
        expect(types.length, equals(missions.length), reason: 'Daily missions should all have distinct types');
      }
    });
  });
}
