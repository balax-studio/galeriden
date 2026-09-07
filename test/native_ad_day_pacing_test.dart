import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
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

    test('All NeoBrutalNativeAdCard sponsor snippet translation keys exist across 7 languages', () {
      final allTranslations = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final allRequiredKeys = <String>[
        'ad_native_local_bulletin',
        'ad_native_detail_title',
        'ad_native_detail_desc',
        'ad_native_sponsor_tag',
        'ad_native_cta',
        'ad_native_card_toast',
        'ad_native_towing_title',
        'ad_native_towing_desc',
        'ad_native_towing_tag',
        'ad_native_towing_cta',
        'ad_native_towing_toast',
        'ad_native_engine_title',
        'ad_native_engine_desc',
        'ad_native_engine_tag',
        'ad_native_engine_cta',
        'ad_native_engine_toast',
        'ad_native_parts_title',
        'ad_native_parts_desc',
        'ad_native_parts_tag',
        'ad_native_parts_cta',
        'ad_native_parts_toast',
        'ad_native_customs_title',
        'ad_native_customs_desc',
        'ad_native_customs_tag',
        'ad_native_customs_cta',
        'ad_native_customs_toast',
        'ad_native_stock_title',
        'ad_native_stock_desc',
        'ad_native_stock_tag',
        'ad_native_stock_cta',
        'ad_native_stock_toast',
        'ad_native_deed_title',
        'ad_native_deed_desc',
        'ad_native_deed_tag',
        'ad_native_deed_cta',
        'ad_native_deed_toast',
        'ad_native_inspection_title',
        'ad_native_inspection_desc',
        'ad_native_inspection_tag',
        'ad_native_inspection_cta',
        'ad_native_inspection_toast',
        'ad_native_marble_title',
        'ad_native_marble_desc',
        'ad_native_marble_tag',
        'ad_native_marble_cta',
        'ad_native_marble_toast',
        // 13 Extended contexts
        'ad_native_consignment_title',
        'ad_native_consignment_desc',
        'ad_native_consignment_tag',
        'ad_native_consignment_cta',
        'ad_native_consignment_toast',
        'ad_native_branch_title',
        'ad_native_branch_desc',
        'ad_native_branch_tag',
        'ad_native_branch_cta',
        'ad_native_branch_toast',
        'ad_native_album_title',
        'ad_native_album_desc',
        'ad_native_album_tag',
        'ad_native_album_cta',
        'ad_native_album_toast',
        'ad_native_bm_title',
        'ad_native_bm_desc',
        'ad_native_bm_tag',
        'ad_native_bm_cta',
        'ad_native_bm_toast',
        'ad_native_character_title',
        'ad_native_character_desc',
        'ad_native_character_tag',
        'ad_native_character_cta',
        'ad_native_character_toast',
        'ad_native_auction_title',
        'ad_native_auction_desc',
        'ad_native_auction_tag',
        'ad_native_auction_cta',
        'ad_native_auction_toast',
        'ad_native_plate_title',
        'ad_native_plate_desc',
        'ad_native_plate_tag',
        'ad_native_plate_cta',
        'ad_native_plate_toast',
        'ad_native_offer_title',
        'ad_native_offer_desc',
        'ad_native_offer_tag',
        'ad_native_offer_cta',
        'ad_native_offer_toast',
        'ad_native_media_title',
        'ad_native_media_desc',
        'ad_native_media_tag',
        'ad_native_media_cta',
        'ad_native_media_toast',
        'ad_native_academy_title',
        'ad_native_academy_desc',
        'ad_native_academy_tag',
        'ad_native_academy_cta',
        'ad_native_academy_toast',
        'ad_native_decor_title',
        'ad_native_decor_desc',
        'ad_native_decor_tag',
        'ad_native_decor_cta',
        'ad_native_decor_toast',
        'ad_native_bank_title',
        'ad_native_bank_desc',
        'ad_native_bank_tag',
        'ad_native_bank_cta',
        'ad_native_bank_toast',
        'ad_native_district_title',
        'ad_native_district_desc',
        'ad_native_district_tag',
        'ad_native_district_cta',
        'ad_native_district_toast',
      ];

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final map = entry.value;
        for (final key in allRequiredKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Missing key "$key" in $lang translation file');
          final val = map[key]!;
          expect(val.trim().isNotEmpty, isTrue,
              reason: 'Empty translation for key "$key" in $lang');
          expect(val.contains('(') || val.contains(')'), isFalse,
              reason: 'Invariant violation: parentheses in "$key" ($lang): $val');
        }
      }
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
