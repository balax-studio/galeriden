import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/dialogs/daily_login_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Rewarded Ad & Engagement Integrations Test Suite', () {
    test('Daily login 2x multiplier doubles money and reputation reward', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      final initialBalance = notifier.state.balance;
      final initialRep = notifier.state.reputationScore;

      final reward = notifier.claimDailyLoginReward(
        customNow: DateTime(2026, 8, 25),
        rewardMultiplier: 2.0,
      );

      expect(reward, isNotNull);
      final expectedMoneyBonus = reward!.moneyAmount * 2.0;
      final expectedRepBonus = reward.reputationAmount * 2;

      expect(notifier.state.balance, equals(initialBalance + expectedMoneyBonus));
      expect(notifier.state.reputationScore, equals(initialRep + expectedRepBonus));

      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('Streak Rescue activates streak freeze and protects login streak', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      expect(notifier.state.hasStreakFreeze, isFalse);

      notifier.activateStreakRescue();

      expect(notifier.state.hasStreakFreeze, isTrue);
      expect(notifier.state.loginStreak, greaterThanOrEqualTo(1));

      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('Lucky Wheel free ad spin grants winnings without deducting player balance', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
      );

      final result = notifier.spinCasinoWheel(
        betAmount: 100000.0,
        isFreeAd: true,
      );

      expect(result, isNotNull);
      // Balance should NOT have decreased by 100,000 TL
      expect(notifier.state.balance, greaterThanOrEqualTo(10000.0));
      if (!result!.isBankrupt && result.slice.multiplier > 0) {
        expect(notifier.state.balance, equals(10000.0 + result.payoutAmount));
      }

      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('Plinko free ad drop grants winnings without deducting player balance', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 5000.0,
      );

      final result = notifier.playCasinoPlinko(
        betAmount: 50000.0,
        isFreeAd: true,
      );

      expect(result, isNotNull);
      // Balance should be initial + payoutAmount without deducting 50,000 TL
      expect(notifier.state.balance, equals(5000.0 + result!.payoutAmount));

      notifier.stopPeriodicOrganicOfferTimer();
    });

    testWidgets('DailyLoginSheet renders 2x Ad Claim button and Streak Rescue Shield', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('tr'),
            supportedLocales: [Locale('tr'), Locale('en')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(body: DailyLoginSheet()),
          ),
        ),
      );

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      expect(find.text('ÖDÜLÜ 2X AL • REKLAM İZLE'), findsOneWidget);
      expect(find.text('SERİ KORUMA VE KURTARMA KALKANI'), findsOneWidget);
      expect(find.text('SERİYİ DONDUR VE KURTAR • REKLAM İZLE'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
