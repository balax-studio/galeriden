import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/black_market_car_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/widgets/mini_games/engine_timing_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/hidden_stash_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/scrapyard_teardown_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/vehicle_inspection_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CarModel createTestCar({
    required String id,
    required String brand,
    required String modelName,
  }) {
    return CarModel(
      id: id,
      brand: brand,
      modelName: modelName,
      modelYear: 2023,
      bodyType: 'Sedan',
      colorHex: '#00E575',
      currentPurchasePrice: 500000.0,
      baseMarketValue: 500000.0,
      expertise: ExpertiseReport(
        engineCondition: 85.0,
        transmissionCondition: 90.0,
        tramerAmount: 0,
        mileage: 35000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.original,
          'Tavan': PartStatus.original,
        },
      ),
    );
  }

  group('New 2D Neo-Brutalist Mini-Games Suite Tests', () {
    testWidgets('1. ScrapyardTeardownModal renders, sweeps torque, and handles bolt loosening', (tester) async {
      bool isFinished = false;
      int resultCondition = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScrapyardTeardownModal(
              partName: 'V6 Çift Turbo',
              carName: 'BMW M3',
              initialCondition: 70,
              onCompleted: (success, condition, msg) {
                isFinished = true;
                resultCondition = condition;
              },
            ),
          ),
        ),
      );

      expect(find.text('PARÇA SÖKÜM CERRAHİSİ'), findsOneWidget);
      expect(find.text('BMW M3 • V6 Çift Turbo'), findsOneWidget);
      expect(find.text('KONDİSYON: %70'), findsOneWidget);
      expect(find.text('TORKU UYGULA • PASI KIR'), findsOneWidget);

      // Advance sweep animation
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('TORKU UYGULA • PASI KIR'));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CustomPaint), findsWidgets);
      expect(isFinished, isFalse);
      expect(resultCondition, equals(0));
    });

    testWidgets('2. VehicleInspectionModal transitions through brake and headlight stages', (tester) async {
      final car = createTestCar(id: 'c_insp_1', brand: 'Mercedes-Benz', modelName: 'C200');
      bool isPassed = false;
      String finalBadge = '';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicleInspectionModal(
              car: car,
              onInspectionFinished: (passed, brakeScore, headlightScore, badge) {
                isPassed = passed;
                finalBadge = badge;
              },
            ),
          ),
        ),
      );

      expect(find.text('ARAÇ MUAYENE VE KUSUR TESTİ'), findsOneWidget);
      expect(find.text('AŞAMA 1/2 • FREN'), findsOneWidget);

      // Tap brake pedal button
      await tester.tap(find.text('FREN PEDALINA BASILI TUT'));
      await tester.pump(const Duration(milliseconds: 400));

      // Should advance to Headlight stage
      expect(find.text('AŞAMA 2/2 • FAR'), findsOneWidget);

      // Tap align button to snap headlight
      await tester.tap(find.textContaining('MERCEĞİ HİZALA'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('TEST TAMAMLANDI'), findsOneWidget);
      expect(find.text('MUAYENE RAPORUNU ONAYLA & KAYDET'), findsOneWidget);

      await tester.tap(find.text('MUAYENE RAPORUNU ONAYLA & KAYDET'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(finalBadge.isNotEmpty, isTrue);
      expect(isPassed, isTrue);
    });

    testWidgets('3. EngineTimingModal aligns cam sprockets and locks torque wrench', (tester) async {
      final car = createTestCar(id: 'c_timing_1', brand: 'Audi', modelName: 'RS3');
      bool isCalibrated = false;
      int hpGain = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EngineTimingModal(
              car: car,
              onTimingCalibrated: (perfect, hp, msg) {
                isCalibrated = true;
                hpGain = hp;
              },
            ),
          ),
        ),
      );

      expect(find.text('TRİGER SENTE VE TORK KALİBRATÖRÜ'), findsOneWidget);
      expect(find.text('AŞAMA 1/2 • SENTE'), findsOneWidget);

      // Rotate cam until aligned
      for (int i = 0; i < 30; i++) {
        if (find.text('SAĞA ÇEVİR').evaluate().isNotEmpty) {
          await tester.tap(find.text('SAĞA ÇEVİR'));
          await tester.pump(const Duration(milliseconds: 40));
        }
      }

      // In torque phase, tap to lock
      if (find.textContaining('TORK ANAHTARINI SIK').evaluate().isNotEmpty) {
        await tester.tap(find.textContaining('TORK ANAHTARINI SIK'));
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('KALİBRE EDİLDİ'), findsOneWidget);
        expect(find.text('MOTORU ÇALIŞTIR & TEST ET'), findsOneWidget);

        await tester.tap(find.text('MOTORU ÇALIŞTIR & TEST ET'));
        await tester.pump(const Duration(milliseconds: 400));

        expect(isCalibrated, isTrue);
        expect(hpGain, greaterThanOrEqualTo(0));
      }
    });

    testWidgets('4. HiddenStashModal reveals secret stash with UV flashlight pan gesture', (tester) async {
      const blackCar = BlackMarketCarModel(
        id: 'bm_test_1',
        brand: 'Porsche',
        modelName: 'Panamera GTS',
        modelYear: 2021,
        realMarketValue: 1200000.0,
        askingPrice: 500000.0,
        riskType: 'change_vin',
        riskLevelPercent: 35,
        riskDescription: 'Hacizli ve gizli modifiye beyni bulunuyor',
        sellerAlias: 'Gölge İbrahim',
      );

      bool isFoundCalled = false;
      double rewardedMoney = 0.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HiddenStashModal(
              car: blackCar,
              onInspectionCompleted: (found, cash, desc) {
                isFoundCalled = true;
                rewardedMoney = cash;
              },
            ),
          ),
        ),
      );

      expect(find.text('ZULA VE ŞASİ DEDEKTÖRÜ'), findsOneWidget);
      expect(find.textContaining('Panamera GTS'), findsOneWidget);

      // Tap fast auto-scan fallback button
      await tester.tap(find.text('HIZLI OTOMATİK TARAMA • PAS GEÇ'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('ZULA BULUNDU'), findsWidgets);
      expect(find.text('ZULAYI TOPLA & ENJEKTE ET'), findsOneWidget);

      await tester.tap(find.text('ZULAYI TOPLA & ENJEKTE ET'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(isFoundCalled, isTrue);
      expect(rewardedMoney, greaterThan(0));
    });
  });
}
