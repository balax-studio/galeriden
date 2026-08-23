import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/car_icons.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_car_vector_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NeoBrutalCarVectorPainter & CarSilhouetteWidget Tests', () {
    testWidgets('Renders Sedan body type with NeoBrutalCarVectorPainter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CarSilhouetteWidget(
              bodyType: 'Sedan',
              color: Colors.red,
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(CarSilhouetteWidget), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CarSilhouetteWidget),
          matching: find.byType(CustomPaint),
        ),
        findsOneWidget,
      );
    });

    testWidgets('Renders all body types (Hatchback, SUV, Sport, Classic, Van)', (tester) async {
      final bodyTypes = ['Hatchback', 'SUV', 'Spor', 'Coupe', 'Klasik', 'Van', 'Station'];

      for (final type in bodyTypes) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CarSilhouetteWidget(
                bodyType: type,
                color: Colors.blue,
                isClean: true,
                isTuned: true,
                damagePercent: 35.0,
                showBackgroundPod: true,
              ),
            ),
          ),
        );

        expect(find.byType(CarSilhouetteWidget), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    test('Painter shouldRepaint triggers when properties change', () {
      final painter1 = NeoBrutalCarVectorPainter(
        bodyColor: Colors.red,
        bodyType: 'Sedan',
      );

      final painter2 = NeoBrutalCarVectorPainter(
        bodyColor: Colors.blue,
        bodyType: 'Sedan',
      );

      final painter3 = NeoBrutalCarVectorPainter(
        bodyColor: Colors.red,
        bodyType: 'SUV',
      );

      expect(painter1.shouldRepaint(painter2), isTrue);
      expect(painter1.shouldRepaint(painter3), isTrue);
      expect(painter1.shouldRepaint(painter1), isFalse);
    });
  });
}
