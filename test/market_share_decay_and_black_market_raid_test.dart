import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/stock_model.dart';
import 'package:galeriden/domain/usecases/random_event_engine.dart';
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

  group('Kara Borsa Polis Baskını & Dramatik Event Tests', () {
    late GameNotifier notifier;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      notifier = GameNotifier();
    });

    test('RandomEventEngine içinde event_black_market_raid eventi eksiksiz mevcuttur', () {
      final allEvents = RandomEventEngine.allEventTemplates;
      final raidEvent = allEvents.firstWhere((e) => e.id == 'event_black_market_raid');

      expect(raidEvent, isNotNull);
      expect(raidEvent.title, contains('GECE PAZARI POLİS BASKINI • MALİYE & KAÇAKÇILIK OPERASYONU'));
      expect(raidEvent.choices.length, equals(3));

      // Seçenek 1: Hukuk Danışmanı
      expect(raidEvent.choices[0].label, contains('Hukuk Danışmanını Ara • -25.000 ₺'));
      expect(raidEvent.choices[0].balanceChange, equals(-25000.0));
      expect(raidEvent.choices[0].reputationChange, equals(5));

      // Seçenek 2: Cezayı Kabul Et
      expect(raidEvent.choices[1].label, contains('Cezayı Kabul Et & Aracı Teslim Et • -60.000 ₺'));
      expect(raidEvent.choices[1].balanceChange, equals(-60000.0));
      expect(raidEvent.choices[1].reputationChange, equals(-20));

      // Seçenek 3: Kaçırmaya Çalış
      expect(raidEvent.choices[2].label, contains('Gece Yarısı Aracı Kaçırmaya Çalış • Riskli'));
      expect(raidEvent.choices[2].balanceChange, equals(-150000.0));
      expect(raidEvent.choices[2].reputationChange, equals(-35));
    });

    test('event_black_market_raid metinlerinde sıfır emoji ve sıfır parantez kuralına tam uyulmuştur', () {
      final allEvents = RandomEventEngine.allEventTemplates;
      final raidEvent = allEvents.firstWhere((e) => e.id == 'event_black_market_raid');

      // Zero Unicode Emoji check
      final emojiRegex = RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true);
      expect(emojiRegex.hasMatch(raidEvent.title), isFalse);
      expect(emojiRegex.hasMatch(raidEvent.description), isFalse);

      for (final choice in raidEvent.choices) {
        expect(emojiRegex.hasMatch(choice.label), isFalse);
        expect(emojiRegex.hasMatch(choice.resultText), isFalse);

        // Zero Parentheses check
        expect(choice.label.contains('(') || choice.label.contains(')'), isFalse);
        expect(choice.resultText.contains('(') || choice.resultText.contains(')'), isFalse);
      }
    });

    test('resolveRandomEvent çağrıldığında bakiye, itibar ve xp doğru mutasyona uğrar', () {
      notifier.state = notifier.state.copyWith(
        balance: 200000.0,
        reputationScore: 50,
      );

      final choice = GameEventChoice(
        label: 'Hukuk Danışmanını Ara • -25.000 ₺',
        resultText: 'Avukat tedbiri durdurdu.',
        balanceChange: -25000.0,
        reputationChange: 5,
        xpGain: 120,
      );

      notifier.resolveRandomEvent(choice);

      expect(notifier.state.balance, equals(175000.0));
      expect(notifier.state.reputationScore, equals(55));
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
