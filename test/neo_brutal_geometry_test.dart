import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/screens/dashboard/widgets/financial_health_card.dart';
import 'package:galeriden/presentation/widgets/dealership_logo_badge.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_card.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_empty_state.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_locked_feature_view.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_skeleton.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithMaterial(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('tr'), Locale('en')],
        locale: const Locale('tr'),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('Neo-Brutalist Geometry & Squircle Verification Tests', () {
    testWidgets('DealershipLogoBadge circle shape renders as 8px squircle badge',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const DealershipLogoBadge(
            badgeShape: 'circle',
            emblemId: 'car',
            badgeColor: 'yellow',
            size: 48,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      bool foundSquircle = false;
      for (final element in containerFinder.evaluate()) {
        final container = element.widget as Container;
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.borderRadius != null) {
          final br = decoration.borderRadius as BorderRadius;
          if (br.topLeft.x == 8.0) {
            foundSquircle = true;
            expect(decoration.shape, BoxShape.rectangle);
            break;
          }
        }
      }
      expect(foundSquircle, isTrue);
    });

    testWidgets('FinancialHealthCard uses <= 10px card and 8px squircle grade badge',
        (tester) async {
      final dealership = DealershipModel.initial();
      await tester.pumpWidget(
        wrapWithMaterial(
          FinancialHealthCard(
            dealership: dealership,
            onSiftahTapped: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardFinder = find.byType(NeoBrutalCard);
      expect(cardFinder, findsWidgets);
      final card = tester.widget<NeoBrutalCard>(cardFinder.first);
      expect(card.borderRadius, lessThanOrEqualTo(10.0));

      final textFinder = find.text('A');
      expect(textFinder, findsOneWidget);

      final containerFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(Container),
      );
      expect(containerFinder, findsWidgets);

      final gradeContainer = tester.widget<Container>(containerFinder.first);
      final decoration = gradeContainer.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.rectangle);
      expect(decoration.borderRadius, BorderRadius.circular(8.0));
    });

    testWidgets('NeoBrutalEmptyState frame is 10px and icon box is 8px',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const NeoBrutalEmptyState(
            title: 'HİÇBİR ŞEY YOK',
            description: 'Buralar tertemiz usta',
            icon: Icons.inventory_2_rounded,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      bool foundFrame10 = false;
      bool foundIconBox8 = false;

      for (final c in containers) {
        final d = c.decoration;
        if (d is BoxDecoration && d.borderRadius != null) {
          final br = d.borderRadius as BorderRadius;
          if (br.topLeft.x == 10.0) {
            foundFrame10 = true;
          }
          if (br.topLeft.x == 8.0) {
            foundIconBox8 = true;
          }
        }
      }

      expect(foundFrame10, isTrue);
      expect(foundIconBox8, isTrue);
    });

    testWidgets('NeoBrutalLockedFeatureView uses 10px card and 10px squircle lock box',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const NeoBrutalLockedFeatureView(
            route: '/auction',
            featureTitle: 'KİLİTLİ ALAN',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final lockIcon = find.byIcon(Icons.lock_outline_rounded);
      expect(lockIcon, findsOneWidget);

      final lockContainer = tester.widget<Container>(
        find.ancestor(of: lockIcon, matching: find.byType(Container)).first,
      );
      final dec = lockContainer.decoration as BoxDecoration;
      expect(dec.shape, BoxShape.rectangle);
      expect(dec.borderRadius, BorderRadius.circular(10.0));
    });

    testWidgets('NeoBrutalSkeletonBox renders squircle when isCircle is requested',
        (tester) async {
      await tester.pumpWidget(
        wrapWithMaterial(
          const NeoBrutalSkeletonBox(
            width: 40,
            height: 40,
            isCircle: true,
          ),
        ),
      );
      await tester.pump();

      final containerFinder = find.byType(Container);
      expect(containerFinder, findsWidgets);

      final skeletonContainer = tester.widget<Container>(containerFinder.first);
      final dec = skeletonContainer.decoration as BoxDecoration;
      expect(dec.shape, BoxShape.rectangle);
      expect(dec.borderRadius, BorderRadius.circular(8.0));
    });
  });
}
