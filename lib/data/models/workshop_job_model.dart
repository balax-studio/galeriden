import 'dart:math';
import 'package:flutter/material.dart';

enum RepairJobType {
  engine,
  transmission,
  ecu,
  bodywork,
  chassis,
  periodicMaintenance;

  String get title {
    switch (this) {
      case RepairJobType.engine:
        return 'Motor Revizyonu';
      case RepairJobType.transmission:
        return 'Şanzıman & Baskı Balata';
      case RepairJobType.ecu:
        return 'OBD-II Beyin & Sensör';
      case RepairJobType.bodywork:
        return 'Kaporta & Fırın Boya';
      case RepairJobType.chassis:
        return 'Şasi & Rot-Balans';
      case RepairJobType.periodicMaintenance:
        return '10.000 KM Periyodik Bakım';
    }
  }

  IconData get icon {
    switch (this) {
      case RepairJobType.engine:
        return Icons.speed_rounded;
      case RepairJobType.transmission:
        return Icons.settings_input_component_rounded;
      case RepairJobType.ecu:
        return Icons.memory_rounded;
      case RepairJobType.bodywork:
        return Icons.format_paint_rounded;
      case RepairJobType.chassis:
        return Icons.straighten_rounded;
      case RepairJobType.periodicMaintenance:
        return Icons.oil_barrel_rounded;
    }
  }
}

class CustomerRepairJob {
  final String id;
  final String customerName;
  final String carModelName;
  final String customerStory;
  final RepairJobType jobType;
  final double partsCost;
  final double laborReward; // Net profit for the gallery
  final int masteryXpReward;
  final int difficultyStars; // 1 to 5
  final bool isUrgent;
  final String correctDiagnosisKey; // For diagnostic acoustic minigame

  const CustomerRepairJob({
    required this.id,
    required this.customerName,
    required this.carModelName,
    required this.customerStory,
    required this.jobType,
    required this.partsCost,
    required this.laborReward,
    required this.masteryXpReward,
    this.difficultyStars = 3,
    this.isUrgent = false,
    required this.correctDiagnosisKey,
  });

  static List<CustomerRepairJob> generateRandomJobs({int count = 4}) {
    final random = Random();
    final templates = [
      (
        'Ahmet Bey (Taksici)',
        'Fiat Egea 1.3 Multijet',
        'Ustam araç rampada çekmiyor, debriyaj kaçırıyor ve koku yapıyor.',
        RepairJobType.transmission,
        6500.0,
        9500.0,
        45,
        2,
        'baski_balata',
      ),
      (
        'Murat Bey (Esnaf)',
        'VW Passat 2.0 TDI',
        'Sabahları egzozdan mavi duman atıyor ve motordan şıkırtı geliyor.',
        RepairJobType.engine,
        14000.0,
        22000.0,
        85,
        4,
        'subap_segman',
      ),
      (
        'Cemre Hanım (Mimar)',
        'BMW 320i',
        'Göstergede motor arıza lambası yandı ve araç kendini korumaya aldı.',
        RepairJobType.ecu,
        3500.0,
        8500.0,
        35,
        1,
        'oksijen_sensoru',
      ),
      (
        'Volkan Bey (Müteahhit)',
        'Ford Ranger 3.2 Wildtrak',
        'Şantiyede yan çamurluk ve kapı göçtü, fırın boya lazım.',
        RepairJobType.bodywork,
        11000.0,
        18500.0,
        60,
        3,
        'camurluk_gocuk',
      ),
      (
        'Kenan Bey (Drift Sever)',
        'Nissan Silvia S15',
        'Kaldırıma vurdum, direksiyon sağa çekiyor ve rot ayarı tutmuyor.',
        RepairJobType.chassis,
        16000.0,
        28000.0,
        95,
        5,
        'salincak_sasi',
      ),
    ];

    templates.shuffle(random);
    return templates.take(count).map((t) {
      return CustomerRepairJob(
        id: 'job_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(9999)}',
        customerName: t.$1,
        carModelName: t.$2,
        customerStory: t.$3,
        jobType: t.$4,
        partsCost: t.$5,
        laborReward: t.$6,
        masteryXpReward: t.$7,
        difficultyStars: t.$8,
        isUrgent: random.nextBool(),
        correctDiagnosisKey: t.$9,
      );
    }).toList();
  }
}

class CustomPaintColor {
  final String name;
  final String hex;
  final double cost;
  final double buyerAppealMultiplier; // e.g. 1.20 = +%20 buyer appeal
  final Color color;

  const CustomPaintColor({
    required this.name,
    required this.hex,
    required this.cost,
    required this.buyerAppealMultiplier,
    required this.color,
  });

  static const List<CustomPaintColor> palette = [
    CustomPaintColor(
      name: 'Nardo Gri (Trend)',
      hex: '#6B7280',
      cost: 14000,
      buyerAppealMultiplier: 1.25,
      color: Color(0xFF6B7280),
    ),
    CustomPaintColor(
      name: 'Gece Siyahı Metalik',
      hex: '#111827',
      cost: 12000,
      buyerAppealMultiplier: 1.15,
      color: Color(0xFF111827),
    ),
    CustomPaintColor(
      name: 'Yarış Kırmızısı (Rosso Corsa)',
      hex: '#DC2626',
      cost: 16000,
      buyerAppealMultiplier: 1.22,
      color: Color(0xFFDC2626),
    ),
    CustomPaintColor(
      name: 'Mat Haki Yeşili (Military)',
      hex: '#4D7C0F',
      cost: 18000,
      buyerAppealMultiplier: 1.30,
      color: Color(0xFF4D7C0F),
    ),
    CustomPaintColor(
      name: 'Sedefli Saf Beyaz',
      hex: '#F8FAFC',
      cost: 10000,
      buyerAppealMultiplier: 1.10,
      color: Color(0xFFF8FAFC),
    ),
    CustomPaintColor(
      name: 'Miamia Mavisi (Electric Blue)',
      hex: '#0284C7',
      cost: 15000,
      buyerAppealMultiplier: 1.20,
      color: Color(0xFF0284C7),
    ),
  ];
}
