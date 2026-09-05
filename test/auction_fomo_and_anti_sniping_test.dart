import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/auction_model.dart';
import 'package:galeriden/domain/usecases/auction_engine.dart';
import 'package:galeriden/presentation/screens/auction/widgets/auction_live_bidding_view.dart';
import 'package:galeriden/presentation/screens/auction/widgets/auction_hammer_result_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('FAZ 2: Auction FOMO & Anti-Sniping Protection Suite', () {
    test('1. Anti-sniping dynamic extension: bids in last 5 seconds extend timer by +15s', () {
      final rival = AuctionRival(
        name: 'Sabırlı Mehmet',
        avatarType: 'shield',
        maxBudget: 600000,
        personality: 'Son Saniye Sniper',
        dialogues: ['Pusuya yattım.'],
      );

      var auction = AuctionEngine.createLiveAuction(playerLevel: 2).copyWith(
        rivals: [rival],
        currentBid: 150000,
        secondsRemaining: 4, // Inside anti-sniping zone (<= 5s)
        antiSnipingCount: 0,
      );

      expect(auction.isHeartbeatPhase, isTrue);
      expect(auction.antiSnipingCount, equals(0));

      // Force-run rival bid
      AuctionModel? updated;
      for (int i = 0; i < 40; i++) {
        updated = AuctionEngine.processRivalBid(auction);
        if (updated != null) break;
      }

      expect(updated, isNotNull);
      // Timer must be extended by +15s (4 + 15 = 19s)
      expect(updated!.secondsRemaining, equals(19));
      expect(updated.antiSnipingCount, equals(1));
      expect(updated.isAntiSnipingTriggered, isTrue);
    });

    test('2. Heartbeat phase and active watcher telemetry calculate accurately', () {
      var auction = AuctionEngine.createLiveAuction(playerLevel: 1);

      // Above 10s -> not heartbeat
      auction = auction.copyWith(secondsRemaining: 15);
      expect(auction.isHeartbeatPhase, isFalse);

      // At 10s -> heartbeat phase active
      auction = auction.copyWith(secondsRemaining: 10);
      expect(auction.isHeartbeatPhase, isTrue);

      // At 3s -> heartbeat phase active
      auction = auction.copyWith(secondsRemaining: 3);
      expect(auction.isHeartbeatPhase, isTrue);

      // At 0s -> ended, not heartbeat
      auction = auction.copyWith(secondsRemaining: 0);
      expect(auction.isHeartbeatPhase, isFalse);

      // Active watchers count verification
      expect(auction.activeWatchersCount, greaterThanOrEqualTo(50));

      // Active rivals count verification
      expect(auction.activeRivalsCount, equals(auction.rivals.where((r) => !r.isFolded).length));
      auction.rivals.first.isFolded = true;
      expect(auction.activeRivalsCount, equals(auction.rivals.where((r) => !r.isFolded).length));
    });

    test('3. Zero Unicode emojis and zero parentheses across all FAZ 2 auction localization keys', () {
      final faz2Keys = [
        'auction_anti_sniping_alert',
        'auction_anti_sniping_badge',
        'auction_anti_sniping_log',
        'auction_fomo_countdown_title',
        'auction_fomo_countdown_sub',
        'auction_fomo_watchers_badge',
        'auction_fomo_rivals_badge',
        'auction_fomo_last_chance',
        'auction_overtaken_title',
        'auction_overtaken_desc',
        'auction_reclaim_lead_btn',
        'auction_lost_near_miss',
        'auction_lost_sunk_cost_desc',
        'auction_reclaim_insufficient_funds',
      ];

      final langMaps = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      for (final key in faz2Keys) {
        for (final entry in langMaps.entries) {
          final lang = entry.key;
          final map = entry.value;

          expect(map.containsKey(key), isTrue, reason: 'Key $key must exist in $lang');
          final value = map[key]!;
          expect(value.isNotEmpty, isTrue, reason: 'Value for $key in $lang must not be empty');

          // Invariant Rule 1: Zero Unicode Emojis
          expect(
            emojiRegex.hasMatch(value),
            isFalse,
            reason: 'Key $key in $lang contains forbidden Unicode emoji: $value',
          );

          // Invariant Rule 2: Zero Parentheses
          expect(
            value.contains('(') || value.contains(')'),
            isFalse,
            reason: 'Key $key in $lang contains forbidden parentheses: $value',
          );
        }
      }
    });

    testWidgets('4. AuctionLiveBiddingView renders heartbeat urgency, anti-sniping and overtaken banner', (tester) async {
      final auction = AuctionEngine.createLiveAuction(playerLevel: 1).copyWith(
        secondsRemaining: 8, // Heartbeat active
        antiSnipingCount: 1,
        isAntiSnipingTriggered: true,
        isPlayerHighestBidder: false,
        highestBidderName: 'Zengin Ayşe',
        currentBid: 240000,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
            Locale('de'),
            Locale('pt'),
            Locale('es'),
            Locale('ru'),
            Locale('ar'),
          ],
          locale: const Locale('tr'),
          home: Scaffold(
            body: AuctionLiveBiddingView(
              auction: auction,
              bidLogs: const ['Önceki pey'],
              isDark: false,
              playerBalance: 1000000,
              hasPlayerEnteredBid: true, // Overtaken condition!
              onPlaceBid: (inc, {isAggressiveFlag = false}) {},
              onBluff: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Heartbeat Banner
      expect(find.text('KRİTİK GERİ SAYIM • ÇEKİÇ HAVADA!'), findsOneWidget);

      // Verify Anti-Sniping Banner
      expect(find.text('SÜRE KORUMASI AKTİF • +15 SN'), findsOneWidget);

      // Verify Overtaken / Loss Aversion Banner
      expect(find.text('TEKLİFİNİZ GEÇİLDİ • Zengin Ayşe ÖNE GEÇTİ!'), findsOneWidget);
      expect(find.text('LİDERLİĞİ GERİ AL • +₺5.000'), findsOneWidget);
    });

    testWidgets('5. AuctionLostDialog displays near-miss and sunk-cost loss aversion copy', (tester) async {
      final auction = AuctionEngine.createLiveAuction(playerLevel: 1).copyWith(
        highestBidderName: 'Baron Selim',
        currentBid: 850000,
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('tr'),
            Locale('en'),
            Locale('de'),
            Locale('pt'),
            Locale('es'),
            Locale('ru'),
            Locale('ar'),
          ],
          locale: const Locale('tr'),
          home: Scaffold(
            body: AuctionLostDialog(
              auction: auction,
              hasExtendedAuction: false,
              hasPlayerEnteredBid: true,
              onExtendAuction: () {},
              onNextAuction: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Near-miss text
      expect(find.text('KIL PAYI KAÇIRDINIZ! • Kazanan: Baron Selim'), findsOneWidget);
      // Verify Sunk-cost description
      expect(
        find.text('Harcanan emek ve peyler boşa gitmesin! Son 15 saniye uzatma hakkınızı kullanın.'),
        findsOneWidget,
      );
    });
  });
}
