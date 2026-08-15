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
      description: 'Haftanın en yoğun günü! Vitlindeki araçlara alıcı akını yaşanır.',
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
}
