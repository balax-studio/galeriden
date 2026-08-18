import '../../data/models/car_model.dart';

enum AuctionStatus { upcoming, active, ended }

enum AuctionGavelStage { ongoing, firstCall, secondCall, finalHammer }

enum TrunkLootType { cash, part, audio, rareTool }

class TrunkLoot {
  final String name;
  final double value;
  final TrunkLootType type;
  final String description;
  final String icon;

  const TrunkLoot({
    required this.name,
    required this.value,
    required this.type,
    required this.description,
    this.icon = '',
  });
}

class CustomsAnnotation {
  final String legalStatus;
  final String riskRewardFactor;
  final String originOffice;
  final TrunkLoot trunkLoot;

  const CustomsAnnotation({
    required this.legalStatus,
    required this.riskRewardFactor,
    required this.originOffice,
    required this.trunkLoot,
  });
}

class UpcomingLotModel {
  final int lotNumber;
  final CarModel car;
  final double startingPrice;
  final double estimatedMarketValue;
  final CustomsAnnotation customsNote;

  const UpcomingLotModel({
    required this.lotNumber,
    required this.car,
    required this.startingPrice,
    required this.estimatedMarketValue,
    required this.customsNote,
  });
}

class AuctionRival {
  final String name;
  final String avatarType;
  final double maxBudget;
  final String personality; // 'Erken Agresif', 'Son Saniye Sniper', 'Yüksek Bütçe & Lüks', 'Sürpriz & Kaotik'
  bool isFolded;
  final List<String> dialogues;
  String? lastSpeech;

  AuctionRival({
    required this.name,
    required this.avatarType,
    required this.maxBudget,
    required this.personality,
    this.isFolded = false,
    this.dialogues = const [],
    this.lastSpeech,
  });

  AuctionRival copyWith({
    bool? isFolded,
    String? lastSpeech,
  }) {
    return AuctionRival(
      name: name,
      avatarType: avatarType,
      maxBudget: maxBudget,
      personality: personality,
      isFolded: isFolded ?? this.isFolded,
      dialogues: dialogues,
      lastSpeech: lastSpeech ?? this.lastSpeech,
    );
  }
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
  final CustomsAnnotation customsNote;
  final String? activeSpeech;
  final String? activeSpeakerName;

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
    required this.customsNote,
    this.activeSpeech,
    this.activeSpeakerName,
  });

  AuctionGavelStage get gavelStage {
    if (secondsRemaining <= 1) return AuctionGavelStage.finalHammer;
    if (secondsRemaining <= 3) return AuctionGavelStage.secondCall;
    if (secondsRemaining <= 5) return AuctionGavelStage.firstCall;
    return AuctionGavelStage.ongoing;
  }

  String get gavelCallText {
    switch (gavelStage) {
      case AuctionGavelStage.finalHammer:
        return '3. ÇAĞRI: SATTIM • SATTT-TIM!';
      case AuctionGavelStage.secondCall:
        return '2. ÇAĞRI: Satıyorum...';
      case AuctionGavelStage.firstCall:
        return '1. ÇAĞRI: Satıyorum...';
      case AuctionGavelStage.ongoing:
        return 'Teklifler alınıyor';
    }
  }

  AuctionModel copyWith({
    double? currentBid,
    String? highestBidderName,
    bool? isPlayerHighestBidder,
    int? secondsRemaining,
    AuctionStatus? status,
    List<AuctionRival>? rivals,
    CustomsAnnotation? customsNote,
    String? activeSpeech,
    String? activeSpeakerName,
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
      customsNote: customsNote ?? this.customsNote,
      activeSpeech: activeSpeech ?? this.activeSpeech,
      activeSpeakerName: activeSpeakerName ?? this.activeSpeakerName,
    );
  }
}
