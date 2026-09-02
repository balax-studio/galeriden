import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/dramatic_card_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/staff_model.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_dramatic_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('365-Day Dramatic Card System Comprehensive End-to-End Audit', () {
    late DealershipModel baseState;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      baseState = DealershipModel.initial().copyWith(
        balance: 250000.0,
        reputationScore: 50,
        currentDay: 1,
        ownedCars: [
          CarModel(
            id: 'car_test_1',
            brand: 'Tofaş',
            modelName: 'Şahin 1.6 ie',
            modelYear: 2001,
            bodyType: 'Sedan',
            colorHex: 'FFFFFF',
            colorDisplayName: 'Beyaz',
            colorRarity: 'common',
            plateNumber: '34 TKN 01',
            plateRarity: 'common',
            currentPurchasePrice: 40000.0,
            baseMarketValue: 60000.0,
            isLockedInShowcase: false,
            expertise: ExpertiseReport(
              engineCondition: 80.0,
              transmissionCondition: 80.0,
              tramerAmount: 0,
              mileage: 120000,
              isMileageTampered: false,
              bodyParts: const {},
            ),
          ),
          CarModel(
            id: 'car_test_heirloom',
            brand: 'Murat',
            modelName: '124 Hacı Murat',
            modelYear: 1976,
            bodyType: 'Sedan',
            colorHex: 'D90429',
            colorDisplayName: 'Kırmızı',
            colorRarity: 'legendary',
            plateNumber: '06 ANK 76',
            plateRarity: 'legendary',
            currentPurchasePrice: 90000.0,
            baseMarketValue: 180000.0,
            isLockedInShowcase: true,
            expertise: ExpertiseReport(
              engineCondition: 95.0,
              transmissionCondition: 95.0,
              tramerAmount: 0,
              mileage: 45000,
              isMileageTampered: false,
              bodyParts: const {},
            ),
          ),
        ],
        hiredStaff: [
          StaffModel(
            id: 'staff_1',
            name: 'Haydar Usta',
            role: StaffRole.masterMechanic,
            hiredAt: DateTime.now(),
            salaryMultiplier: 1.0,
          ),
        ],
      );
    });

    test('1. Full 365-Day Catalog Verification: Unique IDs & Complete Content Structure', () {
      final seenIds = <String>{};

      for (int day = 1; day <= 365; day++) {
        final card = DramaticCardEngine.generateDailyDilemma(day, baseState);

        expect(card.id, isNotEmpty, reason: 'Card id empty on day $day');
        expect(card.title, isNotEmpty, reason: 'Card title empty on day $day');
        expect(card.dialogue, isNotEmpty, reason: 'Card dialogue empty on day $day');
        expect(card.characterName, isNotEmpty, reason: 'Character name empty on day $day');
        expect(card.characterRole, isNotEmpty, reason: 'Character role empty on day $day');
        expect(card.choices.length, greaterThanOrEqualTo(2),
            reason: 'Card has fewer than 2 choices on day $day');

        for (final choice in card.choices) {
          expect(choice.id, isNotEmpty);
          expect(choice.label, isNotEmpty);
          expect(choice.outcomes, isNotEmpty);
          for (final outcome in choice.outcomes) {
            expect(outcome.title, isNotEmpty);
            expect(outcome.message, isNotEmpty);
            expect(outcome.probability, greaterThan(0.0));
          }
        }

        seenIds.add(card.id);
      }

      expect(seenIds.length, equals(365), reason: 'Every single day in the 365-day year must have a unique ID');
    });

    test('2. Invariant Rules: Zero Unicode Emojis and Zero Parentheses across all 365 days', () {
      final emojiRegex = RegExp(
        r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{1F900}-\u{1F9FF}\u{1F018}-\u{1F270}\u{23E9}-\u{23FA}]',
        unicode: true,
      );
      final parenthesesRegex = RegExp(r'[\(\)]');

      for (int day = 1; day <= 365; day++) {
        final card = DramaticCardEngine.generateDailyDilemma(day, baseState);

        expect(emojiRegex.hasMatch(card.title), isFalse, reason: 'Day $day title has emoji: ${card.title}');
        expect(parenthesesRegex.hasMatch(card.title), isFalse, reason: 'Day $day title has parentheses: ${card.title}');
        expect(emojiRegex.hasMatch(card.dialogue), isFalse, reason: 'Day $day dialogue has emoji');
        expect(parenthesesRegex.hasMatch(card.dialogue), isFalse, reason: 'Day $day dialogue has parentheses');
        expect(emojiRegex.hasMatch(card.characterName), isFalse);
        expect(parenthesesRegex.hasMatch(card.characterName), isFalse);
        expect(emojiRegex.hasMatch(card.characterRole), isFalse);
        expect(parenthesesRegex.hasMatch(card.characterRole), isFalse);

        for (final choice in card.choices) {
          expect(emojiRegex.hasMatch(choice.label), isFalse, reason: 'Day $day choice label has emoji: ${choice.label}');
          expect(parenthesesRegex.hasMatch(choice.label), isFalse, reason: 'Day $day choice label has parentheses: ${choice.label}');
          expect(emojiRegex.hasMatch(choice.shortDescription), isFalse);
          expect(parenthesesRegex.hasMatch(choice.shortDescription), isFalse);

          for (final outcome in choice.outcomes) {
            expect(emojiRegex.hasMatch(outcome.title), isFalse);
            expect(parenthesesRegex.hasMatch(outcome.title), isFalse);
            expect(emojiRegex.hasMatch(outcome.message), isFalse);
            expect(parenthesesRegex.hasMatch(outcome.message), isFalse);
          }
        }
      }
    });

    test('3. System State Mutations: Upfront Cost, Money, Reputation Clamping, XP, NPC Trust, and Vehicle Consequences', () {
      // 3.1 Upfront cost and positive money delta
      final cardDay1 = DramaticCardEngine.generateDailyDilemma(1, baseState);
      final choice1 = cardDay1.choices.first; // Çay İkram Et
      final res1 = DramaticCardEngine.resolveChoice(baseState, cardDay1, choice1, fixedRoll: 0.1);

      expect(res1.updatedState.balance, equals(baseState.balance - choice1.upfrontCost + res1.outcome.moneyDelta));
      expect(res1.updatedState.reputationScore, inInclusiveRange(0, 1000));
      expect(res1.updatedState.experience, greaterThanOrEqualTo(baseState.experience));
      expect(res1.updatedState.seenDramaticCardIds.contains(cardDay1.id), isTrue);
      expect(res1.updatedState.pendingDramaticCard, isNull);

      // 3.2 Vehicle Loss Protection on Showcase Locked Cars
      final lossOutcome = const DramaticOutcomeModel(
        title: 'Araba Çalındı',
        message: 'Karanlık sokakta bırakılan araç çalındı.',
        moneyDelta: 0.0,
        reputationDelta: -10,
        isSuccess: false,
        probability: 1.0,
        loseTargetCar: true,
      );
      final lossChoice = DramaticChoiceModel(
        id: 'loss_test',
        label: 'Risk Al',
        shortDescription: 'Tehlikeli bölgeye park et',
        outcomes: [lossOutcome],
      );
      final lossCard = DramaticCardModel(
        id: 'dramatic_loss_test',
        title: 'Gece Parkı',
        dialogue: 'Anahtarları teslim ettiniz.',
        category: DramaticCategory.loss,
        severity: DramaticSeverity.high,
        characterName: 'Gece Bekçisi',
        characterRole: 'Otopark Sorumlusu',
        characterAvatar: 'guard',
        icon: Icons.local_parking,
        foreshadowHint: 'Karanlık sokak',
        choices: [lossChoice],
      );

      final lossRes = DramaticCardEngine.resolveChoice(baseState, lossCard, lossChoice, fixedRoll: 0.1);
      // Ensure regular car was removed, but heirloom locked car remains safe!
      expect(lossRes.updatedState.ownedCars.length, equals(1));
      expect(lossRes.updatedState.ownedCars.first.id, equals('car_test_heirloom'));
      expect(lossRes.updatedState.ownedCars.first.isLockedInShowcase, isTrue);

      // 3.3 Spawn Bargain Car
      final bargainOutcome = const DramaticOutcomeModel(
        title: 'Kelepir Araç Düştü',
        message: 'Acil paraya sıkışan vatandaş uyguna bıraktı.',
        moneyDelta: -50000.0,
        reputationDelta: 5,
        isSuccess: true,
        probability: 1.0,
        spawnBargainCar: true,
      );
      final bargainChoice = DramaticChoiceModel(
        id: 'bargain_test',
        label: 'Satın Al',
        shortDescription: 'Fırsatı kaçırma',
        outcomes: [bargainOutcome],
      );
      final bargainCard = DramaticCardModel(
        id: 'dramatic_bargain_test',
        title: 'Kelepir Teklif',
        dialogue: 'Borcumu kapatmam lazım.',
        category: DramaticCategory.opportunity,
        severity: DramaticSeverity.medium,
        characterName: 'Mecbur Esnaf',
        characterRole: 'Eski Galeri Sahibi',
        characterAvatar: 'trader',
        icon: Icons.handshake,
        foreshadowHint: 'Acil nakit arıyor',
        choices: [bargainChoice],
      );

      final bargainRes = DramaticCardEngine.resolveChoice(baseState, bargainCard, bargainChoice, fixedRoll: 0.1);
      expect(bargainRes.updatedState.ownedCars.length, equals(baseState.ownedCars.length + 1));
      expect(bargainRes.updatedState.ownedCars.any((c) => c.brand == 'Volk'), isTrue);

      // 3.4 Staff Salary Multiplier Consequence
      final salaryOutcome = const DramaticOutcomeModel(
        title: 'Ustaya Zam Yapıldı',
        message: 'Usta motivasyon kazandı.',
        moneyDelta: 0.0,
        reputationDelta: 10,
        isSuccess: true,
        probability: 1.0,
        staffSalaryMultiplier: 1.25,
      );
      final salaryChoice = DramaticChoiceModel(
        id: 'salary_test',
        label: 'Zam Ver',
        shortDescription: 'Maaşı artır',
        outcomes: [salaryOutcome],
      );
      final salaryCard = DramaticCardModel(
        id: 'dramatic_salary_test',
        title: 'Usta Talebi',
        dialogue: 'Piyasa çok yükseldi.',
        category: DramaticCategory.conscience,
        severity: DramaticSeverity.low,
        characterName: 'Haydar Usta',
        characterRole: 'Baş Mekaniker',
        characterAvatar: 'mechanic',
        icon: Icons.build,
        foreshadowHint: 'Usta maaşından şikayetçi',
        choices: [salaryChoice],
      );

      final salaryRes = DramaticCardEngine.resolveChoice(baseState, salaryCard, salaryChoice, fixedRoll: 0.1);
      expect(salaryRes.updatedState.hiredStaff.first.salaryMultiplier, equals(1.25));
    });

    testWidgets('4. UI Screen & Dialog Flow: NeoBrutalDramaticDialog displays card and handles choice resolution', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final card = DramaticCardEngine.generateDailyDilemma(1, baseState);

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(gameProvider.notifier).state = baseState;

      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('tr'),
            supportedLocales: const [Locale('tr')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: NeoBrutalDramaticDialog(card: card),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that all core UI components render on screen
      expect(find.byType(NeoBrutalDramaticDialog), findsOneWidget);
      expect(find.text(card.title), findsOneWidget);
      expect(find.text(card.dialogue), findsOneWidget);
      expect(find.text('${card.characterName} • ${card.characterRole}'), findsOneWidget);

      // Verify choices are rendered
      for (final choice in card.choices) {
        expect(find.text(choice.label), findsOneWidget);
      }

      // Tap first choice
      final firstChoiceFinder = find.text(card.choices.first.label);
      await tester.ensureVisible(firstChoiceFinder);
      await tester.tap(firstChoiceFinder);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      // Verify outcome result view appears with continue button
      expect(find.text('DEVAM ET'), findsOneWidget);

      // Tap Continue Button
      await tester.tap(find.text('DEVAM ET'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      // State pendingDramaticCard should now be cleared
      final updatedState = container.read(gameProvider);
      expect(updatedState.pendingDramaticCard, isNull);
      expect(updatedState.seenDramaticCardIds.contains(card.id), isTrue);
    });

    test('5. Multi-Day Game Progression Sim: 365 consecutive days with dynamic choices and JSON serialization', () {
      DealershipModel simState = baseState;

      for (int day = 1; day <= 365; day++) {
        simState = simState.copyWith(currentDay: day);

        // Generate daily dilemma
        final dilemmaCard = DramaticCardEngine.generateDailyDilemma(day, simState);
        expect(dilemmaCard, isNotNull);
        expect(dilemmaCard.dayNumber, equals(day));

        // Simulate picking a random choice
        final chosenOption = dilemmaCard.choices[day % dilemmaCard.choices.length];
        final res = DramaticCardEngine.resolveChoice(
          simState,
          dilemmaCard,
          chosenOption,
          fixedRoll: 0.5,
        );

        simState = res.updatedState;

        // Verify sanity of numbers
        expect(simState.balance.isNaN, isFalse);
        expect(simState.reputationScore, inInclusiveRange(0, 1000));
        expect(simState.experience, greaterThanOrEqualTo(0));

        // Verify JSON round-trip serialization on sample days
        if (day % 30 == 0 || day == 365) {
          final json = simState.toJson();
          final reconstituted = DealershipModel.fromJson(json);
          expect(reconstituted.currentDay, equals(simState.currentDay));
          expect(reconstituted.balance, equals(simState.balance));
          expect(reconstituted.reputationScore, equals(simState.reputationScore));
          expect(reconstituted.seenDramaticCardIds.length, equals(simState.seenDramaticCardIds.length));
        }
      }

      // At the end of 365 days, player has seen multiple distinct dilemma cards
      expect(simState.seenDramaticCardIds.length, greaterThan(50));
    });
  });
}
