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
        return 'Araçları otomatik yıkar ve parlatır (Resale Değeri +%7)';
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
        return 'Tutumlu (-%20 Maaş)';
      case StaffPerk.hardWorker:
        return 'Çalışkan (+%25 Hız)';
      case StaffPerk.silverTongue:
        return 'Tatlı Dilli (+%15 İkna)';
      case StaffPerk.meticulous:
        return 'Titiz Usta (+%15 Kalite)';
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
    return bonus;
  }

  /// Part cost discount from staff mastery
  double get costDiscountPercent => (masteryLevel - 1) * 0.05;

  /// Mastery Title display
  String get masteryTitle {
    if (masteryLevel >= 3) return 'Baş Usta';
    if (masteryLevel == 2) return 'Kıdemli Usta';
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
    );
  }
}
