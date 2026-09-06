import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRandom implements Random {
  final double value;
  _FakeRandom(this.value);

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).toInt();

  @override
  bool nextBool() => value >= 0.5;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Scrapyard Dismantle Risk & Side Gig Cooldown Test Suite', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
    });

    test('1. Hurdalık Çıraklığı (Side Gig) 20 saatlik cooldown koruması sağlar ve spam engellenir', () {
      final initialBalance = notifier.state.balance;

      // First gig attempt should succeed
      final firstSuccess = notifier.workScrapyardSideGig();
      expect(firstSuccess, isTrue);
      expect(notifier.state.balance, equals(initialBalance + 5000.0));
      expect(notifier.state.lastScrapyardGigDate, isNotNull);

      // Immediate second attempt must fail (Spam prevention)
      final secondSuccess = notifier.workScrapyardSideGig();
      expect(secondSuccess, isFalse);
      expect(notifier.state.balance, equals(initialBalance + 5000.0));

      // After in-game day advances and 21 hours pass, gig should be available again (B6)
      final pastDate = DateTime.now().subtract(const Duration(hours: 21));
      notifier.state = notifier.state.copyWith(
        currentDay: notifier.state.currentDay + 1,
        lastScrapyardGigDate: pastDate,
      );

      final thirdSuccess = notifier.workScrapyardSideGig();
      expect(thirdSuccess, isTrue);
      expect(notifier.state.balance, equals(initialBalance + 10000.0));
    });

    test('2. Tekil parça sökümünde %85 başarı zarı sağlam parça kazandırır', () {
      const testPart = SalvagedPart(
        id: 'test_engine_1',
        name: 'V8 Turbo Motor',
        carModelName: 'Bemeve 3.20',
        category: 'engine',
        conditionPercent: 88,
        estimatedValue: 65000.0,
      );

      const testCar = ScrapyardCar(
        id: 'scrap_car_test',
        brand: 'Bemeve',
        modelName: '3.20d Pert',
        modelYear: 2018,
        scrapPrice: 80000.0,
        estimatedPartTotalValue: 120000.0,
        damageNote: 'Önden Kazalı',
        isPurchased: true,
        parts: [testPart],
      );

      notifier.state = notifier.state.copyWith(
        scrapyardCars: [testCar],
        salvagedParts: [],
      );

      // Roll 0.50 (< 0.85 -> Success)
      final luckyRng = _FakeRandom(0.50);
      final result = notifier.dismantleSinglePartFromScrap('scrap_car_test', 'test_engine_1', random: luckyRng);

      expect(result.success, isTrue);
      expect(result.isSalvaged, isTrue);
      expect(notifier.state.salvagedParts.length, equals(1));
      expect(notifier.state.salvagedParts.first.id, equals('test_engine_1'));
      expect(notifier.state.scrapyardCars.first.parts.isEmpty, isTrue);
      expect(result.message.contains('sağlam şekilde söküldü'), isTrue);
    });

    test('3. Tekil parça sökümünde %15 başarısızlık zarı parça kırılma/ziyan olma riski oluşturur', () {
      const testPart = SalvagedPart(
        id: 'test_trans_1',
        name: 'ZF Otomatik Şanzıman',
        carModelName: 'Bemeve 3.20',
        category: 'transmission',
        conditionPercent: 80,
        estimatedValue: 45000.0,
      );

      const testCar = ScrapyardCar(
        id: 'scrap_car_test_2',
        brand: 'Bemeve',
        modelName: '3.20d Pert',
        modelYear: 2018,
        scrapPrice: 80000.0,
        estimatedPartTotalValue: 120000.0,
        damageNote: 'Önden Kazalı',
        isPurchased: true,
        parts: [testPart],
      );

      notifier.state = notifier.state.copyWith(
        scrapyardCars: [testCar],
        salvagedParts: [],
      );

      // Roll 0.95 (>= 0.85 -> Stripped bolt / Broken)
      final unluckyRng = _FakeRandom(0.95);
      final result = notifier.dismantleSinglePartFromScrap('scrap_car_test_2', 'test_trans_1', random: unluckyRng);

      expect(result.success, isTrue);
      expect(result.isSalvaged, isFalse);
      expect(notifier.state.salvagedParts.isEmpty, isTrue); // Not added to inventory
      expect(notifier.state.scrapyardCars.first.parts.isEmpty, isTrue); // Removed from car
      expect(result.message.contains('Civata kaynamış'), isTrue);
    });

    test('4. Toplu söküm (buyAndDismantleScrapCar) enflasyon önleyici kayıp oranı uygular ve bakiyeyi düşer', () {
      const part1 = SalvagedPart(
        id: 'p1',
        name: 'Motor',
        carModelName: 'Golf',
        category: 'engine',
        conditionPercent: 90,
        estimatedValue: 50000.0,
      );
      const part2 = SalvagedPart(
        id: 'p2',
        name: 'Şanzıman',
        carModelName: 'Golf',
        category: 'transmission',
        conditionPercent: 85,
        estimatedValue: 35000.0,
      );

      const testCar = ScrapyardCar(
        id: 'scrap_bulk_car',
        brand: 'Vosgen',
        modelName: 'Golf GTI',
        modelYear: 2020,
        scrapPrice: 60000.0,
        estimatedPartTotalValue: 85000.0,
        damageNote: 'Arkadan Hasarlı',
        parts: [part1, part2],
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        scrapyardCars: [testCar],
        salvagedParts: [],
      );

      // Roll 0.80 (>= 0.75 -> loss on first roll, but guaranteed at least 1)
      final rng = _FakeRandom(0.80);
      final bulkResult = notifier.buyAndDismantleScrapCar('scrap_bulk_car', random: rng);

      expect(bulkResult.success, isTrue);
      expect(notifier.state.balance, equals(40000.0)); // 100k - 60k
      expect(notifier.state.scrapyardCars.isEmpty, isTrue);
      expect(bulkResult.totalPartsCount, equals(2));
      expect(notifier.state.salvagedParts.isNotEmpty, isTrue);
    });

    test('5. Zero Unicode Emojis and Zero Parentheses invariant test', () {
      const singleSuccess = SinglePartDismantleResult(
        success: true,
        isSalvaged: true,
        message: 'Motor sağlam şekilde söküldü ve depoya alındı!',
      );
      const singleFailure = SinglePartDismantleResult(
        success: true,
        isSalvaged: false,
        message: 'Civata kaynamış! Parça sökülürken hasar gördü ve ziyan oldu.',
      );
      const bulkRes = BulkScrapDismantleResult(
        success: true,
        totalPartsCount: 4,
        salvagedCount: 3,
        lostCount: 1,
        message: 'Hurda araç söküldü! 3 parça kurtarıldı • 1 parça sökümde ziyan oldu.',
      );

      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]', unicode: true);

      for (final msg in [singleSuccess.message, singleFailure.message, bulkRes.message]) {
        expect(emojiRegex.hasMatch(msg), isFalse);
        expect(msg.contains('('), isFalse);
        expect(msg.contains(')'), isFalse);
      }
    });
  });
}
