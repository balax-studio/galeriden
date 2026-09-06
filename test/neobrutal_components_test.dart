import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/widgets/car_icons.dart';
import 'package:galeriden/presentation/widgets/duct_tape_corner.dart';
import 'package:galeriden/presentation/widgets/industrial_rocker_switch.dart';
import 'package:galeriden/presentation/widgets/marquee_ticker_widget.dart';
import 'package:galeriden/presentation/widgets/mechanical_tumbler_counter.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_car_vector_painter.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_page_background.dart';
import 'package:galeriden/presentation/widgets/thermal_receipt_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Neo-Brutalist Core Components Test Suite', () {
    testWidgets('1. ThermalReceiptCard renders with sawtooth edges, barcode, and line items',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ThermalReceiptCard(
                title: 'NOTER SATIŞ SENEDİ',
                subtitle: 'Toyota Corolla • 2021',
                receiptNumber: 'EXP-123456',
                dateText: '30.08.2026 15:30',
                items: [
                  ReceiptLineItem(label: 'Motor Durumu', value: '%95'),
                  ReceiptLineItem(label: 'Tramer Kaydı', value: '₺0'),
                  ReceiptLineItem(label: 'Net Tutar', value: '₺750.000', isBold: true),
                ],
                totalLabel: 'Net Toplam',
                totalAmount: '₺750.000',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('NOTER SATIŞ SENEDİ'), findsOneWidget);
      expect(find.text('Toyota Corolla • 2021'), findsOneWidget);
      expect(find.text('NO: EXP-123456'), findsOneWidget);
      expect(find.text('Motor Durumu'), findsOneWidget);
      expect(find.text('%95'), findsOneWidget);
      expect(find.text('₺750.000'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. MarqueeTickerWidget renders and mounts scrolling ticker seamlessly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MarqueeTickerWidget(
              newsItems: [
                'MASLAK OTO PAZARINDA TALEP YÜKSEK',
                'NOTER DEVİR VE HARÇLARI GÜNCELLENDİ',
              ],
              leadBadgeText: 'CANLI PİYASA',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CANLI PİYASA'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. IndustrialRockerSwitch toggles state and responds to tap interactions',
        (WidgetTester tester) async {
      bool switchValue = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return IndustrialRockerSwitch(
                  value: switchValue,
                  onLabel: 'VİTRİN',
                  offLabel: 'STANDART',
                  onChanged: (val) {
                    setState(() {
                      switchValue = val;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STANDART'), findsWidgets);

      // Tap on the rocker switch to toggle ON
      await tester.tap(find.byType(IndustrialRockerSwitch));
      await tester.pumpAndSettle();

      expect(switchValue, isTrue);
      expect(find.text('VİTRİN'), findsWidgets);
    });

    testWidgets('4. DuctTapeCorner renders jagged torn tape with high-contrast text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DuctTapeCorner(
              text: 'KELEPİR FIRSAT',
              tapeColor: Color(0xFFFFDE59),
              textColor: Colors.black,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KELEPİR FIRSAT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. MechanicalTumblerCounter renders tabular split-flap digit cells',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MechanicalTumblerCounter(
              label: 'KASA BAKİYESİ',
              valueText: '₺750.000',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KASA BAKİYESİ'), findsOneWidget);
      expect(find.text('₺'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });

    testWidgets('6. NeoBrutalPageBackground renders watermarks and adapts palettes', (tester) async {
      for (final watermark in ThematicWatermarkType.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark().copyWith(
              extensions: [
                AppThemeExtension(
                  palette: ThemePaletteModel.defaultPalettes.firstWhere((p) => p.isDark),
                ),
              ],
            ),
            home: Scaffold(
              body: NeoBrutalPageBackground(
                watermark: watermark,
                child: const Center(child: Text('Watermark Content')),
              ),
            ),
          ),
        );

        expect(find.text('Watermark Content'), findsOneWidget);
      }

      for (final palette in ThemePaletteModel.defaultPalettes) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: palette.isDark ? Brightness.dark : Brightness.light,
              extensions: [
                AppThemeExtension(palette: palette),
              ],
            ),
            home: Scaffold(
              body: NeoBrutalPageBackground(
                watermark: ThematicWatermarkType.dealership,
                child: Text(palette.name),
              ),
            ),
          ),
        );

        expect(find.text(palette.name), findsOneWidget);
      }
    });

    testWidgets('7. NeoBrutalCarVectorPainter & CarSilhouetteWidget render body types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarSilhouetteWidget(
              bodyType: 'Sedan',
              color: Colors.red,
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(CarSilhouetteWidget), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CarSilhouetteWidget),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );

      final bodyTypes = ['Hatchback', 'SUV', 'Spor', 'Coupe', 'Klasik', 'Van', 'Station'];
      for (final type in bodyTypes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CarSilhouetteWidget(
                bodyType: type,
                color: Colors.blue,
                isClean: true,
                isTuned: true,
                damagePercent: 35.0,
                showBackgroundPod: true,
              ),
            ),
          ),
        );

        expect(find.byType(CarSilhouetteWidget), findsOneWidget);
        await tester.pumpAndSettle();
      }

      final painter1 = NeoBrutalCarVectorPainter(
        bodyColor: Colors.red,
        bodyType: 'Sedan',
      );
      final painter2 = NeoBrutalCarVectorPainter(
        bodyColor: Colors.blue,
        bodyType: 'Sedan',
      );
      final painter3 = NeoBrutalCarVectorPainter(
        bodyColor: Colors.red,
        bodyType: 'SUV',
      );
      expect(painter1.shouldRepaint(painter2), isTrue);
      expect(painter1.shouldRepaint(painter3), isTrue);
      expect(painter1.shouldRepaint(painter1), isFalse);
    });
  });
}
