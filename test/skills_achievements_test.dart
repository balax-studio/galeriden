import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/data/models/player_achievements.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Skill Tree and Exponential XP Math Tests', () {
    test('Exponential required XP calculation', () {
      expect(PlayerSkills.requiredXpForLevel(1), 1500);
      expect(PlayerSkills.requiredXpForLevel(2), 4000);
      expect(PlayerSkills.requiredXpForLevel(3), 9000);
      expect(PlayerSkills.requiredXpForLevel(4), 18000);
    });

    test('Player level & XP in level based on total XP', () {
      final skillsLvl1 = PlayerSkills(xp: 150);
      expect(skillsLvl1.currentLevel, 1);
      expect(skillsLvl1.xpInCurrentLevel, 150);

      final skillsLvl2 = PlayerSkills(xp: 1650);
      expect(skillsLvl2.currentLevel, 2);
      expect(skillsLvl2.xpInCurrentLevel, 150); // 1650 - 1500
    });

    test('Skill multipliers calculate correctly', () {
      final skills = PlayerSkills(
        negotiationLevel: 5,
        eyeForDetail: 3,
        marketSense: 2,
        financeSense: 4,
      );

      // (5-1) * 0.02 = 0.08 (8%)
      expect(skills.negotiationMultiplier, closeTo(0.08, 0.001));

      // (3-1) * 0.05 = 0.10 (10%)
      expect(skills.expertiseCostDiscount, closeTo(0.10, 0.001));

      // (2-1) * 0.15 = 0.15 (15%)
      expect(skills.marketingDopingBonus, closeTo(0.15, 0.001));

      // (4-1) * 0.01 = 0.03 (3%)
      expect(skills.financeInterestDiscount, closeTo(0.03, 0.001));
    });
  });

  group('Achievement Claiming & Reward Tests', () {
    late GameNotifier gameNotifier;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      gameNotifier = GameNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    tearDown(() {
      gameNotifier.dispose();
    });

    test('Claiming unlocked achievement grants money and bonus skill points', () {
      // Manually unlock an achievement for test
      final achievements = List<AchievementItem>.from(gameNotifier.state.achievements);
      achievements[0] = achievements[0].copyWith(isUnlocked: true);
      
      gameNotifier.overrideStateForTesting(gameNotifier.state.copyWith(achievements: achievements));
      
      final initialBalance = gameNotifier.state.balance;
      final initialSp = gameNotifier.state.skills.availableSkillPoints;
      final targetAchievement = gameNotifier.state.achievements[0];

      final success = gameNotifier.claimAchievementReward(targetAchievement.id);
      expect(success, isTrue);

      final updatedState = gameNotifier.state;
      expect(updatedState.balance, initialBalance + targetAchievement.rewardMoney);
      expect(updatedState.skills.availableSkillPoints, initialSp + targetAchievement.rewardSkillPoints);
      expect(updatedState.achievements[0].isClaimed, isTrue);
    });
  });
}

extension on GameNotifier {
  void overrideStateForTesting(dynamic newState) {
    state = newState;
  }
}
