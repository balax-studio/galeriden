import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/domain/usecases/real_estate_chat_negotiation_engine.dart';
import 'package:galeriden/presentation/screens/real_estate/widgets/real_estate_negotiation_log_box.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', ''),
        Locale('en', ''),
      ],
      locale: const Locale('tr', ''),
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('RealEstateNegotiationLogBox Widget Tests', () {
    testWidgets('renders log header and chronological messages correctly', (tester) async {
      final messages = [
        ChatMessageModel(
          id: 'msg_1',
          senderName: 'SİSTEM',
          role: ChatSenderRole.seller,
          message: 'Masaya oturuldu • İlan Fiyatı: ₺10.000.000',
          timestamp: DateTime.now(),
          isFromPlayer: false,
          badgeText: 'BAŞLANGIÇ',
        ),
        ChatMessageModel(
          id: 'msg_2',
          senderName: 'Galeri Sahibi',
          role: ChatSenderRole.player,
          message: 'Alıcı tarafından ₺9.000.000 teklif masaya kondu.',
          timestamp: DateTime.now(),
          isFromPlayer: true,
          badgeText: 'TEKLİF',
        ),
        ChatMessageModel(
          id: 'msg_3',
          senderName: 'Ahmet Bey',
          role: ChatSenderRole.seller,
          message: 'Bu fiyata sanayi parseli devredilmez!',
          timestamp: DateTime.now(),
          isFromPlayer: false,
          badgeText: 'RET',
        ),
      ];

      await tester.pumpWidget(
        buildTestableWidget(
          RealEstateNegotiationLogBox(
            messages: messages,
            isThinking: false,
            height: 300,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Masaya oturuldu • İlan Fiyatı: ₺10.000.000'), findsOneWidget);
      expect(find.text('Alıcı tarafından ₺9.000.000 teklif masaya kondu.'), findsOneWidget);
      expect(find.text('Bu fiyata sanayi parseli devredilmez!'), findsOneWidget);
      expect(find.text('BAŞLANGIÇ'), findsOneWidget);
      expect(find.text('TEKLİF'), findsOneWidget);
      expect(find.text('RET'), findsOneWidget);
    });

    testWidgets('renders animated thinking indicator when isThinking is true', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          const RealEstateNegotiationLogBox(
            messages: [],
            isThinking: true,
            thinkingText: 'Satıcı mülk sahibini arıyor...',
            height: 300,
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Satıcı mülk sahibini arıyor...'), findsOneWidget);
    });
  });
}
