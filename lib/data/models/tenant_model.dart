import 'dart:math';

enum TenantEvaluationStatus {
  evaluating,
  accepted,
  counterOffer,
  rejected,
}

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
  final TenantEvaluationStatus evaluationStatus;
  final String evaluationThought;
  final int inspectionRemainingSeconds;
  final int desiredLeaseYears;

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
    this.evaluationStatus = TenantEvaluationStatus.accepted,
    this.evaluationThought = '',
    this.inspectionRemainingSeconds = 0,
    this.desiredLeaseYears = 1,
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
      'evaluationStatus': evaluationStatus.name,
      'evaluationThought': evaluationThought,
      'inspectionRemainingSeconds': inspectionRemainingSeconds,
      'desiredLeaseYears': desiredLeaseYears,
    };
  }

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    TenantEvaluationStatus evalStatus = TenantEvaluationStatus.accepted;
    if (json['evaluationStatus'] != null) {
      evalStatus = TenantEvaluationStatus.values.firstWhere(
        (e) => e.name == json['evaluationStatus'],
        orElse: () => TenantEvaluationStatus.accepted,
      );
    }

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
      evaluationStatus: evalStatus,
      evaluationThought: json['evaluationThought'] as String? ?? '',
      inspectionRemainingSeconds: json['inspectionRemainingSeconds'] as int? ?? 0,
      desiredLeaseYears: json['desiredLeaseYears'] as int? ?? 1,
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
    TenantEvaluationStatus? evaluationStatus,
    String? evaluationThought,
    int? inspectionRemainingSeconds,
    int? desiredLeaseYears,
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
      evaluationStatus: evaluationStatus ?? this.evaluationStatus,
      evaluationThought: evaluationThought ?? this.evaluationThought,
      inspectionRemainingSeconds:
          inspectionRemainingSeconds ?? this.inspectionRemainingSeconds,
      desiredLeaseYears: desiredLeaseYears ?? this.desiredLeaseYears,
    );
  }

  static List<TenantModel> generateCandidates({
    required double baseMonthlyRent,
    int count = 3,
    Random? rng,
    int? buildingAge,
    String? propertyTitle,
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

      // Determine evaluation status and thought
      TenantEvaluationStatus status;
      String thought;
      int seconds = 0;

      if (i == 0) {
        status = TenantEvaluationStatus.accepted;
        thought =
            'Mülkün konumu ve planı çok güzel • Rayiç bedel bütçeme uygun, hemen imzalamak isterim.';
      } else if (i == 1) {
        status = TenantEvaluationStatus.evaluating;
        seconds = 10 + random.nextInt(6);
        thought =
            'Dairenin tesisatını, cephesini ve otopark durumunu yerinde inceliyor...';
      } else {
        if (random.nextBool()) {
          status = TenantEvaluationStatus.rejected;
          if (buildingAge != null && buildingAge > 8) {
            thought =
                'Bina yaşı biraz eski ve masraf görünüyor • Bu koşullarda mülkü tutmayı düşünmüyorum.';
          } else {
            thought =
                'Kira bedeli bu muhit için oldukça yüksek • Fiyat şişirilmiş, teklifi reddediyorum.';
          }
        } else {
          status = TenantEvaluationStatus.counterOffer;
          thought =
              'Lokasyon iş yerime yakın ancak kira bütçemi biraz zorluyor • Fiyatta pazarlık talep ediyorum.';
        }
      }

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
          evaluationStatus: status,
          evaluationThought: thought,
          inspectionRemainingSeconds: seconds,
          desiredLeaseYears: random.nextBool() ? 2 : 1,
        ),
      );
    }
    return candidates;
  }
}
