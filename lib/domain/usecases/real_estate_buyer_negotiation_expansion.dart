import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/real_estate_category.dart';
import 'real_estate_chat_negotiation_engine.dart';

enum BuyerArchetypeId {
  fundDirector, // Yatırım Fonu Direktörü / Kurumsal Portföy
  industrialist, // Sanayici & Büyük Yatırımcı
  familyBuyer, // Aile / Doktor / Memur / Yuva Arayan
  merchantTrader, // Esnaf & Ticaret Erbabı
  expatInvestor, // Gurbetçi & Döviz Yatırımcısı
  opportunist, // Fırsatçı & Tok Alıcı
}

class BuyerArchetype {
  final BuyerArchetypeId id;
  final String titleKey;
  final String defaultTitle;
  final String subtitleKey;
  final String defaultSubtitle;
  final IconData avatarIcon;
  final Color themeColor;

  const BuyerArchetype({
    required this.id,
    required this.titleKey,
    required this.defaultTitle,
    required this.subtitleKey,
    required this.defaultSubtitle,
    required this.avatarIcon,
    required this.themeColor,
  });
}

class TacticStepDefinition {
  final String labelKey;
  final String messageKey;
  final int patienceCost;

  const TacticStepDefinition({
    required this.labelKey,
    required this.messageKey,
    required this.patienceCost,
  });
}

class RealEstateBuyerNegotiationExpansion {
  static const Map<BuyerArchetypeId, BuyerArchetype> archetypes = {
    BuyerArchetypeId.fundDirector: BuyerArchetype(
      id: BuyerArchetypeId.fundDirector,
      titleKey: 'buyer_archetype_fund_title',
      defaultTitle: 'Yatırım Fonu Direktörü',
      subtitleKey: 'buyer_archetype_fund_sub',
      defaultSubtitle: 'Kurumsal Fon • SPK Değerleme & Tabela Değeri',
      avatarIcon: Icons.corporate_fare_rounded,
      themeColor: Color(0xFF3B82F6),
    ),
    BuyerArchetypeId.industrialist: BuyerArchetype(
      id: BuyerArchetypeId.industrialist,
      titleKey: 'buyer_archetype_industrialist_title',
      defaultTitle: 'Sanayici & Büyük Yatırımcı',
      subtitleKey: 'buyer_archetype_industrialist_sub',
      defaultSubtitle: 'Holding Finansmanı • Noterde Peşin Devir',
      avatarIcon: Icons.factory_rounded,
      themeColor: Color(0xFFF59E0B),
    ),
    BuyerArchetypeId.familyBuyer: BuyerArchetype(
      id: BuyerArchetypeId.familyBuyer,
      titleKey: 'buyer_archetype_family_title',
      defaultTitle: 'Çekirdek Aile & Yuva Arayan',
      subtitleKey: 'buyer_archetype_family_sub',
      defaultSubtitle: 'Konut Kredisi & Huzurlu Muhit Talebi',
      avatarIcon: Icons.family_restroom_rounded,
      themeColor: Color(0xFF10B981),
    ),
    BuyerArchetypeId.merchantTrader: BuyerArchetype(
      id: BuyerArchetypeId.merchantTrader,
      titleKey: 'buyer_archetype_merchant_title',
      defaultTitle: 'Bölge Esnafı & Tüccar',
      subtitleKey: 'buyer_archetype_merchant_sub',
      defaultSubtitle: 'Sıcak Para • Ciro & Yüksek Ayakbastı',
      avatarIcon: Icons.storefront_rounded,
      themeColor: Color(0xFF8B5CF6),
    ),
    BuyerArchetypeId.expatInvestor: BuyerArchetype(
      id: BuyerArchetypeId.expatInvestor,
      titleKey: 'buyer_archetype_expat_title',
      defaultTitle: 'Gurbetçi & Döviz Yatırımcısı',
      subtitleKey: 'buyer_archetype_expat_sub',
      defaultSubtitle: 'Euro Likiditesi • Yüksek Kira Getirisi & Prim',
      avatarIcon: Icons.flight_takeoff_rounded,
      themeColor: Color(0xFF06B6D4),
    ),
    BuyerArchetypeId.opportunist: BuyerArchetype(
      id: BuyerArchetypeId.opportunist,
      titleKey: 'buyer_archetype_opportunist_title',
      defaultTitle: 'Serbest Portföy Avcısı',
      subtitleKey: 'buyer_archetype_opportunist_sub',
      defaultSubtitle: 'Mevduat & Nakit Gücü • Sert Fiyat Pazarlığı',
      avatarIcon: Icons.trending_down_rounded,
      themeColor: Color(0xFFEF4444),
    ),
  };

