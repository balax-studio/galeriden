import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/domain/usecases/contractor_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';

void main() {
  group('Contractor Negotiation Expansion Suite', () {
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

    test('4. Invariant Rules: Zero Unicode Emojis & Zero Parentheses across all 7 language translations for contractor expansion', () {
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
  });
}
