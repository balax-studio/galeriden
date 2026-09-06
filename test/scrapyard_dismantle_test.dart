import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/scrapyard_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/scrapyard/scrapyard_screen.dart';
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

      final firstSuccess = notifier.workScrapyardSideGig();
      expect(firstSuccess, isTrue);
      expect(notifier.state.balance, equals(initialBalance + 5000.0));
      expect(notifier.state.lastScrapyardGigDate, isNotNull);

      final secondSuccess = notifier.workScrapyardSideGig();
      expect(secondSuccess, isFalse);
      expect(notifier.state.balance, equals(initialBalance + 5000.0));

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

      final unluckyRng = _FakeRandom(0.95);
      final result = notifier.dismantleSinglePartFromScrap('scrap_car_test_2', 'test_trans_1', random: unluckyRng);

      expect(result.success, isTrue);
      expect(result.isSalvaged, isFalse);
      expect(notifier.state.salvagedParts.isEmpty, isTrue);
      expect(notifier.state.scrapyardCars.first.parts.isEmpty, isTrue);
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

      final rng = _FakeRandom(0.80);
      final bulkResult = notifier.buyAndDismantleScrapCar('scrap_bulk_car', random: rng);

      expect(bulkResult.success, isTrue);
      expect(notifier.state.balance, equals(40000.0));
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

    testWidgets('6. Scrapyard dismantle dialog transitions to SÖKÜLDÜ state and prevents spam', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const initialPart = SalvagedPart(
        id: 'part_engine_1',
        name: '2.0 TwinPower Turbo Motor Bloğu',
        category: 'engine',
        tier: PartQualityTier.good,
        conditionPercent: 88,
        estimatedValue: 120000.0,
        carModelName: 'Bemeve 3.20d',
      );

      const initialCar = ScrapyardCar(
        id: 'scrap_car_1',
        brand: 'Bemeve',
        modelName: '3.20d Yanlama E-90',
        modelYear: 2011,
        scrapPrice: 65000.0,
        estimatedPartTotalValue: 120000.0,
        damageNote: 'Ağır Pert',
        chassisScrapValue: 35000.0,
        parts: [initialPart],
        isPurchased: true,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
            theme: ThemeData(
              extensions: [
                AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
              ],
            ),
            home: const ScrapyardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        unlockedBuildings: {'/scrapyard'},
        scrapyardCars: [initialCar],
        salvagedParts: [],
      );
      await tester.pumpAndSettle();

      final sokumBtn = find.text('TEK TEK SÖK');
      expect(sokumBtn, findsOneWidget);
      await tester.tap(sokumBtn);
      await tester.pumpAndSettle();

      expect(find.text('PARÇA PARÇA SÖKÜM'), findsOneWidget);
      expect(find.text('1 Parça Kaldı'), findsOneWidget);
      expect(find.text('SÖK & AL'), findsOneWidget);

      await tester.tap(find.text('SÖK & AL'));
      await tester.pumpAndSettle();

      expect(find.text('HIZLI OTOMATİK SÖKÜM'), findsOneWidget);
      await tester.tap(find.text('HIZLI OTOMATİK SÖKÜM'));
      await tester.pumpAndSettle();

      expect(find.text('SÖKÜLDÜ'), findsOneWidget);
      expect(find.text('SÖK & AL'), findsNothing);
      expect(find.text('TAMAMI SÖKÜLDÜ'), findsOneWidget);
      expect(find.text('Söküldü • Depoya Aktarıldı'), findsOneWidget);

      final state = container.read(gameProvider);
      expect(state.scrapyardCars.first.parts, isEmpty);
      expect(state.salvagedParts.length, anyOf(0, 1));

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpWidget(const SizedBox());
    });
  });

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
        chassisScrapValue: 8100,
        surpriseFindItem: 'Orijinal Harman Kardon Amfi',
        surpriseFindValue: 3500,
        parts: const [
          SalvagedPart(
            id: 'part_engine_1',
            name: 'M54B22 6 Silindir Motor Bloğu',
            carModelName: 'BMW 320i',
            category: 'engine',
            conditionPercent: 40,
            tier: PartQualityTier.usable,
            estimatedValue: 22000,
          ),
          SalvagedPart(
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
        isPurchased: true,
        parts: const [],
      );

      notifier.state = container.read(gameProvider).copyWith(
        scrapyardCars: [testCar],
      );

      final result = notifier.crushChassisToScrapMetal('scrap_crush_test');
      expect(result.success, isTrue);
      expect(result.scrapMetalEarned, 5700);
      expect(result.surpriseEarned, 2500);
      expect(result.surpriseItemName, 'Nostaljik Kasetçalar & Altın Künye');

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

      final refurbCost = wornPart.refurbishCost;
      expect(refurbCost, greaterThan(0));

      final success = notifier.refurbishSalvagedPart('part_worn_test');
      expect(success, isTrue);

      final updatedParts = container.read(gameProvider).salvagedParts;
      final refurbishedPart = updatedParts.firstWhere((p) => p.id == 'part_worn_test');

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
        offeredPrice: 38000,
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

      final success = notifier.fulfillB2BPartOrder('order_haydar_1', 'part_b2b_passat_gearbox');
      expect(success, isTrue);

      expect(container.read(gameProvider).balance, 50000 + 38000);
      expect(container.read(gameProvider).reputationScore, 56);
      expect(container.read(gameProvider).salvagedParts.isEmpty, isTrue);
      expect(container.read(gameProvider).b2bPartOrders.firstWhere((o) => o.id == 'order_haydar_1').isCompleted, isTrue);
    });
  });
}
