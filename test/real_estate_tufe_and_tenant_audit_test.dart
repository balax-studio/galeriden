import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/real_estate_model.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/tenant_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';

void main() {
  group('Real Estate A1 (TÜFE Rent Increase) & C4 (Tenant Lifecycle) Audit Test Suite', () {
    test('A1: applyRentIndexIncrease respects 365 in-game days cooldown and updates risk', () {
      final tenant = TenantModel(
        id: 'tenant_t1',
        name: 'Test Kiracı',
        profession: 'Mühendis',
        reliabilityScore: 85,
        monthlyRent: 20000.0,
        depositAmount: 40000.0,
        evictionRiskScore: 10,
        lastRentIncreaseDay: 0,
      );

      final property = RealEstateModel(
        id: 'prop_t1',
        title: 'Kadıköy 2+1 Daire',
        category: RealEstateCategory.housing,
        city: 'İstanbul',
        district: 'Kadıköy',
        squareMeters: 95,
        roomCount: '2+1',
        buildingAge: 5,
        deedType: DeedType.ownershipDeed,
        sellerType: RealEstateSellerType.individual,
        baseMarketValue: 4500000.0,
        currentPurchasePrice: 4000000.0,
        isRented: true,
        currentTenant: tenant,
      );

      final initial = DealershipModel.initial().copyWith(
        currentDay: 100,
        ownedRealEstates: [property],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initial.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);

      notifier.state = initial;

      // First increase at day 100 (tenant.lastRentIncreaseDay is 0, 100 - 0 = 100 < 365 -> blocked)
      final okEarly = notifier.applyRentIndexIncrease('prop_t1');
      expect(okEarly, isFalse, reason: 'Must block increase if less than 365 days since last increase');

      // Now set currentDay to 400 (400 - 0 >= 365 -> allowed)
      notifier.state = notifier.state.copyWith(currentDay: 400);

      final okValid = notifier.applyRentIndexIncrease('prop_t1');
      expect(okValid, isTrue, reason: 'Must allow increase after 365 in-game days');

      final updatedProp = container.read(gameProvider).ownedRealEstates.firstWhere((p) => p.id == 'prop_t1');
      if (updatedProp.isRented) {
        // Tenant stayed
        expect(updatedProp.currentTenant!.lastRentIncreaseDay, equals(400));
        expect(updatedProp.currentTenant!.monthlyRent, equals(25000.0));
        expect(updatedProp.currentTenant!.evictionRiskScore, equals(25)); // 10 + 15

        // Immediate second increase must fail (cooldown active)
        final okImmediate = notifier.applyRentIndexIncrease('prop_t1');
        expect(okImmediate, isFalse, reason: 'Spam tap must be rejected immediately by 365-day cooldown');
      } else {
        // 20% lease termination occurred
        expect(updatedProp.currentTenant, isNull);
      }
    });
  });
}
