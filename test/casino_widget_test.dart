import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/domain/usecases/casino_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/casino/casino_hub_screen.dart';
import 'package:galeriden/presentation/screens/casino/widgets/valet_baccarat_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/street_craps_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/hilo_vites_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/plinko_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/lucky_wheel_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/scratch_card_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/double_or_nothing_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/aviator_crash_modal.dart';
import 'package:galeriden/presentation/screens/casino/widgets/sanayi_barbutu_modal.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    container = ProviderContainer();
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
  });

  tearDown(() {
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    container.dispose();
  });

  Widget buildTestableWidget(Widget child) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr'), Locale('en')],
        locale: const Locale('tr'),
        home: Scaffold(body: child),
      ),
    );
  }

  group('Casino Hub & Mini-Games Widget Tests', () {
    testWidgets('CasinoHubScreen renders stats card, tiers, and game cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 5000000.0,
        unlockedBuildings: {'property_tier_5'},
      );

      await tester.pumpWidget(buildTestableWidget(const CasinoHubScreen()));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('OTO CENTER • YERALTI CASINO'), findsOneWidget);
      expect(find.text('VIP KULÜP İSTATİSTİKLERİ'), findsOneWidget);
      expect(find.text('Baccarat • Klasik Masa', skipOffstage: false), findsOneWidget);
      expect(find.text('Craps • Sokak Zarı', skipOffstage: false), findsOneWidget);
      expect(find.text('Hi-Lo • Büyük Küçük', skipOffstage: false), findsOneWidget);
      expect(find.text('Sanayi Barbutu', skipOffstage: false), findsOneWidget);
      expect(find.text('Aviator • Turbo Roket', skipOffstage: false), findsOneWidget);
      expect(find.text('Plinko • Şans Piramidi', skipOffstage: false), findsOneWidget);
      expect(find.text('Mega Wheel • Şans Çarkı', skipOffstage: false), findsOneWidget);
      expect(find.text('Altın Kazı Kazan', skipOffstage: false), findsOneWidget);
      expect(find.text('Yazı Tura • 2x Katla', skipOffstage: false), findsOneWidget);
    });

    testWidgets('ValetBaccaratModal renders 3 buttons and executes deal', (tester) async {
      final sampleCar = CasinoEngine.createRewardCar(
        brand: 'Porsche',
        modelName: '911 GT3 RS',
        year: 2023,
        price: 4500000.0,
      );

      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 2000000.0,
        ownedCars: [sampleCar],
        unlockedBuildings: {'property_tier_5'},
      );

      await tester.pumpWidget(buildTestableWidget(const ValetBaccaratModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Baccarat • Klasik Masa'), findsOneWidget);
      expect(find.text('OYUNCU • 2x'), findsOneWidget);
      expect(find.text('BERABERLİK • 8x'), findsOneWidget);
      expect(find.text('KASA • 1.95x'), findsOneWidget);

      // Tap Player button
      await tester.tap(find.text('OYUNCU • 2x'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));
    });

    testWidgets('StreetCrapsModal renders dice and rolls come-out', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'property_tier_5'},
      );

      await tester.pumpWidget(buildTestableWidget(const StreetCrapsModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Craps • Sokak Zarı'), findsOneWidget);
      expect(find.text('AÇILIŞ ZARINI AT'), findsOneWidget);

      await tester.tap(find.text('AÇILIŞ ZARINI AT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pump(const Duration(milliseconds: 300));

      // Either game finished (1 game played) or point established (phase changed)
      final state = container.read(gameProvider);
      expect(
        state.casinoStats.totalGamesPlayed == 1 || find.text('HEDEF İÇİN ZAR AT').evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('HiLoVitesModal starts run and guesses higher', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'property_tier_5'},
      );

      await tester.pumpWidget(buildTestableWidget(const HiLoVitesModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Hi-Lo • Büyük Küçük'), findsOneWidget);
      expect(find.text('OYUNA BAŞLA'), findsOneWidget);

      await tester.tap(find.text('OYUNA BAŞLA'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('DAHA BÜYÜK • YÜKSEK'), findsOneWidget);
      expect(find.text('DAHA KÜÇÜK • DÜŞÜK'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('PlinkoModal drops ball and lands in slot', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'property_tier_6'},
      );

      await tester.pumpWidget(buildTestableWidget(const PlinkoModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Plinko • Şans Piramidi'), findsOneWidget);
      expect(find.text('TOPU BIRAK'), findsOneWidget);

      await tester.tap(find.text('TOPU BIRAK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2500));
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));
    });

    testWidgets('LuckyWheelModal spins wheel with deceleration', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 2000000.0,
        unlockedBuildings: {'property_tier_6'},
      );

      await tester.pumpWidget(buildTestableWidget(const LuckyWheelModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Mega Wheel • Şans Çarkı'), findsOneWidget);
      expect(find.text('ÇARKI ÇEVİR'), findsOneWidget);

      await tester.tap(find.text('ÇARKI ÇEVİR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 4500));
      await tester.pump(const Duration(milliseconds: 400));

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));
    });

    testWidgets('ScratchCardModal buys card and scratches spots', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'property_tier_7'},
      );

      await tester.pumpWidget(buildTestableWidget(const ScratchCardModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Altın Kazı Kazan'), findsOneWidget);
      expect(find.text('KART SATIN AL • ₺25K'), findsOneWidget);

      await tester.tap(find.text('KART SATIN AL • ₺25K'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('TÜMÜNÜ KAZI'), findsOneWidget);

      await tester.tap(find.text('TÜMÜNÜ KAZI'));
      await tester.pump(const Duration(milliseconds: 200));

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('DoubleOrNothingModal flips coin for 2x or 0x', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
      );

      await tester.pumpWidget(buildTestableWidget(const DoubleOrNothingModal(baseProfit: 100000.0)));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Yazı Tura • 2x Katla'), findsOneWidget);
      expect(find.text('YAZI • 2x'), findsOneWidget);
      expect(find.text('TURA • 2x'), findsOneWidget);

      await tester.tap(find.text('YAZI • 2x'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 2200));
      await tester.pump(const Duration(milliseconds: 300));

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));
    });

    testWidgets('AviatorCrashModal launches flight and cashes out', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'property_tier_6'},
      );

      await tester.pumpWidget(buildTestableWidget(const AviatorCrashModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Aviator • Turbo Roket'), findsOneWidget);
      expect(find.text('UÇUŞU BAŞLAT'), findsOneWidget);

      await tester.tap(find.text('UÇUŞU BAŞLAT'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Button should now show cashout or flight ended
      final cashoutFinder = find.byWidgetPredicate((w) => w.toString().contains('KAZANCI AL'));
      if (cashoutFinder.evaluate().isNotEmpty) {
        await tester.tap(cashoutFinder.first);
        await tester.pump(const Duration(milliseconds: 200));
      }

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));
    });

    testWidgets('SanayiBarbutuModal shakes cup and rolls dice', (tester) async {
      container.read(gameProvider.notifier).state = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'property_tier_5'},
      );

      await tester.pumpWidget(buildTestableWidget(const SanayiBarbutuModal()));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Sanayi Barbutu'), findsOneWidget);
      expect(find.text('ZARLARI AT'), findsOneWidget);

      await tester.tap(find.text('ZARLARI AT'));
      await tester.pump();
      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(container.read(gameProvider).casinoStats.totalGamesPlayed, equals(1));
    });
  });
}
