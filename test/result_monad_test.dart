import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/utils/result.dart';

void main() {
  group('AAA+ Result Monad Test Suite', () {
    test('Success returns data and isSuccess is true', () {
      const result = Success<int>(42);
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.errorOrNull, isNull);

      final mapped = result.map((data) => 'Value: $data');
      expect(mapped.dataOrNull, 'Value: 42');
    });

    test('Failure returns message and isFailure is true', () {
      final result = Failure<int>('Network timeout');
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.errorOrNull, 'Network timeout');

      final folded = result.fold(
        onSuccess: (data) => 'Success: $data',
        onFailure: (msg, ex) => 'Failed with: $msg',
      );
      expect(folded, 'Failed with: Network timeout');
    });
  });
}
