import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/lucky_opportunity_model.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

class LuckyOpportunityDialog extends ConsumerWidget {
  final LuckyOpportunityModel opportunity;

  const LuckyOpportunityDialog({
    super.key,
    required this.opportunity,
  });

  static Future<void> show(
      BuildContext context, LuckyOpportunityModel opportunity) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => LuckyOpportunityDialog(opportunity: opportunity),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final hasNoAds = game.hasNoAdsLicense;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: opportunity.accentColor,
        borderWidth: 3.0,
        borderRadius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Badge Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeoBrutalBadge(
                  text: context.tr('lucky_banner_badge'),
                  icon: Icons.stars_rounded,
                  backgroundColor: opportunity.accentColor,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                NeoBrutalBadge(
                  text: context.tr('lucky_limited_time'),
                  icon: Icons.timer_rounded,
                  backgroundColor: isDark
                      ? const Color(0xFF222938)
                      : const Color(0xFFE2E8F0),
                  textColor: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: opportunity.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: opportunity.accentColor, width: 2.0),
                  ),
                  child: Icon(opportunity.icon,
                      color: opportunity.accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(opportunity.titleKey),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.tr('lucky_surprise_subtitle'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: opportunity.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Description Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF0B0D13) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF222938)
                      : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(opportunity.descriptionKey),
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: opportunity.accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: opportunity.accentColor.withValues(alpha: 0.4),
                          width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: opportunity.accentColor, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            context.tr(opportunity.perkSummaryKey),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Reward Values Chips
            Row(
              children: [
                if (opportunity.cashReward > 0)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.brutalGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.brutalGreen, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.tr('lucky_reward_cash_label'),
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF10B981)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+${CurrencyFormatter.formatShort(opportunity.cashReward)}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (opportunity.cashReward > 0 &&
                    opportunity.reputationBonus > 0)
                  const SizedBox(width: 8),
                if (opportunity.reputationBonus > 0)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.brutalPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.brutalPurple, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Text(
                            context.tr('lucky_reward_rep_label'),
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFA855F7)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+${opportunity.reputationBonus} ${context.tr('lucky_rep_points')}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF581C87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),

            // Action Buttons
            NeoBrutalButton(
              label: hasNoAds
                  ? context.tr('lucky_btn_claim_instant')
                  : context.tr('lucky_btn_claim_ad'),
              icon: hasNoAds
                  ? Icons.flash_on_rounded
                  : Icons.play_circle_fill_rounded,
              backgroundColor: opportunity.accentColor,
              textColor: Colors.black,
              fontSize: 13.5,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () {
                if (hasNoAds) {
                  // Direct instant claim for Pro users
                  ref
                      .read(gameProvider.notifier)
                      .claimLuckyOpportunity(opportunity);
                  Navigator.pop(context);
                  NotificationService.showSuccess(
                    context,
                    context.tr('lucky_toast_claimed_success'),
                  );
                } else {
                  // Rewarded ad trigger
                  AdService.instance.showRewardedAd(
                    onRewardEarned: () {
                      ref
                          .read(gameProvider.notifier)
                          .claimLuckyOpportunity(opportunity);
                      if (context.mounted) {
                        Navigator.pop(context);
                        NotificationService.showSuccess(
                          context,
                          context.tr('lucky_toast_claimed_success'),
                        );
                      }
                    },
                    onAdUnavailable: () {
                      // Graceful reward if ad not available
                      ref
                          .read(gameProvider.notifier)
                          .claimLuckyOpportunity(opportunity);
                      if (context.mounted) {
                        Navigator.pop(context);
                        NotificationService.showSuccess(
                          context,
                          context.tr('lucky_toast_claimed_success'),
                        );
                      }
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.tr('lucky_btn_dismiss'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
