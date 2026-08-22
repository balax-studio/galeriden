import '../../../core/localization/app_localizations.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/services/ad_reward_calculator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

class FallbackSponsorStory {
  final String titleKey;
  final String descKey;
  final String badgeKey;
  final IconData icon;
  final Color accentColor;
  final String buttonKey;

  const FallbackSponsorStory({
    required this.titleKey,
    required this.descKey,
    required this.badgeKey,
    required this.icon,
    required this.accentColor,
    required this.buttonKey,
  });
}

/// Neo-Brutalist in-universe fallback dialog displayed when AdMob has no fill or network is offline.
/// Guarantees 100% uninterrupted reward delivery while preserving game immersion.
class NeoBrutalFallbackAdDialog extends StatelessWidget {
  final VoidCallback onRewardClaimed;
  final String? rewardTitle;
  final AdRewardOutcome? outcome;

  const NeoBrutalFallbackAdDialog({
    super.key,
    required this.onRewardClaimed,
    this.rewardTitle,
    this.outcome,
  });

  static final List<FallbackSponsorStory> _stories = [
    const FallbackSponsorStory(
      titleKey: 'fallback_ad_story1_title',
      descKey: 'fallback_ad_story1_desc',
      badgeKey: 'fallback_ad_story1_badge',
      icon: Icons.lock_open_rounded,
      accentColor: AppColors.brutalYellow,
      buttonKey: 'fallback_ad_story1_btn',
    ),
    const FallbackSponsorStory(
      titleKey: 'fallback_ad_story2_title',
      descKey: 'fallback_ad_story2_desc',
      badgeKey: 'fallback_ad_story2_badge',
      icon: Icons.verified_rounded,
      accentColor: AppColors.brutalBlue,
      buttonKey: 'fallback_ad_story2_btn',
    ),
    const FallbackSponsorStory(
      titleKey: 'fallback_ad_story3_title',
      descKey: 'fallback_ad_story3_desc',
      badgeKey: 'fallback_ad_story3_badge',
      icon: Icons.local_fire_department_rounded,
      accentColor: AppColors.errorRed,
      buttonKey: 'fallback_ad_story3_btn',
    ),
    const FallbackSponsorStory(
      titleKey: 'fallback_ad_story4_title',
      descKey: 'fallback_ad_story4_desc',
      badgeKey: 'fallback_ad_story4_badge',
      icon: Icons.restaurant_rounded,
      accentColor: AppColors.successGreen,
      buttonKey: 'fallback_ad_story4_btn',
    ),
    const FallbackSponsorStory(
      titleKey: 'fallback_ad_story5_title',
      descKey: 'fallback_ad_story5_desc',
      badgeKey: 'fallback_ad_story5_badge',
      icon: Icons.speed_rounded,
      accentColor: Color(0xFFA855F7),
      buttonKey: 'fallback_ad_story5_btn',
    ),
  ];

  static void show({
    required BuildContext context,
    required VoidCallback onRewardClaimed,
    String? rewardTitle,
    AdRewardOutcome? outcome,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => NeoBrutalFallbackAdDialog(
        onRewardClaimed: onRewardClaimed,
        rewardTitle: rewardTitle,
        outcome: outcome,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final random = Random();
    final story = _stories[random.nextInt(_stories.length)];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(20),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: story.accentColor,
        borderWidth: 2.5,
        borderRadius: 16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeoBrutalBadge(
                  text: outcome != null ? outcome!.badgeText : context.tr(story.badgeKey),
                  icon: outcome != null ? Icons.stars_rounded : story.icon,
                  backgroundColor: outcome != null && outcome!.tier == AdRewardTier.legendaryJackpot
                      ? AppColors.brutalYellow
                      : story.accentColor,
                  textColor: Colors.black,
                  fontSize: 11,
                ),
                NeoBrutalBadge(
                  text: 'SPONSOR JESTİ',
                  backgroundColor: isDark ? const Color(0xFF232A3B) : const Color(0xFFE2E8F0),
                  textColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: story.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: story.accentColor.withValues(alpha: 0.4),
                  width: 2.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: story.accentColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Icon(
                      story.icon,
                      color: Colors.black,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outcome != null ? outcome!.title : context.tr(story.titleKey),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (outcome != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '+${CurrencyFormatter.format(outcome!.moneyAmount)}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen,
                            ),
                          ),
                        ] else if (rewardTitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            rewardTitle!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: story.accentColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              outcome != null ? outcome!.message : context.tr(story.descKey),
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
              ),
            ),
            if (outcome?.bonusItemDescription != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.brutalYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.brutalYellow, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.military_tech_rounded, color: AppColors.brutalYellow, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        outcome!.bonusItemDescription!,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brutalYellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF262E3E) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.successGreen, size: 15),
                  const SizedBox(width: 6),
                  Text(
                    'Reklam ağı meşgul - Ödülün %100 eksiksiz sağlandı',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            NeoBrutalButton(
              label: context.tr(story.buttonKey),
              icon: Icons.card_giftcard_rounded,
              backgroundColor: story.accentColor,
              textColor: Colors.black,
              fullWidth: true,
              fontSize: 13,
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                onRewardClaimed();
              },
            ),
          ],
        ),
      ),
    );
  }
}
