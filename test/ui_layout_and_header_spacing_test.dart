import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_banners.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_office_view.dart';
import 'package:galeriden/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:galeriden/presentation/screens/showroom/showroom_screen.dart';
import 'package:galeriden/presentation/widgets/daily_bulletin_dialog.dart';
import 'package:galeriden/presentation/widgets/shareable_dealership_card_dialog.dart';
import 'package:galeriden/presentation/widgets/app_floating_dock.dart';
import 'package:galeriden/presentation/widgets/car_damage_schema_widget.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_app_bar.dart';

Widget _buildTestApp(Widget child,
    {ProviderContainer? container, Size screenSize = const Size(360, 640)}) {
  final testTheme = ThemeData.light().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  final widget = MaterialApp(
    locale: const Locale('tr'),
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
    home: MediaQuery(
      data: MediaQueryData(
        size: screenSize,
        padding: const EdgeInsets.only(top: 44, bottom: 34),
      ),
      child: Scaffold(
        body: child,
      ),
    ),
  );

  if (container != null) {
    return UncontrolledProviderScope(
      container: container,
      child: widget,
    );
  }

  return ProviderScope(child: widget);
}

void main() {
  group('UI Layout & Header Spacing Architecture Tests', () {
    testWidgets('1. ShowroomScreen standalone has NeoBrutalAppBar; embedded has none',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      // Standalone mode
      await tester.pumpWidget(
        _buildTestApp(
          const ShowroomScreen(embeddedInDashboard: false),
          container: container,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalAppBar), findsOneWidget);

      // Embedded mode
      await tester.pumpWidget(
        _buildTestApp(
          const ShowroomScreen(embeddedInDashboard: true),
          container: container,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalAppBar), findsNothing);

      container.dispose();
    });

    testWidgets('2. MarketplaceScreen standalone has NeoBrutalAppBar; embedded has none',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      // Standalone mode
      await tester.pumpWidget(
        _buildTestApp(
          const MarketplaceScreen(embeddedInDashboard: false),
          container: container,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalAppBar), findsOneWidget);

      // Embedded mode
      await tester.pumpWidget(
        _buildTestApp(
          const MarketplaceScreen(embeddedInDashboard: true),
          container: container,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(NeoBrutalAppBar), findsNothing);

      container.dispose();
    });

    testWidgets('3. DashboardOfficeView renders cleanly without inner Scaffold or AppBar',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final game = container.read(gameProvider);
      final palette = ThemePaletteModel.defaultPalettes.first;

      await tester.pumpWidget(
        _buildTestApp(
          DashboardOfficeView(game: game, palette: palette),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NeoBrutalAppBar), findsNothing);
      expect(find.byType(ListView), findsOneWidget);

      container.dispose();
    });

    testWidgets('4. AppFloatingDock renders cleanly on narrow 320px screen without overflow',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          AppFloatingDock(
            currentIndex: 1,
            onTap: (_) {},
            items: const [
              FloatingDockItem(icon: Icons.home, label: 'Ana Sayfa'),
              FloatingDockItem(icon: Icons.directions_car, label: 'Showroom & Galerim'),
              FloatingDockItem(icon: Icons.store, label: 'Pazar Yeri'),
              FloatingDockItem(icon: Icons.business, label: 'Yönetim Ofisi'),
            ],
          ),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. CarDamageSchemaWidget renders responsive Wrap without overflow on 320px screen',
        (tester) async {
      final sampleParts = <String, PartStatus>{
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.painted,
        'Sağ Ön Çamurluk': PartStatus.changed,
      };

      await tester.pumpWidget(
        _buildTestApp(
          CarDamageSchemaWidget(bodyParts: sampleParts),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('6. DashboardRetentionHighlightsRow renders cleanly on narrow 320px screen',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final game = container.read(gameProvider);
      final palette = ThemePaletteModel.defaultPalettes.first;

      await tester.pumpWidget(
        _buildTestApp(
          Consumer(
            builder: (context, ref, _) => DashboardRetentionHighlightsRow(
              game: game,
              palette: palette,
              ref: ref,
            ),
          ),
          container: container,
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('7. DailyBulletinDialog renders cleanly with SingleChildScrollView on compact height',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        _buildTestApp(
          const DailyBulletinDialog(),
          container: container,
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsWidgets);

      container.dispose();
    });

    testWidgets('8. ShareableDealershipCardDialog renders cleanly with SingleChildScrollView on compact height',
        (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        _buildTestApp(
          const ShareableDealershipCardDialog(),
          container: container,
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsWidgets);

      container.dispose();
    });
  });
}
