import 'dart:math';
import '../../data/models/auction_model.dart';
import '../../data/models/car_model.dart';
import '../../data/models/vehicle_category.dart';

enum ConsignmentBuyerType {
  dealer,
  collector,
  fleet,
  sniper,
  impatient,
  retiree,
}

class ConsignmentBuyer {
  final String id;
  final String name;
  final ConsignmentBuyerType type;
  final String avatarKey;
  final double maxBudget;
  final double lastBid;
  final bool isFolded;
  final String? lastSpeech;

  const ConsignmentBuyer({
    required this.id,
    required this.name,
    required this.type,
    required this.avatarKey,
    required this.maxBudget,
    this.lastBid = 0.0,
    this.isFolded = false,
    this.lastSpeech,
  });

  ConsignmentBuyer copyWith({
    double? lastBid,
    bool? isFolded,
    String? lastSpeech,
  }) {
    return ConsignmentBuyer(
      id: id,
      name: name,
      type: type,
      avatarKey: avatarKey,
      maxBudget: maxBudget,
      lastBid: lastBid ?? this.lastBid,
      isFolded: isFolded ?? this.isFolded,
      lastSpeech: lastSpeech ?? this.lastSpeech,
    );
  }
}

class ConsignmentAuctionModel {
  final CarModel car;
  final double reservePrice;
  final double startingPrice;
  final double currentBid;
  final ConsignmentBuyer? highestBidder;
  final List<ConsignmentBuyer> buyers;
  final int secondsRemaining;
  final AuctionGavelStage gavelStage;
  final bool isEnded;
  final List<String> logs;
  final bool hasExtended;
  final String? activeSpeech;
  final String? activeSpeakerName;

  const ConsignmentAuctionModel({
    required this.car,
    required this.reservePrice,
    required this.startingPrice,
    required this.currentBid,
    this.highestBidder,
    required this.buyers,
    this.secondsRemaining = 30,
    this.gavelStage = AuctionGavelStage.ongoing,
    this.isEnded = false,
    this.logs = const [],
    this.hasExtended = false,
    this.activeSpeech,
    this.activeSpeakerName,
  });

  bool get isReserveMet => currentBid >= reservePrice;

  bool get isSold => isEnded && isReserveMet && highestBidder != null;

  double get commissionFee => (currentBid * 0.005).roundToDouble();

  double get fixedFee => 1250.0;

  double get totalDeductions => commissionFee + fixedFee;

  double get netPayout => (currentBid - totalDeductions).clamp(0.0, double.infinity);

  ConsignmentAuctionModel copyWith({
    CarModel? car,
    double? reservePrice,
    double? startingPrice,
    double? currentBid,
    ConsignmentBuyer? highestBidder,
    bool clearHighestBidder = false,
    List<ConsignmentBuyer>? buyers,
    int? secondsRemaining,
    AuctionGavelStage? gavelStage,
    bool? isEnded,
    List<String>? logs,
    bool? hasExtended,
    String? activeSpeech,
    bool clearActiveSpeech = false,
    String? activeSpeakerName,
    bool clearActiveSpeakerName = false,
  }) {
    return ConsignmentAuctionModel(
      car: car ?? this.car,
      reservePrice: reservePrice ?? this.reservePrice,
      startingPrice: startingPrice ?? this.startingPrice,
      currentBid: currentBid ?? this.currentBid,
      highestBidder: clearHighestBidder ? null : (highestBidder ?? this.highestBidder),
      buyers: buyers ?? this.buyers,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
      gavelStage: gavelStage ?? this.gavelStage,
      isEnded: isEnded ?? this.isEnded,
      logs: logs ?? this.logs,
      hasExtended: hasExtended ?? this.hasExtended,
      activeSpeech: clearActiveSpeech ? null : (activeSpeech ?? this.activeSpeech),
      activeSpeakerName: clearActiveSpeakerName ? null : (activeSpeakerName ?? this.activeSpeakerName),
    );
  }
}

class ConsignmentAuctionEngine {
  static final Random _rng = Random();

  /// Check if a car can be placed on auction
  static bool canListCar(CarModel car) {
    if (car.isRented || car.isLockedInShowcase || car.isConsignment) {
      return false;
    }
    return true;
  }

  /// Calculate auction fee breakdown
  static ({double commission, double fixedFee, double totalDeductions, double netPayout}) calculateAuctionFees(double salePrice) {
    final commission = (salePrice * 0.005).roundToDouble();
    const fixedFee = 1250.0;
    final totalDeductions = commission + fixedFee;
    final netPayout = max(0.0, salePrice - totalDeductions);
    return (
      commission: commission,
      fixedFee: fixedFee,
      totalDeductions: totalDeductions,
      netPayout: netPayout,
    );
  }

