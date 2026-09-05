import 'package:flutter/material.dart';
import '../../../../core/constants/car_specifications.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/auction_model.dart';
import '../../../../domain/usecases/consignment_auction_engine.dart';
import '../../../widgets/countdown_heat_ring.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class AuctionSellLiveView extends StatelessWidget {
  final ConsignmentAuctionModel auction;
  final bool isDark;
  final VoidCallback onDismissResult;

  const AuctionSellLiveView({
    super.key,
    required this.auction,
    required this.isDark,
    required this.onDismissResult,
  });

  @override
  Widget build(BuildContext context) {
    final car = auction.car;
    final isLastSeconds = auction.secondsRemaining <= 5 && auction.secondsRemaining > 0;
    final hp = car.factoryHorsepower;
    final torque = car.factoryTorque;
    final accel = CarSpecifications.getFactoryZeroToHundred(car.brand, car.modelName, bodyType: car.bodyType);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. TOP TIMER & GAVEL HEADER
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isLastSeconds
                  ? AppColors.errorRed.withValues(alpha: 0.15)
                  : (isDark ? const Color(0xFF141721) : Colors.white),
              borderColor: isLastSeconds
                  ? AppColors.errorRed
                  : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
              borderRadius: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLastSeconds ? AppColors.errorRed : AppColors.brutalYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          Icons.gavel_rounded,
                          color: isLastSeconds ? Colors.white : Colors.black,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGavelTitle(context, auction.gavelStage),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isLastSeconds
                                  ? AppColors.errorRed
                                  : (isDark ? Colors.white : const Color(0xFF0F172A)),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            auction.isReserveMet
                                ? context.tr('auction_sell_reserve_met')
                                : context.tr('auction_sell_reserve_not_met'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: auction.isReserveMet
                                  ? AppColors.brutalGreen
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  CountdownHeatRing(
                    remainingSeconds: auction.secondsRemaining,
                    totalSeconds: 30,
                    size: 48,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 2. CURRENT HIGHEST BID DISPLAY
            NeoBrutalCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: auction.isReserveMet ? AppColors.brutalGreen : const Color(0xFF0F172A),
              borderWidth: auction.isReserveMet ? 2.5 : 2.0,
              borderRadius: 14,
              shadowOffset: const Offset(3, 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('auction_sell_highest_bid'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                      NeoBrutalBadge(
                        text: auction.isReserveMet
                            ? context.tr('auction_sell_reserve_met')
                            : '${context.tr('auction_sell_reserve_price')} • ${CurrencyFormatter.formatShort(auction.reservePrice)}',
                        backgroundColor: auction.isReserveMet
                            ? AppColors.brutalGreen
                            : const Color(0xFF475569),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(auction.currentBid),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: auction.isReserveMet
                          ? AppColors.brutalGreen
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_pin_circle_rounded,
                        size: 14,
                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        auction.highestBidder != null
                            ? auction.highestBidder!.name
                            : context.tr('auction_sell_no_bids_yet'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. VEHICLE SPECIFICATION COMPACT CARD
            NeoBrutalCard(
              padding: const EdgeInsets.all(12),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.modelYear} ${car.brand} ${car.modelName}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      NeoBrutalBadge(
                        text: car.bodyType,
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildSpecPill(
                        label: context.tr('auction_sell_hp_label'),
                        value: '$hp HP',
                        icon: Icons.speed_rounded,
                      ),
                      _buildSpecPill(
                        label: context.tr('auction_sell_torque_label'),
                        value: '$torque Nm',
                        icon: Icons.offline_bolt_rounded,
                      ),
                      _buildSpecPill(
                        label: context.tr('auction_sell_accel_label'),
                        value: '${accel.toStringAsFixed(1)}s',
                        icon: Icons.timer_outlined,
                      ),
                      _buildSpecPill(
                        label: context.tr('auction_sell_engine_label'),
                        value: '%${car.expertise.engineCondition.round()}',
                        icon: Icons.engineering_rounded,
                        isPositive: car.expertise.engineCondition >= 80,
                      ),
                      _buildSpecPill(
                        label: context.tr('auction_sell_tramer_label'),
                        value: CurrencyFormatter.formatShort(car.expertise.tramerAmount.toDouble()),
                        icon: Icons.receipt_long_rounded,
                        isNegative: car.expertise.tramerAmount > 30000,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. BUYERS POOL PANEL
            Text(
              context.tr('auction_sell_buyers_panel'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            ...auction.buyers.map((buyer) {
              final isHighest = auction.highestBidder?.id == buyer.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: buyer.isFolded
                      ? (isDark ? const Color(0xFF0F131C) : const Color(0xFFF1F5F9))
                      : (isHighest
                          ? (isDark ? const Color(0xFF132A1C) : const Color(0xFFF0FDF4))
                          : (isDark ? const Color(0xFF141721) : Colors.white)),
                  borderColor: isHighest
                      ? AppColors.brutalGreen
                      : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                  borderWidth: isHighest ? 2.0 : 1.5,
                  borderRadius: 10,
                  shadowOffset: isHighest ? const Offset(2, 2) : const Offset(1, 1),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getBuyerColor(buyer.type),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          _getBuyerIcon(buyer.type),
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  buyer.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: buyer.isFolded
                                        ? const Color(0xFF64748B)
                                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                  ),
                                ),
                                if (buyer.isFolded)
                                  NeoBrutalBadge(
                                    text: context.tr('auction_sell_buyer_folded'),
                                    backgroundColor: const Color(0xFF64748B),
                                    textColor: Colors.white,
                                  )
                                else if (isHighest)
                                  NeoBrutalBadge(
                                    text: context.tr('auction_sell_highest_bid'),
                                    backgroundColor: AppColors.brutalGreen,
                                    textColor: Colors.white,
                                  )
                                else
                                  Text(
                                    _getBuyerTypeLabel(context, buyer.type),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),
                            if (buyer.lastSpeech != null && buyer.lastSpeech!.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                '"${buyer.lastSpeech}"',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white60 : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 10),

            // 5. LIVE LOG FEED
            Text(
              context.tr('auction_sell_feed_title'),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            NeoBrutalCard(
              padding: const EdgeInsets.all(10),
              backgroundColor: isDark ? const Color(0xFF0E1118) : const Color(0xFFF8FAFC),
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: auction.logs.reversed.take(4).map((log) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            log,
                            style: TextStyle(
                              fontSize: 11,
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
            const SizedBox(height: 30),
          ],
        ),

        // 6. RESULT MODAL OVERLAY (when auction has ended)
        if (auction.isEnded)
          Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(20),
            child: Center(
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(20),
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: auction.isSold ? AppColors.brutalGreen : AppColors.errorRed,
                borderWidth: 2.5,
                borderRadius: 16,
                shadowOffset: const Offset(4, 4),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: auction.isSold ? AppColors.brutalGreen : AppColors.errorRed,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: Icon(
                          auction.isSold ? Icons.emoji_events_rounded : Icons.cancel_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        auction.isSold
                            ? context.tr('auction_sell_sold_title')
                            : context.tr('auction_sell_not_sold_title'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        auction.isSold
                            ? context.tr('auction_sell_sold_desc')
                            : context.tr('auction_sell_not_sold_desc'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (auction.isSold) ...[
                        // Financial breakdown
                        _buildSummaryRow(
                          context,
                          label: context.tr('auction_sell_sale_price'),
                          value: CurrencyFormatter.format(auction.currentBid),
                          isBold: true,
                        ),
                        _buildSummaryRow(
                          context,
                          label: context.tr('auction_sell_commission_deducted'),
                          value: '-${CurrencyFormatter.format(auction.commissionFee)}',
                          valueColor: AppColors.errorRed,
                        ),
                        _buildSummaryRow(
                          context,
                          label: context.tr('auction_sell_fixed_fee'),
                          value: '-${CurrencyFormatter.format(auction.fixedFee)}',
                          valueColor: AppColors.errorRed,
                        ),
                        const Divider(height: 16),
                        _buildSummaryRow(
                          context,
                          label: context.tr('auction_sell_net_income'),
                          value: CurrencyFormatter.format(auction.netPayout),
                          isBold: true,
                          valueColor: AppColors.brutalGreen,
                        ),
                      ] else ...[
                        _buildSummaryRow(
                          context,
                          label: context.tr('auction_sell_highest_bid'),
                          value: CurrencyFormatter.format(auction.currentBid),
                        ),
                        _buildSummaryRow(
                          context,
                          label: context.tr('auction_sell_reserve_price'),
                          value: CurrencyFormatter.format(auction.reservePrice),
                        ),
                      ],
                      const SizedBox(height: 20),
                      NeoBrutalButton(
                        label: auction.isSold
                            ? context.tr('auction_sell_collect_btn')
                            : context.tr('auction_sell_return_garage'),
                        backgroundColor: auction.isSold ? AppColors.brutalGreen : AppColors.brutalYellow,
                        textColor: Colors.black,
                        onPressed: () {
                          GameSoundHapticService.playCashSuccess();
                          onDismissResult();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill({
    required String label,
    required String value,
    required IconData icon,
    bool isPositive = false,
    bool isNegative = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive
            ? AppColors.brutalGreen.withValues(alpha: 0.15)
            : (isNegative
                ? AppColors.errorRed.withValues(alpha: 0.15)
                : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9))),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPositive
              ? AppColors.brutalGreen
              : (isNegative
                  ? AppColors.errorRed
                  : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1))),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? Colors.white70 : const Color(0xFF475569)),
          const SizedBox(width: 4),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: isPositive
                  ? AppColors.brutalGreen
                  : (isNegative
                      ? AppColors.errorRed
                      : (isDark ? Colors.white : const Color(0xFF0F172A))),
            ),
          ),
        ],
      ),
    );
  }

  String _getGavelTitle(BuildContext context, AuctionGavelStage stage) {
    switch (stage) {
      case AuctionGavelStage.ongoing:
        return context.tr('auction_sell_live_title');
      case AuctionGavelStage.firstCall:
        return context.tr('auction_sell_gavel_first');
      case AuctionGavelStage.secondCall:
        return context.tr('auction_sell_gavel_second');
      case AuctionGavelStage.finalHammer:
        return context.tr('auction_sell_gavel_sold');
    }
  }

  Color _getBuyerColor(ConsignmentBuyerType type) {
    switch (type) {
      case ConsignmentBuyerType.dealer:
        return AppColors.brutalYellow;
      case ConsignmentBuyerType.collector:
        return const Color(0xFFA855F7);
      case ConsignmentBuyerType.fleet:
        return const Color(0xFF38BDF8);
      case ConsignmentBuyerType.sniper:
        return AppColors.errorRed;
      case ConsignmentBuyerType.impatient:
        return const Color(0xFFFB923C);
      case ConsignmentBuyerType.retiree:
        return const Color(0xFF34D399);
    }
  }

  IconData _getBuyerIcon(ConsignmentBuyerType type) {
    switch (type) {
      case ConsignmentBuyerType.dealer:
        return Icons.store_mall_directory_rounded;
      case ConsignmentBuyerType.collector:
        return Icons.workspace_premium_rounded;
      case ConsignmentBuyerType.fleet:
        return Icons.local_shipping_rounded;
      case ConsignmentBuyerType.sniper:
        return Icons.gps_fixed_rounded;
      case ConsignmentBuyerType.impatient:
        return Icons.bolt_rounded;
      case ConsignmentBuyerType.retiree:
        return Icons.history_edu_rounded;
    }
  }

  String _getBuyerTypeLabel(BuildContext context, ConsignmentBuyerType type) {
    switch (type) {
      case ConsignmentBuyerType.dealer:
        return context.tr('auction_sell_buyer_type_dealer');
      case ConsignmentBuyerType.collector:
        return context.tr('auction_sell_buyer_type_collector');
      case ConsignmentBuyerType.fleet:
        return context.tr('auction_sell_buyer_type_fleet');
      case ConsignmentBuyerType.sniper:
        return context.tr('auction_sell_buyer_type_sniper');
      case ConsignmentBuyerType.impatient:
        return context.tr('auction_sell_buyer_type_impatient');
      case ConsignmentBuyerType.retiree:
        return context.tr('auction_sell_buyer_type_retiree');
    }
  }
}