  /// Alıcı unvanı ve mülk kategorisinden alıcı profilini tespit eder
  static BuyerArchetype detectBuyerArchetype(
    String buyerName,
    RealEstateCategory category,
  ) {
    final lower = buyerName.toLowerCase();
    if (lower.contains('yatırım fonu') ||
        lower.contains('direktör') ||
        lower.contains('bora')) {
      return archetypes[BuyerArchetypeId.fundDirector]!;
    }
    if (lower.contains('sanayici') ||
        lower.contains('holding') ||
        lower.contains('teoman')) {
      return archetypes[BuyerArchetypeId.industrialist]!;
    }
    if (lower.contains('gurbet') ||
        lower.contains('kerem') ||
        lower.contains('döviz')) {
      return archetypes[BuyerArchetypeId.expatInvestor]!;
    }
    if (lower.contains('esnaf') ||
        lower.contains('ticaret')) {
      return archetypes[BuyerArchetypeId.merchantTrader]!;
    }
    if (lower.contains('doktor') ||
        lower.contains('öğretmen') ||
        lower.contains('aile')) {
      return archetypes[BuyerArchetypeId.familyBuyer]!;
    }
    if (category == RealEstateCategory.building) {
      return archetypes[BuyerArchetypeId.fundDirector]!;
    }
    if (category == RealEstateCategory.commercial) {
      return archetypes[BuyerArchetypeId.merchantTrader]!;
    }
    if (category == RealEstateCategory.housing) {
      return archetypes[BuyerArchetypeId.familyBuyer]!;
    }
    return archetypes[BuyerArchetypeId.opportunist]!;
  }

  /// Taktik adımları havuzu: Her taktik tıklandıkça sıradaki basamağa geçer
  static const Map<ChatTacticType, List<TacticStepDefinition>> tacticSteps = {
    ChatTacticType.counterPrice: [
      TacticStepDefinition(
        labelKey: 'buyer_tactic_counter_label_0',
        messageKey: 'buyer_tactic_counter_msg_0',
        patienceCost: 20,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_counter_label_1',
        messageKey: 'buyer_tactic_counter_msg_1',
        patienceCost: 20,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_counter_label_2',
        messageKey: 'buyer_tactic_counter_msg_2',
        patienceCost: 25,
      ),
    ],
    ChatTacticType.transferDeedCosts: [
      TacticStepDefinition(
        labelKey: 'buyer_tactic_deed_cost_label_0',
        messageKey: 'buyer_tactic_deed_cost_msg_0',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_deed_cost_label_1',
        messageKey: 'buyer_tactic_deed_cost_msg_1',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_deed_cost_label_2',
        messageKey: 'buyer_tactic_deed_cost_msg_2',
        patienceCost: 20,
      ),
    ],
    ChatTacticType.demandCashDiscount: [
      TacticStepDefinition(
        labelKey: 'buyer_tactic_cash_block_label_0',
        messageKey: 'buyer_tactic_cash_block_msg_0',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_cash_block_label_1',
        messageKey: 'buyer_tactic_cash_block_msg_1',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_cash_block_label_2',
        messageKey: 'buyer_tactic_cash_block_msg_2',
        patienceCost: 20,
      ),
    ],
    ChatTacticType.demandPrimeFloors: [
      TacticStepDefinition(
        labelKey: 'buyer_tactic_location_label_0',
        messageKey: 'buyer_tactic_location_msg_0',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_location_label_1',
        messageKey: 'buyer_tactic_location_msg_1',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_location_label_2',
        messageKey: 'buyer_tactic_location_msg_2',
        patienceCost: 15,
      ),
    ],
    ChatTacticType.demandQualityUpgrade: [
      TacticStepDefinition(
        labelKey: 'buyer_tactic_fixture_label_0',
        messageKey: 'buyer_tactic_fixture_msg_0',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_fixture_label_1',
        messageKey: 'buyer_tactic_fixture_msg_1',
        patienceCost: 15,
      ),
      TacticStepDefinition(
        labelKey: 'buyer_tactic_fixture_label_2',
        messageKey: 'buyer_tactic_fixture_msg_2',
        patienceCost: 20,
      ),
    ],
  };

