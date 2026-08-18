import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'car_model.dart';

enum TuningCategory {
  powertrain,
  aero,
  stance,
  exhaust;

  String get title {
    switch (this) {
      case TuningCategory.powertrain:
        return 'Motor & Güç';
      case TuningCategory.aero:
        return 'Aerodinamik & Görsel';
      case TuningCategory.stance:
        return 'Yürüyen & Stance';
      case TuningCategory.exhaust:
        return 'Egzoz & Ses';
    }
  }

  IconData get icon {
    switch (this) {
      case TuningCategory.powertrain:
        return Icons.speed_rounded;
      case TuningCategory.aero:
        return Icons.auto_awesome_rounded;
      case TuningCategory.stance:
        return Icons.tune_rounded;
      case TuningCategory.exhaust:
        return Icons.volume_up_rounded;
    }
  }
}

class TuningOptionModel {
  final String id;
  final String title;
  final String description;
  final TuningCategory category;
  final double cost;
  final int hpGain;
  final int nmGain;
  final double accelDelta; // e.g. -0.4s
  final int soundDbGain;
  final double valueMultiplier;
  final bool isLegalWithoutProject;
  final IconData icon;
  final Color color;

  const TuningOptionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.cost,
    required this.hpGain,
    required this.nmGain,
    required this.accelDelta,
    required this.soundDbGain,
    required this.valueMultiplier,
    this.isLegalWithoutProject = true,
    required this.icon,
    required this.color,
  });
}

class TuningPresetBuild {
  final String id;
  final String title;
  final String description;
  final String badge;
  final List<String> optionIds;
  final double discountPercent; // e.g. 0.15 for %15 off

  const TuningPresetBuild({
    required this.id,
    required this.title,
    required this.description,
    required this.badge,
    required this.optionIds,
    this.discountPercent = 0.15,
  });

  double getDiscountedCost() {
    final rawCost = TuningCatalog.calculateRawCost(optionIds);
    return rawCost * (1.0 - discountPercent);
  }
}

class CarDynoStats {
  final int baseHp;
  final int totalHp;
  final int baseNm;
  final int totalNm;
  final double baseAccel;
  final double currentAccel;
  final int exhaustDb;
  final int tuningRating; // 0 to 100
  final bool isInspectionCompliant;
  final bool hasLegalProject;

  const CarDynoStats({
    required this.baseHp,
    required this.totalHp,
    required this.baseNm,
    required this.totalNm,
    required this.baseAccel,
    required this.currentAccel,
    required this.exhaustDb,
    required this.tuningRating,
    required this.isInspectionCompliant,
    required this.hasLegalProject,
  });
}

class TuningCatalog {
  static const List<TuningOptionModel> allOptions = [
    // 1. Powertrain
    TuningOptionModel(
      id: 'tune_ecu_stg1',
      title: 'Stage 1 ECU Beyin Yazılımı',
      description: 'Motor beyin haritasını optimize ederek +35 BG ve +60 Nm güç artışı sağla.',
      category: TuningCategory.powertrain,
      cost: 15000,
      hpGain: 35,
      nmGain: 60,
      accelDelta: -0.4,
      soundDbGain: 2,
      valueMultiplier: 1.12,
      icon: Icons.memory_rounded,
      color: AppColors.brutalYellow,
    ),
    TuningOptionModel(
      id: 'tune_ecu_stg2',
      title: 'Stage 2 Performans & Downpipe',
      description: 'Açık hava filtresi ve paslanmaz downpipe ile +75 BG güç fırlaması.',
      category: TuningCategory.powertrain,
      cost: 35000,
      hpGain: 75,
      nmGain: 110,
      accelDelta: -0.9,
      soundDbGain: 6,
      valueMultiplier: 1.25,
      icon: Icons.speed_rounded,
      color: AppColors.errorRed,
    ),
    TuningOptionModel(
      id: 'tune_turbo_stg3',
      title: 'Stage 3 Big Turbo & Intercooler',
      description: 'Dövme pistonlar ve dev turbocharger ünitesi ile +140 BG saf güç.',
      category: TuningCategory.powertrain,
      cost: 75000,
      hpGain: 140,
      nmGain: 200,
      accelDelta: -1.6,
      soundDbGain: 10,
      valueMultiplier: 1.40,
      icon: Icons.bolt_rounded,
      color: Color(0xFFA855F7),
    ),

    // 2. Aero & Styling
    TuningOptionModel(
      id: 'tune_bodykit_carbon',
      title: 'Karbon Fiber Aero Bodykit & Spoyler',
      description: 'Ön karlık, karbon yan marşpiyeller ve aktif arka difüzör kiti.',
      category: TuningCategory.aero,
      cost: 45000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: -0.1,
      soundDbGain: 0,
      valueMultiplier: 1.30,
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFA855F7),
    ),
    TuningOptionModel(
      id: 'tune_widebody',
      title: 'Geniş Çamurluk & Widebody Paketi',
      description: 'Agresif çamurluk genişletme ve aerodinamik hava kanalları.',
      category: TuningCategory.aero,
      cost: 55000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: 0.0,
      soundDbGain: 0,
      valueMultiplier: 1.35,
      icon: Icons.view_sidebar_rounded,
      color: Color(0xFFEC4899),
    ),
    TuningOptionModel(
      id: 'tune_matrix_lights',
      title: 'Matrix Lazer LED Far & Stop Takımı',
      description: 'Animasyonlu karşılama ışıkları ve koyu füme LED stop takımı.',
      category: TuningCategory.aero,
      cost: 25000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: 0.0,
      soundDbGain: 0,
      valueMultiplier: 1.15,
      icon: Icons.lightbulb_rounded,
      color: AppColors.brutalYellow,
    ),

