import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/utils/anti_repetition_queue.dart';
import 'package:galeriden/core/utils/slot_text_composer.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/notary_event_model.dart';
import 'package:galeriden/domain/usecases/gossip_engine.dart';
import 'package:galeriden/domain/usecases/market_engine.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/review_engine.dart';

void main() {
  group('AntiRepetitionQueue Unit Testleri', () {
    test('Kuyruk kapasiteyi aşmadan son öğeleri hafızada tutmalı', () {
      final queue = AntiRepetitionQueue<String>(capacity: 3);
      queue.push('A');
      queue.push('B');
      queue.push('C');
      expect(queue.history, equals(['A', 'B', 'C']));

      queue.push('D');
      expect(queue.history, equals(['B', 'C', 'D']));
    });

    test('selectNext ardışık tekrarları önlemeli', () {
      final queue = AntiRepetitionQueue<String>(capacity: 4);
      final pool = ['A', 'B', 'C', 'D', 'E', 'F'];

      final picks = <String>[];
      for (int i = 0; i < 6; i++) {
        picks.add(queue.selectNext(pool));
      }

      // İlk 6 seçimde hiçbir eleman peş peşe 2 kere seçilmemeli
      for (int i = 0; i < picks.length - 1; i++) {
        expect(picks[i], isNot(equals(picks[i + 1])));
      }
    });
  });

  group('SlotTextComposer Unit Testleri', () {
    test('Parantez ve emoji temizliğini kurala uygun yapmalı', () {
      const dirty = 'Dosta Gider (Kazasız) Tertemiz 🚗 [ÖZEL]';
      final clean = SlotTextComposer.sanitizeText(dirty);

      expect(clean.contains('('), isFalse);
      expect(clean.contains(')'), isFalse);
      expect(clean.contains('['), isFalse);
      expect(clean.contains(']'), isFalse);
      expect(clean.contains('🚗'), isFalse);
      expect(clean, contains('Dosta Gider - Kazasız Tertemiz ÖZEL'));
    });

    test('compose3 ve compose4 doğru birleştirme yapmalı', () {
      final res = SlotTextComposer.compose3(
        slot1: ['Selamlar usta •'],
        slot2: ['aracın motoru saat gibi.'],
        slot3: ['Hayırlı işler.'],
      );
      expect(res, equals('Selamlar usta • aracın motoru saat gibi. Hayırlı işler.'));
    });
  });

  group('NegotiationEngine Dinamik Diyalog Testleri', () {
    test('Tüm arketip repliklerinde sıfır emoji ve sıfır parantez olmalı', () {
      for (final archetype in CustomerArchetype.values) {
        for (int i = 0; i < 10; i++) {
          final msg = NegotiationEngine.generateDynamicBuyerMessage(
            archetype: archetype,
            offeredPrice: 450000,
            askingPrice: 500000,
            isLowball: false,
            isOverTuned: false,
          );
          expect(msg.contains('('), isFalse, reason: 'Parantez bulunmamalı: $msg');
          expect(msg.contains(')'), isFalse, reason: 'Parantez bulunmamalı: $msg');
          expect(msg.contains('₺450K') || msg.contains('450'), isTrue);
        }
      }
    });

    test('Ölücü ve modifiyeli teklif replikleri dinamik ve kurallara uygun olmalı', () {
      final lowballMsg = NegotiationEngine.generateDynamicBuyerMessage(
        archetype: CustomerArchetype.greedyFlipper,
        offeredPrice: 300000,
        askingPrice: 500000,
        isLowball: true,
      );
      expect(lowballMsg.contains('('), isFalse);
      expect(lowballMsg.isNotEmpty, isTrue);

      final youthOvertunedMsg = NegotiationEngine.generateDynamicBuyerMessage(
        archetype: CustomerArchetype.impatientYouth,
        offeredPrice: 480000,
        askingPrice: 500000,
        isOverTuned: true,
      );
      expect(youthOvertunedMsg.contains('('), isFalse);
      expect(youthOvertunedMsg.isNotEmpty, isTrue);
    });

    test('Taktik zar atımı dinamik diyalogları hatasız döndürmeli', () {
      final tactic = NegotiationEngine.allTactics.first;
      final outcome = NegotiationEngine.rollTactic(
        tactic: tactic,
        tacticUsageIndex: 0,
        negotiationSkillLevel: 3,
        car: CarModel(
          id: 'test_car',
          brand: 'BMW',
          modelName: '320i',
          modelYear: 2020,
          bodyType: 'Sedan',
          colorHex: '0xFF000000',
          baseMarketValue: 1200000,
          currentPurchasePrice: 1000000,
          expertise: ExpertiseReport(
            engineCondition: 85,
            transmissionCondition: 85,
            tramerAmount: 0,
            mileage: 60000,
            isMileageTampered: false,
            bodyParts: const {},
          ),
        ),
        isBuying: true,
      );

      expect(outcome.message.isNotEmpty, isTrue);
      expect(outcome.message.contains('('), isFalse);
    });
  });

  group('MarketEngine ve GossipEngine Anti-Slop Testleri', () {
    test('Günlük sanayi fısıltıları 24 öğe arasından çeşitli üretilmeli', () {
      final day1 = GossipEngine.generateDailyGossips(1);
      final day2 = GossipEngine.generateDailyGossips(2);

      expect(day1.length, equals(4));
      expect(day2.length, equals(4));

      for (final g in day1) {
        expect(g.title.contains('('), isFalse);
        expect(g.teaser.contains('('), isFalse);
        expect(g.content.contains('('), isFalse);
      }
    });

    test('Noter olayları zenginleştirilmiş ve parantezsiz olmalı', () {
      for (int i = 1; i <= 20; i++) {
        final res = NotaryEventResult.evaluateNotaryEvent(
          buyerName: 'Selim Bey',
          carTitle: '2021 Megane',
          price: 650000,
          dealershipReputation: 70,
        );

        expect(res.title.contains('('), isFalse);
        expect(res.description.contains('('), isFalse);
        expect(res.title.isNotEmpty, isTrue);
      }
    });

    test('ReviewEngine zenginleştirilmiş slot yorumları üretmeli', () {
      final testCar = CarModel(
        id: 'rev_car_1',
        brand: 'Mercedes',
        modelName: 'E-250',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 2000000,
        currentPurchasePrice: 1700000,
        isWashed: true,
        declarationType: ListingDeclarationType.honest,
        expertise: ExpertiseReport(
          engineCondition: 92,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 45000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );

      for (int i = 0; i < 5; i++) {
        final result = ReviewEngine.generateSaleReview(
          car: testCar,
          buyerName: 'Hasan Bey',
          hasVipLounge: true,
        );
        expect(result.review.comment.contains('('), isFalse);
        expect(result.review.comment.isNotEmpty, isTrue);
      }
    });
  });
}
