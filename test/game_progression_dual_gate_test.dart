import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/branch_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/player_skills.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dual-Gated Progression (XP / Level -> Branch Purchase -> Building Unlocks)', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Initial Dealership starts with Level 1 basic services and locked Level 2+ buildings', () {
      final game = DealershipModel.initial();

      expect(game.level, equals(1));
      expect(game.isFeatureUnlocked('/marketplace'), isTrue);
      expect(game.isFeatureUnlocked('/showroom'), isTrue);
      expect(game.isFeatureUnlocked('/expertise'), isTrue);
      expect(game.isFeatureUnlocked('/car-wash'), isTrue);
      expect(game.isFeatureUnlocked('/branches'), isTrue);

      // Level 2+ buildings must be LOCKED initially
      expect(game.isFeatureUnlocked('/workshop'), isFalse);
      expect(game.isFeatureUnlocked('/tuning-studio'), isFalse);
      expect(game.isFeatureUnlocked('/staff'), isFalse);
      expect(game.isFeatureUnlocked('/auction'), isFalse);
      expect(game.isFeatureUnlocked('/finance'), isFalse);
      expect(game.isFeatureUnlocked('/scrapyard'), isFalse);
    });

    test('Leveling up to Level 2 via XP qualifies for branch purchase, but does NOT auto-unlock workshop until purchased', () {
      final notifier = GameNotifier();
      expect(notifier.state.level, equals(1));
      expect(notifier.state.isFeatureUnlocked('/workshop'), isFalse);

      // Add 300 XP (Crosses Level 1 threshold 250 XP -> Level 2)
      notifier.addXP(300);
      expect(notifier.state.level, equals(2));

      // Workshop is STILL locked because player has not bought the Level 2 Branch yet!
      expect(notifier.state.isFeatureUnlocked('/workshop'), isFalse);

      final branch2 = BranchModel.getAllBranches().firstWhere((b) => b.id == 'branch_2');
      expect(branch2.targetLevel, equals(2));

      // Cannot afford yet with low balance
      notifier.state = notifier.state.copyWith(balance: 100000.0);
      final failedBuy = notifier.upgradeBranch(branch2);
      expect(failedBuy, isFalse);
      expect(notifier.state.isFeatureUnlocked('/workshop'), isFalse);

      // Provide funds and purchase Level 2 Branch (İkitelli Sanayi)
      notifier.state = notifier.state.copyWith(balance: 500000.0);
      final successBuy = notifier.upgradeBranch(branch2);
      expect(successBuy, isTrue);

      // Now Level 2 buildings are unlocked!
      expect(notifier.state.isFeatureUnlocked('/workshop'), isTrue);
      expect(notifier.state.isFeatureUnlocked('/tuning-studio'), isTrue);
      expect(notifier.state.isFeatureUnlocked('/staff'), isTrue);
      expect(notifier.state.maxGarageSlots, equals(6));

      // Level 3+ buildings remain locked
      expect(notifier.state.isFeatureUnlocked('/auction'), isFalse);
      expect(notifier.state.isFeatureUnlocked('/finance'), isFalse);
    });

    test('Purchasing Level 3 Branch (Maslak Plaza) unlocks Auction, Finance, and Bank Investments', () {
      final notifier = GameNotifier();
      // Level 3 requires total 900 XP (250 + 650)
      notifier.addXP(1000);
      expect(notifier.state.level, equals(3));

      final branch3 = BranchModel.getAllBranches().firstWhere((b) => b.id == 'branch_3');
      notifier.state = notifier.state.copyWith(balance: 3000000.0);

      final successBuy = notifier.upgradeBranch(branch3);
      expect(successBuy, isTrue);

      expect(notifier.state.isFeatureUnlocked('/auction'), isTrue);
      expect(notifier.state.isFeatureUnlocked('/finance'), isTrue);
      expect(notifier.state.isFeatureUnlocked('/bank-investments'), isTrue);
      expect(notifier.state.isFeatureUnlocked('/stock-market'), isTrue);
      expect(notifier.state.maxGarageSlots, equals(10));
    });

    test('Calibrated XP curve adheres to non-grindy, psychologically balanced thresholds', () {
      expect(PlayerSkills.requiredXpForLevel(1), equals(250));
      expect(PlayerSkills.requiredXpForLevel(2), equals(650));
      expect(PlayerSkills.requiredXpForLevel(3), equals(1400));
      expect(PlayerSkills.requiredXpForLevel(4), equals(2800));

      final skills = PlayerSkills(xp: 250);
      expect(skills.currentLevel, equals(2));

      final skillsLv3 = PlayerSkills(xp: 250 + 650);
      expect(skillsLv3.currentLevel, equals(3));

      final skillsLv4 = PlayerSkills(xp: 250 + 650 + 1400);
      expect(skillsLv4.currentLevel, equals(4));
    });
  });
}
