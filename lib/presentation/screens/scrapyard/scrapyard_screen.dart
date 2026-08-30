import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/rust_oil_drop_widget.dart';
import 'widgets/scrapyard_b2b_orders_tab.dart';
import 'widgets/scrapyard_salvaged_parts_tab.dart';
import 'widgets/scrapyard_scrap_cars_tab.dart';

class ScrapyardScreen extends ConsumerStatefulWidget {
  const ScrapyardScreen({super.key});

  @override
  ConsumerState<ScrapyardScreen> createState() => _ScrapyardScreenState();
}

class _ScrapyardScreenState extends ConsumerState<ScrapyardScreen>
    with SingleTickerProviderStateMixin {
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
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/scrapyard')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('scrapyard')),
        body: NeoBrutalLockedFeatureView(
          route: '/scrapyard',
          featureTitle: context.tr('scrap_screen_title'),
          icon: Icons.delete_outline_rounded,
        ),
      );
    }

    final scrapCars = game.scrapyardCars;
    final salvagedParts = game.salvagedParts;
    final b2bOrders = game.b2bPartOrders.where((o) => !o.isCompleted).toList();

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('scrapyard'),
        subtitle: context.tr('scrapyard_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.pressSlam,
        statusBadge: const NeoBrutalBadge(
          text: 'TAZE ENKAZ',
          backgroundColor: AppColors.brutalOrange,
          textColor: Colors.black,
          fontSize: 9.5,
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14),
            child: RustOilDropWidget(size: 20),
          ),
        ],
        bottom: NeoBrutalTabBar(
          controller: _tabController,
          tabs: [
            context.tr('scrap_tab_scrap_cars',
                {'count': '${scrapCars.where((c) => !c.isPurchased).length}'}),
            context.tr('scrap_tab_salvaged_parts',
                {'count': '${salvagedParts.length}'}),
            context
                .tr('scrap_tab_b2b_orders', {'count': '${b2bOrders.length}'}),
          ],
        ),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.scrapyard,
        child: TabBarView(
          controller: _tabController,
          children: const [
            ScrapyardScrapCarsTab(),
            ScrapyardSalvagedPartsTab(),
            ScrapyardB2BOrdersTab(),
          ],
        ),
      ),
    );
  }
}
