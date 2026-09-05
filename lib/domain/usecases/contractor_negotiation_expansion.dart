import 'dart:math';
import 'package:flutter/material.dart';

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
}
