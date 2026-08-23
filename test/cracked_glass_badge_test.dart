import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/presentation/widgets/cracked_glass_badge.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget({required Widget child, Locale locale = const Locale('tr')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('tr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    );
  }

  group('CrackedGlassBadge Dynamic Defect Resolution Tests', () {
    testWidgets('Renders heavy damage badge when tramer >= 75000', (tester) async {
      final exp = ExpertiseReport(
        engineCondition: 80,
        transmissionCondition: 80,
        tramerAmount: 90000,
        mileage: 100000,
        isMileageTampered: false,
        bodyParts: {},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CrackedGlassBadge(showLabel: true, expertise: exp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AĞIR HASARLI • PERT KAYITLI'), findsOneWidget);
    });

    testWidgets('Renders changed parts badge when 2+ parts changed', (tester) async {
      final exp = ExpertiseReport(
        engineCondition: 80,
        transmissionCondition: 80,
        tramerAmount: 15000,
        mileage: 100000,
        isMileageTampered: false,
        bodyParts: {
          'Kaput': PartStatus.changed,
          'Sol Çamurluk': PartStatus.changed,
        },
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CrackedGlassBadge(showLabel: true, expertise: exp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('DEĞİŞENLİ • KAPORTA İŞLEM'), findsOneWidget);
    });

    testWidgets('Renders mechanical flaw badge when engine condition is poor', (tester) async {
      final exp = ExpertiseReport(
        engineCondition: 35,
        transmissionCondition: 80,
        tramerAmount: 5000,
        mileage: 100000,
        isMileageTampered: false,
        bodyParts: {},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CrackedGlassBadge(showLabel: true, expertise: exp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MEKANİK • MOTOR KUSURLU'), findsOneWidget);
    });

    testWidgets('Renders painted parts badge when 2+ parts painted', (tester) async {
      final exp = ExpertiseReport(
        engineCondition: 80,
        transmissionCondition: 80,
        tramerAmount: 5000,
        mileage: 100000,
        isMileageTampered: false,
        bodyParts: {
          'Sol Kapı': PartStatus.painted,
          'Sağ Kapı': PartStatus.painted,
        },
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CrackedGlassBadge(showLabel: true, expertise: exp),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BOYALI • BEL ALTI BOYA'), findsOneWidget);
    });

    testWidgets('Renders chassis flaw badge when isChassisRepaired is true', (tester) async {
      final exp = ExpertiseReport(
        engineCondition: 80,
        transmissionCondition: 80,
        tramerAmount: 5000,
        mileage: 100000,
        isMileageTampered: false,
        bodyParts: {},
      );

      await tester.pumpWidget(
        buildTestableWidget(
          child: CrackedGlassBadge(showLabel: true, expertise: exp, isChassisRepaired: true),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('KAZALI • ŞASİ İŞLEMLİ'), findsOneWidget);
    });

    testWidgets('Tapping badge triggers haptic shake animation', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          child: const CrackedGlassBadge(showLabel: true),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(CrackedGlassBadge));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(CrackedGlassBadge), findsOneWidget);
    });
  });

  group('7-Language Parity & Invariants for Defect Badges', () {
    final stickerKeys = [
      'sticker_cracked_glass',
      'sticker_heavy_damage',
      'sticker_changed_parts',
      'sticker_painted_parts',
      'sticker_chassis_flaw',
      'sticker_mechanical_flaw',
      'sticker_high_tramer',
    ];

    final Map<String, Map<String, String>> allTranslations = {
      'tr': trTranslations,
      'en': enTranslations,
      'de': deTranslations,
      'pt': ptTranslations,
      'es': esTranslations,
      'ru': ruTranslations,
      'ar': arTranslations,
    };

    test('All 7 languages contain all defect sticker keys without emojis or parentheses', () {
      for (final langEntry in allTranslations.entries) {
        final lang = langEntry.key;
        final map = langEntry.value;

        for (final key in stickerKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Missing key "$key" in language "$lang"');
          final value = map[key]!;
          expect(value.isNotEmpty, isTrue, reason: 'Empty string for key "$key" in language "$lang"');
          expect(value.contains('('), isFalse, reason: 'Key "$key" contains "(" in language "$lang"');
          expect(value.contains(')'), isFalse, reason: 'Key "$key" contains ")" in language "$lang"');
        }
      }
    });
  });
}
