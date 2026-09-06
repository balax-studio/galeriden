import 'dart:math';
import 'package:flutter/material.dart';

import 'construction_timeline_engine.dart';
import 'real_estate_chat_negotiation_engine.dart';

class SubcontractorTacticStageDef {
  final String labelKey;
  final String messageKey;
  final ChatTacticType tacticType;
  final IconData icon;
  final Color chipColor;

  const SubcontractorTacticStageDef({
    required this.labelKey,
    required this.messageKey,
    required this.tacticType,
    required this.icon,
    this.chipColor = const Color(0xFFEFF6FF),
  });
}

class SubcontractorTacticTrackDef {
  final String id;
  final List<SubcontractorTacticStageDef> stages;

  const SubcontractorTacticTrackDef({
    required this.id,
    required this.stages,
  });

  int get maxStages => stages.length;
}

class SubcontractorNegotiationExpansion {
  // --- 6 AŞAMALI DİNAMİK TAŞERON PAZARLIK KULVARI ---
  static const List<SubcontractorTacticTrackDef> tacticTracks = [
    // 1. Birim Fiyat İndirimi Kulvarı
    SubcontractorTacticTrackDef(
      id: 'discount',
      stages: [
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_discount_label_0',
          messageKey: 'subcontractor_tactic_discount_msg_0',
          tacticType: ChatTacticType.counterPrice,
          icon: Icons.percent_rounded,
          chipColor: Color(0xFFEFF6FF),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_discount_label_1',
          messageKey: 'subcontractor_tactic_discount_msg_1',
          tacticType: ChatTacticType.counterPrice,
          icon: Icons.price_check_rounded,
          chipColor: Color(0xFFEFF6FF),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_discount_label_2',
          messageKey: 'subcontractor_tactic_discount_msg_2',
          tacticType: ChatTacticType.counterPrice,
          icon: Icons.gavel_rounded,
          chipColor: Color(0xFFDBEAFE),
        ),
      ],
    ),

