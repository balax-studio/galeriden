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
import '../../../data/models/story_card_model.dart';
import '../../../data/models/dramatic_card_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/contract_model.dart';
import '../../../data/models/mission_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../domain/usecases/mission_factory.dart';
import '../../../domain/usecases/dramatic_card_engine.dart';
import '../../../domain/usecases/random_event_engine.dart';

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

    // 1. Deduct daily property fixed overhead / burn-rate
    double propertyDailyBurn = 500.0;
    if (state.unlockedBuildings.contains('property_tier_4')) {
      propertyDailyBurn = 45000.0;
    } else if (state.unlockedBuildings.contains('property_tier_3')) {
      propertyDailyBurn = 12000.0;
    } else if (state.unlockedBuildings.contains('property_tier_2')) {
      propertyDailyBurn = 3000.0;
    }
    newBalance -= propertyDailyBurn;

    // 2. Deduct daily salaries for hired staff
    double totalSalaries = 0.0;
    for (var staff in state.hiredStaff) {
      totalSalaries += staff.dailySalary;
    }
    // Boss Specialization Perk: -20% staff salary
    if (state.specializationPath == SpecializationPath.boss) {
      totalSalaries *= 0.80;
    }
    
    // Eğer maaşı ödeyecek para yoksa personel işi bırakır
    List<StaffModel> currentStaff = List.from(state.hiredStaff);
    if (newBalance >= totalSalaries) {
      newBalance -= totalSalaries;
    } else if (newBalance > 0) {
      newBalance = 0; // Kalan para ancak bir kısmını ödedi
      currentStaff.clear(); // Tüm personel ayrıldı
    } else {
      currentStaff.clear();
    }

    // --- AKTİF PERSONEL OTOMASYONU ---
    List<CarModel> currentCars = List.from(state.ownedCars);
    final hasWasher = currentStaff.any((s) => s.role == StaffRole.washer);
    final hasMechanic = currentStaff.any((s) => s.role == StaffRole.masterMechanic);
    final hasSalesman = currentStaff.any((s) => s.role == StaffRole.salesman);

    // 1. Oto Yıkama & Detay Uzmanı: Garajdaki araçları otomatik yıkar ve cilalar
    if (hasWasher && currentCars.isNotEmpty) {
      int washedCount = 0;
      for (int i = 0; i < currentCars.length; i++) {
        final car = currentCars[i];
        if (!car.isWashed || !car.isPolished || !car.isDetailedCleaned) {
          currentCars[i] = car.copyWith(
            isWashed: true,
            isPolished: true,
            isDetailedCleaned: true,
          );
          washedCount++;
          if (washedCount >= 2) break; // Günde 2 araca kadar detaylı bakım
        }
      }
    }

    // 2. Mekanik Usta: Hasarlı motor ve şanzımanı günde +%20 ücretsiz onarır
    if (hasMechanic && currentCars.isNotEmpty) {
      for (int i = 0; i < currentCars.length; i++) {
        final car = currentCars[i];
        if (car.expertise.engineCondition < 100 || car.expertise.transmissionCondition < 100) {
          final newEngine = min(100.0, car.expertise.engineCondition + 20.0);
          final newTrans = min(100.0, car.expertise.transmissionCondition + 20.0);
          currentCars[i] = car.copyWith(
            expertise: car.expertise.copyWith(
              engineCondition: newEngine,
              transmissionCondition: newTrans,
            ),
          );
          break; // Günde 1 motor/şanzıman rektifiye revizyonu
        }
      }
    }

    // 3. Satış Danışmanı: Her gün yeni alıcı müşteri çeker
    if (hasSalesman && currentCars.any((c) => c.isListed && !c.isRented)) {
      triggerOrganicOffers();
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

    // 6. Cheques mechanics with FinanceSense perk
    List<Cheque> updatedCheques = List.from(state.activeCheques);
    final double chequeBounceRisk = (0.05 - state.skills.chequeRiskReduction).clamp(0.005, 0.05);
    for (int i = updatedCheques.length - 1; i >= 0; i--) {
      final cheque = updatedCheques[i];
      int remainingDays = cheque.daysUntilDue - 1;
      
      if (remainingDays <= 0) {
        if (random.nextDouble() < chequeBounceRisk) {
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
    // Eğer oyuncu kredi taksiti sonrası eksiye düştüyse ve satılabilir varlıkları borcu karşılamıyorsa kurtar.
    double liquidatableValue = currentCars.fold(0.0, (s, c) => s + c.estimatedRealValue * 0.70) +
        state.bankDepositBalance;
    if (newBalance < 0 && (liquidatableValue + newBalance) < 25000.0) {
      newBalance = 25000.0; // Devlet hibesi / başlangıç sermayesi
      updatedLoans.clear(); // Borçlar silinir
    }

    // 8. Side Businesses (Pasif Gelir)
    List<SideBusinessModel> updatedBusinesses = List.from(state.sideBusinesses);
    final double businessMultiplier = state.specializationPath == SpecializationPath.boss ? 1.30 : 1.0;
    for (int i = 0; i < updatedBusinesses.length; i++) {
      final b = updatedBusinesses[i];
      if (b.isOwned) {
        final income = b.effectiveDailyIncome * businessMultiplier;
        newBalance += income;
        updatedBusinesses[i] = b.copyWith(totalEarned: b.totalEarned + income);
      }
    }

    // 9. Stock Market Fluctuations
    List<StockModel> updatedStocks = List.from(state.marketStocks);
    List<GameEventModel> newEvents = List.from(state.recentEvents);
    
    for (int i = 0; i < updatedStocks.length; i++) {
      final stock = updatedStocks[i];
      // Max +-10% daily price volatility
      double changePercent = (random.nextDouble() * 0.20) - 0.10; // -10.0% to +10.0%
      
      double newPrice = (stock.currentPrice * (1.0 + changePercent)).roundToDouble();
      if (newPrice < 1.0) newPrice = 1.0; 

      List<double> history = List.from(stock.priceHistory);
      history.add(newPrice);
      if (history.length > 30) {
        history = history.sublist(history.length - 30);
      }
      
      updatedStocks[i] = stock.copyWith(
        previousPrice: stock.currentPrice,
        currentPrice: newPrice,
        priceHistory: history,
      );
    }

    // 10. Daily Tax
    newBalance -= state.dailyTaxRate;

    // Daily closing summary event (§5.5)
    final double netDayChange = newBalance - state.balance;
    final summaryEvent = GameEventModel(
      id: 'day_summary_$nextDay',
      title: 'Gün $nextDay Kapanış Özeti',
      description: 'Giderler, personel maaşları ve pasif gelirler hesaplandı. Net günlük değişim: ${netDayChange >= 0 ? "+₺${netDayChange.round()}" : "-₺${netDayChange.abs().round()}"}.',
      type: netDayChange >= 0 ? GameEventType.income : GameEventType.expense,
      amount: netDayChange,
      date: DateTime.now(),
    );
    newEvents.insert(0, summaryEvent);

    // Keep only last 50 events
    if (newEvents.length > 50) {
      newEvents = newEvents.sublist(0, 50);
    }

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

    // 13. Check Story Ad Trigger (every 7-21 days)
    int updatedDaysSinceStoryAd = state.daysSinceLastStoryAd + 1;
    int nextTargetDays = state.nextStoryAdTargetDays;
    StoryCardModel? nextStoryCard = state.pendingStoryCard;

    if (updatedDaysSinceStoryAd >= nextTargetDays && nextStoryCard == null) {
      nextStoryCard = selectNextStoryCard();
      updatedDaysSinceStoryAd = 0;
      nextTargetDays = 7 + random.nextInt(15); // Random range: 7..21
    }

    // 13.5. Check Dramatic Decision Dilemma Cards Trigger (every 15-30 days)
    int updatedDaysSinceDramatic = state.daysSinceLastDramaticCard + 1;
    int nextDramaticTargetDays = state.nextDramaticCardTargetDays;
    DramaticCardModel? nextDramaticCard = state.pendingDramaticCard;

    if (updatedDaysSinceDramatic >= nextDramaticTargetDays && nextDramaticCard == null) {
      nextDramaticCard = DramaticCardEngine.selectNextCard(state, randomInstance: random);
      updatedDaysSinceDramatic = 0;
      nextDramaticTargetDays = 15 + random.nextInt(16); // Random range: 15..30 days
    }

    // 13.6. Check Contextual Random Events (every 5-10 days)
    int updatedDaysSinceRandomEvent = state.daysSinceLastRandomEvent + 1;
    int nextRandomEventTargetDays = state.nextRandomEventTargetDays;
    GameEventModel? nextRandomEvent = state.pendingRandomEvent;
    List<String> seenRandomEventIds = List.from(state.seenRandomEventIds);

    if (updatedDaysSinceRandomEvent >= nextRandomEventTargetDays && nextRandomEvent == null) {
      nextRandomEvent = RandomEventEngine.getFilteredRandomEvent(state);
      if (nextRandomEvent != null) {
        seenRandomEventIds.add(nextRandomEvent.id);
        if (seenRandomEventIds.length > 6) {
          seenRandomEventIds.removeAt(0);
        }
        updatedDaysSinceRandomEvent = 0;
        nextRandomEventTargetDays = 5 + random.nextInt(6); // 5..10 days
      }
    }

    // 13.7. Advance daysListed for all currently listed vehicles
    currentCars = currentCars.map((c) => c.isListed ? c.copyWith(daysListed: c.daysListed + 1) : c).toList();

    // 14. Bank Deposit Daily Interest Accrual (~43% APY => ~0.12% daily)
    double updatedBankDeposit = state.bankDepositBalance;
    if (updatedBankDeposit > 0) {
      final double dailyInterest = (updatedBankDeposit * 0.0012).roundToDouble();
      updatedBankDeposit += (dailyInterest > 0 ? dailyInterest : 1.0);
    }

    // 15. Daily Missions Rotation (rotate only when all active missions are claimed or empty)
    List<MissionModel> updatedMissions = List.from(state.activeMissions);
    if (updatedMissions.isEmpty || updatedMissions.every((m) => m.isClaimed)) {
      updatedMissions = MissionFactory.generateDailyMissions(state.level);
    }

    // 16. VIP Wanted Vehicle Contracts Progression
    List<WantedCarContract> updatedContracts = [];
    for (final c in state.activeContracts) {
      if (c.isFulfilled) continue;
      final remaining = c.deadlineDays - 1;
      if (remaining > 0) {
        updatedContracts.add(c.copyWith(deadlineDays: remaining));
      }
    }
    if (updatedContracts.length < 2 && random.nextDouble() < 0.40) {
      updatedContracts.add(MissionFactory.generateWantedCarContract(level: state.level));
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
      daysSinceLastStoryAd: updatedDaysSinceStoryAd,
      nextStoryAdTargetDays: nextTargetDays,
      pendingStoryCard: nextStoryCard,
      daysSinceLastDramaticCard: updatedDaysSinceDramatic,
      nextDramaticCardTargetDays: nextDramaticTargetDays,
      pendingDramaticCard: nextDramaticCard,
      daysSinceLastRandomEvent: updatedDaysSinceRandomEvent,
      nextRandomEventTargetDays: nextRandomEventTargetDays,
      pendingRandomEvent: nextRandomEvent,
      seenRandomEventIds: seenRandomEventIds,
      bankDepositBalance: updatedBankDeposit,
      activeMissions: updatedMissions,
      activeContracts: updatedContracts,
    );

    refreshMarketTrends();
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
