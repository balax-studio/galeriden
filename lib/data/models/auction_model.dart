import '../../data/models/car_model.dart';

enum AuctionStatus { upcoming, active, ended }

class AuctionRival {
  final String name;
  final String avatarType;
  final double maxBudget;
  final String personality; // 'Agresif', 'Temkinli', 'Blöfçü'
  bool isFolded;

  AuctionRival({
    required this.name,
    required this.avatarType,
    required this.maxBudget,
    required this.personality,
    this.isFolded = false,
  });
}

class AuctionModel {
  final String id;
  final CarModel car;
  final double startingPrice;
  final double estimatedMarketValue;
  double currentBid;
  String highestBidderName;
  bool isPlayerHighestBidder;
  int secondsRemaining;
  AuctionStatus status;
  final List<AuctionRival> rivals;

  AuctionModel({
    required this.id,
    required this.car,
    required this.startingPrice,
    required this.estimatedMarketValue,
    required this.currentBid,
    required this.highestBidderName,
    required this.isPlayerHighestBidder,
    required this.secondsRemaining,
    required this.status,
    required this.rivals,
  });

  AuctionModel copyWith({
    double? currentBid,
    String? highestBidderName,
    bool? isPlayerHighestBidder,
    int? secondsRemaining,
    AuctionStatus? status,
    List<AuctionRival>? rivals,
  }) {
    return AuctionModel(
      id: id,
      car: car,
      startingPrice: startingPrice,
      estimatedMarketValue: estimatedMarketValue,
      currentBid: currentBid ?? this.currentBid,
      highestBidderName: highestBidderName ?? this.highestBidderName,
      isPlayerHighestBidder: isPlayerHighestBidder ?? this.isPlayerHighestBidder,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      status: status ?? this.status,
      rivals: rivals ?? this.rivals,
    );
  }
}
