import 'package:flutter/material.dart';

enum StaffRole {
  washer,
  apprentice,
  salesman,
  masterMechanic,
  appraiser,
  marketer,
  legalAdvisor,
}

extension StaffRoleExtension on StaffRole {
  String get title {
    switch (this) {
      case StaffRole.washer:
        return 'Oto Yıkama & Detay Uzmanı';
      case StaffRole.apprentice:
        return 'Kaportacı Çırağı';
      case StaffRole.salesman:
        return 'Satış Danışmanı';
      case StaffRole.masterMechanic:
        return 'Mekanik Usta';
      case StaffRole.appraiser:
        return 'Ekspertiz & Değerleme Uzmanı';
      case StaffRole.marketer:
        return 'Dijital Pazarlamacı & İlan Yöneticisi';
      case StaffRole.legalAdvisor:
        return 'Hukuk & Finans Danışmanı';
    }
  }

  String get description {
    switch (this) {
      case StaffRole.washer:
        return 'Araçları otomatik yıkar ve parlatır • Resale Değeri +%7';
      case StaffRole.apprentice:
        return 'Yedek parça kargo ve tamir sürelerini %30 hızlandırır';
      case StaffRole.salesman:
        return 'Müşterilerden %10 daha yüksek pazarlık teklifi almanızı sağlar';
      case StaffRole.masterMechanic:
        return 'Ekspertizsiz alımlarda gizli ayıpları %100 ortaya çıkarır';
      case StaffRole.appraiser:
        return 'Piyasa araçlarının gerçek değer sapmasını sıfırlar ve net kârı gösterir';
      case StaffRole.marketer:
        return 'Vitrin araçlarının müşteri çekme ve görüntülenme hızını +%50 artırır';
      case StaffRole.legalAdvisor:
        return 'Günlük kurum vergisini %20 düşürür, icra ve tahsilat sürelerini hızlandırır';
    }
  }

  double get dailySalary {
    switch (this) {
      case StaffRole.washer:
        return 1200;
      case StaffRole.apprentice:
        return 1800;
      case StaffRole.salesman:
        return 2500;
      case StaffRole.masterMechanic:
        return 3500;
      case StaffRole.appraiser:
        return 3000;
      case StaffRole.marketer:
        return 2200;
      case StaffRole.legalAdvisor:
        return 4000;
    }
  }

  double get hireFee => dailySalary * 3.5;

  /// Required feature route to hire this staff role
  String get requiredFeatureRoute {
    switch (this) {
      case StaffRole.washer:
        return '/car-wash';
      case StaffRole.apprentice:
      case StaffRole.masterMechanic:
        return '/workshop';
      case StaffRole.appraiser:
        return '/expertise';
      case StaffRole.salesman:
        return '/showroom';
      case StaffRole.marketer:
        return '/photography-studio';
      case StaffRole.legalAdvisor:
        return '/bank';
    }
  }

  /// Human-readable required facility name
  String get requiredFacilityName {
    switch (this) {
      case StaffRole.washer:
        return 'Oto Yıkama & Detailing İstasyonu';
      case StaffRole.apprentice:
      case StaffRole.masterMechanic:
        return 'Oto Tamir Atölyesi';
      case StaffRole.appraiser:
        return 'Kurumsal Ekspertiz İstasyonu';
      case StaffRole.salesman:
        return 'Galeri Vitrini';
      case StaffRole.marketer:
        return 'Fotoğraf & İlan Stüdyosu';
      case StaffRole.legalAdvisor:
        return 'Finans & Hukuk Ofisi';
    }
  }

  String get iconType {
    switch (this) {
      case StaffRole.washer:
        return 'car';
      case StaffRole.apprentice:
        return 'workshop';
      case StaffRole.salesman:
        return 'negotiation';
      case StaffRole.masterMechanic:
        return 'expertise';
      case StaffRole.appraiser:
        return 'search';
      case StaffRole.marketer:
        return 'campaign';
      case StaffRole.legalAdvisor:
        return 'gavel';
    }
  }
}

enum StaffPerk {
  thrifty,     // Maaş beklentisi %20 daha düşük
  hardWorker,  // Verimlilik %25 daha yüksek
  silverTongue,// Müşteri ikna başarısı +%15
  meticulous,  // İş hata payı sıfıra yakın
}

extension StaffPerkExtension on StaffPerk {
  String get title {
    switch (this) {
      case StaffPerk.thrifty:
        return 'Tutumlu • -%20 Maaş';
      case StaffPerk.hardWorker:
        return 'Çalışkan • +%25 Hız';
      case StaffPerk.silverTongue:
        return 'Tatlı Dilli • +%15 İkna';
      case StaffPerk.meticulous:
        return 'Titiz Usta • +%15 Kalite';
    }
  }

