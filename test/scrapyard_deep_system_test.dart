import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Deep Scrapyard, Part Dismantling, Refurbishing & B2B Orders System Tests', () {
    test('1. ScrapyardCar supports chassis scrap metal calculations and secret finds', () {
      final scrapCar = ScrapyardCar(
        id: 'scrap_test_1',
        brand: 'BMW',
        modelName: '320i E46 Pert',
        modelYear: 2004,
        scrapPrice: 35000,
        estimatedPartTotalValue: 65000,
        damageNote: 'Önden ağır darbeli',
        chassisScrapMetalWeightKg: 1350,
        chassisScrapValue: 8100, // 1350 kg * ₺6/kg
        surpriseFindItem: 'Orijinal Harman Kardon Amfi',
        surpriseFindValue: 3500,
        parts: [
          const SalvagedPart(
            id: 'part_engine_1',
            name: 'M54B22 6 Silindir Motor Bloğu',
            carModelName: 'BMW 320i',
            category: 'engine',
            conditionPercent: 40,
            tier: PartQualityTier.usable,
            estimatedValue: 22000,
          ),
          const SalvagedPart(
            id: 'part_trans_1',
            name: 'ZF 5 İleri Otomatik Şanzıman',
            carModelName: 'BMW 320i',
            category: 'transmission',
            conditionPercent: 20,
            tier: PartQualityTier.worn,
            estimatedValue: 12000,
          ),
        ],
      );

      expect(scrapCar.chassisScrapMetalWeightKg, 1350);
      expect(scrapCar.chassisScrapValue, 8100);
      expect(scrapCar.surpriseFindItem, 'Orijinal Harman Kardon Amfi');
      expect(scrapCar.surpriseFindValue, 3500);
      expect(scrapCar.parts.length, 2);
    });

    test('2. crushChassisToScrapMetal awards scrap metal cash, discovers surprise finds, and cleans state', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.resetGame();

      final initialBalance = container.read(gameProvider).balance;

      final testCar = ScrapyardCar(
        id: 'scrap_crush_test',
        brand: 'Tofaşk',
        modelName: 'Şahin Hurda',
        modelYear: 1996,
        scrapPrice: 15000,
        estimatedPartTotalValue: 25000,
        damageNote: 'Yanmış ve çürük',
        chassisScrapMetalWeightKg: 950,
        chassisScrapValue: 5700,
        surpriseFindItem: 'Nostaljik Kasetçalar & Altın Künye',
        surpriseFindValue: 2500,
        parts: [],
      );

      // Inject test scrap car into state
      notifier.state = container.read(gameProvider).copyWith(
        scrapyardCars: [testCar],
      );

      // Execute chassis crush
      final result = notifier.crushChassisToScrapMetal('scrap_crush_test');
      expect(result.success, isTrue);
      expect(result.scrapMetalEarned, 5700);
      expect(result.surpriseEarned, 2500);
      expect(result.surpriseItemName, 'Nostaljik Kasetçalar & Altın Künye');

      // Verify balance increased by scrap + surprise = 8200
      expect(container.read(gameProvider).balance, initialBalance + 8200);
      expect(container.read(gameProvider).scrapyardCars.any((c) => c.id == 'scrap_crush_test'), isFalse);
    });

    test('3. refurbishSalvagedPart upgrades condition and tier with workshop fee', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.resetGame();

      const wornPart = SalvagedPart(
        id: 'part_worn_test',
        name: 'Paslı Turbo Şarj',
        carModelName: 'Volkswagen Golf',
        category: 'turbo',
        conditionPercent: 25,
        tier: PartQualityTier.worn,
        estimatedValue: 8000,
      );

      notifier.state = container.read(gameProvider).copyWith(
        balance: 100000,
        salvagedParts: [wornPart],
      );

      final refurbCost = wornPart.refurbishCost; // e.g. ₺1.800
      expect(refurbCost, greaterThan(0));

      final success = notifier.refurbishSalvagedPart('part_worn_test');
      expect(success, isTrue);

      final updatedParts = container.read(gameProvider).salvagedParts;
      final refurbishedPart = updatedParts.firstWhere((p) => p.id == 'part_worn_test');

      // Condition improved and tier promoted
      expect(refurbishedPart.conditionPercent, greaterThan(50));
      expect(refurbishedPart.tier, isIn([PartQualityTier.usable, PartQualityTier.good]));
      expect(refurbishedPart.estimatedValue, greaterThan(wornPart.estimatedValue));
      expect(container.read(gameProvider).balance, 100000 - refurbCost);
    });

    test('4. B2B Part Orders can be fulfilled with matching stock for premium cash & reputation', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.resetGame();

      const matchingPart = SalvagedPart(
        id: 'part_b2b_passat_gearbox',
        name: 'DSG Otomatik Şanzıman',
        carModelName: 'Volkswagen Passat',
        category: 'transmission',
        conditionPercent: 75,
        tier: PartQualityTier.good,
        estimatedValue: 24000,
      );

      final b2bOrder = B2BPartOrder(
        id: 'order_haydar_1',
        mechanicName: 'Haydar Usta (Motor & Mekanik)',
        requiredCategory: 'transmission',
        requiredCarBrand: 'Volkswagen',
        minQualityTier: PartQualityTier.usable,
        offeredPrice: 38000, // Premium B2B offer
        reputationReward: 6,
        description: 'Müşterinin Passat aracı liftte kaldı, acil temiz DSG şanzıman aranıyor!',
        expiresInDays: 3,
      );

      notifier.state = container.read(gameProvider).copyWith(
        balance: 50000,
        reputationScore: 50,
        salvagedParts: [matchingPart],
        b2bPartOrders: [b2bOrder],
      );

      // Fulfill B2B Order
      final success = notifier.fulfillB2BPartOrder('order_haydar_1', 'part_b2b_passat_gearbox');
      expect(success, isTrue);

      // Balance increased by ₺38.000, reputationScore increased by +6, part removed from inventory
      expect(container.read(gameProvider).balance, 50000 + 38000);
      expect(container.read(gameProvider).reputationScore, 56);
      expect(container.read(gameProvider).salvagedParts.isEmpty, isTrue);
      expect(container.read(gameProvider).b2bPartOrders.firstWhere((o) => o.id == 'order_haydar_1').isCompleted, isTrue);
    });
  });
}
