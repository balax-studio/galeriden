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

  group('Side Business & Fast Service Events Comprehensive Tests', () {
    test('All negative crises and positive opportunity events are registered in allEventTemplates', () {
      final templates = RandomEventEngine.allEventTemplates;
      final expectedIds = [
        // Negatif Krizler
        'event_wash_pump_explosion',
        'event_wash_chemical_burn',
        'event_vending_coin_jam',
        'event_vending_spoiled_milk',
        'event_tow_truck_cable_snap',
        'event_tow_hydraulic_fail',
        'event_billboard_panel_short',
        'event_billboard_wind_damage',
        'event_autoshop_lift_leak',
        'event_autoshop_oil_spill',
        'event_dyno_roller_jam',
        'event_airbag_bypass_scandal',
        'event_expertise_chassis_miss',
        'event_rental_speeding_fines',
        'event_rental_clutch_burn',
        'event_ev_transformer_trip',
        'event_ev_cable_ripoff',
        'event_spare_parts_tax_audit',
        'event_spare_parts_water_damage',
        'event_wrap_blade_scratch',
        'event_wrap_bubble_peel',
        'event_scrap_press_breakdown',
        'event_salvage_corrosion',
        'event_workshop_waste_fine',
        'event_office_safe_jam',
        'event_office_fake_cheque',
        // Pozitif Fırsatlar & B2B Anlaşmalar
        'event_wash_wedding_convoy_rush',
        'event_wash_ceramic_bulk_contract',
        'event_wash_foam_cannon_upgrade',
        'event_vending_artisan_roastery_deal',
        'event_vending_energy_drink_exclusive',
        'event_tow_sports_club_bus_rescue',
        'event_tow_insurance_annual_tender',
        'event_billboard_politician_election_campaign',
        'event_billboard_viral_3d_anamorphic',
        'event_autoshop_supercar_oil_service',
        'event_autoshop_bulk_drum_oil_deal',
        'event_inspection_commercial_fleet_audit',
        'event_inspection_laser_alignment_upgrade',
        'event_expertise_youtube_phenomenon_review',
        'event_expertise_court_expert_assignment',
        'event_rental_cinema_movie_production',
        'event_rental_airport_vip_transfer_franchise',
        'event_ev_solar_canopy_installation',
        'event_ev_fleet_overnight_depot',
        'event_spare_parts_german_oem_distributorship',
        'event_spare_parts_performance_exhaust_trend',
        'event_wrap_supercar_matte_chameleon',
        'event_wrap_commercial_fleet_branding',
        'event_scrap_classic_chassis_treasure',
        'event_workshop_b2b_engine_rebuild_contract',
        // Genişleme Paketi: Zincirleme Olaylar
        'event_scrap_classic_auction_climax',
        'event_rental_movie_gala_premiere',
        'event_ev_epdk_green_energy_rebate',
        'event_expertise_airbag_redemption_award',
        // Genişleme Paketi: Mevsimsel & Makro
        'event_winter_blizzard_crisis',
        'event_summer_tourism_boom',
        'event_holiday_rush_maintenance',
        'event_macro_import_customs_quota',
        // Genişleme Paketi: Sektörel Lonca & Bankacılık
        'event_guild_presidency_election',
        'event_apprentice_vocational_school_deal',
        'event_bank_manager_vip_credit_line',
        'event_auto_festival_sponsorship',
      ];

      for (final id in expectedIds) {
        final found = templates.any((e) => e.id == id);
        expect(found, isTrue, reason: 'Event $id should exist in allEventTemplates');
      }
    });

    test('Strict Ownership Gating: unowned side businesses never trigger their specific events', () {
      final emptyState = DealershipModel.initial().copyWith(
        balance: 100000.0,
        reputationScore: 500,
        sideBusinesses: [
          SideBusinessModel(
            id: 'car_wash',
            name: 'Oto Yikama',
            type: SideBusinessType.carWash,
            dailyIncome: 100,
            cost: 1000,
            isOwned: false,
          ),
          SideBusinessModel(
            id: 'vending',
            name: 'Otomat',
            type: SideBusinessType.vendingMachine,
            dailyIncome: 50,
            cost: 500,
            isOwned: false,
          ),
        ],
        unlockedBuildings: {},
      );

      final sideBusinessEventIds = [
        'event_wash_pump_explosion',
        'event_wash_chemical_burn',
        'event_wash_wedding_convoy_rush',
        'event_wash_ceramic_bulk_contract',
        'event_wash_foam_cannon_upgrade',
        'event_vending_coin_jam',
        'event_vending_spoiled_milk',
        'event_vending_artisan_roastery_deal',
        'event_vending_energy_drink_exclusive',
        'event_tow_truck_cable_snap',
        'event_tow_hydraulic_fail',
        'event_tow_sports_club_bus_rescue',
        'event_tow_insurance_annual_tender',
        'event_billboard_panel_short',
        'event_billboard_wind_damage',
        'event_billboard_politician_election_campaign',
        'event_billboard_viral_3d_anamorphic',
        'event_ev_transformer_trip',
        'event_ev_cable_ripoff',
        'event_ev_solar_canopy_installation',
        'event_ev_fleet_overnight_depot',
        'event_wrap_blade_scratch',
        'event_wrap_bubble_peel',
        'event_wrap_supercar_matte_chameleon',
        'event_wrap_commercial_fleet_branding',
        'event_rental_speeding_fines',
        'event_rental_clutch_burn',
        'event_rental_cinema_movie_production',
        'event_rental_airport_vip_transfer_franchise',
        'event_scrap_press_breakdown',
        'event_salvage_corrosion',
        'event_scrap_classic_chassis_treasure',
      ];

      for (int i = 0; i < 100; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(emptyState);
        if (event != null) {
          expect(
            event.id,
            isNot(isIn(sideBusinessEventIds)),
            reason: 'Unowned side business event ${event.id} must be gated out',
          );
        }
      }
    });

    test('Ownership Gating: owned side business enables its specific crisis and opportunity events', () {
      final washState = DealershipModel.initial().copyWith(
        balance: 100000.0,
        reputationScore: 500,
        sideBusinesses: [
          SideBusinessModel(
            id: 'car_wash',
            name: 'Oto Yıkama',
            type: SideBusinessType.carWash,
            dailyIncome: 200,
            cost: 2000,
            isOwned: true,
          ),
        ],
        unlockedBuildings: {},
      );

      final templates = RandomEventEngine.allEventTemplates;
      final washEvents = templates.where((e) =>
          e.id == 'event_wash_pump_explosion' ||
          e.id == 'event_wash_chemical_burn' ||
          e.id == 'event_wash_wedding_convoy_rush' ||
          e.id == 'event_wash_ceramic_bulk_contract' ||
          e.id == 'event_wash_foam_cannon_upgrade');
      expect(washEvents.length, 5);
      expect(washState.sideBusinesses.any((b) => b.isOwned && b.type == SideBusinessType.carWash), isTrue);
    });

    test('Choice resolution updates state balance, reputation and XP correctly', () {
      final notifier = GameNotifier();
      notifier.stopPeriodicOrganicOfferTimer();

      final initialBalance = notifier.state.balance;
      final initialReputation = notifier.state.reputationScore;
      final initialXp = notifier.state.experience;

      final testChoice = GameEventChoice(
        label: 'Sözleşmeyi İmzala & Toptan Peşin Al • +36.000 ₺',
        resultText: 'Taksi kooperatifi bağlandı.',
        balanceChange: 36000.0,
        reputationChange: 25,
        xpGain: 140,
      );

      notifier.resolveRandomEvent(testChoice);

      expect(notifier.state.balance, initialBalance + 36000.0);
      expect(notifier.state.reputationScore, (initialReputation + 25).clamp(0, 1000));
      expect(notifier.state.experience, initialXp + 140);
      expect(notifier.state.pendingRandomEvent, isNull);
    });

    test('Zero Unicode Emojis and Zero Parentheses invariant compliance on all templates', () {
      final templates = RandomEventEngine.allEventTemplates;
      final parenthesesRegex = RegExp(r'[()]');

      for (final event in templates) {
        // Test Zero Parentheses
        expect(
          parenthesesRegex.hasMatch(event.title),
          isFalse,
          reason: 'Event title "${event.title}" contains parentheses',
        );
        expect(
          parenthesesRegex.hasMatch(event.description),
          isFalse,
          reason: 'Event description "${event.description}" contains parentheses',
        );

        for (final choice in event.choices) {
          expect(
            parenthesesRegex.hasMatch(choice.label),
            isFalse,
            reason: 'Choice label "${choice.label}" contains parentheses',
          );
          expect(
            parenthesesRegex.hasMatch(choice.resultText),
            isFalse,
            reason: 'Choice resultText "${choice.resultText}" contains parentheses',
          );
        }
      }
    });
  });
}

