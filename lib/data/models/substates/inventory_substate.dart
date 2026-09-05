import '../active_service_job_model.dart';
import '../black_market_car_model.dart';
import '../car_model.dart';
import '../offer_model.dart';
import '../part_order_model.dart';
import '../sale_record_model.dart';
import '../scrapyard_model.dart';

/// Substate representing inventory and vehicle stock management
class InventorySubstate {
  final List<CarModel> ownedCars;
  final List<SaleRecordModel> salesHistory;
  final List<OfferModel> incomingOffers;
  final List<PartOrderModel> pendingOrders;
  final List<ActiveServiceJobModel> activeServiceJobs;
  final List<B2BPartOrder> b2bPartOrders;
  final List<SalvagedPart> salvagedParts;
  final List<ScrapyardCar> scrapyardCars;
  final List<BlackMarketCarModel> blackMarketCars;

  const InventorySubstate({
    this.ownedCars = const [],
    this.salesHistory = const [],
    this.incomingOffers = const [],
    this.pendingOrders = const [],
    this.activeServiceJobs = const [],
    this.b2bPartOrders = const [],
    this.salvagedParts = const [],
    this.scrapyardCars = const [],
    this.blackMarketCars = const [],
  });

  InventorySubstate copyWith({
    List<CarModel>? ownedCars,
    List<SaleRecordModel>? salesHistory,
    List<OfferModel>? incomingOffers,
    List<PartOrderModel>? pendingOrders,
    List<ActiveServiceJobModel>? activeServiceJobs,
    List<B2BPartOrder>? b2bPartOrders,
    List<SalvagedPart>? salvagedParts,
    List<ScrapyardCar>? scrapyardCars,
    List<BlackMarketCarModel>? blackMarketCars,
  }) {
    return InventorySubstate(
      ownedCars: ownedCars ?? this.ownedCars,
      salesHistory: salesHistory ?? this.salesHistory,
      incomingOffers: incomingOffers ?? this.incomingOffers,
      pendingOrders: pendingOrders ?? this.pendingOrders,
      activeServiceJobs: activeServiceJobs ?? this.activeServiceJobs,
      b2bPartOrders: b2bPartOrders ?? this.b2bPartOrders,
      salvagedParts: salvagedParts ?? this.salvagedParts,
      scrapyardCars: scrapyardCars ?? this.scrapyardCars,
      blackMarketCars: blackMarketCars ?? this.blackMarketCars,
    );
  }
}
