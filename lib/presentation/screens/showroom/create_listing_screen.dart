import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/industrial_rocker_switch.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/neo_brutal_segmented_gauge.dart';
import '../../widgets/neo_brutal_slider.dart';
import '../../widgets/tutorial_pulse_target.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final CarModel car;

  const CreateListingScreen({
    super.key,
    required this.car,
  });

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  late double _selectedPrice;
  late ListingDeclarationType _declaration;
  late String _photoLocation;
  late int _photoCount;
  late String _listingTone;
  late bool _hideDamagedPhotos;
  late bool _allowsInstallments;

  @override
  void initState() {
    super.initState();
    final car = widget.car;
    _selectedPrice = car.customListingPrice ?? car.estimatedRealValue;
    _declaration = car.declarationType;
    _photoLocation = car.listingPhotoLocation.isNotEmpty ? car.listingPhotoLocation : 'lot';
    _photoCount = car.listingPhotoCount > 0 ? car.listingPhotoCount : 4;
    _listingTone = (car.listingTone == 'standard' || car.listingTone == 'friendly' || car.listingTone == 'vip')
        ? car.listingTone
        : 'standard';
    _hideDamagedPhotos = car.hideDamagedPhotos;
    _allowsInstallments = car.allowsInstallments;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);

    final currentCarIndex = game.ownedCars.indexWhere((c) => c.id == widget.car.id);
    final activeCar = currentCarIndex != -1 ? game.ownedCars[currentCarIndex] : widget.car;

    final double minPrice = (activeCar.currentPurchasePrice * 0.75).clamp(10000.0, activeCar.estimatedRealValue * 0.9);
    final double maxPrice = (activeCar.estimatedRealValue * 1.65).roundToDouble();
    final double clampedPrice = _selectedPrice.clamp(minPrice, maxPrice);

    final double profitAmount = clampedPrice - activeCar.currentPurchasePrice;
    final double profitMarginPercent = activeCar.currentPurchasePrice > 0
        ? (profitAmount / activeCar.currentPurchasePrice) * 100
        : 0.0;

    final double priceRatio = activeCar.estimatedRealValue > 0
        ? clampedPrice / activeCar.estimatedRealValue
        : 1.0;

    final isFinanceUnlocked = game.isFeatureUnlocked('/finance');

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('title_create_listing'),
        actions: [
          IconButton(
            tooltip: context.tr('btn_reset_price'),
            icon: const Icon(Icons.restart_alt_rounded, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _selectedPrice = activeCar.estimatedRealValue;
              });
              NotificationService.showInfo(context, context.tr('toast_price_reset_market'));
            },
          ),
        ],
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.dealership,
        child: Stack(
          children: [
            SafeArea(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 100 + MediaQuery.paddingOf(context).bottom),
                physics: const BouncingScrollPhysics(),
                children: [
                  // 1. Vehicle Header Overview Card
                  _buildVehicleHeaderCard(activeCar, isDark),
                  const SizedBox(height: 16),

                  // 2. Interactive Pricing & Profit Margin Calculator
                  _buildPricingSection(
                    activeCar: activeCar,
                    clampedPrice: clampedPrice,
                    minPrice: minPrice,
                    maxPrice: maxPrice,
                    profitAmount: profitAmount,
                    profitMarginPercent: profitMarginPercent,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 3. Market Demand & Sales Velocity Index (Arcade Segmented Gauge)
                  _buildMarketDemandSection(
                    activeCar: activeCar,
                    priceRatio: priceRatio,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),

                  // 4. Showcase Packages (Vitrin Paketleri)
                  _buildShowcasePackagesSection(
                    activeCar: activeCar,
                    isDark: isDark,
                    gameBalance: game.balance,
                  ),
                  const SizedBox(height: 16),

                  // 5. Listing Presentation & Declaration
                  _buildListingDetailsSection(
                    activeCar: activeCar,
                    isFinanceUnlocked: isFinanceUnlocked,
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
              child: _buildBottomPublishBar(activeCar, clampedPrice, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHeaderCard(CarModel car, bool isDark) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF384259) : Colors.black,
      borderRadius: 12,
      borderWidth: 2.5,
      shadowOffset: const Offset(4, 4),
      shadowColor: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '${car.brand} ${car.modelName}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${car.modelYear} • ${car.bodyType} • ${car.plateNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                  car.colorDisplayName.isNotEmpty ? car.colorDisplayName : car.colorHex,
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
                child: _buildHeaderMetricItem(
                  title: context.tr('label_purchase_cost'),
                  value: CurrencyFormatter.format(car.currentPurchasePrice),
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  isDark: isDark,
                ),
              ),
              Container(
                width: 2,
                height: 34,
                color: isDark ? const Color(0xFF262C3D) : Colors.black.withValues(alpha: 0.12),
              ),
              Expanded(
                child: _buildHeaderMetricItem(
                  title: context.tr('label_market_est_val'),
                  value: CurrencyFormatter.format(car.estimatedRealValue),
                  color: const Color(0xFF00E575),
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMetricItem({
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection({
    required CarModel activeCar,
    required double clampedPrice,
    required double minPrice,
    required double maxPrice,
    required double profitAmount,
    required double profitMarginPercent,
    required bool isDark,
  }) {
    final isProfitable = profitAmount >= 0;

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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDE59),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: const Icon(Icons.price_change_rounded, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('listing_asking_price_title'),
                  style: TextStyle(
                    fontSize: 14,
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
                  CurrencyFormatter.format(clampedPrice),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Neo-Brutalist Potentiometer Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: const Color(0xFFFFDE59),
              inactiveTrackColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
              trackHeight: 10,
              trackShape: const NeoBrutalSliderTrackShape(trackBorderWidth: 2.0, trackBorderColor: Colors.black),
              thumbShape: const NeoBrutalRectangularThumbShape(
                thumbWidth: 20.0,
                thumbHeight: 26.0,
                fillColor: Color(0xFFFFDE59),
                borderColor: Colors.black,
                borderWidth: 2.2,
                shadowOffsetDistance: 2.0,
              ),
              overlayColor: const Color(0xFFFFDE59).withValues(alpha: 0.2),
            ),
            child: Slider(
              value: clampedPrice,
              min: minPrice,
              max: maxPrice,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedPrice = (val / 1000).round() * 1000.0;
                });
              },
            ),
          ),

          // Min / Max range labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.formatShort(minPrice),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E575).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFF00E575), width: 1.2),
                    ),
                    child: Text(
                      '${context.tr('label_market_val')}: ${CurrencyFormatter.formatShort(activeCar.estimatedRealValue)}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E575),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.formatShort(maxPrice),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Quick Percentage Preset Chunky Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPricePresetChip(
                label: '-5% • Hızlı',
                targetPrice: (activeCar.estimatedRealValue * 0.95),
                isDark: isDark,
              ),
              _buildPricePresetChip(
                label: 'Piyasa Emsali',
                targetPrice: activeCar.estimatedRealValue,
                isDark: isDark,
              ),
              _buildPricePresetChip(
                label: '+10% • Dengeli',
                targetPrice: (activeCar.estimatedRealValue * 1.10),
                isDark: isDark,
              ),
              _buildPricePresetChip(
                label: '+20% • Kârlı',
                targetPrice: (activeCar.estimatedRealValue * 1.20),
                isDark: isDark,
              ),
              _buildPricePresetChip(
                label: '+35% • VIP',
                targetPrice: (activeCar.estimatedRealValue * 1.35),
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tactile Net Profit Ledger Card (Kâr & Borsa Fişi)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181C26) : const Color(0xFFFBFBF9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(3, 3),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isProfitable ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 1.8),
                  ),
                  child: Icon(
                    isProfitable ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isProfitable ? context.tr('label_est_profit') : context.tr('label_est_loss'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${isProfitable ? '+' : ''}${CurrencyFormatter.format(profitAmount)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                          color: isProfitable ? const Color(0xFF00E575) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                    '${isProfitable ? '+' : ''}${profitMarginPercent.toStringAsFixed(1)}% Marj',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
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

  Widget _buildPricePresetChip({
    required String label,
    required double targetPrice,
    required bool isDark,
  }) {
    final isSelected = (_selectedPrice - targetPrice).abs() < 500;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedPrice = (targetPrice / 1000).round() * 1000.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                    color: isDark ? Colors.black : Colors.black.withValues(alpha: 0.4),
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
            letterSpacing: -0.2,
            color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketDemandSection({
    required CarModel activeCar,
    required double priceRatio,
    required bool isDark,
  }) {
    String demandStatus;
    String sellTimeText;
    Color demandColor;
    int activeSegments;

    if (priceRatio <= 0.98) {
      demandStatus = 'Yüksek Talep • Hızlı Alıcı Çekimi';
      sellTimeText = '1 - 2 Gün';
      demandColor = const Color(0xFF00E575);
      activeSegments = 6;
    } else if (priceRatio <= 1.15) {
      demandStatus = 'Dengeli Talep • Normal Piyasa Akışı';
      sellTimeText = '3 - 5 Gün';
      demandColor = const Color(0xFFFFDE59);
      activeSegments = 4;
    } else {
      demandStatus = 'Düşük Talep • Tok Satıcı Pozisyonu';
      sellTimeText = '7+ Gün';
      demandColor = const Color(0xFFEF4444);
      activeSegments = 2;
    }

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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: const Icon(Icons.speed_rounded, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.tr('label_market_demand'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: demandColor,
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
                  sellTimeText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Arcade Segmented Gauge Meter
          SegmentedArcadeGauge(
            totalSegments: 6,
            activeSegments: activeSegments,
            activeColor: demandColor,
            height: 14,
            gap: 5,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: demandColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  demandStatus,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: demandColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShowcasePackagesSection({
    required CarModel activeCar,
    required bool isDark,
    required double gameBalance,
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: const Icon(Icons.campaign_rounded, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vitrin & Tanıtım Paketleri',
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
          const SizedBox(height: 14),

          // Standard Package
          _buildPackageTile(
            title: 'Standart İlan',
            subtitle: 'Ücretsiz • Standart pazar görünürlüğü',
            isActive: !activeCar.isDoped && !activeCar.isHeroShowcase,
            actionLabel: 'Aktif',
            badgeColor: const Color(0xFF94A3B8),
            isDark: isDark,
            onTap: null,
          ),
          const SizedBox(height: 10),

          // Doping Package
          _buildPackageTile(
            title: 'Acil İlan • Doping',
            subtitle: '+%50 daha hızlı organik müşteri teklifi',
            isActive: activeCar.isDoped,
            actionLabel: activeCar.isDoped ? 'Dopingli' : '₺${CurrencyFormatter.formatShort(GameConstants.dopingCost)} Uygula',
            badgeColor: const Color(0xFFFFDE59),
            isDark: isDark,
            onTap: activeCar.isDoped
                ? null
                : () {
                    HapticFeedback.mediumImpact();
                    final success = ref.read(gameProvider.notifier).boostListingDoping(activeCar.id);
                    if (success) {
                      NotificationService.showSuccess(context, 'Doping başarıyla uygulandı!');
                    } else {
                      NotificationService.showError(context, 'Yetersiz bakiye!');
                    }
                  },
          ),
          const SizedBox(height: 10),

          // Hero Showcase Package with Industrial Rocker Switch
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: activeCar.isHeroShowcase
                  ? const Color(0xFFA855F7).withValues(alpha: isDark ? 0.20 : 0.15)
                  : (isDark ? const Color(0xFF1B202D) : const Color(0xFFF8FAFC)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: activeCar.isHeroShowcase ? Colors.black : (isDark ? const Color(0xFF333B4F) : Colors.black.withValues(alpha: 0.5)),
                width: 2.0,
              ),
              boxShadow: activeCar.isHeroShowcase
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Color(0xFFA855F7)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Vitrin Yıldızı • Hero Slot',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Ana vitrinde dev afiş • VIP müşterileri çeker',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IndustrialRockerSwitch(
                  value: activeCar.isHeroShowcase,
                  onLabel: 'VİTRİN',
                  offLabel: 'STANDART',
                  activeColor: const Color(0xFFA855F7),
                  inactiveColor: isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
                  width: 95,
                  height: 32,
                  onChanged: (val) {
                    final ok = ref.read(gameProvider.notifier).toggleHeroShowcase(activeCar.id);
                    if (!ok) {
                      NotificationService.showWarning(context, 'Vitrin slotu değiştirilemedi.');
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTile({
    required String title,
    required String subtitle,
    required bool isActive,
    required String actionLabel,
    required Color badgeColor,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? badgeColor.withValues(alpha: isDark ? 0.20 : 0.15)
            : (isDark ? const Color(0xFF1B202D) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.black : (isDark ? const Color(0xFF333B4F) : Colors.black.withValues(alpha: 0.5)),
          width: 2.0,
        ),
        boxShadow: isActive
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            NeoBrutalButton(
              label: actionLabel,
              backgroundColor: isActive ? badgeColor : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
              textColor: isActive ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
              fontSize: 11,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              shadowOffset: const Offset(2, 2),
              onPressed: onTap,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListingDetailsSection({
    required CarModel activeCar,
    required bool isFinanceUnlocked,
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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E575),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.black, width: 1.8),
                ),
                child: const Icon(Icons.tune_rounded, size: 18, color: Colors.black),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'İlan Beyanı & Esnaf Sunumu',
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
          const SizedBox(height: 14),

          // 1. Declaration Type
          Text(
            'Ekspertiz Dürüstlük Beyanı',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'Dürüst & Şeffaf',
                isSelected: _declaration == ListingDeclarationType.honest,
                isDark: isDark,
                onTap: () => setState(() => _declaration = ListingDeclarationType.honest),
              ),
              _buildChoiceChip(
                label: 'Ufak Kusurları Gizle',
                isSelected: _declaration == ListingDeclarationType.minorFlawHidden,
                isDark: isDark,
                onTap: () => setState(() => _declaration = ListingDeclarationType.minorFlawHidden),
              ),
              _buildChoiceChip(
                label: 'Hatasız İddiası',
                isSelected: _declaration == ListingDeclarationType.flawlessClaim,
                isDark: isDark,
                onTap: () => setState(() => _declaration = ListingDeclarationType.flawlessClaim),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Listing Tone
          Text(
            'İlan Başlığı & Dil Tonu',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'Standart İlan',
                isSelected: _listingTone == 'standard',
                isDark: isDark,
                onTap: () => setState(() => _listingTone = 'standard'),
              ),
              _buildChoiceChip(
                label: 'Samimi Esnaf Ağzı',
                isSelected: _listingTone == 'friendly',
                isDark: isDark,
                onTap: () => setState(() => _listingTone = 'friendly'),
              ),
              _buildChoiceChip(
                label: 'Kurumsal VIP Plaza',
                isSelected: _listingTone == 'vip',
                isDark: isDark,
                onTap: () => setState(() => _listingTone = 'vip'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Photo Shoot Selection
          Text(
            'İlan Fotoğraf Çekimi',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChoiceChip(
                label: 'Galeri Önü • Ücretsiz',
                isSelected: _photoLocation == 'lot',
                isDark: isDark,
                onTap: () => setState(() => _photoLocation = 'lot'),
              ),
              _buildChoiceChip(
                label: 'Profesyonel Stüdyo • ₺1.500',
                isSelected: _photoLocation == 'studio',
                isDark: isDark,
                onTap: () => setState(() => _photoLocation = 'studio'),
              ),
              _buildChoiceChip(
                label: 'Manzaralı Çekim • ₺800',
                isSelected: _photoLocation == 'scenic',
                isDark: isDark,
                onTap: () => setState(() => _photoLocation = 'scenic'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Checkbox toggles
          _buildToggleRow(
            title: 'Hasarlı Parça Görsellerini Gizle',
            subtitle: 'Kusurlu kaporta parçalarını ilk bakışta gösterme',
            value: _hideDamagedPhotos,
            isDark: isDark,
            onChanged: (val) => setState(() => _hideDamagedPhotos = val),
          ),

          if (isFinanceUnlocked) ...[
            const SizedBox(height: 10),
            _buildToggleRow(
              title: 'Taksitli & Senetli Satışa İzin Ver',
              subtitle: 'Finansman faizi kazanarak taksitle sat',
              value: _allowsInstallments,
              isDark: isDark,
              onChanged: (val) => setState(() => _allowsInstallments = val),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00E575)
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
                    offset: Offset(2, 2),
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

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required bool value,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: value
              ? const Color(0xFF00E575).withValues(alpha: isDark ? 0.15 : 0.10)
              : (isDark ? const Color(0xFF1B202D) : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: value ? Colors.black : (isDark ? const Color(0xFF333B4F) : Colors.black.withValues(alpha: 0.4)),
            width: 2.0,
          ),
          boxShadow: value
              ? const [
                  BoxShadow(
                    color: Colors.black,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: value ? const Color(0xFF00E575) : (isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black, width: 1.8),
              ),
              child: Icon(
                value ? Icons.check_rounded : null,
                color: Colors.black,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPublishBar(
    CarModel activeCar,
    double clampedPrice,
    bool isDark,
  ) {
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
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: TutorialPulseTarget(
        isEnabled: !ref.watch(gameProvider).tutorialCompleted &&
            activeCar.id == 'car_heritage_dede',
        pulseColor: const Color(0xFFFFDE59),
        child: NeoBrutalButton(
          label: context.tr('btn_save_listing_details'),
          icon: Icons.publish_rounded,
          backgroundColor: const Color(0xFFFFDE59),
          textColor: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          fullWidth: true,
          borderWidth: 2.5,
          shadowOffset: const Offset(3.5, 3.5),
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(gameProvider.notifier).updateCarListingDetails(
                  activeCar.id,
                  customPrice: clampedPrice,
                  declaration: _declaration,
                  listingPhotoLocation: _photoLocation,
                  listingPhotoCount: _photoCount,
                  listingTone: _listingTone,
                  hideDamagedPhotos: _hideDamagedPhotos,
                  allowsInstallments: _allowsInstallments,
                );
            NotificationService.showSuccess(
              context,
              context.tr('toast_listing_updated_success'),
            );
            context.pop();
          },
        ),
      ),
    );
  }
}
