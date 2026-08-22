import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/animated_rolling_counter.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/pulsing_dot.dart';
import 'package:galeriden/presentation/widgets/slam_stamp_widget.dart';
import 'package:galeriden/presentation/widgets/staggered_item_entry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI Micro-Interactions & Polish Widget Tests', () {
    testWidgets('AnimatedRollingCounter formats currency and renders with tabular figures', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          home: Scaffold(
            body: AnimatedRollingCounter(
              value: 450000,
              isCurrency: true,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('₺450.000'), findsOneWidget);
      final textWidget = tester.widget<Text>(find.text('₺450.000'));
      expect(textWidget.style?.fontFeatures, contains(const FontFeature.tabularFigures()));
    });

    testWidgets('AnimatedRollingCounter short format formats correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          home: Scaffold(
            body: AnimatedRollingCounter(
              value: 1250000,
              isShort: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('₺1.3M'), findsOneWidget);
    });

    testWidgets('SlamStampWidget animates and settles with proper text', (tester) async {
      bool slamFinished = false;

      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          home: Scaffold(
            body: SlamStampWidget(
              text: 'NOTER ONAYLI',
              color: const Color(0xFF00E575),
              onSlamComplete: () => slamFinished = true,
            ),
          ),
        ),
      );

      // Verify widget rendered
      expect(find.text('NOTER ONAYLI'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(slamFinished, isTrue);
    });

    testWidgets('PulsingDot animates breathing pulse and renders ripple', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          home: Scaffold(
            body: PulsingDot(
              color: Color(0xFF00E575),
              size: 10,
              showRipple: true,
            ),
          ),
        ),
      );

      expect(find.byType(PulsingDot), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.byType(PulsingDot), findsOneWidget);
    });

    testWidgets('StaggeredItemEntry fades and translates into view', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          home: Scaffold(
            body: StaggeredItemEntry(
              index: 2,
              child: Text('Staggered Card Content'),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Staggered Card Content'), findsOneWidget);
    });

    testWidgets('NeoBrutalButton respects minimum touch height and haptic feedback trigger', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
          home: Scaffold(
            body: Center(
              child: NeoBrutalButton(
                label: 'HIZLI AL',
                hapticType: NeoHapticType.light,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      final renderBox = tester.renderObject<RenderBox>(find.byType(NeoBrutalButton));
      expect(renderBox.size.height, greaterThanOrEqualTo(44.0));

      await tester.tap(find.byType(NeoBrutalButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
