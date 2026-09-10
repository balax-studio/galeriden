import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'package:galeriden/core/theme/app_theme_extension.dart';
import 'package:galeriden/data/models/theme_palette_model.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/data/models/story_card_model.dart';
import 'package:galeriden/data/models/car_model.dart';
import 'package:galeriden/data/models/expertise_model.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/whats_new_dialog.dart';
import 'package:galeriden/domain/usecases/dramatic_card_engine.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_story_ad_dialog.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_dramatic_dialog.dart';
import 'package:galeriden/presentation/widgets/ads/neo_brutal_fallback_ad_dialog.dart';
import 'package:galeriden/presentation/widgets/tactile_operation_overlay.dart';
import 'package:galeriden/presentation/screens/showroom/widgets/showroom_car_card.dart';

Widget _buildSmallScreenTestApp(
  Widget child, {
  ProviderContainer? container,
  Locale locale = const Locale('tr'),
  Size screenSize = const Size(320, 568),
}) {
  final testTheme = ThemeData.light().copyWith(
    extensions: [
      AppThemeExtension(palette: ThemePaletteModel.defaultPalettes.first),
    ],
  );

  final widget = MaterialApp(
    locale: locale,
    supportedLocales: AppLanguage.values.map((e) => e.locale).toList(),
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: testTheme,
    home: MediaQuery(
      data: MediaQueryData(
        size: screenSize,
        padding: const EdgeInsets.only(top: 20, bottom: 20),
      ),
      child: Scaffold(
        body: Center(child: child),
      ),
    ),
  );

  if (container != null) {
    return UncontrolledProviderScope(
      container: container,
      child: widget,
    );
  }

  return ProviderScope(child: widget);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Small Screen (320x568) Overflow & Layout Audit Tests', () {
    testWidgets('1. WhatsNewDialog on 320px screen in Russian locale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        _buildSmallScreenTestApp(
          const WhatsNewDialog(),
          container: container,
          locale: const Locale('ru'),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('2. NeoBrutalStoryAdDialog on 320px screen in Russian locale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      const sampleCard = StoryCardModel(
        id: 'test_story_1',
        title: 'SANAYİ USTASI ÇAĞRISI',
        characterName: 'Usta Haydar',
        characterRole: 'Kıdemli Motor Revizyoneri',
        characterAvatar: 'wrench',
        icon: Icons.build_rounded,
        dialogue: 'Elimde çok temiz çıkma yedek parça var. Değerlendirmek ister misin?',
        acceptLabel: 'Parçayı Satın Al',
        declineLabel: 'Gerek Yok',
        rewardDescription: '+%15 Tamir Hızı',
        rewardType: StoryAdRewardType.instantExpertise,
      );

      await tester.pumpWidget(
        _buildSmallScreenTestApp(
          const NeoBrutalStoryAdDialog(card: sampleCard),
          container: container,
          locale: const Locale('ru'),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('3. NeoBrutalDramaticDialog on 320px screen in German locale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final sampleCard = DramaticCardEngine.generateDailyDilemma(1, DealershipModel.initial());

      await tester.pumpWidget(
        _buildSmallScreenTestApp(
          NeoBrutalDramaticDialog(card: sampleCard),
          container: container,
          locale: const Locale('de'),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('4. NeoBrutalFallbackAdDialog on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        _buildSmallScreenTestApp(
          NeoBrutalFallbackAdDialog(
            onRewardClaimed: () {},
            rewardTitle: 'Hızlı Sermaye Desteği ₺25.000',
          ),
          container: container,
          locale: const Locale('ru'),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      container.dispose();
    });

    testWidgets('5. TactileOperationOverlay on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _buildSmallScreenTestApp(
          const TactileOperationOverlay(
            title: 'EKSPERTİZ DYNO TESTİ',
            stage1Text: 'Silindir kompresyonu ölçülüyor...',
            stage2Text: 'Tork aktarımı test ediliyor...',
            stage3Text: 'Rapor hazırlanıyor...',
            totalDuration: Duration(seconds: 2),
            accentColor: Color(0xFFFFDE59),
          ),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pump();

      final ex = tester.takeException();
      expect(ex, isNull);
    });

    testWidgets('6. ShowroomCarCard non-car multi-badge on 320px screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer();
      container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();

      final car = CarModel(
        id: 'test_truck_1',
        brand: 'Mercedes-Benz Actros',
        modelName: '1845 LS StreamSpace',
        modelYear: 2021,
        bodyType: 'Çekici Tır',
        colorHex: '#000000',
        baseMarketValue: 3500000.0,
        currentPurchasePrice: 3200000.0,
        vehicleCategory: VehicleCategory.commercial,
        expertise: ExpertiseReport(
          mileage: 120000,
          isMileageTampered: false,
          engineCondition: 98.0,
          transmissionCondition: 98.0,
          tramerAmount: 0,
          bodyParts: {},
          partConditions: {},
        ),
      );

      final game = container.read(gameProvider);
      final palette = ThemePaletteModel.defaultPalettes.first;

      await tester.pumpWidget(
        _buildSmallScreenTestApp(
          ShowroomCarCard(
            car: car,
            game: game,
            palette: palette,
            hasSalesman: true,
          ),
          container: container,
          locale: const Locale('tr'),
          screenSize: const Size(320, 568),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      container.dispose();
    });
  });
}
