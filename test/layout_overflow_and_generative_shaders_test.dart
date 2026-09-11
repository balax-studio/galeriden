import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/core/utils/currency_formatter.dart';
import 'package:galeriden/presentation/widgets/blueprint_grid_background.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_badge.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Layout Overflow & Responsive Resilience Tests (320px Viewport)', () {
    testWidgets('1. Daily Dilemma Card footer text wraps in Expanded without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Muhtar Şerafettin • Sanayi ve Çevre Mahalleler Baş Muhtarı ve Kanaat Önderi',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: 'Karar Ver • Seçim Yap',
                      icon: Icons.touch_app_rounded,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Muhtar Şerafettin'), findsOneWidget);
      expect(find.text('Karar Ver • Seçim Yap'), findsOneWidget);
    });

    testWidgets('2. Compact Service Card (145px width) badge with Flexible does not overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 145,
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    color: Colors.cyan,
                  ),
                  const SizedBox(width: 4),
                  const Flexible(
                    child: NeoBrutalBadge(
                      text: 'Köpüklü Yıkama Hazır',
                      fontSize: 8.5,
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Köpüklü Yıkama Hazır'), findsOneWidget);
    });

    testWidgets('3. Operation Dialog Header with long vehicle name wraps without overflow', (tester) async {
      tester.view.physicalSize = const Size(300, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: NeoBrutalBadge(
                      text: 'Çelikvolvo S-Altmış R-Stil Mega Sedan',
                      fontSize: 10,
                    ),
                  ),
                  NeoBrutalBadge(
                    text: 'İşlem Uygulanıyor...',
                    backgroundColor: Color(0xFF00F0FF),
                    fontSize: 9.5,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Çelikvolvo S-Altmış R-Stil Mega Sedan'), findsOneWidget);
      expect(find.text('İşlem Uygulanıyor...'), findsOneWidget);
    });

    testWidgets('4. Vasıta Market Listing footer wraps price and action buttons cleanly', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 292, // Card inner width inside padding
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Piyasa Değeri',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        CurrencyFormatter.format(4315000),
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      NeoBrutalButton.info(
                        icon: Icons.assignment_outlined,
                        label: 'Ekspertize Sok',
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                        onPressed: () {},
                      ),
                      NeoBrutalButton.primary(
                        icon: Icons.handshake_rounded,
                        label: 'Pazarlığa Başla',
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Piyasa Değeri'), findsOneWidget);
      expect(find.text('Ekspertize Sok'), findsOneWidget);
      expect(find.text('Pazarlığa Başla'), findsOneWidget);
    });
    testWidgets('5. Stock Market IPO company title in Expanded does not overflow on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'VoltŞarj İstasyonları & Enerji Dağıtım Yatırımları A.Ş.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const NeoBrutalBadge(
                      text: 'BORSA İŞLEM',
                      backgroundColor: Colors.green,
                      fontSize: 9.5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('VoltŞarj İstasyonları'), findsOneWidget);
      expect(find.text('BORSA İŞLEM'), findsOneWidget);
    });

    testWidgets('6. Casino Hub Section Header in Expanded does not overflow on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '2. MEKANİK & ÇARPAN OYUNLARI',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5),
                          ),
                          Text(
                            'Lüks Showroom Seviye 6 İle Açık',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    NeoBrutalBadge(
                      text: 'T6 • HIGH ROLLER',
                      backgroundColor: Colors.green,
                      fontSize: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('2. MEKANİK & ÇARPAN OYUNLARI'), findsOneWidget);
      expect(find.text('T6 • HIGH ROLLER'), findsOneWidget);
    });

    testWidgets('7a. Special Plate Balance Header in 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(width: 36, height: 36, color: Colors.yellow),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Bakiye', style: TextStyle(fontSize: 10.5)),
                                Text(
                                  CurrencyFormatter.format(1471601),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NeoBrutalBadge(
                          text: '4 Garajda Araç',
                          icon: Icons.directions_car_rounded,
                          fontSize: 9.5,
                        ),
                        SizedBox(height: 4),
                        NeoBrutalBadge(
                          text: '+%3-10 Araç Değeri',
                          icon: Icons.trending_up_rounded,
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('4 Garajda Araç'), findsOneWidget);
    });

    testWidgets('7b. Special Plate Card Header in 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        NeoBrutalBadge(text: 'Efsanevi', fontSize: 9.5),
                        NeoBrutalBadge(text: '+%10 Değer Katkısı', fontSize: 9.5),
                      ],
                    ),
                    Text(
                      'İstanbul İl Emniyet Kayıtlı',
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('İstanbul İl Emniyet Kayıtlı'), findsOneWidget);
    });
  });

  group('Generative Art & Shaders Procedural Patterns Tests', () {
    testWidgets('1. BlueprintPatternType.bayerDither paints without exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: BlueprintGridBackground(
                patternType: BlueprintPatternType.bayerDither,
                opacity: 0.12,
                spacing: 6.0,
                child: Center(child: Text('BAYER DITHER PATTERN')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('BAYER DITHER PATTERN'), findsOneWidget);
      expect(find.byType(BlueprintGridBackground), findsOneWidget);
    });

    testWidgets('2. BlueprintPatternType.crtScanlines paints without exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: BlueprintGridBackground(
                patternType: BlueprintPatternType.crtScanlines,
                opacity: 0.10,
                spacing: 16.0,
                child: Center(child: Text('CRT SCANLINES PATTERN')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('CRT SCANLINES PATTERN'), findsOneWidget);
      expect(find.byType(BlueprintGridBackground), findsOneWidget);
    });

    testWidgets('3. BlueprintPatternType.technicalCrosses paints without exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: BlueprintGridBackground(
                patternType: BlueprintPatternType.technicalCrosses,
                opacity: 0.10,
                spacing: 16.0,
                child: Center(child: Text('TECHNICAL CROSSES PATTERN')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('TECHNICAL CROSSES PATTERN'), findsOneWidget);
    });

    testWidgets('4. BlueprintPatternType.graphPaper paints without exception', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 200,
              child: BlueprintGridBackground(
                patternType: BlueprintPatternType.graphPaper,
                opacity: 0.10,
                spacing: 16.0,
                child: Center(child: Text('GRAPH PAPER PATTERN')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('GRAPH PAPER PATTERN'), findsOneWidget);
    });

    testWidgets('5. NeoBrutalCard supports bayerDither pattern background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 160,
              child: NeoBrutalCard(
                showBlueprintGrid: true,
                patternType: BlueprintPatternType.bayerDither,
                child: Text('DITHER CARD'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('DITHER CARD'), findsOneWidget);
    });

    testWidgets('6. Plate Designer Fee Breakdown & Full-width Action CTA on 320px viewport', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: NeoBrutalCard(
                  showBlueprintGrid: true,
                  patternType: BlueprintPatternType.graphPaper,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hesaplanan Harç & Bedel:',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        '₺90.000',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ),
                                NeoBrutalBadge.danger(
                                  text: 'Yetersiz Bakiye',
                                  fontSize: 9.5,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            NeoBrutalButton(
                              fullWidth: true,
                              label: 'PLAKAYI TESCİL ET & ARACA TAK',
                              icon: Icons.check_circle_outline_rounded,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Hesaplanan Harç & Bedel:'), findsOneWidget);
      expect(find.text('₺90.000'), findsOneWidget);
      expect(find.text('PLAKAYI TESCİL ET & ARACA TAK'), findsOneWidget);
    });

    testWidgets('7. Plate Assignment Modal Header & Car Items on 320px viewport without overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.brutalYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.directions_car_rounded, size: 20),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Plakayı Araca Ata & Tescil Et',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      'Yeni Plaka: 34 ATA 1923',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Plakayı Araca Ata & Tescil Et'), findsOneWidget);
      expect(find.text('Yeni Plaka: 34 ATA 1923'), findsOneWidget);
    });
  });
}
