import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/screens/showroom/widgets/car_cost_breakdown_sheet.dart';
import 'package:galeriden/presentation/screens/workshop/widgets/workshop_repair_tile.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child, {Size surfaceSize = const Size(360, 640)}) {
    return MaterialApp(
      locale: const Locale('tr'),
      supportedLocales: AppLanguage.values.map((e) => e.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: MediaQuery(
        data: MediaQueryData(size: surfaceSize),
        child: Scaffold(
          body: Center(child: child),
        ),
      ),
    );
  }

  group('UI Overflow & Button State Transition Tests', () {
    testWidgets('NeoBrutalButton falls back gracefully when isApplied is true without appliedLabel',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NeoBrutalButton(
            label: 'OZEL ETIKET',
            isApplied: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('OZEL ETIKET'), findsOneWidget);
    });

    testWidgets('WorkshopRepairTile renders without overflow at 360dp width in unrepaired state',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          WorkshopRepairTile(
            title: '1. Motor Revizyonu',
            description: 'Silindir kapak contasi ve supap ayari yenilenir.',
            cost: 15000,
            bonusText: '+%12 Fiyat',
            netRoiText: 'Net Getiri: +₺18.000',
            badgeColor: AppColors.brutalGreen,
            isDark: false,
            isRepaired: false,
            onRepair: () {},
            onAdRepair: () {},
          ),
          surfaceSize: const Size(360, 640),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1. Motor Revizyonu'), findsOneWidget);
      expect(find.byType(NeoBrutalButton), findsNWidgets(2));
    });

    testWidgets('WorkshopRepairTile renders without overflow at 360dp width in repaired state',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestableWidget(
          WorkshopRepairTile(
            title: '1. Motor Revizyonu',
            description: 'Silindir kapak contasi ve supap ayari yenilenir.',
            cost: 15000,
            bonusText: '+%12 Fiyat',
            badgeColor: AppColors.brutalGreen,
            isDark: false,
            isRepaired: true,
            disabledLabel: 'UYGULANDI',
            onRepair: () {},
          ),
          surfaceSize: const Size(360, 640),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1. Motor Revizyonu'), findsOneWidget);
      expect(find.byType(NeoBrutalButton), findsOneWidget);
    });

    testWidgets('CarCostBreakdownSheet renders without overflow on 360dp width screen',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final car = CarModel(
        id: 'test_car_1',
        brand: 'BMW',
        modelName: '320i M Sport',
        modelYear: 2022,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 800000.0,
        currentPurchasePrice: 700000.0,
        expertise: ExpertiseReport(
          mileage: 45000,
          isMileageTampered: false,
          engineCondition: 90.0,
          transmissionCondition: 90.0,
          tramerAmount: 0,
          bodyParts: {},
          partConditions: {},
        ),
        isWashed: true,
        isPolished: true,
        appliedDetailingOptionIds: const ['scent_vanilla'],
      );

      await tester.pumpWidget(
        buildTestableWidget(
          CarCostBreakdownSheet(car: car),
          surfaceSize: const Size(360, 640),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('BMW 320i M Sport'), findsOneWidget);
    });
  });
}
