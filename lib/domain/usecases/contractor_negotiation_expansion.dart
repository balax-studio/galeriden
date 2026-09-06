import 'dart:math';
import 'package:flutter/material.dart';
import 'real_estate_chat_negotiation_engine.dart';

enum ContractorPersonality {
  traditional, // Hacı Reşat: Geleneksel, %33'ten başlar, inatçı ama güvenilir, çay ve kurban esprileri
  corporate, // Metropol Yapı: Kurumsal, %42'den başlar, statik, BIM ve mühendislik terimleri
  aggressive, // Kartal Hızlı: Çift vardiya, %36'dan başlar, hızlı teslimat, demir enflasyonu şikayetleri
  luxury, // Boğaziçi Elit: Lüks konsept, %40'tan başlar, C40 beton, İtalyan seramik, prestij odaklı
  cooperative, // Güleryüz Kardeşler: Mahalle esnafı, %38'den başlar, esprili, samimi, uzlaşmacı
}

class ContractorNegotiationProfile {
  final String id;
  final String nameKey;
  final String defaultName;
  final String companyTypeKey;
  final String defaultCompanyType;
  final ContractorPersonality personality;
  final int initialOfferPercent; // e.g. 33, 36, 38, 40, 42
  final int maxCapPercent; // e.g. 50, 52, 55, 58
  final int basePatience; // 80 - 120
  final double reputationScore; // 3.8 - 4.9
  final IconData avatarIcon;
  final Color themeColor;

  const ContractorNegotiationProfile({
    required this.id,
    required this.nameKey,
    required this.defaultName,
    required this.companyTypeKey,
    required this.defaultCompanyType,
    required this.personality,
    required this.initialOfferPercent,
    required this.maxCapPercent,
    required this.basePatience,
    required this.reputationScore,
    required this.avatarIcon,
    required this.themeColor,
  });
}

class ContractorNegotiationExpansion {
  static const List<ContractorNegotiationProfile> contractors = [
    ContractorNegotiationProfile(
      id: 'contractor_haci_resat',
      nameKey: 'contractor_profile_haci_resat_name',
      defaultName: 'Hacı Reşat & Oğulları Yapı',
      companyTypeKey: 'contractor_profile_haci_resat_type',
      defaultCompanyType: 'Geleneksel Müteahhitlik • 42 Yıllık Esnaf',
      personality: ContractorPersonality.traditional,
      initialOfferPercent: 33,
      maxCapPercent: 50,
      basePatience: 110,
      reputationScore: 4.8,
      avatarIcon: Icons.foundation_rounded,
      themeColor: Color(0xFFD97706), // Amber
    ),
    ContractorNegotiationProfile(
      id: 'contractor_kartal_hizli',
      nameKey: 'contractor_profile_kartal_name',
      defaultName: 'Kartal Hızlı Kentsel Dönüşüm',
      companyTypeKey: 'contractor_profile_kartal_type',
      defaultCompanyType: 'Çift Vardiya & Jet Hızlı Şantiye',
      personality: ContractorPersonality.aggressive,
      initialOfferPercent: 36,
      maxCapPercent: 52,
      basePatience: 85,
      reputationScore: 4.3,
      avatarIcon: Icons.bolt_rounded,
      themeColor: Color(0xFFDC2626), // Red
    ),
    ContractorNegotiationProfile(
      id: 'contractor_anadolu_kardesler',
      nameKey: 'contractor_profile_anadolu_name',
      defaultName: 'Güleryüz Kardeşler İnşaat',
      companyTypeKey: 'contractor_profile_anadolu_type',
      defaultCompanyType: 'Mahalle Kooperatifi • Samimi Ortaklık',
      personality: ContractorPersonality.cooperative,
      initialOfferPercent: 38,
      maxCapPercent: 54,
      basePatience: 100,
      reputationScore: 4.5,
      avatarIcon: Icons.handshake_rounded,
      themeColor: Color(0xFF059669), // Emerald
    ),
    ContractorNegotiationProfile(
      id: 'contractor_bogazici_elit',
      nameKey: 'contractor_profile_bogazici_name',
      defaultName: 'Boğaziçi Elit Rezidans & Mimarlık',
      companyTypeKey: 'contractor_profile_bogazici_type',
      defaultCompanyType: 'Lüks Konsept & C40 Akıllı Bina',
      personality: ContractorPersonality.luxury,
      initialOfferPercent: 40,
      maxCapPercent: 56,
      basePatience: 95,
      reputationScore: 4.9,
      avatarIcon: Icons.apartment_rounded,
      themeColor: Color(0xFF7C3AED), // Purple
    ),
    ContractorNegotiationProfile(
      id: 'contractor_metropol_mimarlik',
      nameKey: 'contractor_profile_metropol_name',
      defaultName: 'Metropol Yapı Mimarlık A.Ş.',
      companyTypeKey: 'contractor_profile_metropol_type',
      defaultCompanyType: 'Kurumsal Taahhüt & BIM Statik Tasarım',
      personality: ContractorPersonality.corporate,
      initialOfferPercent: 42,
      maxCapPercent: 58,
      basePatience: 105,
      reputationScore: 4.7,
      avatarIcon: Icons.architecture_rounded,
      themeColor: Color(0xFF2563EB), // Blue
    ),
  ];

