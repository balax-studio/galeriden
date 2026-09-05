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
        lower.contains('bora') ||
        category == RealEstateCategory.building) {
      return archetypes[BuyerArchetypeId.fundDirector]!;
    }
    if (lower.contains('sanayici') ||
        lower.contains('holding') ||
        lower.contains('teoman') ||
        category == RealEstateCategory.tourismFacility) {
      return archetypes[BuyerArchetypeId.industrialist]!;
    }
    if (lower.contains('doktor') ||
        lower.contains('öğretmen') ||
        lower.contains('aile') ||
        category == RealEstateCategory.housing) {
      return archetypes[BuyerArchetypeId.familyBuyer]!;
    }
    if (lower.contains('esnaf') ||
        lower.contains('ticaret') ||
        category == RealEstateCategory.commercial) {
      return archetypes[BuyerArchetypeId.merchantTrader]!;
    }
    if (lower.contains('gurbet') ||
        lower.contains('kerem') ||
        lower.contains('döviz') ||
        category == RealEstateCategory.timeshare) {
      return archetypes[BuyerArchetypeId.expatInvestor]!;
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

          switch (archetype.id) {
            case BuyerArchetypeId.fundDirector:
              replyText =
                  'Yatırım komitemizle görüştük • Tabela değeri ve lokasyon primini dikkate alarak teklifimizi $formatted olarak güncelliyoruz.';
              break;
            case BuyerArchetypeId.familyBuyer:
              replyText =
                  'Ailece düşündük, çocuklar okulu ve muhiti çok sevdi • Bütçemizi zorlayıp $formatted vermeyi kabul ediyoruz.';
              break;
            case BuyerArchetypeId.merchantTrader:
              replyText =
                  'Pazarlığın hakkını verdin • Mülkün ciro potansiyeline güvenip teklifimizi $formatted seviyesine çıkardık.';
              break;
            case BuyerArchetypeId.industrialist:
              replyText =
                  'Rakamı yönetimde revize ettik • Prestijli mülkünüz için yeni teklifimiz $formatted olmuştur.';
              break;
            default:
              replyText =
                  'Önerdiğiniz rakamı değerlendirdik • Yeni fiyat $formatted olarak el sıkışabiliriz.';
              break;
          }
        } else {
          switch (archetype.id) {
            case BuyerArchetypeId.fundDirector:
              replyText =
                  'Bu rakam fonumuzun iç verim oranı ve bütçe tavanını aşıyor • Fiyatı daha fazla esnetemeyiz.';
              break;
            case BuyerArchetypeId.familyBuyer:
              replyText =
                  'Kredi limitimiz ve birikimimiz maalesef bu rakama yetmiyor • Mevcut teklifimizin üzerine çıkamayız.';
              break;
            case BuyerArchetypeId.merchantTrader:
              replyText =
                  'Bu fiyata girersek dükkanın amortismanı 20 yılı bulur • Ticaretimizi kilitleyemeyiz.';
              break;
            default:
              replyText =
                  'Bu rakam bizim fizibilitenin çok üzerinde kalıyor • Fiyatı esnetemeyiz.';
              break;
          }
        }
        break;

      case ChatTacticType.transferDeedCosts:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.65) {
          nextSatisfactionDelta = 10;
          replyBadge = 'TAPU HARCI KARŞI TARAFTA';
          switch (archetype.id) {
            case BuyerArchetypeId.fundDirector:
              replyText =
                  'Kurumsal bütçemizde tapu masrafı karşılığı mevcut • Tapu harcı ve döner sermayeyi tamamen üstleniyoruz.';
              break;
            case BuyerArchetypeId.merchantTrader:
              replyText =
                  'Tamamdır • Yeter ki tapuyu yarın alalım, resmi harçların tamamı bizim kasamızdan çıksın.';
              break;
            default:
              replyText =
                  'Tamamdır • Tapu harcı ve döner sermaye masraflarının tamamını biz üstleniyoruz.';
              break;
          }
        } else {
          replyText =
              'Teamül gereği tapu masrafı yarı yarıya ödenmelidir • Tamamını üstlenemeyiz.';
        }
        break;

      case ChatTacticType.demandCashDiscount:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.70) {
          nextSatisfactionDelta = 15;
          replyBadge = 'HIZLI DEVİR & BLOKAJ KABUL';
          switch (archetype.id) {
            case BuyerArchetypeId.industrialist:
              replyText =
                  'Nakit gücümüz tamdır • Yarın sabah 10:00 da Tapu Takas bloke dekontuyla hazır olacağız.';
              break;
            case BuyerArchetypeId.expatInvestor:
              replyText =
                  'Euro mevduatımız hazır • Bankadan bloke çeki anında çıkarıp yarın tapuda buluşuyoruz.';
              break;
            default:
              replyText =
                  'Likiditemiz hazır • Banka bloke çekiyle yarın sabah tapu devrini tamamlamayı kabul ediyoruz.';
              break;
          }
        } else {
          replyText =
              'Finansman paketimiz banka konut kredisine bağlı • Hemen yarın nakit blokaj garantisi veremeyiz.';
        }
        break;

      case ChatTacticType.demandPrimeFloors:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.70) {
          nextSatisfactionDelta = 15;
          replyBadge = 'ŞEREFİYE DEĞERİ TEYİT EDİLDİ';
          switch (archetype.id) {
            case BuyerArchetypeId.fundDirector:
              replyText =
                  'Lokasyon analiz raporumuz tabela değerini ve yaya aksını doğruluyor • Bu şerefiyenin bedelini ödemeye değer.';
              break;
            case BuyerArchetypeId.familyBuyer:
              replyText =
                  'Haklısınız, sokak çok ferah ve okulun hemen yanı başında • Bu konum ailemiz için paha biçilemez.';
              break;
            default:
              replyText =
                  'Haklısınız • Lokasyon ve cephe avantajı gayrimenkulün değerini koruyor • Teklifimize sadık kalacağız.';
              break;
          }
        } else {
          replyText =
              'Lokasyon güçlü olsa da binanın yaşı ve otopark kısıtı şerefiye avantajını dengeliyor.';
        }
        break;

      case ChatTacticType.demandQualityUpgrade:
        nextPatienceDelta = -15;
        if (random.nextDouble() < 0.65) {
          nextSatisfactionDelta = 15;
          replyBadge = 'BOŞ & MASRAFSIZ TESLİM';
          switch (archetype.id) {
            case BuyerArchetypeId.familyBuyer:
              replyText =
                  'Tadilat ustasıyla ve kiracı tahliyesiyle uğraşmayacak olmak bizim için harika • Mülkü olduğu gibi devralıyoruz.';
              break;
            case BuyerArchetypeId.merchantTrader:
              replyText =
                  'Dükkanın hazır kurulu olması bizi 2 ay masraftan ve zaman kaybından kurtarır • Bu şartı sözleşmeye yazıyoruz.';
              break;
            default:
              replyText =
                  'Tadilat ve tahliye stresi yaşamamak bizim için büyük avantaj • Şartlarınızı kabul ediyoruz.';
              break;
          }
        } else {
          replyText =
              'Biz zaten mülkü kendi konseptimize göre yenileyeceğiz • Mevcut donanım bizim için katma değer taşımıyor.';
        }
        break;

      case ChatTacticType.askJokeOrChat:
        nextPatienceDelta = 22;
        nextSatisfactionDelta = 15;
        replyText =
            'Gönüller bir olsun patron • Bir acı kahvenin kırk yıl hatrı var, pazarlığı tatlıya bağlayalım!';
        replyBadge = 'KAHVE VE SOHBET • SABIR +22';
        break;

      case ChatTacticType.acceptAgreement:
        nextAgreed = true;
        replyText =
            'Harika! Şartlarda mutabık kaldık • Sözleşmeyi hazırlatıyorum, hayırlı uğurlu olsun!';
        replyBadge = 'MUTABAKAT SAĞLANDI';
        break;

      case ChatTacticType.walkAway:
        nextWalkedAway = true;
        replyText =
            'Görüşmelerde ortak bir noktada buluşamadık • Teklifimiz iptal edilmiştir.';
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
