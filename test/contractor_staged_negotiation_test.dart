import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/app_localizations.dart';
import 'package:galeriden/domain/usecases/contractor_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';

void main() {
  group('Contractor Staged Negotiation Tests', () {
    test('tacticTracks contains exactly 6 distinct tracks with 3 progressive stages each', () {
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

    test('all 7 supported languages localize all 37 contractor tactic keys without parentheses or emojis', () {
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

    test('Contractor personality response generator produces varied dialogues without parentheses', () {
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

    test('RealEstateChatNegotiationEngine uses personality response for contractor session', () {
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
  });
}