  IconData get vectorIcon {
    switch (this) {
      case StaffPerk.thrifty:
        return Icons.savings_rounded;
      case StaffPerk.hardWorker:
        return Icons.bolt_rounded;
      case StaffPerk.silverTongue:
        return Icons.record_voice_over_rounded;
      case StaffPerk.meticulous:
        return Icons.search_rounded;
    }
  }

  String get icon => '';
}

class TeamSynergy {
  final String id;
  final String title;
  final String description;
  final String icon;

  IconData get vectorIcon {
    switch (id) {
      case 'synergy_sales_force':
        return Icons.trending_up_rounded;
      case 'synergy_full_workshop':
        return Icons.build_circle_rounded;
      case 'synergy_legal_shield':
        return Icons.security_rounded;
      case 'synergy_corporate_culture':
      default:
        return Icons.business_rounded;
    }
  }

  const TeamSynergy({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '',
  });
}

class TeamSynergyEngine {
  static List<TeamSynergy> calculateSynergies(List<StaffModel> staff) {
    final List<TeamSynergy> active = [];
    final roles = staff.map((s) => s.role).toSet();

    if (roles.contains(StaffRole.salesman) && roles.contains(StaffRole.marketer)) {
      active.add(const TeamSynergy(
        id: 'synergy_sales_force',
        title: 'Hızlı Satış Gücü',
        description: 'Pazarlama ve satış entegrasyonu sayesinde araçlar %25 daha hızlı satılır.',
      ));
    }

    if (roles.contains(StaffRole.masterMechanic) && roles.contains(StaffRole.apprentice)) {
      active.add(const TeamSynergy(
        id: 'synergy_full_workshop',
        title: 'Tam Teşekküllü Atölye',
        description: 'Usta-çırak uyumu ile parça tamir ve boya süreleri %40 hızlanır.',
      ));
    }

    if (roles.contains(StaffRole.legalAdvisor) && roles.contains(StaffRole.appraiser)) {
      active.add(const TeamSynergy(
        id: 'synergy_legal_shield',
        title: 'Kurumsal Finans & Hukuk Kalkanı',
        description: 'Tüm ticari alımlarda ve vergi dönemlerinde %20 gider indirimi sağlar.',
      ));
    }

    if (staff.length >= 4) {
      active.add(const TeamSynergy(
        id: 'synergy_corporate_culture',
        title: 'Kurumsal Bayi Kültürü',
        description: 'Geniş ekip sayesinde bayi prestij puanı ve müşteri güveni en üst seviyeye çıkar.',
      ));
    }

    return active;
  }
}

class StaffTrainingCourse {
  final String id;
  final StaffRole role;
  final String title;
  final String description;
  final String bonusSummary;
  final double cost;
  final IconData icon;
  final Color color;

  const StaffTrainingCourse({
    required this.id,
    required this.role,
    required this.title,
    required this.description,
    required this.bonusSummary,
    required this.cost,
    required this.icon,
    required this.color,
  });
}

