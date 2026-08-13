import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/notification_service.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_glass_container.dart';

class RentACarScreen extends ConsumerWidget {
  const RentACarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RENT A CAR MÜDÜRLÜĞÜ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(p, game),
            const SizedBox(height: 24),
            Text('KİRADAKİ ARAÇLAR', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),
            if (game.activeRentals.isEmpty)
              Text('Şu an kirada olan aracınız bulunmuyor.', style: AppTypography.bodyMedium(p.isDark).copyWith(color: p.textSecondaryColor)),
            ...game.activeRentals.map((rental) => _buildRentalCard(context, ref, p, rental)),
            const SizedBox(height: 24),
            Text('KİRAYA VERİLEBİLECEK ARAÇLAR (GARAJ)', style: AppTypography.labelSmall(p.isDark)),
            const SizedBox(height: 12),
            ..._buildAvailableCarsList(context, ref, p, game),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(dynamic p, dynamic game) {
    double dailyRentalIncome = game.activeRentals.fold(0.0, (sum, r) => sum + r.dailyRate);

    return AppGlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.car_rental_rounded, color: Colors.blueAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Günlük Kira Geliri', style: AppTypography.labelSmall(p.isDark)),
                const SizedBox(height: 4),
                Text('₺${CurrencyFormatter.formatShort(dailyRentalIncome)} / Gün', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18, color: p.successColor)),
                const SizedBox(height: 2),
                Text('${game.activeRentals.length} Araç Kirada', style: AppTypography.bodyMedium(p.isDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalCard(BuildContext context, WidgetRef ref, dynamic p, dynamic rental) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.primaryColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rental.carModelName, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 15)),
                const SizedBox(height: 4),
                Text('Günlük Getiri: ₺${CurrencyFormatter.formatShort(rental.dailyRate)}', style: AppTypography.bodyMedium(p.isDark).copyWith(color: p.successColor)),
                const SizedBox(height: 4),
                Text('Toplam Getiri: ₺${CurrencyFormatter.formatShort(rental.totalEarned)}', style: AppTypography.bodyMedium(p.isDark)),
                Text('${rental.rentedDays} Gündür Kirada', style: AppTypography.labelSmall(p.isDark)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: p.errorColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final success = ref.read(gameProvider.notifier).returnRentedCar(rental.id);
              if (success) {
                NotificationService.showSuccess(context, 'Araç kiralama iptal edildi ve galeriye geri döndü.');
              }
            },
            child: const Text('Geri Çağır'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAvailableCarsList(BuildContext context, WidgetRef ref, dynamic p, dynamic game) {
    // Determine which cars are in the garage but not rented out
    final rentedCarIds = game.activeRentals.map((r) => r.carId).toSet();
    final availableCars = game.ownedCars.where((c) => !rentedCarIds.contains(c.id)).toList();

    if (availableCars.isEmpty) {
      return [
        Text('Garajınızda kiraya verilebilecek araç bulunmuyor.', style: AppTypography.bodyMedium(p.isDark).copyWith(color: p.textSecondaryColor))
      ];
    }

    return availableCars.map((car) {
      double suggestedDailyRate = (car.purchasePrice ?? car.basePrice) * 0.005; // 0.5% of value daily
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: p.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: p.surfaceBorderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: p.backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.directions_car_rounded, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${car.brand} ${car.model}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 14)),
                  Text('Değer: ₺${CurrencyFormatter.formatShort(car.purchasePrice ?? car.basePrice)}', style: AppTypography.labelSmall(p.isDark)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showRentDialog(context, ref, p, car, suggestedDailyRate);
              },
              child: const Text('Kiraya Ver'),
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showRentDialog(BuildContext context, WidgetRef ref, dynamic p, dynamic car, double suggestedRate) {
    double currentRate = suggestedRate;
    showModalBottomSheet(
      context: context,
      backgroundColor: p.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aracı Kiraya Ver', style: AppTypography.titleLarge(p.isDark)),
                  const SizedBox(height: 12),
                  Text('${car.brand} ${car.model}', style: AppTypography.bodyMedium(p.isDark)),
                  const SizedBox(height: 20),
                  Text('Günlük Kira Bedeli', style: AppTypography.labelSmall(p.isDark)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            if (currentRate > 100) currentRate -= 100;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          '₺${CurrencyFormatter.formatShort(currentRate)}',
                          textAlign: TextAlign.center,
                          style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 18),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () {
                          setState(() {
                            currentRate += 100;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        final success = ref.read(gameProvider.notifier).rentCar(car.id, currentRate);
                        Navigator.pop(ctx);
                        if (success) {
                          NotificationService.showSuccess(context, '${car.brand} aracı günlük ₺${CurrencyFormatter.formatShort(currentRate)} bedelle kiraya verildi.');
                        } else {
                          NotificationService.showError(context, 'Kiralama başarısız! Araç uygun değil.');
                        }
                      },
                      child: const Text('Sözleşmeyi Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
