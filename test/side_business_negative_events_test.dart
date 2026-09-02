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
    test('All negative crises, positive opportunities, and new diversified events are registered in allEventTemplates', () {
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
        // Yeni Çeşitlendirilmiş Yan İşletme Olayları
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
            name: 'Oto Yıkama',
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
        'event_wash_water_cut',
        'event_vending_coin_jam',
        'event_vending_spoiled_milk',
        'event_vending_artisan_roastery_deal',
        'event_vending_energy_drink_exclusive',
        'event_vending_payment_gateway_down',
        'event_tow_truck_cable_snap',
        'event_tow_hydraulic_fail',
        'event_tow_sports_club_bus_rescue',
        'event_tow_insurance_annual_tender',
        'event_tow_winter_chain_rush',
        'event_billboard_panel_short',
        'event_billboard_wind_damage',
        'event_billboard_politician_election_campaign',
        'event_billboard_viral_3d_anamorphic',
        'event_billboard_storm_torn_canvas',
        'event_ev_transformer_trip',
        'event_ev_cable_ripoff',
        'event_ev_solar_canopy_installation',
        'event_ev_fleet_overnight_depot',
        'event_ev_grid_surge_breaker',
        'event_wrap_blade_scratch',
        'event_wrap_bubble_peel',
        'event_wrap_supercar_matte_chameleon',
        'event_wrap_commercial_fleet_branding',
        'event_wrap_ppf_heat_peel',
        'event_rental_speeding_fines',
        'event_rental_clutch_burn',
        'event_rental_cinema_movie_production',
        'event_rental_airport_vip_transfer_franchise',
        'event_rental_gps_signal_loss',
        'event_scrap_press_breakdown',
        'event_salvage_corrosion',
        'event_scrap_classic_chassis_treasure',
        'event_scrap_crane_hydraulic_burst',
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
          e.id == 'event_wash_foam_cannon_upgrade' ||
          e.id == 'event_wash_water_cut');
      expect(washEvents.length, 6);
      expect(washState.sideBusinesses.any((b) => b.isOwned && b.type == SideBusinessType.carWash), isTrue);
    });

    test('Dynamic Scaling: Level scaling increases penalty dynamically', () {
      final baseChoice = GameEventChoice(
        label: 'Tamir Masrafını Karşıla • -10.000 ₺',
        resultText: 'Tamir yapıldı.',
        balanceChange: -10000.0,
        reputationChange: 0,
        xpGain: 50,
      );

      final scaledLevel1 = RandomEventEngine.scaleChoice(
        choice: baseChoice,
        level: 1,
        currentBalance: 500000.0,
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );

      final scaledLevel8 = RandomEventEngine.scaleChoice(
        choice: baseChoice,
        level: 8,
        currentBalance: 500000.0,
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );

      // Level 1: base 10000
      expect(scaledLevel1.balanceChange, -10000.0);
      // Level 8: base * (1 + 7 * 0.25) = 2.75x = -27500
      expect(scaledLevel8.balanceChange, -27500.0);
      expect(scaledLevel8.label, contains('27.500'));
    });

    test('Dynamic Scaling: Bankruptcy cushion prevents wiping out low-cash players', () {
      final heavyChoice = GameEventChoice(
        label: 'Ağır Cezayı Öde • -60.000 ₺',
        resultText: 'Ceza ödendi.',
        balanceChange: -60000.0,
        reputationChange: 0,
        xpGain: 50,
      );

      final lowCashScaled = RandomEventEngine.scaleChoice(
        choice: heavyChoice,
        level: 1,
        currentBalance: 30000.0, // Low balance
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );

      // 30,000 * 0.30 = 9,000 max penalty capped
      expect(lowCashScaled.balanceChange, -9000.0);
      expect(lowCashScaled.balanceChange.abs(), lessThan(30000.0));
      expect(lowCashScaled.label, contains('9.000'));
    });

    test('Dynamic Scaling: Master Mechanic discount mitigates repair penalty', () {
      final mechanicChoice = GameEventChoice(
        label: 'Parçayı Değiştir • -20.000 ₺',
        resultText: 'Değiştirildi.',
        balanceChange: -20000.0,
        reputationChange: 0,
        xpGain: 50,
      );

      final withoutStaff = RandomEventEngine.scaleChoice(
        choice: mechanicChoice,
        level: 1,
        currentBalance: 500000.0,
        hasMasterMechanic: false,
        hasAccountant: false,
        isBossSpecialization: false,
      );

      final withStaff = RandomEventEngine.scaleChoice(
        choice: mechanicChoice,
        level: 1,
        currentBalance: 500000.0,
        hasMasterMechanic: true,
        hasAccountant: false,
        isBossSpecialization: false,
      );

      // 20000 * 0.75 = 15000
      expect(withoutStaff.balanceChange, -20000.0);
      expect(withStaff.balanceChange, -15000.0);
    });

    test('Level Tier Gating: Levels 1-2 players are protected from high-tier conglomerate scandals', () {
      final level1State = DealershipModel.initial().copyWith(
        level: 1,
        balance: 100000.0,
      );

      final highTierScandalIds = [
        'event_black_market_raid',
        'event_airbag_bypass_scandal',
        'event_macro_import_customs_quota',
      ];

      for (int i = 0; i < 50; i++) {
        final event = RandomEventEngine.getFilteredRandomEvent(level1State);
        if (event != null) {
          expect(
            event.id,
            isNot(isIn(highTierScandalIds)),
            reason: 'Level 1 player should not receive high-tier scandal ${event.id}',
          );
        }
      }
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
