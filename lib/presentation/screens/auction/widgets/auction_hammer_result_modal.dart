import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/auction_model.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class AuctionWonDialog extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onOpenTrunk;
  final VoidCallback onGoToShowroom;

  const AuctionWonDialog({
    super.key,
    required this.auction,
    required this.onOpenTrunk,
    required this.onGoToShowroom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: AppColors.brutalGreen,
        borderWidth: 2.5,
        borderRadius: 12,
        shadowOffset: const Offset(4, 4),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.brutalGreen,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.black,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('auction_won_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('auction_win_success_desc', {
                  'year': auction.car.modelYear,
                  'brand': auction.car.brand,
                  'model': auction.car.modelName,
                  'bid': CurrencyFormatter.formatShort(auction.currentBid),
                }),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              NeoBrutalBadge(
                text: context.tr('auction_market_value_label', {
                  'val': CurrencyFormatter.formatShort(
                    auction.estimatedMarketValue,
                  ),
                }),
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
              ),
              const SizedBox(height: 18),
              NeoBrutalButton(
                label: context.tr('auction_trunk_btn'),
                icon: Icons.card_giftcard_rounded,
                backgroundColor: AppColors.brutalOrange,
                textColor: Colors.black,
                fullWidth: true,
                onPressed: onOpenTrunk,
              ),
              const SizedBox(height: 8),
              NeoBrutalButton(
                label: context.tr('auction_to_showroom_btn'),
                backgroundColor: isDark
                    ? const Color(0xFF1E2330)
                    : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fullWidth: true,
                onPressed: onGoToShowroom,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuctionLostDialog extends StatelessWidget {
  final AuctionModel auction;
  final bool hasExtendedAuction;
  final bool hasPlayerEnteredBid;
  final VoidCallback onExtendAuction;
  final VoidCallback onNextAuction;

  const AuctionLostDialog({
    super.key,
    required this.auction,
    required this.hasExtendedAuction,
    this.hasPlayerEnteredBid = false,
    required this.onExtendAuction,
    required this.onNextAuction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: AppColors.errorRed,
        borderWidth: 2.5,
        borderRadius: 16,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFF0F172A),
                    width: 2.0,
                  ),
                ),
                child: const Icon(
                  Icons.gavel_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.tr('auction_lost_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('auction_lost_desc', {
                  'winner': auction.highestBidderName,
                  'bid': CurrencyFormatter.formatShort(auction.currentBid),
                }),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasPlayerEnteredBid) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.errorRed,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.sentiment_dissatisfied_rounded,
                            color: AppColors.errorRed,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              context.tr('auction_lost_near_miss', {
                                'winner': auction.highestBidderName,
                              }),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                                color: AppColors.errorRed,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr('auction_lost_sunk_cost_desc'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              if (!hasExtendedAuction) ...[
                NeoBrutalButton(
                  label: context.tr('auction_extend_btn'),
                  icon: Icons.access_time_filled_rounded,
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 11,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    AdService.instance.showRewardedAdWithFallback(
                      context: context,
                      customRewardTitle:
                          context.tr('auction_custom_reward_title'),
                      onRewardEarned: () {
                        onExtendAuction();
                        NotificationService.showSuccess(
                          context,
                          context.tr('auction_time_extended_toast'),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
              NeoBrutalButton(
                label: context.tr('auction_next_btn'),
                backgroundColor: isDark
                    ? const Color(0xFF1E2330)
                    : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fullWidth: true,
                onPressed: onNextAuction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
