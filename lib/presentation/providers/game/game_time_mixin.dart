import 'dart:async';
import 'dart:math';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/iterable_extensions.dart';

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
import '../../../data/models/story_card_model.dart';
import '../../../data/models/dramatic_card_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/trade_in_offer_model.dart';
import '../../../domain/usecases/mission_factory.dart';
import '../../../domain/usecases/dramatic_card_engine.dart';
import '../../../domain/usecases/random_event_engine.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/trade_in_engine.dart';
import '../../../domain/usecases/gossip_engine.dart';
import '../../../domain/usecases/weather_engine.dart';
import '../../../domain/usecases/consignment_engine.dart';

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
    List<GameEventModel> newEvents = List.from(state.recentEvents);
    List<StaffModel> currentStaff = List.from(state.hiredStaff);
    List<CarModel> currentCars = List.from(state.ownedCars);

    newBalance = _processDailyPropertyBurn(newBalance);
    final salaryResult = _processSalaries(newBalance, currentStaff, newEvents);
    newBalance = salaryResult.$1;
    currentStaff = salaryResult.$2;
    newEvents = salaryResult.$3;

    currentCars = _processStaffAutomation(currentStaff, currentCars);
    if (currentStaff.any((s) => s.role == StaffRole.salesman) && currentCars.any((c) => c.isListed && !c.isRented)) {
      triggerOrganicOffers();
    }

    final loanResult = _processLoans(nextDay, newBalance, List.from(state.activeLoans));
    newBalance = loanResult.$1;
    final updatedLoans = loanResult.$2;
    
    final rentalResult = _processRentals(newBalance, currentCars, List.from(state.activeRentals), newEvents, List.from(state.incomingOffers));
    newBalance = rentalResult.$1;
    currentCars = rentalResult.$2;
    final updatedRentals = rentalResult.$3;
    newEvents = rentalResult.$4;
    final offersAfterRentals = rentalResult.$5;

    final installResult = _processInstallments(newBalance, List.from(state.activeInstallments));
    newBalance = installResult.$1;
    final updatedInstallments = installResult.$2;

    final chequeResult = _processCheques(newBalance, List.from(state.activeCheques));
    newBalance = chequeResult.$1;
    final updatedCheques = chequeResult.$2;

    final bkResult = _processBankruptcy(nextDay, newBalance, currentCars, updatedLoans, List.from(state.dynastyHistoryLog), newEvents);
    newBalance = bkResult.$1;
    currentCars = bkResult.$2;
    final activeLoansAfterBk = bkResult.$3;
    final updatedDynastyHistory = bkResult.$4;
    newEvents = bkResult.$5;

    final bizResult = _processSideBusinesses(newBalance, currentCars, List.from(state.sideBusinesses));
    newBalance = bizResult.$1;
    final updatedBusinesses = bizResult.$2;

    final stockResult = _processStockMarketAndDividends(nextDay, newBalance, List.from(state.marketStocks), state.ownedStocks, newEvents);
    final updatedStocks = stockResult.$1;
    newBalance = stockResult.$2;
    newEvents = stockResult.$3;

    final updatedForex = _processForexMarket(List.from(state.marketForex));
    final ipoResult = _processIpoMarket(nextDay, newBalance, List.from(state.activeIpos), List.from(state.playerIpoRequests), newEvents);
    final updatedIpos = ipoResult.$1;
    final updatedIpoReqs = ipoResult.$2;
    newBalance = ipoResult.$3;
    newEvents = ipoResult.$4;

    newBalance = _processDailyTax(newBalance);
    newEvents = _createDailySummaryEvent(nextDay, newBalance, newEvents);
    final currentNews = _processMarketNews(nextDay, state.activeNews);

    final scrapAndBlack = _processScrapyardAndBlackMarket(nextDay, List.from(state.scrapyardCars), List.from(state.blackMarketCars));
    final currentScrapCars = scrapAndBlack.$1;
    final currentBlackCars = scrapAndBlack.$2;

    final storyAd = _processStoryAd(state.daysSinceLastStoryAd, state.nextStoryAdTargetDays, state.pendingStoryCard);
    final dramatic = _processDramaticDecision(state.daysSinceLastDramaticCard, state.nextDramaticCardTargetDays, state.pendingDramaticCard);
    final randomEvent = _processRandomEvents(state.daysSinceLastRandomEvent, state.nextRandomEventTargetDays, state.pendingRandomEvent, List.from(state.seenRandomEventIds));

    currentCars = _processListingsAmortization(currentCars);

    // 1. Process Consignment Vehicle Remaining Days & Expiry Return & Daily Parking Fees
    final consignmentResult = _processConsignmentDays(currentCars, newEvents);
    currentCars = consignmentResult.$1;
    newBalance += consignmentResult.$2;
    newEvents = consignmentResult.$3;

    // 2. Process Black Market Police Raid Risk
    int currentReputation = state.reputationScore;
    final raidResult = _processBlackMarketRaid(newBalance, currentCars, currentReputation, newEvents);
    newBalance = raidResult.$1;
    currentCars = raidResult.$2;
    currentReputation = raidResult.$3;
    newEvents = raidResult.$4;

    // 3. Process Showroom Nighttime Vandalism vs Security CCTV
    final vandalismResult = _processVandalism(currentCars, newEvents);
    currentCars = vandalismResult.$1;
    newEvents = vandalismResult.$2;

    final dispute = _processDisputes(nextDay, newBalance, state.pendingDisputeNotice, newEvents);
    newBalance = dispute.$1;
    final currentDisputeNotice = dispute.$2;
    newEvents = dispute.$3;

    final updatedIncomingOffers = _processLoyalCustomerOffers(currentCars, offersAfterRentals);
    final updatedBankDeposit = _processBankInterest(state.bankDepositBalance);
    final updatedMissions = _processDailyMissions(List.from(state.activeMissions));
    final updatedContracts = _processVIPContracts(List.from(state.activeContracts));
    
    final nextWeather = WeatherEngine.getWeatherForDay(nextDay);
    final dailyGossips = GossipEngine.generateDailyGossips(nextDay);
    final updatedTradeOffers = _processTradeInOffers(nextDay, currentCars, List.from(state.incomingTradeInOffers));
    final updatedConsignmentOffers = _processConsignmentOffers(nextDay, List.from(state.consignmentOffers));
    final updatedB2BOrders = (nextDay % 2 == 0 || state.b2bPartOrders.isEmpty)
        ? B2BPartOrder.generateDailyOrders(nextDay)
        : state.b2bPartOrders;

    // Showroom Decor & District Traffic Boosts
    final hasLedGrid = state.hasDecor('decor_led_grid');
    final hasGranite = state.hasDecor('decor_granite_floor');
    final hasTotem = state.hasDecor('decor_led_totem_sign');
    final bagcilarDominance = (state.districtMarketShare['Bağcılar Oto Pazarı'] ?? 0.0) >= 0.50;
    if ((hasLedGrid || hasGranite || hasTotem || bagcilarDominance) && currentCars.any((c) => c.isListed && !c.isRented)) {
      triggerOrganicOffers();
    }

    state = state.copyWith(
      currentDay: nextDay,
      balance: newBalance,
      reputationScore: currentReputation,
      ownedCars: currentCars,
      hiredStaff: currentStaff,
      activeLoans: activeLoansAfterBk,
      activeRentals: updatedRentals,
      activeInstallments: updatedInstallments,
      activeCheques: updatedCheques,
      sideBusinesses: updatedBusinesses,
      marketStocks: updatedStocks,
      marketForex: updatedForex,
      activeIpos: updatedIpos,
      playerIpoRequests: updatedIpoReqs,
      recentEvents: newEvents,
      activeNews: currentNews,
      scrapyardCars: currentScrapCars,
      blackMarketCars: currentBlackCars,
      b2bPartOrders: updatedB2BOrders,
      daysSinceLastStoryAd: storyAd.$1,
      nextStoryAdTargetDays: storyAd.$2,
      pendingStoryCard: storyAd.$3,
      daysSinceLastDramaticCard: dramatic.$1,
      nextDramaticCardTargetDays: dramatic.$2,
      pendingDramaticCard: dramatic.$3,
      daysSinceLastRandomEvent: randomEvent.$1,
      nextRandomEventTargetDays: randomEvent.$2,
      pendingRandomEvent: randomEvent.$3,
      seenRandomEventIds: randomEvent.$4,
      bankDepositBalance: updatedBankDeposit,
      activeMissions: updatedMissions,
      activeContracts: updatedContracts,
      incomingOffers: updatedIncomingOffers,
      dynastyHistoryLog: updatedDynastyHistory,
      pendingDisputeNotice: currentDisputeNotice,
      currentWeather: nextWeather,
      activeGossips: dailyGossips,
      incomingTradeInOffers: updatedTradeOffers,
      consignmentOffers: updatedConsignmentOffers,
      dailyRacesRemaining: 3, // Her gün 3 yarış hakkı yenilenir
    );

    refreshMarketTrends();
  }

  // --- Helper Methods ---

  double _processDailyPropertyBurn(double balance) {
    double burn = 300.0;
    if (state.unlockedBuildings.contains('property_tier_8')) {
      burn = 75000.0;
    } else if (state.unlockedBuildings.contains('property_tier_7')) {
      burn = 40000.0;
    } else if (state.unlockedBuildings.contains('property_tier_6')) {
      burn = 20000.0;
    } else if (state.unlockedBuildings.contains('property_tier_5')) {
      burn = 9500.0;
    } else if (state.unlockedBuildings.contains('property_tier_4')) {
      burn = 4200.0;
    } else if (state.unlockedBuildings.contains('property_tier_3')) {
      burn = 1800.0;
    } else if (state.unlockedBuildings.contains('property_tier_2')) {
      burn = 750.0;
    }
    return balance - burn;
  }

  (double, List<StaffModel>, List<GameEventModel>) _processSalaries(
      double balance, List<StaffModel> staff, List<GameEventModel> events) {
    if (staff.isEmpty) return (balance, staff, events);
    
    double totalSalaries = staff.fold(0.0, (s, st) => s + st.dailySalary);
    if (state.specializationPath == SpecializationPath.boss) totalSalaries *= 0.80;
    
    if (balance >= totalSalaries) {
      final updated = staff.map((s) => s.copyWith(morale: min(100, s.morale + 1))).toList();
      return (balance - totalSalaries, updated, events);
    } else {
      final remainingStaff = <StaffModel>[];
      final resignedStaff = <StaffModel>[];

      for (final s in staff) {
        final newMorale = s.morale - 35;
        if (newMorale <= 10) {
          resignedStaff.add(s);
        } else {
          remainingStaff.add(s.copyWith(morale: newMorale));
        }
      }

      if (resignedStaff.isNotEmpty) {
        final names = resignedStaff.map((s) => '${s.name} (${s.role.name})').join(', ');
        events.insert(0, GameEventModel(
          id: 'staff_resignation_${DateTime.now().millisecondsSinceEpoch}',
          title: 'PERSONEL İSTİFASI!',
          description: 'Maaş ödemeleri yapılamadığı için $names morali tükenerek galerinizi terk etti ve istifa etti!',
          type: GameEventType.expense,
          amount: 0.0,
          date: DateTime.now(),
        ));
      } else {
        events.insert(0, GameEventModel(
          id: 'salary_unpaid_${DateTime.now().millisecondsSinceEpoch}',
          title: 'MAAŞLAR ÖDENEMEDİ!',
          description: 'Kasada yeterli nakit olmadığı için personellerin günlük maaşı ödenemedi. Personel morali ağır darbe aldı (-35 Moral)!',
          type: GameEventType.expense,
          amount: 0.0,
          date: DateTime.now(),
        ));
      }

      return (balance, remainingStaff, events);
    }
  }

  List<CarModel> _processStaffAutomation(List<StaffModel> staff, List<CarModel> cars) {
    final hasWasher = staff.any((s) => s.role == StaffRole.washer);
    final hasMechanic = staff.any((s) => s.role == StaffRole.masterMechanic);

    if (hasWasher && cars.isNotEmpty) {
      int washedCount = 0;
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i];
        if (!car.isWashed || !car.isPolished || !car.isDetailedCleaned) {
          cars[i] = car.copyWith(isWashed: true, isPolished: true, isDetailedCleaned: true);
          washedCount++;
          if (washedCount >= 2) break;
        }
      }
    }

    if (hasMechanic && cars.isNotEmpty) {
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i];
        if (car.expertise.engineCondition < 100 || car.expertise.transmissionCondition < 100) {
          final newEngine = min(100.0, car.expertise.engineCondition + 20.0);
          final newTrans = min(100.0, car.expertise.transmissionCondition + 20.0);
          cars[i] = car.copyWith(expertise: car.expertise.copyWith(engineCondition: newEngine, transmissionCondition: newTrans));
          break;
        }
      }
    }
    return cars;
  }

  (double, List<LoanModel>) _processLoans(int nextDay, double balance, List<LoanModel> loans) {
    if (nextDay % 7 != 0 || loans.isEmpty) return (balance, loans);
    
    for (int i = loans.length - 1; i >= 0; i--) {
      final loan = loans[i];
      balance -= loan.monthlyPayment;
      final newRemaining = loan.remainingAmount - loan.monthlyPayment;
      final newInstallments = loan.remainingInstallments - 1;
      
      if (newInstallments <= 0 || newRemaining <= 0) {
        loans.removeAt(i);
      } else {
        loans[i] = loan.copyWith(remainingAmount: newRemaining, remainingInstallments: newInstallments);
      }
    }
    return (balance, loans);
  }

  (double, List<CarModel>, List<RentalAgreement>, List<GameEventModel>, List<OfferModel>) _processRentals(
      double balance,
      List<CarModel> cars,
      List<RentalAgreement> rentals,
      List<GameEventModel> events,
      List<OfferModel> incomingOffers) {
    for (int i = rentals.length - 1; i >= 0; i--) {
      final rental = rentals[i];
      final insuranceFee = rental.hasInsurance ? rental.insuranceDailyFee : 0.0;
      final netDaily = (rental.dailyRate - insuranceFee).clamp(0.0, double.infinity);
      balance += netDaily;
      
      final carIndex = cars.indexWhere((c) => c.id == rental.carId);
      if (carIndex != -1) {
        CarModel car = cars[carIndex];
        final riskMultiplier = rental.renterType == 'young_driver' ? 1.4 : (rental.renterType == 'corporate' ? 0.2 : 0.6);
        final roll = random.nextDouble();

        // 1. EDS & Hız Radarı Cezası (%2 * multiplier)
        if (roll < 0.020 * riskMultiplier) {
          final fineBase = 4500.0 + random.nextInt(4000);
          final actualCost = (rental.hasInsurance || rental.renterType == 'corporate') ? fineBase * 0.20 : fineBase;
          balance = (balance - actualCost).clamp(0.0, double.infinity);
          events.insert(0, GameEventModel(
            id: 'rental_fine_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: RADAR & EDS CEZASI!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} ile hız sınırını aştı (₺${fineBase.toInt()} ceza tebliğ edildi${rental.hasInsurance ? ', Kasko & kurumsal sözleşme sayesinde ₺${actualCost.toInt()} ödendi' : ''}).',
            type: GameEventType.expense,
            amount: -actualCost,
            date: DateTime.now(),
          ));
        }
        // 2. Düğün Konvoyu Yanlama & Şanzıman Hasarı (%1.5 * multiplier)
        else if (roll < 0.035 * riskMultiplier) {
          final repairDeductible = rental.hasInsurance ? 1000.0 : 4000.0;
          balance = (balance - repairDeductible).clamp(0.0, double.infinity);
          final newTrans = max(10.0, car.expertise.transmissionCondition - 20.0);
          final newEngine = max(10.0, car.expertise.engineCondition - 10.0);
          car = car.copyWith(
            isWashed: false,
            isPolished: false,
            expertise: car.expertise.copyWith(
              transmissionCondition: newTrans,
              engineCondition: newEngine,
            ),
          );
          events.insert(0, GameEventModel(
            id: 'rental_drift_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KONVOYDA AŞIRI YIPRANMA!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} aracında debriyajı yakmış ve lastikleri eritmiş (-%20 Şanzıman, -%10 Motor, ₺${repairDeductible.toInt()} masraf).',
            type: GameEventType.expense,
            amount: -repairDeductible,
            date: DateTime.now(),
          ));
        }
        // 3. Ağır Kaza & Tramer Kaydı (%0.8 * multiplier)
        else if (roll < 0.043 * riskMultiplier) {
          final tramerAdd = 25000 + (random.nextInt(5) * 5000);
          final outOfPocket = rental.hasInsurance ? 3000.0 : 12000.0;
          balance = (balance - outOfPocket).clamp(0.0, double.infinity);
          car = car.copyWith(
            expertise: car.expertise.copyWith(
              tramerAmount: car.expertise.tramerAmount + tramerAdd,
              engineCondition: max(10.0, car.expertise.engineCondition - 25.0),
              transmissionCondition: max(10.0, car.expertise.transmissionCondition - 15.0),
            ),
          );
          events.insert(0, GameEventModel(
            id: 'rental_crash_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: TRAFİK KAZASI HASARI!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} ile refüje çarptı (+₺$tramerAdd Tramer işlendi${rental.hasInsurance ? ', Ticari Kasko hasarı karşıladı (₺3.000 muafiyet ödendi)' : ', Kasko olmadığı için ₺12.000 masraf yapıldı'}).',
            type: GameEventType.expense,
            amount: -outOfPocket,
            date: DateTime.now(),
          ));
        }
        // 4. Korsan Taşımacılık / Otoparka Çekilme (%0.4 * multiplier, only individual & young_driver)
        else if (roll < 0.047 * riskMultiplier && rental.renterType != 'corporate') {
          const impoundFine = 8000.0;
          balance = (balance - impoundFine).clamp(0.0, double.infinity);
          events.insert(0, GameEventModel(
            id: 'rental_impound_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRALIK ARAÇ: KORSAN TAŞIMA & MEN!',
            description: '${rental.renterName}, ${car.brand} ${car.modelName} ile izinsiz yolcu taşırken polis çevirmesine girdi! Araç otoparka çekildi ve ₺8.000 idari ceza kesildi.',
            type: GameEventType.expense,
            amount: -impoundFine,
            date: DateTime.now(),
          ));
        }
        // 5. Kiracının Aracı Satın Alma Teklifi (%2.5 şans)
        else if (roll > (1.0 - 0.025)) {
          final carVal = car.currentPurchasePrice > 0 ? car.currentPurchasePrice : car.baseMarketValue;
          final offerPrice = (carVal * 1.15).roundToDouble();
          final buyoutOffer = OfferModel(
            id: 'offer_rent_buyout_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            carId: car.id,
            buyerName: '${rental.renterName} (Kiracı)',
            offeredAmount: offerPrice,
            buyerMessage: 'Aracınızdan son derece memnun kaldım. Kiralamayı bitirip aracı doğrudan satın almak istiyorum.',
            createdAt: DateTime.now(),
            offerType: OfferType.cash,
          );
          incomingOffers.insert(0, buyoutOffer);
          events.insert(0, GameEventModel(
            id: 'rental_buyout_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'KİRACIDAN SATIN ALMA TEKLİFİ!',
            description: '${rental.renterName}, kiraladığı ${car.brand} ${car.modelName} için piyasa değerinin %15 fazlasına (₺${offerPrice.toInt()}) peşin teklif sundu!',
            type: GameEventType.goodEvent,
            amount: offerPrice,
            date: DateTime.now(),
          ));
        }

        cars[carIndex] = car;
      }
      rentals[i] = rental.copyWith(
        rentedDays: rental.rentedDays + 1,
        totalEarned: rental.totalEarned + netDaily,
      );
    }
    return (balance, cars, rentals, events, incomingOffers);
  }

  (double, List<InstallmentContract>) _processInstallments(double balance, List<InstallmentContract> installments) {
    for (int i = installments.length - 1; i >= 0; i--) {
      final contract = installments[i];
      int remainingDays = contract.daysUntilNextPayment - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < 0.05) {
          balance += (contract.totalAmount - contract.paidAmount) * 0.5;
          installments.removeAt(i);
        } else if (random.nextDouble() < 0.10) {
          installments[i] = contract.copyWith(daysUntilNextPayment: 5, isDefaulted: true);
        } else {
          balance += contract.installmentAmount;
          int newPaidInstallments = contract.paidInstallments + 1;
          if (newPaidInstallments >= contract.totalInstallments) {
            installments.removeAt(i);
          } else {
            installments[i] = contract.copyWith(
              paidAmount: contract.paidAmount + contract.installmentAmount,
              paidInstallments: newPaidInstallments,
              daysUntilNextPayment: 30,
              isDefaulted: false,
            );
          }
        }
      } else {
        installments[i] = contract.copyWith(daysUntilNextPayment: remainingDays);
      }
    }
    return (balance, installments);
  }

  (double, List<Cheque>) _processCheques(double balance, List<Cheque> cheques) {
    final double chequeBounceRisk = (0.05 - state.skills.chequeRiskReduction).clamp(0.005, 0.05);
    for (int i = cheques.length - 1; i >= 0; i--) {
      final cheque = cheques[i];

      // Handle legal collection progression
      if (cheque.inLegalCollection) {
        int legalDays = cheque.legalCollectionDaysRemaining - 1;
        if (legalDays <= 0) {
          final recovered = cheque.amount * 0.75;
          balance += recovered;
          cheques.removeAt(i);
        } else {
          cheques[i] = cheque.copyWith(legalCollectionDaysRemaining: legalDays);
        }
        continue;
      }

      int remainingDays = cheque.daysUntilDue - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < chequeBounceRisk) {
          cheques[i] = cheque.copyWith(daysUntilDue: 0, isDefaulted: true);
        } else {
          balance += cheque.amount;
          cheques.removeAt(i);
        }
      } else {
        cheques[i] = cheque.copyWith(daysUntilDue: remainingDays);
      }
    }
    return (balance, cheques);
  }

  (double, List<CarModel>, List<LoanModel>, List<String>, List<GameEventModel>) _processBankruptcy(
    int nextDay, double balance, List<CarModel> cars, List<LoanModel> loans, List<String> dynasty, List<GameEventModel> events) {
    double liquidatableValue = cars.fold(0.0, (s, c) => s + c.estimatedRealValue * 0.70) + state.bankDepositBalance;

    if (balance < -50000.0) {
      final unlistedSeizableCarIndex = cars.indexWhere((c) => !c.isLockedInShowcase && !c.isRented);
      if (unlistedSeizableCarIndex != -1 && balance < -100000.0) {
        final seizedCar = cars.removeAt(unlistedSeizableCarIndex);
        final recovery = (seizedCar.estimatedRealValue * 0.60).roundToDouble();
        balance += recovery;
        events.insert(0, GameEventModel(
          id: 'bailiff_seize_$nextDay',
          title: 'İcra Dairesi Haciz Tebliği!',
          description: 'Aşırı borç nedeniyle ${seizedCar.brand} ${seizedCar.modelName} icra memurlarınca ₺${recovery.round()} bedelle tasfiye edildi.',
          type: GameEventType.expense,
          amount: recovery,
          date: DateTime.now(),
        ));
      } else if (balance < 0 && (liquidatableValue + balance) < 15000.0) {
        balance = 25000.0;
        loans.clear();
        dynasty.add('Gün $nextDay: Galeri konkordato ilan etti, borçlar yapılandırılarak taze başlangıç yapıldı.');
        events.insert(0, GameEventModel(
          id: 'concordat_$nextDay',
          title: 'Konkordato & Yapılandırma Kararı!',
          description: 'Mahkeme galeri konkordato talebini onayladı. Borçlar donduruldu, ₺25.000 taze can suyu ile faaliyetler sürüyor.',
          type: GameEventType.income,
          amount: 25000.0,
          date: DateTime.now(),
        ));
      }
    }
    return (balance, cars, loans, dynasty, events);
  }

  (double, List<SideBusinessModel>) _processSideBusinesses(double balance, List<CarModel> cars, List<SideBusinessModel> businesses) {
    final double businessMultiplier = state.specializationPath == SpecializationPath.boss ? 1.30 : 1.0;
    for (int i = 0; i < businesses.length; i++) {
      final b = businesses[i];
      if (b.isOwned) {
        final income = b.effectiveIncomeWithUtilization(
          washedLast7Days: state.carsWashedLast7Days,
          expertisesLast7Days: state.expertisesPerformedLast7Days,
          listedCarsCount: cars.where((c) => c.isListed).length,
          partsRepairedLast7Days: state.partsRepairedLast7Days,
          towedCarsLast7Days: state.towedCarsLast7Days,
          activeRentalsCount: state.activeRentals.length,
        ) * businessMultiplier;
        balance += income;
        businesses[i] = b.copyWith(totalEarned: b.totalEarned + income);
      }
    }
    return (balance, businesses);
  }

  (List<CarModel>, double, List<GameEventModel>) _processConsignmentDays(List<CarModel> cars, List<GameEventModel> events) {
    final updated = <CarModel>[];
    double dailyParkingEarnings = 0.0;
    final parkingPerCar = ConsignmentEngine.calculateDailyParkingFee(state.currentBranchTier);

    for (final car in cars) {
      if (car.isConsignment) {
        dailyParkingEarnings += parkingPerCar;
        final daysLeft = car.consignmentDaysRemaining - 1;
        if (daysLeft <= 0) {
          events.insert(0, GameEventModel(
            id: 'consignment_expired_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Emanet Araç Süresi Doldu',
            description: '${car.consignmentOwnerName ?? "Sahibi"}, ${car.brand} ${car.modelName} emanet süresi dolduğu için aracı teslim aldı.',
            amount: 0.0,
            type: GameEventType.neutral,
            date: DateTime.now(),
          ));
        } else {
          updated.add(car.copyWith(consignmentDaysRemaining: daysLeft));
        }
      } else {
        updated.add(car);
      }
    }

    if (dailyParkingEarnings > 0) {
      events.insert(0, GameEventModel(
        id: 'consignment_parking_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Emanet Otopark & Sergileme Geliri',
        description: 'Vitrindeki emanet araçlardan günlük toplam +₺${dailyParkingEarnings.round()} sergileme ücreti kazanıldı.',
        amount: dailyParkingEarnings,
        type: GameEventType.income,
        date: DateTime.now(),
      ));
    }

    return (updated, dailyParkingEarnings, events);
  }

  (double, List<CarModel>, int, List<GameEventModel>) _processBlackMarketRaid(
      double balance, List<CarModel> cars, int reputation, List<GameEventModel> events) {
    final hasGossipWarning = state.activeGossips.any((g) => g.id == 'gossip_police_raid' && g.isPurchased);
    final hasLegalAdvisor = state.hiredStaff.any((s) => s.role == StaffRole.legalAdvisor);

    // Find all black market cars in inventory
    final bmIndices = <int>[];
    for (int i = 0; i < cars.length; i++) {
      final c = cars[i];
      if (c.isBlackMarket || c.modelName.contains('Karaborsa') || c.id.startsWith('bm_')) {
        bmIndices.add(i);
      }
    }

    if (bmIndices.isEmpty) {
      return (balance, cars, reputation, events);
    }

    final carsToRemove = <CarModel>[];

    for (final idx in bmIndices) {
      final car = cars[idx];
      final riskRate = (car.blackMarketRiskPercent > 0 ? car.blackMarketRiskPercent : 25) / 100.0;
      final hasNazarPrayer = state.hasDecor('decor_nazar_prayer_frame');
      final adjustedChance = riskRate * (hasNazarPrayer ? 0.85 : 1.0);

      if (random.nextDouble() < adjustedChance) {
        if (hasGossipWarning) {
          events.insert(0, GameEventModel(
            id: 'gossip_evaded_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
            title: 'İSTİHBARAT SAYESİNDE BASKIN ATLATILDI!',
            description: 'Kahvehaneden satın aldığınız "Polis Baskını" istihbaratı sayesinde ${car.brand} ${car.modelName} aracını önceden gizli depoya çektiniz. Denetim ekibi galeride hiçbir kusur bulamadı!',
            type: GameEventType.goodEvent,
            amount: 0.0,
            date: DateTime.now(),
          ));
          continue;
        }

        final riskType = car.blackMarketRiskType ?? 'change_vin';

        switch (riskType) {
          case 'change_vin':
            if (random.nextDouble() < 0.60) {
              final rawFine = 35000.0;
              final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
              final repLoss = hasLegalAdvisor ? 5 : 20;
              if (!hasLegalAdvisor) {
                carsToRemove.add(car);
              }
              balance = (balance - fine).clamp(0.0, double.infinity);
              reputation = (reputation - repLoss).clamp(0, 200);
              events.insert(0, GameEventModel(
                id: 'police_raid_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
                title: hasLegalAdvisor ? 'HUKUK DANIŞMANI CHANGE DAVASINI KURTARDI!' : 'ASAYİŞ KRİMİNAL: SAHTE ŞASİ (CHANGE) TESPİTİ!',
                description: hasLegalAdvisor
                    ? 'Avukatınız savcılık kararına yürütmeyi durdurma alarak ${car.brand} ${car.modelName} aracının otoparka çekilmesini engelledi! İdari ceza %75 indirildi: ₺${CurrencyFormatter.formatShort(fine)}.'
                    : '${car.brand} ${car.modelName} aracının şasisinin başka bir pert araçtan kopyalandığı (Change) tespit edildi. Araç yediemin otoparkına çekildi! ₺35.000 idari para cezası ve -20 İtibar!',
                type: GameEventType.expense,
                amount: -fine,
                date: DateTime.now(),
              ));
            } else {
              final carIdx = cars.indexOf(car);
              if (carIdx != -1) {
                final updatedParts = Map<String, PartStatus>.from(car.expertise.bodyParts);
                updatedParts['Şasi/Podye'] = PartStatus.damaged;
                updatedParts['Kaput'] = PartStatus.damaged;
                cars[carIdx] = car.copyWith(
                  expertise: car.expertise.copyWith(
                    engineCondition: 25.0,
                    transmissionCondition: 30.0,
                    tramerAmount: car.expertise.tramerAmount + 140000,
                    bodyParts: updatedParts,
                  ),
                );
                events.insert(0, GameEventModel(
                  id: 'chassis_crack_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'MERDİVEN ALTI KAYNAK ÇÖKTÜ!',
                  description: '${car.brand} ${car.modelName} ortadan ikiye eklenmiş kaynaklı araç çıktı! Gece vitrinde dururken şasi kaynağından koptu ve motor bloğu çatladı. Araç ağır hasara düştü!',
                  type: GameEventType.expense,
                  amount: 0.0,
                  date: DateTime.now(),
                ));
              }
            }
            break;

          case 'smuggled_exotic':
            final rawFine = 60000.0;
            final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
            final repLoss = hasLegalAdvisor ? 8 : 25;
            if (!hasLegalAdvisor) {
              carsToRemove.add(car);
            }
            balance = (balance - fine).clamp(0.0, double.infinity);
            reputation = (reputation - repLoss).clamp(0, 200);
            events.insert(0, GameEventModel(
              id: 'interpol_customs_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
              title: hasLegalAdvisor ? 'AVUKATINIZ GÜMRÜK EL KOYMASINI DURDURDU!' : 'GÜMRÜK MUHAFAZA & İNTERPOL BASKINI!',
              description: hasLegalAdvisor
                  ? 'Gümrük Muhafaza müfettişlerine karşı Hukuk Danışmanınız uluslararası tescil itirazında bulunarak araca el konulmasını önledi. Cezayı ₺${CurrencyFormatter.formatShort(fine)}\'ye düşürdü.'
                  : '${car.brand} ${car.modelName} yurt dışından sahte evrakla kaçak sokulduğu için Gümrük Muhafaza ekiplerince el konuldu! ₺60.000 kaçakçılık cezası uygulandı ve -25 İtibar!',
              type: GameEventType.expense,
              amount: -fine,
              date: DateTime.now(),
            ));
            break;

          case 'stolen_paperwork':
            final rawFine = 25000.0;
            final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
            final repLoss = hasLegalAdvisor ? 5 : 15;
            if (!hasLegalAdvisor) {
              carsToRemove.add(car);
            }
            balance = (balance - fine).clamp(0.0, double.infinity);
            reputation = (reputation - repLoss).clamp(0, 200);
            events.insert(0, GameEventModel(
              id: 'stolen_court_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
              title: hasLegalAdvisor ? 'HUKUK DANIŞMANINIZ RUHSAT İHTİLAFINI ÇÖZDÜ!' : 'ASIL RUHSAT SAHİBİ & POLİS BASKINI!',
              description: hasLegalAdvisor
                  ? 'Avukatınız iyi niyetli üçüncü kişi savunması yaparak aracın teslimini durdurdu. Mahkeme masrafı ₺${CurrencyFormatter.formatShort(fine)} olarak sınırlandı.'
                  : 'Asıl araç sahibi savcılık kararıyla galerinize geldi! ${car.brand} ${car.modelName} çalıntı kaydı nedeniyle sahibine teslim edildi. ₺25.000 hukuki masraf ödendi ve -15 İtibar.',
              type: GameEventType.expense,
              amount: -fine,
              date: DateTime.now(),
            ));
            break;

          case 'mafia_debt':
          case 'salvage_hidden':
          default:
            final rawFine = 30000.0;
            final fine = hasLegalAdvisor ? (rawFine * 0.25) : rawFine;
            final repLoss = hasLegalAdvisor ? 3 : 10;
            balance = (balance - fine).clamp(0.0, double.infinity);
            reputation = (reputation - repLoss).clamp(0, 200);
            events.insert(0, GameEventModel(
              id: 'mafia_debt_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
              title: hasLegalAdvisor ? 'AVUKATINIZ TEFECİ ŞANTAJINI SAVCILIĞA BİLDİRDİ!' : 'YERALTI HESAPLAŞMASI & TEFECİ BASKINI!',
              description: hasLegalAdvisor
                  ? 'Hukuk Danışmanınız suç duyurusunda bulunarak mafyanın haraç talebini savurdu. Sembolik ₺${CurrencyFormatter.formatShort(fine)} güvenlik masrafıyla kriz çözüldü.'
                  : '${car.blackMarketSellerAlias ?? "Karanlık satıcı"} borcunu ödemeden kaçtığı için alacaklı çete galeriyi bastı! ${car.brand} ${car.modelName} hatrına ₺30.000 haraç ödenmek zorunda kalındı.',
              type: GameEventType.expense,
              amount: -fine,
              date: DateTime.now(),
            ));
            break;
        }
      }
    }

    for (final c in carsToRemove) {
      cars.removeWhere((item) => item.id == c.id);
    }

    return (balance, cars, reputation, events);
  }

  (List<CarModel>, List<GameEventModel>) _processVandalism(List<CarModel> cars, List<GameEventModel> events) {
    final hasSecurity = state.hasFullSecurityProtection;
    if (!hasSecurity && cars.any((c) => c.isListed) && random.nextDouble() < 0.04) {
      final listedCars = cars.where((c) => c.isListed).toList();
      final targetCar = listedCars[random.nextInt(listedCars.length)];
      final carIdx = cars.indexOf(targetCar);
      if (carIdx != -1) {
        final updatedParts = Map<String, PartStatus>.from(targetCar.expertise.bodyParts);
        if (updatedParts.isNotEmpty) {
          final firstKey = updatedParts.keys.first;
          updatedParts[firstKey] = PartStatus.damaged;
        }
        cars[carIdx] = targetCar.copyWith(
          expertise: targetCar.expertise.copyWith(
            bodyParts: updatedParts,
          ),
        );
        events.insert(0, GameEventModel(
          id: 'vandalism_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Gece Park Halinde Çizilme / Vandalizm',
          description: 'Showroom güvenlik kameranız (CCTV) olmadığı için ${targetCar.brand} ${targetCar.modelName} gece çizildi! Kaporta/boya sağlığı düştü.',
          type: GameEventType.expense,
          amount: 0.0,
          date: DateTime.now(),
        ));
      }
    }
    return (cars, events);
  }

  (List<StockModel>, double, List<GameEventModel>) _processStockMarketAndDividends(
    int nextDay,
    double balance,
    List<StockModel> stocks,
    List<PlayerStockModel> ownedStocks,
    List<GameEventModel> events,
  ) {
    for (int i = 0; i < stocks.length; i++) {
      final stock = stocks[i];
      double baseChange = (random.nextDouble() * 0.20) - 0.10;
      
      // Makro haber etkisi (FROTO ve TOASO hisselerine direkt etki)
      if (state.activeNews != null && (stock.symbol == 'FROTO' || stock.symbol == 'TOASO')) {
        if (state.activeNews!.priceMultiplier > 1.0) {
          baseChange += 0.06;
        } else {
          baseChange -= 0.06;
        }
      }

      double newPrice = (stock.currentPrice * (1.0 + baseChange)).roundToDouble();
      if (newPrice < 1.0) newPrice = 1.0; 
      List<double> history = List.from(stock.priceHistory);
      history.add(newPrice);
      if (history.length > 30) history = history.sublist(history.length - 30);
      stocks[i] = stock.copyWith(previousPrice: stock.currentPrice, currentPrice: newPrice, priceHistory: history);
    }

    // Process daily dividends from portfolio
    double totalDividends = 0.0;
    for (var owned in ownedStocks) {
      final stock = findFirstWhere(stocks, (s) => s.symbol == owned.symbol);
      if (stock != null) {
        final double stockVal = owned.quantity * stock.currentPrice;
        totalDividends += (stockVal * stock.dividendYield) / 365.0;
      }
    }

    if (totalDividends >= 1.0) {
      final roundDiv = (totalDividends * 100).roundToDouble() / 100.0;
      balance += roundDiv;
      events.insert(0, GameEventModel(
        id: 'dividend_$nextDay',
        title: 'BIST Portföy Temettü Geliri',
        description: 'Hisselerinden günlük +₺${roundDiv.round()} net temettü nakit akışı hesabına yatırıldı.',
        type: GameEventType.income,
        amount: roundDiv,
        date: DateTime.now(),
      ));
    }

    return (stocks, balance, events);
  }

  List<ForexGoldModel> _processForexMarket(List<ForexGoldModel> forexList) {
    if (forexList.isEmpty) return ForexGoldModel.defaultForex;
    List<ForexGoldModel> updated = [];
    for (var item in forexList) {
      final double changeRatio = 1.0 + ((random.nextDouble() * 0.03) - 0.015);
      final double newBuy = (item.buyRate * changeRatio * 100).roundToDouble() / 100.0;
      final double newSell = (newBuy * 0.991 * 100).roundToDouble() / 100.0;

      List<double> history = List.from(item.rateHistory);
      history.add(newBuy);
      if (history.length > 30) history = history.sublist(history.length - 30);

      updated.add(item.copyWith(
        buyRate: newBuy,
        sellRate: newSell,
        previousRate: item.buyRate,
        rateHistory: history,
      ));
    }
    return updated;
  }

  (List<IpoOfferModel>, List<PlayerIpoRequestModel>, double, List<GameEventModel>) _processIpoMarket(
    int nextDay,
    double balance,
    List<IpoOfferModel> ipos,
    List<PlayerIpoRequestModel> requests,
    List<GameEventModel> events,
  ) {
    if (ipos.isEmpty) {
      return (IpoOfferModel.defaultIpos(nextDay), requests, balance, events);
    }

    List<IpoOfferModel> updatedIpos = [];
    List<PlayerIpoRequestModel> updatedRequests = List.from(requests);

    for (var ipo in ipos) {
      if (ipo.isListed) {
        updatedIpos.add(ipo);
        continue;
      }

      int remainingDays = ipo.daysUntilListing - 1;
      if (remainingDays <= 0) {
        updatedIpos.add(ipo.copyWith(daysUntilListing: 0, isListed: true));

        final playerReq = findFirstWhere(updatedRequests, (r) => r.ipoId == ipo.id);
        if (playerReq != null) {
          final double payout = playerReq.totalSpent * ipo.listingMultiplier;
          final double profit = payout - playerReq.totalSpent;
          balance += payout;

          events.insert(0, GameEventModel(
            id: 'ipo_listed_${ipo.id}_$nextDay',
            title: '${ipo.companyName} (${ipo.symbol}) Borsada Tavan Açtı!',
            description: '${ipo.symbol} halka arzında tavan serisi gerçekleşti! ₺${playerReq.totalSpent.round()} yatırımın ₺${payout.round()} oldu (+₺${profit.round()} kâr).',
            type: GameEventType.income,
            amount: payout,
            date: DateTime.now(),
          ));
        }
      } else {
        updatedIpos.add(ipo.copyWith(daysUntilListing: remainingDays));
      }
    }

    if (updatedIpos.every((i) => i.isListed)) {
      if (nextDay % 7 == 0) {
        updatedIpos = IpoOfferModel.defaultIpos(nextDay);
      }
    }

    return (updatedIpos, updatedRequests, balance, events);
  }

  double _processDailyTax(double balance) {
    double tax = 150.0;
    if (state.level >= 9) {
      tax = 3500.0;
    } else if (state.level >= 6) {
      tax = 1200.0;
    } else if (state.level >= 3) {
      tax = 450.0;
    }
    return balance - tax;
  }

  List<GameEventModel> _createDailySummaryEvent(int nextDay, double newBalance, List<GameEventModel> events) {
    final double netDayChange = newBalance - state.balance;
    final summaryEvent = GameEventModel(
      id: 'day_summary_$nextDay',
      title: 'Gün $nextDay Kapanış Özeti',
      description: 'Giderler, personel maaşları ve pasif gelirler hesaplandı. Net günlük değişim: ${netDayChange >= 0 ? "+₺${netDayChange.round()}" : "-₺${netDayChange.abs().round()}"}.',
      type: netDayChange >= 0 ? GameEventType.income : GameEventType.expense,
      amount: netDayChange,
      date: DateTime.now(),
    );
    events.insert(0, summaryEvent);
    if (events.length > 50) events = events.sublist(0, 50);
    return events;
  }

  MarketNewsModel? _processMarketNews(int nextDay, MarketNewsModel? currentNews) {
    if (currentNews == null || nextDay % 5 == 0) {
      return MarketNewsModel.newsList[random.nextInt(MarketNewsModel.newsList.length)];
    }
    return currentNews;
  }

  (List<ScrapyardCar>, List<BlackMarketCarModel>) _processScrapyardAndBlackMarket(
    int nextDay, List<ScrapyardCar> scrap, List<BlackMarketCarModel> black) {
    if (nextDay % 3 == 0 || scrap.isEmpty) scrap = _generateRandomScrapyardCars(nextDay);
    if (nextDay % 3 == 0 || black.isEmpty) black = _generateRandomBlackMarketCars(nextDay);
    return (scrap, black);
  }

  (int, int, StoryCardModel?) _processStoryAd(int daysSince, int targetDays, StoryCardModel? pendingCard) {
    int updatedDays = daysSince + 1;
    if (updatedDays >= targetDays && pendingCard == null) {
      pendingCard = selectNextStoryCard();
      updatedDays = 0;
      targetDays = 7 + random.nextInt(15);
    }
    return (updatedDays, targetDays, pendingCard);
  }

  (int, int, DramaticCardModel?) _processDramaticDecision(int daysSince, int targetDays, DramaticCardModel? pendingCard) {
    int updatedDays = daysSince + 1;
    if (updatedDays >= targetDays && pendingCard == null) {
      pendingCard = DramaticCardEngine.selectNextCard(state, randomInstance: random);
      updatedDays = 0;
      targetDays = 15 + random.nextInt(16);
    }
    return (updatedDays, targetDays, pendingCard);
  }

  (int, int, GameEventModel?, List<String>) _processRandomEvents(
    int daysSince, int targetDays, GameEventModel? pendingCard, List<String> seenIds) {
    int updatedDays = daysSince + 1;
    if (updatedDays >= targetDays && pendingCard == null) {
      pendingCard = RandomEventEngine.getFilteredRandomEvent(state);
      if (pendingCard != null) {
        seenIds.add(pendingCard.id);
        if (seenIds.length > 6) seenIds.removeAt(0);
        updatedDays = 0;
        targetDays = 5 + random.nextInt(6);
      }
    }
    return (updatedDays, targetDays, pendingCard, seenIds);
  }

  List<CarModel> _processListingsAmortization(List<CarModel> cars) {
    return cars.map((c) {
      if (!c.isListed) return c;
      final newDays = c.daysListed + 1;
      double newBaseValue = c.baseMarketValue;
      if (newDays > 20) newBaseValue = max(35000.0, newBaseValue * 0.997);
      return c.copyWith(daysListed: newDays, baseMarketValue: newBaseValue);
    }).toList();
  }

  (double, String?, List<GameEventModel>) _processDisputes(int nextDay, double balance, String? currentDispute, List<GameEventModel> events) {
    if (state.dirtyRecordCount > 0 && random.nextDouble() < 0.12) {
      final lawsuitFine = (15000.0 + random.nextInt(25000)).roundToDouble();
      balance = max(0.0, balance - lawsuitFine);
      currentDispute = 'Eski bir alıcı kusurlu araç gerekçesiyle Tüketici Heyeti üzerinden ₺${lawsuitFine.round()} tazminat kazandı!';
      events.insert(0, GameEventModel(
        id: 'lawsuit_$nextDay',
        title: 'Tüketici Mahkemesi Kararı!',
        description: currentDispute,
        type: GameEventType.expense,
        amount: lawsuitFine,
        date: DateTime.now(),
      ));
    }
    return (balance, currentDispute, events);
  }

  List<OfferModel> _processLoyalCustomerOffers(List<CarModel> cars, List<OfferModel> offers) {
    if (state.loyalCustomerNames.isNotEmpty && cars.any((c) => c.isListed) && random.nextDouble() < 0.25) {
      final listedCars = cars.where((c) => c.isListed).toList();
      final randomCar = listedCars[random.nextInt(listedCars.length)];
      final randomCustomer = state.loyalCustomerNames[random.nextInt(state.loyalCustomerNames.length)];
      final loyalOffer = NegotiationEngine.generateLoyalCustomerOffer(car: randomCar, customerName: randomCustomer);
      offers.add(loyalOffer);
    }
    return offers;
  }

  double _processBankInterest(double deposit) {
    if (deposit > 0) {
      final double dailyInterest = (deposit * 0.0012).roundToDouble();
      deposit += (dailyInterest > 0 ? dailyInterest : 1.0);
    }
    return deposit;
  }

  List<MissionModel> _processDailyMissions(List<MissionModel> missions) {
    if (missions.isEmpty || missions.every((m) => m.isClaimed)) {
      return MissionFactory.generateDailyMissions(state.level);
    }
    return missions;
  }

  List<WantedCarContract> _processVIPContracts(List<WantedCarContract> contracts) {
    List<WantedCarContract> updated = [];
    for (final c in contracts) {
      if (c.isFulfilled) continue;
      final remaining = c.deadlineDays - 1;
      if (remaining > 0) updated.add(c.copyWith(deadlineDays: remaining));
    }
    if (updated.length < 2 && random.nextDouble() < 0.40) {
      updated.add(MissionFactory.generateWantedCarContract(level: state.level));
    }
    return updated;
  }

  List<TradeInOfferModel> _processTradeInOffers(int nextDay, List<CarModel> cars, List<TradeInOfferModel> offers) {
    offers = offers.where((t) => t.expiresInDays > 1).map((t) => t.copyWith(expiresInDays: t.expiresInDays - 1)).toList();
    if (cars.any((c) => c.isListed) && random.nextDouble() < 0.35) {
      final listedCars = cars.where((c) => c.isListed).toList();
      final targetCar = listedCars[random.nextInt(listedCars.length)];
      final tradeOffer = TradeInEngine.generateTradeInOffer(targetCar: targetCar, inGameDay: nextDay);
      offers.insert(0, tradeOffer);
      if (offers.length > 5) offers = offers.sublist(0, 5);
    }
    return offers;
  }

  List<CarModel> _processConsignmentOffers(int nextDay, List<CarModel> offers) {
    final hasSamovar = state.hasDecor('decor_copper_samovar');
    final refreshInterval = hasSamovar ? 2 : 3;
    if (nextDay % refreshInterval == 0 || offers.isEmpty) {
      return ConsignmentEngine.generateConsignmentOffers(
        inGameDay: nextDay,
        branchTier: state.currentBranchTier,
        reputationScore: state.reputationScore,
      );
    }
    return offers;
  }


  /// Search car glovebox for historic/valuable hidden items (§1.4)
  Map<String, dynamic> searchGlovebox(String carId) {
    final index = state.ownedCars.indexWhere((c) => c.id == carId);
    if (index == -1) return {'success': false, 'message': 'Araç bulunamadı.'};

    final car = state.ownedCars[index];
    if (car.hasGloveboxSearched) {
      return {'success': false, 'message': 'Torpido gözü daha önce zaten arandı.'};
    }

    final item = car.gloveboxItem ?? 'Nazar Boncuklu Anahtarlık';
    double cashBonus = 1000.0;
    if (item.contains('Gümüş') || item.contains('Altın')) {
      cashBonus = 7500.0;
    } else if (item.contains('Anahtar') || item.contains('Kaset')) {
      cashBonus = 2500.0;
    }

    final updatedCar = car.copyWith(hasGloveboxSearched: true);
    final updatedList = List<CarModel>.from(state.ownedCars);
    updatedList[index] = updatedCar;

    state = state.copyWith(
      ownedCars: updatedList,
      balance: state.balance + cashBonus,
    );
    saveState();

    return {
      'success': true,
      'item': item,
      'cashBonus': cashBonus,
      'message': 'Torpido gözünde "$item" bulundu! (+₺${cashBonus.round()})',
    };
  }

  /// Batch action: Wash and polish all unwashed cars in showroom (§1.5 / Q10)
  int washAllShowroomCars() {
    final unwashed = state.ownedCars.where((c) => !c.isWashed || !c.isPolished).toList();
    if (unwashed.isEmpty) return 0;

    final cost = unwashed.length * 350.0;
    if (state.balance < cost) return -1; // Insufficient funds

    final updatedCars = state.ownedCars.map((c) {
      return c.copyWith(isWashed: true, isPolished: true);
    }).toList();

    state = state.copyWith(
      ownedCars: updatedCars,
      balance: state.balance - cost,
      carsWashedLast7Days: state.carsWashedLast7Days + unwashed.length,
    );
    saveState();
    return unwashed.length;
  }

  /// Batch action: List all unlisted garage cars to marketplace (§1.5 / Q10)
  int listAllGarageCars() {
    int listedCount = 0;
    final updatedCars = state.ownedCars.map<CarModel>((c) {
      if (!c.isListed && !c.isRented && !c.isLockedInShowcase) {
        listedCount++;
        return c.copyWith(customListingPrice: c.estimatedRealValue * 1.15);
      }
      return c;
    }).toList();

    if (listedCount > 0) {
      state = state.copyWith(ownedCars: updatedCars);
      saveState();
    }
    return listedCount;
  }

  /// Batch action: Delist all stale listings (>20 days) to prevent further amortization (§1.5 / Q10)
  int delistStaleListings() {
    int delistedCount = 0;
    final updatedCars = state.ownedCars.map<CarModel>((c) {
      if (c.isListed && c.daysListed > 20) {
        delistedCount++;
        return c.copyWith(clearListingPrice: true, daysListed: 0);
      }
      return c;
    }).toList();

    if (delistedCount > 0) {
      state = state.copyWith(ownedCars: updatedCars);
      saveState();
    }
    return delistedCount;
  }

  /// Resolves the contextual random event choice outcome and mutates state
  void resolveRandomEvent(GameEventChoice choice) {
    final newBalance = (state.balance + choice.balanceChange).clamp(0.0, double.infinity);
    final newReputation = (state.reputationScore + choice.reputationChange).clamp(0, 100);
    state = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      clearPendingRandomEvent: true,
    );
    saveState();
  }

  /// Dismisses a pending random event without making a choice
  void dismissPendingRandomEvent() {
    state = state.copyWith(clearPendingRandomEvent: true);
  }

  /// Selects the next available narrative card from the pool, preventing repeats until cycle completes
  StoryCardModel? selectNextStoryCard() {
    final allCards = StoryCardModel.defaultCards;
    List<StoryCardModel> availableCards = allCards.where((c) => !state.seenStoryCardIds.contains(c.id)).toList();

    // If all cards in current cycle have been seen, reset cycle
    if (availableCards.isEmpty) {
      state = state.copyWith(seenStoryCardIds: const []);
      availableCards = List.from(allCards);
    }

    if (availableCards.isEmpty) return null;
    final selected = availableCards[random.nextInt(availableCards.length)];
    return selected;
  }

  /// Resolves the story card outcome (accepted with reward or declined) and marks it as seen
  void resolveStoryCard({required StoryCardModel card, required bool accepted}) {
    final updatedSeen = List<String>.from(state.seenStoryCardIds);
    if (!updatedSeen.contains(card.id)) {
      updatedSeen.add(card.id);
    }

    double newBalance = state.balance;
    List<CarModel> updatedCars = List.from(state.ownedCars);
    List<OfferModel> updatedOffers = List.from(state.incomingOffers);

    if (accepted) {
      switch (card.rewardType) {
        case StoryAdRewardType.instantExpertise:
          if (updatedCars.isNotEmpty) {
            // Find first car that needs repair/expertise or target first car
            final targetIndex = updatedCars.indexWhere((c) => c.expertise.engineCondition < 100 || c.expertise.transmissionCondition < 100);
            final idx = targetIndex != -1 ? targetIndex : 0;
            final targetCar = updatedCars[idx];
            updatedCars[idx] = targetCar.copyWith(
              isDetailedCleaned: true,
              isWashed: true,
              expertise: targetCar.expertise.copyWith(
                engineCondition: 100.0,
                transmissionCondition: 100.0,
              ),
            );
            newBalance += 10000.0;
          } else {
            newBalance += 35000.0;
          }
          break;

        case StoryAdRewardType.bargainCarSpawn:
          // Spawns a collector car or bargain car
          final bargainCar = CarModel(
            id: 'car_sofor_bargain_${DateTime.now().millisecondsSinceEpoch}',
            brand: 'Bemeve',
            modelName: 'Bemeve E36 Coupe (Koleksiyon / Kelepir)',
            modelYear: 1993,
            bodyType: 'Klasik',
            colorHex: '0xFF1E3A8A',
            colorDisplayName: 'Gece Mavisi',
            colorRarity: 'rare',
            plateNumber: '34 BM 1993',
            plateRarity: 'repeated',
            baseMarketValue: 600000.0,
            currentPurchasePrice: 280000.0, // ~50% discount
            isRare: true,
            expertise: ExpertiseReport(
              engineCondition: 95.0,
              transmissionCondition: 90.0,
              tramerAmount: 0,
              mileage: 110000,
              isMileageTampered: false,
              bodyParts: const {
                'Kaput': PartStatus.original,
                'Tavan': PartStatus.original,
                'Sol Kapı': PartStatus.original,
                'Sağ Kapı': PartStatus.original,
                'Bagaj': PartStatus.original,
              },
            ),
          );
          if (updatedCars.length < state.maxGarageSlots) {
            updatedCars.add(bargainCar);
          } else {
            newBalance += 60000.0;
          }
          break;

        case StoryAdRewardType.expressDetailing:
          if (updatedCars.isNotEmpty) {
            for (int i = 0; i < updatedCars.length; i++) {
              final c = updatedCars[i];
              updatedCars[i] = c.copyWith(
                isWashed: true,
                isPolished: true,
                isDetailedCleaned: true,
                baseMarketValue: (c.baseMarketValue * 1.15).roundToDouble(),
              );
            }
          } else {
            newBalance += 30000.0;
          }
          break;

        case StoryAdRewardType.bonusSaleBoost:
          // Hüsnü Bey: Spawns an immediate offer with +10% over listing price / value
          final listedCars = updatedCars.where((c) => c.isListed && !c.isRented).toList();
          if (listedCars.isNotEmpty) {
            final targetCar = listedCars.first;
            final bonusOfferPrice = ((targetCar.listingPrice > 0 ? targetCar.listingPrice : targetCar.estimatedRealValue) * 1.10).roundToDouble();
            final husnuOffer = OfferModel(
              id: 'offer_husnu_${DateTime.now().millisecondsSinceEpoch}',
              carId: targetCar.id,
              buyerName: 'Hüsnü Bey (İkramlı Müşteri)',
              offeredAmount: bonusOfferPrice,
              buyerMessage: 'Kahve ve ikramlar için teşekkürler, bu fiyata el sıkışalım!',
              offerType: OfferType.cash,
              createdAt: DateTime.now(),
              expiresAt: DateTime.now().add(const Duration(minutes: 15)),
            );
            updatedOffers.add(husnuOffer);
          } else {
            newBalance += 40000.0;
          }
          break;

        case StoryAdRewardType.viralBuyerOffers:
          // Vlogger Berk: Spawns 3 viral buyer offers
          final listedCars = updatedCars.where((c) => c.isListed && !c.isRented).toList();
          if (listedCars.isNotEmpty) {
            final targetCar = listedCars.first;
            final basePrice = targetCar.listingPrice > 0 ? targetCar.listingPrice : targetCar.estimatedRealValue;
            final names = ['Berk Takipçisi Can', 'Reels Alıcısı Murat', 'Vlog İzleyicisi Sarp'];
            for (int i = 0; i < names.length; i++) {
              final mult = 0.98 + (i * 0.05); // 0.98, 1.03, 1.08
              updatedOffers.add(
                OfferModel(
                  id: 'offer_viral_${i}_${DateTime.now().millisecondsSinceEpoch}',
                  carId: targetCar.id,
                  buyerName: names[i],
                  offeredAmount: (basePrice * mult).roundToDouble(),
                  buyerMessage: 'Vlogger Berk’in videosunda gördüm, aracı hemen almak istiyorum!',
                  offerType: OfferType.cash,
                  createdAt: DateTime.now(),
                  expiresAt: DateTime.now().add(Duration(minutes: 10 + i * 5)),
                ),
              );
            }
          } else {
            newBalance += 45000.0;
          }
          break;

        case StoryAdRewardType.auctionMarginReport:
          newBalance += 30000.0;
          break;

        case StoryAdRewardType.partsDiscountCredit:
          newBalance += 35000.0;
          break;

        case StoryAdRewardType.scrapyardFreeTowCredit:
          newBalance += 25000.0;
          break;
      }
    }

    state = state.copyWith(
      balance: newBalance,
      ownedCars: updatedCars,
      incomingOffers: updatedOffers,
      seenStoryCardIds: updatedSeen,
      clearPendingStoryCard: true,
    );

    saveState();
  }

  void dismissPendingStoryCard() {
    state = state.copyWith(clearPendingStoryCard: true);
  }

  /// Resolves the dramatic dilemma card choice outcome and mutates dealership state
  DramaticResolutionResult resolveDramaticCardChoice({
    required DramaticCardModel card,
    required DramaticChoiceModel choice,
    double? fixedRoll,
  }) {
    final result = DramaticCardEngine.resolveChoice(
      state,
      card,
      choice,
      fixedRoll: fixedRoll,
      randomInstance: random,
    );
    state = result.updatedState;
    saveState();
    return result;
  }

  /// Dismisses a pending dramatic card without making a choice
  void dismissPendingDramaticCard() {
    state = state.copyWith(clearPendingDramaticCard: true);
  }

  List<ScrapyardCar> _generateRandomScrapyardCars(int day) {
    return [
      ScrapyardCar(
        id: 'scrap_${day}_1',
        brand: 'Bemeve',
        modelName: 'Bemeve 3.20d Yanlama E-90 (Ağır Pert)',
        modelYear: 2016,
        scrapPrice: 140000.0,
        estimatedPartTotalValue: 280000.0,
        damageNote: 'Önden ağır taklalı, tavan ezik. Motor ve şanzıman sapasağlam.',
        chassisScrapMetalWeightKg: 1450,
        chassisScrapValue: 8700.0,
        surpriseFindItem: 'Orijinal Harman Kardon Amfi & M Vites Topuzu',
        surpriseFindValue: 4500.0,
        parts: const [
          SalvagedPart(id: 'p_1_1', name: '2.0 TwinPower Turbo Motor Bloğu', carModelName: 'Bemeve 3.20d', category: 'engine', conditionPercent: 88, estimatedValue: 120000.0),
          SalvagedPart(id: 'p_1_2', name: '8 İleri ZF Otomatik Şanzıman', carModelName: 'Bemeve 3.20d', category: 'transmission', conditionPercent: 92, estimatedValue: 85000.0),
          SalvagedPart(id: 'p_1_3', name: '19" M Alaşım Çift Jant Takımı', carModelName: 'Bemeve 3.20d', category: 'wheels', conditionPercent: 80, estimatedValue: 35000.0),
          SalvagedPart(id: 'p_1_4', name: 'Harman Kardon Müzik Sistemi', carModelName: 'Bemeve 3.20d', category: 'audio', conditionPercent: 95, estimatedValue: 40000.0),
        ],
      ),
      ScrapyardCar(
        id: 'scrap_${day}_2',
        brand: 'Vosgen',
        modelName: 'Vosgen Golf Sekiz R-Line (Pert Kayıtlı)',
        modelYear: 2018,
        scrapPrice: 190000.0,
        estimatedPartTotalValue: 360000.0,
        damageNote: 'Arkadan kamyon çarpması sonrası pert kararı verilmiş.',
        chassisScrapMetalWeightKg: 1320,
        chassisScrapValue: 7920.0,
        surpriseFindItem: 'Fabrika Takım Çantası & Yedek Anahtar',
        surpriseFindValue: 3000.0,
        parts: const [
          SalvagedPart(id: 'p_2_1', name: '2.0 TSI GTI Turbo Şarj Kiti', carModelName: 'Vosgen Golf', category: 'turbo', conditionPercent: 94, estimatedValue: 65000.0),
          SalvagedPart(id: 'p_2_2', name: 'DSG Islak Kavrama Şanzıman', carModelName: 'Vosgen Golf', category: 'transmission', conditionPercent: 90, estimatedValue: 95000.0),
          SalvagedPart(id: 'p_2_3', name: 'Karbon Difüzör & Çift Egzoz Takımı', carModelName: 'Vosgen Golf', category: 'bodywork', conditionPercent: 85, estimatedValue: 45000.0),
          SalvagedPart(id: 'p_2_4', name: 'GTI Hayalet Gösterge & Direksiyon', carModelName: 'Vosgen Golf', category: 'bodywork', conditionPercent: 96, estimatedValue: 75000.0),
        ],
      ),
      ScrapyardCar(
        id: 'scrap_${day}_3',
        brand: 'Merso',
        modelName: 'Merso C-200 Makam AMG (Yanık/Pert)',
        modelYear: 2017,
        scrapPrice: 165000.0,
        estimatedPartTotalValue: 310000.0,
        damageNote: 'Elektrik kontağından motor kompartımanı kısmen hasarlı.',
        chassisScrapMetalWeightKg: 1550,
        chassisScrapValue: 9300.0,
        surpriseFindItem: 'Nostaljik Becker Teyp & Orijinal Ruhsat Kabı',
        surpriseFindValue: 3800.0,
        parts: const [
          SalvagedPart(id: 'p_3_1', name: 'AMG Deri Koltuk & İç Döşeme Takımı', carModelName: 'Merso C-200', category: 'bodywork', conditionPercent: 92, estimatedValue: 80000.0),
          SalvagedPart(id: 'p_3_2', name: '9G-Tronic Otomatik Şanzıman', carModelName: 'Merso C-200', category: 'transmission', conditionPercent: 89, estimatedValue: 110000.0),
          SalvagedPart(id: 'p_3_3', name: 'Burmester VIP Ses Sistemi', carModelName: 'Merso C-200', category: 'audio', conditionPercent: 98, estimatedValue: 55000.0),
          SalvagedPart(id: 'p_3_4', name: 'AMG MultiBeam LED Far Takımı', carModelName: 'Merso C-200', category: 'bodywork', conditionPercent: 85, estimatedValue: 65000.0),
        ],
      ),
    ];
  }

  List<BlackMarketCarModel> _generateRandomBlackMarketCars(int day) {
    return [
      BlackMarketCarModel(
        id: 'bm_${day}_1',
        brand: 'Porş',
        modelName: 'Porş Pana-Mera 4S Lüks (%50 Kelepir / Soruşturmalı)',
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
        brand: 'Merso',
        modelName: 'Merso G-63 Tuğla V8 (%60 İndirimli / Hacizli)',
        modelYear: 2021,
        askingPrice: 2800000.0,
        realMarketValue: 6500000.0,
        riskType: 'stolen_paperwork',
        riskLevelPercent: 35,
        sellerAlias: 'Karanlık Kenan',
        riskDescription: 'Yurt dışından kaçak sokulmuş sahte plaka Merso G-Kasa Tuğla. Satış esnasında %35 Polis El Koyma Riski!',
      ),
      BlackMarketCarModel(
        id: 'bm_${day}_3',
        brand: 'Avdi',
        modelName: 'Avdi RS-Altı Canavar (%45 İndirimli / Çifte Şasi)',
        modelYear: 2020,
        askingPrice: 1950000.0,
        realMarketValue: 4200000.0,
        riskType: 'salvage_hidden',
        riskLevelPercent: 20,
        sellerAlias: 'Gölge İbrahim',
        riskDescription: 'İki kazalı araç kaynağı ile yapılmış Change Avdi RS-Altı. Yakalanırsa araç kaza enkazı sayılarak bağlanır!',
      ),
    ];
  }
}
