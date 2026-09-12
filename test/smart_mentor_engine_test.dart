import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/domain/usecases/smart_mentor_engine.dart';
import 'package:galeriden/presentation/widgets/pixel_mentor_avatar.dart';
import 'package:galeriden/presentation/widgets/smart_mentor_dialog.dart';

CarModel createTestCar({
  String id = 'car_test_1',
  double baseMarketValue = 100000.0,
  double? customListingPrice,
  bool isListed = false,
  bool isWashed = true,
  double engineCondition = 90.0,
  double transmissionCondition = 90.0,
  Map<String, PartStatus> bodyParts = const {'Kaput': PartStatus.original},
}) {
  final effectiveCustomListingPrice = customListingPrice ?? (isListed ? baseMarketValue * 1.1 : null);

  return CarModel(
    id: id,
    brand: 'Toyota',
    modelName: 'Corolla',
    modelYear: 2020,
    bodyType: 'Sedan',
    colorHex: '#FFFFFF',
    baseMarketValue: baseMarketValue,
    currentPurchasePrice: baseMarketValue * 0.85,
    customListingPrice: effectiveCustomListingPrice,
    isWashed: isWashed,
    expertise: ExpertiseReport(
      mileage: 60000,
      isMileageTampered: false,
      engineCondition: engineCondition,
      transmissionCondition: transmissionCondition,
      tramerAmount: 0,
      bodyParts: bodyParts,
      partConditions: const {'Kaput': 100.0},
    ),
  );
}

