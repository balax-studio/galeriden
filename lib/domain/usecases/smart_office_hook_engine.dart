import '../../data/models/dealership_model.dart';

enum SmartHookType {
  dirtyCarsWash,
  damagedCarRepair,
  lowBalanceGrant,
  emptyGarageSpawn,
  viralReputationBoost,
}

class SmartHookModel {
  final SmartHookType type;
  final String title;
  final String callerName;
  final String callerRole;
  final String characterAvatar;
  final String storyDialogue;
  final String rewardDescription;
  final String rewardBadgeText;
  final String actionButtonLabel;
  final int accentColorValue;

  const SmartHookModel({
    required this.type,
    required this.title,
    required this.callerName,
    required this.callerRole,
    required this.characterAvatar,
    required this.storyDialogue,
    required this.rewardDescription,
    required this.rewardBadgeText,
    required this.actionButtonLabel,
    required this.accentColorValue,
  });
}

class OfficeGrantVariant {
  final String title;
  final String callerName;
  final String callerRole;
  final String dialogue;
  final String badgeText;

  const OfficeGrantVariant({
    required this.title,
    required this.callerName,
    required this.callerRole,
    required this.dialogue,
    required this.badgeText,
  });
}

class OfficeGossipTip {
  final String title;
  final String sourceName;
  final String content;
  final String iconKey;

  const OfficeGossipTip({
    required this.title,
    required this.sourceName,
    required this.content,
    required this.iconKey,
  });
}

