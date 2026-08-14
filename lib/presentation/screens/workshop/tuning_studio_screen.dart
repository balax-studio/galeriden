import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_double_bezel_card.dart';
import '../../widgets/app_glass_container.dart';
import '../../widgets/app_tactile_button.dart';

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
      color: Colors.amber,
    ),
    TuningStudioOption(
      id: 'tune_ecu_stg2',
      title: 'Stage 2 Performans & Downpipe',
      description: 'Açık hava filtresi ve paslanmaz downpipe ile tam performans yükle.',
      cost: 35000,
      valueMultiplier: 1.25,
      icon: Icons.speed_rounded,
      color: Colors.redAccent,
    ),
    TuningStudioOption(
      id: 'tune_exhaust',
      title: 'Varex Kumandalı Egzoz Sistemi',
      description: 'Çift çıkış kumandalı performans egzozu ile araç çekiciliğini artır.',
      cost: 22000,
      valueMultiplier: 1.15,
      icon: Icons.minor_crash_rounded,
      color: Colors.orangeAccent,
    ),
    TuningStudioOption(
      id: 'tune_bodykit',
      title: 'Karbon Fiber Aero Bodykit & Spoyler',
      description: 'Ön karlık, yan marşpiyel ve karbon difüzör takımı.',
      cost: 45000,
      valueMultiplier: 1.30,
      icon: Icons.auto_awesome_rounded,
      color: Colors.purpleAccent,
    ),
    TuningStudioOption(
      id: 'tune_rims',
      title: '20" Dövme Alaşım Spor Jant Takımı',
      description: 'Lüks hafif alaşım jantlar ve alçak profil performans lastikleri.',
      cost: 28000,
      valueMultiplier: 1.18,
      icon: Icons.tire_repair_rounded,
      color: Colors.cyanAccent,
    ),
    TuningStudioOption(
      id: 'tune_air_suspension',
      title: 'Air Ride Havalı Süspansiyon Kiti',
      description: 'Bağımsız körüklü uzaktan kumandalı basık süspansiyon sistemi.',
      cost: 55000,
      valueMultiplier: 1.35,
      icon: Icons.tune_rounded,
      color: Colors.greenAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final ownedCars = game.ownedCars;

    if (_selectedCar != null && !ownedCars.any((c) => c.id == _selectedCar!.id)) {
      _selectedCar = null;
    }

    return Scaffold(
      backgroundColor: p.isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: p.textPrimaryColor, size: 20),
          onPressed: () => context.pop(),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'PERFORMANS & TUNING STÜDYOSU',
            style: AppTypography.titleLarge(p.isDark).copyWith(letterSpacing: 1.2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Banner
            AppGlassContainer(
              padding: const EdgeInsets.all(16),
              borderColor: Colors.amber.withValues(alpha: 0.5),
              glowColor: Colors.amber.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.speed_rounded, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('VIP Tuning & Modifikasyon', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          'Araçlarına özel performans yazılımı ve bodykit ekleyerek değerlerini %35\'e kadar artır.',
                          style: AppTypography.bodyMedium(p.isDark).copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Car Selector Header
            Text('TUNİNG UYGULANACAK ARACI SEÇ', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),

            if (ownedCars.isEmpty)
              AppGlassContainer(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.directions_car_filled_rounded, color: p.textSecondaryColor, size: 48),
                      const SizedBox(height: 12),
                      Text('Garajında Henüz Araç Yok!', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Pazardan araç satın alarak tuning atölyesine getirebilirsin.', style: AppTypography.bodyMedium(p.isDark)),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: ownedCars.length,
                  itemBuilder: (context, index) {
                    final car = ownedCars[index];
                    final isSelected = _selectedCar?.id == car.id;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCar = car),
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? p.primaryColor.withValues(alpha: 0.15) : p.surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? p.primaryColor : p.surfaceBorderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${car.modelYear} ${car.brand}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle_rounded, color: p.primaryColor, size: 18),
                              ],
                            ),
                            Text(car.modelName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTypography.bodyMedium(p.isDark)),
                            Text(
                              '₺${CurrencyFormatter.formatShort(car.currentPurchasePrice)}',
                              style: TextStyle(color: p.successColor, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            if (_selectedCar != null) ...[
              Text('${_selectedCar!.brand} ${_selectedCar!.modelName} İÇİN TUNİNG MODÜLLERİ', style: AppTypography.labelSmall(p.isDark)),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _tuningOptions.length,
                itemBuilder: (context, index) {
                  final opt = _tuningOptions[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppDoubleBezelCard(
                      accentColor: opt.color,
                      outerRadius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: opt.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(opt.icon, color: opt.color, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(opt.title, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Değer Artışı: +%${((opt.valueMultiplier - 1.0) * 100).toStringAsFixed(0)}',
                                      style: TextStyle(color: p.successColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(opt.description, style: AppTypography.bodyMedium(p.isDark)),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Maliyet: ₺${CurrencyFormatter.formatShort(opt.cost)}',
                                style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14),
                              ),
                              AppTactileButton(
                                onPressed: () {
                                  if (game.balance < opt.cost) {
                                    NotificationService.showError(context, 'Yetersiz bakiye! ₺${CurrencyFormatter.formatShort(opt.cost)} gerekli.');
                                    return;
                                  }

                                  // Apply Tuning Upgrade to selected car
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: opt.color,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.flash_on_rounded, size: 16, color: Colors.black),
                                      const SizedBox(width: 6),
                                      const Text(
                                        'Uygula',
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
