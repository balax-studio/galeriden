import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/daily_bulletin_dialog.dart';
import 'package:galeriden/presentation/widgets/pixel_art/neo_brutal_pixel_face.dart';
import 'helpers/invariant_test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(
    Widget child, {
    Locale locale = const Locale('tr'),
    ProviderContainer? container,
  }) {
    final testTheme = ThemeData.light().copyWith(
      extensions: [
        AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
      ],
    );

    final app = MaterialApp(
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
      theme: testTheme,
      home: Scaffold(
        body: Center(child: child),
      ),
    );

    if (container != null) {
      return UncontrolledProviderScope(
        container: container,
        child: app,
      );
    }
    return app;
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

    testWidgets('Renders localized badge in Arabic with ligature-safe letter spacing',
        (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NeoBrutalPixelFaceWidget(
            expression: PixelFaceExpression.cunningDealer,
            showBadge: true,
          ),
          locale: const Locale('ar'),
        ),
      );

      expect(find.byType(NeoBrutalPixelFaceWidget), findsOneWidget);
      expect(find.text('داهية'), findsOneWidget);

      final textWidget = tester.widget<Text>(find.text('داهية'));
      expect(textWidget.style?.letterSpacing, equals(0.0));
    });

    testWidgets('Ignores pointer events when onTap is null', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const NeoBrutalPixelFaceWidget(
            expression: PixelFaceExpression.smugNotary,
          ),
        ),
      );

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(NeoBrutalPixelFaceWidget),
          matching: find.byType(IgnorePointer),
        ).first,
      );
      expect(ignorePointer.ignoring, isTrue);
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

      final ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(
          of: find.byType(NeoBrutalPixelFaceWidget),
          matching: find.byType(IgnorePointer),
        ).first,
      );
      expect(ignorePointer.ignoring, isFalse);

      await tester.tap(find.byType(NeoBrutalPixelFaceWidget));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('DailyBulletinDialog renders pixel face cleanly in LTR and RTL without overflow',
        (tester) async {
      for (final locale in [const Locale('tr'), const Locale('ar')]) {
        final container = ProviderContainer();
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

        await tester.pumpWidget(
          buildTestableWidget(
            const DailyBulletinDialog(),
            locale: locale,
            container: container,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(DailyBulletinDialog), findsOneWidget);
        expect(find.byType(NeoBrutalPixelFaceWidget), findsOneWidget);
        expect(tester.takeException(), isNull);

        container.dispose();
      }
    });
  });
}
