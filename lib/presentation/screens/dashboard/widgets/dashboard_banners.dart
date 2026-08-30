import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/weekly_event_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/daily_bulletin_dialog.dart';
import '../../../widgets/dealership_logo_badge.dart';
import '../../../widgets/floating_money_overlay.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../../widgets/pulsing_dot.dart';
import '../../../widgets/zeigarnik_progress_bar.dart';
import 'dashboard_retention_modals.dart';

/// 1. Profile & Dealership Banner
class DashboardProfileBanner extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardProfileBanner({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final xpInCurrent = game.skills.xpInCurrentLevel;
    final targetXp = game.skills.currentLevelTargetXp;
    final remainingXp = (targetXp - xpInCurrent).clamp(0, targetXp);
    final xpProgress = (xpInCurrent / targetXp).clamp(0.0, 1.0);

    return NeoBrutalCard(
      onTap: () => context.push('/character-growth'),
      padding: const EdgeInsets.all(13),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Dealership Avatar / Custom Badge
              DealershipLogoBadge(
                emblemId: game.logoEmblemId,
                badgeShape: game.logoBadgeShape,
                badgeColor: game.logoBadgeColor,
                size: 44,
              ),
              const SizedBox(width: 10),

              // Title & Level Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            game.dealershipName,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: 'LVL ${game.level}',
                          backgroundColor: const Color(0xFFFFDE59),
                          textColor: Colors.black,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    if (game.dealershipTagline.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        game.dealershipTagline,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: DealershipLogoBadge.getBackgroundColor(
                              game.logoBadgeColor),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(
                      '${game.playerName} • ${game.corporateTierTitle}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Settings Icon
              IconButton(
                icon: Icon(
                  Icons.settings_rounded,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                  size: 22,
                ),
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Level Progress Bar (Goal Gradient & Zeigarnik Effect §2.2)
          Row(
            children: [
              Expanded(
                child: ZeigarnikProgressBar(
                  progress: xpProgress,
                  height: 11,
                  fillColor: palette.primaryColor,
                  backgroundColor: isDark
                      ? const Color(0xFF1E2330)
                      : const Color(0xFFE2E8F0),
                  borderColor: isDark
                      ? const Color(0xFF333B4F)
                      : const Color(0xFF0F172A),
                  borderWidth: 1.4,
                  borderRadius: 6,
                  isHazardStriped: true,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                context.tr('next_level_xp',
                    {'level': game.level + 1, 'xp': remainingXp}),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? const Color(0xFFFFDE59)
                      : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Weekly Dynamic Event Banner
class DashboardWeeklyEventBanner extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardWeeklyEventBanner({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final lang = Localizations.localeOf(context).languageCode;
    final event = WeeklyEventEngine.getEventForDay(game.currentDay);
    final dayNames = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar'
    ];
    final dayName = dayNames[(event.dayOfWeek - 1).clamp(0, 6)];
    final IconData icon = event.dayOfWeek == 1
        ? Icons.credit_card_rounded
        : (event.dayOfWeek == 2
            ? Icons.search_rounded
            : (event.dayOfWeek == 3
                ? Icons.build_rounded
                : (event.dayOfWeek == 4
                    ? Icons.apartment_rounded
                    : (event.dayOfWeek == 5
                        ? Icons.local_fire_department_rounded
                        : (event.dayOfWeek == 6
                            ? Icons.workspace_premium_rounded
                            : Icons.auto_awesome_rounded)))));

    return NeoBrutalCard(
      onTap: () => DailyBulletinDialog.show(context),
      padding: const EdgeInsets.all(10),
      backgroundColor:
          isDark ? const Color(0xFF191D2B) : const Color(0xFFEFF6FF),
      borderColor: const Color(0xFF3B82F6),
      borderRadius: 12,
      borderWidth: 2.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NeoBrutalBadge(
                      text: '${dayName.toUpperCase()} ETKİNLİĞİ',
                      backgroundColor: const Color(0xFF3B82F6),
                      textColor: Colors.white,
                      fontSize: 9,
                    ),
                    const Spacer(),
                    Text(
                      '${game.currentDay}. ${context.tr('hud_day')}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.getLocalizedTitle(langCode: lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.getLocalizedDescription(langCode: lang),
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
    );
  }
}

/// First Day Quest Guide Banner
class DashboardFirstDayQuestBanner extends StatelessWidget {
  final DealershipModel game;
  final VoidCallback onGoToShowroom;

  const DashboardFirstDayQuestBanner({
    super.key,
    required this.game,
    required this.onGoToShowroom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String questTitle;
    String questSubtitle;
    IconData questIcon;
    VoidCallback onQuestTap;

    if (game.ownedCars.isNotEmpty) {
      final hasListedCar = game.ownedCars.any((c) => c.isListed);
      if (!hasListedCar) {
        questTitle = context.tr('quest_title_1');
        questSubtitle = context.tr('quest_sub_1');
        questIcon = Icons.storefront_rounded;
        onQuestTap = onGoToShowroom;
      } else {
        questTitle = context.tr('quest_title_2');
        questSubtitle = context.tr('quest_sub_2');
        questIcon = Icons.handshake_rounded;
        onQuestTap = onGoToShowroom;
      }
    } else {
      questTitle = context.tr('quest_title_buy');
      questSubtitle = context.tr('quest_sub_buy');
      questIcon = Icons.shopping_cart_rounded;
      onQuestTap = () => context.push('/marketplace');
    }

    return NeoBrutalCard(
      onTap: onQuestTap,
      padding: const EdgeInsets.all(10),
      backgroundColor: const Color(0xFFFEF3C7),
      borderColor: Colors.black,
      borderRadius: 12,
      borderWidth: 2.0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDE59),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: Icon(questIcon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NeoBrutalBadge(
                      text: context.tr('starter_quest_badge'),
                      backgroundColor: Colors.black,
                      textColor: const Color(0xFFFFDE59),
                      fontSize: 9,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('go_now'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 13, color: Colors.black),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  questTitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  questSubtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Advisor Guidance Banner
class DashboardAdvisorGuidanceBanner extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final VoidCallback onGoToShowroom;

  const DashboardAdvisorGuidanceBanner({
    super.key,
    required this.game,
    required this.palette,
    required this.onGoToShowroom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    String adviceTitle;
    String adviceSubtitle;
    IconData adviceIcon;
    VoidCallback onAdviceTap;

    final dirtyCars =
        game.ownedCars.where((c) => !c.isWashed || !c.isPolished).toList();
    final damagedCars = game.ownedCars
        .where((c) =>
            c.expertise.engineCondition < 80 ||
            c.expertise.transmissionCondition < 80 ||
            c.expertise.bodyParts.values.any((s) => s == PartStatus.damaged))
        .toList();
    final unlistedCars = game.ownedCars.where((c) => !c.isListed).toList();
    final carsWithOffers = game.ownedCars
        .where((c) =>
            game.incomingOffers.any((o) => o.carId == c.id && !o.isExpired))
        .toList();

    if (carsWithOffers.isNotEmpty) {
      adviceTitle = context.tr('advisor_offers_title');
      adviceSubtitle =
          context.tr('advisor_offers_sub', {'count': carsWithOffers.length});
      adviceIcon = Icons.handshake_rounded;
      onAdviceTap = onGoToShowroom;
    } else if (game.ownedCars.isEmpty) {
      adviceTitle = context.tr('advisor_empty_title');
      adviceSubtitle = context.tr('advisor_empty_sub');
      adviceIcon = Icons.shopping_cart_rounded;
      onAdviceTap = () => context.push('/marketplace');
    } else if (dirtyCars.isNotEmpty) {
      if (game.isFeatureUnlocked('/car-wash')) {
        adviceTitle =
            context.tr('advisor_dirty_title', {'count': dirtyCars.length});
        adviceSubtitle = context.tr('advisor_dirty_sub');
        adviceIcon = Icons.local_car_wash_rounded;
        onAdviceTap = () => context.push('/car-wash');
      } else {
        adviceTitle = context.tr('advisor_unlock_wash_title');
        adviceSubtitle = context.tr('advisor_unlock_wash_sub');
        adviceIcon = Icons.store_rounded;
        onAdviceTap = () => context.push('/branches');
      }
    } else if (damagedCars.isNotEmpty) {
      if (game.isFeatureUnlocked('/workshop')) {
        adviceTitle = context.tr('advisor_damaged_title');
        adviceSubtitle =
            context.tr('advisor_damaged_sub', {'count': damagedCars.length});
        adviceIcon = Icons.build_circle_rounded;
        onAdviceTap = () => context.push('/workshop');
      } else {
        adviceTitle = context.tr('advisor_unlock_workshop_title');
        adviceSubtitle = context.tr('advisor_unlock_workshop_sub');
        adviceIcon = Icons.build_circle_rounded;
        onAdviceTap = () => context.push('/branches');
      }
    } else if (unlistedCars.isNotEmpty) {
      adviceTitle =
          context.tr('advisor_unlisted_title', {'count': unlistedCars.length});
      adviceSubtitle = context.tr('advisor_unlisted_sub');
      adviceIcon = Icons.storefront_rounded;
      onAdviceTap = onGoToShowroom;
    } else {
      adviceTitle = context.tr('advisor_all_good_title');
      adviceSubtitle = context.tr('advisor_all_good_sub');
      adviceIcon = Icons.trending_up_rounded;
      onAdviceTap = () => context.push('/marketplace');
    }

    return NeoBrutalCard(
      onTap: onAdviceTap,
      padding: const EdgeInsets.all(10),
      backgroundColor:
          isDark ? const Color(0xFF19231D) : const Color(0xFFECFDF5),
      borderColor: const Color(0xFF10B981),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(adviceIcon, color: Colors.black, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NeoBrutalBadge(
                      text: context.tr('advisor_badge'),
                      backgroundColor: const Color(0xFF10B981),
                      textColor: Colors.black,
                      fontSize: 8.5,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('inspect_btn'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 13, color: Color(0xFF10B981)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  adviceTitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  adviceSubtitle,
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
    );
  }
}

/// Emergency Rescue Banner (Bailout / Scrapyard gig)
class DashboardEmergencyRescueBanner extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardEmergencyRescueBanner({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final totalOwnedValue = game.ownedCars.fold<double>(
      0.0,
      (sum, c) => sum + c.estimatedRealValue,
    );
    final totalAssets =
        game.balance + game.bankDepositBalance + totalOwnedValue;
    final canClaimBailout = totalAssets <= 15000;

    final bool canWorkGig = game.lastScrapyardGigDate == null ||
        DateTime.now().difference(game.lastScrapyardGigDate!).inHours >= 20;

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor:
          isDark ? const Color(0xFF261818) : const Color(0xFFFEF2F2),
      borderColor: const Color(0xFFEF4444),
      borderRadius: 12,
      borderWidth: 2.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFEF4444), size: 22),
              const SizedBox(width: 8),
              Text(
                context.tr('emergency_title'),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr('emergency_desc',
                {'balance': CurrencyFormatter.formatShort(game.balance)}),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              // 1. Scrapyard Gig
              Expanded(
                child: NeoBrutalButton(
                  label: canWorkGig
                      ? context.tr('scrapyard_gig_btn')
                      : context.tr('scrapyard_gig_done'),
                  icon: canWorkGig
                      ? Icons.handyman_rounded
                      : Icons.check_circle_rounded,
                  backgroundColor: canWorkGig
                      ? const Color(0xFFFFDE59)
                      : (isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0)),
                  textColor: canWorkGig
                      ? Colors.black
                      : (isDark ? Colors.white54 : Colors.black54),
                  fontSize: 10.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  onPressed: canWorkGig
                      ? () {
                          final success = ref
                              .read(gameProvider.notifier)
                              .workScrapyardSideGig();
                          if (success) {
                            FloatingMoneyOverlay.of(context)?.showMoneyPopUp(
                                5000,
                                label: context.tr('scrapyard_gig_done_label'));
                            NotificationService.showSuccess(
                              context,
                              context.tr('scrapyard_toast_apprentice_done'),
                            );
                          } else {
                            NotificationService.showWarning(context,
                                context.tr('scrapyard_toast_apprentice_limit'));
                          }
                        }
                      : null,
                ),
              ),
              if (canClaimBailout) ...[
                const SizedBox(width: 8),
                // 2. Emergency Bailout (Dede Mirası)
                Expanded(
                  child: NeoBrutalButton(
                    label: context.tr('emergency_bailout_btn'),
                    icon: Icons.volunteer_activism_rounded,
                    backgroundColor: const Color(0xFF00E575),
                    textColor: Colors.black,
                    fontSize: 10.5,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    onPressed: () {
                      final success = ref
                          .read(gameProvider.notifier)
                          .claimEmergencyBailout();
                      if (success) {
                        FloatingMoneyOverlay.of(context)
                            ?.showMoneyPopUp(50000, label: context.tr('emergency_bailout_done_label'));
                        NotificationService.showSuccess(
                          context,
                          context.tr('emergency_bailout_success_toast'),
                        );
                      } else {
                        NotificationService.showWarning(context,
                            context.tr('toast_safety_net_rejected'));
                      }
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Retention Highlights Row (Leaderboard, Album, Prestige)
class DashboardRetentionHighlightsRow extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final WidgetRef ref;

  const DashboardRetentionHighlightsRow({
    super.key,
    required this.game,
    required this.palette,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final discoveredCount = game.discoveredCarModelIds.length;
    final canPrestige = game.level >= 4 || game.totalProfit >= 3000000;

    return Row(
      children: [
        // 1. Rivals Leaderboard
        Expanded(
          child: NeoBrutalCard(
            onTap: () => DashboardRetentionModals.showRivalLeaderboardModal(
                context, game),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.leaderboard_rounded,
                      color: Colors.black, size: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('city_league'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.tr('rivals_count', {'count': 5}),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),

        // 2. Collection Album
        Expanded(
          child: NeoBrutalCard(
            onTap: () => context.push('/album'),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFA855F7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 16),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.tr('album_title'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.tr('album_count', {'count': discoveredCount}),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA855F7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Prestige (If unlocked)
        if (canPrestige) ...[
          const SizedBox(width: 6),
          Expanded(
            child: NeoBrutalCard(
              onTap: () => DashboardRetentionModals.showPrestigeModal(
                  context, game, ref),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              backgroundColor: const Color(0xFFFFDE59),
              borderColor: Colors.black,
              borderRadius: 10,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.stars_rounded,
                        color: Color(0xFFFFDE59), size: 16),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('prestige_transfer'),
                          style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          context.tr('prestige_new_season'),
                          style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Daily Streak Reward Claim Banner
class DashboardDailyStreakBanner extends ConsumerWidget {
  final DealershipModel game;

  const DashboardDailyStreakBanner({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    if (game.lastRewardClaimDate != null) {
      final lastClaim = game.lastRewardClaimDate!;
      if (lastClaim.year == now.year &&
          lastClaim.month == now.month &&
          lastClaim.day == now.day) {
        return const SizedBox.shrink();
      }
    }

    return NeoBrutalCard(
      padding: const EdgeInsets.all(10),
      backgroundColor: const Color(0xFFFFDE59),
      borderColor: const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFF7A00),
                  size: 22,
                ),
              ),
              const Positioned(
                top: -3,
                right: -3,
                child: PulsingDot(
                  color: Color(0xFF00E575),
                  size: 8.0,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context
                      .tr('daily_streak_title', {'count': game.loginStreak}),
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr('daily_streak_sub'),
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: context.tr('claim_btn'),
            icon: Icons.attach_money_rounded,
            backgroundColor: const Color(0xFF00E575),
            textColor: Colors.black,
            borderColor: const Color(0xFF0F172A),
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            onPressed: () {
              HapticFeedback.mediumImpact();
              final reward =
                  ref.read(gameProvider.notifier).claimDailyStreak();
              FloatingMoneyOverlay.of(context)
                  ?.showMoneyPopUp(reward.toDouble(), label: 'Seri Ödülü!');
              NotificationService.showSuccess(
                context,
                '${CurrencyFormatter.formatShort(reward.toDouble())} Günlük Seri Ödülü Hesabına Eklendi!',
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Estimated Daily Cash Flow Breakdown Card
class DashboardDailyCashFlowCard extends StatelessWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardDailyCashFlowCard({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = palette.isDark;
    final dailyPassiveIncome =
        game.sideBusinesses.where((b) => b.isOwned).fold<double>(
              0.0,
              (sum, b) => sum + b.grossDailyIncome,
            );
    final dailySalaries = game.hiredStaff.fold<double>(
      0.0,
      (sum, s) => sum + (s.dailySalary),
    );
    final dailyLoanPayment = game.activeLoans.fold<double>(
      0.0,
      (sum, l) => sum + (l.monthlyPayment),
    );
    final netDailyFlow = dailyPassiveIncome - dailySalaries - dailyLoanPayment;

    return NeoBrutalCard(
      onTap: () {
        HapticFeedback.lightImpact();
        context.push('/finance/daily-cashflow');
      },
      padding: const EdgeInsets.all(10),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    context.tr('daily_net_cashflow'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildSparklineBars(isDark, netDailyFlow >= 0),
                  const SizedBox(width: 8),
                  Text(
                    '${netDailyFlow >= 0 ? '+' : ''}${CurrencyFormatter.formatShort(netDailyFlow)}/${context.tr('hud_day').toLowerCase()}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: netDailyFlow >= 0
                          ? const Color(0xFF00E575)
                          : const Color(0xFFEF4444),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                context.tr('side_incomes', {
                  'amount': CurrencyFormatter.formatShort(dailyPassiveIncome)
                }),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00E575)),
              )),
              Expanded(
                  child: Text(
                context.tr('salaries',
                    {'amount': CurrencyFormatter.formatShort(dailySalaries)}),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              )),
              if (dailyLoanPayment > 0)
                Text(
                  context.tr('loans', {
                    'amount': CurrencyFormatter.formatShort(dailyLoanPayment)
                  }),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSparklineBars(bool isDark, bool isPositive) {
    final bars = isPositive
        ? [0.35, 0.5, 0.45, 0.7, 0.65, 0.85, 1.0]
        : [1.0, 0.8, 0.75, 0.6, 0.5, 0.4, 0.3];
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(bars.length, (index) {
        final height = 3.5 + (bars[index] * 9.5);
        final isLast = index == bars.length - 1;
        return Container(
          width: 2.5,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 0.8),
          decoration: BoxDecoration(
            color: isLast
                ? (isPositive ? const Color(0xFF00E575) : const Color(0xFFEF4444))
                : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
            borderRadius: BorderRadius.circular(1.0),
          ),
        );
      }),
    );
  }
}
