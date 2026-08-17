import 'dart:math';
import '../../data/models/auction_model.dart';
import '../../domain/usecases/market_engine.dart';

class AuctionEngine {
  static final Random _random = Random();
  static DateTime? _nextSessionTime;
  static DateTime? _currentSessionEndTime;

  static final List<TrunkLoot> _lootPool = [
    const TrunkLoot(
      name: 'Gizli Torpido Döviz Zarfı',
      value: 14500.0,
      type: TrunkLootType.cash,
      description: 'Önceki araç sahibinin torpidonun arkasına saklayıp unuttuğu döviz birikimi.',
    ),
    const TrunkLoot(
      name: 'Krom Spor Egzoz & Yazılım Beyni',
      value: 18000.0,
      type: TrunkLootType.part,
      description: 'Bagaj havuzunda orijinal kutusunda bekleyen sıfır performans kiti.',
    ),
    const TrunkLoot(
      name: 'Pioneer Tesisat & Amfi Takımı',
      value: 8500.0,
      type: TrunkLootType.audio,
      description: 'Bagaj döşemesine entegre temiz ses sistemi donanımı.',
    ),
    const TrunkLoot(
      name: 'Nadir 18 İnç BBS Jant Takımı',
      value: 22000.0,
      type: TrunkLootType.part,
      description: 'Bagaja istiflenmiş hatasız orijinal alaşımlı jantlar.',
    ),
    const TrunkLoot(
      name: 'Orijinal Stepne & İthal Takım Sandığı',
      value: 5000.0,
      type: TrunkLootType.rareTool,
      description: 'Fabrika çıkışlı sıfır bijon anahtarı ve takım seti.',
    ),
    const TrunkLoot(
      name: 'Profesyonel Detailing & Seramik Kiti',
      value: 7500.0,
      type: TrunkLootType.part,
      description: 'Bagajda unutulmuş açılmamış profesyonel seramik kaplama seti.',
    ),
    const TrunkLoot(
      name: 'Alman Çeki Demiri & Tavan Portbagajı',
      value: 12500.0,
      type: TrunkLootType.rareTool,
      description: 'Ruhsata işli orijinal montaj aparatı ve portbagaj.',
    ),
    const TrunkLoot(
      name: 'Nostaljik 90lar Kaset & CD Koleksiyonu',
      value: 4000.0,
      type: TrunkLootType.audio,
      description: 'Dönemine ait nadir yabancı rock ve Türk sanat müziği arşivi.',
    ),
    const TrunkLoot(
      name: 'Karbon Fiber Ayna Kapakları & Spoiler',
      value: 16000.0,
      type: TrunkLootType.part,
      description: 'Araca özel üretilmiş hafif karbon aerodinamik gövde parçaları.',
    ),
    const TrunkLoot(
      name: 'İmzalı İlk Sahibinden Servis Karnesi',
      value: 6000.0,
      type: TrunkLootType.rareTool,
      description: 'Tüm yetkili servis faturaları ve koleksiyonluk garanti belgesi.',
    ),
  ];

  static final List<String> _legalStatuses = [
    'Gümrük Muhafaza & Tasfiye İdaresi',
    'Maliye Bakanlığı Vergi Haciz Satışı',
    'Banka Finans Rehinli İcra Dairesi',
    'Yabancı Konsolosluk Filo Tasfiyesi',
    'Otopark Yediemin Şerhli Satış',
    'Miras Paylaşımı Mahkeme Müzayedesi',
    'Liman Kaçakçılık Zaptı Tasfiye Lotu',
  ];

  static final List<String> _riskRewardFactors = [
    'Kusursuz Kondisyon (Muhafaza Altında Tutulmuş)',
    'Hafif Kaporta İzi / Çekme Belgeli',
    'Piyango Fırsatı (Düşük KM & Servis Bakımlı)',
    'Anahtarsız Yediemin Girişli',
    'Motor Diri / Ekspertiz Onaylı',
    'Koleksiyonluk Kasa / Orijinal Hatlar',
  ];

