import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_badge.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';

class RestorationStageInfo {
  final int stage;
  final String title;
  final String description;
  final double cost;
  final String icon;

  const RestorationStageInfo({
    required this.stage,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
  });
}

const List<RestorationStageInfo> kRestorationStages = [
  RestorationStageInfo(
    stage: 1,
    title: '1. Şasi & Pas Temizliği',
    description: 'Aracın tabanındaki çürükler kesilir, kumlama yapılır ve şasi güçlendirilir.',
    cost: 4500,
    icon: '🪨',
  ),
  RestorationStageInfo(
    stage: 2,
    title: '2. Motor & Mekanik Revizyon',
    description: 'Pistonlar, segmanlar ve silindir kapağı sıfırlanır, motor ilk günkü gibi çalıştırılır.',
    cost: 9500,
    icon: '⚙️',
  ),
  RestorationStageInfo(
    stage: 3,
    title: '3. Elektrik & Tesisat Yenileme',
    description: 'Eski kablo demetleri sökülür, modern ve güvenli sigorta tesisatı çekilir.',
    cost: 6000,
    icon: '⚡',
  ),
  RestorationStageInfo(
    stage: 4,
    title: '4. Kaporta Düzeltme & Astar',
    description: 'Eksik veya ezik saç paneller çekiçlenir, epoksi astar atılarak fırına hazırlanır.',
    cost: 8000,
    icon: '🔨',
  ),
  RestorationStageInfo(
    stage: 5,
    title: '5. Fabrika Orijinal Boya & Detay',
    description: 'Katalog rengiyle mikron boya atılır, nikelajlar ve iç döşeme sıfırlanır.',
    cost: 12000,
    icon: '✨',
  ),
];

class BarnFindRestorationSheet extends ConsumerStatefulWidget {
  final CarModel car;

  const BarnFindRestorationSheet({
    super.key,
    required this.car,
  });

  static Future<void> show(BuildContext context, CarModel car) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BarnFindRestorationSheet(car: car),
    );
  }

  @override
  ConsumerState<BarnFindRestorationSheet> createState() => _BarnFindRestorationSheetState();
}

class _BarnFindRestorationSheetState extends ConsumerState<BarnFindRestorationSheet> {
  bool _useOriginalParts = true;

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    final currentCar = game.ownedCars.firstWhere(
      (c) => c.id == widget.car.id,
      orElse: () => widget.car,
    );

    final currentStage = currentCar.barnFindStage;
    final isCompleted = currentStage >= 5;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141721) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
          width: 2.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header (§1.3 / Q6)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🛖', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5-AŞAMALI GARAJ RESTORASYONU',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        '${currentCar.brand} ${currentCar.modelName} (${currentCar.modelYear})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Overview Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2330) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF3B82F6), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İlerleme Durumu: Aşama $currentStage / 5',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF93C5FD) : const Color(0xFF1E3A8A),
                  ),
                ),
                NeoBrutalBadge(
                  text: isCompleted ? 'BAŞYAPIT TAMAMLANDI' : 'RESTORASYON SÜRÜYOR',
                  backgroundColor: isCompleted ? const Color(0xFF00E575) : const Color(0xFFFFDE59),
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Original vs Aftermarket Selector (§1.3 / Q6)
          if (!isCompleted) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1F2C) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _useOriginalParts ? const Color(0xFFFFD700) : const Color(0xFF64748B),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _useOriginalParts,
                    activeColor: const Color(0xFFFFD700),
                    checkColor: Colors.black,
                    onChanged: (val) {
                      setState(() => _useOriginalParts = val ?? true);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Orijinal Çıkma & Sıfır Parça Kullan (+%65 Koleksiyonluk Değer)',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          _useOriginalParts
                            ? 'Maliyet +%25 artar fakat araç tamamlandığında 1.65x efsanevi koleksiyon çarpanı kazanır.'
                            : 'Yan sanayi parçalarla maliyet düşük tutulur (1.25x standart çarpan).',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark ? Colors.white60 : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Stages List
          Expanded(
            child: ListView.builder(
              itemCount: kRestorationStages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (ctx, idx) {
                final stageInfo = kRestorationStages[idx];
                final isDone = currentStage >= stageInfo.stage;
                final isCurrent = currentStage + 1 == stageInfo.stage;
                final effectiveCost = _useOriginalParts ? (stageInfo.cost * 1.25) : stageInfo.cost;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NeoBrutalCard(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: isDone
                        ? (isDark ? const Color(0xFF10281E) : const Color(0xFFECFDF5))
                        : (isCurrent
                            ? (isDark ? const Color(0xFF261D12) : const Color(0xFFFFFBEB))
                            : (isDark ? const Color(0xFF181C26) : const Color(0xFFF1F5F9))),
                    borderColor: isDone
                        ? const Color(0xFF00E575)
                        : (isCurrent ? const Color(0xFFFF7A00) : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1))),
                    borderWidth: (isDone || isCurrent) ? 1.8 : 1.0,
                    borderRadius: 10,
                    child: Row(
                      children: [
                        Text(stageInfo.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    stageInfo.title,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: isDone || isCurrent
                                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                          : (isDark ? Colors.white38 : Colors.black38),
                                    ),
                                  ),
                                  if (isDone)
                                    const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF00E575))
                                  else
                                    Text(
                                      CurrencyFormatter.formatShort(effectiveCost),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isCurrent ? const Color(0xFFFF7A00) : (isDark ? Colors.white38 : Colors.black38),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                stageInfo.description,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Action Button
          if (!isCompleted) ...[
            Builder(
              builder: (context) {
                final nextStage = currentStage + 1;
                final nextStageInfo = kRestorationStages.firstWhere((s) => s.stage == nextStage);
                final cost = _useOriginalParts ? (nextStageInfo.cost * 1.25) : nextStageInfo.cost;

                return NeoBrutalButton(
                  label: '${nextStageInfo.title} Tamamla (${CurrencyFormatter.formatShort(cost)})',
                  icon: Icons.handyman_rounded,
                  backgroundColor: const Color(0xFFFFDE59),
                  textColor: Colors.black,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  onPressed: () {
                    if (game.balance < cost) {
                      NotificationService.showError(
                        context,
                        'Bu aşamayı tamamlamak için ${CurrencyFormatter.formatShort(cost)} bakiye gereklidir.',
                      );
                      return;
                    }

                    // Update car in inventory
                    final updatedCar = currentCar.copyWith(
                      barnFindStage: nextStage,
                      isBarnFindOriginalParts: _useOriginalParts,
                      isBarnFindRestored: nextStage >= 5,
                      expertise: currentCar.expertise.copyWith(
                        engineCondition: (currentCar.expertise.engineCondition + 15).clamp(0, 100),
                        transmissionCondition: (currentCar.expertise.transmissionCondition + 15).clamp(0, 100),
                      ),
                    );

                    ref.read(gameProvider.notifier).updateOwnedCar(updatedCar, cost);

                    NotificationService.showSuccess(
                      context,
                      '${nextStageInfo.title} başarıyla tamamlandı! Araç değeri katlandı.',
                    );
                  },
                );
              },
            ),
          ] else ...[
            NeoBrutalButton(
              label: 'HARİKA! BAŞYAPIT SHOWROOM\'A HAZIR',
              icon: Icons.auto_awesome_rounded,
              backgroundColor: const Color(0xFF00E575),
              textColor: Colors.black,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              padding: const EdgeInsets.symmetric(vertical: 12),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}
