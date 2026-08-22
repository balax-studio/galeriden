import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/showroom_theme_model.dart';
import '../../../data/models/store_bundle_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final game = ref.watch(gameProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('store_appbar_title'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141721) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.brutalYellow,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 2.0),
              ),
              labelColor: Colors.black,
              unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              labelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
              unselectedLabelStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              tabs: [
                Tab(text: context.tr('store_tab_bundles')),
                Tab(text: context.tr('store_tab_themes')),
                Tab(text: context.tr('store_tab_cosmetics')),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildBundlesTab(context, game, isDark),
          _buildThemesTab(context, game, isDark),
          _buildCosmeticsTab(context, game, isDark),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: PAKETLER & LİSANSLAR (b.2)
  // ==========================================
  Widget _buildBundlesTab(BuildContext context, dynamic game, bool isDark) {
    final bundles = StoreBundleModel.getAllBundles();

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
        // VIP Banner
        NeoBrutalCard(
          padding: const EdgeInsets.all(14),
          backgroundColor: isDark ? const Color(0xFF16132A) : const Color(0xFFFAF5FF),
          borderColor: AppColors.brutalPurple,
          borderWidth: 2.5,
          borderRadius: 14,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.brutalPurple,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 2.0),
                ),
                child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('store_banner_vip_title'),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      context.tr('store_banner_vip_subtitle'),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Bundles List
        ...bundles.map((b) => _buildBundleCard(context, b, game, isDark)),
      ],
    );
  }

  Widget _buildBundleCard(BuildContext context, StoreBundleModel b, dynamic game, bool isDark) {
    bool isOwned = false;
    switch (b.type) {
      case StoreBundleType.starterPack:
        isOwned = game.isStarterBundlePurchased;
        break;
      case StoreBundleType.scrapyardPack:
        isOwned = game.isScrapyardBundlePurchased;
        break;
      case StoreBundleType.plazaPack:
        isOwned = game.isPlazaBundlePurchased;
        break;
      case StoreBundleType.noAdsLicense:
        isOwned = game.hasNoAdsLicense;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isOwned ? const Color(0xFF334155) : b.accentColor,
        borderWidth: 2.5,
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                NeoBrutalBadge(
                  text: context.tr(b.badgeKey),
                  icon: b.icon,
                  backgroundColor: b.accentColor,
                  textColor: Colors.black,
                  fontSize: 10.5,
                ),
                if (isOwned)
                  NeoBrutalBadge(
                    text: context.tr('store_status_purchased'),
                    icon: Icons.check_circle_rounded,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 10.5,
                  )
                else
                  Text(
                    '\$${b.realPriceUsd.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Title & Subtitle
            Text(
              context.tr(b.titleKey),
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.tr(b.subtitleKey),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),

            // Perks Checklist
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B0D13) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF222938) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: b.perkKeys.map((pk) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: b.accentColor, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.tr(pk),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Action Purchase Button
            if (isOwned)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    context.tr('store_btn_already_owned'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              NeoBrutalButton(
                label: context.tr('store_btn_buy_bundle', {'price': '\$${b.realPriceUsd.toStringAsFixed(2)}'}),
                icon: Icons.shopping_bag_rounded,
                backgroundColor: b.accentColor,
                textColor: Colors.black,
                fontSize: 13,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 11),
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  final success = ref.read(gameProvider.notifier).purchaseStoreBundle(b, paidRealMoney: true);
                  if (success) {
                    NotificationService.showSuccess(
                      context,
                      context.tr('store_toast_purchase_success'),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: SHOWROOM TEMALARI (d)
  // ==========================================
  Widget _buildThemesTab(BuildContext context, dynamic game, bool isDark) {
    final themes = ShowroomThemeModel.getAllThemes();

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
        // Overview Info Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A), width: 2.0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brutalCyan,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Icon(Icons.palette_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('store_themes_overview_hint'),
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Themes Cards
        ...themes.map((t) => _buildThemeCard(context, t, game, isDark)),
      ],
    );
  }

  Widget _buildThemeCard(BuildContext context, ShowroomThemeModel t, dynamic game, bool isDark) {
    final bool isUnlocked = game.unlockedShowroomThemeIds.contains(t.id);
    final bool isActive = game.activeShowroomThemeId == t.id;
    final bool canAfford = game.balance >= t.cost;
    final bool meetsLevel = game.level >= t.minDealershipLevel;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isActive ? AppColors.brutalGreen : (isUnlocked ? t.accentColor : const Color(0xFF334155)),
        borderWidth: isActive ? 3.0 : 2.0,
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Banner Simulation
            Container(
              height: 70,
              decoration: BoxDecoration(
                color: t.wallColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: t.spotColor.withValues(alpha: 0.5), width: 1.5),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 25,
                    child: Container(
                      decoration: BoxDecoration(
                        color: t.floorColor,
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 14,
                    child: Row(
                      children: [
                        Icon(t.icon, color: t.spotColor, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          context.tr(t.titleKey),
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: NeoBrutalBadge(
                        text: context.tr('store_theme_active_badge'),
                        icon: Icons.check_circle_rounded,
                        backgroundColor: AppColors.brutalGreen,
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Description & Stats
            Text(
              context.tr(t.descriptionKey),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                if (t.reputationBonus > 0)
                  NeoBrutalBadge(
                    text: '+${t.reputationBonus.toInt()} ${context.tr('lucky_rep_points')}',
                    icon: Icons.stars_rounded,
                    backgroundColor: AppColors.brutalPurple.withValues(alpha: 0.2),
                    textColor: isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE),
                    fontSize: 10,
                  ),
                if (t.minDealershipLevel > 1) ...[
                  const SizedBox(width: 8),
                  NeoBrutalBadge(
                    text: '${context.tr('level_label')} ${t.minDealershipLevel}+',
                    icon: Icons.lock_open_rounded,
                    backgroundColor: meetsLevel ? AppColors.brutalGreen.withValues(alpha: 0.2) : AppColors.errorRed.withValues(alpha: 0.2),
                    textColor: meetsLevel ? (isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)) : AppColors.errorRed,
                    fontSize: 10,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),

            // Action Button
            if (isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.brutalGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brutalGreen, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    context.tr('store_theme_currently_active'),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                  ),
                ),
              )
            else if (isUnlocked)
              NeoBrutalButton(
                label: context.tr('store_btn_activate_theme'),
                icon: Icons.palette_rounded,
                backgroundColor: t.accentColor,
                textColor: Colors.black,
                fontSize: 12.5,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 9),
                onPressed: () {
                  ref.read(gameProvider.notifier).setActiveShowroomTheme(t.id);
                  NotificationService.showSuccess(context, context.tr('store_toast_theme_activated'));
                },
              )
            else
              NeoBrutalButton(
                label: meetsLevel
                    ? context.tr('store_btn_buy_theme', {'cost': CurrencyFormatter.format(t.cost)})
                    : context.tr('store_btn_level_locked', {'lvl': '${t.minDealershipLevel}'}),
                icon: meetsLevel ? Icons.lock_open_rounded : Icons.lock_rounded,
                backgroundColor: meetsLevel ? (canAfford ? t.accentColor : const Color(0xFF64748B)) : const Color(0xFF334155),
                textColor: meetsLevel ? Colors.black : Colors.white,
                fontSize: 12.5,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 9),
                onPressed: (!meetsLevel || !canAfford)
                    ? null
                    : () {
                        final success = ref.read(gameProvider.notifier).purchaseShowroomTheme(t);
                        if (success) {
                          NotificationService.showSuccess(context, context.tr('store_toast_theme_bought'));
                        }
                      },
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 3: ÖZEL ARAÇ KAPLAMALARI (d)
  // ==========================================
  Widget _buildCosmeticsTab(BuildContext context, dynamic game, bool isDark) {
    final paints = CustomPaintFinishModel.getAllPaintFinishes();

    return ListView(
      padding: const EdgeInsets.all(14),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A), width: 2.0),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.brutalPink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                ),
                child: const Icon(Icons.format_paint_rounded, color: Colors.black, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.tr('store_paints_overview_hint'),
                  style: TextStyle(
                    fontSize: 11.5,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        ...paints.map((p) => _buildPaintCard(context, p, game, isDark)),
      ],
    );
  }

  Widget _buildPaintCard(BuildContext context, CustomPaintFinishModel p, dynamic game, bool isDark) {
    final bool isUnlocked = game.unlockedCustomPaintIds.contains(p.id);
    final bool canAfford = game.balance >= p.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: isUnlocked ? AppColors.brutalGreen : const Color(0xFF334155),
        borderWidth: 2.0,
        borderRadius: 14,
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: p.previewColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white70, width: 2.0),
              ),
              child: Icon(p.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr(p.titleKey),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      NeoBrutalBadge(
                        text: '+${((p.valueMultiplier - 1.0) * 100).toInt()}% ${context.tr('store_paint_value_badge')}',
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 9.5,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    context.tr(p.descriptionKey),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isUnlocked)
                    Text(
                      context.tr('store_paint_unlocked_ready'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF10B981)),
                    )
                  else
                    SizedBox(
                      height: 32,
                      child: NeoBrutalButton(
                        label: context.tr('store_btn_unlock_paint', {'cost': CurrencyFormatter.format(p.cost)}),
                        icon: Icons.lock_open_rounded,
                        backgroundColor: canAfford ? AppColors.brutalPink : const Color(0xFF64748B),
                        textColor: Colors.black,
                        fontSize: 11,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        onPressed: !canAfford
                            ? null
                            : () {
                                final success = ref.read(gameProvider.notifier).purchaseCustomPaint(p);
                                if (success) {
                                  NotificationService.showSuccess(context, context.tr('store_toast_paint_bought'));
                                }
                              },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
