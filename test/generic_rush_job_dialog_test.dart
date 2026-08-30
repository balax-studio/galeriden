import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/widgets/dialogs/generic_rush_job_dialog.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:toastification/toastification.dart';

final testTheme = ThemeData.dark().copyWith(
  extensions: [
    AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
  ],
);

Widget buildTestApp({
  required Widget child,
}) {
  return ToastificationWrapper(
    child: MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: testTheme,
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    toastification.dismissAll(delayForAnimation: false);
  });

  group('GenericRushJobDialog Tests', () {
    testWidgets('1. Renders title badge, target title, lore narrative, and action buttons', (tester) async {
      bool rushEarned = false;

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GenericRushJobDialog.show(
                  context,
                  titleBadge: 'EKSPRES HAVA KARGO HATTI',
                  targetTitle: 'BMW 320i • Oksijen Sensörü',
                  targetSubtitle: 'Kargoda • 48 Saniye Kaldı',
                  loreDescription: 'Sektörel Lojistik Konsorsiyumu kargo uçağı rotasıyla parçalar doğrudan atölye liftine indirilir.',
                  actionButtonLabel: 'HAVA KARGO İLE GETİR & TESLİM ET',
                  onRushSuccess: () {
                    rushEarned = true;
                  },
                );
              },
              child: const Text('SHOW MODAL'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SHOW MODAL'));
      await tester.pumpAndSettle();

      // Assert modal elements
      expect(find.text('EKSPRES HAVA KARGO HATTI'), findsWidgets);
      expect(find.text('BMW 320i • Oksijen Sensörü'), findsOneWidget);
      expect(find.textContaining('Kargoda • 48 Saniye Kaldı'), findsOneWidget);
      expect(find.textContaining('Sektörel Lojistik Konsorsiyumu'), findsOneWidget);
      expect(find.text('İPTAL'), findsOneWidget);
      expect(find.text('HAVA KARGO İLE GETİR & TESLİM ET'), findsOneWidget);

      // Tap action button (in test env, triggers fallback dialog)
      await tester.tap(find.text('HAVA KARGO İLE GETİR & TESLİM ET'));
      await tester.pumpAndSettle();

      final claimBtnFinder = find.byWidgetPredicate((w) => w is NeoBrutalButton);
      if (claimBtnFinder.evaluate().isNotEmpty) {
        await tester.tap(claimBtnFinder.last);
        await tester.pumpAndSettle();
      }

      expect(rushEarned, isTrue);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      toastification.dismissAll(delayForAnimation: false);
    });

    testWidgets('2. Optional cash rush button triggers onRushWithCash callback', (tester) async {
      bool cashRushTriggered = false;

      await tester.pumpWidget(
        buildTestApp(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                GenericRushJobDialog.show(
                  context,
                  titleBadge: 'SANAYİDE GECE MESAİSİ',
                  targetTitle: 'VW Passat 2.0 TDI • Motor Revizyonu',
                  targetSubtitle: '2 Gün Kaldı',
                  loreDescription: 'Sanayi Usta Dayanışma Ağı çift vardiyayı devreye alır.',
                  actionButtonLabel: 'ÇİFTE VARDİYAYA GEÇ & TAMAMLA',
                  rushCashCost: 5000.0,
                  onRushWithCash: () {
                    cashRushTriggered = true;
                  },
                  onRushSuccess: () {},
                );
              },
              child: const Text('SHOW MODAL WITH CASH'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('SHOW MODAL WITH CASH'));
      await tester.pumpAndSettle();

      expect(find.textContaining('5000'), findsOneWidget);
      expect(find.textContaining('NAKİT İLE ANINDA TAMAMLA'), findsOneWidget);

      await tester.tap(find.textContaining('5000'));
      await tester.pumpAndSettle();

      expect(cashRushTriggered, isTrue);
      expect(find.byType(GenericRushJobDialog), findsNothing);
    });
  });
}
