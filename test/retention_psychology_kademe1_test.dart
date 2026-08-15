import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/psychology_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Kademe 1: Retention & Hook Model Unit Tests', () {
    test('PsychologyEngine calculates uncapped progressive streak rewards with milestones', () {
      expect(PsychologyEngine.getStreakReward(1), equals(2500));
      expect(PsychologyEngine.getStreakReward(7), equals(25000));
      expect(PsychologyEngine.getStreakReward(14), equals(60000));
      expect(PsychologyEngine.getStreakReward(21), equals(100000));
      expect(PsychologyEngine.getStreakReward(30), equals(200000));
      expect(PsychologyEngine.getStreakReward(35), equals(250000));
    });

    test('PsychologyEngine generates transparent net ROI repair text', () {
      final roiText = PsychologyEngine.getNetRoiRepairText(12000.0, 25000.0);
      expect(roiText.contains('12.000'), isTrue);
      expect(roiText.contains('25.000'), isTrue);
      expect(roiText.contains('13.000'), isTrue);
    });

    test('Calendar-day login streak calculation advances on next calendar day even if < 24 hours', () {
      final mondayNight = DateTime(2026, 8, 17, 21, 0);
      final tuesdayMorning = DateTime(2026, 8, 18, 9, 0); // 12 hours later, but next calendar day!

      final initialModel = DealershipModel.initial().copyWith(
        lastLoginDate: mondayNight,
        loginStreak: 1,
      );

      final nextStreak = PsychologyEngine.calculateLoginStreak(
        lastLoginDate: initialModel.lastLoginDate,
        currentStreak: initialModel.loginStreak,
        now: tuesdayMorning,
      );

      expect(nextStreak, equals(2));
    });

    test('Calendar-day login streak resets if missed more than 1 calendar day without freeze', () {
      final monday = DateTime(2026, 8, 17, 10, 0);
      final wednesday = DateTime(2026, 8, 19, 10, 0); // 2 calendar days later

      final nextStreak = PsychologyEngine.calculateLoginStreak(
        lastLoginDate: monday,
        currentStreak: 5,
        now: wednesday,
        hasStreakFreeze: false,
      );

      expect(nextStreak, equals(1));
    });

    test('Calendar-day login streak is preserved if player has streak freeze', () {
      final monday = DateTime(2026, 8, 17, 10, 0);
      final wednesday = DateTime(2026, 8, 19, 10, 0); // 2 calendar days later

      final nextStreak = PsychologyEngine.calculateLoginStreak(
        lastLoginDate: monday,
        currentStreak: 5,
        now: wednesday,
        hasStreakFreeze: true,
      );

      expect(nextStreak, equals(5));
    });
  });
}