    // 3. Stance & Handling
    TuningOptionModel(
      id: 'tune_coilover',
      title: 'Yarış Tipi Coilover Spor Yay',
      description: 'Yükseklik ve sertlik ayarlı yarış süspansiyonu ile kusursuz yol tutuş.',
      category: TuningCategory.stance,
      cost: 24000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: -0.2,
      soundDbGain: 0,
      valueMultiplier: 1.16,
      icon: Icons.tune_rounded,
      color: AppColors.brutalGreen,
    ),
    TuningOptionModel(
      id: 'tune_air_suspension',
      title: 'Air Ride Havalı Süspansiyon Kiti',
      description: 'Bağımsız körüklü uzaktan kumandalı basık süspansiyon sistemi.',
      category: TuningCategory.stance,
      cost: 55000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: 0.0,
      soundDbGain: 0,
      valueMultiplier: 1.35,
      isLegalWithoutProject: false, // Extreme stance needs engineering cert
      icon: Icons.height_rounded,
      color: Color(0xFF06B6D4),
    ),
    TuningOptionModel(
      id: 'tune_forged_rims',
      title: '20" Dövme Alaşım Spor Jant Takımı',
      description: 'Lüks hafif alaşım jantlar ve alçak profil performans lastikleri.',
      category: TuningCategory.stance,
      cost: 28000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: -0.1,
      soundDbGain: 0,
      valueMultiplier: 1.18,
      icon: Icons.tire_repair_rounded,
      color: Color(0xFF06B6D4),
    ),
    TuningOptionModel(
      id: 'tune_ceramic_brakes',
      title: 'Karbon Seramik Fren & Çift Kaliper',
      description: '6 pistonlu yarış kaliperleri ve delikli seramik diskler.',
      category: TuningCategory.stance,
      cost: 48000,
      hpGain: 0,
      nmGain: 0,
      accelDelta: 0.0,
      soundDbGain: 0,
      valueMultiplier: 1.28,
      icon: Icons.disc_full_rounded,
      color: AppColors.errorRed,
    ),

