import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/domain/usecases/real_estate_buyer_negotiation_expansion.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';

void main() {
  group('Real Estate Buyer Negotiation Expansion Suite', () {
    test('1. Detects all 6 buyer archetypes accurately from name and property category', () {
      final fund = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Bora Soydan • Yatırım Fonu Direktörü',
        RealEstateCategory.building,
      );
      expect(fund.id, BuyerArchetypeId.fundDirector);

      final ind = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Teoman Bey • Sanayici',
        RealEstateCategory.tourismFacility,
      );
      expect(ind.id, BuyerArchetypeId.industrialist);

      final family = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Dr. Selin & Aile',
        RealEstateCategory.housing,
      );
      expect(family.id, BuyerArchetypeId.familyBuyer);

      final merchant = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Hacı Esnaf Osman Ticaret',
        RealEstateCategory.commercial,
      );
      expect(merchant.id, BuyerArchetypeId.merchantTrader);

      final expat = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Kerem Bey • Gurbetçi Yatırımcı',
        RealEstateCategory.timeshare,
      );
      expect(expat.id, BuyerArchetypeId.expatInvestor);

      final opportunist = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        'Mert Kaya Tok Alıcı',
        RealEstateCategory.land,
      );
      expect(opportunist.id, BuyerArchetypeId.opportunist);
    });

    test('2. Dynamic tactic progression cycles correctly through steps', () {
      final step0 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        0,
      );
      final step1 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        1,
      );
      final step2 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        2,
      );
      final step3 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.counterPrice,
        3,
      );

      expect(step0.labelKey, 'buyer_tactic_counter_label_0');
      expect(step1.labelKey, 'buyer_tactic_counter_label_1');
      expect(step2.labelKey, 'buyer_tactic_counter_label_2');
      // Wraps back to step 0
      expect(step3.labelKey, 'buyer_tactic_counter_label_0');

      final deed0 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.transferDeedCosts,
        0,
      );
      final deed1 = RealEstateBuyerNegotiationExpansion.getTacticStep(
        ChatTacticType.transferDeedCosts,
        1,
      );
      expect(deed0.labelKey, 'buyer_tactic_deed_cost_label_0');
      expect(deed1.labelKey, 'buyer_tactic_deed_cost_label_1');
    });

    test('3. Buyer evaluation outputs formatted prices without raw integers', () {
      final state = ChatNegotiationState(
        targetId: 'prop_test',
        counterpartyName: 'Bora Soydan',
        counterpartyRole: ChatSenderRole.buyer,
        currentPrice: 5000000.0,
        patience: 100,
        satisfaction: 50,
      );

      final archetype = RealEstateBuyerNegotiationExpansion.detectBuyerArchetype(
        state.counterpartyName,
        RealEstateCategory.housing,
      );

      final result = RealEstateBuyerNegotiationExpansion.evaluateBuyerTactic(
        state: state,
        tactic: ChatTacticType.counterPrice,
        archetype: archetype,
        random: Random(42),
      );

      expect(result.nextPrice, greaterThanOrEqualTo(5000000.0));
      // Ensure formatted price does not have unformatted raw integer like '₺5155500' without thousand separators
      expect(result.replyText.contains('₺5155500'), isFalse);
      expect(result.patienceDelta, lessThan(0));
    });

    test('4. Full 7-language synchronization for all buyer negotiation keys', () {
      final allLocales = [
        ('tr', trTranslations),
        ('en', enTranslations),
        ('de', deTranslations),
        ('es', esTranslations),
        ('pt', ptTranslations),
        ('ru', ruTranslations),
        ('ar', arTranslations),
      ];

      final requiredKeys = [
        'buyer_tactic_counter_label_0',
        'buyer_tactic_counter_label_1',
        'buyer_tactic_counter_label_2',
        'buyer_tactic_counter_msg_0',
        'buyer_tactic_counter_msg_1',
        'buyer_tactic_counter_msg_2',
        'buyer_tactic_deed_cost_label_0',
        'buyer_tactic_deed_cost_label_1',
        'buyer_tactic_deed_cost_label_2',
        'buyer_tactic_deed_cost_msg_0',
        'buyer_tactic_deed_cost_msg_1',
        'buyer_tactic_deed_cost_msg_2',
        'buyer_tactic_cash_block_label_0',
        'buyer_tactic_cash_block_label_1',
        'buyer_tactic_cash_block_label_2',
        'buyer_tactic_cash_block_msg_0',
        'buyer_tactic_cash_block_msg_1',
        'buyer_tactic_cash_block_msg_2',
        'buyer_tactic_location_label_0',
        'buyer_tactic_location_label_1',
        'buyer_tactic_location_label_2',
        'buyer_tactic_location_msg_0',
        'buyer_tactic_location_msg_1',
        'buyer_tactic_location_msg_2',
        'buyer_tactic_fixture_label_0',
        'buyer_tactic_fixture_label_1',
        'buyer_tactic_fixture_label_2',
        'buyer_tactic_fixture_msg_0',
        'buyer_tactic_fixture_msg_1',
        'buyer_tactic_fixture_msg_2',
        'buyer_tactic_coffee_label',
        'buyer_tactic_coffee_msg',
        'buyer_chat_patience_normal',
        'buyer_chat_patience_tense',
        'buyer_chat_patience_critical',
        'buyer_chat_player_role_tag',
        'buyer_chat_buyer_role_tag',
        'buyer_chat_market_diff_badge',
        'buyer_chat_tactics_title',
        'buyer_chat_agreed_toast',
        'buyer_chat_walkaway_toast',
        'buyer_archetype_fund_title',
        'buyer_archetype_fund_sub',
        'buyer_archetype_industrialist_title',
        'buyer_archetype_industrialist_sub',
        'buyer_archetype_family_title',
        'buyer_archetype_family_sub',
        'buyer_archetype_merchant_title',
        'buyer_archetype_merchant_sub',
        'buyer_archetype_expat_title',
        'buyer_archetype_expat_sub',
        'buyer_archetype_opportunist_title',
        'buyer_archetype_opportunist_sub',
      ];

      for (final (lang, map) in allLocales) {
        for (final key in requiredKeys) {
          expect(
            map.containsKey(key),
            isTrue,
            reason: 'Missing key "$key" in $lang translations',
          );
          expect(
            map[key],
            isNotNull,
            reason: 'Null value for key "$key" in $lang translations',
          );
          expect(
            map[key]!.isNotEmpty,
            isTrue,
            reason: 'Empty string for key "$key" in $lang translations',
          );
        }
      }
    });

    test('5. Strict invariant check: Zero Unicode emojis and zero parentheses in UI strings', () {
      final allLocales = [
        ('tr', trTranslations),
        ('en', enTranslations),
        ('de', deTranslations),
        ('es', esTranslations),
        ('pt', ptTranslations),
        ('ru', ruTranslations),
        ('ar', arTranslations),
      ];

      final emojiRegex = RegExp(
        r'[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F600}-\u{1F64F}\u{1F680}-\u{1F6FF}]',
        unicode: true,
      );

      final buyerKeys = [
        'buyer_tactic_counter_label_0',
        'buyer_tactic_counter_label_1',
        'buyer_tactic_counter_label_2',
        'buyer_tactic_deed_cost_label_0',
        'buyer_tactic_deed_cost_label_1',
        'buyer_tactic_deed_cost_label_2',
        'buyer_tactic_cash_block_label_0',
        'buyer_tactic_cash_block_label_1',
        'buyer_tactic_cash_block_label_2',
        'buyer_tactic_location_label_0',
        'buyer_tactic_location_label_1',
        'buyer_tactic_location_label_2',
        'buyer_tactic_fixture_label_0',
        'buyer_tactic_fixture_label_1',
        'buyer_tactic_fixture_label_2',
        'buyer_tactic_coffee_label',
        'buyer_chat_patience_normal',
        'buyer_chat_patience_tense',
        'buyer_chat_patience_critical',
        'buyer_chat_player_role_tag',
        'buyer_chat_buyer_role_tag',
        'buyer_chat_market_diff_badge',
        'buyer_chat_tactics_title',
        'buyer_chat_agreed_toast',
        'buyer_chat_walkaway_toast',
        'buyer_archetype_fund_title',
        'buyer_archetype_industrialist_title',
        'buyer_archetype_family_title',
        'buyer_archetype_merchant_title',
        'buyer_archetype_expat_title',
        'buyer_archetype_opportunist_title',
      ];

      for (final (lang, map) in allLocales) {
        for (final key in buyerKeys) {
          final value = map[key] ?? '';
          expect(
            emojiRegex.hasMatch(value),
            isFalse,
            reason: 'Emoji found in $lang for key $key: "$value"',
          );
          expect(
            value.contains('(') || value.contains(')'),
            isFalse,
            reason: 'Parenthesis found in $lang for key $key: "$value"',
          );
        }
      }
    });
  });
}
