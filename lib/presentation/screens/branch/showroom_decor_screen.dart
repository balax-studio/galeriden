import '../../../core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/showroom_decor_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/dialogs/showroom_construction_modal.dart';

class ShowroomDecorScreen extends ConsumerStatefulWidget {
  const ShowroomDecorScreen({super.key});

  @override
  ConsumerState<ShowroomDecorScreen> createState() =>
      _ShowroomDecorScreenState();
}

class _ShowroomDecorScreenState extends ConsumerState<ShowroomDecorScreen> {
  DecorCategory _selectedCategory = DecorCategory.all;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/showroom-decor')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('decor_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/showroom-decor',
          featureTitle: context.tr('decor_screen_title'),
          icon: Icons.palette_rounded,
        ),
      );
    }

    final allDecors = ShowroomDecorModel.getAllDecors();
    final displayedDecors = _selectedCategory == DecorCategory.all
        ? allDecors
        : allDecors.where((d) => d.category == _selectedCategory).toList();

    final unlockedCount = game.unlockedDecorIds.length;
    final totalCount = allDecors.length;
    final double totalRepGained = allDecors
        .where((d) => game.unlockedDecorIds.contains(d.id))
        .fold(0.0, (sum, d) => sum + d.reputationBonus);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('decor_screen_title'),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.showroom,
        child: ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
          // 1. Header RPG Overview Card
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
                      child: const Icon(Icons.storefront_rounded,
                          color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('decor_overview_title'),
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('decor_overview_sub', {
                              'built': '$unlockedCount',
                              'total': '$totalCount',
                              'rep': '${totalRepGained.toInt()}'
                            }),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brutalGreen),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1118)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn(
                          context.tr('decor_stat_bargain'),
                          game.hasDecor('decor_leather_chair_desk')
                              ? context.tr(
                                  'decor_stat_persuade_bonus', {'bonus': '5'})
                              : context.tr('decor_stat_standard'),
                          isDark,
                          AppColors.brutalGreen),
                      _buildStatColumn(
                          context.tr('decor_stat_consignment'),
                          game.hasDecor('decor_copper_samovar')
                              ? context.tr(
                                  'decor_stat_demand_bonus', {'bonus': '10'})
                              : context.tr('decor_stat_standard'),
                          isDark,
                          const Color(0xFFF97316)),
                      _buildStatColumn(
                          context.tr('decor_stat_security'),
                          game.hasFullSecurityProtection
                              ? context.tr('decor_stat_full_protected')
                              : context.tr('decor_stat_unprotected'),
                          isDark,
                          game.hasFullSecurityProtection
                              ? AppColors.brutalGreen
                              : const Color(0xFFEF4444)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Category Tab Filter Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: DecorCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCategory = cat);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark ? const Color(0xFF141721) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.black
                              : (isDark
                                  ? const Color(0xFF2A3142)
                                  : const Color(0xFF0F172A)),
                          width: isSelected ? 2.2 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            ShowroomDecorModel.getCategoryIcon(cat),
                            size: 16,
                            color: isSelected
                                ? Colors.black
                                : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            ShowroomDecorModel.getCategoryLabel(cat),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Options List
          ...displayedDecors.map((item) {
            final isPurchased = game.unlockedDecorIds.contains(item.id);
            final isLevelUnlocked = game.level >= item.minDealershipLevel;
            final canAfford = game.balance >= item.cost;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isPurchased
                    ? AppColors.brutalGreen
                    : (isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFF0F172A)),
                borderRadius: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: isPurchased
                                ? AppColors.brutalGreen
                                : (isLevelUnlocked
                                    ? item.color
                                    : const Color(0xFF64748B)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: Icon(
                            isPurchased
                                ? Icons.check_circle_rounded
                                : item.icon,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ShowroomDecorModel.getCategoryLabel(
                                        item.category)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (isPurchased)
                          NeoBrutalBadge(
                            text: context.tr('decor_badge_active'),
                            icon: Icons.check_rounded,
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                          )
                        else if (!isLevelUnlocked)
                          NeoBrutalBadge(
                            text: context.tr('branch_badge_level',
                                {'lvl': '${item.minDealershipLevel}'}),
                            icon: Icons.lock_rounded,
                            backgroundColor: const Color(0xFF64748B),
                            textColor: Colors.white,
                            fontSize: 9.5,
                          )
                        else
                          NeoBrutalBadge(
                            text: context.tr('decor_badge_rep', {
                              'rep': item.reputationBonus.toStringAsFixed(0)
                            }),
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 8),

                    // RPG Perk Badge Box
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
                          const Icon(Icons.flash_on_rounded,
                              size: 14, color: AppColors.brutalYellow),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              context.tr(
                                  'decor_rpg_perk', {'perk': item.perkSummary}),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFE2E8F0)
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          isPurchased
                              ? context.tr('decor_built_label')
                              : CurrencyFormatter.formatShort(item.cost),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isPurchased
                                ? const Color(0xFF64748B)
                                : AppColors.brutalGreen,
                          ),
                        )),
                        NeoBrutalButton(
                          label: isPurchased
                              ? context.tr('decor_built_label')
                              : (!isLevelUnlocked
                                  ? context.tr('branch_btn_level_req',
                                      {'lvl': '${item.minDealershipLevel}'})
                                  : (canAfford
                                      ? context.tr('decor_btn_build', {
                                          'cost': CurrencyFormatter.formatShort(
                                              item.cost)
                                        })
                                      : context.tr('insufficient_balance'))),
                          icon: isPurchased
                              ? Icons.check_circle_rounded
                              : (!isLevelUnlocked
                                  ? Icons.lock_rounded
                                  : (canAfford
                                      ? Icons.architecture_rounded
                                      : Icons.lock_outline_rounded)),
                          backgroundColor: isPurchased
                              ? (isDark
                                  ? const Color(0xFF1E2330)
                                  : const Color(0xFFE2E8F0))
                              : (!isLevelUnlocked
                                  ? (isDark
                                      ? const Color(0xFF1A1F2C)
                                      : const Color(0xFFCBD5E1))
                                  : (canAfford
                                      ? item.color
                                      : (isDark
                                          ? const Color(0xFF1E2330)
                                          : const Color(0xFFE2E8F0)))),
                          textColor: isPurchased
                              ? (isDark ? Colors.white54 : Colors.black54)
                              : (!isLevelUnlocked
                                  ? const Color(0xFF64748B)
                                  : (canAfford
                                      ? Colors.black
                                      : const Color(0xFF64748B))),
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          onPressed: (isPurchased || !isLevelUnlocked)
                              ? null
                              : () {
                                  if (!canAfford) {
                                    NotificationService.showError(
                                        context,
                                        context.tr(
                                            'toast_insufficient_balance_needed',
                                            {
                                              'cost': CurrencyFormatter.format(
                                                  item.cost)
                                            }));
                                    return;
                                  }

                                  final durationSec = item.cost < 20000
                                      ? 3
                                      : (item.cost < 100000 ? 5 : 10);
                                  ShowroomConstructionModal.show(
                                    context,
                                    title:
                                        context.tr('construction_decor_title'),
                                    subtitle: item.title,
                                    customDurationSeconds: durationSec,
                                    icon: item.icon,
                                    accentColor: item.color,
                                    onComplete: () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .purchaseShowroomDecor(
                                            decorId: item.id,
                                            cost: item.cost,
                                            reputationBonus:
                                                item.reputationBonus,
                                          );

                                      if (success) {
                                        NotificationService.showSuccess(
                                          context,
                                          context.tr('decor_toast_built'),
                                        );
                                      } else {
                                        NotificationService.showError(
                                            context,
                                            context.tr(
                                                'decor_toast_already_built'));
                                      }
                                    },
                                  );
                                },
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
    ),
  );
  }

  Widget _buildStatColumn(
      String title, String value, bool isDark, Color valueColor) {
    return Column(
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
          style: TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w900, color: valueColor),
        ),
      ],
    );
  }
}
