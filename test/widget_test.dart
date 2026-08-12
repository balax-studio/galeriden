import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galerisinden/app/app.dart';

void main() {
  testWidgets('App renders onboarding screen on initial launch', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GalerisindenApp(),
      ),
    );

    expect(find.textContaining('Galerisinden'), findsWidgets);
  });
}
