import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/splash/splash_screen.dart';
import 'package:galeriden/presentation/widgets/hazard_stripe_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'has_seen_onboarding': true,
    });
  });

  Widget createTestWidget(ProviderContainer container) {
    return UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        locale: Locale('tr'),
        supportedLocales: [
          Locale('tr'),
          Locale('en'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(),
      ),
    );
  }

  testWidgets('SplashScreen renders Neo-Brutalist title, badge, hazard stripes and telemetry', (tester) async {
    final container = ProviderContainer();
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

    await tester.pumpWidget(createTestWidget(container));
    await tester.pump();

    // Verify main components are rendered
    expect(find.text('GALERİDEN'), findsNWidgets(2)); // Stroke outline + fill text
    expect(find.text(AppLocalizations.tr(tester.element(find.byType(SplashScreen)), 'splash_studio_present')), findsOneWidget);
    expect(find.text('ENGINE TELEMETRY'), findsOneWidget);
    expect(find.byType(HazardStripeWidget), findsNWidgets(2)); // Top and bottom hazard stripes

    // Pump halfway through 1.5s animation
    await tester.pump(const Duration(milliseconds: 750));
    expect(find.byType(SplashScreen), findsOneWidget);

    // Pump past full duration
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));
    container.dispose();
  });

  testWidgets('Tapping SplashScreen triggers fast-forward without error', (tester) async {
    final container = ProviderContainer();
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

    await tester.pumpWidget(createTestWidget(container));
    await tester.pump();

    // Tap to fast-forward
    await tester.tap(find.byType(SplashScreen));
    await tester.pumpAndSettle();

    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 500));
    container.dispose();
  });
}
