import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/listing_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/domain/usecases/mentor_quest_engine.dart';
import 'package:galeriden/domain/usecases/smart_mentor_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_mentor_card.dart';
import 'package:galeriden/presentation/widgets/pixel_mentor_avatar.dart';
import 'package:galeriden/presentation/widgets/smart_mentor_dialog.dart';

ListingModel createTestListing({
  String id = 'listing_test_1',
  required CarModel car,
  double askingPrice = 80000.0,
}) {
  return ListingModel(
    id: id,
    car: car,
    sellerName: 'Ahmet Bey',
    sellerTrait: 'Esnaf',
    sellerCity: 'İstanbul',
    title: 'Acil Satılık Temiz Araç',
    description: 'İlk sahibinden temiz bakımlı araç.',
    askingPrice: askingPrice,
    createdAt: DateTime.now(),
  );
}

LoanModel createTestLoan({
  String id = 'loan_1',
  double remainingAmount = 150000.0,
  double monthlyPayment = 15000.0,
  int remainingInstallments = 10,
}) {
  return LoanModel(
    id: id,
    bankName: 'Halkbank',
    principalAmount: 150000.0,
    interestRate: 0.15,
    totalRepayment: 172500.0,
    remainingAmount: remainingAmount,
    totalInstallments: 12,
    remainingInstallments: remainingInstallments,
    monthlyPayment: monthlyPayment,
  );
}

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
      expect(advice.quoteKey, equals('mentor_feat_vasita_quote'));
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

    test('unofferedListingStale: triggers when car listed >= 2 days without offers', () {
      final car = createTestCar(id: 'car_stale', isListed: true).copyWith(
        daysListed: 3,
      );
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 100000.0,
        ownedCars: [car],
        incomingOffers: [],
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.unofferedListingStale));
      expect(advice.targetRoute, equals('/showroom'));
      expect(advice.params['carName'], isNotEmpty);
      expect(advice.isCriticalModal, isFalse);
    });

    test('bargainMarketRadar: triggers when market has car <= 80% market value and player has cash and garage slot', () {
      final marketCar = createTestCar(id: 'car_market_1', baseMarketValue: 100000.0);
      final bargainListing = createTestListing(
        id: 'bargain_1',
        car: marketCar,
        askingPrice: 75000.0,
      );
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 100000.0,
        maxGarageSlots: 3,
        ownedCars: [createTestCar(id: 'car_owned_1', isListed: true)],
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

      final advice = SmartMentorEngine.evaluateAdvice(
        state,
        marketListings: [bargainListing],
      );
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.bargainMarketRadar));
      expect(advice.targetRoute, equals('/marketplace'));
      expect(advice.params['carName'], isNotEmpty);
      expect(advice.isCriticalModal, isFalse);
    });

    test('debtInstallmentWarning: triggers when active loans exist and balance < 50k', () {
      final loan = createTestLoan();
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 45000.0,
        activeLoans: [loan],
        maxGarageSlots: 1,
        ownedCars: [createTestCar(id: 'car_owned_1', isListed: true)],
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
      expect(advice!.type, equals(SmartMentorAdviceType.debtInstallmentWarning));
      expect(advice.targetRoute, equals('/finance'));
      expect(advice.isCriticalModal, isFalse);
    });

    test('Priority Inversion Fix: featureUnlocked precedes stuckNoListing', () {
      final unlistedCar = createTestCar(id: 'car_unlisted', isListed: false);
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        level: 3,
        balance: 50000.0,
        ownedCars: [unlistedCar],
        seenFeatureRoutes: const {
          '/car-wash',
          '/workshop',
          '/staff',
          '/tuning-studio',
        },
      );

      final advice = SmartMentorEngine.evaluateAdvice(state);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.featureUnlocked));
      expect(advice.targetRoute, equals('/vasita'));
      expect(advice.isCriticalModal, isTrue);
    });

    test('isCriticalModal Audit: Only critical crisis events have isCriticalModal == true', () {
      final brokeState = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 10000.0,
        ownedCars: [],
      );
      expect(SmartMentorEngine.evaluateAdvice(brokeState)!.isCriticalModal, isTrue);

      final upgradeState = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        unlockedBuildings: const {'property_tier_2'},
        ownedCars: [createTestCar(isListed: true)],
      );
      expect(SmartMentorEngine.evaluateAdvice(upgradeState, lastCelebratedBranchTier: 1)!.isCriticalModal, isTrue);

      final noListingState = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 50000.0,
        ownedCars: [createTestCar(isListed: false)],
        seenFeatureRoutes: const {
          '/car-wash', '/workshop', '/staff', '/tuning-studio',
          '/vasita', '/emlak', '/auction', '/bank-investments', '/stock-market',
        },
      );
      expect(SmartMentorEngine.evaluateAdvice(noListingState)!.isCriticalModal, isFalse);
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

    testWidgets('DashboardMentorCard renders ambient desk card with localized quote and action', (tester) async {
      final testCar = createTestCar(id: 'car_stale', isListed: true).copyWith(
        daysListed: 3,
      );
      final testState = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 100000.0,
        maxGarageSlots: 1,
        ownedCars: [testCar],
        incomingOffers: [],
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

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(testState.toJson()),
      });

      final container = ProviderContainer(
        overrides: [
          gameProvider.overrideWith((ref) => GameNotifier()),
        ],
      );

      addTearDown(() {
        container.dispose();
      });

      final testTheme = ThemeData.light().copyWith(
        extensions: [
          AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
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
              body: SingleChildScrollView(
                child: DashboardMentorCard(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(marketProvider.notifier).onAppPaused();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(DashboardMentorCard), findsOneWidget);
      expect(find.byType(PixelMentorAvatar), findsOneWidget);
      expect(find.text('HALİL USTA MASASI'), findsOneWidget);
      expect(find.text('Durgun İlan • Teklif Tıkanıklığı'), findsOneWidget);
      expect(find.text('Vitrini İncele • İlanı Hızlandır'), findsOneWidget);
    });
  });

  group('SmartMentorEngine - Utility Scoring & Memory Dynamics', () {
    test('Higher utility candidate wins competition over lower utility candidate', () {
      final unlistedCar = createTestCar(id: 'c_unlisted', isListed: false);
      final heavyLoan = createTestLoan(remainingAmount: 50000.0, monthlyPayment: 30000.0);

      // balance = 10000 < 35000 -> debtInstallmentWarning triggers with isCriticalDebt=true (utility 0.95)
      // unlistedCar -> stuckNoListing triggers (utility 0.72)
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 10000.0,
        ownedCars: [unlistedCar],
        activeLoans: [heavyLoan],
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
      expect(advice!.type, equals(SmartMentorAdviceType.debtInstallmentWarning));
      expect(advice.utilityScore, closeTo(0.95, 0.01));
      expect(advice.mood, equals(MentorMood.worried));
    });

    test('Fatigue damping decays repeated advice utility and allows competing advice to win', () {
      final unlistedCar = createTestCar(id: 'c_unlisted', isListed: false);
      final heavyLoan = createTestLoan(remainingAmount: 50000.0, monthlyPayment: 30000.0);

      // debtInstallmentWarning has been repeated for 3 consecutive days:
      // Damped score: 0.95 * (0.80 ^ 3) = 0.95 * 0.512 = ~0.4864
      // stuckNoListing has base utility 0.72 and will overtake debtInstallmentWarning
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 10000.0,
        ownedCars: [unlistedCar],
        activeLoans: [heavyLoan],
        mentorMemory: {
          'lastAdvisedType': SmartMentorAdviceType.debtInstallmentWarning.name,
          'lastAdvisedDay': 3,
          'consecutiveDays': 3,
        },
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
      expect(advice!.type, equals(SmartMentorAdviceType.stuckNoListing));
      expect(advice.utilityScore, closeTo(0.72, 0.01));
      expect(advice.mood, equals(MentorMood.teaSip));
    });

    test('Selected advice quoteKey incorporates dynamic variant suffix (_v1, _v2, or _v3)', () {
      final unlistedCar = createTestCar(id: 'c_unlisted', isListed: false);
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 50000.0,
        ownedCars: [unlistedCar],
        currentDay: 4,
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
      expect(advice!.quoteKey, anyOf(
        endsWith('_v1'),
        endsWith('_v2'),
        endsWith('_v3'),
      ));
    });

    test('recordAdviceGiven increments consecutiveDays on same advice or resets on new advice', () {
      final baseState = DealershipModel.initial().copyWith(
        currentDay: 5,
        mentorMemory: {
          'lastAdvisedType': SmartMentorAdviceType.dirtyCarValueLoss.name,
          'lastAdvisedDay': 4,
          'consecutiveDays': 1,
        },
      );

      const adviceSame = SmartMentorAdvice(
        type: SmartMentorAdviceType.dirtyCarValueLoss,
        titleKey: 't',
        quoteKey: 'q',
        tacticalKey: 'tac',
        actionBtnKey: 'btn',
        targetRoute: '/car-wash',
        iconData: Icons.local_car_wash,
        accentColor: AppColors.brutalCyan,
      );

      final updatedState = SmartMentorEngine.recordAdviceGiven(baseState, adviceSame);
      expect(updatedState.mentorMemory['consecutiveDays'], equals(2));
      expect(updatedState.mentorMemory['lastAdvisedDay'], equals(5));

      const adviceNew = SmartMentorAdvice(
        type: SmartMentorAdviceType.idleCashSurplus,
        titleKey: 't2',
        quoteKey: 'q2',
        tacticalKey: 'tac2',
        actionBtnKey: 'btn2',
        targetRoute: '/marketplace',
        iconData: Icons.wallet,
        accentColor: AppColors.toxicLime,
      );

      final resetState = SmartMentorEngine.recordAdviceGiven(updatedState, adviceNew);
      expect(resetState.mentorMemory['lastAdvisedType'], equals(SmartMentorAdviceType.idleCashSurplus.name));
      expect(resetState.mentorMemory['consecutiveDays'], equals(1));
    });
  });

  group('MentorQuestEngine - Quests and Hospitality', () {
    test('getActiveQuest returns first unclaimed quest and detects restoration progress', () {
      final cleanCar = createTestCar(
        id: 'c_restored',
        engineCondition: 90.0,
        transmissionCondition: 85.0,
      );

      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        ownedCars: [cleanCar],
      );

      final quest = MentorQuestEngine.getActiveQuest(state);
      expect(quest, isNotNull);
      expect(quest!.id, equals(MentorQuestEngine.questHeritageRestore));
      expect(quest.isCompleted, isTrue);
      expect(quest.currentProgress, equals(1));
      expect(quest.progressPercent, equals(1.0));
      expect(quest.rewardMoney, equals(45000));
    });

    test('claimQuestReward credits balance, xp, and marks quest as claimed', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 10000.0,
        totalProfit: 5000.0,
      );

      final claimedState = MentorQuestEngine.claimQuestReward(state, MentorQuestEngine.questHeritageRestore);
      expect(claimedState.balance, equals(55000.0));
      expect(claimedState.totalProfit, equals(50000.0));
      expect(claimedState.skills.xp, equals(150));

      final claimedIds = claimedState.mentorMemory['claimedQuestIds'] as List<dynamic>;
      expect(claimedIds, contains(MentorQuestEngine.questHeritageRestore));

      // Attempting to claim again does not double-reward
      final reClaimState = MentorQuestEngine.claimQuestReward(claimedState, MentorQuestEngine.questHeritageRestore);
      expect(reClaimState.balance, equals(55000.0));
    });

    test('canServeTea and serveTeaToHalil enforce daily throttle and update progress', () {
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        currentDay: 2,
        mentorMemory: {},
      );

      expect(MentorQuestEngine.canServeTea(state), isTrue);

      final servedState = MentorQuestEngine.serveTeaToHalil(state);
      expect(servedState.mentorMemory['teaServedCount'], equals(1));
      expect(servedState.mentorMemory['lastTeaServedDay'], equals(2));

      // Same day serving is prevented
      expect(MentorQuestEngine.canServeTea(servedState), isFalse);
      final doubleServedState = MentorQuestEngine.serveTeaToHalil(servedState);
      expect(doubleServedState.mentorMemory['teaServedCount'], equals(1));

      // Next day serving is allowed again
      final nextDayState = doubleServedState.copyWith(currentDay: 3);
      expect(MentorQuestEngine.canServeTea(nextDayState), isTrue);
    });
  });

  group('SmartMentorEngine - Click Cooldown & Dynamic Rotation (§SPEC-2026-HALIL-USTA-CLICK-COOLDOWN-ROTATION)', () {
    test('Damaged car in garage (0.75) takes precedence over bargain market radar (0.70)', () {
      final damagedCar = createTestCar(id: 'c_damaged', isListed: true, engineCondition: 50.0);
      final marketCar = createTestCar(id: 'c_market_bargain', baseMarketValue: 100000.0);
      final bargainListing = createTestListing(id: 'l_bargain', car: marketCar, askingPrice: 70000.0);

      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 150000.0,
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

      final advice = SmartMentorEngine.evaluateAdvice(state, marketListings: [bargainListing]);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.damagedCarRepairOpportunity));
      expect(advice.targetRoute, equals('/workshop'));
    });

    test('Dirty car in garage (0.72) takes precedence over bargain market radar (0.70)', () {
      final dirtyCar = createTestCar(id: 'c_dirty', isListed: true, isWashed: false);
      final marketCar = createTestCar(id: 'c_market_bargain', baseMarketValue: 100000.0);
      final bargainListing = createTestListing(id: 'l_bargain', car: marketCar, askingPrice: 70000.0);

      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        balance: 150000.0,
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

      final advice = SmartMentorEngine.evaluateAdvice(state, marketListings: [bargainListing]);
      expect(advice, isNotNull);
      expect(advice!.type, equals(SmartMentorAdviceType.dirtyCarValueLoss));
      expect(advice.targetRoute, equals('/car-wash'));
    });

    test('Clicking bargain radar action button puts it on cooldown and rotates immediately to next priority advice', () {
      // Setup state where cars in garage are clean and listed, but branch upgrade is ready
      final cleanCar = createTestCar(id: 'c_clean', isListed: true, isWashed: true);
      final marketCar = createTestCar(id: 'c_market_1', baseMarketValue: 100000.0);
      final bargainListing = createTestListing(id: 'l_bargain_1', car: marketCar, askingPrice: 70000.0);

      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        currentDay: 1,
        level: 2, // Tier 2 ready
        balance: 120000.0, // >= 100,000 required for Tier 2 branch
        maxGarageSlots: 3,
        ownedCars: [cleanCar],
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

      // 1. Before click: bargainMarketRadar (0.70) beats branchUpgradeReady (0.68)
      final initialAdvice = SmartMentorEngine.evaluateAdvice(state, marketListings: [bargainListing]);
      expect(initialAdvice, isNotNull);
      expect(initialAdvice!.type, equals(SmartMentorAdviceType.bargainMarketRadar));
      expect(initialAdvice.targetRoute, equals('/marketplace'));

      // 2. Player clicks the action button: recordAdviceGiven is invoked
      final stateAfterClick = SmartMentorEngine.recordAdviceGiven(state, initialAdvice);
      expect(stateAfterClick.mentorMemory['adviceCooldowns'], isNotNull);
      expect(stateAfterClick.mentorMemory['adviceCooldowns'][SmartMentorAdviceType.bargainMarketRadar.name], equals(1));
      expect(stateAfterClick.mentorMemory['seenBargainCarIds'], contains(marketCar.id));

      // 3. Immediately after click on the same day: bargainMarketRadar is dampened on cooldown,
      // and card rotates immediately to branchUpgradeReady!
      final rotatedAdvice = SmartMentorEngine.evaluateAdvice(stateAfterClick, marketListings: [bargainListing]);
      expect(rotatedAdvice, isNotNull);
      expect(rotatedAdvice!.type, equals(SmartMentorAdviceType.branchUpgradeReady));
      expect(rotatedAdvice.targetRoute, equals('/branches'));
    });

    test('Seen bargain car is excluded from future radar triggers on the same day', () {
      final cleanCar = createTestCar(id: 'c_clean', isListed: true, isWashed: true);
      final marketCar1 = createTestCar(id: 'c_seen_bargain', baseMarketValue: 100000.0);
      final listing1 = createTestListing(id: 'l_bargain_1', car: marketCar1, askingPrice: 70000.0);

      // State where car1 has already been seen today
      final state = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        currentDay: 1,
        balance: 100000.0,
        maxGarageSlots: 3,
        ownedCars: [cleanCar],
        mentorMemory: {
          'seenBargainCarIds': [marketCar1.id],
          'lastBargainSeenDay': 1,
        },
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

      // With only the seen car in market, bargainMarketRadar does not trigger
      final advice = SmartMentorEngine.evaluateAdvice(state, marketListings: [listing1]);
      expect(advice?.type, isNot(equals(SmartMentorAdviceType.bargainMarketRadar)));

      // If a brand new unseen bargain car arrives, it can trigger
      final marketCar2 = createTestCar(id: 'c_fresh_bargain', baseMarketValue: 100000.0);
      final listing2 = createTestListing(id: 'l_bargain_2', car: marketCar2, askingPrice: 65000.0);
      final adviceWithFresh = SmartMentorEngine.evaluateAdvice(state, marketListings: [listing1, listing2]);
      expect(adviceWithFresh, isNotNull);
      expect(adviceWithFresh!.type, equals(SmartMentorAdviceType.bargainMarketRadar));
      expect(adviceWithFresh.params['carId'], equals(marketCar2.id));
    });

    test('Day advancement clears click cooldown and seen bargain car cache', () {
      final cleanCar = createTestCar(id: 'c_clean', isListed: true, isWashed: true);
      final marketCar = createTestCar(id: 'c_market_1', baseMarketValue: 100000.0);
      final bargainListing = createTestListing(id: 'l_bargain_1', car: marketCar, askingPrice: 70000.0);

      // State recorded on Day 1
      final day1State = DealershipModel.initial().copyWith(
        tutorialCompleted: true,
        currentDay: 1,
        balance: 100000.0,
        maxGarageSlots: 3,
        ownedCars: [cleanCar],
        mentorMemory: {
          'lastAdvisedType': SmartMentorAdviceType.bargainMarketRadar.name,
          'lastAdvisedDay': 1,
          'consecutiveDays': 1,
          'adviceCooldowns': {
            SmartMentorAdviceType.bargainMarketRadar.name: 1,
          },
          'seenBargainCarIds': [marketCar.id],
          'lastBargainSeenDay': 1,
        },
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

      // Advance to Day 2
      final day2State = day1State.copyWith(currentDay: 2);

      // On Day 2, cooldown is expired, so bargainMarketRadar triggers again
      final adviceDay2 = SmartMentorEngine.evaluateAdvice(day2State, marketListings: [bargainListing]);
      expect(adviceDay2, isNotNull);
      expect(adviceDay2!.type, equals(SmartMentorAdviceType.bargainMarketRadar));
    });
  });
}