  /// Create a fresh consignment auction session for a given car and reserve price
  static ConsignmentAuctionModel createAuction({
    required CarModel car,
    required double reservePrice,
  }) {
    final startingPrice = (reservePrice * 0.80).roundToDouble();
    final buyers = generateBuyersForCar(car);

    return ConsignmentAuctionModel(
      car: car,
      reservePrice: reservePrice,
      startingPrice: startingPrice,
      currentBid: startingPrice,
      buyers: buyers,
      secondsRemaining: 30,
      gavelStage: AuctionGavelStage.ongoing,
      isEnded: false,
      logs: [
        'Müzayede açıldı • Açılış Bedeli: ₺${startingPrice.round()}',
        'Muhammen Bedel: ₺${reservePrice.round()}',
      ],
      hasExtended: false,
    );
  }

  /// Generate AI buyers tuned to the car's specifications
  static List<ConsignmentBuyer> generateBuyersForCar(CarModel car) {
    final valuation = car.estimatedRealValue;
    final buyers = <ConsignmentBuyer>[];

    // 1. Dealer Buyer (Always present)
    final dealerBudgetMultiplier = 0.75 + _rng.nextDouble() * 0.15; // 75% - 90%
    double dealerPenalty = 1.0;
    if (car.expertise.tramerAmount > 40000) dealerPenalty *= 0.90;
    if (car.expertise.engineCondition < 75) dealerPenalty *= 0.92;
    buyers.add(ConsignmentBuyer(
      id: 'buyer_dealer_${_rng.nextInt(9999)}',
      name: _pickDealerName(),
      type: ConsignmentBuyerType.dealer,
      avatarKey: 'dealer',
      maxBudget: (valuation * dealerBudgetMultiplier * dealerPenalty).roundToDouble(),
    ));

    // 2. Collector Buyer (Prominent if rare, barn find, special color, legendary plate, classic/sport)
    final bool isCollectorCandidate = car.isRare ||
        car.isBarnFind ||
        car.colorRarity != 'standard' ||
        car.plateRarity == 'legendary' ||
        car.plateRarity == 'symmetric' ||
        car.bodyType.toLowerCase() == 'klasik' ||
        car.bodyType.toLowerCase() == 'spor' ||
        car.modelYear < 2000;

    final collectorMultiplier = isCollectorCandidate
        ? (1.05 + _rng.nextDouble() * 0.22) // 105% - 127%
        : (0.85 + _rng.nextDouble() * 0.15); // 85% - 100%
    buyers.add(ConsignmentBuyer(
      id: 'buyer_collector_${_rng.nextInt(9999)}',
      name: _pickCollectorName(),
      type: ConsignmentBuyerType.collector,
      avatarKey: 'collector',
      maxBudget: (valuation * collectorMultiplier).roundToDouble(),
    ));

    // 3. Fleet Buyer (Prominent if commercial, minivan, or low mileage sedan)
    final bool isFleetCandidate = car.vehicleCategory == VehicleCategory.commercial ||
        car.vehicleCategory == VehicleCategory.minivan ||
        car.bodyType.toLowerCase() == 'sedan' ||
        car.bodyType.toLowerCase() == 'hatchback';

    final fleetMultiplier = isFleetCandidate
        ? (0.92 + _rng.nextDouble() * 0.14) // 92% - 106%
        : (0.75 + _rng.nextDouble() * 0.12);
    buyers.add(ConsignmentBuyer(
      id: 'buyer_fleet_${_rng.nextInt(9999)}',
      name: _pickFleetName(),
      type: ConsignmentBuyerType.fleet,
      avatarKey: 'fleet',
      maxBudget: (valuation * fleetMultiplier).roundToDouble(),
    ));

    // 4. Impatient Boss or Sniper
    if (_rng.nextBool()) {
      final sniperMultiplier = 0.95 + _rng.nextDouble() * 0.18; // 95% - 113%
      buyers.add(ConsignmentBuyer(
        id: 'buyer_sniper_${_rng.nextInt(9999)}',
        name: _pickSniperName(),
        type: ConsignmentBuyerType.sniper,
        avatarKey: 'sniper',
        maxBudget: (valuation * sniperMultiplier).roundToDouble(),
      ));
    } else {
      final impatientMultiplier = 0.90 + _rng.nextDouble() * 0.16; // 90% - 106%
      buyers.add(ConsignmentBuyer(
        id: 'buyer_impatient_${_rng.nextInt(9999)}',
        name: _pickImpatientName(),
        type: ConsignmentBuyerType.impatient,
        avatarKey: 'impatient',
        maxBudget: (valuation * impatientMultiplier).roundToDouble(),
      ));
    }

    // 5. Nostalgic Retiree (Enamored by older cars, Tofaşk/Anadolum, or immaculate engines)
    final retireeMultiplier = (car.modelYear <= 2008 || car.expertise.engineCondition >= 90)
        ? (0.95 + _rng.nextDouble() * 0.18) // 95% - 113%
        : (0.80 + _rng.nextDouble() * 0.12);
    buyers.add(ConsignmentBuyer(
      id: 'buyer_retiree_${_rng.nextInt(9999)}',
      name: _pickRetireeName(),
      type: ConsignmentBuyerType.retiree,
      avatarKey: 'retiree',
      maxBudget: (valuation * retireeMultiplier).roundToDouble(),
    ));

    return buyers;
  }

