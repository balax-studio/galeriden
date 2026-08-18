import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/visitor_queue_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/animated_rolling_counter.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pulsing_dot.dart';
import 'car_cost_breakdown_sheet.dart';
import 'showroom_listing_modal.dart';

class ShowroomCarCard extends ConsumerWidget {
  final CarModel car;
  final DealershipModel game;
  final ThemePaletteModel palette;
  final bool hasSalesman;

  const ShowroomCarCard({
    super.key,
    required this.car,
    required this.game,
    required this.palette,
    required this.hasSalesman,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final hasOffer = game.incomingOffers.any((o) => o.carId == car.id && !o.isExpired);
    final nextSec = VisitorQueueEngine.calculateNextVisitorSeconds(
      car: car,
      reputation: game.reputationScore,
      hasSalesman: hasSalesman,
      marketSenseBonus: game.skills.marketSense * 0.05,
    );

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: hasOffer
            ? const Color(0xFF00E575)
            : (car.isDoped
                ? const Color(0xFFFFDE59)
                : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))),
        borderRadius: 10,
        borderWidth: 2.5,
        shadowOffset: const Offset(4.5, 4.5),
        showDotGrid: true,
        showHazardHeader: car.isStaleListing || car.isBarnFind,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          '${car.brand} ${car.modelName}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (hasOffer) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            PulsingDot(color: Color(0xFF00E575), size: 6.0),
                            SizedBox(width: 4),
                            NeoBrutalBadge(
                              text: 'TEKLİF VAR',
                              icon: Icons.local_fire_department_rounded,
                              backgroundColor: Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 9.5,
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                      ],
                      NeoBrutalBadge(
                        text: car.isListed ? 'İLANDA' : 'GARAJDA',
                        backgroundColor: car.isListed
                            ? const Color(0xFF00E575)
                            : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                        textColor: car.isListed ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                        fontSize: 9.5,
                      ),
                      if (car.isHeroShowcase) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'VİTRİN BAŞKÖŞESİ • +%30',
                          icon: Icons.star_rounded,
                          backgroundColor: Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isStaleListing) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'ESKİ İLAN • -%40',
                          icon: Icons.warning_amber_rounded,
                          backgroundColor: Color(0xFFEF4444),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isBarnFindRestored) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'RESTORE EDİLDİ • +%45',
                          icon: Icons.auto_awesome_rounded,
                          backgroundColor: Color(0xFF10B981),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ] else if (car.isBarnFind) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'SAMANLIK KELEPİRİ',
                          icon: Icons.handyman_rounded,
                          backgroundColor: Color(0xFFD97706),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.hasNonOriginalParts) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'YAN SANAYİ PARÇA',
                          backgroundColor: Color(0xFF64748B),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isDoped) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'DOPİNGLİ',
                          icon: Icons.bolt_rounded,
                          backgroundColor: Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isLockedInShowcase) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'KOLEKSİYONDA',
                          icon: Icons.workspace_premium_rounded,
                          backgroundColor: Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ] else if (car.isRare) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'NADİR',
                          icon: Icons.diamond_rounded,
                          backgroundColor: Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: car.bodyType,
                  fontSize: 9.5,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Visitor Queue Countdown Indicator for Listed Cars
            if (car.isListed) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_rounded, size: 16, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 6),
                        Text(
                          'Sonraki Müşteri: ~${(nextSec ~/ 60).toString().padLeft(2, '0')}:${(nextSec % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Quick Wait Action: Share to Social (-%50 wait)
                        Builder(
                          builder: (context) {
                            final bool isDoped = car.isDoped;
                            return InkWell(
                              onTap: isDoped
                                  ? null
                                  : () {
                                      final success = ref.read(gameProvider.notifier).boostListingDoping(car.id);
                                      if (success) {
                                        NotificationService.showSuccess(
                                          context,
                                          '${car.brand} ${car.modelName} sosyal medyada öne çıkarıldı!',
                                        );
                                      } else {
                                        NotificationService.showInfo(
                                          context,
                                          'İlan sosyal medyada zaten paylaşıldı!',
                                        );
                                      }
                                    },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDoped
                                      ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFCBD5E1))
                                      : const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.share_rounded,
                                      size: 11,
                                      color: isDoped
                                          ? (isDark ? Colors.white54 : Colors.black54)
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isDoped ? 'Paylaşıldı' : 'Paylaş • -%50',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isDoped
                                            ? (isDark ? Colors.white54 : Colors.black54)
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        // Quick Wait Action: Cut Price (-%5, 2x Arrival Speed)
                        Builder(
                          builder: (context) {
                            final double minFloorPrice = (car.currentPurchasePrice > 0
                                    ? car.currentPurchasePrice * 0.85
                                    : car.estimatedRealValue * 0.70)
                                .roundToDouble();
                            final bool canCutPrice = car.listingPrice > minFloorPrice;

                            return InkWell(
                              onTap: !canCutPrice
                                  ? null
                                  : () {
                                      final discountedPrice = (car.listingPrice * 0.95).roundToDouble();
                                      ref.read(gameProvider.notifier).updateCarListingPrice(car.id, discountedPrice);
                                      NotificationService.showSuccess(
                                        context,
                                        'Fiyat ${CurrencyFormatter.formatShort(discountedPrice)} seviyesine çekildi! Müşteriler hızlandı.',
                                      );
                                    },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: !canCutPrice
                                      ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFCBD5E1))
                                      : const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.local_offer_rounded,
                                      size: 11,
                                      color: !canCutPrice
                                          ? (isDark ? Colors.white54 : Colors.black54)
                                          : Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      !canCutPrice ? 'Dip Fiyat' : 'Fiyat Kır • -%5',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: !canCutPrice
                                            ? (isDark ? Colors.white54 : Colors.black54)
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        // Quick Wait Action: Social Media Share (§2.5)
                        InkWell(
                          onTap: () {
                            ref.read(gameProvider.notifier).triggerOrganicOffers();
                            NotificationService.showSuccess(
                              context,
                              'İlan ${game.dealershipName} sosyal medya hesaplarında paylaşıldı! Yeni ziyaretçiler akın ediyor.',
                            );
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.share_rounded, size: 11, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Paylaş & Çağır',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // 3-Band Vehicle Card Architecture (§1.5 / Q9)
            // Band 1: Plaka, Renk & Kaporta Özet Bandı
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: car.plateRarity == 'legendary'
                              ? const Color(0xFFFFD700)
                              : (car.plateRarity == 'repeated' || car.plateRarity == 'symmetric'
                                  ? const Color(0xFF38BDF8)
                                  : (isDark ? Colors.white12 : const Color(0xFF0F172A))),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          car.plateNumber,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: car.plateRarity == 'legendary' || car.plateRarity == 'repeated' || car.plateRarity == 'symmetric'
                                ? Colors.black
                                : (isDark ? Colors.white : Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        car.colorDisplayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.build_circle_rounded,
                        size: 13,
                        color: car.hasNonOriginalParts ? const Color(0xFFF59E0B) : const Color(0xFF00E575),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Motor: %${car.expertise.engineCondition.round()}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Band 2: Net Kâr & Fiyat Isı Şeridi (Profit Margin Heat Stripe §1.5)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4.5,
                    height: 28,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: car.profitHeatStatus == 'green'
                          ? const Color(0xFF00E575)
                          : (car.profitHeatStatus == 'yellow'
                              ? const Color(0xFFF59E0B)
                              : (car.profitHeatStatus == 'orange'
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFFEF4444))),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alış Maliyeti',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            AnimatedRollingCounter(
                              value: car.currentPurchasePrice,
                              isShort: true,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            CarCostBreakdownSheet.show(context, car);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Net Kâr Analizi',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 10,
                                      color: isDark ? Colors.white60 : Colors.black45,
                                    ),
                                  ],
                                ),
                                AnimatedRollingCounter(
                                  value: car.netEstimatedProfit,
                                  isShort: true,
                                  prefix: car.netEstimatedProfit >= 0 ? '+' : '',
                                  suffix: ' • %${car.profitMarginPercent.round()}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w900,
                                    color: car.netEstimatedProfit >= 0
                                        ? const Color(0xFF00E575)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              car.isListed ? 'İlan Fiyatı' : 'Piyasa Değeri',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            AnimatedRollingCounter(
                              value: car.isListed ? car.listingPrice : car.estimatedRealValue,
                              isShort: true,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: car.isListed ? const Color(0xFF00E575) : (isDark ? Colors.white : const Color(0xFF0F172A)),
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

            // Band 3: İlan Günü, Torpido & Beyan Durumu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (car.isListed) ...[
                      Text(
                        'İlanda: ${car.daysListed} gün',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: car.isStaleListing ? const Color(0xFFEF4444) : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (!car.hasGloveboxSearched) ...[
                      InkWell(
                        onTap: () {
                          final result = ref.read(gameProvider.notifier).searchGlovebox(car.id);
                          if (result['success'] == true) {
                            NotificationService.showSuccess(
                              context,
                              result['message'] as String,
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE59),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black, width: 1.0),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_rounded, size: 11, color: Colors.black),
                              SizedBox(width: 3),
                              Text(
                                'Torpido Ara',
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                NeoBrutalBadge(
                  text: car.declarationType == ListingDeclarationType.honest
                      ? 'Dürüst İlan'
                      : (car.declarationType == ListingDeclarationType.flawlessClaim
                          ? 'Hatasız Boyasız Hilesi'
                          : 'Sayaç Düşürme Hilesi'),
                  backgroundColor: car.declarationType == ListingDeclarationType.honest
                      ? const Color(0xFF00E575)
                      : (car.declarationType == ListingDeclarationType.flawlessClaim
                          ? const Color(0xFFFF7A00)
                          : const Color(0xFFEF4444)),
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Actions
            Row(
              children: [
                Expanded(
                  child: NeoBrutalButton(
                    label: 'Fiyat & İlanı Düzenle',
                    icon: Icons.edit_note_rounded,
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: () => ShowroomListingModal.showListingEditSheet(context, ref, car),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoBrutalButton(
                    label: car.isDoped ? 'Dopingli' : 'Öne Çıkar • ${CurrencyFormatter.formatShort(GameConstants.dopingCost)}',
                    icon: Icons.bolt_rounded,
                    backgroundColor: car.isDoped
                        ? (isDark ? Colors.white12 : Colors.black12)
                        : const Color(0xFFFFDE59),
                    textColor: Colors.black,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    onPressed: car.isDoped
                        ? () => NotificationService.showError(
                            context,
                            'Bu araç için doping hakkı zaten kullanıldı!',
                          )
                        : () {
                            if (!car.isListed) {
                              NotificationService.showError(
                                context,
                                'Araç ilana konulmadan doping yapılamaz!',
                              );
                              return;
                            }
                            final activeOffersCount = game.incomingOffers
                                .where((o) => o.carId == car.id && !o.isExpired)
                                .length;
                            if (activeOffersCount >= 3) {
                              NotificationService.showError(
                                context,
                                'Aracın maksimum teklif sınırına • 3/3 ulaşıldı!',
                              );
                              return;
                            }
                            final success = ref.read(gameProvider.notifier).boostListingDoping(car.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                '${car.brand} ${car.modelName} için ${CurrencyFormatter.format(GameConstants.dopingCost)} Doping Uygulandı!',
                              );
                            } else {
                              NotificationService.showError(
                                context,
                                'Doping için bakiyeniz yetersiz • ${CurrencyFormatter.format(GameConstants.dopingCost)} gereklidir.',
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
            if (car.isStaleListing) ...[
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: 'İlanı Güncelle & Yenile • ${CurrencyFormatter.format(GameConstants.refreshListingCost)}',
                icon: Icons.refresh_rounded,
                backgroundColor: const Color(0xFFEF4444),
                textColor: Colors.white,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 6),
                fullWidth: true,
                onPressed: () {
                  final ok = ref.read(gameProvider.notifier).refreshStaleListing(car.id);
                  if (ok) {
                    NotificationService.showSuccess(
                      context,
                      '${car.brand} ${car.modelName} ilanı güncellendi ve tekrar en tepeye taşındı!',
                    );
                  } else {
                    NotificationService.showError(
                      context,
                      'İlanı yenilemek için ${CurrencyFormatter.format(GameConstants.refreshListingCost)} bakiye gereklidir.',
                    );
                  }
                },
              ),
            ],
            if (car.isListed) ...[
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: car.isHeroShowcase
                    ? 'Vitrin Başköşesinden İndir'
                    : 'Vitrin Başköşesine Koy • +%30 Müşteri Trafiği',
                icon: car.isHeroShowcase ? Icons.star_border_rounded : Icons.star_rounded,
                backgroundColor: car.isHeroShowcase
                    ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                    : const Color(0xFFFFDE59),
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 6),
                fullWidth: true,
                onPressed: () {
                  final ok = ref.read(gameProvider.notifier).toggleHeroShowcase(car.id);
                  if (ok) {
                    NotificationService.showSuccess(
                      context,
                      car.isHeroShowcase
                          ? '${car.brand} ${car.modelName} vitrin başköşesinden alındı.'
                          : '${car.brand} ${car.modelName} vitrin başköşesine yerleştirildi! Trafik +%30',
                    );
                  }
                },
              ),
            ],
            // Koleksiyon Vitrinine Kilitleme (Her araç için mülkiyet & yadigâr hakkı)
            const SizedBox(height: 8),
            NeoBrutalButton(
              label: car.isLockedInShowcase
                    ? 'Koleksiyon Vitrininden Çıkar • Satışa Aç'
                    : 'Koleksiyon Vitrinine Kilitle • +%5 İtibar',
                icon: car.isLockedInShowcase ? Icons.lock_open_rounded : Icons.workspace_premium_rounded,
                backgroundColor: car.isLockedInShowcase
                    ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                    : const Color(0xFFA855F7),
                textColor: car.isLockedInShowcase ? (isDark ? Colors.white : Colors.black) : Colors.white,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(vertical: 6),
                fullWidth: true,
                onPressed: () {
                  if (car.isLockedInShowcase) {
                    showDialog(
                      context: context,
                      builder: (dCtx) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(18),
                          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                          borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          borderRadius: 12,
                          borderWidth: 2.5,
                          shadowOffset: const Offset(4, 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'VİTRİNDEN ÇIKARILSIN MI?',
                                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Bu araç galeri yadigârı olarak kilitli. Vitrinden çıkarırsan satışa açılacak ve devir sırasında aktarılmayacaktır. Emin misin?',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  NeoBrutalButton(
                                    label: 'İPTAL',
                                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                    textColor: isDark ? Colors.white70 : const Color(0xFF64748B),
                                    fontSize: 11,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    onPressed: () => Navigator.pop(dCtx),
                                  ),
                                  const SizedBox(width: 8),
                                  NeoBrutalButton(
                                    label: 'KİLİDİ AÇ',
                                    icon: Icons.lock_open_rounded,
                                    backgroundColor: AppColors.errorRed,
                                    textColor: Colors.white,
                                    fontSize: 11,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    onPressed: () {
                                      Navigator.pop(dCtx);
                                      ref.read(gameProvider.notifier).toggleShowcaseLock(car.id);
                                      NotificationService.showSuccess(context, '${car.brand} ${car.modelName} vitrinden çıkarıldı.');
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    final success = ref.read(gameProvider.notifier).toggleShowcaseLock(car.id);
                    if (success) {
                      NotificationService.showSuccess(
                        context,
                        '${car.brand} ${car.modelName} koleksiyon vitrinine kilitlendi! +5 Esnaf İtibarı kazanıldı.',
                      );
                    }
                  }
                },
              ),
          ],
        ),
      ),
    ),
  );
}
}