class SmartOfficeHookEngine {
  /// Evaluates player's real-time state and returns the highest priority hook needed
  static SmartHookModel evaluate(DealershipModel game) {
    final seed = (game.officeSeed + game.currentDay).abs();

    // 1. Check if there are dirty/unwashed cars in garage
    final unwashedCars = game.ownedCars.where((c) => !c.isRented && (!c.isWashed || !c.isPolished || !c.isDetailedCleaned)).toList();
    if (unwashedCars.isNotEmpty) {
      final count = unwashedCars.length;
      final dialogues = [
        'Ustam, vitrindeki $count aracın tozu toprağı müşteri kaçırıyor! 30 saniye bir çay molası ver, gece tayfasıyla tüm filona komple köpüklü oto kuaför ve seramik cila çekelim!',
        'Reis, garajdaki $count araba tozdan görünmez olmuş. Sünger ve polisaj makinelerini hazırladım, tek bir sponsor molasıyla tüm arabaları ayna gibi parlatıp teslim edelim!',
        'Sanayinin en hızlı yıkama ekibi kapıda ustam! Vitrindeki $count arabaya komple pasta - cila ve detaylı iç kuaför operasyonu çekip alıcıları büyüleyelim.',
      ];
      final callers = [
        ('Çırak Memo', 'Sünger & Cila Ustası'),
        ('Yıkamacı Serkan', 'Buharlı Kuaför Şefi'),
        ('Detaycı Caner', 'Seramik Kaplama Uzmanı'),
      ];
      final chosenDialogue = dialogues[seed % dialogues.length];
      final chosenCaller = callers[seed % callers.length];

      return SmartHookModel(
        type: SmartHookType.dirtyCarsWash,
        title: 'Karaköy Gece Yıkama Çetesi',
        callerName: chosenCaller.$1,
        callerRole: chosenCaller.$2,
        characterAvatar: 'wash',
        storyDialogue: chosenDialogue,
        rewardDescription: 'Tüm garaj araçlarına anında ücretsiz profesyonel kuaför, pasta - cila ve detaylı temizlik uygulanır.',
        rewardBadgeText: '$count ARAÇ KUAFÖR & CİLA',
        actionButtonLabel: 'TÜM FİLOYU PARLAT',
        accentColorValue: 0xFF06B6D4, // Cyan
      );
    }

    // 2. Check if there is a car with low condition (<85%)
    final damagedCars = game.ownedCars.where((c) => !c.isRented && (c.expertise.engineCondition < 85 || c.expertise.transmissionCondition < 85)).toList()
      ..sort((a, b) => a.expertise.engineCondition.compareTo(b.expertise.engineCondition));
    if (damagedCars.isNotEmpty) {
      final car = damagedCars.first;
      final dialogues = [
        'Dükkandaki ${car.brand} ${car.modelName} aracının motorundan ses geliyor ustam! Sponsorumuzun faturasıyla araca sıfır sandık motor ve mekanik revizyonunu bedavaya getirelim!',
        'Ustam, ${car.brand} ${car.modelName} rektifiye istiyor. Reklam anlaşmamız sayesinde yedek parçayı ve torna işçiliğini sıfır masrafla halledip motoru %100 kondisyona çıkaralım!',
        'Kapıdaki ${car.brand} ${car.modelName} için Almanya sandık motor sevkiyatı denk geldi. Tek bir sponsor molasıyla motor bloğunu sıfırlayıp pazar değerini tavan yaptıralım!',
      ];
      final callers = [
        ('Kadir Usta', 'Kurt Revizyoncu'),
        ('Torna Şefi Hayri', 'Motor Bloğu Ustası'),
        ('Usta Şinasi', 'Sandık Motor Uzmanı'),
      ];
      final chosenDialogue = dialogues[seed % dialogues.length];
      final chosenCaller = callers[seed % callers.length];

      return SmartHookModel(
        type: SmartHookType.damagedCarRepair,
        title: 'Sanayinin Efsanesi Kurt Usta',
        callerName: chosenCaller.$1,
        callerRole: chosenCaller.$2,
        characterAvatar: 'mechanic',
        storyDialogue: chosenDialogue,
        rewardDescription: '${car.brand} ${car.modelName} motor ve şanzımanı anında %100 kondisyona çıkarılır.',
        rewardBadgeText: 'BEDAVA MOTOR REVİZYONU',
        actionButtonLabel: 'USTAYA ANAHTARI VER',
        accentColorValue: 0xFFE11D48, // Rose red
      );
    }

    // 3. Check if player balance is low (< ₺50.000)
    if (game.balance < 50000) {
      final dialogues = [
        'Kasa tamtakır kalmış be koçum! Piyasada nakitsiz durulmaz, al şu hurdalık altın fonundan ₺35.000 acil sermaye can suyunu, hemen ilk kelepir arabayı kap gel!',
        'Sanayide parasız kalan esnafın eli kolu bağlanır yeğenim. Al şu acil hibe sermayesini kasana koy, pazardan ilk fırsat arabasını galerine çek!',
        'Dükkanın nakit akışı sıkışmış ustam. Ticaret durmasın diye yedek zulamdan ₺35.000 nakit can suyu ayarladım, hemen kasana aktaralım!',
      ];
      final callers = [
        ('Çıkmacı İbo', 'Hurdalık Ağası'),
        ('Komisyoncu Nuri', 'Pazarın Ağır Abisi'),
        ('Kuyumcu Kenan', 'Sanayi Finansörü'),
      ];
      final chosenDialogue = dialogues[seed % dialogues.length];
      final chosenCaller = callers[seed % callers.length];

      return SmartHookModel(
        type: SmartHookType.lowBalanceGrant,
        title: 'Çıkmacı İbo Dayı - Acil Zula Fonu',
        callerName: chosenCaller.$1,
        callerRole: chosenCaller.$2,
        characterAvatar: 'deal',
        storyDialogue: chosenDialogue,
        rewardDescription: 'Galeri kasasına karşılıksız +₺35.000 ekstra nakit can suyu sermayesi eklenir.',
        rewardBadgeText: '+₺35.000 CAN SUYU',
        actionButtonLabel: 'ZULAYI KASAYA ÇEK',
        accentColorValue: 0xFF10B981, // Emerald green
      );
    }

    // 4. Check if garage is low on stock (0 or 1 car)
    if (game.ownedCars.length <= 1) {
      final dialogues = [
        'Ustam garajın bomboş kalmış, sinek avlıyorsun! Yediemin otoparkında hacizden düşme tertemiz bir fırsat aracı var, tek bir reklamla pazara %45 kelepir fiyatla düşüreyim!',
        'Galerinin vitrini boşken müşteri dükkana girmez ustam. Gümrük tasfiyesinden süper bir kelepir yakaladım, hemen vitrinine ekleyip +₺10.000 harçlık verelim!',
        'Piyasa araba bekliyor, senin showroom boş kalmış! Noter onaylı kelepir bir fırsat aracını pazara sokalım, harçlığını da cebine koyalım!',
      ];
      final callers = [
        ('Gümrükçü Selim', 'Yediemin Sorumlusu'),
        ('Tasfiye Şefi Rasim', 'İcra Satış Müdürü'),
        ('Oto Simsar Tahir', 'Fırsat Avcısı'),
      ];
      final chosenDialogue = dialogues[seed % dialogues.length];
      final chosenCaller = callers[seed % callers.length];

      return SmartHookModel(
        type: SmartHookType.emptyGarageSpawn,
        title: 'Gümrük Muhafaza Kelepir Tüyosu',
        callerName: chosenCaller.$1,
        callerRole: chosenCaller.$2,
        characterAvatar: 'deal',
        storyDialogue: chosenDialogue,
        rewardDescription: 'İkinci el pazarına %45 indirimli kelepir araç ilanı eklenir ve +₺10.000 harçlık verilir.',
        rewardBadgeText: '%45 KELEPİR ARAÇ + ₺10K',
        actionButtonLabel: 'TÜYOYU YAKALA',
        accentColorValue: 0xFFF59E0B, // Amber
      );
    }

    // 5. Default / Flourishing Dealer Hook: Influencer Viral Boost
    final dialogues = [
      'Abi galerinin önüne geldim, araçlar efsane duruyor! 30 saniyelik bir reels çekelim, videoya sponsor etiketini koyalım; hem +25 Prestij Puanı hem de vitrine %35 Hızlı Satış Dopingi patlatalım!',
      'Galerin sosyal medyada trendlere girdi ustam! Şık bir tanıtım hikayesi yayınlayalım, bayi itibarını +25 puan uçurup vitrindeki tüm arabalara satış dopingi uygulayalım!',
      'Otomobil meraklıları galerindeki araçları konuşuyor reis! Kısa bir video sponsorluğuyla tüm vitrini öne çıkaralım ve müşteri akını başlatalım!',
    ];
    final callers = [
      ('Fenomen Berkcan', 'Otomobil Editörü'),
      ('Vlogger Caner', 'Oto İnceleme Kanalı'),
      ('Editör Tolga', 'Motor Magazin Şefi'),
    ];
    final chosenDialogue = dialogues[seed % dialogues.length];
    final chosenCaller = callers[seed % callers.length];

    return SmartHookModel(
      type: SmartHookType.viralReputationBoost,
      title: 'Oto Fenomeni Viral Çekim Fırsatı',
      callerName: chosenCaller.$1,
      callerRole: chosenCaller.$2,
      characterAvatar: 'flash',
      storyDialogue: chosenDialogue,
      rewardDescription: 'Bayi itibarı anında +25 puan artar ve vitrindeki tüm araçlara 24 saatlik %35 hızlı satış dopingi uygulanır.',
      rewardBadgeText: '+25 İTİBAR & VİTRİN DOPİNGİ',
      actionButtonLabel: 'VİRAL REELS PATLAT',
      accentColorValue: 0xFFA855F7, // Purple
    );
  }

