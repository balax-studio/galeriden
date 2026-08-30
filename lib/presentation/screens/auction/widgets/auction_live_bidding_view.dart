import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../data/models/auction_model.dart';
import '../../../widgets/bid_paddle_animation.dart';
import '../../../widgets/countdown_heat_ring.dart';
import '../../../widgets/gavel_shockwave_widget.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class AuctionLiveBiddingView extends StatelessWidget {
  final AuctionModel auction;
  final List<String> bidLogs;
  final bool isDark;
  final void Function(double increment, {bool isAggressiveFlag}) onPlaceBid;
  final VoidCallback onBluff;

  const AuctionLiveBiddingView({
    super.key,
    required this.auction,
    required this.bidLogs,
    required this.isDark,
    required this.onPlaceBid,
    required this.onBluff,
  });

  @override
  Widget build(BuildContext context) {
    final car = auction.car;
    final isLastSeconds =
        auction.secondsRemaining <= 5 && auction.secondsRemaining > 0;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      physics: const BouncingScrollPhysics(),
      children: [
        // 1. 3-STAGE GAVEL & FOMO TIMER BANNER
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isLastSeconds
              ? AppColors.errorRed.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF141721) : Colors.white),
          borderColor: isLastSeconds
              ? AppColors.errorRed
              : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
          borderRadius: 14,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isLastSeconds
                              ? AppColors.errorRed
                              : AppColors.brutalYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
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
                            context.tr(auction.gavelCallLocalizationKey),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isLastSeconds
                                  ? AppColors.errorRed
                                  : (isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A)),
                            ),
                          ),
                          Text(
                            context.tr('auction_time_remaining', {
                              'sec': auction.secondsRemaining,
                            }),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (isLastSeconds) ...[
                        const GavelShockwaveWidget(size: 32),
                        const SizedBox(width: 6),
                      ],
                      CountdownHeatRing(
                        remainingSeconds: auction.secondsRemaining,
                        totalSeconds: 15,
                        size: 38,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 1.1 CUSTOMS ANNOTATION & OFFICIAL REPORT
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: AppColors.brutalOrange,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        auction.customsNote.originOffice,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: auction.customsNote.legalStatus,
                    backgroundColor: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    context.tr('auction_expert_note'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      auction.customsNote.riskRewardFactor,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2. MONOLITHIC CAR DETAIL CARD
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
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
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${car.modelYear} • ${car.expertise.mileage} KM • ${car.bodyType}',
                          style: TextStyle(
                            fontSize: 11.5,
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
                    text: context.tr('auction_market_est', {
                      'price': CurrencyFormatter.formatShort(
                        auction.estimatedMarketValue,
                      ),
                    }),
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F1118)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFFCBD5E1),
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
                          context.tr('auction_highest_bid_label'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.formatShort(auction.currentBid),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr('auction_bidder_label'),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BidPaddleAnimation(
                              paddleNumber:
                                  '${(auction.currentBid.toInt() % 89) + 10}',
                              bidderName: auction.highestBidderName,
                            ),
                            const SizedBox(width: 6),
                            NeoBrutalBadge(
                              text: auction.highestBidderName,
                              backgroundColor: auction.isPlayerHighestBidder
                                  ? AppColors.brutalGreen
                                  : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE2E8F0)),
                              textColor: auction.isPlayerHighestBidder
                                  ? Colors.black
                                  : (isDark ? Colors.white : Colors.black),
                              fontSize: 10.5,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 2.1 DYNAMIC RIVAL SPEECH BUBBLE
        if (auction.activeSpeech != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.brutalYellow.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.brutalYellow, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.brutalYellow,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${auction.activeSpeakerName ?? context.tr('auction_unknown_speaker')}: "${auction.activeSpeech}"',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 3. QUICK BID BUTTONS & AGGRESSIVE FLAG BID
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      context.tr('auction_quick_bids'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (auction.isPlayerHighestBidder)
                    NeoBrutalBadge(
                      text: context.tr('auction_leader_you'),
                      icon: Icons.workspace_premium_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 10,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: '+₺5.000',
                      backgroundColor: auction.isPlayerHighestBidder
                          ? (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0))
                          : AppColors.brutalYellow,
                      textColor: auction.isPlayerHighestBidder
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: auction.isPlayerHighestBidder
                          ? null
                          : () => onPlaceBid(5000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: '+₺15.000',
                      backgroundColor: auction.isPlayerHighestBidder
                          ? (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0))
                          : AppColors.brutalOrange,
                      textColor: auction.isPlayerHighestBidder
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: auction.isPlayerHighestBidder
                          ? null
                          : () => onPlaceBid(15000),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: '+₺30.000',
                      backgroundColor: auction.isPlayerHighestBidder
                          ? (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0))
                          : AppColors.brutalGreen,
                      textColor: auction.isPlayerHighestBidder
                          ? (isDark ? Colors.white54 : Colors.black54)
                          : Colors.black,
                      fontSize: 12,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      onPressed: auction.isPlayerHighestBidder
                          ? null
                          : () => onPlaceBid(30000),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      icon: Icons.flag_rounded,
                      label: context.tr(
                        'auction_btn_flag',
                        {'amount': '₺50.000'},
                      ),
                      backgroundColor: auction.isPlayerHighestBidder
                          ? (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0))
                          : const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed: auction.isPlayerHighestBidder
                          ? null
                          : () => onPlaceBid(50000, isAggressiveFlag: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      icon: Icons.psychology_rounded,
                      label: context.tr(
                        'auction_btn_bluff',
                        {'amount': '₺20.000'},
                      ),
                      backgroundColor: auction.isPlayerHighestBidder
                          ? (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0))
                          : const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 11,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      onPressed:
                          auction.isPlayerHighestBidder ? null : onBluff,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 4. COMPETITORS / RIVALS
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(
                  'auction_rivals_title',
                  {'count': '${auction.rivals.length}'},
                ),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              ...auction.rivals.map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            r.isFolded
                                ? Icons.close_rounded
                                : Icons.person_rounded,
                            size: 15,
                            color: r.isFolded
                                ? AppColors.errorRed
                                : AppColors.brutalGreen,
                          ),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: r.isFolded
                                      ? (isDark
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFF94A3B8))
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                              if (r.lastSpeech != null)
                                Text(
                                  '"${r.lastSpeech}"',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    color: Color(0xFF64748B),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: r.isFolded
                            ? context.tr('auction_folded_badge')
                            : r.personality,
                        backgroundColor: r.isFolded
                            ? (isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFFCBD5E1))
                            : (isDark
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFE2E8F0)),
                        textColor: r.isFolded
                            ? (isDark ? Colors.white60 : Colors.black54)
                            : (isDark ? Colors.white : Colors.black),
                        fontSize: 9.5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // 5. LIVE BIDDING LOGS
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor:
              isDark ? const Color(0xFF0F1118) : const Color(0xFFF8FAFC),
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('auction_live_stream_title'),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              ...bidLogs.take(5).map(
                (log) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Text(
                    log,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: log.contains('SEN')
                          ? AppColors.brutalGreen
                          : (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
