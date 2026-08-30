import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/dialogs/language_selector_dialog.dart';
import '../../widgets/feedback_dialog.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/whats_new_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('settings_title'),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.none,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              14, 14, 14, 24 + MediaQuery.paddingOf(context).bottom),
          physics: const BouncingScrollPhysics(),
          children: [
          // 1. Dealership Identity
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: InkWell(
              onTap: () => context.push('/dealership-identity'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
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
                    child: const Icon(Icons.badge_rounded,
                        color: Colors.black, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('dealership_identity'),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${game.dealershipName} • ${game.playerName}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2. Theme Store
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: InkWell(
              onTap: () => context.push('/theme-store'),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA855F7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.palette_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('theme_store'),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.tr(
                              'settings_active_theme_label', {'name': p.name}),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Audio & Language Settings
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('audio_effects'),
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w900),
                        ),
                        Text(
                          context.tr('audio_desc'),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.isAudioEnabled,
                      activeTrackColor: AppColors.brutalYellow,
                      onChanged: (_) =>
                          ref.read(settingsProvider.notifier).toggleAudio(),
                    ),
                  ],
                ),
                const Divider(height: 20),
                InkWell(
                  onTap: () => LanguageSelectorDialog.show(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('language_select'),
                              style: const TextStyle(
                                  fontSize: 13.5, fontWeight: FontWeight.w900),
                            ),
                            Text(
                              context.tr('language_desc'),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NeoBrutalBadge(
                              text:
                                  '${settings.currentLanguage.countryBadge} • ${settings.currentLanguage.nativeName}',
                              backgroundColor: isDark
                                  ? const Color(0xFF1E2330)
                                  : const Color(0xFFE2E8F0),
                              textColor: isDark ? Colors.white : Colors.black,
                              fontSize: 11,
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 12, color: Color(0xFF64748B)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. Rewarded Support Banner
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
                  context.tr('sponsor_fund_title'),
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('sponsor_fund_desc'),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                NeoBrutalButton(
                  label: context.tr('watch_video_earn_btn'),
                  icon: Icons.play_circle_fill_rounded,
                  backgroundColor: AppColors.brutalGreen,
                  textColor: Colors.black,
                  fontSize: 12,
                  fullWidth: true,
                  onPressed: () {
                    AdService.instance.showRewardedAdWithFallback(
                      context: context,
                      customRewardTitle: context.tr('sponsor_reward_title'),
                      onRewardEarned: () {
                        ref.read(gameProvider.notifier).claimAdReward(25000.0);
                        NotificationService.showSuccess(
                            context, context.tr('sponsor_reward_success'));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Review & Store Rating Reward Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: game.hasReceivedReviewReward
                ? (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1))
                : const Color(0xFFEAB308),
            borderWidth: 2.2,
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      context.tr('support_rating_title'),
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w900),
                    )),
                    NeoBrutalBadge(
                      text: game.hasReceivedReviewReward
                          ? context.tr('support_reward_claimed')
                          : context.tr('support_one_time_badge'),
                      backgroundColor: game.hasReceivedReviewReward
                          ? (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFE2E8F0))
                          : AppColors.brutalYellow,
                      textColor: game.hasReceivedReviewReward
                          ? (isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B))
                          : Colors.black,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  (defaultTargetPlatform == TargetPlatform.iOS ||
                          defaultTargetPlatform == TargetPlatform.macOS)
                      ? context.tr('support_rating_desc_ios')
                      : context.tr('support_rating_desc_android'),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                if (!game.hasReceivedReviewReward)
                  NeoBrutalButton(
                    label: context.tr('support_rate_5_stars_btn'),
                    icon: Icons.star_rounded,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 11.5,
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
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      } catch (_) {}
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2433)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2E384D)
                            : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 16, color: AppColors.brutalGreen),
                        const SizedBox(width: 6),
                        Text(
                          context.tr('support_claimed_text'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 6. Community & Feedback Desk
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
                  context.tr('community_feedback_title'),
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('community_feedback_desc'),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: NeoBrutalButton(
                        label: context.tr('feedback_report_btn'),
                        icon: Icons.rate_review_rounded,
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        onPressed: () => FeedbackDialog.show(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: NeoBrutalButton(
                        label: context.tr('whats_new_btn'),
                        icon: Icons.new_releases_rounded,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : Colors.black,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => const WhatsNewDialog(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 5. Developer / Cheats Card (Only in debug mode)
          if (kDebugMode) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor:
                  isDark ? const Color(0xFF1B182B) : const Color(0xFFF5F3FF),
              borderColor: const Color(0xFF8B5CF6),
              borderWidth: 2.2,
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: Color(0xFF8B5CF6), size: 20),
                          const SizedBox(width: 6),
                          Text(
                            context.tr('settings_dev_panel_title'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                      NeoBrutalBadge(
                        text: context.tr('settings_dev_test_badge'),
                        backgroundColor: const Color(0xFF8B5CF6),
                        textColor: Colors.white,
                        fontSize: 9.5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('settings_dev_panel_desc'),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('settings_dev_add_funds'),
                          icon: Icons.attach_money_rounded,
                          backgroundColor: const Color(0xFF10B981),
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .addCheatFunds(100000000.0);
                            NotificationService.showSuccess(context,
                                context.tr('settings_dev_funds_added'));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('settings_dev_max_level'),
                          icon: Icons.workspace_premium_rounded,
                          backgroundColor: const Color(0xFF8B5CF6),
                          textColor: Colors.white,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            ref
                                .read(gameProvider.notifier)
                                .unlockAllPropertiesAndMaxLevel();
                            NotificationService.showSuccess(context,
                                context.tr('settings_dev_unlocked_all'));
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('settings_dev_level_4'),
                          icon: Icons.storefront_rounded,
                          backgroundColor: const Color(0xFF38BDF8),
                          textColor: Colors.black,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            ref.read(gameProvider.notifier).setLevel(4);
                            NotificationService.showSuccess(context,
                                context.tr('settings_dev_level_4_unlocked'));
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalButton(
                          label: context.tr('settings_dev_clear_garage'),
                          icon: Icons.cleaning_services_rounded,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor:
                              isDark ? Colors.white70 : const Color(0xFF334155),
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          onPressed: () {
                            ref.read(gameProvider.notifier).clearGarage();
                            NotificationService.showInfo(context,
                                context.tr('settings_dev_garage_cleared'));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 6. Dynasty & Season Reset
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor:
                isDark ? const Color(0xFF161F30) : const Color(0xFFFAF5FF),
            borderColor: const Color(0xFFA855F7),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      context.tr('dynasty_season_title'),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFA855F7)),
                    )),
                    NeoBrutalBadge(
                      text: context.tr('dynasty_generation_badge',
                          {'gen': game.dynastyGeneration}),
                      backgroundColor: const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('dynasty_desc'),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                if (game.dynastyHistoryLog.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F1118) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFFCBD5E1),
                        width: 2.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('dynasty_history_title'),
                            style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF64748B))),
                        const SizedBox(height: 4),
                        ...game.dynastyHistoryLog.reversed.take(3).map((log) =>
                            Text('• $log',
                                style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                NeoBrutalButton(
                  label: context.tr('dynasty_transfer_btn'),
                  icon: Icons.auto_awesome_rounded,
                  backgroundColor: (game.level >= 5 || game.balance >= 1000000)
                      ? const Color(0xFFA855F7)
                      : const Color(0xFF64748B),
                  textColor: Colors.white,
                  fontSize: 11.5,
                  fullWidth: true,
                  onPressed: (game.level >= 5 || game.balance >= 1000000)
                      ? () {
                          showDialog(
                            context: context,
                            builder: (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: NeoBrutalCard(
                                padding: const EdgeInsets.all(20),
                                backgroundColor: isDark
                                    ? const Color(0xFF141721)
                                    : Colors.white,
                                borderColor: const Color(0xFFA855F7),
                                borderRadius: 12,
                                borderWidth: 2.5,
                                shadowOffset: const Offset(4, 4),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.workspace_premium_rounded,
                                        color: Color(0xFFA855F7), size: 44),
                                    const SizedBox(height: 12),
                                    Text(
                                      context.tr('dynasty_confirm_title'),
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      context.tr('dynasty_confirm_desc', {
                                        'gen': game.dynastyGeneration,
                                        'nextGen': game.dynastyGeneration + 1,
                                      }),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: NeoBrutalButton(
                                            label: context.tr('dialog_cancel'),
                                            backgroundColor: isDark
                                                ? const Color(0xFF1E2330)
                                                : const Color(0xFFE2E8F0),
                                            textColor: isDark
                                                ? Colors.white
                                                : Colors.black,
                                            onPressed: () => Navigator.pop(ctx),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: NeoBrutalButton(
                                            label:
                                                context.tr('dialog_transfer'),
                                            backgroundColor:
                                                const Color(0xFFA855F7),
                                            textColor: Colors.white,
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              ref
                                                  .read(gameProvider.notifier)
                                                  .performDynastySeasonReset();
                                              NotificationService.showSuccess(
                                                context,
                                                context.tr(
                                                    'dynasty_started_toast', {
                                                  'gen':
                                                      game.dynastyGeneration + 1
                                                }),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                      : () {
                          NotificationService.showWarning(
                              context, context.tr('dynasty_warning_level'));
                        },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 7. Reset Game
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
                  context.tr('reset_game_title'),
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.errorRed),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('reset_game_desc'),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                NeoBrutalButton(
                  label: context.tr('reset_game_btn'),
                  icon: Icons.delete_forever_rounded,
                  backgroundColor: AppColors.errorRed,
                  textColor: Colors.white,
                  fontSize: 11.5,
                  fullWidth: true,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(20),
                          backgroundColor:
                              isDark ? const Color(0xFF141721) : Colors.white,
                          borderColor: AppColors.errorRed,
                          borderRadius: 12,
                          borderWidth: 2.5,
                          shadowOffset: const Offset(4, 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.errorRed, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                context.tr('reset_confirm_title'),
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                context.tr('reset_confirm_desc'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: context.tr('dialog_cancel'),
                                      backgroundColor: isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0),
                                      textColor:
                                          isDark ? Colors.white : Colors.black,
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: context.tr('dialog_reset'),
                                      backgroundColor: AppColors.errorRed,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        ref
                                            .read(gameProvider.notifier)
                                            .resetGame();
                                        Navigator.pop(ctx);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 8. Legal & Privacy Policy Card
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
                      context.tr('legal_privacy_title'),
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w900),
                    )),
                    NeoBrutalBadge(
                      text: context.tr('legal_gdpr_badge'),
                      backgroundColor: const Color(0xFF00E575),
                      textColor: Colors.black,
                      fontSize: 9,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('legal_privacy_desc'),
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('privacy_policy_btn'),
                        icon: Icons.shield_outlined,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0),
                        textColor:
                            isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: () =>
                            _showPrivacyPolicyDialog(context, isDark),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: NeoBrutalButton(
                        label: context.tr('terms_of_service_btn'),
                        icon: Icons.description_outlined,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0),
                        textColor:
                            isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        onPressed: () => _showTermsDialog(context, isDark),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              '${GameConstants.appName} v${GameConstants.appVersion} • Balax Studio',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    ),
  );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    context.tr('privacy_policy_btn'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900),
                  )),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    context.tr('privacy_policy_content'),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('open_in_web_btn'),
                      icon: Icons.open_in_browser_rounded,
                      backgroundColor: const Color(0xFF00E575),
                      textColor: Colors.black,
                      fontSize: 11,
                      onPressed: () async {
                        final uri = Uri.parse(GameConstants.privacyPolicyUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri,
                              mode: LaunchMode.externalApplication);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('dialog_close'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white : Colors.black,
                      fontSize: 11,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    context.tr('terms_of_service_btn'),
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w900),
                  )),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    'KULLANIM ŞARTLARI VE LİSANS SÖZLEŞMESİ\n\n'
                    '1. GENEL KULLANIM\n'
                    'Galeriden oyunu bir sanal ticaret ve galericilik simülasyonudur. Oyundaki para birimleri, araçlar, hisseler ve kazançlar tamamen kurgusaldır ve gerçek dünyada hiçbir maddi/nakdi karşılığı bulunmamaktadır.\n\n'
                    '2. FİKRİ MÜLKİYET\n'
                    'Oyundaki tüm görsel tasarımlar, logolar, Neo-Brutalist bileşenler ve kod tabanı Balax Studio mülkiyetindedir.\n\n'
                    '3. SORUMLULUK SINIRLAMASI\n'
                    'Oyun eğlence amaçlı sunulmaktadır. Cihaz sıfırlama veya uygulamanın silinmesi durumunda yerel verilerin kaybından kullanıcı sorumludur.',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                      color: isDark
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: context.tr('dialog_close'),
                backgroundColor:
                    isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                textColor: isDark ? Colors.white : Colors.black,
                fontSize: 11.5,
                fullWidth: true,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
