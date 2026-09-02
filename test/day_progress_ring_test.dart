import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/presentation/providers/game/game_time_mixin.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/radial_day_progress_widget.dart';
import 'package:galeriden/presentation/widgets/game_hud_widget.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Day Duration & Bottom Gauge Progress Pill Tests', () {
    test('In-game day duration constant is exactly 2 minutes (120 seconds)', () {
      expect(GameTimeMixin.inGameDayDurationSeconds, equals(120));
    });

    test('7-Language localization includes all day phase keys', () {
      final requiredKeys = [
        'hud_day_phase_morning',
        'hud_day_phase_noon',
        'hud_day_phase_evening',
        'hud_day_phase_night',
        'hud_day_progress_tooltip',
      ];

      final maps = [
        ('TR', trTranslations),
        ('EN', enTranslations),
        ('DE', deTranslations),
        ('PT', ptTranslations),
        ('ES', esTranslations),
        ('RU', ruTranslations),
        ('AR', arTranslations),
      ];

      for (final (lang, map) in maps) {
        for (final key in requiredKeys) {
          expect(map.containsKey(key), isTrue,
              reason: '$lang translations missing $key');
          expect(map[key]!.isNotEmpty, isTrue,
              reason: '$lang translations has empty $key');
        }
      }
    });

    testWidgets('DayProgressHudPill mounts cleanly and updates smoothly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: DayProgressHudPill(
                currentDay: 1,
                isDark: true,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(DayProgressHudPill), findsOneWidget);

      // Advance morning phase (15s)
      await tester.pump(const Duration(seconds: 15));
      expect(find.byType(DayProgressHudPill), findsOneWidget);

      // Advance to noon (45s)
      await tester.pump(const Duration(seconds: 30));
      expect(find.byType(DayProgressHudPill), findsOneWidget);

      // Advance to evening (85s)
      await tester.pump(const Duration(seconds: 40));
      expect(find.byType(DayProgressHudPill), findsOneWidget);

      // Advance to night (110s)
      await tester.pump(const Duration(seconds: 25));
      expect(find.byType(DayProgressHudPill), findsOneWidget);
    });

    testWidgets('DayProgressHudPill responds to day rollover',
        (tester) async {
      int currentDay = 1;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    DayProgressHudPill(
                      currentDay: currentDay,
                      isDark: false,
                      onTap: () {},
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentDay++;
                        });
                      },
                      child: const Text('Next Day'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.byType(DayProgressHudPill), findsOneWidget);

      // Trigger day change
      await tester.tap(find.text('Next Day'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 160));
      await tester.pump(const Duration(milliseconds: 160));

      expect(currentDay, equals(2));
    });

    testWidgets('GameHudHeaderWidget mounts with DayProgressHudPill',
        (tester) async {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: GameHudHeaderWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(GameHudHeaderWidget), findsOneWidget);
      expect(find.byType(DayProgressHudPill), findsOneWidget);
    });
  });
}
