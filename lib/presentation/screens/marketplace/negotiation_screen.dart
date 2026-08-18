import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/first_time_action_keys.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/listing_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/market_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
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
  String? _sellerResponse;
  bool _isAccepted = false;
  bool _isProcessing = false;
  bool _isThinking = false;
  String _thinkingText = '';
  int _counterOfferCount = 0;
  bool _isNearMiss = false;
  bool _isLockedOut = false;
  late CustomerModel _customer;
  late String _fomoText;
  int _bonusChancePercent = 0;
  bool _hasUsedTea = false;
  bool _hasUsedCigarette = false;
  bool _hasUsedPartner = false;

  @override
  void initState() {
    super.initState();
    _offeredPrice = (widget.listing.askingPrice * 0.90).roundToDouble();
    _customer = CustomerModel.generateSellerFromListing(widget.listing.sellerName);
    _fomoText = PsychologyEngine.getRandomFomoText();
  }

  int _calculateSuccessChance(int negotiationSkillLevel, {double decorBonusPercent = 0.0}) {
    final baseChance = NegotiationEngine.calculateMarketplaceBuyerSuccessChance(
      askingPrice: widget.listing.askingPrice,
      offeredPrice: _offeredPrice,
      negotiationSkillLevel: negotiationSkillLevel,
    );
    return (baseChance + _bonusChancePercent + decorBonusPercent.toInt()).clamp(5, 95);
  }

  void _snapToDiscount(double asking, double discountPercent) {
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
    final chancePercent = _calculateSuccessChance(game.skills.negotiationLevel, decorBonusPercent: decorBonus);
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
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(62),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141721) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
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
                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
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
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        NeoBrutalBadge(
                          text: 'PROTOKOL #PZ-884',
                          backgroundColor: Color(0xFFFFDE59),
                          textColor: Colors.black,
                          borderWidth: 1.2,
                          fontSize: 8,
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        ),
                        SizedBox(width: 4),
                        NeoBrutalBadge(
                          text: 'CANLI MÜZAKERE',
                          backgroundColor: Color(0xFF38BDF8),
                          textColor: Colors.black,
                          borderWidth: 1.2,
                          fontSize: 8,
                          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'PAZARLIK MASASI',
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Seller Dossier & Archetype Card
              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor: isDark ? const Color(0xFF161922) : const Color(0xFFFEFCE8),
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
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
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
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _customer.personalityDescription,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFDE59),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
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
                                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${currentListing.sellerCity} • Plaka: ${car.plateNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                              'Satıcı İlan Fiyatı',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(asking),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? const Color(0xFFFFDE59) : const Color(0xFFD97706),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // FOMO badge & Remaining Rights Counter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.local_fire_department_rounded, size: 14, color: Color(0xFFFF7A00)),
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
                                'Pazarlık:',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 5),
                              ...List.generate(3, (index) {
                                final isRemaining = index < (3 - _counterOfferCount);
                                return Container(
                                  margin: const EdgeInsets.only(left: 2.5),
                                  width: 10,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isRemaining
                                        ? const Color(0xFFFFDE59)
                                        : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
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
                                  color: _counterOfferCount >= 3 ? const Color(0xFFEF4444) : const Color(0xFFFFDE59),
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
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderWidth: 2,
                borderRadius: 12,
                shadowOffset: const Offset(3, 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SENİN TEKLİFİN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
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
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              ),
                              const SizedBox(width: 4),
                            ],
                            NeoBrutalBadge(
                              icon: Icons.psychology_rounded,
                              text: 'İkna Şansı: %$chancePercent',
                              backgroundColor: chanceColor,
                              textColor: Colors.black,
                              borderWidth: 1.5,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                            color: isDark ? const Color(0xFFFFDE59) : const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          discountAmount > 0
                              ? 'İndirim: ${CurrencyFormatter.formatShort(discountAmount)} (-%$discountRatio)'
                              : 'Tam Fiyat Teklifi',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: discountAmount > 0
                                ? (isDark ? const Color(0xFF00E575) : const Color(0xFF15803D))
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
                    const SizedBox(height: 8),

                    // Neo-Brutalist Styled Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFFFFDE59),
                        inactiveTrackColor: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
                        thumbColor: const Color(0xFFFFDE59),
                        overlayColor: const Color(0xFFFFDE59).withValues(alpha: 0.2),
                        trackHeight: 6.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11.0),
                      ),
                      child: Slider(
                        value: _offeredPrice,
                        min: (asking * 0.75).roundToDouble(),
                        max: asking,
                        divisions: 50,
                        onChanged: (_sellerResponse != null || _isThinking || _isLockedOut)
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
                Text(
                  'ESNAF KOZLARI & MÜZAKERE TAKTİKLERİ',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Çay İkram Et
                    Expanded(
                      child: _buildTacticalCard(
                        title: _hasUsedTea ? 'Çay Verildi' : 'Çay İkram Et',
                        badgeText: '+%10 Şans',
                        icon: Icons.local_cafe_rounded,
                        activeBgColor: const Color(0xFFFFDE59),
                        isUsed: _hasUsedTea,
                        isDark: isDark,
                        onTap: () {
                          final res = NegotiationEngine.executeEsnafAction(
                            actionType: 'cay_soyle',
                            currentOffer: _offeredPrice,
                            askingPrice: asking,
                            negotiationSkillLevel: game.skills.negotiationLevel,
                          );
                          setState(() {
                            _hasUsedTea = true;
                            _bonusChancePercent += res['bonusChance'] as int;
                          });
                          HapticFeedback.mediumImpact();
                          NotificationService.showSuccess(context, res['message'] as String);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Sigara Yak
                    Expanded(
                      child: _buildTacticalCard(
                        title: _hasUsedCigarette ? 'Sigara Yakıldı' : 'Bir Sigara Yak',
                        badgeText: '+%12 Şans',
                        icon: Icons.smoking_rooms_rounded,
                        activeBgColor: const Color(0xFFCBD5E1),
                        isUsed: _hasUsedCigarette,
                        isDark: isDark,
                        onTap: () {
                          final res = NegotiationEngine.executeEsnafAction(
                            actionType: 'sigara_yak',
                            currentOffer: _offeredPrice,
                            askingPrice: asking,
                            negotiationSkillLevel: game.skills.negotiationLevel,
                          );
                          setState(() {
                            _hasUsedCigarette = true;
                            _bonusChancePercent += res['bonusChance'] as int;
                          });
                          HapticFeedback.mediumImpact();
                          NotificationService.showSuccess(context, res['message'] as String);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Ortağa Danış
                    Expanded(
                      child: _buildTacticalCard(
                        title: _hasUsedPartner ? 'Ortağa Danışıldı' : 'Ortağa Danış',
                        badgeText: 'Fiyatı İt',
                        icon: Icons.phone_in_talk_rounded,
                        activeBgColor: const Color(0xFF38BDF8),
                        isUsed: _hasUsedPartner,
                        isDark: isDark,
                        onTap: () {
                          final res = NegotiationEngine.executeEsnafAction(
                            actionType: 'ortak_arayayim',
                            currentOffer: _offeredPrice,
                            askingPrice: asking,
                            negotiationSkillLevel: game.skills.negotiationLevel,
                          );
                          setState(() {
                            _hasUsedPartner = true;
                            _bonusChancePercent += res['bonusChance'] as int;
                            if (res['priceShift'] != null) {
                              _offeredPrice = (res['priceShift'] as double).clamp(asking * 0.75, asking);
                            }
                          });
                          HapticFeedback.mediumImpact();
                          NotificationService.showSuccess(context, res['message'] as String);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // 5. Thinking & Suspense Ticker
              if (_isThinking) ...[
                NeoBrutalCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFFEFCE8),
                  borderColor: const Color(0xFFFFDE59),
                  borderWidth: 2,
                  borderRadius: 10,
                  shadowOffset: const Offset(2, 2),
                  child: Row(
                    children: [
                      const PulsingDot(color: Color(0xFFFFDE59), size: 10),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _thinkingText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ] else if (_sellerResponse == null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          PsychologyEngine.getSuspenseNegotiationText(),
                          style: TextStyle(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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
                      ? (isDark ? const Color(0xFF14291D) : const Color(0xFFF0FDF4))
                      : (isDark ? const Color(0xFF291414) : const Color(0xFFFEF2F2)),
                  borderColor: _isAccepted ? const Color(0xFF00E575) : const Color(0xFFEF4444),
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
                            _isAccepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: _isAccepted ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isAccepted ? 'TEKLİF KABUL EDİLDİ!' : 'TEKLİF REDDEDİLDİ',
                            style: TextStyle(
                              color: _isAccepted ? const Color(0xFF00E575) : const Color(0xFFEF4444),
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
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      if (_isNearMiss && !_isAccepted && !_isLockedOut) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE59).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFDE59), width: 1.2),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.near_me_rounded, size: 14, color: Color(0xFFD97706)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Çok yaklaştın! Satıcı kararsız kaldı ama fiyatı biraz daha yükseltmen gerek.',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
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
                            color: const Color(0xFFEF4444).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.block_rounded, size: 14, color: Color(0xFFEF4444)),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '3 pazarlık hakkın tükendi! Satıcı bu araç için tekliflere kapandı.',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 7. Discrepancy Bargaining Leverage Card OR Bluff Mechanic
              if (_sellerResponse == null && currentListing.isExpertiseCompleted) ...[
                Builder(
                  builder: (context) {
                    final disc = NegotiationEngine.detectExpertiseDiscrepancy(currentListing.car);
                    
                    if (!disc.hasDiscrepancy) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(12),
                          backgroundColor: isDark ? const Color(0xFF24142B) : const Color(0xFFFAF5FF),
                          borderColor: const Color(0xFFA855F7),
                          borderWidth: 2,
                          borderRadius: 12,
                          shadowOffset: const Offset(3, 3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.masks_rounded, color: Color(0xFFA855F7), size: 18),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'BLÖF FIRSATI: Satıcıyı Yanılt',
                                      style: TextStyle(color: Color(0xFFA855F7), fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Araçta sorun yok ama yalan söyleyerek fiyatı kırabilirsin. (Başarısız olursa teklifi anında reddeder!)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFC084FC) : const Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              NeoBrutalButton(
                                label: 'Blöf Yap (-%15 İndirim Kopar)',
                                icon: Icons.psychology_alt_rounded,
                                backgroundColor: const Color(0xFFA855F7),
                                textColor: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                fullWidth: true,
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                onPressed: () {
                                  final roll = Random().nextInt(100);
                                  final bluffChance = game.skills.negotiationLevel * 5;
                                  
                                  if (roll < bluffChance) {
                                    final targetDiscPrice = (asking * 0.85).roundToDouble();
                                    setState(() {
                                      _offeredPrice = targetDiscPrice;
                                      _isAccepted = true;
                                      switch (_customer.archetype) {
                                        case CustomerArchetype.skepticalOfficial:
                                          _sellerResponse = 'Gerçekten mi? Raporu o kadar dikkatli okumamıştım. Peki o zaman, ${CurrencyFormatter.formatShort(targetDiscPrice)} olsun.';
                                          break;
                                        case CustomerArchetype.impatientYouth:
                                          _sellerResponse = 'Öyle mi diyorsun? Uğraşamayacağım şimdi, al senin dediğin fiyat ${CurrencyFormatter.formatShort(targetDiscPrice)} olsun geç.';
                                          break;
                                        case CustomerArchetype.greedyFlipper:
                                          _sellerResponse = 'Vay be, gözümden kaçmış demek. Nakit vereceksen ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a bırakıyorum, yoksa iptal.';
                                          break;
                                        case CustomerArchetype.familyMan:
                                          _sellerResponse = 'Yaa, öyle miymiş... Ben hiç fark etmedim. Neyse tamam, ${CurrencyFormatter.formatShort(targetDiscPrice)} olsun o zaman.';
                                          break;
                                      }
                                    });
                                  } else {
                                    setState(() {
                                      _isAccepted = false;
                                      switch (_customer.archetype) {
                                        case CustomerArchetype.skepticalOfficial:
                                          _sellerResponse = 'Ben aracımın her şeyini bilirim, evraklarım tam! Kimi kandırıyorsun, seninle işim olmaz!';
                                          break;
                                        case CustomerArchetype.impatientYouth:
                                          _sellerResponse = 'Kardeşim sen beni kopardın mı sanıyorsun? Raporda her şey yazıyor, hadi işine!';
                                          break;
                                        case CustomerArchetype.greedyFlipper:
                                          _sellerResponse = 'Hoppala! Kimi yiyorsun sen? O raporu ben kendi ustama da gösterdim, uza buradan.';
                                          break;
                                        case CustomerArchetype.familyMan:
                                          _sellerResponse = 'Ayıptır, biz burada dürüstçe iş yapıyoruz. Ekspertiz raporu ortada, sana araç falan satmıyorum.';
                                          break;
                                      }
                                    });
                                  }
                                },
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
                        backgroundColor: isDark ? const Color(0xFF2E1E0E) : const Color(0xFFFEF3C7),
                        borderColor: const Color(0xFFD97706),
                        borderWidth: 2,
                        borderRadius: 12,
                        shadowOffset: const Offset(3, 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.report_problem_rounded, color: Color(0xFFD97706), size: 18),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'KOZ FIRSATI: ${disc.title}',
                                    style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w900, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              disc.description,
                              style: TextStyle(
                                color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF451A03),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            NeoBrutalButton(
                              label: 'Kusuru Masaya Vur (-%${(disc.extraDiscountPercent * 100).toInt()} İndirim)',
                              icon: Icons.gavel_rounded,
                              backgroundColor: const Color(0xFFD97706),
                              textColor: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              fullWidth: true,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () {
                                final targetDiscPrice = (asking * (1.0 - disc.extraDiscountPercent)).roundToDouble();
                                setState(() {
                                  _offeredPrice = targetDiscPrice;
                                  _isAccepted = true;
                                  switch (_customer.archetype) {
                                    case CustomerArchetype.skepticalOfficial:
                                      _sellerResponse = 'Haklısınız, bu detay gözümden kaçmış. Titiz biriyimdir ama hata benim, ${CurrencyFormatter.formatShort(targetDiscPrice)} fiyatı kabul ediyorum.';
                                      break;
                                    case CustomerArchetype.impatientYouth:
                                      _sellerResponse = 'Tamam tamam, uzatma. Zaten acil satmam lazım, ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a al git.';
                                      break;
                                    case CustomerArchetype.greedyFlipper:
                                      _sellerResponse = 'Usta yakaladın beni, helal olsun... Neyse zararın neresinden dönsek kârdır, ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a veriyorum!';
                                      break;
                                    case CustomerArchetype.familyMan:
                                      _sellerResponse = 'Haklısınız, mahcup oldum şimdi... Size karşı dürüst olmak isterim, teklifiniz olan ${CurrencyFormatter.formatShort(targetDiscPrice)}\'a bırakıyorum.';
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
                        label: '${CurrencyFormatter.formatShort(_offeredPrice)} TEKLİF ET',
                        icon: Icons.handshake_rounded,
                        backgroundColor: const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: (_isProcessing || _isThinking || _isLockedOut)
                            ? null
                            : () async {
                                HapticFeedback.heavyImpact();
                                setState(() {
                                  _isProcessing = true;
                                  _isThinking = true;
                                  _thinkingText = PsychologyEngine.getSuspenseNegotiationText();
                                  _counterOfferCount++;
                                });

                                await Future.delayed(const Duration(milliseconds: 850));
                                if (!mounted) return;

                                final roll = Random().nextInt(100) + 1;
                                if (roll <= chancePercent) {
                                  ref.read(gameProvider.notifier).checkAndAwardFirstTimeAction(FirstTimeActionKeys.firstNegotiationWin);
                                  setState(() {
                                    _isThinking = false;
                                    _isProcessing = false;
                                    _isAccepted = true;
                                    _isNearMiss = false;
                                    switch (_customer.archetype) {
                                      case CustomerArchetype.skepticalOfficial:
                                        _sellerResponse = 'Teklifiniz makul. Beyefendi/Hanımefendi gibi anlaştık. Hayırlı olsun.';
                                        break;
                                      case CustomerArchetype.impatientYouth:
                                        _sellerResponse = 'Süper, hızını sevdim! Ver elini, hayırlı olsun.';
                                        break;
                                      case CustomerArchetype.greedyFlipper:
                                        _sellerResponse = 'Tamam arkadaşım, nakit hazırsa hemen notere geçiyoruz. Dediğin fiyata veriyorum.';
                                        break;
                                      case CustomerArchetype.familyMan:
                                        _sellerResponse = 'Ortada buluştuk diyelim, aileye gidecek araba sonuçta. Hayırlı uğurlu olsun.';
                                        break;
                                    }
                                  });
                                } else {
                                  final isNear = roll <= chancePercent + 15;
                                  final isLocked = _counterOfferCount >= 3;
                                  setState(() {
                                    _isThinking = false;
                                    _isProcessing = false;
                                    _isAccepted = false;
                                    _isNearMiss = isNear;
                                    _isLockedOut = isLocked;
                                    if (isLocked) {
                                      _sellerResponse = '3 kere pazarlık yaptık, anlaşamıyoruz. Daha fazla vaktimi harcama!';
                                    } else {
                                      switch (_customer.archetype) {
                                        case CustomerArchetype.skepticalOfficial:
                                          _sellerResponse = 'Maalesef bu fiyat aracımın değerini yansıtmıyor. İyi günler dilerim.';
                                          break;
                                        case CustomerArchetype.impatientYouth:
                                          _sellerResponse = 'O fiyata bedava vereyim istersen? Yok kardeşim, kurtarmaz.';
                                          break;
                                        case CustomerArchetype.greedyFlipper:
                                          _sellerResponse = 'Bizi mi koparıyorsun ustam? O fiyata ölüsü bile verilmez, biraz daha yukarı çık.';
                                          break;
                                        case CustomerArchetype.familyMan:
                                          _sellerResponse = 'Kusura bakmayın, o fiyata verirsem aile bütçemiz çok sarsılır. Biraz daha yükseltmeniz lazım.';
                                          break;
                                      }
                                    }
                                  });
                                }
                              },
                      ),
                    )
                  else if (_isAccepted)
                    Expanded(
                      child: NeoBrutalButton(
                        label: '${CurrencyFormatter.formatShort(_offeredPrice)} ÖDE VE SATIN AL',
                        icon: Icons.shopping_bag_rounded,
                        backgroundColor: const Color(0xFF00E575),
                        textColor: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        onPressed: (game.balance < _offeredPrice || _isProcessing)
                            ? null
                            : () {
                                HapticFeedback.heavyImpact();
                                setState(() => _isProcessing = true);
                                final outcome = ref.read(gameProvider.notifier).buyCar(
                                      currentListing.car,
                                      _offeredPrice,
                                      isExpertiseCompleted: currentListing.isExpertiseCompleted,
                                    );
                                if (outcome != null) {
                                  ref.read(marketProvider.notifier).removeListing(currentListing.id);
                                  
                                  if (outcome.isTrapped) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        child: NeoBrutalCard(
                                          backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
                                          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                          borderWidth: 2.5,
                                          borderRadius: 16,
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.warning_amber_rounded, color: p.errorColor, size: 32),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      outcome.title,
                                                      style: TextStyle(color: p.errorColor, fontWeight: FontWeight.w900, fontSize: 18),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                outcome.description,
                                                style: TextStyle(
                                                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              NeoBrutalButton(
                                                label: 'Anladım',
                                                icon: Icons.check_circle_outline,
                                                backgroundColor: const Color(0xFFFFDE59),
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
                                    NotificationService.showSuccess(
                                      context,
                                      'Tebrikler! ${currentListing.car.brand} ${currentListing.car.modelName} ${CurrencyFormatter.formatShort(_offeredPrice)} fiyata satın alındı!',
                                    );
                                    if (context.canPop()) {
                                      context.pop();
                                    } else {
                                      context.go('/marketplace');
                                    }
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
                        label: 'TEKLİFİ REVİZE ET (${3 - _counterOfferCount} Hak Kaldı)',
                        icon: Icons.refresh_rounded,
                        backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : const Color(0xFF0F172A),
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
                        label: 'MASADAN AYRIL',
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

  Widget _buildQuickSnapChip(String label, double discountPercent, double asking, bool isDark) {
    final targetPrice = (asking * (1.0 - discountPercent)).roundToDouble();
    final isSelected = (_offeredPrice - targetPrice).abs() < 500;

    return InkWell(
      onTap: () => _snapToDiscount(asking, discountPercent),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFDE59)
              : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A))
                : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF475569)),
          ),
        ),
      ),
    );
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
    return InkWell(
      onTap: isUsed ? null : onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isUsed
              ? (isDark ? const Color(0xFF141721) : const Color(0xFFE2E8F0))
              : (isDark ? activeBgColor.withValues(alpha: 0.15) : activeBgColor.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isUsed
                ? (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1))
                : (isDark ? activeBgColor : const Color(0xFF0F172A)),
            width: 1.8,
          ),
          boxShadow: isUsed
              ? null
              : [
                  BoxShadow(
                    color: isDark ? Colors.black : const Color(0xFF0F172A),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isUsed
                  ? (isDark ? Colors.white30 : Colors.black26)
                  : (isDark ? activeBgColor : const Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
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
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isUsed
                    ? Colors.transparent
                    : (isDark ? const Color(0xFF1E2330) : Colors.white),
                borderRadius: BorderRadius.circular(4),
                border: isUsed ? null : Border.all(color: isDark ? activeBgColor : const Color(0xFF0F172A), width: 1),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  color: isUsed ? (isDark ? Colors.white24 : Colors.black26) : const Color(0xFF0F172A),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
