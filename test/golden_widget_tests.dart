import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/presentation/widgets/countdown_heat_ring.dart';
import 'package:galeriden/presentation/widgets/duct_tape_corner.dart';
import 'package:galeriden/presentation/widgets/industrial_rocker_switch.dart';
import 'package:galeriden/presentation/widgets/mechanical_tumbler_counter.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_badge.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_card.dart';
import 'package:galeriden/presentation/widgets/thermal_receipt_card.dart';

Widget _wrapForGolden(Widget child, {bool isDark = false, Size size = const Size(400, 300)}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: isDark
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0C0E14),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF4F4F0),
          ),
    home: Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      body: Center(
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: Center(child: child),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Neo-Brutalist Visual Golden Regression Tests', () {
    testWidgets('1. NeoBrutalCard Light & Dark Mode Golden Snapshots',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 400));

      final cardLight = _wrapForGolden(
        NeoBrutalCard(
          backgroundColor: Colors.white,
          borderColor: const Color(0xFF0F172A),
          borderWidth: 2.5,
          borderRadius: 12,
          shadowOffset: const Offset(4, 4),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'NEO-BRUTAL KART',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Endüstriyel kalın kenarlık ve sıfır-yumuşatmalı sert gölge.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        isDark: false,
        size: const Size(420, 200),
      );

      await tester.pumpWidget(cardLight);
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalCard), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/neo_brutal_card_light.png'),
      );

      // Dark mode variant
      final cardDark = _wrapForGolden(
        NeoBrutalCard(
          backgroundColor: const Color(0xFF141721),
          borderColor: const Color(0xFF333B4F),
          borderWidth: 2.5,
          borderRadius: 12,
          shadowOffset: const Offset(4, 4),
          shadowColor: Colors.black,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'KARANLIK TEMA KART',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Karanlık siberpunk oto galeri paleti.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
        isDark: true,
        size: const Size(420, 200),
      );

      await tester.pumpWidget(cardDark);
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalCard), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/neo_brutal_card_dark.png'),
      );
    });

    testWidgets('2. NeoBrutalButton State Variants Golden Snapshots',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 400));

      final buttonSuite = _wrapForGolden(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            NeoBrutalButton(
              label: 'TEKLİFİ GÖNDER',
              backgroundColor: AppColors.brutalYellow,
              textColor: const Color(0xFF0F172A),
              icon: Icons.send_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            NeoBrutalButton(
              label: 'HIZLI İŞLEM',
              backgroundColor: AppColors.brutalCyan,
              textColor: const Color(0xFF0F172A),
              icon: Icons.flash_on_rounded,
              onPressed: () {},
            ),
            const SizedBox(height: 12),
            const NeoBrutalButton(
              label: 'DEVRE DIŞI BUTON',
              backgroundColor: Color(0xFFCBD5E1),
              textColor: Color(0xFF64748B),
              onPressed: null,
            ),
          ],
        ),
        isDark: false,
        size: const Size(420, 280),
      );

      await tester.pumpWidget(buttonSuite);
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalButton), findsNWidgets(3));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/neo_brutal_buttons.png'),
      );
    });

    testWidgets('3. NeoBrutalBadge Semantic Badges Golden Snapshots',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 300));

      final badgeSuite = _wrapForGolden(
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: const [
            NeoBrutalBadge(
              text: 'KUSURSUZ',
              backgroundColor: Color(0xFF10B981),
              textColor: Colors.white,
              icon: Icons.verified_rounded,
            ),
            NeoBrutalBadge(
              text: 'AĞIR HASARLI',
              backgroundColor: Color(0xFFEF4444),
              textColor: Colors.white,
              icon: Icons.warning_amber_rounded,
            ),
            NeoBrutalBadge(
              text: 'NADİR MODEL',
              backgroundColor: Color(0xFFFFDE59),
              textColor: Color(0xFF0F172A),
              icon: Icons.star_rounded,
            ),
            NeoBrutalBadge(
              text: 'VIP MÜŞTERİ',
              backgroundColor: Color(0xFF8B5CF6),
              textColor: Colors.white,
              icon: Icons.shield_rounded,
            ),
          ],
        ),
        isDark: false,
        size: const Size(420, 150),
      );

      await tester.pumpWidget(badgeSuite);
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalBadge), findsNWidgets(4));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/neo_brutal_badges.png'),
      );
    });

    testWidgets('4. CountdownHeatRing Timer Arc Golden Snapshots',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(300, 300));

      final heatRing = _wrapForGolden(
        const CountdownHeatRing(
          remainingSeconds: 4,
          totalSeconds: 10,
          size: 70,
        ),
        isDark: true,
        size: const Size(200, 200),
      );

      await tester.pumpWidget(heatRing);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CountdownHeatRing), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/countdown_heat_ring.png'),
      );
    });

    testWidgets('5. ThermalReceiptCard & DuctTape Corner Golden Snapshots',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 480));

      final receiptWithTape = _wrapForGolden(
        Stack(
          clipBehavior: Clip.none,
          children: const [
            ThermalReceiptCard(
              title: 'NOTER SATIŞ SENEDİ',
              subtitle: 'BMW 320i M Sport • 2022',
              receiptNumber: 'NTR-998811',
              dateText: '30.08.2026 18:00',
              items: [
                ReceiptLineItem(label: 'Ekspertiz Puanı', value: '88/100'),
                ReceiptLineItem(label: 'Tramer Kaydı', value: '₺12.500'),
                ReceiptLineItem(label: 'Noter Masrafı', value: '₺2.150'),
                ReceiptLineItem(
                    label: 'Net Tutar', value: '₺1.450.000', isBold: true),
              ],
              totalLabel: 'Ödenecek Tutar',
              totalAmount: '₺1.452.150',
            ),
            Positioned(
              top: -8,
              left: -12,
              child: DuctTapeCorner(text: 'ACİL', angle: -0.4),
            ),
            Positioned(
              bottom: -8,
              right: -12,
              child: DuctTapeCorner(text: 'ORİJİNAL', angle: 0.35),
            ),
          ],
        ),
        isDark: false,
        size: const Size(420, 420),
      );

      await tester.pumpWidget(receiptWithTape);
      await tester.pumpAndSettle();
      expect(find.byType(ThermalReceiptCard), findsOneWidget);
      expect(find.byType(DuctTapeCorner), findsNWidgets(2));
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/thermal_receipt_with_tape.png'),
      );
    });

    testWidgets('6. IndustrialRockerSwitch & Tumbler Counter Golden Snapshots',
        (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(450, 300));

      final industrialControlSuite = _wrapForGolden(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IndustrialRockerSwitch(
              value: true,
              onLabel: 'AKTİF',
              offLabel: 'KAPALI',
              onChanged: (_) {},
            ),
            const MechanicalTumblerCounter(
              valueText: '128.500 ₺',
              label: 'BÜTÇE',
            ),
          ],
        ),
        isDark: true,
        size: const Size(420, 180),
      );

      await tester.pumpWidget(industrialControlSuite);
      await tester.pumpAndSettle();
      expect(find.byType(IndustrialRockerSwitch), findsOneWidget);
      expect(find.byType(MechanicalTumblerCounter), findsOneWidget);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/industrial_rocker_and_tumbler.png'),
      );
    });
  });
}
