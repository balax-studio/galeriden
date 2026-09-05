import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/domain/usecases/vasita_market_engine.dart';
import 'package:galeriden/domain/usecases/vasita_negotiation_engine.dart';
import 'package:galeriden/presentation/providers/auction_session_provider.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/vasita_negotiation_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('UI State Extraction Providers Test Suite', () {
    test('1. AuctionSessionProvider initializes cleanly and records player bid', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final state = container.read(auctionSessionProvider);
      expect(state.auction, isNotNull);
      expect(state.hasPlayerEnteredBid, isFalse);

      final notifier = container.read(auctionSessionProvider.notifier);
      notifier.recordPlayerBid(
        nextBid: 150000,
        highestBidderName: 'Oyuncu Galeri',
        nextSeconds: 30,
        antiSnipingCount: 0,
        wasLateBid: false,
        bidLogText: 'Oyuncu 150.000 TL teklif verdi',
      );

      final updatedState = container.read(auctionSessionProvider);
      expect(updatedState.hasPlayerEnteredBid, isTrue);
      expect(updatedState.auction.currentBid, 150000);
      expect(updatedState.auction.isPlayerHighestBidder, isTrue);
      expect(updatedState.bidLogs.first, 'Oyuncu 150.000 TL teklif verdi');
    });

    test('2. AuctionSessionProvider handles bluff move and resets round', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(auctionSessionProvider.notifier);
      notifier.recordBluff(
        counterBid: 200000,
        rivalName: 'Baron Selim',
        dialogue: 'Bu arabayı sana bırakmam!',
        logText: 'Baron Selim tuzağa düştü: 200.000 TL',
      );

      final state = container.read(auctionSessionProvider);
      expect(state.hasBluffedInCurrentAuction, isTrue);
      expect(state.auction.currentBid, 200000);
      expect(state.auction.highestBidderName, 'Baron Selim');
      expect(state.auction.isPlayerHighestBidder, isFalse);
      expect(state.auction.activeSpeech, 'Bu arabayı sana bırakmam!');

      notifier.resetRound(playerLevel: 1);
      final resetState = container.read(auctionSessionProvider);
      expect(resetState.hasBluffedInCurrentAuction, isFalse);
      expect(resetState.hasPlayerEnteredBid, isFalse);
    });

    test('3. VasitaNegotiationProvider initializes with listing and manages offer & tactics', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final testListing = VasitaMarketEngine.generateListings(count: 1).first;

      final state = container.read(vasitaNegotiationProvider(testListing));
      expect(state.offeredPrice, (testListing.askingPrice * 0.90).roundToDouble());
      expect(state.sellerPatience, 100);
      expect(state.sellerDialogue.isNotEmpty, isTrue);

      final notifier = container.read(vasitaNegotiationProvider(testListing).notifier);
      notifier.updateOfferPrice(testListing.askingPrice * 0.85);
      expect(container.read(vasitaNegotiationProvider(testListing)).offeredPrice, testListing.askingPrice * 0.85);

      notifier.resetToAskingPrice();
      expect(container.read(vasitaNegotiationProvider(testListing)).offeredPrice, testListing.askingPrice);

      // Execute a known tactic
      final tactic = VasitaNegotiationEngine.allTactics.first;
      final outcome = notifier.executeTactic(tactic);
      expect(outcome, isNotNull);

      final afterTacticState = container.read(vasitaNegotiationProvider(testListing));
      expect(afterTacticState.usedTacticIds.contains(tactic.id), isTrue);
    });
  });
}
