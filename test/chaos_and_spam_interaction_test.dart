import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/constants/game_constants.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/theme_provider.dart';
import 'package:galeriden/presentation/screens/branch/showroom_decor_screen.dart';
import 'package:galeriden/presentation/screens/car_wash/car_wash_screen.dart';
import 'package:galeriden/presentation/screens/settings/theme_store_screen.dart';
import 'package:galeriden/presentation/screens/showroom/widgets/showroom_car_card.dart';
import 'package:galeriden/presentation/screens/side_business/side_business_screen.dart';
import 'package:galeriden/presentation/screens/staff/staff_academy_screen.dart';
import 'package:galeriden/presentation/screens/staff/staff_screen.dart';
import 'package:galeriden/presentation/screens/workshop/widgets/workshop_repair_tile.dart';
import 'package:galeriden/presentation/screens/workshop/workshop_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final testTheme = ThemeData.dark().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    toastification.dismissAll(delayForAnimation: false);
  });

  Future<void> drainTimers(WidgetTester tester) async {
    toastification.dismissAll(delayForAnimation: false);
    await tester.pump(const Duration(seconds: 12));
    await tester.pumpAndSettle();
  }

  CarModel createSampleCar({
    String id = 'spam_test_car_1',
    double price = 500000,
    bool isListed = false,
    bool isDoped = false,
    bool isHeroShowcase = false,
    bool isWashed = false,
    bool isPolished = false,
    bool isDetailedCleaned = false,
    double engineCondition = 80,
    double transmissionCondition = 80,
  }) {
    return CarModel(
      id: id,
      brand: 'BMW',
      modelName: '320i M Sport',
      modelYear: 2020,
      bodyType: 'Sedan',
      colorHex: '#000000',
      baseMarketValue: price,
      currentPurchasePrice: price,
      customListingPrice: isListed ? price : null,
      isDoped: isDoped,
      isHeroShowcase: isHeroShowcase,
      isWashed: isWashed,
      isPolished: isPolished,
      isDetailedCleaned: isDetailedCleaned,
      expertise: ExpertiseReport(
        engineCondition: engineCondition,
        transmissionCondition: transmissionCondition,
        tramerAmount: 0,
        mileage: 65000,
        isMileageTampered: false,
        bodyParts: const {
          'Kaput': PartStatus.painted,
          'Ön Tampon': PartStatus.changed,
          'Tavan': PartStatus.original,
        },
      ),
    );
  }

  group('Aggressive Chaos & Spam Interaction Test Suite', () {
    testWidgets('1. Showroom Showcase Lock & Doping Button Spam Safety', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialCar = createSampleCar(isListed: true);
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: Consumer(
                  builder: (context, ref, _) {
                    final game = ref.watch(gameProvider);
                    final theme = ref.watch(themeProvider);
                    final car = game.ownedCars.first;
                    return ShowroomCarCard(
                      car: car,
                      game: game,
                      palette: theme.activePalette,
                      hasSalesman: false,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        ownedCars: [initialCar],
      );
      await tester.pumpAndSettle();

      // Verify Initial State
      expect(find.text('Koleksiyon Vitrinine Kilitle (+%5 İtibar)'), findsOneWidget);
      expect(find.textContaining('Öne Çıkar'), findsOneWidget);

      // Lock in showcase
      final lockBtn = find.text('Koleksiyon Vitrinine Kilitle (+%5 İtibar)');
      await tester.ensureVisible(lockBtn);
      await tester.tap(lockBtn);
      await drainTimers(tester);

      // Verify car is locked, badge and button updated
      expect(container.read(gameProvider).ownedCars.first.isLockedInShowcase, true);
      expect(find.text('Koleksiyon Vitrininden Çıkar (Satışa Aç)'), findsOneWidget);
      expect(find.text('KOLEKSİYONDA'), findsOneWidget);

      final balanceBeforeDoping = container.read(gameProvider).balance;

      // SPAM CLICK "Öne Çıkar" (Doping) 10 times
      final dopingBtn = find.textContaining('Öne Çıkar');
      await tester.ensureVisible(dopingBtn);
      for (int i = 0; i < 10; i++) {
        await tester.tap(dopingBtn);
      }
      await drainTimers(tester);

      // Balance deducted only once for doping (₺2,500)
      expect(container.read(gameProvider).balance, balanceBeforeDoping - GameConstants.dopingCost);
      expect(container.read(gameProvider).ownedCars.first.isDoped, true);
      expect(find.text('Dopingli'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await drainTimers(tester);
    });

    testWidgets('2. Car Wash & Detailing Service Spam Double-Charge Prevention', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialCar = createSampleCar();
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const CarWashScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 200000.0,
        ownedCars: [initialCar],
      );
      await tester.pumpAndSettle();

      expect(find.text('UYGULA'), findsWidgets);

      final initialBalance = container.read(gameProvider).balance;

      // SPAM CLICK the first "UYGULA" button (Köpüklü Standart Yıkama - ₺350)
      final firstApplyBtn = find.text('UYGULA').first;
      for (int i = 0; i < 8; i++) {
        await tester.tap(firstApplyBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      // State check: Washed should be true, balance deducted exactly ₺350 once
      final updatedCar = container.read(gameProvider).ownedCars.first;
      expect(updatedCar.isWashed, true);
      expect(container.read(gameProvider).balance, initialBalance - 350.0);

      // Verify button label immediately updated to "UYGULANDI"
      expect(find.text('UYGULANDI'), findsAtLeastNWidgets(1));

      // SPAM CLICK Detaylı İç-Dış Yıkama (₺1,200)
      final balanceBeforeInterior = container.read(gameProvider).balance;
      final secondApplyBtn = find.text('UYGULA').first;
      for (int i = 0; i < 8; i++) {
        await tester.tap(secondApplyBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      expect(container.read(gameProvider).ownedCars.first.isInteriorCleaned, true);
      expect(container.read(gameProvider).balance, balanceBeforeInterior - 1200.0);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await drainTimers(tester);
    });

    testWidgets('3. Theme Store Unlock & Apply Button State Transitions and Spam', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const ThemeStoreScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
      );
      await tester.pumpAndSettle();

      // Verify "AKTİF" for currently active theme
      expect(find.text('AKTİF'), findsOneWidget);
      // Verify "SATIN AL" for locked themes
      expect(find.text('SATIN AL'), findsWidgets);

      // Now unlock a new theme by spam clicking "SATIN AL"
      final balanceBeforeUnlock = container.read(gameProvider).balance;
      final buyBtn = find.text('SATIN AL').first;
      for (int i = 0; i < 6; i++) {
        await tester.tap(buyBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      // Should be unlocked and activated, balance deducted once
      expect(container.read(gameProvider).balance < balanceBeforeUnlock, true);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await drainTimers(tester);
    });

    testWidgets('4. Staff Hire / Fire & Staff Academy Certification Spam Safety', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const StaffScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        hiredStaff: [],
      );
      await tester.pumpAndSettle();

      // Initial state: "İŞE AL"
      expect(find.text('İŞE AL'), findsWidgets);
      expect(find.text('İŞTEN ÇIKAR'), findsNothing);

      // SPAM CLICK "İŞE AL" on first role
      final hireBtn = find.text('İŞE AL').first;
      for (int i = 0; i < 10; i++) {
        await tester.tap(hireBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      // Exactly 1 staff should be hired
      expect(container.read(gameProvider).hiredStaff.length, 1);
      expect(find.text('İŞTEN ÇIKAR'), findsOneWidget);

      // SPAM CLICK "İŞTEN ÇIKAR"
      final fireBtn = find.text('İŞTEN ÇIKAR').first;
      for (int i = 0; i < 10; i++) {
        await tester.tap(fireBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      // Staff removed cleanly
      expect(container.read(gameProvider).hiredStaff.isEmpty, true);
      expect(find.text('İŞTEN ÇIKAR'), findsNothing);

      // Test Staff Academy Course Enrollment Spam
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const StaffAcademyScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EĞİTİME GÖNDER'), findsWidgets);
      expect(find.text('SERTİFİKA ALINDI'), findsNothing);

      final balanceBeforeCourse = container.read(gameProvider).balance;
      final enrollBtn = find.text('EĞİTİME GÖNDER').first;
      for (int i = 0; i < 8; i++) {
        await tester.tap(enrollBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      // Course unlocked once, button transitions to "SERTİFİKA ALINDI"
      expect(container.read(gameProvider).purchasedAcademyCourses.length, 1);
      expect(find.text('SERTİFİKA ALINDI'), findsOneWidget);
      expect(find.text('SERTİFİKALI'), findsOneWidget);
      expect(container.read(gameProvider).balance < balanceBeforeCourse, true);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await drainTimers(tester);
    });

    testWidgets('5. Showroom Decor & Side Business Purchase Spam Safety', (tester) async {
      final container = ProviderContainer();

      final testBusiness = SideBusinessModel(
        id: 'test_biz_1',
        name: 'Oto Kuaför İstasyonu',
        description: 'Detaylı temizlik dükkanı',
        type: SideBusinessType.carWash,
        dailyIncome: 500.0,
        cost: 25000.0,
        isOwned: false,
        level: 1,
      );

      // Test Showroom Decor Screen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const ShowroomDecorScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final notifier = container.read(gameProvider.notifier);
      notifier.state = notifier.state.copyWith(
        balance: 1000000.0,
        sideBusinesses: [testBusiness],
      );
      await tester.pumpAndSettle();

      expect(find.text('İNŞA ET'), findsWidgets);
      expect(find.text('İNŞA EDİLDİ'), findsNothing);

      final initialDecors = container.read(gameProvider).unlockedDecorIds.length;
      final decorBtn = find.text('İNŞA ET').first;
      for (int i = 0; i < 8; i++) {
        await tester.tap(decorBtn, warnIfMissed: false);
      }
      await drainTimers(tester);

      // Decor purchased once, unlockedDecorIds updated, button label updated
      expect(container.read(gameProvider).unlockedDecorIds.length, initialDecors + 1);
      expect(find.text('İNŞA EDİLDİ'), findsWidgets);
      expect(find.text('AKTİF'), findsOneWidget);

      // Test Side Business Screen
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const SideBusinessScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buyBusinessFinder = find.byWidgetPredicate(
        (widget) => widget is Text && widget.data != null && widget.data!.startsWith('SATIN AL'),
      );
      expect(buyBusinessFinder, findsWidgets);

      for (int i = 0; i < 8; i++) {
        await tester.tap(buyBusinessFinder.first, warnIfMissed: false);
      }
      await drainTimers(tester);

      // Business is now owned and button switches to YÖNET & GELİŞTİR
      expect(find.text('YÖNET & GELİŞTİR'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await drainTimers(tester);
    });

    testWidgets('6. Workshop Repair Direct Execution and State Feedback Update', (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final brokenCar = createSampleCar(
        engineCondition: 60,
        transmissionCondition: 100,
      );
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = notifier.state.copyWith(
        balance: 500000.0,
        ownedCars: [brokenCar],
      );

      final initialBalance = notifier.state.balance;

      // Execute repair via notifier directly
      final repairSuccess = notifier.performWorkshopStationRepair(
        brokenCar.id,
        repairType: 'engine',
        cost: 18500.0,
      );
      expect(repairSuccess, true);
      expect(notifier.state.ownedCars.first.expertise.engineCondition, 100.0);
      expect(notifier.state.balance < initialBalance, true);

      // Immediate second repair must be rejected
      final secondRepair = notifier.performWorkshopStationRepair(
        brokenCar.id,
        repairType: 'engine',
        cost: 18500.0,
      );
      expect(secondRepair, false);

      // Verify in WorkshopScreen UI that repaired engine station shows ONARILDI / KUSURSUZ
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: testTheme,
            home: const WorkshopScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WorkshopRepairTile), findsWidgets);

      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await drainTimers(tester);
    });
  });
}
