import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../domain/usecases/consignment_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class ConsignmentScreen extends ConsumerWidget {
  const ConsignmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/consignment-market')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'KONSİNYE & EMANET ARAÇLAR'),
        body: const NeoBrutalLockedFeatureView(
          route: '/consignment-market',
          featureTitle: 'KONSİNYE PAZARI',
          icon: Icons.handshake_rounded,
        ),
      );
    }

    if (game.reputationScore < 40) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'KONSİNYE & EMANET ARAÇLAR'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: NeoBrutalCard(
              padding: const EdgeInsets.all(24),
              backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
              borderColor: AppColors.brutalOrange,
              borderRadius: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.brutalOrange.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.brutalOrange, width: 2),
                    ),
                    child: const Icon(Icons.handshake_rounded, size: 42, color: AppColors.brutalOrange),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'KONSİNYE PAZARI KİLİTLİ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Araç sahiplerinin arabalarını size güvenip emanet bırakması için minimum 40 Esnaf İtibarı gereklidir.\n\nŞu anki İtibarınız: ${game.reputationScore} / 40',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  NeoBrutalButton(
                    label: 'PAZARA GİT & İTİBAR KAZAN',
                    icon: Icons.storefront_rounded,
                    backgroundColor: AppColors.brutalYellow,
                    textColor: Colors.black,
                    fontSize: 11.5,
                    onPressed: () => context.push('/marketplace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final activeConsignmentCars = game.ownedCars.where((c) => c.isConsignment).toList();
    final availableOffers = game.consignmentOffers;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'KONSİNYE & EMANET ARAÇLAR',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Explanatory Banner with Branch Tier & Parking Fee Highlights
          NeoBrutalCard(
            padding: const EdgeInsets.all(14),
            backgroundColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0FDF4),
            borderColor: AppColors.brutalGreen,
            borderRadius: 14,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.brutalGreen,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                          width: 2.0,
                        ),
                      ),
                      child: const Icon(Icons.handshake_rounded, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SIFIR SERMAYE İLE ÇİFTE KAZANÇ',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Müşteriler araçlarını galerinize emanet bıraksın. Sıfır sermaye ile hem satış komisyonu hem de günlük sergileme ücreti kazanın!',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF11131C) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.storefront_rounded, size: 16, color: AppColors.brutalYellow),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          game.currentBranchName,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brutalGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.brutalGreen, width: 1),
                        ),
                        child: Text(
                          '+₺${(game.currentBranchTier == 1 ? 300 : (game.currentBranchTier == 2 ? 600 : (game.currentBranchTier == 3 ? 1200 : (game.currentBranchTier == 4 ? 2500 : (game.currentBranchTier == 5 ? 5000 : (game.currentBranchTier == 6 ? 10000 : (game.currentBranchTier == 7 ? 22000 : 45000))))))) }/gün otopark',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.brutalGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Active in-showroom consignment vehicles
          if (activeConsignmentCars.isNotEmpty) ...[
            Text(
              'VİTRİNDEKİ EMANET ARAÇLARINIZ • ${activeConsignmentCars.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 10),
            ...activeConsignmentCars.map((car) => _buildActiveConsignmentCard(context, ref, car, isDark)),
            const SizedBox(height: 14),
          ],

          // 3. New incoming consignment offers
          Text(
            'YENİ KONSİNYE TALEPLERİ • ${availableOffers.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 10),

          if (availableOffers.isEmpty)
            const NeoBrutalEmptyState(
              icon: Icons.directions_car_filled_outlined,
              title: 'BEKLEYEN EMANET YOK',
              description: 'Şu an emanet bırakılmak istenen araç bulunmuyor. Yeni güne geçildiğinde yeni teklifler gelecektir.',
            )
          else
            ...availableOffers.map((car) => _buildOfferCard(context, ref, car, isDark)),
        ],
      ),
    );
  }

  Widget _buildActiveConsignmentCard(BuildContext context, WidgetRef ref, CarModel car, bool isDark) {
    final commission = car.estimatedRealValue * car.consignmentCommissionRate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(12),
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        borderColor: AppColors.brutalGreen,
        borderRadius: 12,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.brutalGreen,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.car_rental_rounded, size: 20, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.modelName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Sahibi: ${(car.consignmentOwnerName?.isNotEmpty ?? false) ? car.consignmentOwnerName! : "Müşteri"} • Kalan: ${car.consignmentDaysRemaining} Gün',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'KAZANÇ',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  '+${CurrencyFormatter.format(commission)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.brutalGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, WidgetRef ref, CarModel car, bool isDark) {
    final game = ref.watch(gameProvider);
    final hasGarageSpace = game.ownedCars.length < game.maxGarageSlots;
    final commissionPercent = (car.consignmentCommissionRate * 100).round();
    final estimatedCommission = car.estimatedRealValue * car.consignmentCommissionRate;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF161922) : Colors.white,
        borderColor: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car.modelName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Araç Sahibi: ${(car.consignmentOwnerName?.isNotEmpty ?? false) ? car.consignmentOwnerName! : "Esnaf Müşterisi"} • ${car.modelYear} Model • ${car.expertise.mileage} km',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                NeoBrutalBadge(
                  text: '%$commissionPercent KOMİSYON',
                  backgroundColor: AppColors.brutalYellow,
                  textColor: Colors.black,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Financial comparison box
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1117) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? const Color(0xFF262C3D) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'ÖDENECEK SERMAYE',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '₺0 • Ücretsiz',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 28, color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
                  Column(
                    children: [
                      const Text(
                        'TAHMİNİ KOMİSYON',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${CurrencyFormatter.format(estimatedCommission)}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brutalYellow),
                      ),
                    ],
                  ),
                  Container(width: 1, height: 28, color: isDark ? const Color(0xFF333B4F) : const Color(0xFFCBD5E1)),
                  Column(
                    children: [
                      const Text(
                        'GÜNLÜK SERGİLEME',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+₺${ConsignmentEngine.calculateDailyParkingFee(game.currentBranchTier).round()}/gün',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action row
            Row(
              children: [
                Text(
                  'Süre: ${car.consignmentDaysRemaining} Gün',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondaryLight,
                  ),
                ),
                const Spacer(),
                NeoBrutalButton(
                  label: hasGarageSpace ? 'EMANET AL' : 'GARAJ DOLU',
                  backgroundColor: hasGarageSpace ? AppColors.brutalGreen : const Color(0xFF64748B),
                  textColor: Colors.black,
                  onPressed: hasGarageSpace
                      ? () {
                          final success = ref.read(gameProvider.notifier).acceptConsignmentOffer(car);
                          if (success) {
                            NotificationService.showSuccess(
                              context,
                              '${car.modelName} emanet olarak vitrine eklendi!',
                            );
                          }
                        }
                      : () {
                          NotificationService.showWarning(context, 'Garajınızda boş yer yok!');
                        },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
