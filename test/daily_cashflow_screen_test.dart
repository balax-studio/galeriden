import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/finance/daily_cashflow_screen.dart';

void main() {
  group('DailyCashflowScreen Widget & Calculations Test Suite', () {
    testWidgets('1. DailyCashflowScreen renders hero summary and breakdown cards', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final businesses = DealershipModel.initial().sideBusinesses.map((b) {
        if (b.id == 'sb_1') {
          return b.copyWith(isOwned: true, level: 1);
        }
        return b;
      }).toList();

      final initialDealership = DealershipModel.initial().copyWith(
        sideBusinesses: businesses,
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Ahmet Çırak',
            role: StaffRole.washer,
            hiredAt: DateTime.now(),
            salaryMultiplier: 1.0,
          ),
        ],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: const MaterialApp(
            home: DailyCashflowScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check title and hero elements
      expect(find.text('GÜNLÜK NET NAKİT AKIŞI'), findsWidgets);
      expect(find.text('NET GÜNLÜK NAKİT AKIŞI'), findsOneWidget);
      expect(find.text('DİNAMİK GÜNLÜK GELİRLER'), findsOneWidget);
      expect(find.text('DİNAMİK GÜNLÜK GİDERLER'), findsOneWidget);
      expect(find.text('HIZLI YÖNETİM & GELİR ARTIRMA'), findsOneWidget);

      // Check breakdown items
      expect(find.textContaining('Oto Yıkama'), findsWidgets);
      expect(find.textContaining('Ahmet Çırak'), findsOneWidget);
      expect(find.textContaining('Galeri Sabit Genel Gideri'), findsOneWidget);
    });

    testWidgets('2. DailyCashflowScreen correctly calculates positive cashflow status', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final businesses = DealershipModel.initial().sideBusinesses.map((b) {
        if (b.id == 'sb_1' || b.id == 'sb_2') {
          return b.copyWith(isOwned: true, level: 3, hasManager: true);
        }
        return b;
      }).toList();

      final profitableDealership = DealershipModel.initial().copyWith(
        sideBusinesses: businesses,
        hiredStaff: [],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(profitableDealership.toJson()),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: const MaterialApp(
            home: DailyCashflowScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('POZİTİF KÂR AKIŞI'), findsOneWidget);
      expect(find.text('7 & 30 GÜNLÜK PROJEKSİYON'), findsOneWidget);
      expect(find.textContaining('Finansal Durum Mükemmel'), findsOneWidget);
    });

    testWidgets('3. DailyCashflowScreen correctly calculates negative cashflow status', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final deficitDealership = DealershipModel.initial().copyWith(
        sideBusinesses: [],
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Mehmet Usta',
            role: StaffRole.masterMechanic,
            hiredAt: DateTime.now(),
            salaryMultiplier: 1.0,
          ),
        ],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(deficitDealership.toJson()),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: const MaterialApp(
            home: DailyCashflowScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('NAKİT AÇIĞI (ZARAR)'), findsOneWidget);
      expect(find.textContaining('Personel Gideri Yüksek'), findsOneWidget);
    });
  });
}
