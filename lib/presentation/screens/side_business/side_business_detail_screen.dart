import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/side_business_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/dialogs/generic_rush_job_dialog.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

/// Dedicated sub-page screen for side business details, upgrades, and ROI tracking.
class SideBusinessDetailScreen extends ConsumerWidget {
  final String businessId;

  const SideBusinessDetailScreen({
    super.key,
    required this.businessId,
  });

  IconData _getUpgradeIconData(String iconName) {
    switch (iconName) {
      case 'coffee':
        return Icons.coffee_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'precision_manufacturing':
        return Icons.precision_manufacturing_rounded;
      case 'clean_hands':
        return Icons.clean_hands_rounded;
      case 'tv':
        return Icons.tv_rounded;
      case 'wb_incandescent':
        return Icons.wb_incandescent_rounded;
      case 'handshake':
        return Icons.handshake_rounded;
      case 'minor_crash':
        return Icons.minor_crash_rounded;
      case 'emergency':
        return Icons.emergency_rounded;
      case 'fire_truck':
        return Icons.fire_truck_rounded;
      case 'sanitizer':
        return Icons.sanitizer_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'tire_repair':
        return Icons.tire_repair_rounded;
      case 'local_shipping':
        return Icons.local_shipping_rounded;
      case 'build_circle':
        return Icons.build_circle_rounded;
      case 'memory':
        return Icons.memory_rounded;
      case 'center_focus_strong':
        return Icons.center_focus_strong_rounded;
      case 'flight_land':
        return Icons.flight_land_rounded;
      case 'airline_seat_recline_extra':
        return Icons.airline_seat_recline_extra_rounded;
      case 'business_center':
        return Icons.business_center_rounded;
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'electric_car':
        return Icons.electric_car_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'solar_power':
        return Icons.solar_power_rounded;
      case 'battery_charging_full':
        return Icons.battery_charging_full_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'alt_route':
        return Icons.alt_route_rounded;
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    final businessIndex =
        game.sideBusinesses.indexWhere((b) => b.id == businessId);

    if (businessIndex == -1) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'İşletme Detayı'),
        body: const Center(
          child: Text(
            'İşletme bulunamadı',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final business = game.sideBusinesses[businessIndex];
    final nextLevelCost = business.nextLevelUpgradeCost;
    final isMaxLevel = business.level >= 5;
    final canAffordLevelUpgrade =
        game.balance >= nextLevelCost && !isMaxLevel && !business.isUpgradingLevel;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: business.type.getLocalizedName(lang),
        subtitle: context.tr('side_biz_sheet_subtitle', {
          'lvl': '${business.level}',
          'modules': '${business.purchasedUpgradeCount}',
          'total': '${business.upgrades.length}'
        }),
        headerAnimation: NeoBrutalHeaderAnimation.cashShimmer,
        statusBadge: NeoBrutalBadge(
          text: context.tr('side_biz_level_badge', {'lvl': '${business.level}'}),
          backgroundColor: AppColors.brutalGreen,
          textColor: Colors.black,
          fontSize: 10.5,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Construction State Banner
          if (business.isUnderConstruction) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor:
                  isDark ? const Color(0xFF1E1E14) : const Color(0xFFFEFCE8),
              borderColor: AppColors.brutalYellow,
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.brutalYellow,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black, width: 1.5),
                            ),
                            child: const Icon(Icons.construction_rounded,
                                size: 18, color: Colors.black),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.tr('side_biz_badge_construction'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalYellow,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '%${(business.constructionProgress * 100).round()}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2A2A20)
                            : const Color(0xFFE2E8F0),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor:
                            business.constructionProgress.clamp(0.05, 1.0),
                        child: Container(color: AppColors.brutalYellow),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('side_biz_construction_remaining', {
                      'days': '${business.constructionDaysRemaining}'
                    }),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.tr('side_biz_rush_desc'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeoBrutalButton(
                    label: context.tr('side_biz_btn_rush'),
                    icon: Icons.bolt_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 12,
                    fullWidth: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    onPressed: () {
                      GenericRushJobDialog.show(
                        context,
                        titleBadge: context.tr('rush_lore_construction_title'),
                        targetTitle:
                            '${business.type.getLocalizedName(lang)} • ${context.tr('side_biz_status_building')}',
                        targetSubtitle: context.tr('rush_lore_days_remaining', {
                          'days': business.constructionDaysRemaining.toString()
                        }),
                        loreDescription: context.tr('rush_lore_construction_desc'),
                        icon: Icons.apartment_rounded,
                        badgeColor: AppColors.brutalYellow,
                        actionButtonLabel:
                            context.tr('rush_lore_construction_btn'),
                        onRushSuccess: () {
                          final success = ref
                              .read(gameProvider.notifier)
                              .completeSideBusinessConstruction(business.id);
                          if (success) {
                            NotificationService.showSuccess(
                              context,
                              context.tr('side_biz_rush_success'),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // 2. Financial & ROI Amortization Overview Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      context.tr('side_biz_stat_net_profit'),
                      CurrencyFormatter.formatShort(
                          business.effectiveDailyIncome),
                      AppColors.brutalGreen,
                    ),
                    Container(
                      width: 1.5,
                      height: 32,
                      color: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFFE2E8F0),
                    ),
                    _buildStatColumn(
                      context.tr('side_biz_stat_accumulated'),
                      CurrencyFormatter.formatShort(business.totalEarned),
                      AppColors.brutalYellow,
                    ),
                    Container(
                      width: 1.5,
                      height: 32,
                      color: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFFE2E8F0),
                    ),
                    _buildStatColumn(
                      context.tr('side_biz_stat_roi'),
                      context.tr('side_biz_stat_roi_days',
                          {'days': '${business.roiDays}'}),
                      const Color(0xFF06B6D4),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFFE2E8F0),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.tr('side_biz_total_invested'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(business.totalInvested),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.brutalYellow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Günlük Brüt Gelir & Gider:',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '₺${business.grossDailyIncome.round()} - ₺${business.dailyMaintenanceExpense.round()}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Level Upgrade Section with Reactive Disabled State
          Text(
            context.tr('side_biz_capacity_upgrade_title'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: business.isUpgradingLevel
                ? AppColors.brutalYellow
                : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
            borderRadius: 14,
            child: business.isUpgradingLevel
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.brutalYellow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: const Icon(Icons.upgrade_rounded,
                                color: Colors.black, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('side_biz_next_lvl_title',
                                      {'lvl': '${business.pendingTargetLevel}'}),
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  context.tr('side_biz_level_upgrading_badge', {
                                    'days':
                                        '${business.levelUpgradeDaysRemaining}'
                                  }),
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.brutalYellow),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '%${(business.levelUpgradeProgress * 100).round()}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalYellow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF2A2A20)
                                : const Color(0xFFE2E8F0),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: business.levelUpgradeProgress
                                .clamp(0.05, 1.0),
                            child: Container(color: AppColors.brutalYellow),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      NeoBrutalButton(
                        label: context.tr('rush_lore_level_upgrade_btn'),
                        icon: Icons.bolt_rounded,
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 11.5,
                        fullWidth: true,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        onPressed: () {
                          GenericRushJobDialog.show(
                            context,
                            titleBadge:
                                context.tr('rush_lore_level_upgrade_title'),
                            targetTitle:
                                '${business.type.getLocalizedName(lang)} • ${context.tr('side_biz_next_lvl_title', {
                                  'lvl': '${business.pendingTargetLevel}'
                                })}',
                            targetSubtitle:
                                '${business.levelUpgradeDaysRemaining} ${context.tr('rush_lore_days_remaining', {
                                  'days': business.levelUpgradeDaysRemaining.toString()
                                })}',
                            loreDescription:
                                context.tr('rush_lore_level_upgrade_desc'),
                            icon: Icons.upgrade_rounded,
                            badgeColor: AppColors.brutalYellow,
                            actionButtonLabel:
                                context.tr('rush_lore_level_upgrade_btn'),
                            onRushSuccess: () {
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .completeSideBusinessLevelUpgrade(business.id);
                              if (success) {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('side_biz_level_upgrade_success'),
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.brutalYellow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF333B4F)
                                : const Color(0xFF0F172A),
                            width: 2.0,
                          ),
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMaxLevel
                                  ? context.tr('side_biz_max_lvl_title')
                                  : context.tr('side_biz_next_lvl_title',
                                      {'lvl': '${business.level + 1}'}),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isMaxLevel
                                  ? context.tr('side_biz_max_capacity_desc')
                                  : context.tr('side_biz_capacity_boost_desc'),
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      if (isMaxLevel)
                        NeoBrutalBadge(
                          text: context.tr('max_badge'),
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 10,
                        )
                      else
                        NeoBrutalButton(
                          label: context.tr('side_biz_btn_upgrade_level', {
                            'cost': CurrencyFormatter.formatShort(nextLevelCost)
                          }),
                          backgroundColor: canAffordLevelUpgrade
                              ? AppColors.brutalYellow
                              : (isDark
                                  ? const Color(0xFF222938)
                                  : const Color(0xFFE2E8F0)),
                          textColor: canAffordLevelUpgrade
                              ? Colors.black
                              : (isDark ? Colors.white38 : Colors.black38),
                          borderColor: canAffordLevelUpgrade
                              ? Colors.black
                              : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          onPressed: canAffordLevelUpgrade
                              ? () {
                                  final success = ref
                                      .read(gameProvider.notifier)
                                      .upgradeSideBusiness(business.id);
                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      context.tr('side_biz_upgraded_toast', {
                                        'name': business.type
                                            .getLocalizedName(lang),
                                        'lvl': '${business.level + 1}'
                                      }),
                                    );
                                  } else {
                                    NotificationService.showError(
                                      context,
                                      context.tr('insufficient_balance'),
                                    );
                                  }
                                }
                              : null,
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 16),

          // 4. Manager & Automation Section
          Text(
            context.tr('side_biz_manager_section_title'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          NeoBrutalCard(
            padding: const EdgeInsets.all(12),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 12,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(8),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        business.managerTitle,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        business.hasManager
                            ? context.tr('side_biz_manager_assigned', {
                                'salary':
                                    CurrencyFormatter.formatShort(business.managerSalary)
                              })
                            : context.tr('side_biz_manager_hire_desc'),
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                if (business.hasManager)
                  NeoBrutalBadge(
                    text: context.tr('side_biz_badge_managed'),
                    backgroundColor: const Color(0xFF06B6D4),
                    textColor: Colors.black,
                    fontSize: 10,
                  )
                else
                  NeoBrutalButton(
                    label: context.tr('side_biz_btn_hire_manager', {
                      'cost':
                          CurrencyFormatter.formatShort(business.managerCost)
                    }),
                    backgroundColor: (game.balance >= business.managerCost)
                        ? const Color(0xFF06B6D4)
                        : (isDark
                            ? const Color(0xFF222938)
                            : const Color(0xFFE2E8F0)),
                    textColor: (game.balance >= business.managerCost)
                        ? Colors.black
                        : (isDark ? Colors.white38 : Colors.black38),
                    borderColor: (game.balance >= business.managerCost)
                        ? Colors.black
                        : (isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
                    fontSize: 10.5,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    onPressed: (game.balance >= business.managerCost)
                        ? () {
                            final success = ref
                                .read(gameProvider.notifier)
                                .hireSideBusinessManager(business.id);
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                context.tr('side_biz_manager_hired_toast',
                                    {'title': business.managerTitle}),
                              );
                            } else {
                              NotificationService.showError(
                                context,
                                context.tr('insufficient_balance'),
                              );
                            }
                          }
                        : null,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Upgrade Modules Catalog
          if (business.upgrades.isNotEmpty) ...[
            Text(
              context.tr('side_biz_modules_title', {
                'count': '${business.purchasedUpgradeCount}',
                'total': '${business.upgrades.length}'
              }),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            ...business.upgrades.map((upgrade) {
              final isInstalled = upgrade.isOperational;
              final isInstalling = upgrade.isUpgrading;
              final canAffordModule =
                  game.balance >= upgrade.cost && !upgrade.isPurchased;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isInstalling
                      ? AppColors.brutalYellow
                      : (isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A)),
                  borderRadius: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isInstalled
                                  ? AppColors.brutalGreen
                                  : (isInstalling
                                      ? AppColors.brutalYellow
                                      : (isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0))),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 1.5,
                              ),
                            ),
                            child: Icon(
                              _getUpgradeIconData(upgrade.iconName),
                              color: (isInstalled || isInstalling)
                                  ? Colors.black
                                  : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upgrade.title,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  upgrade.description,
                                  style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      context.tr(
                                          'side_biz_module_bonus_rate', {
                                        'amount': CurrencyFormatter.formatShort(
                                            upgrade.bonusDailyIncome)
                                      }),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.brutalGreen),
                                    ),
                                    if (upgrade.totalUpgradeDays > 0 &&
                                        !upgrade.isPurchased) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '• ${upgrade.totalUpgradeDays} Gün Montaj',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (isInstalling)
                            NeoBrutalButton(
                              label: context.tr('side_biz_btn_rush'),
                              icon: Icons.bolt_rounded,
                              backgroundColor: AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 10.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              onPressed: () {
                                GenericRushJobDialog.show(
                                  context,
                                  titleBadge:
                                      context.tr('rush_lore_sub_upgrade_title'),
                                  targetTitle:
                                      '${business.type.getLocalizedName(lang)} • ${upgrade.title}',
                                  targetSubtitle: context
                                      .tr('rush_lore_days_remaining', {
                                    'days': upgrade.upgradeDaysRemaining
                                        .toString()
                                  }),
                                  loreDescription:
                                      context.tr('rush_lore_sub_upgrade_desc'),
                                  icon: _getUpgradeIconData(upgrade.iconName),
                                  badgeColor: AppColors.brutalYellow,
                                  actionButtonLabel:
                                      context.tr('rush_lore_sub_upgrade_btn'),
                                  onRushSuccess: () {
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .completeSideBusinessSubUpgrade(
                                            business.id, upgrade.id);
                                    if (success) {
                                      NotificationService.showSuccess(
                                        context,
                                        context.tr(
                                            'side_biz_sub_upgrade_success'),
                                      );
                                    }
                                  },
                                );
                              },
                            )
                          else if (isInstalled)
                            NeoBrutalBadge(
                              text: context.tr('active_badge'),
                              backgroundColor: AppColors.brutalGreen,
                              textColor: Colors.black,
                              fontSize: 10,
                            )
                          else
                            NeoBrutalButton(
                              label: CurrencyFormatter.formatShort(upgrade.cost),
                              backgroundColor: canAffordModule
                                  ? AppColors.brutalGreen
                                  : (isDark
                                      ? const Color(0xFF222938)
                                      : const Color(0xFFE2E8F0)),
                              textColor: canAffordModule
                                  ? Colors.black
                                  : (isDark ? Colors.white38 : Colors.black38),
                              borderColor: canAffordModule
                                  ? Colors.black
                                  : (isDark
                                      ? const Color(0xFF333B4F)
                                      : const Color(0xFFCBD5E1)),
                              fontSize: 10.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              onPressed: canAffordModule
                                  ? () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .buySideBusinessUpgrade(
                                              business.id, upgrade.id);
                                      if (success) {
                                        NotificationService.showSuccess(
                                          context,
                                          context.tr(
                                              'side_biz_module_bought_toast',
                                              {'title': upgrade.title}),
                                        );
                                      } else {
                                        NotificationService.showError(
                                          context,
                                          context.tr('insufficient_balance'),
                                        );
                                      }
                                    }
                                  : null,
                            ),
                        ],
                      ),
                      if (isInstalling) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('side_biz_upgrade_installing_badge', {
                                'days': '${upgrade.upgradeDaysRemaining}'
                              }),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.brutalYellow),
                            ),
                            Text(
                              '%${(upgrade.totalUpgradeDays > 0 ? ((1.0 - (upgrade.upgradeDaysRemaining / upgrade.totalUpgradeDays)) * 100).round() : 100)}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.brutalYellow,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // 6. Locked Features & Level Perks Roadmap Card
          Text(
            'SEVİYE YOL HARİTASI & KİLİTLİ AVANTAJLAR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                _buildPerkRow(
                  level: 1,
                  currentLevel: business.level,
                  title: 'Temel Faaliyet & Müşteri Girişi',
                  description: 'Günlük taban pasif nakit akışı ve temel müşteri trafiği.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildPerkRow(
                  level: 2,
                  currentLevel: business.level,
                  title: '+%35 Gelir & Kapasite Artışı',
                  description: 'Genişletilmiş operasyon hacmi ve hızlandırılmış servis.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildPerkRow(
                  level: 3,
                  currentLevel: business.level,
                  title: 'İşletme Müdürü & Otomasyon Kilidi',
                  description: 'Müdür atayarak tam otomasyon ve +%30 ciro primi sağlama yetkisi.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildPerkRow(
                  level: 4,
                  currentLevel: business.level,
                  title: 'Premium Modül Entegrasyonu',
                  description: 'Gelişmiş ekipmanlarla bakım masraflarını düşürme ve ekstra getiri.',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildPerkRow(
                  level: 5,
                  currentLevel: business.level,
                  title: 'Maksimum Amortisman & Prestij',
                  description: 'Şehir çapında kurumsal bilinirlik ve en yüksek pasif kâr marjı.',
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPerkRow({
    required int level,
    required int currentLevel,
    required String title,
    required String description,
    required bool isDark,
  }) {
    final isUnlocked = currentLevel >= level;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.brutalGreen
                : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.check_rounded : Icons.lock_outline_rounded,
              color: isUnlocked ? Colors.black : const Color(0xFF64748B),
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Seviye $level • $title',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isUnlocked
                          ? (isDark ? Colors.white : Colors.black)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isUnlocked
                      ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569))
                      : (isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
