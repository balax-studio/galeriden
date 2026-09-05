import 'package:flutter/services.dart';
import '../../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../core/services/game_sound_haptic_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../domain/usecases/collection_album_engine.dart';
import '../../../../domain/usecases/offline_multiplier_engine.dart';
import '../../../../domain/usecases/psychology_engine.dart';
import '../../../../domain/usecases/rival_leaderboard_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/floating_money_overlay.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/confetti_celebration_overlay.dart';

extension LeaderboardEntryUiExt on LeaderboardEntry {
  String getLocalizedName(BuildContext context) {
    if (isPlayer) return name;
    if (key.isNotEmpty) return context.tr('${key}_name');
    return name;
  }

  String getLocalizedTagline(BuildContext context) {
    if (isPlayer) return context.tr('rival_player_tagline');
    if (key.isNotEmpty) return context.tr('${key}_tagline');
    return tagline;
  }
}

extension LeaderboardNearMissUiExt on LeaderboardNearMissInfo {
  String getLocalizedMotivation(BuildContext context) {
    final rivalLocalizedName = (targetRivalKey != null && targetRivalKey!.isNotEmpty)
        ? context.tr('${targetRivalKey}_name')
        : (targetRivalName ?? '');

    if (isLeader) {
      if (rivalLocalizedName.isNotEmpty) {
        return context.tr('rival_leader_motivation', {
          'rival': rivalLocalizedName,
          'diff': CurrencyFormatter.format(scoreDifference),
        });
      }
      return context.tr('rival_leader_solo');
    }

    if (rivalLocalizedName.isNotEmpty) {
      return context.tr('rival_chaser_motivation', {
        'rank': '${playerRank - 1}',
        'rival': rivalLocalizedName,
        'diff': CurrencyFormatter.format(scoreDifference),
      });
    }

    return context.tr('rival_empty_motivation');
  }
}

/// Centralized Modals & Bottom Sheets for Dashboard Retention Mechanics
class DashboardRetentionModals {
  DashboardRetentionModals._();

  /// Offline Progression Recap Dialog with Dynamic Rewarded Ad Multiplier (1.5x - 3.0x)
  static void showOfflineRecapModal(
      BuildContext context, Map<String, dynamic> recap,
      {WidgetRef? ref}) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ??
        (Theme.of(context).brightness == Brightness.dark);

    final earnedIncome = (recap['earnedIncome'] as num?)?.toDouble() ?? 0.0;
    final rawBulletPoints = recap['bulletPoints'];
    final bulletPoints = (rawBulletPoints is List)
        ? rawBulletPoints.map((e) => e.toString()).toList()
        : <String>[];
    final multiplier = earnedIncome > 0
        ? OfflineMultiplierEngine.getRandomMultiplier()
        : 1.0;
    final bonusIncome =
        OfflineMultiplierEngine.calculateBonusAmount(earnedIncome, multiplier);
    final totalMultipliedIncome =
        OfflineMultiplierEngine.calculateTotalAmount(earnedIncome, multiplier);
    final multiplierFormatted =
        OfflineMultiplierEngine.formatMultiplier(multiplier);

