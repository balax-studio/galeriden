import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/core/localization/translations/tr_translations.dart';
import 'package:galeriden/core/localization/translations/en_translations.dart';
import 'package:galeriden/core/localization/translations/de_translations.dart';
import 'package:galeriden/core/localization/translations/pt_translations.dart';
import 'package:galeriden/core/localization/translations/es_translations.dart';
import 'package:galeriden/core/localization/translations/ru_translations.dart';
import 'package:galeriden/core/localization/translations/ar_translations.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/customer_crm_event_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/loan_model.dart';
import 'package:galeriden/data/models/lucky_opportunity_model.dart';
import 'package:galeriden/data/models/notary_event_model.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/providers/market_provider.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/dashboard_quick_finance_card.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/financial_health_card.dart';
import 'package:galeriden/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:galeriden/presentation/widgets/dialogs/customer_follow_up_dialog.dart';
import 'package:galeriden/presentation/widgets/dialogs/daily_login_sheet.dart';
import 'package:galeriden/presentation/widgets/dialogs/lucky_opportunity_dialog.dart';
import 'package:galeriden/presentation/widgets/dialogs/notary_transfer_dialog.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_badge.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';

Widget _buildTestApp(Widget child, {Locale locale = const Locale('tr'), Size screenSize = const Size(360, 640)}) {
  final testTheme = ThemeData.light().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  return MaterialApp(
    locale: locale,
    supportedLocales: const [
      Locale('tr'),
      Locale('en'),
      Locale('de'),
      Locale('pt'),
      Locale('es'),
      Locale('ru'),
      Locale('ar'),
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: testTheme,
    home: MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.height,
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UI/UX, Typography & Button Dimension Audit Tests', () {
    testWidgets('1. NeoBrutalButton renders without overflow in narrow constraints with long German/Russian strings', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const SizedBox(
            width: 200,
            child: NeoBrutalButton(
              label: 'Geschäftsleitung Hauptuntersuchung',
              icon: Icons.settings_rounded,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NeoBrutalButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. NeoBrutalButton respects minimum 48dp touch target standard', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const NeoBrutalButton(
            label: 'TEST BUTTON',
            fontSize: 13.0,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final buttonSize = tester.getSize(find.byType(NeoBrutalButton));
      expect(buttonSize.height, greaterThanOrEqualTo(48.0));
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. NeoBrutalBadge renders in narrow constraints without row overflow', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const SizedBox(
            width: 100,
            child: Row(
              children: [
                Expanded(
                  child: NeoBrutalBadge(
                    text: 'Very Long Badge Text That Should Not Overflow',
                    icon: Icons.verified_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NeoBrutalBadge), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. DashboardQuickFinanceCard renders cleanly in compact 360dp width with active loans', (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final baseGame = container.read(gameProvider);

      const testLoan = LoanModel(
        id: 'loan_1',
        bankName: 'Ziraat Esnaf',
        principalAmount: 500000.0,
        interestRate: 0.15,
        totalRepayment: 575000.0,
        remainingAmount: 485000.0,
        totalInstallments: 12,
        remainingInstallments: 10,
        monthlyPayment: 47916.0,
      );

      final game = baseGame.copyWith(
        activeLoans: [testLoan],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _buildTestApp(
            DashboardQuickFinanceCard(
              game: game,
              palette: ThemePaletteModel.defaultPalettes.first,
            ),
            screenSize: const Size(360, 640),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DashboardQuickFinanceCard), findsOneWidget);
      expect(find.byType(NeoBrutalButton), findsOneWidget);
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('5. FinancialHealthCard renders grade and localized button cleanly in 360dp width', (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      final baseGame = container.read(gameProvider);

      final sampleCar = CarModel(
        id: 'c1',
        brand: 'BMW',
        modelName: '320i',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#FFFFFF',
        baseMarketValue: 1200000,
        currentPurchasePrice: 1100000,
        expertise: ExpertiseReport(
          engineCondition: 90,
          transmissionCondition: 90,
          tramerAmount: 0,
          mileage: 50000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      final game = baseGame.copyWith(
        balance: 250000.0,
        ownedCars: [sampleCar],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _buildTestApp(
            FinancialHealthCard(
              dealership: game,
              onSiftahTapped: () {},
            ),
            screenSize: const Size(360, 640),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FinancialHealthCard), findsOneWidget);
      expect(find.byType(NeoBrutalButton), findsOneWidget);
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('6. CustomerFollowUpDialog builds with SingleChildScrollView and does not overflow in compact height', (tester) async {
      const event = CustomerCrmEventModel(
        id: 'crm_1',
        customerName: 'Ahmet Bey',
        carModelName: 'Honda Civic',
        type: CustomerCrmEventType.collectorAppreciation,
        title: 'Müşteri Teşekkürü',
        description: 'Geçen hafta sattığınız araçtan çok memnun kalan müşteri esnafınıza özel ikram paketi hediye etti.',
        financialImpact: 15000.0,
        reputationImpact: 15,
        triggerDay: 5,
      );

      await tester.pumpWidget(
        _buildTestApp(
          const CustomerFollowUpDialog(event: event),
          screenSize: const Size(360, 500),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomerFollowUpDialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('7. LuckyOpportunityDialog builds with SingleChildScrollView in compact height', (tester) async {
      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      const opportunity = LuckyOpportunityModel(
        id: 'lucky_1',
        type: LuckyOpportunityType.vipSponsorDeal,
        titleKey: 'lucky_sponsor_title',
        descriptionKey: 'lucky_sponsor_desc',
        perkSummaryKey: 'lucky_sponsor_perk',
        icon: Icons.campaign_rounded,
        accentColor: Color(0xFFFFDE59),
        cashReward: 75000.0,
        reputationBonus: 20,
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _buildTestApp(
            const LuckyOpportunityDialog(opportunity: opportunity),
            screenSize: const Size(360, 500),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LuckyOpportunityDialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('8. NotaryTransferDialog builds with SingleChildScrollView in compact height', (tester) async {
      final car = CarModel(
        id: 'c2',
        brand: 'Mercedes',
        modelName: 'C200',
        modelYear: 2021,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 1800000,
        currentPurchasePrice: 1700000,
        expertise: ExpertiseReport(
          engineCondition: 95,
          transmissionCondition: 95,
          tramerAmount: 0,
          mileage: 30000,
          isMileageTampered: false,
          bodyParts: {},
        ),
      );

      const eventResult = NotaryEventResult(
        type: NotaryEventType.smoothDeal,
        title: 'Noter Satış Onayı',
        description: 'Ruhsat devir işlemleri başarıyla tamamlandı.',
        isCancelled: false,
        bonusXp: 50,
        bonusReputation: 10,
        extraFee: 0.0,
      );

      await tester.pumpWidget(
        _buildTestApp(
          NotaryTransferDialog(
            car: car,
            buyerName: 'Mehmet Kaya',
            sellerName: 'Galeri Sahibi',
            salePrice: 1950000.0,
            eventResult: eventResult,
          ),
          screenSize: const Size(360, 500),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(NotaryTransferDialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test('9. All 7 languages have complete synchronization for new UI audit keys', () {
      final auditKeys = [
        'tramer_inquiry_body',
        'tramer_total_damage_label',
        'financial_health_title',
        'siftah_btn',
        'scrapyard_strip_all_btn',
        'consignment_go_market_btn',
        'explore_now_btn',
        'all_segments_filter',
        'prestige_transfer_btn',
      ];

      final allTranslationMaps = {
        'tr': trTranslations,
        'en': enTranslations,
        'de': deTranslations,
        'pt': ptTranslations,
        'es': esTranslations,
        'ru': ruTranslations,
        'ar': arTranslations,
      };

      for (final entry in allTranslationMaps.entries) {
        final lang = entry.key;
        final map = entry.value;
        for (final key in auditKeys) {
          expect(map.containsKey(key), isTrue, reason: 'Language $lang missing key: $key');
          expect(map[key]!.isNotEmpty, isTrue, reason: 'Language $lang has empty string for key: $key');
          expect(map[key]!.contains('('), isFalse, reason: 'Language $lang key $key contains illegal opening parenthesis');
          expect(map[key]!.contains(')'), isFalse, reason: 'Language $lang key $key contains illegal closing parenthesis');
        }
      }
    });

    testWidgets('10. DailyLoginSheet builds with SingleChildScrollView and properly stacked banner without overflow', (tester) async {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _buildTestApp(
            const DailyLoginSheet(),
            screenSize: const Size(360, 600),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DailyLoginSheet), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.text('SERİ KORUMA VE KURTARMA KALKANI'), findsOneWidget);
      expect(find.text('SERİYİ DONDUR VE KURTAR • REKLAM İZLE'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('11. MarketplaceScreen car card action bar renders cleanly without horizontal overflow in compact 360dp width and German locale', (tester) async {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.read(marketProvider.notifier).onAppPaused();
        container.dispose();
      });
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
      container.read(marketProvider.notifier).onAppPaused();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _buildTestApp(
            const MarketplaceScreen(),
            locale: const Locale('de'),
            screenSize: const Size(360, 640),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(MarketplaceScreen), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 500));
    });
  });
}