void main() {
  group('SmartMentorEngine Unit Tests', () {
    test('Gating: returns null if tutorial is not completed', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: false,
        balance: 1000.0,
        ownedCars: [],
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNull);
    });

    test('stuckBrokeNoCar: triggers when balance < 25k and no cars owned', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 12000.0,
        ownedCars: [],
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.stuckBrokeNoCar));
      expect(advice.targetRoute, equals('/marketplace'));
      expect(advice.titleKey, equals('mentor_title_broke_no_car'));
    });

    test('stuckNoListing: triggers when cars are owned but none are listed', () {
      final car = createTestCar(id: 'car_1', isListed: false);
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 50000.0,
        ownedCars: [car],
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.stuckNoListing));
      expect(advice.targetRoute, equals('/showroom'));
      expect(advice.titleKey, equals('mentor_title_no_listing'));
    });

    test('stuckOverpriced: triggers when cash is tight and car listed > 25% above market', () {
      final car = createTestCar(
        id: 'car_overpriced',
        isListed: true,
        baseMarketValue: 100000.0,
        customListingPrice: 140000.0, // 40% markup
      );
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 30000.0, // under 60k threshold
        ownedCars: [car],
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.stuckOverpriced));
      expect(advice.targetRoute, equals('/showroom'));
    });

    test('branchUpgradedCelebration: triggers when current tier exceeds last celebrated tier', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 200000.0,
        unlockedBuildings: const {'property_tier_2'}, // Tier 2
        ownedCars: [createTestCar(isListed: true)],
      );

      final advice = SmartMentorEngine.evaluateAdvice(
        state,
        lastCelebratedBranchTier: 1,
      );

      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.branchUpgradedCelebration));
      expect(advice.targetRoute, equals('/branches'));
      expect(advice.params['branchName'], isNotEmpty);
    });

    test('branchUpgradeReady: triggers when balance and level suffice for next tier', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 2,
        balance: 150000.0, // >= 100,000 for tier 2
        ownedCars: [createTestCar(isListed: true)],
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.branchUpgradeReady));
      expect(advice.targetRoute, equals('/branches'));
      expect(advice.params['branchName'], isNotEmpty);
      expect(advice.params['slots'], isNotEmpty);
    });

    test('newFeatureUnlocked: triggers for unseen unlocked feature', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 3, // /vasita unlocked at level 3
        balance: 50000.0,
        ownedCars: [createTestCar(isListed: true)],
        seenFeatureRoutes: const {
          '/car-wash',
          '/workshop',
          '/staff',
          '/tuning-studio',
        }, // /vasita is unseen
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.featureUnlocked));
      expect(advice.targetRoute, equals('/vasita'));
    });

    test('dirtyCarValueLoss: prompts car wash when dirty car is in inventory', () {
      final dirtyCar = createTestCar(
        isListed: true,
        isWashed: false, // dirty / unwashed
      );
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 1,
        balance: 50000.0,
        unlockedBuildings: const {'/car-wash'},
        ownedCars: [dirtyCar],
        seenFeatureRoutes: const {
          '/car-wash',
          '/workshop',
          '/staff',
          '/tuning-studio',
          '/vasita',
          '/emlak',
          '/auction',
          '/bank-investments',
          '/stock-market',
        },
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.dirtyCarValueLoss));
      expect(advice.targetRoute, equals('/car-wash'));
    });

    test('damagedCarRepairOpportunity: prompts workshop when damaged parts exist', () {
      final damagedCar = createTestCar(
        isListed: true,
        isWashed: true,
        engineCondition: 50.0, // damaged engine
      );
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 1,
        balance: 50000.0,
        unlockedBuildings: const {'/workshop'},
        ownedCars: [damagedCar],
        seenFeatureRoutes: const {
          '/car-wash',
          '/workshop',
          '/staff',
          '/tuning-studio',
          '/vasita',
          '/emlak',
          '/auction',
          '/bank-investments',
          '/stock-market',
        },
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.damagedCarRepairOpportunity));
      expect(advice.targetRoute, equals('/workshop'));
    });

    test('idleCashSurplus: prompts marketplace when cash is high and slots are open', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 1, // Branch 2 requires level 2, so branchUpgradeReady will not trigger
        balance: 220000.0, // >= 150k
        maxGarageSlots: 4,
        ownedCars: [createTestCar(isListed: true)],
        seenFeatureRoutes: const {
          '/car-wash',
          '/workshop',
          '/staff',
          '/tuning-studio',
          '/vasita',
          '/emlak',
          '/auction',
          '/bank-investments',
          '/stock-market',
        },
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.idleCashSurplus));
      expect(advice.targetRoute, equals('/marketplace'));
    });

    test('rivalDominanceNudge: prompts leaderboard every 5 days after day 1', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 1, // Branch 2 requires level 2
        currentDay: 5,
        carsSold: 3,
        balance: 70000.0,
        maxGarageSlots: 1,
        ownedCars: [createTestCar(isListed: true)],
        seenFeatureRoutes: const {
          '/car-wash',
          '/workshop',
          '/staff',
          '/tuning-studio',
          '/vasita',
          '/emlak',
          '/auction',
          '/bank-investments',
          '/stock-market',
        },
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.rivalDominanceNudge));
      expect(advice.targetRoute, equals('/leaderboard'));
    });
  });

  group('PixelMentorAvatar & SmartMentorDialog Widget Tests', () {
    testWidgets('PixelMentorAvatar renders with custom scanlines and matrix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelMentorAvatar(
                size: 72,
                animated: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(PixelMentorAvatar), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('SmartMentorDialog renders with Neo-Brutalist styling and localized text', (tester) async {
      const advice = SmartMentorAdvice(
        type: SmartMentorAdviceType.stuckBrokeNoCar,
        titleKey: 'mentor_title_broke_no_car',
        quoteKey: 'mentor_quote_broke_no_car',
        tacticalKey: 'mentor_tactical_broke_no_car',
        actionBtnKey: 'mentor_action_go_marketplace',
        targetRoute: '/marketplace',
        iconData: Icons.storefront_rounded,
        accentColor: AppColors.brutalRed,
      );

      final testTheme = ThemeData.light().copyWith(
        extensions: [
          AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            locale: const Locale('tr'),
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
              Locale('de'),
              Locale('pt'),
              Locale('es'),
              Locale('ru'),
              Locale('ar'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: testTheme,
            home: const Scaffold(
              body: SmartMentorDialog(
                advice: advice,
                animatedAvatar: false,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byType(SmartMentorDialog), findsOneWidget);
      expect(find.byType(PixelMentorAvatar), findsOneWidget);
      expect(find.text('HALİL USTA'), findsOneWidget);
      expect(find.text('Kasa Boş • Sıfır Araç Stoğu'), findsOneWidget);
      expect(find.text('Pazara İn • Kelepir Fırsatları Gör'), findsOneWidget);
      expect(find.text('Eyvallah Usta • Anlaşıldı'), findsOneWidget);
    });
  });
}
