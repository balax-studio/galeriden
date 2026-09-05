import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_card.dart';

enum NativeAdContextType {
  marketplace,
  gossip,
  stockMarket,
}

class InGameSponsorSnippet {
  final String title;
  final String description;
  final String badgeText;
  final String actionText;
  final IconData icon;
  final Color accentColor;
  final String benefitToast;

  const InGameSponsorSnippet({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.actionText,
    required this.icon,
    required this.accentColor,
    required this.benefitToast,
  });
}

/// Neo-Brutalist Native Advanced Ad Container.
/// Displays an AdMob Native Ad when available, or seamlessly renders in-universe
/// automotive / trade lore cards if AdMob returns no fill or is offline.
///
/// Features:
/// 1. First 7 In-Game Days Protection: Completely closed during days 1-7 (returns SizedBox.shrink).
/// 2. Dynamic Pacing Algorithm: From day 8 onwards, activates on randomized in-game days
///    to provide a balanced, natural esnaf experience.
class NeoBrutalNativeAdCard extends ConsumerStatefulWidget {
  final NativeAdContextType contextType;
  final EdgeInsetsGeometry margin;

  const NeoBrutalNativeAdCard({
    super.key,
    this.contextType = NativeAdContextType.marketplace,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  ConsumerState<NeoBrutalNativeAdCard> createState() =>
      _NeoBrutalNativeAdCardState();
}

class _NeoBrutalNativeAdCardState extends ConsumerState<NeoBrutalNativeAdCard>
    with AutomaticKeepAliveClientMixin {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  late InGameSponsorSnippet _fallbackSnippet;
  int _lastDayEvaluated = -1;
  Timer? _debounceTimer;

  @override
  bool get wantKeepAlive => _isAdLoaded && _nativeAd != null;

  static final List<InGameSponsorSnippet> _marketplaceSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_detail_title',
      description: 'ad_native_detail_desc',
      badgeText: 'ad_native_sponsor_tag',
      actionText: 'ad_native_cta',
      icon: Icons.auto_fix_high_rounded,
      accentColor: AppColors.brutalYellow,
      benefitToast: 'ad_native_card_toast',
    ),
    const InGameSponsorSnippet(
      title: 'ad_native_towing_title',
      description: 'ad_native_towing_desc',
      badgeText: 'ad_native_towing_tag',
      actionText: 'ad_native_towing_cta',
      icon: Icons.local_shipping_rounded,
      accentColor: AppColors.brutalBlue,
      benefitToast: 'ad_native_towing_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _gossipSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_customs_title',
      description: 'ad_native_customs_desc',
      badgeText: 'ad_native_customs_tag',
      actionText: 'ad_native_customs_cta',
      icon: Icons.newspaper_rounded,
      accentColor: Color(0xFFA855F7),
      benefitToast: 'ad_native_customs_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _stockSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_stock_title',
      description: 'ad_native_stock_desc',
      badgeText: 'ad_native_stock_tag',
      actionText: 'ad_native_stock_cta',
      icon: Icons.trending_up_rounded,
      accentColor: AppColors.successGreen,
      benefitToast: 'ad_native_stock_toast',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pickFallbackSnippet();
  }

  void _pickFallbackSnippet() {
    final random = Random();
    switch (widget.contextType) {
      case NativeAdContextType.marketplace:
        _fallbackSnippet =
            _marketplaceSnippets[random.nextInt(_marketplaceSnippets.length)];
        break;
      case NativeAdContextType.gossip:
        _fallbackSnippet =
            _gossipSnippets[random.nextInt(_gossipSnippets.length)];
        break;
      case NativeAdContextType.stockMarket:
        _fallbackSnippet =
            _stockSnippets[random.nextInt(_stockSnippets.length)];
        break;
    }
  }

  void _evaluateAdLoading(int currentDay) {
    if (_lastDayEvaluated == currentDay) return;
    _lastDayEvaluated = currentDay;

    final bool shouldShow =
        AdService.shouldShowNativeAdForDay(currentDay, widget.contextType);
    if (!shouldShow) {
      _cancelDebounce();
      if (_nativeAd != null) {
        _nativeAd?.dispose();
        _nativeAd = null;
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
            _isAdLoading = false;
          });
          updateKeepAlive();
        }
      }
      return;
    }

    if (_nativeAd == null && !_isAdLoaded && !_isAdLoading) {
      if (!AdService.instance.canRequestNativeAd) {
        return; // Retains lore sponsor fallback, avoiding unviewed ad requests
      }
      _scheduleDebouncedLoad();
    }
  }

  void _scheduleDebouncedLoad() {
    _cancelDebounce();
    // 650ms debounce prevents rapid scrolling from firing requests that are immediately disposed
    _debounceTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted && _nativeAd == null && !_isAdLoaded && !_isAdLoading) {
        if (AdService.instance.canRequestNativeAd) {
          _loadNativeAd();
        }
      }
    });
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void _loadNativeAd() {
    if (kIsWeb || _isAdLoading || _nativeAd != null || !AdService.instance.canRequestNativeAd) {
      return;
    }

    AdService.instance.markNativeAdRequested();
    _isAdLoading = true;
    _nativeAd = AdService.instance.createNativeAd(
      onAdLoaded: (ad) {
        if (!mounted) {
          ad.dispose();
          return;
        }
        setState(() {
          _isAdLoaded = true;
          _isAdLoading = false;
        });
        updateKeepAlive();
      },
      onAdFailedToLoad: (error) {
        if (!mounted) return;
        debugPrint(
            '[NeoBrutalNativeAdCard] Ad failed to load: ${error.message}. Switching to in-game lore sponsor.');
        setState(() {
          _isAdLoaded = false;
          _isAdLoading = false;
          _nativeAd = null;
        });
      },
    );

    _nativeAd?.load();
  }

  @override
  void dispose() {
    _cancelDebounce();
    _nativeAd?.dispose();
    _nativeAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentDay = ref.watch(gameProvider.select((g) => g.currentDay));
    final shouldShow =
        AdService.shouldShowNativeAdForDay(currentDay, widget.contextType);

    _evaluateAdLoading(currentDay);

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isAdLoaded && _nativeAd != null) {
      return Container(
        margin: widget.margin,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141721) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black : const Color(0xFF0F172A),
              offset: const Offset(3.5, 3.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 320,
              minHeight: 320,
              maxHeight: 360,
            ),
            child: AdWidget(ad: _nativeAd!),
          ),
        ),
      );
    }

    // In-game lore fallback card
    return Container(
      margin: widget.margin,
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor:
            isDark ? const Color(0xFF131722) : const Color(0xFFFAF9F6),
        borderColor: _fallbackSnippet.accentColor,
        borderWidth: 2.5,
        borderRadius: 12,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: NeoBrutalBadge(
                    text:
                        _resolveLocalized(context, _fallbackSnippet.badgeText),
                    icon: _fallbackSnippet.icon,
                    backgroundColor: _fallbackSnippet.accentColor,
                    textColor: Colors.black,
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalBadge(
                  text: context.tr('ad_native_local_bulletin'),
                  backgroundColor: isDark
                      ? const Color(0xFF1F2432)
                      : const Color(0xFFE2E8F0),
                  textColor: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              _resolveLocalized(context, _fallbackSnippet.title),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _resolveLocalized(context, _fallbackSnippet.description),
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
                color:
                    isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    NotificationService.showSuccess(
                        context,
                        _resolveLocalized(
                            context, _fallbackSnippet.benefitToast));
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _fallbackSnippet.accentColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _resolveLocalized(
                              context, _fallbackSnippet.actionText),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.black, size: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _resolveLocalized(BuildContext context, String val) {
    if (val.startsWith('ad_')) {
      return context.tr(val);
    }
    return val;
  }
}
