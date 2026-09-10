import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_banners.dart';

Widget _buildTestApp({
  required DealershipModel game,
  required ThemePaletteModel palette,
  Size size = const Size(360, 640),
}) {
  return MaterialApp(
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
    home: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DashboardDailyCashFlowCard(
              game: game,
              palette: palette,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  final lightPalette = ThemePaletteModel.defaultPalettes.first;
  final darkPalette = ThemePaletteModel.defaultPalettes.firstWhere(
    (p) => p.isDark,
    orElse: () => ThemePaletteModel.defaultPalettes.first,
  );

  group('DashboardDailyCashFlowCard Tactical HUD Tests', () {
    testWidgets('1. Renders positive cash flow card with telemetry pods', (tester) async {
      final ownedBusinesses = DealershipModel.initial().sideBusinesses.map((b) {
        if (b.id == 'sb_1') {
          return b.copyWith(isOwned: true, level: 2);
        }
        return b;
      }).toList();

      final game = DealershipModel.initial().copyWith(
        sideBusinesses: ownedBusinesses,
        hiredStaff: [],
        activeLoans: [],
      );

      await tester.pumpWidget(_buildTestApp(game: game, palette: lightPalette));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardDailyCashFlowCard), findsOneWidget);
      expect(find.text('GÜNLÜK NET NAKİT AKIŞI'), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.badge_rounded), findsOneWidget);
      // No active loans, so loan pod is omitted
      expect(find.byIcon(Icons.account_balance_outlined), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. Displays loan telemetry pod when active loans exist', (tester) async {
      final game = DealershipModel.initial().copyWith(
        sideBusinesses: [],
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Usta',
            role: StaffRole.masterMechanic,
            hiredAt: DateTime.now(),
            salaryMultiplier: 1.0,
          ),
        ],
        activeLoans: [
          const LoanModel(
            id: 'loan_1',
            bankName: 'Halkbank',
            principalAmount: 100000,
            interestRate: 0.05,
            totalRepayment: 120000,
            remainingAmount: 80000,
            totalInstallments: 12,
            remainingInstallments: 8,
            monthlyPayment: 2500,
          ),
        ],
      );

      await tester.pumpWidget(_buildTestApp(game: game, palette: darkPalette));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardDailyCashFlowCard), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_outlined), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. Compact screen renders without overflow', (tester) async {
      final game = DealershipModel.initial().copyWith(
        sideBusinesses: DealershipModel.initial().sideBusinesses.map((b) => b.copyWith(isOwned: true, level: 3)).toList(),
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Ali Usta',
            role: StaffRole.appraiser,
            hiredAt: DateTime.now(),
            salaryMultiplier: 1.5,
          ),
        ],
        activeLoans: [
          const LoanModel(
            id: 'loan_test',
            bankName: 'İş Bankası',
            principalAmount: 50000,
            interestRate: 0.04,
            totalRepayment: 60000,
            remainingAmount: 45000,
            totalInstallments: 10,
            remainingInstallments: 7,
            monthlyPayment: 1500,
          ),
        ],
      );

      // Ultra-narrow viewport (320px)
      await tester.pumpWidget(_buildTestApp(game: game, palette: lightPalette, size: const Size(320, 568)));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardDailyCashFlowCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
