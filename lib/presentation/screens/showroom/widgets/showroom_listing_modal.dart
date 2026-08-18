import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/offer_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class ShowroomListingModal {
  // =========================================================================
  // 1. KARŞI TEKLİF SUN MODAL (COUNTER OFFER SHEET)
  // =========================================================================
  static void showCounterOfferSheet(BuildContext context, WidgetRef ref, OfferModel offer, CarModel car) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette ?? ThemePaletteModel.defaultPalettes.first;
    final isDark = p.isDark;
    double targetPrice = (offer.offeredAmount * 1.08).roundToDouble();
    String selectedStrategy = 'ikna_et';

    final remainingCounters = offer.maxCounters - offer.counterCount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        side: BorderSide(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.brutalYellow,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                  width: 2.0,
                                ),
                              ),
                              child: const Icon(Icons.handshake_rounded, size: 20, color: Colors.black),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'KARŞI TEKLİF SUN',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  '${offer.buyerName} ile Pazarlık Masası',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        NeoBrutalBadge(
                          text: '$remainingCounters / ${offer.maxCounters} HAK',
                          icon: Icons.repeat_rounded,
                          backgroundColor: remainingCounters <= 1 ? AppColors.errorRed : AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 11,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price Card
                    NeoBrutalCard(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      borderRadius: 12,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alıcının Teklifi',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(offer.offeredAmount),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Senin Karşı Teklifin',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.brutalGreen : const Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(targetPrice),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.brutalGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.brutalGreen,
                              inactiveTrackColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                              thumbColor: AppColors.brutalYellow,
                              overlayColor: AppColors.brutalYellow.withValues(alpha: 0.2),
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10, elevation: 2),
                            ),
                            child: Slider(
                              value: targetPrice.clamp(offer.offeredAmount, (car.estimatedRealValue * 1.25).roundToDouble()),
                              min: offer.offeredAmount,
                              max: (car.estimatedRealValue * 1.25).roundToDouble(),
                              divisions: 40,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  targetPrice = val.roundToDouble();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Strategy Choices
                    Row(
                      children: [
                        const Icon(Icons.psychology_rounded, size: 16, color: AppColors.brutalCyan),
                        const SizedBox(width: 6),
                        Text(
                          'PAZARLIK YAKLAŞIMI / STRATEJİSİ',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.brutalCyan : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTactileStrategyCard(
                            icon: Icons.search_rounded,
                            label: 'Şeffaflık',
                            subtitle: '+%20 İkna Bonusu',
                            isSelected: selectedStrategy == 'ikna_et',
                            activeColor: AppColors.brutalGreen,
                            onTap: () => setState(() => selectedStrategy = 'ikna_et'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTactileStrategyCard(
                            icon: Icons.coffee_rounded,
                            label: 'Çay İkramı',
                            subtitle: 'Esnaf Sıcaklığı',
                            isSelected: selectedStrategy == 'duyguya_oyna',
                            activeColor: AppColors.brutalYellow,
                            onTap: () => setState(() => selectedStrategy = 'duyguya_oyna'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTactileStrategyCard(
                            icon: Icons.work_rounded,
                            label: 'Tok Satıcı',
                            subtitle: 'Gençleri Etkiler',
                            isSelected: selectedStrategy == 'sert_dur',
                            activeColor: AppColors.brutalOrange,
                            onTap: () => setState(() => selectedStrategy = 'sert_dur'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTactileStrategyCard(
                            icon: Icons.bolt_rounded,
                            label: 'Hızlı Kapat',
                            subtitle: 'Nakit İndirimi',
                            isSelected: selectedStrategy == 'hizli_kapat',
                            activeColor: AppColors.brutalCyan,
                            onTap: () => setState(() => selectedStrategy = 'hizli_kapat'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    NeoBrutalButton(
                      label: 'Karşı Teklifi İlet',
                      icon: Icons.send_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.pop(context);
                        final outcome = ref.read(gameProvider.notifier).counterOffer(
                              offer.id,
                              targetPrice,
                              strategy: selectedStrategy,
                            );
                        NotificationService.showSuccess(context, outcome.responseMessage);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // 2. İLAN AYARLARI & STRATEJİ MERKEZİ (LISTING EDIT SHEET)
  // =========================================================================
  static void showListingEditSheet(BuildContext context, WidgetRef ref, CarModel car) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final p = themeExt?.palette ?? ThemePaletteModel.defaultPalettes.first;
    final isDark = p.isDark;

    double selectedPrice = car.listingPrice > 0 ? car.listingPrice : (car.estimatedRealValue * 1.20).roundToDouble();
    ListingDeclarationType selectedDeclaration = car.declarationType;
    String selectedPhotoLocation = (car.listingPhotoLocation == 'dealership' || car.listingPhotoLocation == 'scenic' || car.listingPhotoLocation == 'studio')
        ? car.listingPhotoLocation
        : 'dealership';
    int selectedPhotoCount = (car.listingPhotoCount == 4 || car.listingPhotoCount == 8 || car.listingPhotoCount == 12)
        ? car.listingPhotoCount
        : 4;
    String selectedTone = (car.listingTone == 'standard' || car.listingTone == 'friendly' || car.listingTone == 'vip')
        ? car.listingTone
        : 'standard';
    bool hideDamagedPhotos = car.hideDamagedPhotos;
    bool allowsInstallments = car.allowsInstallments;

    final double minPrice = (car.currentPurchasePrice * 0.8).clamp(10000.0, car.estimatedRealValue);
    final double maxPrice = (car.estimatedRealValue * 1.6).roundToDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İLAN AYARLARI',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${car.brand} ${car.modelName} • ${car.modelYear}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              if (car.isDoped) ...[
                                const SizedBox(height: 4),
                                NeoBrutalBadge(
                                  text: 'DOPİNGLİ İLAN',
                                  icon: Icons.bolt_rounded,
                                  backgroundColor: AppColors.brutalGreen,
                                  textColor: Colors.black,
                                  fontSize: 10,
                                ),
                              ],
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2330) : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark ? Colors.black : const Color(0xFF0F172A),
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SECTION 1: PRICE & VALUATION SLIDER
                    Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, size: 16, color: AppColors.brutalYellow),
                        const SizedBox(width: 6),
                        Text(
                          'BELİRLENEN İLAN FİYATI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.brutalYellow : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Müşterilerin vereceği tüm teklifler belirlediğiniz bu fiyatın altında kalacaktır.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),

                    NeoBrutalCard(
                      padding: const EdgeInsets.all(14),
                      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      borderWidth: 2.0,
                      borderRadius: 14,
                      shadowOffset: const Offset(3.5, 3.5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'İlan Satış Fiyatı:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(selectedPrice),
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brutalGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              NeoBrutalBadge(
                                text: 'Piyasa Ekspertiz Değeri: ${CurrencyFormatter.formatShort(car.estimatedRealValue)}',
                                icon: Icons.speed_rounded,
                                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                                textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                                fontSize: 10,
                              ),
                              NeoBrutalBadge(
                                text: 'Çapa: %${((selectedPrice / car.estimatedRealValue) * 100).toInt()}',
                                icon: Icons.anchor_rounded,
                                backgroundColor: AppColors.brutalCyan,
                                textColor: Colors.black,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.brutalGreen,
                              inactiveTrackColor: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                              thumbColor: AppColors.brutalYellow,
                              overlayColor: AppColors.brutalYellow.withValues(alpha: 0.2),
                              trackHeight: 8,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11, elevation: 3),
                            ),
                            child: Slider(
                              value: selectedPrice.clamp(minPrice, maxPrice),
                              min: minPrice,
                              max: maxPrice,
                              divisions: 100,
                              onChanged: (val) {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  selectedPrice = (val / 1000).round() * 1000.0;
                                });
                              },
                            ),
                          ),

                          // Real-Time Inline Market Valuation & Buyer Interest Badge
                          Builder(
                            builder: (context) {
                              final double diffRatio = (selectedPrice - car.estimatedRealValue) / car.estimatedRealValue;
                              final double diffPct = diffRatio * 100;
                              Color badgeColor;
                              Color textColor;
                              IconData badgeIcon;
                              String badgeText;

                              if (diffPct <= -10) {
                                badgeColor = AppColors.brutalGreen;
                                textColor = Colors.black;
                                badgeIcon = Icons.bolt_rounded;
                                badgeText = '-%${diffPct.abs().toStringAsFixed(0)} FIRSAT FİYAT • Çok Hızlı Teklif';
                              } else if (diffPct <= 5) {
                                badgeColor = AppColors.brutalYellow;
                                textColor = Colors.black;
                                badgeIcon = Icons.balance_rounded;
                                badgeText = 'PİYASA DENGESİNDE • Normal Satış Hızı';
                              } else if (diffPct <= 20) {
                                badgeColor = AppColors.brutalOrange;
                                textColor = Colors.black;
                                badgeIcon = Icons.hourglass_bottom_rounded;
                                badgeText = '+%${diffPct.toStringAsFixed(0)} YÜKSEK FİYAT • Yavaş Satış';
                              } else {
                                badgeColor = AppColors.errorRed;
                                textColor = Colors.white;
                                badgeIcon = Icons.warning_amber_rounded;
                                badgeText = '+%${diffPct.toStringAsFixed(0)} RİSKLİ FİYAT • Riskli Fiyat';
                              }

                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(badgeIcon, size: 16, color: textColor),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        badgeText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 6),
                          // Preset Buttons with Neo-Brutal styling
                          Row(
                            children: [
                              Expanded(
                                child: _buildPresetPriceButton(
                                  label: 'Piyasa Değeri',
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => selectedPrice = car.estimatedRealValue.roundToDouble());
                                  },
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildPresetPriceButton(
                                  label: '+%10 Kâr',
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => selectedPrice = (car.estimatedRealValue * 1.10).roundToDouble());
                                  },
                                  isDark: isDark,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: _buildPresetPriceButton(
                                  label: '+%20 Tok Satıcı',
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() => selectedPrice = (car.estimatedRealValue * 1.20).roundToDouble());
                                  },
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // SECTION 2: PHOTO SHOOT LOCATION & QUALITY
                    Row(
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.brutalCyan),
                        const SizedBox(width: 6),
                        Text(
                          'FOTOĞRAF ÇEKİMİ & SUNUM SANATI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.brutalCyan : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTactileLocationCard(
                            title: 'Galeri Önü',
                            subtitle: 'Ücretsiz',
                            icon: Icons.storefront_rounded,
                            activeColor: AppColors.brutalYellow,
                            isSelected: selectedPhotoLocation == 'dealership',
                            onTap: () => setState(() => selectedPhotoLocation = 'dealership'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTactileLocationCard(
                            title: 'Manzaralı',
                            subtitle: '-₺800 • +%3 İlgi',
                            icon: Icons.landscape_rounded,
                            activeColor: AppColors.brutalCyan,
                            isSelected: selectedPhotoLocation == 'scenic',
                            onTap: () => setState(() => selectedPhotoLocation = 'scenic'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTactileLocationCard(
                            title: 'VIP Stüdyo',
                            subtitle: '-₺1.500 • +%5 İlgi',
                            icon: Icons.camera_rounded,
                            activeColor: AppColors.brutalPink,
                            isSelected: selectedPhotoLocation == 'studio',
                            onTap: () => setState(() => selectedPhotoLocation = 'studio'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Fotoğraf Adedi & İlan Tonu Dropdowns with Neo-Brutal Container
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fotoğraf Sayısı',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141721) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: selectedPhotoCount,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF161922) : Colors.white,
                                    icon: const Icon(Icons.arrow_drop_down_rounded, size: 28),
                                    items: const [
                                      DropdownMenuItem(value: 4, child: Text('4 Fotoğraf', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                                      DropdownMenuItem(value: 8, child: Text('8 Fotoğraf • +%2', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                                      DropdownMenuItem(value: 12, child: Text('12 Detaylı • +%4', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                                    ],
                                    onChanged: (val) => setState(() => selectedPhotoCount = val ?? 4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'İlan Tonu',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF141721) : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedTone,
                                    isExpanded: true,
                                    dropdownColor: isDark ? const Color(0xFF161922) : Colors.white,
                                    icon: const Icon(Icons.arrow_drop_down_rounded, size: 28),
                                    items: const [
                                      DropdownMenuItem(value: 'standard', child: Text('Standart', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                                      DropdownMenuItem(value: 'friendly', child: Text('Samimi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                                      DropdownMenuItem(value: 'vip', child: Text('VIP / Kurumsal', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                                    ],
                                    onChanged: (val) => setState(() => selectedTone = val ?? 'standard'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // SECTION 3: TACTILE TOGGLE CARDS (Senetle & Hasar Gizleme)
                    _buildTactileToggleRow(
                      title: 'Vadeli / Senet / Çek Satışına Aç',
                      subtitle: 'Vadeli senet ve çek tekliflerine izin ver • +%20 vade farkı. Kapalıyken SADECE %100 PEŞİN NAKİT teklif gelir.',
                      icon: Icons.payments_rounded,
                      isActive: allowsInstallments,
                      activeLabel: 'AÇIK • VADELİ/ÇEK',
                      inactiveLabel: 'SADECE NAKİT',
                      activeColor: AppColors.brutalGreen,
                      onToggle: () => setState(() => allowsInstallments = !allowsInstallments),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildTactileToggleRow(
                      title: 'Hasarlı Açıları Fotoğrafta Gizle',
                      subtitle: 'Kusurlu bölgeleri kadraj dışı bırak • Ekspertizde yakalanma riski',
                      icon: Icons.hide_image_rounded,
                      isActive: hideDamagedPhotos,
                      activeLabel: 'GİZLE • RİSKLİ',
                      inactiveLabel: 'ŞEFFAF & AÇIK',
                      activeColor: AppColors.brutalOrange,
                      onToggle: () => setState(() => hideDamagedPhotos = !hideDamagedPhotos),
                      isDark: isDark,
                    ),

                    const SizedBox(height: 18),

                    // SECTION 4: STRATEGIC DECLARATION CARDS
                    Row(
                      children: [
                        const Icon(Icons.gavel_rounded, size: 16, color: AppColors.brutalOrange),
                        const SizedBox(width: 6),
                        Text(
                          'İLAN BEYANI • STRATEJİK SEÇİM',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? AppColors.brutalOrange : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    _buildTactileDeclarationCard(
                      title: 'Dürüst İlan',
                      subtitle: 'Araç durumu olduğu gibi beyan edilir. Risk yok.',
                      badgeText: 'GÜVENLİ',
                      icon: Icons.verified_rounded,
                      accentColor: AppColors.brutalGreen,
                      isSelected: selectedDeclaration == ListingDeclarationType.honest,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.honest),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildTactileDeclarationCard(
                      title: 'Hatasız Boyasız Hilesi',
                      subtitle: 'Hasarlar gizlenir. Müşteri ekspertiz yaptırırsa ₺10k ceza kesilir.',
                      badgeText: 'RİSKLİ BEYAN',
                      icon: Icons.car_crash_rounded,
                      accentColor: AppColors.brutalOrange,
                      isSelected: selectedDeclaration == ListingDeclarationType.flawlessClaim,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.flawlessClaim),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildTactileDeclarationCard(
                      title: 'Sayaç Düşürme Hilesi',
                      subtitle: 'KM düşürülmüş gösterilir. Beyin taramasında yakalanırsa ₺10k ceza kesilir.',
                      badgeText: 'AĞIR SUÇ',
                      icon: Icons.speed_rounded,
                      accentColor: AppColors.errorRed,
                      isSelected: selectedDeclaration == ListingDeclarationType.tamperedMileageClaim,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.tamperedMileageClaim),
                      isDark: isDark,
                    ),

                    if (car.provenanceLog.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.history_edu_rounded, size: 16, color: AppColors.brutalYellow),
                          const SizedBox(width: 6),
                          Text(
                            'ARAÇ KÜNYESİ & GEÇMİŞİ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.brutalYellow : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      NeoBrutalCard(
                        padding: const EdgeInsets.all(12),
                        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                        borderColor: AppColors.brutalYellow,
                        borderRadius: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: car.provenanceLog.map((log) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.brutalYellow),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    NeoBrutalButton(
                      label: 'İlanı Güncelle & Kaydet',
                      icon: Icons.check_circle_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        ref.read(gameProvider.notifier).updateCarListingDetails(
                              car.id,
                              customPrice: selectedPrice,
                              declaration: selectedDeclaration,
                              listingPhotoLocation: selectedPhotoLocation,
                              listingPhotoCount: selectedPhotoCount,
                              listingTone: selectedTone,
                              hideDamagedPhotos: hideDamagedPhotos,
                              allowsInstallments: allowsInstallments,
                            );
                        Navigator.pop(context);
                        NotificationService.showSuccess(context, '${car.brand} ${car.modelName} ilanı güncellendi!');
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // =========================================================================
  // HELPER WIDGETS (NEO-BRUTALIST TACTILE COMPONENTS)
  // =========================================================================
  static Widget _buildPresetPriceButton({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 1.6,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5)),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildTactileLocationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      backgroundColor: isSelected
          ? activeColor
          : (isDark ? const Color(0xFF141721) : Colors.white),
      borderColor: isSelected
          ? (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A))
          : (isDark ? const Color(0xFF2A3142) : Colors.grey.shade400),
      borderWidth: isSelected ? 2.2 : 1.4,
      borderRadius: 10,
      shadowOffset: isSelected ? const Offset(3.0, 3.0) : const Offset(2.0, 2.0),
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 22,
            color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: isSelected ? Colors.black : (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.black87 : (isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTactileToggleRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isActive,
    required String activeLabel,
    required String inactiveLabel,
    required Color activeColor,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isActive ? activeColor : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
      borderWidth: 2.0,
      borderRadius: 12,
      shadowOffset: const Offset(2.5, 2.5),
      onTap: onToggle,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isActive ? activeColor : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isActive ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 10),
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
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalBadge(
            text: isActive ? activeLabel : inactiveLabel,
            backgroundColor: isActive ? activeColor : (isDark ? const Color(0xFF262C3D) : const Color(0xFFCBD5E1)),
            textColor: isActive ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF475569)),
            fontSize: 10,
          ),
        ],
      ),
    );
  }

  static Widget _buildTactileDeclarationCard({
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData icon,
    required Color accentColor,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isSelected
          ? accentColor.withValues(alpha: isDark ? 0.20 : 0.12)
          : (isDark ? const Color(0xFF141721) : Colors.white),
      borderColor: isSelected ? accentColor : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)),
      borderWidth: isSelected ? 2.5 : 1.5,
      borderRadius: 12,
      shadowOffset: isSelected ? const Offset(3.5, 3.5) : const Offset(2.0, 2.0),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? accentColor : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
            child: Icon(
              isSelected ? Icons.check_circle_rounded : icon,
              size: 20,
              color: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    NeoBrutalBadge(
                      text: badgeText,
                      backgroundColor: isSelected ? accentColor : (isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0)),
                      textColor: isSelected ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF475569)),
                      fontSize: 9.5,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildTactileStrategyCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      backgroundColor: isSelected ? activeColor : (isDark ? const Color(0xFF141721) : Colors.white),
      borderColor: isSelected ? Colors.black : (isDark ? const Color(0xFF2A3142) : Colors.grey.shade400),
      borderWidth: isSelected ? 2.0 : 1.2,
      borderRadius: 10,
      shadowOffset: isSelected ? const Offset(2.5, 2.5) : const Offset(1.5, 1.5),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black87 : (isDark ? Colors.grey : Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
