import 'dart:math';
import '../../data/models/auction_model.dart';
import '../../domain/usecases/market_engine.dart';

class AuctionEngine {
  static final Random _random = Random();
  static DateTime? _nextSessionTime;
  static DateTime? _currentSessionEndTime;

  /// Checks if an auction window is currently active (Dynamically randomized open/close cycles)
  static bool isAuctionActiveNow() {
    final now = DateTime.now();

    // If active session is ongoing
    if (_currentSessionEndTime != null) {
      if (now.isBefore(_currentSessionEndTime!)) {
        return true;
      } else {
        // Session ended, schedule next random interval
        _currentSessionEndTime = null;
        scheduleNextRandomSession();
        return false;
      }
    }

    // If waiting for next scheduled session
    if (_nextSessionTime != null) {
      if (now.isAfter(_nextSessionTime!)) {
        // Scheduled time reached! Open session for randomized duration (90 to 180 seconds)
        final sessionDuration = 90 + _random.nextInt(90);
        _currentSessionEndTime = now.add(Duration(seconds: sessionDuration));
        _nextSessionTime = null;
        return true;
      } else {
        return false;
      }
    }

    // If uninitialized, initialize with a fresh random schedule
    scheduleNextRandomSession();
    return false;
  }

  /// Calculates remaining seconds until next auction window opens
  static int getSecondsUntilNextAuction() {
    final now = DateTime.now();
    if (_nextSessionTime == null) {
      scheduleNextRandomSession();
    }
    final diff = _nextSessionTime!.difference(now).inSeconds;
    return diff > 0 ? diff : 0;
  }

  /// Schedules next random session interval (random between 45 and 180 seconds)
  static void scheduleNextRandomSession({int minSeconds = 45, int maxSeconds = 180}) {
    final randomSeconds = minSeconds + _random.nextInt(maxSeconds - minSeconds + 1);
    _nextSessionTime = DateTime.now().add(Duration(seconds: randomSeconds));
    _currentSessionEndTime = null;
  }

  /// Force start an active auction session
  static void openSessionImmediately({int durationSeconds = 120}) {
    _currentSessionEndTime = DateTime.now().add(Duration(seconds: durationSeconds));
    _nextSessionTime = null;
  }

  /// Clerk / Officer interactive dialogues
  static String getRandomOfficerDialogue(String timeStr) {
    final dialogues = [
      'Gümrük ve Tasfiye İdaresi evrakları inceliyor. Bir sonraki ihale seansı yaklaşık $timeStr sonra başlayacak.',
      'İcra dairesinden yeni hacizli araç dosyaları geldi, sisteme giriyoruz. İhale salonu $timeStr sonra açılacak.',
      'Müzayede komisyonu araç başlangıç fiyatlarını onaylıyor. Seansın başlamasına yaklaşık $timeStr kaldı.',
      'Ekspertiz ve muhafaza tutanakları tamamlanmak üzere. Bir sonraki araç müzayedesi $timeStr içinde başlayacak.',
      'Salon hazırlıkları ve katılımcı listeleri düzenleniyor. Sıradaki müzayede $timeStr sonra canlı yayına geçecek.',
    ];
    return dialogues[_random.nextInt(dialogues.length)];
  }

  static AuctionModel createLiveAuction({int playerLevel = 1}) {
    final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: playerLevel);
    final car = listings.first.car;

    final marketValue = car.estimatedRealValue;
    // Kelepir starting price: 50% - 70% of market value
    final startRatio = 0.50 + (_random.nextDouble() * 0.20);
    final startingPrice = (marketValue * startRatio).roundToDouble();

    final rivals = [
      AuctionRival(
        name: 'Hızlı Ahmet',
        avatarType: 'craftsman',
        maxBudget: (marketValue * 0.82).roundToDouble(),
        personality: 'Erken Agresif',
      ),
      AuctionRival(
        name: 'Sabırlı Mehmet',
        avatarType: 'shield',
        maxBudget: (marketValue * 0.92).roundToDouble(),
        personality: 'Son Saniye Sniper',
      ),
      AuctionRival(
        name: 'Zengin Ayşe',
        avatarType: 'rare',
        maxBudget: (marketValue * 1.15).roundToDouble(),
        personality: 'Yüksek Bütçe & Lüks',
      ),
      AuctionRival(
        name: 'Çılgın Kemal',
        avatarType: 'sparkles',
        maxBudget: (marketValue * 0.98).roundToDouble(),
        personality: 'Sürpriz & Kaotik',
      ),
    ];

    return AuctionModel(
      id: 'auc_${DateTime.now().microsecondsSinceEpoch}',
      car: car,
      startingPrice: startingPrice,
      estimatedMarketValue: marketValue,
      currentBid: startingPrice,
      highestBidderName: 'Gümrük ve Tasfiye İdaresi',
      isPlayerHighestBidder: false,
      secondsRemaining: 25,
      status: AuctionStatus.active,
      rivals: rivals,
    );
  }

  /// Process AI rivals' bid logic on each tick
  static AuctionModel? processRivalBid(AuctionModel auction) {
    if (auction.status != AuctionStatus.active || auction.secondsRemaining <= 0) {
      return null;
    }

    final activeRivals = auction.rivals.where((r) => !r.isFolded && r.maxBudget > auction.currentBid).toList();
    if (activeRivals.isEmpty) return null;

    // Evaluate each rival's personality
    for (final rival in activeRivals) {
      bool shouldBid = false;
      double increment = 5000.0;

      if (rival.name == 'Hızlı Ahmet') {
        // Ahmet bids early (seconds > 12) with high chance
        if (auction.secondsRemaining > 10 && _random.nextDouble() < 0.45) {
          shouldBid = true;
          increment = 7500.0 + _random.nextInt(7500);
        }
      } else if (rival.name == 'Sabırlı Mehmet') {
        // Mehmet snipes at the very end (seconds <= 5)
        if (auction.secondsRemaining <= 5 && _random.nextDouble() < 0.70) {
          shouldBid = true;
          increment = 5000.0 + _random.nextInt(10000);
        }
      } else if (rival.name == 'Zengin Ayşe') {
        // Ayşe bids if marketValue is high or randomly
        if (_random.nextDouble() < 0.35) {
          shouldBid = true;
          increment = 12000.0 + _random.nextInt(18000);
        }
      } else if (rival.name == 'Çılgın Kemal') {
        // Kemal has erratic bursts
        if (_random.nextDouble() < 0.30) {
          shouldBid = true;
          increment = 3000.0 + _random.nextInt(25000);
        }
      }

      if (shouldBid) {
        final newBid = auction.currentBid + increment;
        if (newBid > rival.maxBudget) {
          rival.isFolded = true;
          continue;
        }

        return auction.copyWith(
          currentBid: newBid,
          highestBidderName: rival.name,
          isPlayerHighestBidder: false,
          secondsRemaining: (auction.secondsRemaining < 6) ? 7 : auction.secondsRemaining,
        );
      }
    }

    return null;
  }
}
