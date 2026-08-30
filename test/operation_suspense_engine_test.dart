import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/car_wash/car_wash_screen.dart';
import 'package:galeriden/presentation/screens/workshop/tuning_studio_screen.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/data/models/tuning_model.dart';
import 'package:galeriden/domain/usecases/operation_suspense_engine.dart';
import 'package:galeriden/presentation/widgets/dialogs/neo_brutal_operation_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Operation Suspense & Animation Engine Test Suite', () {
    test('1. OperationSuspenseType correctly maps wash service IDs and tuning categories', () {
      expect(OperationSuspenseType.fromWashServiceId('pkg1'),
          equals(OperationSuspenseType.washFoam));
      expect(OperationSuspenseType.fromWashServiceId('pkg2'),
          equals(OperationSuspenseType.washInterior));
      expect(OperationSuspenseType.fromWashServiceId('pkg3'),
          equals(OperationSuspenseType.washPolish));
      expect(OperationSuspenseType.fromWashServiceId('pkg4'),
          equals(OperationSuspenseType.washCeramic));

      expect(OperationSuspenseType.fromTuningCategory(TuningCategory.powertrain),
          equals(OperationSuspenseType.tuningPowertrain));
      expect(OperationSuspenseType.fromTuningCategory(TuningCategory.aero),
          equals(OperationSuspenseType.tuningAero));
      expect(OperationSuspenseType.fromTuningCategory(TuningCategory.stance),
          equals(OperationSuspenseType.tuningStance));
      expect(OperationSuspenseType.fromTuningCategory(TuningCategory.exhaust),
          equals(OperationSuspenseType.tuningExhaust));
    });

    test('2. All operation types define valid stage keys and durations within 2.6s - 4.2s', () {
      final rng = Random(42);
      for (final op in OperationSuspenseType.values) {
        expect(op.stageKeys.length, equals(3));
        expect(op.titleKey.isNotEmpty, isTrue);

        final durations = op.generateStageDurations(rng: rng);
        expect(durations.length, equals(3));
        final totalMs = durations.reduce((a, b) => a + b);

        expect(totalMs >= 2600 && totalMs <= 4300, isTrue);
      }
    });

    testWidgets('3. NeoBrutalOperationDialog renders neo-brutalist workstation modal and steps through 3 stages', (tester) async {
      bool completed = false;
      final fixedRng = Random(100); // Deterministic

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NeoBrutalOperationDialog.show(
                    context,
                    operationType: OperationSuspenseType.washFoam,
                    carName: 'BMW M3',
                    rng: fixedRng,
                    onComplete: () {
                      completed = true;
                    },
                  );
                },
                child: const Text('Başlat'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Başlat'));
      await tester.pump();

      // Dialog is displayed
      expect(find.text('Köpüklü Standart Yıkama'), findsOneWidget);
      expect(find.text('BMW M3'), findsOneWidget);
      expect(find.text('İşlem Uygulanıyor...'), findsOneWidget);
      expect(find.text('Aşama 1 / 3'), findsOneWidget);

      expect(completed, isFalse);

      // Advance time for Stage 1
      await tester.pump(const Duration(milliseconds: 1400));
      expect(find.text('Aşama 2 / 3'), findsOneWidget);
      expect(completed, isFalse);

      // Advance time for Stage 2
      await tester.pump(const Duration(milliseconds: 1700));
      expect(find.text('Aşama 3 / 3'), findsOneWidget);
      expect(completed, isFalse);

      // Advance time for Stage 3 and completion
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.pumpAndSettle();

      // Callback executed and dialog dismissed
      expect(completed, isTrue);
      expect(find.byType(NeoBrutalOperationDialog), findsNothing);
    });

    testWidgets('4. Tuning powertrain operation dialog displays custom title and stage logs', (tester) async {
      bool tuningCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  NeoBrutalOperationDialog.show(
                    context,
                    operationType: OperationSuspenseType.tuningPowertrain,
                    carName: 'Porsche 911 GT3',
                    customTitle: 'Stage 2 Performans & Downpipe',
                    onComplete: () {
                      tuningCompleted = true;
                    },
                  );
                },
                child: const Text('Tuning Başlat'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Tuning Başlat'));
      await tester.pump();

      expect(find.text('Stage 2 Performans & Downpipe'), findsOneWidget);
      expect(find.text('Porsche 911 GT3'), findsOneWidget);

      // Advance until finish
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      expect(tuningCompleted, isTrue);
      expect(find.byType(NeoBrutalOperationDialog), findsNothing);
    });

    testWidgets('5. CarWashScreen triggers NeoBrutalOperationDialog when applying wash service', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final car = CarModel(
        id: 'car_wash_test_1',
        brand: 'Mercedes-Benz',
        modelName: 'C200',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 800000,
        currentPurchasePrice: 750000,
        isDetailedCleaned: false,
        isWashed: false,
        isPolished: false,
        isRare: false,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        declarationType: ListingDeclarationType.honest,
        appliedDetailingOptionIds: [],
        isRented: false,
        isDoped: false,
        isChassisRepaired: false,
        isLockedInShowcase: false,
        daysListed: 0,
        isHeroShowcase: false,
        isBarnFind: false,
        isBarnFindRestored: false,
        provenanceLog: [],
        allowsInstallments: false,
        listingPhotoLocation: 'outdoor_city',
        listingPhotoCount: 3,
        listingTone: 'classic',
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 500000.0,
        unlockedBuildings: {'/car-wash'},
        ownedCars: [car],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const CarWashScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      // Tap on the first "UYGULA" button for Köpüklü Yıkama
      final applyBtn = find.text('UYGULA').first;
      await tester.tap(applyBtn);
      await tester.pump();

      // Dialog opens
      expect(find.byType(NeoBrutalOperationDialog), findsOneWidget);
      expect(find.text('Köpüklü Standart Yıkama'), findsWidgets);
      expect(find.text('Mercedes-Benz C200'), findsWidgets);

      // Fast-forward animation and flush toast notification timers
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Dialog is gone
      expect(find.byType(NeoBrutalOperationDialog), findsNothing);
    });

    testWidgets('6. TuningStudioScreen triggers NeoBrutalOperationDialog when applying tuning mod', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final car = CarModel(
        id: 'car_tuning_test_1',
        brand: 'Audi',
        modelName: 'RS6',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1500000,
        currentPurchasePrice: 1400000,
        isDetailedCleaned: false,
        isWashed: false,
        isPolished: false,
        isRare: false,
        expertise: ExpertiseReport(
          engineCondition: 95,
          transmissionCondition: 95,
          tramerAmount: 0,
          mileage: 25000,
          isMileageTampered: false,
          bodyParts: {},
        ),
        declarationType: ListingDeclarationType.honest,
        appliedDetailingOptionIds: [],
        isRented: false,
        isDoped: false,
        isChassisRepaired: false,
        isLockedInShowcase: false,
        daysListed: 0,
        isHeroShowcase: false,
        isBarnFind: false,
        isBarnFindRestored: false,
        provenanceLog: [],
        allowsInstallments: false,
        listingPhotoLocation: 'outdoor_city',
        listingPhotoCount: 3,
        listingTone: 'classic',
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 1000000.0,
        unlockedBuildings: {'/tuning-studio'},
        ownedCars: [car],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const TuningStudioScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      // Tap on the first "UYGULA" button in tuning catalog
      final applyBtn = find.text('UYGULA').first;
      await tester.tap(applyBtn);
      await tester.pump();

      // Dialog opens
      expect(find.byType(NeoBrutalOperationDialog), findsOneWidget);
      expect(find.text('Audi RS6'), findsWidgets);

      // Fast-forward animation and flush toast notification timers
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Dialog is gone
      expect(find.byType(NeoBrutalOperationDialog), findsNothing);
    });
  });
}
