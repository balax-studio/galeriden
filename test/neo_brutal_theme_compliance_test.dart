import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_card.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_badge.dart';
import 'package:galeriden/presentation/screens/marketplace/widgets/turkish_hospitality_bar.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/financial_health_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Neo-Brutalist Theme System Compliance Tests', () {
    testWidgets('NeoBrutalCard renders with zero blur and correct offset', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoBrutalCard(
              borderWidth: 2.5,
              borderRadius: 12,
              shadowOffset: Offset(4, 4),
              child: Text('Test Brutal Card'),
            ),
          ),
        ),
      );

      expect(find.text('Test Brutal Card'), findsOneWidget);
      final cardFinder = find.byType(NeoBrutalCard);
      expect(cardFinder, findsOneWidget);

      final NeoBrutalCard card = tester.widget(cardFinder);
      expect(card.borderWidth, 2.5);
      expect(card.borderRadius, 12);
      expect(card.shadowOffset, const Offset(4, 4));
    });

    testWidgets('NeoBrutalButton renders and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalButton(
              label: 'TEST BUTON',
              icon: Icons.check,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('TEST BUTON'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.byType(NeoBrutalButton));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('NeoBrutalBadge displays with solid brutalist styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NeoBrutalBadge(
              text: 'İNAT KIRICI',
              backgroundColor: Color(0xFF10B981),
              textColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.text('İNAT KIRICI'), findsOneWidget);
      final badgeFinder = find.byType(NeoBrutalBadge);
      expect(badgeFinder, findsOneWidget);
    });

    testWidgets('TurkishHospitalityBar renders NeoBrutal cards and buttons', (tester) async {
      bool teaCalled = false;
      bool coffeeCalled = false;
      String? plateChosen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TurkishHospitalityBar(
              onTeaTreated: () => teaCalled = true,
              onCoffeeTreated: () => coffeeCalled = true,
              onPlateGifted: (code) => plateChosen = code,
            ),
          ),
        ),
      );

      expect(find.text('ESNAF İKRAMI & HATIR KARTLARI'), findsOneWidget);
      expect(find.text('Tavşan Çay'), findsOneWidget);
      expect(find.text('Közde Kahve'), findsOneWidget);
      expect(find.text('Özel Plaka'), findsOneWidget);
      expect(find.text('İNAT KIRICI'), findsOneWidget);

      await tester.tap(find.text('Tavşan Çay'));
      await tester.pump();
      expect(teaCalled, isTrue);

      await tester.tap(find.text('Közde Kahve'));
      await tester.pump();
      expect(coffeeCalled, isTrue);

      // Open plate dialog
      await tester.tap(find.text('Özel Plaka'));
      await tester.pumpAndSettle();

      expect(find.text('MEMLEKET PLAKASI SEÇ'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // Choose 06 Ankara
      await tester.tap(find.text('06 Ankara'));
      await tester.pumpAndSettle();

      expect(plateChosen, '06');
    });

    testWidgets('FinancialHealthCard renders properly with metrics and sifter button', (tester) async {
      final dealership = DealershipModel.initial();
      bool siftahTapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: FinancialHealthCard(
                dealership: dealership,
                onSiftahTapped: () => siftahTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('BİLANÇO & FİNANSAL SAĞLIK'), findsOneWidget);
      expect(find.text('SİFTAH ET'), findsOneWidget);
      expect(find.byType(NeoBrutalCard), findsWidgets);

      await tester.tap(find.text('SİFTAH ET'));
      await tester.pump();
      expect(siftahTapped, isTrue);
    });
  });
}
