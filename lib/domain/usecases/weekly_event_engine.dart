import '../../data/models/car_model.dart';
import '../../data/models/expertise_model.dart';

enum MacroSeason {
  spring('İlkbahar / Sanayi Canlanması', 'Kelepir ve bakım bekleyen araçlara ilgi yüksek.'),
  summer('Yaz / Tatil & Gezi Sezonu', 'Cabrio, SUV ve spor araç fiyatlarında prim dönemi.'),
  autumn('Sonbahar / Filo & Şehir İçi', 'Sedan, dizel ve ekonomi sınıfı araçlara talep yoğun.'),
  winter('Kış / Zorlu Şartlar', '4x4, SUV ve kışlık araçlar değer kazanıyor.');

  final String title;
  final String description;
  const MacroSeason(this.title, this.description);

  String getLocalizedTitle({String langCode = 'tr'}) {
    switch (langCode) {
      case 'en':
        switch (this) {
          case MacroSeason.spring:
            return 'Spring / Workshop Revival';
          case MacroSeason.summer:
            return 'Summer / Holiday & Travel';
          case MacroSeason.autumn:
            return 'Autumn / Fleet & Commuting';
          case MacroSeason.winter:
            return 'Winter / Tough Terrain';
        }
      case 'de':
        switch (this) {
          case MacroSeason.spring:
            return 'Frühling / Werkstattbelebung';
          case MacroSeason.summer:
            return 'Sommer / Urlaubs- & Reisesaison';
          case MacroSeason.autumn:
            return 'Herbst / Flotten- & Stadtverkehr';
          case MacroSeason.winter:
            return 'Winter / Härtebedingungen';
        }
      case 'pt':
        switch (this) {
          case MacroSeason.spring:
            return 'Primavera / Retomada das Oficinas';
          case MacroSeason.summer:
            return 'Verão / Férias & Viagens';
          case MacroSeason.autumn:
            return 'Outono / Frotas & Uso Urbano';
          case MacroSeason.winter:
            return 'Inverno / Terrenos Difíceis';
        }
      case 'es':
        switch (this) {
          case MacroSeason.spring:
            return 'Primavera / Reactivación de Talleres';
          case MacroSeason.summer:
            return 'Verano / Vacaciones y Viajes';
          case MacroSeason.autumn:
            return 'Otoño / Flotas y Ciudad';
          case MacroSeason.winter:
            return 'Invierno / Terrenos Difíciles';
        }
      case 'ru':
        switch (this) {
          case MacroSeason.spring:
            return 'Весна / Оживление автосервисов';
          case MacroSeason.summer:
            return 'Лето / Сезон отпусков и поездок';
          case MacroSeason.autumn:
            return 'Осень / Корпоративные парки и город';
          case MacroSeason.winter:
            return 'Зима / Суровые дорожные условия';
        }
      case 'ar':
        switch (this) {
          case MacroSeason.spring:
            return 'الربيع / انتعاش الورش والصيانة';
          case MacroSeason.summer:
            return 'الصيف / موسم العطلات والسفر';
          case MacroSeason.autumn:
            return 'الخريف / الأساطيل والقيادة داخل المدينة';
          case MacroSeason.winter:
            return 'الشتاء / الظروف القاسية';
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
          case MacroSeason.spring:
            return 'High interest in bargain cars needing maintenance and restoration.';
          case MacroSeason.summer:
            return 'Premium pricing period for cabrios, SUVs, and sports cars.';
          case MacroSeason.autumn:
            return 'High demand for sedans, diesel, and economy class cars.';
          case MacroSeason.winter:
            return '4x4, SUV, and winter-ready vehicles gain extra market value.';
        }
      case 'de':
        switch (this) {
          case MacroSeason.spring:
            return 'Hohes Interesse an Schnäppchen und wartungsbedürftigen Fahrzeugen.';
          case MacroSeason.summer:
            return 'Premiumpreise für Cabrios, SUVs und Sportwagen.';
          case MacroSeason.autumn:
            return 'Starke Nachfrage nach Limousinen, Diesel- und Sparmodellen.';
          case MacroSeason.winter:
            return '4x4, SUVs und winterfeste Fahrzeuge gewinnen an Wert.';
        }
      case 'pt':
        switch (this) {
          case MacroSeason.spring:
            return 'Alto interesse em carros baratos precisando de manutenção e restauração.';
          case MacroSeason.summer:
            return 'Período de valorização para conversíveis, SUVs e carros esportivos.';
          case MacroSeason.autumn:
            return 'Alta procura por sedãs, modelos a diesel e carros econômicos.';
          case MacroSeason.winter:
            return 'Veículos 4x4, SUVs e preparados para o frio ganham valor de mercado.';
        }
      case 'es':
        switch (this) {
          case MacroSeason.spring:
            return 'Gran interés en coches de ocasión que requieren puesta a punto.';
          case MacroSeason.summer:
            return 'Temporada de precios altos para descapotables, SUV y deportivos.';
          case MacroSeason.autumn:
            return 'Alta demanda de berlinas, diésel y coches económicos.';
          case MacroSeason.winter:
            return 'Los 4x4, SUV y vehículos preparados para el invierno se revalorizan.';
        }
      case 'ru':
        switch (this) {
          case MacroSeason.spring:
            return 'Высокий интерес к недорогим авто под ремонт и обслуживание.';
          case MacroSeason.summer:
            return 'Пик цен на кабриолеты, внедорожники и спортивные автомобили.';
          case MacroSeason.autumn:
            return 'Высокий спрос на седаны, дизельные и экономичные авто.';
          case MacroSeason.winter:
            return 'Внедорожники 4x4 и зимние автомобили растут в цене.';
        }
      case 'ar':
        switch (this) {
          case MacroSeason.spring:
            return 'اهتمام كبير بالسيارات الاقتصادية التي تحتاج إلى صيانة وتجديد.';
          case MacroSeason.summer:
            return 'فترة ارتفاع أسعار الكابريوليه وسيارات الدفع الرباعي والسيارات الرياضية.';
          case MacroSeason.autumn:
            return 'طلب كثيف على سيارات السيدان والديزل والفئات الاقتصادية.';
          case MacroSeason.winter:
            return 'سيارات الدفع الرباعي 4x4 والمركبات الشتوية تكتسب قيمة سوقية أعلى.';
        }
      case 'tr':
      default:
        return description;
    }
  }
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

