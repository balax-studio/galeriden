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
  realEstate,
  expertise,
  scrapyard,
  carWash,
  finance,
  workshop,
  staff,
  rentACar,
  sideBusiness,
  reviews,
  salesHistory,
  consignment,
  branch,
  album,
  blackMarket,
  character,
  auction,
  specialPlate,
  offerEvaluation,
  mediaAgency,
  staffAcademy,
  showroomDecor,
  bankInvestments,
  district,
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
  bool get wantKeepAlive => true;

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
    const InGameSponsorSnippet(
      title: 'ad_native_engine_title',
      description: 'ad_native_engine_desc',
      badgeText: 'ad_native_engine_tag',
      actionText: 'ad_native_engine_cta',
      icon: Icons.build_circle_rounded,
      accentColor: Color(0xFFF97316),
      benefitToast: 'ad_native_engine_toast',
    ),
    const InGameSponsorSnippet(
      title: 'ad_native_parts_title',
      description: 'ad_native_parts_desc',
      badgeText: 'ad_native_parts_tag',
      actionText: 'ad_native_parts_cta',
      icon: Icons.inventory_rounded,
      accentColor: Color(0xFF06B6D4),
      benefitToast: 'ad_native_parts_toast',
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

  static final List<InGameSponsorSnippet> _realEstateSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_deed_title',
      description: 'ad_native_deed_desc',
      badgeText: 'ad_native_deed_tag',
      actionText: 'ad_native_deed_cta',
      icon: Icons.assignment_turned_in_rounded,
      accentColor: Color(0xFFF59E0B),
      benefitToast: 'ad_native_deed_toast',
    ),
    const InGameSponsorSnippet(
      title: 'ad_native_inspection_title',
      description: 'ad_native_inspection_desc',
      badgeText: 'ad_native_inspection_tag',
      actionText: 'ad_native_inspection_cta',
      icon: Icons.foundation_rounded,
      accentColor: Color(0xFF0EA5E9),
      benefitToast: 'ad_native_inspection_toast',
    ),
    const InGameSponsorSnippet(
      title: 'ad_native_marble_title',
      description: 'ad_native_marble_desc',
      badgeText: 'ad_native_marble_tag',
      actionText: 'ad_native_marble_cta',
      icon: Icons.countertops_rounded,
      accentColor: Color(0xFF10B981),
      benefitToast: 'ad_native_marble_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _expertiseSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_dyno_title',
      description: 'ad_native_dyno_desc',
      badgeText: 'ad_native_dyno_tag',
      actionText: 'ad_native_dyno_cta',
      icon: Icons.speed_rounded,
      accentColor: Color(0xFF38BDF8),
      benefitToast: 'ad_native_dyno_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _scrapyardSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_salvage_title',
      description: 'ad_native_salvage_desc',
      badgeText: 'ad_native_salvage_tag',
      actionText: 'ad_native_salvage_cta',
      icon: Icons.car_crash_rounded,
      accentColor: Color(0xFFF97316),
      benefitToast: 'ad_native_salvage_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _carWashSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_detailing_title',
      description: 'ad_native_detailing_desc',
      badgeText: 'ad_native_detailing_tag',
      actionText: 'ad_native_detailing_cta',
      icon: Icons.local_car_wash_rounded,
      accentColor: Color(0xFF06B6D4),
      benefitToast: 'ad_native_detailing_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _financeSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_credit_title',
      description: 'ad_native_credit_desc',
      badgeText: 'ad_native_credit_tag',
      actionText: 'ad_native_credit_cta',
      icon: Icons.account_balance_rounded,
      accentColor: Color(0xFF10B981),
      benefitToast: 'ad_native_credit_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _workshopSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_workshop_title',
      description: 'ad_native_workshop_desc',
      badgeText: 'ad_native_workshop_tag',
      actionText: 'ad_native_workshop_cta',
      icon: Icons.precision_manufacturing_rounded,
      accentColor: Color(0xFFEF4444),
      benefitToast: 'ad_native_workshop_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _staffSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_staff_title',
      description: 'ad_native_staff_desc',
      badgeText: 'ad_native_staff_tag',
      actionText: 'ad_native_staff_cta',
      icon: Icons.badge_rounded,
      accentColor: Color(0xFF3B82F6),
      benefitToast: 'ad_native_staff_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _rentACarSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_rental_title',
      description: 'ad_native_rental_desc',
      badgeText: 'ad_native_rental_tag',
      actionText: 'ad_native_rental_cta',
      icon: Icons.car_rental_rounded,
      accentColor: Color(0xFF8B5CF6),
      benefitToast: 'ad_native_rental_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _sideBusinessSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_business_title',
      description: 'ad_native_business_desc',
      badgeText: 'ad_native_business_tag',
      actionText: 'ad_native_business_cta',
      icon: Icons.ev_station_rounded,
      accentColor: Color(0xFFF59E0B),
      benefitToast: 'ad_native_business_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _reviewsSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_review_title',
      description: 'ad_native_review_desc',
      badgeText: 'ad_native_review_tag',
      actionText: 'ad_native_review_cta',
      icon: Icons.rate_review_rounded,
      accentColor: Color(0xFF10B981),
      benefitToast: 'ad_native_review_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _salesHistorySnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_ledger_title',
      description: 'ad_native_ledger_desc',
      badgeText: 'ad_native_ledger_tag',
      actionText: 'ad_native_ledger_cta',
      icon: Icons.receipt_long_rounded,
      accentColor: Color(0xFF64748B),
      benefitToast: 'ad_native_ledger_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _consignmentSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_consignment_title',
      description: 'ad_native_consignment_desc',
      badgeText: 'ad_native_consignment_tag',
      actionText: 'ad_native_consignment_cta',
      icon: Icons.handshake_rounded,
      accentColor: AppColors.brutalGreen,
      benefitToast: 'ad_native_consignment_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _branchSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_branch_title',
      description: 'ad_native_branch_desc',
      badgeText: 'ad_native_branch_tag',
      actionText: 'ad_native_branch_cta',
      icon: Icons.domain_rounded,
      accentColor: Color(0xFF6366F1),
      benefitToast: 'ad_native_branch_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _albumSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_album_title',
      description: 'ad_native_album_desc',
      badgeText: 'ad_native_album_tag',
      actionText: 'ad_native_album_cta',
      icon: Icons.auto_stories_rounded,
      accentColor: AppColors.brutalYellow,
      benefitToast: 'ad_native_album_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _blackMarketSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_bm_title',
      description: 'ad_native_bm_desc',
      badgeText: 'ad_native_bm_tag',
      actionText: 'ad_native_bm_cta',
      icon: Icons.anchor_rounded,
      accentColor: Color(0xFFEF4444),
      benefitToast: 'ad_native_bm_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _characterSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_character_title',
      description: 'ad_native_character_desc',
      badgeText: 'ad_native_character_tag',
      actionText: 'ad_native_character_cta',
      icon: Icons.military_tech_rounded,
      accentColor: Color(0xFFA855F7),
      benefitToast: 'ad_native_character_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _auctionSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_auction_title',
      description: 'ad_native_auction_desc',
      badgeText: 'ad_native_auction_tag',
      actionText: 'ad_native_auction_cta',
      icon: Icons.gavel_rounded,
      accentColor: Color(0xFF38BDF8),
      benefitToast: 'ad_native_auction_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _specialPlateSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_plate_title',
      description: 'ad_native_plate_desc',
      badgeText: 'ad_native_plate_tag',
      actionText: 'ad_native_plate_cta',
      icon: Icons.badge_rounded,
      accentColor: Color(0xFFFFDE59),
      benefitToast: 'ad_native_plate_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _offerEvaluationSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_offer_title',
      description: 'ad_native_offer_desc',
      badgeText: 'ad_native_offer_tag',
      actionText: 'ad_native_offer_cta',
      icon: Icons.price_check_rounded,
      accentColor: Color(0xFF10B981),
      benefitToast: 'ad_native_offer_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _mediaAgencySnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_media_title',
      description: 'ad_native_media_desc',
      badgeText: 'ad_native_media_tag',
      actionText: 'ad_native_media_cta',
      icon: Icons.campaign_rounded,
      accentColor: Color(0xFF0284C7),
      benefitToast: 'ad_native_media_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _staffAcademySnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_academy_title',
      description: 'ad_native_academy_desc',
      badgeText: 'ad_native_academy_tag',
      actionText: 'ad_native_academy_cta',
      icon: Icons.school_rounded,
      accentColor: Color(0xFFA855F7),
      benefitToast: 'ad_native_academy_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _showroomDecorSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_decor_title',
      description: 'ad_native_decor_desc',
      badgeText: 'ad_native_decor_tag',
      actionText: 'ad_native_decor_cta',
      icon: Icons.architecture_rounded,
      accentColor: Color(0xFF06B6D4),
      benefitToast: 'ad_native_decor_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _bankInvestmentsSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_bank_title',
      description: 'ad_native_bank_desc',
      badgeText: 'ad_native_bank_tag',
      actionText: 'ad_native_bank_cta',
      icon: Icons.savings_rounded,
      accentColor: Color(0xFF10B981),
      benefitToast: 'ad_native_bank_toast',
    ),
  ];

  static final List<InGameSponsorSnippet> _districtSnippets = [
    const InGameSponsorSnippet(
      title: 'ad_native_district_title',
      description: 'ad_native_district_desc',
      badgeText: 'ad_native_district_tag',
      actionText: 'ad_native_district_cta',
      icon: Icons.location_city_rounded,
      accentColor: Color(0xFF3B82F6),
      benefitToast: 'ad_native_district_toast',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pickFallbackSnippet();
    AdService.instance.addListener(_onAdServiceChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final currentDay = ref.read(gameProvider).currentDay;
        if (AdService.shouldShowNativeAdForDay(currentDay, widget.contextType)) {
          if (!kIsWeb && !AdService.instance.hasPreloadedNativeAd) {
            AdService.instance.preloadNativeAd();
          }
        }
      }
    });
  }

  void _onAdServiceChanged() {
    if (!mounted || kIsWeb || _isAdLoaded) return;
    final currentDay = ref.read(gameProvider).currentDay;
    if (!AdService.shouldShowNativeAdForDay(currentDay, widget.contextType)) return;

    // Invariant: Background/covered routes must NOT consume preloaded pool ads from the foreground screen
    final route = ModalRoute.of(context);
    final bool isRouteActive = route == null || route.isCurrent;
    if (!isRouteActive) return;

    if (AdService.instance.hasPreloadedNativeAd) {
      final cachedAd = AdService.instance.consumePreloadedNativeAd();
      if (cachedAd != null) {
        _cancelDebounce();
        if (_nativeAd != null && !_isAdLoaded) {
          _nativeAd?.dispose();
        }
        setState(() {
          _nativeAd = cachedAd;
          _isAdLoaded = true;
          _isAdLoading = false;
        });
        updateKeepAlive();
      }
    }
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
      case NativeAdContextType.realEstate:
        _fallbackSnippet =
            _realEstateSnippets[random.nextInt(_realEstateSnippets.length)];
        break;
      case NativeAdContextType.expertise:
        _fallbackSnippet =
            _expertiseSnippets[random.nextInt(_expertiseSnippets.length)];
        break;
      case NativeAdContextType.scrapyard:
        _fallbackSnippet =
            _scrapyardSnippets[random.nextInt(_scrapyardSnippets.length)];
        break;
      case NativeAdContextType.carWash:
        _fallbackSnippet =
            _carWashSnippets[random.nextInt(_carWashSnippets.length)];
        break;
      case NativeAdContextType.finance:
        _fallbackSnippet =
            _financeSnippets[random.nextInt(_financeSnippets.length)];
        break;
      case NativeAdContextType.workshop:
        _fallbackSnippet =
            _workshopSnippets[random.nextInt(_workshopSnippets.length)];
        break;
      case NativeAdContextType.staff:
        _fallbackSnippet =
            _staffSnippets[random.nextInt(_staffSnippets.length)];
        break;
      case NativeAdContextType.rentACar:
        _fallbackSnippet =
            _rentACarSnippets[random.nextInt(_rentACarSnippets.length)];
        break;
      case NativeAdContextType.sideBusiness:
        _fallbackSnippet =
            _sideBusinessSnippets[random.nextInt(_sideBusinessSnippets.length)];
        break;
      case NativeAdContextType.reviews:
        _fallbackSnippet =
            _reviewsSnippets[random.nextInt(_reviewsSnippets.length)];
        break;
      case NativeAdContextType.salesHistory:
        _fallbackSnippet =
            _salesHistorySnippets[random.nextInt(_salesHistorySnippets.length)];
        break;
      case NativeAdContextType.consignment:
        _fallbackSnippet =
            _consignmentSnippets[random.nextInt(_consignmentSnippets.length)];
        break;
      case NativeAdContextType.branch:
        _fallbackSnippet =
            _branchSnippets[random.nextInt(_branchSnippets.length)];
        break;
      case NativeAdContextType.album:
        _fallbackSnippet =
            _albumSnippets[random.nextInt(_albumSnippets.length)];
        break;
      case NativeAdContextType.blackMarket:
        _fallbackSnippet =
            _blackMarketSnippets[random.nextInt(_blackMarketSnippets.length)];
        break;
      case NativeAdContextType.character:
        _fallbackSnippet =
            _characterSnippets[random.nextInt(_characterSnippets.length)];
        break;
      case NativeAdContextType.auction:
        _fallbackSnippet =
            _auctionSnippets[random.nextInt(_auctionSnippets.length)];
        break;
      case NativeAdContextType.specialPlate:
        _fallbackSnippet =
            _specialPlateSnippets[random.nextInt(_specialPlateSnippets.length)];
        break;
      case NativeAdContextType.offerEvaluation:
        _fallbackSnippet =
            _offerEvaluationSnippets[random.nextInt(_offerEvaluationSnippets.length)];
        break;
      case NativeAdContextType.mediaAgency:
        _fallbackSnippet =
            _mediaAgencySnippets[random.nextInt(_mediaAgencySnippets.length)];
        break;
      case NativeAdContextType.staffAcademy:
        _fallbackSnippet =
            _staffAcademySnippets[random.nextInt(_staffAcademySnippets.length)];
        break;
      case NativeAdContextType.showroomDecor:
        _fallbackSnippet =
            _showroomDecorSnippets[random.nextInt(_showroomDecorSnippets.length)];
        break;
      case NativeAdContextType.bankInvestments:
        _fallbackSnippet =
            _bankInvestmentsSnippets[random.nextInt(_bankInvestmentsSnippets.length)];
        break;
      case NativeAdContextType.district:
        _fallbackSnippet =
            _districtSnippets[random.nextInt(_districtSnippets.length)];
        break;
    }
  }

  void _evaluateAdLoading(int currentDay) {
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

    if (_lastDayEvaluated == currentDay && (_nativeAd != null || _isAdLoading)) return;
    _lastDayEvaluated = currentDay;

    if (_nativeAd == null && !_isAdLoaded && !_isAdLoading) {
      // 1. Instant Cache Pool Check: If a warm preloaded native ad is ready, consume immediately!
      if (!kIsWeb && AdService.instance.hasPreloadedNativeAd) {
        final cachedAd = AdService.instance.consumePreloadedNativeAd();
        if (cachedAd != null) {
          _cancelDebounce();
          _nativeAd = cachedAd;
          _isAdLoaded = true;
          _isAdLoading = false;
          updateKeepAlive();
          return;
        }
      }

      // 2. Proactively trigger background preload if pool is currently empty
      if (!kIsWeb &&
          !AdService.instance.hasPreloadedNativeAd &&
          !AdService.instance.isPreloadingNativeAd) {
        AdService.instance.preloadNativeAd();
      }

      // 3. Fallback debounced load if card dwells in viewport
      _scheduleDebouncedLoad();
    }
  }

  void _scheduleDebouncedLoad() {
    _cancelDebounce();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _nativeAd == null && !_isAdLoaded && !_isAdLoading) {
        _loadNativeAd();
      }
    });
  }

  void _cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void _loadNativeAd() {
    if (kIsWeb || _isAdLoading || _nativeAd != null || _isAdLoaded) {
      return;
    }

    // Check pool one more time before deciding next action
    if (AdService.instance.hasPreloadedNativeAd) {
      final cachedAd = AdService.instance.consumePreloadedNativeAd();
      if (cachedAd != null) {
        setState(() {
          _nativeAd = cachedAd;
          _isAdLoaded = true;
          _isAdLoading = false;
        });
        updateKeepAlive();
        return;
      }
    }

    // If pool is currently preloading an ad, wait for _onAdServiceChanged to deliver it
    if (AdService.instance.isPreloadingNativeAd) {
      return;
    }

    // If pool is idle and has no ads, kick off preload
    if (!AdService.instance.hasPreloadedNativeAd) {
      AdService.instance.preloadNativeAd();
    }
  }

  @override
  void dispose() {
    AdService.instance.removeListener(_onAdServiceChanged);
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
