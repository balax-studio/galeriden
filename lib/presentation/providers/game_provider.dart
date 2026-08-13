import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/staff_model.dart';
import '../../data/models/customer_review_model.dart';
import '../../data/models/car_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/mission_model.dart';
import '../../data/models/offer_model.dart';
import '../../data/models/part_order_model.dart';
import '../../data/models/sale_record_model.dart';
import '../../data/models/detailing_model.dart';
import '../../data/models/player_skills.dart';
import '../../data/models/cheque_model.dart';
import '../../data/models/installment_contract_model.dart';
import '../../data/models/rental_agreement_model.dart';
import '../../data/models/side_business_model.dart';
import '../../data/models/stock_model.dart';
import '../../data/models/game_event_model.dart';

import '../../domain/usecases/market_engine.dart';
import '../../domain/usecases/negotiation_engine.dart';
import '../../domain/usecases/offline_progression.dart';
import '../../domain/usecases/psychology_engine.dart';
import '../../domain/usecases/repair_engine.dart';
import '../../domain/usecases/risk_engine.dart';

final gameProvider = StateNotifierProvider<GameNotifier, DealershipModel>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<DealershipModel> {
  final Random _random = Random();
  Timer? _organicOfferTimer;

  GameNotifier() : super(DealershipModel.initial()) {
    _loadState();
    _startPeriodicOrganicOfferTimer();
  }

  void _startPeriodicOrganicOfferTimer() {
    _organicOfferTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      // ponytail: Advance game calendar day every 2 ticks (120 seconds)
      if (timer.tick % 2 == 0) {
        _advanceGameDay();
      }

      // Günlük dalgalanma faktörü (0.8 ile 1.2 arası)
      double dayFactor = 0.8 + (_random.nextDouble() * 0.4);

      // Daha düşük ihtimal ve daha uzun aralıklarla organik teklifler (Örn: %15 şans)
      if (state.ownedCars.isNotEmpty && _random.nextDouble() < (0.15 * dayFactor)) {
        triggerOrganicOffers();
      }
    });
  }

  void _advanceGameDay() {
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
        if (_random.nextDouble() < 0.05) { 
          car = car.copyWith(expertise: car.expertise.copyWith(engineCondition: max(0, car.expertise.engineCondition - 5)));
        } else if (_random.nextDouble() < 0.01) { 
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
        if (_random.nextDouble() < 0.05) {
          newBalance += (contract.totalAmount - contract.paidAmount) * 0.5;
          updatedInstallments.removeAt(i);
        } else if (_random.nextDouble() < 0.10) {
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
        if (_random.nextDouble() < 0.05) {
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
      if (updatedBusinesses[i].isOwned) {
        newBalance += updatedBusinesses[i].dailyIncome;
      }
    }

    // 9. Stock Market Fluctuations
    List<StockModel> updatedStocks = List.from(state.marketStocks);
    List<GameEventModel> newEvents = List.from(state.recentEvents);
    
    for (int i = 0; i < updatedStocks.length; i++) {
      final stock = updatedStocks[i];
      double changePercent = (_random.nextDouble() * 0.10) - 0.05; // -5% to +5%
      
      if (_random.nextDouble() < 0.05) {
        changePercent = (_random.nextDouble() * 0.30) - 0.15; // -15% to +15%
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
    // Apply tax on balance or daily profit? Let's apply a very small wealth tax for now, or just a flat daily fee representing expenses.
    // We can interpret dailyTaxRate as a percentage of balance or flat. Let's do small percentage of balance.
    newBalance -= (newBalance * state.dailyTaxRate);

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
    );

    refreshMarketTrends();
  }

  @override
  void dispose() {
    _organicOfferTimer?.cancel();
    super.dispose();
  }

  static const String _storageKey = 'dealership_state_v2';

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        final loaded = DealershipModel.fromJson(decoded);

        // Calculate login streak
        final now = DateTime.now();
        int streak = loaded.loginStreak;
        final diffDays = now.difference(loaded.lastLoginDate).inDays;
        if (diffDays == 1) {
          streak += 1;
        } else if (diffDays > 1) {
          streak = 1;
        }

        // Filter expired offers
        final activeOffers = loaded.incomingOffers.where((o) => !o.isExpired).toList();

        // Process offline time progression
        final offlineResult = OfflineProgression.processOfflineTime(loaded.copyWith(incomingOffers: activeOffers));
        DealershipModel updated = offlineResult['updatedDealership'] as DealershipModel;
        updated = updated.copyWith(loginStreak: streak, lastLoginDate: now);

        state = updated;
        _saveState();
        return;
      } catch (e) {
        // Fallback
      }
    }

    state = DealershipModel.initial();
    _saveState();
  }

  Future<void> _saveState() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Claim daily login streak reward
  int claimDailyStreak() {
    final reward = PsychologyEngine.getStreakReward(state.loginStreak);
    state = state.copyWith(
      balance: state.balance + reward,
      lastLoginDate: DateTime.now(),
      lastRewardClaimDate: DateTime.now(),
    );
    addXP(50);
    _saveState();
    return reward;
  }

  /// Refresh Market Trends
  void refreshMarketTrends() {
    final newTrend = MarketEngine.generateMarketTrend();
    state = state.copyWith(marketTrend: newTrend);
    _saveState();
  }

  /// Deduct balance from dealership capital
  void deductBalance(double amount) {
    if (state.balance < amount) return;
    state = state.copyWith(balance: state.balance - amount);
    _saveState();
  }

  /// Buy a side business
  bool buySideBusiness(String businessId) {
    final businessIndex = state.sideBusinesses.indexWhere((b) => b.id == businessId);
    if (businessIndex == -1) return false;

    final business = state.sideBusinesses[businessIndex];
    if (business.isOwned) return false; // Zaten sahip
    if (state.balance < business.cost) return false; // Yetersiz bakiye

    final updatedBusinesses = List<SideBusinessModel>.from(state.sideBusinesses);
    updatedBusinesses[businessIndex] = business.copyWith(isOwned: true);

    state = state.copyWith(
      balance: state.balance - business.cost,
      sideBusinesses: updatedBusinesses,
    );
    
    addXP(150); 
    _saveState();
    return true;
  }

  /// Upgrade a side business
  bool upgradeSideBusiness(String businessId) {
    final businessIndex = state.sideBusinesses.indexWhere((b) => b.id == businessId);
    if (businessIndex == -1) return false;

    final business = state.sideBusinesses[businessIndex];
    if (!business.isOwned) return false;
    
    double upgradeCost = business.cost * 0.5 * business.level; // Basit artış
    if (state.balance < upgradeCost) return false;

    final updatedBusinesses = List<SideBusinessModel>.from(state.sideBusinesses);
    updatedBusinesses[businessIndex] = business.copyWith(
      level: business.level + 1,
      dailyIncome: business.dailyIncome * 1.5, // %50 gelir artışı
    );

    state = state.copyWith(
      balance: state.balance - upgradeCost,
      sideBusinesses: updatedBusinesses,
    );
    
    addXP(50);
    _saveState();
    return true;
  }

  /// Buy stocks
  bool buyStock(String symbol, int amount) {
    final stock = state.marketStocks.firstWhere((s) => s.symbol == symbol, orElse: () => throw Exception('Hisse bulunamadı'));
    double totalCost = stock.currentPrice * amount;
    
    if (state.balance < totalCost) return false;

    List<PlayerStockModel> updatedOwned = List.from(state.ownedStocks);
    final existingIndex = updatedOwned.indexWhere((s) => s.symbol == symbol);
    
    if (existingIndex != -1) {
      final existing = updatedOwned[existingIndex];
      double totalSpent = (existing.averageCost * existing.quantity) + totalCost;
      int newShares = existing.quantity + amount;
      double newAvgPrice = totalSpent / newShares;
      
      updatedOwned[existingIndex] = existing.copyWith(
        quantity: newShares,
        averageCost: newAvgPrice,
      );
    } else {
      updatedOwned.add(PlayerStockModel(
        symbol: symbol,
        quantity: amount,
        averageCost: stock.currentPrice,
      ));
    }

    state = state.copyWith(
      balance: state.balance - totalCost,
      ownedStocks: updatedOwned,
    );
    
    addXP(10);
    _saveState();
    return true;
  }

  /// Sell stocks
  bool sellStock(String symbol, int amount) {
    List<PlayerStockModel> updatedOwned = List.from(state.ownedStocks);
    final existingIndex = updatedOwned.indexWhere((s) => s.symbol == symbol);
    
    if (existingIndex == -1) return false;
    
    final existing = updatedOwned[existingIndex];
    if (existing.quantity < amount) return false;
    
    final stock = state.marketStocks.firstWhere((s) => s.symbol == symbol);
    double revenue = stock.currentPrice * amount;

    if (existing.quantity == amount) {
      updatedOwned.removeAt(existingIndex);
    } else {
      updatedOwned[existingIndex] = existing.copyWith(
        quantity: existing.quantity - amount,
      );
    }

    state = state.copyWith(
      balance: state.balance + revenue,
      ownedStocks: updatedOwned,
    );
    
    addXP(10);
    _saveState();
    return true;
  }

  /// Purchase a car from market with RiskEngine check
  PurchaseRiskOutcome? buyCar(CarModel car, double purchasePrice, {bool isExpertiseCompleted = false}) {
    if (state.balance < purchasePrice) return null;
    if (state.ownedCars.length >= state.maxGarageSlots) return null;

    final updatedBalance = state.balance - purchasePrice;
    
    // Evaluate risk if expertise was not done
    PurchaseRiskOutcome outcome;
    if (!isExpertiseCompleted) {
      outcome = RiskEngine.evaluateUninspectedPurchaseRisk(car);
    } else {
      outcome = PurchaseRiskOutcome(
        isTrapped: false,
        title: 'Ekspertizli Alım',
        description: 'Ekspertiz raporu doğrultusunda güvenle satın alındı.',
        updatedCar: car,
      );
    }

    final finalCar = outcome.updatedCar.copyWith(
      currentPurchasePrice: purchasePrice,
    );

    state = state.copyWith(
      balance: updatedBalance,
      ownedCars: [...state.ownedCars, finalCar],
    );

    addXP(25);
    _checkAchievement('first_buy');
    _updateMissionProgress(MissionType.buyCars, 1);
    _saveState();
    return outcome;
  }

  /// Directly purchase a car (e.g. won from Live Auction)
  bool buyCarDirectly(CarModel car, double price) {
    if (state.balance < price) return false;
    if (state.ownedCars.length >= state.maxGarageSlots) return false;
    final finalCar = car.copyWith(currentPurchasePrice: price);
    state = state.copyWith(
      balance: state.balance - price,
      ownedCars: [...state.ownedCars, finalCar],
    );
    addXP(30);
    _checkAchievement('first_buy');
    _updateMissionProgress(MissionType.buyCars, 1);
    _saveState();
    return true;
  }

  /// Expand Garage Slots / Buy Branch
  bool expandGarageSlot(int newMaxSlots, double cost) {
    if (state.balance < cost) return false;
    state = state.copyWith(
      balance: state.balance - cost,
      maxGarageSlots: newMaxSlots,
    );
    addXP(100);
    _checkAchievement('garage_expand');
    _saveState();
    return true;
  }

  /// Boost Listing Doping (₺2.500): Increases listing visibility with randomized delay
  bool boostListingDoping(String carId) {
    const cost = 2500.0;
    if (state.balance < cost) return false;

    final car = state.ownedCars.firstWhere((c) => c.id == carId, orElse: () => throw Exception('Car not found'));
    
    state = state.copyWith(balance: state.balance - cost);
    addXP(15);
    _saveState();

    final delay1 = 3 + _random.nextInt(3);
    final delay2 = 6 + _random.nextInt(4);

    // Doping brings 2 offers after realistic randomized delays (3-8 sec)
    Future.delayed(Duration(seconds: delay1), () {
      if (!mounted || !state.ownedCars.any((c) => c.id == car.id)) return;
      final newOffer1 = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.05);
      state = state.copyWith(incomingOffers: [...state.incomingOffers, newOffer1]);
      _saveState();
    });

    Future.delayed(Duration(seconds: delay2), () {
      if (!mounted || !state.ownedCars.any((c) => c.id == car.id)) return;
      final newOffer2 = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.05);
      state = state.copyWith(incomingOffers: [...state.incomingOffers, newOffer2]);
      _saveState();
    });

    return true;
  }

  /// Organic buyer offers trigger over time even WITHOUT paid doping
  void triggerOrganicOffers() {
    if (state.ownedCars.isEmpty) return;
    
    // Sadece üzerinde 2'den az aktif teklif olan araçlara organik teklif gelsin
    final eligibleCars = state.ownedCars.where((car) {
       int activeOffers = state.incomingOffers.where((o) => o.carId == car.id && !o.isExpired).length;
       return activeOffers < 2; 
    }).toList();

    if (eligibleCars.isEmpty) return;

    final randomCar = eligibleCars[_random.nextInt(eligibleCars.length)];
    final offer = NegotiationEngine.generateBuyerOffer(randomCar, randomCar.estimatedRealValue);
    state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
    _saveState();
  }

  /// Apply a specific detailing/tuning option to a car
  bool applyDetailingOption(String carId, DetailingOption option) {
    if (state.balance < option.cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.appliedDetailingOptionIds.contains(option.id)) return false; // Already applied

    final updatedOptionIds = [...car.appliedDetailingOptionIds, option.id];
    final updatedCar = car.copyWith(
      appliedDetailingOptionIds: updatedOptionIds,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - option.cost,
      ownedCars: updatedCars,
    );

    addXP(25);
    _saveState();
    return true;
  }

  /// Perform detailing & pasta cila (+8% value boost & shine badge)
  bool detailCleanCar(String carId) {
    const cost = RepairEngine.detailedCleanCost; // 2500 TL
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    if (car.isDetailedCleaned) return false; // Already cleaned guard!

    final updatedCar = RepairEngine.performDetailing(car);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(20);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      _checkAchievement('restoration_king');
    }
    _saveState();
    return true;
  }

  /// Hire a staff member
  bool hireStaff(StaffModel staff) {
    if (state.hiredStaff.any((s) => s.role == staff.role)) return false; // Max 1 per role
    state = state.copyWith(hiredStaff: [...state.hiredStaff, staff]);
    _saveState();
    return true;
  }

  /// Fire a staff member
  void fireStaff(String staffId) {
    state = state.copyWith(
      hiredStaff: state.hiredStaff.where((s) => s.id != staffId).toList(),
    );
    _saveState();
  }

  /// Interactive Wash and Polish Car
  bool washAndPolishCar(String carId, {required bool wash, required bool polish}) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    
    // Only charge for what is actually needed
    final bool willWash = wash && !car.isWashed;
    final bool willPolish = polish && !car.isPolished;
    
    if (!willWash && !willPolish) return false;

    final cost = (willWash ? 300.0 : 0.0) + (willPolish ? 800.0 : 0.0);
    if (state.balance < cost) return false;

    final updatedCar = car.copyWith(
      isWashed: willWash ? true : car.isWashed,
      isPolished: willPolish ? true : car.isPolished,
    );

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );

    addXP(15);
    _saveState();
    return true;
  }

  /// Add customer review upon sales
  void addCustomerReview(CustomerReviewModel review) {
    // Update average rating impact on reputation score
    final newReputation = (state.reputationScore + (review.rating >= 4.0 ? 5 : -10)).clamp(0, 100);
    state = state.copyWith(
      customerReviews: [review, ...state.customerReviews],
      reputationScore: newReputation,
    );
    _saveState();
  }

  /// Update owned car after repair or detailing
  void updateOwnedCar(CarModel updatedCar, double cost) {
    if (state.balance < cost) return;

    final cars = state.ownedCars.map((c) {
      return c.id == updatedCar.id ? updatedCar : c;
    }).toList();

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: cars,
    );

    addXP(15);
    _updateMissionProgress(MissionType.repairParts, 1);
    if (updatedCar.expertise.engineCondition == 100.0 && updatedCar.isDetailedCleaned) {
      _checkAchievement('restoration_king');
    }
    _saveState();
  }

  /// Repair body part with Craftsman Tier
  RepairResult repairBodyPartWithTier(CarModel car, String partName, RepairTier tier) {
    final result = RepairEngine.repairBodyPart(car, partName, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(20);
        _updateMissionProgress(MissionType.repairParts, 1);
      }
      _saveState();
    }
    return result;
  }

  /// Repair Engine with Craftsman Tier
  RepairResult repairEngineWithTier(CarModel car, RepairTier tier) {
    final result = RepairEngine.repairEngine(car, tier);
    if (state.balance >= result.costPaid) {
      final updatedCars = state.ownedCars.map((c) => c.id == car.id ? result.updatedCar : c).toList();
      state = state.copyWith(
        balance: state.balance - result.costPaid,
        ownedCars: updatedCars,
      );
      if (result.isSuccess) {
        addXP(30);
        _updateMissionProgress(MissionType.repairParts, 1);
      }
      _saveState();
    }
    return result;
  }

  /// Submit counter-offer to buyer
  NegotiationOutcome counterOffer(String offerId, double playerTargetPrice) {
    final offerIndex = state.incomingOffers.indexWhere((o) => o.id == offerId);
    if (offerIndex == -1) {
      throw Exception('Teklif bulunamadı');
    }

    final offer = state.incomingOffers[offerIndex];
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) {
      throw Exception('Araç bulunamadı');
    }

    final car = state.ownedCars[carIndex];
    final outcome = NegotiationEngine.evaluateCounterOffer(
      currentOffer: offer,
      playerTargetPrice: playerTargetPrice,
      car: car,
      negotiationSkillLevel: state.skills.negotiationLevel,
    );

    List<OfferModel> updatedOffers = List.from(state.incomingOffers);
    if (outcome.isWalkaway) {
      updatedOffers.removeAt(offerIndex);
    } else {
      updatedOffers[offerIndex] = outcome.updatedOffer;
    }

    state = state.copyWith(incomingOffers: updatedOffers);
    _saveState();
    return outcome;
  }

  /// Updates car's listing declaration status (honest, flawless claim, tampered mileage)
  void updateCarListingDeclaration(String carId, ListingDeclarationType declaration) {
    updateCarListingDetails(carId, declaration: declaration);
  }

  /// Updates car's custom listing price and/or declaration status
  void updateCarListingDetails(String carId, {double? customPrice, ListingDeclarationType? declaration}) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return;

    final existing = state.ownedCars[carIndex];
    final updatedCar = existing.copyWith(
      customListingPrice: customPrice,
      declarationType: declaration ?? existing.declarationType,
    );
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    state = state.copyWith(ownedCars: updatedCars);
    _saveState();
  }

  /// Accept offer with fraud inspection evaluation
  FraudInspectionResult? acceptOfferWithFraudCheck(OfferModel offer, CustomerModel customer) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) return null;

    final car = state.ownedCars[carIndex];
    final fraudResult = NegotiationEngine.evaluatePlayerFraudInspection(car: car, customer: customer);

    if (fraudResult.caughtFraud) {
      // Deduct fine (₺10.000) and reputation penalty (-15)
      final newBalance = (state.balance - fraudResult.fineAmount).clamp(0.0, double.infinity);
      final newReputation = (state.reputationScore - fraudResult.reputationPenalty).clamp(0, 100);
      final updatedOffers = state.incomingOffers.where((o) => o.id != offer.id).toList();

      state = state.copyWith(
        balance: newBalance,
        reputationScore: newReputation,
        incomingOffers: updatedOffers,
      );
      _saveState();
      return fraudResult;
    }

    // Honest or uninspected: proceed with standard sale!
    acceptOffer(offer);
    return fraudResult;
  }

  /// Accept an offer and sell car
  void acceptOffer(OfferModel offer) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == offer.carId);
    if (carIndex == -1) return;

    final car = state.ownedCars[carIndex];
    final profit = offer.offeredAmount - car.currentPurchasePrice;

    final updatedCars = state.ownedCars.where((c) => c.id != car.id).toList();
    final updatedOffers = state.incomingOffers.where((o) => o.carId != car.id).toList();
    final updatedPendingOrders = state.pendingOrders.where((o) => o.carId != car.id).toList();

    int newCarsSold = state.carsSold + 1;

    final record = SaleRecordModel(
      id: 'sale_${DateTime.now().millisecondsSinceEpoch}',
      carTitle: '${car.modelYear} ${car.brand} ${car.modelName}',
      buyerName: offer.buyerName,
      purchasePrice: car.currentPurchasePrice,
      salePrice: offer.offeredAmount,
      netProfit: profit,
      saleDay: state.currentDay,
      saleDate: DateTime.now(),
    );

    // Depending on offerType
    double cashReceived = 0.0;
    List<Cheque> updatedCheques = List.from(state.activeCheques);
    List<InstallmentContract> updatedInstallments = List.from(state.activeInstallments);

    if (offer.offerType == OfferType.cash) {
      cashReceived = offer.offeredAmount;
    } else if (offer.offerType == OfferType.cheque) {
      updatedCheques.add(Cheque(
        id: 'cheque_${DateTime.now().millisecondsSinceEpoch}',
        customerName: offer.buyerName,
        amount: offer.offeredAmount,
        daysUntilDue: 30, // 1 month
      ));
    } else if (offer.offerType == OfferType.installment) {
      updatedInstallments.add(InstallmentContract(
        id: 'inst_${DateTime.now().millisecondsSinceEpoch}',
        customerName: offer.buyerName,
        totalAmount: offer.offeredAmount,
        paidAmount: 0.0,
        installmentAmount: offer.offeredAmount / 5,
        totalInstallments: 5,
        paidInstallments: 0,
        daysUntilNextPayment: 30,
      ));
    }

    state = state.copyWith(
      balance: state.balance + cashReceived,
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      pendingOrders: updatedPendingOrders,
      activeCheques: updatedCheques,
      activeInstallments: updatedInstallments,
      totalProfit: state.totalProfit + profit,
      carsSold: newCarsSold,
      salesHistory: [record, ...state.salesHistory],
    );

    addXP(100 + (profit > 0 ? (profit / 1000).round() : 0));
    _checkAchievement('first_sale');
    _updateMissionProgress(MissionType.sellCars, 1);
    if (profit > 0) {
      _updateMissionProgress(MissionType.earnProfit, profit.round());
    }
    if (state.totalProfit >= 250000) _checkAchievement('dealer_baron');

    if (!state.tutorialCompleted) {
      completeTutorial();
    }

    _saveState();
  }

  /// Reject an offer
  void rejectOffer(String offerId) {
    final updatedOffers = state.incomingOffers.where((o) => o.id != offerId).toList();
    state = state.copyWith(incomingOffers: updatedOffers);
    _saveState();
  }

  /// Add a new offer
  void addOffer(OfferModel offer) {
    state = state.copyWith(incomingOffers: [...state.incomingOffers, offer]);
    _saveState();
  }

  /// Complete & Claim Mission Reward
  bool claimMissionReward(String missionId) {
    final missionIndex = state.activeMissions.indexWhere((m) => m.id == missionId);
    if (missionIndex == -1) return false;

    final mission = state.activeMissions[missionIndex];
    if (mission.currentProgress < mission.targetGoal || mission.isCompleted) return false;

    final updatedMission = mission.copyWith(isCompleted: true);
    final updatedMissions = List<MissionModel>.from(state.activeMissions);
    updatedMissions[missionIndex] = updatedMission;

    state = state.copyWith(
      balance: state.balance + mission.rewardMoney,
      activeMissions: updatedMissions,
    );

    addXP(mission.rewardXP);
    _saveState();
    return true;
  }

  void _updateMissionProgress(MissionType type, int amount) {
    final updatedMissions = state.activeMissions.map((m) {
      if (m.type == type && !m.isCompleted) {
        final newProgress = (m.currentProgress + amount).clamp(0, m.targetGoal);
        return m.copyWith(
          currentProgress: newProgress,
          isCompleted: newProgress >= m.targetGoal,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(activeMissions: updatedMissions);
  }

  /// Upgrade player skill
  bool upgradeSkill(String skillName) {
    final skills = state.skills;
    if (skills.availableSkillPoints <= 0) return false;

    PlayerSkills updated;
    switch (skillName) {
      case 'negotiation':
        if (skills.negotiationLevel >= 10) return false;
        updated = skills.copyWith(negotiationLevel: skills.negotiationLevel + 1);
        break;
      case 'eyeForDetail':
        if (skills.eyeForDetail >= 10) return false;
        updated = skills.copyWith(eyeForDetail: skills.eyeForDetail + 1);
        break;
      case 'marketSense':
        if (skills.marketSense >= 10) return false;
        updated = skills.copyWith(marketSense: skills.marketSense + 1);
        break;
      case 'reputation':
        if (skills.reputation >= 10) return false;
        updated = skills.copyWith(reputation: skills.reputation + 1);
        break;
      default:
        return false;
    }

    state = state.copyWith(skills: updated);
    _saveState();
    return true;
  }

  /// Add XP
  void addXP(int amount) {
    final updatedSkills = state.skills.copyWith(xp: state.skills.xp + amount);
    state = state.copyWith(skills: updatedSkills);
  }

  /// Take bank loan (e.g. ₺100.000, ₺250.000, ₺500.000)
  bool takeBankLoan({required String bankName, required double amount, required int months}) {
    if (state.activeLoans.length >= 3) return false; // Max 3 active loans guard!

    final interestRate = months == 3 ? 0.10 : (months == 6 ? 0.18 : 0.28);
    final totalRepayment = amount * (1.0 + interestRate);
    final monthlyPayment = totalRepayment / months;

    final loan = LoanModel(
      id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      principalAmount: amount,
      interestRate: interestRate,
      totalRepayment: totalRepayment,
      remainingAmount: totalRepayment,
      totalInstallments: months,
      remainingInstallments: months,
      monthlyPayment: monthlyPayment,
    );

    state = state.copyWith(
      balance: state.balance + amount,
      activeLoans: [...state.activeLoans, loan],
    );
    _saveState();
    return true;
  }

  /// Pay installment for bank loan
  bool payLoanInstallment(String loanId) {
    final index = state.activeLoans.indexWhere((l) => l.id == loanId);
    if (index == -1) return false;

    final loan = state.activeLoans[index];
    if (state.balance < loan.monthlyPayment) return false;

    final newRemaining = loan.remainingAmount - loan.monthlyPayment;
    final newInstallments = loan.remainingInstallments - 1;

    List<LoanModel> updatedLoans = List<LoanModel>.from(state.activeLoans);
    if (newInstallments <= 0 || newRemaining <= 0) {
      updatedLoans.removeAt(index);
    } else {
      updatedLoans[index] = loan.copyWith(
        remainingAmount: newRemaining,
        remainingInstallments: newInstallments,
      );
    }

    state = state.copyWith(
      balance: state.balance - loan.monthlyPayment,
      activeLoans: updatedLoans,
    );
    _saveState();
    return true;
  }

  /// Check & unlock achievement
  void _checkAchievement(String id) {
    final list = state.achievements.map((a) {
      if (a.id == id && !a.isUnlocked) {
        return a.copyWith(isUnlocked: true);
      }
      return a;
    }).toList();

    state = state.copyWith(achievements: list);
  }

  /// Add rewarded ad balance boost
  void claimAdReward(double rewardAmount) {
    state = state.copyWith(balance: state.balance + rewardAmount);
    _saveState();
  }

  /// Place a part order or master repair request
  bool orderPart({
    required String carId,
    required String partName,
    required OrderType orderType,
    required double cost,
    required int deliveryDurationSeconds,
  }) {
    if (state.balance < cost) return false;

    final newOrder = PartOrderModel(
      id: 'order_${DateTime.now().millisecondsSinceEpoch}',
      carId: carId,
      partName: partName,
      orderType: orderType,
      cost: cost,
      orderedAt: DateTime.now(),
      deliveryDurationSeconds: deliveryDurationSeconds,
    );

    final updatedOrders = List<PartOrderModel>.from(state.pendingOrders)..add(newOrder);

    state = state.copyWith(
      balance: state.balance - cost,
      pendingOrders: updatedOrders,
    );
    _saveState();
    return true;
  }

  /// Perform an instant repair without placing an order (for Quick Patch)
  bool instantRepair({
    required String carId,
    required String partName,
    required OrderType orderType,
    required double cost,
  }) {
    if (state.balance < cost) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final restoredCar = RepairEngine.applyInstalledPart(car, partName, orderType);

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = restoredCar;

    state = state.copyWith(
      balance: state.balance - cost,
      ownedCars: updatedCars,
    );
    _saveState();
    return true;
  }

  /// Install a delivered part order onto the car
  bool installDeliveredPart(String orderId) {
    final orderIndex = state.pendingOrders.indexWhere((o) => o.id == orderId);
    if (orderIndex == -1) return false;

    final order = state.pendingOrders[orderIndex];
    if (!order.isDelivered) return false;

    final carIndex = state.ownedCars.indexWhere((c) => c.id == order.carId);
    if (carIndex == -1) return false;

    final car = state.ownedCars[carIndex];
    final restoredCar = RepairEngine.applyInstalledPart(car, order.partName, order.orderType);

    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = restoredCar;

    final updatedOrders = List<PartOrderModel>.from(state.pendingOrders)..removeAt(orderIndex);

    state = state.copyWith(
      ownedCars: updatedCars,
      pendingOrders: updatedOrders,
    );
    _saveState();
    return true;
  }

  /// Advance tutorial step index
  void advanceTutorialStep(int nextStepIndex) {
    state = state.copyWith(tutorialStepIndex: nextStepIndex);
    _saveState();
  }

  /// Complete initial guided tutorial after first car sale
  void completeTutorial() {
    if (state.tutorialCompleted) return; // Prevent duplicate rewards
    state = state.copyWith(
      tutorialCompleted: true,
      balance: state.balance + 50000.0, // Bonus capital reward for completing tutorial!
    );
    _saveState();
  }

  /// Update player identity, gallery title and logo emblem
  void updateDealershipIdentity({
    String? playerName,
    String? dealershipName,
    String? logoEmblemId,
  }) {
    state = state.copyWith(
      playerName: playerName ?? state.playerName,
      dealershipName: dealershipName ?? state.dealershipName,
      logoEmblemId: logoEmblemId ?? state.logoEmblemId,
    );
    _saveState();
  }

  /// Reset progress
  void resetGame() {
    state = DealershipModel.initial();
    _saveState();
  }

  /// Rent a Car
  bool rentCar(String carId, double dailyRate) {
    final carIndex = state.ownedCars.indexWhere((c) => c.id == carId);
    if (carIndex == -1) return false;
    
    final car = state.ownedCars[carIndex];
    if (car.isRented) return false;

    final updatedCar = car.copyWith(isRented: true);
    final updatedCars = List<CarModel>.from(state.ownedCars);
    updatedCars[carIndex] = updatedCar;

    final agreement = RentalAgreement(
      id: 'rent_${DateTime.now().millisecondsSinceEpoch}',
      carId: carId,
      dailyRate: dailyRate,
    );

    state = state.copyWith(
      ownedCars: updatedCars,
      activeRentals: [...state.activeRentals, agreement],
    );
    _saveState();
    return true;
  }

  /// Return Rented Car
  bool returnRentedCar(String agreementId) {
    final rentalIndex = state.activeRentals.indexWhere((r) => r.id == agreementId);
    if (rentalIndex == -1) return false;

    final rental = state.activeRentals[rentalIndex];
    
    final carIndex = state.ownedCars.indexWhere((c) => c.id == rental.carId);
    if (carIndex != -1) {
      final updatedCar = state.ownedCars[carIndex].copyWith(isRented: false);
      final updatedCars = List<CarModel>.from(state.ownedCars);
      updatedCars[carIndex] = updatedCar;
      
      final updatedRentals = List<RentalAgreement>.from(state.activeRentals);
      updatedRentals.removeAt(rentalIndex);

      state = state.copyWith(
        ownedCars: updatedCars,
        activeRentals: updatedRentals,
      );
      _saveState();
      return true;
    }
    return false;
  }
}
