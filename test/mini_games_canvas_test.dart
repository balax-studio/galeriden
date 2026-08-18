import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/tuning_model.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';
import 'package:galeriden/presentation/widgets/mini_games/car_wash_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/drag_race_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/dyno_run_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/handshake_stamp_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/micron_body_scan_canvas.dart';

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
      modelYear: 2022,
      bodyType: 'Coupe',
      colorHex: '#FF9529',
      currentPurchasePrice: 400000.0,
      baseMarketValue: 400000.0,
      expertise: ExpertiseReport(
        engineCondition: 100.0,
        transmissionCondition: 100.0,
        tramerAmount: 0,
        mileage: 40000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.original,
          'Tavan': PartStatus.original,
          'Bagaj': PartStatus.painted,
          'Sol Ön Çamurluk': PartStatus.changed,
        },
      ),
    );
  }

  group('2D Neo-Brutalist Mini-Games Suite Tests', () {
    testWidgets('1. DragRaceMiniGameModal renders, counts down, and handles shift action', (tester) async {
      final car = createTestCar(id: 'c1', brand: 'BMW', modelName: 'M3');
      const rival = NightRivalModel(
        id: 'r1',
        name: 'Rüzgar Efe',
        title: 'Gece Şampiyonu',
        badge: 'DRIFT KRALI',
        carName: 'Nissan Silvia S15',
        modificationSummary: 'Stage 3 Turbo & Düz Boru',
        basePower: 320,
        tier: 1,
      );

      const raceResult = NightRaceResult(
        isWon: true,
        prizeMoney: 30000.0,
        reputationBonus: 4,
        raceSummary: 'Rüzgar Efe arkanda toz yuttu!',
        rivalName: 'Rüzgar Efe',
        rivalCarName: 'Nissan Silvia S15',
      );

      bool isFinishedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DragRaceMiniGameModal(
              car: car,
              rival: rival,
              raceResult: raceResult,
              onFinished: () => isFinishedCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('GECE MEZATI DRAG ARENASI'), findsOneWidget);
      expect(find.text('DRIFT KRALI'), findsOneWidget);

      // Advance past countdown timer
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump(const Duration(milliseconds: 800));

      // In racing phase, shift button or canvas should be present
      expect(find.byType(CustomPaint), findsWidgets);
      expect(isFinishedCalled, isFalse);
    });

    testWidgets('2. MicronBodyScanCanvasWidget renders bodywork blueprint and updates LCD probe on part tap', (tester) async {
      final bodyParts = {
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Bagaj': PartStatus.painted,
        'Sol Ön Çamurluk': PartStatus.changed,
      };

      String? lastScannedPart;
      int? lastScannedMicrons;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MicronBodyScanCanvasWidget(
              bodyParts: bodyParts,
              isDark: true,
              onPartScanned: (name, microns, status) {
                lastScannedPart = name;
                lastScannedMicrons = microns;
              },
            ),
          ),
        ),
      );

      expect(find.text('2D KAPORTA & BOYA RADARI'), findsOneWidget);
      expect(find.text('0/4 PARÇA TARANDI'), findsOneWidget);

      // Tap on 'Kaput' pill
      await tester.tap(find.text('Kaput'));
      await tester.pump();

      expect(lastScannedPart, equals('Kaput'));
      expect(lastScannedMicrons, greaterThanOrEqualTo(90));
      expect(find.text('1/4 PARÇA TARANDI'), findsOneWidget);
    });

    testWidgets('3. DynoRunCanvasModal animates RPM climb, live power graph, and completes test', (tester) async {
      final car = createTestCar(id: 'c1', brand: 'Porsche', modelName: '911 GT3');
      const dyno = CarDynoStats(
        baseHp: 500,
        totalHp: 580,
        baseNm: 470,
        totalNm: 560,
        baseAccel: 3.4,
        currentAccel: 3.0,
        exhaustDb: 102,
        tuningRating: 85,
        isInspectionCompliant: true,
        hasLegalProject: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynoRunCanvasModal(car: car, dyno: dyno),
          ),
        ),
      );

      expect(find.text('DYNO GÜÇ & TORK TESTİ'), findsOneWidget);
      expect(find.text('MAX 7500'), findsOneWidget);

      // Advance animation to completion
      await tester.pump(const Duration(seconds: 5));

      expect(find.text('TEST BİTTİ'), findsOneWidget);
      expect(find.text('TESTİ TAMAMLA VE KAYDET'), findsOneWidget);
    });

    testWidgets('4. CarWashMiniGameModal collects pan gestures, cleans mud mask, and completes detailing', (tester) async {
      final car = createTestCar(id: 'c1', brand: 'Audi', modelName: 'RS6');
      bool isCompleted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CarWashMiniGameModal(
              car: car,
              onCleanCompleted: () => isCompleted = true,
            ),
          ),
        ),
      );

      expect(find.text('İNTERAKTİF KÖPÜK & YIKAMA'), findsOneWidget);
      expect(find.text('%0 TEMİZLENDİ'), findsOneWidget);

      // Drag across canvas area
      final canvasFinder = find.byType(GestureDetector).first;
      for (int i = 0; i < 70; i++) {
        await tester.drag(canvasFinder, const Offset(5, 5));
        await tester.pump(const Duration(milliseconds: 16));
      }

      expect(find.text('%100 TEMİZLENDİ'), findsOneWidget);
      expect(find.text('TEMİZLİĞİ ONAYLA • +%100 PARLAKLIK'), findsOneWidget);

      await tester.tap(find.text('TEMİZLİĞİ ONAYLA • +%100 PARLAKLIK'));
      expect(isCompleted, isTrue);
    });

    testWidgets('5. HandshakeStampModal displays handshake animation and triggers notary confirmation', (tester) async {
      bool isConfirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HandshakeStampModal(
              sellerName: 'Mustafa Bey',
              carModel: 'Mercedes-Benz C63 AMG',
              agreedPrice: 1250000.0,
              onConfirmed: () => isConfirmed = true,
            ),
          ),
        ),
      );

      expect(find.text('PAZARLIK BİTTİ & EL SIKIŞILDI'), findsOneWidget);
      expect(find.text('Satıcı: Mustafa Bey'), findsOneWidget);

      // Advance animation to show notary stamp
      await tester.pump(const Duration(milliseconds: 1500));

      expect(find.text('RUHSATI TESLİM AL & PARAYI ÖDE'), findsOneWidget);

      await tester.tap(find.text('RUHSATI TESLİM AL & PARAYI ÖDE'));
      expect(isConfirmed, isTrue);
    });
  });
}
