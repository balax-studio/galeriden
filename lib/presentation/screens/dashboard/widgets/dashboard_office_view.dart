import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/ad_reward_calculator.dart';
import '../../../../core/services/ad_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../../domain/usecases/smart_office_hook_engine.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_app_bar.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

import 'dashboard_quick_finance_card.dart';

class DashboardOfficeView extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const DashboardOfficeView({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final smartHook = SmartOfficeHookEngine.evaluate(game);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('office_title'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Reputation Block
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFDE59),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.star_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('office_reputation_title'),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('office_reputation_desc', {'score': '${game.reputationScore}'}),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Financial Summary Card
          DashboardQuickFinanceCard(game: game, palette: palette),
          const SizedBox(height: 14),

          // ==========================================
          // 3. STORY-DRIVEN REWARDED AD BONUS CARDS
          // ==========================================
          // Card A: Dynamic Daily Grant / Zarf Fonu
          Builder(
            builder: (context) {
              final dailyGrant = SmartOfficeHookEngine.getDailyGrantVariant(game);
              final isGrantUsed = game.isOfficeGrantClaimedToday;
              final garageTotal = game.ownedCars.fold<double>(0.0, (sum, c) => sum + c.baseMarketValue);
              final outcome = AdRewardCalculator.calculateDynamicReward(
                playerLevel: game.level,
                totalGarageValue: garageTotal,
              );

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF191D2B) : const Color(0xFFFEFCE8),
                borderColor: isGrantUsed ? const Color(0xFF475569) : const Color(0xFFEAB308),
                borderWidth: 2.4,
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalBadge(
                          text: dailyGrant.badgeText,
                          backgroundColor: isGrantUsed ? const Color(0xFF475569) : const Color(0xFFEAB308),
                          textColor: isGrantUsed ? Colors.white : Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                        if (isGrantUsed)
                          const NeoBrutalBadge(
                            text: 'KULLANILDI',
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: Color(0xFF334155),
                            textColor: Color(0xFF94A3B8),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          )
                        else
                          NeoBrutalBadge(
                            text: '+${CurrencyFormatter.formatShort(outcome.moneyAmount)} HİBE',
                            icon: Icons.play_circle_filled_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF242A3D) : const Color(0xFFFEF08A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isGrantUsed
                                  ? const Color(0xFF475569)
                                  : (isDark ? const Color(0xFFEAB308) : const Color(0xFF0F172A)),
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AvatarIconWidget(
                            avatar: 'deal',
                            color: isGrantUsed ? const Color(0xFF64748B) : const Color(0xFFEAB308),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dailyGrant.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isGrantUsed
                                      ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dailyGrant.callerRole,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isGrantUsed ? const Color(0xFF64748B) : const Color(0xFFEAB308),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isGrantUsed
                                    ? '"Bugünkü hibe desteğini teslim aldın esnafım. Yarın sabah taze zarfla tekrar uğra!"'
                                    : dailyGrant.dialogue,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: isGrantUsed
                          ? NeoBrutalButton(
                              label: context.tr('office_grant_used_btn'),
                              icon: Icons.check_rounded,
                              backgroundColor: const Color(0xFF222838),
                              textColor: const Color(0xFF64748B),
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: null,
                            )
                          : NeoBrutalButton(
                              label: context.tr('office_grant_open_btn', {'amount': CurrencyFormatter.formatShort(outcome.moneyAmount)}),
                              icon: Icons.play_circle_filled_rounded,
                              backgroundColor: const Color(0xFFEAB308),
                              textColor: Colors.black,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                AdService.instance.showRewardedAdWithFallback(
                                  context: context,
                                  customRewardTitle: outcome.title,
                                  outcome: outcome,
                                  onRewardEarned: () {
                                    ref.read(gameProvider.notifier).claimOfficeAdGrant(outcome.moneyAmount);
                                    NotificationService.showSuccess(
                                      context,
                                      '${dailyGrant.callerName} Desteği Alındı! Kasaya +${CurrencyFormatter.format(outcome.moneyAmount)} Eklendi!',
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Card B: Dynamic Smart Hook tailored to player deficiency
          Builder(
            builder: (context) {
              final isHookUsed = game.isSmartHookClaimedToday;

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF161A26) : const Color(0xFFF0FDF4),
                borderColor: isHookUsed ? const Color(0xFF475569) : smartHook.accentColor,
                borderWidth: 2.4,
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalBadge(
                          text: context.tr('office_dynamic_opportunity'),
                          backgroundColor: isHookUsed ? const Color(0xFF475569) : smartHook.accentColor,
                          textColor: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                        if (isHookUsed)
                          NeoBrutalBadge(
                            text: context.tr('office_used_badge'),
                            icon: Icons.check_circle_outline_rounded,
                            backgroundColor: const Color(0xFF334155),
                            textColor: const Color(0xFF94A3B8),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          )
                        else
                          NeoBrutalBadge(
                            text: smartHook.rewardBadgeText,
                            backgroundColor: isDark ? const Color(0xFF232B3E) : Colors.white,
                            textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                            borderColor: smartHook.accentColor,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF22293A) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isHookUsed ? const Color(0xFF475569) : smartHook.accentColor,
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AvatarIconWidget(
                            avatar: smartHook.characterAvatar,
                            color: isHookUsed ? const Color(0xFF64748B) : smartHook.accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    smartHook.title,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isHookUsed
                                          ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${smartHook.callerName} • ${smartHook.callerRole}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isHookUsed ? const Color(0xFF64748B) : smartHook.accentColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isHookUsed
                                    ? '"Bugünkü fırsatı değerlendirdin. Sanayide yeni bir haber çıktığında sana ilk ben haber vereceğim!"'
                                    : smartHook.storyDialogue,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Ödül: ${smartHook.rewardDescription}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: isHookUsed
                          ? NeoBrutalButton(
                              label: context.tr('office_hook_used_btn'),
                              icon: Icons.check_rounded,
                              backgroundColor: const Color(0xFF222838),
                              textColor: const Color(0xFF64748B),
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: null,
                            )
                          : NeoBrutalButton(
                              label: smartHook.actionButtonLabel,
                              icon: Icons.play_circle_filled_rounded,
                              backgroundColor: smartHook.accentColor,
                              textColor: Colors.white,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              onPressed: () {
                                HapticFeedback.heavyImpact();
                                AdService.instance.showRewardedAdWithFallback(
                                  context: context,
                                  customRewardTitle: smartHook.rewardBadgeText,
                                  onRewardEarned: () {
                                    ref.read(gameProvider.notifier).executeSmartOfficeHook(smartHook.type);
                                    NotificationService.showSuccess(
                                      context,
                                      '${smartHook.title}: ${smartHook.rewardBadgeText} Başarıyla Uygulandı!',
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Card C: Esnaf Dedikoduları & Piyasa Fısıltıları
          Builder(
            builder: (context) {
              final gossipList = SmartOfficeHookEngine.getOfficeGossipAndTips(game);

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor: isDark ? const Color(0xFF141824) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A),
                borderWidth: 2.2,
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        NeoBrutalBadge(
                          text: context.tr('whispers_title'),
                          backgroundColor: const Color(0xFF38BDF8),
                          textColor: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                        Text(
                          context.tr('whispers_day', {'day': '${game.currentDay}'}),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...gossipList.map((gossip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2433) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF2A3347) : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  gossip.icon,
                                  color: const Color(0xFF38BDF8),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          gossip.sourceName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          gossip.title,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF38BDF8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      gossip.content,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
                                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // 4. Management Sections Header
          Text(
            context.tr('office_management_ops'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 8),

          // Staff Management
          _buildOfficeItem(
            context: context,
            icon: Icons.people_alt_rounded,
            color: const Color(0xFFA855F7),
            title: context.tr('staff_title'),
            subtitle: game.isFeatureUnlocked('/staff')
                ? context.tr('staff_desc', {'count': '${game.hiredStaff.length}'})
                : context.tr('office_locked_branch', {'branch': DealershipModel.getRequiredBranchName('/staff')}),
            actionLabel: game.isFeatureUnlocked('/staff') ? context.tr('office_btn_manage') : context.tr('office_btn_locked'),
            route: '/staff',
            isUnlocked: game.isFeatureUnlocked('/staff'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Customer Reviews
          _buildOfficeItem(
            context: context,
            icon: Icons.chat_bubble_rounded,
            color: const Color(0xFFFFDE59),
            title: context.tr('reviews_title'),
            subtitle: game.isFeatureUnlocked('/reviews')
                ? context.tr('reviews_desc', {'count': '${game.customerReviews.length}'})
                : context.tr('office_locked_branch', {'branch': DealershipModel.getRequiredBranchName('/reviews')}),
            actionLabel: game.isFeatureUnlocked('/reviews') ? context.tr('office_btn_inspect') : context.tr('office_btn_locked'),
            route: '/reviews',
            isUnlocked: game.isFeatureUnlocked('/reviews'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Sales History
          _buildOfficeItem(
            context: context,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF3B82F6),
            title: context.tr('sales_history_title'),
            subtitle: game.isFeatureUnlocked('/history')
                ? context.tr('sales_history_desc', {'count': '${game.salesHistory.length}'})
                : context.tr('office_locked_branch', {'branch': DealershipModel.getRequiredBranchName('/history')}),
            actionLabel: game.isFeatureUnlocked('/history') ? context.tr('office_btn_view') : context.tr('office_btn_locked'),
            route: '/history',
            isUnlocked: game.isFeatureUnlocked('/history'),
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Special License Plates (Emniyet & Noter Tescil)
          _buildOfficeItem(
            context: context,
            icon: Icons.confirmation_number_rounded,
            color: const Color(0xFFFFDE59),
            title: context.tr('special_plates_title'),
            subtitle: context.tr('special_plates_desc'),
            actionLabel: context.tr('office_btn_register'),
            route: '/special-plates',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Media & Influencer PR Agency Desk
          _buildOfficeItem(
            context: context,
            icon: Icons.campaign_rounded,
            color: const Color(0xFF38BDF8),
            title: context.tr('media_pr_title'),
            subtitle: game.activePrCampaign != null && game.activePrCampaign!.isActive(game.currentDay)
                ? context.tr('media_campaign_running', {'days': '${game.activePrCampaign!.remainingDays(game.currentDay)}'})
                : context.tr('media_pr_desc'),
            actionLabel: context.tr('office_btn_launch'),
            route: '/media-agency',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Lifestyle & Wardrobe Desk
          _buildOfficeItem(
            context: context,
            icon: Icons.dry_cleaning_rounded,
            color: const Color(0xFFEAB308),
            title: context.tr('lifestyle_title'),
            subtitle: context.tr('lifestyle_desc'),
            actionLabel: context.tr('office_btn_wardrobe'),
            route: '/lifestyle',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Character Growth
          _buildOfficeItem(
            context: context,
            icon: Icons.bolt_rounded,
            color: const Color(0xFF00E575),
            title: context.tr('talent_tree_title'),
            subtitle: context.tr('talent_tree_desc', {'level': '${game.level}'}),
            actionLabel: context.tr('office_btn_upgrade'),
            route: '/character-growth',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Theme Store
          _buildOfficeItem(
            context: context,
            icon: Icons.palette_rounded,
            color: const Color(0xFFFF54B0),
            title: context.tr('theme_store_title'),
            subtitle: context.tr('theme_store_desc'),
            actionLabel: context.tr('office_btn_store'),
            route: '/theme-store',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // Collection Album
          _buildOfficeItem(
            context: context,
            icon: Icons.auto_stories_rounded,
            color: const Color(0xFF38BDF8),
            title: context.tr('album_appbar_title'),
            subtitle: context.tr('album_subtitle_desc'),
            actionLabel: context.tr('office_btn_view'),
            route: '/album',
            isUnlocked: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeItem({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String actionLabel,
    required String route,
    required bool isUnlocked,
    required bool isDark,
  }) {
    final activeColor = isUnlocked ? color : const Color(0xFF64748B);

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isUnlocked
          ? (isDark ? const Color(0xFF141721) : Colors.white)
          : (isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0)),
      borderColor: isUnlocked
          ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
          : (isDark ? const Color(0xFF202636) : const Color(0xFF94A3B8)),
      borderRadius: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Icon(
                    isUnlocked ? icon : Icons.lock_outline_rounded,
                    size: 20,
                    color: isUnlocked ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked
                              ? (isDark ? Colors.white : const Color(0xFF0F172A))
                              : (isDark ? Colors.white60 : const Color(0xFF475569)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isUnlocked
                              ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))
                              : (isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
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
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: actionLabel,
            backgroundColor: activeColor,
            textColor: isUnlocked ? Colors.black : Colors.white,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            onPressed: () {
              if (isUnlocked) {
                context.push(route);
              } else {
                NotificationService.showInfo(
                  context,
                  'Kilitli Alan! Bu özellik ${DealershipModel.getRequiredBranchName(route)} satın alındığında açılır. Şubeler ekranından inceleyebilirsin.',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
