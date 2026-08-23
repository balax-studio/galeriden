import 'dart:math' as math;
import '../../data/models/car_model.dart';
import '../../data/models/casino_game_model.dart';
import '../../data/models/expertise_model.dart';

class CasinoEngine {
  static final math.Random _random = math.Random();

  static CarModel createRewardCar({
    required String brand,
    required String modelName,
    required int year,
    required double price,
    String colorHex = '0xFFFFDE59',
  }) {
    final expertise = ExpertiseReport(
      engineCondition: 98.0,
      transmissionCondition: 98.0,
      tramerAmount: 0,
      mileage: 3500,
      isMileageTampered: false,
      bodyParts: {
        'Kaput': PartStatus.original,
        'Tavan': PartStatus.original,
        'Sol Ön Çamurluk': PartStatus.original,
        'Sağ Ön Çamurluk': PartStatus.original,
        'Sol Ön Kapı': PartStatus.original,
        'Sağ Ön Kapı': PartStatus.original,
        'Sol Arka Kapı': PartStatus.original,
        'Sağ Arka Kapı': PartStatus.original,
        'Sol Arka Çamurluk': PartStatus.original,
        'Sağ Arka Çamurluk': PartStatus.original,
        'Bagaj': PartStatus.original,
      },
      isEcuCleaned: true,
      isChassisAligned: true,
    );

    return CarModel(
      id: 'casino_reward_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}',
      brand: brand,
      modelName: modelName,
      modelYear: year,
      bodyType: 'Spor',
      colorHex: colorHex,
      baseMarketValue: price,
      currentPurchasePrice: price * 0.7,
      isRare: true,
      isHeroShowcase: true,
      expertise: expertise,
      plateNumber: '34 VIP 777',
      plateRarity: 'legendary',
      colorRarity: 'legendary',
      colorDisplayName: 'Casino Altın Sarısı',
    );
  }

  // Suits and ranks for standard decks
  static const List<String> _suits = ['spades', 'hearts', 'diamonds', 'clubs'];

  static CasinoCard drawRandomCard({math.Random? rng}) {
    final rand = rng ?? _random;
    final suit = _suits[rand.nextInt(_suits.length)];
    final rank = rand.nextInt(13) + 1; // 1 to 13
    return CasinoCard.fromRankAndSuit(rank, suit);
  }

