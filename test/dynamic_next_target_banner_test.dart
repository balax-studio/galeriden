import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_services_grid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('DashboardServicesGrid renders dynamic rotating next target banner with motivating benefits', (tester) async {
    final game = DealershipModel.initial();
    final palette = ThemePaletteModel.defaultPalettes.first;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DashboardServicesGrid(
                game: game,
                palette: palette,
              ),
            ),
          ),
        ),
      ),
    );

    // Initial render
    await tester.pump();

    // Verify unlocked core services exist
    expect(find.text('Araç Satın Al'), findsOneWidget);
    expect(find.text('Showroom & Galerim'), findsOneWidget);
    expect(find.text('Şube Yönetimi'), findsOneWidget);

    // Verify 'SIRADAKİ HEDEF' badge is rendered
    expect(find.text('SIRADAKİ HEDEF'), findsOneWidget);
    expect(find.text('ŞUBELER'), findsOneWidget);

    // Initial locked item is Oto Yıkama (or first locked service)
    expect(find.text('Oto Yıkama'), findsOneWidget);
    expect(find.text('Araçları yıka & detaylandır, kâr marjını %10-15 artır!'), findsOneWidget);

    // Advance timer by 5 seconds to test auto-rotation
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));

    // Next item (Tamir & Atölye) should now be displayed
    expect(find.text('Tamir & Atölye'), findsOneWidget);
    expect(find.text('Hasarlı araçları kelepire topla, onarıp yüksek kârla sat!'), findsOneWidget);

    // Tap card to manually cycle target
    await tester.tap(find.text('Tamir & Atölye'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Next item (Tuning Stüdyosu) should now be displayed
    expect(find.text('Tuning Stüdyosu'), findsOneWidget);
    expect(find.text('Stage yazılım & egzoz tak, gece yarışlarına hükmet!'), findsOneWidget);
  });
}
