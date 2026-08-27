import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/black_market_car_model.dart';
import 'package:galeriden/data/models/tuning_model.dart';
import 'package:galeriden/domain/usecases/black_market_container_engine.dart';
import 'package:galeriden/domain/usecases/night_market_engine.dart';
import 'package:galeriden/presentation/widgets/mini_games/car_wash_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/drag_race_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/dyno_run_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/engine_timing_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/handshake_stamp_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/hidden_stash_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/micron_body_scan_canvas.dart';
import 'package:galeriden/presentation/widgets/mini_games/mystery_container_unboxing_modal.dart';
import 'package:galeriden/presentation/widgets/mini_games/neo_brutal_poly_painter.dart';
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
      bodyType: 'Coupe',
      colorHex: '#00E575',
      currentPurchasePrice: 600000.0,
      baseMarketValue: 600000.0,
      expertise: ExpertiseReport(
        engineCondition: 90.0,
        transmissionCondition: 90.0,
        tramerAmount: 0,
        mileage: 25000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.original,
          'Tavan': PartStatus.original,
          'Bagaj': PartStatus.painted,
        },
      ),
    );
  }

  group('NeoBrutalPolyPainter & Atölye/Hurdalık Tests', () {
    testWidgets('1. NeoBrutalPolyPainter paints polygons, hex bolts, and hazard stripes without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 300),
              painter: _TestPolyCustomPainter(),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('2. Low-Poly ScrapyardTeardownModal mounts and renders faceted engine', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: ScrapyardTeardownModal(
              partName: 'V6 Turbo',
              carName: 'BMW M3',
              initialCondition: 70,
              onCompleted: (success, cond, msg) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(ScrapyardTeardownModal), findsOneWidget);
    });

    testWidgets('3. Low-Poly EngineTimingModal mounts and renders faceted sprockets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: EngineTimingModal(
              car: createTestCar(id: 'c1', brand: 'BMW', modelName: 'M3'),
              onTimingCalibrated: (perfect, bonus, stamp) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(EngineTimingModal), findsOneWidget);
    });

    testWidgets('4. Low-Poly CarWashMiniGameModal mounts and renders isometric car', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: CarWashMiniGameModal(
              car: createTestCar(id: 'c2', brand: 'Porsche', modelName: '911'),
              onCleanCompleted: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CarWashMiniGameModal), findsOneWidget);
    });

    testWidgets('5. Low-Poly DynoRunCanvasModal mounts and renders CRT oscilloscope', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: DynoRunCanvasModal(
              car: createTestCar(id: 'c3', brand: 'Audi', modelName: 'RS6'),
              dyno: const CarDynoStats(
                baseHp: 600,
                totalHp: 720,
                baseNm: 800,
                totalNm: 950,
                baseAccel: 3.6,
                currentAccel: 3.1,
                exhaustDb: 88,
                tuningRating: 85,
                isInspectionCompliant: true,
                hasLegalProject: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DynoRunCanvasModal), findsOneWidget);
    });

    testWidgets('6. Low-Poly MicronBodyScanCanvasWidget mounts and renders faceted blueprint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: MicronBodyScanCanvasWidget(
                bodyParts: {
                  'Kaput': PartStatus.original,
                  'Tavan': PartStatus.original,
                  'Bagaj': PartStatus.painted,
                },
                isDark: true,
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MicronBodyScanCanvasWidget), findsOneWidget);
    });

    testWidgets('7. Low-Poly VehicleInspectionModal mounts and renders dual hydraulic rollers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: VehicleInspectionModal(
              car: createTestCar(id: 'c4', brand: 'Mercedes', modelName: 'C63'),
              onInspectionFinished: (p, b, h, r) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(VehicleInspectionModal), findsOneWidget);
    });

    testWidgets('8. Low-Poly DragRaceMiniGameModal mounts and renders isometric racer', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: DragRaceMiniGameModal(
              car: createTestCar(id: 'c5', brand: 'Nissan', modelName: 'GT-R R35'),
              rival: const NightRivalModel(
                id: 'riv1',
                name: 'Korkusuz Burak',
                title: 'Cadde Şampiyonu',
                carName: 'Toyota Supra Mk4',
                modificationSummary: 'Stage 3 Turbo + NOS',
                tier: 2,
                basePower: 700,
                badge: 'CHAMPION',
              ),
              raceResult: const NightRaceResult(
                isWon: true,
                prizeMoney: 45000,
                reputationBonus: 25,
                raceSummary: 'Mükemmel vites geçişiyle yarışı kazandın!',
                rivalName: 'Korkusuz Burak',
                rivalCarName: 'Toyota Supra Mk4',
              ),
              onFinished: (res) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DragRaceMiniGameModal), findsOneWidget);
    });

    testWidgets('9. Low-Poly HiddenStashModal mounts and renders UV blueprint', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: HiddenStashModal(
              car: const BlackMarketCarModel(
                id: 'bm1',
                brand: 'BMW',
                modelName: 'M5 E60 V10',
                modelYear: 2008,
                askingPrice: 800000,
                realMarketValue: 1800000,
                riskType: 'change_vin',
                riskLevelPercent: 30,
                sellerAlias: 'Gece Kuşu',
                riskDescription: 'Şüpheli plaka ve gizli bölme şüphesi',
              ),
              onInspectionCompleted: (found, cash, desc) {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(HiddenStashModal), findsOneWidget);
    });

    testWidgets('10. Low-Poly MysteryContainerUnboxingModal mounts and renders 3D container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: MysteryContainerUnboxingModal(
              result: MysteryContainerResult(
                car: createTestCar(id: 'c6', brand: 'Ferrari', modelName: '488 Pista'),
                tier: MysteryContainerTier.exotic,
                costPaid: 3500000,
                estimatedValue: 8500000,
                profitMargin: 5000000,
              ),
              onClaim: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MysteryContainerUnboxingModal), findsOneWidget);
    });

    testWidgets('11. Low-Poly HandshakeStampModal mounts and renders brass notary seal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('tr'), Locale('en')],
          locale: const Locale('tr'),
          home: Scaffold(
            body: HandshakeStampModal(
              sellerName: 'Ahmet Usta',
              carModel: 'BMW 320d',
              agreedPrice: 750000,
              onConfirmed: () {},
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(HandshakeStampModal), findsOneWidget);
    });
  });
}

class _TestPolyCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    NeoBrutalPolyPainter.drawCRTGrid(canvas, size);
    NeoBrutalPolyPainter.drawHazardStripes(canvas, const Rect.fromLTWH(10, 10, 200, 24));
    NeoBrutalPolyPainter.draw3DHexBolt(canvas, const Offset(100, 100), 20);
    NeoBrutalPolyPainter.drawPrismaticDiamond(canvas, const Offset(150, 150), 16, const Color(0xFF00E575));
    NeoBrutalPolyPainter.drawLowPolyIsometricCar(canvas, const Offset(150, 220), 1.5, bodyColor: const Color(0xFFFF5500));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
