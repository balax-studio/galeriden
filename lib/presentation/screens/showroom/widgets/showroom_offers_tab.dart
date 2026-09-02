import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../offer_evaluation_screen.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/offer_model.dart';
import '../../../../data/models/trade_in_offer_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/tutorial_pulse_target.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/neo_brutal_empty_state.dart';
import '../../../../domain/usecases/negotiation_engine.dart';
import '../../../widgets/dialogs/lucky_opportunity_dialog.dart';
import '../../../widgets/dialogs/notary_transfer_dialog.dart';

class ShowroomOffersTab extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final double? bottomPadding;

  const ShowroomOffersTab({
    super.key,
    required this.game,
    required this.palette,
    this.bottomPadding,
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
          final res = ref.read(gameProvider.notifier).manualPullOrganicOffer();
          if (context.mounted) {
            if (res.hasNewOffer) {
              NotificationService.showSuccess(context, res.message);
            } else {
              NotificationService.showInfo(context, res.message);
            }
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          children: [
            const SizedBox(height: 40),
            NeoBrutalEmptyState(
              icon: Icons.local_offer_outlined,
              badgeText: context.tr('badge_awaiting_offers'),
              title: context.tr('title_no_offers_yet'),
              description: context.tr('desc_no_offers_yet'),
              actionLabel: context.tr('btn_pull_customers_refresh'),
              actionIcon: Icons.campaign_rounded,
              onActionPressed: () {
                final res =
                    ref.read(gameProvider.notifier).manualPullOrganicOffer();
                if (res.hasNewOffer) {
                  NotificationService.showSuccess(context, res.message);
                } else {
                  NotificationService.showInfo(context, res.message);
                }
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
        final res = ref.read(gameProvider.notifier).manualPullOrganicOffer();
        if (context.mounted) {
          if (res.hasNewOffer) {
            NotificationService.showSuccess(context, res.message);
          } else {
            NotificationService.showInfo(context, res.message);
          }
        }
      },
      child: ListView(
        padding: EdgeInsets.fromLTRB(14, 12, 14, bottomPadding ?? 24),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        children: [
          // 1. Trade-in Offers Section (§4.6.2)
          if (game.incomingTradeInOffers.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sync_alt_rounded,
                        color: Color(0xFFFFDE59), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('title_trade_in_offers',
                          {'count': '${game.incomingTradeInOffers.length}'}),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (game.incomingTradeInOffers.length >= 2)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectAllTradeInOffers();
                      NotificationService.showInfo(
                          context, context.tr('toast_all_trade_ins_cleared'));
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Text(
                        context.tr('btn_reject'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFFF87171)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ...game.incomingTradeInOffers.map((tradeOffer) =>
                _buildTradeInOfferCard(context, ref, tradeOffer, isDark)),
            const SizedBox(height: 14),
          ],

          // 2. Regular Cash Offers Section
          if (game.incomingOffers.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.payments_outlined,
                        color: Color(0xFF00E575), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      context.tr('title_cash_offers',
                          {'count': '${game.incomingOffers.length}'}),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (game.incomingOffers.length >= 2)
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(gameProvider.notifier).rejectAllOffers();
                      NotificationService.showInfo(
                          context, context.tr('toast_all_cash_offers_cleared'));
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      child: Text(
                        context.tr('btn_reject'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? const Color(0xFFF87171)
                              : const Color(0xFFDC2626),
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
        modelName: context.tr('showroom_vitrin_tag'),
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
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded,
                      size: 18, color: Colors.black),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('trade_offer_title',
                            {'customer': tradeOffer.customerName}),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        context.tr('trade_requested_car',
                            {'car': targetCar.modelName}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                NeoBrutalBadge(
                  text: isCashGivenToPlayer
                      ? '+${CurrencyFormatter.format(tradeOffer.cashDifference)}'
                      : '-${CurrencyFormatter.format(-tradeOffer.cashDifference)}',
                  backgroundColor: isCashGivenToPlayer
                      ? const Color(0xFF00E575)
                      : const Color(0xFFFF9F1C),
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
                color:
                    isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF262C3D)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Text(
                '"${tradeOffer.dialogText}"',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFF334155),
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
                      Text(
                        context.tr('offered_car_title'),
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B)),
                      ),
                      Text(
                        tradeOffer.offeredCar.modelName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${tradeOffer.offeredCar.modelYear} • ${tradeOffer.offeredCar.expertise.mileage} km • ${context.tr('engine_condition')}: %${tradeOffer.offeredCar.expertise.engineCondition.round()}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    NeoBrutalButton(
                      label: context.tr('btn_reject'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor:
                          isDark ? Colors.white70 : const Color(0xFF64748B),
                      onPressed: () {
                        ref
                            .read(gameProvider.notifier)
                            .rejectTradeInOffer(tradeOffer.id);
                        NotificationService.showInfo(
                            context, context.tr('toast_trade_in_rejected'));
                      },
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: context.tr('btn_accept_trade'),
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      onPressed: () {
                        final success = ref
                            .read(gameProvider.notifier)
                            .acceptTradeInOffer(tradeOffer);
                        if (success) {
                          NotificationService.showSuccess(
                            context,
                            context.tr('toast_trade_in_success',
                                {'car': targetCar.modelName}),
                          );
                        } else {
                          NotificationService.showWarning(context,
                              context.tr('toast_trade_in_insufficient_funds'));
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
        modelName: context.tr('car_label'),
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
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.black, size: 26),
              const SizedBox(width: 8),
              Text(
                context.tr('swipe_accept_sell'),
                style: const TextStyle(
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
            children: [
              Text(
                context.tr('swipe_reject_delete'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.delete_forever_rounded,
                  color: Colors.white, size: 26),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          HapticFeedback.mediumImpact();
          final isExpired =
              offer.isExpired || offer.status == OfferStatus.expired;
          if (isExpired) {
            ref.read(gameProvider.notifier).dismissOffer(offer.id);
            return true;
          }
          if (direction == DismissDirection.startToEnd) {
            _processOfferAcceptWithNotary(context, ref, offer, car);
            return true;
          } else {
            ref.read(gameProvider.notifier).rejectOffer(offer.id);
            if (context.mounted) {
              NotificationService.showWarning(
                  context,
                  context
                      .tr('toast_offer_rejected', {'buyer': offer.buyerName}));
            }
            return true;
          }
        },
        child: Builder(
          builder: (context) {
            final isExpired =
                offer.isExpired || offer.status == OfferStatus.expired;

            return NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark
                  ? (isExpired
                      ? const Color(0xFF161922)
                      : const Color(0xFF141721))
                  : (isExpired ? const Color(0xFFF8FAFC) : Colors.white),
              borderColor: isExpired
                  ? const Color(0xFFEF4444)
                  : (isCountered
                      ? const Color(0xFFFFDE59)
                      : (isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A))),
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
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isExpired) ...[
                              const SizedBox(width: 8),
                              NeoBrutalBadge(
                                text: context.tr('badge_buyer_left_timeout'),
                                backgroundColor: const Color(0xFFDC2626),
                                textColor: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                          child: Text(
                        CurrencyFormatter.format(offer.offeredAmount),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isExpired
                              ? const Color(0xFF94A3B8)
                              : (isDark
                                  ? const Color(0xFF00E575)
                                  : const Color(0xFF15803D)),
                          decoration:
                              isExpired ? TextDecoration.lineThrough : null,
                        ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                        context.tr('market_val_short', {
                          'val': CurrencyFormatter.formatShort(
                              car.estimatedRealValue)
                        }),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      )),
                      Expanded(
                          child: Text(
                        context.tr('listing_price_short', {
                          'val': CurrencyFormatter.formatShort(
                              car.listingPrice > 0
                                  ? car.listingPrice
                                  : car.estimatedRealValue)
                        }),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF334155),
                        ),
                      )),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context
                            .tr('buyer_name_label', {'buyer': offer.buyerName}),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      if (offer.buyerCustomer != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE59),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: offer.offerType == OfferType.installment
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFFA855F7),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 1.8,
                            ),
                          ),
                          child: Text(
                            offer.offerType == OfferType.installment
                                ? context.tr('installment_badge_text', {
                                    'months':
                                        offer.installmentMonths.toString(),
                                    'risk': offer.riskLevel
                                  })
                                : context.tr('cheque_offer_badge'),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (offer.requestedTestDrive &&
                      offer.testDriveResult != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F291E)
                            : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFF00E575),
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded,
                              size: 14, color: Color(0xFF00E575)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              offer.testDriveResult!,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFF86EFAC)
                                    : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isExpired) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF7F1D1D)
                              : const Color(0xFFFCA5A5),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '"${context.tr('buyer_timeout_message')}"',
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Color(0xFFEF4444),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else if (offer.buyerMessage.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF333B4F)
                              : const Color(0xFF0F172A),
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '"${offer.buyerMessage}"',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? palette.primaryColor
                              : const Color(0xFF0F172A),
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Actions
                  if (isExpired)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          context.tr('offer_expired_label'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFEF4444),
                          ),
                        )),
                        NeoBrutalButton(
                          label: context.tr('btn_clear_offer'),
                          icon: Icons.delete_outline_rounded,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFF1F5F9),
                          textColor: isDark
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFDC2626),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .dismissOffer(offer.id);
                          },
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalButton(
                          label: context.tr('btn_reject'),
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor: isDark
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFDC2626),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .rejectOffer(offer.id);
                          },
                        ),
                        Row(
                          children: [
                            NeoBrutalButton(
                              label: context.tr('btn_counter_offer'),
                              backgroundColor: const Color(0xFFFFDE59),
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              onPressed: () {
                                context.push(
                                  '/offer-evaluation',
                                  extra: OfferEvaluationArgs(car: car, offer: offer),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            TutorialPulseTarget(
                              isEnabled: !game.tutorialCompleted &&
                                  offer.carId == 'car_heritage_dede',
                              pulseColor: const Color(0xFF00E575),
                              child: NeoBrutalButton(
                                label: context.tr('btn_accept_and_sell'),
                                icon: Icons.check_circle_rounded,
                                backgroundColor: const Color(0xFF00E575),
                                textColor: Colors.black,
                                fontSize: 11,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                onPressed: () {
                                  _processOfferAcceptWithNotary(
                                      context, ref, offer, car);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _processOfferAcceptWithNotary(
    BuildContext context,
    WidgetRef ref,
    OfferModel offer,
    CarModel car,
  ) {
    GameSoundHapticService.playNotarySignature();
    final customer =
        offer.buyerCustomer ?? CustomerModel.generateRandomCustomer();
    final fraudResult = NegotiationEngine.evaluatePlayerFraudInspection(
        car: car, customer: customer);

    if (fraudResult.caughtFraud) {
      ref
          .read(gameProvider.notifier)
          .acceptOfferWithFraudCheck(offer, customer);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(18),
              backgroundColor:
                  palette.isDark ? const Color(0xFF141721) : Colors.white,
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
                      VectorIconWidget(
                          type: 'error', color: palette.errorColor, size: 24),
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
                    '${context.tr('fine_penalty_label', {
                          'amount': CurrencyFormatter.formatShort(
                              fraudResult.fineAmount)
                        })}\n'
                    '${context.tr('reputation_loss_label', {
                          'points': fraudResult.reputationPenalty.toString()
                        })}',
                    style: AppTypography.bodyMedium(palette.isDark),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: NeoBrutalButton(
                      label: context.tr('ok_button'),
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
      return;
    }

    final notaryResult =
        ref.read(gameProvider.notifier).processNotarySale(offer, customer);

    if (context.mounted) {
      NotaryTransferDialog.show(
        context: context,
        car: car,
        buyerName: offer.buyerName,
        sellerName: '${game.dealershipName} • ${game.playerName}',
        salePrice: offer.offeredAmount,
        isBuying: false,
        eventResult: notaryResult,
        onComplete: () {
          if (!notaryResult.isCancelled) {
            GameSoundHapticService.playCashSuccess();
            NotificationService.showSuccess(
              context,
              context.tr('notary_sale_success_toast', {
                'dealership': game.dealershipName,
                'amount': CurrencyFormatter.format(offer.offeredAmount),
              }),
            );
            final luckyOpp =
                ref.read(gameProvider.notifier).checkAndRollLuckyOpportunity();
            if (luckyOpp != null && context.mounted) {
              Future.delayed(const Duration(milliseconds: 300), () {
                if (context.mounted) {
                  LuckyOpportunityDialog.show(context, luckyOpp);
                }
              });
            }
          } else {
            NotificationService.showWarning(
              context,
              context.tr('notary_sale_cancelled_toast', {
                'car': '${car.brand} ${car.modelName}',
              }),
            );
          }
        },
      );
    }
  }
}
