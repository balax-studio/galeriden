import 'dart:async';
import 'dart:math';

import '../../../data/models/staff_model.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/loan_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import '../../../data/models/installment_contract_model.dart';
import '../../../data/models/cheque_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../../data/models/stock_model.dart';
import '../../../data/models/game_event_model.dart';
import '../../../data/models/market_news_model.dart';
import '../../../data/models/scrapyard_model.dart';
import '../../../data/models/black_market_car_model.dart';

import 'game_base_notifier.dart';

mixin GameTimeMixin on GameBaseNotifier {
  Timer? _organicOfferTimer;

  void startPeriodicOrganicOfferTimer() {
    _organicOfferTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // ponytail: Advance game calendar day every 2 ticks (120 seconds)
      if (timer.tick % 2 == 0) {
        advanceGameDay();
      }

      // Günlük dalgalanma faktörü (0.8 ile 1.2 arası)
      double dayFactor = 0.8 + (random.nextDouble() * 0.4);

      // Daha düşük ihtimal ve daha uzun aralıklarla organik teklifler (Örn: %15 şans)
      if (state.ownedCars.isNotEmpty && random.nextDouble() < (0.15 * dayFactor)) {
        triggerOrganicOffers();
      }
    });
  }

  void stopPeriodicOrganicOfferTimer() {
    _organicOfferTimer?.cancel();
  }

  void advanceGameDay() {
    int nextDay = state.currentDay + 1;
    double newBalance = state.balance;

    // 1. Deduct daily salaries for hired staff
    double totalSalaries = 0.0;
    for (var staff in state.hiredStaff) {
      totalSalaries += staff.role.dailySalary;
    }
    
    // Eğer maaşı ödeyecek para yoksa personel işi bırakır
    List<StaffModel> currentStaff = List.from(state.hiredStaff);
    if (newBalance >= totalSalaries) {
      newBalance -= totalSalaries;
    } else {
      newBalance = 0; // Kalan para ancak bir kısmını ödedi
      currentStaff.clear(); // Tüm personel ayrıldı
    }

    // 2. Process automatic loan installments every 7 days (Weekly deduction)
    List<LoanModel> updatedLoans = List.from(state.activeLoans);
    bool isLoanPaymentDay = nextDay % 7 == 0;

    if (isLoanPaymentDay && updatedLoans.isNotEmpty) {
      for (int i = updatedLoans.length - 1; i >= 0; i--) {
        final loan = updatedLoans[i];
        newBalance -= loan.monthlyPayment;

        final newRemaining = loan.remainingAmount - loan.monthlyPayment;
        final newInstallments = loan.remainingInstallments - 1;

        if (newInstallments <= 0 || newRemaining <= 0) {
          updatedLoans.removeAt(i);
        } else {
          updatedLoans[i] = loan.copyWith(
            remainingAmount: newRemaining,
            remainingInstallments: newInstallments,
          );
        }
      }
    }

    // 4. Rent a Car (Pasif Gelir) mechanics
    List<RentalAgreement> updatedRentals = List.from(state.activeRentals);
    List<CarModel> currentCars = List.from(state.ownedCars);
    
    for (int i = updatedRentals.length - 1; i >= 0; i--) {
      final rental = updatedRentals[i];
      newBalance += rental.dailyRate;
      
      final carIndex = currentCars.indexWhere((c) => c.id == rental.carId);
      if (carIndex != -1) {
        CarModel car = currentCars[carIndex];
        if (random.nextDouble() < 0.05) { 
          car = car.copyWith(expertise: car.expertise.copyWith(engineCondition: max(0, car.expertise.engineCondition - 5)));
        } else if (random.nextDouble() < 0.01) { 
          car = car.copyWith(expertise: car.expertise.copyWith(tramerAmount: car.expertise.tramerAmount + 15000, engineCondition: max(0, car.expertise.engineCondition - 20)));
        }
        currentCars[carIndex] = car;
      }
      
      updatedRentals[i] = rental.copyWith(
        rentedDays: rental.rentedDays + 1,
        totalEarned: rental.totalEarned + rental.dailyRate,
      );
    }

    // 5. Installments mechanics
    List<InstallmentContract> updatedInstallments = List.from(state.activeInstallments);
    for (int i = updatedInstallments.length - 1; i >= 0; i--) {
      final contract = updatedInstallments[i];
      int remainingDays = contract.daysUntilNextPayment - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < 0.05) {
          newBalance += (contract.totalAmount - contract.paidAmount) * 0.5;
          updatedInstallments.removeAt(i);
        } else if (random.nextDouble() < 0.10) {
          updatedInstallments[i] = contract.copyWith(daysUntilNextPayment: 5, isDefaulted: true);
        } else {
          newBalance += contract.installmentAmount;
          int newPaidInstallments = contract.paidInstallments + 1;
          
          if (newPaidInstallments >= contract.totalInstallments) {
            updatedInstallments.removeAt(i);
          } else {
            updatedInstallments[i] = contract.copyWith(
              paidAmount: contract.paidAmount + contract.installmentAmount,
              paidInstallments: newPaidInstallments,
              daysUntilNextPayment: 30,
              isDefaulted: false,
            );
          }
        }
      } else {
        updatedInstallments[i] = contract.copyWith(daysUntilNextPayment: remainingDays);
      }
    }

    // 6. Cheques mechanics
    List<Cheque> updatedCheques = List.from(state.activeCheques);
    for (int i = updatedCheques.length - 1; i >= 0; i--) {
      final cheque = updatedCheques[i];
      int remainingDays = cheque.daysUntilDue - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < 0.05) {
          newBalance += cheque.amount * 0.5; 
          updatedCheques.removeAt(i);
        } else {
          newBalance += cheque.amount;
          updatedCheques.removeAt(i);
        }
      } else {
        updatedCheques[i] = cheque.copyWith(daysUntilDue: remainingDays);
      }
    }

    // 7. Bailout (İflas Kurtarma Mekanizması)
    // Eğer oyuncu kredi taksiti sonrası eksiye düştüyse ve satacak arabası yoksa soft-lock olur.
    if (newBalance < 0 && currentCars.isEmpty && state.pendingOrders.isEmpty) {
      newBalance = 25000.0; // Devlet hibesi / başlangıç sermayesi
      updatedLoans.clear(); // Borçlar silinir
    }

    // 8. Side Businesses (Pasif Gelir)
    List<SideBusinessModel> updatedBusinesses = List.from(state.sideBusinesses);
    for (int i = 0; i < updatedBusinesses.length; i++) {
      final b = updatedBusinesses[i];
      if (b.isOwned) {
        final income = b.effectiveDailyIncome;
        newBalance += income;
        updatedBusinesses[i] = b.copyWith(totalEarned: b.totalEarned + income);
      }
    }

    // 9. Stock Market Fluctuations
    List<StockModel> updatedStocks = List.from(state.marketStocks);
    List<GameEventModel> newEvents = List.from(state.recentEvents);
    
    for (int i = 0; i < updatedStocks.length; i++) {
      final stock = updatedStocks[i];
      double changePercent = (random.nextDouble() * 0.10) - 0.05; // -5% to +5%
      
      if (random.nextDouble() < 0.05) {
        changePercent = (random.nextDouble() * 0.30) - 0.15; // -15% to +15%
        newEvents.insert(0, GameEventModel(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          date: DateTime.now(),
          title: '${stock.symbol} Hissesinde Dalgalanma',
          description: 'Piyasa haberleri ${stock.symbol} hissesini etkiledi.',
          amount: 0.0,
          type: changePercent > 0 ? GameEventType.income : GameEventType.badEvent,
        ));
      }
      
      double newPrice = stock.currentPrice * (1 + changePercent);
      if (newPrice < 1.0) newPrice = 1.0; 
      
      updatedStocks[i] = stock.copyWith(currentPrice: newPrice);
    }
    
    // Keep only last 50 events
    if (newEvents.length > 50) {
      newEvents = newEvents.sublist(0, 50);
    }

    // 10. Daily Tax
    newBalance -= state.dailyTaxRate;

    // 11. Market News Event Rotation (Every 5 days or if null)
    MarketNewsModel? currentNews = state.activeNews;
    if (currentNews == null || nextDay % 5 == 0) {
      final randomIndex = random.nextInt(MarketNewsModel.newsList.length);
      currentNews = MarketNewsModel.newsList[randomIndex];
    }

    // 12. Scrapyard & Black Market Inventory Refresh (Every 3 days)
    List<ScrapyardCar> currentScrapCars = List.from(state.scrapyardCars);
    List<BlackMarketCarModel> currentBlackCars = List.from(state.blackMarketCars);

    if (nextDay % 3 == 0 || currentScrapCars.isEmpty) {
      currentScrapCars = _generateRandomScrapyardCars(nextDay);
    }
    if (nextDay % 3 == 0 || currentBlackCars.isEmpty) {
      currentBlackCars = _generateRandomBlackMarketCars(nextDay);
    }

    state = state.copyWith(
      currentDay: nextDay,
      balance: newBalance,
      ownedCars: currentCars,
      hiredStaff: currentStaff,
      activeLoans: updatedLoans,
      activeRentals: updatedRentals,
      activeInstallments: updatedInstallments,
      activeCheques: updatedCheques,
      sideBusinesses: updatedBusinesses,
      marketStocks: updatedStocks,
      recentEvents: newEvents,
      activeNews: currentNews,
      scrapyardCars: currentScrapCars,
      blackMarketCars: currentBlackCars,
    );

    refreshMarketTrends();
  }

  List<ScrapyardCar> _generateRandomScrapyardCars(int day) {
    return [
      ScrapyardCar(
        id: 'scrap_${day}_1',
        brand: 'BMW',
        modelName: '320i M-Sport (Ağır Pert)',
        modelYear: 2016,
        scrapPrice: 140000.0,
        estimatedPartTotalValue: 280000.0,
        damageNote: 'Önden ağır taklalı, tavan ezik. Motor ve şanzıman sapasağlam.',
        parts: const [
          SalvagedPart(id: 'p_1_1', name: '2.0 TwinPower Turbo Motor Bloğu', carModelName: 'BMW 320i', category: 'engine', conditionPercent: 88, estimatedValue: 120000.0),
          SalvagedPart(id: 'p_1_2', name: '8 İleri ZF Otomatik Şanzıman', carModelName: 'BMW 320i', category: 'transmission', conditionPercent: 92, estimatedValue: 85000.0),
          SalvagedPart(id: 'p_1_3', name: '19" M Alaşım Çift Jant Takımı', carModelName: 'BMW 320i', category: 'wheels', conditionPercent: 80, estimatedValue: 35000.0),
          SalvagedPart(id: 'p_1_4', name: 'Harman Kardon Müzik Sistemi', carModelName: 'BMW 320i', category: 'audio', conditionPercent: 95, estimatedValue: 40000.0),
        ],
      ),
      ScrapyardCar(
        id: 'scrap_${day}_2',
        brand: 'Volkswagen',
        modelName: 'Golf 7.5 GTI (Pert Kayıtlı)',
        modelYear: 2018,
        scrapPrice: 190000.0,
        estimatedPartTotalValue: 360000.0,
        damageNote: 'Arkadan kamyon çarpması sonrası pert kararı verilmiş.',
        parts: const [
          SalvagedPart(id: 'p_2_1', name: '2.0 TSI GTI Turbo Şarj Kiti', carModelName: 'Golf GTI', category: 'turbo', conditionPercent: 94, estimatedValue: 65000.0),
          SalvagedPart(id: 'p_2_2', name: 'DSG Islak Kavrama Şanzıman', carModelName: 'Golf GTI', category: 'transmission', conditionPercent: 90, estimatedValue: 95000.0),
          SalvagedPart(id: 'p_2_3', name: 'Karbon Difüzör & Çift Egzoz Takımı', carModelName: 'Golf GTI', category: 'bodywork', conditionPercent: 85, estimatedValue: 45000.0),
          SalvagedPart(id: 'p_2_4', name: 'GTI Hayalet Gösterge & Direksiyon', carModelName: 'Golf GTI', category: 'bodywork', conditionPercent: 96, estimatedValue: 75000.0),
        ],
      ),
      ScrapyardCar(
        id: 'scrap_${day}_3',
        brand: 'Mercedes-Benz',
        modelName: 'C200d AMG (Yanık/Pert)',
        modelYear: 2017,
        scrapPrice: 165000.0,
        estimatedPartTotalValue: 310000.0,
        damageNote: 'Elektrik kontağından motor kompartımanı kısmen hasarlı.',
        parts: const [
          SalvagedPart(id: 'p_3_1', name: 'AMG Deri Koltuk & İç Döşeme Takımı', carModelName: 'C200d', category: 'bodywork', conditionPercent: 92, estimatedValue: 80000.0),
          SalvagedPart(id: 'p_3_2', name: '9G-Tronic Otomatik Şanzıman', carModelName: 'C200d', category: 'transmission', conditionPercent: 89, estimatedValue: 110000.0),
          SalvagedPart(id: 'p_3_3', name: 'Burmester VIP Ses Sistemi', carModelName: 'C200d', category: 'audio', conditionPercent: 98, estimatedValue: 55000.0),
          SalvagedPart(id: 'p_3_4', name: 'AMG MultiBeam LED Far Takımı', carModelName: 'C200d', category: 'bodywork', conditionPercent: 85, estimatedValue: 65000.0),
        ],
      ),
    ];
  }

  List<BlackMarketCarModel> _generateRandomBlackMarketCars(int day) {
    return [
      BlackMarketCarModel(
        id: 'bm_${day}_1',
        brand: 'Porsche',
        modelName: 'Panamera GTS (%50 Kelepir / Soruşturmalı)',
        modelYear: 2019,
        askingPrice: 1200000.0,
        realMarketValue: 2400000.0,
        riskType: 'change_vin',
        riskLevelPercent: 25,
        sellerAlias: 'Gece Kuşu Selim',
        riskDescription: 'Şasi numarası yurt dışı gümrük kaçakçılığı şüphesiyle takipli. Satışta %25 Polis Yakalama Riski!',
      ),
      BlackMarketCarModel(
        id: 'bm_${day}_2',
        brand: 'Mercedes-Benz',
        modelName: 'G63 AMG V8 (%60 İndirimli / Hacizli)',
        modelYear: 2021,
        askingPrice: 2800000.0,
        realMarketValue: 6500000.0,
        riskType: 'stolen_paperwork',
        riskLevelPercent: 35,
        sellerAlias: 'Karanlık Kenan',
        riskDescription: 'Yurt dışından kaçak sokulmuş sahte plaka G-Wagon. Satış esnasında %35 Polis El Koyma Riski!',
      ),
      BlackMarketCarModel(
        id: 'bm_${day}_3',
        brand: 'Audi',
        modelName: 'RS6 Avant (%45 İndirimli / Çifte Şasi)',
        modelYear: 2020,
        askingPrice: 1950000.0,
        realMarketValue: 4200000.0,
        riskType: 'salvage_hidden',
        riskLevelPercent: 20,
        sellerAlias: 'Gölge İbrahim',
        riskDescription: 'İki kazalı araç kaynağı ile yapılmış Change RS6. Yakalanırsa araç kaza enkazı sayılarak bağlanır!',
      ),
    ];
  }
}
