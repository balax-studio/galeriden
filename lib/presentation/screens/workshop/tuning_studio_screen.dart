import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/tuning_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';
import '../../widgets/mini_games/dyno_run_canvas.dart';

class TuningStudioScreen extends ConsumerStatefulWidget {
  const TuningStudioScreen({super.key});

  @override
  ConsumerState<TuningStudioScreen> createState() => _TuningStudioScreenState();
}

class _TuningStudioScreenState extends ConsumerState<TuningStudioScreen> {
  CarModel? _selectedCar;
  int _selectedTabIndex = 0; // 0: Tümü, 1: Motor, 2: Aero, 3: Yürüyen, 4: Egzoz, 5: Hazır Paketler

  void _runDynoSimulation(BuildContext context, CarDynoStats dyno) {
    if (_selectedCar == null) return;
    DynoRunCanvasModal.show(context, car: _selectedCar!, dyno: dyno);
  }

  void _applyTuningOption(TuningOptionModel opt) {
    final game = ref.read(gameProvider);
    if (game.balance < opt.cost) {
      NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.formatShort(opt.cost)} gerekli.');
      return;
    }

    final wasOverTuned = _selectedCar!.isOverTuned;
    final updatedCar = _selectedCar!.copyWith(
      appliedDetailingOptionIds: [..._selectedCar!.appliedDetailingOptionIds, opt.id],
    );
    ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, opt.cost);

    setState(() {
      _selectedCar = updatedCar;
    });

    final newMarketValue = updatedCar.estimatedRealValue;
    NotificationService.showSuccess(
      context,
      '${opt.title} uygulandı! • ${opt.hpGain > 0 ? '+${opt.hpGain} HP • ' : ''}Değer: ${CurrencyFormatter.formatShort(newMarketValue)}',
    );

    if (!wasOverTuned && updatedCar.isOverTuned) {
      _showOverTunedWarningDialog();
    }
  }

  void _applyPresetBuild(TuningPresetBuild preset) {
    final game = ref.read(gameProvider);
    final discountedCost = preset.getDiscountedCost();

    if (game.balance < discountedCost) {
      NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.format(discountedCost)} gerekli.');
      return;
    }

    final wasOverTuned = _selectedCar!.isOverTuned;
    // Apply all unapplied options
    final newOptionIds = Set<String>.from(_selectedCar!.appliedDetailingOptionIds)..addAll(preset.optionIds);
    final updatedCar = _selectedCar!.copyWith(
      appliedDetailingOptionIds: newOptionIds.toList(),
    );

    ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, discountedCost);

    setState(() {
      _selectedCar = updatedCar;
    });

    final newMarketValue = updatedCar.estimatedRealValue;
    NotificationService.showSuccess(
      context,
      '${preset.title} %15 indirimle uygulandı! Araç Pazar Değeri: ${CurrencyFormatter.formatShort(newMarketValue)}',
    );

    if (!wasOverTuned && updatedCar.isOverTuned) {
      _showOverTunedWarningDialog();
    }
  }

  void _showOverTunedWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1410),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.brutalOrange, width: 2.8),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.brutalOrange, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'DİKKAT • AŞIRI MODİFİYE',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Bu araç artık aşırı modifiyeli statüsüne ulaştı! Standart aile, memur ve filo müşterileri bu aracı tercih etmeyebilir.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFFFED7AA)),
            ),
            SizedBox(height: 8),
            Text(
              'Gelen teklifler ağırlıklı olarak genç ve modifiye tutkunu kitleye kayacaktır. Pazar teklif sıklığı %30-40 düşebilir.',
              style: TextStyle(fontSize: 11.5, color: Color(0xFFCBD5E1), fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          NeoBrutalButton(
            label: 'ANLADIM • DEVAM ET',
            backgroundColor: AppColors.brutalOrange,
            textColor: Colors.black,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _applyLegalProject() {
    const certCost = 4500.0;
    final game = ref.read(gameProvider);
    if (game.balance < certCost) {
      NotificationService.showError(context, 'Yetersiz bakiye! ${CurrencyFormatter.format(certCost)} gerekli.');
      return;
    }

    final updatedCar = _selectedCar!.copyWith(
      appliedDetailingOptionIds: [..._selectedCar!.appliedDetailingOptionIds, 'tune_legal_project_cert'],
    );

    ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, certCost);

    setState(() {
      _selectedCar = updatedCar;
    });

    NotificationService.showSuccess(
      context,
      'Mühendislik projesi onaylandı! Araç TÜVTÜRK & Ruhsata işlendi • +%5 Değer.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/tuning-studio')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'TUNING & MODİFİYE STÜDYOSU'),
        body: const NeoBrutalLockedFeatureView(
          route: '/tuning-studio',
          featureTitle: 'TUNING STÜDYOSU',
          icon: Icons.speed_rounded,
        ),
      );
    }

    final ownedCars = game.ownedCars;

    if (_selectedCar != null && !ownedCars.any((c) => c.id == _selectedCar!.id)) {
      _selectedCar = null;
    } else if (_selectedCar != null) {
      _selectedCar = ownedCars.firstWhere((c) => c.id == _selectedCar!.id);
    }

    final dyno = _selectedCar != null ? CarDynoCalculator.calculateDyno(_selectedCar!) : null;

    final tabs = [
      (label: 'TÜMÜ • ${TuningCatalog.allOptions.length}', icon: Icons.tune_rounded),
      (label: 'MOTOR', icon: Icons.speed_rounded),
      (label: 'AERO', icon: Icons.palette_rounded),
      (label: 'YÜRÜYEN', icon: Icons.directions_car_rounded),
      (label: 'EGZOZ', icon: Icons.volume_up_rounded),
      (label: 'PAKETLER', icon: Icons.inventory_2_rounded),
    ];

    List<TuningOptionModel> visibleOptions;
    switch (_selectedTabIndex) {
      case 1:
        visibleOptions = TuningCatalog.getOptionsByCategory(TuningCategory.powertrain);
        break;
      case 2:
        visibleOptions = TuningCatalog.getOptionsByCategory(TuningCategory.aero);
        break;
      case 3:
        visibleOptions = TuningCatalog.getOptionsByCategory(TuningCategory.stance);
        break;
      case 4:
        visibleOptions = TuningCatalog.getOptionsByCategory(TuningCategory.exhaust);
        break;
      default:
        visibleOptions = TuningCatalog.allOptions;
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'VIP TUNİNG & MODİFİYE STÜDYOSU',
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
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.speed_rounded, color: Colors.black, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VIP PERFORMANS & MODİFİYE ATÖLYESİ',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Stage yazılımlar, aero bodykit ve egzoz sistemleri ile araçlarınızı pist canavarına dönüştürün.',
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
            'MODİFİYE EDİLECEK ARACI SEÇ',
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
                      width: 160,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brutalYellow
                            : (isDark ? const Color(0xFF141721) : Colors.white),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF7A00) : (isDark ? const Color(0xFF334155) : const Color(0xFF0F172A)),
                          width: isSelected ? 2.5 : 2.0,
                        ),
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
                            CurrencyFormatter.formatShort(car.baseMarketValue),
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

          // 3. Dyno Dashboard & Car Stats
          if (_selectedCar != null && dyno != null) ...[
            NeoBrutalCard(
              padding: const EdgeInsets.all(14),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.brutalGreen,
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, color: AppColors.brutalGreen, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'DYNO GÜÇ KARNESİ • ${_selectedCar!.brand}',
                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 4,
                        children: [
                          if (_selectedCar!.isOverTuned)
                            const NeoBrutalBadge(
                              text: 'AŞIRI MODİFİYE • GENÇ KİTLE',
                              backgroundColor: AppColors.brutalOrange,
                              textColor: Colors.black,
                              fontSize: 9.0,
                            ),
                          NeoBrutalBadge(
                            text: dyno.isInspectionCompliant ? 'TÜVTÜRK UYGUN' : 'MUAYENEDEN GEÇMEZ',
                            backgroundColor: dyno.isInspectionCompliant ? AppColors.brutalGreen : AppColors.errorRed,
                            textColor: dyno.isInspectionCompliant ? Colors.black : Colors.white,
                            fontSize: 9.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildMetricTile('GÜÇ', '${dyno.totalHp} HP', '+${dyno.totalHp - dyno.baseHp} HP', AppColors.brutalGreen, isDark)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMetricTile('TORK', '${dyno.totalNm} Nm', '+${dyno.totalNm - dyno.baseNm} Nm', AppColors.brutalOrange, isDark)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMetricTile('0-100', '${dyno.currentAccel}s', '${dyno.baseAccel}s idi', const Color(0xFF06B6D4), isDark)),
                      const SizedBox(width: 6),
                      Expanded(child: _buildMetricTile('DESİBEL', '${dyno.exhaustDb} dB', '%${dyno.tuningRating} Skor', const Color(0xFFA855F7), isDark)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: NeoBrutalButton(
                          icon: Icons.speed_rounded,
                          label: 'DYNO ÇEKİMİ YAP',
                          backgroundColor: AppColors.brutalYellow,
                          textColor: Colors.black,
                          fontSize: 11,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          onPressed: () => _runDynoSimulation(context, dyno),
                        ),
                      ),
                      if (!dyno.isInspectionCompliant) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: NeoBrutalButton(
                            icon: Icons.shield_rounded,
                            label: 'RUHSATA İŞLET • ₺4.5k',
                            backgroundColor: AppColors.brutalGreen,
                            textColor: Colors.black,
                            fontSize: 10.5,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            onPressed: _applyLegalProject,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Tab Bar (Tümü, Motor, Aero, Stance, Egzoz, Paketler)
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: tabs.length,
                itemBuilder: (ctx, i) {
                  final isTabSelected = _selectedTabIndex == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTabIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isTabSelected
                            ? AppColors.brutalYellow
                            : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isTabSelected ? const Color(0xFFFF7A00) : (isDark ? const Color(0xFF334155) : const Color(0xFF0F172A)),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 13,
                            color: isTabSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isTabSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // 5. Preset Builds Tab or Option List
            if (_selectedTabIndex == 5) ...[
              ...TuningPresetBuilds.allPresets.map((preset) {
                final discountedPrice = preset.getDiscountedCost();
                final rawPrice = TuningCatalog.calculateRawCost(preset.optionIds);
                final allApplied = preset.optionIds.every((id) => _selectedCar!.appliedDetailingOptionIds.contains(id));

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: allApplied ? AppColors.brutalGreen : AppColors.brutalOrange,
                    borderRadius: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(preset.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
                            NeoBrutalBadge(
                              text: allApplied ? 'UYGULANDI' : '%15 İNDİRİMLİ',
                              backgroundColor: allApplied ? AppColors.brutalGreen : AppColors.brutalYellow,
                              textColor: Colors.black,
                              fontSize: 10,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(preset.description, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  CurrencyFormatter.formatShort(rawPrice),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: Color(0xFF64748B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatShort(discountedPrice),
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                                ),
                              ],
                            ),
                            NeoBrutalButton(
                              label: allApplied ? 'PAKET AKTİF' : 'PAKETİ UYGULA',
                              icon: allApplied ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                              backgroundColor: allApplied ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)) : AppColors.brutalYellow,
                              textColor: allApplied ? Colors.grey : Colors.black,
                              fontSize: 11,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              onPressed: allApplied ? null : () => _applyPresetBuild(preset),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ] else ...[
              // Standard Options List
              ...visibleOptions.map((opt) {
                final isApplied = _selectedCar!.appliedDetailingOptionIds.contains(opt.id);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(14),
                    backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                    borderColor: isApplied ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
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
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Icon(opt.icon, color: Colors.black, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  opt.title,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isApplied)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: NeoBrutalBadge(
                                      text: 'UYGULANDI',
                                      backgroundColor: AppColors.brutalGreen,
                                      textColor: Colors.black,
                                      fontSize: 9.5,
                                    ),
                                  ),
                                NeoBrutalBadge(
                                  text: '+%${((opt.valueMultiplier - 1.0) * 100).toStringAsFixed(0)} Değer',
                                  backgroundColor: AppColors.brutalYellow,
                                  textColor: Colors.black,
                                  fontSize: 9.5,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          opt.description,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 8),

                        // Performance Gain Badges
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (opt.hpGain > 0)
                              NeoBrutalBadge(
                                text: '+${opt.hpGain} HP',
                                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                textColor: AppColors.brutalGreen,
                                fontSize: 9.5,
                              ),
                            if (opt.nmGain > 0)
                              NeoBrutalBadge(
                                text: '+${opt.nmGain} Nm',
                                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                textColor: AppColors.brutalOrange,
                                fontSize: 9.5,
                              ),
                            if (opt.accelDelta != 0.0)
                              NeoBrutalBadge(
                                text: '${opt.accelDelta}s 0-100',
                                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                textColor: const Color(0xFF06B6D4),
                                fontSize: 9.5,
                              ),
                            if (opt.soundDbGain > 0)
                              NeoBrutalBadge(
                                text: '+${opt.soundDbGain} dB',
                                backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                textColor: const Color(0xFFA855F7),
                                fontSize: 9.5,
                              ),
                            if (!opt.isLegalWithoutProject)
                              const NeoBrutalBadge(
                                icon: Icons.warning_amber_rounded,
                                text: 'Ruhsat Onayı Gerekir',
                                backgroundColor: AppColors.errorRed,
                                textColor: Colors.white,
                                fontSize: 9.5,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isApplied ? 'TAMAMLANDI' : CurrencyFormatter.formatShort(opt.cost),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isApplied ? const Color(0xFF64748B) : AppColors.brutalOrange,
                              ),
                            ),
                            NeoBrutalButton(
                              label: isApplied ? 'UYGULANDI' : 'UYGULA',
                              icon: isApplied ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                              backgroundColor: isApplied ? (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)) : opt.color,
                              textColor: isApplied ? (isDark ? Colors.white54 : Colors.black54) : Colors.black,
                              fontSize: 11.5,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              onPressed: isApplied ? null : () => _applyTuningOption(opt),
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
        ],
      ),
    );
  }

  static Widget _buildMetricTile(String title, String val, String sub, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              val,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              sub,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