    bool isAdLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogContext, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 18),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(18),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: const Color(0xFF00E575),
              borderRadius: 12,
              borderWidth: 2.5,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E575),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.wb_sunny_rounded,
                              color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            recap['title'] as String? ??
                                context.tr('retention_offline_title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (earnedIncome > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFF00E575), width: 1.5),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    context.tr('retention_passive_income'),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '+${CurrencyFormatter.format(earnedIncome)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF00E575),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFDE59),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: Colors.black, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.bolt_rounded,
                                      size: 14, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Text(
                                    context.tr(
                                        'retention_offline_chance_badge',
                                        {'multiplier': multiplierFormatted}),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    ...bulletPoints.map(
                      (bp) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          bp,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFCBD5E1)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (earnedIncome > 0) ...[
                      NeoBrutalButton(
                        label: context.tr('retention_offline_multiplier_btn',
                            {'multiplier': multiplierFormatted}),
                        icon: Icons.movie_filter_rounded,
                        backgroundColor: const Color(0xFFFFDE59),
                        textColor: Colors.black,
                        fullWidth: true,
                        onPressed: isAdLoading
                            ? null
                            : () {
                                setState(() => isAdLoading = true);
                                HapticFeedback.selectionClick();
                                GameSoundHapticService.playClick();

                                AdService.instance.showRewardedAdWithFallback(
                                  context: context,
                                  customRewardTitle: context.tr(
                                      'retention_offline_chance_badge',
                                      {'multiplier': multiplierFormatted}),
                                  onRewardEarned: () {
                                    if (dialogContext.mounted) {
                                      Navigator.pop(dialogContext);
                                    }

                                    // Add bonus income to balance
                                    if (ref != null && bonusIncome > 0) {
                                      ref.read(gameProvider.notifier).addMoney(bonusIncome);
                                    }

                                    if (context.mounted) {
                                      FloatingMoneyOverlay.of(context)
                                          ?.showMoneyPopUp(
                                        totalMultipliedIncome,
                                        label:
                                            '$multiplierFormatted Katlanan Pasif Gelir!',
                                      );
                                      GameSoundHapticService.playCashSuccess();
                                      HapticFeedback.heavyImpact();
                                    }
                                  },
                                );
                              },
                      ),
                      const SizedBox(height: 8),
                    ],
                    NeoBrutalButton(
                      label: context.tr('retention_claim_rewards'),
                      icon: Icons.check_circle_rounded,
                      backgroundColor: earnedIncome > 0
                          ? (isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0))
                          : const Color(0xFF00E575),
                      textColor: earnedIncome > 0
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (earnedIncome > 0) {
                          FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                            earnedIncome,
                            label: 'Kazanılan Pasif Gelir!',
                          );
                          GameSoundHapticService.playCashSuccess();
                          HapticFeedback.mediumImpact();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Exit Hook Dialog with Peak-End Rule & Open Loops (§1.5 & §2.1)
  static void showExitHookDialog(BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;

    String? peakHighlight;
    if (game.carsSold > 0) {
      peakHighlight =
          '${game.dealershipName} bünyesinde ${game.carsSold} başarılı satışla toplam ${CurrencyFormatter.formatShort(game.totalProfit)} kâr elde ettin.';
    }

    final openLoops = PsychologyEngine.getOpenLoopsSummary(
      pendingOrdersCount: game.pendingOrders.length,
      showroomListedCarsCount: game.ownedCars.where((c) => c.isListed).length,
      currentStreak: game.loginStreak,
      peakSaleHighlight: peakHighlight,
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          borderRadius: 12,
          borderWidth: 2.5,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                openLoops['title'] as String? ?? 'DÖNÜŞÜNÜ BEKLEYENLER',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ...((openLoops['items'] as List<String>?) ?? []).map(
                (bp) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    bp,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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
                      label: context.tr('retention_stay_button'),
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('retention_exit_button'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor:
                          isDark ? Colors.white70 : const Color(0xFF64748B),
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  /// Reciprocity Starter Welcome Gift Dialog (§4.3)
  static void showReciprocityStarterGiftModal(
      BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;
    final gift = PsychologyEngine.getReciprocityStarterGift();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: const Color(0xFFFFDE59),
          borderRadius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.card_giftcard_rounded,
                        color: Colors.black, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      gift['title'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFFFFDE59), width: 2.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gift['sender'] as String,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD97706)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${gift['message']}"',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontStyle: FontStyle.italic,
                        color: isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('retention_gift_content'),
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(context.tr('retention_gift_grant_1'),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00E575))),
              Text(context.tr('retention_gift_grant_2'),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF38BDF8))),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: context.tr('retention_gift_accept'),
                icon: Icons.check_circle_rounded,
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  ref
                      .read(gameProvider.notifier)
                      .addMoney(gift['bonusMoney'] as double);
                  ref.read(gameProvider.notifier).addXP(100);
                  Navigator.pop(ctx);
                  FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                      gift['bonusMoney'] as double,
                      label: 'Haydar Usta Hibesi!');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Level-Up Celebration Modal (§1.4 & §5.5)
  static void showLevelUpModal(BuildContext context, int newLevel,
      {VoidCallback? onExplore}) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;

    // Trigger celebratory neo-brutal confetti
    ConfettiCelebrationOverlay.show(context);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: const Color(0xFFFFDE59),
          borderRadius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.military_tech_rounded,
                        color: Colors.black, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.tr('level_up_badge'),
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF59E0B))),
                        Text(
                            context.tr('level_up_title', {'level': '$newLevel'}),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Semantics(
                    label: context.tr('btn_close'),
                    button: true,
                    child: InkWell(
                      onTap: () => Navigator.of(ctx).pop(),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                context.tr('level_up_modal_desc', {'level': '$newLevel'}),
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFF00E575), width: 2.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFF00E575), size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.tr('level_up_modal_perk'),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E575)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalButton(
                label: context.tr('explore_now_btn'),
                icon: Icons.rocket_launch_rounded,
                backgroundColor: const Color(0xFFFFDE59),
                textColor: Colors.black,
                fullWidth: true,
                onPressed: () {
                  Navigator.pop(ctx);
                  onExplore?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Rival Leaderboard Modal
  static void showRivalLeaderboardModal(
      BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final leaderboard = RivalLeaderboardEngine.getLeaderboard(
      playerDealership: game,
      currentDay: game.currentDay,
    );
    final nearMissInfo = RivalLeaderboardEngine.getNearMissInfo(leaderboard);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.90,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded,
                          color: Color(0xFFFFDE59), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('rival_leaderboard_title'),
                        style: AppTypography.titleLarge(p.isDark),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.tr('rival_leaderboard_subtitle'),
                style: AppTypography.labelSmall(p.isDark),
              ),
              const SizedBox(height: 12),

              // Near-Miss / Leader Motivation Banner
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: nearMissInfo.isLeader
                      ? (isDark
                          ? const Color(0xFF2A2412)
                          : const Color(0xFFFEF9C3))
                      : (isDark
                          ? const Color(0xFF13231B)
                          : const Color(0xFFECFDF5)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: nearMissInfo.isLeader
                        ? const Color(0xFFFFDE59)
                        : const Color(0xFF00E575),
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      nearMissInfo.isLeader
                          ? Icons.workspace_premium_rounded
                          : Icons.trending_up_rounded,
                      color: nearMissInfo.isLeader
                          ? const Color(0xFFFFDE59)
                          : const Color(0xFF00E575),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        nearMissInfo.getLocalizedMotivation(ctx),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              ...leaderboard.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final item = entry.value;
                final isPlayer = item.isPlayer;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isPlayer
                        ? (isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFFEF3C7))
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPlayer
                          ? const Color(0xFFFFDE59)
                          : (isDark
                              ? const Color(0xFF2A3142)
                              : const Color(0xFFCBD5E1)),
                      width: isPlayer ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Rank Badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rank == 1
                              ? const Color(0xFFFFDE59)
                              : (rank == 2
                                  ? const Color(0xFFCBD5E1)
                                  : (rank == 3
                                      ? const Color(0xFFF97316)
                                      : Colors.transparent)),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: rank <= 3
                                  ? Colors.black
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Rank Trend (▲ / ▼ / —)
                      SizedBox(
                        width: 32,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (item.rankChange > 0) ...[
                              const Icon(Icons.arrow_drop_up_rounded,
                                  color: Color(0xFF00E575), size: 18),
                              Text(
                                '+${item.rankChange}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF00E575),
                                ),
                              ),
                            ] else if (item.rankChange < 0) ...[
                              const Icon(Icons.arrow_drop_down_rounded,
                                  color: Color(0xFFFF4D4D), size: 18),
                              Text(
                                '${item.rankChange}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFFFF4D4D),
                                ),
                              ),
                            ] else ...[
                              Text(
                                '—',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Name & Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    item.getLocalizedName(ctx),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                      color: isPlayer
                                          ? (isDark
                                              ? const Color(0xFFFFDE59)
                                              : const Color(0xFF0F172A))
                                          : (isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ),
                                if (isPlayer) ...[
                                  const SizedBox(width: 6),
                                  NeoBrutalBadge(
                                    text: ctx.tr('rival_badge_you'),
                                    backgroundColor: const Color(0xFFFFDE59),
                                    textColor: Colors.black,
                                    fontSize: 8.5,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.getLocalizedTagline(ctx).isNotEmpty ? "${item.getLocalizedTagline(ctx)} • " : ""}${ctx.tr('rival_stat_cars_rep', {'cars': '${item.carsSold}', 'rep': '${item.reputation}'})}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Turnover Score
                      Text(
                        CurrencyFormatter.formatShort(item.turnoverScore),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF00E575)
                              : const Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ),
  );
},
    );
  }

  /// Collection Album Modal
  static void showCollectionAlbumModal(
      BuildContext context, DealershipModel game) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final progress = CollectionAlbumEngine.calculateAlbumProgress(
      discoveredCarIds: game.discoveredCarModelIds,
      totalCatalogCarsCount: 30,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(ctx).height * 0.90,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_stories_rounded,
                          color: Color(0xFFA855F7), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'KOLEKSİYON ALBÜMÜ • 30 ARAÇ',
                        style: AppTypography.titleLarge(p.isDark),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Galerinden geçen her farklı modeli albümüne kaydet ve kilometre taşı ödülleri kazan',
                style: AppTypography.labelSmall(p.isDark),
              ),
              const SizedBox(height: 14),

              // Progress Bar Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFFA855F7), width: 1.4),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          'Keşif İlerlemesi:',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF581C87)),
                        )),
                        Expanded(
                            child: Text(
                          '${progress.discoveredCount} / 30 Araç • %${(progress.completionPercentage * 100).toStringAsFixed(1)}',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFA855F7)),
                        )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.completionPercentage,
                      backgroundColor: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFFE9D5FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFA855F7)),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'KİLOMETRE TAŞI ÖDÜLLERİ',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? const Color(0xFFA855F7)
                        : const Color(0xFF581C87)),
              ),
              const SizedBox(height: 8),
              _buildMilestoneRow(
                  5,
                  'Çırak Koleksiyoner',
                  '₺25.000 + 1 Yetenek Puanı',
                  progress.discoveredCount >= 5,
                  isDark),
              _buildMilestoneRow(
                  10,
                  'Usta Koleksiyoner',
                  '₺60.000 + 2 Yetenek Puanı',
                  progress.discoveredCount >= 10,
                  isDark),
              _buildMilestoneRow(
                  20,
                  'Oto Gurmesi',
                  '₺150.000 + 3 Yetenek Puanı',
                  progress.discoveredCount >= 20,
                  isDark),
              _buildMilestoneRow(
                  30,
                  'Efsane Küratör',
                  '₺500.000 + 5 Yetenek Puanı',
                  progress.discoveredCount >= 30,
                  isDark),
            ],
          ),
        ),
      ),
    ),
  );
},
    );
  }

  static Widget _buildMilestoneRow(int targetCount, String title, String reward,
      bool isUnlocked, bool isDark) {
    final mutedColor =
        isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? const Color(0xFF19231D) : const Color(0xFFECFDF5))
            : (isDark ? const Color(0xFF141721) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF10B981)
              : (isDark ? const Color(0xFF2A3142) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUnlocked
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            color: isUnlocked ? const Color(0xFF10B981) : mutedColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$targetCount Araç: $title',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked
                        ? (isDark ? Colors.white : const Color(0xFF0F172A))
                        : mutedColor,
                  ),
                ),
                Text(
                  reward,
                  style: TextStyle(
                    fontSize: 10,
                    color: isUnlocked ? const Color(0xFF10B981) : mutedColor,
                  ),
                ),
              ],
            ),
          ),
          if (isUnlocked)
            const NeoBrutalBadge(
              text: 'AÇILDI',
              backgroundColor: Color(0xFF10B981),
              textColor: Colors.white,
              fontSize: 8.5,
            ),
        ],
      ),
    );
  }

  /// Prestige / Galeri Devretme Modal
  static void showPrestigeModal(
      BuildContext context, DealershipModel game, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final isDark = themeExt.palette.isDark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 18),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(18),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: const Color(0xFFFFDE59),
          borderRadius: 12,
          borderWidth: 2.5,
          shadowOffset: const Offset(4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDE59),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        width: 2.0,
                      ),
                    ),
                    child: const Icon(Icons.stars_rounded,
                        color: Colors.black, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'GALERİYİ DEVRET • YENİ SEZON',
                      style:
                          TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Galerini yüksek kârla bir holdinge devrederek yeni sezona başlayabilirsin.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color(0xFFFFDE59), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.workspace_premium_rounded,
                            size: 14, color: Color(0xFFD97706)),
                        const SizedBox(width: 4),
                        Text(context.tr('prestige_season_benefits_title'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11.5)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                        context.tr('prestige_season_benefit_margin',
                            {'level': '${game.prestigeLevel}'}),
                        style: const TextStyle(fontSize: 11)),
                    Text(context.tr('prestige_season_benefit_cash'),
                        style: const TextStyle(fontSize: 11)),
                    Text(context.tr('prestige_season_benefit_skills'),
                        style: const TextStyle(fontSize: 11)),
                    Text(
                        context.tr('prestige_season_benefit_reset'),
                        style:
                            const TextStyle(fontSize: 11, color: AppColors.errorRed)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalButton(
                      label: context.tr('btn_cancel'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor:
                          isDark ? Colors.white70 : const Color(0xFF64748B),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: NeoBrutalButton(
                      label: context.tr('prestige_transfer_btn'),
                      icon: Icons.rocket_launch_rounded,
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref.read(gameProvider.notifier).performPrestige();
                        NotificationService.showSuccess(
                          context,
                          'Yeni sezona başladın! Sezon çarpanın yükseldi ve ₺150.000 eklendi.',
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
}