    // 4. Exhaust & Sound
    TuningOptionModel(
      id: 'tune_varex_exhaust',
      title: 'Varex Kumandalı Egzoz Sistemi',
      description: 'Çift çıkış kumandalı performans egzozu ile araç çekiciliğini artır.',
      category: TuningCategory.exhaust,
      cost: 22000,
      hpGain: 12,
      nmGain: 18,
      accelDelta: -0.1,
      soundDbGain: 15,
      valueMultiplier: 1.15,
      icon: Icons.minor_crash_rounded,
      color: AppColors.brutalOrange,
    ),
    TuningOptionModel(
      id: 'tune_straight_pipe_flame',
      title: 'Titanyum Düz Boru & Alev Kiti',
      description: 'Katalizörsüz titanyum boru ve vites geçişlerinde patlama/alev efekti.',
      category: TuningCategory.exhaust,
      cost: 42000,
      hpGain: 28,
      nmGain: 40,
      accelDelta: -0.3,
      soundDbGain: 28,
      valueMultiplier: 1.28,
      isLegalWithoutProject: false, // Very loud, fails default inspection
      icon: Icons.local_fire_department_rounded,
      color: AppColors.errorRed,
    ),
    TuningOptionModel(
      id: 'tune_popcorn_map',
      title: 'Pop & Bang Popcorn Yazılımı',
      description: 'Gazdan çekişte çatırdayan özel akustik yazılım haritası.',
      category: TuningCategory.exhaust,
      cost: 16000,
      hpGain: 8,
      nmGain: 12,
      accelDelta: 0.0,
      soundDbGain: 12,
      valueMultiplier: 1.12,
      icon: Icons.speaker_rounded,
      color: Color(0xFFA855F7),
    ),
  ];

  static List<TuningOptionModel> getOptionsByCategory(TuningCategory category) {
    return allOptions.where((o) => o.category == category).toList();
  }

  static double calculateRawCost(List<String> optionIds) {
    double total = 0;
    for (final id in optionIds) {
      final opt = allOptions.where((o) => o.id == id);
      if (opt.isNotEmpty) total += opt.first.cost;
    }
    return total;
  }
}

class TuningPresetBuilds {
  static const List<TuningPresetBuild> allPresets = [
    TuningPresetBuild(
      id: 'preset_street_racer',
      title: 'Sokak Yarışçısı Paketi',
      description: 'Stage 1 Yazılım + Varex Egzoz + Coilover Yay (Sokakların Efendisi).',
      badge: 'STREET RACER',
      optionIds: ['tune_ecu_stg1', 'tune_varex_exhaust', 'tune_coilover'],
      discountPercent: 0.15,
    ),
    TuningPresetBuild(
      id: 'preset_vip_executive',
      title: 'VIP Executive Paketi',
      description: '20" Dövme Jant + Matrix LED + Karbon Aero Kit (Lüks & Prestij).',
      badge: 'VIP LUXURY',
      optionIds: ['tune_forged_rims', 'tune_matrix_lights', 'tune_bodykit_carbon'],
      discountPercent: 0.15,
    ),
    TuningPresetBuild(
      id: 'preset_track_monster',
      title: 'Pist Canavarı Paketi',
      description: 'Stage 3 Turbo + Widebody + Seramik Fren + Düz Boru Alev (Saf Güç).',
      badge: 'TRACK MONSTER',
      optionIds: ['tune_turbo_stg3', 'tune_widebody', 'tune_ceramic_brakes', 'tune_straight_pipe_flame'],
      discountPercent: 0.15,
    ),
  ];
}

class CarDynoCalculator {
  static CarDynoStats calculateDyno(CarModel car) {
    // Authentic baseline from vehicle characteristics
    final baseHp = car.factoryHorsepower;
    final baseNm = car.factoryTorque;
    final baseAccel = car.factoryZeroToHundred;
    final baseDb = 78;

    int addedHp = 0;
    int addedNm = 0;
    double reducedAccel = 0.0;
    int addedDb = 0;
    bool hasIllegalMod = false;
    final hasLegalProject = car.appliedDetailingOptionIds.contains('tune_legal_project_cert');

    for (final id in car.appliedDetailingOptionIds) {
      final matches = TuningCatalog.allOptions.where((o) => o.id == id);
      if (matches.isNotEmpty) {
        final opt = matches.first;
        addedHp += opt.hpGain;
        addedNm += opt.nmGain;
        reducedAccel += opt.accelDelta.abs();
        addedDb += opt.soundDbGain;
        if (!opt.isLegalWithoutProject) {
          hasIllegalMod = true;
        }
      }
    }

    final totalHp = baseHp + addedHp;
    final totalNm = baseNm + addedNm;
    final currentAccel = max(2.8, baseAccel - reducedAccel);
    final exhaustDb = min(125, baseDb + addedDb);
    final tuningRating = min(100, car.appliedDetailingOptionIds.length * 15);

    final isInspectionCompliant = !hasIllegalMod || hasLegalProject;

    return CarDynoStats(
      baseHp: baseHp,
      totalHp: totalHp,
      baseNm: baseNm,
      totalNm: totalNm,
      baseAccel: double.parse(baseAccel.toStringAsFixed(1)),
      currentAccel: double.parse(currentAccel.toStringAsFixed(1)),
      exhaustDb: exhaustDb,
      tuningRating: tuningRating,
      isInspectionCompliant: isInspectionCompliant,
      hasLegalProject: hasLegalProject,
    );
  }
}
