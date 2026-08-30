import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/side_business_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/dialogs/generic_rush_job_dialog.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import 'widgets/side_business_detail_sheet.dart';

class SideBusinessScreen extends ConsumerWidget {
  const SideBusinessScreen({super.key});

  IconData _getBusinessIcon(SideBusinessType type) {
    switch (type) {
      case SideBusinessType.vendingMachine:
        return Icons.local_cafe_rounded;
      case SideBusinessType.carWash:
        return Icons.local_car_wash_rounded;
      case SideBusinessType.billboard:
        return Icons.connected_tv_rounded;
      case SideBusinessType.towTruck:
        return Icons.fire_truck_rounded;
      case SideBusinessType.autoShop:
        return Icons.storefront_rounded;
      case SideBusinessType.inspectionStation:
        return Icons.fact_check_rounded;
      case SideBusinessType.carRental:
        return Icons.car_rental_rounded;
      case SideBusinessType.evCharging:
        return Icons.ev_station_rounded;
      case SideBusinessType.corporateExpertise:
        return Icons.verified_rounded;
      case SideBusinessType.sparePartsStore:
        return Icons.inventory_2_rounded;
      case SideBusinessType.wrapStudio:
        return Icons.auto_fix_high_rounded;
    }
  }

  void _openDetailSheet(BuildContext context, String businessId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SideBusinessDetailSheet(businessId: businessId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/side-businesses')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('side_biz_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/side-businesses',
          featureTitle: context.tr('side_biz_screen_title'),
          icon: Icons.storefront_rounded,
        ),
      );
    }

    final ownedBusinesses =
        game.sideBusinesses.where((b) => b.isOwned).toList();
    final totalDailyIncome =
        game.sideBusinesses.fold(0.0, (sum, b) => sum + b.effectiveDailyIncome);
    final totalLifetimeEarned =
        game.sideBusinesses.fold(0.0, (sum, b) => sum + b.totalEarned);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('side_biz_screen_title'),
        subtitle: context.tr('side_biz_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.cashShimmer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Top Analytics Overview Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.brutalGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.monetization_on_rounded,
                              color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.tr('side_biz_daily_income'),
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.tr('side_biz_income_per_day', {
                                'income': CurrencyFormatter.formatShort(
                                    totalDailyIncome)
                              }),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brutalGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                    NeoBrutalBadge(
                      text: context.tr('side_biz_active_count', {
                        'owned': '${ownedBusinesses.length}',
                        'total': '${game.sideBusinesses.length}'
                      }),
                      backgroundColor: const Color(0xFFA855F7),
                      textColor: Colors.white,
                      fontSize: 11,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(
                      context.tr('side_biz_lifetime_earned'),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B)),
                    )),
                    Expanded(
                        child: Text(
                      CurrencyFormatter.format(totalLifetimeEarned),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.brutalYellow),
                    )),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            context.tr('side_biz_catalog_title'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 2. Business Catalog List
          ...game.sideBusinesses.map((business) {
            final isOwned = business.isOwned;
            final isUnderConstruction = business.isUnderConstruction;
            final isOperational = business.isOperational;
            final iconData = _getBusinessIcon(business.type);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isOperational
                    ? AppColors.brutalGreen
                    : (isUnderConstruction
                        ? AppColors.brutalYellow
                        : (isDark
                            ? const Color(0xFF2A3142)
                            : const Color(0xFF0F172A))),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isOperational
                                      ? AppColors.brutalGreen
                                      : (isUnderConstruction
                                          ? AppColors.brutalYellow
                                          : (isDark
                                              ? const Color(0xFF1E2330)
                                              : const Color(0xFFE2E8F0))),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF333B4F)
                                        : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                ),
                                child: Icon(iconData,
                                    color: (isOperational || isUnderConstruction)
                                        ? Colors.black
                                        : const Color(0xFF64748B),
                                    size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.type.getLocalizedName(lang),
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    if (isOperational && business.upgrades.isNotEmpty)
                                      Text(
                                        context.tr('side_biz_modules_active', {
                                          'count':
                                              '${business.purchasedUpgradeCount}',
                                          'total': '${business.upgrades.length}'
                                        }),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.brutalYellow),
                                      ),
                                    if (!isOwned && business.type.baseConstructionDays > 0)
                                      Text(
                                        context.tr('side_biz_construction_remaining', {
                                          'days': '${business.type.baseConstructionDays}'
                                        }),
                                        style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B)),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isOwned)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isUnderConstruction)
                                NeoBrutalBadge(
                                  text: context.tr('side_biz_badge_construction'),
                                  backgroundColor: AppColors.brutalYellow,
                                  textColor: Colors.black,
                                  fontSize: 10,
                                )
                              else ...[
                                if (business.hasManager)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: NeoBrutalBadge(
                                      text: context.tr('side_biz_badge_managed'),
                                      backgroundColor: const Color(0xFF06B6D4),
                                      textColor: Colors.black,
                                      fontSize: 10,
                                    ),
                                  ),
                                if (business.isUpgradingLevel)
                                  NeoBrutalBadge(
                                    text: context.tr('side_biz_level_upgrading_badge',
                                        {'days': '${business.levelUpgradeDaysRemaining}'}),
                                    backgroundColor: AppColors.brutalYellow,
                                    textColor: Colors.black,
                                    fontSize: 10,
                                  )
                                else
                                  NeoBrutalBadge(
                                    text: context.tr('side_biz_level_badge',
                                        {'lvl': '${business.level}'}),
                                    backgroundColor: AppColors.brutalGreen,
                                    textColor: Colors.black,
                                    fontSize: 10.5,
                                  ),
                              ],
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      business.description,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    if (isUnderConstruction) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E14)
                              : const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.brutalYellow,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.engineering_rounded,
                                        size: 16, color: AppColors.brutalYellow),
                                    const SizedBox(width: 6),
                                    Text(
                                      context.tr('side_biz_construction_remaining', {
                                        'days': '${business.constructionDaysRemaining}'
                                      }),
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '%${(business.constructionProgress * 100).round()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brutalYellow,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
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
                                  widthFactor: business.constructionProgress.clamp(0.05, 1.0),
                                  child: Container(color: AppColors.brutalYellow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (business.isUpgradingLevel) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E1E14)
                              : const Color(0xFFFEFCE8),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.brutalYellow,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.upgrade_rounded,
                                        size: 16, color: AppColors.brutalYellow),
                                    const SizedBox(width: 6),
                                    Text(
                                      context.tr('side_biz_level_upgrading_badge', {
                                        'days': '${business.levelUpgradeDaysRemaining}'
                                      }),
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '%${(business.levelUpgradeProgress * 100).round()}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.brutalYellow,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
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
                                  widthFactor: business.levelUpgradeProgress.clamp(0.05, 1.0),
                                  child: Container(color: AppColors.brutalYellow),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUnderConstruction
                                    ? context.tr('side_biz_status_building')
                                    : context.tr('side_biz_daily_income_header'),
                                style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B)),
                              ),
                              Text(
                                isUnderConstruction
                                    ? context.tr('side_biz_construction_remaining', {
                                        'days': '${business.constructionDaysRemaining}'
                                      })
                                    : context.tr('side_biz_income_rate', {
                                        'amount': CurrencyFormatter.formatShort(isOperational
                                            ? business.effectiveDailyIncome
                                            : business.dailyIncome)
                                      }),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isOperational
                                      ? AppColors.brutalGreen
                                      : (isUnderConstruction
                                          ? AppColors.brutalYellow
                                          : (isDark
                                              ? Colors.white70
                                              : Colors.black87)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!isOwned)
                          NeoBrutalButton(
                            label: context.tr('side_biz_btn_buy', {
                              'cost':
                                  CurrencyFormatter.formatShort(business.cost)
                            }),
                            icon: Icons.shopping_cart_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            onPressed: () {
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .buySideBusiness(business.id);
                              if (success) {
                                NotificationService.showSuccess(
                                    context,
                                    context.tr('side_biz_bought_toast', {
                                      'name':
                                          business.type.getLocalizedName(lang)
                                    }));
                              } else {
                                NotificationService.showError(context,
                                    context.tr('insufficient_balance'));
                              }
                            },
                          )
                        else if (isUnderConstruction)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NeoBrutalButton(
                                label: context.tr('side_biz_btn_rush'),
                                icon: Icons.bolt_rounded,
                                backgroundColor: AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 10.5,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                onPressed: () {
                                  GenericRushJobDialog.show(
                                    context,
                                    titleBadge: context.tr('rush_lore_construction_title'),
                                    targetTitle: '${business.type.getLocalizedName(Localizations.localeOf(context).languageCode)} • ${context.tr('side_biz_status_building')}',
                                    targetSubtitle: context.tr('rush_lore_days_remaining', {'days': business.constructionDaysRemaining.toString()}),
                                    loreDescription: context.tr('rush_lore_construction_desc'),
                                    icon: Icons.apartment_rounded,
                                    badgeColor: AppColors.brutalYellow,
                                    actionButtonLabel: context.tr('rush_lore_construction_btn'),
                                    onRushSuccess: () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .completeSideBusinessConstruction(
                                              business.id);
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
                              const SizedBox(width: 6),
                              NeoBrutalButton(
                                label: context.tr('detail'),
                                icon: Icons.info_outline_rounded,
                                backgroundColor: isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0),
                                textColor: isDark ? Colors.white : Colors.black,
                                fontSize: 10.5,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                onPressed: () =>
                                    _openDetailSheet(context, business.id),
                              ),
                            ],
                          )
                        else
                          NeoBrutalButton(
                            label: context.tr('side_biz_btn_manage'),
                            icon: Icons.store_rounded,
                            backgroundColor: const Color(0xFFA855F7),
                            textColor: Colors.white,
                            fontSize: 11,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            onPressed: () =>
                                _openDetailSheet(context, business.id),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
