import 'dart:math';
import 'package:flutter/material.dart';


enum TenantArchetypeId {
  civilServant,
  corporateSpecialist,
  doctorSpecialist,
  merchantShopkeeper,
  youngDesigner,
  studentGroup,
}

class TenantArchetype {
  final TenantArchetypeId id;
  final String titleKey;
  final String subtitleKey;
  final IconData avatarIcon;
  final Color themeColor;

  const TenantArchetype({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.avatarIcon,
    required this.themeColor,
  });
}

enum TenantTacticType {
  offerRentDiscount,
  offerRenovation,
  demandTwoYearCommitment,
  demandGuarantor,
  demandExtraDeposit,
  sweetenDealTea,
  firmStance,
  // 7 New Strategic Negotiation Tactics
  offerAnnualAdvanceDiscount,
  demandEvictionUndertaking,
  offerPetAndDecorationFreedom,
  demandCreditScoreReport,
  demandBuildingRulesPledge,
  offerLongTermRentCap,
  offerWhiteGoodsUpgrade,
  // Direct Final Actions
  acceptLease,
  walkAway,
}

class TenantTacticCard {
  final TenantTacticType type;
  final String labelKey;
  final String messageKey;
  final IconData icon;
  final Color accentColor;
  final int patienceCost;
  final int maxUses;

  const TenantTacticCard({
    required this.type,
    required this.labelKey,
    required this.messageKey,
    required this.icon,
    required this.accentColor,
    required this.patienceCost,
    this.maxUses = 1,
  });
}

class TenantTacticOutcome {
  final int patienceDelta;
  final int satisfactionDelta;
  final double nextRent;
  final double nextDeposit;
  final String replyText;
  final String? replyBadge;
  final bool isAgreed;
  final bool isWalkedAway;

  const TenantTacticOutcome({
    required this.patienceDelta,
    required this.satisfactionDelta,
    required this.nextRent,
    required this.nextDeposit,
    required this.replyText,
    this.replyBadge,
    this.isAgreed = false,
    this.isWalkedAway = false,
  });
}

class RealEstateTenantNegotiationExpansion {
  static const Map<TenantArchetypeId, TenantArchetype> archetypes = {
    TenantArchetypeId.civilServant: TenantArchetype(
      id: TenantArchetypeId.civilServant,
      titleKey: 'tenant_archetype_civil_servant_title',
      subtitleKey: 'tenant_archetype_civil_servant_sub',
      avatarIcon: Icons.account_balance_rounded,
      themeColor: Color(0xFF3B82F6),
    ),
    TenantArchetypeId.corporateSpecialist: TenantArchetype(
      id: TenantArchetypeId.corporateSpecialist,
      titleKey: 'tenant_archetype_corporate_title',
      subtitleKey: 'tenant_archetype_corporate_sub',
      avatarIcon: Icons.terminal_rounded,
      themeColor: Color(0xFF10B981),
    ),
    TenantArchetypeId.doctorSpecialist: TenantArchetype(
      id: TenantArchetypeId.doctorSpecialist,
      titleKey: 'tenant_archetype_doctor_title',
      subtitleKey: 'tenant_archetype_doctor_sub',
      avatarIcon: Icons.medical_services_rounded,
      themeColor: Color(0xFF06B6D4),
    ),
    TenantArchetypeId.merchantShopkeeper: TenantArchetype(
      id: TenantArchetypeId.merchantShopkeeper,
      titleKey: 'tenant_archetype_merchant_title',
      subtitleKey: 'tenant_archetype_merchant_sub',
      avatarIcon: Icons.storefront_rounded,
      themeColor: Color(0xFFF59E0B),
    ),
    TenantArchetypeId.youngDesigner: TenantArchetype(
      id: TenantArchetypeId.youngDesigner,
      titleKey: 'tenant_archetype_designer_title',
      subtitleKey: 'tenant_archetype_designer_sub',
      avatarIcon: Icons.draw_rounded,
      themeColor: Color(0xFF8B5CF6),
    ),
    TenantArchetypeId.studentGroup: TenantArchetype(
      id: TenantArchetypeId.studentGroup,
      titleKey: 'tenant_archetype_student_title',
      subtitleKey: 'tenant_archetype_student_sub',
      avatarIcon: Icons.school_rounded,
      themeColor: Color(0xFFEC4899),
    ),
  };

