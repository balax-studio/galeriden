import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/feedback_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({required ProviderContainer container}) {
    return UncontrolledProviderScope(
      container: container,
      child: ToastificationWrapper(
        child: MaterialApp(
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr'),
              Locale('en'),
              Locale('de'),
              Locale('pt'),
              Locale('es'),
              Locale('ru'),
              Locale('ar'),
            ],
            locale: const Locale('tr'),
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: FeedbackDialog(),
          ),
        ),
      ),
    );
  }

  group('FeedbackDialog Tests', () {
    testWidgets('Renders all fields, categories and buttons properly', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      expect(find.text('GERİ BİLDİRİM & ÖNERİ'), findsOneWidget);
      expect(find.text('Hata Bildirimi'), findsOneWidget);
      expect(find.text('Yeni Özellik İsteği'), findsOneWidget);
      expect(find.text('Oyun Dengesi & Ekonomi'), findsOneWidget);
      expect(find.text('Genel Öneri & Fikir'), findsOneWidget);
      expect(find.text('BİLDİRİMİ GÖNDER'), findsOneWidget);
      expect(find.text('E-POSTA UYGULAMASIYLA GÖNDER'), findsOneWidget);
      expect(find.text('VAZGEÇ'), findsOneWidget);

      notifier.stopPeriodicOrganicOfferTimer();
      toastification.dismissAll();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Selecting category updates active category', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Yeni Özellik İsteği'));
      await tester.pumpAndSettle();

      expect(find.text('Yeni Özellik İsteği'), findsOneWidget);

      notifier.stopPeriodicOrganicOfferTimer();
      toastification.dismissAll();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Empty fields show warning and prevent submission', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      await tester.tap(find.text('BİLDİRİMİ GÖNDER'));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('in_app_feedback_queue') ?? [];
      expect(queue.isEmpty, isTrue);

      notifier.stopPeriodicOrganicOfferTimer();
      toastification.dismissAll();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Filling fields and submitting saves to local feedback queue', (tester) async {
      final container = ProviderContainer();
      final notifier = container.read(gameProvider.notifier);

      await tester.pumpWidget(createTestWidget(container: container));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.first, 'Test Konu');
      await tester.enterText(textFields.last, 'Test Mesaj Detayı');
      await tester.pumpAndSettle();

      await tester.tap(find.text('BİLDİRİMİ GÖNDER'));
      await tester.pump(const Duration(milliseconds: 200));

      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('in_app_feedback_queue') ?? [];
      expect(queue.length, 1);
      expect(queue.first.contains('Test Konu'), isTrue);
      expect(queue.first.contains('Test Mesaj Detayı'), isTrue);

      notifier.stopPeriodicOrganicOfferTimer();
      toastification.dismissAll();
      container.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
