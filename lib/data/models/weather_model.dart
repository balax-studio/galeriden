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

  String get displayName => title;
  String get flavorDescription => description;
  double get carWashDemandMultiplier => carWashBonusMultiplier;
  double get sportCarDemandMultiplier => sportDemandMultiplier;
  double get eyeForDetailAccuracyMultiplier => 1.0 - eyeForDetailPenalty;

  String getLocalizedTitle({String langCode = 'tr'}) {
    switch (langCode) {
      case 'en':
        switch (this) {
          case WeatherType.sunny:
            return 'Sunny & Clear';
          case WeatherType.rainy:
            return 'Heavy Rain';
          case WeatherType.snowy:
            return 'Heavy Snow';
          case WeatherType.foggy:
            return 'Dense Fog';
        }
      case 'de':
        switch (this) {
          case WeatherType.sunny:
            return 'Sonnig & Heiter';
          case WeatherType.rainy:
            return 'Starker Regen';
          case WeatherType.snowy:
            return 'Starker Schneefall';
          case WeatherType.foggy:
            return 'Dichter Nebel';
        }
      case 'pt':
        switch (this) {
          case WeatherType.sunny:
            return 'Ensolarado & Aberto';
          case WeatherType.rainy:
            return 'Chuva Forte';
          case WeatherType.snowy:
            return 'Neve Intensa';
          case WeatherType.foggy:
            return 'Neblina Densa';
        }
      case 'es':
        switch (this) {
          case WeatherType.sunny:
            return 'Soleado & Despejado';
          case WeatherType.rainy:
            return 'Lluvia Intensa';
          case WeatherType.snowy:
            return 'Nieve Intensa';
          case WeatherType.foggy:
            return 'Niebla Densa';
        }
      case 'ru':
        switch (this) {
          case WeatherType.sunny:
            return 'Солнечно и ясно';
          case WeatherType.rainy:
            return 'Проливной дождь';
          case WeatherType.snowy:
            return 'Сильный снегопад';
          case WeatherType.foggy:
            return 'Густой туман';
        }
      case 'ar':
        switch (this) {
          case WeatherType.sunny:
            return 'مشمس وصافٍ';
          case WeatherType.rainy:
            return 'أمطار غزيرة';
          case WeatherType.snowy:
            return 'ثلوج كثيفة';
          case WeatherType.foggy:
            return 'ضباب كثيف';
        }
      case 'tr':
      default:
        return title;
    }
  }

  String getLocalizedDescription({String langCode = 'tr'}) {
    switch (langCode) {
      case 'en':
        switch (this) {
          case WeatherType.sunny:
            return 'Market is active, showroom visitors and test drives at full performance.';
          case WeatherType.rainy:
            return 'Foot traffic slows down, but car wash detailing revenue jumps by +50%.';
          case WeatherType.snowy:
            return 'SUV and 4x4 demand spikes by +60%! Stranded vehicles double tow truck earnings.';
          case WeatherType.foggy:
            return 'Low visibility. Visual inspection accuracy drops by -20%.';
        }
      case 'de':
        switch (this) {
          case WeatherType.sunny:
            return 'Markt ist lebendig, Ausstellungsbesuche und Probefahrten laufen auf Hochtouren.';
          case WeatherType.rainy:
            return 'Besucherverkehr nimmt ab, aber das Autowaschgeschäft boomt um +50%.';
          case WeatherType.snowy:
            return 'SUV- und Allrad-Nachfrage steigt um +60%! Abschleppeinnahmen verdoppeln sich.';
          case WeatherType.foggy:
            return 'Geringe Sichtweite. Genauigkeit visueller Prüfungen sinkt um -20%.';
        }
      case 'pt':
        switch (this) {
          case WeatherType.sunny:
            return 'Mercado aquecido, fluxo de showroom e test-drives no auge.';
          case WeatherType.rainy:
            return 'Movimento na loja diminui, mas faturamento do lava-rápido salta +50%.';
          case WeatherType.snowy:
            return 'Demanda por SUVs e 4x4 dispara +60%! Guincho fatura o dobro.';
          case WeatherType.foggy:
            return 'Baixa visibilidade. Precisão da avaliação visual cai em -20%.';
        }
      case 'es':
        switch (this) {
          case WeatherType.sunny:
            return 'Mercado dinámico, visitas a exposición y pruebas a pleno rendimiento.';
          case WeatherType.rainy:
            return 'Menos afluencia a la tienda, pero la facturación del lavado sube un +50%.';
          case WeatherType.snowy:
            return '¡La demanda de SUV y 4x4 sube un +60%! Los rescates duplican ingresos.';
          case WeatherType.foggy:
            return 'Baja visibilidad. La precisión de la peritación visual baja un -20%.';
        }
      case 'ru':
        switch (this) {
          case WeatherType.sunny:
            return 'Рынок активен, поток клиентов и тест-драйвы на максимуме.';
          case WeatherType.rainy:
            return 'Трафик в салоне снижается, но выручка автомойки взлетает на +50%.';
          case WeatherType.snowy:
            return 'Спрос на внедорожники и 4x4 растет на +60%! Эвакуаторы приносят вдвое больше.';
          case WeatherType.foggy:
            return 'Плохая видимость. Точность визуального осмотра падает на -20%.';
        }
      case 'ar':
        switch (this) {
          case WeatherType.sunny:
            return 'السوق نشط، إقبال صالة العرض وتجارب القيادة بأعلى أداء.';
          case WeatherType.rainy:
            return 'حركة الزوار تهدأ، لكن إيرادات مغسلة السيارات تقفز بنسبة +50%.';
          case WeatherType.snowy:
            return 'ارتفاع الطلب على الدفع الرباعي بنسبة +60%! إيرادات سحب السيارات تتضاعف.';
          case WeatherType.foggy:
            return 'مدى الرؤية منخفض. دقة الفحص البصري التقديري تنخفض بنسبة -20%.';
        }
      case 'tr':
      default:
        return description;
    }
  }

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
}
