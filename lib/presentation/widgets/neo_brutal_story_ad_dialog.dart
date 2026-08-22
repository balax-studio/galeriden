import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/ad_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/story_card_model.dart';
import '../providers/game_provider.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';
import 'app_vector_icons.dart';

class NeoBrutalStoryAdDialog extends ConsumerWidget {
  final StoryCardModel card;

  const NeoBrutalStoryAdDialog({
    super.key,
    required this.card,
  });

  static Future<void> show(BuildContext context, StoryCardModel card) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => NeoBrutalStoryAdDialog(card: card),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: NeoBrutalCard(
        backgroundColor: isDark ? const Color(0xFF131620) : Colors.white,
        borderColor: isDark ? const Color(0xFF2E3748) : const Color(0xFF0F172A),
        borderWidth: 2.8,
        borderRadius: 18,
        shadowOffset: const Offset(5, 5),
        shadowColor: isDark ? Colors.black87 : const Color(0xFF0F172A),
        padding: const EdgeInsets.all(18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Bar with Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: context.tr('badge_special_encounter'),
                    backgroundColor: const Color(0xFFF59E0B),
                    textColor: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  ),
                  NeoBrutalBadge(
                    text: context.tr('badge_optional_opportunity'),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                    fontSize: 9.5,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Character Profile & Title
              Row(
                children: [
                  // Avatar Box
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2433) : const Color(0xFFEEF2F6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0xFF384252) : const Color(0xFF0F172A),
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : const Color(0xFF0F172A),
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AvatarIconWidget(
                      avatar: card.characterAvatar,
                      size: 26,
                      color: isDark ? const Color(0xFFF59E0B) : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name & Role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          card.characterName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          card.characterRole,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 3. Narrative Dialogue Speech Bubble
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF191E2C) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3444) : const Color(0xFFCBD5E1),
                    width: 2.0,
                  ),
                ),
                child: Text(
                  card.dialogue,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Reward Guarantee Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F261C) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.brutalGreen,
                    width: 2.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars_rounded, color: AppColors.brutalGreen, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('label_reward_advantage'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            card.rewardDescription,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF065F46),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 5. Accept (Watch Ad) Button
              NeoBrutalButton(
                label: card.acceptLabel,
                icon: Icons.play_circle_fill_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                fullWidth: true,
                onPressed: () {
                  AdService.instance.showRewardedAd(
                    onRewardEarned: () {
                      ref.read(gameProvider.notifier).resolveStoryCard(
                            card: card,
                            accepted: true,
                          );
                      Navigator.of(context, rootNavigator: true).pop();
                      NotificationService.showSuccess(
                        context,
                        context.tr('toast_opportunity_accepted'),
                      );
                    },
                    onAdUnavailable: () {
                      // Graceful fallback for test or unavailable ad network
                      ref.read(gameProvider.notifier).resolveStoryCard(
                            card: card,
                            accepted: true,
                          );
                      Navigator.of(context, rootNavigator: true).pop();
                      NotificationService.showSuccess(
                        context,
                        context.tr('toast_reward_claimed'),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 8),

              // 6. Role-Play Decline Button
              NeoBrutalButton(
                label: card.declineLabel,
                icon: Icons.close_rounded,
                backgroundColor: isDark ? const Color(0xFF222838) : const Color(0xFFF1F5F9),
                textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                borderColor: isDark ? const Color(0xFF3B465C) : const Color(0xFF94A3B8),
                borderWidth: 2.0,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                fullWidth: true,
                onPressed: () {
                  ref.read(gameProvider.notifier).resolveStoryCard(
                        card: card,
                        accepted: false,
                      );
                  Navigator.of(context, rootNavigator: true).pop();
                  NotificationService.showInfo(
                    context,
                    context.tr('toast_opportunity_declined'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
