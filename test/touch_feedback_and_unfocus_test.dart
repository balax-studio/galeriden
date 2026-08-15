import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_button.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_touch_feedback_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Global Unfocus & Neo-Brutalist Touch Feedback Overlay Tests', () {
    testWidgets('Tapping outside an active TextField automatically dismisses keyboard focus', (tester) async {
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: NeoBrutalTouchFeedbackOverlay(
            child: Scaffold(
              body: Column(
                children: [
                  const SizedBox(height: 50),
                  TextField(
                    focusNode: focusNode,
                    key: const Key('test_input'),
                  ),
                  const SizedBox(height: 100),
                  Container(
                    key: const Key('outside_area'),
                    height: 200,
                    width: 200,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Focus the text field
      await tester.tap(find.byKey(const Key('test_input')));
      await tester.pumpAndSettle();
      expect(focusNode.hasFocus, isTrue, reason: 'TextField should have focus after tapping it');

      // Tap outside the textfield on the blue container
      await tester.tap(find.byKey(const Key('outside_area')));
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isFalse, reason: 'TextField should lose focus when tapping outside');
    });

    testWidgets('Touch feedback overlay does not block button taps or interactive elements', (tester) async {
      bool buttonClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: NeoBrutalTouchFeedbackOverlay(
            child: Scaffold(
              body: Center(
                child: NeoBrutalButton(
                  key: const Key('test_button'),
                  label: 'Tıkla',
                  onPressed: () {
                    buttonClicked = true;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const Key('test_button')));
      await tester.pumpAndSettle();

      expect(buttonClicked, isTrue, reason: 'Button onPressed must execute normally through overlay');
    });

    testWidgets('Pointer down spawns tactile burst animation and cleans up after animation finishes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NeoBrutalTouchFeedbackOverlay(
            child: Scaffold(
              body: Container(
                key: const Key('tap_target'),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      // Tap down
      final gesture = await tester.startGesture(const Offset(150, 200));
      await tester.pump(const Duration(milliseconds: 50));

      final state = tester.state<NeoBrutalTouchFeedbackOverlayState>(find.byType(NeoBrutalTouchFeedbackOverlay));
      expect(state.activeParticles.isNotEmpty, isTrue, reason: 'A touch ripple particle should be active');

      await gesture.up();
      // Advance clock past particle lifetime (300ms)
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(state.activeParticles.isEmpty, isTrue, reason: 'Particle should be cleaned up after animation completes');
    });
  });
}
