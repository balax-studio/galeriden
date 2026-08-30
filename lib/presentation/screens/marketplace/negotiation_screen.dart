import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/first_time_action_keys.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../data/models/notary_event_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/negotiation_suspense_engine.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/dialogs/notary_transfer_dialog.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_segmented_gauge.dart';
import '../../widgets/neo_brutal_slider.dart';
import '../../widgets/pulsing_dot.dart';

/// Full-Page Dedicated "Pazarlık Masası" (Live Deal Room Screen)
/// High-performance, zero-frame-drop dedicated route replacing cramped bottom sheets.
class NegotiationScreen extends ConsumerStatefulWidget {
  final ListingModel listing;

  const NegotiationScreen({
    super.key,
    required this.listing,
  });

  @override
  ConsumerState<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends ConsumerState<NegotiationScreen> {
  late double _offeredPrice;
  double? _agreedFinalPrice;
  String? _sellerResponse;
  bool _isAccepted = false;
  bool _isProcessing = false;
  bool _isThinking = false;
  String _thinkingText = '';
  int _counterOfferCount = 0;
  bool _isNearMiss = false;
  bool _isLockedOut = false;
  bool _hasRescuedWithTea = false;
  late CustomerModel _customer;
  late String _fomoText;
  int _bonusChancePercent = 0;
  late List<EsnafTactic> _dynamicTactics;
  final Set<String> _usedTacticIds = {};
  int _tacticUsageCount = 0;
  TacticRollOutcome? _lastTacticOutcome;
  bool _hasUsedHonestDiscount = false;

  @override
  void initState() {
    super.initState();
    AdService.instance.loadRewardedAd();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _customer =
        CustomerModel.generateSellerFromListing(widget.listing.sellerName);
    _fomoText = PsychologyEngine.getRandomFomoText();
    _dynamicTactics = NegotiationEngine.generateTactics(
      isBuying: true,
      car: widget.listing.car,
      customer: _customer,
      price: widget.listing.askingPrice,
    );
  }

  int _calculateSuccessChance(int negotiationSkillLevel,
      {double decorBonusPercent = 0.0}) {
    final baseChance = NegotiationEngine.calculateMarketplaceBuyerSuccessChance(
      askingPrice: widget.listing.askingPrice,
      offeredPrice: _offeredPrice,
      negotiationSkillLevel: negotiationSkillLevel,
    );
    return (baseChance + _bonusChancePercent + decorBonusPercent.toInt())
        .clamp(5, 95);
  }

  void _snapToDiscount(double asking, double discountPercent) {
    if (_isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _offeredPrice = (asking * (1.0 - discountPercent)).roundToDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final listings = ref.watch(marketProvider);
    final currentListing = listings.firstWhere(
      (l) => l.id == widget.listing.id,
      orElse: () => widget.listing,
    );

    final asking = currentListing.askingPrice;
    final car = currentListing.car;

    final decorBonus = game.negotiationPersuasionBonusPercent;
    final chancePercent = _calculateSuccessChance(game.skills.negotiationLevel,
        decorBonusPercent: decorBonus);
    final discountAmount = asking - _offeredPrice;
    final discountRatio = ((discountAmount / asking) * 100).toStringAsFixed(1);

    Color chanceColor;
    if (chancePercent >= 70) {
      chanceColor = const Color(0xFF00E575);
    } else if (chancePercent >= 40) {
      chanceColor = const Color(0xFFFFDE59);
    } else {
      chanceColor = const Color(0xFFFF54B0);
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141721) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  width: 2.5,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black : const Color(0xFF0F172A),
                  offset: const Offset(0, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                NeoBrutalCard(
                  padding: EdgeInsets.zero,
                  borderWidth: 2,
                  borderRadius: 8,
                  shadowOffset: const Offset(2, 2),
                  backgroundColor: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFF1F5F9),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/marketplace');
                    }
                  },
                  child: SizedBox(
                    width: 38,
                    height: 38,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),

                // Center Title & Protocol Badge
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const NeoBrutalBadge(
                          text: 'PROTOKOL #PZ-884',
                          backgroundColor: Color(0xFFFFDE59),
                          textColor: Colors.black,
                          borderWidth: 1.2,
                          fontSize: 8,
                          padding:
                              EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        ),
                        const SizedBox(width: 4),
                        NeoBrutalBadge(
                          text: context.tr('deal_live_badge'),
                          backgroundColor: const Color(0xFF38BDF8),
                          textColor: Colors.black,
                          borderWidth: 1.2,
                          fontSize: 8,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('deal_negotiation_table'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),

                // Balance Badge
                NeoBrutalBadge(
                  icon: Icons.account_balance_wallet_rounded,
                  text: CurrencyFormatter.formatShort(game.balance),
                  backgroundColor: const Color(0xFF00E575),
                  textColor: Colors.black,
                  borderWidth: 1.8,
                  fontSize: 11,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              16, 14, 16, 24 + MediaQuery.paddingOf(context).bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Seller Dossier & Archetype Card
              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor:
                    isDark ? const Color(0xFF161922) : const Color(0xFFFEFCE8),
                borderColor: const Color(0xFFFFDE59),
                borderWidth: 2,
                borderRadius: 12,
                shadowOffset: const Offset(3, 3),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDE59),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 1.8,
                        ),
                      ),
                      child: Center(
                        child: VectorIconWidget(
                          type: _customer.avatarType,
                          color: Colors.black,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _customer.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              NeoBrutalBadge(
                                text: _customer.archetypeTitle,
                                backgroundColor: const Color(0xFF3B82F6),
                                textColor: Colors.white,
                                fontSize: 9.5,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _customer.personalityDescription,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Vehicle Target & Live Rights Battery Card
              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderWidth: 2,
                borderRadius: 12,
                shadowOffset: const Offset(3, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFDE59),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isDark
                                            ? const Color(0xFF333B4F)
                                            : const Color(0xFF0F172A),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      '${car.modelYear}',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${car.brand} ${car.modelName}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${currentListing.getLocalizedSellerCity(context)} • ${context.tr('listing_plate')}: ${car.plateNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              context.tr('negotiation_seller_asking_price'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(asking),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? const Color(0xFFFFDE59)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // FOMO badge & Remaining Rights Counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded,
                                    size: 14, color: Color(0xFFFF7A00)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _fomoText,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFFF7A00),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // 3-Block Battery Rights Counter
                          Row(
                            children: [
                              Text(
                                context.tr('negotiation_bargaining_label'),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 5),
                              ...List.generate(3, (index) {
                                final isRemaining =
                                    index < (3 - _counterOfferCount);
                                return Container(
                                  margin: const EdgeInsets.only(left: 2.5),
                                  width: 10,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isRemaining
                                        ? const Color(0xFFFFDE59)
                                        : (isDark
                                            ? const Color(0xFF2A3142)
                                            : const Color(0xFFCBD5E1)),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: isDark
                                          ? const Color(0xFF333B4F)
                                          : const Color(0xFF0F172A),
                                      width: 1.2,
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 5),
                              Text(
                                '${3 - _counterOfferCount}/3',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: _counterOfferCount >= 3
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFFFFDE59),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Offer & Probability Station (Interactive Dial Card)
              NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderWidth: 2,
                borderRadius: 12,
                shadowOffset: const Offset(3, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          context.tr('negotiation_your_offer_title'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        )),
                        Row(
                          children: [
                            if (decorBonus > 0) ...[
                              const NeoBrutalBadge(
                                icon: Icons.chair_rounded,
                                text: '+%4 Makam',
                                backgroundColor: Color(0xFFD97706),
                                textColor: Colors.black,
                                borderWidth: 1.5,
                                fontSize: 10,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 2),
                              ),
                              const SizedBox(width: 4),
                            ],
                            NeoBrutalBadge(
                              icon: Icons.psychology_rounded,
                              text: context.tr('deal_persuasion_chance',
                                  {'chance': chancePercent}),
                              backgroundColor: chanceColor,
                              textColor: Colors.black,
                              borderWidth: 1.5,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Stencil Price Display & Discount Diff
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyFormatter.format(_offeredPrice),
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            color: isDark
                                ? const Color(0xFFFFDE59)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          discountAmount > 0
                              ? context.tr(
                                  'deal_discount_info', {'pct': discountRatio})
                              : context.tr('deal_full_price_offer'),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: discountAmount > 0
                                ? (isDark
                                    ? const Color(0xFF00E575)
                                    : const Color(0xFF15803D))
                                : (isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Quick Bargaining Snap Chips (-%5, -%10, -%15, -%20, -%25, TAM)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildQuickSnapChip('-%5', 0.05, asking, isDark),
                          const SizedBox(width: 6),
                          _buildQuickSnapChip('-%10', 0.10, asking, isDark),
                          const SizedBox(width: 6),
                          _buildQuickSnapChip('-%15', 0.15, asking, isDark),
                          const SizedBox(width: 6),
                          _buildQuickSnapChip('-%20', 0.20, asking, isDark),
                          const SizedBox(width: 6),
                          _buildQuickSnapChip('-%25', 0.25, asking, isDark),
                          const SizedBox(width: 6),
                          _buildQuickSnapChip('Tam Fiyat', 0.0, asking, isDark),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Arcade Segmented Persuasion & Conviction Meter
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'İKNA VE KABUL OLASILIĞI',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '%$chancePercent İkna Gücü',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: chanceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    SegmentedArcadeGauge(
                      totalSegments: 6,
                      activeSegments:
                          ((chancePercent / 100) * 6).round().clamp(1, 6),
                      activeColor: chanceColor,
                      height: 10,
                      gap: 4,
                    ),
                    const SizedBox(height: 10),

                    // Neo-Brutalist Potentiometer Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFFDE59),
                        inactiveTrackColor: isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFFFFDE59),
                        overlayColor:
                            const Color(0xFFFFDE59).withValues(alpha: 0.2),
                        trackHeight: 10.0,
                        trackShape: NeoBrutalSliderTrackShape(
                          trackBorderColor: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          trackBorderWidth: 2.0,
                        ),
                        thumbShape: NeoBrutalRectangularThumbShape(
                          thumbWidth: 20,
                          thumbHeight: 26,
                          fillColor: const Color(0xFFFFDE59),
                          borderColor: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          borderWidth: 2.2,
                          shadowOffsetDistance: 2.5,
                        ),
                      ),
                      child: Slider(
                        value: _offeredPrice,
                        min: (asking * 0.75).roundToDouble(),
                        max: asking,
                        divisions: 50,
                        onChanged: (_isAccepted ||
                                _sellerResponse != null ||
                                _isThinking ||
                                _isLockedOut ||
                                _isProcessing)
                            ? null
                            : (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _offeredPrice = val.roundToDouble();
                                });
                              },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Tactical Esnaf Action Cards Bar
              if (_sellerResponse == null && !_isLockedOut) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      context.tr('negotiation_tactics_header'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF0F172A),
                      ),
                    )),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _tacticUsageCount >= 3
                            ? (isDark
                                ? const Color(0xFF7F1D1D)
                                : const Color(0xFFFEE2E2))
                            : (isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _tacticUsageCount >= 3
                              ? AppColors.errorRed
                              : (isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFFCBD5E1)),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        '$_tacticUsageCount / 3 KOZ KULLANILDI',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: _tacticUsageCount >= 3
                              ? AppColors.errorRed
                              : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Last Tactic Outcome Banner
                if (_lastTacticOutcome != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _lastTacticOutcome!.isSuccess
                          ? (isDark
                              ? const Color(0xFF064E3B)
                              : const Color(0xFFD1FAE5))
                          : (_lastTacticOutcome!.isWalkaway
                              ? (isDark
                                  ? const Color(0xFF7F1D1D)
                                  : const Color(0xFFFEE2E2))
                              : (isDark
                                  ? const Color(0xFF78350F)
                                  : const Color(0xFFFEF3C7))),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _lastTacticOutcome!.isSuccess
                            ? AppColors.brutalGreen
                            : (_lastTacticOutcome!.isWalkaway
                                ? AppColors.errorRed
                                : AppColors.brutalYellow),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _lastTacticOutcome!.isSuccess
                              ? Icons.casino_rounded
                              : (_lastTacticOutcome!.isWalkaway
                                  ? Icons.cancel_rounded
                                  : Icons.casino_outlined),
                          size: 16,
                          color: _lastTacticOutcome!.isSuccess
                              ? AppColors.brutalGreen
                              : (_lastTacticOutcome!.isWalkaway
                                  ? AppColors.errorRed
                                  : AppColors.brutalYellow),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Zar: ${_lastTacticOutcome!.diceRoll} / ${_lastTacticOutcome!.threshold} • ${_lastTacticOutcome!.isSuccess ? "Başarılı +%${_lastTacticOutcome!.bonusChance}" : (_lastTacticOutcome!.isWalkaway ? "Masadan Kalkıldı" : "Direnç ${_lastTacticOutcome!.bonusChance}%")}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                Row(
                  children: _dynamicTactics.map((tactic) {
                    final isUsed = _usedTacticIds.contains(tactic.id);
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _buildTacticalCard(
                          title: isUsed
                              ? context.tr('negotiation_toast_tactic_used')
                              : tactic.title,
                          badgeText: tactic.badgeText,
                          icon: _getTacticIcon(tactic.iconKey),
                          activeBgColor: _getTacticColor(tactic.iconKey),
                          isUsed: isUsed,
                          isDark: isDark,
                          onTap: () =>
                              _executeTactic(tactic, car, asking, game),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // 5. Thinking & Suspense Ticker Card
              if (_isThinking) ...[
                NeoBrutalCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  backgroundColor: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFFEFCE8),
                  borderColor: const Color(0xFFFFDE59),
                  borderWidth: 2.2,
                  borderRadius: 10,
                  shadowOffset: const Offset(3, 3),
                  child: Row(
                    children: [
                      const PulsingDot(color: Color(0xFFFFDE59), size: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const NeoBrutalBadge(
                                  text: 'CANLI DÜŞÜNCE RADARI',
                                  backgroundColor: Color(0xFFFFDE59),
                                  textColor: Colors.black,
                                  borderWidth: 1.2,
                                  fontSize: 8.5,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Değerlendiriliyor...',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _thinkingText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ] else if (_sellerResponse == null) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          PsychologyEngine.getSuspenseNegotiationText(),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // 6. Dialogue Outcome Display Card
              if (_sellerResponse != null) ...[
                NeoBrutalCard(
                  backgroundColor: _isAccepted
                      ? (isDark
                          ? const Color(0xFF14291D)
                          : const Color(0xFFF0FDF4))
                      : (isDark
                          ? const Color(0xFF291414)
                          : const Color(0xFFFEF2F2)),
                  borderColor: _isAccepted
                      ? const Color(0xFF00E575)
                      : const Color(0xFFEF4444),
                  borderWidth: 2.2,
                  borderRadius: 12,
                  shadowOffset: const Offset(3, 3),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isAccepted
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _isAccepted
                                ? const Color(0xFF00E575)
                                : const Color(0xFFEF4444),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isAccepted
                                ? context.tr('deal_offer_accepted')
                                : context.tr('deal_offer_rejected'),
                            style: TextStyle(
                              color: _isAccepted
                                  ? const Color(0xFF00E575)
                                  : const Color(0xFFEF4444),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_customer.name}: "${_sellerResponse!}"',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      if (_isNearMiss && !_isAccepted && !_isLockedOut) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFDE59).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFFFDE59), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.near_me_rounded,
                                  size: 14, color: Color(0xFFD97706)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('deal_near_miss_desc'),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB45309)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_isLockedOut) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFEF4444), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.block_rounded,
                                  size: 14, color: Color(0xFFEF4444)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  context.tr('deal_locked_out_desc'),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEF4444)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!_hasRescuedWithTea) ...[
                          const SizedBox(height: 8),
                          NeoBrutalButton(
                            label: context.tr('deal_tea_rescue_btn'),
                            icon: Icons.local_cafe_rounded,
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 11,
                            fullWidth: true,
                            onPressed: () {
                              AdService.instance.showRewardedAdWithFallback(
                                context: context,
                                customRewardTitle:
                                    context.tr('deal_tea_reward_title'),
                                onRewardEarned: () {
                                  setState(() {
                                    _isLockedOut = false;
                                    _hasRescuedWithTea = true;
                                    _counterOfferCount = 1;
                                    _sellerResponse = null;
                                    _isNearMiss = false;
                                  });
                                  NotificationService.showSuccess(
                                    context,
                                    context.tr('deal_tea_rescue_toast'),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 7. Discrepancy Bargaining Leverage Card OR Bluff Mechanic
              if (_sellerResponse == null &&
                  currentListing.isExpertiseCompleted) ...[
                Builder(
                  builder: (context) {
                    final disc = NegotiationEngine.detectExpertiseDiscrepancy(
                        currentListing.car);

                    if (!disc.hasDiscrepancy) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(12),
                          backgroundColor: isDark
                              ? const Color(0xFF0F291E)
                              : const Color(0xFFECFDF5),
                          borderColor: const Color(0xFF10B981),
                          borderWidth: 2,
                          borderRadius: 12,
                          shadowOffset: const Offset(3, 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.verified_rounded,
                                      color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      context.tr('deal_honest_seller_title'),
                                      style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr('deal_honest_seller_desc'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF6EE7B7)
                                      : const Color(0xFF065F46),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: _hasUsedHonestDiscount
                                          ? context
                                              .tr('deal_friendly_discount_used')
                                          : context
                                              .tr('deal_friendly_discount_btn'),
                                      icon: Icons.handshake_rounded,
                                      backgroundColor: _hasUsedHonestDiscount
                                          ? const Color(0xFF059669)
                                          : const Color(0xFF10B981),
                                      textColor: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      onPressed: (_hasUsedHonestDiscount ||
                                              _isAccepted ||
                                              _sellerResponse != null ||
                                              _isLockedOut ||
                                              _isThinking ||
                                              _isProcessing)
                                          ? null
                                          : () {
                                              HapticFeedback.selectionClick();
                                              setState(() {
                                                _hasUsedHonestDiscount = true;
                                                _bonusChancePercent += 10;
                                                _sellerResponse = context.tr(
                                                    'deal_honest_seller_resp');
                                              });
                                              NotificationService.showSuccess(
                                                  context,
                                                  context.tr(
                                                      'deal_honest_bonus_toast'));
                                            },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: context.tr('deal_bluff_btn'),
                                      icon: Icons.psychology_alt_rounded,
                                      backgroundColor: isDark
                                          ? const Color(0xFF24142B)
                                          : const Color(0xFFFAF5FF),
                                      textColor: const Color(0xFFA855F7),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      onPressed: (_isAccepted ||
                                              _sellerResponse != null ||
                                              _isLockedOut ||
                                              _isThinking ||
                                              _isProcessing)
                                          ? null
                                          : () {
                                              final roll =
                                                  Random().nextInt(100);
                                              final bluffChance =
                                                  game.skills.negotiationLevel *
                                                      5;

                                              if (roll < bluffChance) {
                                                final targetDiscPrice =
                                                    (asking * 0.85)
                                                        .roundToDouble();
                                                setState(() {
                                                  _offeredPrice =
                                                      targetDiscPrice;
                                                  _agreedFinalPrice =
                                                      targetDiscPrice;
                                                  _isAccepted = true;
                                                  switch (_customer.archetype) {
                                                    case CustomerArchetype
                                                          .skepticalOfficial:
                                                      _sellerResponse = context.tr(
                                                          'deal_skeptical_bluff_win',
                                                          {
                                                            'price': CurrencyFormatter
                                                                .formatShort(
                                                                    targetDiscPrice)
                                                          });
                                                      break;
                                                    case CustomerArchetype
                                                          .impatientYouth:
                                                      _sellerResponse = context.tr(
                                                          'deal_impatient_bluff_win',
                                                          {
                                                            'price': CurrencyFormatter
                                                                .formatShort(
                                                                    targetDiscPrice)
                                                          });
                                                      break;
                                                    case CustomerArchetype
                                                          .greedyFlipper:
                                                      _sellerResponse = context.tr(
                                                          'deal_greedy_bluff_win',
                                                          {
                                                            'price': CurrencyFormatter
                                                                .formatShort(
                                                                    targetDiscPrice)
                                                          });
                                                      break;
                                                    case CustomerArchetype
                                                          .familyMan:
                                                      _sellerResponse = context.tr(
                                                          'deal_family_bluff_win',
                                                          {
                                                            'price': CurrencyFormatter
                                                                .formatShort(
                                                                    targetDiscPrice)
                                                          });
                                                      break;
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  _isAccepted = false;
                                                  switch (_customer.archetype) {
                                                    case CustomerArchetype
                                                          .skepticalOfficial:
                                                      _sellerResponse = context.tr(
                                                          'deal_skeptical_bluff_fail');
                                                      break;
                                                    case CustomerArchetype
                                                          .impatientYouth:
                                                      _sellerResponse = context.tr(
                                                          'deal_impatient_bluff_fail');
                                                      break;
                                                    case CustomerArchetype
                                                          .greedyFlipper:
                                                      _sellerResponse = context.tr(
                                                          'deal_greedy_bluff_fail');
                                                      break;
                                                    case CustomerArchetype
                                                          .familyMan:
                                                      _sellerResponse = context.tr(
                                                          'deal_family_bluff_fail');
                                                      break;
                                                  }
                                                });
                                              }
                                            },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(12),
                        backgroundColor: isDark
                            ? const Color(0xFF2E1E0E)
                            : const Color(0xFFFEF3C7),
                        borderColor: const Color(0xFFD97706),
                        borderWidth: 2,
                        borderRadius: 12,
                        shadowOffset: const Offset(3, 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.report_problem_rounded,
                                    color: Color(0xFFD97706), size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    context.tr('deal_discrepancy_title',
                                        {'title': disc.title}),
                                    style: const TextStyle(
                                        color: Color(0xFFD97706),
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              disc.description,
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFF451A03),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            NeoBrutalButton(
                              label: context.tr('deal_strike_defect_btn', {
                                'percent':
                                    (disc.extraDiscountPercent * 100).toInt()
                              }),
                              icon: Icons.gavel_rounded,
                              backgroundColor: const Color(0xFFD97706),
                              textColor: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fullWidth: true,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: (_isAccepted ||
                                      _sellerResponse != null ||
                                      _isLockedOut ||
                                      _isThinking ||
                                      _isProcessing)
                                  ? null
                                  : () {
                                      final targetDiscPrice = (asking *
                                              (1.0 - disc.extraDiscountPercent))
                                          .roundToDouble();
                                      setState(() {
                                        _offeredPrice = targetDiscPrice;
                                        _agreedFinalPrice = targetDiscPrice;
                                        _isAccepted = true;
                                        switch (_customer.archetype) {
                                          case CustomerArchetype
                                                .skepticalOfficial:
                                            _sellerResponse = context.tr(
                                                'deal_skeptical_defect_accept',
                                                {
                                                  'price': CurrencyFormatter
                                                      .formatShort(
                                                          targetDiscPrice)
                                                });
                                            break;
                                          case CustomerArchetype.impatientYouth:
                                            _sellerResponse = context.tr(
                                                'deal_impatient_defect_accept',
                                                {
                                                  'price': CurrencyFormatter
                                                      .formatShort(
                                                          targetDiscPrice)
                                                });
                                            break;
                                          case CustomerArchetype.greedyFlipper:
                                            _sellerResponse = context.tr(
                                                'deal_greedy_defect_accept', {
                                              'price':
                                                  CurrencyFormatter.formatShort(
                                                      targetDiscPrice)
                                            });
                                            break;
                                          case CustomerArchetype.familyMan:
                                            _sellerResponse = context.tr(
                                                'deal_family_defect_accept', {
                                              'price':
                                                  CurrencyFormatter.formatShort(
                                                      targetDiscPrice)
                                            });
                                            break;
                                        }
                                      });
                                    },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],

              // 8. Monolithic Action Buttons
              Row(
                children: [
                  if (_sellerResponse == null)
                    Expanded(
                      child: NeoBrutalButton(
                        label: _isThinking
                            ? 'TEKLİF DEĞERLENDİRİLİYOR...'
                            : context.tr('deal_make_offer_btn', {
                                'price': CurrencyFormatter.formatShort(_offeredPrice)
                              }),
                        icon: _isThinking
                            ? Icons.hourglass_top_rounded
                            : Icons.handshake_rounded,
                        backgroundColor: const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: (_isProcessing ||
                                _isThinking ||
                                _isLockedOut)
                            ? null
                            : () => _handleSendOffer(chancePercent),
                      ),
                    )
                  else if (_isAccepted)
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('deal_pay_and_buy_btn', {
                          'price': CurrencyFormatter.formatShort(
                              _agreedFinalPrice ?? _offeredPrice)
                        }),
                        icon: Icons.shopping_bag_rounded,
                        backgroundColor: const Color(0xFF00E575),
                        textColor: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: (game.balance <
                                    (_agreedFinalPrice ?? _offeredPrice) ||
                                _isProcessing)
                            ? null
                            : () {
                                if (game.ownedCars.length >=
                                    game.maxGarageSlots) {
                                  NotificationService.showError(
                                    context,
                                    context.tr('deal_garage_full_msg', {
                                      'current': game.ownedCars.length,
                                      'max': game.maxGarageSlots
                                    }),
                                  );
                                  return;
                                }
                                HapticFeedback.heavyImpact();
                                setState(() => _isProcessing = true);
                                final finalPayPrice =
                                    _agreedFinalPrice ?? _offeredPrice;
                                final outcome =
                                    ref.read(gameProvider.notifier).buyCar(
                                          currentListing.car,
                                          finalPayPrice,
                                          isExpertiseCompleted: currentListing
                                              .isExpertiseCompleted,
                                        );
                                if (outcome != null) {
                                  ref
                                      .read(marketProvider.notifier)
                                      .removeListing(currentListing.id);

                                  if (outcome.isTrapped) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: NeoBrutalCard(
                                          backgroundColor: isDark
                                              ? const Color(0xFF161922)
                                              : Colors.white,
                                          borderColor: isDark
                                              ? const Color(0xFF333B4F)
                                              : const Color(0xFF0F172A),
                                          borderWidth: 2.5,
                                          borderRadius: 16,
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: p.errorColor,
                                                      size: 32),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      outcome.title,
                                                      style: TextStyle(
                                                          color: p.errorColor,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 18),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                outcome.description,
                                                style: TextStyle(
                                                  color: isDark
                                                      ? Colors.white70
                                                      : const Color(0xFF0F172A),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              NeoBrutalButton(
                                                label: context
                                                    .tr('modal_understood'),
                                                icon:
                                                    Icons.check_circle_outline,
                                                backgroundColor:
                                                    const Color(0xFFFFDE59),
                                                textColor: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                fullWidth: true,
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                  if (context.canPop()) {
                                                    context.pop();
                                                  } else {
                                                    context.go('/marketplace');
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  } else {
                                    NotaryTransferDialog.show(
                                      context: context,
                                      car: currentListing.car,
                                      buyerName:
                                          '${game.dealershipName} • ${game.playerName}',
                                      sellerName: currentListing.getLocalizedSellerName(context),
                                      salePrice: finalPayPrice,
                                      isBuying: true,
                                      eventResult: NotaryEventResult(
                                        type: NotaryEventType.smoothDeal,
                                        title:
                                            context.tr('notary_success_title'),
                                        description:
                                            context.tr('notary_success_desc'),
                                      ),
                                      onComplete: () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go('/marketplace');
                                        }
                                      },
                                    );
                                  }
                                }
                                if (mounted) {
                                  setState(() => _isProcessing = false);
                                }
                              },
                      ),
                    )
                  else if (!_isLockedOut)
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('deal_revise_offer_btn',
                            {'count': 3 - _counterOfferCount}),
                        icon: Icons.refresh_rounded,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0),
                        textColor:
                            isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _sellerResponse = null;
                            _isProcessing = false;
                            _isThinking = false;
                            _isNearMiss = false;
                          });
                        },
                      ),
                    )
                  else
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('deal_leave_table_btn'),
                        icon: Icons.close_rounded,
                        backgroundColor: const Color(0xFFEF4444),
                        textColor: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/marketplace');
                          }
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendOffer(int chancePercent) async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
      _isThinking = true;
      _counterOfferCount++;
    });

    final random = Random();
    final stages = NegotiationSuspenseEngine.getBuyingSuspenseStages(
      archetype: _customer.archetype,
      rng: random,
    );

    // Stage 1: Initial reaction (600ms - 900ms)
    final stage1Duration = 600 + random.nextInt(300);
    setState(() {
      _thinkingText = stages[0];
    });
    HapticFeedback.selectionClick();
    await Future.delayed(Duration(milliseconds: stage1Duration));
    if (!mounted) return;

    // Stage 2: Consultation & Calculation (700ms - 1100ms)
    final stage2Duration = 700 + random.nextInt(400);
    setState(() {
      _thinkingText = stages[1];
    });
    HapticFeedback.selectionClick();
    await Future.delayed(Duration(milliseconds: stage2Duration));
    if (!mounted) return;

    // Stage 3: Final decision moment (500ms - 800ms)
    final stage3Duration = 500 + random.nextInt(300);
    setState(() {
      _thinkingText = stages[2];
    });
    HapticFeedback.selectionClick();
    await Future.delayed(Duration(milliseconds: stage3Duration));
    if (!mounted) return;

    // Verdict Outcome
    final roll = random.nextInt(100) + 1;
    if (roll <= chancePercent) {
      ref.read(gameProvider.notifier).checkAndAwardFirstTimeAction(
          FirstTimeActionKeys.firstNegotiationWin);
      GameSoundHapticService.playCashSuccess();
      setState(() {
        _isThinking = false;
        _isProcessing = false;
        _isAccepted = true;
        _agreedFinalPrice = _offeredPrice;
        _isNearMiss = false;
        switch (_customer.archetype) {
          case CustomerArchetype.skepticalOfficial:
            _sellerResponse = context.tr('deal_skeptical_accept');
            break;
          case CustomerArchetype.impatientYouth:
            _sellerResponse = context.tr('deal_impatient_accept');
            break;
          case CustomerArchetype.greedyFlipper:
            _sellerResponse = context.tr('deal_greedy_accept');
            break;
          case CustomerArchetype.familyMan:
            _sellerResponse = context.tr('deal_family_accept');
            break;
        }
      });
    } else {
      final isNear = roll <= chancePercent + 15;
      final isLocked = _counterOfferCount >= 3;
      GameSoundHapticService.playWarningVibration();
      setState(() {
        _isThinking = false;
        _isProcessing = false;
        _isAccepted = false;
        _isNearMiss = isNear;
        _isLockedOut = isLocked;
        if (isLocked) {
          _sellerResponse = context.tr('deal_seller_locked_resp');
        } else {
          switch (_customer.archetype) {
            case CustomerArchetype.skepticalOfficial:
              _sellerResponse = context.tr('deal_skeptical_reject');
              break;
            case CustomerArchetype.impatientYouth:
              _sellerResponse = context.tr('deal_impatient_reject');
              break;
            case CustomerArchetype.greedyFlipper:
              _sellerResponse = context.tr('deal_greedy_reject');
              break;
            case CustomerArchetype.familyMan:
              _sellerResponse = context.tr('deal_family_reject');
              break;
          }
        }
      });
    }
  }

  Widget _buildQuickSnapChip(
      String label, double discountPercent, double asking, bool isDark) {
    final targetPrice = (asking * (1.0 - discountPercent)).roundToDouble();
    final isSelected = (_offeredPrice - targetPrice).abs() < 500;
    final isLocked = _isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing;

    return InkWell(
      onTap: isLocked ? null : () => _snapToDiscount(asking, discountPercent),
      borderRadius: BorderRadius.circular(6),
      child: Opacity(
        opacity: isLocked ? 0.45 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFDE59)
                : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 1.8,
            ),
            boxShadow: isLocked
                ? null
                : [
                    BoxShadow(
                      color: isDark ? Colors.black : const Color(0xFF0F172A),
                      offset: isSelected
                          ? const Offset(1, 1)
                          : const Offset(2.5, 2.5),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: isSelected
                  ? Colors.black
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getTacticIcon(String iconKey) {
    switch (iconKey) {
      case 'expert':
        return Icons.search_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'market':
        return Icons.trending_down_rounded;
      case 'partner':
        return Icons.phone_in_talk_rounded;
      case 'tea':
        return Icons.local_cafe_rounded;
      case 'smoke':
        return Icons.smoking_rooms_rounded;
      case 'mechanic':
        return Icons.build_rounded;
      case 'urgent':
        return Icons.alarm_on_rounded;
      case 'pristine':
        return Icons.auto_awesome_rounded;
      case 'notary':
        return Icons.drive_file_rename_outline_rounded;
      case 'tok_seller':
        return Icons.work_rounded;
      default:
        return Icons.handshake_rounded;
    }
  }

  Color _getTacticColor(String iconKey) {
    switch (iconKey) {
      case 'expert':
        return const Color(0xFF00E575);
      case 'cash':
        return const Color(0xFFFFDE59);
      case 'market':
        return const Color(0xFFFF54B0);
      case 'partner':
        return const Color(0xFF38BDF8);
      case 'tea':
        return const Color(0xFFFFDE59);
      case 'smoke':
        return const Color(0xFFCBD5E1);
      case 'mechanic':
        return const Color(0xFFF97316);
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'pristine':
        return const Color(0xFFA855F7);
      case 'notary':
        return const Color(0xFF10B981);
      case 'tok_seller':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFFFDE59);
    }
  }

  void _executeTactic(
      EsnafTactic tactic, CarModel car, double asking, DealershipModel game) {
    if (_usedTacticIds.contains(tactic.id) || _tacticUsageCount >= 3) {
      return;
    }
    if (_isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing) {
      return;
    }

    final outcome = NegotiationEngine.rollTactic(
      tactic: tactic,
      tacticUsageIndex: _tacticUsageCount,
      negotiationSkillLevel: game.skills.negotiationLevel,
      car: car,
      customer: _customer,
      isBuying: true,
      purchasedAcademyCourses: game.purchasedAcademyCourses,
      isTraderSpecialization:
          game.specializationPath == SpecializationPath.trader,
    );

    setState(() {
      _usedTacticIds.add(tactic.id);
      _tacticUsageCount++;
      _bonusChancePercent += outcome.bonusChance;
      _lastTacticOutcome = outcome;
      if (outcome.isWalkaway) {
        _isLockedOut = true;
        _sellerResponse = outcome.message;
      }
    });

    HapticFeedback.heavyImpact();
    if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(context, outcome.message);
    } else if (outcome.isSuccess) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(context,
          'Zar: ${outcome.diceRoll}/${outcome.threshold} • ${outcome.message}');
    } else {
      GameSoundHapticService.playTapImpact();
      NotificationService.showWarning(context,
          'Zar: ${outcome.diceRoll}/${outcome.threshold} • ${outcome.message}');
    }
  }

  Widget _buildTacticalCard({
    required String title,
    required String badgeText,
    required IconData icon,
    required Color activeBgColor,
    required bool isUsed,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isCardDisabled = isUsed ||
        _isAccepted ||
        _sellerResponse != null ||
        _isLockedOut ||
        _isThinking ||
        _isProcessing;

    return InkWell(
      onTap: isCardDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: isUsed
              ? (isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0))
              : (isDark ? const Color(0xFF1E2330) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUsed
                ? (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1))
                : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
            width: 2.0,
          ),
          boxShadow: (isUsed || isCardDisabled)
              ? null
              : [
                  BoxShadow(
                    color: isDark ? Colors.black : const Color(0xFF0F172A),
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Opacity(
          opacity: (isCardDisabled && !isUsed) ? 0.45 : 1.0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isUsed
                      ? (isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFCBD5E1))
                      : activeBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 18,
                    color: isUsed
                        ? (isDark ? Colors.white30 : Colors.black26)
                        : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isUsed
                      ? (isDark ? Colors.white38 : Colors.black38)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isUsed
                      ? Colors.transparent
                      : (isDark
                          ? const Color(0xFF141721)
                          : const Color(0xFFFEFCE8)),
                  borderRadius: BorderRadius.circular(4),
                  border: isUsed
                      ? null
                      : Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 1.2),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: isUsed
                        ? (isDark ? Colors.white24 : Colors.black26)
                        : (isDark
                            ? const Color(0xFFFFDE59)
                            : const Color(0xFF0F172A)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

