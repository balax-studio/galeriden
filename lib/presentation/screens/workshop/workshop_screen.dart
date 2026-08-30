import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/workshop_job_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/neo_brutal_page_background.dart';
import 'widgets/workshop_customer_jobs_tab.dart';
import 'widgets/workshop_garage_repairs_tab.dart';

class WorkshopScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const WorkshopScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends ConsumerState<WorkshopScreen> {
  int _activeTopTab = 0; // 0: Garaj Araçlarım, 1: Müşteri Tamir Kontratları
  List<CustomerRepairJob> _customerJobs = [];

  @override
  void initState() {
    super.initState();
    _activeTopTab = widget.initialTabIndex;
    _customerJobs = CustomerRepairJob.generateRandomJobs(count: 4);
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/workshop')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('workshop_screen_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/workshop',
          featureTitle: context.tr('workshop_screen_title'),
          icon: Icons.build_circle_rounded,
        ),
      );
    }

    final hasMechanic =
        game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
    final hasApprentice =
        game.hiredStaff.any((s) => s.role == StaffRole.apprentice);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('workshop_title'),
        subtitle: context.tr('workshop_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.wrenchRotate,
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.workshop,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
              14, 14, 14, 24 + MediaQuery.paddingOf(context).bottom),
          physics: const BouncingScrollPhysics(),
          children: [
            // 1. Top Segmented Tab Controller
            Row(
              children: [
                Expanded(
                  child: NeoBrutalButton(
                    icon: Icons.directions_car_rounded,
                    label: context.tr('tab_garage_repairs'),
                    backgroundColor: _activeTopTab == 0
                        ? AppColors.brutalYellow
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    textColor: _activeTopTab == 0
                        ? Colors.black
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => setState(() => _activeTopTab = 0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: NeoBrutalButton(
                    icon: Icons.build_rounded,
                    label:
                        '${context.tr('tab_customer_repairs')} • ${_customerJobs.length}',
                    backgroundColor: _activeTopTab == 1
                        ? AppColors.brutalGreen
                        : (isDark ? const Color(0xFF141721) : Colors.white),
                    textColor: _activeTopTab == 1
                        ? Colors.black
                        : (isDark ? Colors.white70 : Colors.black87),
                    fontSize: 11,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    onPressed: () => setState(() => _activeTopTab = 1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 1.1 Staff Synergies Banner
            if (hasMechanic || hasApprentice) ...[
              NeoBrutalCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: AppColors.brutalGreen,
                borderRadius: 10,
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded,
                        color: AppColors.brutalGreen, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hasMechanic && hasApprentice
                            ? context.tr('workshop_staff_synergy_both')
                            : (hasMechanic
                                ? context.tr('workshop_staff_synergy_mechanic')
                                : context
                                    .tr('workshop_staff_synergy_apprentice')),
                        style: const TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 6),
                    NeoBrutalButton(
                      icon: Icons.fastfood_rounded,
                      label: context.tr('workshop_btn_treat_staff'),
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 9.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      onPressed: () {
                        final game = ref.read(gameProvider);
                        if (game.hiredStaff.isEmpty) {
                          NotificationService.showWarning(
                              context, context.tr('staff_no_staff_hired'));
                          return;
                        }
                        if (game.hiredStaff.every((s) => s.morale >= 100)) {
                          NotificationService.showInfo(
                              context, context.tr('staff_morale_already_full'));
                          return;
                        }
                        final success = ref
                            .read(gameProvider.notifier)
                            .treatWorkshopStaffSnack();
                        if (success) {
                          NotificationService.showSuccess(context,
                              context.tr('workshop_toast_staff_morale'));
                          setState(() {});
                        } else {
                          NotificationService.showError(context,
                              context.tr('stock_insufficient_funds_toast'));
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (_activeTopTab == 1)
              WorkshopCustomerJobsTab(initialJobs: _customerJobs)
            else
              const WorkshopGarageRepairsTab(),
          ],
        ),
      ),
    );
  }
}
