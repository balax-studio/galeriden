import 'dart:math';
import '../../data/models/auction_model.dart';
import '../../domain/usecases/market_engine.dart';

class AuctionEngine {
  static final Random _random = Random();

  /// Checks if an auction window is currently active (Active 3 minutes, Closed 3 minutes)
  static bool isAuctionActiveNow() {
    final minute = DateTime.now().minute;
    return (minute % 6) < 3;
  }

  /// Calculates remaining seconds until next auction window opens
  static int getSecondsUntilNextAuction() {
    final now = DateTime.now();
    final minute = now.minute;
    final second = now.second;

    int minutesUntil = 6 - (minute % 6);
    int totalSeconds = (minutesUntil * 60) - second;
    return totalSeconds > 0 ? totalSeconds : 60;
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
