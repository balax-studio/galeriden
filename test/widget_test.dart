import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/app/app.dart';

void main() {
  testWidgets('App renders onboarding screen on initial launch', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: GaleridenApp(),
      ),
    );

    expect(find.textContaining('Hasan Usta'), findsWidgets);
  });
}
