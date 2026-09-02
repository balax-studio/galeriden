import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/game_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/visitor_queue_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../providers/tutorial_provider.dart';
import '../../../widgets/animated_rolling_counter.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pulsing_dot.dart';
import '../../../widgets/tutorial_pulse_target.dart';
import '../../../widgets/foil_shimmer_widget.dart';
import '../../../widgets/leather_keychain_swing_widget.dart';
import 'car_cost_breakdown_sheet.dart';

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
    final hasOffer =
        game.incomingOffers.any((o) => o.carId == car.id && !o.isExpired);
    final hasActiveGossipIntel = game.activeGossips.any((g) =>
            g.isPurchased &&
            (game.currentDay - g.inGameDay <= 2) &&
            ((g.targetSegment != null &&
                    g.targetSegment!.toLowerCase() ==
                        car.bodyType.toLowerCase()) ||
                (g.targetCarId != null && g.targetCarId == car.id) ||
                (g.targetSegment != null &&
                    g.targetSegment!.toLowerCase() ==
                        car.brand.toLowerCase()))) ||
        game.playerSpreadGossips.any((r) =>
            !r.isExpired(game.currentDay) &&
            r.targetSegment.toLowerCase() == car.bodyType.toLowerCase());
    final nextSec = VisitorQueueEngine.calculateNextVisitorSeconds(
      car: car,
      reputation: game.reputationScore,
      hasSalesman: hasSalesman,
      marketSenseBonus: game.skills.marketSense * 0.05,
    );

    final isTutorialFocusCar =
        !game.tutorialCompleted && car.id == 'car_heritage_dede';

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: FoilShimmerWidget(
          isEnabled: car.isRare || isTutorialFocusCar,
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isTutorialFocusCar
                ? const Color(0xFFFFDE59)
                : (hasOffer
                    ? const Color(0xFF00E575)
                    : (car.isDoped
                        ? const Color(0xFFFFDE59)
                        : (isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFF0F172A)))),
            borderRadius: 10,
            borderWidth: isTutorialFocusCar ? 3.0 : 2.5,
            shadowOffset: const Offset(4.5, 4.5),
            showDotGrid: true,
            showHazardHeader: car.isStaleListing || car.isBarnFind,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isTutorialFocusCar) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          NeoBrutalBadge(
                            text: context.tr('tut_action_badge'),
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 9.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                          ),
                          const SizedBox(width: 6),
                          const PulsingDot(color: Color(0xFFFFDE59), size: 6),
                          const SizedBox(width: 4),
                          Text(
                            !car.isListed
                                ? context.tr('tut_step_list_title')
                                : (hasOffer
                                    ? context.tr('tut_step_sell_title')
                                    : context.tr('badge_has_offer')),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          ref.read(gameProvider.notifier).skipTutorial();
                          ref.read(tutorialProvider.notifier).skipTutorial();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            context.tr('onboarding_skip_btn'),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const LeatherKeychainSwingWidget(size: 24),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${car.brand} ${car.modelName}',
                              style: TextStyle(
                                fontSize: 15,
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
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_buildContextualStampBadge(context) != null) ...[
                          _buildContextualStampBadge(context)!,
                          const SizedBox(width: 6),
                        ],
                        NeoBrutalBadge(
                          text: car.bodyType,
                          fontSize: 9.5,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      if (hasOffer) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const PulsingDot(
                                color: Color(0xFF00E575), size: 6.0),
                            const SizedBox(width: 4),
                            NeoBrutalBadge(
                              text: context.tr('badge_has_offer'),
                              icon: Icons.local_fire_department_rounded,
                              backgroundColor: const Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 9.5,
                            ),
                          ],
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (car.isLockedInShowcase) ...[
                        NeoBrutalBadge(
                          text: context.tr('badge_showcase_locked'),
                          icon: Icons.lock_rounded,
                          backgroundColor: AppColors.brutalCyan,
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ] else if (car.isRented) ...[
                        NeoBrutalBadge(
                          text: context.tr('badge_rented'),
                          icon: Icons.key_rounded,
                          backgroundColor: AppColors.brutalPurple,
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ] else ...[
                        NeoBrutalBadge(
                          text: car.isListed
                              ? context.tr('badge_listed')
                              : context.tr('badge_in_garage'),
                          backgroundColor: car.isListed
                              ? const Color(0xFF00E575)
                              : (isDark
                                  ? const Color(0xFF1E2330)
                                  : const Color(0xFFE2E8F0)),
                          textColor: car.isListed
                              ? Colors.black
                              : (isDark ? Colors.white70 : Colors.black87),
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isOverTuned) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_overtuned'),
                          icon: Icons.speed_rounded,
                          backgroundColor: AppColors.brutalOrange,
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isHeroShowcase) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_hero_showcase'),
                          icon: Icons.star_rounded,
                          backgroundColor: const Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isStaleListing) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_stale_listing'),
                          icon: Icons.warning_amber_rounded,
                          backgroundColor: const Color(0xFFEF4444),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isBarnFindRestored) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_barn_restored'),
                          icon: Icons.auto_awesome_rounded,
                          backgroundColor: const Color(0xFF10B981),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ] else if (car.isBarnFind) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_barn_find'),
                          icon: Icons.handyman_rounded,
                          backgroundColor: const Color(0xFFD97706),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.hasNonOriginalParts) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_aftermarket_parts'),
                          backgroundColor: const Color(0xFF64748B),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isDoped) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_doped'),
                          icon: Icons.bolt_rounded,
                          backgroundColor: const Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                      if (car.isLockedInShowcase) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_in_collection'),
                          icon: Icons.workspace_premium_rounded,
                          backgroundColor: const Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ] else if (car.isRare) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_rare'),
                          icon: Icons.diamond_rounded,
                          backgroundColor: const Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 9.5,
                        ),
                      ],
                      if (hasActiveGossipIntel) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('badge_intel_active'),
                          icon: Icons.campaign_rounded,
                          backgroundColor: AppColors.brutalCyan,
                          textColor: Colors.black,
                          fontSize: 9.5,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Visitor Queue Countdown Indicator for Listed Cars
                if (car.isListed) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFFEF3C7),
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
                            const Icon(Icons.timer_rounded,
                                size: 16, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 6),
                            Text(
                              context.tr('next_customer_time', {
                                'time':
                                    '${(nextSec ~/ 60).toString().padLeft(2, '0')}:${(nextSec % 60).toString().padLeft(2, '0')}'
                              }),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? const Color(0xFFFDE68A)
                                    : const Color(0xFF92400E),
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
                                          final success = ref
                                              .read(gameProvider.notifier)
                                              .boostListingDoping(car.id);
                                          if (success) {
                                            NotificationService.showSuccess(
                                              context,
                                              context.tr(
                                                  'boost_social_success', {
                                                'car':
                                                    '${car.brand} ${car.modelName}'
                                              }),
                                            );
                                          } else {
                                            NotificationService.showInfo(
                                              context,
                                              context
                                                  .tr('boost_social_already'),
                                            );
                                          }
                                        },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDoped
                                          ? (isDark
                                              ? const Color(0xFF1E2330)
                                              : const Color(0xFFCBD5E1))
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
                                              ? (isDark
                                                  ? Colors.white54
                                                  : Colors.black54)
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isDoped
                                              ? context.tr('shared_badge')
                                              : context
                                                  .tr('share_boost_action'),
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: isDoped
                                                ? (isDark
                                                    ? Colors.white54
                                                    : Colors.black54)
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
                                final double minFloorPrice =
                                    (car.currentPurchasePrice > 0
                                            ? car.currentPurchasePrice * 0.85
                                            : car.estimatedRealValue * 0.70)
                                        .roundToDouble();
                                final bool canCutPrice =
                                    car.listingPrice > minFloorPrice;

                                return InkWell(
                                  onTap: !canCutPrice
                                      ? null
                                      : () {
                                          final discountedPrice =
                                              (car.listingPrice * 0.95)
                                                  .roundToDouble();
                                          ref
                                              .read(gameProvider.notifier)
                                              .updateCarListingPrice(
                                                  car.id, discountedPrice);
                                          NotificationService.showSuccess(
                                            context,
                                            context.tr('cut_price_success', {
                                              'price':
                                                  CurrencyFormatter.formatShort(
                                                      discountedPrice)
                                            }),
                                          );
                                        },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: !canCutPrice
                                          ? (isDark
                                              ? const Color(0xFF1E2330)
                                              : const Color(0xFFCBD5E1))
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
                                              ? (isDark
                                                  ? Colors.white54
                                                  : Colors.black54)
                                              : Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          !canCutPrice
                                              ? context.tr('floor_price_badge')
                                              : context.tr('cut_price_action'),
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: !canCutPrice
                                                ? (isDark
                                                    ? Colors.white54
                                                    : Colors.black54)
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
                                ref
                                    .read(gameProvider.notifier)
                                    .triggerOrganicOffers();
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('share_social_success',
                                      {'name': game.dealershipName}),
                                );
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.share_rounded,
                                        size: 11, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      context.tr('share_call_action'),
                                      style: const TextStyle(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1A1F2C)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: car.plateRarity == 'legendary'
                                  ? const Color(0xFFFFD700)
                                  : (car.plateRarity == 'repeated' ||
                                          car.plateRarity == 'symmetric'
                                      ? const Color(0xFF38BDF8)
                                      : (isDark
                                          ? Colors.white12
                                          : const Color(0xFF0F172A))),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              car.plateNumber,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: car.plateRarity == 'legendary' ||
                                        car.plateRarity == 'repeated' ||
                                        car.plateRarity == 'symmetric'
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
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.build_circle_rounded,
                            size: 13,
                            color: car.hasNonOriginalParts
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF00E575),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${context.tr('engine_condition')}: %${car.expertise.engineCondition.round()}',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Band 2: Net Kâr & Fiyat Isı Şeridi (Profit Margin Heat Stripe §1.5)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
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
                                  context.tr('purchase_cost_label'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                AnimatedRollingCounter(
                                  value: car.currentPurchasePrice,
                                  isShort: true,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.tr('net_profit_analysis'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.info_outline_rounded,
                                          size: 10,
                                          color: isDark
                                              ? Colors.white60
                                              : Colors.black45,
                                        ),
                                      ],
                                    ),
                                    AnimatedRollingCounter(
                                      value: car.netEstimatedProfit,
                                      isShort: true,
                                      prefix: car.netEstimatedProfit >= 0
                                          ? '+'
                                          : '',
                                      suffix:
                                          ' • %${car.profitMarginPercent.round()}',
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
                                  car.isListed
                                      ? context.tr('listing_price_label')
                                      : context.tr('market_value'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? const Color(0xFF94A3B8)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                                AnimatedRollingCounter(
                                  value: car.isListed
                                      ? car.listingPrice
                                      : car.estimatedRealValue,
                                  isShort: true,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900,
                                    color: car.isListed
                                        ? const Color(0xFF00E575)
                                        : (isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A)),
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
                            context.tr(
                                'days_listed_label', {'days': car.daysListed}),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: car.isStaleListing
                                  ? const Color(0xFFEF4444)
                                  : (isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B)),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (!car.hasGloveboxSearched) ...[
                          InkWell(
                            onTap: () {
                              final result = ref
                                  .read(gameProvider.notifier)
                                  .searchGlovebox(car.id);
                              if (result['success'] == true) {
                                NotificationService.showSuccess(
                                  context,
                                  result['message'] as String,
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDE59),
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: Colors.black, width: 1.0),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.search_rounded,
                                      size: 11, color: Colors.black),
                                  const SizedBox(width: 3),
                                  Text(
                                    context.tr('glovebox_search_btn'),
                                    style: const TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black),
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
                          ? context.tr('honest_listing_badge')
                          : (car.declarationType ==
                                  ListingDeclarationType.flawlessClaim
                              ? context.tr('flawless_claim_badge')
                              : context.tr('mileage_tamper_badge')),
                      backgroundColor:
                          car.declarationType == ListingDeclarationType.honest ||
                                  (car.declarationType ==
                                          ListingDeclarationType.flawlessClaim &&
                                      car.isPristineOriginal)
                              ? const Color(0xFF00E575)
                              : (car.declarationType ==
                                      ListingDeclarationType.flawlessClaim
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
                      child: TutorialPulseTarget(
                        isEnabled: isTutorialFocusCar && (!car.isListed || hasOffer),
                        pulseColor: !car.isListed
                            ? AppColors.brutalYellow
                            : const Color(0xFF00E575),
                        child: NeoBrutalButton(
                          label: car.isLockedInShowcase
                              ? context.tr('badge_showcase_locked')
                              : (car.isRented
                                  ? context.tr('badge_rented')
                                  : (isTutorialFocusCar && !car.isListed
                                      ? context.tr('tut_step_list_title')
                                      : (isTutorialFocusCar && hasOffer
                                          ? context.tr('tut_step_sell_title')
                                          : context.tr('edit_listing_btn')))),
                          icon: car.isLockedInShowcase
                              ? Icons.lock_rounded
                              : (car.isRented
                                  ? Icons.key_rounded
                                  : (isTutorialFocusCar && !car.isListed
                                      ? Icons.publish_rounded
                                      : (isTutorialFocusCar && hasOffer
                                          ? Icons.local_fire_department_rounded
                                          : Icons.edit_note_rounded))),
                          backgroundColor:
                              (car.isLockedInShowcase || car.isRented)
                                  ? (isDark
                                      ? const Color(0xFF141721)
                                      : const Color(0xFFF1F5F9))
                                  : (isTutorialFocusCar && !car.isListed
                                      ? AppColors.brutalYellow
                                      : (isTutorialFocusCar && hasOffer
                                          ? const Color(0xFF00E575)
                                          : (isDark
                                              ? const Color(0xFF1E2330)
                                              : const Color(0xFFE2E8F0)))),
                          textColor: (car.isLockedInShowcase || car.isRented)
                              ? const Color(0xFF64748B)
                              : (isTutorialFocusCar
                                  ? Colors.black
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A))),
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          onPressed: () {
                            if (isTutorialFocusCar && hasOffer) {
                              try {
                                DefaultTabController.of(context).animateTo(1);
                              } catch (_) {
                                context.push('/create-listing', extra: car);
                              }
                            } else {
                              context.push('/create-listing', extra: car);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeoBrutalButton(
                        label: car.isDoped
                            ? context.tr('badge_doped')
                            : context.tr('doping_boost_btn', {
                                'cost': CurrencyFormatter.formatShort(
                                    GameConstants.dopingCost)
                              }),
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
                                  context.tr('doping_already_used'),
                                )
                            : () {
                                if (!car.isListed) {
                                  NotificationService.showError(
                                    context,
                                    context.tr('doping_not_listed'),
                                  );
                                  return;
                                }
                                final activeOffersCount = game.incomingOffers
                                    .where((o) =>
                                        o.carId == car.id && !o.isExpired)
                                    .length;
                                if (activeOffersCount >= 3) {
                                  NotificationService.showError(
                                    context,
                                    context.tr('doping_max_offers'),
                                  );
                                  return;
                                }
                                final success = ref
                                    .read(gameProvider.notifier)
                                    .boostListingDoping(car.id);
                                if (success) {
                                  NotificationService.showSuccess(
                                    context,
                                    context.tr('doping_success_toast', {
                                      'car': '${car.brand} ${car.modelName}',
                                      'cost': CurrencyFormatter.format(
                                          GameConstants.dopingCost),
                                    }),
                                  );
                                } else {
                                  NotificationService.showError(
                                    context,
                                    context.tr('doping_insufficient_funds', {
                                      'cost': CurrencyFormatter.format(
                                          GameConstants.dopingCost),
                                    }),
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
                    label: context.tr('refresh_listing_btn', {
                      'cost': CurrencyFormatter.format(
                          GameConstants.refreshListingCost)
                    }),
                    icon: Icons.refresh_rounded,
                    backgroundColor: const Color(0xFFEF4444),
                    textColor: Colors.white,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    fullWidth: true,
                    onPressed: () {
                      final ok = ref
                          .read(gameProvider.notifier)
                          .refreshStaleListing(car.id);
                      if (ok) {
                        NotificationService.showSuccess(
                          context,
                          context.tr('stale_refresh_success',
                              {'car': '${car.brand} ${car.modelName}'}),
                        );
                      } else {
                        NotificationService.showError(
                          context,
                          context.tr('stale_refresh_insufficient_funds', {
                            'cost': CurrencyFormatter.format(
                                GameConstants.refreshListingCost)
                          }),
                        );
                      }
                    },
                  ),
                ],
                if (car.isListed) ...[
                  const SizedBox(height: 8),
                  NeoBrutalButton(
                    label: car.isHeroShowcase
                        ? context.tr('hero_showcase_remove')
                        : context.tr('hero_showcase_add'),
                    icon: car.isHeroShowcase
                        ? Icons.star_border_rounded
                        : Icons.star_rounded,
                    backgroundColor: car.isHeroShowcase
                        ? (isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0))
                        : const Color(0xFFFFDE59),
                    textColor: Colors.black,
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    fullWidth: true,
                    onPressed: () {
                      final ok = ref
                          .read(gameProvider.notifier)
                          .toggleHeroShowcase(car.id);
                      if (ok) {
                        NotificationService.showSuccess(
                          context,
                          car.isHeroShowcase
                              ? context.tr('hero_showcase_removed_toast',
                                  {'car': '${car.brand} ${car.modelName}'})
                              : context.tr('hero_showcase_added_toast',
                                  {'car': '${car.brand} ${car.modelName}'}),
                        );
                      }
                    },
                  ),
                ],
                // Koleksiyon Vitrinine Kilitleme (Her araç için mülkiyet & yadigâr hakkı)
                const SizedBox(height: 8),
                NeoBrutalButton(
                  label: car.isLockedInShowcase
                      ? context.tr('unlock_collection_btn')
                      : context.tr('lock_collection_btn'),
                  icon: car.isLockedInShowcase
                      ? Icons.lock_open_rounded
                      : Icons.workspace_premium_rounded,
                  backgroundColor: car.isLockedInShowcase
                      ? (isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0))
                      : const Color(0xFFA855F7),
                  textColor: car.isLockedInShowcase
                      ? (isDark ? Colors.white : Colors.black)
                      : Colors.white,
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  fullWidth: true,
                  onPressed: () {
                    if (car.isLockedInShowcase) {
                      showDialog(
                        context: context,
                        builder: (dCtx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                          child: NeoBrutalCard(
                            padding: const EdgeInsets.all(18),
                            backgroundColor:
                                isDark ? const Color(0xFF141721) : Colors.white,
                            borderColor: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            borderRadius: 12,
                            borderWidth: 2.5,
                            shadowOffset: const Offset(4, 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('dialog_unlock_title'),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  context.tr('dialog_unlock_desc'),
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    NeoBrutalButton(
                                      label: context.tr('dialog_unlock_cancel'),
                                      backgroundColor: isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0),
                                      textColor: isDark
                                          ? Colors.white70
                                          : const Color(0xFF64748B),
                                      fontSize: 11,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      onPressed: () => Navigator.pop(dCtx),
                                    ),
                                    const SizedBox(width: 8),
                                    NeoBrutalButton(
                                      label:
                                          context.tr('dialog_unlock_confirm'),
                                      icon: Icons.lock_open_rounded,
                                      backgroundColor: AppColors.errorRed,
                                      textColor: Colors.white,
                                      fontSize: 11,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      onPressed: () {
                                        Navigator.pop(dCtx);
                                        ref
                                            .read(gameProvider.notifier)
                                            .toggleShowcaseLock(car.id);
                                        NotificationService.showSuccess(
                                            context,
                                            context.tr(
                                                'showcase_unlocked_toast', {
                                              'car':
                                                  '${car.brand} ${car.modelName}'
                                            }));
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
                      final success = ref
                          .read(gameProvider.notifier)
                          .toggleShowcaseLock(car.id);
                      if (success) {
                        NotificationService.showSuccess(
                          context,
                          context.tr('showcase_locked_toast',
                              {'car': '${car.brand} ${car.modelName}'}),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildContextualStampBadge(BuildContext context) {
    if (car.isRare) {
      return NeoBrutalBadge(
        text: context.tr('stamp_rare_collector'),
        backgroundColor: const Color(0xFFA855F7),
        textColor: Colors.white,
        borderColor: const Color(0xFF0F172A),
        borderWidth: 1.6,
        borderRadius: 4.0,
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
        angle: -0.06,
        showHardShadow: true,
        shadowOffset: const Offset(1.5, 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      );
    }
    if (car.expertise.engineCondition >= 90 && car.expertise.transmissionCondition >= 90) {
      return NeoBrutalBadge(
        text: context.tr('stamp_expert_approved'),
        backgroundColor: const Color(0xFF10B981),
        textColor: Colors.black,
        borderColor: const Color(0xFF0F172A),
        borderWidth: 1.6,
        borderRadius: 4.0,
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
        angle: 0.05,
        showHardShadow: true,
        shadowOffset: const Offset(1.5, 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      );
    }
    if (car.expertise.tramerAmount == 0 &&
        !car.expertise.bodyParts.values.any((s) => s != PartStatus.original)) {
      return NeoBrutalBadge(
        text: context.tr('stamp_accident_free'),
        backgroundColor: const Color(0xFF0EA5E9),
        textColor: Colors.black,
        borderColor: const Color(0xFF0F172A),
        borderWidth: 1.6,
        borderRadius: 4.0,
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
        angle: -0.05,
        showHardShadow: true,
        shadowOffset: const Offset(1.5, 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      );
    }
    if (car.isStaleListing) {
      return NeoBrutalBadge(
        text: context.tr('stamp_urgent_sale'),
        backgroundColor: const Color(0xFFEF4444),
        textColor: Colors.white,
        borderColor: const Color(0xFF0F172A),
        borderWidth: 1.6,
        borderRadius: 4.0,
        fontSize: 8.5,
        fontWeight: FontWeight.w900,
        angle: 0.06,
        showHardShadow: true,
        shadowOffset: const Offset(1.5, 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      );
    }
    return null;
  }
}
