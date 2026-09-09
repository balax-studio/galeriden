import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/data/models/real_estate_category.dart';
import 'package:galeriden/data/models/vehicle_category.dart';
import 'package:galeriden/presentation/widgets/neo_brutal_listing_thumbnail.dart';

void main() {
  group('NeoBrutalListingThumbnail Tests', () {
    testWidgets('VasitaListingThumbnail renders for every VehicleCategory without error',
        (tester) async {
      for (final cat in VehicleCategory.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VasitaListingThumbnail(
                category: cat,
                bodyType: 'SUV',
                colorHex: '#FF0000',
                isDark: false,
              ),
            ),
          ),
        );

        expect(find.byType(VasitaListingThumbnail), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('VasitaListingThumbnail renders in dark mode without error',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VasitaListingThumbnail(
              category: VehicleCategory.motorcycle,
              isDark: true,
            ),
          ),
        ),
      );

      expect(find.byType(VasitaListingThumbnail), findsOneWidget);
    });

    testWidgets('RealEstateListingThumbnail renders for every RealEstateCategory without error',
        (tester) async {
      for (final cat in RealEstateCategory.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RealEstateListingThumbnail(
                category: cat,
                isDark: false,
              ),
            ),
          ),
        );

        expect(find.byType(RealEstateListingThumbnail), findsOneWidget);
        expect(find.byType(CustomPaint), findsWidgets);
      }
    });

    testWidgets('RealEstateListingThumbnail renders in dark mode without error',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RealEstateListingThumbnail(
              category: RealEstateCategory.housingProjects,
              isDark: true,
            ),
          ),
        ),
      );

      expect(find.byType(RealEstateListingThumbnail), findsOneWidget);
    });

    testWidgets('VasitaListingThumbnail renders multiple distinct seeds and colors properly',
        (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VasitaListingThumbnail(
                category: VehicleCategory.values[i % VehicleCategory.values.length],
                bodyType: 'Panelvan',
                colorHex: i % 2 == 0 ? '#2563EB' : '#10B981',
                seed: 'seed_variant_$i',
                isDark: i.isOdd,
              ),
            ),
          ),
        );

        expect(find.byType(VasitaListingThumbnail), findsOneWidget);
      }
    });

    testWidgets('RealEstateListingThumbnail renders multiple distinct seeds and specs properly',
        (tester) async {
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RealEstateListingThumbnail(
                category: RealEstateCategory.values[i % RealEstateCategory.values.length],
                seed: 're_listing_seed_$i',
                squareMeters: 120 + i * 50,
                roomCount: '${i + 1}+1',
                isDark: i.isEven,
              ),
            ),
          ),
        );

        expect(find.byType(RealEstateListingThumbnail), findsOneWidget);
      }
    });
  });
}