  /// Belirli bir taktiğin sıradaki adımını verir
  static TacticStepDefinition getTacticStep(ChatTacticType tactic, int useCount) {
    final steps = tacticSteps[tactic] ?? [];
    if (steps.isEmpty) {
      return const TacticStepDefinition(
        labelKey: 'buyer_tactic_counter_label_0',
        messageKey: 'buyer_tactic_counter_msg_0',
        patienceCost: 20,
      );
    }
    return steps[useCount % steps.length];
  }

  /// Taktiğin tükenip tükenmediğini kontrol eder
  static bool isTacticExhausted(ChatTacticType tactic, int useCount) {
    if (tactic == ChatTacticType.askJokeOrChat) {
      return useCount >= 2;
    }
    final steps = tacticSteps[tactic];
    if (steps == null) return false;
    return useCount >= steps.length;
  }

  /// Alıcı yanıtını ve rozetini oluşturur
  static ({String replyText, String? replyBadge, double nextPrice, int satisfactionDelta, int patienceDelta, bool isAgreed, bool isWalkedAway})
      evaluateBuyerTactic({
    required ChatNegotiationState state,
    required ChatTacticType tactic,
    required BuyerArchetype archetype,
    required Random random,
  }) {
    double nextPrice = state.currentPrice;
    int nextSatisfactionDelta = 0;
    int nextPatienceDelta = 0;
    bool nextAgreed = false;
    bool nextWalkedAway = false;
    String replyText = '';
    String? replyBadge;

    switch (tactic) {
      case ChatTacticType.counterPrice:
        nextPatienceDelta = -20;
        final successChance = 0.65;
        if (random.nextDouble() < successChance) {
          nextPrice = (state.currentPrice * 1.05).roundToDouble();
          nextSatisfactionDelta = 12;
          final formatted = CurrencyFormatter.format(nextPrice);
          replyBadge = 'YENİ TEKLİF • $formatted';

          final Map<BuyerArchetypeId, List<String>> successPools = {
            BuyerArchetypeId.fundDirector: [
              'Yatırım komitemizle görüştük • Tabela değeri ve lokasyon primini dikkate alarak teklifimizi $formatted olarak güncelliyoruz.',
              'SPK lisanslı değerleme raporumuzu revize ettik • Fonumuzun tavan limiti dahilinde teklifimizi $formatted seviyesine çıkardık.',
              'Yönetim kurulu onayımızı aldık • Kurumsal portföy büyüme stratejimize uygun olarak $formatted rakamını onayladık.',
            ],
            BuyerArchetypeId.industrialist: [
              'Rakamı yönetimde revize ettik • Prestijli mülkünüz için yeni teklifimiz $formatted olmuştur.',
              'Holding finansman direktörlüğüyle görüştük • Fabrika ve lojistik hedeflerimiz için $formatted teklifini sunduk.',
              'Şirket büyüme hedeflerimiz doğrultusunda bütçemizi esnettik • Noterde devir için $formatted olarak el sıkışabiliriz.',
            ],
            BuyerArchetypeId.familyBuyer: [
              'Ailece düşündük, çocuklar okulu ve muhiti çok sevdi • Bütçemizi zorlayıp $formatted vermeyi kabul ediyoruz.',
              'Eşimin ve ailemizin ortak kararıyla birikimlerimizi bir araya getirdik • Teklifimizi $formatted seviyesine yükseltiyoruz.',
              'Ev sahibiyle uzlaşmak için konut kredi limitimizi artırdık • Son teklifimiz $formatted olmuştur.',
            ],
            BuyerArchetypeId.merchantTrader: [
              'Pazarlığın hakkını verdin • Mülkün ciro potansiyeline güvenip teklifimizi $formatted seviyesine çıkardık.',
              'Bölge esnafıyla istişare ettik • Mülkün yaya trafiğine güvenerek teklifimizi $formatted yaptık.',
              'Sıcak para gücümüzü masaya koyuyoruz • Bu ticarethane için $formatted seviyesinde el sıkışmaya varız.',
            ],
            BuyerArchetypeId.expatInvestor: [
              'Döviz birikimimizi TL ye çevirip bütçeyi artırdık • Yeni teklifimiz $formatted olarak güncellendi.',
              'Yıllık kira getiri projeksiyonunu beğendik • Gurbet birikimimizle $formatted vermeye hazırız.',
              'Yurt dışındaki finans danışmanımla teyitleştik • Bu değerli mülk için $formatted teklif ediyoruz.',
            ],
            BuyerArchetypeId.opportunist: [
              'Önerdiğiniz rakamı değerlendirdik • Yeni fiyat $formatted olarak el sıkışabiliriz.',
              'Piyasa koşullarını tekrar analiz ettik • Teklifimizi $formatted seviyesine revize ediyoruz.',
              'Bütçe marjlarımızı sonuna kadar kullandık • $formatted üzerinden anlaşmaya varız.',
            ],
          };

          final pool = successPools[archetype.id] ?? successPools[BuyerArchetypeId.opportunist]!;
          replyText = pool[random.nextInt(pool.length)];
        } else {
          final Map<BuyerArchetypeId, List<String>> rejectPools = {
            BuyerArchetypeId.fundDirector: [
              'Bu rakam fonumuzun iç verim oranı ve bütçe tavanını aşıyor • Fiyatı daha fazla esnetemeyiz.',
              'Komite kararı kesindir • Hedef kârlılık oranımız bu fiyat seviyesinde karşılanmıyor.',
              'Değerleme uzmanımızın biçtiği tavan aşıldı • Bu fiyatla kurumsal alım yapamayız.',
            ],
            BuyerArchetypeId.industrialist: [
              'Yatırım bütçemizin tavanına ulaştık • Holding ilkeleri gereği bu rakamı kabul edemeyiz.',
              'Mali işler direktörümüz bu fiyata onay vermedi • Teklifimizi daha fazla artıramayız.',
              'Tesis fizibilitesi bu maliyetle kurtarmıyor • Fiyatı daha fazla esnetmemiz imkansız.',
            ],
            BuyerArchetypeId.familyBuyer: [
              'Kredi limitimiz ve birikimimiz maalesef bu rakama yetmiyor • Mevcut teklifimizin üzerine çıkamayız.',
              'Banka eksperi mülke bu kadar kredi çıkartmıyor • Bütçemizi daha fazla zorlayamayız.',
              'Aylık kredi taksit ödemelerimiz sınırda • Maalesef bu fiyatın üzerine çıkmamız imkansız.',
            ],
            BuyerArchetypeId.merchantTrader: [
              'Bu fiyata girersek dükkanın amortismanı 20 yılı bulur • Ticaretimizi kilitleyemeyiz.',
              'Esnaf hesabına uymaz • Bu maliyetle işletme açıp kâr etmek hayal olur.',
              'Sermayemizi tek bir mülke bağlayamayız • Bu rakam bizim ticaret mantığımıza ters.',
            ],
            BuyerArchetypeId.expatInvestor: [
              'Döviz kuru ve kira çarpanı bu seviyede cazibesini yitiriyor • Daha fazla çıkamayız.',
              'Avrupa daki emlak getirileriyle kıyasladığımızda bu fiyat mantıklı gelmiyor.',
              'Bütçemin son sınırına kadar söyledim • Üzerine bir kuruş daha koyamam.',
            ],
            BuyerArchetypeId.opportunist: [
              'Bu rakam bizim fizibilitenin çok üzerinde kalıyor • Fiyatı esnetemeyiz.',
              'Piyasa rayicinin çok üzerine çıkamam • Teklifim son fiyattır.',
              'Mevcut teklifim geçerlidir • Üzerine çıkmamız mümkün görünmüyor.',
            ],
          };

          final pool = rejectPools[archetype.id] ?? rejectPools[BuyerArchetypeId.opportunist]!;
          replyText = pool[random.nextInt(pool.length)];
        }
        break;

      case ChatTacticType.transferDeedCosts:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.65) {
          nextSatisfactionDelta = 10;
          replyBadge = 'TAPU HARCI KARŞI TARAFTA';
          final Map<BuyerArchetypeId, List<String>> deedSuccessPools = {
            BuyerArchetypeId.fundDirector: [
              'Kurumsal bütçemizde tapu masrafı karşılığı mevcut • Tapu harcı ve döner sermayeyi tamamen üstleniyoruz.',
              'Yatırım fonumuz alım harçlarını gider yazabiliyor • Masrafların tamamını karşılamayı kabul ettik.',
            ],
            BuyerArchetypeId.merchantTrader: [
              'Tamamdır • Yeter ki tapuyu yarın alalım, resmi harçların tamamı bizim kasamızdan çıksın.',
              'Sözümüz senettir • Tapu dairesindeki döner sermaye dahil tüm harçları biz ödüyoruz.',
            ],
            BuyerArchetypeId.industrialist: [
              'Holding muhasebemiz tapu harçlarını üstlenmeye onay verdi • Masraflar tamamen bize aittir.',
              'Hızlı devir şartıyla tüm tapu ve döner sermaye giderlerini şirketimiz karşılıyor.',
            ],
            BuyerArchetypeId.familyBuyer: [
              'Kredi dosyamızda tapu masrafı kredisini de onaylattık • Harçların tamamını üstleniyoruz.',
              'Mülkü çok beğendik • Tapu masraflarının tamamını karşılayarak devir işlemlerini hızlandıralım.',
            ],
            BuyerArchetypeId.expatInvestor: [
              'Euro likiditemizden tapu harçlarını karşılayabiliriz • Masrafların tümünü üstlenmeyi kabul ediyoruz.',
              'Gurbetçi bütçemizden tapu ve belediye harçlarını eksiksiz karşılayacağız.',
            ],
            BuyerArchetypeId.opportunist: [
              'Tamamdır • Tapu harcı ve döner sermaye masraflarının tamamını biz üstleniyoruz.',
              'Pazarlığı tatlıya bağlamak adına resmi harçların hepsini faturamıza yazdıracağız.',
            ],
          };

          final pool = deedSuccessPools[archetype.id] ?? deedSuccessPools[BuyerArchetypeId.opportunist]!;
          replyText = pool[random.nextInt(pool.length)];
        } else {
          final deedRejectPool = [
            'Teamül gereği tapu masrafı yarı yarıya ödenmelidir • Tamamını üstlenemeyiz.',
            'Yasal olarak alıcı ve satıcı eşit paydaş olmalıdır • Resmi harçları tek taraflı ödemeyiz.',
            'Bütçemizde ekstra tapu kalemi açılmamış • Masrafların yarısını sizin karşılamanız gerekir.',
          ];
          replyText = deedRejectPool[random.nextInt(deedRejectPool.length)];
        }
        break;

      case ChatTacticType.demandCashDiscount:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.70) {
          nextSatisfactionDelta = 15;
          replyBadge = 'HIZLI DEVİR & BLOKAJ KABUL';
          final Map<BuyerArchetypeId, List<String>> cashSuccessPools = {
            BuyerArchetypeId.industrialist: [
              'Nakit gücümüz tamdır • Yarın sabah 10:00 da Tapu Takas bloke dekontuyla hazır olacağız.',
              'Holding kasasından nakit transferi hazırlandı • Yarın sabah ilk randevuda blokajı koyuyoruz.',
            ],
            BuyerArchetypeId.expatInvestor: [
              'Euro mevduatımız hazır • Bankadan bloke çeki anında çıkarıp yarın tapuda buluşuyoruz.',
              'Döviz hesabımızdan nakdi çektik • Yarın noterde veya tapuda hazır bloke hesapla bekliyoruz.',
            ],
            BuyerArchetypeId.fundDirector: [
              'Fon likiditemiz anlık takasa uygundur • Takasbank aracılığıyla nakit transferi hemen teyit edilir.',
              'Kurumsal hesabımızdan blokeli devir işlemi için talimat verildi • Yarın devir tamamlanabilir.',
            ],
            BuyerArchetypeId.merchantTrader: [
              'Esnafın parası kasada beklemez • Yarın sabah banka blokajıyla tapu dairesindeyiz.',
              'Çantada sıcak nakit ve bloke çekiyle hazırız • İşi yarın bitirelim.',
            ],
            BuyerArchetypeId.familyBuyer: [
              'Birikimimizi hazır tuttuk • Yarın sabah banka garantili blokajla tapu devrine geliyoruz.',
              'Konut kredisini onaylattık • Nakit peşinat kısmını bloke ettirip yarın imzaya hazırız.',
            ],
            BuyerArchetypeId.opportunist: [
              'Likiditemiz hazır • Banka bloke çekiyle yarın sabah tapu devrini tamamlamayı kabul ediyoruz.',
              'Anında nakit garantisi veriyoruz • Yarın sabah tapu müdürlüğünde buluşabiliriz.',
            ],
          };

          final pool = cashSuccessPools[archetype.id] ?? cashSuccessPools[BuyerArchetypeId.opportunist]!;
          replyText = pool[random.nextInt(pool.length)];
        } else {
          final cashRejectPool = [
            'Finansman paketimiz banka konut kredisine bağlı • Hemen yarın nakit blokaj garantisi veremeyiz.',
            'Mevduatımızın vadesi haftaya doluyor • Yarın sabah anında nakit blokaj sağlayamayız.',
            'Para transferi için fon komitesinden ek gün talep etmemiz gerekiyor • Hemen devir yapamayız.',
          ];
          replyText = cashRejectPool[random.nextInt(cashRejectPool.length)];
        }
        break;

