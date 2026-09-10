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
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import '../../leaderboard/widgets/leaderboard_season_reward_dialog.dart';
import 'dashboard_quick_finance_card.dart';

extension SmartHookModelUiExtension on SmartHookModel {
  Color get accentColor => Color(accentColorValue);
}

IconData _getGossipIcon(String iconKey) {
  switch (iconKey) {
    case 'trending_up':
      return Icons.trending_up_rounded;
    case 'verified':
      return Icons.verified_rounded;
    case 'auto_awesome':
      return Icons.auto_awesome_rounded;
    case 'security':
      return Icons.security_rounded;
    case 'account_balance':
      return Icons.account_balance_rounded;
    case 'build_circle':
      return Icons.build_circle_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

class DashboardOfficeView extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;
  final EdgeInsetsGeometry? padding;

  const DashboardOfficeView({
    super.key,
    required this.game,
    required this.palette,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;
    final smartHook = SmartOfficeHookEngine.evaluate(game);

    return ListView(
      padding: padding ?? const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
          // 1. Reputation Block
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
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
                  child: const Icon(Icons.star_rounded,
                      color: Colors.black, size: 24),
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
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('office_reputation_desc',
                            {'score': '${game.reputationScore}'}),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 1.5. Podium Trophy & Season Glory Showcase
          _buildOfficeTrophySection(context, isDark),
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
              final dailyGrant =
                  SmartOfficeHookEngine.getDailyGrantVariant(game);
              final isGrantUsed = game.isOfficeGrantClaimedToday;
              final garageTotal = game.ownedCars
                  .fold<double>(0.0, (sum, c) => sum + c.baseMarketValue);
              final outcome = AdRewardCalculator.calculateDynamicReward(
                playerLevel: game.level,
                totalGarageValue: garageTotal,
                playerBalance: game.balance,
              );

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF191D2B) : const Color(0xFFFEFCE8),
                borderColor: isGrantUsed
                    ? const Color(0xFF475569)
                    : const Color(0xFFEAB308),
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
                          backgroundColor: isGrantUsed
                              ? const Color(0xFF475569)
                              : const Color(0xFFEAB308),
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
                            text:
                                '+${CurrencyFormatter.formatShort(outcome.moneyAmount)} HİBE',
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
                            color: isDark
                                ? const Color(0xFF242A3D)
                                : const Color(0xFFFEF08A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isGrantUsed
                                  ? const Color(0xFF475569)
                                  : (isDark
                                      ? const Color(0xFFEAB308)
                                      : const Color(0xFF0F172A)),
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AvatarIconWidget(
                            avatar: 'deal',
                            color: isGrantUsed
                                ? const Color(0xFF64748B)
                                : const Color(0xFFEAB308),
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
                                      ? (isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF64748B))
                                      : (isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dailyGrant.callerRole,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isGrantUsed
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFFEAB308),
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
                              label: context.tr('office_grant_open_btn', {
                                'amount': CurrencyFormatter.formatShort(
                                    outcome.moneyAmount)
                              }),
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
                                    ref
                                        .read(gameProvider.notifier)
                                        .claimOfficeAdGrant(
                                            outcome.moneyAmount);
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
                backgroundColor:
                    isDark ? const Color(0xFF161A26) : const Color(0xFFF0FDF4),
                borderColor: isHookUsed
                    ? const Color(0xFF475569)
                    : smartHook.accentColor,
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
                          backgroundColor: isHookUsed
                              ? const Color(0xFF475569)
                              : smartHook.accentColor,
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
                            backgroundColor:
                                isDark ? const Color(0xFF232B3E) : Colors.white,
                            textColor:
                                isDark ? Colors.white : const Color(0xFF0F172A),
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
                            color: isDark
                                ? const Color(0xFF22293A)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isHookUsed
                                  ? const Color(0xFF475569)
                                  : smartHook.accentColor,
                              width: 2.0,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: AvatarIconWidget(
                            avatar: smartHook.characterAvatar,
                            color: isHookUsed
                                ? const Color(0xFF64748B)
                                : smartHook.accentColor,
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
                                          ? (isDark
                                              ? const Color(0xFF94A3B8)
                                              : const Color(0xFF64748B))
                                          : (isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A)),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${smartHook.callerName} • ${smartHook.callerRole}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: isHookUsed
                                      ? const Color(0xFF64748B)
                                      : smartHook.accentColor,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isHookUsed
                                    ? '"${context.tr('office_hook_used_dialogue')}"'
                                    : smartHook.storyDialogue,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: isDark
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                context.tr('office_reward_prefix',
                                    {'reward': smartHook.rewardDescription}),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF334155),
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
                                    ref
                                        .read(gameProvider.notifier)
                                        .executeSmartOfficeHook(smartHook.type);
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
              final gossipList =
                  SmartOfficeHookEngine.getOfficeGossipAndTips(game);

              return NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141824) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A344A) : const Color(0xFF0F172A),
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
                        Expanded(
                            child: Text(
                          context.tr(
                              'whispers_day', {'day': '${game.currentDay}'}),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...gossipList.map((gossip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2433)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2E384D)
                                  : const Color(0xFFE2E8F0),
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
                                  color: isDark
                                      ? const Color(0xFF2A3347)
                                      : const Color(0xFFE0F2FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _getGossipIcon(gossip.iconKey),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: Text(
                                          gossip.sourceName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF0F172A),
                                          ),
                                        )),
                                        Expanded(
                                            child: Text(
                                          gossip.title,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF38BDF8),
                                          ),
                                        )),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      gossip.content,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontStyle: FontStyle.italic,
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
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // 4. Categorized Neo-Brutalist Management & Expansion Hubs
          // Hub 1: Galeri & Ticaret
          _buildCategoryHeader(
            context: context,
            title: context.tr('office_category_gallery'),
            subtitle: context.tr('office_cat_gallery_sub'),
            color: const Color(0xFFFFDE59),
            icon: Icons.storefront_rounded,
            isDark: isDark,
            counterBadge: context.tr('telemetry_cars_count', {'count': '${game.ownedCars.length}'}),
          ),
          _buildOfficeItem(
            context: context,
            icon: Icons.directions_car_rounded,
            color: const Color(0xFFFFDE59),
            title: context.tr('service_showroom'),
            subtitle: context.tr('service_showroom_sub'),
            telemetryBadge: context.tr('telemetry_cars_count', {'count': '${game.ownedCars.length}'}),
            actionLabel: context.tr('office_btn_view'),
            route: '/showroom',
            isUnlocked: game.isFeatureUnlocked('/showroom'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.storefront_rounded,
            color: const Color(0xFF38BDF8),
            title: context.tr('service_buy_car'),
            subtitle: context.tr('service_buy_car_sub'),
            actionLabel: context.tr('office_btn_inspect'),
            route: '/marketplace',
            isUnlocked: game.isFeatureUnlocked('/marketplace'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.local_car_wash_rounded,
            color: const Color(0xFF00F0FF),
            title: context.tr('service_car_wash'),
            subtitle: context.tr('service_car_wash_sub'),
            telemetryBadge: game.ownedCars.where((c) => !c.isWashed).isNotEmpty
                ? context.tr('telemetry_dirty_count', {'count': '${game.ownedCars.where((c) => !c.isWashed).length}'})
                : null,
            actionLabel: game.isFeatureUnlocked('/car-wash')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/car-wash',
            isUnlocked: game.isFeatureUnlocked('/car-wash'),
            isDark: isDark,
          ),

          // Hub 2: Atölye & Teknik Servis
          _buildCategoryHeader(
            context: context,
            title: context.tr('office_category_workshop'),
            subtitle: context.tr('office_cat_workshop_sub'),
            color: const Color(0xFFFF7A00),
            icon: Icons.build_circle_rounded,
            isDark: isDark,
            counterBadge: game.pendingOrders.isNotEmpty
                ? '${game.pendingOrders.length}'
                : null,
          ),
          _buildOfficeItem(
            context: context,
            icon: Icons.build_circle_rounded,
            color: const Color(0xFFFF7A00),
            title: context.tr('service_workshop'),
            subtitle: context.tr('service_workshop_sub'),
            telemetryBadge: game.pendingOrders.isNotEmpty
                ? '${game.pendingOrders.length}'
                : null,
            actionLabel: game.isFeatureUnlocked('/workshop')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/workshop',
            isUnlocked: game.isFeatureUnlocked('/workshop'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.speed_rounded,
            color: const Color(0xFFA855F7),
            title: context.tr('service_tuning'),
            subtitle: context.tr('service_tuning_sub'),
            actionLabel: game.isFeatureUnlocked('/tuning-studio')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/tuning-studio',
            isUnlocked: game.isFeatureUnlocked('/tuning-studio'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.delete_outline_rounded,
            color: const Color(0xFF64748B),
            title: context.tr('service_scrapyard'),
            subtitle: context.tr('service_scrapyard_sub'),
            telemetryBadge: game.salvagedParts.isNotEmpty
                ? context.tr('telemetry_parts_count', {'count': '${game.salvagedParts.length}'})
                : null,
            actionLabel: game.isFeatureUnlocked('/scrapyard')
                ? context.tr('office_btn_view')
                : context.tr('office_btn_locked'),
            route: '/scrapyard',
            isUnlocked: game.isFeatureUnlocked('/scrapyard'),
            isDark: isDark,
          ),

          // Hub 3: Finans & Yatırım
          _buildCategoryHeader(
            context: context,
            title: context.tr('office_category_finance'),
            subtitle: context.tr('office_cat_finance_sub'),
            color: const Color(0xFF00E575),
            icon: Icons.account_balance_rounded,
            isDark: isDark,
            counterBadge: game.activeLoans.isNotEmpty
                ? context.tr('telemetry_active_loans', {'count': '${game.activeLoans.length}'})
                : null,
          ),
          _buildOfficeItem(
            context: context,
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF00E575),
            title: context.tr('service_finance'),
            subtitle: context.tr('service_finance_sub'),
            telemetryBadge: game.activeLoans.isNotEmpty
                ? '${game.activeLoans.length}'
                : null,
            actionLabel: game.isFeatureUnlocked('/finance')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/finance',
            isUnlocked: game.isFeatureUnlocked('/finance'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF6366F1),
            title: context.tr('service_stocks'),
            subtitle: context.tr('service_stocks_sub'),
            telemetryBadge: game.ownedStocks.isNotEmpty
                ? '${game.ownedStocks.length}'
                : null,
            actionLabel: game.isFeatureUnlocked('/stock-market')
                ? context.tr('office_btn_view')
                : context.tr('office_btn_locked'),
            route: '/stock-market',
            isUnlocked: game.isFeatureUnlocked('/stock-market'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.gavel_rounded,
            color: const Color(0xFFEF4444),
            title: context.tr('service_auction'),
            subtitle: context.tr('service_auction_sub'),
            actionLabel: game.isFeatureUnlocked('/auction')
                ? context.tr('office_btn_inspect')
                : context.tr('office_btn_locked'),
            route: '/auction',
            isUnlocked: game.isFeatureUnlocked('/auction'),
            isDark: isDark,
          ),

          // Hub 4: Yönetim & Operasyon
          _buildCategoryHeader(
            context: context,
            title: context.tr('office_category_operations'),
            subtitle: context.tr('office_cat_operations_sub'),
            color: const Color(0xFFA855F7),
            icon: Icons.badge_rounded,
            isDark: isDark,
            counterBadge: context.tr('telemetry_staff_count', {'count': '${game.hiredStaff.length}'}),
          ),
          _buildOfficeItem(
            context: context,
            icon: Icons.people_alt_rounded,
            color: const Color(0xFFA855F7),
            title: context.tr('staff_title'),
            subtitle: game.isFeatureUnlocked('/staff')
                ? context.tr('staff_desc', {'count': '${game.hiredStaff.length}'})
                : context.tr('office_locked_branch', {
                    'branch': DealershipModel.getRequiredBranchName('/staff', context)
                  }),
            telemetryBadge: '${game.hiredStaff.length}',
            actionLabel: game.isFeatureUnlocked('/staff')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/staff',
            isUnlocked: game.isFeatureUnlocked('/staff'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.receipt_long_rounded,
            color: const Color(0xFF3B82F6),
            title: context.tr('sales_history_title'),
            subtitle: game.isFeatureUnlocked('/history')
                ? context.tr('sales_history_desc', {'count': '${game.salesHistory.length}'})
                : context.tr('office_locked_branch', {
                    'branch': DealershipModel.getRequiredBranchName('/history', context)
                  }),
            telemetryBadge: '${game.salesHistory.length}',
            actionLabel: game.isFeatureUnlocked('/history')
                ? context.tr('office_btn_view')
                : context.tr('office_btn_locked'),
            route: '/history',
            isUnlocked: game.isFeatureUnlocked('/history'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.chat_bubble_rounded,
            color: const Color(0xFFFFDE59),
            title: context.tr('reviews_title'),
            subtitle: game.isFeatureUnlocked('/reviews')
                ? context.tr('reviews_desc', {'count': '${game.customerReviews.length}'})
                : context.tr('office_locked_branch', {
                    'branch': DealershipModel.getRequiredBranchName('/reviews', context)
                  }),
            telemetryBadge: '${game.reputationScore} XP',
            actionLabel: game.isFeatureUnlocked('/reviews')
                ? context.tr('office_btn_inspect')
                : context.tr('office_btn_locked'),
            route: '/reviews',
            isUnlocked: game.isFeatureUnlocked('/reviews'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.campaign_rounded,
            color: const Color(0xFF38BDF8),
            title: context.tr('media_pr_title'),
            subtitle: game.activePrCampaign != null &&
                    game.activePrCampaign!.isActive(game.currentDay)
                ? context.tr('media_campaign_running', {
                    'days': '${game.activePrCampaign!.remainingDays(game.currentDay)}'
                  })
                : context.tr('media_pr_desc'),
            actionLabel: context.tr('office_btn_launch'),
            route: '/media-agency',
            isUnlocked: true,
            isDark: isDark,
          ),

          // Hub 5: Genişleme & Şebeke
          _buildCategoryHeader(
            context: context,
            title: context.tr('office_category_expansion'),
            subtitle: context.tr('office_cat_expansion_sub'),
            color: const Color(0xFF00E5FF),
            icon: Icons.hub_rounded,
            isDark: isDark,
            counterBadge: '${context.tr('level_prefix')} ${game.currentBranchTier}',
          ),
          _buildOfficeItem(
            context: context,
            icon: Icons.apartment_rounded,
            color: const Color(0xFF8B5CF6),
            title: context.tr('service_branches'),
            subtitle: context.tr('service_branches_sub'),
            telemetryBadge: '${context.tr('level_prefix')} ${game.currentBranchTier}',
            actionLabel: game.isFeatureUnlocked('/branches')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/branches',
            isUnlocked: game.isFeatureUnlocked('/branches'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.domain_rounded,
            color: const Color(0xFF10B981),
            title: context.tr('service_real_estate'),
            subtitle: context.tr('service_real_estate_sub'),
            telemetryBadge: '${game.ownedRealEstates.length}',
            actionLabel: game.isFeatureUnlocked('/emlak')
                ? context.tr('office_btn_view')
                : context.tr('office_btn_locked'),
            route: '/emlak',
            isUnlocked: game.isFeatureUnlocked('/emlak'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.directions_boat_filled_rounded,
            color: const Color(0xFF06B6D4),
            title: context.tr('service_vasita_market'),
            subtitle: context.tr('service_vasita_market_sub'),
            actionLabel: game.isFeatureUnlocked('/vasita')
                ? context.tr('office_btn_inspect')
                : context.tr('office_btn_locked'),
            route: '/vasita',
            isUnlocked: game.isFeatureUnlocked('/vasita'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.car_rental_rounded,
            color: const Color(0xFF38BDF8),
            title: context.tr('service_rent_car'),
            subtitle: context.tr('service_rent_car_sub'),
            telemetryBadge: context.tr('telemetry_fleet_count', {'count': '${game.ownedCars.where((c) => c.isRented).length}'}),
            actionLabel: game.isFeatureUnlocked('/rent-a-car')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/rent-a-car',
            isUnlocked: game.isFeatureUnlocked('/rent-a-car'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.business_center_rounded,
            color: const Color(0xFF10B981),
            title: context.tr('service_side_biz'),
            subtitle: context.tr('service_side_biz_sub'),
            telemetryBadge: '${game.sideBusinesses.where((b) => b.isOwned).length}',
            actionLabel: game.isFeatureUnlocked('/side-businesses')
                ? context.tr('office_btn_manage')
                : context.tr('office_btn_locked'),
            route: '/side-businesses',
            isUnlocked: game.isFeatureUnlocked('/side-businesses'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.map_rounded,
            color: const Color(0xFF38BDF8),
            title: context.tr('service_district'),
            subtitle: context.tr('service_district_sub'),
            actionLabel: game.isFeatureUnlocked('/districts')
                ? context.tr('office_btn_inspect')
                : context.tr('office_btn_locked'),
            route: '/districts',
            isUnlocked: game.isFeatureUnlocked('/districts'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.handshake_rounded,
            color: const Color(0xFF00E575),
            title: context.tr('service_consignment'),
            subtitle: context.tr('service_consignment_sub'),
            telemetryBadge: '${game.consignmentOffers.length}',
            actionLabel: game.isFeatureUnlocked('/consignment')
                ? context.tr('office_btn_view')
                : context.tr('office_btn_locked'),
            route: '/consignment',
            isUnlocked: game.isFeatureUnlocked('/consignment'),
            isDark: isDark,
          ),

          // Hub 6: Özel & Prestij
          _buildCategoryHeader(
            context: context,
            title: context.tr('office_category_lifestyle'),
            subtitle: context.tr('office_cat_lifestyle_sub'),
            color: const Color(0xFFFF54B0),
            icon: Icons.diamond_rounded,
            isDark: isDark,
          ),
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
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final personalResidence = game.ownedRealEstates
                  .where((p) => p.isPersonalResidence)
                  .firstOrNull;
              final isUnlocked = personalResidence != null;

              return _buildOfficeItem(
                context: context,
                icon: Icons.chair_rounded,
                color: const Color(0xFFF59E0B),
                title: context.tr('home_interior_office_title'),
                subtitle: isUnlocked
                    ? context.tr('home_interior_office_desc_unlocked')
                    : context.tr('home_interior_office_desc_locked'),
                telemetryBadge: isUnlocked ? context.tr('home_interior_office_title') : null,
                actionLabel: isUnlocked
                    ? context.tr('office_btn_manage')
                    : context.tr('office_btn_locked'),
                route: isUnlocked
                    ? '/emlak-ev-dizayn/${personalResidence.id}'
                    : '',
                isUnlocked: isUnlocked,
                isDark: isDark,
                lockedToast: context.tr('home_interior_office_desc_locked'),
              );
            },
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.bolt_rounded,
            color: const Color(0xFF00E575),
            title: context.tr('talent_tree_title'),
            subtitle: context.tr('talent_tree_desc', {'level': '${game.level}'}),
            telemetryBadge: '${game.level}',
            actionLabel: context.tr('office_btn_upgrade'),
            route: '/character-growth',
            isUnlocked: true,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
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
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.casino_rounded,
            color: const Color(0xFFFFDE59),
            title: context.tr('service_casino'),
            subtitle: context.tr('service_casino_sub'),
            telemetryBadge: 'VIP',
            actionLabel: game.isFeatureUnlocked('/casino')
                ? context.tr('office_btn_view')
                : context.tr('office_btn_locked'),
            route: '/casino',
            isUnlocked: game.isFeatureUnlocked('/casino'),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildOfficeItem(
            context: context,
            icon: Icons.sports_score_rounded,
            color: const Color(0xFFF43F5E),
            title: context.tr('service_night_market'),
            subtitle: context.tr('service_night_market_sub'),
            actionLabel: context.tr('office_btn_view'),
            route: '/night-market',
            isUnlocked: true,
            isDark: isDark,
          ),
        ],
      );
  }

  Widget _buildCategoryHeader({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required bool isDark,
    String? counterBadge,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: NeoBrutalCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor:
            isDark ? const Color(0xFF181C28) : const Color(0xFFF8FAFC),
        borderColor: isDark ? const Color(0xFF2E384D) : const Color(0xFF0F172A),
        borderWidth: 2.2,
        borderRadius: 10,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? Colors.black45 : const Color(0xFF0F172A),
                  width: 1.8,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 16, color: Colors.black),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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
            if (counterBadge != null) ...[
              const SizedBox(width: 8),
              NeoBrutalBadge(
                text: counterBadge,
                backgroundColor: color,
                textColor: Colors.black,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              ),
            ],
          ],
        ),
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
    String? telemetryBadge,
    String? lockedToast,
  }) {
    final activeColor = isUnlocked ? color : const Color(0xFF64748B);

    return NeoBrutalCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: isUnlocked
          ? (isDark ? const Color(0xFF141721) : Colors.white)
          : (isDark ? const Color(0xFF0F1118) : const Color(0xFFE2E8F0)),
      borderColor: isUnlocked
          ? (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A))
          : (isDark ? const Color(0xFF202636) : const Color(0xFF94A3B8)),
      borderRadius: 12,
      onTap: () {
        if (isUnlocked) {
          context.push(route);
        } else {
          NotificationService.showInfo(
            context,
            lockedToast ??
                context.tr('cashflow_locked_feature_toast', {
                  'branch': DealershipModel.getRequiredBranchName(route, context)
                }),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: activeColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              isUnlocked ? icon : Icons.lock_outline_rounded,
              size: 20,
              color: isUnlocked ? Colors.black : Colors.white,
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
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: isUnlocked
                              ? (isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A))
                              : (isDark
                                  ? Colors.white60
                                  : const Color(0xFF475569)),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (telemetryBadge != null && isUnlocked) ...[
                      const SizedBox(width: 6),
                      NeoBrutalBadge(
                        text: telemetryBadge,
                        backgroundColor: isDark
                            ? activeColor.withValues(alpha: 0.25)
                            : activeColor.withValues(alpha: 0.3),
                        textColor:
                            isDark ? activeColor : const Color(0xFF0F172A),
                        borderColor: activeColor,
                        fontSize: 9.0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1.5),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isUnlocked
                        ? (isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF64748B))
                        : (isDark
                            ? const Color(0xFFF87171)
                            : const Color(0xFFDC2626)),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: actionLabel,
            backgroundColor: activeColor,
            textColor: isUnlocked ? Colors.black : Colors.white,
            fontSize: 10.5,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: () {
              if (isUnlocked) {
                context.push(route);
              } else {
                NotificationService.showInfo(
                  context,
                  lockedToast ??
                      context.tr('cashflow_locked_feature_toast', {
                        'branch': DealershipModel.getRequiredBranchName(
                            route, context)
                      }),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfficeTrophySection(BuildContext context, bool isDark) {
    final bool hasUnclaimed = game.hasUnclaimedSeasonRewards;
    final borderColor = isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A);
    final hasTrophies = game.earnedTrophies.isNotEmpty;
    final latestTrophy = hasTrophies ? game.earnedTrophies.last : null;
    final activePerks = game.activePodiumPerks;

    Color trophyColor;
    String trophyTitle;
    IconData trophyIcon;

    if (latestTrophy != null) {
      if (latestTrophy.rank == 1) {
        trophyColor = const Color(0xFFFFD700);
        trophyTitle = context.tr('podium_trophy_gold');
        trophyIcon = Icons.workspace_premium_rounded;
      } else if (latestTrophy.rank == 2) {
        trophyColor = const Color(0xFFE2E8F0);
        trophyTitle = context.tr('podium_trophy_silver');
        trophyIcon = Icons.shield_rounded;
      } else {
        trophyColor = const Color(0xFFCD7F32);
        trophyTitle = context.tr('podium_trophy_bronze');
        trophyIcon = Icons.handshake_rounded;
      }
    } else {
      trophyColor = hasUnclaimed ? const Color(0xFFFFD700) : const Color(0xFF94A3B8);
      trophyTitle = context.tr('office_trophy_empty_pedestal');
      trophyIcon = Icons.military_tech_outlined;
    }

    return InkWell(
      onTap: () {
        if (hasUnclaimed) {
          LeaderboardSeasonRewardDialog.show(
            context,
            game: game,
            isDark: isDark,
          );
        } else {
          context.push('/leaderboard');
        }
      },
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF161B28) : Colors.white,
        borderColor: hasUnclaimed ? const Color(0xFFEF4444) : (hasTrophies ? trophyColor : borderColor),
        borderWidth: (hasTrophies || hasUnclaimed) ? 2.4 : 2.0,
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (hasUnclaimed ? const Color(0xFFEF4444) : trophyColor).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasUnclaimed ? const Color(0xFFEF4444) : (hasTrophies ? trophyColor : borderColor),
                  width: 2.0,
                ),
              ),
              alignment: Alignment.center,
              child: Icon(
                trophyIcon,
                color: hasUnclaimed
                    ? const Color(0xFFEF4444)
                    : (hasTrophies ? trophyColor : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                size: 26,
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
                        trophyTitle,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      if (hasUnclaimed) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: context.tr('podium_unclaimed_alert'),
                          backgroundColor: const Color(0xFFEF4444),
                          textColor: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ] else if (hasTrophies) ...[
                        const SizedBox(width: 6),
                        NeoBrutalBadge(
                          text: 'SEZON ${latestTrophy?.seasonId ?? ""}',
                          backgroundColor: trophyColor,
                          textColor: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hasUnclaimed
                        ? context.tr('podium_dialog_congrats_desc')
                        : (hasTrophies
                            ? (activePerks?.isActive == true
                                ? '${context.tr('office_active_perk_prefix')}: ${activePerks?.customPlateTitle ?? 'VIP Noter İndirimi'}'
                                : context.tr('office_trophy_cabinet_desc'))
                            : context.tr('office_trophy_empty_desc')),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
