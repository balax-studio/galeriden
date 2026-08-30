import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../domain/usecases/black_market_container_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/fake_doc_ink_spread_widget.dart';
import '../../widgets/mini_games/hidden_stash_canvas.dart';
import '../../widgets/mini_games/mystery_container_unboxing_modal.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class BlackMarketScreen extends ConsumerStatefulWidget {
  const BlackMarketScreen({super.key});

  @override
  ConsumerState<BlackMarketScreen> createState() => _BlackMarketScreenState();
}

class _BlackMarketScreenState extends ConsumerState<BlackMarketScreen>
    with SingleTickerProviderStateMixin {
  final Set<String> _scannedCarIds = {};
  final Set<String> _cleansedRiskCarIds = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/black-market')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('bm_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/black-market',
          featureTitle: context.tr('bm_screen_title'),
          icon: Icons.masks_rounded,
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(title: context.tr('bm_screen_title')),
      body: Column(
        children: [
          // 2-Tab Neo-Brutalist Selector Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141721) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFF0F172A),
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF0F172A),
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppColors.brutalYellow,
                  borderRadius: BorderRadius.circular(9),
                  border:
                      Border.all(color: const Color(0xFF0F172A), width: 1.5),
                ),
                labelColor: Colors.black,
                unselectedLabelColor:
                    isDark ? Colors.white70 : const Color(0xFF64748B),
                labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.car_repair_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(context.tr('bm_tab_shadow_deals')),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.anchor_rounded, size: 16),
                        const SizedBox(width: 6),
                        Text(context.tr('bm_tab_mystery_container')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShadowDealsTab(context, game, isDark),
                _buildMysteryContainerTab(context, game, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab 1: Gölge Pazar Araçları
  Widget _buildShadowDealsTab(BuildContext context, dynamic game, bool isDark) {
    final bmCars = game.blackMarketCars;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          14, 14, 14, 24 + MediaQuery.paddingOf(context).bottom),
      physics: const BouncingScrollPhysics(),
      children: [
        // Banner Warning & Shadow Contact Info
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: const Color(0xFF1F1212),
          borderColor: AppColors.errorRed,
          borderRadius: 14,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.errorRed,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: const Color(0xFF0F172A), width: 2.0),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('bm_warning_banner_title'),
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.errorRed),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.tr('bm_warning_banner_desc'),
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEF4444)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Shadow Contact Relationship Status
        NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.person_pin_rounded,
                      color: AppColors.brutalYellow, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.tr('bm_npc_status_label'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              NeoBrutalBadge(
                text: game.hasHighNpcTrust('golge_ibrahim')
                    ? context.tr('bm_npc_status_trusted')
                    : context.tr('bm_npc_status_suspicious'),
                backgroundColor: game.hasHighNpcTrust('golge_ibrahim')
                    ? AppColors.brutalGreen
                    : AppColors.brutalYellow,
                textColor: Colors.black,
                fontSize: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Black Market Inventory List
        Text(
          context.tr('bm_deals_header'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        if (bmCars.where((c) => !c.isPurchased).isEmpty)
          NeoBrutalCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Center(
              child: Text(
                context.tr('bm_no_cars_available'),
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B)),
              ),
            ),
          )
        else
          ...bmCars.where((c) => !c.isPurchased).map((car) {
            final isScanned = _scannedCarIds.contains(car.id);
            final isCleansed = _cleansedRiskCarIds.contains(car.id);
            final displayRisk = isCleansed ? 0 : car.riskLevelPercent;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeoBrutalCard(
                padding: const EdgeInsets.all(14),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isCleansed ? AppColors.brutalGreen : AppColors.errorRed,
                borderRadius: 14,
                child: Stack(
                  children: [
                    if (isCleansed)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: FakeDocInkSpreadWidget(
                            stampText: context.tr('bm_stamp_cleansed'), size: 55),
                      ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${car.modelYear} ${car.brand} ${car.modelName}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900),
                                  ),
                                ],
                              ),
                            ),
                            NeoBrutalBadge(
                              text: isCleansed
                                  ? context.tr('bm_police_risk_clean')
                                  : context.tr('bm_police_risk_val',
                                      {'risk': '$displayRisk'}),
                              backgroundColor: isCleansed
                                  ? AppColors.brutalGreen
                                  : AppColors.errorRed,
                              textColor:
                                  isCleansed ? Colors.black : Colors.white,
                              fontSize: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.tr(
                              'bm_seller_label', {'seller': car.sellerAlias}),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.brutalYellow),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isCleansed
                              ? context.tr('bm_clean_desc')
                              : car.riskDescription,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isCleansed
                                ? AppColors.brutalGreen
                                : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.tr('bm_market_val', {
                                    'price': CurrencyFormatter.formatShort(
                                        car.realMarketValue)
                                  }),
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      CurrencyFormatter.formatShort(
                                        game.hasHighNpcTrust('golge_ibrahim')
                                            ? (car.askingPrice * 0.85)
                                                .roundToDouble()
                                            : car.askingPrice,
                                      ),
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.brutalGreen),
                                    ),
                                    if (game
                                        .hasHighNpcTrust('golge_ibrahim')) ...[
                                      const SizedBox(width: 6),
                                      NeoBrutalBadge(
                                        text: context.tr('bm_shadow_discount'),
                                        backgroundColor: AppColors.brutalYellow,
                                        textColor: Colors.black,
                                        fontSize: 9,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                NeoBrutalButton(
                                  label: isScanned
                                      ? context.tr('bm_btn_scanned_stash')
                                      : context.tr('bm_btn_scan_stash'),
                                  icon: isScanned
                                      ? Icons.check_circle_rounded
                                      : Icons.radar_rounded,
                                  backgroundColor: isScanned
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF6366F1),
                                  textColor:
                                      isScanned ? Colors.white54 : Colors.white,
                                  fontSize: 10,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  onPressed: isScanned
                                      ? null
                                      : () {
                                          HiddenStashModal.show(
                                            context,
                                            car: car,
                                            onInspectionCompleted: (stashFound,
                                                rewardCash, itemDesc) {
                                              setState(() {
                                                _scannedCarIds.add(car.id);
                                              });
                                              if (stashFound) {
                                                ref
                                                    .read(gameProvider.notifier)
                                                    .addMoney(rewardCash);
                                                NotificationService.showSuccess(
                                                  context,
                                                  context.tr(
                                                      'black_market_toast_stash_seized'),
                                                );
                                              }
                                            },
                                          );
                                        },
                                ),
                                if (!isCleansed) ...[
                                  const SizedBox(height: 6),
                                  NeoBrutalButton(
                                    label: context.tr('bm_btn_fake_plate'),
                                    icon: Icons.shield_rounded,
                                    backgroundColor: const Color(0xFF10B981),
                                    textColor: Colors.black,
                                    fontSize: 10,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    onPressed: () {
                                      AdService.instance
                                          .showRewardedAdWithFallback(
                                        context: context,
                                        customRewardTitle: context
                                            .tr('bm_ad_reward_fake_plate_title'),
                                        onRewardEarned: () {
                                          setState(() {
                                            _cleansedRiskCarIds.add(car.id);
                                          });
                                          NotificationService.showSuccess(
                                            context,
                                            context.tr(
                                                'black_market_toast_fake_plate'),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                                const SizedBox(height: 6),
                                NeoBrutalButton(
                                  label: context.tr('bm_btn_buy_risk'),
                                  icon: Icons.gavel_rounded,
                                  backgroundColor: AppColors.errorRed,
                                  textColor: Colors.white,
                                  fontSize: 11,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  onPressed: () {
                                    if (game.ownedCars.length >=
                                        game.maxGarageSlots) {
                                      NotificationService.showError(
                                          context,
                                          context.tr(
                                              'black_market_toast_no_space'));
                                      return;
                                    }
                                    final effectiveCost =
                                        game.hasHighNpcTrust('golge_ibrahim')
                                            ? (car.askingPrice * 0.85)
                                                .roundToDouble()
                                            : car.askingPrice;
                                    if (game.balance < effectiveCost) {
                                      NotificationService.showError(
                                        context,
                                        context.tr('err_insufficient_cash'),
                                      );
                                      return;
                                    }

                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .buyBlackMarketCar(car.id,
                                            isCleansed: isCleansed);
                                    if (success) {
                                      NotificationService.showSuccess(
                                        context,
                                        context.tr(
                                            'black_market_toast_car_bought'),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  /// Tab 2: Gizemli Liman Konteyneri (Gacha Unboxing)
  Widget _buildMysteryContainerTab(
      BuildContext context, dynamic game, bool isDark) {
    final daysLeft = game.mysteryContainerDaysRemaining;
    final isAvailable = game.isMysteryContainerAvailable;
    final containerCost = BlackMarketContainerEngine.containerCost;
    final hasEnoughBalance = game.balance >= containerCost;

    return ListView(
      padding: EdgeInsets.fromLTRB(
          14, 14, 14, 24 + MediaQuery.paddingOf(context).bottom),
      physics: const BouncingScrollPhysics(),
      children: [
        // Hero Container Bento Card
        NeoBrutalCard(
          padding: const EdgeInsets.all(16),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor:
              isAvailable ? AppColors.brutalYellow : const Color(0xFF64748B),
          borderRadius: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? AppColors.brutalYellow
                              : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF0F172A), width: 1.5),
                        ),
                        child: Icon(
                          Icons.anchor_rounded,
                          color: isAvailable ? Colors.black : Colors.white70,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('bm_container_header_title'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  NeoBrutalBadge(
                    text: isAvailable
                        ? context.tr('bm_container_ready_badge')
                        : context.tr(
                            'bm_container_locked_badge', {'days': '$daysLeft'}),
                    backgroundColor: isAvailable
                        ? AppColors.brutalGreen
                        : const Color(0xFF334155),
                    textColor: isAvailable ? Colors.black : Colors.white,
                    fontSize: 10,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                context.tr('bm_container_header_desc'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 14),

              // Visual container graphic badge with pricing
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0C0E14)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('bm_container_cost_label'),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          CurrencyFormatter.formatShort(containerCost),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          context.tr('bm_container_cooldown_label'),
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                        Text(
                          isAvailable
                              ? context.tr('bm_container_ready_now')
                              : context.tr('bm_container_days_left',
                                  {'days': '$daysLeft'}),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isAvailable
                                ? AppColors.brutalYellow
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Action Purchase Button
              SizedBox(
                width: double.infinity,
                child: NeoBrutalButton(
                  label: isAvailable
                      ? context.tr('bm_container_btn_purchase')
                      : context.tr(
                          'bm_container_btn_waiting', {'days': '$daysLeft'}),
                  icon: isAvailable
                      ? Icons.lock_open_rounded
                      : Icons.timer_rounded,
                  backgroundColor: isAvailable
                      ? (hasEnoughBalance
                          ? AppColors.brutalYellow
                          : const Color(0xFF475569))
                      : const Color(0xFF1E293B),
                  textColor: isAvailable
                      ? (hasEnoughBalance ? Colors.black : Colors.white60)
                      : Colors.white38,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  onPressed: isAvailable && hasEnoughBalance
                      ? () {
                          if (game.ownedCars.length >= game.maxGarageSlots) {
                            NotificationService.showError(context,
                                context.tr('black_market_toast_no_space'));
                            return;
                          }

                          final result = ref
                              .read(gameProvider.notifier)
                              .buyMysteryContainer();
                          if (result != null) {
                            MysteryContainerUnboxingModal.show(
                              context,
                              result: result,
                              onClaim: () {
                                NotificationService.showSuccess(
                                  context,
                                  context.tr('bm_container_toast_bought',
                                      {'model': result.car.modelName}),
                                );
                              },
                            );
                          }
                        }
                      : () {
                          if (!isAvailable) {
                            NotificationService.showWarning(
                              context,
                              context.tr('bm_container_toast_cooldown',
                                  {'days': '$daysLeft'}),
                            );
                          } else if (!hasEnoughBalance) {
                            NotificationService.showError(
                                context, context.tr('err_insufficient_cash'));
                          }
                        },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Drop Rates & Probability Bento Section
        Text(
          context.tr('bm_container_rates_title'),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isDark ? Colors.white70 : const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),

        // 4 Rarity Cards
        _buildRarityRateCard(
          context,
          title: context.tr('bm_container_tier_standard_title'),
          badge: '%15',
          priceRange:
              '${CurrencyFormatter.formatShort(2000000)} • ${CurrencyFormatter.formatShort(4200000)}',
          desc: context.tr('bm_container_tier_standard_desc'),
          accentColor: const Color(0xFF38BDF8),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildRarityRateCard(
          context,
          title: context.tr('bm_container_tier_rare_title'),
          badge: '%40',
          priceRange:
              '${CurrencyFormatter.formatShort(4200000)} • ${CurrencyFormatter.formatShort(6500000)}',
          desc: context.tr('bm_container_tier_rare_desc'),
          accentColor: const Color(0xFFF59E0B),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildRarityRateCard(
          context,
          title: context.tr('bm_container_tier_exotic_title'),
          badge: '%30',
          priceRange:
              '${CurrencyFormatter.formatShort(7000000)} • ${CurrencyFormatter.formatShort(10500000)}',
          desc: context.tr('bm_container_tier_exotic_desc'),
          accentColor: const Color(0xFF10B981),
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        _buildRarityRateCard(
          context,
          title: context.tr('bm_container_tier_hyper_title'),
          badge: '%15',
          priceRange:
              '${CurrencyFormatter.formatShort(13500000)} • ${CurrencyFormatter.formatShort(22000000)}',
          desc: context.tr('bm_container_tier_hyper_desc'),
          accentColor: const Color(0xFFA855F7),
          isDark: isDark,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRarityRateCard(
    BuildContext context, {
    required String title,
    required String badge,
    required String priceRange,
    required String desc,
    required Color accentColor,
    required bool isDark,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: accentColor,
      borderRadius: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.black),
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
                    Expanded(
                        child: Text(
                      title,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w900),
                    )),
                    Expanded(
                        child: Text(
                      priceRange,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF0F172A),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10.5,
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
    );
  }
}