class StaffRoleSpecializations {
  static const List<StaffTrainingCourse> allCourses = [
    // 1. Washer Courses
    StaffTrainingCourse(
      id: 'train_washer_ceramic',
      role: StaffRole.washer,
      title: 'Seramik Kaplama & İleri Boya Koruma',
      description: 'Detaylı temizlikte araçlara nano boya koruması uygular ve temizlik değer artışını güçlendirir.',
      bonusSummary: 'Yıkama Değer Katkısı +%3 • Hız +%20',
      cost: 6000,
      icon: Icons.auto_fix_high_rounded,
      color: Color(0xFF06B6D4),
    ),
    StaffTrainingCourse(
      id: 'train_washer_interior_ozone',
      role: StaffRole.washer,
      title: 'VIP Medikal Ozon & İç Kuaför Ustalığı',
      description: 'Koltuk ve tavan temizliğinde derinlemesine hijyen sağlayarak alıcı beğenisini artırır.',
      bonusSummary: 'İç Temizlik Bonusu +%4 • Moral +25',
      cost: 14000,
      icon: Icons.sanitizer_rounded,
      color: Color(0xFF3B82F6),
    ),

    // 2. Apprentice Courses
    StaffTrainingCourse(
      id: 'train_appr_fast_dismantle',
      role: StaffRole.apprentice,
      title: 'Hızlı Parça Söküm & Takım Düzeni',
      description: 'Hurdalık ve atölye parça söküm işlemlerini hızlandırır, takım kaybını sıfırlar.',
      bonusSummary: 'Parça Söküm Hızı +%35',
      cost: 5000,
      icon: Icons.handyman_rounded,
      color: Color(0xFFF59E0B),
    ),
    StaffTrainingCourse(
      id: 'train_appr_pdr_sheet',
      role: StaffRole.apprentice,
      title: 'Boyasız Göçük Düzeltme & Zımpara',
      description: 'Ustanın yanındaki destek verimliliğini artırarak kaporta tamir hata payını azaltır.',
      bonusSummary: 'Tamir Başarı Şansı +%20 • Hata -%50',
      cost: 12000,
      icon: Icons.hardware_rounded,
      color: Color(0xFFF97316),
    ),

    // 3. Salesman Courses
    StaffTrainingCourse(
      id: 'train_sales_persuasion',
      role: StaffRole.salesman,
      title: 'Müşteri İkna & Kapora Kapatma',
      description: 'Pazarlık masasında alıcıların ölücü tekliflerini kırar ve karlı satış olasılığını yükseltir.',
      bonusSummary: 'Alıcı Teklif Kabul +%15 • İkna +%20',
      cost: 10000,
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFEAB308),
    ),
    StaffTrainingCourse(
      id: 'train_sales_vip_portfolio',
      role: StaffRole.salesman,
      title: 'VIP Koleksiyon & Zengin Portföy Yönetimi',
      description: 'Nadir ve lüks araçlar için zengin koleksiyoner alıcıları vitrine daha sık çeker.',
      bonusSummary: 'Lüks Araç Satış Hızı +%35 • Prestij +15',
      cost: 24000,
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFA855F7),
    ),

    // 4. Master Mechanic Courses
    StaffTrainingCourse(
      id: 'train_mech_advanced_diag',
      role: StaffRole.masterMechanic,
      title: 'Motor & Şanzıman İleri Teşhis Uzmanlığı',
      description: 'Ekspertizsiz kelepir alımlarda gizli motor arızalarını %100 oranında tespit eder.',
      bonusSummary: 'Gizli Ayıp Tespiti %100 • Tamir Maliyeti -%20',
      cost: 18000,
      icon: Icons.build_circle_rounded,
      color: Color(0xFFEF4444),
    ),
    StaffTrainingCourse(
      id: 'train_mech_dyno_ecu',
      role: StaffRole.masterMechanic,
      title: 'Dyno & Stage Yazılım Kalibrasyonu',
      description: 'Performans yazılımlarını ve motor rektifiye işlemlerini en yüksek tork verimiyle tamamlar.',
      bonusSummary: 'Tuning Başarı Oranı +%30 • Motor Gücü +%10',
      cost: 35000,
      icon: Icons.speed_rounded,
      color: Color(0xFFDC2626),
    ),

    // 5. Appraiser Courses
    StaffTrainingCourse(
      id: 'train_appr_micron_paint',
      role: StaffRole.appraiser,
      title: 'Mikron Boya & Şasi Teşhis Sertifikası',
      description: 'Lokal boya ve değişen parçaları anında tarayarak ekspertiz raporlama süresini yarıya indirir.',
      bonusSummary: 'Ekspertiz Hızı x2 • Doğruluk %100',
      cost: 15000,
      icon: Icons.fact_check_rounded,
      color: Color(0xFF10B981),
    ),
    StaffTrainingCourse(
      id: 'train_appr_market_arbitrage',
      role: StaffRole.appraiser,
      title: 'Tramer & Piyasa Değerleme Analizi',
      description: 'Piyasadaki kelepir araç fırsatlarını algılar ve anlık tahmini kâr marjını net gösterir.',
      bonusSummary: 'Fırsat İlan Tespiti +%40 • Net Kâr Analizi',
      cost: 28000,
      icon: Icons.query_stats_rounded,
      color: Color(0xFF059669),
    ),

    // 6. Marketer Courses
    StaffTrainingCourse(
      id: 'train_mkt_viral_ad',
      role: StaffRole.marketer,
      title: 'Viral İlan & Sosyal Medya Tasarımı',
      description: 'İlan fotoğraflarını ve başlıklarını ilgi çekici kılarak vitrin görüntülenmesini katlar.',
      bonusSummary: 'Vitrin İlan Görüntülenme +%60',
      cost: 8000,
      icon: Icons.campaign_rounded,
      color: Color(0xFFEC4899),
    ),
    StaffTrainingCourse(
      id: 'train_mkt_target_ads',
      role: StaffRole.marketer,
      title: 'Bölgesel Reklam & Müşteri Trafiği',
      description: 'Galeriye fiziksel ve sanal alıcı trafiği çekerek araçların bekleme süresini azaltır.',
      bonusSummary: 'Alıcı Teklif Gelme Hızı +%50',
      cost: 20000,
      icon: Icons.trending_up_rounded,
      color: Color(0xFFDB2777),
    ),

    // 7. Legal Advisor Courses
    StaffTrainingCourse(
      id: 'train_legal_tax_shield',
      role: StaffRole.legalAdvisor,
      title: 'Vergi İndirimi & Gider Muhasebesi',
      description: 'Resmi şirket giderlerini ve bayi vergi kesintilerini yasal indirimlerle düşürür.',
      bonusSummary: 'Günlük Vergi Kesintisi -%25',
      cost: 16000,
      icon: Icons.shield_rounded,
      color: Color(0xFF6366F1),
    ),
    StaffTrainingCourse(
      id: 'train_legal_fast_factoring',
      role: StaffRole.legalAdvisor,
      title: 'Çek & Senet İcra Tahsilat Kalkanı',
      description: 'Vadeli müşteri senetlerinin karşılıksız çıkma riskini engeller ve tahsilatı hızlandırır.',
      bonusSummary: 'Faktoring Komisyon İndirimi -%40',
      cost: 32000,
      icon: Icons.gavel_rounded,
      color: Color(0xFF4F46E5),
    ),
  ];

  static List<StaffTrainingCourse> coursesForRole(StaffRole role) {
    return allCourses.where((c) => c.role == role).toList();
  }
}