  /// Returns dynamic grant variants for Dayi Envelope cash bonus
  static OfficeGrantVariant getDailyGrantVariant(DealershipModel game) {
    final seed = (game.officeSeed + game.currentDay).abs();
    final variants = [
      const OfficeGrantVariant(
        title: 'Hikmet Dayı - Sarı Zarf Fonu',
        callerName: 'Gurbetçi Hikmet Dayı',
        callerRole: 'Almanya Emeklisi',
        dialogue: '"Yeğenim sanayide namını duyduk, piyasayı kasıp kavuruyorsun! Şu sarı zarfı al, dükkanın çorbası kaynasın, vitrine can suyu olsun!"',
        badgeText: 'GURBETÇİ DAYI FONU',
      ),
      const OfficeGrantVariant(
        title: 'Tüccar Muzaffer Bey - Esnaf Dayanışması',
        callerName: 'Tüccar Muzaffer',
        callerRole: 'Galericiler Derneği Onursal Başkanı',
        dialogue: '"Genç esnafın ayağı tökezlemesin! Ticaretin bereketi dayanışmadadır; al bu zarfı, kasana koyup piyasada dik dur!"',
        badgeText: 'ESNAF DAYANIŞMA FONU',
      ),
      const OfficeGrantVariant(
        title: 'Enişte Vedat - Ticaret Destek Paketi',
        callerName: 'Galerici Enişte Vedat',
        callerRole: 'Bölge Bayi Müteahhidi',
        dialogue: '"Aslan yeğenim dükkan açmış da biz destek olmaz mıyız? Al bu siftah desteğini, bereketli satışlar yap!"',
        badgeText: 'SİFTAH DESTEK FONU',
      ),
      const OfficeGrantVariant(
        title: 'Hacı İhsan Amca - Bereket Hissesi',
        callerName: 'Hacı İhsan Amca',
        callerRole: 'Eski Sanayi Ağası',
        dialogue: '"Dürüst esnafın rızkı boldur evlat. Al şu hayır duasını ve zarfı, dükkanına helalinden bol kazanç getirsin!"',
        badgeText: 'BEREKET HİSSESİ',
      ),
    ];

    return variants[seed % variants.length];
  }

