import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/presentation/widgets/countdown_heat_ring.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_badge.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/zeigarnik_progress_bar.dart';

void main() {
  BoxDecoration getButtonDecoration(WidgetTester tester) {
    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(NeoBrutalButton),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return decoratedBox.decoration as BoxDecoration;
  }

  group('NeoBrutalButton Semantic Variants', () {
    testWidgets('primary variant resolves brutalGreen and black text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalButton.primary(
              label: 'Satin Al',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = getButtonDecoration(tester);
      expect(decoration.color, AppColors.brutalGreen);
      expect(decoration.border?.top.width, 2.5);

      final text = tester.widget<Text>(find.text('Satin Al'));
      expect(text.style?.color, const Color(0xFF07090E));
    });

    testWidgets('destructive variant resolves brutalRed and white text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalButton.destructive(
              label: 'Sat',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = getButtonDecoration(tester);
      expect(decoration.color, AppColors.brutalRed);

      final text = tester.widget<Text>(find.text('Sat'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('trade variant resolves brutalYellow and black text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalButton.trade(
              label: 'Pazarlik',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = getButtonDecoration(tester);
      expect(decoration.color, AppColors.brutalYellow);

      final text = tester.widget<Text>(find.text('Pazarlik'));
      expect(text.style?.color, const Color(0xFF07090E));
    });

    testWidgets('info variant resolves brutalCyan', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalButton.info(
              label: 'Ekspertiz',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = getButtonDecoration(tester);
      expect(decoration.color, AppColors.brutalCyan);

      final text = tester.widget<Text>(find.text('Ekspertiz'));
      expect(text.style?.color, const Color(0xFF07090E));
    });

    testWidgets('luxury variant resolves brutalPurple and white text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalButton.luxury(
              label: 'Tuning',
              onPressed: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = getButtonDecoration(tester);
      expect(decoration.color, AppColors.brutalPurple);

      final text = tester.widget<Text>(find.text('Tuning'));
      expect(text.style?.color, Colors.white);
    });

    testWidgets('disabled button resolves neutral slate styling',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: NeoBrutalButton.primary(
              label: 'Devre Disi',
              onPressed: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final decoration = getButtonDecoration(tester);
      expect(decoration.color, const Color(0xFF1E2330));
    });
  });

  group('NeoBrutalBadge Semantic Variants', () {
    testWidgets('renders success, warning, danger badges properly',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NeoBrutalBadge.success(text: 'Onaylandi'),
                NeoBrutalBadge.warning(text: 'Firsat'),
                NeoBrutalBadge.danger(text: 'Acil'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Onaylandi'), findsOneWidget);
      expect(find.text('Firsat'), findsOneWidget);
      expect(find.text('Acil'), findsOneWidget);
    });
  });

  group('CountdownHeatRing and ZeigarnikProgressBar', () {
    testWidgets('CountdownHeatRing renders in dark mode without error',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: CountdownHeatRing(
              remainingSeconds: 5,
              totalSeconds: 10,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CountdownHeatRing), findsOneWidget);
      expect(find.text('5s'), findsOneWidget);
    });

    testWidgets('ZeigarnikProgressBar.adaptive renders dynamic fill',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ZeigarnikProgressBar.adaptive(
              progress: 0.85,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ZeigarnikProgressBar), findsOneWidget);
    });
  });
}