  /// Advance the auction by one clock tick (typically called every 1 second)
  static ConsignmentAuctionModel tick(ConsignmentAuctionModel model) {
    if (model.isEnded) return model;

    var newRemaining = model.secondsRemaining - 1;
    final updatedLogs = List<String>.from(model.logs);
    var updatedBuyers = List<ConsignmentBuyer>.from(model.buyers);
    var currentBid = model.currentBid;
    var highestBidder = model.highestBidder;
    var hasExtended = model.hasExtended;
    String? activeSpeech;
    String? activeSpeakerName;

    // Check gavel calls
    AuctionGavelStage gavelStage;
    if (newRemaining <= 0) {
      gavelStage = AuctionGavelStage.finalHammer;
    } else if (newRemaining <= 2) {
      gavelStage = AuctionGavelStage.secondCall;
    } else if (newRemaining <= 4) {
      gavelStage = AuctionGavelStage.firstCall;
    } else {
      gavelStage = AuctionGavelStage.ongoing;
    }

    // Determine bidding action
    if (newRemaining > 0) {
      // Find eligible buyers who haven't folded and whose maxBudget can support a higher bid
      final candidates = <int>[];
      for (int i = 0; i < updatedBuyers.length; i++) {
        final b = updatedBuyers[i];
        if (b.isFolded) continue;
        if (highestBidder != null && highestBidder.id == b.id) continue;

        // Snipers only wake up in final 6 seconds
        if (b.type == ConsignmentBuyerType.sniper && newRemaining > 6) continue;

        // Fold check: if max budget is strictly less than current bid, fold
        if (b.maxBudget <= currentBid) {
          final foldSpeech = _getFoldDialogue(b.type);
          updatedBuyers[i] = b.copyWith(isFolded: true, lastSpeech: foldSpeech);
          updatedLogs.add('${b.name} çekildi • "$foldSpeech"');
          activeSpeech = foldSpeech;
          activeSpeakerName = b.name;
          continue;
        }

        candidates.add(i);
      }

      // Decide if a bid occurs this tick
      final bool shouldAttemptBid = candidates.isNotEmpty &&
          (_rng.nextDouble() < (newRemaining <= 6 ? 0.75 : 0.45));

      if (shouldAttemptBid) {
        candidates.shuffle(_rng);
        final candidateIndex = candidates.first;
        final bidder = updatedBuyers[candidateIndex];

        // Increment calculation: 1.5% to 3.5% of current bid, rounded to 500 or 1000 step
        final rawStep = currentBid * (0.015 + _rng.nextDouble() * 0.020);
        final double roundedStep;
        if (currentBid > 500000) {
          roundedStep = max(5000.0, (rawStep / 5000.0).round() * 5000.0);
        } else if (currentBid > 100000) {
          roundedStep = max(2000.0, (rawStep / 1000.0).round() * 1000.0);
        } else {
          roundedStep = max(1000.0, (rawStep / 500.0).round() * 500.0);
        }

        final targetBid = currentBid + roundedStep;
        if (targetBid <= bidder.maxBudget) {
          currentBid = targetBid;
          final bidSpeech = _getBidDialogue(bidder.type, isReserveMet: currentBid >= model.reservePrice);
          updatedBuyers[candidateIndex] = bidder.copyWith(
            lastBid: currentBid,
            lastSpeech: bidSpeech,
          );
          highestBidder = updatedBuyers[candidateIndex];
          activeSpeech = bidSpeech;
          activeSpeakerName = bidder.name;
          updatedLogs.add('${bidder.name}: ₺${currentBid.round()} teklif etti • "$bidSpeech"');

          // FOMO late bid extension: if bid occurs in last 5 seconds and not extended yet
          if (newRemaining <= 5 && !hasExtended) {
            hasExtended = true;
            updatedLogs.add('Son saniye teklifi • Süre +5 saniye uzatıldı');
          }
        } else {
          // Can't afford step, fold
          final foldSpeech = _getFoldDialogue(bidder.type);
          updatedBuyers[candidateIndex] = bidder.copyWith(isFolded: true, lastSpeech: foldSpeech);
          updatedLogs.add('${bidder.name} çekildi • "$foldSpeech"');
          activeSpeech = foldSpeech;
          activeSpeakerName = bidder.name;
        }
      }
    }

    final finalRemaining = (newRemaining <= 5 && hasExtended && !model.hasExtended)
        ? newRemaining + 5
        : max(0, newRemaining);

    final isEnded = finalRemaining <= 0;
    if (isEnded) {
      if (highestBidder != null && currentBid >= model.reservePrice) {
        updatedLogs.add('SATTIM! Araç ₺${currentBid.round()} bedelle ${highestBidder.name} adına kaldı.');
      } else {
        updatedLogs.add('İhale kapandı • Muhammen bedele ulaşılamadı. Araç satılamadı.');
      }
    }

    return model.copyWith(
      secondsRemaining: finalRemaining,
      gavelStage: gavelStage,
      isEnded: isEnded,
      currentBid: currentBid,
      highestBidder: highestBidder,
      buyers: updatedBuyers,
      logs: updatedLogs,
      hasExtended: hasExtended,
      activeSpeech: activeSpeech,
      clearActiveSpeech: activeSpeech == null,
      activeSpeakerName: activeSpeakerName,
      clearActiveSpeakerName: activeSpeakerName == null,
    );
  }

