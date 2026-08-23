import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:galeriden/data/models/dealership_model.dart';
import 'package:galeriden/presentation/providers/game_provider.dart';
import 'package:galeriden/presentation/widgets/dealership_logo_badge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Dealership Identity Customization Tests', () {
    test('DealershipModel initial values and copyWith for identity customization', () {
      final initial = DealershipModel.initial();
      expect(initial.logoEmblemId, 'crown');
      expect(initial.logoBadgeShape, 'square');
      expect(initial.logoBadgeColor, 'yellow');
      expect(initial.dealershipTagline, 'Güvenin ve Kalitenin Adresi');

      final updated = initial.copyWith(
        logoEmblemId: 'bull',
        logoBadgeShape: 'shield',
        logoBadgeColor: 'red',
        dealershipTagline: 'Piyasanın Nabzı • Zirve Galeri',
      );

      expect(updated.logoEmblemId, 'bull');
      expect(updated.logoBadgeShape, 'shield');
      expect(updated.logoBadgeColor, 'red');
      expect(updated.dealershipTagline, 'Piyasanın Nabzı • Zirve Galeri');
    });

    test('DealershipModel JSON serialization preserves identity customization', () {
      final model = DealershipModel.initial().copyWith(
        playerName: 'Mehmet Usta',
        dealershipName: 'Yıldız Otomotiv',
        logoEmblemId: 'cobra',
        logoBadgeShape: 'hexagon',
        logoBadgeColor: 'cyan',
        dealershipTagline: 'Dürüst Esnaf • Hızlı Noter',
      );

      final json = model.toJson();
      final fromJson = DealershipModel.fromJson(json);

      expect(fromJson.playerName, 'Mehmet Usta');
      expect(fromJson.dealershipName, 'Yıldız Otomotiv');
      expect(fromJson.logoEmblemId, 'cobra');
      expect(fromJson.logoBadgeShape, 'hexagon');
      expect(fromJson.logoBadgeColor, 'cyan');
      expect(fromJson.dealershipTagline, 'Dürüst Esnaf • Hızlı Noter');
    });

    test('DealershipLogoBadge color helper returns correct brand palettes', () {
      expect(DealershipLogoBadge.getBackgroundColor('yellow'), const Color(0xFFFFDE59));
      expect(DealershipLogoBadge.getBackgroundColor('blue'), const Color(0xFF3B82F6));
      expect(DealershipLogoBadge.getBackgroundColor('red'), const Color(0xFFEF4444));
      expect(DealershipLogoBadge.getBackgroundColor('green'), const Color(0xFF10B981));
      expect(DealershipLogoBadge.getBackgroundColor('purple'), const Color(0xFFA855F7));
      expect(DealershipLogoBadge.getBackgroundColor('dark'), const Color(0xFF1E293B));
      expect(DealershipLogoBadge.getBackgroundColor('cyan'), const Color(0xFF06B6D4));
      expect(DealershipLogoBadge.getBackgroundColor('orange'), const Color(0xFFF97316));
    });

    test('GameCoreNotifier.updateDealershipIdentity updates state and identity fields', () {
      final container = ProviderContainer();
      addTearDown(() {
        container.read(gameProvider.notifier).stopPeriodicOrganicOfferTimer();
        container.dispose();
      });

      final notifier = container.read(gameProvider.notifier);
      notifier.updateDealershipIdentity(
        playerName: 'Ali Kaptan',
        dealershipName: 'Prestij Motors',
        logoEmblemId: 'lion',
        logoBadgeShape: 'laurel',
        logoBadgeColor: 'purple',
        dealershipTagline: 'Güvenin ve Kalitenin Adresi',
        characterOrigin: CharacterOrigin.tuccarTorunu,
      );

      final state = container.read(gameProvider);
      expect(state.playerName, 'Ali Kaptan');
      expect(state.dealershipName, 'Prestij Motors');
      expect(state.logoEmblemId, 'lion');
      expect(state.logoBadgeShape, 'laurel');
      expect(state.logoBadgeColor, 'purple');
      expect(state.dealershipTagline, 'Güvenin ve Kalitenin Adresi');
      expect(state.characterOrigin, CharacterOrigin.tuccarTorunu);
    });
  });
}