  static ContractorNegotiationProfile getContractor(String id) {
    return contractors.firstWhere(
      (c) => c.id == id,
      orElse: () => contractors.first,
    );
  }

  static ContractorNegotiationProfile getRandomContractor(Random random) {
    return contractors[random.nextInt(contractors.length)];
  }

  // --- KÜLT VE KOMİK ŞANTİYE DİYALOGLARI HAVUZU ---
  static const List<String> constructionJokes = [
    'contractor_joke_inspector_tea',
    'contractor_joke_inverted_blueprint',
    'contractor_joke_positive_energy',
    'contractor_joke_mixer_wedding',
    'contractor_joke_monet_painter',
    'contractor_joke_iron_price_moon',
    'contractor_joke_c40_bunker',
    'contractor_joke_plumber_waterfall',
    'contractor_joke_cat_crane',
  ];

  static String getRandomJokeKey(Random random) {
    return constructionJokes[random.nextInt(constructionJokes.length)];
  }

  // --- DİNAMİK AŞAMALI KAT KARŞILIĞI PAZARLIK KULVARLARI ---
  static const List<ContractorTacticTrackDef> tacticTracks = [
    ContractorTacticTrackDef(
      id: 'share',
      stages: [
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_share_label_0',
          messageKey: 'contractor_tactic_share_msg_0',
          tacticType: ChatTacticType.demandHigherShare,
          icon: Icons.trending_up_rounded,
          chipColor: Color(0xFFEFF6FF),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_share_label_1',
          messageKey: 'contractor_tactic_share_msg_1',
          tacticType: ChatTacticType.demandHigherShare,
          icon: Icons.bar_chart_rounded,
          chipColor: Color(0xFFEFF6FF),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_share_label_2',
          messageKey: 'contractor_tactic_share_msg_2',
          tacticType: ChatTacticType.demandHigherShare,
          icon: Icons.gavel_rounded,
          chipColor: Color(0xFFDBEAFE),
        ),
      ],
    ),
    ContractorTacticTrackDef(
      id: 'primeFloors',
      stages: [
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_floors_label_0',
          messageKey: 'contractor_tactic_floors_msg_0',
          tacticType: ChatTacticType.demandPrimeFloors,
          icon: Icons.view_day_rounded,
          chipColor: Color(0xFFF3E8FF),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_floors_label_1',
          messageKey: 'contractor_tactic_floors_msg_1',
          tacticType: ChatTacticType.demandPrimeFloors,
          icon: Icons.wb_sunny_rounded,
          chipColor: Color(0xFFF3E8FF),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_floors_label_2',
          messageKey: 'contractor_tactic_floors_msg_2',
          tacticType: ChatTacticType.demandPrimeFloors,
          icon: Icons.deck_rounded,
          chipColor: Color(0xFFE9D5FF),
        ),
      ],
    ),
    ContractorTacticTrackDef(
      id: 'quality',
      stages: [
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_quality_label_0',
          messageKey: 'contractor_tactic_quality_msg_0',
          tacticType: ChatTacticType.demandQualityUpgrade,
          icon: Icons.verified_rounded,
          chipColor: Color(0xFFFEF3C7),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_quality_label_1',
          messageKey: 'contractor_tactic_quality_msg_1',
          tacticType: ChatTacticType.demandQualityUpgrade,
          icon: Icons.home_repair_service_rounded,
          chipColor: Color(0xFFFEF3C7),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_quality_label_2',
          messageKey: 'contractor_tactic_quality_msg_2',
          tacticType: ChatTacticType.demandQualityUpgrade,
          icon: Icons.elevator_rounded,
          chipColor: Color(0xFFFDE68A),
        ),
      ],
    ),
    ContractorTacticTrackDef(
      id: 'advance',
      stages: [
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_advance_label_0',
          messageKey: 'contractor_tactic_advance_msg_0',
          tacticType: ChatTacticType.demandAdvanceDeposit,
          icon: Icons.payments_rounded,
          chipColor: Color(0xFFFEE2E2),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_advance_label_1',
          messageKey: 'contractor_tactic_advance_msg_1',
          tacticType: ChatTacticType.demandAdvanceDeposit,
          icon: Icons.price_change_rounded,
          chipColor: Color(0xFFFEE2E2),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_advance_label_2',
          messageKey: 'contractor_tactic_advance_msg_2',
          tacticType: ChatTacticType.demandAdvanceDeposit,
          icon: Icons.local_shipping_rounded,
          chipColor: Color(0xFFFECACA),
        ),
      ],
    ),
    ContractorTacticTrackDef(
      id: 'guarantee',
      stages: [
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_guarantee_label_0',
          messageKey: 'contractor_tactic_guarantee_msg_0',
          tacticType: ChatTacticType.demandBankGuarantee,
          icon: Icons.security_rounded,
          chipColor: Color(0xFFE0E7FF),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_guarantee_label_1',
          messageKey: 'contractor_tactic_guarantee_msg_1',
          tacticType: ChatTacticType.demandPenaltyClause,
          icon: Icons.history_edu_rounded,
          chipColor: Color(0xFFE0E7FF),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_guarantee_label_2',
          messageKey: 'contractor_tactic_guarantee_msg_2',
          tacticType: ChatTacticType.demandBankGuarantee,
          icon: Icons.policy_rounded,
          chipColor: Color(0xFFC7D2FE),
        ),
      ],
    ),
    ContractorTacticTrackDef(
      id: 'tea',
      stages: [
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_tea_label_0',
          messageKey: 'contractor_tactic_tea_msg_0',
          tacticType: ChatTacticType.askJokeOrChat,
          icon: Icons.local_cafe_rounded,
          chipColor: Color(0xFFD1FAE5),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_tea_label_1',
          messageKey: 'contractor_tactic_tea_msg_1',
          tacticType: ChatTacticType.askJokeOrChat,
          icon: Icons.bakery_dining_rounded,
          chipColor: Color(0xFFD1FAE5),
        ),
        ContractorTacticStageDef(
          labelKey: 'contractor_tactic_tea_label_2',
          messageKey: 'contractor_tactic_tea_msg_2',
          tacticType: ChatTacticType.askJokeOrChat,
          icon: Icons.handshake_rounded,
          chipColor: Color(0xFFA7F3D0),
        ),
      ],
    ),
  ];

  /// Kişiliğe özgü genişletilmiş pay pazarlığı yanıtı üretir
  static String getShareResponse({
    required ContractorPersonality personality,
    required bool isAccepted,
    required int nextShare,
    required Random random,
  }) {
    if (isAccepted) {
      switch (personality) {
        case ContractorPersonality.traditional:
          final pool = [
            'Biz dededen beri hak yemeyiz arsa sahibi kardeşim • Gönlünüz hoş olsun, payınızı %$nextShare yapıyoruz • Yalnız temel kurbanını beraber keseriz.',
            'Sözünüz yerde kalmasın • Bu muhitte arsa payını %$nextShare seviyesine çektik • Yüzümüzün akıyla bitirmek nasip olsun.',
            'Pazarlığınız çetin ama niyetiniz halis • %$nextShare payı kabul ettik, sözleşmeye yazdırıyorum • Bereketini görelim.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.aggressive:
          final pool = [
            'Tamamdır patron • %$nextShare payı bağladık • Yarın sabah kepçeyi arsaya sokuyoruz, 14 ayda anahtar teslim!',
            'Hızlı karar vereni severiz • %$nextShare kabul, çift vardiya döneceğiz • Gece lambaları yakın, şantiye uyumayacak!',
            'Pazarlık bitti • %$nextShare pay onaylandı • Mikserleri sıraya diziyoruz, bu projeyi rekor sürede dikeceğiz.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.cooperative:
          final pool = [
            'Biz yabancı değiliz, mahallenin çocuğuyuz • Payınızı %$nextShare yaptık • Hep beraber güzel bir bina dikelim komşum.',
            'Gönüller bir olsun • %$nextShare payı kabul ediyoruz • Malzemeden çalmadan, komşuluk hukukunu çiğnemeden bitireceğiz.',
            'Ortaklık dediğin böyle olur • %$nextShare olarak anlaştık • Çayımızı içip temel harcını atalım.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.luxury:
          final pool = [
            'Mimari vizyonumuza güveniniz için teşekkür ederiz • Prestij projemizde arsa payınızı %$nextShare olarak revize ettik.',
            'Kabul • %$nextShare pay ve C40 brüt beton tasarımıyla bölgenin en seçkin rezidansını inşa edeceğiz.',
            'Seçkin lokasyonunuza yakışan budur • Payınızı %$nextShare yaptık, mimari detayları imzalıyoruz.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.corporate:
          final pool = [
            'Risk ve fizibilite komitemiz onay verdi • Arsa payınız kurumsal sistemimizde %$nextShare olarak revize edildi.',
            'BIM simülasyonu güncellendi • %$nextShare pay taahhüdü sözleşme şartnamesine eklenmiştir.',
            'Kurumsal portföyümüze değer katacak bir parsel • %$nextShare pay oranını onayladık.',
          ];
          return pool[random.nextInt(pool.length)];
      }
    } else {
      switch (personality) {
        case ContractorPersonality.traditional:
          final pool = [
            'Aman kardeşim, demirin tonu dolara bağlı, çimento fabrikası peşin para istiyor • %$nextShare payın üstü bizi batırır, kurtarmaz.',
            'Biz esnafız, boş vaat verip yarım bırakmayız • %$nextShare pay bu arsa için azami sınırımızdır, fazlası haram olur.',
            'Fizibilite cetvelini önümüze koyduk, kolon demiri maliyeti ortada • Daha fazla pay verirsek işçinin yevmiyesini ödeyemeyiz.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.aggressive:
          final pool = [
            'Olmaz patron • Çift vardiya jeneratör yakıtı ve gece işçilik primi bütçeyi zorluyor • %$nextShare son limitimiz!',
            'Dakikalarla yarışıyoruz, bu payın üstüne çıkarsak hızımız kesilir • %$nextShare teklifimiz nettir.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.cooperative:
          final pool = [
            'Komşum aramızda lafı olmaz ama demirciye, kalıpçıya da hakkını vereceğiz • %$nextShare üzerine çıkamayız, anlayış gösterin.',
            'Kooperatif bütçemiz sınırlı, fazla açılırsak şantiyeyi zora sokarız • %$nextShare mahallemiz için en adil orandır.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.luxury:
          final pool = [
            'Projemiz lüks İtalyan seramik ve akıllı bina altyapısı içeriyor • %$nextShare payın üzerinde mimari kaliteden ödün vermek zorunda kalırız.',
            'Rezidans standartlarımızdaki malzeme maliyeti bellidir • %$nextShare pay fizibilitemizin tavanıdır.',
          ];
          return pool[random.nextInt(pool.length)];
        case ContractorPersonality.corporate:
          final pool = [
            'Mali denetim ve risk parametrelerimiz %$nextShare üzerindeki oranlara izin vermemektedir.',
            'Kurumsal taahhüt politikamız gereği fizibilite sınırını aşan teklifleri onaylayamıyoruz • %$nextShare nihaidir.',
          ];
          return pool[random.nextInt(pool.length)];
      }
    }
  }
}

class ContractorTacticStageDef {
  final String labelKey;
  final String messageKey;
  final ChatTacticType tacticType;
  final IconData icon;
  final Color chipColor;

  const ContractorTacticStageDef({
    required this.labelKey,
    required this.messageKey,
    required this.tacticType,
    required this.icon,
    required this.chipColor,
  });
}

class ContractorTacticTrackDef {
  final String id;
  final List<ContractorTacticStageDef> stages;

  const ContractorTacticTrackDef({
    required this.id,
    required this.stages,
  });
}
