enum StaffRole {
  washer,
  apprentice,
  salesman,
  masterMechanic,
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
    }
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

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.hiredAt,
    this.salaryMultiplier = 1.0,
    this.tasksCompleted = 0,
    this.masteryLevel = 1,
    this.specialization,
  });

  /// Effective daily salary considering raises and multipliers
  double get dailySalary => role.dailySalary * salaryMultiplier;

  /// Speed bonus multiplier gained from experience
  double get speedMultiplier => 1.0 + (masteryLevel * 0.15);

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
    );
  }
}