  static String _pickDealerName() {
    const list = [
      'Galeri Kadir',
      'Esnaf Mahmut',
      'Oto Galeri İlyas',
      'Ticarethane Şahin',
      'Galerici Ekrem',
    ];
    return list[_rng.nextInt(list.length)];
  }

  static String _pickCollectorName() {
    const list = [
      'Koleksiyoner Selim Bey',
      'Avukat Cengiz',
      'Mimar Haldun',
      'Restorasyon Uzmanı Asım',
      'Koleksiyoncu Vural',
    ];
    return list[_rng.nextInt(list.length)];
  }

  static String _pickFleetName() {
    const list = [
      'Filo Direktörü Tarık',
      'Lojistik Müdürü Hamdi',
      'Turizm İşletmecisi Zafer',
      'Şirket Temsilcisi Kerem',
      'Filo Satın Alma Erhan',
    ];
    return list[_rng.nextInt(list.length)];
  }

  static String _pickSniperName() {
    const list = [
      'Sniper Koray',
      'Avcı Levent',
      'Fırsatçı Murat',
      'Pusu Tahsin',
      'Sessiz Alıcı Doğan',
    ];
    return list[_rng.nextInt(list.length)];
  }

  static String _pickImpatientName() {
    const list = [
      'Müteahhit Burhan',
      'Tekstilci Vedat',
      'İş İnsanı Sami',
      'Fabrikatör Reha',
      'Patron Necati',
    ];
    return list[_rng.nextInt(list.length)];
  }

  static String _pickRetireeName() {
    const list = [
      'Emekli Muallim Rıza Bey',
      'Albay Mümtaz',
      'Eski Bankacı Nihat Bey',
      'Usta Şoför Rasim Dayı',
      'Emekli Makinist Cevdet',
    ];
    return list[_rng.nextInt(list.length)];
  }

  static String _getBidDialogue(ConsignmentBuyerType type, {required bool isReserveMet}) {
    switch (type) {
      case ConsignmentBuyerType.dealer:
        return isReserveMet
            ? 'Esnaf kârını bırakır bu fiyat, artırıyorum.'
            : 'Açılışa katılıyorum, dükkana çekilir.';
      case ConsignmentBuyerType.collector:
        return isReserveMet
            ? 'Koleksiyonuma çok yakışacak, kaçırmam.'
            : 'Kondisyonu çok diri, değerini hak ediyor.';
      case ConsignmentBuyerType.fleet:
        return 'Fizibilite onayladı, şirket adına artırıyorum.';
      case ConsignmentBuyerType.sniper:
        return 'Pusu bitti! Son saniyede alıp çıkıyorum.';
      case ConsignmentBuyerType.impatient:
        return 'Vaktim değerli, doğrudan rakamı büyütüyorum.';
      case ConsignmentBuyerType.retiree:
        return 'Gençlik yıllarımın arabası, torunuma hediye edeceğim.';
    }
  }

  static String _getFoldDialogue(ConsignmentBuyerType type) {
    switch (type) {
      case ConsignmentBuyerType.dealer:
        return 'Rakam esnaf limitini aştı, hayırlı işler.';
      case ConsignmentBuyerType.collector:
        return 'Benim için tavan fiyat buydu, alana hayırlı olsun.';
      case ConsignmentBuyerType.fleet:
        return 'Bütçe sınırımız doldu, ihaleden çekiliyoruz.';
      case ConsignmentBuyerType.sniper:
        return 'Fiyat beklediğimden yukarı fırladı, pas geçiyorum.';
      case ConsignmentBuyerType.impatient:
        return 'Bu kadar inatlaşmaya değmez, başka araca bakarım.';
      case ConsignmentBuyerType.retiree:
        return 'Emekli maaşını aşar bu evlat, ben duruyorum.';
    }
  }
}
