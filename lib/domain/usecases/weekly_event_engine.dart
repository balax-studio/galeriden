import '../../data/models/car_model.dart';

enum MacroSeason {
  spring('İlkbahar / Sanayi Canlanması', 'Kelepir ve bakım bekleyen araçlara ilgi yüksek.'),
  summer('Yaz / Tatil & Gezi Sezonu', 'Cabrio, SUV ve spor araç fiyatlarında prim dönemi.'),
  autumn('Sonbahar / Filo & Şehir İçi', 'Sedan, dizel ve ekonomi sınıfı araçlara talep yoğun.'),
  winter('Kış / Zorlu Şartlar', '4x4, SUV ve kışlık araçlar değer kazanıyor.');

  final String title;
  final String description;
  const MacroSeason(this.title, this.description);
}

class WeeklyGameEvent {
  final String id;
  final String title;
  final String description;
  final int dayOfWeek; // 1 = Monday ... 7 = Sunday
  final double visitorSpeedMultiplier;
  final double priceBonusMultiplier;
  final double discountMultiplier;

  const WeeklyGameEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.dayOfWeek,
    this.visitorSpeedMultiplier = 1.0,
    this.priceBonusMultiplier = 1.0,
    this.discountMultiplier = 1.0,
  });
}

class WeeklyEventEngine {
  static const List<WeeklyGameEvent> weeklySchedule = [
    WeeklyGameEvent(
      id: 'credit_ease_monday',
      title: 'Kredi Kolaylığı Pazartesisi',
      description: 'Bankalar kredi faizlerinde %20 indirim uyguluyor.',
      dayOfWeek: 1,
      discountMultiplier: 0.80,
    ),
    WeeklyGameEvent(
      id: 'tramer_audit_tuesday',
      title: 'Ekspertiz ve Denetim Salısı',
      description: 'Ekspertiz raporu ücretleri yarı yarıya indirimli.',
      dayOfWeek: 2,
      discountMultiplier: 0.50,
    ),
    WeeklyGameEvent(
      id: 'parts_express_wednesday',
      title: 'Çıkmacılar Çarşambası',
      description: 'Tüm yedek parça siparişlerinde %15 indirim fırsatı.',
      dayOfWeek: 3,
      discountMultiplier: 0.85,
    ),
    WeeklyGameEvent(
      id: 'fleet_lease_thursday',
      title: 'Filo ve Kiralama Perşembesi',
      description: 'Araç kiralama sözleşmelerinden %25 daha fazla gelir elde edilir.',
      dayOfWeek: 4,
      priceBonusMultiplier: 1.25,
    ),
    WeeklyGameEvent(
      id: 'friday_super_market',
      title: 'Cuma Galeri Pazarı',
      description: 'Piyasa hareketleniyor! Müşteri ziyaretleri %40 daha hızlı gerçekleşir.',
      dayOfWeek: 5,
      visitorSpeedMultiplier: 1.40,
    ),
    WeeklyGameEvent(
      id: 'saturday_open_showcase',
      title: 'Hafta Sonu Açık Oto Pazarı',
      description: 'Haftanın en yoğun günü! Vitrindeki araçlara alıcı akını yaşanır.',
      dayOfWeek: 6,
      visitorSpeedMultiplier: 1.60,
    ),
    WeeklyGameEvent(
      id: 'collector_sunday_auction',
      title: 'Pazar Koleksiyoner Müzayedesi',
      description: 'Özel ve temiz araçlara koleksiyonerlerden cömert teklifler yağar.',
      dayOfWeek: 7,
      priceBonusMultiplier: 1.25,
    ),
  ];

  /// Returns the dynamic active event for an in-game day (1..N mapped to 1..7)
  static WeeklyGameEvent getEventForDay(int inGameDay) {
    final dayOfWeek = ((inGameDay - 1) % 7) + 1;
    return weeklySchedule.firstWhere(
      (e) => e.dayOfWeek == dayOfWeek,
      orElse: () => weeklySchedule[0],
    );
  }

  /// Determines Macro Season based on In-Game Month / Day or Real-World Date (§2.1)
  static MacroSeason getMacroSeason({int inGameDay = 1, DateTime? realDate}) {
    final date = realDate ?? DateTime.now();
    final month = date.month;

    if (month >= 3 && month <= 5) {
      return MacroSeason.spring;
    } else if (month >= 6 && month <= 8) {
      return MacroSeason.summer;
    } else if (month >= 9 && month <= 11) {
      return MacroSeason.autumn;
    } else {
      return MacroSeason.winter;
    }
  }

  /// Returns localized season title string
  static String getCurrentSeasonName(int inGameDay, {DateTime? realDate}) {
    return getMacroSeason(inGameDay: inGameDay, realDate: realDate).title;
  }

  /// Calculates combined dual-layer market multiplier for a vehicle (§2.1 / §2.2)
  static double getCombinedMarketMultiplier(int inGameDay, CarModel car, {DateTime? realDate}) {
    final weeklyEvent = getEventForDay(inGameDay);
    final season = getMacroSeason(inGameDay: inGameDay, realDate: realDate);

    double multiplier = 1.0;

    // Weekly day bonuses
    if (weeklyEvent.id == 'collector_sunday_auction' && (car.isRare || car.isBarnFind)) {
      multiplier *= 1.20;
    }

    // Seasonal body type modifiers
    switch (season) {
      case MacroSeason.summer:
        if (car.bodyType == 'Spor' || car.bodyType == 'Cabrio' || car.bodyType == 'SUV') {
          multiplier *= 1.12;
        }
        break;
      case MacroSeason.winter:
        if (car.bodyType == 'SUV' || car.bodyType == '4x4') {
          multiplier *= 1.15;
        }
        break;
      case MacroSeason.autumn:
        if (car.bodyType == 'Sedan' || car.bodyType == 'Hatchback') {
          multiplier *= 1.08;
        }
        break;
      case MacroSeason.spring:
        if (car.isBarnFind || car.expertise.engineCondition < 75) {
          multiplier *= 1.06;
        }
        break;
    }

    return multiplier;
  }
}
