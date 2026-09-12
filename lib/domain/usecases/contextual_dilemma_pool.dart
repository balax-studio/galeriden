import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/dealership_model.dart';
import '../../data/models/dramatic_card_model.dart';

/// Contextual dilemma pool providing situational narrative dilemmas based on player state.
/// Replaces the rigid 365-day static calendar lookup with responsive gameplay events.
class ContextualDilemmaPool {
  ContextualDilemmaPool._();

  /// Calculates dynamically scaling grant/bailout funds based on level and debt deficit.
  static double calculateDynamicGrant(DealershipModel state) {
    final levelMultiplier = state.level * 40000.0;
    final deficitCover = state.balance < 0 ? state.balance.abs() + 25000.0 : 0.0;
    return max(50000.0, levelMultiplier + deficitCover);
  }

  /// 1. ROOKIE DEALER POOL (Days 1 to 5 or Level <= 2)
  static final List<DramaticCardModel> rookieCards = [
    DramaticCardModel(
      id: 'rookie_tea_mahmut',
      category: DramaticCategory.comedy,
      severity: DramaticSeverity.low,
      title: 'Çay Ocağı Çırağı Mahmut',
      characterName: 'Çırak Mahmut',
      characterRole: 'Sanayi Çay Ocağı',
      characterAvatar: 'mustache',
      icon: Icons.local_cafe_rounded,
      dialogue: 'Hayırlı siftahlar abi! Yeni dükkanın ilk demli tavşan kanı çayı ocağımızın hediyesi. Esnaflıkta ağız tatlılığı berekettir der ustam.',
      foreshadowHint: 'Esnafla kurulan sıcak bağlar ileride sana müşteri ve tüyo olarak geri döner.',
      minPlayerLevel: 1,
      choices: [
        DramaticChoiceModel(
          id: 'tea_tip',
          label: 'Bahşiş Ver ve Hatır Say',
          shortDescription: 'Çırağa ₺200 bahşiş vererek esnafa samimi bir merhaba de',
          upfrontCost: 200.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Esnaf Dayanışması Başladı',
              message: 'Mahmut sevinçle teşekkür etti. Sanayi esnafı yeni galericinin cömertliğini konuşuyor.',
              isSuccess: true,
              reputationDelta: 4,
              xpReward: 35,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'tea_thanks',
          label: 'Teşekkür Et ve İkramı Al',
          shortDescription: 'Masraf yapmadan kibarca teşekkür ederek işine odaklan',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Sıcak Bir Başlangıç',
              message: 'Çayı yudumlayıp ilk iş gününün heyecanını yaşadın.',
              isSuccess: true,
              reputationDelta: 1,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'rookie_mentor_cemil',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.low,
      title: 'Eski Kurt Galericinin Ziyareti',
      characterName: 'Cemil Usta',
      characterRole: 'Emekli Galeri Duayeni',
      characterAvatar: 'suit',
      icon: Icons.workspace_premium_rounded,
      dialogue: 'Evlat, bu caddede kırk yılım geçti. Araba satmak kolaydır, asıl marifet müşteriyi kapıdan içeri sokmakta. Arabanı alır almaz hemen vitrine koyacaksın, bekletmeyeceksin.',
      foreshadowHint: 'Tecrübeli ustaların tüyoları ticaret ufkunu ve piyasa sezgini hızla açar.',
      minPlayerLevel: 1,
      choices: [
        DramaticChoiceModel(
          id: 'listen_advice',
          label: 'Hürmet Et ve Öğüt Al',
          shortDescription: 'Ustanın tecrübelerini dinleyip zihnine not et',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Ticaret Sırrı Kazanıldı',
              message: 'Cemil Usta memnuniyetle başını salladı. Galerici vizyonun güçlendi.',
              isSuccess: true,
              reputationDelta: 2,
              xpReward: 50,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'treat_lunch',
          label: 'Yemek Ismarla • Tam Tüyo Al',
          shortDescription: 'Ustaya ₺500 esnaf lokantası yemeği ısmarlayıp piyasa sırrını öğren',
          upfrontCost: 500.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Usta Tüyosu Cepte',
              message: 'Cemil Usta sana çevredeki ekspertiz açıkları ve hızlı satış formülünü anlattı.',
              isSuccess: true,
              reputationDelta: 5,
              xpReward: 90,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'rookie_first_cleaning',
      category: DramaticCategory.comedy,
      severity: DramaticSeverity.low,
      title: 'İlk Vitrin Parlatması',
      characterName: 'Seyyar Temizlikçi',
      characterRole: 'Oto Kuaför Emekçisi',
      characterAvatar: 'detective',
      icon: Icons.cleaning_services_rounded,
      dialogue: 'Hayırlı olsun patron! Vitrindeki araba toz içinde kalmış. Şöyle bir cila çekelim, geçen müşteri dönüp bir daha baksın.',
      foreshadowHint: 'Görsel temizlik müşterinin ilk bakışta teklif verme arzusunu tetikler.',
      minPlayerLevel: 1,
      choices: [
        DramaticChoiceModel(
          id: 'clean_yourself',
          label: 'Kolları Sıva ve Kendin Sil',
          shortDescription: 'Para harcamadan bez ve kovayı alıp vitrini parlat',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Alın Teriyle Parlayan Galeri',
              message: 'Yorulup terledin ama vitrindeki araç pırıl pırıl parıldıyor.',
              isSuccess: true,
              reputationDelta: 2,
              xpReward: 40,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'hire_cleaner',
          label: 'Profesyonel Cila Yaptır',
          shortDescription: '₺400 vererek hızlı ve kusursuz bir vitrin temizliği sağla',
          upfrontCost: 400.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Ayna Gibi Vitrin',
              message: 'Araç showroom ışıkları altında ayna gibi parladı, yoldan geçenlerin ilgisini çekti.',
              isSuccess: true,
              reputationDelta: 4,
              xpReward: 60,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 2. CASH CRISIS & LIQUIDITY POOL (Balance < ₺25,000)
  static final List<DramaticCardModel> cashCrisisCards = [
    DramaticCardModel(
      id: 'crisis_scrap_buyer',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.high,
      title: 'Hurda Akü ve Parça Toptancısı',
      characterName: 'Hurdacı Hamdi',
      characterRole: 'Metal ve Akü Tüccarı',
      characterAvatar: 'mustache',
      icon: Icons.car_crash_rounded,
      dialogue: 'Selamın aleyküm patron. Kasanın sıkışık olduğunu sanayi konuşuyor. Arka depoda duran eski akü, çıkma radyatör ve sac parçaları ver, peşin ₺15.000 nakit sayayım.',
      foreshadowHint: 'Acil nakit krizlerinde atıl malzemeleri elden çıkarmak iflastan korur.',
      choices: [
        DramaticChoiceModel(
          id: 'sell_scrap_now',
          label: 'Hurdayı Ver ve Nakdi Al',
          shortDescription: 'Depodaki hurda metalleri satarak kasayı anında ₺15.000 rahatlat',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Kritik Can Suyu Sağlandı',
              message: 'Hamdi peşin parayı masaya saydı. Kasa nefes aldı, borç tehlikesi ötelendi.',
              isSuccess: true,
              moneyDelta: 15000.0,
              reputationDelta: -1,
              xpReward: 40,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'keep_scrap',
          label: 'Teklifi Reddet • Gururu Koru',
          shortDescription: 'Depoyu elletme, kendi imkanlarınla toparlanmaya çalış',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Zorlu Mücadele Devam Ediyor',
              message: 'Hurdacı eli boş döndü. Esnaf senin kararlılığına ve dik duruşuna saygı duydu.',
              isSuccess: true,
              reputationDelta: 3,
              xpReward: 25,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'crisis_esnaf_solidarity',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.medium,
      title: 'Esnaf Kefaleti ve Dayanışma',
      characterName: 'Seyfi Galeri',
      characterRole: 'Komşu Galeri Sahibi',
      characterAvatar: 'suit',
      icon: Icons.handshake_rounded,
      dialogue: 'Kardeşim, dar gün esnafın imtihanıdır. Biz birbirimizin ayağına basmayız, elinden tutarız. Şimdilik kasana ₺25.000 faizsiz emanet bırakayım, işleri toparlayınca ödersin.',
      foreshadowHint: 'Esnaf dayanışması seni batmaktan kurtarır ama borç sadakati gerektirir.',
      choices: [
        DramaticChoiceModel(
          id: 'accept_solidarity',
          label: 'Emaneti Kabul Et • Teşekkür Et',
          shortDescription: 'Acil esnaf dayanışma sermayesini kasana aktar',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Esnaf Can Suyu Geldi',
              message: 'Kasaya dinamik can suyu sermayesi girdi. Seyfi Abi omzuna vurup başarılar diledi.',
              isSuccess: true,
              isDynamicGrant: true,
              reputationDelta: 2,
              xpReward: 50,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'decline_solidarity',
          label: 'Teşekkür Et ama Kendi Başına Çöz',
          shortDescription: 'Borç altına girmeden kendi ticaretinle toparlan',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Özgüven Tazelendi',
              message: 'Seyfi Abi gururuna saygı duydu. İtibarın esnaf nezdinde katlandı.',
              isSuccess: true,
              reputationDelta: 5,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'crisis_family_legacy',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.high,
      title: 'Köyden Gelen Miras İntikali',
      characterName: 'Avukat Rıfat',
      characterRole: 'Aile Miras Vekili',
      characterAvatar: 'suit',
      icon: Icons.account_balance_rounded,
      dialogue: 'Müjdeli haber galericim! Köydeki miras intikal işlemleri tamamlandı. Ya hissene düşen nakit payı doğrudan alıp kasanı rahatlat ya da örtü altında yatan dede yadigârı 1982 model Mercedes 200D klasiği galerine çekelim.',
      foreshadowHint: 'Nakit kasa açığını tamamen kapatır, yadigâr araç ise karlı bir restorasyon ve satış fırsatı sunar.',
      choices: [
        DramaticChoiceModel(
          id: 'legacy_cash',
          label: 'Miras Payını Nakde Çevir',
          shortDescription: 'Miras hissesini peşin tahsil ederek işletme kasana dinamik can suyu sağla',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Miras Payı Kasaya Girdi',
              message: 'Avukat miras payını işletme hesabına aktardı. Kasa ferahladı, borç tehlikesi son buldu.',
              isSuccess: true,
              isDynamicGrant: true,
              reputationDelta: 1,
              xpReward: 60,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'legacy_classic_car',
          label: 'Yadigâr Klasik Aracı Getir',
          shortDescription: 'Köydeki garajdan 1982 Mercedes 200D W123 klasiği sıfır maliyetle filona kat',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Yadigâr Klasik Galeride',
              message: '1982 Mercedes 200D W123 çekiciyle galeriye ulaştırıldı. Sıfır maliyetle filona katıldı.',
              isSuccess: true,
              grantHeirloomVehicle: true,
              reputationDelta: 4,
              xpReward: 100,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 3. IDLE INVENTORY POOL (Cars listed for days or unlisted idle cars)
  static final List<DramaticCardModel> idleInventoryCards = [
    DramaticCardModel(
      id: 'idle_walk_in_buyer',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.medium,
      title: 'Ayaküstü Gelen Alıcı Fırsatı',
      characterName: 'Müteahhit Rıfat',
      characterRole: 'Nakit Hazır Müşteri',
      characterAvatar: 'suit',
      icon: Icons.payments_rounded,
      dialogue: 'Selamlar galeriye. Vitrindeki aracı internet ilanında gördüm. Fazla pazarlık sevmem, ufak bir ikram yaparsan çantamdaki nakitle hemen notere geçeriz.',
      foreshadowHint: 'Hızlı nakit dönmesi yeni yatırımların önünü açar.',
      requiresCarInGarage: true,
      choices: [
        DramaticChoiceModel(
          id: 'accept_cash_offer',
          label: 'İkram Yap ve Hemen Sat',
          shortDescription: 'Aracı hızlıca nakde çevirerek kasana güçlü sıcak para girişi sağla',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Hızlı ve Temiz Satış',
              message: 'Noterde işlemler yarım saatte bitti. Kasana taze satış kârı girdi!',
              isSuccess: true,
              moneyDelta: 35000.0,
              reputationDelta: 3,
              xpReward: 80,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'firm_price',
          label: 'Liste Fiyatında Israr Et',
          shortDescription: 'Fiyattan taviz verme, tam değerini beklemeyi tercih et',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.6,
              title: 'Müşteri Fiyatı Kabul Etti',
              message: 'Rıfat kararlılığını görünce parayı eksiksiz ödemeyi kabul etti.',
              isSuccess: true,
              moneyDelta: 50000.0,
              reputationDelta: 4,
              xpReward: 100,
            ),
            DramaticOutcomeModel(
              probability: 0.4,
              title: 'Müşteri Vazgeçti',
              message: 'Rıfat tok satıcı tavrına bozulup başka galeriye yöneldi.',
              isSuccess: false,
              reputationDelta: -1,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'idle_car_photographer',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.low,
      title: 'Otomobil Fotoğrafçısı Genç',
      characterName: 'Ömer Çekim',
      characterRole: 'Sosyal Medya Fotoğrafçısı',
      characterAvatar: 'detective',
      icon: Icons.camera_enhance_rounded,
      dialogue: 'Abi arabaların çok güzel ama ilan fotoğrafların zayıf kalmış. Özel ışık ve geniş açıyla çekim yapayım, Sarı Sitede ilanına bakanların sayısı üçe katlansın.',
      foreshadowHint: 'Kusursuz ilan görselleri alıcı teklif sıklığını doğrudan artırır.',
      requiresCarInGarage: true,
      choices: [
        DramaticChoiceModel(
          id: 'pay_photo',
          label: 'Profesyonel Çekim Yaptır',
          shortDescription: '₺850 ödeyerek araçlarına stüdyo kalitesinde fotoğraf çektir',
          upfrontCost: 850.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'İlanlar Ön Plana Çıktı',
              message: 'Fotoğraflar harika oldu! İlan sayfana görüntüleme ve teklif yağmaya başladı.',
              isSuccess: true,
              reputationDelta: 4,
              xpReward: 70,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'skip_photo',
          label: 'Kendi Fotoğraflarımla Devam',
          shortDescription: 'Mevcut telefon fotoğraflarıyla masrafsız devam et',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Masrafsız Tercih',
              message: 'Bütçeyi korudun. Doğal fotoğraflarla yola devam ediyorsun.',
              isSuccess: true,
              xpReward: 15,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 4. GENERAL & FLOURISHING MARKET POOL
  static final List<DramaticCardModel> generalCards = [
    DramaticCardModel(
      id: 'general_tax_inspection',
      category: DramaticCategory.conscience,
      severity: DramaticSeverity.medium,
      title: 'Maliye Esnaf Yoklaması',
      characterName: 'Müfettiş Serdar',
      characterRole: 'Gelir İdaresi Denetmeni',
      characterAvatar: 'suit',
      icon: Icons.fact_check_rounded,
      dialogue: 'Kolay gelsin. Bölgedeki ikinci el otomobil alım satım faturalarını ve noter devir harçlarını rutin kontrolden geçiriyoruz.',
      foreshadowHint: 'Şeffaf ve dürüst muhasebe defterleri galeri itibarının garantisidir.',
      choices: [
        DramaticChoiceModel(
          id: 'present_books',
          label: 'Defterleri Eksiksiz Sun',
          shortDescription: 'Tüm evrakları şeffafça müfettişe teslim et',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.9,
              title: 'Kusursuz Denetim Raporu',
              message: 'Müfettiş düzenli muhasebeni tebrik etti. Galeri güvenilirlik puanın arttı.',
              isSuccess: true,
              reputationDelta: 6,
              xpReward: 60,
            ),
            DramaticOutcomeModel(
              probability: 0.1,
              title: 'Ufak Evrak Harcı',
              message: 'Eski bir noter dekontundaki eksik pul için ₺1.200 idari harç kesildi.',
              isSuccess: false,
              moneyDelta: -1200.0,
              reputationDelta: 2,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'general_celebrity_offer',
      category: DramaticCategory.comedy,
      severity: DramaticSeverity.low,
      title: 'Dizi Oyuncusunun Ziyareti',
      characterName: 'Oyuncu Kaan',
      characterRole: 'Televizyon Yıldızı',
      characterAvatar: 'suit',
      icon: Icons.movie_filter_rounded,
      dialogue: 'Merhaba! Yeni dizimizin set sahneleri için gösterişli bir araca ihtiyacımız var. Galerinden araç kiralarsak sosyal medyada dükkanını etiketlerim.',
      foreshadowHint: 'Ünlü etkileşimi galerine prestij ve yüksek takipçi kazandırır.',
      choices: [
        DramaticChoiceModel(
          id: 'sponsor_actor',
          label: 'İndirimli Tahsis Et • Etiket Al',
          shortDescription: 'Dizi ekibine kolaylık sağla ve geniş kitlelere adını duyur',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Sosyal Medyada Patlama',
              message: 'Kaan hikayesinde galerini paylaştı! Yüzlerce yeni potansiyel alıcı dükkanı kaydetti.',
              isSuccess: true,
              reputationDelta: 8,
              xpReward: 90,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 5. HIGH CAPITAL & WEALTH POOL (Balance >= ₺500,000)
  static final List<DramaticCardModel> highCapitalCards = [
    DramaticCardModel(
      id: 'high_capital_tax_audit',
      category: DramaticCategory.loss,
      severity: DramaticSeverity.high,
      title: 'Maliye ve Vergi Denetimi',
      characterName: 'Müfettiş Cengiz',
      characterRole: 'Maliye Başmüfettişi',
      characterAvatar: 'suit',
      icon: Icons.fact_check_rounded,
      dialogue: 'Kolay gelsin patron. Şirket hesaplarındaki yüksek nakit hacmi dikkat çekti. Defterleri, faturaları ve noter beyanlarını incelememiz gerekiyor.',
      foreshadowHint: 'Şeffaf vergi beyanı yüksek itibar kazandırır, masraf göstermek ise nakit tasarrufu sağlar.',
      choices: [
        DramaticChoiceModel(
          id: 'audit_transparent',
          label: 'Şeffaf Beyan Ver • Vergi Levhasını Parlat',
          shortDescription: '₺35.000 yasal harç ve fark ödeyerek temiz sicil ve itibar kazan',
          upfrontCost: 35000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Altın Vergi Levhası',
              message: 'Müfettiş teftişi övgüyle kapattı. Sanayide güvenilirliğin tescillendi.',
              isSuccess: true,
              reputationDelta: 8,
              xpReward: 120,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'audit_lawyer',
          label: 'Muhasebeciye Pasla • Masrafı Düş',
          shortDescription: 'Masrafları ve amortismanları göstererek vergiyi sıfırla',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 0.7,
              title: 'Masraflar Kabul Edildi',
              message: 'Muhasebeci tüm giderleri amortismana saydırdı. Cepten tek kuruş çıkmadı.',
              isSuccess: true,
              reputationDelta: 2,
              xpReward: 50,
            ),
            DramaticOutcomeModel(
              probability: 0.3,
              title: 'Gecikme Cezası Kesildi',
              message: 'Müfettiş gider makbuzlarının bir kısmını reddetti ve ₺45.000 ceza yazdı.',
              isSuccess: false,
              moneyDelta: -45000.0,
              reputationDelta: -3,
              xpReward: 25,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'high_capital_secret_auction',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.medium,
      title: 'Gizli Koleksiyon Müzayedesi',
      characterName: 'Komisyoncu Vedat',
      characterRole: 'Özel Müzayede Aracısı',
      characterAvatar: 'detective',
      icon: Icons.gavel_rounded,
      dialogue: 'Patron, elindeki sıcak parayı değerlendirecek nadir bir fırsat var. Borcundan dolayı haczedilen garaj arabası kelepir fiyata gizli ihalede satılacak.',
      foreshadowHint: 'Büyük sermaye büyük fırsatlar doğurur.',
      choices: [
        DramaticChoiceModel(
          id: 'auction_bid',
          label: 'İhaleye Gir • Teminat Yatır',
          shortDescription: '₺50.000 teminat vererek kelepir fırsatı değerlendir',
          upfrontCost: 50000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Kelepir İhale Kazanıldı',
              message: 'İhaledeki aracı piyasa fiyatının çok altına kapattın ve hızlıca devrettin.',
              isSuccess: true,
              moneyDelta: 85000.0,
              reputationDelta: 4,
              xpReward: 90,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'auction_pass',
          label: 'Riski Alma • Pas Geç',
          shortDescription: 'Nakit gücünü koru, maceraya girme',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Temkinli Tüccar',
              message: 'İhaleye girmedin, elindeki nakitle fırsat kollamaya devam ettin.',
              isSuccess: true,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 6. DAMAGED & MUDDY FLEET POOL (2+ damaged or unwashed cars)
  static final List<DramaticCardModel> damagedFleetCards = [
    DramaticCardModel(
      id: 'damaged_fleet_taxi_buyout',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.medium,
      title: 'Taksici Kooperatifi Toptan Alım',
      characterName: 'Başkan Rıza',
      characterRole: 'Taksi Kooperatifi Başkanı',
      characterAvatar: 'mustache',
      icon: Icons.local_taxi_rounded,
      dialogue: 'Selamın aleyküm galericim. Duraktaki şoförlere sarı taksiye çevirmelik araç lazım. Garajındaki masraflı ve tamir bekleyen arabaları biliyoruz, toptan alalım.',
      foreshadowHint: 'Masraflı filoyu tek kalemde eritip nakde dönme fırsatı.',
      choices: [
        DramaticChoiceModel(
          id: 'taxi_bulk_sell',
          label: 'Toplu Satış Teklifini Onayla',
          shortDescription: 'Masraflı araçları elden çıkarıp kasaya anında dinamik nakit sağla',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Toptan Satış Başarılı',
              message: 'Kooperatif araçları çekiciyle aldı, kasana toplu para girdi.',
              isSuccess: true,
              isDynamicGrant: true,
              reputationDelta: 3,
              xpReward: 80,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'taxi_bulk_reject',
          label: 'Kendin Topla • Teklifi Geri Çevir',
          shortDescription: 'Araçları atölyende tek tek restore edip perakende sat',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Perakende Israrı',
              message: 'Taksiciler başka kapıya yöneldi. Araçları kendin toplayacaksın.',
              isSuccess: true,
              reputationDelta: 2,
              xpReward: 30,
            ),
          ],
        ),
      ],
    ),
    DramaticCardModel(
      id: 'damaged_fleet_scrap_master',
      category: DramaticCategory.opportunity,
      severity: DramaticSeverity.low,
      title: 'Çıkmacı İrfan Usta',
      characterName: 'İrfan Usta',
      characterRole: 'Yedek Parça ve Çıkma Ustası',
      characterAvatar: 'mechanic',
      icon: Icons.build_circle_rounded,
      dialogue: 'Ustam garajındaki arabaların kaportası ve yürürü ilgi istiyor. Çıkma parça deposunu yeni boşalttım, cüzi bir fiyata hepsine elden geçireyim.',
      foreshadowHint: 'Çıkma parçalarla filo kondisyonunu ucuza toparlama fırsatı.',
      choices: [
        DramaticChoiceModel(
          id: 'master_bulk_repair',
          label: 'Toplu Revizyon Yaptır',
          shortDescription: '₺12.000 harcayarak filondaki araçların kondisyonunu toparla',
          upfrontCost: 12000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Filo Sıfırlandı',
              message: 'İrfan Usta tüm araçları revizyondan geçirdi. Arabalar vitrinde alıcı beklemeye hazır.',
              isSuccess: true,
              reputationDelta: 5,
              xpReward: 90,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'master_repair_skip',
          label: 'Şimdilik Beklet',
          shortDescription: 'Tamirat bütçesini ertele',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Tamirat Ertelendi',
              message: 'Masraflar sonraki haftaya kaldı.',
              isSuccess: true,
              xpReward: 15,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 7. VIP REPUTATION POOL (Reputation >= 70)
  static final List<DramaticCardModel> vipReputationCards = [
    DramaticCardModel(
      id: 'vip_celebrity_deal',
      category: DramaticCategory.legacy,
      severity: DramaticSeverity.medium,
      title: 'Ünlü Dizi Yıldızı Ziyareti',
      characterName: 'Dizi Yıldızı Kenan',
      characterRole: 'Televizyon ve Sinema Oyuncusu',
      characterAvatar: 'suit',
      icon: Icons.star_rounded,
      dialogue: 'İyi günler! Bölgenin en güvenilir ve prestijli galerisi olduğunuzu duydum. Yeni projem için vitrininizdeki lüks aracı almak istiyorum. Bana özel bir esnaf indirimi yaparsanız, teslimat fotoğrafını milyonluk hesabımda paylaşırım.',
      foreshadowHint: 'Ünlü prestiji galerinin itibarını ve müşteri çekimini uçurur.',
      choices: [
        DramaticChoiceModel(
          id: 'celebrity_vip_discount',
          label: 'VIP İndirimi Yap • Sosyal Medyada Parla',
          shortDescription: '₺20.000 jest indirimi yap, viral tanıtım ve prestij kazan',
          upfrontCost: 20000.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Viral Şöhret Patlaması',
              message: 'Kenan anahtar teslim fotoğrafını paylaştı! Galeri telefonları kilitlendi, müşteri trafiği katlandı.',
              isSuccess: true,
              reputationDelta: 12,
              xpReward: 150,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'celebrity_firm_price',
          label: 'Fiyattan Taviz Verme • Net Kârı Al',
          shortDescription: 'Ticaret ticarettir, liste fiyatından aşağı inme',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Tavizsiz Ticaret',
              message: 'Kenan pazarlık yapamasa da aracı beğendi ve nakit ödeyerek satın aldı.',
              isSuccess: true,
              moneyDelta: 15000.0,
              reputationDelta: 1,
              xpReward: 50,
            ),
          ],
        ),
      ],
    ),
  ];

  /// 8. POST-SALE DISPUTE POOL (Sales history is not empty)
  static final List<DramaticCardModel> postSaleDisputeCards = [
    DramaticCardModel(
      id: 'post_sale_customer_dispute',
      category: DramaticCategory.conscience,
      severity: DramaticSeverity.medium,
      title: 'Kapıya Dayanan Huysuz Alıcı',
      characterName: 'Müşteri Tahsin',
      characterRole: 'Eski Müşteri',
      characterAvatar: 'glasses',
      icon: Icons.warning_amber_rounded,
      dialogue: 'Usta! Geçen hafta aldığım arabanın şanzımanından üçüncü viteste ses geliyor. Noterden çıkana kadar melek gibiydiniz, şimdi ne olacak?',
      foreshadowHint: 'Esnaflık sadece satarken değil, sattıktan sonra da arkasında durmaktır.',
      choices: [
        DramaticChoiceModel(
          id: 'dispute_repair_cover',
          label: 'Masrafı Üstlen • Esnaf Şanını Koru',
          shortDescription: '₺4.500 usta ücretini vererek arızayı gider ve müşteriyi memnun uğurla',
          upfrontCost: 4500.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Esnaflık Dersi',
              message: 'Tahsin Abi memnun ayrıldı, sanayide arkandan dürüst esnaf diye bahsediyor.',
              isSuccess: true,
              reputationDelta: 6,
              xpReward: 70,
            ),
          ],
        ),
        DramaticChoiceModel(
          id: 'dispute_notary_contract',
          label: 'Noter Sözleşmesini Göster',
          shortDescription: 'Gördün de aldın, ekspertiz raporu ortada diyerek sorumluluk alma',
          upfrontCost: 0.0,
          outcomes: [
            DramaticOutcomeModel(
              probability: 1.0,
              title: 'Soğuk Vedalaşma',
              message: 'Müşteri homurdanarak gitti. Cebinden para çıkmadı ama kapıda tatsızlık yaşandı.',
              isSuccess: true,
              reputationDelta: -3,
              xpReward: 20,
            ),
          ],
        ),
      ],
    ),
  ];

  /// Evaluates dealership operational metrics and returns a dilemma card ONLY if a
  /// genuine critical event, crisis, or state milestone is triggered.
  /// Returns null if operations are normal, avoiding disruptive daily interruptions.
  static DramaticCardModel? selectCriticalCard(
    DealershipModel state, {
    List<String> seenIds = const [],
  }) {
    // 1. Cash Crisis: Player is broke or in debt (balance < ₺25,000)
    if (state.balance < 25000.0) {
      final available = cashCrisisCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
      return cashCrisisCards.first;
    }

    // 2. Rookie Onboarding: First 3 days AND Level <= 2
    if (state.level <= 2 && state.currentDay <= 3) {
      final available = rookieCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // 3. Damaged / Muddy Fleet Crisis: 2+ neglected or damaged cars in garage
    final damagedCount = state.ownedCars.where((c) =>
      c.expertise.engineCondition < 70.0 ||
      c.expertise.transmissionCondition < 70.0 ||
      !c.isWashed ||
      c.hasMuddyPenalty
    ).length;
    if (damagedCount >= 2) {
      final available = damagedFleetCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // 4. Post-Sale Dispute: Has sales history and periodic dispute event
    if (state.salesHistory.isNotEmpty && (state.currentDay % 5 == 0)) {
      final available = postSaleDisputeCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // 5. High Capital & Wealth: balance >= ₺500,000 on periodic cycle
    if (state.balance >= 500000.0 && (state.currentDay % 4 == 0)) {
      final available = highCapitalCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // 6. VIP Reputation: reputationScore >= 120 on periodic cycle
    if (state.reputationScore >= 120 && (state.currentDay % 4 == 2)) {
      final available = vipReputationCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // Operations are normal: return null so no card interrupts the player
    return null;
  }

  /// Dynamically resolves the most appropriate dilemma card based on player context.
  static DramaticCardModel selectContextualCard(
    DealershipModel state, {
    List<String> seenIds = const [],
  }) {
    // 1. Cash Crisis Priority: Player is broke or in debt (balance < ₺25,000)
    if (state.balance < 25000.0) {
      final available = cashCrisisCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
      return cashCrisisCards.first;
    }

    // 2. Rookie Onboarding Priority: First 5 days AND Level <= 2
    if (state.level <= 2 && state.currentDay <= 5) {
      final available = rookieCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // 3. High Capital & Wealth (balance >= ₺500,000)
    if (state.balance >= 500000.0) {
      final available = highCapitalCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty && (state.currentDay % 2 == 0)) {
        return available.first;
      }
    }

    // 4. Damaged / Muddy Fleet (2+ damaged or unwashed cars in garage)
    final damagedCount = state.ownedCars.where((c) =>
      c.expertise.engineCondition < 70.0 ||
      c.expertise.transmissionCondition < 70.0 ||
      !c.isWashed ||
      c.hasMuddyPenalty
    ).length;
    if (damagedCount >= 2) {
      final available = damagedFleetCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty && (state.currentDay % 2 == 1)) {
        return available.first;
      }
    }

    // 5. Post-Sale Dispute (has sales history)
    if (state.salesHistory.isNotEmpty && (state.currentDay % 4 == 0)) {
      final available = postSaleDisputeCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty) {
        return available.first;
      }
    }

    // 6. Idle Inventory Priority: If player has cars in garage that need sales attention
    if (state.ownedCars.isNotEmpty) {
      final available = idleInventoryCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty && (state.currentDay % 3 == 0)) {
        return available.first;
      }
    }

    // 7. VIP Reputation (reputationScore >= 120)
    if (state.reputationScore >= 120) {
      final available = vipReputationCards.where((c) => !seenIds.contains(c.id)).toList();
      if (available.isNotEmpty && (state.currentDay % 3 == 0)) {
        return available.first;
      }
    }

    // 8. General / Flourishing Pool
    final generalAvailable = generalCards.where((c) => !seenIds.contains(c.id)).toList();
    if (generalAvailable.isNotEmpty) {
      return generalAvailable.first;
    }

    // Fallback: Cycle through all pools gracefully
    final allCards = [
      ...cashCrisisCards,
      ...highCapitalCards,
      ...damagedFleetCards,
      ...vipReputationCards,
      ...postSaleDisputeCards,
      ...rookieCards,
      ...idleInventoryCards,
      ...generalCards,
    ];
    final index = (state.currentDay - 1) % allCards.length;
    return allCards[index];
  }
}
