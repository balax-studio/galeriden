import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/presentation/widgets/pixel_art/neo_brutal_pixel_face.dart';
import 'helpers/invariant_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child, {Locale locale = const Locale('tr')}) {
    return MaterialApp(
      locale: locale,
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
      home: Scaffold(
        body: Center(child: child),
      ),
    );
  }

  group('NeoBrutalPixelFaceWidget Invariant and Localization Tests', () {
    test('All 5 pixel face translation keys satisfy invariant rules across 7 languages', () {
      expectInvariantKeys([
        'pixel_face_dealer',
        'pixel_face_banker',
        'pixel_face_mechanic',
        'pixel_face_notary',
        'pixel_face_gambler',
      ]);
    });

    test('Default accent colors match expression specifications', () {
      expect(
        PixelFaceExpression.cunningDealer.defaultAccentColor,
        equals(AppColors.brutalYellow),
      );
      expect(
        PixelFaceExpression.panickedBanker.defaultAccentColor,
        equals(AppColors.brutalRed),
      );
      expect(
        PixelFaceExpression.sweatingMechanic.defaultAccentColor,
        equals(AppColors.brutalOrange),
      );
      expect(
        PixelFaceExpression.smugNotary.defaultAccentColor,
        equals(AppColors.brutalCyan),
      );
      expect(
        PixelFaceExpression.hypedGambler.defaultAccentColor,
        equals(AppColors.brutalGreen),
      );
    });
  });

  group('NeoBrutalPixelFaceWidget Rendering & Interactions', () {
    testWidgets('Renders all 5 PixelFaceExpression variants without errors',
        (tester) async {
      for (final expression in PixelFaceExpression.values) {
        await tester.pumpWidget(
          buildTestableWidget(
            NeoBrutalPixelFaceWidget(
              expression: expression,
              size: 56.0,
            ),
          ),
        );
        expect(find.byType(NeoBrutalPixelFaceWidget), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('Renders localized badge when showBadge is true in TR',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NeoBrutalPixelFaceWidget(
            expression: PixelFaceExpression.panickedBanker,
            showBadge: true,
          ),
          locale: const Locale('tr'),
        ),
      );

      expect(find.byType(NeoBrutalPixelFaceWidget), findsOneWidget);
      expect(find.text('PANIK!'), findsOneWidget);
    });

    testWidgets('Renders localized badge in English', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NeoBrutalPixelFaceWidget(
            expression: PixelFaceExpression.cunningDealer,
            showBadge: true,
          ),
          locale: const Locale('en'),
        ),
      );

      expect(find.byType(NeoBrutalPixelFaceWidget), findsOneWidget);
      expect(find.text('SLY'), findsOneWidget);
    });

    testWidgets('Invokes onTap callback when pressed', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildTestableWidget(
          NeoBrutalPixelFaceWidget(
            expression: PixelFaceExpression.sweatingMechanic,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(NeoBrutalPixelFaceWidget));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
