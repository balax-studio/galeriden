import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/ad_service.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/dialogs/rush_training_confirmation_dialog.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

final testTheme = ThemeData.dark().copyWith(
  extensions: [
    AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
  ],
);

Widget buildTestApp({
  required Widget child,
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: ToastificationWrapper(
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: const [Locale('tr'), Locale('en')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: testTheme,
        home: Scaffold(
          body: child,
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() {
    toastification.dismissAll(delayForAnimation: false);
  });

  group('Rush Training Ad Confirmation Dialog & Platform Routing Tests', () {
    testWidgets('1. Dialog renders trainee details, remaining days, and ad warning', (tester) async {
      final staff = StaffModel(
        id: 'st_mechanic_1',
        name: 'Usta Ahmet',
        role: StaffRole.masterMechanic,
        hiredAt: DateTime.now(),
        isUnderTraining: true,
        trainingDaysRemaining: 2,
        totalTrainingDays: 2,
        currentTrainingCourseId: 'mech_engine_tuning',
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 100000.0,
        unlockedBuildings: {'/workshop', '/staff', '/staff-academy'},
        hiredStaff: [staff],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();
      notifier.state = initialDealership;

      await tester.pumpWidget(
        buildTestApp(
          container: container,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RushTrainingConfirmationDialog.show(context, staff: staff),
              child: const Text('OPEN DIALOG'),
            ),
          ),
        ),
      );
      notifier.stopPeriodicOrganicOfferTimer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      // Assert Dialog Header & Content
      expect(find.text('ÖZEL SANAYİ SEMİNERİ'), findsWidgets);
      expect(find.text('Usta Ahmet'), findsOneWidget);
      expect(find.textContaining('2 gün kaldı'), findsOneWidget);
      expect(find.textContaining('Otomotiv Sanayi Odası'), findsOneWidget);
      expect(find.text('İPTAL'), findsOneWidget);
      expect(find.text('SPONSOR DESTEĞİ AL & MEZUN ET'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('2. Tapping Cancel dismisses dialog without rushing training', (tester) async {
      final staff = StaffModel(
        id: 'st_washer_1',
        name: 'Yıkamacı Can',
        role: StaffRole.washer,
        hiredAt: DateTime.now(),
        isUnderTraining: true,
        trainingDaysRemaining: 1,
        totalTrainingDays: 1,
        currentTrainingCourseId: 'washer_detailing_mastery',
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 100000.0,
        unlockedBuildings: {'/staff', '/staff-academy', '/car-wash'},
        hiredStaff: [staff],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();
      notifier.state = initialDealership;

      await tester.pumpWidget(
        buildTestApp(
          container: container,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RushTrainingConfirmationDialog.show(context, staff: staff),
              child: const Text('OPEN DIALOG'),
            ),
          ),
        ),
      );
      notifier.stopPeriodicOrganicOfferTimer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      // Tap Cancel (İPTAL)
      await tester.tap(find.text('İPTAL'));
      await tester.pumpAndSettle();

      // Dialog is gone, staff is still in training
      expect(find.byType(RushTrainingConfirmationDialog), findsNothing);
      expect(notifier.state.hiredStaff.isNotEmpty, isTrue);
      final currentStaff = notifier.state.hiredStaff.first;
      expect(currentStaff.isUnderTraining, isTrue);
      expect(currentStaff.trainingDaysRemaining, equals(1));

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('3. Tapping Watch Ad triggers rush graduation and delivers diploma', (tester) async {
      final course = StaffRoleSpecializations.coursesForRole(StaffRole.salesman).first;
      final staff = StaffModel(
        id: 'st_sales_1',
        name: 'Satışçı Zeynep',
        role: StaffRole.salesman,
        hiredAt: DateTime.now(),
        isUnderTraining: true,
        trainingDaysRemaining: 3,
        totalTrainingDays: 3,
        currentTrainingCourseId: course.id,
      );

      final initialDealership = DealershipModel.initial().copyWith(
        balance: 500000.0,
        unlockedBuildings: {'/showroom', '/staff', '/staff-academy'},
        hiredStaff: [staff],
      );

      SharedPreferences.setMockInitialValues({
        'dealership_state_v2': jsonEncode(initialDealership.toJson()),
      });

      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();
      notifier.state = initialDealership;

      await tester.pumpWidget(
        buildTestApp(
          container: container,
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => RushTrainingConfirmationDialog.show(context, staff: staff),
              child: const Text('OPEN DIALOG'),
            ),
          ),
        ),
      );
      notifier.stopPeriodicOrganicOfferTimer();
      await tester.pumpAndSettle();

      await tester.tap(find.text('OPEN DIALOG'));
      await tester.pumpAndSettle();

      // Tap "SPONSOR DESTEĞİ AL & MEZUN ET"
      await tester.tap(find.text('SPONSOR DESTEĞİ AL & MEZUN ET'));
      await tester.pumpAndSettle();

      // In test environment, fallback ad dialog opens; claim reward
      final claimBtnFinder = find.byWidgetPredicate((w) => w is NeoBrutalButton);
      if (claimBtnFinder.evaluate().isNotEmpty) {
        await tester.tap(claimBtnFinder.last);
        await tester.pumpAndSettle();
      }

      // Staff should now be graduated
      expect(notifier.state.hiredStaff.isNotEmpty, isTrue);
      final updatedStaff = notifier.state.hiredStaff.first;
      expect(updatedStaff.isUnderTraining, isFalse);
      expect(updatedStaff.trainingDaysRemaining, 0);
      expect(updatedStaff.completedCourseIds.contains(course.id), isTrue);
      expect(updatedStaff.isAvailableForWork, isTrue);
      expect(updatedStaff.perk, isNotNull);

      // Drain toast timer completely
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      toastification.dismissAll(delayForAnimation: false);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });

    test('4. AdService correctly resolves platform specific AdMob Rewarded Ad Unit IDs', () {
      final adService = AdService.instance;
      final adUnitId = adService.rewardedAdUnitId;
      expect(adUnitId, isNotEmpty);
      expect(adUnitId.startsWith('ca-app-pub-'), isTrue);

      final nativeAdUnitId = adService.nativeAdUnitId;
      expect(nativeAdUnitId, isNotEmpty);
      expect(nativeAdUnitId.startsWith('ca-app-pub-'), isTrue);
    });
  });
}
