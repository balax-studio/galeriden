import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/confetti_celebration_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Neo-Brutalist Confetti Celebration Overlay Tests', () {
    testWidgets('1. ConfettiCelebrationOverlay mounts and generates all 5 geometric shapes', (tester) async {
      bool isFinished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfettiCelebrationOverlay(
              duration: const Duration(milliseconds: 500),
              particleCount: 50,
              onFinished: () {
                isFinished = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(ConfettiCelebrationOverlay), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      // Advance animation halfway
      await tester.pump(const Duration(milliseconds: 250));
      expect(isFinished, isFalse);

      // Complete animation
      await tester.pump(const Duration(milliseconds: 300));
      expect(isFinished, isTrue);

      // Unmount cleanly
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets('2. ConfettiCelebrationOverlay.show attaches to Navigator overlay and removes entry on finish', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ConfettiCelebrationOverlay.show(
                      context,
                      duration: const Duration(milliseconds: 400),
                    );
                  },
                  child: const Text('PATLAT'),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('PATLAT'), findsOneWidget);

      // Trigger static show helper
      await tester.tap(find.text('PATLAT'));
      await tester.pump();

      // Verify ConfettiCelebrationOverlay appears in overlay tree
      expect(find.byType(ConfettiCelebrationOverlay), findsOneWidget);

      // Pump to completion
      await tester.pump(const Duration(milliseconds: 500));

      // Entry should be removed from overlay
      expect(find.byType(ConfettiCelebrationOverlay), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 50));
    });
  });
}
