import 'package:flutter/material.dart';

enum WeatherType {
  sunny(
    title: 'Güneşli & Açık',
    description: 'Piyasa canlı, vitrin ziyaretleri ve test sürüşleri tam verimde.',
    visitorMultiplier: 1.15,
    carWashBonusMultiplier: 1.0,
    suvDemandMultiplier: 1.0,
    sportDemandMultiplier: 1.25,
    towTruckBonusMultiplier: 1.0,
    eyeForDetailPenalty: 0.0,
  ),
  rainy(
    title: 'Sağanak Yağmurlu',
    description: 'Ziyaretçi trafiği sakinler fakat oto yıkama işletmesinin işleri %50 patlar.',
    visitorMultiplier: 0.75,
    carWashBonusMultiplier: 1.50,
    suvDemandMultiplier: 1.10,
    sportDemandMultiplier: 0.85,
    towTruckBonusMultiplier: 1.25,
    eyeForDetailPenalty: 0.05,
  ),
  snowy(
    title: 'Yoğun Kar Yağışlı',
    description: 'SUV ve 4x4 araç talebi %60 artar! Yolda kalan araçlar çekici gelirini katlar.',
    visitorMultiplier: 0.65,
    carWashBonusMultiplier: 0.50,
    suvDemandMultiplier: 1.60,
    sportDemandMultiplier: 0.60,
    towTruckBonusMultiplier: 2.00,
    eyeForDetailPenalty: 0.10,
  ),
  foggy(
    title: 'Yoğun Sisli',
    description: 'Görüş mesafesi düşük. Ekspertiz göz kararı doğruluğu %20 azalır.',
    visitorMultiplier: 0.90,
    carWashBonusMultiplier: 0.80,
    suvDemandMultiplier: 1.0,
    sportDemandMultiplier: 0.95,
    towTruckBonusMultiplier: 1.15,
    eyeForDetailPenalty: 0.20,
  );

  final String title;
  final String description;
  final double visitorMultiplier;
  final double carWashBonusMultiplier;
  final double suvDemandMultiplier;
  final double sportDemandMultiplier;
  final double towTruckBonusMultiplier;
  final double eyeForDetailPenalty;

  String get displayName => title;
  String get flavorDescription => description;
  double get carWashDemandMultiplier => carWashBonusMultiplier;
  double get sportCarDemandMultiplier => sportDemandMultiplier;
  double get eyeForDetailAccuracyMultiplier => 1.0 - eyeForDetailPenalty;

  IconData get icon {
    switch (this) {
      case WeatherType.sunny:
        return Icons.wb_sunny_rounded;
      case WeatherType.rainy:
        return Icons.water_drop_rounded;
      case WeatherType.snowy:
        return Icons.ac_unit_rounded;
      case WeatherType.foggy:
        return Icons.cloud_rounded;
    }
  }

  const WeatherType({
    required this.title,
    required this.description,
    required this.visitorMultiplier,
    required this.carWashBonusMultiplier,
    required this.suvDemandMultiplier,
    required this.sportDemandMultiplier,
    required this.towTruckBonusMultiplier,
    required this.eyeForDetailPenalty,
  });
}
