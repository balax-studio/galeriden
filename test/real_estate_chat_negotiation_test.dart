import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';

void main() {
  group('RealEstateChatNegotiationEngine Tests', () {
    test('createContractorSession initializes with opening contractor message and 100 patience', () {
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_123',
        contractorName: 'Metropol Yapı',
        totalUnits: 12,
        baseMarketValue: 5000000.0,
      );

      expect(session.counterpartyName, 'Metropol Yapı');
      expect(session.counterpartyRole, ChatSenderRole.contractor);
      expect(session.patience, 100);
      expect(session.currentSharePercent, 50);
      expect(session.messages.length, 1);
      expect(session.messages.first.isFromPlayer, isFalse);
      expect(session.messages.first.badgeText, isNotNull);
    });

    test('createBuyerSession initializes with opening buyer offer message', () {
      final session = RealEstateChatNegotiationEngine.createBuyerSession(
        propertyId: 'prop_456',
        buyerName: 'Ahmet Yılmaz',
        offeredPrice: 3800000.0,
        buyerNote: 'Peşin alıcıyım hemen devir yapalım.',
        isRental: false,
      );

      expect(session.counterpartyName, 'Ahmet Yılmaz');
      expect(session.counterpartyRole, ChatSenderRole.buyer);
      expect(session.currentPrice, 3800000.0);
      expect(session.messages.first.message, 'Peşin alıcıyım hemen devir yapalım.');
    });

    test('executeTactic acceptAgreement sets isAgreed to true with mutabakat reply', () {
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_123',
        contractorName: 'Metropol Yapı',
        totalUnits: 12,
        baseMarketValue: 5000000.0,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.acceptAgreement,
        playerMessageText: 'Şartları kabul ediyorum, sözleşmeyi imzalayalım.',
        random: Random(42),
      );

      expect(next.isAgreed, isTrue);
      expect(next.isWalkedAway, isFalse);
      expect(next.messages.length, 3); // Opening, Player, Reply
      expect(next.messages.last.badgeText, 'MUTABAKAT SAĞLANDI');
    });

    test('executeTactic walkAway immediately sets isWalkedAway to true', () {
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_123',
        contractorName: 'Metropol Yapı',
        totalUnits: 12,
        baseMarketValue: 5000000.0,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.walkAway,
        playerMessageText: 'Bu şartlarda sizinle anlaşamayız, masadan kalkıyorum.',
        random: Random(42),
      );

      expect(next.isWalkedAway, isTrue);
      expect(next.isAgreed, isFalse);
      expect(next.messages.last.badgeText, 'PAZARLIK BİTTİ');
    });
  });
}