  String getLocalizedTitle({String langCode = 'tr'}) {
    switch (langCode) {
      case 'en':
        switch (id) {
          case 'credit_ease_monday':
            return 'Credit Ease Monday';
          case 'tramer_audit_tuesday':
            return 'Inspection & Audit Tuesday';
          case 'parts_express_wednesday':
            return 'Parts Express Wednesday';
          case 'fleet_lease_thursday':
            return 'Fleet & Rental Thursday';
          case 'friday_super_market':
            return 'Friday Super Market';
          case 'saturday_open_showcase':
            return 'Saturday Open Showcase';
          case 'collector_sunday_auction':
            return 'Sunday Collector Auction';
        }
        return title;
      case 'de':
        switch (id) {
          case 'credit_ease_monday':
            return 'Krediterleichterungs-Montag';
          case 'tramer_audit_tuesday':
            return 'Inspektions-Dienstag';
          case 'parts_express_wednesday':
            return 'Ersatzteile-Mittwoch';
          case 'fleet_lease_thursday':
            return 'Flotten- & Miet-Donnerstag';
          case 'friday_super_market':
            return 'Freitags-Automarkt';
          case 'saturday_open_showcase':
            return 'Samstags-Gebrauchtwagenmarkt';
          case 'collector_sunday_auction':
            return 'Sonntags-Sammlerauktion';
        }
        return title;
      case 'pt':
        switch (id) {
          case 'credit_ease_monday':
            return 'Segunda do Crédito Fácil';
          case 'tramer_audit_tuesday':
            return 'Terça da Vistoria & Laudos';
          case 'parts_express_wednesday':
            return 'Quarta das Peças & Desmanche';
          case 'fleet_lease_thursday':
            return 'Quinta da Frota & Locação';
          case 'friday_super_market':
            return 'Sexta do Super Feirão';
          case 'saturday_open_showcase':
            return 'Sábado de Portas Abertas';
          case 'collector_sunday_auction':
            return 'Domingo de Leilão de Coleção';
        }
        return title;
      case 'es':
        switch (id) {
          case 'credit_ease_monday':
            return 'Lunes de Crédito Fácil';
          case 'tramer_audit_tuesday':
            return 'Martes de Peritaje e Inspección';
          case 'parts_express_wednesday':
            return 'Miércoles de Recambios';
          case 'fleet_lease_thursday':
            return 'Jueves de Flotas y Alquiler';
          case 'friday_super_market':
            return 'Viernes de Gran Mercado';
          case 'saturday_open_showcase':
            return 'Sábado de Feria Abierta';
          case 'collector_sunday_auction':
            return 'Domingo de Subasta Exclusiva';
        }
        return title;
      case 'ru':
        switch (id) {
          case 'credit_ease_monday':
            return 'Понедельник доступных кредитов';
          case 'tramer_audit_tuesday':
            return 'Вторник техосмотра и дефектовки';
          case 'parts_express_wednesday':
            return 'Среда авторазборок и запчастей';
          case 'fleet_lease_thursday':
            return 'Четверг аренды и автопарка';
          case 'friday_super_market':
            return 'Пятничный супер-авторынок';
          case 'saturday_open_showcase':
            return 'Субботняя открытая ярмарка';
          case 'collector_sunday_auction':
            return 'Воскресный аукцион коллекционеров';
        }
        return title;
      case 'ar':
        switch (id) {
          case 'credit_ease_monday':
            return 'اثنين التسهيلات الائتمانية';
          case 'tramer_audit_tuesday':
            return 'ثلاثاء الفحص والتدقيق';
          case 'parts_express_wednesday':
            return 'أربعاء قطع الغيار';
          case 'fleet_lease_thursday':
            return 'خميس الأساطيل والتأجير';
          case 'friday_super_market':
            return 'جمعة سوق السيارات الكبرى';
          case 'saturday_open_showcase':
            return 'سبت المعرض المفتوح';
          case 'collector_sunday_auction':
            return 'أحد مزادات الهواة والنوادر';
        }
        return title;
      case 'tr':
      default:
        return title;
    }
  }

