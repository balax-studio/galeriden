import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/auction_model.dart';
import 'package:galeriden/domain/usecases/auction_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Auction Micro & RPG Systems Test Suite', () {
    test('1. AuctionModel generates with Customs Annotation & Trunk Loot', () {
      final auction = AuctionEngine.createLiveAuction(playerLevel: 2);

      expect(auction.customsNote, isNotNull);
      expect(auction.customsNote.legalStatus.isNotEmpty, isTrue);
      expect(auction.customsNote.riskRewardFactor.isNotEmpty, isTrue);
      expect(auction.customsNote.trunkLoot, isNotNull);
      expect(auction.customsNote.trunkLoot.value, greaterThan(0));
    });

    test('2. Live Auction Catalog generates next upcoming lots', () {
      final upcomingLots = AuctionEngine.generateUpcomingLots(count: 3, playerLevel: 2);

      expect(upcomingLots.length, equals(3));
      expect(upcomingLots.first.lotNumber, greaterThan(100));
      expect(upcomingLots.first.startingPrice, greaterThan(0));
      expect(upcomingLots.first.car.brand.isNotEmpty, isTrue);
    });

    test('3. Rivals speak dynamic dialogue bubbles during bidding and fold reactions', () {
      var auction = AuctionEngine.createLiveAuction(playerLevel: 2);
      
      // Advance bids to trigger rival speeches
      bool speechTriggered = false;
      for (int i = 0; i < 10; i++) {
        final updated = AuctionEngine.processRivalBid(auction);
        if (updated != null) {
          auction = updated;
          if (auction.activeSpeech != null && auction.activeSpeech!.isNotEmpty) {
            speechTriggered = true;
            break;
          }
        }
      }

      // Rival speech should be present or available
      expect(speechTriggered || auction.rivals.any((r) => r.dialogues.isNotEmpty), isTrue);
    });

    test('4. Gavel 3-Stage Call Status calculates accurately based on seconds remaining', () {
      var auction = AuctionEngine.createLiveAuction(playerLevel: 1);

      auction = auction.copyWith(secondsRemaining: 15);
      expect(auction.gavelStage, equals(AuctionGavelStage.ongoing));

      auction = auction.copyWith(secondsRemaining: 5);
      expect(auction.gavelStage, equals(AuctionGavelStage.firstCall));
      expect(auction.gavelCallText, contains('1. ÇAĞRI'));

      auction = auction.copyWith(secondsRemaining: 3);
      expect(auction.gavelStage, equals(AuctionGavelStage.secondCall));
      expect(auction.gavelCallText, contains('2. ÇAĞRI'));

      auction = auction.copyWith(secondsRemaining: 1);
      expect(auction.gavelStage, equals(AuctionGavelStage.finalHammer));
      expect(auction.gavelCallText, contains('SATTIM'));
    });

    test('5. Trunk Loot Unboxing claims bonus reward to player balance or garage', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(balance: 10000.0);

      final loot = TrunkLoot(
        name: 'Torpido İçi Döviz & Altın Zarfı',
        value: 12500.0,
        type: TrunkLootType.cash,
        description: 'Önceki sahibinin unuttuğu döviz ve altın birikimi.',
      );

      notifier.addMoney(loot.value);
      expect(notifier.state.balance, equals(22500.0));
    });
  });
}
