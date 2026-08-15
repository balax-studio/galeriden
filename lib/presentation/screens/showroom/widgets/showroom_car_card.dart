import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/visitor_queue_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: hasOffer
            ? const Color(0xFF00E575)
            : (car.isDoped
                ? const Color(0xFFFFDE59)
                : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))),
        borderRadius: 12,
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
                        const NeoBrutalBadge(
                          text: 'TEKLİF VAR',
                          icon: Icons.local_fire_department_rounded,
                          backgroundColor: Color(0xFF00E575),
                          textColor: Colors.black,
                          fontSize: 9.5,
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
                          text: 'VİTRİN BAŞKÖŞESİ (+%30)',
                          icon: Icons.star_rounded,
                          backgroundColor: Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isStaleListing) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'ESKİ İLAN (-%40)',
                          icon: Icons.warning_amber_rounded,
                          backgroundColor: Color(0xFFEF4444),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isBarnFindRestored) ...[
                        const SizedBox(width: 6),
                        const NeoBrutalBadge(
                          text: 'RESTORE EDİLDİ (+%45)',
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
                                      isDoped ? 'Paylaşıldı' : 'Paylaş (-%50)',
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
                                      !canCutPrice ? 'Dip Fiyat' : 'Fiyat Kır (-%5)',
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

            // Price Matrix Block
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Maliyet',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatShort(car.currentPurchasePrice),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Piyasa Değeri',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatShort(car.estimatedRealValue),
                        style: TextStyle(
                          fontSize: 12.5,
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
                        'İlan Satış Fiyatı',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatShort(car.listingPrice),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Declaration Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İlan Beyanı:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
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
                    label: car.isDoped ? 'Dopingli' : 'Öne Çıkar (₺2.5k)',
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
                                'Aracın maksimum teklif sınırına (3/3) ulaşıldı!',
                              );
                              return;
                            }
                            final success = ref.read(gameProvider.notifier).boostListingDoping(car.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                '${car.brand} ${car.modelName} için ₺2.500 Doping Uygulandı!',
                              );
                            } else {
                              NotificationService.showError(
                                context,
                                'Doping için bakiyeniz yetersiz (₺2.500 gereklidir).',
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
                label: 'İlanı Güncelle & Yenile (₺1.500)',
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
                      'İlanı yenilemek için ₺1.500 bakiye gereklidir.',
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
                    : 'Vitrin Başköşesine Koy (+%30 Müşteri Trafiği)',
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
                    ? 'Koleksiyon Vitrininden Çıkar (Satışa Aç)'
                    : 'Koleksiyon Vitrinine Kilitle (+%5 İtibar)',
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
                      builder: (dCtx) => AlertDialog(
                        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Colors.black, width: 2),
                        ),
                        title: const Text('VİTRİNDEN ÇIKARILSIN MI?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        content: const Text(
                          'Bu araç galeri yadigârı olarak kilitli. Vitrinden çıkarırsan satışa açılacak ve devir (prestij) sırasında aktarılmayacaktır. Emin misin?',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dCtx),
                            child: const Text('İPTAL', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorRed,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.pop(dCtx);
                              ref.read(gameProvider.notifier).toggleShowcaseLock(car.id);
                              NotificationService.showSuccess(context, '${car.brand} ${car.modelName} vitrinden çıkarıldı.');
                            },
                            child: const Text('KİLİDİ AÇ', style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ],
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
    );
  }
}
