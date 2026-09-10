import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Construction Speedup & Time Control Suite', () {
    test('1. ConstructionTimelineEngine.calculateLogicalDaysToReduce calculates rational reduction', () {
      expect(ConstructionTimelineEngine.calculateLogicalDaysToReduce(stageDays: 0), equals(3));
      expect(ConstructionTimelineEngine.calculateLogicalDaysToReduce(stageDays: 5), equals(3)); // max(3, (5/3).round() = 2) -> 3
      expect(ConstructionTimelineEngine.calculateLogicalDaysToReduce(stageDays: 10), equals(3)); // max(3, 3) -> 3
      expect(ConstructionTimelineEngine.calculateLogicalDaysToReduce(stageDays: 15), equals(5)); // max(3, 5) -> 5
      expect(ConstructionTimelineEngine.calculateLogicalDaysToReduce(stageDays: 21), equals(7)); // max(3, 7) -> 7
    });

    test('2. 7-Language translation symmetry and invariant rules check', () {
      final requiredKeys = [
        'construction_speedup_btn',
        'construction_speedup_reward_title',
        'construction_speedup_toast',
        'construction_time_equivalence_hint',
        'construction_weather_hold_badge',
        'real_estate_minutes_suffix',
        'hud_time_control_title',
        'hud_time_control_desc',
        'hud_time_fast_forward_btn',
        'hud_time_fast_forward_toast',
        'hud_time_view_history_btn',
      ];

      final allTranslations = {
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      for (final entry in allTranslations.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in requiredKeys) {
          expect(map.containsKey(key), isTrue, reason: '$lang is missing key $key');
          final value = map[key]!;
          expect(value.isNotEmpty, isTrue, reason: '$lang has empty value for $key');
          expect(value.contains('(') || value.contains(')'), isFalse,
              reason: '$lang key $key contains forbidden parentheses: $value');
        }
      }
    });

    test('3. accelerateConstructionTimer reduces remaining days and finishes stage properly', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final testLand = RealEstateModel(
        id: 'speedup_land_1',
        title: 'Beykoz Projesi',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Beykoz',
        squareMeters: 800,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 6000000,
        currentPurchasePrice: 6000000,
        constructionMode: 'selfBuild',
        constructionStage: 2,
        stageTotalDays: 12,
        constructionDaysRemaining: 10,
        isConstructionWorking: true,
      );

      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        ownedRealEstates: [testLand],
      );

      final notifier = container.read(gameProvider.notifier);
      final ok = notifier.accelerateConstructionTimer('speedup_land_1', daysToReduce: 4);
      expect(ok, isTrue);

      final updatedLand = container.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == 'speedup_land_1');
      expect(updatedLand.constructionDaysRemaining, equals(6));
      expect(updatedLand.isConstructionWorking, isTrue);

      // Accelerate remaining days to 0
      final ok2 = notifier.accelerateConstructionTimer('speedup_land_1', daysToReduce: 6);
      expect(ok2, isTrue);

      final finishedLand = container.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == 'speedup_land_1');
      expect(finishedLand.constructionDaysRemaining, equals(0));
      expect(finishedLand.isConstructionWorking, isFalse);

      // Complete self build stage after reach 0
      final completed = notifier.completeSelfBuildStage('speedup_land_1');
      expect(completed, isTrue);

      final nextStageLand = container.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == 'speedup_land_1');
      expect(nextStageLand.constructionStage, equals(3));
    });

    test('4. fastForwardGameDay advances calendar day safely', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final initialDay = container.read(gameProvider).currentDay;
      final ok = container.read(gameProvider.notifier).fastForwardGameDay(days: 1);
      expect(ok, isTrue);
      expect(container.read(gameProvider).currentDay, equals(initialDay + 1));
    });

    test('5. accelerateConstructionTimer resolves Stage 1 drafting and municipal permit instantly', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final landPreconDrafting = RealEstateModel(
        id: 'precon_land_1',
        title: 'Sarıyer Arsa',
        category: RealEstateCategory.land,
        city: 'İstanbul',
        district: 'Sarıyer',
        squareMeters: 1000,
        roomCount: '-',
        buildingAge: 0,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 10000000,
        currentPurchasePrice: 10000000,
        constructionMode: 'selfBuild',
        constructionStage: 1,
        isConstructionWorking: true,
        constructionDaysRemaining: 1,
        isArchitecturalApproved: false,
        hasBuildingPermit: false,
        preConstructionStep: 'drafting',
      );

      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        ownedRealEstates: [landPreconDrafting],
      );

      final notifier = container.read(gameProvider.notifier);

      // Accelerate drafting
      final okDrafting = notifier.accelerateConstructionTimer('precon_land_1');
      expect(okDrafting, isTrue);

      final landAfterDrafting = container.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == 'precon_land_1');
      expect(landAfterDrafting.isArchitecturalApproved, isTrue);
      expect(landAfterDrafting.preConstructionStep, equals('draftingCompleted'));
      expect(landAfterDrafting.isConstructionWorking, isFalse);

      // Now set permit in progress
      container.read(gameProvider.notifier).state = container.read(gameProvider).copyWith(
        ownedRealEstates: [
          landAfterDrafting.copyWith(
            preConstructionStep: 'municipalReview',
            isConstructionWorking: true,
            constructionDaysRemaining: 1,
          ),
        ],
      );

      // Accelerate municipal permit
      final okPermit = notifier.accelerateConstructionTimer('precon_land_1');
      expect(okPermit, isTrue);

      final landAfterPermit = container.read(gameProvider).ownedRealEstates.firstWhere((r) => r.id == 'precon_land_1');
      expect(landAfterPermit.hasBuildingPermit, isTrue);
      expect(landAfterPermit.constructionStage, equals(2));
      expect(landAfterPermit.preConstructionStep, equals('permitApproved'));
      expect(landAfterPermit.isConstructionWorking, isFalse);
    });
  });
}