    // 2. Çift Vardiya & Süre Hızlandırma Kulvarı
    SubcontractorTacticTrackDef(
      id: 'doubleShift',
      stages: [
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_double_shift_label_0',
          messageKey: 'subcontractor_tactic_double_shift_msg_0',
          tacticType: ChatTacticType.demandDoubleShift,
          icon: Icons.bolt_rounded,
          chipColor: Color(0xFFFEF3C7),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_double_shift_label_1',
          messageKey: 'subcontractor_tactic_double_shift_msg_1',
          tacticType: ChatTacticType.demandDoubleShift,
          icon: Icons.nightlight_round,
          chipColor: Color(0xFFFEF3C7),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_double_shift_label_2',
          messageKey: 'subcontractor_tactic_double_shift_msg_2',
          tacticType: ChatTacticType.demandDoubleShift,
          icon: Icons.timer_rounded,
          chipColor: Color(0xFFFDE68A),
        ),
      ],
    ),

    // 3. Peşin Malzeme Alımı & İskonto Kulvarı
    SubcontractorTacticTrackDef(
      id: 'cashMaterials',
      stages: [
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_cash_materials_label_0',
          messageKey: 'subcontractor_tactic_cash_materials_msg_0',
          tacticType: ChatTacticType.demandCashMaterials,
          icon: Icons.payments_rounded,
          chipColor: Color(0xFFD1FAE5),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_cash_materials_label_1',
          messageKey: 'subcontractor_tactic_cash_materials_msg_1',
          tacticType: ChatTacticType.demandCashMaterials,
          icon: Icons.local_shipping_rounded,
          chipColor: Color(0xFFD1FAE5),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_cash_materials_label_2',
          messageKey: 'subcontractor_tactic_cash_materials_msg_2',
          tacticType: ChatTacticType.demandCashMaterials,
          icon: Icons.account_balance_wallet_rounded,
          chipColor: Color(0xFFA7F3D0),
        ),
      ],
    ),

    // 4. Gecikme Cezai Şartı & Noter Taahhüdü Kulvarı
    SubcontractorTacticTrackDef(
      id: 'penaltyClause',
      stages: [
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_penalty_clause_label_0',
          messageKey: 'subcontractor_tactic_penalty_clause_msg_0',
          tacticType: ChatTacticType.demandPenaltyClause,
          icon: Icons.assignment_late_rounded,
          chipColor: Color(0xFFFEE2E2),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_penalty_clause_label_1',
          messageKey: 'subcontractor_tactic_penalty_clause_msg_1',
          tacticType: ChatTacticType.demandPenaltyClause,
          icon: Icons.policy_rounded,
          chipColor: Color(0xFFFEE2E2),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_penalty_clause_label_2',
          messageKey: 'subcontractor_tactic_penalty_clause_msg_2',
          tacticType: ChatTacticType.demandPenaltyClause,
          icon: Icons.shield_rounded,
          chipColor: Color(0xFFFECACA),
        ),
      ],
    ),

    // 5. Kesin Teminat & Şantiye Güvencesi Kulvarı
    SubcontractorTacticTrackDef(
      id: 'guarantee',
      stages: [
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_guarantee_label_0',
          messageKey: 'subcontractor_tactic_guarantee_msg_0',
          tacticType: ChatTacticType.demandPrimeFloors,
          icon: Icons.verified_user_rounded,
          chipColor: Color(0xFFF3E8FF),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_guarantee_label_1',
          messageKey: 'subcontractor_tactic_guarantee_msg_1',
          tacticType: ChatTacticType.demandPrimeFloors,
          icon: Icons.lock_rounded,
          chipColor: Color(0xFFF3E8FF),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_guarantee_label_2',
          messageKey: 'subcontractor_tactic_guarantee_msg_2',
          tacticType: ChatTacticType.demandPrimeFloors,
          icon: Icons.verified_rounded,
          chipColor: Color(0xFFE9D5FF),
        ),
      ],
    ),

    // 6. Usta ile Çay & Hasbihal Kulvarı (Sabır Yenileme)
    SubcontractorTacticTrackDef(
      id: 'tea',
      stages: [
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_tea_label_0',
          messageKey: 'subcontractor_tactic_tea_msg_0',
          tacticType: ChatTacticType.askJokeOrChat,
          icon: Icons.emoji_food_beverage_rounded,
          chipColor: Color(0xFFFFFBEB),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_tea_label_1',
          messageKey: 'subcontractor_tactic_tea_msg_1',
          tacticType: ChatTacticType.askJokeOrChat,
          icon: Icons.handshake_rounded,
          chipColor: Color(0xFFFFFBEB),
        ),
        SubcontractorTacticStageDef(
          labelKey: 'subcontractor_tactic_tea_label_2',
          messageKey: 'subcontractor_tactic_tea_msg_2',
          tacticType: ChatTacticType.askJokeOrChat,
          icon: Icons.sentiment_satisfied_alt_rounded,
          chipColor: Color(0xFFFEF3C7),
        ),
      ],
    ),
  ];

  static SubcontractorTacticTrackDef? getTrack(String id) {
    for (final track in tacticTracks) {
      if (track.id == id) return track;
    }
    return null;
  }

  // --- ZANAAT VE ETAP BAZLI ZENGİN ESNAF REPLİKLERİ ---
  static String getTradeDialogue({
    required int stageNumber,
    required SubcontractorTier tier,
    required ChatTacticType tactic,
    required bool isSuccess,
    required Random random,
  }) {
    switch (tactic) {
      case ChatTacticType.counterPrice:
        return _getPriceDialogue(stageNumber, tier, isSuccess, random);
      case ChatTacticType.demandDoubleShift:
        return _getDoubleShiftDialogue(stageNumber, tier, isSuccess, random);
      case ChatTacticType.demandCashMaterials:
        return _getCashMaterialsDialogue(stageNumber, tier, isSuccess, random);
      case ChatTacticType.demandPenaltyClause:
        return _getPenaltyDialogue(stageNumber, tier, isSuccess, random);
      case ChatTacticType.demandPrimeFloors:
        return _getGuaranteeDialogue(stageNumber, tier, isSuccess, random);
      case ChatTacticType.askJokeOrChat:
        return _getTeaDialogue(stageNumber, tier, random);
      default:
        return isSuccess
            ? 'subcontractor_reply_generic_accept'
            : 'subcontractor_reply_generic_reject';
    }
  }

  static String _getPriceDialogue(int stage, SubcontractorTier tier, bool isSuccess, Random r) {
    if (stage == 2) {
      if (isSuccess) {
        return tier == SubcontractorTier.speed
            ? 'subcontractor_hafriyat_price_accept_speed'
            : 'subcontractor_hafriyat_price_accept_std';
      } else {
        return tier == SubcontractorTier.budget
            ? 'subcontractor_hafriyat_price_reject_budget'
            : 'subcontractor_hafriyat_price_reject_std';
      }
    } else if (stage == 3) {
      return isSuccess
          ? 'subcontractor_kalip_price_accept'
          : 'subcontractor_kalip_price_reject';
    } else if (stage == 4) {
      return isSuccess
          ? 'subcontractor_duvar_price_accept'
          : 'subcontractor_duvar_price_reject';
    } else if (stage == 5) {
      return isSuccess
          ? 'subcontractor_tesisat_price_accept'
          : 'subcontractor_tesisat_price_reject';
    } else if (stage == 6) {
      return isSuccess
          ? 'subcontractor_ince_price_accept'
          : 'subcontractor_ince_price_reject';
    } else if (stage == 7) {
      return isSuccess
          ? 'subcontractor_peyzaj_price_accept'
          : 'subcontractor_peyzaj_price_reject';
    } else {
      return isSuccess
          ? 'subcontractor_musavir_price_accept'
          : 'subcontractor_musavir_price_reject';
    }
  }

  static String _getDoubleShiftDialogue(int stage, SubcontractorTier tier, bool isSuccess, Random r) {
    if (stage == 2) {
      return isSuccess
          ? 'subcontractor_hafriyat_shift_accept'
          : 'subcontractor_hafriyat_shift_reject';
    } else if (stage == 3) {
      return isSuccess
          ? 'subcontractor_kalip_shift_accept'
          : 'subcontractor_kalip_shift_reject';
    } else if (stage == 5 || stage == 6) {
      return isSuccess
          ? 'subcontractor_mep_shift_accept'
          : 'subcontractor_mep_shift_reject';
    }
    return isSuccess
        ? 'subcontractor_shift_accept_generic'
        : 'subcontractor_shift_reject_generic';
  }

  static String _getCashMaterialsDialogue(int stage, SubcontractorTier tier, bool isSuccess, Random r) {
    if (stage == 3) {
      return isSuccess
          ? 'subcontractor_kalip_material_accept'
          : 'subcontractor_kalip_material_reject';
    } else if (stage == 5) {
      return isSuccess
          ? 'subcontractor_tesisat_material_accept'
          : 'subcontractor_tesisat_material_reject';
    } else if (stage == 6) {
      return isSuccess
          ? 'subcontractor_ince_material_accept'
          : 'subcontractor_ince_material_reject';
    }
    return isSuccess
        ? 'subcontractor_material_accept_generic'
        : 'subcontractor_material_reject_generic';
  }

  static String _getPenaltyDialogue(int stage, SubcontractorTier tier, bool isSuccess, Random r) {
    if (tier == SubcontractorTier.speed) {
      return isSuccess
          ? 'subcontractor_penalty_accept_speed'
          : 'subcontractor_penalty_reject_speed';
    } else if (tier == SubcontractorTier.budget) {
      return 'subcontractor_penalty_reject_budget';
    }
    return isSuccess
        ? 'subcontractor_penalty_accept_std'
        : 'subcontractor_penalty_reject_std';
  }

  static String _getGuaranteeDialogue(int stage, SubcontractorTier tier, bool isSuccess, Random r) {
    if (tier == SubcontractorTier.speed) {
      return isSuccess
          ? 'subcontractor_guarantee_accept_speed'
          : 'subcontractor_guarantee_reject_speed';
    }
    return isSuccess
        ? 'subcontractor_guarantee_accept_std'
        : 'subcontractor_guarantee_reject_std';
  }

  static String _getTeaDialogue(int stage, SubcontractorTier tier, Random r) {
    final jokes = [
      'subcontractor_tea_reply_1',
      'subcontractor_tea_reply_2',
      'subcontractor_tea_reply_3',
    ];
    return jokes[r.nextInt(jokes.length)];
  }
}
