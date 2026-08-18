import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/screens/city_map/district_market_screen.dart';

void main() {
  group('District Market Share Exponential Scaling & Full Dominance Test Suite', () {
    test('1. calculateDistrictBoostCost scales progressively and exponentially with rawShare', () {
      final cost0 = DistrictMarketScreen.calculateBoostCost(0.0);
      final cost20 = DistrictMarketScreen.calculateBoostCost(0.20);
      final cost50 = DistrictMarketScreen.calculateBoostCost(0.50);
      final cost80 = DistrictMarketScreen.calculateBoostCost(0.80);
      final cost95 = DistrictMarketScreen.calculateBoostCost(0.95);
      final cost100 = DistrictMarketScreen.calculateBoostCost(1.0);

      expect(cost0, equals(15000.0));
      expect(cost20, greaterThan(cost0));
      expect(cost50, greaterThan(cost20));
      expect(cost80, greaterThan(cost50));
      expect(cost95, greaterThan(cost80));
      expect(cost100, equals(0.0));

      // Range benchmarks
      expect(cost20, inInclusiveRange(25000.0, 35000.0));
      expect(cost50, inInclusiveRange(80000.0, 110000.0));
      expect(cost80, inInclusiveRange(250000.0, 320000.0));
      expect(cost95, inInclusiveRange(450000.0, 520000.0));
    });

    test('2. DealershipModel stores and clamps districtMarketShare properly', () {
      final initialGame = DealershipModel.initial();
      final currentShare = initialGame.districtMarketShare['İkitelli Sanayi'] ?? 0.05;
      expect(currentShare, equals(0.05));

      final maxedMap = Map<String, double>.from(initialGame.districtMarketShare);
      maxedMap['İkitelli Sanayi'] = 1.0;
      final maxedGame = initialGame.copyWith(districtMarketShare: maxedMap);

      expect(maxedGame.districtMarketShare['İkitelli Sanayi'], equals(1.0));
    });

    test('3. kDistricts contains valid metadata with invariant rules (zero parentheses & clean perks)', () {
      for (final district in kDistricts) {
        expect(district.name.contains('('), isFalse);
        expect(district.name.contains(')'), isFalse);
        expect(district.perk.contains('('), isFalse);
        expect(district.perk.contains(')'), isFalse);

        final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);
        expect(emojiRegex.hasMatch(district.name), isFalse);
        expect(emojiRegex.hasMatch(district.perk), isFalse);
      }
    });
  });
}
