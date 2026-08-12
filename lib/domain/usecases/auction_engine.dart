import 'dart:math';
import '../../data/models/auction_model.dart';
import '../../domain/usecases/market_engine.dart';

class AuctionEngine {
  static final Random _random = Random();

  /// Checks if an auction is currently live (Active for 2 minutes every 5 minutes window)
  static bool isAuctionActiveNow() {
    final minute = DateTime.now().minute;
    return (minute % 5) < 2;
  }

  /// Calculates remaining seconds until next auction window opens
  static int getSecondsUntilNextAuction() {
    final now = DateTime.now();
    final minute = now.minute;
    final second = now.second;

    int minutesUntil = 5 - (minute % 5);
    int totalSeconds = (minutesUntil * 60) - second;
    return totalSeconds > 0 ? totalSeconds : 60;
  }

  static AuctionModel createLiveAuction({int playerLevel = 1}) {
    final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: playerLevel);
    final car = listings.first.car;

    final marketValue = car.estimatedRealValue;
    final startingPrice = (marketValue * 0.65).roundToDouble(); // Starts 35% below market!

    final rivals = [
      AuctionRival(
        name: 'Çakal Kerim',
        avatarType: 'craftsman',
        maxBudget: (marketValue * 0.95).roundToDouble(),
        personality: 'Agresif',
      ),
      AuctionRival(
        name: 'Hacı Osman',
        avatarType: 'shield',
        maxBudget: (marketValue * 0.88).roundToDouble(),
        personality: 'Temkinli',
      ),
      AuctionRival(
        name: 'Sosyetik Mert',
        avatarType: 'rare',
        maxBudget: (marketValue * 1.05).roundToDouble(),
        personality: 'Blöfçü',
      ),
    ];

    return AuctionModel(
      id: 'auc_${DateTime.now().microsecondsSinceEpoch}',
      car: car,
      startingPrice: startingPrice,
      estimatedMarketValue: marketValue,
      currentBid: startingPrice,
      highestBidderName: 'Gümrük İdaresi',
      isPlayerHighestBidder: false,
      secondsRemaining: 30,
      status: AuctionStatus.active,
      rivals: rivals,
    );
  }

  /// Process AI rivals' bid logic on each tick (returns updated auction or null if no bid placed)
  static AuctionModel? processRivalBid(AuctionModel auction) {
    if (auction.status != AuctionStatus.active || auction.secondsRemaining <= 0) {
      return null;
    }

    final activeRivals = auction.rivals.where((r) => !r.isFolded && r.maxBudget > auction.currentBid).toList();
    if (activeRivals.isEmpty) return null;

    // 40% chance an active rival bids on this tick
    if (_random.nextDouble() > 0.40) return null;

    final bidder = activeRivals[_random.nextInt(activeRivals.length)];
    final bidIncrement = (5000 + _random.nextInt(15000)).toDouble();
    final newBid = auction.currentBid + bidIncrement;

    if (newBid > bidder.maxBudget) {
      bidder.isFolded = true;
      return null;
    }

    return auction.copyWith(
      currentBid: newBid,
      highestBidderName: bidder.name,
      isPlayerHighestBidder: false,
      secondsRemaining: (auction.secondsRemaining < 8) ? 8 : auction.secondsRemaining,
    );
  }
}
