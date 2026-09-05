import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/localization/language_model.dart';
import 'package:galeriden/core/theme/app_theme.dart';
import 'package:galeriden/presentation/widgets/dialogs/showroom_construction_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestableApp({required Widget home}) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      locale: const Locale('tr'),
      supportedLocales: AppLanguage.values.map((e) => e.locale).toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );
  }

  testWidgets('ShowroomConstructionModal dismisses properly when Hurry button is pressed',
      (tester) async {
    bool isCompleted = false;

    await tester.pumpWidget(
      buildTestableApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ShowroomConstructionModal.show(
                    context,
                    title: 'Test İnşaat',
                    subtitle: 'Kadıköy Şube',
                    customDurationSeconds: 5,
                    onComplete: () {
                      isCompleted = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap button to open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ShowroomConstructionModal), findsOneWidget);
    expect(isCompleted, isFalse);

    // Find and tap the "Hemen Bitir" (construction_btn_hurry) button
    await tester.tap(find.text('Hemen Bitir'));
    await tester.pumpAndSettle();

    // Verify modal is completely dismissed and onComplete was executed
    expect(find.byType(ShowroomConstructionModal), findsNothing);
    expect(isCompleted, isTrue);
  });

  testWidgets('ShowroomConstructionModal dismisses properly when countdown finishes',
      (tester) async {
    bool isCompleted = false;

    await tester.pumpWidget(
      buildTestableApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ShowroomConstructionModal.show(
                    context,
                    title: 'Test İnşaat',
                    subtitle: 'Kadıköy Şube',
                    customDurationSeconds: 3,
                    onComplete: () {
                      isCompleted = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    // Open modal
    await tester.tap(find.text('Open Modal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ShowroomConstructionModal), findsOneWidget);
    expect(isCompleted, isFalse);

    // Fast-forward 4 seconds to let countdown finish
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Verify modal is closed and completed
    expect(find.byType(ShowroomConstructionModal), findsNothing);
    expect(isCompleted, isTrue);
  });

  testWidgets('ShowroomConstructionModal dismisses properly when close button is tapped',
      (tester) async {
    bool isCompleted = false;

    await tester.pumpWidget(
      buildTestableApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ShowroomConstructionModal.show(
                    context,
                    title: 'Test İnşaat',
                    subtitle: 'Kadıköy Şube',
                    customDurationSeconds: 10,
                    onComplete: () {
                      isCompleted = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Modal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ShowroomConstructionModal), findsOneWidget);
    expect(isCompleted, isFalse);

    // Tap close button (Icons.close_rounded)
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    // Verify modal is dismissed
    expect(find.byType(ShowroomConstructionModal), findsNothing);
    expect(isCompleted, isFalse);
  });

  testWidgets('ShowroomConstructionModal dismisses properly when barrier is tapped',
      (tester) async {
    bool isCompleted = false;

    await tester.pumpWidget(
      buildTestableApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ShowroomConstructionModal.show(
                    context,
                    title: 'Test İnşaat',
                    subtitle: 'Kadıköy Şube',
                    customDurationSeconds: 10,
                    onComplete: () {
                      isCompleted = true;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Modal'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(ShowroomConstructionModal), findsOneWidget);
    expect(isCompleted, isFalse);

    // Tap outside dialog bounds (e.g. top-left corner (10, 10))
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Verify modal is dismissed
    expect(find.byType(ShowroomConstructionModal), findsNothing);
    expect(isCompleted, isFalse);
  });
}
