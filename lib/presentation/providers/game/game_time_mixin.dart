import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

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
import '../../../data/models/customer_crm_event_model.dart';
import '../../../data/models/active_service_job_model.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../domain/usecases/mission_factory.dart';
import '../../../domain/usecases/dramatic_card_engine.dart';
import '../../../domain/usecases/random_event_engine.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/trade_in_engine.dart';
import '../../../domain/usecases/gossip_engine.dart';
import '../../../domain/usecases/weather_engine.dart';
import '../../../domain/usecases/consignment_engine.dart';
import '../../../domain/usecases/district_economy_engine.dart';
import '../../../domain/usecases/black_market_engine.dart';
import '../../../domain/usecases/loan_settlement_engine.dart';
import '../../../domain/usecases/stock_market_engine.dart';
import '../../../domain/usecases/rental_progression_engine.dart';
import '../../../domain/usecases/side_business_engine.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/gossip_item_model.dart';

import 'game_base_notifier.dart';

mixin GameTimeMixin on GameBaseNotifier {
  /// 1 in-game calendar day = 2 minutes (120 seconds) of active gameplay
  static const int inGameDayDurationSeconds = 120;

  Timer? _organicOfferTimer;
  DateTime _lastDayAdvanceTime = DateTime.now();
  DateTime get lastDayAdvanceTime => _lastDayAdvanceTime;

  void startPeriodicOrganicOfferTimer() {
    _organicOfferTimer?.cancel();
    _lastDayAdvanceTime = DateTime.now();
    _organicOfferTimer = Timer.periodic(
        const Duration(seconds: inGameDayDurationSeconds), (timer) {
      // ponytail: 1 in-game calendar day = 2 minutes (120 seconds) of active gameplay
      advanceGameDay();

      // Günlük dalgalanma faktörü (0.8 ile 1.2 arası)
      double dayFactor = 0.8 + (random.nextDouble() * 0.4);

      // Organik müşteri teklifleri
      if (state.ownedCars.isNotEmpty &&
          random.nextDouble() < (0.25 * dayFactor)) {
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
    if (currentStaff.any((s) => s.isAvailableForWork && s.role == StaffRole.salesman) &&
        currentCars.any((c) => c.isListed && !c.isRented)) {
      triggerOrganicOffers();
    }

    final loanResult =
        _processLoans(nextDay, newBalance, List.from(state.activeLoans));
    newBalance = loanResult.$1;
    final updatedLoans = loanResult.$2;

    final rentalResult = _processRentals(
        newBalance,
        currentCars,
        List.from(state.activeRentals),
        newEvents,
        List.from(state.incomingOffers));
    newBalance = rentalResult.$1;
    currentCars = rentalResult.$2;
    final updatedRentals = rentalResult.$3;
    newEvents = rentalResult.$4;
    final offersAfterRentals = rentalResult.$5;

    final installResult =
        _processInstallments(newBalance, List.from(state.activeInstallments));
    newBalance = installResult.$1;
    final updatedInstallments = installResult.$2;

    final chequeResult =
        _processCheques(newBalance, List.from(state.activeCheques));
    newBalance = chequeResult.$1;
    final updatedCheques = chequeResult.$2;

    final bkResult = _processBankruptcy(nextDay, newBalance, currentCars,
        updatedLoans, List.from(state.dynastyHistoryLog), newEvents);
    newBalance = bkResult.$1;
    currentCars = bkResult.$2;
    final activeLoansAfterBk = bkResult.$3;
    final updatedDynastyHistory = bkResult.$4;
    newEvents = bkResult.$5;

    final bizResult = _processSideBusinesses(
        newBalance, currentCars, List.from(state.sideBusinesses));
    newBalance = bizResult.$1;
    final updatedBusinesses = bizResult.$2;

    final realEstateResult = _processRealEstateRentals(
        newBalance, List.from(state.ownedRealEstates), newEvents);
    newBalance = realEstateResult.$1;
    newEvents = realEstateResult.$2;

    final stockResult = _processStockMarketAndDividends(nextDay, newBalance,
        List.from(state.marketStocks), state.ownedStocks, newEvents);
    final updatedStocks = stockResult.$1;
    newBalance = stockResult.$2;
    newEvents = stockResult.$3;

    final updatedForex = _processForexMarket(List.from(state.marketForex));
    final ipoResult = _processIpoMarket(
        nextDay,
        newBalance,
        List.from(state.activeIpos),
        List.from(state.playerIpoRequests),
        newEvents);
    final updatedIpos = ipoResult.$1;
    final updatedIpoReqs = ipoResult.$2;
    newBalance = ipoResult.$3;
    newEvents = ipoResult.$4;

    newBalance = _processDailyTax(newBalance);
    newEvents = _createDailySummaryEvent(nextDay, newBalance, newEvents);
    final currentNews = _processMarketNews(nextDay, state.activeNews);

    final scrapAndBlack = _processScrapyardAndBlackMarket(nextDay,
        List.from(state.scrapyardCars), List.from(state.blackMarketCars));
    final currentScrapCars = scrapAndBlack.$1;
    final currentBlackCars = scrapAndBlack.$2;

    final storyAd = _processStoryAd(state.daysSinceLastStoryAd,
        state.nextStoryAdTargetDays, state.pendingStoryCard);
    final dramatic = _processDramaticDecision(nextDay, state.daysSinceLastDramaticCard,
        state.nextDramaticCardTargetDays, state.pendingDramaticCard);
    final randomEvent = _processRandomEvents(
        state.daysSinceLastRandomEvent,
        state.nextRandomEventTargetDays,
        state.pendingRandomEvent,
        List.from(state.seenRandomEventIds));

    currentCars = _processListingsAmortization(currentCars);

    // 1. Process Consignment Vehicle Remaining Days & Expiry Return & Daily Parking Fees
    final consignmentResult = _processConsignmentDays(currentCars, newEvents);
    currentCars = consignmentResult.$1;
    newBalance += consignmentResult.$2;
    newEvents = consignmentResult.$3;

    // 2. Process Black Market Police Raid Risk
    int currentReputation = state.reputationScore;
    final raidResult = _processBlackMarketRaid(
        newBalance, currentCars, currentReputation, newEvents);
    newBalance = raidResult.$1;
    currentCars = raidResult.$2;
    currentReputation = raidResult.$3;
    newEvents = raidResult.$4;

    // 3. Process Showroom Nighttime Vandalism vs Security CCTV
    final vandalismResult = _processVandalism(currentCars, newEvents);
    currentCars = vandalismResult.$1;
    newEvents = vandalismResult.$2;

    final dispute = _processDisputes(
        nextDay, newBalance, state.pendingDisputeNotice, newEvents);
    newBalance = dispute.$1;
    final currentDisputeNotice = dispute.$2;
    newEvents = dispute.$3;

    final validOffers = offersAfterRentals
        .where((o) => currentCars.any((c) => c.id == o.carId) && !o.isExpired)
        .toList();
    final updatedIncomingOffers =
        _processLoyalCustomerOffers(currentCars, validOffers);
    final updatedBankDeposit = _processBankInterest(state.bankDepositBalance);
    final updatedMissions =
        _processDailyMissions(List.from(state.activeMissions));
    final updatedContracts =
        _processVIPContracts(List.from(state.activeContracts));

    final decayResult = _processDistrictMarketDecay(
        Map<String, double>.from(state.districtMarketShare), newEvents);
    final updatedDistrictShares = decayResult.$1;
    newEvents = decayResult.$2;

    final nextWeather = WeatherEngine.getWeatherForDay(nextDay);
    final dailyGossips = GossipEngine.generateDailyGossips(nextDay);
    final updatedPlayerGossips =
        state.playerSpreadGossips.where((r) => !r.isExpired(nextDay)).toList();
    final updatedTradeOffers = _processTradeInOffers(
        nextDay, currentCars, List.from(state.incomingTradeInOffers));
    final updatedConsignmentOffers =
        _processConsignmentOffers(nextDay, List.from(state.consignmentOffers));
    final updatedB2BOrders = (nextDay % 2 == 0 || state.b2bPartOrders.isEmpty)
        ? B2BPartOrder.generateDailyOrders(nextDay)
        : state.b2bPartOrders;

    // Showroom Decor & District Traffic Boosts
    final hasLedGrid = state.hasDecor('decor_led_grid');
    final hasGranite = state.hasDecor('decor_granite_floor');
    final hasTotem = state.hasDecor('decor_led_totem_sign');
    final bagcilarDominance =
        (updatedDistrictShares['Bağcılar Oto Pazarı'] ?? 0.0) >= 0.50;
    if ((hasLedGrid || hasGranite || hasTotem || bagcilarDominance) &&
        currentCars.any((c) => c.isListed && !c.isRented)) {
      triggerOrganicOffers();
    }

    // Satış Sonrası CRM & Karma Olayları Kuyruk İşleme
    CustomerCrmEventModel? nextActiveCrm = state.activeCrmEvent;
    final remainingCrmEvents =
        List<CustomerCrmEventModel>.from(state.pendingCrmEvents);
    if (nextActiveCrm == null && remainingCrmEvents.isNotEmpty) {
      final readyIndex =
          remainingCrmEvents.indexWhere((e) => e.triggerDay <= nextDay);
      if (readyIndex != -1) {
        nextActiveCrm = remainingCrmEvents.removeAt(readyIndex);
      }
    }

    // Process Multi-Day Active Service Jobs (§SPEC-2026-RUSH-LORE-MASTER)
    final serviceJobsResult = _processActiveServiceJobs(
        nextDay,
        List<ActiveServiceJobModel>.from(state.activeServiceJobs),
        currentCars,
        newEvents);
    final updatedServiceJobs = serviceJobsResult.$1;
    currentCars = serviceJobsResult.$2;
    newEvents = serviceJobsResult.$3;

    // Process pending part orders delivery progression on new day
    final updatedPendingOrders = state.pendingOrders.map((order) {
      if (!order.isDelivered) {
        return order.copyWith(
          orderedAt: DateTime.now().subtract(
            Duration(seconds: order.deliveryDurationSeconds + 1),
          ),
        );
      }
      return order;
    }).toList();

    // Process custom paint oven curing completions
    int paintCompletedCount = 0;
    currentCars = currentCars.map((c) {
      if (c.isPainting && nextDay >= c.paintReadyDay) {
        paintCompletedCount++;
        final newColorName = c.pendingPaintName ?? c.colorDisplayName;
        final newColorHex = c.pendingPaintHex ?? c.colorHex;
        final newColorRarity = c.pendingPaintRarity ?? c.colorRarity;
        newEvents.insert(
          0,
          GameEventModel(
            id: 'evt_paint_done_${c.id}_$nextDay',
            title: '${c.brand} ${c.modelName} • Fırın Boyası Tamamlandı',
            description:
                '${c.brand} ${c.modelName} boya fırınından çıktı ve yeni rengiyle • $newColorName • teslim edildi.',
            amount: 0.0,
            type: GameEventType.goodEvent,
            date: DateTime.now(),
          ),
        );
        return c.copyWith(
          colorHex: newColorHex,
          colorDisplayName: newColorName,
          colorRarity: newColorRarity,
          paintReadyDay: 0,
          clearPendingPaint: true,
        );
      }
      return c;
    }).toList();

    if (paintCompletedCount > 0) {
      addXP(40 * paintCompletedCount);
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
      activeServiceJobs: updatedServiceJobs,
      pendingOrders: updatedPendingOrders,
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
      playerSpreadGossips: updatedPlayerGossips,
      incomingTradeInOffers: updatedTradeOffers,
      consignmentOffers: updatedConsignmentOffers,
      districtMarketShare: updatedDistrictShares,
      dailyRacesRemaining: 3, // Her gün 3 yarış hakkı yenilenir
      pendingCrmEvents: remainingCrmEvents,
      activeCrmEvent: nextActiveCrm,
    );

    _lastDayAdvanceTime = DateTime.now();
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

    // Ek Gayrimenkul Tapu Bakım & Çevre Aidatları
    final deedCount = state.ownedBranchDeeds.length;
    if (deedCount > 0) {
      burn += deedCount * 1250.0;
    }

    return balance - burn;
  }

  (double, List<StaffModel>, List<GameEventModel>) _processSalaries(
      double balance, List<StaffModel> staff, List<GameEventModel> events) {
    if (staff.isEmpty) return (balance, staff, events);

    // 1. Process staff training progression & graduations
    List<StaffModel> updatedStaff = [];
    for (final s in staff) {
      if (s.isUnderTraining) {
        final remaining = s.trainingDaysRemaining - 1;
        if (remaining <= 0) {
          final courseId = s.currentTrainingCourseId;
          final course = courseId != null
              ? StaffRoleSpecializations.allCourses.firstWhere(
                  (c) => c.id == courseId,
                  orElse: () => StaffRoleSpecializations.allCourses.first,
                )
              : null;
          final updatedCourses = courseId != null &&
                  !s.completedCourseIds.contains(courseId)
              ? [...s.completedCourseIds, courseId]
              : s.completedCourseIds;
          StaffPerk? assignedPerk = s.perk;
          if (assignedPerk == null) {
            switch (s.role) {
              case StaffRole.washer:
                assignedPerk = StaffPerk.meticulous;
                break;
              case StaffRole.apprentice:
                assignedPerk = StaffPerk.hardWorker;
                break;
              case StaffRole.salesman:
                assignedPerk = StaffPerk.silverTongue;
                break;
              case StaffRole.masterMechanic:
              case StaffRole.appraiser:
                assignedPerk = StaffPerk.meticulous;
                break;
              case StaffRole.marketer:
                assignedPerk = StaffPerk.silverTongue;
                break;
              case StaffRole.legalAdvisor:
                assignedPerk = StaffPerk.thrifty;
                break;
            }
          }
          final newMorale = min(100, s.morale + 25);
          final newMastery = min(5, s.masteryLevel + 1);
          updatedStaff.add(s.copyWith(
            completedCourseIds: updatedCourses,
            morale: newMorale,
            masteryLevel: newMastery,
            perk: assignedPerk,
            specialization: course?.title ?? s.specialization,
            isUnderTraining: false,
            trainingDaysRemaining: 0,
            totalTrainingDays: 0,
            currentTrainingCourseId: null,
          ));
          events.insert(
            0,
            GameEventModel(
              id: 'staff_grad_${DateTime.now().millisecondsSinceEpoch}_${s.id}',
              title: 'USTALIK MEZUNİYETİ!',
              description:
                  '${s.name}, ${course?.title ?? "kurs"} eğitimini üstün başarıyla tamamladı ve diplomasını alarak görevine döndü!',
              type: GameEventType.goodEvent,
              amount: 0.0,
              date: DateTime.now(),
            ),
          );
        } else {
          final newEnergy = max(0, s.energy - 10);
          updatedStaff.add(s.copyWith(
            trainingDaysRemaining: remaining,
            energy: newEnergy,
          ));
        }
      } else if (s.isOnLeave) {
        final remainingLeave = s.leaveDaysRemaining - 1;
        final recoveredEnergy = min(100, s.energy + 50);
        final refreshedMorale = min(100, s.morale + 5);
        if (remainingLeave <= 0) {
          updatedStaff.add(s.copyWith(
            isOnLeave: false,
            leaveDaysRemaining: 0,
            energy: recoveredEnergy,
            morale: refreshedMorale,
          ));
          events.insert(
            0,
            GameEventModel(
              id: 'staff_leave_end_${DateTime.now().millisecondsSinceEpoch}_${s.id}',
              title: 'PERSONEL İZİNDEN DÖNDÜ!',
              description:
                  '${s.name} dinlenme iznini tamamladı, enerjisini toplayarak - %$recoveredEnergy Enerji ile - göreve geri döndü!',
              type: GameEventType.goodEvent,
              amount: 0.0,
              date: DateTime.now(),
            ),
          );
        } else {
          updatedStaff.add(s.copyWith(
            leaveDaysRemaining: remainingLeave,
            energy: recoveredEnergy,
            morale: refreshedMorale,
          ));
        }
      } else {
        // Working staff daily fatigue
        final decay = s.perk == StaffPerk.hardWorker ? 8 : 12;
        final newEnergy = max(0, s.energy - decay);
        updatedStaff.add(s.copyWith(energy: newEnergy));
      }
    }

    // 2. Process daily salaries and morale
    double totalSalaries = updatedStaff.fold(0.0, (sum, st) => sum + st.dailySalary);
    if (state.specializationPath == SpecializationPath.boss) {
      totalSalaries *= 0.80;
    }

    if (balance >= totalSalaries) {
      final finalStaff = updatedStaff
          .map((s) => s.copyWith(morale: min(100, s.morale + 1)))
          .toList();
      return (balance - totalSalaries, finalStaff, events);
    } else {
      final remainingStaff = <StaffModel>[];
      final resignedStaff = <StaffModel>[];

      for (final s in updatedStaff) {
        final newMorale = s.morale - 35;
        if (newMorale <= 10) {
          resignedStaff.add(s);
        } else {
          remainingStaff.add(s.copyWith(morale: newMorale));
        }
      }

      if (resignedStaff.isNotEmpty) {
        final names =
            resignedStaff.map((s) => '${s.name} • ${s.role.name}').join(', ');
        events.insert(
            0,
            GameEventModel(
              id: 'staff_resignation_${DateTime.now().millisecondsSinceEpoch}',
              title: 'PERSONEL İSTİFASI!',
              description:
                  'Maaş ödemeleri yapılamadığı için $names morali tükenerek galerinizi terk etti ve istifa etti!',
              type: GameEventType.expense,
              amount: 0.0,
              date: DateTime.now(),
            ));
      } else {
        events.insert(
            0,
            GameEventModel(
              id: 'salary_unpaid_${DateTime.now().millisecondsSinceEpoch}',
              title: 'MAAŞLAR ÖDENEMEDİ!',
              description:
                  'Kasada yeterli nakit olmadığı için personellerin günlük maaşı ödenemedi. Personel morali ağır darbe aldı • -35 Moral!',
              type: GameEventType.expense,
              amount: 0.0,
              date: DateTime.now(),
            ));
      }

      return (balance, remainingStaff, events);
    }
  }

  List<CarModel> _processStaffAutomation(
      List<StaffModel> staff, List<CarModel> cars) {
    final hasCarWashBusiness = state.sideBusinesses
        .any((b) => b.isOperational && b.type == SideBusinessType.carWash);
    final hasWasher =
        staff.any((s) => s.isAvailableForWork && s.role == StaffRole.washer) || hasCarWashBusiness;
    final hasMechanic = staff.any((s) => s.isAvailableForWork && s.role == StaffRole.masterMechanic);

    if (hasWasher && cars.isNotEmpty) {
      int washedCount = 0;
      final maxCleanPerDay = hasCarWashBusiness ? 5 : 2;
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i];
        if (!car.isWashed || !car.isPolished || !car.isDetailedCleaned) {
          cars[i] = car.copyWith(
              isWashed: true, isPolished: true, isDetailedCleaned: true);
          washedCount++;
          if (washedCount >= maxCleanPerDay) break;
        }
      }
    }

    if (hasMechanic && cars.isNotEmpty) {
      for (int i = 0; i < cars.length; i++) {
        final car = cars[i];
        if (car.expertise.engineCondition < 100 ||
            car.expertise.transmissionCondition < 100) {
          final newEngine = min(100.0, car.expertise.engineCondition + 20.0);
          final newTrans =
              min(100.0, car.expertise.transmissionCondition + 20.0);
          cars[i] = car.copyWith(
              expertise: car.expertise.copyWith(
                  engineCondition: newEngine, transmissionCondition: newTrans));
          break;
        }
      }
    }
    return cars;
  }

  (double, List<LoanModel>) _processLoans(
      int nextDay, double balance, List<LoanModel> loans) {
    return LoanSettlementEngine.processWeeklyLoans(
      nextDay: nextDay,
      balance: balance,
      loans: loans,
    );
  }

  (
    double,
    List<CarModel>,
    List<RentalAgreement>,
    List<GameEventModel>,
    List<OfferModel>
  ) _processRentals(
      double balance,
      List<CarModel> cars,
      List<RentalAgreement> rentals,
      List<GameEventModel> events,
      List<OfferModel> incomingOffers) {
    return RentalProgressionEngine.processDailyRentals(
      balance: balance,
      cars: cars,
      rentals: rentals,
      events: events,
      incomingOffers: incomingOffers,
      random: random,
    );
  }

  (double, List<InstallmentContract>) _processInstallments(
      double balance, List<InstallmentContract> installments) {
    return LoanSettlementEngine.processInstallments(
      balance: balance,
      installments: installments,
      random: random,
    );
  }

  (double, List<Cheque>) _processCheques(double balance, List<Cheque> cheques) {
    return LoanSettlementEngine.processCheques(
      balance: balance,
      cheques: cheques,
      chequeRiskReduction: state.skills.chequeRiskReduction,
      random: random,
    );
  }

  (double, List<CarModel>, List<LoanModel>, List<String>, List<GameEventModel>)
      _processBankruptcy(
          int nextDay,
          double balance,
          List<CarModel> cars,
          List<LoanModel> loans,
          List<String> dynasty,
          List<GameEventModel> events) {
    return LoanSettlementEngine.processBankruptcy(
      nextDay: nextDay,
      balance: balance,
      cars: cars,
      loans: loans,
      dynastyHistory: dynasty,
      events: events,
      bankDepositBalance: state.bankDepositBalance,
    );
  }

  (double, List<SideBusinessModel>) _processSideBusinesses(
      double balance, List<CarModel> cars, List<SideBusinessModel> businesses) {
    final updatedList = <SideBusinessModel>[];
    for (final b in businesses) {
      if (!b.isOwned) {
        updatedList.add(b);
        continue;
      }

      SideBusinessModel current = b;

      // 1. Process initial construction
      if (current.isUnderConstruction) {
        final remaining = current.constructionDaysRemaining - 1;
        if (remaining <= 0) {
          current = current.copyWith(
            isUnderConstruction: false,
            constructionDaysRemaining: 0,
          );
        } else {
          current = current.copyWith(
            constructionDaysRemaining: remaining,
          );
        }
      }

      // 2. Process Level Upgrade
      if (current.isUpgradingLevel) {
        final remaining = current.levelUpgradeDaysRemaining - 1;
        if (remaining <= 0) {
          final newLevel = current.pendingTargetLevel > current.level
              ? current.pendingTargetLevel
              : current.level + 1;
          current = current.copyWith(
            level: newLevel,
            isUpgradingLevel: false,
            levelUpgradeDaysRemaining: 0,
          );
        } else {
          current = current.copyWith(
            levelUpgradeDaysRemaining: remaining,
          );
        }
      }

      // 3. Process Sub-Upgrades
      if (current.upgrades.any((u) => u.isPurchased && u.isUpgrading)) {
        final updatedUpgrades = current.upgrades.map((u) {
          if (u.isPurchased && u.isUpgrading) {
            final remaining = u.upgradeDaysRemaining - 1;
            if (remaining <= 0) {
              return u.copyWith(
                isUpgrading: false,
                upgradeDaysRemaining: 0,
              );
            } else {
              return u.copyWith(
                upgradeDaysRemaining: remaining,
              );
            }
          }
          return u;
        }).toList();
        current = current.copyWith(upgrades: updatedUpgrades);
      }

      updatedList.add(current);
    }

    return SideBusinessEngine.processDailyEarnings(
      balance: balance,
      cars: cars,
      businesses: updatedList,
      specializationPath: state.specializationPath,
      carsWashedLast7Days: state.carsWashedLast7Days,
      expertisesPerformedLast7Days: state.expertisesPerformedLast7Days,
      partsRepairedLast7Days: state.partsRepairedLast7Days,
      towedCarsLast7Days: state.towedCarsLast7Days,
      activeRentalsCount: state.activeRentals.length,
    );
  }

  (double, List<GameEventModel>) _processRealEstateRentals(
      double balance,
      List<RealEstateModel> properties,
      List<GameEventModel> events) {
    if (properties.isEmpty) return (balance, events);

    double totalDailyRent = 0.0;
    int rentedCount = 0;

    for (final prop in properties) {
      if (prop.isRented) {
        totalDailyRent += prop.dailyRentIncome;
        rentedCount++;
      }
    }

    if (totalDailyRent > 0) {
      final updatedEvents = List<GameEventModel>.from(events);
      updatedEvents.insert(
        0,
        GameEventModel(
          id: 'real_estate_rent_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Gayrimenkul Kira Geliri',
          description:
              'Portföyünüzdeki $rentedCount adet kiradaki mülkten toplam ${CurrencyFormatter.format(totalDailyRent)} günlük kira geliri tahsil edildi.',
          amount: totalDailyRent,
          type: GameEventType.income,
          date: DateTime.now(),
        ),
      );
      addXP(15 * rentedCount);
      return (balance + totalDailyRent, updatedEvents);
    }

    return (balance, events);
  }

  (List<CarModel>, double, List<GameEventModel>) _processConsignmentDays(
      List<CarModel> cars, List<GameEventModel> events) {
    final updated = <CarModel>[];
    double dailyParkingEarnings = 0.0;
    final parkingPerCar =
        ConsignmentEngine.calculateDailyParkingFee(state.currentBranchTier);

    for (final car in cars) {
      if (car.isConsignment) {
        dailyParkingEarnings += parkingPerCar;
        final daysLeft = car.consignmentDaysRemaining - 1;
        if (daysLeft <= 0) {
          events.insert(
              0,
              GameEventModel(
                id: 'consignment_expired_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
                title: 'Emanet Araç Süresi Doldu',
                description:
                    '${car.consignmentOwnerName ?? "Sahibi"}, ${car.brand} ${car.modelName} emanet süresi dolduğu için aracı teslim aldı.',
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
      events.insert(
          0,
          GameEventModel(
            id: 'consignment_parking_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Emanet Otopark & Sergileme Geliri',
            description:
                'Vitrindeki emanet araçlardan günlük toplam ${CurrencyFormatter.format(dailyParkingEarnings)} sergileme ücreti kazanıldı.',
            amount: dailyParkingEarnings,
            type: GameEventType.income,
            date: DateTime.now(),
          ));
    }

    return (updated, dailyParkingEarnings, events);
  }

  (double, List<CarModel>, int, List<GameEventModel>) _processBlackMarketRaid(
      double balance,
      List<CarModel> cars,
      int reputation,
      List<GameEventModel> events) {
    final hasGossipWarning = state.activeGossips.any((g) =>
        (g.type == GossipType.rivalIntel ||
            g.id.contains('police_raid') ||
            g.id.contains('tasfiye')) &&
        g.isPurchased);
    final hasLegalAdvisor =
        state.hiredStaff.any((s) => s.role == StaffRole.legalAdvisor);

    // Find all black market cars in inventory
    final bmIndices = <int>[];
    for (int i = 0; i < cars.length; i++) {
      final c = cars[i];
      if (c.isBlackMarket ||
          c.modelName.contains('Karaborsa') ||
          c.id.startsWith('bm_')) {
        bmIndices.add(i);
      }
    }

    if (bmIndices.isEmpty) {
      return (balance, cars, reputation, events);
    }

    final carsToRemove = <CarModel>[];

    for (final idx in bmIndices) {
      final car = cars[idx];
      final riskRate =
          (car.blackMarketRiskPercent > 0 ? car.blackMarketRiskPercent : 25) /
              100.0;
      final hasNazarPrayer = state.hasDecor('decor_nazar_prayer_frame');
      final adjustedChance = riskRate * (hasNazarPrayer ? 0.85 : 1.0);

      if (random.nextDouble() < adjustedChance) {
        if (hasGossipWarning) {
          events.insert(
              0,
              GameEventModel(
                id: 'gossip_evaded_${car.id}_${DateTime.now().millisecondsSinceEpoch}',
                title: 'İSTİHBARAT SAYESİNDE BASKIN ATLATILDI!',
                description:
                    'Kahvehaneden satın aldığınız "Polis Baskını" istihbaratı sayesinde ${car.brand} ${car.modelName} aracını önceden gizli depoya çektiniz. Denetim ekibi galeride hiçbir kusur bulamadı!',
                type: GameEventType.goodEvent,
                amount: 0.0,
                date: DateTime.now(),
              ));
          continue;
        }

        final raidResult = BlackMarketEngine.processRaid(
          car: car,
          hasLegalAdvisor: hasLegalAdvisor,
          random: random,
        );

        if (raidResult.shouldSeizeCar) {
          carsToRemove.add(car);
        } else if (raidResult.updatedCar != null) {
          final carIdx = cars.indexOf(car);
          if (carIdx != -1) {
            cars[carIdx] = raidResult.updatedCar!;
          }
        }

        if (raidResult.fine > 0) {
          balance = (balance - raidResult.fine).clamp(0.0, double.infinity);
        }
        if (raidResult.reputationLoss > 0) {
          reputation = (reputation - raidResult.reputationLoss).clamp(0, 200);
        }
        events.insert(0, raidResult.event);
      }
    }

    for (final c in carsToRemove) {
      cars.removeWhere((item) => item.id == c.id);
    }

    return (balance, cars, reputation, events);
  }

  (List<CarModel>, List<GameEventModel>) _processVandalism(
      List<CarModel> cars, List<GameEventModel> events) {
    final hasSecurity = state.hasFullSecurityProtection;
    if (!hasSecurity &&
        cars.any((c) => c.isListed) &&
        random.nextDouble() < 0.04) {
      final listedCars = cars.where((c) => c.isListed).toList();
      final targetCar = listedCars[random.nextInt(listedCars.length)];
      final carIdx = cars.indexOf(targetCar);
      if (carIdx != -1) {
        final updatedParts =
            Map<String, PartStatus>.from(targetCar.expertise.bodyParts);
        if (updatedParts.isNotEmpty) {
          final firstKey = updatedParts.keys.first;
          updatedParts[firstKey] = PartStatus.damaged;
        }
        cars[carIdx] = targetCar.copyWith(
          expertise: targetCar.expertise.copyWith(
            bodyParts: updatedParts,
          ),
        );
        events.insert(
            0,
            GameEventModel(
              id: 'vandalism_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Gece Park Halinde Çizilme / Vandalizm',
              description:
                  'Showroom güvenlik kameranız olmadığı için ${targetCar.brand} ${targetCar.modelName} gece çizildi! Kaporta/boya sağlığı düştü.',
              type: GameEventType.expense,
              amount: 0.0,
              date: DateTime.now(),
            ));
      }
    }
    return (cars, events);
  }

  (List<StockModel>, double, List<GameEventModel>)
      _processStockMarketAndDividends(
    int nextDay,
    double balance,
    List<StockModel> stocks,
    List<PlayerStockModel> ownedStocks,
    List<GameEventModel> events,
  ) {
    final (updatedStocks, updatedBal, updatedEvents) =
        StockMarketEngine.processStockFluctuationsAndDividends(
      nextDay: nextDay,
      balance: balance,
      stocks: stocks,
      ownedStocks: ownedStocks,
      events: events,
      activeNews: state.activeNews,
      random: random,
    );

    return StockMarketEngine.processQuarterlyFinancialReport(
      nextDay: nextDay,
      balance: updatedBal,
      stocks: updatedStocks,
      events: updatedEvents,
      reputationScore: state.reputationScore,
      totalProfit: state.totalProfit,
      isCompanyListed: state.isCompanyListedOnBist,
    );
  }

  List<ForexGoldModel> _processForexMarket(List<ForexGoldModel> forexList) {
    return StockMarketEngine.processForexFluctuations(
      forexList: forexList,
      random: random,
    );
  }

  (
    List<IpoOfferModel>,
    List<PlayerIpoRequestModel>,
    double,
    List<GameEventModel>
  ) _processIpoMarket(
    int nextDay,
    double balance,
    List<IpoOfferModel> ipos,
    List<PlayerIpoRequestModel> requests,
    List<GameEventModel> events,
  ) {
    return StockMarketEngine.processIpoSettlement(
      nextDay: nextDay,
      balance: balance,
      ipos: ipos,
      requests: requests,
      events: events,
    );
  }

  double _processDailyTax(double balance) {
    final totalLiquid = state.balance + state.bankDepositBalance;
    final tax = LoanSettlementEngine.calculateDailyTax(state.level,
        totalLiquidWealth: totalLiquid);
    return balance - tax;
  }

  List<GameEventModel> _createDailySummaryEvent(
      int nextDay, double newBalance, List<GameEventModel> events) {
    final double netDayChange = newBalance - state.balance;
    final summaryEvent = GameEventModel(
      id: 'day_summary_$nextDay',
      title: 'Gün $nextDay Kapanış Özeti',
      description:
          'Giderler, personel maaşları ve pasif gelirler hesaplandı. Net günlük değişim: ${netDayChange >= 0 ? "+₺${netDayChange.round()}" : "-₺${netDayChange.abs().round()}"}.',
      type: netDayChange >= 0 ? GameEventType.income : GameEventType.expense,
      amount: netDayChange,
      date: DateTime.now(),
    );
    events.insert(0, summaryEvent);
    if (events.length > 50) events = events.sublist(0, 50);
    return events;
  }

  MarketNewsModel? _processMarketNews(
      int nextDay, MarketNewsModel? currentNews) {
    if (currentNews == null || nextDay % 5 == 0) {
      return MarketNewsModel
          .newsList[random.nextInt(MarketNewsModel.newsList.length)];
    }
    return currentNews;
  }

  (
    List<ScrapyardCar>,
    List<BlackMarketCarModel>
  ) _processScrapyardAndBlackMarket(
      int nextDay, List<ScrapyardCar> scrap, List<BlackMarketCarModel> black) {
    if (nextDay % 3 == 0 || scrap.isEmpty) {
      scrap = _generateRandomScrapyardCars(nextDay);
    }
    if (nextDay % 3 == 0 || black.isEmpty) {
      black = _generateRandomBlackMarketCars(nextDay);
    }
    return (scrap, black);
  }

  (int, int, StoryCardModel?) _processStoryAd(
      int daysSince, int targetDays, StoryCardModel? pendingCard) {
    int updatedDays = daysSince + 1;
    if (updatedDays >= targetDays && pendingCard == null) {
      pendingCard = selectNextStoryCard();
      updatedDays = 0;
      targetDays = 7 + random.nextInt(15);
    }
    return (updatedDays, targetDays, pendingCard);
  }

  (int, int, DramaticCardModel?) _processDramaticDecision(
      int nextDay, int daysSince, int targetDays, DramaticCardModel? pendingCard) {
    int updatedDays = daysSince + 1;
    if (pendingCard == null) {
      pendingCard = DramaticCardEngine.generateDailyDilemma(nextDay, state,
          randomInstance: random);
      updatedDays = 0;
      targetDays = 1;
    }
    return (updatedDays, targetDays, pendingCard);
  }

  (int, int, GameEventModel?, List<String>) _processRandomEvents(int daysSince,
      int targetDays, GameEventModel? pendingCard, List<String> seenIds) {
    int updatedDays = daysSince + 1;
    if (updatedDays >= targetDays && pendingCard == null) {
      pendingCard = RandomEventEngine.getFilteredRandomEvent(state);
      if (pendingCard != null) {
        seenIds.add(pendingCard.id);
        if (seenIds.length > 12) seenIds.removeAt(0);
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

  (double, String?, List<GameEventModel>) _processDisputes(int nextDay,
      double balance, String? currentDispute, List<GameEventModel> events) {
    if (state.dirtyRecordCount > 0 && random.nextDouble() < 0.12) {
      final lawsuitFine = (15000.0 + random.nextInt(25000)).roundToDouble();
      balance = max(0.0, balance - lawsuitFine);
      currentDispute =
          'Eski bir alıcı kusurlu araç gerekçesiyle Tüketici Heyeti üzerinden ₺${lawsuitFine.round()} tazminat kazandı!';
      events.insert(
          0,
          GameEventModel(
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

  List<OfferModel> _processLoyalCustomerOffers(
      List<CarModel> cars, List<OfferModel> offers) {
    final availableCars = cars
        .where((c) => c.isListed && !c.isRented && !c.isLockedInShowcase)
        .toList();
    if (state.loyalCustomerNames.isNotEmpty &&
        availableCars.isNotEmpty &&
        random.nextDouble() < 0.25) {
      final randomCar = availableCars[random.nextInt(availableCars.length)];
      final randomCustomer = state
          .loyalCustomerNames[random.nextInt(state.loyalCustomerNames.length)];
      final loyalOffer = NegotiationEngine.generateLoyalCustomerOffer(
          car: randomCar, customerName: randomCustomer);
      offers.add(loyalOffer);
    }
    return offers;
  }

  double _processBankInterest(double deposit) {
    if (deposit >= 100.0) {
      final double dailyInterest = (deposit * 0.0012).roundToDouble();
      deposit += dailyInterest;
    }
    return deposit;
  }

  (Map<String, double>, List<GameEventModel>) _processDistrictMarketDecay(
    Map<String, double> currentShares,
    List<GameEventModel> events, {
    Random? randomInstance,
  }) =>
      DistrictEconomyEngine.processDecay(currentShares, events,
          random: randomInstance ?? random);

  @visibleForTesting
  (Map<String, double>, List<GameEventModel>)
      processDistrictMarketDecayForTesting(
    Map<String, double> currentShares,
    List<GameEventModel> events, {
    Random? randomInstance,
  }) =>
          _processDistrictMarketDecay(currentShares, events,
              randomInstance: randomInstance);

  @visibleForTesting
  double processBankInterestForTesting(double deposit) =>
      _processBankInterest(deposit);

  List<MissionModel> _processDailyMissions(List<MissionModel> missions) {
    if (missions.isEmpty || missions.every((m) => m.isClaimed)) {
      return MissionFactory.generateDailyMissions(
        state.level,
        unlockedBuildings: state.unlockedBuildings,
      );
    }
    return missions;
  }

  List<WantedCarContract> _processVIPContracts(
      List<WantedCarContract> contracts) {
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

  List<TradeInOfferModel> _processTradeInOffers(
      int nextDay, List<CarModel> cars, List<TradeInOfferModel> offers) {
    // Retain only offers whose target cars still exist and are tradeable
    offers = offers
        .where((t) =>
            t.expiresInDays > 1 &&
            cars.any((c) =>
                c.id == t.targetCarId &&
                !c.isRented &&
                !c.isConsignment &&
                !c.isLockedInShowcase))
        .map((t) => t.copyWith(expiresInDays: t.expiresInDays - 1))
        .toList();

    final tradeableCars = cars
        .where((c) =>
            c.isListed &&
            !c.isRented &&
            !c.isConsignment &&
            !c.isLockedInShowcase)
        .toList();
    if (tradeableCars.isNotEmpty && random.nextDouble() < 0.35) {
      final targetCar = tradeableCars[random.nextInt(tradeableCars.length)];
      final tradeOffer = TradeInEngine.generateTradeInOffer(
          targetCar: targetCar, inGameDay: nextDay);
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
    if (car.isRented) {
      return {
        'success': false,
        'message': 'Araç kirada olduğu için torpido aranamaz.'
      };
    }
    if (car.hasGloveboxSearched) {
      return {
        'success': false,
        'message': 'Torpido gözü daha önce zaten arandı.'
      };
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
      'message': 'Torpido gözünde "$item" bulundu! • +₺${cashBonus.round()}',
    };
  }

  /// Batch action: Wash and polish all unwashed cars in showroom (§1.5 / Q10)
  int washAllShowroomCars() {
    final unwashed =
        state.ownedCars.where((c) => !c.isWashed || !c.isPolished).toList();
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
    final newBalance = state.balance + choice.balanceChange;
    final newReputation =
        (state.reputationScore + choice.reputationChange).clamp(0, 1000);
    state = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      clearPendingRandomEvent: true,
    );
    if (choice.xpGain > 0) {
      addXP(choice.xpGain);
    }
    saveState();
  }

  /// Dismisses a pending random event without making a choice
  void dismissPendingRandomEvent() {
    state = state.copyWith(clearPendingRandomEvent: true);
  }

  /// Selects the next available narrative card from the pool, preventing repeats until cycle completes
  StoryCardModel? selectNextStoryCard() {
    final allCards = StoryCardModel.defaultCards;
    List<StoryCardModel> availableCards =
        allCards.where((c) => !state.seenStoryCardIds.contains(c.id)).toList();

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
  void resolveStoryCard(
      {required StoryCardModel card, required bool accepted}) {
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
            final targetIndex = updatedCars.indexWhere((c) =>
                c.expertise.engineCondition < 100 ||
                c.expertise.transmissionCondition < 100);
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
            modelName: 'Bemeve E36 Coupe • Koleksiyon / Kelepir',
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
          final listedCars =
              updatedCars.where((c) => c.isListed && !c.isRented).toList();
          if (listedCars.isNotEmpty) {
            final targetCar = listedCars.first;
            final bonusOfferPrice = ((targetCar.listingPrice > 0
                        ? targetCar.listingPrice
                        : targetCar.estimatedRealValue) *
                    1.10)
                .roundToDouble();
            final husnuOffer = OfferModel(
              id: 'offer_husnu_${DateTime.now().millisecondsSinceEpoch}',
              carId: targetCar.id,
              buyerName: 'Hüsnü Bey • İkramlı Müşteri',
              offeredAmount: bonusOfferPrice,
              buyerMessage:
                  'Kahve ve ikramlar için teşekkürler, bu fiyata el sıkışalım!',
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
          final listedCars =
              updatedCars.where((c) => c.isListed && !c.isRented).toList();
          if (listedCars.isNotEmpty) {
            final targetCar = listedCars.first;
            final basePrice = targetCar.listingPrice > 0
                ? targetCar.listingPrice
                : targetCar.estimatedRealValue;
            final names = [
              'Berk Takipçisi Can',
              'Reels Alıcısı Murat',
              'Vlog İzleyicisi Sarp'
            ];
            for (int i = 0; i < names.length; i++) {
              final mult = 0.98 + (i * 0.05); // 0.98, 1.03, 1.08
              updatedOffers.add(
                OfferModel(
                  id: 'offer_viral_${i}_${DateTime.now().millisecondsSinceEpoch}',
                  carId: targetCar.id,
                  buyerName: names[i],
                  offeredAmount: (basePrice * mult).roundToDouble(),
                  buyerMessage:
                      'Vlogger Berk’in videosunda gördüm, aracı hemen almak istiyorum!',
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
        modelName: 'Bemeve 3.20d Yanlama E-90 • Ağır Pert',
        modelYear: 2016,
        scrapPrice: 140000.0,
        estimatedPartTotalValue: 280000.0,
        damageNote:
            'Önden ağır taklalı, tavan ezik. Motor ve şanzıman sapasağlam.',
        chassisScrapMetalWeightKg: 1450,
        chassisScrapValue: 8700.0,
        surpriseFindItem: 'Orijinal Harman Kardon Amfi & M Vites Topuzu',
        surpriseFindValue: 4500.0,
        parts: const [
          SalvagedPart(
              id: 'p_1_1',
              name: '2.0 TwinPower Turbo Motor Bloğu',
              carModelName: 'Bemeve 3.20d',
              category: 'engine',
              conditionPercent: 88,
              estimatedValue: 120000.0),
          SalvagedPart(
              id: 'p_1_2',
              name: '8 İleri ZF Otomatik Şanzıman',
              carModelName: 'Bemeve 3.20d',
              category: 'transmission',
              conditionPercent: 92,
              estimatedValue: 85000.0),
          SalvagedPart(
              id: 'p_1_3',
              name: '19" M Alaşım Çift Jant Takımı',
              carModelName: 'Bemeve 3.20d',
              category: 'wheels',
              conditionPercent: 80,
              estimatedValue: 35000.0),
          SalvagedPart(
              id: 'p_1_4',
              name: 'Harman Kardon Müzik Sistemi',
              carModelName: 'Bemeve 3.20d',
              category: 'audio',
              conditionPercent: 95,
              estimatedValue: 40000.0),
        ],
      ),
      ScrapyardCar(
        id: 'scrap_${day}_2',
        brand: 'Vosgen',
        modelName: 'Vosgen Golf Sekiz R-Line • Pert Kayıtlı',
        modelYear: 2018,
        scrapPrice: 190000.0,
        estimatedPartTotalValue: 360000.0,
        damageNote: 'Arkadan kamyon çarpması sonrası pert kararı verilmiş.',
        chassisScrapMetalWeightKg: 1320,
        chassisScrapValue: 7920.0,
        surpriseFindItem: 'Fabrika Takım Çantası & Yedek Anahtar',
        surpriseFindValue: 3000.0,
        parts: const [
          SalvagedPart(
              id: 'p_2_1',
              name: '2.0 TSI GTI Turbo Şarj Kiti',
              carModelName: 'Vosgen Golf',
              category: 'turbo',
              conditionPercent: 94,
              estimatedValue: 65000.0),
          SalvagedPart(
              id: 'p_2_2',
              name: 'DSG Islak Kavrama Şanzıman',
              carModelName: 'Vosgen Golf',
              category: 'transmission',
              conditionPercent: 90,
              estimatedValue: 95000.0),
          SalvagedPart(
              id: 'p_2_3',
              name: 'Karbon Difüzör & Çift Egzoz Takımı',
              carModelName: 'Vosgen Golf',
              category: 'bodywork',
              conditionPercent: 85,
              estimatedValue: 45000.0),
          SalvagedPart(
              id: 'p_2_4',
              name: 'GTI Hayalet Gösterge & Direksiyon',
              carModelName: 'Vosgen Golf',
              category: 'bodywork',
              conditionPercent: 96,
              estimatedValue: 75000.0),
        ],
      ),
      ScrapyardCar(
        id: 'scrap_${day}_3',
        brand: 'Merso',
        modelName: 'Merso C-200 Makam AMG • Yanık/Pert',
        modelYear: 2017,
        scrapPrice: 165000.0,
        estimatedPartTotalValue: 310000.0,
        damageNote: 'Elektrik kontağından motor kompartımanı kısmen hasarlı.',
        chassisScrapMetalWeightKg: 1550,
        chassisScrapValue: 9300.0,
        surpriseFindItem: 'Nostaljik Becker Teyp & Orijinal Ruhsat Kabı',
        surpriseFindValue: 3800.0,
        parts: const [
          SalvagedPart(
              id: 'p_3_1',
              name: 'AMG Deri Koltuk & İç Döşeme Takımı',
              carModelName: 'Merso C-200',
              category: 'bodywork',
              conditionPercent: 92,
              estimatedValue: 80000.0),
          SalvagedPart(
              id: 'p_3_2',
              name: '9G-Tronic Otomatik Şanzıman',
              carModelName: 'Merso C-200',
              category: 'transmission',
              conditionPercent: 89,
              estimatedValue: 110000.0),
          SalvagedPart(
              id: 'p_3_3',
              name: 'Burmester VIP Ses Sistemi',
              carModelName: 'Merso C-200',
              category: 'audio',
              conditionPercent: 98,
              estimatedValue: 55000.0),
          SalvagedPart(
              id: 'p_3_4',
              name: 'AMG MultiBeam LED Far Takımı',
              carModelName: 'Merso C-200',
              category: 'bodywork',
              conditionPercent: 85,
              estimatedValue: 65000.0),
        ],
      ),
    ];
  }

  List<BlackMarketCarModel> _generateRandomBlackMarketCars(int day) {
    return BlackMarketEngine.generateBlackMarketCars(
      day: day,
      count: 4,
      playerLevel: state.level,
    );
  }

  (List<ActiveServiceJobModel>, List<CarModel>, List<GameEventModel>)
      _processActiveServiceJobs(
    int nextDay,
    List<ActiveServiceJobModel> jobs,
    List<CarModel> currentCars,
    List<GameEventModel> events,
  ) {
    final remainingJobs = <ActiveServiceJobModel>[];
    var updatedCars = List<CarModel>.from(currentCars);

    for (final job in jobs) {
      final updatedRemaining = job.remainingDays - 1;
      if (updatedRemaining <= 0) {
        // Job is completed!
        events.insert(
          0,
          GameEventModel(
            id: 'job_done_${job.id}_$nextDay',
            title: '${job.targetTitle} Tamamlandı!',
            description:
                'Gün $nextDay: ${job.targetTitle} operasyonu başarıyla tamamlanarak teslim edildi.',
            amount: 0.0,
            type: GameEventType.goodEvent,
            date: DateTime.now(),
          ),
        );
        // Handle specific type side effects on car if entity exists
        if (job.targetEntityId.isNotEmpty) {
          final carIndex =
              updatedCars.indexWhere((c) => c.id == job.targetEntityId);
          if (carIndex != -1) {
            var car = updatedCars[carIndex];
            if (job.type == ServiceJobType.workshopEngineOverhaul) {
              car = car.copyWith(
                expertise: car.expertise.copyWith(engineCondition: 100.0),
              );
            } else if (job.type == ServiceJobType.carWashCeramicCure ||
                job.type == ServiceJobType.carWashPpfArmor) {
              car = car.copyWith(
                isDetailedCleaned: true,
                isWashed: true,
                isPolished: true,
              );
            }
            updatedCars[carIndex] = car;
          }
        }
      } else {
        remainingJobs.add(job.copyWith(remainingDays: updatedRemaining));
      }
    }

    return (remainingJobs, updatedCars, events);
  }
}
