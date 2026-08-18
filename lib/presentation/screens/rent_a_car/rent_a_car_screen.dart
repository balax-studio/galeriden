import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/iterable_extensions.dart';
import '../../../core/utils/notification_service.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/dealership_model.dart';
import '../../../data/models/rental_agreement_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/neo_brutal_app_bar.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';
import '../../widgets/neo_brutal_empty_state.dart';
import '../../widgets/neo_brutal_locked_feature_view.dart';

class RentACarScreen extends ConsumerWidget {
  const RentACarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    if (!game.isFeatureUnlocked('/rent-a-car')) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: const NeoBrutalAppBar(title: 'RENT A CAR MÜDÜRLÜĞÜ'),
        body: const NeoBrutalLockedFeatureView(
          route: '/rent-a-car',
          featureTitle: 'RENT A CAR KİRALAMA',
          icon: Icons.car_rental_rounded,
        ),
      );
    }

    final double dailyRentalIncome = game.activeRentals.fold(0.0, (sum, r) => sum + r.dailyRate);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
      appBar: const NeoBrutalAppBar(
        title: 'RENT A CAR MÜDÜRLÜĞÜ',
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. Income Summary Card
          NeoBrutalCard(
            padding: const EdgeInsets.all(16),
            backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
            borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brutalYellow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                      width: 2.0,
                    ),
                  ),
                  child: const Icon(Icons.car_rental_rounded, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GÜNLÜK KİRA GELİRİ',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${CurrencyFormatter.formatShort(dailyRentalIncome)} / Gün',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${game.activeRentals.length} Araç Kirada Çalışıyor',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Active Rentals Section
          Text(
            'KİRADAKİ AKTİF ARAÇLAR • ${game.activeRentals.length}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          if (game.activeRentals.isEmpty)
            const NeoBrutalEmptyState(
              icon: Icons.car_rental_rounded,
              accentColor: Color(0xFF3B82F6),
              badgeText: 'KİRADA ARAÇ YOK',
              title: 'Şu Anda Kirada Çalışan Aracın Yok',
              description: 'Galerindeki sağlam araçları kurumsal müşterilere kiralayarak düzenli günlük pasif nakit akışı oluşturabilirsin.',
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            )
          else
            ...game.activeRentals.map((rental) => _buildRentalCard(context, ref, rental, game, isDark)),

          const SizedBox(height: 20),

          // 3. Garage Available Cars to Rent
          Text(
            'KİRAYA VERİLEBİLECEK GARAJ ARAÇLARI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: isDark ? Colors.white70 : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),

          ..._buildAvailableCarsList(context, ref, game, isDark),
        ],
      ),
    );
  }

  Widget _buildRentalCard(
    BuildContext context,
    WidgetRef ref,
    RentalAgreement rental,
    DealershipModel game,
    bool isDark,
  ) {
    final car = findFirstWhere(game.ownedCars, (c) => c.id == rental.carId);
    final carTitle = car != null ? '${car.brand} ${car.modelName}' : 'Kiradaki Araç';

    final Color profileBadgeColor;
    final String profileLabel;
    final IconData profileIcon;

    if (rental.renterType == 'corporate') {
      profileBadgeColor = const Color(0xFF38BDF8);
      profileLabel = 'KURUMSAL';
      profileIcon = Icons.business_rounded;
    } else if (rental.renterType == 'young_driver') {
      profileBadgeColor = const Color(0xFFF97316);
      profileLabel = 'GENÇ & DÜĞÜN';
      profileIcon = Icons.speed_rounded;
    } else {
      profileBadgeColor = AppColors.brutalYellow;
      profileLabel = 'BİREYSEL';
      profileIcon = Icons.person_rounded;
    }

    final netDaily = rental.dailyRate - (rental.hasInsurance ? rental.insuranceDailyFee : 0.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeoBrutalCard(
        padding: const EdgeInsets.all(14),
        backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
        borderColor: AppColors.brutalGreen,
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    carTitle,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900),
                  ),
                ),
                NeoBrutalBadge(
                  icon: profileIcon,
                  text: profileLabel,
                  backgroundColor: profileBadgeColor,
                  textColor: Colors.black,
                  fontSize: 9.5,
                ),
                const SizedBox(width: 6),
                if (rental.hasInsurance)
                  const NeoBrutalBadge(
                    icon: Icons.shield_rounded,
                    text: 'KASKOLU',
                    backgroundColor: AppColors.brutalGreen,
                    textColor: Colors.black,
                    fontSize: 9.5,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(profileIcon, size: 13, color: const Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'Kiracı: ${rental.renterName}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Net Getiri: ${CurrencyFormatter.formatShort(netDaily)} / Gün',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Toplam: ${CurrencyFormatter.formatShort(rental.totalEarned)} • ${rental.rentedDays} Gün',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                NeoBrutalButton(
                  label: 'GERİ ÇAĞIR',
                  backgroundColor: AppColors.errorRed,
                  textColor: Colors.white,
                  fontSize: 10.5,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  onPressed: () {
                    final success = ref.read(gameProvider.notifier).returnRentedCar(rental.id);
                    if (success) {
                      NotificationService.showSuccess(context, 'Araç kiralama sonlandırıldı, galeriye döndü.');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildAvailableCarsList(
    BuildContext context,
    WidgetRef ref,
    DealershipModel game,
    bool isDark,
  ) {
    final rentedCarIds = game.activeRentals.map((r) => r.carId).toSet();
    final availableCars = game.ownedCars.where((c) => !c.isRented && !rentedCarIds.contains(c.id)).toList();

    if (availableCars.isEmpty) {
      return [
        NeoBrutalCard(
          padding: const EdgeInsets.all(20),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 14,
          child: const Center(
            child: Text(
              'Garajınızda kiraya verilebilecek boşta araç bulunmuyor.',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
          ),
        ),
      ];
    }

    return availableCars.map((car) {
      final double suggestedDailyRate = car.currentPurchasePrice * 0.005;

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: NeoBrutalCard(
          padding: const EdgeInsets.all(12),
          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
          borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
          borderRadius: 12,
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: const Icon(Icons.directions_car_rounded, color: AppColors.brutalYellow, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${car.brand} ${car.modelName}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Değer: ${CurrencyFormatter.formatShort(car.currentPurchasePrice)}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              NeoBrutalButton(
                label: 'KİRAYA VER',
                backgroundColor: AppColors.brutalGreen,
                textColor: Colors.black,
                fontSize: 11,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                onPressed: () => _showRentDialog(context, ref, car, suggestedDailyRate, isDark),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  void _showRentDialog(
    BuildContext context,
    WidgetRef ref,
    CarModel car,
    double suggestedRate,
    bool isDark,
  ) {
    double currentRate = suggestedRate.clamp(100.0, 50000.0);
    final double maxAllowedRate = (car.currentPurchasePrice * 0.016).clamp(100.0, 60000.0);
    String selectedRenterType = 'individual';
    bool hasInsurance = false;
    final insuranceDailyFee = (car.currentPurchasePrice * 0.001).clamp(150.0, 1500.0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            final double demandRatio = 1.0 - ((currentRate - suggestedRate) / (maxAllowedRate - suggestedRate + 0.1)).clamp(0.0, 0.85);
            final int demandPercent = (demandRatio * 100).round();
            final netRate = currentRate - (hasInsurance ? insuranceDailyFee : 0.0);

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141721) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  top: BorderSide(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 2.5),
                  left: BorderSide(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 2.5),
                  right: BorderSide(color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A), width: 2.5),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KİRAYA VER: ${car.brand} ${car.modelName}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),

                    // 1. Müşteri Profili Seçimi
                    const Text('MÜŞTERİ PROFİLİ SEÇİMİ', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildProfileChoice(
                            icon: Icons.business_rounded,
                            label: 'Kurumsal',
                            sub: '0 Kaza Riski',
                            isSelected: selectedRenterType == 'corporate',
                            color: const Color(0xFF38BDF8),
                            isDark: isDark,
                            onTap: () => setState(() => selectedRenterType = 'corporate'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildProfileChoice(
                            icon: Icons.person_rounded,
                            label: 'Bireysel',
                            sub: 'Dengeli',
                            isSelected: selectedRenterType == 'individual',
                            color: AppColors.brutalYellow,
                            isDark: isDark,
                            onTap: () => setState(() => selectedRenterType = 'individual'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _buildProfileChoice(
                            icon: Icons.speed_rounded,
                            label: 'Genç & Düğün',
                            sub: '+%35 Getiri',
                            isSelected: selectedRenterType == 'young_driver',
                            color: const Color(0xFFF97316),
                            isDark: isDark,
                            onTap: () => setState(() => selectedRenterType = 'young_driver'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 2. Kasko Poliçesi Toggle
                    NeoBrutalCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF8FAFC),
                      borderColor: hasInsurance ? AppColors.brutalGreen : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
                      borderRadius: 10,
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, color: AppColors.brutalGreen, size: 24),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Ticari Rent a Car Kaskosu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                                Text(
                                  'Günlük ${CurrencyFormatter.formatShort(insuranceDailyFee)} • Kaza & radar muafiyeti',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: hasInsurance,
                            activeTrackColor: AppColors.brutalGreen,
                            onChanged: (val) => setState(() => hasInsurance = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 3. Rayic & Demand Card
                    NeoBrutalCard(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                      borderColor: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                      borderRadius: 10,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tavsiye Edilen Rayiç:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Text(
                                '${CurrencyFormatter.formatShort(suggestedRate)} / Gün',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.brutalGreen),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Müşteri Talep Oranı:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              NeoBrutalBadge(
                                text: '%$demandPercent Talep',
                                backgroundColor: demandPercent > 60 ? AppColors.brutalGreen : AppColors.brutalYellow,
                                textColor: Colors.black,
                                fontSize: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. Rate Selector
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: AppColors.errorRed, size: 28),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (currentRate > 200) currentRate -= 100;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                '${CurrencyFormatter.formatShort(currentRate)} / Gün',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                              ),
                              if (hasInsurance)
                                Text(
                                  'Net Gelir: ${CurrencyFormatter.formatShort(netRate)}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.brutalGreen),
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.brutalGreen, size: 28),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              if (currentRate + 100 <= maxAllowedRate) currentRate += 100;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    NeoBrutalButton(
                      label: 'SÖZLEŞMEYİ İMZALA & KİRAYA VER',
                      icon: Icons.check_circle_rounded,
                      backgroundColor: AppColors.brutalGreen,
                      textColor: Colors.black,
                      fontSize: 12.5,
                      fullWidth: true,
                      onPressed: () {
                        final success = ref.read(gameProvider.notifier).rentCar(
                          car.id,
                          currentRate,
                          renterType: selectedRenterType,
                          hasInsurance: hasInsurance,
                        );
                        Navigator.pop(ctx);
                        if (success) {
                          NotificationService.showSuccess(
                            context,
                            '${car.brand} günlük ${CurrencyFormatter.formatShort(netRate)} net bedelle kiraya verildi.',
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildProfileChoice({
    required IconData icon,
    required String label,
    required String sub,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : (isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : (isDark ? const Color(0xFF2A3142) : const Color(0xFFCBD5E1)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 11,
                  color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                ),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.black87 : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
