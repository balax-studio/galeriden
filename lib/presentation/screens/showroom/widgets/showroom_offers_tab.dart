import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/customer_review_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/offer_model.dart';
import '../../../../data/models/trade_in_offer_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/neo_brutal_empty_state.dart';
import 'showroom_listing_modal.dart';

class ShowroomOffersTab extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const ShowroomOffersTab({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;

    if (game.incomingOffers.isEmpty && game.incomingTradeInOffers.isEmpty) {
      return RefreshIndicator(
        color: Colors.black,
        backgroundColor: const Color(0xFFFFDE59),
        strokeWidth: 2.5,
        onRefresh: () async {
          HapticFeedback.mediumImpact();
          await Future.delayed(const Duration(milliseconds: 450));
          ref.read(gameProvider.notifier).triggerOrganicOffers();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          children: [
            const SizedBox(height: 40),
            NeoBrutalEmptyState(
              icon: Icons.local_offer_outlined,
              badgeText: 'TEKLİF BEKLENİYOR',
              title: 'Henüz Gelen Teklif Yok',
              description: 'Vitrindeki araçlarına müşteri geldikçe pazarlık teklifleri burada listelenecek. Sayfayı aşağı çekerek müşteri çağırabilirsin.',
              actionLabel: 'Müşteri Çek • Yenile',
              actionIcon: Icons.campaign_rounded,
              onActionPressed: () {
                ref.read(gameProvider.notifier).triggerOrganicOffers();
              },
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Colors.black,
      backgroundColor: const Color(0xFFFFDE59),
      strokeWidth: 2.5,
      onRefresh: () async {
        HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 450));
        ref.read(gameProvider.notifier).triggerOrganicOffers();
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        children: [
          // 1. Trade-in Offers Section (§4.6.2)
          if (game.incomingTradeInOffers.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync_alt_rounded, color: Color(0xFFFFDE59), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'ARABA TAKAS TEKLİFLERİ • ${game.incomingTradeInOffers.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (game.incomingTradeInOffers.length >= 2)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectAllTradeInOffers();
                      NotificationService.showInfo(context, 'Tüm takas teklifleri temizlendi.');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        'Tümünü Reddet',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...game.incomingTradeInOffers.map((tradeOffer) => _buildTradeInOfferCard(context, ref, tradeOffer, isDark)),
            const SizedBox(height: 14),
          ],

          // 2. Regular Cash Offers Section
          if (game.incomingOffers.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payments_outlined, color: Color(0xFF00E575), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'NAKİT SATIN ALMA TEKLİFLERİ • ${game.incomingOffers.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (game.incomingOffers.length >= 2)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectAllOffers();
                      NotificationService.showInfo(context, 'Tüm nakit teklifleri temizlendi.');
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(
                        'Tümünü Reddet',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...game.incomingOffers.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return _buildCashOfferCard(context, ref, offer, index, isDark);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildTradeInOfferCard(
    BuildContext context,
    WidgetRef ref,
    TradeInOfferModel tradeOffer,
    bool isDark,
  ) {
    final targetCar = game.ownedCars.firstWhere(
      (c) => c.id == tradeOffer.targetCarId,
      orElse: () => CarModel(
        id: '',
        brand: 'Bilinmeyen',
        modelName: 'Vitrin Aracı',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 0,
        currentPurchasePrice: 0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 0,
          isMileageTampered: false,
          bodyParts: {},
        ),
      ),
    );

    final isCashGivenToPlayer = tradeOffer.cashDifference >= 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        borderColor: const Color(0xFFFFDE59),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${tradeOffer.customerName} • Takas Teklifi',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'İstenen Aracın: ${targetCar.modelName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: isCashGivenToPlayer
                      ? '+${CurrencyFormatter.format(tradeOffer.cashDifference)} FARK'
                      : '-${CurrencyFormatter.format(-tradeOffer.cashDifference)} FARK',
                  backgroundColor: isCashGivenToPlayer ? const Color(0xFF00E575) : const Color(0xFFFF9F1C),
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dialog speech bubble
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Text(
                '"${tradeOffer.dialogText}"',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Offered Car Summary Box
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TEKLİF EDİLEN ARAÇ',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                      ),
                      Text(
                        tradeOffer.offeredCar.modelName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${tradeOffer.offeredCar.modelYear} • ${tradeOffer.offeredCar.expertise.mileage} km • Motor: %${tradeOffer.offeredCar.expertise.engineCondition.round()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    NeoBrutalButton(
                      label: 'Reddet',
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white70 : const Color(0xFF64748B),
                      onPressed: () {
                        ref.read(gameProvider.notifier).rejectTradeInOffer(tradeOffer.id);
                        NotificationService.showInfo(context, 'Takas teklifi reddedildi.');
                      },
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: 'Takas Yap',
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      onPressed: () {
                        final success = ref.read(gameProvider.notifier).acceptTradeInOffer(tradeOffer);
                        if (success) {
                          NotificationService.showSuccess(
                            context,
                            '${targetCar.modelName} takaslandı! Yeni araç garajına eklendi.',
                          );
                        } else {
                          NotificationService.showWarning(context, 'Takas için yeterli nakdiniz yok!');
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashOfferCard(
    BuildContext context,
    WidgetRef ref,
    OfferModel offer,
    int index,
    bool isDark,
  ) {
    final car = game.ownedCars.firstWhere(
      (c) => c.id == offer.carId,
      orElse: () => CarModel(
        id: '',
        brand: 'Bilinmeyen',
        modelName: 'Araç',
        modelYear: 2020,
        bodyType: 'Sedan',
        colorHex: '#000000',
        baseMarketValue: 0,
        currentPurchasePrice: 0,
        expertise: ExpertiseReport(
          engineCondition: 100,
          transmissionCondition: 100,
          tramerAmount: 0,
          mileage: 0,
          isMileageTampered: false,
          bodyParts: {},
        ),
      ),
    );

    final isCountered = offer.status == OfferStatus.countered;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key('offer_${offer.id}_$index'),
              direction: DismissDirection.horizontal,
              background: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E575),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_rounded, color: Colors.black, size: 26),
                    SizedBox(width: 8),
                    Text(
                      'KABUL ET & SAT',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                margin: const EdgeInsets.only(bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text(
                      'REDDET & SİL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.delete_forever_rounded, color: Colors.white, size: 26),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                HapticFeedback.mediumImpact();
                if (direction == DismissDirection.startToEnd) {
                  // Swipe Right -> Accept Offer
                  final customer = CustomerModel.generateRandomCustomer();
                  final fraudResult = ref.read(gameProvider.notifier).acceptOfferWithFraudCheck(offer, customer);

                  if (fraudResult != null && fraudResult.caughtFraud) {
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.symmetric(horizontal: 18),
                          child: NeoBrutalCard(
                            padding: const EdgeInsets.all(18),
                            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                            borderColor: palette.errorColor,
                            borderRadius: 12,
                            borderWidth: 2.5,
                            shadowOffset: const Offset(4, 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    VectorIconWidget(type: 'error', color: palette.errorColor, size: 24),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        fraudResult.title,
                                        style: TextStyle(
                                          color: palette.errorColor,
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
                                  'Tazminat Cezası: ${CurrencyFormatter.formatShort(fraudResult.fineAmount)}\n'
                                  'İtibar Kaybı: -${fraudResult.reputationPenalty} Puan',
                                  style: AppTypography.bodyMedium(palette.isDark),
                                ),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: NeoBrutalButton(
                                    label: 'Tamam',
                                    backgroundColor: AppColors.errorRed,
                                    textColor: Colors.white,
                                    onPressed: () => Navigator.pop(ctx),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  } else {
                    final isHonest = car.declarationType == ListingDeclarationType.honest;
                    final review = CustomerReviewModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      reviewerName: offer.buyerName,
                      carTitle: '${car.brand} ${car.modelName}',
                      rating: isHonest ? (4.0 + (offer.offeredAmount >= car.listingPrice ? 1.0 : 0.0)) : 1.0,
                      comment: isHonest
                          ? 'Harika ve dürüst bir galerici! ${game.dealershipName} ekibi ve ${game.playerName} çok ilgiliydi. Araç ekspertizdeki gibi tertemiz çıktı.'
                          : '${game.dealershipName} galerisinde göz göre göre gizli kusurlu araç sattılar! Kesinlikle tavsiye etmiyorum.',
                      createdAt: DateTime.now(),
                    );
                    ref.read(gameProvider.notifier).addCustomerReview(review);

                    if (context.mounted) {
                      NotificationService.showSuccess(
                        context,
                        '${game.dealershipName} bünyesinde ${CurrencyFormatter.format(offer.offeredAmount)} tutarında noter satışı tamamlandı!',
                      );
                    }
                  }
                  return true;
                } else {
                  // Swipe Left -> Reject Offer
                  ref.read(gameProvider.notifier).rejectOffer(offer.id);
                  if (context.mounted) {
                    NotificationService.showWarning(context, '${offer.buyerName} teklifi reddedildi.');
                  }
                  return true;
                }
              },
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isCountered
                    ? const Color(0xFFFFDE59)
                    : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                borderRadius: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${car.brand} ${car.modelName}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(offer.offeredAmount),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Piyasa Değeri: ${CurrencyFormatter.formatShort(car.estimatedRealValue)}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          'İlan Fiyatı: ${CurrencyFormatter.formatShort(car.listingPrice > 0 ? car.listingPrice : car.estimatedRealValue)}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Alıcı: ${offer.buyerName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                        if (offer.buyerCustomer != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFDE59),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 1.8,
                              ),
                            ),
                            child: Text(
                              offer.buyerCustomer!.archetypeTitle,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        if (offer.offerType != OfferType.cash)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: offer.offerType == OfferType.installment ? const Color(0xFF38BDF8) : const Color(0xFFA855F7),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                width: 1.8,
                              ),
                            ),
                            child: Text(
                              offer.offerType == OfferType.installment
                                  ? '${offer.installmentMonths} Ay Senetli • ${offer.riskLevel}'
                                  : 'Çekli Teklif',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (offer.requestedTestDrive && offer.testDriveResult != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F291E) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF00E575),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.speed_rounded, size: 14, color: Color(0xFF00E575)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                offer.testDriveResult!,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF86EFAC) : const Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (offer.buyerMessage.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '"${offer.buyerMessage}"',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: isDark ? palette.primaryColor : const Color(0xFF0F172A),
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),

                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalButton(
                          label: 'Reddet',
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                          textColor: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          onPressed: () {
                            ref.read(gameProvider.notifier).rejectOffer(offer.id);
                          },
                        ),
                        Row(
                          children: [
                            NeoBrutalButton(
                              label: 'Karşı Teklif',
                              backgroundColor: const Color(0xFFFFDE59),
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              onPressed: () {
                                ShowroomListingModal.showCounterOfferSheet(context, ref, offer, car);
                              },
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton(
                              label: 'Kabul Et & Sat',
                              backgroundColor: const Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              onPressed: () {
                                GameSoundHapticService.playNotarySignature();
                                GameSoundHapticService.playCashSuccess();
                                final customer = offer.buyerCustomer ?? CustomerModel.generateRandomCustomer();
                                final fraudResult = ref.read(gameProvider.notifier).acceptOfferWithFraudCheck(offer, customer);

                                if (fraudResult != null && fraudResult.caughtFraud) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
                                      child: NeoBrutalCard(
                                        padding: const EdgeInsets.all(18),
                                        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                                        borderColor: palette.errorColor,
                                        borderRadius: 12,
                                        borderWidth: 2.5,
                                        shadowOffset: const Offset(4, 4),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                VectorIconWidget(type: 'error', color: palette.errorColor, size: 24),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    fraudResult.title,
                                                    style: TextStyle(
                                                      color: palette.errorColor,
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
                                              'Tazminat Cezası: ${CurrencyFormatter.formatShort(fraudResult.fineAmount)}\n'
                                              'İtibar Kaybı: -${fraudResult.reputationPenalty} Puan',
                                              style: AppTypography.bodyMedium(palette.isDark),
                                            ),
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: NeoBrutalButton(
                                                label: 'Tamam',
                                                backgroundColor: AppColors.errorRed,
                                                textColor: Colors.white,
                                                onPressed: () => Navigator.pop(ctx),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  final isCollector = offer.buyerName.startsWith('Koleksiyoner') || offer.offeredAmount > car.estimatedRealValue * 1.18;
                                  final isHonest = car.declarationType == ListingDeclarationType.honest;
                                  final review = CustomerReviewModel(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    reviewerName: offer.buyerName,
                                    carTitle: '${car.brand} ${car.modelName}',
                                    rating: isHonest ? (4.0 + (offer.offeredAmount >= car.listingPrice ? 1.0 : 0.0)) : 1.0,
                                    comment: isHonest
                                        ? 'Harika ve dürüst bir galerici! ${game.dealershipName} ekibi ve ${game.playerName} çok ilgiliydi. Araç ekspertizdeki gibi tertemiz çıktı.'
                                        : '${game.dealershipName} galerisinde göz göre göre gizli kusurlu araç sattılar! Kesinlikle tavsiye etmiyorum.',
                                    createdAt: DateTime.now(),
                                  );
                                  ref.read(gameProvider.notifier).addCustomerReview(review);

                                  // Cascading Reward Modal (§1.4 Ödül Zincirleme)
                                  if (context.mounted) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
                                        child: NeoBrutalCard(
                                          padding: const EdgeInsets.all(18),
                                          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                                          borderColor: const Color(0xFF00E575),
                                          borderRadius: 12,
                                          borderWidth: 2.5,
                                          shadowOffset: const Offset(4, 4),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF00E575),
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                                        width: 2.0,
                                                      ),
                                                    ),
                                                    child: const Icon(Icons.check_circle_rounded, color: Colors.black, size: 24),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: Text(
                                                      isCollector ? 'KOLEKSİYONER SATIŞI!' : 'NOTER SATIŞI ONAYLANDI!',
                                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                '${car.brand} ${car.modelName} aracı ${CurrencyFormatter.format(offer.offeredAmount)} bedelle ${offer.buyerName} adlı alıcıya devredildi.',
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.all(10),
                                                decoration: BoxDecoration(
                                                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: const Color(0xFF3B82F6), width: 2.0),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.bolt_rounded, color: Color(0xFF3B82F6), size: 20),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        'Yeni kelepir ilanlar pazara düştü! Hemen yeni araç toplayarak kasanı katla.',
                                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: NeoBrutalButton(
                                                      label: 'Galeride Kal',
                                                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                                      textColor: isDark ? Colors.white70 : const Color(0xFF64748B),
                                                      onPressed: () => Navigator.pop(ctx),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: NeoBrutalButton(
                                                      label: 'Pazara Git',
                                                      icon: Icons.storefront_rounded,
                                                      backgroundColor: const Color(0xFFFFDE59),
                                                      textColor: Colors.black,
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                        ref.read(dashboardTabProvider.notifier).state = 1;
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
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
