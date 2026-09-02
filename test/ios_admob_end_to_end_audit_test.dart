import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:galeriden/core/services/ad_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('iOS AdMob End-to-End Architectural Audit Tests', () {
    test('1. Info.plist contains valid GADApplicationIdentifier and ATT Description', () {
      final plistFile = File('ios/Runner/Info.plist');
      expect(plistFile.existsSync(), isTrue, reason: 'ios/Runner/Info.plist must exist');

      final content = plistFile.readAsStringSync();

      // GADApplicationIdentifier check
      expect(content.contains('<key>GADApplicationIdentifier</key>'), isTrue);
      expect(content.contains('<string>ca-app-pub-2626843024156194~9733712295</string>'), isTrue);

      // ATT (NSUserTrackingUsageDescription) check
      expect(content.contains('<key>NSUserTrackingUsageDescription</key>'), isTrue);

      // SKAdNetworkItems check (Google AdMob SKAdNetwork)
      expect(content.contains('<key>SKAdNetworkItems</key>'), isTrue);
      expect(content.contains('<string>cstr6suwn9.skadnetwork</string>'), isTrue);
    });

    test('2. AdService IDs and production constants are well-formed', () {
      final adService = AdService.instance;
      expect(adService.rewardedAdUnitId, isNotEmpty);
      expect(adService.nativeAdUnitId, isNotEmpty);
      expect(adService.rewardedAdUnitId.startsWith('ca-app-pub-'), isTrue);
      expect(adService.nativeAdUnitId.startsWith('ca-app-pub-'), isTrue);
    });

    test('3. Native Ad creation produces valid template style and non-null instance', () {
      final adService = AdService.instance;
      final nativeAd = adService.createNativeAd(
        onAdLoaded: (_) {},
        onAdFailedToLoad: (_) {},
      );

      expect(nativeAd, isNotNull);
      expect(nativeAd.adUnitId, isNotEmpty);
      expect(nativeAd.nativeTemplateStyle, isNotNull);
      expect(nativeAd.nativeTemplateStyle?.mainBackgroundColor, equals(const Color(0xFF141721)));
    });

    test('4. Graceful Fallback Guarantee: Always calls onRewardEarned when ad is offline/unavailable', () {
      final adService = AdService.instance;
      bool rewardClaimed = false;

      adService.showRewardedAd(
        onRewardEarned: () {
          rewardClaimed = true;
        },
      );

      expect(rewardClaimed, isTrue);
    });
  });
}
