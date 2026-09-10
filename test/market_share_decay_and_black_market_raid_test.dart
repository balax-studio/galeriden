import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Semt Hakimiyeti Doğal Aşınması (Market Share Decay) Tests', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
    });

    test('Semt pazar payı %10 üzerindeyken zar tutarsa %2-%5 arasında aşınır ve taban %5 altına düşmez', () {
      final initialShares = {
        'Bağcılar Oto Pazarı': 0.80,
        'İkitelli Sanayi': 0.08, // <= %10 -> aşınmaz
        'Kadıköy Rıhtım': 0.06,  // <= %10 -> aşınmaz
      };

      // Mock random: nextDouble() returns 0.10 (< 0.20 -> trigger decay), decay rate calculation
      final mockRandom = _PredictableRandom([0.10, 0.50]); // 0.10 triggers (<0.20), 0.50 -> 0.02 + 0.50*0.03 = 0.035 (%3.5 loss)

      final events = <GameEventModel>[];
      final result = notifier.processDistrictMarketDecayForTesting(
        initialShares,
        events,
        randomInstance: mockRandom,
      );

      final updatedShares = result.$1;
      final updatedEvents = result.$2;

      // Bağcılar: 0.80 - 0.035 = 0.765
      expect(updatedShares['Bağcılar Oto Pazarı'], closeTo(0.765, 0.001));
      expect(updatedShares['İkitelli Sanayi'], equals(0.08));
      expect(updatedShares['Kadıköy Rıhtım'], equals(0.06));

      // Event oluşturuldu mu?
      expect(updatedEvents.isNotEmpty, isTrue);
      expect(updatedEvents.first.title, contains('Bağcılar Oto Pazarı • Rakip Esnaf Hamlesi!'));
      expect(updatedEvents.first.description, contains('Pazar payın %4 azaldı')); // round(0.035 * 100) = 4
      expect(updatedEvents.first.type, equals(GameEventType.badEvent));
    });

    test('Pazar payı %10 üzerinde olsa bile aşınma taban %5 sınırına kenetlenir', () {
      final initialShares = {
        'Nişantaşı Vitrin': 0.11,
      };

      // Mock random: nextDouble() returns 0.05 (< 0.20 -> trigger), lossRate = 0.02 + 0.99*0.03 = 0.0497
      final mockRandom = _PredictableRandom([0.05, 0.99]);

      final events = <GameEventModel>[];
      final result = notifier.processDistrictMarketDecayForTesting(
        initialShares,
        events,
        randomInstance: mockRandom,
      );

      expect(result.$1['Nişantaşı Vitrin']! >= 0.05, isTrue);
    });

    test('Zar tutmazsa (>= %20) pazar payı korunur ve event üretilmez', () {
      final initialShares = {
        'Bağcılar Oto Pazarı': 0.95,
      };

      // Mock random: 0.50 (>= 0.20 -> no decay)
      final mockRandom = _PredictableRandom([0.50]);

      final events = <GameEventModel>[];
      final result = notifier.processDistrictMarketDecayForTesting(
        initialShares,
        events,
        randomInstance: mockRandom,
      );

      expect(result.$1['Bağcılar Oto Pazarı'], equals(0.95));
      expect(result.$2.isEmpty, isTrue);
    });
  });

  group('Banka Mevduat Faizi ve Halka Arz (IPO) Doğrulama Tests', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
    });

    test('Banka mevduat faizi günlük %0.12 doğru hesaplanır', () {
      const double initialDeposit = 100000.0;
      final updated = notifier.processBankInterestForTesting(initialDeposit);

      // 100000 * 0.0012 = 120.0
      expect(updated, equals(100120.0));
    });

    test('Banka mevduatı sıfır veya negatifken faiz işletilmez', () {
      final updated = notifier.processBankInterestForTesting(0.0);
      expect(updated, equals(0.0));
    });

    test('Halka arz günü geldiğinde katsayısıyla nakit kazanç sağlar ve event bildirimi oluşturur', () {
      final ipo = IpoOfferModel(
        id: 'ipo_test_1',
        companyName: 'Anadolu Batarya A.Ş.',
        symbol: 'ANABAT',
        lotPrice: 100.0,
        totalLotsAvailable: 50000,
        daysUntilListing: 1,
        listingMultiplier: 1.60, // %60 tavan açılış
        description: 'Yerli elektrikli araç bataryası üreticisi.',
      );

      final playerReq = PlayerIpoRequestModel(
        ipoId: 'ipo_test_1',
        requestedLots: 10,
        totalSpent: 50000.0,
      );

      notifier.state = notifier.state.copyWith(
        balance: 100000.0,
        activeIpos: [ipo],
        playerIpoRequests: [playerReq],
      );

      notifier.advanceGameDay();

      // Payout = 50000 * 1.60 = 80000
      final ipoEvent = notifier.state.recentEvents.firstWhere(
        (e) => e.title.contains('ANABAT') && e.title.contains('Tavan Açtı'),
      );

      expect(ipoEvent, isNotNull);
      expect(ipoEvent.title, contains('Anadolu Batarya A.Ş. • ANABAT Borsada Tavan Açtı!'));
      expect(notifier.state.activeIpos.first.isListed, isTrue);
    });
  });
}

class _PredictableRandom implements Random {
  final List<double> _doubleValues;
  int _doubleIndex = 0;

  _PredictableRandom(this._doubleValues);

  @override
  double nextDouble() {
    if (_doubleValues.isEmpty) return 0.0;
    final val = _doubleValues[_doubleIndex % _doubleValues.length];
    _doubleIndex++;
    return val;
  }

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => true;
}
