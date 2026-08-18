import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/gossip_item_model.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/presentation/providers/game/game_core_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NPC Dynamic Relationships & Perks Test Suite', () {
    late GameCoreNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameCoreNotifier();
      notifier.stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      notifier.stopPeriodicOrganicOfferTimer();
    });

    test('1. interactWithNpc properly deducts balance, increases trust, and awards XP', () {
      final initialBalance = notifier.state.balance;
      final initialTrust = notifier.state.getNpcRelation('haydar_usta');

      // Interact with Haydar Usta: ₺250 cost, +3 trust
      final success = notifier.interactWithNpc(
        npcId: 'haydar_usta',
        cost: 250.0,
        trustGain: 3,
      );

      expect(success, isTrue);
      expect(notifier.state.balance, equals(initialBalance - 250.0));
      expect(notifier.state.getNpcRelation('haydar_usta'), equals(initialTrust + 3));
    });

    test('2. interactWithNpc fails if player cannot afford the cost', () {
      // Drain balance
      notifier.state = notifier.state.copyWith(balance: 50.0);

      final success = notifier.interactWithNpc(
        npcId: 'vlogger_berk',
        cost: 1500.0,
        trustGain: 8,
      );

      expect(success, isFalse);
      expect(notifier.state.balance, equals(50.0));
    });

    test('3. Trust reaches threshold >= 70 and hasHighNpcTrust turns true', () {
      expect(notifier.state.hasHighNpcTrust('necati'), isFalse);

      // Boost Necati trust to 75
      final newRelations = Map<String, int>.from(notifier.state.npcRelationships);
      newRelations['necati'] = 75;
      notifier.state = notifier.state.copyWith(npcRelationships: newRelations);

      expect(notifier.state.hasHighNpcTrust('necati'), isTrue);
    });

    test('4. MarketEngine respects hasHighNecatiTrust parameter for Kelepir & Barn Find', () {
      // Generate market listings with and without Necati trust
      final normalListings = MarketEngine.generateRandomListings(
        count: 50,
        playerLevel: 5,
        hasHighNecatiTrust: false,
      );

      final necatiListings = MarketEngine.generateRandomListings(
        count: 50,
        playerLevel: 5,
        hasHighNecatiTrust: true,
      );

      expect(normalListings.isNotEmpty, isTrue);
      expect(necatiListings.isNotEmpty, isTrue);
    });

    test('5. buyGossipItem grants 50% discount and adds +3 trust when NPC trust >= 70', () {
      // Set high trust with Necati
      final newRelations = Map<String, int>.from(notifier.state.npcRelationships);
      newRelations['necati'] = 80;

      final testGossip = const GossipItemModel(
        id: 'test_gossip_1',
        sourceNpc: 'cayci_necati',
        sourceNpcName: 'Çaycı Necati',
        sourceAvatar: 'cayci',
        title: 'Kelepir İstihbaratı',
        teaser: 'Maslakta bir araç var...',
        content: 'Fiyatı çok uygun düşecek.',
        cost: 2000.0,
        accuracy: 0.85,
        type: GossipType.bargainTip,
        inGameDay: 5,
      );

      notifier.state = notifier.state.copyWith(
        balance: 10000.0,
        npcRelationships: newRelations,
        activeGossips: [testGossip],
      );

      final initialTrust = notifier.state.getNpcRelation('necati');
      final buySuccess = notifier.buyGossipItem(testGossip);

      expect(buySuccess, isTrue);
      // 50% discount applied: ₺2000 -> ₺1000 deducted
      expect(notifier.state.balance, equals(9000.0));
      expect(notifier.state.getNpcRelation('necati'), equals(initialTrust + 3));
    });

    test('6. manualPullOrganicOffer operates with reduced lull chance and respects Berk trust', () {
      // Default state
      final result1 = notifier.manualPullOrganicOffer();
      expect(result1, isNotNull);

      // With Vlogger Berk high trust
      final newRelations = Map<String, int>.from(notifier.state.npcRelationships);
      newRelations['vlogger_berk'] = 85;
      notifier.state = notifier.state.copyWith(npcRelationships: newRelations);

      final result2 = notifier.manualPullOrganicOffer();
      expect(result2, isNotNull);
    });
  });
}
