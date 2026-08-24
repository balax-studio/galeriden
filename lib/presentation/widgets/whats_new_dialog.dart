import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/game_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_extension.dart';
import '../providers/game_provider.dart';
import 'feedback_dialog.dart';
import 'neo_brutal_badge.dart';
import 'neo_brutal_button.dart';
import 'neo_brutal_card.dart';

class WhatsNewDialog extends ConsumerWidget {
  const WhatsNewDialog({super.key});

  static Future<void> checkAndShow(BuildContext context, WidgetRef ref) async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final game = ref.read(gameProvider);
    if (!hasSeenOnboarding || !game.tutorialCompleted) return;

    final lastSeenVersion = prefs.getString('last_seen_app_version');
    if (lastSeenVersion == GameConstants.appVersion) return;

    if (context.mounted) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const WhatsNewDialog(),
      );
      await prefs.setString('last_seen_app_version', GameConstants.appVersion);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(18),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
        borderRadius: 16,
        borderWidth: 2.5,
        shadowOffset: const Offset(4, 4),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brutalYellow,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.new_releases_rounded,
                            color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('whats_new_title'),
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            context.tr('whats_new_version_subtitle',
                                {'version': GameConstants.appVersion}),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.brutalYellow
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: context.tr('whats_new_badge_current'),
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                  ),
                ],
              ),
              const Divider(height: 20),

              // Changelog Items
              _buildChangelogItem(
                icon: Icons.sports_score_rounded,
                iconColor: const Color(0xFF00E575),
                title: context.tr('changelog_drag_race_title'),
                description: context.tr('changelog_drag_race_desc'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildChangelogItem(
                icon: Icons.speed_rounded,
                iconColor: const Color(0xFFFFDE59),
                title: context.tr('changelog_perf_title'),
                description: context.tr('changelog_perf_desc'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildChangelogItem(
                icon: Icons.car_repair_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: context.tr('changelog_mini_games_title'),
                description: context.tr('changelog_mini_games_desc'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildChangelogItem(
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFFFB923C),
                title: context.tr('changelog_calendar_title'),
                description: context.tr('changelog_calendar_desc'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildChangelogItem(
                icon: Icons.apartment_rounded,
                iconColor: const Color(0xFFA855F7),
                title: context.tr('changelog_ipo_title'),
                description: context.tr('changelog_ipo_desc'),
                isDark: isDark,
              ),
              const SizedBox(height: 10),

              _buildChangelogItem(
                icon: Icons.support_agent_rounded,
                iconColor: const Color(0xFFEC4899),
                title: context.tr('changelog_crm_title'),
                description: context.tr('changelog_crm_desc'),
                isDark: isDark,
              ),
              const SizedBox(height: 14),

              // Anonymous In-App Feedback Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2433)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF333B4F)
                        : const Color(0xFFCBD5E1),
                    width: 1.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded,
                            size: 16, color: AppColors.brutalYellow),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('whats_new_feedback_title'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('whats_new_feedback_desc'),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    NeoBrutalButton(
                      label: context.tr('whats_new_feedback_btn'),
                      icon: Icons.rate_review_rounded,
                      backgroundColor:
                          isDark ? const Color(0xFF2A3142) : Colors.white,
                      textColor:
                          isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 10.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        FeedbackDialog.show(context);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Main Confirm Button
              NeoBrutalButton(
                label: context.tr('whats_new_start_game_btn'),
                icon: Icons.check_circle_rounded,
                backgroundColor: AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 12.5,
                fullWidth: true,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChangelogItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: isDark ? 0.25 : 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? const Color(0xFF2E384D) : const Color(0xFFCBD5E1),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
