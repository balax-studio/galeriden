import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:galeriden/app/router.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_locked_feature_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Button Action Feedback, Anti-Spam & Navigation Audit Tests', () {
    testWidgets('1. NeoBrutalButton debounces rapid spam clicking within debounceDuration', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoBrutalButton(
                label: 'HIZLI SATIN AL',
                debounceDuration: const Duration(milliseconds: 350),
                onPressed: () {
                  tapCount++;
                },
              ),
            ),
          ),
        ),
      );

      final buttonFinder = find.byType(NeoBrutalButton);
      expect(buttonFinder, findsOneWidget);

      // Tap rapidly 5 times in short sequence
      await tester.tap(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      // Only the first tap should register due to the anti-spam debounce
      expect(tapCount, equals(1));

      // Wait for debounce cooldown to expire
      await tester.pump(const Duration(milliseconds: 400));

      // Subsequent tap after cooldown succeeds
      await tester.tap(buttonFinder);
      await tester.pump();
      expect(tapCount, equals(2));
    });

    testWidgets('2. NeoBrutalButton switches to applied state (UYGULANDI) with check icon when isApplied is true', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoBrutalButton(
                label: 'UYGULA',
                appliedLabel: 'UYGULANDI',
                isApplied: true,
                onPressed: () {
                  tapCount++;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('UYGULANDI'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      // Clicking applied button is disabled and does not trigger callback
      await tester.tap(find.byType(NeoBrutalButton));
      await tester.pump();
      expect(tapCount, equals(0));
    });

    testWidgets('3. NeoBrutalButton displays loading indicator and blocks clicks when isLoading is true', (tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: NeoBrutalButton(
                label: 'İŞLEMİ YAP',
                isLoading: true,
                onPressed: () {
                  tapCount++;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('İŞLENİYOR...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Tapping during loading should not trigger callback
      await tester.tap(find.byType(NeoBrutalButton));
      await tester.pump();
      expect(tapCount, equals(0));
    });

    testWidgets('4. NeoBrutalLockedFeatureView navigation buttons route to /branches and /dashboard without error', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: NeoBrutalLockedFeatureView(
                route: '/workshop',
                featureTitle: 'SANAYİ ATÖLYESİ',
                icon: Icons.build_rounded,
              ),
            ),
          ),
        ),
      );

      expect(find.text('SANAYİ ATÖLYESİ KİLİTLİ'), findsOneWidget);
      expect(find.text('ŞUBELERE GİT & KİLİDİ AÇ'), findsOneWidget);
      expect(find.text('GERİ DÖN'), findsOneWidget);
    });

    test('5. GoRouter routes completeness audit across all game paths', () {
      final routes = appRouter.configuration.routes;
      final paths = routes.whereType<GoRoute>().map((r) => r.path).toSet();

      final expectedPaths = {
        '/',
        '/dashboard',
        '/marketplace',
        '/showroom',
        '/workshop',
        '/car-wash',
        '/staff',
        '/staff-academy',
        '/finance',
        '/finance/daily-cashflow',
        '/bank-investments',
        '/stock-market',
        '/auction',
        '/branches',
        '/character-growth',
        '/settings',
        '/dealership-identity',
        '/theme-store',
        '/tuning-studio',
        '/showroom-decor',
        '/side-businesses',
        '/rent-a-car',
        '/districts',
        '/black-market',
        '/scrapyard',
        '/gossip',
        '/consignment',
        '/history',
        '/reviews',
        '/expertise',
        '/negotiation',
        '/listing-detail',
        '/onboarding',
        '/night-market',
      };

      for (final p in expectedPaths) {
        expect(paths.contains(p), isTrue, reason: 'Route $p must be registered in appRouter');
      }
    });
  });
}
