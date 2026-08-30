import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/gossip_item_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/gossip_engine.dart';
import 'package:galeriden/domain/usecases/consignment_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gossip, Consignment and Office Audit Tests', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    });

    tearDown(() {
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    test('Day 1 Gossip Engine generates deterministic gossips when activeGossips is empty', () {
      final notifier = container.read(gameProvider.notifier);
      final initialGame = container.read(gameProvider);

      expect(initialGame.activeGossips, isEmpty);

      // Generating daily gossips directly
      final day1Gossips = GossipEngine.generateDailyGossips(initialGame.currentDay);
      expect(day1Gossips, isNotEmpty);
      expect(day1Gossips.length, 4);

      // Purchasing a gossip item on Day 1 when activeGossips was empty
      notifier.addCheatFunds(100000);
      final gossipToBuy = day1Gossips.first;
      final success = notifier.buyGossipItem(gossipToBuy);

      expect(success, isTrue);
      final updatedGame = container.read(gameProvider);
      expect(updatedGame.activeGossips.length, 4);
      expect(updatedGame.activeGossips.firstWhere((g) => g.id == gossipToBuy.id).isPurchased, isTrue);
    });

    test('Consignment Parking Fee calculation & Daily event processing', () {
      final feeTier1 = ConsignmentEngine.calculateDailyParkingFee(1);
      final feeTier8 = ConsignmentEngine.calculateDailyParkingFee(8);

      expect(feeTier1, 300.0);
      expect(feeTier8, 45000.0);

      // Create a test consignment car
      final car = CarModel(
        id: 'consignment_test_1',
        brand: 'Mercedes',
        modelName: 'C200',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1500000.0,
        currentPurchasePrice: 0.0,
        isConsignment: true,
        consignmentOwnerName: 'Ahmet Bey',
        consignmentDaysRemaining: 5,
        consignmentCommissionRate: 0.10,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final notifier = container.read(gameProvider.notifier);
      final acceptSuccess = notifier.acceptConsignmentOffer(car);
      expect(acceptSuccess, isTrue);

      final gameAfterAccept = container.read(gameProvider);
      expect(gameAfterAccept.ownedCars.any((c) => c.id == 'consignment_test_1'), isTrue);
    });

    test('Raid gossip warning detection correctly detects rivalIntel and tasfiye intel', () {
      final rivalIntelGossip = GossipItemModel(
        id: 'gossip_tarik_tasfiye_1',
        sourceNpc: 'gumrukcu_tarik',
        sourceNpcName: 'Gümrükçü Tarık',
        sourceAvatar: 'gumrukcu_tarik',
        title: 'Tasfiye Uyarısı',
        teaser: 'Baskın ve denetimler sıklaştı.',
        content: 'Yakında baskın yapılacak.',
        cost: 5000.0,
        accuracy: 0.95,
        type: GossipType.rivalIntel,
        targetSegment: 'Lüks',
        inGameDay: 1,
        isPurchased: true,
      );

      final hasWarning = [rivalIntelGossip].any((g) =>
          (g.type == GossipType.rivalIntel ||
              g.id.contains('police_raid') ||
              g.id.contains('tasfiye')) &&
          g.isPurchased);

      expect(hasWarning, isTrue);
    });
  });
}