  static final List<String> _originOffices = [
    'İstanbul Erenköy Gümrük Müdürlüğü',
    'Ankara İcra Dairesi 4. Satış Memurluğu',
    'İzmir Alsancak Liman Tasfiye Şubesi',
    'Bursa Ticaret Mahkemesi Müzayede Masası',
    'Antalya Havalimanı Gümrük Başmüdürlüğü',
    'Kocaeli Derince Liman Müzayede Bürosu',
  ];

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
      'Tasfiye ilanları askıya çıktı. Yeni seans $timeStr içinde müzayedeye sunulacak.',
    ];
    return dialogues[_random.nextInt(dialogues.length)];
  }

  /// Generates a random Customs Annotation with trunk loot
  static CustomsAnnotation generateCustomsAnnotation() {
    return CustomsAnnotation(
      legalStatus: _legalStatuses[_random.nextInt(_legalStatuses.length)],
      riskRewardFactor: _riskRewardFactors[_random.nextInt(_riskRewardFactors.length)],
      originOffice: _originOffices[_random.nextInt(_originOffices.length)],
      trunkLoot: _lootPool[_random.nextInt(_lootPool.length)],
    );
  }

  /// Generates the upcoming auction lot catalogue
  static List<UpcomingLotModel> generateUpcomingLots({int count = 3, int playerLevel = 1}) {
    final listings = MarketEngine.generateRandomListings(count: count, playerLevel: playerLevel);
    int startLot = 101 + _random.nextInt(50);

    return List.generate(listings.length, (index) {
      final car = listings[index].car;
      final marketValue = car.estimatedRealValue;
      final startRatio = 0.50 + (_random.nextDouble() * 0.18);
      final startingPrice = (marketValue * startRatio).roundToDouble();

      return UpcomingLotModel(
        lotNumber: startLot + index,
        car: car,
        startingPrice: startingPrice,
        estimatedMarketValue: marketValue,
        customsNote: generateCustomsAnnotation(),
      );
    });
  }

  /// Create a fresh live auction instance
  static AuctionModel createLiveAuction({int playerLevel = 1}) {
    final listings = MarketEngine.generateRandomListings(count: 1, playerLevel: playerLevel);
    final car = listings.first.car;

    final marketValue = car.estimatedRealValue;
    final startRatio = 0.50 + (_random.nextDouble() * 0.20);
    final startingPrice = (marketValue * startRatio).roundToDouble();

    final allRivalsPool = [
      AuctionRival(
        name: 'Hızlı Ahmet',
        avatarType: 'craftsman',
        maxBudget: (marketValue * 0.82).roundToDouble(),
        personality: 'Erken Agresif',
        dialogues: [
          'Ben bu arabayı ucuza kapatırım!',
          'Hemen artırıyorum, beklemek yok!',
          'Gaza bastım bir kere, zor dururum!',
          'Bütçemi aşıyor, ben çekiliyorum...',
        ],
      ),
      AuctionRival(
        name: 'Sabırlı Mehmet',
        avatarType: 'shield',
        maxBudget: (marketValue * 0.92).roundToDouble(),
        personality: 'Son Saniye Sniper',
        dialogues: [
          'Acele eden eceline koşar...',
          'Pusuya yattım, son saniyeyi bekleyin.',
          'Tam zamanında vuruş yaptım!',
          'Fiyat çok şişti, hayrını görün.',
        ],
      ),
      AuctionRival(
        name: 'Zengin Ayşe',
        avatarType: 'rare',
        maxBudget: (marketValue * 1.15).roundToDouble(),
        personality: 'Yüksek Bütçe & Lüks',
        dialogues: [
          'Paranın gözü kör olsun, alacağım!',
          'Bunu galerimin en önüne koyacağım.',
          'Benim teklifimi kimse geçemez!',
          'Bu hurdaya daha fazla para gömmem.',
        ],
      ),
      AuctionRival(
        name: 'Çılgın Kemal',
        avatarType: 'sparkles',
        maxBudget: (marketValue * 0.98).roundToDouble(),
        personality: 'Sürpriz & Kaotik',
        dialogues: [
          'Ortalık karışsın biraz, teklife bak!',
          'Şansa bak araba benim olacak!',
          'İnadım inat, sonuna kadar!',
          'Racon kestiniz, pes ediyorum!',
        ],
      ),
      AuctionRival(
        name: 'Galerici Vedat',
        avatarType: 'craftsman',
        maxBudget: (marketValue * 0.88).roundToDouble(),
        personality: 'Piyasa Kurdu',
        dialogues: [
          'Esnaf işi fiyat verdim, üstü kurtarmaz.',
          'Bu arabayı dükkana çeker üç günde satarım.',
          'Rakam yükseldi, bize ekmek kalmadı.',
        ],
      ),
      AuctionRival(
        name: 'Koleksiyoner Selçuk',
        avatarType: 'rare',
        maxBudget: (marketValue * 1.20).roundToDouble(),
        personality: 'Nadir Kasa Avcısı',
        dialogues: [
          'Böyle diri kasa on yılda bir düşer.',
          'Değerini bilmeyenler çekilsin aradan.',
          'Fiyat sınırımı aştı, tebrik ederim.',
        ],
      ),
    ];

    allRivalsPool.shuffle(_random);
    final rivals = allRivalsPool.take(4).toList();

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
      customsNote: generateCustomsAnnotation(),
    );
  }

  /// Process AI rivals' bid logic on each tick
  static AuctionModel? processRivalBid(AuctionModel auction) {
    if (auction.status != AuctionStatus.active || auction.secondsRemaining <= 0) {
      return null;
    }

    final activeRivals = auction.rivals.where((r) => !r.isFolded && r.maxBudget > auction.currentBid).toList();
    if (activeRivals.isEmpty) return null;

    for (final rival in activeRivals) {
      bool shouldBid = false;
      double increment = 5000.0;

      if (rival.name == 'Hızlı Ahmet') {
        if (auction.secondsRemaining > 10 && _random.nextDouble() < 0.45) {
          shouldBid = true;
          increment = 7500.0 + _random.nextInt(7500);
        }
      } else if (rival.name == 'Sabırlı Mehmet') {
        if (auction.secondsRemaining <= 5 && _random.nextDouble() < 0.70) {
          shouldBid = true;
          increment = 5000.0 + _random.nextInt(10000);
        }
      } else if (rival.name == 'Zengin Ayşe') {
        if (_random.nextDouble() < 0.35) {
          shouldBid = true;
          increment = 12000.0 + _random.nextInt(18000);
        }
      } else if (rival.name == 'Çılgın Kemal') {
        if (_random.nextDouble() < 0.30) {
          shouldBid = true;
          increment = 3000.0 + _random.nextInt(25000);
        }
      }

      if (shouldBid) {
        final newBid = auction.currentBid + increment;
        if (newBid > rival.maxBudget) {
          rival.isFolded = true;
          rival.lastSpeech = rival.dialogues.isNotEmpty ? rival.dialogues.last : 'Ben çekiliyorum!';
          continue;
        }

        final speechIdx = rival.dialogues.isNotEmpty ? _random.nextInt(rival.dialogues.length - 1) : 0;
        final speech = rival.dialogues.isNotEmpty ? rival.dialogues[speechIdx] : 'Teklifim hazır!';
        rival.lastSpeech = speech;

        return auction.copyWith(
          currentBid: newBid,
          highestBidderName: rival.name,
          isPlayerHighestBidder: false,
          secondsRemaining: (auction.secondsRemaining < 6) ? 7 : auction.secondsRemaining,
          activeSpeech: speech,
          activeSpeakerName: rival.name,
        );
      }
    }

    return null;
  }
}
