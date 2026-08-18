import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/random_event_engine.dart';

void main() {
  group('RandomEventEngine Strict Ownership Gating & Diversity Tests', () {
    late DealershipModel baseState;

    setUp(() {
      baseState = DealershipModel.initial().copyWith(
        ownedCars: DealershipModel.initial().ownedCars,
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Emre',
            role: StaffRole.apprentice,
            hiredAt: DateTime.now(),
          ),
        ],
        unlockedBuildings: {},
        sideBusinesses: DealershipModel.initial().sideBusinesses.map((b) => b.copyWith(isOwned: false)).toList(),
      );
    });

    test('1. When no side businesses are owned and scrapyard is locked, zero business-specific negative events are returned', () {
      final businessEventIds = {
        'event_vending_coin_jam',
        'event_vending_spoiled_milk',
        'event_wash_pump_explosion',
        'event_wash_chemical_burn',
        'event_ev_transformer_trip',
        'event_ev_cable_ripoff',
        'event_billboard_panel_short',
        'event_wrap_blade_scratch',
        'event_dyno_roller_jam',
        'event_airbag_bypass_scandal',
        'event_spare_parts_tax_audit',
        'event_tow_truck_cable_snap',
        'event_rental_speeding_fines',
        'event_autoshop_lift_leak',
        'event_scrap_press_breakdown',
        'event_salvage_corrosion',
        'event_b2b_defective_return',
        'event_workshop_waste_fine',
      };

      for (int i = 0; i < 200; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(baseState);
        expect(event, isNotNull);
        expect(businessEventIds.contains(event!.id), isFalse,
            reason: 'Event ${event.id} should NOT trigger when player does not own the business');
      }
    });

    test('2. When Vending Machine is owned, vending negative events become eligible', () {
      final stateWithVending = baseState.copyWith(
        sideBusinesses: baseState.sideBusinesses.map((b) {
          if (b.type == SideBusinessType.vendingMachine) {
            return b.copyWith(isOwned: true);
          }
          return b;
        }).toList(),
      );

      final pickedIds = <String>{};
      for (int i = 0; i < 500; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithVending);
        if (event != null) pickedIds.add(event.id);
      }

      expect(pickedIds.contains('event_vending_coin_jam') || pickedIds.contains('event_vending_spoiled_milk'), isTrue);
      // Other unowned businesses must still NOT trigger
      expect(pickedIds.contains('event_wash_pump_explosion'), isFalse);
      expect(pickedIds.contains('event_ev_transformer_trip'), isFalse);
      expect(pickedIds.contains('event_scrap_press_breakdown'), isFalse);
    });

    test('3. When Car Wash is owned, car wash pump and chemical burn events become eligible', () {
      final stateWithWash = baseState.copyWith(
        sideBusinesses: baseState.sideBusinesses.map((b) {
          if (b.type == SideBusinessType.carWash) {
            return b.copyWith(isOwned: true);
          }
          return b;
        }).toList(),
      );

      final pickedIds = <String>{};
      for (int i = 0; i < 500; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithWash);
        if (event != null) pickedIds.add(event.id);
      }

      expect(pickedIds.contains('event_wash_pump_explosion') || pickedIds.contains('event_wash_chemical_burn'), isTrue);
      expect(pickedIds.contains('event_vending_coin_jam'), isFalse);
      expect(pickedIds.contains('event_wrap_blade_scratch'), isFalse);
    });

    test('4. When EV Charging is owned, transformer and cable ripoff events become eligible', () {
      final stateWithEv = baseState.copyWith(
        sideBusinesses: baseState.sideBusinesses.map((b) {
          if (b.type == SideBusinessType.evCharging) {
            return b.copyWith(isOwned: true);
          }
          return b;
        }).toList(),
      );

      final pickedIds = <String>{};
      for (int i = 0; i < 500; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithEv);
        if (event != null) pickedIds.add(event.id);
      }

      expect(pickedIds.contains('event_ev_transformer_trip') || pickedIds.contains('event_ev_cable_ripoff'), isTrue);
      expect(pickedIds.contains('event_tow_truck_cable_snap'), isFalse);
    });

    test('5. When Scrapyard is unlocked, scrapyard press breakdown and corrosion events become eligible', () {
      final stateWithScrapyard = baseState.copyWith(
        unlockedBuildings: {'/scrapyard'},
      );

      final pickedIds = <String>{};
      for (int i = 0; i < 500; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithScrapyard);
        if (event != null) pickedIds.add(event.id);
      }

      expect(
        pickedIds.contains('event_scrap_press_breakdown') ||
            pickedIds.contains('event_salvage_corrosion') ||
            pickedIds.contains('event_b2b_defective_return'),
        isTrue,
      );
      expect(pickedIds.contains('event_rental_speeding_fines'), isFalse);
    });

    test('6. All event templates adhere to zero emoji and zero parentheses standards', () {
      for (final event in RandomEventEngine.allEventTemplates) {
        expect(event.title.contains('(') || event.title.contains(')'), isFalse,
            reason: 'Title "${event.title}" must not contain parentheses');
        expect(event.description.contains('(') || event.description.contains(')'), isFalse,
            reason: 'Description "${event.description}" must not contain parentheses');

        for (final choice in event.choices) {
          expect(choice.label.contains('(') || choice.label.contains(')'), isFalse,
              reason: 'Choice label "${choice.label}" must not contain parentheses');
          expect(choice.resultText.contains('(') || choice.resultText.contains(')'), isFalse,
              reason: 'Choice resultText "${choice.resultText}" must not contain parentheses');
        }
      }
    });
  });
}
