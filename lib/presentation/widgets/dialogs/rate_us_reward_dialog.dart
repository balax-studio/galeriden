import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

/// Rare 'Rate Us & Win Reward' popup dialog for app store ratings.
/// Triggered with ~5% probability, maximum once per calendar day,
/// only if the player has not yet claimed their store review reward.
class RateUsRewardDialog extends ConsumerWidget {
  const RateUsRewardDialog({super.key});

  /// Evaluates trigger conditions:
  /// 1. Player has not yet received review reward (`hasReceivedReviewReward == false`).
  /// 2. Has not been prompted today (checked via SharedPreferences).
  /// 3. Random 5% chance roll passes (`math.Random().nextDouble() < 0.05`).
  static Future<bool> checkAndShow(BuildContext context, WidgetRef ref) async {
    final game = ref.read(gameProvider);
    if (game.hasReceivedReviewReward) return false;

    // Roll 5% chance
    final randomRoll = math.Random().nextDouble();
    if (randomRoll >= 0.05) return false;

    // Check 1 per day limit via SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final lastPromptDate = prefs.getString('last_rate_us_prompt_date');
    if (lastPromptDate == todayKey) return false;

    // Save prompt date to enforce daily quota
    await prefs.setString('last_rate_us_prompt_date', todayKey);

    if (!context.mounted) return false;
    final result = await show(context);
    return result ?? false;
  }

  /// Explicitly displays the dialog.
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const RateUsRewardDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: AppColors.brutalYellow,
          borderWidth: 3.0,
          borderRadius: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Top Badges Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeoBrutalBadge(
                    text: context.tr('rate_us_dialog_badge'),
                    icon: Icons.favorite_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 10.5,
                  ),
                  NeoBrutalBadge(
                    text: '+₺100.000 • +100 XP',
                    icon: Icons.monetization_on_rounded,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 10.5,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 2. 5 Gold Stars Showcase Container
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2433)
                      : const Color(0xFFFEFCE8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.brutalYellow,
                    width: 2.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                        Icons.star_rounded,
                        color: AppColors.brutalYellow,
                        size: 34,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Title & Lore Description
              Text(
                context.tr('rate_us_dialog_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('rate_us_dialog_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 20),

              // 4. Primary Action Button: 5 Yıldız Ver & Ödülü Al
              NeoBrutalButton(
                label: context.tr('rate_us_dialog_action_btn'),
                icon: Icons.star_rounded,
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 12.5,
                padding: const EdgeInsets.symmetric(vertical: 12),
                fullWidth: true,
                onPressed: () async {
                  final success =
                      ref.read(gameProvider.notifier).claimReviewReward();
                  if (success) {
                    NotificationService.showSuccess(
                      context,
                      context.tr('support_reward_success_toast'),
                    );
                  }
                  try {
                    final uri = Uri.parse(GameConstants.storeReviewUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } catch (_) {}
                  if (context.mounted) {
                    Navigator.of(context).pop(true);
                  }
                },
              ),
              const SizedBox(height: 8),

              // 5. Dismiss Button: Daha Sonra
              NeoBrutalButton(
                label: context.tr('rate_us_dialog_later_btn'),
                icon: Icons.close_rounded,
                backgroundColor: isDark
                    ? const Color(0xFF1E2330)
                    : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white70 : const Color(0xFF475569),
                borderColor: isDark
                    ? const Color(0xFF333B4F)
                    : const Color(0xFFCBD5E1),
                fontSize: 11.5,
                padding: const EdgeInsets.symmetric(vertical: 8),
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
