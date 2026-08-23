import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/mission_model.dart';
import 'package:galeriden/domain/usecases/mission_factory.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';

void main() {
  group('DailyMission Level Scaling & Feature Discovery Tests', () {
    test('Level 1: Generates exactly 3 missions and strictly 0 locked tier missions', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(1);
        expect(missions.length, equals(3));

        for (final m in missions) {
          // Feature route must be unlocked at level 1
          if (m.featureRoute != null) {
            final reqLevel = DealershipModel.getRequiredLevel(m.featureRoute!);
            expect(reqLevel, equals(1), reason: 'Route ${m.featureRoute} should not be generated at level 1');
          }
          // Must not have tier 2+ specific mission types
          expect(
            [
              MissionType.washCars,
              MissionType.repairParts,
              MissionType.tuneCar,
              MissionType.auctionBid,
              MissionType.stockTrade,
              MissionType.rentCar,
              MissionType.blackMarketTrade,
              MissionType.gossipListen,
              MissionType.scrapyardDismantle,
              MissionType.consignmentAccept,
              MissionType.sideBusinessCollect,
            ].contains(m.type),
            isFalse,
            reason: 'Mission type ${m.type} should not appear at Level 1',
          );
        }
      }
    });

    test('Level 2: Always generates a Discovery Mission for Car Wash', () {
      int carWashDiscoveryCount = 0;
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(2);
        expect(missions.length, equals(3));

        final discoveryMissions = missions.where((m) => m.isDiscoveryMission).toList();
        expect(discoveryMissions.length, greaterThanOrEqualTo(1));

        final disc = discoveryMissions.first;
        expect(disc.featureRoute, equals('/car-wash'));
        expect(disc.type, equals(MissionType.washCars));
        carWashDiscoveryCount++;

        // Ensure no level 3+ missions exist
        for (final m in missions) {
          if (m.featureRoute != null) {
            final reqLevel = DealershipModel.getRequiredLevel(m.featureRoute!);
            expect(reqLevel, lessThanOrEqualTo(2));
          }
        }
      }
      expect(carWashDiscoveryCount, equals(50));
    });

    test('Level 3: Generates Discovery Mission for Workshop or Staff', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(3);
        expect(missions.length, equals(3));

        final discovery = missions.firstWhere((m) => m.isDiscoveryMission);
        expect(
          [MissionType.repairParts, MissionType.hireStaff].contains(discovery.type),
          isTrue,
        );
        expect(
          ['/workshop', '/staff'].contains(discovery.featureRoute),
          isTrue,
        );

        // Ensure no level 4+ missions exist
        for (final m in missions) {
          if (m.featureRoute != null) {
            final reqLevel = DealershipModel.getRequiredLevel(m.featureRoute!);
            expect(reqLevel, lessThanOrEqualTo(3));
          }
        }
      }
    });

    test('Level 4: Generates Discovery Mission for Tuning Studio', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(4);
        expect(missions.length, equals(3));

        final discovery = missions.firstWhere((m) => m.isDiscoveryMission);
        expect(discovery.type, equals(MissionType.tuneCar));
        expect(discovery.featureRoute, equals('/tuning-studio'));

        // Ensure no level 5+ missions exist
        for (final m in missions) {
          if (m.featureRoute != null) {
            final reqLevel = DealershipModel.getRequiredLevel(m.featureRoute!);
            expect(reqLevel, lessThanOrEqualTo(4));
          }
        }
      }
    });

    test('Level 5: Generates Discovery Mission for Live Auction or Bank Finance', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(5);
        expect(missions.length, equals(3));

        final discovery = missions.firstWhere((m) => m.isDiscoveryMission);
        expect(
          [MissionType.auctionBid, MissionType.bankInvestment].contains(discovery.type),
          isTrue,
        );
        expect(
          ['/auction', '/finance'].contains(discovery.featureRoute),
          isTrue,
        );
      }
    });

    test('Level 6: Generates Discovery Mission for Stock Market or Casino', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(6);
        expect(missions.length, equals(3));

        final discovery = missions.firstWhere((m) => m.isDiscoveryMission);
        expect(
          [MissionType.stockTrade, MissionType.casinoPlay].contains(discovery.type),
          isTrue,
        );
        expect(
          ['/stock-market', '/casino'].contains(discovery.featureRoute),
          isTrue,
        );
      }
    });

    test('Level 7: Generates Discovery Mission for Rent-a-Car, Black Market or Gossip', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(7);
        expect(missions.length, equals(3));

        final discovery = missions.firstWhere((m) => m.isDiscoveryMission);
        expect(
          [MissionType.rentCar, MissionType.blackMarketTrade, MissionType.gossipListen].contains(discovery.type),
          isTrue,
        );
        expect(
          ['/rent-a-car', '/black-market', '/gossip'].contains(discovery.featureRoute),
          isTrue,
        );
      }
    });

    test('Level 8: Generates Discovery Mission for Scrapyard, Consignment or Side Businesses', () {
      for (int i = 0; i < 50; i++) {
        final missions = MissionFactory.generateDailyMissions(8);
        expect(missions.length, equals(3));

        final discovery = missions.firstWhere((m) => m.isDiscoveryMission);
        expect(
          [MissionType.scrapyardDismantle, MissionType.consignmentAccept, MissionType.sideBusinessCollect].contains(discovery.type),
          isTrue,
        );
        expect(
          ['/scrapyard', '/consignment', '/side-businesses'].contains(discovery.featureRoute),
          isTrue,
        );
      }
    });

    test('Target and Reward Scaling: Level 8 missions give strictly higher rewards than Level 1', () {
      final lvl1Missions = MissionFactory.generateDailyMissions(1);
      final lvl8Missions = MissionFactory.generateDailyMissions(8);

      final avgRewardLvl1 = lvl1Missions.map((m) => m.rewardMoney).reduce((a, b) => a + b) / 3;
      final avgRewardLvl8 = lvl8Missions.map((m) => m.rewardMoney).reduce((a, b) => a + b) / 3;

      expect(avgRewardLvl8, greaterThan(avgRewardLvl1));

      final avgXpLvl1 = lvl1Missions.map((m) => m.rewardXP).reduce((a, b) => a + b) / 3;
      final avgXpLvl8 = lvl8Missions.map((m) => m.rewardXP).reduce((a, b) => a + b) / 3;

      expect(avgXpLvl8, greaterThan(avgXpLvl1));
    });

    test('MissionModel JSON serialization roundtrip retains all properties', () {
      final original = MissionModel(
        id: 'test_mission_100',
        title: 'Örnek Başlık',
        description: 'Örnek Açıklama',
        titleKey: 'mission_wash_title',
        descriptionKey: 'mission_wash_desc',
        templateParams: {'count': 2},
        type: MissionType.washCars,
        currentProgress: 1,
        targetGoal: 2,
        rewardMoney: 8500,
        rewardXP: 14,
        isCompleted: false,
        isClaimed: false,
        featureRoute: '/car-wash',
        isDiscoveryMission: true,
      );

      final json = original.toJson();
      final deserialized = MissionModel.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.title, equals(original.title));
      expect(deserialized.description, equals(original.description));
      expect(deserialized.titleKey, equals(original.titleKey));
      expect(deserialized.descriptionKey, equals(original.descriptionKey));
      expect(deserialized.templateParams?['count'], equals(2));
      expect(deserialized.type, equals(MissionType.washCars));
      expect(deserialized.currentProgress, equals(1));
      expect(deserialized.targetGoal, equals(2));
      expect(deserialized.rewardMoney, equals(8500));
      expect(deserialized.rewardXP, equals(14));
      expect(deserialized.featureRoute, equals('/car-wash'));
      expect(deserialized.isDiscoveryMission, isTrue);
    });

    test('7-Language Parity & Invariants: Zero emojis, Zero parentheses across all translations', () {
      final translationMaps = <String, Map<String, String>>{
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      final missionKeys = [
        'mission_discovery_badge',
        'mission_tap_to_open',
        'mission_buy_title',
        'mission_buy_desc',
        'mission_sell_title',
        'mission_sell_desc',
        'mission_expertise_title',
        'mission_expertise_desc',
        'mission_sms_title',
        'mission_sms_desc',
        'mission_profit_title',
        'mission_profit_desc',
        'mission_night_market_title',
        'mission_night_market_desc',
        'mission_wash_title',
        'mission_wash_desc',
        'mission_repair_title',
        'mission_repair_desc',
        'mission_staff_title',
        'mission_staff_desc',
        'mission_tune_title',
        'mission_tune_desc',
        'mission_auction_title',
        'mission_auction_desc',
        'mission_bank_title',
        'mission_bank_desc',
        'mission_stock_title',
        'mission_stock_desc',
        'mission_casino_title',
        'mission_casino_desc',
        'mission_rent_title',
        'mission_rent_desc',
        'mission_black_market_title',
        'mission_black_market_desc',
        'mission_gossip_title',
        'mission_gossip_desc',
        'mission_scrapyard_title',
        'mission_scrapyard_desc',
        'mission_consignment_title',
        'mission_consignment_desc',
        'mission_side_biz_title',
        'mission_side_biz_desc',
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F5FF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );

      for (final entry in translationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;

        for (final key in missionKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Language $lang missing translation key $key');
          final value = map[key]!;
          expect(value.isNotEmpty, isTrue, reason: 'Translation for $key in $lang is empty');

          // Invariant 1: Zero Unicode Emojis
          expect(emojiRegex.hasMatch(value), isFalse, reason: 'Emoji found in $lang for $key: $value');

          // Invariant 2: Zero Parentheses
          expect(value.contains('('), isFalse, reason: 'Opening parenthesis found in $lang for $key: $value');
          expect(value.contains(')'), isFalse, reason: 'Closing parenthesis found in $lang for $key: $value');
        }
      }
    });
  });
}
