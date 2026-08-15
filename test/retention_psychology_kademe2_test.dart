import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/negotiation_engine.dart';
import 'package:galeriden/domain/usecases/psychology_engine.dart';
import 'package:galeriden/domain/usecases/visitor_queue_engine.dart';

void main() {
  group('Kademe 2: Long-Tail Distribution & Retention Engine Tests', () {
    late CarModel sampleCar;

    setUp(() {
      sampleCar = CarModel(
        id: 'car_k2_1',
        brand: 'Bemeve',
        modelName: '320i M Sport',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '0xFF000000',
        baseMarketValue: 1000000.0,
        currentPurchasePrice: 850000.0,
        customListingPrice: 1050000.0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: const {},
        ),
      );
    });

    test('NegotiationEngine generates diverse long-tail buyer offer types', () {
      int collectorJackpotCount = 0;
      int lowballCount = 0;
      int standardCount = 0;

      // Sample 1000 offers to verify all distribution categories occur
      for (int i = 0; i < 1000; i++) {
        final offer = NegotiationEngine.generateBuyerOffer(sampleCar, sampleCar.listingPrice);
        if (offer.buyerName.contains('Koleksiyoner')) {
          collectorJackpotCount++;
        } else if (offer.buyerName.contains('Ölücü')) {
          lowballCount++;
        } else {
          standardCount++;
        }
      }

      expect(collectorJackpotCount, greaterThan(5), reason: '2% collector jackpot offers should spawn');
      expect(lowballCount, greaterThan(100), reason: '20% lowball offers should spawn');
      expect(standardCount, greaterThan(600), reason: 'Standard and asking offers should form the bulk (70-80%)');
    });

    test('VisitorQueueEngine calculates arrival seconds with reputation and doping factors', () {
      final dopedCar = sampleCar.copyWith(isDoped: true);
      final standardCar = sampleCar.copyWith(isDoped: false);

      final dopedSeconds = VisitorQueueEngine.calculateNextVisitorSeconds(
        car: dopedCar,
        reputation: 80,
        hasSalesman: false,
      );
      final standardSeconds = VisitorQueueEngine.calculateNextVisitorSeconds(
        car: standardCar,
        reputation: 80,
        hasSalesman: false,
      );

      expect(dopedSeconds, lessThan(standardSeconds));
    });

    test('PsychologyEngine generates rich offline recap breakdown', () {
      final summary = PsychologyEngine.getOfflineRecapSummary(
        offlineHours: 4,
        earnedIncome: 45000.0,
        partsArrivedCount: 2,
        newOffersCount: 3,
        streakDays: 5,
      );

      expect(summary['title'], contains('YOKLUĞUNDA'));
      expect(summary['earnedIncome'], equals(45000.0));
      expect(summary['bulletPoints'], isNotEmpty);
    });

    test('DealershipModel supports custom dealership branding and emblem index', () {
      final initial = DealershipModel.initial();
      final branded = initial.copyWith(
        dealershipName: 'Apex Motors Kadıköy',
        emblemIndex: 3,
      );

      expect(branded.dealershipName, equals('Apex Motors Kadıköy'));
      expect(branded.emblemIndex, equals(3));
      
      final json = branded.toJson();
      final restored = DealershipModel.fromJson(json);
      expect(restored.dealershipName, equals('Apex Motors Kadıköy'));
      expect(restored.emblemIndex, equals(3));
    });
  });
}