      case ChatTacticType.demandPrimeFloors:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.70) {
          nextSatisfactionDelta = 15;
          replyBadge = 'ŞEREFİYE DEĞERİ TEYİT EDİLDİ';
          final Map<BuyerArchetypeId, List<String>> primeSuccessPools = {
            BuyerArchetypeId.fundDirector: [
              'Lokasyon analiz raporumuz tabela değerini ve yaya aksını doğruluyor • Bu şerefiyenin bedelini ödemeye değer.',
              'Kurumsal değerleme uzmanımız cephe primini teyit etti • Lokasyon avantajı teklifimizi güçlendiriyor.',
            ],
            BuyerArchetypeId.familyBuyer: [
              'Haklısınız, sokak çok ferah ve okulun hemen yanı başında • Bu konum ailemiz için paha biçilemez.',
              'Balkonun önünün açık olması ve güneş alması harika • Ailemiz için aradığımız tam buydu.',
            ],
            BuyerArchetypeId.merchantTrader: [
              'Köşe başı olması ve tabela değeri tartışılmaz • Bu cephe için fiyatı kabul ediyoruz.',
              'Müşteri giriş aksı çok kuvvetli • Bu şerefiye farkını memnuniyetle karşılıyoruz.',
            ],
            BuyerArchetypeId.industrialist: [
              'Lojistik ve anayol bağlantısı kusursuz • Prestijli mülkünüzün şerefiye payını onaylıyoruz.',
              'Geniş otopark ve ön cephe avantajı şirketimiz için tam aranan niteliktedir.',
            ],
            BuyerArchetypeId.expatInvestor: [
              'Deniz ve şehir manzarası gerçekten birinci sınıf • Bu manzara için yatırım yapmaya değer.',
              'Bölgenin prim potansiyeli yüksek • Konum avantajını takdir ediyoruz.',
            ],
            BuyerArchetypeId.opportunist: [
              'Haklısınız • Lokasyon ve cephe avantajı gayrimenkulün değerini koruyor • Teklifimize sadık kalacağız.',
              'Şerefiye primini göz ardı etmiyoruz • Sunduğunuz konum avantajını onaylıyoruz.',
            ],
          };

          final pool = primeSuccessPools[archetype.id] ?? primeSuccessPools[BuyerArchetypeId.opportunist]!;
          replyText = pool[random.nextInt(pool.length)];
        } else {
          final primeRejectPool = [
            'Lokasyon güçlü olsa da binanın yaşı ve otopark kısıtı şerefiye avantajını dengeliyor.',
            'Ön cephe açık ama sokaktaki trafik gürültüsü şerefiye primini düşürüyor.',
            'Bölgede benzer konumda birçok alternatif var • Ekstra şerefiye farkı ödeyemeyiz.',
          ];
          replyText = primeRejectPool[random.nextInt(primeRejectPool.length)];
        }
        break;

      case ChatTacticType.demandQualityUpgrade:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.65) {
          nextSatisfactionDelta = 15;
          replyBadge = 'BOŞ & MASRAFSIZ TESLİM';
          final Map<BuyerArchetypeId, List<String>> fixtureSuccessPools = {
            BuyerArchetypeId.familyBuyer: [
              'Tadilat ustasıyla ve kiracı tahliyesiyle uğraşmayacak olmak bizim için harika • Mülkü olduğu gibi devralıyoruz.',
              'Mutfak ve banyonun yapılı olması bize aylar kazandırır • Boş teslim şartını kabul ediyoruz.',
            ],
            BuyerArchetypeId.merchantTrader: [
              'Dükkanın hazır kurulu olması bizi 2 ay masraftan ve zaman kaybından kurtarır • Bu şartı sözleşmeye yazıyoruz.',
              'Tesisatın yenilenmiş olması büyük artı • Masrafsız teslim şartınızı kabul ediyoruz.',
            ],
            BuyerArchetypeId.fundDirector: [
              'Taşınmazın hemen kiraya verilebilir durumda olması portföy getirimiz için idealdir • Kabul ediyoruz.',
              'Ekspertiz raporunda masrafsız teslim tescillendi • Bu koşulu sözleşmeye ekliyoruz.',
            ],
            BuyerArchetypeId.industrialist: [
              'Anahtar teslim ve boş vaziyette mülk devralmak şirketimiz için avantajdır • Şartı onayladık.',
              'Ekstra tadilat bütçesi ayırmak istemiyorduk • Masrafsız teslim garantisini kabul ediyoruz.',
            ],
            BuyerArchetypeId.expatInvestor: [
              'Yurt dışından tadilat yönetmek imkansız olurdu • Hazır ve masrafsız teslim edilmesi harika bir artı.',
              'Eşyalı ve temiz vaziyette teslimat şartınızı memnuniyetle kabul ediyoruz.',
            ],
            BuyerArchetypeId.opportunist: [
              'Tadilat ve tahliye stresi yaşamamak bizim için büyük avantaj • Şartlarınızı kabul ediyoruz.',
              'Masrafsız anahtar teslim koşulunu olumlu karşılıyoruz • Sözleşmeye yazalım.',
            ],
          };

          final pool = fixtureSuccessPools[archetype.id] ?? fixtureSuccessPools[BuyerArchetypeId.opportunist]!;
          replyText = pool[random.nextInt(pool.length)];
        } else {
          final fixtureRejectPool = [
            'Biz zaten mülkü kendi konseptimize göre yenileyeceğiz • Mevcut donanım bizim için katma değer taşımıyor.',
            'Kendi mimarımızla sıfırdan tadilata gireceğiz • Mevcut eklentiler teklifimizi etkilemez.',
            'Eski tadilatın bizim projelerimizde bir karşılığı yok • Ekstra prim ödemeyiz.',
          ];
          replyText = fixtureRejectPool[random.nextInt(fixtureRejectPool.length)];
        }
        break;

      case ChatTacticType.askJokeOrChat:
        nextPatienceDelta = 22;
        nextSatisfactionDelta = 15;
        final coffeePool = [
          'Gönüller bir olsun patron • Bir acı kahvenin kırk yıl hatrı var, pazarlığı tatlıya bağlayalım!',
          'Şeref verdiniz • Çaylar şirketten, sohbet sizden. Masada halledilmeyecek iş yoktur!',
          'Ağzınızın tadı bozulmasın • Esnafın sohbeti berekettir, biraz nefes alıp şartları yumuşatalım.',
          'Yüzünüz güldü ya gerisi kolay • Kahvemizi yudumlayıp orta yolu buluruz.',
        ];
        replyText = coffeePool[random.nextInt(coffeePool.length)];
        replyBadge = 'KAHVE VE SOHBET • SABIR +22';
        break;

      case ChatTacticType.acceptAgreement:
        nextAgreed = true;
        final acceptPool = [
          'Harika! Şartlarda mutabık kaldık • Sözleşmeyi hazırlatıyorum, hayırlı uğurlu olsun!',
          'El sıkıştık patron! Noter randevusunu hemen alıyoruz • İki tarafa da bol kazanç getirsin.',
          'Anlaşma sağlandı • Her iki taraf için de çok bereketli bir ticaret oldu, tebrik ederim!',
          'Hayırlı ve mübarek olsun • Şartlar kesinleşti, tapu devir işlemlerini başlatıyoruz.',
        ];
        replyText = acceptPool[random.nextInt(acceptPool.length)];
        replyBadge = 'MUTABAKAT SAĞLANDI';
        break;

      case ChatTacticType.walkAway:
        nextWalkedAway = true;
        final walkawayPool = [
          'Görüşmelerde ortak bir noktada buluşamadık • Teklifimiz iptal edilmiştir.',
          'Şartlarımız maalesef uyuşmadı • Vaktiniz için teşekkür ederiz, masadan kalkıyoruz.',
          'Ticarette nasip buraya kadarmış • Başka portföylerde görüşmek üzere, iyi günler dileriz.',
          'Beklentilerimiz arasında çok uçurum var • Görüşmeyi sonlandırıyoruz.',
        ];
        replyText = walkawayPool[random.nextInt(walkawayPool.length)];
        replyBadge = 'PAZARLIK BİTTİ';
        break;

      default:
        replyText = 'Şartlarınızı değerlendiriyoruz.';
        break;
    }

    return (
      replyText: replyText,
      replyBadge: replyBadge,
      nextPrice: nextPrice,
      satisfactionDelta: nextSatisfactionDelta,
      patienceDelta: nextPatienceDelta,
      isAgreed: nextAgreed,
      isWalkedAway: nextWalkedAway,
    );
  }
}
