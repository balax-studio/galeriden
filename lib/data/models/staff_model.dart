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

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.hiredAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'hiredAt': hiredAt.toIso8601String(),
    };
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: StaffRole.values.firstWhere((r) => r.name == json['role']),
      hiredAt: DateTime.parse(json['hiredAt'] as String),
    );
  }
}
