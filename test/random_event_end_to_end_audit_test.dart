import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/game_event_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/domain/usecases/random_event_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Random Event Engine & Side Business End-to-End Comprehensive Audit', () {
    test('1. Template Catalog Integrity: ID uniqueness, zero duplicate IDs', () {
      final templates = RandomEventEngine.allEventTemplates;
      expect(templates.length, greaterThan(80));

      final seenIds = <String>{};
      for (final event in templates) {
        expect(
          seenIds.contains(event.id),
          isFalse,
          reason: 'Duplicate event ID found: ${event.id}',
        );
        seenIds.add(event.id);
      }
    });

    test('2. Invariant Rules: Zero Unicode Emojis and Zero Parentheses in all strings', () {
      final templates = RandomEventEngine.allEventTemplates;
      final parenthesesRegex = RegExp(r'[()]');
      final emojiRegex = RegExp(
          r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]',
          unicode: true);

      for (final event in templates) {
        expect(parenthesesRegex.hasMatch(event.title), isFalse,
            reason: 'Title "${event.title}" must not contain parentheses');
        expect(parenthesesRegex.hasMatch(event.description), isFalse,
            reason: 'Description "${event.description}" must not contain parentheses');
        expect(emojiRegex.hasMatch(event.title), isFalse,
            reason: 'Title "${event.title}" must not contain emoji');
        expect(emojiRegex.hasMatch(event.description), isFalse,
            reason: 'Description "${event.description}" must not contain emoji');

        for (final choice in event.choices) {
          expect(parenthesesRegex.hasMatch(choice.label), isFalse,
              reason: 'Choice label "${choice.label}" must not contain parentheses');
          expect(parenthesesRegex.hasMatch(choice.resultText), isFalse,
              reason: 'Choice resultText "${choice.resultText}" must not contain parentheses');
          expect(emojiRegex.hasMatch(choice.label), isFalse,
              reason: 'Choice label "${choice.label}" must not contain emoji');
          expect(emojiRegex.hasMatch(choice.resultText), isFalse,
              reason: 'Choice resultText "${choice.resultText}" must not contain emoji');
        }
      }
    });

    test('3. Dynamic Scaling Edge Cases: 0 balance, negative balance, and mega tycoon balance', () {
      final baseExpenseChoice = GameEventChoice(
        label: 'Ağır Hasarı Onar • -50.000 ₺',
        resultText: 'Onarım tamamlandı.',
        balanceChange: -50000.0,
        reputationChange: 10,
        xpGain: 60,
      );

      // Edge case A: Zero balance
      final zeroBalanceScaled = RandomEventEngine.scaleChoice(
        choice: baseExpenseChoice,
        level: 1,
        currentBalance: 0.0,
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );
      // Safety cap min 1200 TL prevents crash
      expect(zeroBalanceScaled.balanceChange, -1200.0);
      expect(zeroBalanceScaled.label, contains('1.200'));

      // Edge case B: Negative balance
      final negativeBalanceScaled = RandomEventEngine.scaleChoice(
        choice: baseExpenseChoice,
        level: 1,
        currentBalance: -25000.0,
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );
      expect(negativeBalanceScaled.balanceChange, -1200.0);

      // Edge case C: Mega Tycoon (50,000,000 TL)
      final tycoonScaled = RandomEventEngine.scaleChoice(
        choice: baseExpenseChoice,
        level: 8,
        currentBalance: 50000000.0,
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );
      expect(tycoonScaled.balanceChange.abs(), greaterThan(50000.0));
      expect(tycoonScaled.balanceChange.abs(), lessThanOrEqualTo(50000.0 * 2.75 * 2.2));
    });

    test('4. Gating Check across all 11 Side Business Types', () {
      final unownedBusinesses = SideBusinessType.values.map((type) {
        return SideBusinessModel(
          id: 'biz_${type.name}',
          name: type.name,
          type: type,
          dailyIncome: 100,
          cost: 1000,
          isOwned: false,
        );
      }).toList();

      final unownedState = DealershipModel.initial().copyWith(
        sideBusinesses: unownedBusinesses,
        unlockedBuildings: {},
        balance: 100000.0,
      );

      final specificSideEventIds = [
        'event_wash_water_cut',
        'event_tow_winter_chain_rush',
        'event_autoshop_counterfeit_filter',
        'event_dyno_calibration_drift',
        'event_wrap_ppf_heat_peel',
        'event_ev_grid_surge_breaker',
        'event_spare_parts_customs_seizure',
        'event_rental_gps_signal_loss',
        'event_scrap_crane_hydraulic_burst',
        'event_vending_payment_gateway_down',
        'event_billboard_storm_torn_canvas',
        'event_inspection_caliper_gauge_crack',
      ];

      for (int i = 0; i < 200; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(unownedState);
        if (event != null) {
          expect(
            specificSideEventIds.contains(event.id),
            isFalse,
            reason: 'Unowned side business event ${event.id} must never trigger',
          );
        }
      }
    });

    test('5. Multi-Day Game Progression Simulation: ticks, triggers, resolutions, and anti-repetition buffer', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      // Give player some owned businesses and staff
      notifier.state = notifier.state.copyWith(
        balance: 250000.0,
        level: 3,
        sideBusinesses: [
          SideBusinessModel(
            id: 'car_wash',
            name: 'Oto Yıkama',
            type: SideBusinessType.carWash,
            dailyIncome: 300,
            cost: 5000,
            isOwned: true,
          ),
          SideBusinessModel(
            id: 'tow_truck',
            name: 'Çekici',
            type: SideBusinessType.towTruck,
            dailyIncome: 500,
            cost: 8000,
            isOwned: true,
          ),
        ],
      );

      int eventsEncountered = 0;

      for (int day = 1; day <= 45; day++) {
        notifier.advanceGameDay();

        if (notifier.state.pendingRandomEvent != null) {
          eventsEncountered++;
          final event = notifier.state.pendingRandomEvent!;

          expect(event.choices.isNotEmpty, isTrue);
          expect(notifier.state.seenRandomEventIds.length, lessThanOrEqualTo(12));

          // Resolve event with first choice
          final choice = event.choices.first;
          final balanceBefore = notifier.state.balance;
          notifier.resolveRandomEvent(choice);

          // Verify clean resolution
          expect(notifier.state.pendingRandomEvent, isNull);
          expect(notifier.state.balance, (balanceBefore + choice.balanceChange));
        }
      }

      expect(eventsEncountered, greaterThan(0), reason: 'Random events must periodically occur over 45 days');
    });

    test('6. State JSON Serialization Round-Trip with Pending Event', () {
      final sampleEvent = GameEventModel(
        id: 'event_wash_water_cut',
        title: 'ŞEBEKE SUYU KESİNTİSİ • OTO YIKAMA DURMA NOKTASINDA',
        description: 'Belediye ana su hattı patladı.',
        iconEmoji: 'wrench',
        amount: -4000.0,
        type: GameEventType.badEvent,
        date: DateTime.now(),
        choices: [
          GameEventChoice(
            label: 'Acil Su Tankeri Çağır • -4.000 ₺',
            resultText: 'Su tankeri geldi.',
            balanceChange: -4000.0,
            reputationChange: 5,
            xpGain: 30,
          ),
        ],
      );

      final originalState = DealershipModel.initial().copyWith(
        pendingRandomEvent: sampleEvent,
        seenRandomEventIds: ['event_1', 'event_2', 'event_wash_water_cut'],
      );

      final jsonMap = originalState.toJson();
      final restoredState = DealershipModel.fromJson(jsonMap);

      expect(restoredState.pendingRandomEvent, isNotNull);
      expect(restoredState.pendingRandomEvent!.id, 'event_wash_water_cut');
      expect(restoredState.pendingRandomEvent!.choices.first.balanceChange, -4000.0);
      expect(restoredState.seenRandomEventIds, ['event_1', 'event_2', 'event_wash_water_cut']);
    });
  });
}