  static TenantArchetype detectTenantArchetype(String profession, String name) {
    final combined = '$profession $name'.toLowerCase();
    if (combined.contains('memur') ||
        combined.contains('öğretmen') ||
        combined.contains('müfettiş')) {
      return archetypes[TenantArchetypeId.civilServant]!;
    }
    if (combined.contains('yazılım') ||
        combined.contains('mühendis') ||
        combined.contains('analist')) {
      return archetypes[TenantArchetypeId.corporateSpecialist]!;
    }
    if (combined.contains('doktor') ||
        combined.contains('eczacı') ||
        combined.contains('sağlık')) {
      return archetypes[TenantArchetypeId.doctorSpecialist]!;
    }
    if (combined.contains('esnaf') || combined.contains('usta')) {
      return archetypes[TenantArchetypeId.merchantShopkeeper]!;
    }
    if (combined.contains('mimar') || combined.contains('avukat')) {
      return archetypes[TenantArchetypeId.youngDesigner]!;
    }
    return archetypes[TenantArchetypeId.studentGroup]!;
  }

  static List<TenantTacticCard> getAllTactics() {
    return const [
      TenantTacticCard(
        type: TenantTacticType.offerRentDiscount,
        labelKey: 'tenant_tactic_discount_label',
        messageKey: 'tenant_tactic_discount_msg',
        icon: Icons.trending_down_rounded,
        accentColor: Color(0xFF34D399),
        patienceCost: 0,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.offerRenovation,
        labelKey: 'tenant_tactic_renovation_label',
        messageKey: 'tenant_tactic_renovation_msg',
        icon: Icons.format_paint_rounded,
        accentColor: Color(0xFF60A5FA),
        patienceCost: 0,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandTwoYearCommitment,
        labelKey: 'tenant_tactic_two_year_label',
        messageKey: 'tenant_tactic_two_year_msg',
        icon: Icons.event_repeat_rounded,
        accentColor: Color(0xFFFBBF24),
        patienceCost: 10,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandGuarantor,
        labelKey: 'tenant_tactic_guarantor_label',
        messageKey: 'tenant_tactic_guarantor_msg',
        icon: Icons.verified_user_rounded,
        accentColor: Color(0xFFA78BFA),
        patienceCost: 12,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandExtraDeposit,
        labelKey: 'tenant_tactic_deposit_label',
        messageKey: 'tenant_tactic_deposit_msg',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: Color(0xFFF87171),
        patienceCost: 15,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.sweetenDealTea,
        labelKey: 'tenant_tactic_coffee_label',
        messageKey: 'tenant_tactic_coffee_msg',
        icon: Icons.coffee_rounded,
        accentColor: Color(0xFFE2E8F0),
        patienceCost: -22,
        maxUses: 2,
      ),
      TenantTacticCard(
        type: TenantTacticType.firmStance,
        labelKey: 'tenant_tactic_firm_label',
        messageKey: 'tenant_tactic_firm_msg',
        icon: Icons.shield_rounded,
        accentColor: Color(0xFFCBD5E1),
        patienceCost: 16,
        maxUses: 1,
      ),
      // 7 New Dynamic Strategies
      TenantTacticCard(
        type: TenantTacticType.offerAnnualAdvanceDiscount,
        labelKey: 'tenant_tactic_annual_advance_label',
        messageKey: 'tenant_tactic_annual_advance_msg',
        icon: Icons.payments_rounded,
        accentColor: Color(0xFF10B981),
        patienceCost: 0,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandEvictionUndertaking,
        labelKey: 'tenant_tactic_eviction_undertaking_label',
        messageKey: 'tenant_tactic_eviction_undertaking_msg',
        icon: Icons.gavel_rounded,
        accentColor: Color(0xFFEF4444),
        patienceCost: 10,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.offerPetAndDecorationFreedom,
        labelKey: 'tenant_tactic_pet_decoration_label',
        messageKey: 'tenant_tactic_pet_decoration_msg',
        icon: Icons.pets_rounded,
        accentColor: Color(0xFFF472B6),
        patienceCost: -15,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandCreditScoreReport,
        labelKey: 'tenant_tactic_credit_score_label',
        messageKey: 'tenant_tactic_credit_score_msg',
        icon: Icons.request_quote_rounded,
        accentColor: Color(0xFF38BDF8),
        patienceCost: 8,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandBuildingRulesPledge,
        labelKey: 'tenant_tactic_building_rules_label',
        messageKey: 'tenant_tactic_building_rules_msg',
        icon: Icons.apartment_rounded,
        accentColor: Color(0xFF818CF8),
        patienceCost: 6,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.offerLongTermRentCap,
        labelKey: 'tenant_tactic_rent_cap_label',
        messageKey: 'tenant_tactic_rent_cap_msg',
        icon: Icons.lock_clock_rounded,
        accentColor: Color(0xFF34D399),
        patienceCost: -10,
        maxUses: 1,
      ),
      TenantTacticCard(
        type: TenantTacticType.offerWhiteGoodsUpgrade,
        labelKey: 'tenant_tactic_white_goods_label',
        messageKey: 'tenant_tactic_white_goods_msg',
        icon: Icons.kitchen_rounded,
        accentColor: Color(0xFFF59E0B),
        patienceCost: -12,
        maxUses: 1,
      ),
    ];
  }

