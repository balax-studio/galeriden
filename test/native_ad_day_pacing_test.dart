import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/ad_service.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/ads/neo_brutal_native_ad_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Native Ad 7-Day Protection & Dynamic Day Pacing Algorithm Tests', () {
    test('AdService.shouldShowNativeAdForDay strictly returns false for first 7 in-game days', () {
      for (int day = 1; day <= 7; day++) {
        expect(
          AdService.shouldShowNativeAdForDay(day, NativeAdContextType.marketplace),
          isFalse,
          reason: 'Day $day must be strictly ad-free and sponsor-free',
        );
        expect(
          AdService.shouldShowNativeAdForDay(day, NativeAdContextType.gossip),
          isFalse,
          reason: 'Day $day must be strictly ad-free in gossip screen',
        );
        expect(
          AdService.shouldShowNativeAdForDay(day, NativeAdContextType.stockMarket),
          isFalse,
          reason: 'Day $day must be strictly ad-free in stock market screen',
        );
      }
    });

    test('AdService.shouldShowNativeAdForDay alternates dynamically after Day 7', () {
      int activeDays = 0;
      int inactiveDays = 0;

      // Sample a 30-day window (Days 8 to 37)
      for (int day = 8; day <= 37; day++) {
        final isShown = AdService.shouldShowNativeAdForDay(day, NativeAdContextType.marketplace);
        if (isShown) {
          activeDays++;
        } else {
          inactiveDays++;
        }
      }

      // Both active and inactive days must exist (bazen açık, bazen kapalı)
      expect(activeDays > 0, isTrue, reason: 'There must be active ad days after day 7');
      expect(inactiveDays > 0, isTrue, reason: 'There must be clean ad-free days after day 7');
      // The ratio should be balanced (around 40% - 70%)
      expect(activeDays, inInclusiveRange(10, 24));
    });

    testWidgets('NeoBrutalNativeAdCard renders SizedBox.shrink on Day 1-7', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Ensure day is within first 7 days
      expect(container.read(gameProvider).currentDay <= 7, isTrue);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: NeoBrutalNativeAdCard(
                contextType: NativeAdContextType.marketplace,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Card / sponsor title must NOT be rendered on Day 1-7
      expect(find.text('SPONSORLU İLAN'), findsNothing);
      expect(find.text('YEREL DUYURU'), findsNothing);
      expect(find.byType(NeoBrutalNativeAdCard), findsOneWidget);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('NeoBrutalNativeAdCard dynamically renders when day progresses to an active ad day', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      // Find an active day after day 7
      int targetActiveDay = 8;
      while (!AdService.shouldShowNativeAdForDay(targetActiveDay, NativeAdContextType.marketplace)) {
        targetActiveDay++;
      }

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('tr'), Locale('en')],
            locale: const Locale('tr'),
            theme: AppTheme.darkTheme,
            home: const Scaffold(
              body: NeoBrutalNativeAdCard(
                contextType: NativeAdContextType.marketplace,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Set target active day after initial load settles
      notifier.state = notifier.state.copyWith(currentDay: targetActiveDay);
      await tester.pumpAndSettle();

      // On active day > 7, fallback sponsor lore card or native ad container is rendered
      expect(find.text('YEREL DUYURU'), findsOneWidget);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
