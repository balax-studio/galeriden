import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/contractor_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/domain/usecases/subcontractor_negotiation_expansion.dart';

void main() {
  group('Contractor Negotiation & Staged Negotiation Suite', () {
    test('1. Contractor Profiles catalog contains 5 distinct contractors with realistic starting shares', () {
      final contractors = ContractorNegotiationExpansion.contractors;
      expect(contractors.length, 5);

      final haci = ContractorNegotiationExpansion.getContractor('contractor_haci_resat');
      expect(haci.initialOfferPercent, 33);
      expect(haci.personality, ContractorPersonality.traditional);
      expect(haci.basePatience, 110);
      expect(haci.reputationScore, 4.8);

      final kartal = ContractorNegotiationExpansion.getContractor('contractor_kartal_hizli');
      expect(kartal.initialOfferPercent, 36);
      expect(kartal.personality, ContractorPersonality.aggressive);
      expect(kartal.maxCapPercent, 52);

      final anadolu = ContractorNegotiationExpansion.getContractor('contractor_anadolu_kardesler');
      expect(anadolu.initialOfferPercent, 38);
      expect(anadolu.personality, ContractorPersonality.cooperative);

      final bogazici = ContractorNegotiationExpansion.getContractor('contractor_bogazici_elit');
      expect(bogazici.initialOfferPercent, 40);
      expect(bogazici.personality, ContractorPersonality.luxury);

      final metropol = ContractorNegotiationExpansion.getContractor('contractor_metropol_mimarlik');
      expect(metropol.initialOfferPercent, 42);
      expect(metropol.personality, ContractorPersonality.corporate);
    });

    test('2. Construction jokes pool contains rich cultural anecdotes and returns valid keys', () {
      final jokes = ContractorNegotiationExpansion.constructionJokes;
      expect(jokes.length, greaterThanOrEqualTo(9));
      expect(jokes.contains('contractor_joke_inspector_tea'), isTrue);
      expect(jokes.contains('contractor_joke_inverted_blueprint'), isTrue);
      expect(jokes.contains('contractor_joke_cat_crane'), isTrue);

      final randomJoke = ContractorNegotiationExpansion.getRandomJokeKey(Random(42));
      expect(jokes.contains(randomJoke), isTrue);
    });

    test('3. Dynamic opening dialogue matches contractor personality and share percentage', () {
      final haci = ContractorNegotiationExpansion.getContractor('contractor_haci_resat');
      final sessionHaci = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_haci',
        totalUnits: 30,
        baseMarketValue: 10000000.0,
        profile: haci,
      );
      expect(sessionHaci.currentSharePercent, 33);
      expect(sessionHaci.messages.first.message.contains('%33'), isTrue);
      expect(sessionHaci.messages.first.message.contains('Selamünaleyküm'), isTrue);

      final metropol = ContractorNegotiationExpansion.getContractor('contractor_metropol_mimarlik');
      final sessionMetropol = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_metropol',
        totalUnits: 30,
        baseMarketValue: 10000000.0,
        profile: metropol,
      );
      expect(sessionMetropol.currentSharePercent, 42);
      expect(sessionMetropol.messages.first.message.contains('%42'), isTrue);
      expect(sessionMetropol.messages.first.message.contains('kurumsal taahhüt'), isTrue);
    });

    test('4. tacticTracks contains exactly 6 distinct tracks with 3 progressive stages each', () {
      final tracks = ContractorNegotiationExpansion.tacticTracks;
      expect(tracks.length, 6);

      final expectedTrackIds = ['share', 'primeFloors', 'quality', 'advance', 'guarantee', 'tea'];
      expect(tracks.map((t) => t.id).toList(), expectedTrackIds);

      for (final track in tracks) {
        expect(track.stages.length, 3, reason: 'Track ${track.id} must have 3 progressive stages');
        for (int i = 0; i < track.stages.length; i++) {
          final stage = track.stages[i];
          expect(stage.labelKey.isNotEmpty, isTrue);
          expect(stage.messageKey.isNotEmpty, isTrue);
          expect(stage.labelKey.endsWith('_$i'), isTrue,
              reason: 'Stage $i labelKey ${stage.labelKey} should end with _$i');
          expect(stage.messageKey.endsWith('_$i'), isTrue,
              reason: 'Stage $i messageKey ${stage.messageKey} should end with _$i');
        }
      }
    });

    test('5. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all 7 language translations for contractor expansion', () {
      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]|[\u{1F600}-\u{1F64F}]|[\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      final targetKeys = [
        'contractor_switch_header',
        'contractor_patience_ratio',
        'contractor_reputation_label',
        'contractor_profile_haci_resat_name',
        'contractor_profile_haci_resat_type',
        'contractor_profile_kartal_name',
        'contractor_profile_kartal_type',
        'contractor_profile_anadolu_name',
        'contractor_profile_anadolu_type',
        'contractor_profile_bogazici_name',
        'contractor_profile_bogazici_type',
        'contractor_profile_metropol_name',
        'contractor_profile_metropol_type',
        'contractor_tactic_bank_guarantee_label',
        'contractor_tactic_bank_guarantee_msg',
        'contractor_tactic_tea_joke_label',
        'contractor_tactic_tea_joke_msg',
      ];

      final maps = [
        {'lang': 'tr', 'map': trTranslations},
        {'lang': 'en', 'map': enTranslations},
        {'lang': 'de', 'map': deTranslations},
        {'lang': 'es', 'map': esTranslations},
        {'lang': 'pt', 'map': ptTranslations},
        {'lang': 'ru', 'map': ruTranslations},
        {'lang': 'ar', 'map': arTranslations},
      ];

      for (final item in maps) {
        final lang = item['lang'] as String;
        final map = item['map'] as Map<String, String>;

        for (final key in targetKeys) {
          expect(map.containsKey(key), isTrue,
              reason: 'Missing key: $key in $lang translations');
          final val = map[key]!;
          expect(emojiRegex.hasMatch(val), isFalse,
              reason: 'Found emoji in $lang for $key: $val');
          expect(val.contains('(') || val.contains(')'), isFalse,
              reason: 'Found parentheses in $lang for $key: $val');
        }
      }
    });

    test('6. all 7 supported languages localize all 37 contractor tactic keys without parentheses or emojis', () {
      final supportedCodes = AppLocalizations.supportedLanguageCodes;
      expect(supportedCodes, containsAll(['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar']));

      final tracks = ContractorNegotiationExpansion.tacticTracks;
      final requiredKeys = <String>[];

      for (final track in tracks) {
        for (final stage in track.stages) {
          requiredKeys.add(stage.labelKey);
          requiredKeys.add(stage.messageKey);
        }
      }
      requiredKeys.add('contractor_tactics_exhausted_notice');
      expect(requiredKeys.length, 37);

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
        unicode: true,
      );

      for (final code in supportedCodes) {
        final translations = AppLocalizations.getAllKeysFor(code);
        for (final key in requiredKeys) {
          final value = translations[key];
          expect(value, isNotNull, reason: 'Missing key $key in language $code');
          expect(value!.isNotEmpty, isTrue, reason: 'Empty value for key $key in language $code');

          expect(value.contains('('), isFalse,
              reason: 'Key $key in $code must not contain open parenthesis: $value');
          expect(value.contains(')'), isFalse,
              reason: 'Key $key in $code must not contain close parenthesis: $value');

          expect(emojiRegex.hasMatch(value), isFalse,
              reason: 'Key $key in $code must not contain unicode emojis: $value');
        }
      }
    });

    test('7. Contractor personality response generator produces varied dialogues without parentheses', () {
      final random = Random(42);
      for (final personality in ContractorPersonality.values) {
        for (final isAccepted in [true, false]) {
          final reply = ContractorNegotiationExpansion.getShareResponse(
            personality: personality,
            isAccepted: isAccepted,
            nextShare: 45,
            random: random,
          );
          expect(reply.isNotEmpty, isTrue);
          expect(reply.contains('('), isFalse,
              reason: 'Personality $personality reply must not contain parentheses');
          expect(reply.contains(')'), isFalse,
              reason: 'Personality $personality reply must not contain parentheses');
        }
      }
    });

    test('8. RealEstateChatNegotiationEngine uses personality response for contractor session', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_haci_resat');
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_test',
        totalUnits: 20,
        baseMarketValue: 5000000.0,
        profile: profile,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.demandHigherShare,
        playerMessageText: 'Mevcut arsa rayici karsisinda %33 yetersiz kaliyor.',
        random: Random(100),
      );

      expect(next.messages.length, 3);
      final reply = next.messages.last.message;
      expect(reply.isNotEmpty, isTrue);
      expect(reply.contains('('), isFalse);
      expect(reply.contains(')'), isFalse);
    });

    test('9. SubcontractorNegotiationExpansion: Exactly 6 tracks with 3 progressive stages each', () {
      final tracks = SubcontractorNegotiationExpansion.tacticTracks;
      expect(tracks.length, equals(6));

      final expectedTrackIds = [
        'discount',
        'doubleShift',
        'cashMaterials',
        'penaltyClause',
        'guarantee',
        'tea',
      ];
      expect(tracks.map((t) => t.id).toList(), equals(expectedTrackIds));

      for (final track in tracks) {
        expect(track.stages.length, equals(3), reason: 'Track ${track.id} must have 3 progressive stages');
        for (int i = 0; i < track.stages.length; i++) {
          final stage = track.stages[i];
          expect(stage.labelKey.isNotEmpty, isTrue);
          expect(stage.messageKey.isNotEmpty, isTrue);
          expect(stage.labelKey.endsWith('_$i'), isTrue,
              reason: 'Stage $i labelKey ${stage.labelKey} should end with _$i');
          expect(stage.messageKey.endsWith('_$i'), isTrue,
              reason: 'Stage $i messageKey ${stage.messageKey} should end with _$i');
        }
      }

      expect(SubcontractorNegotiationExpansion.getTrack('discount'), isNotNull);
      expect(SubcontractorNegotiationExpansion.getTrack('non_existent'), isNull);
    });

    test('10. Progressive subcontractor track advancement and exhaustion simulation', () {
      final tracks = SubcontractorNegotiationExpansion.tacticTracks;
      final trackStageIndices = <String, int>{
        for (final t in tracks) t.id: 0,
      };

      bool areAllExhausted() => tracks.every((t) => (trackStageIndices[t.id] ?? 0) >= t.maxStages);
      List<SubcontractorTacticTrackDef> getAvailableTracks() =>
          tracks.where((t) => (trackStageIndices[t.id] ?? 0) < t.maxStages).toList();

      expect(areAllExhausted(), isFalse);
      expect(getAvailableTracks().length, equals(6));

      expect(trackStageIndices['discount'], equals(0));
      trackStageIndices['discount'] = trackStageIndices['discount']! + 1;
      expect(trackStageIndices['discount'], equals(1));
      trackStageIndices['discount'] = trackStageIndices['discount']! + 1;
      expect(trackStageIndices['discount'], equals(2));
      trackStageIndices['discount'] = trackStageIndices['discount']! + 1;
      expect(trackStageIndices['discount'], equals(3));

      expect(getAvailableTracks().any((t) => t.id == 'discount'), isFalse);
      expect(getAvailableTracks().length, equals(5));
      expect(areAllExhausted(), isFalse);

      for (final t in tracks) {
        trackStageIndices[t.id] = t.maxStages;
      }

      expect(getAvailableTracks(), isEmpty);
      expect(areAllExhausted(), isTrue);
    });

    test('11. Subcontractor trade dialogue generator produces valid dialogue keys across all stages and tiers', () {
      final random = Random(42);
      final tactics = [
        ChatTacticType.counterPrice,
        ChatTacticType.demandDoubleShift,
        ChatTacticType.demandCashMaterials,
        ChatTacticType.demandPenaltyClause,
        ChatTacticType.demandPrimeFloors,
        ChatTacticType.askJokeOrChat,
      ];

      final supportedCodes = AppLocalizations.supportedLanguageCodes;
      final turkishTranslations = AppLocalizations.getAllKeysFor('tr');

      for (int stage = 2; stage <= 8; stage++) {
        for (final tier in SubcontractorTier.values) {
          for (final tactic in tactics) {
            for (final isSuccess in [true, false]) {
              final dialogueKey = SubcontractorNegotiationExpansion.getTradeDialogue(
                stageNumber: stage,
                tier: tier,
                tactic: tactic,
                isSuccess: isSuccess,
                random: random,
              );

              expect(dialogueKey.isNotEmpty, isTrue);
              expect(turkishTranslations.containsKey(dialogueKey), isTrue,
                  reason: 'Dialogue key $dialogueKey not found in Turkish translations');

              for (final code in supportedCodes) {
                final translations = AppLocalizations.getAllKeysFor(code);
                final text = translations[dialogueKey];
                expect(text, isNotNull,
                    reason: 'Missing trade dialogue $dialogueKey in language $code');
                expect(text!.contains('('), isFalse,
                    reason: 'Trade dialogue $dialogueKey in $code must not have parentheses');
                expect(text.contains(')'), isFalse,
                    reason: 'Trade dialogue $dialogueKey in $code must not have parentheses');
              }
            }
          }
        }
      }
    });

    test('12. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all 37 subcontractor keys in 7 languages', () {
      final supportedCodes = AppLocalizations.supportedLanguageCodes;
      expect(supportedCodes, containsAll(['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar']));

      final tracks = SubcontractorNegotiationExpansion.tacticTracks;
      final requiredKeys = <String>[];

      for (final track in tracks) {
        for (final stage in track.stages) {
          requiredKeys.add(stage.labelKey);
          requiredKeys.add(stage.messageKey);
        }
      }
      requiredKeys.add('subcontractor_tactics_exhausted_banner');
      expect(requiredKeys.length, equals(37));

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F1E6}-\u{1F1FF}]',
        unicode: true,
      );

      for (final code in supportedCodes) {
        final translations = AppLocalizations.getAllKeysFor(code);
        for (final key in requiredKeys) {
          final value = translations[key];
          expect(value, isNotNull, reason: 'Missing key $key in language $code');
          expect(value!.isNotEmpty, isTrue, reason: 'Empty value for key $key in language $code');

          expect(value.contains('('), isFalse,
              reason: 'Key $key in $code must not contain open parenthesis: $value');
          expect(value.contains(')'), isFalse,
              reason: 'Key $key in $code must not contain close parenthesis: $value');

          expect(emojiRegex.hasMatch(value), isFalse,
              reason: 'Key $key in $code must not contain unicode emojis: $value');
        }
      }
    });
  });
}
