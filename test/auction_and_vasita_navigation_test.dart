import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/domain/usecases/auction_engine.dart';
import 'package:galeriden/data/models/auction_model.dart';
import 'package:galeriden/core/services/ad_reward_calculator.dart';
import 'package:galeriden/presentation/providers/auction_session_provider.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auction Cooldown Bypass with Ad Protocol Tests', () {
    test('1. bypassClosedCooldownWithAd immediately unlocks the auction session', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.read(auctionSessionProvider.notifier).stopTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final auctionNotifier = container.read(auctionSessionProvider.notifier);

      // Force state to closed window with countdown
      auctionNotifier.state = auctionNotifier.state.copyWith(
        isWindowOpen: false,
        closedCountdown: 180,
      );

      expect(container.read(auctionSessionProvider).isWindowOpen, isFalse);
      expect(container.read(auctionSessionProvider).closedCountdown, equals(180));

      // Invoke Ad Bypass
      auctionNotifier.bypassClosedCooldownWithAd();

      final updatedState = container.read(auctionSessionProvider);
      expect(updatedState.isWindowOpen, isTrue);
      expect(updatedState.closedCountdown, equals(0));
      expect(updatedState.isVipSession, isFalse);
      expect(updatedState.auction.status, equals(AuctionStatus.active));
      expect(updatedState.auction.secondsRemaining, greaterThan(0));
      expect(AuctionEngine.isAuctionActiveNow(), isTrue);
    });

    test('2. startVipAuction immediately unlocks window and starts VIP lot', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.read(auctionSessionProvider.notifier).stopTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final auctionNotifier = container.read(auctionSessionProvider.notifier);

      // Force state to closed window
      auctionNotifier.state = auctionNotifier.state.copyWith(
        isWindowOpen: false,
        closedCountdown: 300,
      );

      auctionNotifier.startVipAuction(
        playerLevel: 10,
        startedLog: 'VIP Seansı Başladı',
        startingPriceLog: 'Açılış Fiyatı: 1.000.000 TL',
      );

      final state = container.read(auctionSessionProvider);
      expect(state.isWindowOpen, isTrue);
      expect(state.isVipSession, isTrue);
      expect(state.closedCountdown, equals(0));
      expect(state.auction.status, equals(AuctionStatus.active));
    });

    test('2b. closeWindow transitions state to closed window with active countdown', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.read(auctionSessionProvider.notifier).stopTimer();
        container.dispose();
      });

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final auctionNotifier = container.read(auctionSessionProvider.notifier);

      auctionNotifier.bypassClosedCooldownWithAd();
      expect(container.read(auctionSessionProvider).isWindowOpen, isTrue);

      auctionNotifier.closeWindow();

      final closedState = container.read(auctionSessionProvider);
      expect(closedState.isWindowOpen, isFalse);
      expect(closedState.closedCountdown, greaterThan(0));
      expect(closedState.isVipSession, isFalse);
      expect(closedState.hasPlayerEnteredBid, isFalse);
    });
  });

  group('Economy Balance & Ad Reward Safety Tests (3M Wealth Safe Caps)', () {
    test('Economy Test 1: 3M TL wealth yields safe ~40-50k standard reward, never 3.2M', () {
      // Test player with 3M wealth at level 5
      final outcome = AdRewardCalculator.calculateDynamicReward(
        playerLevel: 5,
        totalGarageValue: 1500000.0,
        playerBalance: 1500000.0,
      );

      // Must be reasonable (around 35k to 120k on jackpot), NEVER 3.2M
      expect(outcome.moneyAmount, greaterThanOrEqualTo(25000.0));
      expect(outcome.moneyAmount, lessThanOrEqualTo(140000.0));
      expect(outcome.moneyAmount, lessThan(500000.0)); // Strictly less than 500k
    });

    test('Economy Test 2: 100M TL late-game tycoon is strictly capped at max 350.000 TL', () {
      // Test player with 100M wealth at max level 15
      for (int i = 0; i < 50; i++) {
        final outcome = AdRewardCalculator.calculateDynamicReward(
          playerLevel: 15,
          totalGarageValue: 50000000.0,
          playerBalance: 50000000.0,
        );

        // Absolute global ceiling must never exceed 350.000 TL
        expect(outcome.moneyAmount, lessThanOrEqualTo(350000.0));
      }
    });

    test('Economy Test 3: Emergency and branch grants are strictly bounded', () {
      final emergency = AdRewardCalculator.calculateEmergencyGrant(
        playerLevel: 5,
        playerBalance: 3000000.0,
      );
      expect(emergency, lessThanOrEqualTo(220000.0));

      final branch = AdRewardCalculator.calculateBranchGrant(
        playerLevel: 5,
        playerBalance: 3000000.0,
      );
      expect(branch, lessThanOrEqualTo(180000.0));
    });
  });

  group('Auction & Vasita Localization & String Hygiene (Invariant Rules 1, 2, 8)', () {
    final translationMaps = [
      trTranslations,
      enTranslations,
      deTranslations,
      ptTranslations,
      esTranslations,
      ruTranslations,
      arTranslations,
    ];

    final requiredKeys = [
      'auction_closed_ad_protocol_title',
      'auction_closed_ad_protocol_desc',
      'auction_closed_ad_bypass_btn',
      'auction_closed_ad_success_toast',
      'auction_closed_protocol_badge',
      'auction_sell_guide_title',
      'auction_sell_guide_desc',
      'auction_sell_no_cars_detail',
      'auction_sell_go_to_market_btn',
      'btn_send_to_auction',
    ];

    test('3. All required keys exist simultaneously across all 7 supported languages', () {
      for (final translations in translationMaps) {
        for (final key in requiredKeys) {
          expect(
            translations.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in translation map',
          );
          expect(
            translations[key],
            isNotEmpty,
            reason: 'Empty translation for key "$key"',
          );
        }
      }
    });

    test('4. Invariant Rule 1 & 2: Zero Unicode emojis and zero parentheses in new keys', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      for (final translations in translationMaps) {
        for (final key in requiredKeys) {
          final val = translations[key]!;
          // No emojis
          expect(
            emojiRegex.hasMatch(val),
            isFalse,
            reason: 'Found emoji in key "$key": "$val"',
          );
          // No parentheses
          expect(
            val.contains('(') || val.contains(')'),
            isFalse,
            reason: 'Found parentheses in key "$key": "$val"',
          );
        }
      }
    });
  });
}
