import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/presentation/widgets/isometric_showroom_canvas.dart';

void main() {
  group('IsometricMath Matrix Transformation Tests', () {
    const origin = Offset(200.0, 50.0);
    const tileWidth = 100.0;
    const tileHeight = 50.0;

    test('isoToScreen projects (0,0) to origin', () {
      final screenPt = IsometricMath.isoToScreen(0, 0, tileWidth, tileHeight, origin);
      expect(screenPt.dx, equals(200.0));
      expect(screenPt.dy, equals(50.0));
    });

    test('isoToScreen projects (0,1) correctly to the right-down isometric axis', () {
      final screenPt = IsometricMath.isoToScreen(0, 1, tileWidth, tileHeight, origin);
      expect(screenPt.dx, equals(250.0)); // (1 - 0) * 50 + 200
      expect(screenPt.dy, equals(75.0));  // (1 + 0) * 25 + 50
    });

    test('isoToScreen projects (1,0) correctly to the left-down isometric axis', () {
      final screenPt = IsometricMath.isoToScreen(1, 0, tileWidth, tileHeight, origin);
      expect(screenPt.dx, equals(150.0)); // (0 - 1) * 50 + 200
      expect(screenPt.dy, equals(75.0));  // (0 + 1) * 25 + 50
    });

    test('screenToIso converts origin back to (0,0)', () {
      final isoPt = IsometricMath.screenToIso(origin, tileWidth, tileHeight, origin);
      expect(isoPt.row, equals(0.0));
      expect(isoPt.col, equals(0.0));
    });

    test('screenToIso inverse transformation matches isoToScreen', () {
      final screenPt = IsometricMath.isoToScreen(2, 1, tileWidth, tileHeight, origin);
      final isoPt = IsometricMath.screenToIso(screenPt, tileWidth, tileHeight, origin);

      expect(isoPt.row, equals(2.0));
      expect(isoPt.col, equals(1.0));
    });
  });
}
