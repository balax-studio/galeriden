import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/domain/usecases/contractor_negotiation_expansion.dart';
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

    test('createContractorSession with Hacı Reşat profile starts at %33 and base patience 110', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_haci_resat');
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_haci',
        totalUnits: 20,
        baseMarketValue: 8000000.0,
        profile: profile,
      );

      expect(session.counterpartyName, 'Hacı Reşat & Oğulları Yapı');
      expect(session.patience, 110);
      expect(session.maxPatience, 110);
      expect(session.currentSharePercent, 33);
      expect(session.maxSharePercent, 50);
      expect(session.contractorId, 'contractor_haci_resat');
      expect(session.messages.first.badgeText, '%33 - %67 KAT KARŞILIĞI');
      expect(session.messages.first.message.contains('%33'), isTrue);
    });

    test('executeTactic askJokeOrChat restores patience and returns an authentic joke', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_kartal_hizli');
      var session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_kartal',
        totalUnits: 16,
        baseMarketValue: 6000000.0,
        profile: profile,
      );

      // Reduce patience first
      session = session.copyWith(patience: 40);

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.askJokeOrChat,
        playerMessageText: 'Ustam gel bir çay içelim, dertleşelim.',
        random: Random(42),
      );

      expect(next.patience, greaterThan(40));
      expect(next.messages.last.badgeText, 'ÇAY VE SOHBET • SABIR +22');
      expect(next.messages.last.message.isNotEmpty, isTrue);
    });

    test('executeTactic demandBankGuarantee handles corporate guarantee request', () {
      final profile = ContractorNegotiationExpansion.getContractor('contractor_metropol_mimarlik');
      final session = RealEstateChatNegotiationEngine.createContractorSession(
        landId: 'land_metropol',
        totalUnits: 24,
        baseMarketValue: 12000000.0,
        profile: profile,
      );

      final next = RealEstateChatNegotiationEngine.executeTactic(
        state: session,
        tactic: ChatTacticType.demandBankGuarantee,
        playerMessageText: 'Yarım kalma riskine karşı teminat mektubu istiyoruz.',
        random: Random(1), // seeded to test response
      );

      expect(next.messages.length, 3);
      expect(next.patience, lessThan(session.patience));
    });
  });
}

