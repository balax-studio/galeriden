import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/tutorial_pulse_target.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TutorialPulseTarget Tests', () {
    testWidgets('renders child properly when enabled without timer leak in test environment',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TutorialPulseTarget(
              isEnabled: true,
              child: Text('Tutorial Step 3 Target'),
            ),
          ),
        ),
      );

      expect(find.text('Tutorial Step 3 Target'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Tutorial Step 3 Target'), findsOneWidget);
    });

    testWidgets('renders child properly when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TutorialPulseTarget(
              isEnabled: false,
              child: Text('Disabled Pulse Target'),
            ),
          ),
        ),
      );

      expect(find.text('Disabled Pulse Target'), findsOneWidget);
    });
  });
}