  /// Returns dynamic daily office gossip and trading tips
  static List<OfficeGossipTip> getOfficeGossipAndTips(DealershipModel game) {
    final seed = (game.officeSeed + game.currentDay).abs();
    final allTips = [
      const OfficeGossipTip(
        title: 'Sanayi Fısıltısı • Suv Talebi',
        sourceName: 'Lastikçi Niyazi',
        content: 'Yaz sezonu yaklaşırken SUV ve 4x4 araçlara talep %20 yükseliyor. Stokta SUV tutanlar yüksek kâr marjıyla satacak.',
        iconKey: 'trending_up',
      ),
      const OfficeGossipTip(
        title: 'Ekspertiz Tüyosu • Boyasız Göçük',
        sourceName: 'Ekspertiz Şefi Tarık',
        content: 'Orijinal boyalı parçaları boyamak yerine PDR Boyasız Göçük Düzeltme yapmak aracın orijinalliğini ve alıcı ilgisini korur.',
        iconKey: 'verified',
      ),
      const OfficeGossipTip(
        title: 'Pazar Stratejisi • Temiz Araç Etkisi',
        sourceName: 'Yıkamacı Serkan',
        content: 'Detaylı temizliği ve cilası yapılmış araçlar vitrinde %40 daha hızlı teklif toplar. Müşteriler ilk bakışta ışıldayan arabayı tercih eder.',
        iconKey: 'auto_awesome',
      ),
      const OfficeGossipTip(
        title: 'Noter Uyarısı • Dolandırıcılık',
        sourceName: 'Noter Katibi Zeynep',
        content: 'Piyasa değerinin çok üzerinde nakit teklif eden bazı şüpheli alıcılar sahte dekont kullanabilir. Noterde para hesaba geçmeden imza atma!',
        iconKey: 'security',
      ),
      const OfficeGossipTip(
        title: 'Banka Finansmanı • Kredi Çekimi',
        sourceName: 'Banka Müdürü Serdar',
        content: 'Düşük faizli esnaf kredileriyle toplu kelepir alıp restore etmek sermaye büyümesini 3 katına çıkarabilir.',
        iconKey: 'account_balance',
      ),
      const OfficeGossipTip(
        title: 'Hurda Değeri • Nadir Parçalar',
        sourceName: 'Çıkmacı İbo',
        content: 'Hurdalıktaki klasik araçları ucuza toplayıp atölyede parçalarını orijinal revize edersen koleksiyonerlere rekor fiyata satarsın.',
        iconKey: 'build_circle',
      ),
    ];

    final index1 = seed % allTips.length;
    final index2 = (seed + 1) % allTips.length;
    return [allTips[index1], allTips[index2]];
  }
}
