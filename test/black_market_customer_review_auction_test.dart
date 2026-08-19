import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/domain/usecases/black_market_engine.dart';
import 'package:galeriden/domain/usecases/review_engine.dart';

void main() {
  group('Kara Borsa Dinamik Algoritma ve Risk Testleri', () {
    test('Kara borsa araç üretimi dinamik ve çeşitli olmalı', () {
      final day1Cars = BlackMarketEngine.generateBlackMarketCars(day: 1, count: 4);
      final day2Cars = BlackMarketEngine.generateBlackMarketCars(day: 2, count: 4);

      expect(day1Cars.length, equals(4));
      expect(day2Cars.length, equals(4));

      for (final car in day1Cars) {
        // İndirimli fiyat gerçek piyasa değerinden düşük olmalı
        expect(car.askingPrice, lessThan(car.realMarketValue));
        expect(car.askingPrice, greaterThan(0));

        // İndirim oranı %15 ile %60 arasında olmalı
        final discountRatio = (car.realMarketValue - car.askingPrice) / car.realMarketValue;
        expect(discountRatio, greaterThanOrEqualTo(0.15));
        expect(discountRatio, lessThanOrEqualTo(0.60));

        // Risk seviyesi indirim oranına paralel ve geçerli aralıkta olmalı (15 - 60)
        expect(car.riskLevelPercent, greaterThanOrEqualTo(15));
        expect(car.riskLevelPercent, lessThanOrEqualTo(60));

        // Proje kuralları: Sıfır Parantez ve Sıfır Unicode Emoji kontrolü
        expect(car.modelName.contains('('), isFalse, reason: 'Parantez bulunmamalı');
        expect(car.modelName.contains(')'), isFalse, reason: 'Parantez bulunmamalı');
        expect(car.riskDescription.contains('('), isFalse, reason: 'Parantez bulunmamalı');
        expect(car.riskDescription.contains(')'), isFalse, reason: 'Parantez bulunmamalı');
      }
    });

    test('Daha yüksek indirim oranı genel olarak daha yüksek risk üretmeli', () {
      final cars = BlackMarketEngine.generateBlackMarketCars(day: 10, count: 20);
      for (final car in cars) {
        final discountPercent = ((car.realMarketValue - car.askingPrice) / car.realMarketValue) * 100;
        // Risk seviyesi indirim oranına yaklaşık olmalı (+-10 tolerans)
        final diff = (car.riskLevelPercent - discountPercent).abs();
        expect(diff, lessThanOrEqualTo(12.0));
      }
    });
  });

  group('Müşteri Profili ve Anti-Repetition Testleri', () {
    test('Müşteri üretimi peş peşe aynı isimleri hemen tekrarlamamalı', () {
      final generatedNames = <String>[];
      for (int i = 0; i < 6; i++) {
        final customer = CustomerModel.generateRandomCustomer();
        generatedNames.add(customer.name);
      }

      // 6 çağrıda en az 4 farklı müşteri ismi gelmeli (anti-repetition)
      final uniqueCount = generatedNames.toSet().length;
      expect(uniqueCount, greaterThanOrEqualTo(4));
    });

    test('Arketipe göre müşteri üretimi doğru çalışmalı', () {
      final skeptical = CustomerModel.generate(CustomerArchetype.skepticalOfficial);
      expect(skeptical.archetype, equals(CustomerArchetype.skepticalOfficial));
      expect(skeptical.inspectionProbability, equals(0.90));

      final youth = CustomerModel.generate(CustomerArchetype.impatientYouth);
      expect(youth.archetype, equals(CustomerArchetype.impatientYouth));
      expect(youth.inspectionProbability, equals(0.20));
    });

    test('İlan satıcı başlığına göre gerçekçi satıcı profili üretilmeli', () {
      final doc = CustomerModel.generateSellerFromListing('Doktordan Temiz Merso');
      expect(doc.archetype, equals(CustomerArchetype.skepticalOfficial));
      expect(doc.archetypeTitle, contains('Doktor'));

      final flipper = CustomerModel.generateSellerFromListing('Oto Al-Satçı Hasan');
      expect(flipper.archetype, equals(CustomerArchetype.greedyFlipper));
    });
  });

  group('Dinamik Müşteri Yorum Motoru Testleri', () {
    final cleanExpertise = ExpertiseReport(
      engineCondition: 90.0,
      transmissionCondition: 88.0,
      tramerAmount: 0,
      mileage: 50000,
      isMileageTampered: false,
      bodyParts: const {},
    );

    final flawlessCar = CarModel(
      id: 'car_test_1',
      brand: 'Merso',
      modelName: 'C-200 Makam AMG',
      modelYear: 2022,
      bodyType: 'Sedan',
      colorHex: '0xFF000000',
      colorDisplayName: 'Obsidyen Siyah',
      colorRarity: 'rare',
      plateNumber: '34 GKT 01',
      plateRarity: 'rare',
      baseMarketValue: 1800000.0,
      currentPurchasePrice: 1500000.0,
      isWashed: true,
      declarationType: ListingDeclarationType.honest,
      expertise: cleanExpertise,
    );

    test('Dürüst ve hatasız araç satışında 5 yıldız ve yüksek itibar üretmeli', () {
      final result = ReviewEngine.generateSaleReview(
        car: flawlessCar,
        buyerName: 'Ahmet Bey',
        hasVipLounge: true,
        hasTrophy: true,
      );

      expect(result.review.rating, equals(5.0));
      expect(result.reputationChange, greaterThanOrEqualTo(5));
      expect(result.review.comment.isNotEmpty, isTrue);

      // Sıfır Parantez kuralı
      expect(result.review.comment.contains('('), isFalse);
      expect(result.review.comment.contains(')'), isFalse);
    });

    test('Kusurlu/yanıltıcı beyanda düşük puan ve itibar kaybı üretmeli', () {
      final dishonestCar = flawlessCar.copyWith(
        declarationType: ListingDeclarationType.minorFlawHidden,
      );

      final result = ReviewEngine.generateSaleReview(
        car: dishonestCar,
        buyerName: 'Mustafa Bey',
      );

      expect(result.review.rating, lessThanOrEqualTo(2.5));
      expect(result.reputationChange, lessThan(0));
      expect(result.review.comment.contains('('), isFalse);
    });
  });
}
