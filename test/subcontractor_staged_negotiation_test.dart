import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/domain/usecases/construction_timeline_engine.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/domain/usecases/subcontractor_negotiation_expansion.dart';

void main() {
  group('Subcontractor Staged Dynamic Negotiation Suite', () {
    test('1. SubcontractorNegotiationExpansion: Exactly 6 tracks with 3 progressive stages each', () {
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

      // Track lookup
      expect(SubcontractorNegotiationExpansion.getTrack('discount'), isNotNull);
      expect(SubcontractorNegotiationExpansion.getTrack('non_existent'), isNull);
    });

    test('2. Progressive track advancement and exhaustion simulation', () {
      final tracks = SubcontractorNegotiationExpansion.tacticTracks;
      final trackStageIndices = <String, int>{
        for (final t in tracks) t.id: 0,
      };

      // Initially, no track is exhausted
      bool areAllExhausted() => tracks.every((t) => (trackStageIndices[t.id] ?? 0) >= t.maxStages);
      List<SubcontractorTacticTrackDef> getAvailableTracks() =>
          tracks.where((t) => (trackStageIndices[t.id] ?? 0) < t.maxStages).toList();

      expect(areAllExhausted(), isFalse);
      expect(getAvailableTracks().length, equals(6));

      // Simulate advancing track 'discount' through all 3 stages
      expect(trackStageIndices['discount'], equals(0));
      trackStageIndices['discount'] = trackStageIndices['discount']! + 1; // stage 1
      expect(trackStageIndices['discount'], equals(1));
      trackStageIndices['discount'] = trackStageIndices['discount']! + 1; // stage 2
      expect(trackStageIndices['discount'], equals(2));
      trackStageIndices['discount'] = trackStageIndices['discount']! + 1; // stage 3 (exhausted)
      expect(trackStageIndices['discount'], equals(3));

      // Now discount track is no longer in available list
      expect(getAvailableTracks().any((t) => t.id == 'discount'), isFalse);
      expect(getAvailableTracks().length, equals(5));
      expect(areAllExhausted(), isFalse);

      // Advance remaining tracks to exhaustion
      for (final t in tracks) {
        trackStageIndices[t.id] = t.maxStages;
      }

      expect(getAvailableTracks(), isEmpty);
      expect(areAllExhausted(), isTrue);
    });

    test('3. Trade dialogue generator produces valid dialogue keys across all stages and tiers', () {
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

              // Check all supported languages localize this dialogue key without parentheses or emojis
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

    test('4. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all 37 subcontractor keys in 7 languages', () {
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

          // Zero parentheses invariant
          expect(value.contains('('), isFalse,
              reason: 'Key $key in $code must not contain open parenthesis: $value');
          expect(value.contains(')'), isFalse,
              reason: 'Key $key in $code must not contain close parenthesis: $value');

          // Zero emoji invariant
          expect(emojiRegex.hasMatch(value), isFalse,
              reason: 'Key $key in $code must not contain unicode emojis: $value');
        }
      }
    });
  });
}
