import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/game_sound_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../../domain/usecases/negotiation_suspense_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/dialogs/notary_transfer_dialog.dart';
import '../../widgets/dialogs/rate_us_reward_dialog.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/neo_brutal_segmented_gauge.dart';
import '../../widgets/neo_brutal_slider.dart';
import '../../widgets/pulsing_dot.dart';

class OfferEvaluationArgs {
  final CarModel car;
  final OfferModel offer;

  const OfferEvaluationArgs({
    required this.car,
    required this.offer,
  });
}

class OfferEvaluationScreen extends ConsumerStatefulWidget {
  final OfferEvaluationArgs args;

  const OfferEvaluationScreen({
    super.key,
    required this.args,
  });

  @override
  ConsumerState<OfferEvaluationScreen> createState() => _OfferEvaluationScreenState();
}

class _OfferEvaluationScreenState extends ConsumerState<OfferEvaluationScreen> {
  late double _counterTargetPrice;
  late List<EsnafTactic> _dynamicTactics;
  late String _selectedStrategyId;
  bool _isProcessing = false;
  bool _isThinking = false;
  String _thinkingText = '';
  int _thinkingStage = 1;

  @override
  void initState() {
    super.initState();
    final car = widget.args.car;
    final offer = widget.args.offer;

    final effectiveListingPrice = (car.customListingPrice != null && car.customListingPrice! > 0)
        ? car.customListingPrice!
        : (car.estimatedRealValue * 1.15);
    final minOffer = offer.offeredAmount;
    final maxOffer = max(minOffer, effectiveListingPrice);

    _counterTargetPrice = (minOffer + (maxOffer - minOffer) * 0.40)
        .roundToDouble()
        .clamp(minOffer, maxOffer);

    _dynamicTactics = NegotiationEngine.generateTactics(
      isBuying: false,
      car: car,
      customer: offer.buyerCustomer,
      price: _counterTargetPrice,
    );
    _selectedStrategyId = _dynamicTactics.isNotEmpty ? _dynamicTactics.first.id : 'standard';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final car = widget.args.car;
    final offer = widget.args.offer;
    final customer = offer.buyerCustomer ?? CustomerModel.generateRandomCustomer();

    final effectiveListingPrice = (car.customListingPrice != null && car.customListingPrice! > 0)
        ? car.customListingPrice!
        : (car.estimatedRealValue * 1.15);
    final minOfferPrice = offer.offeredAmount;
    final maxOfferPrice = max(minOfferPrice, effectiveListingPrice);
    final priceGap = maxOfferPrice - minOfferPrice;
    final progressRatio = priceGap > 0 ? (_counterTargetPrice - minOfferPrice) / priceGap : 0.0;

    final double priceDiffFromListing = effectiveListingPrice - offer.offeredAmount;
    final double diffPercent = effectiveListingPrice > 0 ? (priceDiffFromListing / effectiveListingPrice) * 100 : 0.0;

    final remainingCounters = max(0, offer.maxCounters - offer.counterCount);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('title_offer_evaluation'),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.dealership,
        child: Stack(
          children: [
            SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 110 + MediaQuery.paddingOf(context).bottom),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Car & Offer Overview Card
                  _buildOfferOverviewCard(
                    car: car,
                    offer: offer,
                    effectiveListingPrice: effectiveListingPrice,
                    diffPercent: diffPercent,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 2. Buyer Profile & Psychology Radar
                  _buildBuyerPsychologyCard(
                    customer: customer,
                    offer: offer,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // Live Suspense Thinking Radar Card (Visible while evaluating counter offer)
                  if (_isThinking) ...[
                    _buildThinkingRadarCard(isDark: isDark),
                    const SizedBox(height: 16),
                  ],

                  // 3. Counter Offer & Live Tension Desk
                  _buildCounterOfferDesk(
                    car: car,
                    offer: offer,
                    minOfferPrice: minOfferPrice,
                    maxOfferPrice: maxOfferPrice,
                    progressRatio: progressRatio,
                    remainingCounters: remainingCounters,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 4. Notary & Profit Settlement Preview
                  _buildNotarySettlementCard(
                    car: car,
                    targetPrice: _counterTargetPrice,
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Bottom Action Dock
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomActionDock(
                car: car,
                offer: offer,
                customer: customer,
                remainingCounters: remainingCounters,
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferOverviewCard({
    required CarModel car,
    required OfferModel offer,
    required double effectiveListingPrice,
    required double diffPercent,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      shadowColor: Colors.black,
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
                    Text(
                      '${car.brand} ${car.modelName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${car.modelYear} • ${car.plateNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E575),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  offer.offerType == OfferType.installment
                      ? 'Taksitli Teklif'
                      : (offer.offerType == OfferType.cheque ? 'Senetli Teklif' : 'Nakit Teklif'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 2,
            color: isDark ? const Color(0xFF262C3D) : Colors.black.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlan Liste Fiyatı',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(effectiveListingPrice),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 2, height: 34, color: isDark ? const Color(0xFF262C3D) : Colors.black.withValues(alpha: 0.12)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alıcının Masadaki Teklifi',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(offer.offeredAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF00E575),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: diffPercent > 10
                  ? const Color(0xFFEF4444).withValues(alpha: isDark ? 0.20 : 0.12)
                  : const Color(0xFFFFDE59).withValues(alpha: isDark ? 0.20 : 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: diffPercent > 10 ? const Color(0xFFEF4444) : Colors.black,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  diffPercent > 10 ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: diffPercent > 10 ? const Color(0xFFEF4444) : (isDark ? const Color(0xFFFFDE59) : Colors.black),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    diffPercent > 0
                        ? 'İlan fiyatının %${diffPercent.toStringAsFixed(1)} altında teklif sunuldu'
                        : 'İlan fiyatının üzerinde cömert teklif sunuldu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: diffPercent > 10
                          ? const Color(0xFFEF4444)
                          : (isDark ? const Color(0xFFFFDE59) : Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerPsychologyCard({
    required CustomerModel customer,
    required OfferModel offer,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      shadowColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38BDF8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      child: const Icon(Icons.psychology_rounded, size: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Alıcı Profili & Psikoloji Radarı',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  customer.archetypeTitle,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Buyer Name & Message Dossier Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1B202D) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 18, color: Color(0xFFFFDE59)),
                    const SizedBox(width: 6),
                    Text(
                      offer.buyerName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  offer.buyerMessage.isNotEmpty
                      ? '"${offer.buyerMessage}"'
                      : '"Aracınızı yakından inceledim, ciddi alıcıyım."',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Psychology Metrics Row
          Row(
            children: [
              Expanded(
                child: _buildPsychologyBlock(
                  label: 'Pazarlık Direnci',
                  value: customer.archetype == CustomerArchetype.greedyFlipper
                      ? 'Yüksek'
                      : (customer.archetype == CustomerArchetype.skepticalOfficial ? 'Titiz' : 'Dengeli'),
                  color: customer.archetype == CustomerArchetype.greedyFlipper
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF00E575),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPsychologyBlock(
                  label: 'Bütçe Esnekliği',
                  value: customer.archetype == CustomerArchetype.impatientYouth
                      ? 'Cömert'
                      : (customer.archetype == CustomerArchetype.greedyFlipper ? 'Sıkı' : 'Esnek'),
                  color: customer.archetype == CustomerArchetype.impatientYouth
                      ? const Color(0xFF00E575)
                      : const Color(0xFFFFDE59),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPsychologyBlock(
                  label: 'Karar Acelesi',
                  value: customer.archetype == CustomerArchetype.impatientYouth ? 'Aceleci' : 'Sakin',
                  color: customer.archetype == CustomerArchetype.impatientYouth
                      ? const Color(0xFFFFDE59)
                      : const Color(0xFF38BDF8),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPsychologyBlock({
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(1.5, 1.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThinkingRadarCard({required bool isDark}) {
    String stageLabel = 'AŞAMA $_thinkingStage/3 • ';
    if (_thinkingStage == 1) {
      stageLabel += 'İLK TEPKİ & İNCELEME';
    } else if (_thinkingStage == 2) {
      stageLabel += 'BÜTÇE & İSTİŞARE';
    } else {
      stageLabel += 'SON KARAR';
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFFEFCE8),
      borderColor: const Color(0xFFFFDE59),
      borderWidth: 2.2,
      borderRadius: 12,
      shadowOffset: const Offset(3.5, 3.5),
      child: Row(
        children: [
          const PulsingDot(color: Color(0xFFFFDE59), size: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const NeoBrutalBadge(
                      text: 'ALICI RADARI',
                      backgroundColor: Color(0xFFFFDE59),
                      textColor: Colors.black,
                      borderWidth: 1.5,
                      fontSize: 8.5,
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        stageLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterOfferDesk({
    required CarModel car,
    required OfferModel offer,
    required double minOfferPrice,
    required double maxOfferPrice,
    required double progressRatio,
    required int remainingCounters,
    required bool isDark,
  }) {
    Color tensionColor;
    String tensionText;
    int activeTensionBlocks;

    if (progressRatio <= 0.20) {
      tensionColor = const Color(0xFF00E575);
      tensionText = 'Yumuşak Karşı Teklif • Yüksek Kabul İhtimali';
      activeTensionBlocks = 2;
    } else if (progressRatio <= 0.55) {
      tensionColor = const Color(0xFFFFDE59);
      tensionText = 'Dengeli Karşı Teklif • Klasik Esnaf Uzlaşması';
      activeTensionBlocks = 4;
    } else if (progressRatio <= 0.85) {
      tensionColor = const Color(0xFFF97316);
      tensionText = 'Sert Pazarlık • Alıcıyı Zorlayabilir';
      activeTensionBlocks = 5;
    } else {
      tensionColor = const Color(0xFFEF4444);
      tensionText = 'Tavizsiz Duruş • Masadan Kalkma Riski Yüksek';
      activeTensionBlocks = 6;
    }

    final isDeskLocked = _isThinking || _isProcessing;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      shadowColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDE59),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.black, width: 1.8),
                      ),
                      child: const Icon(Icons.handshake_rounded, size: 18, color: Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Karşı Teklif & Gerilim Masası',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: remainingCounters <= 1 ? const Color(0xFFEF4444) : const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  'Kalan Hak: $remainingCounters',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Price Counter Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Karşı Teklif Tutarınız:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 2.0),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  CurrencyFormatter.format(_counterTargetPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Custom Neo-Brutalist Potentiometer Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: tensionColor,
              inactiveTrackColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
              trackHeight: 10,
              trackShape: const NeoBrutalSliderTrackShape(trackBorderWidth: 2.0, trackBorderColor: Colors.black),
              thumbShape: NeoBrutalRectangularThumbShape(
                thumbWidth: 20.0,
                thumbHeight: 26.0,
                fillColor: tensionColor,
                borderColor: Colors.black,
                borderWidth: 2.2,
                shadowOffsetDistance: 2.0,
              ),
              overlayColor: tensionColor.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _counterTargetPrice,
              min: minOfferPrice,
              max: maxOfferPrice,
              onChanged: isDeskLocked
                  ? null
                  : (val) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _counterTargetPrice = (val / 1000).round() * 1000.0;
                      });
                    },
            ),
          ),

          // Segmented Arcade Tension Meter
          SegmentedArcadeGauge(
            totalSegments: 6,
            activeSegments: activeTensionBlocks,
            activeColor: tensionColor,
            height: 12,
            gap: 4,
          ),
          const SizedBox(height: 10),

          // Tension Status Text Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: tensionColor.withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 18, color: tensionColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    tensionText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Gap Preset Chunky Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildGapPresetChip(
                label: '%25 Yakın',
                target: minOfferPrice + (maxOfferPrice - minOfferPrice) * 0.25,
                isDark: isDark,
              ),
              _buildGapPresetChip(
                label: '%50 Orta Yol',
                target: minOfferPrice + (maxOfferPrice - minOfferPrice) * 0.50,
                isDark: isDark,
              ),
              _buildGapPresetChip(
                label: '%75 Sert',
                target: minOfferPrice + (maxOfferPrice - minOfferPrice) * 0.75,
                isDark: isDark,
              ),
              _buildGapPresetChip(
                label: 'Liste Fiyatı',
                target: maxOfferPrice,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tactical Arguments
          if (_dynamicTactics.isNotEmpty) ...[
            Text(
              'Esnaf Pazarlık Taktikleri',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 8),
            ..._dynamicTactics.map((tactic) {
              final isSelected = _selectedStrategyId == tactic.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: isDeskLocked
                      ? null
                      : () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedStrategyId = tactic.id);
                        },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFFDE59).withValues(alpha: isDark ? 0.25 : 0.20)
                          : (isDark ? const Color(0xFF1B202D) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.black : (isDark ? const Color(0xFF333B4F) : Colors.black.withValues(alpha: 0.4)),
                        width: isSelected ? 2.2 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(2.5, 2.5),
                                blurRadius: 0,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFFFDE59) : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.8),
                          ),
                          child: Icon(
                            isSelected ? Icons.check_rounded : null,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tactic.title,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tactic.description,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildGapPresetChip({
    required String label,
    required double target,
    required bool isDark,
  }) {
    final isSelected = (_counterTargetPrice - target).abs() < 500;
    final isDeskLocked = _isThinking || _isProcessing;

    return GestureDetector(
      onTap: isDeskLocked
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() {
                _counterTargetPrice = (target / 1000).round() * 1000.0;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFDE59)
              : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ]
              : [
                  BoxShadow(
                    color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.35),
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }

  Widget _buildNotarySettlementCard({
    required CarModel car,
    required double targetPrice,
    required bool isDark,
  }) {
    const double notaryFee = 1250.0;
    final double netProfit = targetPrice - car.totalCost - notaryFee;
    final isProfitable = netProfit >= 0;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141721) : const Color(0xFFFBFBF9),
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      shadowColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E575),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: const Icon(Icons.receipt_long_rounded, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Noter & Kâr Hesaplaşma Önizlemesi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSettlementRow('Satış Bedeli', CurrencyFormatter.format(targetPrice), isDark),
          _buildSettlementRow('Araç Alış Maliyeti', '-${CurrencyFormatter.format(car.currentPurchasePrice)}', isDark, isNegative: true),
          if (car.maintenanceCost > 0)
            _buildSettlementRow('Bakım ve Onarım Masrafı', '-${CurrencyFormatter.format(car.maintenanceCost)}', isDark, isNegative: true),
          _buildSettlementRow('Tahmini Noter Harcı', '-${CurrencyFormatter.format(notaryFee)}', isDark, isNegative: true),
          const SizedBox(height: 10),
          Container(
            height: 2,
            color: isDark ? const Color(0xFF262C3D) : Colors.black.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Tahmini Net Galeri Kârı:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isProfitable ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      offset: Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  '${isProfitable ? '+' : ''}${CurrencyFormatter.format(netProfit)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementRow(String label, String value, bool isDark, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isNegative
                  ? (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626))
                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionDock({
    required CarModel car,
    required OfferModel offer,
    required CustomerModel customer,
    required int remainingCounters,
    required bool isDark,
  }) {
    final isActionDisabled = _isProcessing || _isThinking;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        border: const Border(
          top: BorderSide(
            color: Colors.black,
            width: 2.5,
          ),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          // Reject Button
          Expanded(
            flex: 1,
            child: NeoBrutalButton(
              label: context.tr('btn_reject'),
              backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
              textColor: const Color(0xFFEF4444),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              borderWidth: 2.0,
              shadowOffset: const Offset(2.5, 2.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: isActionDisabled
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectOffer(offer.id);
                      NotificationService.showWarning(context, '${offer.buyerName} teklifi reddedildi.');
                      context.pop();
                    },
            ),
          ),
          const SizedBox(width: 8),

          // Send Counter Offer Button
          if (remainingCounters > 0) ...[
            Expanded(
              flex: 2,
              child: NeoBrutalButton(
                label: _isThinking ? 'DEĞERLENDİRİLİYOR...' : 'Karşı Teklif Gönder',
                icon: _isThinking ? Icons.hourglass_top_rounded : Icons.send_rounded,
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                borderWidth: 2.0,
                shadowOffset: const Offset(2.5, 2.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
                onPressed: isActionDisabled
                    ? null
                    : () {
                        _handleSendCounterOffer(car, offer, customer);
                      },
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Accept and Proceed to Notary Button
          Expanded(
            flex: 2,
            child: NeoBrutalButton(
              label: 'Kabul Et & Sat',
              icon: Icons.check_circle_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              borderWidth: 2.0,
              shadowOffset: const Offset(2.5, 2.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: isActionDisabled
                  ? null
                  : () {
                      _handleAcceptOffer(car, offer, customer);
                    },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendCounterOffer(CarModel car, OfferModel offer, CustomerModel customer) async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isProcessing = true;
      _isThinking = true;
      _thinkingStage = 1;
    });

    final random = Random();
    final stages = NegotiationSuspenseEngine.getSellingSuspenseStages(
      archetype: customer.archetype,
      offerType: offer.offerType,
      rng: random,
    );

    final durations =
        NegotiationSuspenseEngine.generateRandomStageDurations(rng: random);

    // Stage 1: Initial reaction & appraisal (800ms - 1300ms)
    setState(() {
      _thinkingText = stages[0];
      _thinkingStage = 1;
    });
    HapticFeedback.selectionClick();
    await Future.delayed(Duration(milliseconds: durations[0]));
    if (!mounted) return;

    // Stage 2: Deep calculation & consultation (1000ms - 1700ms)
    setState(() {
      _thinkingText = stages[1];
      _thinkingStage = 2;
    });
    HapticFeedback.mediumImpact();
    GameSoundHapticService.playTapImpact();
    await Future.delayed(Duration(milliseconds: durations[1]));
    if (!mounted) return;

    // Stage 3: Final posture & verdict (800ms - 1400ms)
    setState(() {
      _thinkingText = stages[2];
      _thinkingStage = 3;
    });
    HapticFeedback.heavyImpact();
    await Future.delayed(Duration(milliseconds: durations[2]));
    if (!mounted) return;

    final outcome = ref.read(gameProvider.notifier).counterOffer(
          offer.id,
          _counterTargetPrice,
          strategy: _selectedStrategyId,
        );

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isThinking = false;
    });

    if (outcome.isAccepted) {
      GameSoundHapticService.playCashSuccess();
      NotificationService.showSuccess(context, outcome.responseMessage);
      if (mounted && Navigator.of(context).canPop()) {
        context.pop();
      }
    } else if (outcome.isWalkaway) {
      GameSoundHapticService.playWarningVibration();
      NotificationService.showError(context, outcome.responseMessage);
      if (mounted && Navigator.of(context).canPop()) {
        context.pop();
      }
    } else {
      NotificationService.showInfo(context, outcome.responseMessage);
      if (mounted && Navigator.of(context).canPop()) {
        context.pop();
      }
    }
  }

  void _handleAcceptOffer(CarModel car, OfferModel offer, CustomerModel customer) {
    GameSoundHapticService.playNotaryStamp();
    final fraudResult = NegotiationEngine.evaluatePlayerFraudInspection(
      car: car,
      customer: customer,
    );

    if (fraudResult.caughtFraud) {
      ref.read(gameProvider.notifier).acceptOfferWithFraudCheck(offer, customer);
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: Colors.white,
              borderColor: AppColors.errorRed,
              borderRadius: 12,
              borderWidth: 2.5,
              shadowOffset: const Offset(4, 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const VectorIconWidget(type: 'error', color: AppColors.errorRed, size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fraudResult.title,
                          style: const TextStyle(
                            color: AppColors.errorRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${fraudResult.description}\n\n'
                    '${context.tr('fine_penalty_label', {'amount': CurrencyFormatter.formatShort(fraudResult.fineAmount)})}\n'
                    '${context.tr('reputation_loss_label', {'points': fraudResult.reputationPenalty.toString()})}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NeoBrutalButton(
                      label: context.tr('ok_button'),
                      backgroundColor: AppColors.errorRed,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
      return;
    }

    final wasTutorial = !ref.read(gameProvider).tutorialCompleted;
    final notaryResult = ref.read(gameProvider.notifier).processNotarySale(offer, customer);

    if (mounted) {
      NotaryTransferDialog.show(
        context: context,
        car: car,
        buyerName: offer.buyerName,
        sellerName: ref.read(gameProvider).dealershipName,
        salePrice: offer.offeredAmount,
        isBuying: false,
        eventResult: notaryResult,
        onComplete: () async {
          if (wasTutorial && mounted) {
            _showTutorialCelebrationDialog(context);
          } else {
            final isProfitable = offer.offeredAmount > car.purchasePrice;
            if (isProfitable && mounted) {
              await RateUsRewardDialog.checkAndShow(context, ref);
            }
            if (mounted) {
              context.pop();
            }
          }
        },
      );
    }
  }

  void _showTutorialCelebrationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: const Color(0xFF141721),
          borderColor: const Color(0xFFFFDE59),
          borderRadius: 14,
          borderWidth: 3.0,
          shadowOffset: const Offset(5, 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 36,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('tut_celebration_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('tut_celebration_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              NeoBrutalButton(
                label: context.tr('tut_celebration_btn'),
                icon: Icons.arrow_forward_rounded,
                fullWidth: true,
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
