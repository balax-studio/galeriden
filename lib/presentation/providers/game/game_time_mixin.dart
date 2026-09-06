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
import '../../../data/models/contract_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/trade_in_offer_model.dart';
import '../../../data/models/customer_crm_event_model.dart';
import '../../../data/models/active_service_job_model.dart';
import '../../../data/models/real_estate_category.dart';
import '../../../data/models/real_estate_model.dart';
import '../../../data/models/real_estate_offer_model.dart';
import '../../../data/models/tenant_model.dart';
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
import '../../../domain/usecases/side_business_engine.dart';
import '../../../domain/usecases/construction_timeline_engine.dart';
import '../../../domain/usecases/construction_negative_events_engine.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/gossip_item_model.dart';
import '../../../domain/services/daily_loan_processor.dart';
import '../../../domain/services/daily_rental_processor.dart';
import '../../../domain/services/daily_staff_processor.dart';

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
    final updatedOwnedRealEstates = realEstateResult.$2;
    newEvents = realEstateResult.$3;

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

    // F3·2: Malzeme Fiyat Endeksi günlük hafif dalgalanma (±0.015) ve haber sıçraması
    double nextCostIndex = state.constructionCostIndex;
    final dailyCostDrift = (random.nextDouble() - 0.5) * 0.03;
    nextCostIndex = (nextCostIndex + dailyCostDrift).clamp(0.85, 1.35);

    if (currentNews != null) {
      final newsStr = '${currentNews.title} ${currentNews.description}'.toLowerCase();
      if (newsStr.contains('demir') ||
          newsStr.contains('çimento') ||
          newsStr.contains('cimento') ||
          newsStr.contains('inşaat') ||
          newsStr.contains('insaat') ||
          newsStr.contains('harç') ||
          newsStr.contains('döviz') ||
          newsStr.contains('enflasyon')) {
        nextCostIndex = (nextCostIndex + 0.05).clamp(0.85, 1.35);
      }
    }

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
        .where((o) => currentCars.any((c) => c.id == o.carId) && !o.isExpiredForDay(nextDay))
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
      constructionCostIndex: nextCostIndex,
      ownedCars: currentCars,
      ownedRealEstates: updatedOwnedRealEstates,
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
      recentEvents: newEvents.length > 50 ? newEvents.sublist(0, 50) : newEvents,
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
    return balance - state.dailyPropertyRentBurn;
  }

  (double, List<StaffModel>, List<GameEventModel>) _processSalaries(
      double balance, List<StaffModel> staff, List<GameEventModel> events) {
    return DailyStaffProcessor.processSalaries(
      balance: balance,
      staff: staff,
      events: events,
      specializationPath: state.specializationPath,
    );
  }

  List<CarModel> _processStaffAutomation(
      List<StaffModel> staff, List<CarModel> cars) {
    final hasCarWashBusiness = state.sideBusinesses
        .any((b) => b.isOperational && b.type == SideBusinessType.carWash);
    return DailyStaffProcessor.processStaffAutomation(
      staff: staff,
      cars: cars,
      hasCarWashBusiness: hasCarWashBusiness,
    );
  }

  (double, List<LoanModel>) _processLoans(
      int nextDay, double balance, List<LoanModel> loans) {
    return DailyLoanProcessor.processLoans(
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
    return DailyRentalProcessor.processRentals(
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
    return DailyLoanProcessor.processInstallments(
      balance: balance,
      installments: installments,
      random: random,
    );
  }

  (double, List<Cheque>) _processCheques(double balance, List<Cheque> cheques) {
    return DailyLoanProcessor.processCheques(
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

  (double, List<RealEstateModel>, List<GameEventModel>) _processRealEstateRentals(
      double balance,
      List<RealEstateModel> properties,
      List<GameEventModel> events) {
    if (properties.isEmpty) return (balance, properties, events);

    var currentBalance = balance;
    double totalDailyRent = 0.0;
    int rentedCount = 0;
    int atRiskCount = 0;
    final updatedEvents = List<GameEventModel>.from(events);

    final updatedProperties = <RealEstateModel>[];
    for (final prop in properties) {
      var currentProp = prop;

      // F2·6, F5: İpotekli Arsa İcra ve Haciz Kontrolü (Temerrüt Durumu)
      if (currentProp.isMortgaged && currentBalance < -50000.0) {
        final eventId = 'foreclosure_${currentProp.id}_${state.currentDay}';
        updatedEvents.insert(
          0,
          GameEventModel(
            id: eventId,
            title: 'İpotekli Arsa Haczedildi • İcra Takibi',
            description:
                'Ödenemeyen inşaat kredisi borçları sebebiyle ${currentProp.district} arsanıza banka tarafından el konuldu.',
            amount: 0.0,
            type: GameEventType.badEvent,
            date: DateTime.now(),
          ),
        );
        continue;
      }
      if (currentProp.isRented) {
        final tenant = currentProp.currentTenant;
        if (tenant != null) {
          // C4: Blend reliabilityScore and evictionRiskScore, plus progressive risk for consecutive unpaid days
          final baseDelinquencyRisk = ((100 - tenant.reliabilityScore) * 0.5 + tenant.evictionRiskScore * 0.5).clamp(5.0, 85.0);
          final totalDelinquencyChance = (baseDelinquencyRisk + (tenant.unpaidRentDays * 2.0)).clamp(5.0, 95.0);
          final isDelinquent = random.nextInt(100) < totalDelinquencyChance;

          if (isDelinquent) {
            final nextUnpaid = tenant.unpaidRentDays + 1;

            // C4: Automatic eviction threshold at 30 days of consecutive unpaid rent
            if (nextUnpaid >= 30) {
              totalDailyRent += tenant.depositAmount;
              atRiskCount += 2;
              currentProp = currentProp.copyWith(
                isRented: false,
                currentTenant: null,
                clearCurrentTenant: true,
                pendingRentIncome: currentProp.pendingRentIncome + tenant.depositAmount,
                provenanceLog: [
                  ...currentProp.provenanceLog,
                  '${state.currentDay}. Gün • 30 gün kira ödenmedi • Kiracı tahliye edildi, depozito gelir kaydedildi',
                ],
              );
              updatedEvents.insert(
                0,
                GameEventModel(
                  id: 'tenant_evicted_${currentProp.id}_${DateTime.now().millisecondsSinceEpoch}',
                  title: 'Kiracı Tahliye Edildi • Kira Borcu',
                  description:
                      '${currentProp.title} mülkündeki kiracı ${tenant.name} 30 gün boyunca kira ödemediği için tahliye edildi. ₺${tenant.depositAmount.round()} depozitosu kasanıza aktarıldı.',
                  amount: tenant.depositAmount,
                  type: GameEventType.badEvent,
                  date: DateTime.now(),
                ),
              );
            } else {
              currentProp = currentProp.copyWith(
                currentTenant: tenant.copyWith(unpaidRentDays: nextUnpaid),
              );

              // Warning and legal notice at 15 days
              if (nextUnpaid == 15) {
                updatedEvents.insert(
                  0,
                  GameEventModel(
                    id: 'rent_warning_15_${currentProp.id}_${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Kira İhtarnamesi Gönderildi',
                    description:
                        '${currentProp.title} mülkünüzdeki kiracı ${tenant.name} 15 gündür kira ödemiyor. Hukuki tahliye süreci başlatıldı.',
                    amount: 0.0,
                    type: GameEventType.badEvent,
                    date: DateTime.now(),
                  ),
                );
              } else if (nextUnpaid % 7 == 0) {
                updatedEvents.insert(
                  0,
                  GameEventModel(
                    id: 'rent_delayed_${currentProp.id}_${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Kira Ödemesi Gecikti',
                    description:
                        '${currentProp.title} mülkünüzdeki kiracı ${tenant.name} ödemeyi $nextUnpaid gündür geciktirdi.',
                    amount: 0.0,
                    type: GameEventType.badEvent,
                    date: DateTime.now(),
                  ),
                );
              }
            }
          } else {
            final dailyRent = currentProp.dailyRentIncome;
            totalDailyRent += dailyRent;
            rentedCount++;
            final nextDays = currentProp.uncollectedRentDays + 1;
            if (nextDays >= 5) {
              atRiskCount++;
            }
            final resolvedUnpaid = max(0, tenant.unpaidRentDays - 1);
            var updatedTenant = tenant.copyWith(unpaidRentDays: resolvedUnpaid);

            // C4: Lease duration check (desiredLeaseYears)
            final leaseDurationDays = (tenant.desiredLeaseYears * 365);
            if (state.currentDay - tenant.leaseStartDay >= leaseDurationDays) {
              // Lease term completed: 70% renews with 10% rent bump, 30% vacates peacefully
              final bool renews = random.nextInt(100) < 70;
              if (renews) {
                final renewedRent = (tenant.monthlyRent * 1.10).roundToDouble();
                updatedTenant = updatedTenant.copyWith(
                  monthlyRent: renewedRent,
                  leaseStartDay: state.currentDay,
                );
                updatedEvents.insert(
                  0,
                  GameEventModel(
                    id: 'lease_renewed_${currentProp.id}_${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Kira Sözleşmesi Yenilendi',
                    description:
                        '${currentProp.title} mülkündeki kiracı ${tenant.name} sözleşmesini %10 artışla yeniledi.',
                    amount: 0.0,
                    type: GameEventType.income,
                    date: DateTime.now(),
                  ),
                );
                currentProp = currentProp.copyWith(
                  currentTenant: updatedTenant,
                  pendingRentIncome: currentProp.pendingRentIncome + dailyRent,
                  uncollectedRentDays: nextDays,
                );
              } else {
                currentProp = currentProp.copyWith(
                  isRented: false,
                  currentTenant: null,
                  clearCurrentTenant: true,
                  pendingRentIncome: currentProp.pendingRentIncome + dailyRent,
                  uncollectedRentDays: nextDays,
                  provenanceLog: [
                    ...currentProp.provenanceLog,
                    '${state.currentDay}. Gün • Sözleşme süresi doldu • Kiracı memnun şekilde ayrıldı',
                  ],
                );
                updatedEvents.insert(
                  0,
                  GameEventModel(
                    id: 'lease_ended_${currentProp.id}_${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Sözleşme Süresi Doldu',
                    description:
                        '${currentProp.title} mülkündeki kiracı ${tenant.name} sözleşme süresini tamamlayarak daireyi boşalttı.',
                    amount: 0.0,
                    type: GameEventType.neutral,
                    date: DateTime.now(),
                  ),
                );
              }
            } else {
              currentProp = currentProp.copyWith(
                currentTenant: updatedTenant,
                pendingRentIncome: currentProp.pendingRentIncome + dailyRent,
                uncollectedRentDays: nextDays,
              );
            }
          }
        } else {
          // Fallback if property is marked rented without explicit tenant object
          final dailyRent = currentProp.dailyRentIncome;
          totalDailyRent += dailyRent;
          rentedCount++;
          final nextDays = currentProp.uncollectedRentDays + 1;
          if (nextDays >= 5) {
            atRiskCount++;
          }
          currentProp = currentProp.copyWith(
            pendingRentIncome: currentProp.pendingRentIncome + dailyRent,
            uncollectedRentDays: nextDays,
          );
        }
      }

      if (currentProp.renovationDaysRemaining > 0) {
        final remaining = currentProp.renovationDaysRemaining - 1;
        currentProp = currentProp.copyWith(
          renovationDaysRemaining: remaining,
        );
        if (remaining == 0) {
          final stageName = currentProp.renovationStage == 1
              ? 'Yıkım ve Sıhhi Tesisat'
              : (currentProp.renovationStage == 2
                  ? 'Mutfak ve Banyo'
                  : 'Boya ve Anahtar Teslim');
          updatedEvents.insert(
            0,
            GameEventModel(
              id: 'renovation_ready_${currentProp.id}_${DateTime.now().millisecondsSinceEpoch}',
              title: 'Tadilat Aşaması Tamamlandı',
              description:
                  '${currentProp.title} için $stageName etabı başarıyla tamamlandı • Mülk kullanıma ve sonraki aşamaya hazır.',
              amount: 0.0,
              type: GameEventType.goodEvent,
              date: DateTime.now(),
            ),
          );
        }
      }

      if (currentProp.isConstructionActive) {
        if (currentProp.constructionMode == 'contractor') {
          // C1: If already complete (stage >= 8), skip! Do not decrement, do not spam notifications
          if (currentProp.constructionStage >= 8) {
            // Already complete, waiting for player to finalize turnkey
          } else {
            // F2: Weather check for contractor: rainy/snowy during concrete or excavation
            final isWeatherFrozen = (state.currentWeather == WeatherType.rainy || state.currentWeather == WeatherType.snowy) &&
                (currentProp.constructionStage == 2 || currentProp.constructionStage == 3);
            if (isWeatherFrozen) {
              final updatedLogs = List<String>.from(currentProp.provenanceLog);
              if (updatedLogs.isEmpty || !updatedLogs.last.contains('Hava Muhalefeti')) {
                final nowStr = DateTime.now().toIso8601String().split('T').first;
                updatedLogs.add('$nowStr • Şantiye Telsizi: Hava Muhalefeti • Yağış nedeniyle beton dökümü bekletiliyor');
                currentProp = currentProp.copyWith(provenanceLog: updatedLogs);
              }
            } else {
              final daysLeft = currentProp.constructionDaysRemaining - 1;
              final updatedLogs = List<String>.from(currentProp.provenanceLog);
              int adjustedDays = daysLeft;

              // F3·1: Bürokrasi ve Ruhsat Engeli (Etap 1)
              if (currentProp.constructionStage == 1 &&
                  !updatedLogs.any((l) => l.contains('Bürokrasi') || l.contains('Hukuk Müşaviri'))) {
                final hasLegalAdvisor = state.hiredStaff.any((s) => s.role == StaffRole.legalAdvisor);
                final nowStr = DateTime.now().toIso8601String().split('T').first;
                if (hasLegalAdvisor) {
                  updatedLogs.add('$nowStr • Ruhsat Onayı: Hukuk Müşaviri sayesinde bürokrasi pürüzsüz aşıldı');
                } else if (random.nextDouble() < 0.25) {
                  adjustedDays += 4;
                  updatedLogs.add('$nowStr • İmar Bürokrasi Engeli: Komisyon itirazı ve evrak revizyonu • +4 gün gecikme');
                  final bEventId = 'bureaucracy_delay_${currentProp.id}';
                  if (!events.any((e) => e.id == bEventId) && !updatedEvents.any((e) => e.id == bEventId)) {
                    updatedEvents.insert(
                      0,
                      GameEventModel(
                        id: bEventId,
                        title: 'İmar Bürokrasi Engeli • Şantiye Gecikti',
                        description: '${currentProp.district} arsasındaki ruhsat sürecinde komisyon itirazı çıktı • 4 gün ek süre gerekti.',
                        amount: 0.0,
                        type: GameEventType.badEvent,
                        date: DateTime.now(),
                      ),
                    );
                  }
                }
              }

              if (adjustedDays <= 0) {
                final nextStage = currentProp.constructionStage + 1;
                final stageDays = currentProp.contractorStageDays > 0 ? currentProp.contractorStageDays : 15;
                currentProp = currentProp.copyWith(
                  constructionStage: nextStage,
                  constructionDaysRemaining: nextStage < 8 ? stageDays : 0,
                  provenanceLog: updatedLogs,
                );
                if (nextStage >= 8) {
                  final eventId = 'construction_ready_${currentProp.id}_stage8';
                  if (!events.any((e) => e.id == eventId) && !updatedEvents.any((e) => e.id == eventId)) {
                    updatedEvents.insert(
                      0,
                      GameEventModel(
                        id: eventId,
                        title: 'Şantiye Tamamlandı • Anahtar Teslim Hazır',
                        description:
                            '${currentProp.district} arsanızdaki kat karşılığı inşaat tamamlandı ve iskan ruhsatı alındı • Daireleri portföyünüze aktarabilirsiniz.',
                        amount: 0.0,
                        type: GameEventType.goodEvent,
                        date: DateTime.now(),
                      ),
                    );
                  }
                } else if (nextStage == 3 || nextStage == 5) {
                  // A9: Decision/Risk points in contractor mode
                  // If contractor has no bank guarantee, 8% chance contractor abandons site
                  if (!currentProp.hasBankGuarantee && random.nextDouble() < 0.08) {
                    final abandonEventId = 'contractor_abandon_${currentProp.id}_$nextStage';
                    if (!events.any((e) => e.id == abandonEventId) && !updatedEvents.any((e) => e.id == abandonEventId)) {
                      updatedEvents.insert(
                        0,
                        GameEventModel(
                          id: abandonEventId,
                          title: 'Müteahhit Şantiyeyi Terk Etti',
                          description:
                              '${currentProp.district} arsasındaki müteahhit mali krize girerek şantiyeyi bıraktı • Teminat mektubu olmadığı için proje durdu • Yeni müteahhit bulmanız gerekiyor.',
                          amount: 0.0,
                          type: GameEventType.badEvent,
                          date: DateTime.now(),
                        ),
                      );
                    }
                    currentProp = currentProp.copyWith(
                      constructionStage: 3,
                      constructionDaysRemaining: 0,
                      clearConstructionMode: true,
                    );
                  }
                }
              } else {
                currentProp = currentProp.copyWith(
                  constructionDaysRemaining: adjustedDays,
                  provenanceLog: updatedLogs,
                );
              }
            }
          }
        } else if (currentProp.constructionMode == 'selfBuild' && currentProp.isConstructionWorking) {
          final isWeatherFrozen = (state.currentWeather == WeatherType.rainy || state.currentWeather == WeatherType.snowy) &&
              (currentProp.constructionStage == 2 || currentProp.constructionStage == 3);
          if (isWeatherFrozen) {
            final updatedLogs = List<String>.from(currentProp.provenanceLog);
            if (updatedLogs.isEmpty || !updatedLogs.last.contains('Hava Muhalefeti')) {
              final nowStr = DateTime.now().toIso8601String().split('T').first;
              updatedLogs.add('$nowStr • Şantiye Telsizi: Hava Muhalefeti • Beton dökümü ve hafriyat beklemeye alındı');
              currentProp = currentProp.copyWith(provenanceLog: updatedLogs);
            }
          } else {
            final daysLeft = currentProp.constructionDaysRemaining - 1;
            if (daysLeft <= 0) {
              // C1: Stop working so daily loop does not continuously re-trigger!
              currentProp = currentProp.copyWith(
                constructionDaysRemaining: 0,
                isConstructionWorking: false,
              );
              final eventId = 'construction_stage_ready_${currentProp.id}_${currentProp.constructionStage}';
              if (!events.any((e) => e.id == eventId) && !updatedEvents.any((e) => e.id == eventId)) {
                updatedEvents.insert(
                  0,
                  GameEventModel(
                    id: eventId,
                    title: 'Şantiye Etabı Tamamlandı • Teslim Almaya Hazır',
                    description:
                        '${currentProp.district} arsasındaki ${currentProp.constructionStage}. Etap çalışmaları başarıyla tamamlandı • Etabı denetleyip teslim alabilirsiniz.',
                    amount: 0.0,
                    type: GameEventType.goodEvent,
                    date: DateTime.now(),
                  ),
                );
              }
            } else {
              final updatedLogs = List<String>.from(currentProp.provenanceLog);
              int adjustedDays = daysLeft;

              // F3·1: Bürokrasi ve Ruhsat Engeli (Etap 1)
              if (currentProp.constructionStage == 1 &&
                  !updatedLogs.any((l) => l.contains('Bürokrasi') || l.contains('Hukuk Müşaviri'))) {
                final hasLegalAdvisor = state.hiredStaff.any((s) => s.role == StaffRole.legalAdvisor);
                final nowStr = DateTime.now().toIso8601String().split('T').first;
                if (hasLegalAdvisor) {
                  updatedLogs.add('$nowStr • Ruhsat Onayı: Hukuk Müşaviri sayesinde bürokrasi pürüzsüz aşıldı');
                } else if (random.nextDouble() < 0.25) {
                  adjustedDays += 4;
                  updatedLogs.add('$nowStr • İmar Bürokrasi Engeli: Komisyon itirazı ve evrak revizyonu • +4 gün gecikme');
                  final bEventId = 'bureaucracy_delay_${currentProp.id}';
                  if (!events.any((e) => e.id == bEventId) && !updatedEvents.any((e) => e.id == bEventId)) {
                    updatedEvents.insert(
                      0,
                      GameEventModel(
                        id: bEventId,
                        title: 'İmar Bürokrasi Engeli • Şantiye Gecikti',
                        description: '${currentProp.district} arsasındaki ruhsat sürecinde komisyon itirazı çıktı • 4 gün ek süre gerekti.',
                        amount: 0.0,
                        type: GameEventType.badEvent,
                        date: DateTime.now(),
                      ),
                    );
                  }
                }
              }

              // B6, F1·8, F2·5: Dinamik şantiye olayı (etap, usta mekanik, hava durumu)
              final hasMasterMechanic = state.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
              final isBadWeather = state.currentWeather == WeatherType.rainy || state.currentWeather == WeatherType.snowy;
              final incidentDailyChance = (0.04 * (hasMasterMechanic ? 0.6 : 1.0) * (isBadWeather ? 1.3 : 1.0)).clamp(0.01, 0.10);
              if (random.nextDouble() < incidentDailyChance) {
                final stageDetails = ConstructionTimelineEngine.getStageDetails(currentProp.constructionStage);
                final baseCost = (currentProp.baseMarketValue * stageDetails.costPercentage).roundToDouble();
                final incident = ConstructionNegativeEventsEngine.rollStageIncident(
                  stageNumber: currentProp.constructionStage,
                  baseStageCost: baseCost,
                  riskMultiplier: 1.0,
                  hasMasterMechanic: hasMasterMechanic,
                  isBadWeather: isBadWeather,
                );
                if (incident != null) {
                  adjustedDays += incident.dayDelayImpact;
                  final nowStr = DateTime.now().toIso8601String().split('T').first;
                  updatedLogs.add('$nowStr • Olay: ${incident.title} • +${incident.dayDelayImpact} gün gecikme');
                  if (currentBalance >= incident.costImpact) {
                    currentBalance -= incident.costImpact;
                    updatedLogs.add('$nowStr • Maliyet: ${CurrencyFormatter.format(incident.costImpact)} ek harcama yapıldı');
                  } else {
                    adjustedDays += incident.dayDelayImpact;
                  }
                }
              }

              if (adjustedDays % 3 == 0 && random.nextDouble() < 0.50) {
                final nowStr = DateTime.now().toIso8601String().split('T').first;
                final anecdote = ConstructionTimelineEngine.getRandomAnecdoteText(random);
                updatedLogs.add('$nowStr • Şantiye Telsizi: $anecdote');
              }
              currentProp = currentProp.copyWith(
                constructionDaysRemaining: adjustedDays,
                provenanceLog: updatedLogs,
              );
            }
          }
        }
      }

      // F3·4: Rakip Proje Tamamlanma Uyarısı (Süre Baskısı & Bölge Rayici Baskısı)
      if (currentProp.isConstructionActive &&
          !currentProp.provenanceLog.any((l) => l.contains('Rakip Müteahhit') || l.contains('Öz-Gözde'))) {
        final delayCount = currentProp.provenanceLog.where((l) => l.contains('gecikme')).length;
        if (delayCount >= 2) {
          final rivalEventId = 'rival_project_completed_${currentProp.id}';
          if (!events.any((e) => e.id == rivalEventId) && !updatedEvents.any((e) => e.id == rivalEventId)) {
            final nowStr = DateTime.now().toIso8601String().split('T').first;
            final updatedLogs = List<String>.from(currentProp.provenanceLog);
            updatedLogs.add('$nowStr • Rakip Müteahhit: Öz-Gözde İnşaat karşı parseli tamamladı • Bölge rayici %8 baskılandı');
            currentProp = currentProp.copyWith(provenanceLog: updatedLogs);
            updatedEvents.insert(
              0,
              GameEventModel(
                id: rivalEventId,
                title: 'Rakip Proje Teslim Edildi • Bölgesel Fiyat Baskısı',
                description:
                    '${currentProp.district} bölgesindeki gecikmeler sebebiyle rakip firma projeyi sizden önce teslim etti • Bölge rayici %8 baskılandı.',
                amount: 0.0,
                type: GameEventType.badEvent,
                date: DateTime.now(),
              ),
            );
          }
        }
      }

      if (currentProp.isListed) {
        final nextDaysListed = currentProp.daysListed + 1;
        // Age existing offers and remove expired ones
        final updatedOffers = <RealEstateOfferModel>[];
        for (final offer in currentProp.activeOffers) {
          if (offer.daysRemaining > 1) {
            updatedOffers.add(offer.copyWith(daysRemaining: offer.daysRemaining - 1));
          }
        }

        // Real estate market is heavier than cars; offers arrive slower, tuned by pricing strategy & vitrin package
        final fairValue = currentProp.estimatedRealValue > 0 ? currentProp.estimatedRealValue : 1.0;
        final askedPrice = currentProp.customListingPrice ?? fairValue;
        final priceRatio = askedPrice / fairValue;

        // Interval & probability based on strategy
        int cycleInterval = 3;
        double arrivalChance = 0.35;

        if (priceRatio <= 0.93) {
          // Kelepir • Hızlı Satış
          cycleInterval = 2;
          arrivalChance = 0.52;
        } else if (priceRatio <= 1.05) {
          // Rayiç • Dengeli
          cycleInterval = 3;
          arrivalChance = 0.38;
        } else if (priceRatio <= 1.18) {
          // Primli
          cycleInterval = 3;
          arrivalChance = 0.25;
        } else {
          // Tok Satıcı
          cycleInterval = 4;
          arrivalChance = 0.16;
        }

        // Showcase promotion boosts
        if (currentProp.listingPackage == 'featured') {
          arrivalChance += 0.18;
          cycleInterval = (cycleInterval - 1).clamp(2, 4);
        } else if (currentProp.listingPackage == 'super') {
          arrivalChance += 0.32;
          cycleInterval = (cycleInterval - 1).clamp(1, 3);
        }

        if (updatedOffers.length < 4 && (nextDaysListed % cycleInterval == 0) && random.nextDouble() < arrivalChance) {
          List<String> buyers;
          List<String> notes;

          switch (currentProp.category) {
            case RealEstateCategory.land:
              buyers = [
                'Müteahhit Haldun Özkan',
                'Yatırım Uzmanı Ferhat Taş',
                'Lojistik Müdürü Sinan Kaya',
                'Arsa Yatırımcısı Nazif Bey',
                'Sanayici Kudret Erdem',
              ];
              notes = [
                'İmar ve parselasyon durumunu inceledik, kat karşılığı veya depolama projemiz için uygun.',
                'Belediye plan tadilatı ve emsal oranına göre değerleme yaptık, nakit teklifimiz budur.',
                'Lojistik antrepo yatırımı amacıyla parseli portföyümüze katmak istiyoruz.',
                'Müteahhitlik şirketimiz adına teklif iletiyoruz, devir olursa ruhsata hemen başvuracağız.',
                'Bölgedeki arsa rayiçlerini araştırdık, bütçemiz elverdiği ölçüde son rakamımızdır.',
              ];
              break;
            case RealEstateCategory.commercial:
            case RealEstateCategory.building:
              buyers = [
                'Franchise Direktörü Bora Ekşi',
                'Yatırım Fonu Temsilcisi Nihal Hanım',
                'Perakende Mağaza Müdürü Tolga Bey',
                'Eczacı Aslı Hanım',
                'İş İnsanı Can Pekkan',
              ];
              notes = [
                'Tabela değeri ve yaya trafiği kurumsal şubemiz için elverişli, pazarlık payınız varsa notere geçelim.',
                'Kira amortisman çarpanına göre teklifimizi oluşturduk, şirket adına alım yapacağız.',
                'Geniş vitrin cephesi ve baca altyapısı gıda bayiliğimiz için ideal.',
                'Yatırım amaçlı satın alıp kurumsal kiracıya vermeyi planlıyoruz.',
                'Özkaynaklarımızla satın alacağız, kredi beklemeden tek seferde devir yapabiliriz.',
              ];
              break;
            case RealEstateCategory.tourismFacility:
            case RealEstateCategory.timeshare:
              buyers = [
                'Sanayici Teoman Karaca',
                'Dr. Aylin Korkmaz',
                'Yazılımcı Erdem Demir',
                'Av. Berke Tan',
                'İş İnsanı Zeynep Arslan',
              ];
              notes = [
                'Müstakil bahçe ve mahremiyet kriterlerimize uyuyor, ailemiz için hemen taşınabileceğimiz bir mülk.',
                'Peyzaj ve mimarisini çok beğendik, tapu işlemlerini bu hafta başlatabiliriz.',
                'Şehrin gürültüsünden uzaklaşmak istiyoruz, banka teminatımız ve nakdimiz hazır.',
                'Özel havuzlu ve akıllı ev donanımlı olması tercih sebebimiz, rakamda el sıkışabiliriz.',
                'Ekspertiz değerini kontrol ettik, peşin ödeme şartıyla teklifimizi sunuyoruz.',
              ];
              break;
            case RealEstateCategory.housing:
            case RealEstateCategory.housingProjects:
              buyers = [
                'Öğretmen Berna Hanım',
                'Mühendis Cenk Aydın',
                'Yatırımcı Hakan Koç',
                'Yeni Evli Çift Gizem & Ali',
                'Av. Selin Kaya',
                'Dr. Mert Öztürk',
              ];
              notes = [
                'Konut kredimiz onaylandı, ekspertiz değerine uygun teklifimizi iletiyoruz.',
                'İlk evimiz olacak, ailemizin bütçesi doğrultusunda sunabileceğimiz son rakam budur.',
                'Kiraya vermek amacıyla yatırımlık düşünüyoruz, tapuda hemen devir alabiliriz.',
                'Merkezi konumu ve güney cephe ferahlığı hoşumuza gitti, küçük bir pazarlık payı rica ediyoruz.',
                'Nakit paramız hazır, tapu ve döner sermaye harçlarını görüşüp anlaşalım.',
              ];
              break;
          }

          final basePrice = askedPrice;
          final variance = 0.88 + (random.nextDouble() * 0.16);
          final offerAmount = ((basePrice * variance) / 10000).round() * 10000.0;

          final newOffer = RealEstateOfferModel(
            id: 're_offer_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999)}',
            realEstateId: currentProp.id,
            buyerName: buyers[random.nextInt(buyers.length)],
            buyerNote: notes[random.nextInt(notes.length)],
            offeredAmount: offerAmount,
            daysRemaining: 3,
            createdAt: DateTime.now(),
          );
          updatedOffers.add(newOffer);

          updatedEvents.insert(
            0,
            GameEventModel(
              id: 're_offer_event_${newOffer.id}',
              title: 'Gayrimenkul Teklifi • Showroom',
              description:
                  '${currentProp.title} ilanınıza ${newOffer.buyerName} tarafından ₺${offerAmount.round()} tutarında resmi teklif sunuldu. Showroom üzerinden inceleyebilirsiniz.',
              amount: 0.0,
              type: GameEventType.goodEvent,
              date: DateTime.now(),
            ),
          );
        }

        currentProp = currentProp.copyWith(
          daysListed: nextDaysListed,
          activeOffers: updatedOffers,
        );
      }

      if (currentProp.isRentalListed && !currentProp.isRented) {
        // Age existing rental offers and purge expired ones
        final updatedOffers = <RealEstateOfferModel>[];
        for (final offer in currentProp.activeOffers) {
          if (offer.isRentalOffer) {
            if (offer.daysRemaining > 1) {
              updatedOffers.add(offer.copyWith(daysRemaining: offer.daysRemaining - 1));
            }
          } else {
            updatedOffers.add(offer);
          }
        }

        final rentalOffersCount = updatedOffers.where((o) => o.isRentalOffer).length;
        if (rentalOffersCount < 3 && random.nextDouble() < 0.40) {
          final baseMonthly = (currentProp.estimatedRealValue * currentProp.category.dailyRentYieldRate * 30).roundToDouble();
          final candidates = TenantModel.generateCandidates(
            baseMonthlyRent: baseMonthly > 0 ? baseMonthly : 12000.0,
            count: 1,
            rng: random,
          );
          if (candidates.isNotEmpty) {
            final candidate = candidates.first;
            final newOffer = RealEstateOfferModel(
              id: 'rental_offer_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999)}',
              realEstateId: currentProp.id,
              buyerName: candidate.name,
              buyerNote: '${candidate.profession} • Güvenilirlik Notu: ${candidate.reliabilityGrade} • Aylık Teklif: ₺${candidate.monthlyRent.round()}',
              offeredAmount: candidate.monthlyRent,
              depositAmount: candidate.depositAmount,
              daysRemaining: 3,
              createdAt: DateTime.now(),
              isRentalOffer: true,
              tenant: candidate,
            );
            updatedOffers.add(newOffer);

            updatedEvents.insert(
              0,
              GameEventModel(
                id: 're_rental_offer_event_${newOffer.id}',
                title: 'Yeni Kira Teklifi Geldi',
                description:
                    '${currentProp.title} kiralık ilanınıza ${candidate.name} - ${candidate.profession} tarafından aylık ₺${candidate.monthlyRent.round()} kira teklifi sunuldu. Showroom üzerinden değerlendirebilirsiniz.',
                amount: 0.0,
                type: GameEventType.goodEvent,
                date: DateTime.now(),
              ),
            );
          }
        }

        currentProp = currentProp.copyWith(
          activeOffers: updatedOffers,
        );
      }

      updatedProperties.add(currentProp);
    }

    if (totalDailyRent > 0) {
      if (atRiskCount > 0) {
        updatedEvents.insert(
          0,
          GameEventModel(
            id: 'real_estate_rent_risk_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Kira Tahsilat Gecikmesi • Erime Riski',
            description:
                '$atRiskCount mülkünüzde biriken kiralar 5 gündür tahsil edilmedi. Kiracı temerrüdü ve kayıp yaşamamak için portföyünüzden hemen tahsil edin.',
            amount: 0.0,
            type: GameEventType.badEvent,
            date: DateTime.now(),
          ),
        );
      }
      updatedEvents.insert(
        0,
        GameEventModel(
          id: 'real_estate_rent_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Kira Geliri Havuzda Birikti',
          description:
              'Portföyünüzdeki $rentedCount mülkten ${CurrencyFormatter.format(totalDailyRent)} günlük kira tahsilat havuzuna eklendi • Kasaya aktarmak için portföyünüzden tahsil edin.',
          amount: totalDailyRent,
          type: GameEventType.income,
          date: DateTime.now(),
        ),
      );
      addXP(10 * rentedCount);
    }

    return (currentBalance, updatedProperties, updatedEvents);
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
        car: randomCar,
        customerName: randomCustomer,
        currentDay: state.currentDay,
      );
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
  /// Resolves the contextual random event choice outcome and mutates state
  void resolveRandomEvent(GameEventChoice choice) {
    // Insufficient funds guard: Player cannot select choices they cannot afford (A6)
    if (choice.balanceChange < 0 && state.balance < choice.balanceChange.abs()) {
      return;
    }

    final newBalance = state.balance + choice.balanceChange;
    final newReputation =
        (state.reputationScore + choice.reputationChange).clamp(0, 1000);

    List<CarModel> updatedCars = List.from(state.ownedCars);
    List<SideBusinessModel> updatedSideBusinesses =
        List.from(state.sideBusinesses);
    List<StaffModel> updatedStaff = List.from(state.hiredStaff);

    // Mechanical consequences on owned cars (C3)
    if (choice.targetCarEffect != null && updatedCars.isNotEmpty) {
      switch (choice.targetCarEffect) {
        case 'impound':
          final bmIndex = updatedCars.indexWhere((c) => c.isBlackMarket);
          final targetIndex = bmIndex != -1 ? bmIndex : 0;
          updatedCars.removeAt(targetIndex);
          break;
        case 'dirty':
          updatedCars = updatedCars
              .map((c) => c.copyWith(
                    isWashed: false,
                    isDetailedCleaned: false,
                    isPolished: false,
                  ))
              .toList();
          break;
        case 'wash_all':
          updatedCars = updatedCars
              .map((c) => c.copyWith(
                    isWashed: true,
                    isDetailedCleaned: true,
                  ))
              .toList();
          break;
        case 'damage':
          final car = updatedCars.first;
          final updatedBodyParts =
              Map<String, PartStatus>.from(car.expertise.bodyParts);
          final updatedPartConditions =
              Map<String, double>.from(car.expertise.partConditions);

          final partToDamage = updatedBodyParts.keys.firstWhere(
            (k) => updatedBodyParts[k] == PartStatus.original,
            orElse: () => updatedBodyParts.keys.isNotEmpty
                ? updatedBodyParts.keys.first
                : 'Kaput',
          );
          updatedBodyParts[partToDamage] = PartStatus.damaged;
          updatedPartConditions[partToDamage] = 20.0;

          final newExpertise = car.expertise.copyWith(
            bodyParts: updatedBodyParts,
            partConditions: updatedPartConditions,
            tramerAmount: car.expertise.tramerAmount + 15000,
          );
          updatedCars[0] = car.copyWith(expertise: newExpertise);
          break;
        case 'repaint':
          final car = updatedCars.first;
          final updatedBodyParts =
              Map<String, PartStatus>.from(car.expertise.bodyParts);
          final updatedPartConditions =
              Map<String, double>.from(car.expertise.partConditions);

          final partToPaint = updatedBodyParts.keys.firstWhere(
            (k) =>
                updatedBodyParts[k] == PartStatus.damaged ||
                updatedBodyParts[k] == PartStatus.changed,
            orElse: () => updatedBodyParts.keys.isNotEmpty
                ? updatedBodyParts.keys.first
                : 'Kaput',
          );
          updatedBodyParts[partToPaint] = PartStatus.painted;
          updatedPartConditions[partToPaint] = 85.0;

          final newExpertise = car.expertise.copyWith(
            bodyParts: updatedBodyParts,
            partConditions: updatedPartConditions,
            tramerAmount: car.expertise.tramerAmount + 4000,
          );
          updatedCars[0] = car.copyWith(expertise: newExpertise);
          break;
      }
    }

    // Mechanical consequences on side businesses (C3)
    if (choice.sideBusinessId != null && updatedSideBusinesses.isNotEmpty) {
      final sbIndex = updatedSideBusinesses.indexWhere((b) =>
          b.id == choice.sideBusinessId ||
          b.type.name == choice.sideBusinessId ||
          (choice.sideBusinessId == 'car_wash' &&
              b.type == SideBusinessType.carWash));
      if (sbIndex != -1) {
        final targetBiz = updatedSideBusinesses[sbIndex];
        if (choice.sideBusinessDowntimeDays != null) {
          if (choice.sideBusinessDowntimeDays! > 0) {
            updatedSideBusinesses[sbIndex] = targetBiz.copyWith(
              isUnderConstruction: true,
              constructionDaysRemaining: choice.sideBusinessDowntimeDays!,
              totalConstructionDays: choice.sideBusinessDowntimeDays!,
            );
          } else {
            updatedSideBusinesses[sbIndex] = targetBiz.copyWith(
              isUnderConstruction: false,
              constructionDaysRemaining: 0,
            );
          }
        }
      }
    }

    // Mechanical consequences on staff morale (C3)
    if (choice.staffMoraleChange != null &&
        choice.staffMoraleChange != 0 &&
        updatedStaff.isNotEmpty) {
      updatedStaff = updatedStaff.map((s) {
        final newMorale = (s.morale + choice.staffMoraleChange!).clamp(0, 100);
        return s.copyWith(morale: newMorale);
      }).toList();
    }

    state = state.copyWith(
      balance: newBalance,
      reputationScore: newReputation,
      ownedCars: updatedCars,
      sideBusinesses: updatedSideBusinesses,
      hiredStaff: updatedStaff,
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
              expiresOnDay: state.currentDay + 2,
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
                  expiresOnDay: state.currentDay + 2 + i,
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
