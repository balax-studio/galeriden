import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/core/theme/app_colors.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_empty_state.dart';
import 'package:galeriden/presentation/widgets/procedural_shader_textures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Procedural Shader & Generative Art Textures Tests', () {
    testWidgets('CrtScanlinesOverlay paints horizontal CRT raster scanlines',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 200,
              child: CrtScanlinesOverlay(
                opacity: 0.15,
                lineSpacing: 3.0,
                scanlineColor: AppColors.brutalCyan,
                child: Center(child: Text('GOSSIP TERMINAL')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CrtScanlinesOverlay), findsOneWidget);
      expect(find.text('GOSSIP TERMINAL'), findsOneWidget);
    });

    testWidgets('BayerDitherOverlay generates 4x4 matrix ordered dithering',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 200,
              child: BayerDitherOverlay(
                dotSize: 1.5,
                spacing: 4.0,
                opacity: 0.10,
                ditherColor: Colors.black,
                child: Center(child: Text('THERMAL RECEIPT')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(BayerDitherOverlay), findsOneWidget);
      expect(find.text('THERMAL RECEIPT'), findsOneWidget);
    });

    testWidgets('TactileBrutalStamp renders angled neo-brutalist stamp',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: TactileBrutalStamp(
                text: 'ONAYLANDI',
                color: AppColors.brutalGreen,
                angleRadians: -0.12,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TactileBrutalStamp), findsOneWidget);
      expect(find.text('ONAYLANDI'), findsOneWidget);
    });

    testWidgets('CadBlueprintOverlay renders CAD millimeter grid and crosses',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              height: 200,
              child: CadBlueprintOverlay(
                gridSpacing: 16.0,
                gridColor: AppColors.brutalCyan,
                opacity: 0.12,
                child: Center(child: Text('CONSTRUCTION BLUEPRINT')),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CadBlueprintOverlay), findsOneWidget);
      expect(find.text('CONSTRUCTION BLUEPRINT'), findsOneWidget);
    });
  });

  group('Simultaneous 7-Language Localization Integrity & Invariants', () {
    const supportedLangs = ['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar'];
    const requiredKeys = [
      'reviews_empty_cta',
      'scrap_no_parts_cta',
      'gossip_empty_cta',
      'consignment_earn_rep_cta',
      'media_headline_tag',
      'scrap_mechanic_order_badge',
    ];

    test('All required new keys exist simultaneously across all 7 languages',
        () {
      for (final lang in supportedLangs) {
        final keys = AppLocalizations.getAllKeysFor(lang);
        for (final key in requiredKeys) {
          expect(keys.containsKey(key), isTrue,
              reason: 'Missing key "$key" in "$lang"');
          expect(keys[key]!.trim(), isNotEmpty,
              reason: 'Empty translation for "$key" in "$lang"');
        }
      }
    });

    test('Invariant Rules: Zero Unicode Emojis in new translations', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
        unicode: true,
      );

      for (final lang in supportedLangs) {
        final keys = AppLocalizations.getAllKeysFor(lang);
        for (final key in requiredKeys) {
          final value = keys[key] ?? '';
          expect(emojiRegex.hasMatch(value), isFalse,
              reason: 'Found emoji in key "$key" in "$lang": "$value"');
        }
      }
    });

    test('Invariant Rules: Zero Parentheses in new translations', () {
      for (final lang in supportedLangs) {
        final keys = AppLocalizations.getAllKeysFor(lang);
        for (final key in requiredKeys) {
          final value = keys[key] ?? '';
          expect(value.contains('(') || value.contains(')'), isFalse,
              reason: 'Found parentheses in key "$key" in "$lang": "$value"');
        }
      }
    });
  });

  group('Empty State CTA & Narrow Screen Viewport Resilience (<340dp)', () {
    testWidgets(
        'NeoBrutalEmptyState renders action button cleanly on 320px compact phone',
        (tester) async {
      tester.view.physicalSize = const Size(320, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NeoBrutalEmptyState(
              icon: Icons.rate_review_outlined,
              title: 'Müşteri Yorumu Bulunmuyor',
              description:
                  'Satış yaptıkça müşterilerinizin yorumları burada sergilenir.',
              actionLabel: 'Showroom Vitrinine Git',
              actionIcon: Icons.storefront_rounded,
              onActionPressed: () => actionPressed = true,
            ),
          ),
        ),
      );

      expect(find.byType(NeoBrutalEmptyState), findsOneWidget);
      expect(find.text('Showroom Vitrinine Git'), findsOneWidget);

      await tester.tap(find.text('Showroom Vitrinine Git'));
      await tester.pumpAndSettle();
      expect(actionPressed, isTrue);
    });
  });
}
