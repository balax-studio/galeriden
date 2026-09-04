import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/vehicle_category.dart';
import '../../../data/models/car_wash_job_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_page_background.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/mini_games/car_wash_canvas.dart';
import '../../../domain/usecases/operation_suspense_engine.dart';
import '../../widgets/dialogs/neo_brutal_operation_dialog.dart';

class CarWashScreen extends ConsumerStatefulWidget {
  const CarWashScreen({super.key});

  @override
  ConsumerState<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends ConsumerState<CarWashScreen> {
  String? _selectedCarId;
  int _activeTopTab =
      0; // 0: Garaj Araçlarım & Detailing, 1: Müşteri Yıkama Talepleri
  List<CustomerWashJob> _customerWashJobs = [];
  String? _loadingServiceId;

  @override
  void initState() {
    super.initState();
    _customerWashJobs = CustomerWashJob.generateRandomJobs(count: 4);
  }

  void _showScentSelectionSheet(BuildContext context, CarModel car) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang = Localizations.localeOf(context).languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141721) : Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.5,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          context.tr('wash_scent_title'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                      ),
                      NeoBrutalBadge(
                        text: context.tr('wash_scent_sub'),
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('wash_scent_hint'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...CarScent.availableScents.map((scent) {
                    final isCurrent = car.appliedScentId == scent.id;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(10),
                        backgroundColor: isDark
                            ? const Color(0xFF1E2330)
                            : const Color(0xFFF8FAFC),
                        borderColor: isDark
                            ? const Color(0xFF333B4F)
                            : const Color(0xFF0F172A),
                        borderRadius: 10,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: scent.badgeColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Colors.black, width: 1.5),
                                    ),
                                    child: Icon(scent.icon,
                                        color: Colors.black, size: 20),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                scent.getLocalizedName(lang),
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.w900),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            NeoBrutalBadge(
                                              text: scent.buyerAppealBuff,
                                              backgroundColor:
                                                  scent.badgeColor,
                                              textColor: Colors.black,
                                              fontSize: 8.5,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${scent.getLocalizedDescription(lang)} • ${CurrencyFormatter.format(scent.cost)}',
                                          style: const TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton(
                              label: isCurrent
                                  ? context.tr('btn_scent_hung')
                                  : context.tr('btn_hang_scent'),
                              backgroundColor: isCurrent
                                  ? const Color(0xFF00E575)
                                  : AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 10.5,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              onPressed: isCurrent
                                  ? null
                                  : () {
                                      Navigator.pop(ctx);
                                      final game = ref.read(gameProvider);
                                      if (game.balance < scent.cost) {
                                        NotificationService.showError(
                                          context,
                                          context.tr(
                                            'toast_insufficient_balance_needed',
                                            {
                                              'cost': CurrencyFormatter.format(
                                                  scent.cost)
                                            },
                                          ),
                                        );
                                        return;
                                      }
                                      final success = ref
                                          .read(gameProvider.notifier)
                                          .applyCarScent(car.id, scent);
                                      if (success) {
                                        NotificationService.showSuccess(
                                            context,
                                            context.tr('wash_toast_scent'));
                                        setState(() {});
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
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>();
    final isDark = themeExt?.palette.isDark ??
        (Theme.of(context).brightness == Brightness.dark);

    if (!game.isFeatureUnlocked('/car-wash')) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: NeoBrutalAppBar(title: context.tr('car_wash_title')),
        body: NeoBrutalLockedFeatureView(
          route: '/car-wash',
          featureTitle: context.tr('car_wash_title'),
          icon: Icons.local_car_wash_rounded,
        ),
      );
    }

    final hasHotWaterGun = game.unlockedBuildings.contains('wash_eq_hot_water');
    final hasFoamPump = game.unlockedBuildings.contains('wash_eq_foam_pump');
    final hasPolisher =
        game.unlockedBuildings.contains('wash_eq_dual_polisher');
    final discountMultiplier = hasFoamPump ? 0.70 : 1.0;

    CarModel? selectedCar;
    if (game.ownedCars.isNotEmpty) {
      selectedCar = game.ownedCars.firstWhere(
        (c) => c.id == _selectedCarId,
        orElse: () => game.ownedCars.first,
      );
      _selectedCarId = selectedCar.id;
    }

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('car_wash_title'),
        subtitle: context.tr('car_wash_slug'),
        headerAnimation: NeoBrutalHeaderAnimation.waterBubbles,
        statusBadge: NeoBrutalBadge(
          text: context.tr('car_wash_foam_full'),
          backgroundColor: const Color(0xFF38BDF8),
          textColor: Colors.black,
          fontSize: 9.5,
        ),
      ),
      body: NeoBrutalPageBackground(
        watermark: ThematicWatermarkType.carWash,
        child: ListView(
          padding: const EdgeInsets.all(14),
          physics: const BouncingScrollPhysics(),
          children: [
          // 1. Top Segmented Tab Controller
          Row(
            children: [
              Expanded(
                child: NeoBrutalButton(
                  icon: Icons.directions_car_rounded,
                  label: context.tr('tab_garage_wash'),
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
                  icon: Icons.local_taxi_rounded,
                  label:
                      '${context.tr('tab_customer_wash')} • ${_customerWashJobs.length}',
                  backgroundColor: _activeTopTab == 1
                      ? const Color(0xFF00E575)
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

          if (_activeTopTab == 1) ...[
            // ================= MÜŞTERİ YIKAMA TALEPLERİ TABI =================
            Builder(
              builder: (context) {
                final hasWasherStaff =
                    game.hiredStaff.any((s) => s.role == StaffRole.washer);
                final hasWashBusiness = game.sideBusinesses.any(
                    (b) => b.type == SideBusinessType.carWash && b.isOperational);

                if (!hasWasherStaff && !hasWashBusiness) {
                  return NeoBrutalCard(
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
                            color:
                                AppColors.brutalOrange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.brutalOrange, width: 2),
                          ),
                          child: const Icon(Icons.lock_rounded,
                              size: 36, color: AppColors.brutalOrange),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('car_wash_locked_service_title'),
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('car_wash_locked_service_desc'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: NeoBrutalButton(
                                label: game.isFeatureUnlocked('/staff')
                                    ? context.tr('car_wash_btn_hire_staff')
                                    : context.tr('locked_badge'),
                                icon: Icons.person_add_rounded,
                                backgroundColor:
                                    game.isFeatureUnlocked('/staff')
                                        ? AppColors.brutalYellow
                                        : (isDark
                                            ? const Color(0xFF2A3142)
                                            : const Color(0xFFCBD5E1)),
                                textColor: game.isFeatureUnlocked('/staff')
                                    ? Colors.black
                                    : Colors.white70,
                                fontSize: 11,
                                onPressed: () {
                                  if (game.isFeatureUnlocked('/staff')) {
                                    context.push('/staff');
                                  } else {
                                    NotificationService.showInfo(
                                      context,
                                      context.tr('wash_toast_level3_req'),
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NeoBrutalButton(
                                label:
                                    game.isFeatureUnlocked('/side-businesses')
                                        ? context.tr('car_wash_btn_open_shop')
                                        : context.tr('locked_badge'),
                                icon: Icons.storefront_rounded,
                                backgroundColor:
                                    game.isFeatureUnlocked('/side-businesses')
                                        ? AppColors.brutalGreen
                                        : (isDark
                                            ? const Color(0xFF2A3142)
                                            : const Color(0xFFCBD5E1)),
                                textColor:
                                    game.isFeatureUnlocked('/side-businesses')
                                        ? Colors.black
                                        : Colors.white70,
                                fontSize: 11,
                                onPressed: () {
                                  if (game
                                      .isFeatureUnlocked('/side-businesses')) {
                                    context.push('/side-businesses');
                                  } else {
                                    NotificationService.showInfo(
                                      context,
                                      context.tr('wash_toast_level8_req'),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                          context.tr('car_wash_queue_title'),
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900),
                        )),
                        NeoBrutalButton(
                          label: context.tr('car_wash_btn_scan_requests'),
                          icon: Icons.refresh_rounded,
                          backgroundColor: isDark
                              ? const Color(0xFF1E2330)
                              : const Color(0xFFE2E8F0),
                          textColor: isDark ? Colors.white : Colors.black,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          onPressed: () {
                            setState(() {
                              _customerWashJobs =
                                  CustomerWashJob.generateRandomJobs(count: 4);
                            });
                            NotificationService.showSuccess(
                                context, context.tr('wash_toast_new_queue'));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),

            if (_customerWashJobs.isEmpty)
              NeoBrutalCard(
                padding: const EdgeInsets.all(20),
                borderRadius: 12,
                child: Center(
                  child: Text(context.tr('car_wash_queue_empty')),
                ),
              )
            else if (game.hiredStaff.any((s) => s.role == StaffRole.washer) ||
                game.sideBusinesses.any(
                    (b) => b.type == SideBusinessType.carWash && b.isOperational))
              ..._customerWashJobs.map((job) {
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
                                    color: job.isVipCustomer
                                        ? const Color(0xFFA855F7)
                                        : const Color(0xFF38BDF8),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black, width: 1.5),
                                  ),
                                  child: Icon(job.washType.icon,
                                      color: Colors.black, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.customerName,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900)),
                                    Text(job.vehicleName,
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ),
                            if (job.isVipCustomer)
                              NeoBrutalBadge(
                                text: context.tr('car_wash_vip_badge'),
                                icon: Icons.star_rounded,
                                backgroundColor: const Color(0xFFA855F7),
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      context.tr('car_wash_service_label',
                                          {'service': job.washType.name}),
                                      style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w700)),
                                  Text(
                                      context.tr('car_wash_income_label', {
                                        'amount': CurrencyFormatter.format(
                                            job.paymentReward)
                                      }),
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF00E575))),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton(
                              label: context.tr('car_wash_btn_wash_earn'),
                              icon: Icons.cleaning_services_rounded,
                              backgroundColor: const Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              onPressed: () {
                                if (job.isVipCustomer &&
                                    !hasPolisher &&
                                    !hasFoamPump) {
                                  NotificationService.showError(
                                    context,
                                    context.tr('wash_toast_vip_equip_req'),
                                  );
                                  return;
                                }

                                final dummyCar = CarModel(
                                  id: job.id,
                                  brand: job.customerName,
                                  modelName: job.vehicleName,
                                  modelYear: 2022,
                                  bodyType: 'Sedan',
                                  colorHex: '#38BDF8',
                                  currentPurchasePrice: 200000.0,
                                  baseMarketValue: 200000.0,
                                  expertise: ExpertiseReport(
                                    engineCondition: 100,
                                    transmissionCondition: 100,
                                    tramerAmount: 0,
                                    mileage: 50000,
                                    isMileageTampered: false,
                                    bodyParts: {},
                                  ),
                                );

                                CarWashMiniGameModal.show(
                                  context,
                                  car: dummyCar,
                                  onCleanCompleted: () {
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .completeCustomerWashJob(job);
                                    if (success) {
                                      NotificationService.showSuccess(
                                        context,
                                        context.tr('wash_toast_job_delivered'),
                                      );
                                      setState(() {
                                        _customerWashJobs
                                            .removeWhere((j) => j.id == job.id);
                                      });
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
          ] else ...[
            // ================= GARAJ ARAÇLARIM TABI =================
            if (game.ownedCars.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(24),
                    backgroundColor:
                        isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark
                        ? const Color(0xFF2A3142)
                        : const Color(0xFF0F172A),
                    borderRadius: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_car_wash_rounded,
                            size: 44, color: Color(0xFF38BDF8)),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('car_wash_empty_garage_title'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.tr('car_wash_empty_garage_desc'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        NeoBrutalButton(
                          label: context.tr('car_wash_btn_go_market'),
                          icon: Icons.storefront_rounded,
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          onPressed: () => context.push('/marketplace'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (selectedCar != null) ...[
              // Garage Car Selection Carousel
              Text(
                context.tr('car_wash_select_car_title',
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
                    final isSelected = selectedCar!.id == car.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCarId = car.id),
                      child: Container(
                        width: 170,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFE0F2FE))
                              : (isDark
                                  ? const Color(0xFF141721)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF38BDF8)
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : Colors.black),
                            width: isSelected ? 2.5 : 1.5,
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
                              children: [
                                NeoBrutalBadge(
                                  text: car.isDetailedCleaned
                                      ? context.tr('car_wash_badge_ceramic')
                                      : car.isPolished
                                          ? context
                                              .tr('car_wash_badge_polished')
                                          : car.isWashed
                                              ? context
                                                  .tr('car_wash_badge_clean')
                                              : context
                                                  .tr('car_wash_badge_dirty'),
                                  backgroundColor: car.isDetailedCleaned
                                      ? const Color(0xFFA855F7)
                                      : car.isPolished
                                          ? const Color(0xFFFFDE59)
                                          : car.isWashed
                                              ? const Color(0xFF00E575)
                                              : const Color(0xFFEF4444),
                                  textColor: Colors.black,
                                  fontSize: 9,
                                ),
                                const Spacer(),
                                Text(
                                    CurrencyFormatter.formatShort(
                                        car.baseMarketValue),
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900)),
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

              // Active Wash Bay Visual & Status Indicators
              NeoBrutalCard(
                padding: const EdgeInsets.all(16),
                backgroundColor:
                    isDark ? const Color(0xFF141721) : Colors.white,
                borderColor:
                    isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                borderRadius: 14,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F0FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333B4F)
                                  : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.water_drop_rounded,
                              color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                        '${selectedCar.brand} ${selectedCar.modelName}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  if (selectedCar.vehicleCategory !=
                                      VehicleCategory.car) ...[
                                    const SizedBox(width: 6),
                                    NeoBrutalBadge(
                                      text: context.tr(selectedCar
                                          .vehicleCategory.localizationKey),
                                      icon: selectedCar.vehicleCategory.icon,
                                      backgroundColor: selectedCar
                                          .vehicleCategory.badgeColor,
                                      textColor: Colors.black,
                                      fontSize: 8.5,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${context.tr('car_card_market_value')}: ${CurrencyFormatter.formatShort(selectedCar.baseMarketValue)} • ${context.tr('car_spec_year')}: ${selectedCar.modelYear}',
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
                    const SizedBox(height: 14),

                    // Status indicators
                    Row(
                      children: [
                        Expanded(
                          child: _buildWashStatusPill(
                            title: context.tr('car_wash_status_foamed'),
                            isDone: selectedCar.isWashed,
                            color: const Color(0xFF00E575),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildWashStatusPill(
                            title: context.tr('car_wash_status_interior'),
                            isDone: selectedCar.isInteriorCleaned,
                            color: const Color(0xFF38BDF8),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildWashStatusPill(
                            title: context.tr('car_wash_status_polish'),
                            isDone: selectedCar.isPolished,
                            color: const Color(0xFFFFDE59),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildWashStatusPill(
                            title: context.tr('car_wash_status_ceramic'),
                            isDone: selectedCar.isDetailedCleaned,
                            color: const Color(0xFFA855F7),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Micro Quick Actions: Dikiz Aynası Kokusu, Far Restorasyonu, Demir Tozu
                    Row(
                      children: [
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.air_rounded,
                            label: selectedCar.hasScent
                                ? context.tr('car_wash_scent_label', {
                                    'scent': selectedCar.appliedScentId
                                            ?.replaceAll('scent_', '') ??
                                        ''
                                  })
                                : context.tr('car_wash_btn_mirror_scent'),
                            backgroundColor: selectedCar.hasScent
                                ? const Color(0xFF00E575)
                                : const Color(0xFFFFDE59),
                            textColor: Colors.black,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: () =>
                                _showScentSelectionSheet(context, selectedCar!),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.highlight_rounded,
                            label: selectedCar.hasRestoredHeadlights
                                ? context.tr('car_wash_headlight_clean')
                                : context.tr('car_wash_btn_headlight'),
                            backgroundColor: selectedCar.hasRestoredHeadlights
                                ? const Color(0xFF1E2330)
                                : const Color(0xFF38BDF8),
                            textColor: selectedCar.hasRestoredHeadlights
                                ? (isDark ? Colors.white54 : Colors.black54)
                                : Colors.black,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: selectedCar.hasRestoredHeadlights
                                ? null
                                : () {
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .restoreHeadlights(selectedCar!.id);
                                    if (success) {
                                      NotificationService.showSuccess(
                                          context,
                                          context
                                              .tr('wash_toast_headlight_done'));
                                      setState(() {});
                                    } else {
                                      NotificationService.showError(
                                          context,
                                          context.tr(
                                              'toast_insufficient_balance_needed',
                                              {'cost': '₺850'}));
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.flare_rounded,
                            label: selectedCar.hasIronDecon
                                ? context.tr('car_wash_wheel_clean')
                                : context.tr('car_wash_btn_wheel_decon'),
                            backgroundColor: selectedCar.hasIronDecon
                                ? const Color(0xFF1E2330)
                                : const Color(0xFFA855F7),
                            textColor: selectedCar.hasIronDecon
                                ? (isDark ? Colors.white54 : Colors.black54)
                                : Colors.white,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: selectedCar.hasIronDecon
                                ? null
                                : () {
                                    final success = ref
                                        .read(gameProvider.notifier)
                                        .cleanWheelIronDecon(selectedCar!.id);
                                    if (success) {
                                      NotificationService.showSuccess(
                                          context,
                                          context.tr(
                                              'wash_toast_iron_decon_done'));
                                      setState(() {});
                                    } else {
                                      NotificationService.showError(
                                          context,
                                          context.tr(
                                              'toast_insufficient_balance_needed',
                                              {'cost': '₺450'}));
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Interactive Detailing Canvas Trigger
              NeoBrutalButton(
                icon: selectedCar.isWashed
                    ? Icons.check_circle_rounded
                    : Icons.cleaning_services_rounded,
                label: selectedCar.isWashed
                    ? context.tr('car_wash_btn_canvas_done')
                    : context.tr('car_wash_btn_canvas_start'),
                backgroundColor: selectedCar.isWashed
                    ? const Color(0xFF1E293B)
                    : AppColors.brutalYellow,
                textColor: selectedCar.isWashed ? Colors.white54 : Colors.black,
                fontSize: 11.5,
                fullWidth: true,
                padding: const EdgeInsets.symmetric(vertical: 10),
                onPressed: selectedCar.isWashed
                    ? null
                    : () => CarWashMiniGameModal.show(
                          context,
                          car: selectedCar!,
                          onCleanCompleted: () {
                            _applyWashService(
                              serviceId: 'mini_game',
                              car: selectedCar!,
                              cost: 350.0 * discountMultiplier,
                              valueBoost: 0.01,
                              setWashed: true,
                              setInterior: false,
                              setPolished: false,
                              setDetailed: false,
                              successMsg: context.tr('wash_toast_foam_done'),
                            );
                          },
                        ),
              ),
              const SizedBox(height: 14),

              // Wash & Detailing Service Packages
              Text(
                context.tr('car_wash_packages_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              // Service 1: Köpüklü Yıkama
              _buildServicePackageTile(
                title: selectedCar.vehicleCategory != VehicleCategory.car
                    ? context.tr(selectedCar.vehicleCategory.washTitleKey)
                    : context.tr('car_wash_pkg_1_title'),
                subtitle: context.tr('car_wash_pkg_1_desc'),
                cost: 350.0 * discountMultiplier,
                bonusText: context.tr('car_wash_pkg_1_bonus'),
                badgeColor: const Color(0xFF00E575),
                isCompleted: selectedCar.isWashed,
                isDark: isDark,
                isLoading: _loadingServiceId == 'pkg1',
                loadingIcon: Icons.water_drop_rounded,
                onApply: () => _applyWashService(
                  serviceId: 'pkg1',
                  car: selectedCar!,
                  cost: 350.0 * discountMultiplier,
                  valueBoost: 0.01,
                  setWashed: true,
                  setInterior: false,
                  setPolished: false,
                  setDetailed: false,
                  successMsg: context.tr('wash_toast_foam_done'),
                ),
              ),
              const SizedBox(height: 8),

              // Service 2: İç Detaylı Temizlik
              _buildServicePackageTile(
                title: context.tr('car_wash_pkg_2_title'),
                subtitle: context.tr('car_wash_pkg_2_desc'),
                cost: 1200.0 * discountMultiplier,
                bonusText: context.tr('car_wash_pkg_2_bonus'),
                badgeColor: const Color(0xFF38BDF8),
                isCompleted: selectedCar.isInteriorCleaned,
                isDark: isDark,
                isLoading: _loadingServiceId == 'pkg2',
                loadingIcon: Icons.dry_cleaning_rounded,
                onApply: () => _applyWashService(
                  serviceId: 'pkg2',
                  car: selectedCar!,
                  cost: 1200.0 * discountMultiplier,
                  valueBoost: 0.03,
                  setWashed: true,
                  setInterior: true,
                  setPolished: false,
                  setDetailed: false,
                  successMsg: context.tr('wash_toast_interior_done'),
                ),
              ),
              const SizedBox(height: 8),

              // Service 3: Pasta Cila & Boya Koruma
              _buildServicePackageTile(
                title: context.tr('car_wash_pkg_3_title'),
                subtitle: context.tr('car_wash_pkg_3_desc'),
                cost: 3500.0 * discountMultiplier,
                bonusText: hasPolisher
                    ? context.tr('car_wash_pkg_3_bonus_polisher')
                    : context.tr('car_wash_pkg_3_bonus_base'),
                badgeColor: const Color(0xFFFFDE59),
                isCompleted: selectedCar.isPolished,
                isDark: isDark,
                isLoading: _loadingServiceId == 'pkg3',
                loadingIcon: Icons.blur_circular_rounded,
                onApply: () => _applyWashService(
                  serviceId: 'pkg3',
                  car: selectedCar!,
                  cost: 3500.0 * discountMultiplier,
                  valueBoost: hasPolisher ? 0.08 : 0.06,
                  setWashed: true,
                  setInterior: false,
                  setPolished: true,
                  setDetailed: false,
                  successMsg: context.tr('wash_toast_polish_done'),
                ),
              ),
              const SizedBox(height: 8),

              // Service 4: Seramik Kaplama & VIP Detailing
              _buildServicePackageTile(
                title: selectedCar.vehicleCategory != VehicleCategory.car
                    ? context.tr(selectedCar.vehicleCategory.washDetailKey)
                    : context.tr('car_wash_pkg_4_title'),
                subtitle: context.tr('car_wash_pkg_4_desc'),
                cost: 8500.0 * discountMultiplier,
                bonusText: context.tr('car_wash_pkg_4_bonus'),
                badgeColor: const Color(0xFFA855F7),
                isCompleted: selectedCar.isDetailedCleaned,
                isDark: isDark,
                isLoading: _loadingServiceId == 'pkg4',
                loadingIcon: Icons.auto_awesome_rounded,
                onApply: () => _applyWashService(
                  serviceId: 'pkg4',
                  car: selectedCar!,
                  cost: 8500.0 * discountMultiplier,
                  valueBoost: 0.12,
                  setWashed: true,
                  setInterior: false,
                  setPolished: true,
                  setDetailed: true,
                  successMsg: context.tr('wash_toast_ceramic_done'),
                ),
              ),
              const SizedBox(height: 20),

              // Purchasable Wash Equipment Upgrades
              Text(
                context.tr('car_wash_equipment_title'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              _buildEquipmentTile(
                id: 'wash_eq_hot_water',
                title: context.tr('car_wash_eq_gun_title'),
                description: context.tr('car_wash_eq_gun_desc'),
                cost: 25000.0,
                isOwned: hasHotWaterGun,
                icon: Icons.electric_bolt_rounded,
                color: const Color(0xFFFF7A00),
                isDark: isDark,
                onBuy: () => _buyEquipment('wash_eq_hot_water', 25000.0,
                    context.tr('car_wash_eq_gun_title')),
              ),
              const SizedBox(height: 8),

              _buildEquipmentTile(
                id: 'wash_eq_foam_pump',
                title: context.tr('car_wash_eq_pump_title'),
                description: context.tr('car_wash_eq_pump_desc'),
                cost: 60000.0,
                isOwned: hasFoamPump,
                icon: Icons.science_rounded,
                color: const Color(0xFF00E575),
                isDark: isDark,
                onBuy: () => _buyEquipment('wash_eq_foam_pump', 60000.0,
                    context.tr('car_wash_eq_pump_title')),
              ),
              const SizedBox(height: 8),

              _buildEquipmentTile(
                id: 'wash_eq_dual_polisher',
                title: context.tr('car_wash_eq_polisher_title'),
                description: context.tr('car_wash_eq_polisher_desc'),
                cost: 140000.0,
                isOwned: hasPolisher,
                icon: Icons.build_circle_rounded,
                color: const Color(0xFFA855F7),
                isDark: isDark,
                onBuy: () => _buyEquipment('wash_eq_dual_polisher', 140000.0,
                    context.tr('car_wash_eq_polisher_title')),
              ),
            ],
          ],
        ],
      ),
    ),
  );
  }

  Widget _buildWashStatusPill({
    required String title,
    required bool isDone,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDone
            ? color
            : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isDone ? Colors.black : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDone
                  ? Colors.black
                  : (isDark ? Colors.white70 : const Color(0xFF64748B)),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServicePackageTile({
    required String title,
    required String subtitle,
    required double cost,
    required String bonusText,
    required Color badgeColor,
    required bool isCompleted,
    required bool isDark,
    required VoidCallback onApply,
    bool isLoading = false,
    IconData? loadingIcon,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                    NeoBrutalBadge(
                      text: bonusText,
                      backgroundColor: badgeColor,
                      textColor: Colors.black,
                      fontSize: 9.5,
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('car_wash_service_fee_label',
                      {'cost': CurrencyFormatter.format(cost)}),
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF00E575)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          NeoBrutalButton(
            label: isCompleted
                ? context.tr('tuning_btn_applied')
                : context.tr('tuning_btn_apply'),
            icon: isCompleted
                ? Icons.check_circle_rounded
                : Icons.cleaning_services_rounded,
            isApplied: isCompleted,
            isLoading: isLoading,
            loadingIcon: loadingIcon,
            loadingLabel: context.tr('general_processing'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: isCompleted || isLoading ? null : onApply,
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentTile({
    required String id,
    required String title,
    required String description,
    required double cost,
    required bool isOwned,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onBuy,
  }) {
    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                width: 2.0,
              ),
            ),
            child: Icon(icon, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 12.5, fontWeight: FontWeight.w900)),
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 3),
                Text(
                  isOwned
                      ? context.tr('car_wash_installed_badge')
                      : CurrencyFormatter.format(cost),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isOwned
                        ? const Color(0xFF00E575)
                        : const Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: isOwned
                ? context.tr('equipment_badge_owned')
                : context.tr('equipment_btn_buy'),
            backgroundColor: isOwned
                ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                : AppColors.brutalYellow,
            textColor: isOwned
                ? (isDark ? Colors.white54 : Colors.black54)
                : Colors.black,
            fontSize: 10.5,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: isOwned ? null : onBuy,
          ),
        ],
      ),
    );
  }

  Future<void> _applyWashService({
    required String serviceId,
    required CarModel car,
    required double cost,
    required double valueBoost,
    required bool setWashed,
    required bool setInterior,
    required bool setPolished,
    required bool setDetailed,
    required String successMsg,
  }) async {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(
        context,
        context.tr(
          'toast_insufficient_balance_needed',
          {'cost': CurrencyFormatter.format(cost)},
        ),
      );
      return;
    }

    setState(() => _loadingServiceId = serviceId);

    final opType = OperationSuspenseType.fromWashServiceId(serviceId);
    await NeoBrutalOperationDialog.show(
      context,
      operationType: opType,
      carName: '${car.brand} ${car.modelName}',
      onComplete: () {
        final success = ref.read(gameProvider.notifier).performWashService(
              car.id,
              cost: cost,
              valueBoostPercent: valueBoost,
              setWashed: setWashed,
              setInterior: setInterior,
              setPolished: setPolished,
              setDetailed: setDetailed,
            );

        if (success && mounted) {
          NotificationService.showSuccess(context, successMsg);
        }
      },
    );

    if (mounted) {
      setState(() => _loadingServiceId = null);
    }
  }

  void _buyEquipment(String eqId, double cost, String name) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(
        context,
        context.tr(
          'toast_insufficient_balance_needed',
          {'cost': CurrencyFormatter.format(cost)},
        ),
      );
      return;
    }

    final success =
        ref.read(gameProvider.notifier).purchaseEquipmentUpgrade(eqId, cost);
    if (success) {
      NotificationService.showReward(
          context, context.tr('wash_toast_equip_installed'));
      setState(() {});
    }
  }
}
