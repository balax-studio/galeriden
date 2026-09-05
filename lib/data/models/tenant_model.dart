import 'dart:math';

class TenantModel {
  final String id;
  final String name;
  final String profession;
  final int reliabilityScore; // 1-100 (90+ Yüksek, 70-89 Güvenilir, <70 Riskli)
  final double monthlyRent;
  final double depositAmount;
  final int evictionRiskScore; // % tahliye / gecikme riski
  final int leaseStartDay;
  final int unpaidRentDays;

  const TenantModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.reliabilityScore,
    required this.monthlyRent,
    required this.depositAmount,
    this.evictionRiskScore = 5,
    this.leaseStartDay = 1,
    this.unpaidRentDays = 0,
  });

  double get dailyRent => (monthlyRent / 30).roundToDouble();

  String get reliabilityGrade {
    if (reliabilityScore >= 90) return 'A+';
    if (reliabilityScore >= 80) return 'A';
    if (reliabilityScore >= 65) return 'B';
    return 'C';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profession': profession,
      'reliabilityScore': reliabilityScore,
      'monthlyRent': monthlyRent,
      'depositAmount': depositAmount,
      'evictionRiskScore': evictionRiskScore,
      'leaseStartDay': leaseStartDay,
      'unpaidRentDays': unpaidRentDays,
    };
  }

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id'] as String? ?? 'tenant_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Kiracı',
      profession: json['profession'] as String? ?? 'Memur',
      reliabilityScore: json['reliabilityScore'] as int? ?? 85,
      monthlyRent: (json['monthlyRent'] as num?)?.toDouble() ?? 10000.0,
      depositAmount: (json['depositAmount'] as num?)?.toDouble() ?? 20000.0,
      evictionRiskScore: json['evictionRiskScore'] as int? ?? 5,
      leaseStartDay: json['leaseStartDay'] as int? ?? 1,
      unpaidRentDays: json['unpaidRentDays'] as int? ?? 0,
    );
  }

  TenantModel copyWith({
    String? id,
    String? name,
    String? profession,
    int? reliabilityScore,
    double? monthlyRent,
    double? depositAmount,
    int? evictionRiskScore,
    int? leaseStartDay,
    int? unpaidRentDays,
  }) {
    return TenantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      reliabilityScore: reliabilityScore ?? this.reliabilityScore,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      depositAmount: depositAmount ?? this.depositAmount,
      evictionRiskScore: evictionRiskScore ?? this.evictionRiskScore,
      leaseStartDay: leaseStartDay ?? this.leaseStartDay,
      unpaidRentDays: unpaidRentDays ?? this.unpaidRentDays,
    );
  }

  static List<TenantModel> generateCandidates({
    required double baseMonthlyRent,
    int count = 3,
    Random? rng,
  }) {
    final random = rng ?? Random();
    final names = [
      'Burak Çelik',
      'Av. Selin Kaya',
      'Dr. Mert Öztürk',
      'Mimar Cenk Demir',
      'Öğretmen Ayşe Yılmaz',
      'Yazılımcı Eren Koç',
      'Bankacı Zeynep Arslan',
      'Eczacı Murat Aydın',
      'Üniversite Öğrencisi Can',
      'Esnaf Hasan Usta',
    ];
    final professions = [
      'Kıdemli Yazılım Mühendisi',
      'Kurumsal Hukuk Müşaviri',
      'Uzman Doktor',
      'Mimar & İç Mimar',
      'Devlet Memuru',
      'Banka Müfettişi',
      'Eczacı',
      'Üniversite Öğrencisi',
      'Mahalle Esnafı',
      'Finans Analisti',
    ];

    final candidates = <TenantModel>[];
    for (int i = 0; i < count; i++) {
      final nameIndex = (random.nextInt(names.length) + i) % names.length;
      final profIndex = (random.nextInt(professions.length) + i) % professions.length;

      // Variance in rent offer (-10% to +20%)
      final variance = 0.90 + (random.nextDouble() * 0.30);
      final offeredRent = ((baseMonthlyRent * variance) / 250).round() * 250.0;
      final deposit = offeredRent * (random.nextBool() ? 2 : 1);

      // Reliability correlated inversely with high/irregular offers
      final reliability = variance > 1.12
          ? (50 + random.nextInt(25)) // high offer often higher risk
          : (75 + random.nextInt(23)); // market offer more reliable

      final evictionRisk = (100 - reliability).clamp(3, 45);

      candidates.add(
        TenantModel(
          id: 'tenant_candidate_${DateTime.now().millisecondsSinceEpoch}_$i',
          name: names[nameIndex],
          profession: professions[profIndex],
          reliabilityScore: reliability,
          monthlyRent: offeredRent,
          depositAmount: deposit,
          evictionRiskScore: evictionRisk,
          leaseStartDay: 1,
        ),
      );
    }
    return candidates;
  }
}
