import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/branch_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/dialogs/showroom_construction_modal.dart';

class BranchScreen extends ConsumerWidget {
  const BranchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);
    final branches = BranchModel.getAllBranches(
      currentSlotCount: game.maxGarageSlots,
      currentLevel: game.level,
      unlockedBuildings: game.unlockedBuildings,
      ownedDeeds: game.ownedBranchDeeds,
    );

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('branch_screen_title'),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.dealership,
        child: ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
          // 1. Current Branch Status Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('branch_current_hq'),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Text(
                  game.dealershipName,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn(
                        context.tr('branch_capacity_label'),
                        context.tr('branch_capacity_val',
                            {'count': '${game.maxGarageSlots}'}),
                        isDark),
                    _buildInfoColumn(
                        context.tr('branch_level_label'),
                        context
                            .tr('branch_level_val', {'level': '${game.level}'}),
                        isDark),
                    _buildInfoColumn(context.tr('branch_capital_label'),
                        CurrencyFormatter.formatShort(game.balance), isDark),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 2. Showroom Decor Navigation Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF333B4F)
                          : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.palette_rounded,
                      color: Colors.black, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('branch_decor_banner_title'),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        context.tr('branch_decor_banner_sub'),
                        style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                NeoBrutalButton(
                  label: game.isFeatureUnlocked('/showroom-decor')
                      ? context.tr('branch_btn_decor_open')
                      : context.tr('locked'),
                  backgroundColor: game.isFeatureUnlocked('/showroom-decor')
                      ? const Color(0xFF06B6D4)
                      : (isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFFCBD5E1)),
                  textColor: game.isFeatureUnlocked('/showroom-decor')
                      ? Colors.black
                      : Colors.white70,
                  fontSize: 11,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  onPressed: () {
                    if (game.isFeatureUnlocked('/showroom-decor')) {
                      context.push('/showroom-decor');
                    } else {
                      final reqBranch = DealershipModel.getRequiredBranchName(
                          '/showroom-decor', context);
                      NotificationService.showInfo(
                        context,
                        context.tr('cashflow_locked_feature_toast',
                            {'branch': reqBranch}),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            context.tr('branch_tiers_title'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Branches List
          ...branches.map((b) {
            final isCurrent = game.maxGarageSlots == b.maxGarageSlots;
            final isLevelUnlocked = game.level >= b.targetLevel;
            final canAfford = game.balance >= b.requiredBalance;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isCurrent
                    ? AppColors.brutalYellow
                    : (isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFF0F172A)),
                borderWidth: isCurrent ? 2.5 : 2.0,
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (isCurrent || b.isUnlocked)
                                      ? AppColors.brutalYellow
                                      : (isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0)),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF333B4F)
                                        : const Color(0xFF0F172A),
                                    width: 2.0,
                                  ),
                                ),
                                child: Icon(_getBranchIcon(b.vectorIcon),
                                    color: Colors.black, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.getLocalizedName(context),
                                      style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      b.getLocalizedLocation(context),
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
                        if (isCurrent)
                          NeoBrutalBadge(
                            text: context.tr('branch_badge_current'),
                            backgroundColor: AppColors.brutalYellow,
                            textColor: Colors.black,
                            fontSize: 10,
                          )
                        else
                          NeoBrutalBadge(
                            text: context.tr('branch_badge_level',
                                {'lvl': '${b.targetLevel}'}),
                            backgroundColor: isLevelUnlocked
                                ? const Color(0xFF6366F1)
                                : const Color(0xFF64748B),
                            textColor: Colors.white,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          context.tr('branch_item_capacity',
                              {'cap': '${b.maxGarageSlots}'}),
                          style: const TextStyle(
                              fontSize: 11.5, fontWeight: FontWeight.w700),
                        )),
                        Expanded(
                            child: Text(
                          context.tr('branch_item_burn_rate', {
                            'cost':
                                CurrencyFormatter.formatShort(b.dailyBurnRate)
                          }),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFFF87171)
                                : const Color(0xFFDC2626),
                          ),
                        )),
                        Expanded(
                            child: Text(
                          context.tr('branch_item_profit_mult',
                              {'mult': '${b.profitMultiplier}'}),
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.brutalGreen),
                        )),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F1118)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A3142)
                              : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                              isLevelUnlocked
                                  ? Icons.lock_open_rounded
                                  : Icons.lock_rounded,
                              size: 14,
                              color: isLevelUnlocked
                                  ? AppColors.brutalGreen
                                  : const Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              context.tr('branch_unlocked_features',
                                  {'summary': b.getLocalizedSummary(context)}),
                              style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Tapu & Gayrimenkul Mülkiyet Durumu
                    if (isCurrent || b.isUnlocked) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: b.isDeedOwned
                              ? (isDark
                                  ? const Color(0xFF064E3B)
                                  : const Color(0xFFECFDF5))
                              : (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: b.isDeedOwned
                                ? const Color(0xFF10B981)
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  b.isDeedOwned
                                      ? Icons.verified_user_rounded
                                      : Icons.real_estate_agent_rounded,
                                  size: 16,
                                  color: b.isDeedOwned
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF3B82F6),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  b.isDeedOwned
                                      ? context.tr('branch_deed_owned_title')
                                      : context.tr('branch_deed_rented_title'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: b.isDeedOwned
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF3B82F6),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              b.isDeedOwned
                                  ? context.tr('branch_deed_owned_desc')
                                  : context.tr('branch_deed_buy_desc', {
                                      'limit': CurrencyFormatter.formatShort(
                                          b.deedCost * 0.35)
                                    }),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF475569),
                              ),
                            ),
                            if (!b.isDeedOwned) ...[
                              const SizedBox(height: 8),
                              NeoBrutalButton(
                                label: game.balance >= b.deedCost
                                    ? context.tr('branch_btn_buy_deed', {
                                        'cost': CurrencyFormatter.formatShort(
                                            b.deedCost)
                                      })
                                    : context.tr(
                                        'branch_btn_insufficient_deed', {
                                        'cost': CurrencyFormatter.formatShort(
                                            b.deedCost)
                                      }),
                                backgroundColor: game.balance >= b.deedCost
                                    ? const Color(0xFF3B82F6)
                                    : (isDark
                                        ? const Color(0xFF1E2330)
                                        : const Color(0xFFE2E8F0)),
                                textColor: game.balance >= b.deedCost
                                    ? Colors.white
                                    : const Color(0xFF64748B),
                                fontSize: 10.5,
                                fullWidth: true,
                                onPressed: game.balance >= b.deedCost
                                    ? () {
                                        final success = ref
                                            .read(gameProvider.notifier)
                                            .buyBranchDeed(b);
                                        if (success) {
                                          NotificationService.showSuccess(
                                            context,
                                            context
                                                .tr('branch_toast_deed_owned'),
                                          );
                                        }
                                      }
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    if (!isCurrent && !b.isUnlocked) ...[
                      const SizedBox(height: 12),
                      NeoBrutalButton(
                        label: !isLevelUnlocked
                            ? context.tr('branch_btn_level_req',
                                {'lvl': '${b.targetLevel}'})
                            : (canAfford
                                ? context.tr('branch_btn_buy_branch', {
                                    'cost': CurrencyFormatter.formatShort(
                                        b.requiredBalance)
                                  })
                                : context.tr('branch_btn_insufficient_branch', {
                                    'cost': CurrencyFormatter.formatShort(
                                        b.requiredBalance)
                                  })),
                        backgroundColor: !isLevelUnlocked
                            ? (isDark
                                ? const Color(0xFF1A1F2C)
                                : const Color(0xFFCBD5E1))
                            : (canAfford
                                ? AppColors.brutalGreen
                                : (isDark
                                    ? const Color(0xFF1E2330)
                                    : const Color(0xFFE2E8F0))),
                        textColor: isLevelUnlocked && canAfford
                            ? Colors.black
                            : const Color(0xFF64748B),
                        fontSize: 11.5,
                        fullWidth: true,
                        onPressed: (isLevelUnlocked && canAfford)
                            ? () {
                                final durationSec = b.targetLevel <= 3
                                    ? 3
                                    : (b.targetLevel <= 5 ? 5 : 10);
                                ShowroomConstructionModal.show(
                                  context,
                                  title: context.tr('construction_branch_title'),
                                  subtitle: b.getLocalizedName(context),
                                  customDurationSeconds: durationSec,
                                  icon: Icons.domain_rounded,
                                  accentColor: AppColors.brutalYellow,
                                  onComplete: () {
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .upgradeBranch(b);
                                    if (success) {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => Dialog(
                                          backgroundColor: Colors.transparent,
                                          insetPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 20),
                                          child: NeoBrutalCard(
                                            padding: const EdgeInsets.all(20),
                                            backgroundColor: isDark
                                                ? const Color(0xFF141721)
                                                : Colors.white,
                                            borderColor: isDark
                                                ? const Color(0xFF333B4F)
                                                : const Color(0xFF0F172A),
                                            borderRadius: 12,
                                            borderWidth: 2.5,
                                            shadowOffset: const Offset(4, 4),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        AppColors.brutalYellow,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: isDark
                                                          ? const Color(
                                                              0xFF333B4F)
                                                          : const Color(
                                                              0xFF0F172A),
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                      Icons.stars_rounded,
                                                      size: 40,
                                                      color: Colors.black),
                                                ),
                                                const SizedBox(height: 14),
                                                Text(
                                                    context.tr(
                                                        'branch_congrats_title'),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w900)),
                                                const SizedBox(height: 6),
                                                Text(
                                                  context.tr(
                                                      'branch_congrats_desc', {
                                                    'name': b
                                                        .getLocalizedName(
                                                            context),
                                                    'cap': '${b.maxGarageSlots}'
                                                  }),
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                const SizedBox(height: 16),
                                                NeoBrutalButton(
                                                  label: context
                                                      .tr('branch_btn_awesome'),
                                                  fullWidth: true,
                                                  backgroundColor:
                                                      AppColors.brutalYellow,
                                                  textColor: Colors.black,
                                                  onPressed: () =>
                                                      Navigator.pop(ctx),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                            : null,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    ),
  );
  }

  Widget _buildInfoColumn(String title, String value, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  IconData _getBranchIcon(String vectorIcon) {
    switch (vectorIcon) {
      case 'craftsman':
        return Icons.storefront_rounded;
      case 'car_wash':
        return Icons.local_car_wash_rounded;
      case 'workshop':
        return Icons.build_circle_rounded;
      case 'tuning':
        return Icons.tune_rounded;
      case 'auction':
        return Icons.gavel_rounded;
      case 'shield':
        return Icons.account_balance_rounded;
      case 'fleet':
        return Icons.car_rental_rounded;
      case 'rare':
        return Icons.domain_rounded;
      default:
        return Icons.apartment_rounded;
    }
  }
}
