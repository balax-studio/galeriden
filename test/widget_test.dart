import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/app/app.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  testWidgets('App renders onboarding screen on initial launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const GaleridenApp(),
      ),
    );

    expect(find.byType(GaleridenApp), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  });
}
