import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/dramatic_card_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/domain/usecases/offline_progression.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dramatik Karar Kartları Kaos & Dayanıklılık Testleri (Chaos & Resilience Suite)', () {
    // -------------------------------------------------------------------------
    // SENARYO 1: Hızlı Gün İlerlemeleri & Üzerine Yazılma Koruması (Day Advance Spam)
    // -------------------------------------------------------------------------
    test('Kaos 1: Başka ekrandayken peş peşe 30 gün atlasa bile bekleyen kart asla ezilmez veya kaybolmaz', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // Day 1: Bekleyen kartı al
      final initialCard = notifier.state.pendingDramaticCard;
      expect(initialCard, isNotNull);
      final initialCardId = initialCard!.id;

      // Kullanıcı başka ekranda 30 gün bekledi (30 gün tick'i)
      for (int i = 0; i < 30; i++) {
        notifier.advanceGameDay();
        // Kartın asla ezilmediğini her gün doğrula
        expect(notifier.state.pendingDramaticCard, isNotNull);
        expect(notifier.state.pendingDramaticCard!.id, equals(initialCardId));
      }

      expect(notifier.state.currentDay, equals(31));
      expect(notifier.state.pendingDramaticCard!.id, equals(initialCardId));

      // Kart çözülünce bir sonraki gün yeni kart üretilir
      final choice = notifier.state.pendingDramaticCard!.choices.first;
      notifier.resolveDramaticCardChoice(
        card: notifier.state.pendingDramaticCard!,
        choice: choice,
      );
      notifier.dismissPendingDramaticCard();
      expect(notifier.state.pendingDramaticCard, isNull);

      // Yeni gün ilerlemesinde 32. günün kartı üretilir
      notifier.advanceGameDay();
      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(notifier.state.pendingDramaticCard!.dayNumber, equals(32));
    });

    // -------------------------------------------------------------------------
    // SENARYO 2: Uygulama Çökmesi / Bellekten Silinme & JSON Deserialization (Cold Restart)
    // -------------------------------------------------------------------------
    test('Kaos 2: Bekleyen kart JSON serialization/deserialization döngüsünde hiçbir verisini kaybetmez', () {
      final card = DramaticCardEngine.generateDailyDilemma(
        42,
        DealershipModel.initial().copyWith(currentDay: 42),
      );

      final stateWithCard = DealershipModel.initial().copyWith(
        currentDay: 42,
        pendingDramaticCard: card,
      );

      // Diske yazma simülasyonu (toJson)
      final json = stateWithCard.toJson();
      expect(json['pendingDramaticCard'], isNotNull);

      // Diskten okuma simülasyonu (fromJson)
      final restoredState = DealershipModel.fromJson(json);
      expect(restoredState.pendingDramaticCard, isNotNull);
      expect(restoredState.pendingDramaticCard!.id, equals(card.id));
      expect(restoredState.pendingDramaticCard!.title, equals(card.title));
      expect(restoredState.pendingDramaticCard!.dialogue, equals(card.dialogue));
      expect(restoredState.pendingDramaticCard!.dayNumber, equals(42));
      expect(restoredState.pendingDramaticCard!.choices.length, equals(card.choices.length));

      for (int i = 0; i < card.choices.length; i++) {
        expect(restoredState.pendingDramaticCard!.choices[i].label, equals(card.choices[i].label));
        expect(restoredState.pendingDramaticCard!.choices[i].upfrontCost, equals(card.choices[i].upfrontCost));
      }
    });

    // -------------------------------------------------------------------------
    // SENARYO 3: Uzun Süre Çevrimdışı Kalma & Zaman Atlama (Offline Time Jump)
    // -------------------------------------------------------------------------
    test('Kaos 3: Oyuncu 30 gün boyunca oyuna girmese bile offline motoru bekleyen kartı silmez', () {
      final initialCard = DramaticCardEngine.generateDailyDilemma(5, DealershipModel.initial());
      final dealership = DealershipModel.initial().copyWith(
        currentDay: 5,
        balance: 500000.0,
        pendingDramaticCard: initialCard,
        lastActiveTime: DateTime.now().subtract(const Duration(days: 30)),
      );

      final offlineResult = OfflineProgression.processOfflineTime(dealership);
      final DealershipModel updatedDealership = offlineResult['updatedDealership'];

      // Günler ilerlemiş olsa bile bekleyen kart korunmalı ve güncel günle senkronize edilmeli
      expect(updatedDealership.currentDay, greaterThan(5));
      expect(updatedDealership.pendingDramaticCard, isNotNull);
      expect(updatedDealership.pendingDramaticCard!.id, equals(initialCard.id));
      expect(updatedDealership.pendingDramaticCard!.dayNumber, equals(updatedDealership.currentDay));
    });

    // -------------------------------------------------------------------------
    // SENARYO 4: Çoklu Olay Çakışması Kuyruğu (Dramatic + Random Event + Story)
    // -------------------------------------------------------------------------
    test('Kaos 4: Dramatik kart, rastgele olay ve hikaye kartı aynı anda tetiklense bile bağımsız state alanlarında korunur', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      final randomEvent = GameEventModel(
        id: 'rand_01',
        title: 'Vergi Denetimi',
        description: 'Maliye müfettişleri galeriyi denetledi.',
        date: DateTime.now(),
        type: GameEventType.neutral,
        amount: 0.0,
      );

      final dramaticCard = DramaticCardEngine.generateDailyDilemma(10, notifier.state);

      notifier.state = notifier.state.copyWith(
        pendingDramaticCard: dramaticCard,
        pendingRandomEvent: randomEvent,
      );

      // İki olay da bağımsız olarak mevcut olmalı
      expect(notifier.state.pendingDramaticCard, isNotNull);
      expect(notifier.state.pendingRandomEvent, isNotNull);

      // Dramatik kartı çöz
      notifier.resolveDramaticCardChoice(
        card: dramaticCard,
        choice: dramaticCard.choices.first,
      );
      notifier.dismissPendingDramaticCard();

      // Dramatik kart null oldu ama rastgele olay hala bekliyor
      expect(notifier.state.pendingDramaticCard, isNull);
      expect(notifier.state.pendingRandomEvent, isNotNull);
      expect(notifier.state.pendingRandomEvent!.id, equals('rand_01'));
    });

    // -------------------------------------------------------------------------
    // SENARYO 5: Bakiye & Envanter Değişimi Dayanıklılığı (Negative Balance & Missing Asset Safety)
    // -------------------------------------------------------------------------
    test('Kaos 5: Oyuncu parasını tüketse bile kart çözümü çökmez, borç/itibar/araç etkileri güvenle uygulanır', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      // Bakiyeyi 0'a indir
      notifier.state = notifier.state.copyWith(balance: 0.0, reputationScore: 50);

      // Yüksek masraflı veya riskli bir kart oluştur
      final costlyChoice = DramaticChoiceModel(
        id: 'c_costly',
        label: 'Tefeciye Git',
        shortDescription: 'Acil nakit al',
        upfrontCost: 20000.0,
        outcomes: [
          DramaticOutcomeModel(
            title: 'Kötü Sonuç',
            isSuccess: false,
            message: 'Tefeci faizle borç verdi.',
            moneyDelta: -50000.0,
            reputationDelta: -10,
            probability: 1.0,
          ),
        ],
      );

      final card = DramaticCardModel(
        id: 'chaos_card',
        category: DramaticCategory.gamble,
        severity: DramaticSeverity.extreme,
        title: 'Kaos Kararı',
        characterName: 'Tefeci Mahmut',
        characterRole: 'Tefeci',
        characterAvatar: 'shadow',
        icon: Icons.dangerous,
        dialogue: 'Para lazım mı?',
        foreshadowHint: 'Geri dönüşü yok.',
        choices: [costlyChoice],
      );

      final result = notifier.resolveDramaticCardChoice(
        card: card,
        choice: costlyChoice,
      );

      // Upfront cost ve moneyDelta güvenle bakiyeyi eksiye düşürmeli, NaN/null olmamalı
      expect(result.updatedState.balance, equals(-70000.0));
      expect(result.updatedState.reputationScore, equals(40));
    });

    test('OfflineProgression 30dk=1gün ve tavan 3 gün kuralı ile kart senkronizasyonu', () {
      final base = DealershipModel.initial().copyWith(
        currentDay: 8,
        pendingDramaticCard: DramaticCardEngine.generateDailyDilemma(8, DealershipModel.initial()),
      );

      // 1. 20 dakika çevrimdışı -> 0 gün ilerler
      final res20m = OfflineProgression.processOfflineTime(
        base.copyWith(lastActiveTime: DateTime.now().subtract(const Duration(minutes: 20))),
      );
      expect(res20m['daysElapsed'], equals(0));
      final DealershipModel state20m = res20m['updatedDealership'];
      expect(state20m.currentDay, equals(8));
      expect(state20m.pendingDramaticCard!.dayNumber, equals(8));

      // 2. 35 dakika çevrimdışı -> 1 gün ilerler (8 -> 9)
      final res35m = OfflineProgression.processOfflineTime(
        base.copyWith(lastActiveTime: DateTime.now().subtract(const Duration(minutes: 35))),
      );
      expect(res35m['daysElapsed'], equals(1));
      final DealershipModel state35m = res35m['updatedDealership'];
      expect(state35m.currentDay, equals(9));
      expect(state35m.pendingDramaticCard!.dayNumber, equals(9));

      // 3. 70 dakika çevrimdışı -> 2 gün ilerler (8 -> 10)
      final res70m = OfflineProgression.processOfflineTime(
        base.copyWith(lastActiveTime: DateTime.now().subtract(const Duration(minutes: 70))),
      );
      expect(res70m['daysElapsed'], equals(2));
      final DealershipModel state70m = res70m['updatedDealership'];
      expect(state70m.currentDay, equals(10));
      expect(state70m.pendingDramaticCard!.dayNumber, equals(10));

      // 4. 12 saat çevrimdışı -> Tavan 3 gün ilerler (8 -> 11)
      final res12h = OfflineProgression.processOfflineTime(
        base.copyWith(lastActiveTime: DateTime.now().subtract(const Duration(hours: 12))),
      );
      expect(res12h['daysElapsed'], equals(3));
      final DealershipModel state12h = res12h['updatedDealership'];
      expect(state12h.currentDay, equals(11));
      expect(state12h.pendingDramaticCard!.dayNumber, equals(11));
    });
  });
}