  String getLocalizedDescription({String langCode = 'tr'}) {
    switch (langCode) {
      case 'en':
        switch (id) {
          case 'credit_ease_monday':
            return 'Banks apply a 20% discount on credit interest rates.';
          case 'tramer_audit_tuesday':
            return 'Vehicle inspection report fees are 50% off.';
          case 'parts_express_wednesday':
            return '15% discount on all spare part orders.';
          case 'fleet_lease_thursday':
            return 'Earn 25% more revenue from vehicle rental contracts.';
          case 'friday_super_market':
            return 'Market is buzzing! Customer foot traffic arrives 40% faster.';
          case 'saturday_open_showcase':
            return 'Peak rush of the week! Wave of buyers flood showroom vehicles.';
          case 'collector_sunday_auction':
            return 'Collectors make generous offers on pristine & rare vehicles.';
        }
        return description;
      case 'de':
        switch (id) {
          case 'credit_ease_monday':
            return 'Banken gewähren 20% Rabatt auf Kreditzinsen.';
          case 'tramer_audit_tuesday':
            return 'Fahrzeuggutachten zum halben Preis.';
          case 'parts_express_wednesday':
            return '15% Rabatt auf alle Ersatzteilbestellungen.';
          case 'fleet_lease_thursday':
            return 'Erzielen Sie 25% mehr Einnahmen aus Mietverträgen.';
          case 'friday_super_market':
            return 'Der Markt boomt! Kundenbesuche finden 40% schneller statt.';
          case 'saturday_open_showcase':
            return 'Höhepunkt der Woche! Riesiger Käuferandrang auf Ausstellungsfahrzeuge.';
          case 'collector_sunday_auction':
            return 'Sammler bieten großzügig auf seltene und gepflegte Fahrzeuge.';
        }
        return description;
      case 'pt':
        switch (id) {
          case 'credit_ease_monday':
            return 'Bancos oferecem 20% de desconto nos juros de financiamento.';
          case 'tramer_audit_tuesday':
            return 'Taxas de laudo pericial com 50% de desconto.';
          case 'parts_express_wednesday':
            return '15% de desconto em todos os pedidos de autopeças.';
          case 'fleet_lease_thursday':
            return 'Fature 25% a mais em contratos de aluguel de carros.';
          case 'friday_super_market':
            return 'Mercado agitado! Clientes chegam 40% mais rápido.';
          case 'saturday_open_showcase':
            return 'Pico da semana! Onda de compradores no showroom.';
          case 'collector_sunday_auction':
            return 'Colecionadores fazem lances generosos em carros impecáveis.';
        }
        return description;
      case 'es':
        switch (id) {
          case 'credit_ease_monday':
            return 'Los bancos aplican un 20% de descuento en tipos de interés.';
          case 'tramer_audit_tuesday':
            return 'Tarifas de informe pericial al 50% de descuento.';
          case 'parts_express_wednesday':
            return '15% de descuento en todos os pedidos de piezas.';
          case 'fleet_lease_thursday':
            return 'Obtén un 25% más de ingresos en contratos de alquiler.';
          case 'friday_super_market':
            return '¡El mercado se agita! Las visitas de clientes son un 40% más rápidas.';
          case 'saturday_open_showcase':
            return '¡El día más concurrido! Avalancha de compradores en la exposición.';
          case 'collector_sunday_auction':
            return 'Generosas ofertas de coleccionistas para vehículos exclusivos.';
        }
        return description;
      case 'ru':
        switch (id) {
          case 'credit_ease_monday':
            return 'Банки снижают процентные ставки по кредитам на 20%.';
          case 'tramer_audit_tuesday':
            return 'Плата за диагностику и отчеты со скидкой 50%.';
          case 'parts_express_wednesday':
            return 'Скидка 15% на все заказы запчастей.';
          case 'fleet_lease_thursday':
            return 'Выручка по договорам проката авто вырастает на 25%.';
          case 'friday_super_market':
            return 'Рынок оживает! Поток покупателей идет на 40% быстрее.';
          case 'saturday_open_showcase':
            return 'Самый загруженный день! Наплыв покупателей на витрину.';
          case 'collector_sunday_auction':
            return 'Коллекционеры щедро платят за редкие и идеальные авто.';
        }
        return description;
      case 'ar':
        switch (id) {
          case 'credit_ease_monday':
            return 'البنوك تطبق خصما بنسبة 20% على فوائد القروض.';
          case 'tramer_audit_tuesday':
            return 'رسوم تقارير الفحص بخصم 50%.';
          case 'parts_express_wednesday':
            return 'خصم 15% على جميع طلبات قطع الغيار.';
          case 'fleet_lease_thursday':
            return 'تحقيق إيرادات أعلى بنسبة 25% من عقود التأجير.';
          case 'friday_super_market':
            return 'حركة السوق تنتعش! إقبال العملاء أسرع بنسبة 40%.';
          case 'saturday_open_showcase':
            return 'ذروة الأسبوع! توافد هائل للمشترين على سيارات العرض.';
          case 'collector_sunday_auction':
            return 'عروض سخية من الهواة على السيارات النادرة والمميزة.';
        }
        return description;
      case 'tr':
      default:
        return description;
    }
  }
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

  /// Returns current season name localized
  static String getCurrentSeasonName([int inGameDay = 1, String langCode = 'tr']) {
    return getMacroSeason(inGameDay: inGameDay).getLocalizedTitle(langCode: langCode);
  }

  /// Returns localized market recommendation text
  static String getMacroSeasonMarketTip(MacroSeason season, [String langCode = 'tr']) {
    return season.getLocalizedDescription(langCode: langCode);
  }

  /// Evaluates special car bonus multiplier based on Day & Category
  static double getCarValueBonus({
    required CarModel car,
    required int inGameDay,
  }) {
    final event = getEventForDay(inGameDay);
    double multiplier = 1.0;

    if (event.id == 'collector_sunday_auction' &&
        car.expertise.bodyParts.values.every((s) => s == PartStatus.original) &&
        car.expertise.mileage < 80000) {
      multiplier *= event.priceBonusMultiplier;
    }

    return multiplier;
  }
}