  // ==========================================
  // 1. VALET BACCARAT
  // ==========================================
  static BaccaratResult playBaccarat({
    required double betAmount,
    required BaccaratBetChoice choice,
    CarModel? wageredCar,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;

    // Deal 2 cards to Player and 2 cards to Banker
    final p1 = drawRandomCard(rng: rand);
    final p2 = drawRandomCard(rng: rand);
    final b1 = drawRandomCard(rng: rand);
    final b2 = drawRandomCard(rng: rand);

    final playerCards = [p1, p2];
    final bankerCards = [b1, b2];

    int pTotal = (p1.baccaratValue + p2.baccaratValue) % 10;
    int bTotal = (b1.baccaratValue + b2.baccaratValue) % 10;

    // Natural 8 or 9 ends round immediately
    final isNatural = pTotal >= 8 || bTotal >= 8;

    if (!isNatural) {
      // Player draws 3rd card if total is 0 to 5
      if (pTotal <= 5) {
        final p3 = drawRandomCard(rng: rand);
        playerCards.add(p3);
        pTotal = (pTotal + p3.baccaratValue) % 10;
      }

      // Banker draws 3rd card if total is 0 to 5
      if (bTotal <= 5) {
        final b3 = drawRandomCard(rng: rand);
        bankerCards.add(b3);
        bTotal = (bTotal + b3.baccaratValue) % 10;
      }
    }

    BaccaratBetChoice winningChoice;
    if (pTotal > bTotal) {
      winningChoice = BaccaratBetChoice.player;
    } else if (bTotal > pTotal) {
      winningChoice = BaccaratBetChoice.banker;
    } else {
      winningChoice = BaccaratBetChoice.tie;
    }

    final isWin = choice == winningChoice;
    double multiplier = 0.0;
    if (isWin) {
      switch (choice) {
        case BaccaratBetChoice.player:
          multiplier = 2.0; // 1:1 payout
          break;
        case BaccaratBetChoice.banker:
          multiplier = 1.95; // 0.95:1 payout (house commission)
          break;
        case BaccaratBetChoice.tie:
          multiplier = 8.0; // 8:1 payout
          break;
      }
    }

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final payout = isWin ? (effectiveBet * multiplier) : 0.0;

    CarModel? awardedCar;
    if (isWin && wageredCar != null && choice == BaccaratBetChoice.tie) {
      // High-roller tie with Pink slip rewards an upgraded prize vehicle
      awardedCar = createRewardCar(
        brand: 'Porsche',
        modelName: '911 GT3 RS Clubsport',
        year: 2024,
        price: effectiveBet * 1.5,
      );
    }

    return BaccaratResult(
      playerCards: playerCards,
      bankerCards: bankerCards,
      playerTotal: pTotal,
      bankerTotal: bTotal,
      winningChoice: winningChoice,
      isWin: isWin,
      payoutAmount: payout,
      wonCar: awardedCar,
    );
  }

  // ==========================================
  // 2. STREET CRAPS (SOKAK ZARI)
  // ==========================================
  static StreetCrapsRollResult rollStreetCraps({
    required CrapsPhase currentPhase,
    int? currentPoint,
    required double betAmount,
    CarModel? wageredCar,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;
    final die1 = rand.nextInt(6) + 1;
    final die2 = rand.nextInt(6) + 1;
    final sum = die1 + die2;

    if (currentPhase == CrapsPhase.comeOut) {
      // Come-Out Roll rules:
      // 7 or 11 = Natural Win (2x)
      // 2, 3, or 12 = Craps Loss (0x)
      // 4, 5, 6, 8, 9, 10 = Point Established
      if (sum == 7 || sum == 11) {
        return StreetCrapsRollResult(
          die1: die1,
          die2: die2,
          sum: sum,
          nextPhase: CrapsPhase.comeOut,
          isWin: true,
          isLoss: false,
          payoutMultiplier: 2.0,
          statusSummaryKey: 'craps_status_natural_win',
        );
      } else if (sum == 2 || sum == 3 || sum == 12) {
        return StreetCrapsRollResult(
          die1: die1,
          die2: die2,
          sum: sum,
          nextPhase: CrapsPhase.comeOut,
          isWin: false,
          isLoss: true,
          payoutMultiplier: 0.0,
          statusSummaryKey: 'craps_status_craps_loss',
        );
      } else {
        return StreetCrapsRollResult(
          die1: die1,
          die2: die2,
          sum: sum,
          nextPhase: CrapsPhase.pointPhase,
          point: sum,
          isWin: false,
          isLoss: false,
          payoutMultiplier: 1.0,
          statusSummaryKey: 'craps_status_point_set',
        );
      }
    } else {
      // Point Phase rules:
      // Roll Point again = WIN (2x)
      // Roll 7 = Seven-Out Loss (0x)
      // Any other = Keep rolling
      if (sum == currentPoint) {
        return StreetCrapsRollResult(
          die1: die1,
          die2: die2,
          sum: sum,
          nextPhase: CrapsPhase.comeOut,
          point: null,
          isWin: true,
          isLoss: false,
          payoutMultiplier: 2.0,
          statusSummaryKey: 'craps_status_point_hit_win',
        );
      } else if (sum == 7) {
        return StreetCrapsRollResult(
          die1: die1,
          die2: die2,
          sum: sum,
          nextPhase: CrapsPhase.comeOut,
          point: null,
          isWin: false,
          isLoss: true,
          payoutMultiplier: 0.0,
          statusSummaryKey: 'craps_status_seven_out_loss',
        );
      } else {
        return StreetCrapsRollResult(
          die1: die1,
          die2: die2,
          sum: sum,
          nextPhase: CrapsPhase.pointPhase,
          point: currentPoint,
          isWin: false,
          isLoss: false,
          payoutMultiplier: 1.0,
          statusSummaryKey: 'craps_status_roll_again',
        );
      }
    }
  }

  // ==========================================
  // 3. HI-LO VİTES
  // ==========================================
  static const List<double> hiLoMultipliers = [
    1.0, // streak 0
    1.5, // streak 1
    2.25, // streak 2
    3.5, // streak 3
    5.5, // streak 4
    9.0, // streak 5
    15.0, // streak 6
    30.0, // streak 7+
  ];

  static HiLoStepResult guessHiLo({
    required CasinoCard currentCard,
    required bool guessHigher,
    required int currentStreak,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;
    CasinoCard nextCard;
    do {
      nextCard = drawRandomCard(rng: rand);
    } while (nextCard.rank == currentCard.rank && rand.nextDouble() < 0.8); // slight redraw on exact ties

    bool isCorrect = false;
    if (guessHigher) {
      isCorrect = nextCard.rank > currentCard.rank;
    } else {
      isCorrect = nextCard.rank < currentCard.rank;
    }

    // In exact rank tie, count as push / small consolation
    if (nextCard.rank == currentCard.rank) {
      isCorrect = true;
    }

    final newStreak = isCorrect ? (currentStreak + 1) : 0;
    final multiplierIndex = math.min(newStreak, hiLoMultipliers.length - 1);
    final multiplier = isCorrect ? hiLoMultipliers[multiplierIndex] : 0.0;

    return HiLoStepResult(
      currentCard: currentCard,
      nextCard: nextCard,
      isCorrect: isCorrect,
      currentStreak: newStreak,
      currentMultiplier: multiplier,
      isBust: !isCorrect,
    );
  }

  // ==========================================
  // 4. PISTON PLINKO
  // ==========================================
  // Symmetrical steep multipliers for 8 rows (9 slots)
  static const List<double> plinkoMultipliers = [
    1000.0, // Slot 0
    100.0, // Slot 1
    10.0, // Slot 2
    1.5, // Slot 3
    0.2, // Slot 4 (Center - Loss)
    1.5, // Slot 5
    10.0, // Slot 6
    100.0, // Slot 7
    1000.0, // Slot 8
  ];

  static PlinkoDropResult dropPlinkoBuji({
    required double betAmount,
    int rows = 8,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;
    final path = <int>[];
    int currentPos = 0; // relative count of right steps

    for (int r = 0; r < rows; r++) {
      // 50% left (-1), 50% right (+1)
      final step = rand.nextBool() ? 1 : 0;
      path.add(step == 1 ? 1 : -1);
      currentPos += step;
    }

    final slotIndex = math.min(math.max(currentPos, 0), plinkoMultipliers.length - 1);
    final mult = plinkoMultipliers[slotIndex];
    final payout = betAmount * mult;

    return PlinkoDropResult(
      pathOffsets: path,
      slotIndex: slotIndex,
      multiplier: mult,
      payoutAmount: payout,
    );
  }

  // ==========================================
  // 5. KAYIP BAGAJ RULETİ (LUCKY WHEEL)
  // ==========================================
  static final List<LuckyWheelSlice> wheelSlices = [
    const LuckyWheelSlice(id: 'slice_1', type: WheelSliceType.cashMultiplier, multiplier: 1.2, labelKey: 'wheel_1_2x', colorHex: 0xFF38BDF8),
    const LuckyWheelSlice(id: 'slice_2', type: WheelSliceType.cashMultiplier, multiplier: 2.0, labelKey: 'wheel_2x', colorHex: 0xFFFFDE59),
    const LuckyWheelSlice(id: 'slice_3', type: WheelSliceType.cashMultiplier, multiplier: 0.5, labelKey: 'wheel_0_5x', colorHex: 0xFF94A3B8),
    const LuckyWheelSlice(id: 'slice_4', type: WheelSliceType.cashMultiplier, multiplier: 5.0, labelKey: 'wheel_5x', colorHex: 0xFFFF7A00),
    const LuckyWheelSlice(id: 'slice_5', type: WheelSliceType.bankrupt, multiplier: 0.0, labelKey: 'wheel_bankrupt', colorHex: 0xFFEF4444),
    const LuckyWheelSlice(id: 'slice_6', type: WheelSliceType.cashMultiplier, multiplier: 1.5, labelKey: 'wheel_1_5x', colorHex: 0xFF38BDF8),
    const LuckyWheelSlice(id: 'slice_7', type: WheelSliceType.mysteryParts, multiplier: 3.0, labelKey: 'wheel_parts_box', colorHex: 0xFFA855F7),
    const LuckyWheelSlice(id: 'slice_8', type: WheelSliceType.cashMultiplier, multiplier: 10.0, labelKey: 'wheel_10x', colorHex: 0xFF00E575),
    const LuckyWheelSlice(id: 'slice_9', type: WheelSliceType.cashMultiplier, multiplier: 1.0, labelKey: 'wheel_1x', colorHex: 0xFF94A3B8),
    const LuckyWheelSlice(id: 'slice_10', type: WheelSliceType.legendaryCarKey, multiplier: 50.0, labelKey: 'wheel_legendary_key', colorHex: 0xFFFFD700),
    const LuckyWheelSlice(id: 'slice_11', type: WheelSliceType.cashMultiplier, multiplier: 2.5, labelKey: 'wheel_2_5x', colorHex: 0xFFFFDE59),
    const LuckyWheelSlice(id: 'slice_12', type: WheelSliceType.cashMultiplier, multiplier: 0.0, labelKey: 'wheel_miss', colorHex: 0xFF64748B),
  ];

  static LuckyWheelSpinResult spinLuckyWheel({
    required double betAmount,
    CarModel? wageredCar,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;

    // Weighted slice selection to prevent hyper-inflation
    // Legendary key has ~2.5% chance, Bankrupt ~8%, rest distributed
    final weights = [18, 14, 15, 8, 8, 16, 7, 4, 15, 2, 9, 12];
    final totalWeight = weights.reduce((a, b) => a + b);
    int pick = rand.nextInt(totalWeight);

    int selectedIndex = 0;
    for (int i = 0; i < weights.length; i++) {
      if (pick < weights[i]) {
        selectedIndex = i;
        break;
      }
      pick -= weights[i];
    }

    final slice = wheelSlices[selectedIndex];
    final isBankrupt = slice.type == WheelSliceType.bankrupt;

    double payout = 0.0;
    CarModel? awardedCar;

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;

    if (slice.type == WheelSliceType.cashMultiplier) {
      payout = effectiveBet * slice.multiplier;
    } else if (slice.type == WheelSliceType.mysteryParts) {
      payout = effectiveBet * 3.0;
    } else if (slice.type == WheelSliceType.legendaryCarKey) {
      payout = effectiveBet * 2.0;
      awardedCar = createRewardCar(
        brand: 'Ferrari',
        modelName: 'SF90 Stradale Speciale',
        year: 2025,
        price: math.max(effectiveBet * 2.5, 3500000.0),
      );
    }

    return LuckyWheelSpinResult(
      sliceIndex: selectedIndex,
      slice: slice,
      payoutAmount: payout,
      awardedCar: awardedCar,
      isBankrupt: isBankrupt,
    );
  }

  // ==========================================
  // 6. KAZI KAZAN (SCRATCH CARD)
  // ==========================================
  static const List<String> scratchSymbols = ['diamond', 'seven', 'crown', 'bell', 'coin', 'bar'];

  static ScratchCardResult generateScratchCard({
    required double cardCost,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;
    final isWinner = rand.nextDouble() < 0.40; // 40% win rate

    String? winSymbol;
    double payoutMultiplier = 0.0;

    if (isWinner) {
      final tierRoll = rand.nextDouble();
      if (tierRoll < 0.60) {
        winSymbol = 'coin';
        payoutMultiplier = 2.0; // 2x
      } else if (tierRoll < 0.85) {
        winSymbol = 'bell';
        payoutMultiplier = 4.0; // 4x
      } else if (tierRoll < 0.96) {
        winSymbol = 'seven';
        payoutMultiplier = 10.0; // 10x
      } else {
        winSymbol = 'crown';
        payoutMultiplier = 50.0; // 50x Jackpot!
      }
    }

    final List<ScratchSpot> grid = [];
    if (isWinner && winSymbol != null) {
      // Place 3 matching winning symbols at random spots
      final winIndices = <int>{};
      while (winIndices.length < 3) {
        winIndices.add(rand.nextInt(9));
      }

      for (int i = 0; i < 9; i++) {
        if (winIndices.contains(i)) {
          grid.add(ScratchSpot(
            symbol: winSymbol,
            prizeValue: cardCost * payoutMultiplier,
          ));
        } else {
          // Other random symbols not equal to winSymbol
          String filler;
          do {
            filler = scratchSymbols[rand.nextInt(scratchSymbols.length)];
          } while (filler == winSymbol);
          grid.add(ScratchSpot(symbol: filler, prizeValue: cardCost * 1.5));
        }
      }
    } else {
      // Non-winning card (no symbol appears 3 times)
      final counts = <String, int>{};
      for (int i = 0; i < 9; i++) {
        String s;
        do {
          s = scratchSymbols[rand.nextInt(scratchSymbols.length)];
        } while ((counts[s] ?? 0) >= 2); // cap max occurrences to 2
        counts[s] = (counts[s] ?? 0) + 1;
        grid.add(ScratchSpot(symbol: s, prizeValue: cardCost * 2.0));
      }
    }

    return ScratchCardResult(
      grid: grid,
      matchingSymbol: winSymbol,
      isWin: isWinner,
      payoutAmount: isWinner ? (cardCost * payoutMultiplier) : 0.0,
    );
  }

  // ==========================================
  // 7. ÇİFTE KATLA YA DA SIFIRLAN (DOUBLE OR NOTHING)
  // ==========================================
  static bool flipDoubleOrNothing({
    required bool guessHeads,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;
    final resultIsHeads = rand.nextBool();
    return resultIsHeads == guessHeads;
  }

  // ==========================================
  // 8. AVİATOR (TURBO ROKET • CRASH GAME)
  // ==========================================
  static double generateAviatorCrashMultiplier({math.Random? rng}) {
    final rand = rng ?? _random;
    final r = rand.nextDouble();
    // 3% instant crash at 1.00x
    if (r < 0.03) return 1.00;

    // Standard exponential distribution with 96% RTP
    final raw = 0.96 / (1.0 - r);
    // Clamp between 1.01x and 75.0x
    final mult = raw.clamp(1.01, 75.0);
    return double.parse(mult.toStringAsFixed(2));
  }

  static AviatorFlightResult playAviatorCashout({
    required double betAmount,
    required double cashedOutMultiplier,
    required double crashMultiplier,
    CarModel? wageredCar,
  }) {
    final isSuccess = cashedOutMultiplier <= crashMultiplier;
    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final payout = isSuccess ? (effectiveBet * cashedOutMultiplier) : 0.0;

    return AviatorFlightResult(
      crashMultiplier: crashMultiplier,
      cashedOutMultiplier: cashedOutMultiplier,
      isCashedOut: isSuccess,
      payoutAmount: payout,
    );
  }

  // ==========================================
  // 9. SANAYİ BARBUTU (ESNAF KUPA & ZAR DÜELLOSU)
  // ==========================================
  static BarbutResult playSanayiBarbutu({
    required double betAmount,
    required BarbutBetChoice choice,
    CarModel? wageredCar,
    math.Random? rng,
  }) {
    final rand = rng ?? _random;
    final d1 = rand.nextInt(6) + 1;
    final d2 = rand.nextInt(6) + 1;
    final sum = d1 + d2;

    final isDouble = d1 == d2;
    final isDuses = isDouble && d1 == 6; // 6-6
    final isDubes = isDouble && d1 == 5; // 5-5
    final isDortCihar = isDouble && d1 == 4; // 4-4
    final isDuse = isDouble && d1 == 3; // 3-3
    final isDubara = isDouble && d1 == 2; // 2-2
    final isHepyek = isDouble && d1 == 1; // 1-1

    String comboName;
    if (isDuses) {
      comboName = 'Düşeş • 6-6';
    } else if (isDubes) {
      comboName = 'Dübeş • 5-5';
    } else if (isDortCihar) {
      comboName = 'Dört Cihar • 4-4';
    } else if (isDuse) {
      comboName = 'Düse • 3-3';
    } else if (isDubara) {
      comboName = 'Dübara • 2-2';
    } else if (isHepyek) {
      comboName = 'Hepyek • 1-1';
    } else {
      comboName = 'Zar Toplamı • $sum';
    }

    bool isWin = false;
    double multiplier = 0.0;

    switch (choice) {
      case BarbutBetChoice.duses:
        if (isDuses) {
          isWin = true;
          multiplier = 5.0;
        }
        break;
      case BarbutBetChoice.ciftler:
        if (isDouble) {
          isWin = true;
          multiplier = 2.5;
        }
        break;
      case BarbutBetChoice.barbut:
        // Traditional Barbut: 3-3, 5-5, 6-6 wins (2.0x), 1-1, 2-2, 4-4 loses
        if (isDuses || isDubes || isDuse) {
          isWin = true;
          multiplier = 2.0;
        } else if (!isDouble && sum >= 9) {
          isWin = true;
          multiplier = 1.5;
        }
        break;
      case BarbutBetChoice.highRoll:
        if (sum >= 8) {
          isWin = true;
          multiplier = 2.0;
        }
        break;
    }

    final effectiveBet = wageredCar != null ? wageredCar.price : betAmount;
    final payout = isWin ? (effectiveBet * multiplier) : 0.0;

    return BarbutResult(
      die1: d1,
      die2: d2,
      sum: sum,
      isDuses: isDuses,
      isDubes: isDubes,
      isDortCihar: isDortCihar,
      isDuse: isDuse,
      isDubara: isDubara,
      isHepyek: isHepyek,
      isWin: isWin,
      multiplier: multiplier,
      payoutAmount: payout,
      comboName: comboName,
    );
  }
}
