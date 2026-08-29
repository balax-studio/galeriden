import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/workshop_job_model.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import 'widgets/animated_order_card.dart';
import 'widgets/barn_find_restoration_sheet.dart';
import 'widgets/order_parts_sheet.dart';
import 'widgets/repair_tier_selection_sheet.dart';
import 'widgets/workshop_equipment_tile.dart';
import 'widgets/workshop_repair_tile.dart';

class WorkshopScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  const WorkshopScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends ConsumerState<WorkshopScreen> {
  CarModel? _selectedCar;
  int _activeTopTab = 0; // 0: Garaj Araçlarım, 1: Müşteri Tamir Kontratları
  List<CustomerRepairJob> _customerJobs = [];

  @override
  void initState() {
    super.initState();
    _activeTopTab = widget.initialTabIndex;
    _customerJobs = CustomerRepairJob.generateRandomJobs(count: 4);
  }

  void _showColorPickerSheet(BuildContext context, CarModel car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF141721) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(context.tr('custom_paint_title'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900))),
                  NeoBrutalBadge(
                      text: context.tr('custom_paint_sub'),
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 10),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('custom_paint_hint'),
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              ...CustomPaintColor.palette.map((paint) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFF8FAFC),
                    borderColor: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFCBD5E1),
                    borderRadius: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: paint.color,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.black, width: 2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      paint.name,
                                      style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      CurrencyFormatter.format(paint.cost),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.brutalOrange),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        NeoBrutalButton(
                          label: context.tr('paint_action_btn'),
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          onPressed: () {
                            Navigator.pop(ctx);
                            final game = ref.read(gameProvider);
                            if (game.balance < paint.cost) {
                              NotificationService.showError(context,
                                  'Yetersiz bakiye! ${CurrencyFormatter.format(paint.cost)} gerekli.');
                              return;
                            }
                            final success = ref
                                .read(gameProvider.notifier)
                                .applyCustomPaintRespray(car.id, paint);
                            if (success) {
                              NotificationService.showSuccess(context,
                                  context.tr('workshop_toast_paint_done'));
                              setState(() {
                                _selectedCar = ref
                                    .read(gameProvider)
                                    .ownedCars
                                    .firstWhere((c) => c.id == car.id,
                                        orElse: () => car);
                              });
                            }
                          },
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
    );
  }

  void _showAcousticDiagnosticDialog(BuildContext context, CarModel car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diagnoses = [
      (
        'Subap ve Piston Vuruntusu',
        'subap',
        'Metalik şıkırtı ve rölantide ritmik tıklama sesi.'
      ),
      (
        'Turbo Şarj Kaçağı ve Islığı',
        'turbo',
        'Hızlanırken gelen yüksek frekanslı hava üfleme sesi.'
      ),
      (
        'Şanzıman Prizdirek Bilyası Uğultusu',
        'sanziman',
        'Debriyaja basınca kesilen kalın dönme uğultusu.'
      ),
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: NeoBrutalCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor:
                isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
            borderRadius: 12,
            borderWidth: 2.5,
            shadowOffset: const Offset(4, 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.hearing_rounded,
                        color: AppColors.brutalOrange, size: 24),
                    const SizedBox(width: 8),
                    Text(context.tr('workshop_engine_diagnose_title'),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${car.brand} ${car.modelName} motor bloğuna stetoskop bağlandı. Arıza sesini dinleyip doğru teşhisi koy:',
                  style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                ...diagnoses.map((d) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        NotificationService.showSuccess(
                          context,
                          'Doğru teşhis: ${d.$1}! Bir sonraki tamirde %25 işçilik indirimi tanımlandı.',
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(10),
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF1F5F9),
                        borderColor: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        borderRadius: 8,
                        borderWidth: 1.5,
                        shadowOffset: const Offset(2, 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.$1,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 2),
                            Text(d.$3,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    NeoBrutalButton(
                      label: context.tr('btn_close'),
                      backgroundColor: isDark
                          ? const Color(0xFF1E2330)
                          : const Color(0xFFE2E8F0),
                      textColor: isDark ? Colors.white : Colors.black,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

    if (game.ownedCars.isNotEmpty && _selectedCar == null) {
      _selectedCar = game.ownedCars.first;
    } else if (game.ownedCars.isNotEmpty && _selectedCar != null) {
      _selectedCar = game.ownedCars.firstWhere(
        (c) => c.id == _selectedCar!.id,
        orElse: () => game.ownedCars.first,
      );
    }

    final hasLift = game.unlockedBuildings.contains('workshop_eq_lift');
    final hasChassisBench =
        game.unlockedBuildings.contains('workshop_eq_chassis_bench');
    final hasPaintBooth =
        game.unlockedBuildings.contains('workshop_eq_paint_booth');
    final paintCostMultiplier = hasPaintBooth ? 0.50 : 1.0;

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
      body: ListView(
        padding: const EdgeInsets.all(14),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        NotificationService.showSuccess(
                            context, context.tr('workshop_toast_staff_morale'));
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

          if (_activeTopTab == 1) ...[
            // ================= MÜŞTERİ TAMİR KONTRATLARI TABI =================
            if (!hasMechanic)
              NeoBrutalCard(
                padding: const EdgeInsets.all(20),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: AppColors.brutalOrange,
                borderRadius: 14,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.brutalOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.brutalOrange, width: 2),
                      ),
                      child: const Icon(Icons.build_circle_rounded,
                          size: 36, color: AppColors.brutalOrange),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('workshop_locked_service_title'),
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.tr('workshop_locked_service_desc'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),
                    NeoBrutalButton(
                      label: context.tr('workshop_btn_hire_mechanic'),
                      icon: Icons.person_add_rounded,
                      backgroundColor: AppColors.brutalYellow,
                      textColor: Colors.black,
                      fontSize: 11,
                      onPressed: () {
                        if (game.isFeatureUnlocked('/staff')) {
                          context.push('/staff');
                        } else {
                          NotificationService.showInfo(
                            context,
                            context.tr('cashflow_locked_feature_toast', {
                              'branch': DealershipModel.getRequiredBranchName(
                                  '/staff', context)
                            }),
                          );
                        }
                      },
                    ),
                  ],
                ),
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      child: Text(
                    context.tr('workshop_customer_repairs_title'),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900),
                  )),
                  NeoBrutalButton(
                    label: context.tr('workshop_btn_scan_jobs'),
                    icon: Icons.refresh_rounded,
                    backgroundColor: isDark
                        ? const Color(0xFF1E2330)
                        : const Color(0xFFE2E8F0),
                    textColor: isDark ? Colors.white : Colors.black,
                    fontSize: 10,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    onPressed: () {
                      setState(() {
                        _customerJobs =
                            CustomerRepairJob.generateRandomJobs(count: 4);
                      });
                      NotificationService.showSuccess(
                          context, 'Yeni müşteri tamir talepleri listelendi!');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (_customerJobs.isEmpty)
                NeoBrutalCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 12,
                  child: Center(
                    child: Text(context.tr('workshop_no_customer_jobs')),
                  ),
                )
              else
                ..._customerJobs.map((job) {
                  final netProfit = job.laborReward - job.partsCost;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(14),
                      backgroundColor:
                          isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A),
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
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.brutalGreen,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    child: Icon(job.jobType.icon,
                                        color: Colors.black, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(job.customerName,
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900)),
                                      Text(job.carModelName,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B),
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ],
                              ),
                              if (job.isUrgent)
                                NeoBrutalBadge(
                                  icon: Icons.bolt_rounded,
                                  text: context.tr('workshop_badge_urgent'),
                                  backgroundColor: AppColors.errorRed,
                                  textColor: Colors.white,
                                  fontSize: 9.5,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF0C0E14)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '"${job.customerStory}"',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontStyle: FontStyle.italic,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      context.tr('workshop_parts_cost', {
                                        'cost': CurrencyFormatter.formatShort(
                                            job.partsCost)
                                      }),
                                      style: const TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                      context.tr('workshop_net_profit', {
                                        'profit':
                                            CurrencyFormatter.format(netProfit)
                                      }),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.brutalGreen)),
                                ],
                              ),
                              NeoBrutalButton(
                                label: context.tr('workshop_repair_earn_btn'),
                                icon: Icons.handshake_rounded,
                                backgroundColor: AppColors.brutalGreen,
                                textColor: Colors.black,
                                fontSize: 11,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                onPressed: () {
                                  final success = ref
                                      .read(gameProvider.notifier)
                                      .completeCustomerRepairJob(job);
                                  if (success) {
                                    NotificationService.showSuccess(
                                      context,
                                      '${job.customerName} aracını teslim aldı! +${CurrencyFormatter.format(netProfit)} net kâr & +${job.masteryXpReward} XP kazanıldı.',
                                    );
                                    setState(() {
                                      _customerJobs
                                          .removeWhere((j) => j.id == job.id);
                                    });
                                  }
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
          ] else ...[
            // ================= GARAJ ARAÇLARIM & ONARIM TABI =================
            if (game.ownedCars.isEmpty)
              NeoBrutalEmptyState(
                icon: Icons.build_circle_rounded,
                accentColor: const Color(0xFFFF7A00),
                badgeText: context.tr('workshop_empty_badge'),
                title: context.tr('workshop_empty_title'),
                description: context.tr('workshop_empty_desc'),
                actionLabel: context.tr('car_wash_btn_go_market'),
                actionIcon: Icons.storefront_rounded,
                onActionPressed: () => context.push('/marketplace'),
              )
            else ...[
              // VIP Tuning Banner Nav
              NeoBrutalCard(
                padding: const EdgeInsets.all(12),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                              color: AppColors.brutalYellow,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: const Icon(Icons.speed_rounded,
                                color: Colors.black, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(context.tr('workshop_tuning_studio_title'),
                                    style: const TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900)),
                                Text(
                                    context
                                        .tr('workshop_tuning_studio_subtitle'),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    NeoBrutalButton(
                      label: game.isFeatureUnlocked('/tuning-studio')
                          ? context.tr('workshop_btn_tuning_enter')
                          : context.tr('locked_badge'),
                      backgroundColor: game.isFeatureUnlocked('/tuning-studio')
                          ? AppColors.brutalYellow
                          : const Color(0xFF64748B),
                      textColor: game.isFeatureUnlocked('/tuning-studio')
                          ? Colors.black
                          : Colors.white,
                      fontSize: 10.5,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      onPressed: () {
                        if (game.isFeatureUnlocked('/tuning-studio')) {
                          context.push('/tuning-studio');
                        } else {
                          NotificationService.showInfo(
                            context,
                            context.tr('cashflow_locked_feature_toast', {
                              'branch': DealershipModel.getRequiredBranchName(
                                  '/tuning-studio', context)
                            }),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Car Selector Carousel
              Text(
                context.tr('workshop_select_car_title',
                    {'count': game.ownedCars.length.toString()}),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 94,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: game.ownedCars.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final car = game.ownedCars[index];
                    final isSelected = _selectedCar?.id == car.id;
                    final exp = car.expertise;
                    final isPerfect = exp.engineCondition >= 95 &&
                        exp.transmissionCondition >= 95;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCar = car),
                      child: Container(
                        width: 190,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFFEF3C7))
                              : (isDark
                                  ? const Color(0xFF141721)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF7A00)
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFF0F172A)),
                            width: isSelected ? 2.5 : 2.0,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(car.brand,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF64748B)),
                                maxLines: 1),
                            Text(car.modelName,
                                style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: NeoBrutalBadge(
                                    text: isPerfect
                                        ? context.tr('workshop_badge_perfect')
                                        : context.tr(
                                            'workshop_badge_engine_cond', {
                                            'val': exp.engineCondition
                                                .toInt()
                                                .toString()
                                          }),
                                    backgroundColor: isPerfect
                                        ? const Color(0xFF00E575)
                                        : const Color(0xFFFF7A00),
                                    textColor: Colors.black,
                                    fontSize: 8.5,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                    child: Text(
                                        CurrencyFormatter.formatShort(
                                            car.baseMarketValue),
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900))),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Active Vehicle Mechanical Diagnosis Card
              if (_selectedCar != null) ...[
                NeoBrutalCard(
                  padding: const EdgeInsets.all(14),
                  backgroundColor:
                      isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark
                      ? const Color(0xFF2A3142)
                      : const Color(0xFF0F172A),
                  borderRadius: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: const Icon(Icons.car_repair_rounded,
                                color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${_selectedCar!.brand} ${_selectedCar!.modelName}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900)),
                                const SizedBox(height: 2),
                                Text(
                                  '${context.tr('car_card_market_value')}: ${CurrencyFormatter.format(_selectedCar!.estimatedRealValue)} • ${context.tr('workshop_badge_perfect')}: ${CurrencyFormatter.formatShort(_selectedCar!.baseMarketValue)} • ${_selectedCar!.modelYear}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Gauges
                      Row(
                        children: [
                          Expanded(
                            child: _buildHealthBar(
                              label: context.tr('car_expertise_engine'),
                              percent: _selectedCar!.expertise.engineCondition,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildHealthBar(
                              label: context.tr('car_expertise_transmission'),
                              percent:
                                  _selectedCar!.expertise.transmissionCondition,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // RPG Quick Action Buttons (10.000 KM Bakım, Renk Değişimi, Motor Dinleme)
                      Row(
                        children: [
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.oil_barrel_rounded,
                              label: _selectedCar!.isPeriodicMaintained
                                  ? context.tr('workshop_btn_10k_maintained')
                                  : context.tr('workshop_btn_10k_service'),
                              backgroundColor:
                                  _selectedCar!.isPeriodicMaintained
                                      ? const Color(0xFF1E2330)
                                      : AppColors.brutalYellow,
                              textColor: _selectedCar!.isPeriodicMaintained
                                  ? (isDark ? Colors.white54 : Colors.black54)
                                  : Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: _selectedCar!.isPeriodicMaintained
                                  ? null
                                  : () {
                                      if (game.balance < 3500) {
                                        NotificationService.showError(context,
                                            'Yetersiz bakiye! ₺3.500 gerekli.');
                                        return;
                                      }
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .performPeriodicMaintenance(
                                              _selectedCar!.id);
                                      if (success) {
                                        NotificationService.showSuccess(context,
                                            'Yağ, buji ve filtreler yenilendi • +%15 Kondisyon!');
                                        setState(() {
                                          _selectedCar = ref
                                              .read(gameProvider)
                                              .ownedCars
                                              .firstWhere(
                                                  (c) =>
                                                      c.id == _selectedCar!.id,
                                                  orElse: () => _selectedCar!);
                                        });
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.palette_rounded,
                              label: context.tr('workshop_btn_paint_oven'),
                              backgroundColor: const Color(0xFFA855F7),
                              textColor: Colors.white,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: () =>
                                  _showColorPickerSheet(context, _selectedCar!),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.hearing_rounded,
                              label: context.tr('workshop_btn_engine_listen'),
                              backgroundColor: const Color(0xFF06B6D4),
                              textColor: Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: () => _showAcousticDiagnosticDialog(
                                  context, _selectedCar!),
                            ),
                          ),
                        ],
                      ),
                      // Row 2 RPG Quick Action Buttons (Boyasız Göçük PDR, TÜVTÜRK Muayene)
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.hardware_rounded,
                              label: _selectedCar!.hasPdrRepaired
                                  ? context.tr('workshop_pdr_done')
                                  : context.tr('workshop_btn_pdr'),
                              backgroundColor: _selectedCar!.hasPdrRepaired
                                  ? const Color(0xFF1E2330)
                                  : const Color(0xFF00E575),
                              textColor: _selectedCar!.hasPdrRepaired
                                  ? (isDark ? Colors.white54 : Colors.black54)
                                  : Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: _selectedCar!.hasPdrRepaired
                                  ? null
                                  : () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .performPdrDentRepair(
                                              _selectedCar!.id);
                                      if (success) {
                                        NotificationService.showSuccess(context,
                                            'Boyasız Göçük Düzeltme ile kaporta orijinalliği korundu • +%6 Değer!');
                                        setState(() {
                                          _selectedCar = ref
                                              .read(gameProvider)
                                              .ownedCars
                                              .firstWhere(
                                                  (c) =>
                                                      c.id == _selectedCar!.id,
                                                  orElse: () => _selectedCar!);
                                        });
                                      } else {
                                        NotificationService.showError(context,
                                            'Yetersiz bakiye! ₺3.200 gerekli.');
                                      }
                                    },
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: NeoBrutalButton(
                              icon: Icons.verified_rounded,
                              label: _selectedCar!.hasTuvturkCertified
                                  ? context.tr('workshop_tuvturk_certified')
                                  : context.tr('workshop_btn_tuvturk'),
                              backgroundColor: _selectedCar!.hasTuvturkCertified
                                  ? const Color(0xFF1E2330)
                                  : const Color(0xFF38BDF8),
                              textColor: _selectedCar!.hasTuvturkCertified
                                  ? (isDark ? Colors.white54 : Colors.black54)
                                  : Colors.black,
                              fontSize: 10,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              onPressed: _selectedCar!.hasTuvturkCertified
                                  ? null
                                  : () {
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .certifyTuvturkInspection(
                                              _selectedCar!.id);
                                      if (success) {
                                        NotificationService.showSuccess(
                                            context,
                                            context.tr(
                                                'workshop_toast_tuvturk_done'));
                                        setState(() {
                                          _selectedCar = ref
                                              .read(gameProvider)
                                              .ownedCars
                                              .firstWhere(
                                                  (c) =>
                                                      c.id == _selectedCar!.id,
                                                  orElse: () => _selectedCar!);
                                        });
                                      } else {
                                        NotificationService.showError(context,
                                            'Yetersiz bakiye! ₺1.500 gerekli.');
                                      }
                                    },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (_selectedCar!.isBarnFind) ...[
                        NeoBrutalButton(
                          label: context.tr('workshop_btn_barn_find', {
                            'stage': _selectedCar!.barnFindStage.toString()
                          }),
                          icon: Icons.auto_fix_high_rounded,
                          backgroundColor: const Color(0xFFA855F7),
                          textColor: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          fullWidth: true,
                          onPressed: () => BarnFindRestorationSheet.show(
                              context, _selectedCar!),
                        ),
                        const SizedBox(height: 8),
                      ],

                      NeoBrutalButton(
                        label: context.tr('workshop_btn_order_parts'),
                        icon: Icons.local_shipping_rounded,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFE2E8F0),
                        textColor: isDark ? Colors.white : Colors.black,
                        fontSize: 10.5,
                        fullWidth: true,
                        onPressed: () => OrderPartsSheet.show(
                          context: context,
                          car: _selectedCar!,
                          game: game,
                          onOrderConfirmed:
                              (partName, type, cost, durationSeconds) {
                            if (game.balance < cost) {
                              NotificationService.showError(context,
                                  'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekli.');
                              return;
                            }
                            final success =
                                ref.read(gameProvider.notifier).orderPart(
                                      carId: _selectedCar!.id,
                                      partName: partName,
                                      orderType: type,
                                      cost: cost,
                                      deliveryDurationSeconds: durationSeconds,
                                    );
                            if (success) {
                              NotificationService.showSuccess(
                                context,
                                context.tr('workshop_toast_order_dispatched'),
                              );
                              setState(() {});
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Five Specialized Repair Stations
              Text(
                context.tr('workshop_stations_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              Builder(
                builder: (context) {
                  final exp = _selectedCar?.expertise;
                  final isEngineRepaired =
                      (exp?.engineCondition ?? 100.0) >= 95.0;
                  final isTransmissionRepaired =
                      (exp?.transmissionCondition ?? 100.0) >= 95.0;
                  final isEcuRepaired = exp?.isEcuCleaned ?? false;
                  final isBodyworkRepaired = !(exp?.bodyParts.values
                          .any((v) => v != PartStatus.original) ??
                      false);
                  final isChassisRepaired = exp?.isChassisAligned ?? false;

                  final carBaseVal = _selectedCar != null
                      ? max(150000.0, _selectedCar!.baseMarketValue.toDouble())
                      : 400000.0;
                  final dynamicEngineCost =
                      (carBaseVal * 0.035).clamp(8500.0, 75000.0);
                  final dynamicTransCost =
                      (carBaseVal * 0.025).clamp(6500.0, 50000.0);
                  final dynamicEcuCost =
                      (carBaseVal * 0.010).clamp(2500.0, 20000.0);
                  final dynamicBodyCost =
                      (carBaseVal * 0.045 * paintCostMultiplier)
                          .clamp(12000.0, 90000.0);
                  final dynamicChassisCost =
                      (carBaseVal * 0.065).clamp(25000.0, 150000.0);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WorkshopRepairTile(
                        title: '1. Motor Rektifiye & Subap Ayarı',
                        description:
                            'Piston, segman ve subapları yenileyerek motor kondisyonunu %100 yapar.',
                        cost: dynamicEngineCost,
                        bonusText: 'Motor %100 & +%10 Değer',
                        netRoiText: _selectedCar != null
                            ? PsychologyEngine.getNetRoiRepairText(
                                dynamicEngineCost,
                                _selectedCar!.estimatedRealValue * 0.10)
                            : null,
                        badgeColor: const Color(0xFF00E575),
                        isDark: isDark,
                        isRepaired: isEngineRepaired,
                        disabledLabel: 'GEREKLİ DEĞİL • MOTOR KUSURSUZ',
                        onRepair: () => RepairTierSelectionSheet.show(
                          context: context,
                          car: _selectedCar!,
                          repairType: 'engine',
                          baseCost: dynamicEngineCost,
                          onTierSelected: (tier, cost) => _executeTierRepair(
                              _selectedCar!, 'engine', tier, cost),
                        ),
                        onAdRepair: () {
                          AdService.instance.showRewardedAdWithFallback(
                            context: context,
                            customRewardTitle: 'Ücretsiz Motor Rektifiye',
                            onRewardEarned: () {
                              final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
                                _selectedCar!.id,
                                repairType: 'engine',
                                cost: 0.0,
                              );
                              if (success) {
                                NotificationService.showSuccess(context, 'Motor ücretsiz rektifiye edildi! Kondisyon %100.');
                                setState(() {
                                  _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id, orElse: () => _selectedCar!);
                                });
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      WorkshopRepairTile(
                        title: '2. Şanzıman & Baskı Balata Yenileme',
                        description:
                            'Vites geçişlerini pürüzsüzleştirir, debriyaj setini sıfırlar.',
                        cost: dynamicTransCost,
                        bonusText: 'Şanzıman %100 & +%8 Değer',
                        netRoiText: _selectedCar != null
                            ? PsychologyEngine.getNetRoiRepairText(
                                dynamicTransCost,
                                _selectedCar!.estimatedRealValue * 0.08)
                            : null,
                        badgeColor: const Color(0xFF38BDF8),
                        isDark: isDark,
                        isRepaired: isTransmissionRepaired,
                        disabledLabel: 'GEREKLİ DEĞİL • ŞANZIMAN KUSURSUZ',
                        onRepair: () => RepairTierSelectionSheet.show(
                          context: context,
                          car: _selectedCar!,
                          repairType: 'transmission',
                          baseCost: dynamicTransCost,
                          onTierSelected: (tier, cost) => _executeTierRepair(
                              _selectedCar!, 'transmission', tier, cost),
                        ),
                        onAdRepair: () {
                          AdService.instance.showRewardedAdWithFallback(
                            context: context,
                            customRewardTitle: 'Ücretsiz Şanzıman Yenileme',
                            onRewardEarned: () {
                              final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
                                _selectedCar!.id,
                                repairType: 'transmission',
                                cost: 0.0,
                              );
                              if (success) {
                                NotificationService.showSuccess(context, 'Şanzıman ücretsiz yenilendi! Kondisyon %100.');
                                setState(() {
                                  _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id, orElse: () => _selectedCar!);
                                });
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      WorkshopRepairTile(
                        title: '3. Bilgisayarlı OBD-II Beyin Arıza Tespiti',
                        description:
                            'Tüm sensör, enjektör ve gizli elektriksel arıza kodlarını siler.',
                        cost: dynamicEcuCost,
                        bonusText: 'Gizli Kusurlar Silinir',
                        netRoiText: _selectedCar != null
                            ? PsychologyEngine.getNetRoiRepairText(
                                dynamicEcuCost,
                                _selectedCar!.estimatedRealValue * 0.05)
                            : null,
                        badgeColor: const Color(0xFFA855F7),
                        isDark: isDark,
                        isRepaired: isEcuRepaired,
                        disabledLabel: 'GEREKLİ DEĞİL • ARIZA YOK',
                        onRepair: () => RepairTierSelectionSheet.show(
                          context: context,
                          car: _selectedCar!,
                          repairType: 'ecu',
                          baseCost: dynamicEcuCost,
                          onTierSelected: (tier, cost) => _executeTierRepair(
                              _selectedCar!, 'ecu', tier, cost),
                        ),
                        onAdRepair: () {
                          AdService.instance.showRewardedAdWithFallback(
                            context: context,
                            customRewardTitle: 'Ücretsiz Beyin Arıza Tespiti',
                            onRewardEarned: () {
                              final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
                                _selectedCar!.id,
                                repairType: 'ecu',
                                cost: 0.0,
                              );
                              if (success) {
                                NotificationService.showSuccess(context, 'Gizli arızalar ücretsiz silindi!');
                                setState(() {
                                  _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id, orElse: () => _selectedCar!);
                                });
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      WorkshopRepairTile(
                        title: '4. Kaporta Çekiçleme & Fırın Boya',
                        description:
                            'Değişen veya boyalı kaporta parçalarını fabrika kondisyonuna getirir.',
                        cost: dynamicBodyCost,
                        bonusText: hasPaintBooth
                            ? '+%15 Değer • Boya Fırını İndirimi'
                            : '+%15 Değer Artışı',
                        netRoiText: _selectedCar != null
                            ? PsychologyEngine.getNetRoiRepairText(
                                dynamicBodyCost,
                                _selectedCar!.estimatedRealValue * 0.15)
                            : null,
                        badgeColor: const Color(0xFFFFDE59),
                        isDark: isDark,
                        isRepaired: isBodyworkRepaired,
                        disabledLabel: 'GEREKLİ DEĞİL • KAPORTA KUSURSUZ',
                        onRepair: () => RepairTierSelectionSheet.show(
                          context: context,
                          car: _selectedCar!,
                          repairType: 'bodywork',
                          baseCost: dynamicBodyCost,
                          onTierSelected: (tier, cost) => _executeTierRepair(
                              _selectedCar!, 'bodywork', tier, cost),
                        ),
                        onAdRepair: () {
                          AdService.instance.showRewardedAdWithFallback(
                            context: context,
                            customRewardTitle: 'Ücretsiz Kaporta & Boya',
                            onRewardEarned: () {
                              final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
                                _selectedCar!.id,
                                repairType: 'bodywork',
                                cost: 0.0,
                              );
                              if (success) {
                                NotificationService.showSuccess(context, 'Kaporta kusurları ücretsiz onarıldı!');
                                setState(() {
                                  _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id, orElse: () => _selectedCar!);
                                });
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      WorkshopRepairTile(
                        title: '5. Lazerli Şasi Düzeltme & Rot-Balans',
                        description:
                            'Ağır kazalı, podye veya direk hasarlı araçların şasisini sıfır toleransla doğrultur.',
                        cost: dynamicChassisCost,
                        bonusText: hasChassisBench
                            ? '+%20 Süper Değer • Şasi Tezgahı Bonusu'
                            : '+%20 Değer',
                        netRoiText: _selectedCar != null
                            ? PsychologyEngine.getNetRoiRepairText(
                                dynamicChassisCost,
                                _selectedCar!.estimatedRealValue * 0.20)
                            : null,
                        badgeColor: const Color(0xFFEF4444),
                        isDark: isDark,
                        isRepaired: isChassisRepaired,
                        disabledLabel: 'GEREKLİ DEĞİL • ŞASİ SAĞLAM',
                        onRepair: () => RepairTierSelectionSheet.show(
                          context: context,
                          car: _selectedCar!,
                          repairType: 'chassis',
                          baseCost: dynamicChassisCost,
                          onTierSelected: (tier, cost) => _executeTierRepair(
                              _selectedCar!, 'chassis', tier, cost),
                        ),
                        onAdRepair: () {
                          AdService.instance.showRewardedAdWithFallback(
                            context: context,
                            customRewardTitle: 'Ücretsiz Şasi Düzeltme',
                            onRewardEarned: () {
                              final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
                                _selectedCar!.id,
                                repairType: 'chassis',
                                cost: 0.0,
                              );
                              if (success) {
                                NotificationService.showSuccess(context, 'Şasi sıfır toleransla ücretsiz doğrultuldu!');
                                setState(() {
                                  _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == _selectedCar!.id, orElse: () => _selectedCar!);
                                });
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Pending Part Orders
              if (game.pendingOrders.isNotEmpty) ...[
                Text(
                  context.tr('workshop_pending_orders_title',
                      {'count': game.pendingOrders.length.toString()}),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                ...game.pendingOrders.map((order) {
                  return AnimatedOrderCard(
                    order: order,
                    p: p,
                    onInstall: () {
                      final success = ref
                          .read(gameProvider.notifier)
                          .installDeliveredPart(order.id);
                      if (success) {
                        NotificationService.showSuccess(
                            context, '${order.partName} montajı tamamlandı!');
                        setState(() {});
                      }
                    },
                    onFastDeliverWithAd: () {
                      AdService.instance.showRewardedAdWithFallback(
                        context: context,
                        customRewardTitle: 'Hızlı Kargo Teslimatı',
                        onRewardEarned: () {
                          ref
                              .read(gameProvider.notifier)
                              .instantDeliverPartOrder(order.id);
                          NotificationService.showReward(context,
                              context.tr('workshop_toast_fast_shipping'));
                          setState(() {});
                        },
                      );
                    },
                  );
                }),
                const SizedBox(height: 16),
              ],

              // Salvaged Parts
              if (game.salvagedParts.isNotEmpty) ...[
                Text(
                  context.tr('workshop_salvaged_parts_title',
                      {'count': game.salvagedParts.length.toString()}),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                ...game.salvagedParts.map((part) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor:
                          isDark ? const Color(0xFF141721) : Colors.white,
                      borderColor: isDark
                          ? const Color(0xFF2A3142)
                          : const Color(0xFF0F172A),
                      borderRadius: 12,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF64748B),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF333B4F)
                                    : const Color(0xFF0F172A),
                                width: 2.0,
                              ),
                            ),
                            child: const Icon(Icons.settings_suggest_rounded,
                                color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(part.name,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900)),
                                Text(
                                  'Kondisyon: %${part.conditionPercent} • Tahmini Değer: ${CurrencyFormatter.format(part.estimatedValue)}',
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
                            label: context.tr('workshop_btn_install_salvage'),
                            icon: Icons.build_rounded,
                            backgroundColor: const Color(0xFF00E575),
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            onPressed: () {
                              if (_selectedCar == null) return;
                              final success = ref
                                  .read(gameProvider.notifier)
                                  .installPartToCar(part.id, _selectedCar!.id);
                              if (success) {
                                NotificationService.showSuccess(
                                    context,
                                    context
                                        .tr('workshop_toast_part_installed'));
                                setState(() {});
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // Equipment Upgrades
              Text(
                context.tr('workshop_equipment_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              WorkshopEquipmentTile(
                id: 'workshop_eq_lift',
                title: '4 Tonluk Hidrolik Araç Lifti',
                description:
                    'Aynı anda birden fazla aracın alt takımlarını hızlıca onarabilme imkanı sağlar.',
                cost: 85000.0,
                isOwned: hasLift,
                icon: Icons.elevator_rounded,
                color: const Color(0xFFFF7A00),
                isDark: isDark,
                onBuy: () => _buyEquipment('workshop_eq_lift', 85000.0,
                    '4 Tonluk Hidrolik Araç Lifti'),
              ),
              const SizedBox(height: 8),

              WorkshopEquipmentTile(
                id: 'workshop_eq_chassis_bench',
                title: 'Lazerli Şasi Doğrultma Tezgahı',
                description:
                    'Ağır kazalı pert araçların şasilerini milimetrik hassasiyetle fabrikasyon standardına çevirir.',
                cost: 220000.0,
                isOwned: hasChassisBench,
                icon: Icons.straighten_rounded,
                color: const Color(0xFFEF4444),
                isDark: isDark,
                onBuy: () => _buyEquipment('workshop_eq_chassis_bench',
                    220000.0, 'Lazerli Şasi Doğrultma Tezgahı'),
              ),
              const SizedBox(height: 8),

              WorkshopEquipmentTile(
                id: 'workshop_eq_paint_booth',
                title: 'Filtreli Endüstriyel Fırın Boya Kabini',
                description:
                    'Kaporta ve boya işlemlerinde sarfiyatı azaltarak tüm boya maliyetlerini kalıcı olarak %50 düşürür.',
                cost: 450000.0,
                isOwned: hasPaintBooth,
                icon: Icons.format_paint_rounded,
                color: const Color(0xFFFFDE59),
                isDark: isDark,
                onBuy: () => _buyEquipment('workshop_eq_paint_booth', 450000.0,
                    'Filtreli Endüstriyel Fırın Boya Kabini'),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildHealthBar({
    required String label,
    required double percent,
    required bool isDark,
  }) {
    final color = percent >= 80
        ? const Color(0xFF00E575)
        : (percent >= 50 ? const Color(0xFFFFDE59) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          fontSize: 10.5, fontWeight: FontWeight.w800))),
              Expanded(
                  child: Text('%${percent.toInt()}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: color))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (percent / 100).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _buyEquipment(String eqId, double cost, String name) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(context,
          'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    final success =
        ref.read(gameProvider.notifier).purchaseEquipmentUpgrade(eqId, cost);
    if (success) {
      NotificationService.showReward(
          context, context.tr('workshop_toast_equip_installed'));
      setState(() {});
    }
  }

  void _executeTierRepair(
      CarModel car, String repairType, RepairTier tier, double cost) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(context,
          'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    if (repairType == 'engine') {
      if (car.expertise.engineCondition >= 99.5) {
        NotificationService.showInfo(context, 'Motor zaten kusursuz durumda!');
        return;
      }
      if (tier == RepairTier.master &&
          !game.unlockedBuildings.contains('workshop_eq_lift')) {
        NotificationService.showError(
            context, context.tr('workshop_toast_lift_req'));
        return;
      }
      final result =
          ref.read(gameProvider.notifier).repairEngineWithTier(car, tier);
      if (result.isSuccess) {
        NotificationService.showSuccess(context, result.message);
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      } else {
        NotificationService.showError(context, result.message);
      }
    } else if (repairType == 'transmission') {
      if (car.expertise.transmissionCondition >= 99.5) {
        NotificationService.showInfo(
            context, 'Şanzıman ve baskı balata zaten kusursuz durumda!');
        return;
      }
      if (tier == RepairTier.master &&
          !game.unlockedBuildings.contains('workshop_eq_lift')) {
        NotificationService.showError(
            context, context.tr('workshop_toast_lift_req'));
        return;
      }
      final result =
          ref.read(gameProvider.notifier).repairTransmissionWithTier(car, tier);
      if (result.isSuccess) {
        NotificationService.showSuccess(context, result.message);
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      } else {
        NotificationService.showError(context, result.message);
      }
    } else if (repairType == 'bodywork') {
      final nonOriginalParts = car.expertise.bodyParts.entries
          .where((e) => e.value != PartStatus.original)
          .map((e) => e.key)
          .toList();

      if (nonOriginalParts.isEmpty) {
        NotificationService.showInfo(
            context, 'Kaportada hasarlı veya boyanacak parça yok!');
        return;
      }

      final hasMechanic =
          game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final double successRate =
          hasMechanic ? 1.0 : RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(context,
            'Boya fırınında renk dalgalanması oldu! ₺${CurrencyFormatter.formatShort(cost * 0.4)} sarfiyat yandı.');
        return;
      }

      final success =
          ref.read(gameProvider.notifier).performWorkshopStationRepair(
                car.id,
                repairType: 'bodywork',
                cost: cost,
              );

      if (success) {
        NotificationService.showSuccess(
            context, context.tr('workshop_toast_body_all_done'));
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    } else if (repairType == 'ecu') {
      if (car.expertise.isEcuCleaned) {
        NotificationService.showInfo(context,
            'OBD-II Beyin arıza tespiti zaten yapılmış, sistem kusursuz!');
        return;
      }
      final hasMechanic =
          game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final double successRate =
          hasMechanic ? 1.0 : RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(context,
            'ECU haberleşme protokolü kurulamadı! ₺${CurrencyFormatter.formatShort(cost * 0.4)} sarfiyat yandı.');
        return;
      }
      final success =
          ref.read(gameProvider.notifier).performWorkshopStationRepair(
                car.id,
                repairType: 'ecu',
                cost: cost,
              );
      if (success) {
        NotificationService.showSuccess(
            context, context.tr('workshop_toast_ecu_done'));
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    } else if (repairType == 'chassis') {
      if (car.expertise.isChassisAligned) {
        NotificationService.showInfo(
            context, 'Lazerli şasi doğrultma zaten yapılmış, şasi kusursuz!');
        return;
      }
      final hasMechanic =
          game.hiredStaff.any((s) => s.role == StaffRole.masterMechanic);
      final double successRate =
          hasMechanic ? 1.0 : RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(context,
            'Lazerli şasi tezgahında sıfır tolerans tutturulamadı! ₺${CurrencyFormatter.formatShort(cost * 0.4)} sarfiyat yandı.');
        return;
      }
      final success =
          ref.read(gameProvider.notifier).performWorkshopStationRepair(
                car.id,
                repairType: 'chassis',
                cost: cost,
              );
      if (success) {
        NotificationService.showSuccess(
            context, context.tr('workshop_toast_chassis_done'));
        setState(() {
          _selectedCar = ref
              .read(gameProvider)
              .ownedCars
              .firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    }
  }
}
