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

  const TenantTacticCard({
    required this.type,
    required this.labelKey,
    required this.messageKey,
    required this.icon,
    required this.accentColor,
    required this.patienceCost,
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

  static List<TenantTacticCard> getAvailableDeck(Map<TenantTacticType, int> useCounts) {
    return [
      TenantTacticCard(
        type: TenantTacticType.offerRentDiscount,
        labelKey: 'tenant_tactic_discount_label',
        messageKey: 'tenant_tactic_discount_msg',
        icon: Icons.trending_down_rounded,
        accentColor: const Color(0xFF34D399),
        patienceCost: 0,
      ),
      TenantTacticCard(
        type: TenantTacticType.offerRenovation,
        labelKey: 'tenant_tactic_renovation_label',
        messageKey: 'tenant_tactic_renovation_msg',
        icon: Icons.format_paint_rounded,
        accentColor: const Color(0xFF60A5FA),
        patienceCost: 0,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandTwoYearCommitment,
        labelKey: 'tenant_tactic_two_year_label',
        messageKey: 'tenant_tactic_two_year_msg',
        icon: Icons.event_repeat_rounded,
        accentColor: const Color(0xFFFBBF24),
        patienceCost: 10,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandGuarantor,
        labelKey: 'tenant_tactic_guarantor_label',
        messageKey: 'tenant_tactic_guarantor_msg',
        icon: Icons.verified_user_rounded,
        accentColor: const Color(0xFFA78BFA),
        patienceCost: 12,
      ),
      TenantTacticCard(
        type: TenantTacticType.demandExtraDeposit,
        labelKey: 'tenant_tactic_deposit_label',
        messageKey: 'tenant_tactic_deposit_msg',
        icon: Icons.account_balance_wallet_rounded,
        accentColor: const Color(0xFFF87171),
        patienceCost: 15,
      ),
      TenantTacticCard(
        type: TenantTacticType.sweetenDealTea,
        labelKey: 'tenant_tactic_coffee_label',
        messageKey: 'tenant_tactic_coffee_msg',
        icon: Icons.coffee_rounded,
        accentColor: const Color(0xFFE2E8F0),
        patienceCost: -22,
      ),
      TenantTacticCard(
        type: TenantTacticType.firmStance,
        labelKey: 'tenant_tactic_firm_label',
        messageKey: 'tenant_tactic_firm_msg',
        icon: Icons.shield_rounded,
        accentColor: const Color(0xFFCBD5E1),
        patienceCost: 16,
      ),
    ];
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
        return TenantTacticOutcome(
          patienceDelta: 16,
          satisfactionDelta: 25,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText:
              'Evi temiz ve boyalı teslim edecek olmanız benim için büyük artı • Masrafsız taşınmak harika olacak.',
          replyBadge: 'BOYA & TADİLAT TAAHHÜDÜ',
        );

      case TenantTacticType.demandTwoYearCommitment:
        if (archetype.id == TenantArchetypeId.civilServant ||
            archetype.id == TenantArchetypeId.doctorSpecialist ||
            archetype.id == TenantArchetypeId.corporateSpecialist) {
          return TenantTacticOutcome(
            patienceDelta: 5,
            satisfactionDelta: 15,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'Zaten uzun vadeli ve huzurlu bir oturum istiyordum • 2 yıllık taahhüt vermek benim için de çok uygun.',
            replyBadge: '2 YILLIK TAAHHÜT ONAYLANDI',
          );
        } else {
          return TenantTacticOutcome(
            patienceDelta: -10,
            satisfactionDelta: 0,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'İş durumum veya tayin ihtimalim sebebiyle 2 yıl kesin söz veremem ancak 1 yıl sonra uzatmayı değerlendiririz.',
            replyBadge: '1 YILDA ISRARCI',
          );
        }

      case TenantTacticType.demandGuarantor:
        if (patience > 30) {
          return TenantTacticOutcome(
            patienceDelta: -8,
            satisfactionDelta: 5,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'Mülk sahibi olarak güvence istemeniz doğal • Memur kefil evraklarımı ve noter onaylı taahhütnameyi temin ederim.',
            replyBadge: 'KEFİL BELGESİ HAZIRLANIYOR',
          );
        } else {
          return TenantTacticOutcome(
            patienceDelta: -18,
            satisfactionDelta: -15,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'Kefil ve noter prosedürleri beni zorlar • Şahsıma güvenilmeyecekse başka seçeneklere bakabilirim.',
            replyBadge: 'KEFİL TALEBİNE İTİRAZ',
          );
        }

      case TenantTacticType.demandExtraDeposit:
        final extraDeposit = currentDeposit + currentRent;
        if (satisfaction >= 50 && patience > 35) {
          return TenantTacticOutcome(
            patienceDelta: -12,
            satisfactionDelta: -5,
            nextRent: currentRent,
            nextDeposit: extraDeposit,
            replyText:
                '2 aylık depozito bütçemi biraz sıksa da daireyi çok beğendiğim için kabul ediyorum.',
            replyBadge: '2 AYLIK DEPOZİTO KABUL',
          );
        } else {
          return TenantTacticOutcome(
            patienceDelta: -20,
            satisfactionDelta: -20,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'Peşin 2 aylık depozito şartı nakit akışımı bozar • Mevcut 1 aylık depozitoda kalmamız şart.',
            replyBadge: 'DEPOZİTO ZAMMI REDDEDİLDİ',
          );
        }

      case TenantTacticType.sweetenDealTea:
        return TenantTacticOutcome(
          patienceDelta: 24,
          satisfactionDelta: 12,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText:
              'İkramınız ve nazik yaklaşımınız için teşekkür ederim • Mülk sahibiyle böyle medeni konuşabilmek çok kıymetli.',
          replyBadge: 'SABIR VE MEMNUNİYET ARTTI',
        );

      case TenantTacticType.firmStance:
        if (satisfaction >= 60) {
          return TenantTacticOutcome(
            patienceDelta: -10,
            satisfactionDelta: 0,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'Piyasa araştırması yaptım, haklısınız • Bu kalitede bir daire için rakamınız makul, fiyatta ısrar etmeyeceğim.',
            replyBadge: 'RAYİÇ KABUL EDİLDİ',
          );
        } else {
          return TenantTacticOutcome(
            patienceDelta: -22,
            satisfactionDelta: -15,
            nextRent: currentRent,
            nextDeposit: currentDeposit,
            replyText:
                'Hiç esneklik göstermemeniz beni düşündürüyor • Masadan kalkma eşiğine geldim.',
            replyBadge: 'GERGİNLİK ARTTI',
          );
        }

      case TenantTacticType.acceptLease:
        return TenantTacticOutcome(
          patienceDelta: 0,
          satisfactionDelta: 30,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText:
              'Şartlarda mutabık kaldık • Kira kontratını imzalamaktan büyük mutluluk duyuyorum, hayırlı uğurlu olsun!',
          replyBadge: 'KİRA KONTRATI İMZALANDI',
          isAgreed: true,
        );

      case TenantTacticType.walkAway:
        return TenantTacticOutcome(
          patienceDelta: 0,
          satisfactionDelta: 0,
          nextRent: currentRent,
          nextDeposit: currentDeposit,
          replyText:
              'Şartlarda anlaşamadık • Zaman ayırdığınız için teşekkürler, iyi günler.',
          replyBadge: 'MASADAN KALKILDI',
          isWalkedAway: true,
        );
    }
  }
}
