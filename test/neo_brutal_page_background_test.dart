import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_page_background.dart';

void main() {
  testWidgets('NeoBrutalPageBackground renders all watermark types without error', (tester) async {
    for (final watermark in ThematicWatermarkType.values) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(
            extensions: [
              AppThemeExtension(
                palette: ThemePaletteModel.defaultPalettes.firstWhere((p) => p.isDark),
              ),
            ],
          ),
          home: Scaffold(
            body: NeoBrutalPageBackground(
              watermark: watermark,
              child: const Center(child: Text('Content')),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    }
  });

  testWidgets('NeoBrutalPageBackground adapts across all 4 theme palettes', (tester) async {
    for (final palette in ThemePaletteModel.defaultPalettes) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: palette.isDark ? Brightness.dark : Brightness.light,
            extensions: [
              AppThemeExtension(palette: palette),
            ],
          ),
          home: Scaffold(
            body: NeoBrutalPageBackground(
              watermark: ThematicWatermarkType.dealership,
              child: Text(palette.name),
            ),
          ),
        ),
      );

      expect(find.text(palette.name), findsOneWidget);
    }
  });
}
