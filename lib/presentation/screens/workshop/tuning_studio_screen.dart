import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class TuningStudioOption {
  final String id;
  final String title;
  final String description;
  final double cost;
  final double valueMultiplier;
  final IconData icon;
  final Color color;

  const TuningStudioOption({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.valueMultiplier,
    required this.icon,
    required this.color,
  });
}

class TuningStudioScreen extends ConsumerStatefulWidget {
  const TuningStudioScreen({super.key});

  @override
  ConsumerState<TuningStudioScreen> createState() => _TuningStudioScreenState();
}

class _TuningStudioScreenState extends ConsumerState<TuningStudioScreen> {
  CarModel? _selectedCar;

  final List<TuningStudioOption> _tuningOptions = const [
    TuningStudioOption(
      id: 'tune_ecu_stg1',
      title: 'Stage 1 ECU Beyin Yazılımı',
      description: 'Motor beyin haritasını güncelleyerek +45 BG güç kazanımı sağla.',
      cost: 15000,
      valueMultiplier: 1.12,
      icon: Icons.memory_rounded,
      color: AppColors.brutalYellow,
    ),
    TuningStudioOption(
      id: 'tune_ecu_stg2',
      title: 'Stage 2 Performans & Downpipe',
      description: 'Açık hava filtresi ve paslanmaz downpipe ile tam performans yükle.',
      cost: 35000,
      valueMultiplier: 1.25,
      icon: Icons.speed_rounded,
      color: AppColors.errorRed,
    ),
    TuningStudioOption(
      id: 'tune_exhaust',
      title: 'Varex Kumandalı Egzoz Sistemi',
      description: 'Çift çıkış kumandalı performans egzozu ile araç çekiciliğini artır.',
      cost: 22000,
      valueMultiplier: 1.15,
      icon: Icons.minor_crash_rounded,
      color: AppColors.brutalOrange,
    ),
    TuningStudioOption(
      id: 'tune_bodykit',
      title: 'Karbon Fiber Aero Bodykit & Spoyler',
      description: 'Ön karlık, yan marşpiyel ve karbon difüzör takımı.',
      cost: 45000,
      valueMultiplier: 1.30,
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFFA855F7),
    ),
    TuningStudioOption(
      id: 'tune_rims',
      title: '20" Dövme Alaşım Spor Jant Takımı',
      description: 'Lüks hafif alaşım jantlar ve alçak profil performans lastikleri.',
      cost: 28000,
      valueMultiplier: 1.18,
      icon: Icons.tire_repair_rounded,
      color: Color(0xFF06B6D4),
    ),
    TuningStudioOption(
      id: 'tune_air_suspension',
      title: 'Air Ride Havalı Süspansiyon Kiti',
      description: 'Bağımsız körüklü uzaktan kumandalı basık süspansiyon sistemi.',
      cost: 55000,
      valueMultiplier: 1.35,
      icon: Icons.tune_rounded,
      color: AppColors.brutalGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;
    final ownedCars = game.ownedCars;

    if (_selectedCar != null && !ownedCars.any((c) => c.id == _selectedCar!.id)) {
      _selectedCar = null;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'VIP TUNİNG & MODİFİYE STÜDYOSU',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Header Banner
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: const Icon(Icons.speed_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIP TUNİNG & GÜÇ YÜKLEME',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Araçlara özel performans yazılımı ve bodykit ekleyerek değerlerini %35\'e kadar artırın.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Car Selector
          Text(
            'TUNİNG YAPILACAK ARACI SEÇ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          if (ownedCars.isEmpty)
            NeoBrutalCard(
              padding: const EdgeInsets.all(20),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
              borderRadius: 12,
              child: const Center(
                child: Text(
                  'Garajında tuning uygulayabileceğin araç yok!',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
              ),
            )
          else
            SizedBox(
              height: 86,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ownedCars.length,
                itemBuilder: (context, index) {
                  final car = ownedCars[index];
                  final isSelected = _selectedCar?.id == car.id;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCar = car),
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark ? const Color(0xFF141721) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black, width: isSelected ? 2.5 : 1.5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${car.brand} ${car.modelName}',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₺${CurrencyFormatter.formatShort(car.currentPurchasePrice)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.black87 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),

          // 3. Tuning Modules
          if (_selectedCar != null) ...[
            Text(
              '${_selectedCar!.brand} ${_selectedCar!.modelName} İÇİN MODÜLLER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? Colors.white70 : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),

            ..._tuningOptions.map((opt) {
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
                                  color: opt.color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black, width: 1.4),
                                ),
                                child: Icon(opt.icon, color: Colors.black, size: 20),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                opt.title,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          NeoBrutalBadge(
                            text: '+%${((opt.valueMultiplier - 1.0) * 100).toStringAsFixed(0)} Değer',
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        opt.description,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₺${CurrencyFormatter.formatShort(opt.cost)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.brutalOrange),
                          ),
                          NeoBrutalButton(
                            label: 'UYGULA',
                            icon: Icons.flash_on_rounded,
                            backgroundColor: opt.color,
                            textColor: Colors.black,
                            fontSize: 11.5,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            onPressed: () {
                              if (game.balance < opt.cost) {
                                NotificationService.showError(context, 'Yetersiz bakiye! ₺${CurrencyFormatter.formatShort(opt.cost)} gerekli.');
                                return;
                              }

                              final newMarketValue = _selectedCar!.baseMarketValue * opt.valueMultiplier;
                              final updatedCar = _selectedCar!.copyWith(baseMarketValue: newMarketValue);
                              ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, opt.cost);

                              setState(() {
                                _selectedCar = updatedCar;
                              });

                              NotificationService.showSuccess(
                                context,
                                '${opt.title} uygulandı! Yeni Pazar Değeri: ₺${CurrencyFormatter.formatShort(newMarketValue)}',
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
          ],
        ],
      ),
    );
  }
}
