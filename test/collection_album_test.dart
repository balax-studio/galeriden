import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/screens/album/collection_album_screen.dart';
import 'package:galeriden/presentation/widgets/cracked_glass_badge.dart';
import 'package:galeriden/presentation/widgets/sweat_drop_widget.dart';
import 'package:galeriden/presentation/widgets/handshake_clash_overlay.dart';
import 'package:galeriden/presentation/widgets/hydraulic_lift_widget.dart';
import 'package:galeriden/presentation/widgets/engine_pulse_widget.dart';
import 'package:galeriden/presentation/widgets/paint_spark_widget.dart';
import 'package:galeriden/presentation/widgets/rust_oil_drop_widget.dart';
import 'package:galeriden/presentation/widgets/gavel_shockwave_widget.dart';
import 'package:galeriden/presentation/widgets/bid_paddle_animation.dart';
import 'package:galeriden/presentation/widgets/countdown_heat_ring.dart';
import 'package:galeriden/presentation/widgets/chassis_laser_scan_widget.dart';
import 'package:galeriden/presentation/widgets/fake_doc_ink_spread_widget.dart';
import 'package:galeriden/presentation/widgets/candle_spark_widget.dart';
import 'package:galeriden/presentation/widgets/fountain_pen_signature_widget.dart';
import 'package:galeriden/presentation/widgets/tax_alert_bell_widget.dart';
import 'package:galeriden/presentation/widgets/leather_keychain_swing_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Collection Album & 19 Micro-Animations Test Suite', () {
    testWidgets('1. CollectionAlbumScreen renders header, progress and vehicle grid', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);
      notifier.stopPeriodicOrganicOfferTimer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [
              Locale('tr'),
              Locale('en'),
            ],
            home: CollectionAlbumScreen(),
          ),
        ),
      );

      // Drain timers and load state
      await tester.pump(const Duration(milliseconds: 500));
      notifier.stopPeriodicOrganicOfferTimer();
      await tester.pumpAndSettle();

      expect(find.byType(CollectionAlbumScreen), findsOneWidget);
      expect(find.textContaining('KOLEKSİYON ALBÜMÜ'), findsOneWidget);

      notifier.stopPeriodicOrganicOfferTimer();
      container.dispose();
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('2. Micro-animation widgets render without assertion failures', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  CrackedGlassBadge(),
                  SweatDropWidget(),
                  HandshakeClashOverlay(),
                  HydraulicLiftWidget(child: Text('Car Lift')),
                  EnginePulseWidget(engineHealthPercent: 90),
                  PaintSparkWidget(micronValue: 120),
                  RustOilDropWidget(),
                  GavelShockwaveWidget(),
                  BidPaddleAnimation(paddleNumber: '42', bidderName: 'Test Buyer'),
                  CountdownHeatRing(remainingSeconds: 8, totalSeconds: 15),
                  ChassisLaserScanWidget(isScanning: true, child: Text('Laser Scan')),
                  FakeDocInkSpreadWidget(stampText: 'AKLANDI'),
                  CandleSparkWidget(isPositive: true),
                  FountainPenSignatureWidget(),
                  TaxAlertBellWidget(hasUnpaidTax: true),
                  LeatherKeychainSwingWidget(),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Car Lift'), findsOneWidget);
      expect(find.text('Laser Scan'), findsOneWidget);
    });
  });
}
