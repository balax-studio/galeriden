import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/staff/staff_screen.dart';
import 'package:galeriden/presentation/screens/staff/staff_academy_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Staff Role Specialization & Facility Gating Test Suite', () {
    test('1. StaffRole extensions map correctly to required facilities and routes', () {
      expect(StaffRole.washer.requiredFeatureRoute, equals('/car-wash'));
      expect(StaffRole.washer.requiredFacilityName, contains('Oto Yıkama'));

      expect(StaffRole.apprentice.requiredFeatureRoute, equals('/workshop'));
      expect(StaffRole.apprentice.requiredFacilityName, contains('Oto Tamir'));

      expect(StaffRole.masterMechanic.requiredFeatureRoute, equals('/workshop'));
      expect(StaffRole.masterMechanic.requiredFacilityName, contains('Oto Tamir'));

      expect(StaffRole.appraiser.requiredFeatureRoute, equals('/expertise'));
      expect(StaffRole.appraiser.requiredFacilityName, contains('Ekspertiz'));

      expect(StaffRole.salesman.requiredFeatureRoute, equals('/showroom'));
      expect(StaffRole.salesman.requiredFacilityName, contains('Galeri Vitrini'));

      expect(StaffRole.marketer.requiredFeatureRoute, equals('/photography-studio'));
      expect(StaffRole.marketer.requiredFacilityName, contains('Fotoğraf'));

      expect(StaffRole.legalAdvisor.requiredFeatureRoute, equals('/bank'));
      expect(StaffRole.legalAdvisor.requiredFacilityName, contains('Finans'));
    });

    test('2. StaffRoleSpecializations defines specialized courses for each role', () {
      expect(StaffRoleSpecializations.allCourses.length, equals(14));

      for (final role in StaffRole.values) {
        final courses = StaffRoleSpecializations.coursesForRole(role);
        expect(courses.length, equals(2), reason: 'Role ${role.name} must have exactly 2 specialized courses');
        for (final c in courses) {
          expect(c.role, equals(role));
          expect(c.cost, greaterThan(0));
          expect(c.title.isNotEmpty, isTrue);
          expect(c.bonusSummary.isNotEmpty, isTrue);
        }
      }
    });

    test('3. StaffModel serializes and deserializes completedCourseIds properly', () {
      final staff = StaffModel(
        id: 'staff_test_1',
        name: 'Kemal Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        completedCourseIds: ['train_mech_master_assembly', 'train_mech_ecu_dyno'],
      );

      final json = staff.toJson();
      expect(json['completedCourseIds'], isNotNull);
      expect((json['completedCourseIds'] as List).length, equals(2));

      final restored = StaffModel.fromJson(json);
      expect(restored.completedCourseIds.length, equals(2));
      expect(restored.completedCourseIds.contains('train_mech_master_assembly'), isTrue);
      expect(restored.completedCourseIds.contains('train_mech_ecu_dyno'), isTrue);
    });

    test('4. Hiring staff is blocked when facility is locked and allowed when unlocked', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      notifier.state = DealershipModel.initial().copyWith(
        balance: 100000.0,
        unlockedBuildings: {}, // No facilities unlocked
        hiredStaff: [],
      );

      final newWasher = StaffModel(
        id: 'w1',
        name: 'Ahmet Yıkamacı',
        role: StaffRole.washer,
        hiredAt: DateTime.now(),
      );

      // Attempt to hire washer when /car-wash is locked
      final hireBlocked = notifier.hireStaff(newWasher);
      expect(hireBlocked, isFalse);
      expect(notifier.state.hiredStaff.isEmpty, isTrue);

      // Unlock car wash facility
      notifier.state = notifier.state.copyWith(
        unlockedBuildings: {'/car-wash'},
      );

      // Now hiring should succeed
      final hireAllowed = notifier.hireStaff(newWasher);
      expect(hireAllowed, isTrue);
      expect(notifier.state.hiredStaff.length, equals(1));
    });

    test('5. trainStaffMember deducts money, increases morale, mastery, and records course ID', () {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      final staff = StaffModel(
        id: 'st_mech_1',
        name: 'Murat Usta',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        morale: 60,
        masteryLevel: 1,
      );

      notifier.state = DealershipModel.initial().copyWith(
        balance: 50000.0,
        unlockedBuildings: {'/workshop'},
        hiredStaff: [staff],
      );

      final course = StaffRoleSpecializations.coursesForRole(StaffRole.masterMechanic).first;

      // Train staff
      final success = notifier.trainStaffMember(staff.id, course);
      expect(success, isTrue);
      expect(notifier.state.balance, equals(50000.0 - course.cost));

      final trainingStaff = notifier.state.hiredStaff.first;
      expect(trainingStaff.isUnderTraining, isTrue);
      expect(trainingStaff.trainingDaysRemaining, equals(course.durationDays));
      expect(trainingStaff.isAvailableForWork, isFalse);

      // Training same course or another course while in training should be prevented
      final repeat = notifier.trainStaffMember(staff.id, course);
      expect(repeat, isFalse);

      // Complete training via rush speedup
      notifier.rushStaffTraining(staff.id);
      final graduatedStaff = notifier.state.hiredStaff.first;
      expect(graduatedStaff.isUnderTraining, isFalse);
      expect(graduatedStaff.morale, equals(85)); // 60 + 25
      expect(graduatedStaff.masteryLevel, equals(2)); // +1
      expect(graduatedStaff.completedCourseIds.contains(course.id), isTrue);
    });

    testWidgets('6. StaffScreen renders facility locked badge and role training action', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final staff = StaffModel(
        id: 'st_appraiser_1',
        name: 'Kadir Eksper',
        role: StaffRole.appraiser,
        hiredAt: DateTime.now(),
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 100000.0,
        unlockedBuildings: {'/staff', '/expertise'},
        hiredStaff: [staff],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            supportedLocales: [Locale('tr'), Locale('en')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: StaffScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kadir Eksper'), findsOneWidget);
      expect(find.text('EĞİTİM VER'), findsOneWidget);

      // Other unhired locked facilities should show TESİS KİLİTLİ
      expect(find.text('TESİS KİLİTLİ'), findsWidgets);
    });

    testWidgets('7. StaffAcademyScreen renders role filter chips and specialized courses', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final staff = StaffModel(
        id: 'st_washer_1',
        name: 'Deniz Yıkama',
        role: StaffRole.washer,
        hiredAt: DateTime.now(),
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 100000.0,
        unlockedBuildings: {'/staff-academy', '/car-wash'},
        hiredStaff: [staff],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
          ],
          child: const MaterialApp(
            locale: Locale('tr'),
            supportedLocales: [Locale('tr'), Locale('en')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: StaffAcademyScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ROL BAZLI UZMANLIK AKADEMİSİ'), findsOneWidget);
      expect(find.text('Tüm Roller'), findsOneWidget);
      expect(find.text('MÜFREDAT DERSLERİ • 14 Kurs'), findsOneWidget);
    });
  });
}
