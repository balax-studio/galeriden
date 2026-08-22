import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/car_wash_job_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/staff_model.dart';
import '../../../data/models/side_business_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/mini_games/car_wash_canvas.dart';

class CarWashScreen extends ConsumerStatefulWidget {
  const CarWashScreen({super.key});

  @override
  ConsumerState<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends ConsumerState<CarWashScreen> {
  String? _selectedCarId;
  int _activeTopTab = 0; // 0: Garaj Araçlarım & Detailing, 1: Müşteri Yıkama Talepleri
  List<CustomerWashJob> _customerWashJobs = [];

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
                  Text(context.tr('wash_scent_title'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
                  NeoBrutalBadge(text: context.tr('wash_scent_sub'), backgroundColor: AppColors.brutalYellow, textColor: Colors.black, fontSize: 10),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                context.tr('wash_scent_hint'),
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              ...CarScent.availableScents.map((scent) {
                final isCurrent = car.appliedScentId == scent.id;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(10),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                    borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                    borderRadius: 10,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: scent.badgeColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: Icon(scent.icon, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(scent.getLocalizedName(lang), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                                    const SizedBox(width: 6),
                                    NeoBrutalBadge(text: scent.buyerAppealBuff, backgroundColor: scent.badgeColor, textColor: Colors.black, fontSize: 8.5),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${scent.getLocalizedDescription(lang)} • ${CurrencyFormatter.format(scent.cost)}',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        NeoBrutalButton(
                          label: isCurrent ? context.tr('btn_scent_hung') : context.tr('btn_hang_scent'),
                          backgroundColor: isCurrent ? const Color(0xFF00E575) : AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 10.5,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          onPressed: isCurrent
                              ? null
                              : () {
                                  Navigator.pop(ctx);
                                  final game = ref.read(gameProvider);
                                  if (game.balance < scent.cost) {
                                    NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.format(scent.cost)} gerekli.');
                                    return;
                                  }
                                  final success = ref.read(gameProvider.notifier).applyCarScent(car.id, scent);
                                  if (success) {
                                    NotificationService.showSuccess(context, '${car.modelName} aynasına ${scent.name} asıldı!');
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

    if (!game.isFeatureUnlocked('/car-wash')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'OTO YIKAMA & DETAILING'),
        body: const NeoBrutalLockedFeatureView(
          route: '/car-wash',
          featureTitle: 'OTO YIKAMA & DETAILING',
          icon: Icons.local_car_wash_rounded,
        ),
      );
    }

    final hasHotWaterGun = game.unlockedBuildings.contains('wash_eq_hot_water');
    final hasFoamPump = game.unlockedBuildings.contains('wash_eq_foam_pump');
    final hasPolisher = game.unlockedBuildings.contains('wash_eq_dual_polisher');
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
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: NeoBrutalAppBar(
        title: context.tr('car_wash_title'),
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
                  label: context.tr('tab_garage_wash'),
                  backgroundColor: _activeTopTab == 0 ? AppColors.brutalYellow : (isDark ? const Color(0xFF141721) : Colors.white),
                  textColor: _activeTopTab == 0 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                  fontSize: 11,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  onPressed: () => setState(() => _activeTopTab = 0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NeoBrutalButton(
                  icon: Icons.local_taxi_rounded,
                  label: '${context.tr('tab_customer_wash')} • ${_customerWashJobs.length}',
                  backgroundColor: _activeTopTab == 1 ? const Color(0xFF00E575) : (isDark ? const Color(0xFF141721) : Colors.white),
                  textColor: _activeTopTab == 1 ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
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
                final hasWasherStaff = game.hiredStaff.any((s) => s.role == StaffRole.washer);
                final hasWashBusiness = game.sideBusinesses.any((b) => b.type == SideBusinessType.carWash && b.isOwned);

                if (!hasWasherStaff && !hasWashBusiness) {
                  return NeoBrutalCard(
                    padding: const EdgeInsets.all(20),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: AppColors.brutalOrange,
                    borderRadius: 14,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.brutalOrange.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.brutalOrange, width: 2),
                          ),
                          child: const Icon(Icons.lock_rounded, size: 36, color: AppColors.brutalOrange),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'MÜŞTERİ YIKAMA SERVİSİ KİLİTLİ',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Dışarıdan müşteri araçlarını yıkayıp sıcak nakit para ve XP kazanabilmek için kadronuza bir Yıkama & Detay Uzmanı almalı veya Oto Yıkama Dükkanı açmalısınız.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: NeoBrutalButton(
                                label: game.isFeatureUnlocked('/staff') ? 'PERSONEL AL' : 'KİLİTLİ',
                                icon: Icons.person_add_rounded,
                                backgroundColor: game.isFeatureUnlocked('/staff')
                                    ? AppColors.brutalYellow
                                    : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                                textColor: game.isFeatureUnlocked('/staff') ? Colors.black : Colors.white70,
                                fontSize: 11,
                                onPressed: () {
                                  if (game.isFeatureUnlocked('/staff')) {
                                    context.push('/staff');
                                  } else {
                                    NotificationService.showInfo(
                                      context,
                                      'Personel alımı Seviye 3 • Sanayi Sitesi gerektirir.',
                                    );
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: NeoBrutalButton(
                                label: game.isFeatureUnlocked('/side-businesses') ? 'DÜKKAN AÇ' : 'KİLİTLİ',
                                icon: Icons.storefront_rounded,
                                backgroundColor: game.isFeatureUnlocked('/side-businesses')
                                    ? AppColors.brutalGreen
                                    : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                                textColor: game.isFeatureUnlocked('/side-businesses') ? Colors.black : Colors.white70,
                                fontSize: 11,
                                onPressed: () {
                                  if (game.isFeatureUnlocked('/side-businesses')) {
                                    context.push('/side-businesses');
                                  } else {
                                    NotificationService.showInfo(
                                      context,
                                      'Yan işletmeler Seviye 8 • Mega Holding gerektirir.',
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
                        const Text(
                          'YIKAMAYA GELEN MÜŞTERİ ARAÇLARI',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                        NeoBrutalButton(
                          label: 'YENİ TALEPLER TARA',
                          icon: Icons.refresh_rounded,
                          backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                          textColor: isDark ? Colors.white : Colors.black,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          onPressed: () {
                            setState(() {
                              _customerWashJobs = CustomerWashJob.generateRandomJobs(count: 4);
                            });
                            NotificationService.showSuccess(context, 'Yeni yıkama müşterileri sıraya girdi!');
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
              const NeoBrutalCard(
                padding: EdgeInsets.all(20),
                borderRadius: 12,
                child: Center(
                  child: Text('Şu an kuyrukta araç yok. Yeni talepler tarayabilirsin.'),
                ),
              )
            else if (game.hiredStaff.any((s) => s.role == StaffRole.washer) || game.sideBusinesses.any((b) => b.type == SideBusinessType.carWash && b.isOwned))
              ..._customerWashJobs.map((job) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                                    color: job.isVipCustomer ? const Color(0xFFA855F7) : const Color(0xFF38BDF8),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.black, width: 1.5),
                                  ),
                                  child: Icon(job.washType.icon, color: Colors.black, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(job.customerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                                    Text(job.vehicleName, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ],
                            ),
                            if (job.isVipCustomer)
                              const NeoBrutalBadge(
                                text: 'VIP MÜŞTERİ',
                                icon: Icons.star_rounded,
                                backgroundColor: Color(0xFFA855F7),
                                textColor: Colors.white,
                                fontSize: 9.5,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"${job.customerStory}"',
                            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hizmet: ${job.washType.name}', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                                Text('Kazanç: +${CurrencyFormatter.format(job.paymentReward)}', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF00E575))),
                              ],
                            ),
                            NeoBrutalButton(
                              label: 'YIKA & KAZAN',
                              icon: Icons.cleaning_services_rounded,
                              backgroundColor: const Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              onPressed: () {
                                if (job.isVipCustomer && !hasPolisher && !hasFoamPump) {
                                  NotificationService.showError(
                                    context,
                                    'VIP Araç Detailing işlemi için Endüstriyel Polisaj veya Otomatik Köpük Pompası ekipmanı gereklidir!',
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
                                    final success = ref.read(gameProvider.notifier).completeCustomerWashJob(job);
                                    if (success) {
                                      NotificationService.showSuccess(
                                        context,
                                        '${job.vehicleName} pırıl pırıl teslim edildi! +${CurrencyFormatter.format(job.paymentReward)} & +${job.masteryXp} XP kazanıldı.',
                                      );
                                      setState(() {
                                        _customerWashJobs.removeWhere((j) => j.id == job.id);
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
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                    borderRadius: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.local_car_wash_rounded, size: 44, color: Color(0xFF38BDF8)),
                        const SizedBox(height: 12),
                        const Text(
                          'Garajında Araç Yok!',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Yıkamak ve parlatmak için önce pazardan araç satın almalısın.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 16),
                        NeoBrutalButton(
                          label: 'İLANLARA GİT',
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
                'YIKANACAK ARACI SEÇ • ${game.ownedCars.length} Araç',
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
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
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
                              ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFE0F2FE))
                              : (isDark ? const Color(0xFF141721) : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF38BDF8) : (isDark ? const Color(0xFF334155) : Colors.black),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(car.brand, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)), maxLines: 1),
                            Text(car.modelName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900), maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                NeoBrutalBadge(
                                  text: car.isDetailedCleaned
                                      ? 'SERAMİK'
                                      : car.isPolished
                                          ? 'CİLALI'
                                          : car.isWashed
                                              ? 'TEMİZ'
                                              : 'KİRLİ',
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
                                Text(CurrencyFormatter.formatShort(car.baseMarketValue), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
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
                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                              color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                              width: 2.0,
                            ),
                          ),
                          child: const Icon(Icons.water_drop_rounded, color: Colors.black, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${selectedCar.brand} ${selectedCar.modelName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(
                                'Piyasa Değeri: ${CurrencyFormatter.formatShort(selectedCar.baseMarketValue)} • Yıl: ${selectedCar.modelYear}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                            title: 'Köpüklü',
                            isDone: selectedCar.isWashed,
                            color: const Color(0xFF00E575),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildWashStatusPill(
                            title: 'İç Temizlik',
                            isDone: selectedCar.isInteriorCleaned,
                            color: const Color(0xFF38BDF8),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildWashStatusPill(
                            title: 'Pasta Cila',
                            isDone: selectedCar.isPolished,
                            color: const Color(0xFFFFDE59),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildWashStatusPill(
                            title: 'Nano Seramik',
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
                            label: selectedCar.hasScent ? 'Koku: ${selectedCar.appliedScentId?.replaceAll('scent_', '')}' : 'Ayna Kokusu',
                            backgroundColor: selectedCar.hasScent ? const Color(0xFF00E575) : const Color(0xFFFFDE59),
                            textColor: Colors.black,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: () => _showScentSelectionSheet(context, selectedCar!),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.highlight_rounded,
                            label: selectedCar.hasRestoredHeadlights ? 'Far Temiz' : 'Far Sil • ₺850',
                            backgroundColor: selectedCar.hasRestoredHeadlights ? const Color(0xFF1E2330) : const Color(0xFF38BDF8),
                            textColor: selectedCar.hasRestoredHeadlights ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: selectedCar.hasRestoredHeadlights
                                ? null
                                : () {
                                    final success = ref.read(gameProvider.notifier).restoreHeadlights(selectedCar!.id);
                                    if (success) {
                                      NotificationService.showSuccess(context, 'Sararmış farlar klorobuharla sıfırlandı • +%4 Değer!');
                                      setState(() {});
                                    } else {
                                      NotificationService.showError(context, 'Yetersiz bakiye! ₺850 gerekli.');
                                    }
                                  },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.flare_rounded,
                            label: selectedCar.hasIronDecon ? 'Jant Temiz' : 'Jant Decon • ₺450',
                            backgroundColor: selectedCar.hasIronDecon ? const Color(0xFF1E2330) : const Color(0xFFA855F7),
                            textColor: selectedCar.hasIronDecon ? (isDark ? Colors.white54 : Colors.black54) : Colors.white,
                            fontSize: 10,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            onPressed: selectedCar.hasIronDecon
                                ? null
                                : () {
                                    final success = ref.read(gameProvider.notifier).cleanWheelIronDecon(selectedCar!.id);
                                    if (success) {
                                      NotificationService.showSuccess(context, 'Jantlardaki balata ve demir tozları mor spreyle temizlendi!');
                                      setState(() {});
                                    } else {
                                      NotificationService.showError(context, 'Yetersiz bakiye! ₺450 gerekli.');
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
                icon: selectedCar.isWashed ? Icons.check_circle_rounded : Icons.cleaning_services_rounded,
                label: selectedCar.isWashed ? '2D YIKAMA TAMAMLANDI • TEMİZ' : 'KÖPÜKLÜ 2D YIKAMA KANVASI',
                backgroundColor: selectedCar.isWashed ? const Color(0xFF1E293B) : AppColors.brutalYellow,
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
                              car: selectedCar!,
                              cost: 350.0 * discountMultiplier,
                              valueBoost: 0.01,
                              setWashed: true,
                              setInterior: false,
                              setPolished: false,
                              setDetailed: false,
                              successMsg: 'Köpüklü yıkama tamamlandı! Araç pırıl pırıl parlıyor.',
                            );
                          },
                        ),
              ),
              const SizedBox(height: 14),

              // Wash & Detailing Service Packages
              Text(
                'YIKAMA & DETAILING PAKETLERİ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),

              _buildServicePackageTile(
                title: '1. Köpüklü Standart Yıkama',
                subtitle: 'Basınçlı köpük, jant fırçalama ve kurulama.',
                cost: 350.0 * discountMultiplier,
                bonusText: '+%20 Temizlik',
                badgeColor: const Color(0xFF00E575),
                isCompleted: selectedCar.isWashed,
                isDark: isDark,
                onApply: () => _applyWashService(
                  car: selectedCar!,
                  cost: 350.0 * discountMultiplier,
                  valueBoost: 0.01,
                  setWashed: true,
                  setInterior: false,
                  setPolished: false,
                  setDetailed: false,
                  successMsg: 'Köpüklü yıkama tamamlandı! Araç pırıl pırıl parlıyor.',
                ),
              ),
              const SizedBox(height: 8),

              _buildServicePackageTile(
                title: '2. Detaylı İç-Dış & Koltuk Yıkama',
                subtitle: 'Buharlı döşeme temizliği, tavan silme ve ozon dezenfeksiyonu.',
                cost: 1200.0 * discountMultiplier,
                bonusText: '+%3 Satış Değeri Artışı',
                badgeColor: const Color(0xFF38BDF8),
                isCompleted: selectedCar.isInteriorCleaned,
                isDark: isDark,
                onApply: () => _applyWashService(
                  car: selectedCar!,
                  cost: 1200.0 * discountMultiplier,
                  valueBoost: 0.03,
                  setWashed: true,
                  setInterior: true,
                  setPolished: false,
                  setDetailed: false,
                  successMsg: 'Detaylı iç-dış yıkama bitti! Araç değeri %3 arttı.',
                ),
              ),
              const SizedBox(height: 8),

              _buildServicePackageTile(
                title: '3. Pasta Cila & Çizik Giderme',
                subtitle: 'Kılcal çizik giderme, teflon koruma ve ayna gibi parlaklık.',
                cost: 3500.0 * discountMultiplier,
                bonusText: hasPolisher ? '+%8 Satış Değeri • Polisaj Bonusu' : '+%6 Satış Değeri',
                badgeColor: const Color(0xFFFFDE59),
                isCompleted: selectedCar.isPolished,
                isDark: isDark,
                onApply: () => _applyWashService(
                  car: selectedCar!,
                  cost: 3500.0 * discountMultiplier,
                  valueBoost: hasPolisher ? 0.08 : 0.06,
                  setWashed: true,
                  setInterior: false,
                  setPolished: true,
                  setDetailed: false,
                  successMsg: 'Pasta cila çekildi! Kaporta ayna gibi parlıyor.',
                ),
              ),
              const SizedBox(height: 8),

              _buildServicePackageTile(
                title: '4. Nano Seramik Kaplama & VIP Detailing',
                subtitle: '9H elmas seramik, hidrofobik su itici ve 2x vitrin alıcı ilgisi.',
                cost: 8500.0 * discountMultiplier,
                bonusText: '+%12 Süper Değer Artışı & 2x Hızlı Satış',
                badgeColor: const Color(0xFFA855F7),
                isCompleted: selectedCar.isDetailedCleaned,
                isDark: isDark,
                onApply: () => _applyWashService(
                  car: selectedCar!,
                  cost: 8500.0 * discountMultiplier,
                  valueBoost: 0.12,
                  setWashed: true,
                  setInterior: false,
                  setPolished: true,
                  setDetailed: true,
                  successMsg: 'VIP Seramik kaplama uygulandı! Araç vitrinde hemen alıcı bulacak.',
                ),
              ),
              const SizedBox(height: 20),

              // Purchasable Wash Equipment Upgrades
              Text(
                'SATIN ALINABİLİR YIKAMA EKİPMANLARI',
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
                title: 'Basınçlı Sıcak Su Tabancası',
                description: 'Zift ve inatçı kirleri saniyeler içinde çözer, yıkama hızını artırır.',
                cost: 25000.0,
                isOwned: hasHotWaterGun,
                icon: Icons.electric_bolt_rounded,
                color: const Color(0xFFFF7A00),
                isDark: isDark,
                onBuy: () => _buyEquipment('wash_eq_hot_water', 25000.0, 'Basınçlı Sıcak Su Tabancası'),
              ),
              const SizedBox(height: 8),

              _buildEquipmentTile(
                id: 'wash_eq_foam_pump',
                title: 'Otomatik Köpük Dozajlayıcı Pompa',
                description: 'Şampuan ve kimyasal sarfiyatını %30 düşürerek tüm yıkama maliyetlerini kalıcı olarak indirir.',
                cost: 60000.0,
                isOwned: hasFoamPump,
                icon: Icons.science_rounded,
                color: const Color(0xFF00E575),
                isDark: isDark,
                onBuy: () => _buyEquipment('wash_eq_foam_pump', 60000.0, 'Otomatik Köpük Dozajlayıcı Pompa'),
              ),
              const SizedBox(height: 8),

              _buildEquipmentTile(
                id: 'wash_eq_dual_polisher',
                title: 'Endüstriyel Çift Kafalı Polisaj Makinesi',
                description: 'Pasta cila işlemlerinde araç değer artış kâr çarpanını %6\'dan %8\'e çıkarır.',
                cost: 140000.0,
                isOwned: hasPolisher,
                icon: Icons.build_circle_rounded,
                color: const Color(0xFFA855F7),
                isDark: isDark,
                onBuy: () => _buyEquipment('wash_eq_dual_polisher', 140000.0, 'Endüstriyel Çift Kafalı Polisaj Makinesi'),
              ),
            ],
          ],
        ],
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
        color: isDone ? color : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 16,
            color: isDone ? Colors.black : const Color(0xFF94A3B8),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isDone ? Colors.black : (isDark ? Colors.white70 : const Color(0xFF64748B)),
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
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
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
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hizmet Bedeli: ${CurrencyFormatter.format(cost)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF00E575)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          NeoBrutalButton(
            label: isCompleted ? 'UYGULANDI' : 'UYGULA',
            icon: isCompleted ? Icons.check_circle_rounded : Icons.cleaning_services_rounded,
            backgroundColor: isCompleted
                ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                : AppColors.brutalYellow,
            textColor: isCompleted ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            onPressed: isCompleted ? null : onApply,
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
                color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
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
                Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 3),
                Text(
                  isOwned ? 'ATÖLYENDE KURULU' : CurrencyFormatter.format(cost),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isOwned ? const Color(0xFF00E575) : const Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NeoBrutalButton(
            label: isOwned ? 'SAHİPSİN' : 'SATIN AL',
            backgroundColor: isOwned
                ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0))
                : AppColors.brutalYellow,
            textColor: isOwned ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
            fontSize: 10.5,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            onPressed: isOwned ? null : onBuy,
          ),
        ],
      ),
    );
  }

  void _applyWashService({
    required CarModel car,
    required double cost,
    required double valueBoost,
    required bool setWashed,
    required bool setInterior,
    required bool setPolished,
    required bool setDetailed,
    required String successMsg,
  }) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(context, 'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    final success = ref.read(gameProvider.notifier).performWashService(
      car.id,
      cost: cost,
      valueBoostPercent: valueBoost,
      setWashed: setWashed,
      setInterior: setInterior,
      setPolished: setPolished,
      setDetailed: setDetailed,
    );

    if (success) {
      NotificationService.showSuccess(context, successMsg);
      setState(() {});
    }
  }

  void _buyEquipment(String eqId, double cost, String name) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(context, 'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    final success = ref.read(gameProvider.notifier).purchaseEquipmentUpgrade(eqId, cost);
    if (success) {
      NotificationService.showReward(context, '$name yıkama istasyonuna kuruldu!');
      setState(() {});
    }
  }
}
