import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/auction_session_provider.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/auction/auction_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AuctionScreen mounts cleanly without modifying provider during widget build', (tester) async {
    final unlockedGame = DealershipModel.initial().copyWith(
      level: 5,
      reputationScore: 50,
      balance: 1000000,
    );

    SharedPreferences.setMockInitialValues({
      'dealership_state_v2': jsonEncode(unlockedGame.toJson()),
    });

    final container = ProviderContainer(
      overrides: [
        gameProvider.overrideWith((ref) => GameNotifier()),
      ],
    );

    addTearDown(() {
      try {
        container.read(auctionSessionProvider.notifier).stopTimer();
      } catch (_) {}
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('tr'),
          supportedLocales: const [Locale('tr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData.light().copyWith(
            extensions: [
              AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
            ],
          ),
          home: const AuctionScreen(),
        ),
      ),
    );

    // Initial pump (didChangeDependencies schedules addPostFrameCallback)
    expect(tester.takeException(), isNull);

    // Stop timers and drain callbacks
    container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);

    // Verify auction session is active and bid logs are initialized
    final auctionState = container.read(auctionSessionProvider);
    expect(auctionState.bidLogs.isNotEmpty, isTrue);

    // Stop auction timer before unmounting
    container.read(auctionSessionProvider.notifier).stopTimer();

    // Cleanly unmount
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
