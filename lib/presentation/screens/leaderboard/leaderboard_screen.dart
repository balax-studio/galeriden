import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/leaderboard_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../domain/usecases/season_engine.dart';
import '../../providers/game_provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_card.dart';
import 'widgets/leaderboard_podium_perks_sheet.dart';
import 'widgets/leaderboard_season_reward_dialog.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.logLeaderboardViewed(activeTab: 'wealth');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = ref.read(gameProvider);
      ref.read(leaderboardProvider.notifier).syncMyStats(game);
      ref.read(leaderboardProvider.notifier).loadLeaderboard(game: game);

      // Settle / prompt unclaimed season podium rewards if available
      if (game.hasUnclaimedSeasonRewards) {
        final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
        LeaderboardSeasonRewardDialog.show(
          context,
          game: game,
          isDark: themeExt.palette.isDark,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leaderboardProvider);
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('leaderboard_screen_title'),
        subtitle: context.tr('leaderboard_screen_slug'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.military_tech_rounded,
              color: isDark ? const Color(0xFFFFD700) : const Color(0xFFB45309),
            ),
            tooltip: context.tr('podium_sheet_header_title'),
            onPressed: () => LeaderboardPodiumPerksSheet.show(context, isDark: isDark),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : Colors.black,
            ),
            tooltip: context.tr('leaderboard_btn_refresh'),
            onPressed: state.isLoading
                ? null
                : () {
                    ref.read(leaderboardProvider.notifier).syncMyStats(game, force: true);
                    ref.read(leaderboardProvider.notifier).loadLeaderboard(game: game, forceRefresh: true);
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // 0. Season Countdown & Podium Perks Banner
          _buildSeasonBanner(context, game, isDark),

          // 1. Tab Selector (Wealth vs Reputation)
          _buildTabSelector(state, game, isDark),

          // 2. Main List or Loading / Empty View
          Expanded(
            child: state.isLoading && state.currentList.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.brutalYellow))
                : _buildLeaderboardList(state, isDark),
          ),

          // 3. Sticky Bottom My Rank Bar
          _buildStickyMyRank(state, game, isDark),
        ],
      ),
    );
  }

  Widget _buildSeasonBanner(BuildContext context, DealershipModel game, bool isDark) {
    final seasonId = SeasonEngine.getSeasonId();
    final remaining = SeasonEngine.getTimeRemainingInSeason();
    final remainingStr = SeasonEngine.formatRemainingTime(remaining);
    final borderColor = isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A);

    return InkWell(
      onTap: () => LeaderboardPodiumPerksSheet.show(context, isDark: isDark),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 2),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF191E2B) : const Color(0xFFFEFCE8),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2.0),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black : const Color(0xFF0F172A),
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.black,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'SEZON $seasonId',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'KALAN: $remainingStr',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    context.tr('leaderboard_banner_tap_perks'),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFEAB308),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector(LeaderboardState state, DealershipModel game, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 2.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              title: context.tr('leaderboard_tab_wealth'),
              icon: Icons.account_balance_rounded,
              isSelected: state.activeTab == LeaderboardSortType.wealth,
              selectedColor: AppColors.brutalYellow,
              onTap: () => ref
                  .read(leaderboardProvider.notifier)
                  .switchTab(LeaderboardSortType.wealth, game),
              isDark: isDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabButton(
              title: context.tr('leaderboard_tab_reputation'),
              icon: Icons.military_tech_rounded,
              isSelected: state.activeTab == LeaderboardSortType.reputation,
              selectedColor: const Color(0xFF00E575),
              onTap: () => ref
                  .read(leaderboardProvider.notifier)
                  .switchTab(LeaderboardSortType.reputation, game),
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required Color selectedColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedColor
              : (isDark ? const Color(0xFF1F2432) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 2.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: isDark ? Colors.black : const Color(0xFF0F172A),
                    offset: const Offset(2.5, 2.5),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(LeaderboardState state, bool isDark) {
    final list = state.currentList;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.leaderboard_outlined,
                size: 56,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('leaderboard_empty_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.tr('leaderboard_empty_desc'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final entry = list[index];
        final rank = index + 1;
        final isMe = entry.playerId == state.myPlayerId;
        return _buildLeaderboardRow(entry, rank, isMe, state.activeTab, isDark);
      },
    );
  }

  Widget _buildLeaderboardRow(
    LeaderboardEntryModel entry,
    int rank,
    bool isMe,
    LeaderboardSortType sortType,
    bool isDark,
  ) {
    Color rankBadgeBg;
    Color rankBadgeTextColor = Colors.black;
    if (rank == 1) {
      rankBadgeBg = const Color(0xFFFFD700);
    } else if (rank == 2) {
      rankBadgeBg = const Color(0xFFE2E8F0);
    } else if (rank == 3) {
      rankBadgeBg = const Color(0xFFCD7F32);
    } else {
      rankBadgeBg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
      rankBadgeTextColor = isDark ? Colors.white70 : const Color(0xFF334155);
    }

    final borderColor = isMe
        ? const Color(0xFF00E575)
        : (rank <= 3
            ? rankBadgeBg
            : (isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A)));

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: isMe
            ? (isDark ? const Color(0xFF12241A) : const Color(0xFFF0FDF4))
            : (isDark ? const Color(0xFF141721) : Colors.white),
        borderColor: borderColor,
        borderWidth: isMe ? 2.5 : 2.0,
        child: Row(
          children: [
            // Rank Number Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rankBadgeBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: rankBadgeTextColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Dealership & Owner Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.dealershipName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('leaderboard_tag_me'),
                          backgroundColor: const Color(0xFF00E575),
                          textColor: Colors.black,
                          fontSize: 9,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.ownerName} • ${context.tr('level_prefix')} ${entry.playerLevel}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Score Value (Wealth or XP)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (sortType == LeaderboardSortType.wealth) ...[
                  Text(
                    CurrencyFormatter.format(entry.netWorth),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E575),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.carCount} ${context.tr('leaderboard_label_cars')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ] else ...[
                  Text(
                    '${entry.reputationXp} XP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${context.tr('level_prefix')} ${entry.playerLevel}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyMyRank(LeaderboardState state, DealershipModel game, bool isDark) {
    final double totalCarValue = game.ownedCars.fold(
      0.0,
      (sum, car) => sum + car.baseMarketValue,
    );
    final double myNetWorth = game.balance + totalCarValue;
    final int myXp = game.skills.xp;

    int myRankIndex = state.currentList.indexWhere((e) => e.playerId == state.myPlayerId);
    final String myRankText;
    if (myRankIndex >= 0) {
      myRankText = '#${myRankIndex + 1}';
    } else if (state.myExactRank != null) {
      myRankText = '#${state.myExactRank}';
    } else {
      myRankText = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            width: 2.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : Colors.black12,
            offset: const Offset(0, -3),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00E575),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Text(
                myRankText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    game.dealershipName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    context.tr('leaderboard_my_standing_label'),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.activeTab == LeaderboardSortType.wealth)
                  Text(
                    CurrencyFormatter.format(myNetWorth),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E575),
                    ),
                  )
                else
                  Text(
                    '$myXp XP',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                    ),
                  ),
                Text(
                  '${context.tr('level_prefix')} ${game.level}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
