import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/part_order_model.dart';
import '../../../domain/usecases/psychology_engine.dart';
import '../../../domain/usecases/repair_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import 'widgets/animated_order_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (game.ownedCars.isNotEmpty && _selectedCar == null) {
      _selectedCar = game.ownedCars.first;
    } else if (game.ownedCars.isNotEmpty && _selectedCar != null) {
      _selectedCar = game.ownedCars.firstWhere(
        (c) => c.id == _selectedCar!.id,
        orElse: () => game.ownedCars.first,
      );
    }

    final hasLift = game.unlockedBuildings.contains('workshop_eq_lift');
    final hasChassisBench = game.unlockedBuildings.contains('workshop_eq_chassis_bench');
    final hasPaintBooth = game.unlockedBuildings.contains('workshop_eq_paint_booth');

    final paintCostMultiplier = hasPaintBooth ? 0.50 : 1.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'TAMİR, KAPORTA & ATÖLYE',
      ),
      body: game.ownedCars.isEmpty
          ? NeoBrutalEmptyState(
              icon: Icons.build_circle_rounded,
              accentColor: const Color(0xFFFF7A00),
              badgeText: 'ATÖLYE BOŞ',
              title: 'Garajında Onarılacak Araç Yok!',
              description: 'Pazardan veya hurdalıktan kelepir araç satın alarak burada toplayabilir ve değerini ikiye katlayabilirsin.',
              actionLabel: 'İLANLARA GİT',
              actionIcon: Icons.storefront_rounded,
              onActionPressed: () => context.push('/marketplace'),
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. VIP Tuning Banner Nav
                NeoBrutalCard(
                  padding: const EdgeInsets.all(12),
                  backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                  borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: const Icon(Icons.speed_rounded, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tuning & Performans Stüdyosu', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                                  Text('Stage 1/2 Yazılım, Varex Egzoz & Air Süspansiyon', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      NeoBrutalButton(
                        label: 'GİRİŞ ET',
                        backgroundColor: AppColors.brutalYellow,
                        textColor: Colors.black,
                        fontSize: 10.5,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        onPressed: () => context.push('/tuning-studio'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Car Selector Carousel
                Text(
                  'TAMİR EDİLECEK ARACI SEÇ (${game.ownedCars.length} Araç)',
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
                      final isSelected = _selectedCar?.id == car.id;
                      final exp = car.expertise;
                      final isPerfect = exp.engineCondition >= 95 && exp.transmissionCondition >= 95;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedCar = car),
                        child: Container(
                          width: 175,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? const Color(0xFF1E293B) : const Color(0xFFFEF3C7))
                                : (isDark ? const Color(0xFF141721) : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFFFF7A00) : (isDark ? const Color(0xFF334155) : Colors.black),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: isSelected ? const Offset(3, 3) : const Offset(1.5, 1.5),
                                blurRadius: 0,
                              ),
                            ],
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
                                    text: isPerfect ? 'KUSURSUZ' : 'MOTOR %${exp.engineCondition.toInt()}',
                                    backgroundColor: isPerfect ? const Color(0xFF00E575) : const Color(0xFFFF7A00),
                                    textColor: Colors.black,
                                    fontSize: 8.5,
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

                // 3. Active Vehicle Mechanical Diagnosis Card
                if (_selectedCar != null) ...[
                  NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
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
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
                              ),
                              child: const Icon(Icons.car_repair_rounded, color: Colors.black, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_selectedCar!.brand} ${_selectedCar!.modelName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Piyasa Değeri: ${CurrencyFormatter.format(_selectedCar!.estimatedRealValue)} (Kusursuz: ${CurrencyFormatter.formatShort(_selectedCar!.baseMarketValue)}) • ${_selectedCar!.modelYear}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
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
                                label: 'Motor Sağlığı',
                                percent: _selectedCar!.expertise.engineCondition,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildHealthBar(
                                label: 'Şanzıman Sağlığı',
                                percent: _selectedCar!.expertise.transmissionCondition,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        NeoBrutalButton(
                          label: 'YEDEK PARÇA SİPARİŞİ VER (OEM / Hurda / Yan Sanayi)',
                          icon: Icons.local_shipping_rounded,
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 11,
                          fullWidth: true,
                          onPressed: () => _showOrderPartsSheet(context, _selectedCar!, game, isDark),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3.5 IKEA Etkisi & Restorasyon Öncesi/Sonrası Künye Kartı (§3.2)
                  NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                    borderColor: const Color(0xFF3B82F6),
                    borderRadius: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.history_edu_rounded, color: Color(0xFF3B82F6), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'RESTORASYON EMEĞİ & ARAÇ KÜNYESİ (ÖNCESİ / SONRASI)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF3B82F6)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alış Maliyeti', style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54)),
                                Text(CurrencyFormatter.formatShort(_selectedCar!.currentPurchasePrice), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Mevcut Restorasyon', style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54)),
                                Text(
                                  '%${((_selectedCar!.expertise.engineCondition + _selectedCar!.expertise.transmissionCondition) / 2).toInt()} Kondisyon',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF00E575)),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Tahmini Satış', style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54)),
                                Text(CurrencyFormatter.formatShort(_selectedCar!.estimatedRealValue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFFF7A00))),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 4. Five Specialized Repair Stations
                Text(
                  'ATÖLYE & TAMİR İSTASYONLARI',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: isDark ? Colors.white70 : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),

                // Condition checks for repair stations
                Builder(
                  builder: (context) {
                    final exp = _selectedCar?.expertise;
                    final isEngineRepaired = (exp?.engineCondition ?? 100.0) >= 99.5;
                    final isTransmissionRepaired = (exp?.transmissionCondition ?? 100.0) >= 99.5;
                    final isEcuRepaired = exp?.isEcuCleaned ?? false;
                    final isBodyworkRepaired = !(exp?.bodyParts.values.any((v) => v != PartStatus.original) ?? false);
                    final isChassisRepaired = exp?.isChassisAligned ?? false;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WorkshopRepairTile(
                          title: '1. Motor Rektifiye & Subap Ayarı',
                          description: 'Piston, segman ve subapları yenileyerek motor kondisyonunu %100 yapar.',
                          cost: 18500.0,
                          bonusText: 'Motor %100 & +%10 Değer',
                          netRoiText: _selectedCar != null ? PsychologyEngine.getNetRoiRepairText(18500.0, _selectedCar!.estimatedRealValue * 0.10) : null,
                          badgeColor: const Color(0xFF00E575),
                          isDark: isDark,
                          isRepaired: isEngineRepaired,
                          disabledLabel: 'KUSURSUZ',
                          onRepair: () => _showTierSelectionDialog(
                            context: context,
                            car: _selectedCar!,
                            repairType: 'engine',
                            baseCost: 18500.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        WorkshopRepairTile(
                          title: '2. Şanzıman & Baskı Balata Yenileme',
                          description: 'Vites geçişlerini pürüzsüzleştirir, debriyaj setini sıfırlar.',
                          cost: 12000.0,
                          bonusText: 'Şanzıman %100 & +%8 Değer',
                          netRoiText: _selectedCar != null ? PsychologyEngine.getNetRoiRepairText(12000.0, _selectedCar!.estimatedRealValue * 0.08) : null,
                          badgeColor: const Color(0xFF38BDF8),
                          isDark: isDark,
                          isRepaired: isTransmissionRepaired,
                          disabledLabel: 'KUSURSUZ',
                          onRepair: () => _showTierSelectionDialog(
                            context: context,
                            car: _selectedCar!,
                            repairType: 'transmission',
                            baseCost: 12000.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        WorkshopRepairTile(
                          title: '3. Bilgisayarlı OBD-II Beyin (ECU) Arıza Tespiti',
                          description: 'Tüm sensör, enjektör ve gizli elektriksel arıza kodlarını siler.',
                          cost: 4500.0,
                          bonusText: 'Gizli Kusurlar Silinir',
                          netRoiText: _selectedCar != null ? PsychologyEngine.getNetRoiRepairText(4500.0, _selectedCar!.estimatedRealValue * 0.05) : null,
                          badgeColor: const Color(0xFFA855F7),
                          isDark: isDark,
                          isRepaired: isEcuRepaired,
                          disabledLabel: 'ARIZA YOK',
                          onRepair: () => _showTierSelectionDialog(
                            context: context,
                            car: _selectedCar!,
                            repairType: 'ecu',
                            baseCost: 4500.0,
                          ),
                        ),
                        const SizedBox(height: 8),

                        WorkshopRepairTile(
                          title: '4. Kaporta Çekiçleme & Fırın Boya',
                          description: 'Değişen veya boyalı kaporta parçalarını fabrika kondisyonuna getirir.',
                          cost: 22000.0 * paintCostMultiplier,
                          bonusText: hasPaintBooth ? '+%15 Değer (Boya Fırını %50 İndirimi!)' : '+%15 Değer Artışı',
                          netRoiText: _selectedCar != null ? PsychologyEngine.getNetRoiRepairText(22000.0 * paintCostMultiplier, _selectedCar!.estimatedRealValue * 0.15) : null,
                          badgeColor: const Color(0xFFFFDE59),
                          isDark: isDark,
                          isRepaired: isBodyworkRepaired,
                          disabledLabel: 'KUSURSUZ',
                          onRepair: () => _showTierSelectionDialog(
                            context: context,
                            car: _selectedCar!,
                            repairType: 'bodywork',
                            baseCost: 22000.0 * paintCostMultiplier,
                          ),
                        ),
                        const SizedBox(height: 8),

                        WorkshopRepairTile(
                          title: '5. Lazerli Şasi Düzeltme & Rot-Balans',
                          description: 'Ağır kazalı, podye veya direk hasarlı araçların şasisini sıfır toleransla doğrultur.',
                          cost: 45000.0,
                          bonusText: hasChassisBench ? '+%20 Süper Değer (Şasi Tezgahı Bonusu!)' : '+%20 Değer',
                          netRoiText: _selectedCar != null ? PsychologyEngine.getNetRoiRepairText(45000.0, _selectedCar!.estimatedRealValue * 0.20) : null,
                          badgeColor: const Color(0xFFEF4444),
                          isDark: isDark,
                          isRepaired: isChassisRepaired,
                          disabledLabel: 'ŞASİ DÜZGÜN',
                          onRepair: () => _showTierSelectionDialog(
                            context: context,
                            car: _selectedCar!,
                            repairType: 'chassis',
                            baseCost: 45000.0,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),

                // 4.1 Pending Part Orders & Fast Delivery
                if (game.pendingOrders.isNotEmpty) ...[
                  Text(
                    'BEKLEYEN PARÇA SİPARİŞLERİ (${game.pendingOrders.length})',
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
                        final success = ref.read(gameProvider.notifier).installDeliveredPart(order.id);
                        if (success) {
                          NotificationService.showSuccess(context, '${order.partName} montajı tamamlandı!');
                          setState(() {});
                        }
                      },
                      onFastDeliverWithAd: () {
                        AdService.instance.showRewardedAd(
                          onRewardEarned: () {
                            ref.read(gameProvider.notifier).instantDeliverPartOrder(order.id);
                            NotificationService.showReward(context, 'Kargo hızlandırıldı! Parça teslim edildi.');
                            setState(() {});
                          },
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // 5. Salvaged Parts Installation Section (Hurdalık Çıkma Parçaları)
                if (game.salvagedParts.isNotEmpty) ...[
                  Text(
                    'HURDALIKTAN TOPLANAN ÇIKMA PARÇALAR (${game.salvagedParts.length})',
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
                        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                        borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64748B),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black, width: 1.5),
                              ),
                              child: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(part.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                                  Text(
                                    'Kondisyon: %${part.conditionPercent} • Tahmini Değer: ${CurrencyFormatter.format(part.estimatedValue)}',
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            NeoBrutalButton(
                              label: 'MONTE ET',
                              icon: Icons.build_rounded,
                              backgroundColor: const Color(0xFF00E575),
                              textColor: Colors.black,
                              fontSize: 10.5,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              onPressed: () {
                                if (_selectedCar == null) return;
                                final success = ref.read(gameProvider.notifier).installPartToCar(part.id, _selectedCar!.id);
                                if (success) {
                                  NotificationService.showSuccess(context, '${part.name} araca başarıyla monte edildi!');
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

                // 6. Purchasable Workshop Equipment Upgrades
                Text(
                  'SATIN ALINABİLİR ATÖLYE EKİPMANLARI',
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
                  description: 'Aynı anda birden fazla aracın alt takımlarını hızlıca onarabilme imkanı sağlar.',
                  cost: 85000.0,
                  isOwned: hasLift,
                  icon: Icons.elevator_rounded,
                  color: const Color(0xFFFF7A00),
                  isDark: isDark,
                  onBuy: () => _buyEquipment('workshop_eq_lift', 85000.0, '4 Tonluk Hidrolik Araç Lifti'),
                ),
                const SizedBox(height: 8),

                WorkshopEquipmentTile(
                  id: 'workshop_eq_chassis_bench',
                  title: 'Lazerli Şasi Doğrultma Tezgahı',
                  description: 'Ağır kazalı pert araçların şasilerini milimetrik hassasiyetle fabrikasyon standardına çevirir.',
                  cost: 220000.0,
                  isOwned: hasChassisBench,
                  icon: Icons.straighten_rounded,
                  color: const Color(0xFFEF4444),
                  isDark: isDark,
                  onBuy: () => _buyEquipment('workshop_eq_chassis_bench', 220000.0, 'Lazerli Şasi Doğrultma Tezgahı'),
                ),
                const SizedBox(height: 8),

                WorkshopEquipmentTile(
                  id: 'workshop_eq_paint_booth',
                  title: 'Filtreli Endüstriyel Fırın Boya Kabini',
                  description: 'Kaporta ve boya işlemlerinde sarfiyatı azaltarak tüm boya maliyetlerini kalıcı olarak %50 düşürür.',
                  cost: 450000.0,
                  isOwned: hasPaintBooth,
                  icon: Icons.format_paint_rounded,
                  color: const Color(0xFFFFDE59),
                  isDark: isDark,
                  onBuy: () => _buyEquipment('workshop_eq_paint_booth', 450000.0, 'Filtreli Endüstriyel Fırın Boya Kabini'),
                ),
              ],
            ),
    );
  }

  Widget _buildHealthBar({
    required String label,
    required double percent,
    required bool isDark,
  }) {
    final color = percent >= 80 ? const Color(0xFF00E575) : (percent >= 50 ? const Color(0xFFFFDE59) : const Color(0xFFEF4444));
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800)),
              Text('%${percent.toInt()}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color)),
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
      NotificationService.showError(context, 'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    final success = ref.read(gameProvider.notifier).purchaseEquipmentUpgrade(eqId, cost);
    if (success) {
      NotificationService.showReward(context, '$name atölyene başarıyla kuruldu!');
      setState(() {});
    }
  }

  void _showTierSelectionDialog({
    required BuildContext context,
    required CarModel car,
    required String repairType,
    required double baseCost,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    repairType == 'engine'
                        ? 'MOTOR USTALIK SEVİYESİ SEÇİN'
                        : (repairType == 'transmission'
                            ? 'ŞANZIMAN İŞÇİLİK SEVİYESİ'
                            : (repairType == 'ecu'
                                ? 'OBD-II BEYİN İŞÇİLİK SEVİYESİ'
                                : (repairType == 'chassis'
                                    ? 'ŞASİ DOĞRULTMA İŞÇİLİK SEVİYESİ'
                                    : 'KAPORTA İŞÇİLİK SEVİYESİ'))),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTierOption(
                title: 'Çırak İşi (%68 Başarı Şansı)',
                subtitle: 'Hızlı ve ucuz onarım, ancak ayar tutturamama riski var.',
                cost: baseCost * 0.55,
                successRate: '%68',
                color: const Color(0xFFFF7A00),
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _executeTierRepair(car, repairType, RepairTier.apprentice, baseCost * 0.55);
                },
              ),
              const SizedBox(height: 8),
              _buildTierOption(
                title: 'Kalfa İşi (%88 Başarı Şansı)',
                subtitle: 'Dengeli sanayi standardı işçilik ve kaliteli parça montajı.',
                cost: baseCost * 1.0,
                successRate: '%88',
                color: const Color(0xFF38BDF8),
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _executeTierRepair(car, repairType, RepairTier.journeyman, baseCost * 1.0);
                },
              ),
              const SizedBox(height: 8),
              _buildTierOption(
                title: 'Usta İşi (%100 Kesin Başarı)',
                subtitle: 'Kusursuz işçilik, sıfır hata toleransı ile fabrika kondisyonu.',
                cost: baseCost * 1.75,
                successRate: '%100',
                color: const Color(0xFF00E575),
                isDark: isDark,
                onTap: () {
                  Navigator.pop(ctx);
                  _executeTierRepair(car, repairType, RepairTier.master, baseCost * 1.75);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTierOption({
    required String title,
    required String subtitle,
    required double cost,
    required String successRate,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          successRate,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(subtitle, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              CurrencyFormatter.formatShort(cost),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
            ),
          ],
        ),
      ),
    );
  }

  void _executeTierRepair(CarModel car, String repairType, RepairTier tier, double cost) {
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(context, 'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    if (repairType == 'engine') {
      if (car.expertise.engineCondition >= 99.5) {
        NotificationService.showInfo(context, 'Motor zaten kusursuz durumda!');
        return;
      }
      final result = ref.read(gameProvider.notifier).repairEngineWithTier(car, tier);
      if (result.isSuccess) {
        NotificationService.showSuccess(context, result.message);
        setState(() {
          _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      } else {
        NotificationService.showError(context, result.message);
      }
    } else if (repairType == 'transmission') {
      if (car.expertise.transmissionCondition >= 99.5) {
        NotificationService.showInfo(context, 'Şanzıman ve baskı balata zaten kusursuz durumda!');
        return;
      }
      final result = ref.read(gameProvider.notifier).repairTransmissionWithTier(car, tier);
      if (result.isSuccess) {
        NotificationService.showSuccess(context, result.message);
        setState(() {
          _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == car.id, orElse: () => car);
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
        NotificationService.showInfo(context, 'Kaportada hasarlı veya boyanacak parça yok!');
        return;
      }

      final double successRate = RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(context, 'Boya fırınında renk dalgalanması oldu! ₺${CurrencyFormatter.formatShort(cost * 0.4)} sarfiyat yandı.');
        return;
      }

      final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
        car.id,
        repairType: 'bodywork',
        cost: cost,
      );

      if (success) {
        NotificationService.showSuccess(context, 'Tüm kaporta parçaları başarıyla onarıldı ve fırın boya tamamlandı!');
        setState(() {
          _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    } else if (repairType == 'ecu') {
      if (car.expertise.isEcuCleaned) {
        NotificationService.showInfo(context, 'OBD-II Beyin arıza tespiti zaten yapılmış, sistem kusursuz!');
        return;
      }
      final double successRate = RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(context, 'ECU haberleşme protokolü kurulamadı! ₺${CurrencyFormatter.formatShort(cost * 0.4)} sarfiyat yandı.');
        return;
      }
      final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
        car.id,
        repairType: 'ecu',
        cost: cost,
      );
      if (success) {
        NotificationService.showSuccess(context, 'Tüm sensör ve arıza kodları OBD-II ile başarıyla temizlendi!');
        setState(() {
          _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    } else if (repairType == 'chassis') {
      if (car.expertise.isChassisAligned) {
        NotificationService.showInfo(context, 'Lazerli şasi doğrultma zaten yapılmış, şasi kusursuz!');
        return;
      }
      final double successRate = RepairEngine.getSuccessRate(tier);
      final isSuccess = Random().nextDouble() <= successRate;
      if (!isSuccess) {
        ref.read(gameProvider.notifier).deductBalance(cost * 0.4);
        NotificationService.showError(context, 'Lazerli şasi tezgahında sıfır tolerans tutturulamadı! ₺${CurrencyFormatter.formatShort(cost * 0.4)} sarfiyat yandı.');
        return;
      }
      final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
        car.id,
        repairType: 'chassis',
        cost: cost,
      );
      if (success) {
        NotificationService.showSuccess(context, 'Lazerli şasi düzeltme ve rot-balans kusursuz tamamlandı!');
        setState(() {
          _selectedCar = ref.read(gameProvider).ownedCars.firstWhere((c) => c.id == car.id, orElse: () => car);
        });
      }
    }
  }

  void _showOrderPartsSheet(BuildContext context, CarModel car, DealershipModel game, bool isDark) {
    final parts = [
      'Ön Kaput',
      'Ön Tampon',
      'Tavan',
      'Sol Ön Kapı',
      'Sağ Ön Kapı',
      'Sol Çamurluk',
      'Sağ Çamurluk',
      'Bagaj Kapağı',
      'Motor Bloğu & Piston',
      'Şanzıman & Debriyaj',
    ];

    String selectedPart = parts.first;
    OrderType selectedType = OrderType.newOemPart;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final cost = RepairEngine.calculatePartRepairCost(car, selectedPart, selectedType);
            final durationSeconds = selectedType == OrderType.quickPatch ? 30 : (selectedType == OrderType.masterRepair ? 60 : 120);

            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'YEDEK PARÇA SİPARİŞİ VER',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('Parça Seçin:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPart,
                        isExpanded: true,
                        dropdownColor: isDark ? const Color(0xFF1E2330) : Colors.white,
                        items: parts.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(p, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedPart = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Tedarik / Parça Kalitesi:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildOrderTypeTile(
                        title: 'Geçici Yama',
                        time: '30 sn',
                        type: OrderType.quickPatch,
                        selected: selectedType,
                        isDark: isDark,
                        onTap: () => setSheetState(() => selectedType = OrderType.quickPatch),
                      ),
                      const SizedBox(width: 6),
                      _buildOrderTypeTile(
                        title: 'Usta / Çıkma',
                        time: '60 sn',
                        type: OrderType.masterRepair,
                        selected: selectedType,
                        isDark: isDark,
                        onTap: () => setSheetState(() => selectedType = OrderType.masterRepair),
                      ),
                      const SizedBox(width: 6),
                      _buildOrderTypeTile(
                        title: 'Sıfır OEM',
                        time: '120 sn',
                        type: OrderType.newOemPart,
                        selected: selectedType,
                        isDark: isDark,
                        onTap: () => setSheetState(() => selectedType = OrderType.newOemPart),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black, width: 1.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sipariş Maliyeti', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            Text(CurrencyFormatter.format(cost), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalGreen)),
                          ],
                        ),
                        Text(
                          'Teslimat: $durationSeconds Saniye',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalOrange),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  NeoBrutalButton(
                    label: 'SİPARİŞİ ONAYLA VE GÖNDER',
                    icon: Icons.shopping_cart_checkout_rounded,
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      if (game.balance < cost) {
                        NotificationService.showError(context, 'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekli.');
                        return;
                      }

                      final success = ref.read(gameProvider.notifier).orderPart(
                        carId: car.id,
                        partName: selectedPart,
                        orderType: selectedType,
                        cost: cost,
                        deliveryDurationSeconds: durationSeconds,
                      );

                      Navigator.pop(ctx);
                      if (success) {
                        NotificationService.showSuccess(
                          context,
                          '$selectedPart siparişi kargoya verildi! (${durationSeconds}s içinde teslim edilecek)',
                        );
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrderTypeTile({
    required String title,
    required String time,
    required OrderType type,
    required OrderType selected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSel = type == selected;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSel ? AppColors.brutalYellow : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.4),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isSel ? Colors.black : (isDark ? Colors.white : Colors.black87),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: isSel ? Colors.black87 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
