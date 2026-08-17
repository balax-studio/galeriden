import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/showroom_decor_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Showroom Decor & Architecture RPG System Tests', () {
    test('1. ShowroomDecorModel catalog contains all 16 items categorized into 5 distinct RPG themes', () {
      final catalog = ShowroomDecorModel.getAllDecors();
      expect(catalog.length, 16);

      final makamItems = catalog.where((d) => d.category == DecorCategory.makam).toList();
      final socialItems = catalog.where((d) => d.category == DecorCategory.social).toList();
      final displayItems = catalog.where((d) => d.category == DecorCategory.display).toList();
      final securityItems = catalog.where((d) => d.category == DecorCategory.security).toList();
      final prestigeItems = catalog.where((d) => d.category == DecorCategory.prestige).toList();

      expect(makamItems.length, 4);
      expect(socialItems.length, 3);
      expect(displayItems.length, 5);
      expect(securityItems.length, 3);
      expect(prestigeItems.length, 1);

      // Verify specific essential cultural & RPG items exist
      expect(catalog.any((d) => d.id == 'decor_leather_chair_desk'), isTrue);
      expect(catalog.any((d) => d.id == 'decor_tesbih_lighter_stand'), isTrue);
      expect(catalog.any((d) => d.id == 'decor_nazar_prayer_frame'), isTrue);
      expect(catalog.any((d) => d.id == 'decor_copper_samovar'), isTrue);
      expect(catalog.any((d) => d.id == 'decor_money_counter_safe'), isTrue);
      expect(catalog.any((d) => d.id == 'decor_trophy_cabinet'), isTrue);
    });

    test('2. purchaseShowroomDecor enforces balance, level gates, and prevents duplicate purchases', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Setup initial state: Level 1, ₺50.000 balance
      notifier.resetGame();
      expect(container.read(gameProvider).balance, greaterThanOrEqualTo(50000));
      expect(container.read(gameProvider).unlockedDecorIds, isEmpty);

      // Purchase Makam Desk (₺40.000, Level 1 required) -> SUCCESS
      final leatherDesk = ShowroomDecorModel.getById('decor_leather_chair_desk')!;
      final success1 = notifier.purchaseShowroomDecor(
        decorId: leatherDesk.id,
        cost: leatherDesk.cost,
        reputationBonus: leatherDesk.reputationBonus,
      );
      expect(success1, isTrue);
      expect(container.read(gameProvider).unlockedDecorIds.contains('decor_leather_chair_desk'), isTrue);

      // Attempt duplicate purchase -> FAIL
      final successDuplicate = notifier.purchaseShowroomDecor(
        decorId: leatherDesk.id,
        cost: leatherDesk.cost,
        reputationBonus: leatherDesk.reputationBonus,
      );
      expect(successDuplicate, isFalse);

      // Attempt purchase when balance is insufficient -> FAIL
      final trophyCabinet = ShowroomDecorModel.getById('decor_trophy_cabinet')!; // ₺95.000
      final successExpensive = notifier.purchaseShowroomDecor(
        decorId: trophyCabinet.id,
        cost: trophyCabinet.cost,
        reputationBonus: trophyCabinet.reputationBonus,
      );
      expect(successExpensive, isFalse);
    });

    test('3. DealershipModel RPG helper getters reflect active decor perks correctly', () {
      DealershipModel game = DealershipModel.initial().copyWith(
        dealershipName: 'Test Galeri',
        balance: 500000,
        unlockedDecorIds: [
          'decor_leather_chair_desk',
          'decor_tesbih_lighter_stand',
          'decor_copper_samovar',
          'decor_money_counter_safe',
          'decor_security_cctv',
          'decor_trophy_cabinet',
        ],
      );

      expect(game.hasDecor('decor_leather_chair_desk'), isTrue);
      expect(game.negotiationPersuasionBonusPercent, 4.0); // +4%
      expect(game.buyerWalkawayReductionPercent, 20.0); // -20%
      expect(game.consignmentDemandBonusPercent, 25.0); // +25%
      expect(game.cashSaleProfitBonusMultiplier, 1.02); // +2%
      expect(game.hasFullSecurityProtection, isTrue); // CCTV
      expect(game.unlockedDecorCount, 6);
    });

    test('4. ShowroomDecorModel getCategoryLabel returns authentic Turkish titles', () {
      expect(ShowroomDecorModel.getCategoryLabel(DecorCategory.all), 'Tümü');
      expect(ShowroomDecorModel.getCategoryLabel(DecorCategory.makam), 'Makam Odası');
      expect(ShowroomDecorModel.getCategoryLabel(DecorCategory.social), 'Sosyal & İkram');
      expect(ShowroomDecorModel.getCategoryLabel(DecorCategory.display), 'Vitrin & Şov');
      expect(ShowroomDecorModel.getCategoryLabel(DecorCategory.security), 'Güvenlik');
      expect(ShowroomDecorModel.getCategoryLabel(DecorCategory.prestige), 'Prestij & Kupa');
    });
  });
}
