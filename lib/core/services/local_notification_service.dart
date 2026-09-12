import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Bildirimin gonderilecegi gercek esnaf saat dilimi
enum NotificationTimeSlot {
  morning,   // 09:00 - 11:59 (Sabah siftahi, kepenk acilisi)
  afternoon, // 12:00 - 16:59 (Ogle pazari, noter telasi)
  evening,   // 17:00 - 21:59 (Aksam pazari, hesap kesimi)
}

/// Cihaz ici yerel bildirim servisi (Local Notification Engine)
/// Sunucu baglantisi veya internet gerektirmez; tamamen cevrimdisi calisir.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static const int idShowroomOffer = 101;
  static const int idDailyReturn = 102;

  static const String channelId = 'galeriden_retention_channel';
  static const String channelName = 'Galeriden Tycoon Bildirimleri';
  static const String channelDesc = 'Esnaf firsatlari ve vitrin teklif bildirimleri';

  /// Bildirime dokunuldugunda rota yonlendirmesi icin payload akisi
  static final StreamController<String> payloadStream = StreamController<String>.broadcast();

  /// Gece uykusu saatlerini (22:00 - 09:00) koruyan akilli zamanlayici
  /// Eger hesaplanan an bu sessiz saatlere denk geliyorsa, sabahi (09:30) bekler.
  static DateTime calculateSafeScheduledTime(DateTime now, Duration delay) {
    final target = now.add(delay);
    final hour = target.hour;

    // 22:00 (dahil) ile 09:00 (haric) arasi sessiz saatler kabul edilir
    if (hour >= 22) {
      // Gece 22:00 sonrasi: Ertesi sabah 09:30
      final tomorrow = target.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 30);
    } else if (hour < 9) {
      // Gece yarisi ile sabah 09:00 arasi: Ayni gunun sabahi 09:30
      return DateTime(target.year, target.month, target.day, 9, 30);
    }

    return target;
  }

  /// Bildirim motorunu baslatir
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
    } catch (e) {
      debugPrint('LocalNotificationService init error: $e');
    }
  }

  /// Kullanicidan bildirim izni talep eder (Ilk satistan sonra kibarca istenir)
  Future<bool> requestPermissions() async {
    if (kIsWeb) return false;
    try {
      final androidImplementation =
          _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        return granted ?? false;
      }

      final iosImplementation =
          _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (iosImplementation != null) {
        final granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('LocalNotificationService permission error: $e');
    }
    return false;
  }

  /// 90 dakika sonra vitrinde bekleyen araca alici teklifi bildirimi kurar
  Future<void> scheduleShowroomOfferReminder({
    required String title,
    required String body,
    Duration delay = const Duration(minutes: 90),
  }) async {
    if (!_isInitialized || kIsWeb) return;

    try {
      await _plugin.cancel(idShowroomOffer);

      final safeTime = calculateSafeScheduledTime(DateTime.now(), delay);
      final scheduledTime = tz.TZDateTime.from(safeTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.high,
        priority: Priority.high,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        idShowroomOffer,
        title,
        body,
        scheduledTime,
        details,
        payload: 'route_showroom',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleShowroomOfferReminder error: $e');
    }
  }

  /// 24 saat sonra dukkan ve usta destegi hatirlatmasi kurar
  Future<void> scheduleDailyReturnReminder({
    required String title,
    required String body,
    Duration delay = const Duration(hours: 24),
  }) async {
    if (!_isInitialized || kIsWeb) return;

    try {
      await _plugin.cancel(idDailyReturn);

      final safeTime = calculateSafeScheduledTime(DateTime.now(), delay);
      final scheduledTime = tz.TZDateTime.from(safeTime, tz.local);

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _plugin.zonedSchedule(
        idDailyReturn,
        title,
        body,
        scheduledTime,
        details,
        payload: 'route_daily_login',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('scheduleDailyReturnReminder error: $e');
    }
  }

  /// Oyuncu oyuna girdiginde bekleyen teklif bildirimini iptal eder
  Future<void> cancelShowroomOfferReminder() async {
    if (!_isInitialized || kIsWeb) return;
    try {
      await _plugin.cancel(idShowroomOffer);
    } catch (_) {}
  }

  /// Tum bildirimleri iptal eder (Ayarlardan bildirimler kapatildiginda cagrilir)
  Future<void> cancelAllReminders() async {
    if (!_isInitialized || kIsWeb) return;
    try {
      await _plugin.cancel(idShowroomOffer);
      await _plugin.cancel(idDailyReturn);
    } catch (_) {}
  }

  /// Bildirimin hedeflenen gonderim saatine gore zaman dilimini belirler
  static NotificationTimeSlot getTimeSlot(int hour) {
    if (hour < 12) {
      return NotificationTimeSlot.morning;
    } else if (hour < 17) {
      return NotificationTimeSlot.afternoon;
    } else {
      return NotificationTimeSlot.evening;
    }
  }

  /// 7 Dilde yerellestirilmis ve zamana duyarlı olarak uygulama kapandiginda hatirlatmalari planlar
  Future<void> scheduleLocalizedReminders({
    required String languageCode,
    required bool hasListedCar,
    String? carTitle,
  }) async {
    if (!_isInitialized || kIsWeb) return;

    final lang = languageCode.toLowerCase();
    final now = DateTime.now();

    // 1. 90 Dakika Sonra Vitrin Teklifi Hatirlatmasi
    if (hasListedCar) {
      const showroomDelay = Duration(minutes: 90);
      final safeTime = calculateSafeScheduledTime(now, showroomDelay);
      final slot = getTimeSlot(safeTime.hour);
      final variant = (now.day + (carTitle?.hashCode ?? 0).abs()) % 3;

      final showroomContent = resolveShowroomCopy(
        lang,
        slot: slot,
        variant: variant,
        carTitle: carTitle,
      );
      await scheduleShowroomOfferReminder(
        title: showroomContent.$1,
        body: showroomContent.$2,
        delay: showroomDelay,
      );
    }

    // 2. 24 Saat Sonra Esnaf Dayanismasi ve Gunluk Odul Hatirlatmasi
    const dailyDelay = Duration(hours: 24);
    final safeDailyTime = calculateSafeScheduledTime(now, dailyDelay);
    final dailySlot = getTimeSlot(safeDailyTime.hour);
    final dailyVariant = (now.day + 1) % 2;

    final dailyContent = resolveDailyCopy(
      lang,
      slot: dailySlot,
      variant: dailyVariant,
    );
    await scheduleDailyReturnReminder(
      title: dailyContent.$1,
      body: dailyContent.$2,
      delay: dailyDelay,
    );
  }

  /// Vitrin teklif bildirim metinlerini zaman dilimi, varyant ve dile gore cozer
  static (String, String) resolveShowroomCopy(
    String lang, {
    required NotificationTimeSlot slot,
    required int variant,
    String? carTitle,
  }) {
    final hasCar = carTitle != null && carTitle.trim().isNotEmpty;
    final car = carTitle?.trim() ?? '';
    final v = variant % 3;

    switch (lang.toLowerCase()) {
      case 'en':
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('Master Halil • Morning Trade', 'Just rolled up the shutters lad • First customer walked in for $car, offer is on the desk!')
                  : ('Master Halil • Morning Trade', 'Just rolled up the shutters lad • First customer walked in, offer is on the desk!');
            } else if (v == 1) {
              return hasCar
                  ? ('Master Halil • Shop News', 'Morning tea is brewed, an eager buyer is at the door for $car • Come shake hands!')
                  : ('Master Halil • Shop News', 'Morning tea is brewed, an eager buyer is at the door • Come shake hands!');
            } else {
              return hasCar
                  ? ('Master Halil • First Deal of the Day', 'First deal brings good fortune lad • A buyer is waiting at the table for $car.')
                  : ('Master Halil • First Deal of the Day', 'First deal brings good fortune lad • A buyer is waiting at the table.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('Master Halil • Market Rush', 'Car market is bustling this afternoon • Serious customer arrived for $car, offer is ready!')
                  : ('Master Halil • Market Rush', 'Car market is bustling this afternoon • Serious customer arrived, offer is ready!');
            } else if (v == 1) {
              return hasCar
                  ? ('Master Halil • Beat the Notary Queue', 'Buyer is circling around $car lad • Sit down at the table, let us close the sale.')
                  : ('Master Halil • Beat the Notary Queue', 'Buyer is circling around the showroom lad • Sit down at the table, let us close the sale.');
            } else {
              return hasCar
                  ? ('Master Halil • Sharp Bargain', 'Market demand is soaring • They left a solid offer for $car, come take a look lad!')
                  : ('Master Halil • Sharp Bargain', 'Market demand is soaring • They left a solid offer for your vehicle, come take a look lad!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('Master Halil • Evening Market Blessing', 'Time for the final handshake before pulling down shutters • Buyer awaits for $car.')
                  : ('Master Halil • Evening Market Blessing', 'Time for the final handshake before pulling down shutters • Buyer awaits at the dealership.');
            } else if (v == 1) {
              return hasCar
                  ? ('Master Halil • End of Day Bargain', 'Let us close today with profit lad • Offer for $car is on the desk, call the shots.')
                  : ('Master Halil • End of Day Bargain', 'Let us close today with profit lad • An offer is on the desk, call the shots.');
            } else {
              return hasCar
                  ? ('Master Halil • Last Customer', 'Last customer of the day dropped by in the evening cool • Do not miss the $car deal!')
                  : ('Master Halil • Last Customer', 'Last customer of the day dropped by in the evening cool • Do not miss the deal!');
            }
        }

      case 'de':
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('Meister Halil • Frühgeschäft', 'Rolltor gerade geöffnet Junge • Erster Kunde für $car ist im Laden, Angebot liegt auf dem Tisch!')
                  : ('Meister Halil • Frühgeschäft', 'Rolltor gerade geöffnet Junge • Erster Kunde im Laden, Angebot liegt auf dem Tisch!');
            } else if (v == 1) {
              return hasCar
                  ? ('Meister Halil • Werkstatt-Nachricht', 'Der Morgentee dampft, ein Kaufinteressent für $car steht vor der Tür • Komm zum Handschlag!')
                  : ('Meister Halil • Werkstatt-Nachricht', 'Der Morgentee dampft, ein Kaufinteressent steht vor der Tür • Komm zum Handschlag!');
            } else {
              return hasCar
                  ? ('Meister Halil • Erste Tageschance', 'Das erste Geschäft bringt Segen Junge • Ein Käufer wartet am Tisch auf $car.')
                  : ('Meister Halil • Erste Tageschance', 'Das erste Geschäft bringt Segen Junge • Ein Käufer wartet am Verhandlungstisch.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('Meister Halil • Markt im Aufwind', 'Am Nachmittag tobt der Automarkt • Ernsthafter Interessent für $car eingetroffen, Angebot bereit!')
                  : ('Meister Halil • Markt im Aufwind', 'Am Nachmittag tobt der Automarkt • Ernsthafter Interessent eingetroffen, Angebot bereit!');
            } else if (v == 1) {
              return hasCar
                  ? ('Meister Halil • Vor dem Notartermin', 'Käufer begutachtet den $car Junge • Setz dich an den Tisch und mach den Deal fest.')
                  : ('Meister Halil • Vor dem Notartermin', 'Käufer begutachtet die Ausstellung Junge • Setz dich an den Tisch und mach den Deal fest.');
            } else {
              return hasCar
                  ? ('Meister Halil • Heisse Verhandlung', 'Grosse Nachfrage auf dem Markt • Gutes Angebot für $car abgegeben, sieh es dir an Junge!')
                  : ('Meister Halil • Heisse Verhandlung', 'Grosse Nachfrage auf dem Markt • Gutes Angebot für dein Fahrzeug abgegeben, sieh es dir an Junge!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('Meister Halil • Abendmarkt-Segen', 'Zeit für den letzten Handschlag vor Feierabend • Käufer wartet auf $car.')
                  : ('Meister Halil • Abendmarkt-Segen', 'Zeit für den letzten Handschlag vor Feierabend • Käufer wartet im Autohaus.');
            } else if (v == 1) {
              return hasCar
                  ? ('Meister Halil • Tagesabschluss-Deal', 'Lass uns den Tag mit Gewinn beenden Junge • Angebot für $car liegt bereit, triff die Entscheidung.')
                  : ('Meister Halil • Tagesabschluss-Deal', 'Lass uns den Tag mit Gewinn beenden Junge • Angebot liegt bereit, triff die Entscheidung.');
            } else {
              return hasCar
                  ? ('Meister Halil • Letzter Kunde', 'In der Abendkühle hat ein letzter Kunde vorbeigeschaut • Verpasse nicht das Angebot für $car!')
                  : ('Meister Halil • Letzter Kunde', 'In der Abendkühle hat ein letzter Kunde vorbeigeschaut • Verpasse nicht das Angebot!');
            }
        }

      case 'pt':
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('Mestre Halil • Primeira Venda do Dia', 'Portas abertas garoto • Primeiro cliente entrou para ver o $car, proposta na mesa!')
                  : ('Mestre Halil • Primeira Venda do Dia', 'Portas abertas garoto • Primeiro cliente entrou na loja, proposta na mesa!');
            } else if (v == 1) {
              return hasCar
                  ? ('Mestre Halil • Novidades da Loja', 'Café fresco pronto, cliente animado esperando pelo $car • Venha fechar negócio!')
                  : ('Mestre Halil • Novidades da Loja', 'Café fresco pronto, cliente animado esperando na porta • Venha fechar negócio!');
            } else {
              return hasCar
                  ? ('Mestre Halil • Primeira Oportunidade', 'Primeira negociação traz fartura garoto • Cliente aguarda na mesa pelo $car.')
                  : ('Mestre Halil • Primeira Oportunidade', 'Primeira negociação traz fartura garoto • Cliente aguarda na mesa de negociação.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('Mestre Halil • Mercado em Alta', 'Tarde agitada no feirão • Cliente decidido avaliando o $car, proposta pronta!')
                  : ('Mestre Halil • Mercado em Alta', 'Tarde agitada no feirão • Cliente decidido na loja, proposta pronta!');
            } else if (v == 1) {
              return hasCar
                  ? ('Mestre Halil • Antes do Cartório', 'Cliente rodeando o $car garoto • Sente na mesa e finalize a venda.')
                  : ('Mestre Halil • Antes do Cartório', 'Cliente rodeando a vitrine garoto • Sente na mesa e finalize a venda.');
            } else {
              return hasCar
                  ? ('Mestre Halil • Negociação Quente', 'Mercado aquecido • Deixaram uma ótima proposta pelo $car, venha conferir garoto!')
                  : ('Mestre Halil • Negociação Quente', 'Mercado aquecido • Deixaram uma ótima proposta pelo seu veículo, venha conferir garoto!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('Mestre Halil • Bênção do Fim de Tarde', 'Hora do aperto de mão final antes de fechar as portas • Cliente aguardando o $car.')
                  : ('Mestre Halil • Bênção do Fim de Tarde', 'Hora do aperto de mão final antes de fechar as portas • Cliente aguardando na loja.');
            } else if (v == 1) {
              return hasCar
                  ? ('Mestre Halil • Lucro do Dia', 'Vamos fechar o dia no lucro garoto • Proposta do $car na mesa, decida agora.')
                  : ('Mestre Halil • Lucro do Dia', 'Vamos fechar o dia no lucro garoto • Proposta excelente na mesa, decida agora.');
            } else {
              return hasCar
                  ? ('Mestre Halil • Último Cliente', 'Último cliente do dia passou na loja • Não perca a oferta no $car!')
                  : ('Mestre Halil • Último Cliente', 'Último cliente do dia passou na loja • Não perca essa oferta!');
            }
        }

      case 'es':
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('Maestro Halil • Primera Venta del Día', 'Persianas levantadas muchacho • Primer cliente entró por el $car, oferta en la mesa!')
                  : ('Maestro Halil • Primera Venta del Día', 'Persianas levantadas muchacho • Primer cliente entró al salón, oferta en la mesa!');
            } else if (v == 1) {
              return hasCar
                  ? ('Maestro Halil • Novedades del Salón', 'El té mañanero está listo, comprador entusiasta esperando por el $car • Ven a dar la mano!')
                  : ('Maestro Halil • Novedades del Salón', 'El té mañanero está listo, comprador entusiasta esperando en la puerta • Ven a dar la mano!');
            } else {
              return hasCar
                  ? ('Maestro Halil • Primera Oportunidad', 'El primer trato del día trae suerte muchacho • El cliente aguarda en la mesa por el $car.')
                  : ('Maestro Halil • Primera Oportunidad', 'El primer trato del día trae suerte muchacho • El cliente aguarda en la mesa de negociación.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('Maestro Halil • Mercado al Máximo', 'Tarde concurrida en el mercado • Cliente decidido vino por el $car, oferta preparada!')
                  : ('Maestro Halil • Mercado al Máximo', 'Tarde concurrida en el mercado • Cliente decidido vino al salón, oferta preparada!');
            } else if (v == 1) {
              return hasCar
                  ? ('Maestro Halil • Antes de la Notaría', 'El comprador ronda el $car muchacho • Siéntate a la mesa y cerremos el trato.')
                  : ('Maestro Halil • Antes de la Notaría', 'El comprador ronda la exposición muchacho • Siéntate a la mesa y cerremos el trato.');
            } else {
              return hasCar
                  ? ('Maestro Halil • Negociación Fuerte', 'La demanda está alta • Dejaron una buena oferta por el $car, échale un ojo muchacho!')
                  : ('Maestro Halil • Negociación Fuerte', 'La demanda está alta • Dejaron una buena oferta por tu auto, échale un ojo muchacho!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('Maestro Halil • Buena Racha Vespertina', 'Momento del apretón de manos final antes del cierre • Comprador esperando por el $car.')
                  : ('Maestro Halil • Buena Racha Vespertina', 'Momento del apretón de manos final antes del cierre • Comprador esperando en el salón.');
            } else if (v == 1) {
              return hasCar
                  ? ('Maestro Halil • Cierre con Ganancia', 'Terminemos la jornada con beneficios muchacho • Oferta por el $car en mesa, tú decides.')
                  : ('Maestro Halil • Cierre con Ganancia', 'Terminemos la jornada con beneficios muchacho • Oferta en mesa, tú decides.');
            } else {
              return hasCar
                  ? ('Maestro Halil • Último Cliente', 'En el fresco del atardecer llegó el último cliente • No dejes escapar el trato por el $car!')
                  : ('Maestro Halil • Último Cliente', 'En el fresco del atardecer llegó el último cliente • No dejes escapar el trato!');
            }
        }

      case 'ru':
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('Мастер Халиль • Утренний почин', 'Только подняли ставни парень • Первый покупатель зашел за $car, предложение на столе!')
                  : ('Мастер Халиль • Утренний почин', 'Только подняли ставни парень • Первый покупатель зашел в салон, предложение на столе!');
            } else if (v == 1) {
              return hasCar
                  ? ('Мастер Халиль • Вести из салона', 'Утренний чай готов, у дверей ждет клиент по поводу $car • Пора ударить по рукам!')
                  : ('Мастер Халиль • Вести из салона', 'Утренний чай готов, у дверей ждет клиент • Пора ударить по рукам!');
            } else {
              return hasCar
                  ? ('Мастер Халиль • Первая сделка дня', 'Первый почин приносит удачу сынок • Покупатель ждет за столом переговоров по $car.')
                  : ('Мастер Халиль • Первая сделка дня', 'Первый почин приносит удачу сынок • Покупатель ждет за столом переговоров.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('Мастер Халиль • Оживление на рынке', 'В дневные часы авторынок гудит • Прибыл серьезный покупатель на $car, предложение готово!')
                  : ('Мастер Халиль • Оживление на рынке', 'В дневные часы авторынок гудит • Прибыл серьезный покупатель, предложение готово!');
            } else if (v == 1) {
              return hasCar
                  ? ('Мастер Халиль • До закрытия конторы', 'Покупатель осматривает $car парень • Садись за стол, завершим продажу.')
                  : ('Мастер Халиль • До закрытия конторы', 'Покупатель осматривает витрину парень • Садись за стол, завершим продажу.');
            } else {
              return hasCar
                  ? ('Мастер Халиль • Горячий торг', 'Спрос на рынке высок • Оставили щедрое предложение за $car, взгляни сынок!')
                  : ('Мастер Халиль • Горячий торг', 'Спрос на рынке высок • Оставили щедрое предложение за машину, взгляни сынок!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('Мастер Халиль • Вечерняя удача', 'Время последнего рукопожатия перед закрытием • Покупатель ждет у дверей за $car.')
                  : ('Мастер Халиль • Вечерняя удача', 'Время последнего рукопожатия перед закрытием • Покупатель ждет у дверей салона.');
            } else if (v == 1) {
              return hasCar
                  ? ('Мастер Халиль • Сделка на закате', 'Завершим день с прибылью сынок • Предложение за $car на столе, решай сам.')
                  : ('Мастер Халиль • Сделка на закате', 'Завершим день с прибылью сынок • Предложение на столе, решай сам.');
            } else {
              return hasCar
                  ? ('Мастер Халиль • Последний клиент', 'В вечерней прохладе зашел последний покупатель • Не упусти выгоду по $car!')
                  : ('Мастер Халиль • Последний клиент', 'В вечерней прохладе зашел последний покупатель • Не упусти выгодную сделку!');
            }
        }

      case 'ar':
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('المعلم خليل • استفتاح الصباح', 'فتحنا أبواب المعرض للتو يا بني • دخل أول مشترٍ من أجل $car، والعرض على الطاولة!')
                  : ('المعلم خليل • استفتاح الصباح', 'فتحنا أبواب المعرض للتو يا بني • دخل أول مشترٍ إلى المعرض، والعرض على الطاولة!');
            } else if (v == 1) {
              return hasCar
                  ? ('المعلم خليل • أخبار المعرض', 'شاي الصباح جاهز، وهناك مشترٍ متحمس ينتظر $car عند الباب • تعال لنتصافح بالبيعة!')
                  : ('المعلم خليل • أخبار المعرض', 'شاي الصباح جاهز، وهناك مشترٍ متحمس ينتظر عند الباب • تعال لنتصافح بالبيعة!');
            } else {
              return hasCar
                  ? ('المعلم خليل • أولى صفقات اليوم', 'أول استبشار بركة يا بني • المشتري بانتظارك على طاولة التفاوض من أجل $car.')
                  : ('المعلم خليل • أولى صفقات اليوم', 'أول استبشار بركة يا بني • المشتري بانتظارك على طاولة التفاوض.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('المعلم خليل • السوق يشتعل', 'حركة سوق السيارات في ذروتها وقت الظهيرة • وصل مشترٍ جاد من أجل $car، وعرضه جاهز!')
                  : ('المعلم خليل • السوق يشتعل', 'حركة سوق السيارات في ذروتها وقت الظهيرة • وصل مشترٍ جاد، وعرضه جاهز!');
            } else if (v == 1) {
              return hasCar
                  ? ('المعلم خليل • قبل ازدحام التوثيق', 'المشتري يعاين $car باهتمام يا بني • اجلس إلى الطاولة ولننهِ البيعة.')
                  : ('المعلم خليل • قبل ازدحام التوثيق', 'المشتري يعاين المعرض باهتمام يا بني • اجلس إلى الطاولة ولننهِ البيعة.');
            } else {
              return hasCar
                  ? ('المعلم خليل • مساومة حامية', 'الطلب مرتفع في السوق • تركوا عرضاً طيباً من أجل $car، تفضل بالاطلاع عليه يا بني!')
                  : ('المعلم خليل • مساومة حامية', 'الطلب مرتفع في السوق • تركوا عرضاً طيباً من أجل سيارتك، تفضل بالاطلاع عليه يا بني!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('المعلم خليل • بركة سوق المساء', 'حان وقت مصافحة الختام قبل إغلاق المعرض • المشتري ينتظرك من أجل $car.')
                  : ('المعلم خليل • بركة سوق المساء', 'حان وقت مصافحة الختام قبل إغلاق المعرض • المشتري ينتظرك في المعرض.');
            } else if (v == 1) {
              return hasCar
                  ? ('المعلم خليل • مساومة ختام اليوم', 'دعنا نختم يومنا بربح طيب يا بني • عرض $car على الطاولة، ولك القرار.')
                  : ('المعلم خليل • مساومة ختام اليوم', 'دعنا نختم يومنا بربح طيب يا بني • العرض على الطاولة، ولك القرار.');
            } else {
              return hasCar
                  ? ('المعلم خليل • آخر زبائن اليوم', 'في نسمات المساء وصل آخر زبون إلى المعرض • لا تفوت عرض $car!')
                  : ('المعلم خليل • آخر زبائن اليوم', 'في نسمات المساء وصل آخر زبون إلى المعرض • لا تفوت الصفقة!');
            }
        }

      case 'tr':
      default:
        switch (slot) {
          case NotificationTimeSlot.morning:
            if (v == 0) {
              return hasCar
                  ? ('Halil Usta • Sabah Siftahı', 'Kepenkleri yeni açtık evlat • $car için ilk müşteri dükkana girdi, teklif masada!')
                  : ('Halil Usta • Sabah Siftahı', 'Kepenkleri yeni açtık evlat • Galerine ilk müşteri girdi, teklif masada!');
            } else if (v == 1) {
              return hasCar
                  ? ('Halil Usta • Dükkandan Haber Var', 'Sabah çayı demlendi, kapıda $car için hevesli bir alıcı bekliyor • Gel el sıkışalım!')
                  : ('Halil Usta • Dükkandan Haber Var', 'Sabah çayı demlendi, kapıda hevesli bir alıcı bekliyor • Gel el sıkışalım!');
            } else {
              return hasCar
                  ? ('Halil Usta • Günün İlk Fırsatı', 'Günün ilk siftahı berekettir evlat • $car için alıcı pazarlık masasında bekliyor.')
                  : ('Halil Usta • Günün İlk Fırsatı', 'Günün ilk siftahı berekettir evlat • Alıcı pazarlık masasında bekliyor.');
            }
          case NotificationTimeSlot.afternoon:
            if (v == 0) {
              return hasCar
                  ? ('Halil Usta • Pazar Hareketlendi', 'Öğle sıcağında oto pazarı kaynıyor • $car için ciddi bir müşteri geldi, teklifi hazır!')
                  : ('Halil Usta • Pazar Hareketlendi', 'Öğle sıcağında oto pazarı kaynıyor • Vitrindeki aracına ciddi bir müşteri geldi, teklifi hazır!');
            } else if (v == 1) {
              return hasCar
                  ? ('Halil Usta • Noter Sırası Gelmeden', 'Alıcı $car başında volta atıyor evlat • Gel masaya otur, satışı bitirelim.')
                  : ('Halil Usta • Noter Sırası Gelmeden', 'Alıcı vitrinin önünde volta atıyor evlat • Gel masaya otur, satışı bitirelim.');
            } else {
              return hasCar
                  ? ('Halil Usta • Hararetli Pazarlık', 'Piyasada talep yüksek • $car için güzel bir teklif bıraktılar, göz at evlat!')
                  : ('Halil Usta • Hararetli Pazarlık', 'Piyasada talep yüksek • Vitrindeki aracın için güzel bir teklif bıraktılar, göz at evlat!');
            }
          case NotificationTimeSlot.evening:
            if (v == 0) {
              return hasCar
                  ? ('Halil Usta • Akşam Pazarı Bereketi', 'Kepenkleri indirmeden son el sıkışma vakti • $car için alıcı kapıda bekliyor.')
                  : ('Halil Usta • Akşam Pazarı Bereketi', 'Kepenkleri indirmeden son el sıkışma vakti • Galerine son müşteri uğradı.');
            } else if (v == 1) {
              return hasCar
                  ? ('Halil Usta • Gün Sonu Pazarlığı', 'Günü kârla kapatalım evlat • $car için teklif masada, kararı sen ver.')
                  : ('Halil Usta • Gün Sonu Pazarlığı', 'Günü kârla kapatalım evlat • Teklif masada bekliyor, kararı sen ver.');
            } else {
              return hasCar
                  ? ('Halil Usta • Son Müşteri', 'Akşam serinliğinde son müşteri dükkana uğradı • $car teklifini kaçırma!')
                  : ('Halil Usta • Son Müşteri', 'Akşam serinliğinde son müşteri dükkana uğradı • Gelen teklifi kaçırma!');
            }
        }
    }
  }

  /// Gunluk esnaf destegi bildirim metinlerini zaman dilimi, varyant ve dile gore cozer
  static (String, String) resolveDailyCopy(
    String lang, {
    required NotificationTimeSlot slot,
    required int variant,
  }) {
    final v = variant % 2;

    switch (lang.toLowerCase()) {
      case 'en':
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('Master Halil • Merchant Solidarity', 'Opened up the shop and put fresh funds in the register lad • Come start the day right!')
                : ('Master Halil • Morning Tea Ready', 'The industrial district is awake lad • Your daily dealer cut is ready, shop is waiting!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('Master Halil • Daily Support Ready', 'Market is turning lad • Collect your daily grant from the register, do not miss deals!')
                : ('Master Halil • Back to the Desk', 'A shop thrives when the master is present • Your daily reward is on the counter!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('Master Halil • Daily Wrap-up', 'Today\'s dealer support sits in the register lad • Come claim your share and grab tea.')
                : ('Master Halil • Evening Books', 'Counted the till and set aside your merchant cut • Drop by the dealership and take it!');
        }

      case 'de':
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('Meister Halil • Händler-Gemeinschaft', 'Laden geöffnet und Tageszuschuss in die Kasse gelegt Junge • Lass uns frisch starten!')
                : ('Meister Halil • Morgentee bereit', 'Das Gewerbegebiet ist erwacht Junge • Dein Tagesanteil liegt bereit, der Laden wartet!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('Meister Halil • Händler-Hilfe bereit', 'Der Markt dreht sich Junge • Hol dir die tägliche Unterstützung aus der Kasse!')
                : ('Meister Halil • Zurück an die Arbeit', 'Der Laden floriert wenn der Chef da ist • Deine Tagesbelohnung wartet am Tresen!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('Meister Halil • Tagesabschluss', 'Die tägliche Händlerhilfe liegt in der Kasse Junge • Hol dir deinen Anteil vor Feierabend!')
                : ('Meister Halil • Kassensturz', 'Habe die Kasse gezählt und deinen Anteil beiseite gelegt • Komm im Autohaus vorbei!');
        }

      case 'pt':
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('Mestre Halil • União de Comerciante', 'Abri a oficina e separei a ajuda do dia no caixa garoto • Venha começar com o pé direito!')
                : ('Mestre Halil • Chá da Manhã Pronto', 'O setor automotivo acordou garoto • Sua cota diária está pronta, a loja espera por você!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('Mestre Halil • Apoio Diário Pronto', 'O comércio não para garoto • Pegue seu apoio diário no caixa e aproveite as oportunidades!')
                : ('Mestre Halil • Hora do Trabalho', 'A loja prospera quando o dono está presente • Sua recompensa diária está no balcão!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('Mestre Halil • Balanço Diário', 'O apoio de hoje está reservado no caixa garoto • Venha retirar sua parte e tomar um café!')
                : ('Mestre Halil • Caixa Fechado', 'Fechei a conta e guardei seu bônus diário • Passe na loja e resgate sua recompensa!');
        }

      case 'es':
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('Maestro Halil • Solidaridad del Gremio', 'Abrí el concesionario y dejé el apoyo del día en la caja muchacho • Empecemos con fuerza!')
                : ('Maestro Halil • Té de la Mañana', 'El polígono ya despertó muchacho • Tu cuota diaria está lista, el negocio te espera!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('Maestro Halil • Apoyo Diario Listo', 'El mercado está activo muchacho • Recoge tu ayuda diaria de la caja y no pierdas gangas!')
                : ('Maestro Halil • Vuelta al Ruedo', 'El negocio rinde cuando el dueño da la cara • Tu recompensa diaria te espera!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('Maestro Halil • Balance del Día', 'El apoyo de hoy te espera en caja muchacho • Ven a cobrar tu parte y tomar un descanso!')
                : ('Maestro Halil • Cuadre de Caja', 'Hice el recuento y aparté tu bonificación diaria • Pasa por el concesionario a recogerla!');
        }

      case 'ru':
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('Мастер Халиль • Купеческая взаимовыручка', 'Открыл салон и положил поддержку на новый день в кассу сынок • Начнем с добром!')
                : ('Мастер Халиль • Утренний чай готов', 'Авторынок проснулся парень • Твоя дневная доля ждет в кассе, салон открыт!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('Мастер Халиль • Поддержка готова', 'Торговля кипит сынок • Забери ежедневную поддержку из кассы и лови выгоду!')
                : ('Мастер Халиль • Время за работу', 'Дело спорится когда хозяин на месте • Твоя ежедневная награда на столе!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('Мастер Халиль • Итоги дня', 'Дневная поддержка ждет тебя в кассе сынок • Забери свою долю и отдохни за чаем!')
                : ('Мастер Халиль • Вечерний расчет', 'Подсчитал кассу и отложил твою долю • Загляни в салон и забери расчет!');
        }

      case 'ar':
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('المعلم خليل • تكاتف التجار', 'فتحت المعرض ووضعت دعم اليوم الجديد في الخزينة يا بني • تعال ولنبدأ باسم الله!')
                : ('المعلم خليل • شاي الصباح جاهز', 'استيقظت المنطقة الصناعية يا بني • حصتك اليومية جاهزة في الخزينة، والمعرض ينتظرك!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('المعلم خليل • الدعم اليومي جاهز', 'السوق يدور يا بني • استلم دعمك اليومي من الخزينة ولا تفوت الصفقات الرابحة!')
                : ('المعلم خليل • حان وقت العمل', 'بركة المعرض بحضور صاحبه • مكافأتك اليومية على الطاولة بانتظارك!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('المعلم خليل • كشف ختام اليوم', 'دعم التجار لهذا اليوم محفوظ في الخزينة يا بني • تعال واستلم حصتك واشرب شاي الراحة!')
                : ('المعلم خليل • حساب المساء', 'أحصيت الخزينة وعزلت نصيبك من أرباح اليوم • مر على المعرض واستلم مستحقاتك!');
        }

      case 'tr':
      default:
        switch (slot) {
          case NotificationTimeSlot.morning:
            return v == 0
                ? ('Halil Usta • Esnaf Dayanışması', 'Dükkanı açtım, yeni gün desteğini kasaya koydum evlat • Gel bismillah diyelim!')
                : ('Halil Usta • Sabah Çayı Hazır', 'Sanayi uyandı evlat • Günlük esnaf payın hazır, dükkan seni bekler!');
          case NotificationTimeSlot.afternoon:
            return v == 0
                ? ('Halil Usta • Esnaf Desteği Hazır', 'Piyasa dönüyor evlat • Günlük desteğini kasadan al, yeni fırsatları kaçırma!')
                : ('Halil Usta • Tezgaha Dönüş Vakti', 'Dükkanın bereketi esnafın başında durmasıyla artar • Günlük ödülün masada!');
          case NotificationTimeSlot.evening:
            return v == 0
                ? ('Halil Usta • Gün Sonu Raporu', 'Günün esnaf desteği kasada duruyor evlat • Gel hakkını al, yorgunluk çayı içelim.')
                : ('Halil Usta • Akşam Hesabı', 'Kasayı saydım, bugünkü esnaf payını ayırdım • Dükkana uğra, payını al evlat!');
        }
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    if (response.payload != null && response.payload!.isNotEmpty) {
      payloadStream.add(response.payload!);
    }
  }
}
