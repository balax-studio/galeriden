import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/auction_model.dart';
import 'package:galeriden/domain/usecases/auction_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/core/localization/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auction Screen & Engine End-to-End Test Suite', () {
    test('1. Live and VIP auction models generate proper initial state and annotations', () {
      final standard = AuctionEngine.createLiveAuction(playerLevel: 3);
      expect(standard.id.startsWith('auc_'), isTrue);
      expect(standard.startingPrice, greaterThan(0));
      expect(standard.currentBid, equals(standard.startingPrice));
      expect(standard.isPlayerHighestBidder, isFalse);
      expect(standard.status, equals(AuctionStatus.active));
      expect(standard.rivals.length, equals(4));
      expect(standard.customsNote.originOffice.isNotEmpty, isTrue);
      expect(standard.customsNote.legalStatus.isNotEmpty, isTrue);
      expect(standard.customsNote.trunkLoot.value, greaterThan(0));

      final vip = AuctionEngine.createVipAuction(playerLevel: 5);
      expect(vip.id.startsWith('auc_vip_'), isTrue);
      expect(vip.car.isRare, isTrue);
      expect(vip.startingPrice, greaterThan(1000000));
      expect(vip.rivals.any((r) => r.name.contains('Baron') || r.name.contains('Holding') || r.name.contains('Ferit')), isTrue);
      expect(vip.customsNote.trunkLoot.value, greaterThanOrEqualTo(100000));
    });

    test('2. All rival bots (including Vedat and Selçuk) process bids and fold when budget exceeded', () {
      // Test explicit bidding personalities
      final rivals = [
        AuctionRival(name: 'Hızlı Ahmet', avatarType: 'craftsman', maxBudget: 500000, personality: 'Erken Agresif', dialogues: ['Hemen artırıyorum!']),
        AuctionRival(name: 'Sabırlı Mehmet', avatarType: 'shield', maxBudget: 500000, personality: 'Son Saniye Sniper', dialogues: ['Pusuya yattım.']),
        AuctionRival(name: 'Zengin Ayşe', avatarType: 'rare', maxBudget: 500000, personality: 'Yüksek Bütçe & Lüks', dialogues: ['Alacağım!']),
        AuctionRival(name: 'Çılgın Kemal', avatarType: 'sparkles', maxBudget: 500000, personality: 'Sürpriz & Kaotik', dialogues: ['Gaza bastım!']),
        AuctionRival(name: 'Galerici Vedat', avatarType: 'craftsman', maxBudget: 500000, personality: 'Piyasa Kurdu', dialogues: ['Esnaf işi teklif!']),
        AuctionRival(name: 'Koleksiyoner Selçuk', avatarType: 'rare', maxBudget: 500000, personality: 'Nadir Kasa Avcısı', dialogues: ['Değerini bilirim.']),
        AuctionRival(name: 'Bilinmeyen Rakip', avatarType: 'craftsman', maxBudget: 500000, personality: 'Genel Alıcı', dialogues: ['Ben de varım!']),
      ];

      for (final rival in rivals) {
        var baseAuction = AuctionEngine.createLiveAuction(playerLevel: 1);
        baseAuction = baseAuction.copyWith(
          rivals: [rival],
          currentBid: 100000,
          secondsRemaining: 4, // triggers end-game sniper checks too
        );

        bool didAttemptOrBid = false;
        for (int step = 0; step < 50; step++) {
          final updated = AuctionEngine.processRivalBid(baseAuction);
          if (updated != null) {
            didAttemptOrBid = true;
            expect(updated.currentBid, greaterThan(100000));
            expect(updated.highestBidderName, equals(rival.name));
            expect(updated.isPlayerHighestBidder, isFalse);
            break;
          }
        }
        expect(didAttemptOrBid, isTrue, reason: '${rival.name} should be capable of bidding');
      }

      // Test fold when budget exceeded
      final lowBudgetRival = AuctionRival(name: 'Hızlı Ahmet', avatarType: 'craftsman', maxBudget: 50000, personality: 'Erken Agresif', dialogues: ['Param bitti!']);
      var foldAuction = AuctionEngine.createLiveAuction(playerLevel: 1).copyWith(
        rivals: [lowBudgetRival],
        currentBid: 60000,
      );
      final foldResult = AuctionEngine.processRivalBid(foldAuction);
      expect(foldResult, isNull);
      expect(lowBudgetRival.isFolded, isTrue);
    });

    test('3. Gavel stage and localization keys accurately change with remaining seconds', () {
      var auction = AuctionEngine.createLiveAuction(playerLevel: 1);

      auction = auction.copyWith(secondsRemaining: 15);
      expect(auction.gavelStage, equals(AuctionGavelStage.ongoing));
      expect(auction.gavelCallLocalizationKey, equals('auction_gavel_ongoing'));

      auction = auction.copyWith(secondsRemaining: 5);
      expect(auction.gavelStage, equals(AuctionGavelStage.firstCall));
      expect(auction.gavelCallLocalizationKey, equals('auction_gavel_call_1'));

      auction = auction.copyWith(secondsRemaining: 3);
      expect(auction.gavelStage, equals(AuctionGavelStage.secondCall));
      expect(auction.gavelCallLocalizationKey, equals('auction_gavel_call_2'));

      auction = auction.copyWith(secondsRemaining: 1);
      expect(auction.gavelStage, equals(AuctionGavelStage.finalHammer));
      expect(auction.gavelCallLocalizationKey, equals('auction_gavel_final'));
    });

    test('4. Player winning auction purchases car, updates inventory and claims trunk loot', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        maxGarageSlots: 10,
        ownedCars: [],
      );

      final liveAuction = AuctionEngine.createLiveAuction(playerLevel: 2);
      final purchasePrice = liveAuction.currentBid;
      final winCar = liveAuction.car;

      final success = notifier.buyCarDirectly(winCar, purchasePrice);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(1000000.0 - purchasePrice));
      expect(notifier.state.ownedCars.length, equals(1));
      expect(notifier.state.ownedCars.first.brand, equals(winCar.brand));

      // Trunk loot claim
      final loot = liveAuction.customsNote.trunkLoot;
      notifier.addMoney(loot.value);
      expect(notifier.state.balance, equals(1000000.0 - purchasePrice + loot.value));
    });

    test('5. Closed session scheduling and officer dialogues work reliably', () {
      AuctionEngine.openSessionImmediately(durationSeconds: 60);
      expect(AuctionEngine.isAuctionActiveNow(), isTrue);

      final nextDate = AuctionEngine.scheduleNextRandomSession(minSeconds: 50, maxSeconds: 100);
      expect(nextDate.isAfter(DateTime.now()), isTrue);
      expect(AuctionEngine.getSecondsUntilNextAuction(), greaterThanOrEqualTo(49));

      final dialogue = AuctionEngine.getRandomOfficerDialogue('01:30');
      expect(dialogue.contains('01:30'), isTrue);
      expect(dialogue.contains('(') || dialogue.contains(')'), isFalse);
    });

    test('6. All auction localization keys exist and translate in all 7 supported languages', () {
      final requiredKeys = [
        'auction_screen_title',
        'auction_vip_title',
        'auction_tab_customs',
        'auction_tab_vip',
        'auction_tab_catalog',
        'auction_badge_live',
        'auction_badge_vip',
        'auction_badge_closed',
        'auction_closed_title',
        'auction_closed_desc',
        'auction_highest_bid_yours',
        'auction_garage_full_err',
        'auction_bluff_already_used',
        'auction_already_leading',
        'auction_all_folded',
        'auction_loot_added_to_vault',
        'auction_unknown_speaker',
        'auction_gavel_final',
        'auction_gavel_call_2',
        'auction_gavel_call_1',
        'auction_gavel_ongoing',
      ];

      for (final code in AppLocalizations.supportedLanguageCodes) {
        final translations = AppLocalizations.getAllKeysFor(code);
        for (final key in requiredKeys) {
          expect(
            translations.containsKey(key),
            isTrue,
            reason: 'Language "$code" is missing key: $key',
          );
          expect(
            translations[key]!.isNotEmpty,
            isTrue,
            reason: 'Language "$code" has empty translation for key: $key',
          );
        }
      }
    });
  });
}
