import 'package:flutter/material.dart';

enum StoryAdRewardType {
  instantExpertise,
  bargainCarSpawn,
  expressDetailing,
  bonusSaleBoost,
  viralBuyerOffers,
  auctionMarginReport,
  partsDiscountCredit,
  scrapyardFreeTowCredit,
}

class StoryCardModel {
  final String id;
  final String title;
  final String characterName;
  final String characterRole;
  final String characterAvatar;
  final IconData icon;
  final String dialogue;
  final String rewardDescription;
  final String acceptLabel;
  final String declineLabel;
  final StoryAdRewardType rewardType;
  final Map<String, dynamic>? payload;

  const StoryCardModel({
    required this.id,
    required this.title,
    required this.characterName,
    required this.characterRole,
    required this.characterAvatar,
    required this.icon,
    required this.dialogue,
    required this.rewardDescription,
    required this.acceptLabel,
    required this.declineLabel,
    required this.rewardType,
    this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'characterName': characterName,
      'characterRole': characterRole,
      'characterAvatar': characterAvatar,
      'dialogue': dialogue,
      'rewardDescription': rewardDescription,
      'acceptLabel': acceptLabel,
      'declineLabel': declineLabel,
      'rewardType': rewardType.name,
      'payload': payload,
    };
  }

  factory StoryCardModel.fromJson(Map<String, dynamic> json) {
    // Find matching default card to restore non-serializable fields (like icon)
    final match = defaultCards.firstWhere(
      (c) => c.id == json['id'],
      orElse: () => defaultCards.first,
    );
    return StoryCardModel(
      id: json['id'] as String? ?? match.id,
      title: json['title'] as String? ?? match.title,
      characterName: json['characterName'] as String? ?? match.characterName,
      characterRole: json['characterRole'] as String? ?? match.characterRole,
      characterAvatar: json['characterAvatar'] as String? ?? match.characterAvatar,
      icon: match.icon,
      dialogue: json['dialogue'] as String? ?? match.dialogue,
      rewardDescription: json['rewardDescription'] as String? ?? match.rewardDescription,
      acceptLabel: json['acceptLabel'] as String? ?? match.acceptLabel,
      declineLabel: json['declineLabel'] as String? ?? match.declineLabel,
      rewardType: StoryAdRewardType.values.firstWhere(
        (e) => e.name == json['rewardType'],
        orElse: () => match.rewardType,
      ),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  /// 8 Rich Narrative Scenarios (5 Core Tycoon Stories + 3 Expansion Stories)
  static const List<StoryCardModel> defaultCards = [
    // 1. Haydar Usta (Kurnaz Ekspertiz Ustası)
    StoryCardModel(
      id: 'haydar_usta',
      title: 'KURNAZ EKSPERTİZ USTASI',
      characterName: 'Haydar Usta',
      characterRole: 'Sanayi Duayeni',
      characterAvatar: 'mechanic',
      icon: Icons.engineering_rounded,
      dialogue:
          '“Patron, garajdaki arabanın şasisi şüpheli duruyor. Normalde ekspertiz makinesi yarım saat sürer ama ben eski usül kulağımı kaportaya dayar ciğerini okurum. Bir çırağa çay ısmarla, sana bu araba yatırımlık mı hurdalık mı hemen fısıldayayım!”',
      rewardDescription: 'Bekleme süresi olmadan anında tam ekspertiz raporu & kusur tespiti.',
      acceptLabel: 'ÇAYA ÇORBAYA DESTEK (REKLAMI İZLE)',
      declineLabel: 'Hayır, Usta Dinlensin',
      rewardType: StoryAdRewardType.instantExpertise,
    ),

    // 2. Zengin Koleksiyonerin Şoförü
    StoryCardModel(
      id: 'zengin_sofor',
      title: 'KAPALI GARAJ İPUCU',
      characterName: 'Kadir Beyin Şoförü',
      characterRole: 'Koleksiyoner Asistanı',
      characterAvatar: 'sunglasses',
      icon: Icons.vpn_key_rounded,
      dialogue:
          '“Selam usta. Patronum bu gece acilen yurt dışına uçuyor. Garajdaki koleksiyonluk arabayı piyasanın yarı fiyatına elden çıkaracak. Konumu sana vermem için bana ufak bir sponsorluk jesti yapman lazım...”',
      rewardDescription: 'Pazara %50 indirimli, yüksek kâr marjlı kelepir fırsat aracı eklenir.',
      acceptLabel: 'KONUMU AL (REKLAMI İZLE)',
      declineLabel: 'Bana Güven Vermedi',
      rewardType: StoryAdRewardType.bargainCarSpawn,
    ),

    // 3. Gece Kuşu Boyacı
    StoryCardModel(
      id: 'gece_boyaci',
      title: 'EKSPRES DETAILING',
      characterName: 'Çırak Taylan',
      characterRole: 'Boya & Kaporta Kalfası',
      characterAvatar: 'sparkle',
      icon: Icons.format_paint_rounded,
      dialogue:
          '“Usta mesai bitti gidiyoruz ama çıraklara bir enerji içeceği ısmarlarsan gece vardiyasına kalırız! Arabaya sabaha kadar seramik kaplama ve pasta cila atarız. Yarın vitrinde iki katı fiyata parlar!”',
      rewardDescription: 'Araca anında %100 kusursuz boya/kaporta ve +%15 Vitrin Cazibesi (Değer Artışı).',
      acceptLabel: 'GECE VARDİYASINI AÇ (REKLAMI İZLE)',
      declineLabel: 'Mesaiye Kalmasınlar',
      rewardType: StoryAdRewardType.expressDetailing,
    ),

    // 4. İnatçı Alıcı ve Kahve Molası
    StoryCardModel(
      id: 'kahve_molasi',
      title: 'PAZARLIK MASASI & KAHVE',
      characterName: 'Hüsnü Bey',
      characterRole: 'İnatçı Müşteri',
      characterAvatar: 'coffee',
      icon: Icons.handshake_rounded,
      dialogue:
          '“Bu fiyat bana çok patron, ben masadan kalkıyorum... Dur bakalım sekreter bir orta şekerli Türk kahvesiyle ikram masasını donatırsa masaya geri oturur, istediğin fiyata el sıkışırız!”',
      rewardDescription: 'Müşterinin direnci kırılır: Araca anında liste fiyatının %10 üzerine hazır satış fırsatı.',
      acceptLabel: 'İKRÂM MASASINI DONAT (REKLAMI İZLE)',
      declineLabel: 'Normal Fiyata Razıyım',
      rewardType: StoryAdRewardType.bonusSaleBoost,
    ),

    // 5. Otomobil Vloggerı
    StoryCardModel(
      id: 'vlogger_ilan',
      title: 'VİRAL İLAN İNCELEMESİ',
      characterName: 'Vlogger Berk',
      characterRole: 'Oto Fenomeni',
      characterAvatar: 'video',
      icon: Icons.campaign_rounded,
      dialogue:
          '“Selam patron! Galerindeki şu yatan arabayla ilgili YouTube kanalında efsane bir reels patlatabilirim. Sponsorluk bütçemi karşıla, yarım saate kapında 3 tane hazır alıcı sıraya girsin!”',
      rewardDescription: 'İlandaki araç için anında 3 adet hazır alıcı teklifi yağar ve hızla satılır.',
      acceptLabel: 'VİRAL VİDEOYU PATLAT (REKLAMI İZLE)',
      declineLabel: 'Gerek Yok, Kendi Satılır',
      rewardType: StoryAdRewardType.viralBuyerOffers,
    ),

    // 6. Genişleme: Sigorta Eksperi (İhale Danışmanı)
    StoryCardModel(
      id: 'sigorta_eksperi',
      title: 'SİGORTA HASAR İSTİHBARATI',
      characterName: 'Eksper Melih',
      characterRole: 'TRAMER Denetçisi',
      characterAvatar: 'clipboard',
      icon: Icons.fact_check_rounded,
      dialogue:
          '“İhaledeki araçların gerçek hasar dosyalarına ve kâr analizlerine erişimim var. Bir çayımı tazelersen bir sonraki ihale için +%20 net kâr sağlayan gizli eksper dosyasını önüne sereyim.”',
      rewardDescription: 'Galeri sermayene ₺30.000 analiz desteği ve ihale kâr marjı bonusu aktarılır.',
      acceptLabel: 'DOSYAYI İNCELE (REKLAMI İZLE)',
      declineLabel: 'Riske Girerim',
      rewardType: StoryAdRewardType.auctionMarginReport,
    ),

    // 7. Genişleme: Çıkmacı İbo (Parça Tedariği)
    StoryCardModel(
      id: 'cikmaci_ibo',
      title: 'ÇIKMA PARÇA İNDİRİMİ',
      characterName: 'Çıkmacı İbo',
      characterRole: 'Yedek Parça Baronu',
      characterAvatar: 'bolt',
      icon: Icons.build_circle_rounded,
      dialogue:
          '“Almanya’dan tır dolusu orijinal sıfır ayarında yedek parça indirdim! Çıraklara ufak bir destek atarsan atölye masrafların için sana ₺35.000 değerinde parça kredisi hibe ediyorum!”',
      rewardDescription: 'Atölye tamirat ve yedek parça kasana ₺35.000 nakit hibe eklenir.',
      acceptLabel: 'PARÇA KREDİSİNİ AL (REKLAMI İZLE)',
      declineLabel: 'Orijinal Parçadan Şaşmam',
      rewardType: StoryAdRewardType.partsDiscountCredit,
    ),

    // 8. Genişleme: Çekici Remzi (Bedava Lojistik)
    StoryCardModel(
      id: 'cekici_remzi',
      title: 'ÇEKİCİ LOJİSTİK DESTEĞİ',
      characterName: 'Çekici Remzi',
      characterRole: 'Ağır Vasıta Operatörü',
      characterAvatar: 'truck',
      icon: Icons.local_shipping_rounded,
      dialogue:
          '“Hurdalıktan veya sanayiden çekeceğin araçlar için boş dönüyordum. Bana bir çorba parası bırak, bir sonraki nakliye operasyonunu ve ₺25.000 lojistik bedelini şirkete yazayım!”',
      rewardDescription: 'Lojistik ve nakliye fonuna ₺25.000 hibe kredisi tanımlanır.',
      acceptLabel: 'ÇEKİCİYİ YÖNLENDİR (REKLAMI İZLE)',
      declineLabel: 'Kendi Çekicimiz Var',
      rewardType: StoryAdRewardType.scrapyardFreeTowCredit,
    ),
  ];
}
