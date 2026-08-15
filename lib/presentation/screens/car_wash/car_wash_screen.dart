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

class CarWashScreen extends ConsumerStatefulWidget {
  const CarWashScreen({super.key});

  @override
  ConsumerState<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends ConsumerState<CarWashScreen> {
  String? _selectedCarId;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (game.ownedCars.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(
          title: 'OTO YIKAMA & DETAILING',
        ),
        body: Center(
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
        ),
      );
    }

    final selectedCar = game.ownedCars.firstWhere(
      (c) => c.id == _selectedCarId,
      orElse: () => game.ownedCars.first,
    );
    _selectedCarId = selectedCar.id;

    final hasHotWaterGun = game.unlockedBuildings.contains('wash_eq_hot_water');
    final hasFoamPump = game.unlockedBuildings.contains('wash_eq_foam_pump');
    final hasPolisher = game.unlockedBuildings.contains('wash_eq_dual_polisher');

    // Discounts applied if equipment owned
    final discountMultiplier = hasFoamPump ? 0.70 : 1.0;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'OTO YIKAMA & DETAILING',
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
          : ListView(
              padding: const EdgeInsets.all(14),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Garage Car Selection Carousel
                Text(
                  'YIKANACAK ARACI SEÇ (${game.ownedCars.length} Araç)',
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
                      final isSelected = selectedCar.id == car.id;
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
                              Text(
                                car.brand,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                                maxLines: 1,
                              ),
                              Text(
                                car.modelName,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                                  Text(
                                    CurrencyFormatter.formatShort(car.baseMarketValue),
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                                  ),
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

                // 2. Active Wash Bay Interactive Visual
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
                              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
                            ),
                            child: const Icon(Icons.water_drop_rounded, color: Colors.black, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${selectedCar.brand} ${selectedCar.modelName}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                ),
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
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 3. Wash & Detailing Service Packages
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
                    car: selectedCar,
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
                    car: selectedCar,
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
                  bonusText: hasPolisher ? '+%8 Satış Değeri (Polisaj Bonusu!)' : '+%6 Satış Değeri',
                  badgeColor: const Color(0xFFFFDE59),
                  isCompleted: selectedCar.isPolished,
                  isDark: isDark,
                  onApply: () => _applyWashService(
                    car: selectedCar,
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
                    car: selectedCar,
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

                // 4. Purchasable Wash Equipment Upgrades
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0)],
            ),
            child: Icon(icon, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (isOwned)
                      const NeoBrutalBadge(
                        text: 'SAHİPSİN',
                        backgroundColor: Color(0xFF00E575),
                        textColor: Colors.black,
                        fontSize: 9,
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  isOwned ? 'Maliyeti düşürüldü' : 'Fiyat: ${CurrencyFormatter.format(cost)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isOwned ? const Color(0xFF64748B) : const Color(0xFFFF7A00),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isOwned)
            NeoBrutalButton(
              label: 'SATIN AL',
              icon: Icons.shopping_cart_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 10.5,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onPressed: onBuy,
            ),
        ],
      ),
    );
  }

  void _applyWashService({
    required CarModel car,
    required double cost,
    required double valueBoost,
    bool setWashed = false,
    bool setInterior = false,
    bool setPolished = false,
    bool setDetailed = false,
    required String successMsg,
  }) {
    if (setDetailed && car.isDetailedCleaned) {
      NotificationService.showInfo(context, 'VIP Seramik kaplama zaten uygulanmış!');
      return;
    }
    if (setPolished && !setDetailed && car.isPolished) {
      NotificationService.showInfo(context, 'Pasta cila zaten uygulanmış!');
      return;
    }
    if (setInterior && car.isInteriorCleaned) {
      NotificationService.showInfo(context, 'Detaylı iç-dış yıkama zaten uygulanmış!');
      return;
    }
    if (setWashed && !setInterior && !setPolished && !setDetailed && car.isWashed) {
      NotificationService.showInfo(context, 'Köpüklü standart yıkama zaten yapılmış!');
      return;
    }

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
      setState(() {
        _selectedCarId = car.id;
      });
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
      NotificationService.showReward(context, '$name satın alındı ve aktif edildi!');
      setState(() {});
    }
  }
}