class StaffModel {
  final String id;
  final String name;
  final StaffRole role;
  final DateTime hiredAt;
  final double salaryMultiplier;
  final int tasksCompleted;
  final int masteryLevel;
  final String? specialization;
  final int morale; // 0 to 100
  final StaffPerk? perk;
  final double profitContributed;
  final List<String> completedCourseIds;

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.hiredAt,
    this.salaryMultiplier = 1.0,
    this.tasksCompleted = 0,
    this.masteryLevel = 1,
    this.specialization,
    this.morale = 100,
    this.perk,
    this.profitContributed = 0.0,
    this.completedCourseIds = const [],
  });

  /// Effective daily salary considering raises, perks, and multipliers
  double get dailySalary {
    double base = role.dailySalary * salaryMultiplier;
    if (perk == StaffPerk.thrifty) {
      base *= 0.85;
    }
    return base;
  }

  /// Speed bonus multiplier gained from experience & perks
  double get speedMultiplier {
    double bonus = 1.0 + (masteryLevel * 0.15);
    if (perk == StaffPerk.hardWorker) bonus += 0.20;
    if (morale > 80) bonus += 0.10;
    if (completedCourseIds.isNotEmpty) bonus += completedCourseIds.length * 0.10;
    return bonus;
  }

  /// Part cost discount from staff mastery
  double get costDiscountPercent => (masteryLevel - 1) * 0.05 + (completedCourseIds.length * 0.03);

  /// Mastery Title display
  String get masteryTitle {
    if (masteryLevel >= 3 || completedCourseIds.length >= 2) return 'Baş Usta';
    if (masteryLevel == 2 || completedCourseIds.isNotEmpty) return 'Kıdemli Usta';
    return role.title;
  }

  StaffModel copyWith({
    String? id,
    String? name,
    StaffRole? role,
    DateTime? hiredAt,
    double? salaryMultiplier,
    int? tasksCompleted,
    int? masteryLevel,
    String? specialization,
    int? morale,
    StaffPerk? perk,
    double? profitContributed,
    List<String>? completedCourseIds,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      hiredAt: hiredAt ?? this.hiredAt,
      salaryMultiplier: salaryMultiplier ?? this.salaryMultiplier,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      specialization: specialization ?? this.specialization,
      morale: morale ?? this.morale,
      perk: perk ?? this.perk,
      profitContributed: profitContributed ?? this.profitContributed,
      completedCourseIds: completedCourseIds ?? this.completedCourseIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'hiredAt': hiredAt.toIso8601String(),
      'salaryMultiplier': salaryMultiplier,
      'tasksCompleted': tasksCompleted,
      'masteryLevel': masteryLevel,
      'specialization': specialization,
      'morale': morale,
      'perk': perk?.name,
      'profitContributed': profitContributed,
      'completedCourseIds': completedCourseIds,
    };
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: StaffRole.values.firstWhere((r) => r.name == json['role']),
      hiredAt: DateTime.parse(json['hiredAt'] as String),
      salaryMultiplier: (json['salaryMultiplier'] as num?)?.toDouble() ?? 1.0,
      tasksCompleted: json['tasksCompleted'] as int? ?? 0,
      masteryLevel: json['masteryLevel'] as int? ?? 1,
      specialization: json['specialization'] as String?,
      morale: json['morale'] as int? ?? 100,
      perk: json['perk'] != null ? StaffPerk.values.firstWhere((p) => p.name == json['perk'], orElse: () => StaffPerk.hardWorker) : null,
      profitContributed: (json['profitContributed'] as num?)?.toDouble() ?? 0.0,
      completedCourseIds: (json['completedCourseIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }
}
