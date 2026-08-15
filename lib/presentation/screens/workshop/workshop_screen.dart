import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
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
          ? Center(
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
                      const Icon(Icons.build_circle_rounded, size: 44, color: Color(0xFFFF7A00)),
                      const SizedBox(height: 12),
                      const Text(
                        'Garajında Onarılacak Araç Yok!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pazardan veya hurdalıktan kelepir araç satın alarak burada toplayabilir ve değerini ikiye katlayabilirsin.',
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
                                    'Mevcut Değer: ${CurrencyFormatter.formatShort(_selectedCar!.baseMarketValue)} • Model Yılı: ${_selectedCar!.modelYear}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
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

                WorkshopRepairTile(
                  title: '1. Motor Rektifiye & Subap Ayarı',
                  description: 'Piston, segman ve subapları yenileyerek motor kondisyonunu %100 yapar.',
                  cost: 18500.0,
                  bonusText: 'Motor %100 & +%10 Değer',
                  badgeColor: const Color(0xFF00E575),
                  isDark: isDark,
                  onRepair: () => _applyRepair(
                    type: 'engine',
                    cost: 18500.0,
                    successMsg: 'Motor rektifiye edildi! Performans ve kondisyon %100 oldu.',
                  ),
                ),
                const SizedBox(height: 8),

                WorkshopRepairTile(
                  title: '2. Şanzıman & Baskı Balata Yenileme',
                  description: 'Vites geçişlerini pürüzsüzleştirir, debriyaj setini sıfırlar.',
                  cost: 12000.0,
                  bonusText: 'Şanzıman %100 & +%8 Değer',
                  badgeColor: const Color(0xFF38BDF8),
                  isDark: isDark,
                  onRepair: () => _applyRepair(
                    type: 'transmission',
                    cost: 12000.0,
                    successMsg: 'Şanzıman ve baskı balata sıfırlandı!',
                  ),
                ),
                const SizedBox(height: 8),

                WorkshopRepairTile(
                  title: '3. Bilgisayarlı OBD-II Beyin (ECU) Arıza Tespiti',
                  description: 'Tüm sensör, enjektör ve gizli elektriksel arıza kodlarını siler.',
                  cost: 4500.0,
                  bonusText: 'Gizli Kusurlar Silinir',
                  badgeColor: const Color(0xFFA855F7),
                  isDark: isDark,
                  onRepair: () => _applyRepair(
                    type: 'ecu',
                    cost: 4500.0,
                    successMsg: 'Elektronik beyin taraması yapıldı, tüm arıza lambaları söndü!',
                  ),
                ),
                const SizedBox(height: 8),

                WorkshopRepairTile(
                  title: '4. Kaporta Çekiçleme & Fırın Boya',
                  description: 'Değişen veya boyalı kaporta parçalarını fabrika kondisyonuna getirir.',
                  cost: 22000.0 * paintCostMultiplier,
                  bonusText: hasPaintBooth ? '+%15 Değer (Boya Fırını %50 İndirimi!)' : '+%15 Değer Artışı',
                  badgeColor: const Color(0xFFFFDE59),
                  isDark: isDark,
                  onRepair: () => _applyRepair(
                    type: 'bodywork',
                    cost: 22000.0 * paintCostMultiplier,
                    successMsg: 'Kaporta düzeltildi ve fırın boyası çekildi! Orijinal görünüme kavuştu.',
                  ),
                ),
                const SizedBox(height: 8),

                WorkshopRepairTile(
                  title: '5. Lazerli Şasi Düzeltme & Rot-Balans',
                  description: 'Ağır kazalı, podye veya direk hasarlı araçların şasisini sıfır toleransla doğrultur.',
                  cost: 45000.0,
                  bonusText: hasChassisBench ? '+%20 Süper Değer (Şasi Tezgahı Bonusu!)' : '+%20 Değer',
                  badgeColor: const Color(0xFFEF4444),
                  isDark: isDark,
                  onRepair: () => _applyRepair(
                    type: 'chassis',
                    cost: 45000.0,
                    successMsg: 'Lazerli şasi doğrultma tamamlandı! Araç fabrikasyon dengesine ulaştı.',
                  ),
                ),
                const SizedBox(height: 20),

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

  void _applyRepair({
    required String type,
    required double cost,
    required String successMsg,
  }) {
    if (_selectedCar == null) return;
    final game = ref.read(gameProvider);
    if (game.balance < cost) {
      NotificationService.showError(context, 'Yetersiz Bakiye! ${CurrencyFormatter.format(cost)} gerekiyor.');
      return;
    }

    final success = ref.read(gameProvider.notifier).performWorkshopStationRepair(
      _selectedCar!.id,
      repairType: type,
      cost: cost,
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
      NotificationService.showReward(context, '$name atölyene başarıyla kuruldu!');
      setState(() {});
    }
  }
}
