import '../../data/models/car_model.dart';
import 'market_engine.dart';

class ConsignmentEngine {

  static const List<Map<String, dynamic>> _npcOwners = [
    {'name': 'Doktor Cihan Bey', 'trait': 'Tertemiz makam arabasını satmak istiyor.', 'rate': 0.12},
    {'name': 'Avukat Tarık', 'trait': 'Lüks SUV aracını emanet bırakıyor.', 'rate': 0.10},
    {'name': 'Eczacı Nazan Hanım', 'trait': 'Yeni araç aldığı için eski aracını konsinye veriyor.', 'rate': 0.15},
    {'name': 'Müteahhit Rıfat', 'trait': 'Şirket filosundan çıkan aracı galeriye bıraktı.', 'rate': 0.10},
  ];

  /// Generates consignment vehicle offers from trusted NPCs (§4.6.1)
  static List<CarModel> generateConsignmentOffers({required int inGameDay}) {
    final generatedCars = MarketEngine.generateRandomListings(count: 3).map((l) => l.car).toList();
    final results = <CarModel>[];

    for (int i = 0; i < generatedCars.length; i++) {
      final owner = _npcOwners[i % _npcOwners.length];
      final rawCar = generatedCars[i];

      final consignmentCar = rawCar.copyWith(
        isConsignment: true,
        consignmentCommissionRate: (owner['rate'] as double),
        consignmentOwnerName: (owner['name'] as String),
        consignmentDaysRemaining: 14,
        currentPurchasePrice: 0.0, // Zero capital required
      );
      results.add(consignmentCar);
    }

    return results;
  }

  /// Calculates net commission earnings for the gallery upon selling a consignment car
  static double calculateCommissionEarnings(CarModel car, double salePrice) {
    if (!car.isConsignment) return 0.0;
    return salePrice * car.consignmentCommissionRate;
  }
}
