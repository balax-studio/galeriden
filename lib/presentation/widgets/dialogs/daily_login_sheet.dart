import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/daily_login_reward_model.dart';
import '../../providers/game_provider.dart';
import '../neo_brutal_badge.dart';
import '../neo_brutal_button.dart';
import '../neo_brutal_card.dart';

class DailyLoginSheet extends ConsumerStatefulWidget {
  const DailyLoginSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const DailyLoginSheet(),
    );
  }

  @override
  ConsumerState<DailyLoginSheet> createState() => _DailyLoginSheetState();
}

class _DailyLoginSheetState extends ConsumerState<DailyLoginSheet> {
  int _selectedWeek = 1;

  @override
  void initState() {
    super.initState();
    final game = ref.read(gameProvider);
    _selectedWeek = ((game.currentStreakDay - 1) ~/ 7) + 1;
    if (_selectedWeek < 1 || _selectedWeek > 4) _selectedWeek = 1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final game = ref.watch(gameProvider);
    final langCode = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final canClaim = game.canClaimTodayStreak(todayStr);

    final allRewards = DailyLoginRewardModel.getSeasonalCycle(
        cycleCount: game.streakCycleCount);
    final currentStreakDay = game.currentStreakDay.clamp(1, 28);
    final weekRewards =
        allRewards.where((r) => r.weekNumber == _selectedWeek).toList();
    final todayReward =
        allRewards.firstWhere((r) => r.dayNumber == currentStreakDay);
    final seasonTitle = DailyLoginRewardModel.getSeasonTitle(
        game.streakCycleCount,
        langCode: langCode);
    final seasonDesc = DailyLoginRewardModel.getSeasonDescription(
        game.streakCycleCount,
        langCode: langCode);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF10131B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.black, width: 3.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seasonTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.brutalYellow,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.tr('streak_cycle_day', {
                        'cycle': game.streakCycleCount + 1,
                        'day': currentStreakDay,
                      }),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              NeoBrutalBadge(
                text: canClaim
                    ? context.tr('streak_ready_badge')
                    : context.tr('streak_come_back'),
                icon: canClaim
                    ? Icons.check_circle_rounded
                    : Icons.lock_clock_rounded,
                backgroundColor: canClaim
                    ? AppColors.brutalGreen
                    : (isDark
                        ? const Color(0xFF242C3D)
                        : const Color(0xFFE2E8F0)),
                textColor: canClaim
                    ? Colors.black
                    : (isDark ? Colors.white70 : Colors.black87),
                fontSize: 10.5,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Season description card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny_rounded,
                    size: 16, color: AppColors.brutalYellow),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    seasonDesc,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4-Week Selector Tabs
          Row(
            children: List.generate(4, (index) {
              final weekNum = index + 1;
              final isSelected = _selectedWeek == weekNum;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedWeek = weekNum),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark
                                ? const Color(0xFF1E2433)
                                : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : (isDark ? Colors.white12 : Colors.black12),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          context.tr('week_tab_label', {'week': weekNum}),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Colors.black
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // 7 Cards of the Selected Week
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weekRewards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final reward = weekRewards[idx];
                final isCurrentDay = reward.dayNumber == currentStreakDay;
                final isClaimed =
                    game.claimedStreakDays.contains(reward.dayNumber);

                return SizedBox(
                  width: 95,
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: isClaimed
                        ? (isDark
                            ? const Color(0xFF141923)
                            : const Color(0xFFE2E8F0))
                        : (isCurrentDay
                            ? reward.accentColor
                                .withValues(alpha: isDark ? 0.25 : 0.15)
                            : (isDark
                                ? const Color(0xFF1E2433)
                                : Colors.white)),
                    borderColor: isCurrentDay
                        ? reward.accentColor
                        : (isClaimed ? AppColors.successGreen : Colors.black),
                    borderWidth: isCurrentDay ? 2.5 : 1.5,
                    borderRadius: 12,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'D.${reward.dayNumber}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: isCurrentDay
                                    ? reward.accentColor
                                    : (isDark
                                        ? Colors.white70
                                        : Colors.black87),
                              ),
                            ),
                            if (isClaimed)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.successGreen, size: 14)
                            else if (reward.isMilestone)
                              Icon(Icons.stars_rounded,
                                  color: reward.accentColor, size: 14),
                          ],
                        ),
                        Icon(
                          reward.icon,
                          size: 24,
                          color: isClaimed ? Colors.grey : reward.accentColor,
                        ),
                        Text(
                          reward.moneyAmount > 0
                              ? '+${CurrencyFormatter.formatShort(reward.moneyAmount)}'
                              : '+${reward.reputationAmount}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isClaimed
                                ? Colors.grey
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Today's Detailed Reward Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: todayReward.accentColor
                  .withValues(alpha: isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: todayReward.accentColor, width: 2.0),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: todayReward.accentColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Icon(todayReward.icon, color: Colors.black, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              todayReward.title,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (!canClaim) ...[
                            const SizedBox(width: 6),
                            NeoBrutalBadge(
                              text: context.tr('streak_unlocks_tomorrow'),
                              icon: Icons.lock_clock_rounded,
                              backgroundColor: isDark
                                  ? const Color(0xFF242C3D)
                                  : const Color(0xFFE2E8F0),
                              textColor:
                                  isDark ? Colors.white70 : Colors.black87,
                              fontSize: 9.5,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        todayReward.description,
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
            ),
          ),
          const SizedBox(height: 14),

          // Streak Rescue / Freeze Banner
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2433) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: game.hasStreakFreeze
                    ? const Color(0xFF38BDF8)
                    : (isDark ? Colors.white12 : Colors.black12),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  game.hasStreakFreeze
                      ? Icons.shield_rounded
                      : Icons.security_rounded,
                  size: 20,
                  color: game.hasStreakFreeze
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('streak_rescue_banner_title'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        context.tr('streak_rescue_banner_desc'),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (game.hasStreakFreeze)
                  NeoBrutalBadge(
                    text: context.tr('streak_rescue_active_badge'),
                    icon: Icons.check_circle_rounded,
                    backgroundColor: const Color(0xFF38BDF8),
                    textColor: Colors.black,
                    fontSize: 9,
                  )
                else
                  NeoBrutalButton(
                    label: context.tr('streak_rescue_btn'),
                    icon: Icons.shield_rounded,
                    backgroundColor: const Color(0xFFF59E0B),
                    textColor: Colors.black,
                    fontSize: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    onPressed: () {
                      AdService.instance.showRewardedAdWithFallback(
                        context: context,
                        customRewardTitle: context.tr('streak_rescue_banner_title'),
                        onRewardEarned: () {
                          ref.read(gameProvider.notifier).activateStreakRescue();
                          NotificationService.showSuccess(
                            context,
                            context.tr('toast_streak_rescued'),
                          );
                          setState(() {});
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Claim Action Buttons
          if (canClaim) ...[
            NeoBrutalButton(
              label: context.tr('streak_double_reward_btn'),
              icon: Icons.stars_rounded,
              backgroundColor: AppColors.brutalYellow,
              textColor: Colors.black,
              fontSize: 13,
              fullWidth: true,
              onPressed: () {
                AdService.instance.showRewardedAdWithFallback(
                  context: context,
                  customRewardTitle: context.tr('streak_double_reward_title'),
                  onRewardEarned: () {
                    final claimed = ref
                        .read(gameProvider.notifier)
                        .claimDailyLoginReward(rewardMultiplier: 2.0);
                    if (claimed != null) {
                      final doubleMoney = claimed.moneyAmount * 2;
                      final doubleRep = claimed.reputationAmount * 2;
                      final rewardSummary = doubleMoney > 0
                          ? '+${CurrencyFormatter.formatShort(doubleMoney)}'
                          : '+$doubleRep';
                      NotificationService.showSuccess(
                        context,
                        context.tr('toast_daily_reward_claimed', {
                          'day': claimed.dayNumber,
                          'reward': rewardSummary,
                        }),
                      );
                      setState(() {});
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 8),
            NeoBrutalButton(
              label: context.tr('streak_claim_btn', {'day': currentStreakDay}),
              icon: Icons.card_giftcard_rounded,
              backgroundColor: AppColors.brutalGreen,
              textColor: Colors.black,
              fontSize: 12,
              fullWidth: true,
              onPressed: () {
                final claimed =
                    ref.read(gameProvider.notifier).claimDailyLoginReward();
                if (claimed != null) {
                  final rewardSummary = claimed.moneyAmount > 0
                      ? '+${CurrencyFormatter.formatShort(claimed.moneyAmount)}'
                      : '+${claimed.reputationAmount}';
                  NotificationService.showSuccess(
                    context,
                    context.tr('toast_daily_reward_claimed', {
                      'day': claimed.dayNumber,
                      'reward': rewardSummary,
                    }),
                  );
                  setState(() {});
                }
              },
            ),
          ] else ...[
            NeoBrutalButton(
              label: context.tr('streak_already_claimed_btn'),
              icon: Icons.check_circle_rounded,
              backgroundColor: isDark
                  ? const Color(0xFF232A3B)
                  : const Color(0xFFE2E8F0),
              textColor: isDark ? Colors.white54 : Colors.black45,
              fullWidth: true,
              onPressed: null,
            ),
          ],
        ],
      ),
    );
  }
}