  static List<TenantTacticCard> getAvailableDeck(Map<TenantTacticType, int> useCounts) {
    return getAllTactics()
        .where((card) => (useCounts[card.type] ?? 0) < card.maxUses)
        .toList();
  }

  static TenantTacticOutcome evaluateTactic({
    required TenantTacticType tactic,
    required double currentRent,
    required double currentDeposit,
    required int patience,
    required int satisfaction,
    required TenantArchetype archetype,
    required int useCount,
    required Random random,
  }) {
    switch (tactic) {
      case TenantTacticType.offerRentDiscount:
        final discountAmount = (currentRent * 0.05).clamp(500.0, 15000.0);
        final nextRent = (currentRent - discountAmount).roundToDouble();
        final successReplies = [
          'Kira indirimi teklifiniz beni çok rahatlattı • Bu anlayışınız için teşekkür ederim, mülke çok iyi bakacağım.',
          'Bütçeme uygun bir seviyeye indik • İndiriminiz sayesinde hemen kontrat imzalamaya hazırım.',
          'Harika bir jest oldu • Kira ödemelerini her ayın 1\'inde eksiksiz hesabınıza geçeceğim.',
          'Pazarlık sünnettir derler • Bu indiriminizle iki taraf da memnun kaldı.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 18,
          satisfactionDelta: 22,
          nextRent: nextRent,
          nextDeposit: currentDeposit,
          replyText: successReplies[random.nextInt(successReplies.length)],
          replyBadge: 'KİRA İNDİRİMİ KABUL EDİLDİ',
        );

      case TenantTacticType.offerRenovation:
        final renoReplies = [
          'Evi temiz ve boyalı teslim edecek olmanız benim için büyük artı • Masrafsız taşınmak harika olacak.',
          'Usta masrafı ve tadilat derdinden kurtulmak büyük ferahlık • Teşekkür ederim.',
          'Tertemiz oturmak gibisi yok • Mülkünüzü teslim aldığım titizlikle koruyacağıma söz veriyorum.',
          'Boya badana jestiniz için minnettarım • Evi pırıl pırıl teslim almayı dört gözle bekliyorum.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 16,
          satisfactionDelta: 25,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: renoReplies[random.nextInt(renoReplies.length)],
          replyBadge: 'BOYA & TADİLAT TAAHHÜDÜ',
        );

      case TenantTacticType.demandTwoYearCommitment:
        if (archetype.id == TenantArchetypeId.civilServant ||
            archetype.id == TenantArchetypeId.doctorSpecialist ||
            archetype.id == TenantArchetypeId.corporateSpecialist) {
          final replies = [
            'Zaten uzun vadeli ve huzurlu bir oturum istiyordum • 2 yıllık taahhüt vermek benim için de çok uygun.',
            'Görev yerim sabit, düzeni seven biriyim • 2 yıl gönül rahatlığıyla kalırız.',
            'Ev arama stresinden iki sene uzak kalmak bana da uyar • Memnuniyetle kabul ediyorum.',
          ];
          return TenantTacticOutcome(
            patienceDelta: 5,
            satisfactionDelta: 15,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: '2 YILLIK TAAHHÜT ONAYLANDI',
          );
        } else {
          final replies = [
            'İş durumum veya tayin ihtimalim sebebiyle 2 yıl kesin söz veremem ancak 1 yıl sonra uzatmayı değerlendiririz.',
            'Hayatın ne getireceği belli olmaz • Şimdilik 1 yıllık yapalım, seneye bakarız.',
            '2 yıl bağlayıcı taahhüt şu an esnekliğimi kısıtlar • İlk yılı sorunsuz tamamlayalım sonra bakarız.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -10,
            satisfactionDelta: 0,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: '1 YILDA ISRARCI',
          );
        }

      case TenantTacticType.demandGuarantor:
        if (patience > 30) {
          final replies = [
            'Mülk sahibi olarak güvence istemeniz doğal • Memur kefil evraklarımı ve noter onaylı taahhütnameyi temin ederim.',
            'Kefil bulmakta sıkıntım yok • Kamu çalışanı yakınımın bordrosunu yarın getiririm.',
            'Açık alın, ak yüz • Kefil belgelerini dosyalayıp evraklarınıza ekleyelim.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -8,
            satisfactionDelta: 5,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'KEFİL BELGESİ HAZIRLANIYOR',
          );
        } else {
          final replies = [
            'Kefil ve noter prosedürleri beni zorlar • Şahsıma güvenilmeyecekse başka seçeneklere bakabilirim.',
            'Kimseye minnet etmeyi sevmem • Kendi gelirim yeterliyken kefil şartı beni soğutur.',
            'Müstakil bir hayat kurmaya çalışırken kefil bürokrasisi beni aşar • Bu şartı esnetmelisiniz.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -18,
            satisfactionDelta: -15,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'KEFİL TALEBİNE İTİRAZ',
          );
        }

      case TenantTacticType.demandExtraDeposit:
        final extraDeposit = currentDeposit + currentRent;
        if (satisfaction >= 50 && patience > 35) {
          final replies = [
            '2 aylık depozito bütçemi biraz sıksa da daireyi çok beğendiğim için kabul ediyorum.',
            'Demirbaşların kıymetini anlıyorum • İlave depozitoyu kontrat anında hesaba geçerim.',
            'Güven iki taraflı olmalı • Dairenin temizliği hatırına çift depozitoyu veriyorum.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -12,
            satisfactionDelta: -5,
            nextRent: currentRent,
            nextDeposit: extraDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: '2 AYLIK DEPOZİTO KABUL',
          );
        } else {
          final replies = [
            'Peşin 2 aylık depozito şartı nakit akışımı bozar • Mevcut 1 aylık depozitoda kalmamız şart.',
            'Nakit bütçemi taşınmaya ayırdım • Fazladan depozito vermem mümkün değil.',
            'Piyasa teamülü 1 aylık depozitodur • İlave depozito talebiniz anlaşmayı zorlaştırır.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -20,
            satisfactionDelta: -20,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'DEPOZİTO ZAMMI REDDEDİLDİ',
          );
        }

      case TenantTacticType.sweetenDealTea:
        final teaReplies = [
          'İkramınız ve nazik yaklaşımınız için teşekkür ederim • Mülk sahibiyle böyle medeni konuşabilmek çok kıymetli.',
          'Gönül ne kahve ister ne kahvehane, gönül sohbet ister kahve bahane • İkramınız için sağ olun.',
          'Tatlı dil yılanı deliğinden çıkarır derler • Samimiyetiniz için çok teşekkür ederim.',
          'Çayınız içildi, muhabbet kuruldu • Artık iki yabancı değiliz, anlaşacağımıza inancım tam.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 24,
          satisfactionDelta: 12,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: teaReplies[random.nextInt(teaReplies.length)],
          replyBadge: 'SABIR VE MEMNUNİYET ARTTI',
        );

      case TenantTacticType.firmStance:
        if (satisfaction >= 60) {
          final replies = [
            'Piyasa araştırması yaptım, haklısınız • Bu kalitede bir daire için rakamınız makul, fiyatta ısrar etmeyeceğim.',
            'Görünen köy kılavuz istemez • Muhitin şartları belli, teklifinizi kabul ediyorum.',
            'Duruşunuz net ve tutarlı • Evin değerini bildiğinizi görüyorum, liste fiyatını onaylıyorum.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -10,
            satisfactionDelta: 0,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'RAYİÇ KABUL EDİLDİ',
          );
        } else {
          final replies = [
            'Hiç esneklik göstermemeniz beni düşündürüyor • Masadan kalkma eşiğine geldim.',
            'Pazarlıksız ticaret olmaz • Biraz esneklik beklerdim, şevkim kırıldı.',
            'Katı tutumunuz karşısında kendimi rahat hissetmiyorum • Biraz daha uzlaşmacı olmalısınız.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -22,
            satisfactionDelta: -15,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'GERGİNLİK ARTTI',
          );
        }

      case TenantTacticType.offerAnnualAdvanceDiscount:
        if (archetype.id == TenantArchetypeId.corporateSpecialist ||
            archetype.id == TenantArchetypeId.merchantShopkeeper ||
            archetype.id == TenantArchetypeId.doctorSpecialist) {
          final discountAmount = (currentRent * 0.10).clamp(1000.0, 30000.0);
          final nextRent = (currentRent - discountAmount).roundToDouble();
          final replies = [
            'Peşin satan ile veresiye satan bir olmaz • Yıllık peşin ödeme teklifiniz iki taraf için de bereketli oldu.',
            'Nakit hazırlığım vardı • Bir yıllık kirayı tek seferde ödeyip kafamı dinlemek harika bir fırsat.',
            'Damlaya damlaya göl olur • Bu indirimle yıllık peşin ödemeyi seve seve kabul ediyorum.',
          ];
          return TenantTacticOutcome(
            patienceDelta: 20,
            satisfactionDelta: 30,
            nextRent: nextRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'YILLIK PEŞİN KİRA KABUL EDİLDİ',
          );
        } else {
          final replies = [
            'Teklifiniz çok cazip ancak yıllık peşin çıkaracak toplu nakdim yok • Aylık düzenli ödemede kalalım.',
            'Maaşla çalışan biriyim, toplu ödeme bütçemi aşar • Ancak aylık ödemeleri bir gün bile aksatmam.',
            'İndirim için teşekkürler ancak peşin ödeme gücüm bulunmuyor • Normal aylık periyotta anlaşalım.',
          ];
          return TenantTacticOutcome(
            patienceDelta: 5,
            satisfactionDelta: 10,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'AYLIK ÖDEMEDE MUTABIK',
          );
        }

      case TenantTacticType.demandEvictionUndertaking:
        if (archetype.id == TenantArchetypeId.civilServant ||
            archetype.id == TenantArchetypeId.doctorSpecialist ||
            archetype.id == TenantArchetypeId.corporateSpecialist) {
          final replies = [
            'Söz uçar yazı kalır • Noter onaylı tahliye taahhütnamesini yarın ilk iş imzalarım.',
            'Mülk sahibinin yasal hakkıdır • Kanuna ve usule uygun taahhütname vermekten çekinmem.',
            'Kurallara saygılı biriyim • Tahliye taahhütnamesi vermek benim için hiç sorun değil.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -5,
            satisfactionDelta: 10,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'NOTER TAAHHÜTNAMESİ ONAYLANDI',
          );
        } else {
          final replies = [
            'Daha taşınmadan kapı önüne koyma belgesi imzalatmak kırıcı • Karşılıklı güven nerede kaldı?',
            'Noter taahhütnamesi kiracı aleyhine ağır bir koz • Bu şart beni ciddi düşündürüyor.',
            'Peşinen tahliye taahhüdü vermek huzursuzluk yaratır • Güven esasına dayalı ilerleyelim.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -18,
            satisfactionDelta: -12,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'TAAHHÜTNAME TALEBİNE DİRENÇ',
          );
        }

      case TenantTacticType.offerPetAndDecorationFreedom:
        final replies = [
          'Evcil hayvanıma ve evimin dekoruna izin vermeniz harika • Daireyi kendi evim gibi özenle koruyacağım.',
          'Can dostumla huzurla yaşayabileceğim bir ev bulmak paha biçilemez • Sonsuz teşekkürler.',
          'Kendi zevkime göre tablo asıp duvar boyayabilmek beni eve bağlar • Harika bir ev sahibisiniz.',
          'Ev sahibinin bir evi, kiracının bin evi var derler • Anlayışınız ve hayvan dostu yaklaşımınız için minnettarım.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 22,
          satisfactionDelta: 32,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: replies[random.nextInt(replies.length)],
          replyBadge: 'EVCİL HAYVAN & DEKOR İZNİ VERİLDİ',
        );

      case TenantTacticType.demandCreditScoreReport:
        if (archetype.id == TenantArchetypeId.civilServant ||
            archetype.id == TenantArchetypeId.doctorSpecialist ||
            archetype.id == TenantArchetypeId.corporateSpecialist) {
          final replies = [
            'Açık hesap, net vicdan • Findeks notum 1850 puan seviyesinde, bordromla birlikte takdim ederim.',
            'Finansal sicilim tertemiz • Kredi ve ödeme raporumu memnuniyetle e-Devlet üzerinden iletirim.',
            'Kurumsal şeffaflık her zaman iyidir • Raporumu karekodlu olarak hemen paylaşıyorum.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -2,
            satisfactionDelta: 12,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'FİNDEKS RAPORU ONAYLANDI',
          );
        } else {
          final replies = [
            'Banka kredisine başvurmuyoruz, altı üstü ev kiralıyoruz • Bu kadar bürokrasi fazla değil mi?',
            'Özel gelir detaylarımı dökmek istemezdim • Şahsi referanslarım yeterli olmalıydı.',
            'Kredi skoru sorgulaması biraz soğuk bir prosedür • Yine de değerlendireceğim.',
          ];
          return TenantTacticOutcome(
            patienceDelta: -14,
            satisfactionDelta: -8,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText: replies[random.nextInt(replies.length)],
            replyBadge: 'KREDİ RAPORUNA İTİRAZ',
          );
        }

      case TenantTacticType.demandBuildingRulesPledge:
        final replies = [
          'Komşu komşunun külüne muhtaçtır • Apartman sükuneti ve komşuluk hukuku bizim de ilk şartımız.',
          'Gece gürültüsü ve dağınıklık bize göre değil • Bina kurallarına harfiyen uyacağıma söz veriyorum.',
          'Huzurlu bir aile apartmanı arıyordum • Bu hassasiyetiniz beni daha da memnun etti.',
          'Ortak alanlara saygı medeniyet göstergesidir • Apartman yönetim planına sonuna kadar bağlıyım.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 5,
          satisfactionDelta: 15,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: replies[random.nextInt(replies.length)],
          replyBadge: 'BİNA DÜZENİ TAAHHÜDÜ ALINDI',
        );

      case TenantTacticType.offerLongTermRentCap:
        final replies = [
          'Önünü gören rahat uyur • Gelecek yıl fahiş kira artışı korkusu yaşamamak beni çok rahatlattı.',
          'Yasal TÜFE güvencesi vermeniz mülk sahibinden çok bir dost yaklaşımı • Minnettarım.',
          'Piyasada her gün kira kavgaları yaşanırken bu garantiniz altın değerinde.',
          'Hakkaniyetli mülk sahibiyle karşılaşmak büyük şans • Bu madde ile içim tamamen rahatladı.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 18,
          satisfactionDelta: 28,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: replies[random.nextInt(replies.length)],
          replyBadge: 'TÜFE KİRA GARANTİSİ VERİLDİ',
        );

      case TenantTacticType.offerWhiteGoodsUpgrade:
        final replies = [
          'Evi gösteren mutfağıdır • Sıfır beyaz eşya jestinizle taşınma masrafım yarı yarıya indi.',
          'Kendi eşyamı alma külfetinden kurtuldum • Demirbaşlara gözüm gibi bakacağıma emin olabilirsiniz.',
          'Sıfır ankastre ve buzdolabı teklifiniz harika • Kontratı hemen yapabiliriz.',
          'Eşyalı konforunda taşınmak harika bir lüks • Bu jestinizi unutmayacağım.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 20,
          satisfactionDelta: 30,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: replies[random.nextInt(replies.length)],
          replyBadge: 'SIFIR BEYAZ EŞYA ONAYLANDI',
        );

      case TenantTacticType.acceptLease:
        final agreeReplies = [
          'Şartlarda mutabık kaldık • Kira kontratını imzalamaktan büyük mutluluk duyuyorum, hayırlı uğurlu olsun!',
          'El sıkıştık • Her iki tarafa da huzur ve bereket getirmesini dilerim, anahtarı teslim alabilirim.',
          'Mülkünüz gibi dürüst bir ev sahibi bulduğum için çok şanslıyım • Kontratı seve seve imzalıyorum.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 0,
          satisfactionDelta: 30,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: agreeReplies[random.nextInt(agreeReplies.length)],
          replyBadge: 'KİRA KONTRATI İMZALANDI',
          isAgreed: true,
        );

      case TenantTacticType.walkAway:
        final walkReplies = [
          'Şartlarda anlaşamadık • Zaman ayırdığınız için teşekkürler, iyi günler dilerim.',
          'Beklentilerimiz uyuşmadı • Başka bir kiracı adayıyla daha iyi anlaşabilirsiniz, hoşça kalın.',
          'Masadan kalkmak durumundayım • Mülkünüz için dilediğiniz gibi bir kiracı bulmanızı dilerim.',
        ];
        return TenantTacticOutcome(
          patienceDelta: 0,
          satisfactionDelta: 0,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText: walkReplies[random.nextInt(walkReplies.length)],
          replyBadge: 'MASADAN KALKILDI',
          isWalkedAway: true,
        );
    }
  }
}
