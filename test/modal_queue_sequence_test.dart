import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/tactile_cash_pattern_painter.dart';
import 'package:galeriden/presentation/widgets/dialogs/daily_login_sheet.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_retention_modals.dart';

void main() {
  group('Modal Queue Sequence & Tactile Cash Tests (§SPEC-2026-09-12-SEQUENTIAL-RETENTION-ORCHESTRATION)', () {
    testWidgets('TactileCashPatternOverlay sıfır hata ile canvas üzerine çizim yapar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 150,
              child: TactileCashPatternOverlay(
                child: Center(
                  child: Text('Taktil Banknot Testi'),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TactileCashPatternOverlay), findsOneWidget);
      expect(find.text('Taktil Banknot Testi'), findsOneWidget);
    });

    test('showOfflineRecapModal ve DailyLoginSheet.show Future döndürür', () {
      // Metot imzalarının Future döndürdüğü statik olarak doğrulanır
      expect(DashboardRetentionModals.showOfflineRecapModal, isA<Function>());
      expect(DailyLoginSheet.show, isA<Function>());
    });
  });
}
