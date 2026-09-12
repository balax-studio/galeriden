import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/local_notification_service.dart';

void main() {
  group('Quiet Hours Notification Guard Tests (§SPEC-2026-09-12-NOTIFICATION-HARDENING)', () {
    test('Gündüz saatlerinde (14:00) kurulan 90 dakikalık bildirim normal saatinde (15:30) kalır', () {
      final afternoon = DateTime(2026, 9, 12, 14, 0);
      final safeTime = LocalNotificationService.calculateSafeScheduledTime(
        afternoon,
        const Duration(minutes: 90),
      );

      expect(safeTime.year, 2026);
      expect(safeTime.month, 9);
      expect(safeTime.day, 12);
      expect(safeTime.hour, 15);
      expect(safeTime.minute, 30);
    });

    test('Gece 22:30\'da oyundan çıkıldığında 90 dk sonraki gece yarısı (00:00) bildirimi sabah 09:30\'a ötelenir', () {
      final night = DateTime(2026, 9, 12, 22, 30);
      final safeTime = LocalNotificationService.calculateSafeScheduledTime(
        night,
        const Duration(minutes: 90),
      );

      expect(safeTime.year, 2026);
      expect(safeTime.month, 9);
      expect(safeTime.day, 13); // Ertesi gün
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });

    test('Gece 21:00\'de çıkıldığında 90 dk sonraki (22:30) sessiz saat bildirimi ertesi sabah 09:30\'a ötelenir', () {
      final lateEvening = DateTime(2026, 9, 12, 21, 0);
      final safeTime = LocalNotificationService.calculateSafeScheduledTime(
        lateEvening,
        const Duration(minutes: 90),
      );

      expect(safeTime.year, 2026);
      expect(safeTime.month, 9);
      expect(safeTime.day, 13);
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });

    test('Sabah erken saatte (06:00) kurulan 90 dk sonraki (07:30) bildirim uykuyu bölmemek için aynı gün 09:30\'a ötelenir', () {
      final earlyMorning = DateTime(2026, 9, 12, 6, 0);
      final safeTime = LocalNotificationService.calculateSafeScheduledTime(
        earlyMorning,
        const Duration(minutes: 90),
      );

      expect(safeTime.year, 2026);
      expect(safeTime.month, 9);
      expect(safeTime.day, 12); // Aynı gün sabahı
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });

    test('24 saatlik bildirim gece geç saate (23:30) denk gelirse ertesi sabah 09:30\'a kaydırılır', () {
      final lateNight = DateTime(2026, 9, 12, 23, 30);
      final safeTime = LocalNotificationService.calculateSafeScheduledTime(
        lateNight,
        const Duration(hours: 24),
      );

      expect(safeTime.year, 2026);
      expect(safeTime.month, 9);
      expect(safeTime.day, 14); // 23:30 ertesi gün -> sessiz saat -> ertesi sabah
      expect(safeTime.hour, 9);
      expect(safeTime.minute, 30);
    });
  });

  group('Time-Sensitive Notification Dialogue Pool Tests (§SPEC-2026-09-12-TIME-SENSITIVE-NOTIFICATIONS)', () {
    test('getTimeSlot saat dilimlerini doğru tespit eder', () {
      expect(LocalNotificationService.getTimeSlot(9), NotificationTimeSlot.morning);
      expect(LocalNotificationService.getTimeSlot(11), NotificationTimeSlot.morning);
      expect(LocalNotificationService.getTimeSlot(12), NotificationTimeSlot.afternoon);
      expect(LocalNotificationService.getTimeSlot(16), NotificationTimeSlot.afternoon);
      expect(LocalNotificationService.getTimeSlot(17), NotificationTimeSlot.evening);
      expect(LocalNotificationService.getTimeSlot(21), NotificationTimeSlot.evening);
    });

    test('Sabah, öğle ve akşam vitrin bildirimleri zaman dilimine uygun lora sahiptir', () {
      final morningCopy = LocalNotificationService.resolveShowroomCopy(
        'tr',
        slot: NotificationTimeSlot.morning,
        variant: 0,
        carTitle: 'Renault Clio',
      );
      expect(morningCopy.$1, contains('Sabah Siftahı'));
      expect(morningCopy.$2, contains('Renault Clio'));
      expect(morningCopy.$2, contains('Kepenkleri'));

      final afternoonCopy = LocalNotificationService.resolveShowroomCopy(
        'tr',
        slot: NotificationTimeSlot.afternoon,
        variant: 0,
        carTitle: 'Fiat Egea',
      );
      expect(afternoonCopy.$1, contains('Pazar Hareketlendi'));
      expect(afternoonCopy.$2, contains('Fiat Egea'));
      expect(afternoonCopy.$2, contains('oto pazarı kaynıyor'));

      final eveningCopy = LocalNotificationService.resolveShowroomCopy(
        'tr',
        slot: NotificationTimeSlot.evening,
        variant: 0,
        carTitle: 'BMW 320i',
      );
      expect(eveningCopy.$1, contains('Akşam Pazarı Bereketi'));
      expect(eveningCopy.$2, contains('BMW 320i'));
      expect(eveningCopy.$2, contains('Kepenkleri indirmeden'));
    });

    test('Tüm 7 dilde sıfır parantez ve sıfır emoji kuralı korunur', () {
      final languages = ['tr', 'en', 'de', 'pt', 'es', 'ru', 'ar'];
      final slots = NotificationTimeSlot.values;

      final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
        unicode: true,
      );

      for (final lang in languages) {
        for (final slot in slots) {
          for (int v = 0; v < 3; v++) {
            final (title, body) = LocalNotificationService.resolveShowroomCopy(
              lang,
              slot: slot,
              variant: v,
              carTitle: 'Test Car',
            );

            expect(title.isNotEmpty, isTrue);
            expect(body.isNotEmpty, isTrue);
            expect(title.contains('(') || title.contains(')'), isFalse, reason: 'Title contains parenthesis in $lang');
            expect(body.contains('(') || body.contains(')'), isFalse, reason: 'Body contains parenthesis in $lang');
            expect(emojiRegex.hasMatch(title), isFalse, reason: 'Title contains emoji in $lang');
            expect(emojiRegex.hasMatch(body), isFalse, reason: 'Body contains emoji in $lang');
          }

          for (int v = 0; v < 2; v++) {
            final (title, body) = LocalNotificationService.resolveDailyCopy(
              lang,
              slot: slot,
              variant: v,
            );

            expect(title.isNotEmpty, isTrue);
            expect(body.isNotEmpty, isTrue);
            expect(title.contains('(') || title.contains(')'), isFalse, reason: 'Daily title contains parenthesis in $lang');
            expect(body.contains('(') || body.contains(')'), isFalse, reason: 'Daily body contains parenthesis in $lang');
            expect(emojiRegex.hasMatch(title), isFalse, reason: 'Daily title contains emoji in $lang');
            expect(emojiRegex.hasMatch(body), isFalse, reason: 'Daily body contains emoji in $lang');
          }
        }
      }
    });
  });
}
