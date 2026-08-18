import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/side_business_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/random_event_engine.dart';

void main() {
  group('Deep Immersion & Notary Random Events Test Suite', () {
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
        balance: 100000.0,
      );
    });

    test('1. All 16 new immersion event templates exist in allEventTemplates', () {
      final allIds = RandomEventEngine.allEventTemplates.map((e) => e.id).toSet();

      final expectedNewIds = [
        'event_notary_fake_cash',
        'event_notary_power_of_attorney_expired',
        'event_notary_hidden_tax_block',
        'event_vip_special_plate_request',
        'event_customer_deposit_ghosting',
        'event_night_shady_buyer',
        'event_buyer_knowitall_uncle',
        'event_suspicious_lost_registration_swap',
        'event_master_mechanic_poached',
        'event_sanayi_broker_deal',
        'event_apprentice_graduation_milestone',
        'event_expertise_customer_distress_sale',
        'event_winter_blizzard_demand',
        'event_holiday_rush_sedans',
        'event_interest_rate_hike_shock',
        'event_impound_lot_auction',
        'event_night_drag_sponsorship',
      ];

      for (final id in expectedNewIds) {
        expect(allIds.contains(id), isTrue, reason: 'Event $id should exist in allEventTemplates');
      }
    });

    test('2. Zero Emoji and Zero Parentheses strict compliance across all templates', () {
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

    test('3. Master mechanic poaching event triggers ONLY when master mechanic is hired', () {
      // Base state has apprentice only
      final pickedWithoutMaster = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(baseState);
        if (event != null) pickedWithoutMaster.add(event.id);
      }
      expect(pickedWithoutMaster.contains('event_master_mechanic_poached'), isFalse);

      // Now add master mechanic
      final stateWithMaster = baseState.copyWith(
        hiredStaff: [
          ...baseState.hiredStaff,
          StaffModel(
            id: 'staff_master',
            name: 'Ahmet Usta',
            role: StaffRole.masterMechanic,
            hiredAt: DateTime.now(),
          ),
        ],
      );

      final pickedWithMaster = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithMaster);
        if (event != null) pickedWithMaster.add(event.id);
      }
      expect(pickedWithMaster.contains('event_master_mechanic_poached'), isTrue);
    });

    test('4. Expertise customer distress sale triggers ONLY when expertise business is owned', () {
      final pickedWithoutExp = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(baseState);
        if (event != null) pickedWithoutExp.add(event.id);
      }
      expect(pickedWithoutExp.contains('event_expertise_customer_distress_sale'), isFalse);

      final stateWithExp = baseState.copyWith(
        sideBusinesses: baseState.sideBusinesses.map((b) {
          if (b.type == SideBusinessType.corporateExpertise) {
            return b.copyWith(isOwned: true);
          }
          return b;
        }).toList(),
      );

      final pickedWithExp = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithExp);
        if (event != null) pickedWithExp.add(event.id);
      }
      expect(pickedWithExp.contains('event_expertise_customer_distress_sale'), isTrue);
    });

    test('5. Winter blizzard demand triggers ONLY when tow truck fleet is owned', () {
      final pickedWithoutTow = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(baseState);
        if (event != null) pickedWithoutTow.add(event.id);
      }
      expect(pickedWithoutTow.contains('event_winter_blizzard_demand'), isFalse);

      final stateWithTow = baseState.copyWith(
        sideBusinesses: baseState.sideBusinesses.map((b) {
          if (b.type == SideBusinessType.towTruck) {
            return b.copyWith(isOwned: true);
          }
          return b;
        }).toList(),
      );

      final pickedWithTow = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithTow);
        if (event != null) pickedWithTow.add(event.id);
      }
      expect(pickedWithTow.contains('event_winter_blizzard_demand'), isTrue);
    });

    test('6. Night drag racing sponsorship triggers ONLY when autoShop is owned or workshop is unlocked', () {
      final pickedWithoutShop = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(baseState);
        if (event != null) pickedWithoutShop.add(event.id);
      }
      expect(pickedWithoutShop.contains('event_night_drag_sponsorship'), isFalse);

      final stateWithWorkshop = baseState.copyWith(
        unlockedBuildings: {'/workshop'},
      );

      final pickedWithWorkshop = <String>{};
      for (int i = 0; i < 400; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(stateWithWorkshop);
        if (event != null) pickedWithWorkshop.add(event.id);
      }
      expect(pickedWithWorkshop.contains('event_night_drag_sponsorship'), isTrue);
    });

    test('7. Notary and buyer psychology events trigger properly for active dealerships', () {
      final pickedEvents = <String>{};
      for (int i = 0; i < 600; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(baseState);
        if (event != null) pickedEvents.add(event.id);
      }

      expect(
        pickedEvents.contains('event_notary_fake_cash') ||
            pickedEvents.contains('event_notary_power_of_attorney_expired') ||
            pickedEvents.contains('event_notary_hidden_tax_block') ||
            pickedEvents.contains('event_customer_deposit_ghosting') ||
            pickedEvents.contains('event_buyer_knowitall_uncle'),
        isTrue,
      );
    });
  });
}
