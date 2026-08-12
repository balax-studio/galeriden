import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../providers/game_provider.dart';

class ShowroomScreen extends ConsumerWidget {
  const ShowroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SHOWROOM VE İLANLARIM'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Galerideki Araçlar'),
              Tab(text: 'Gelen Teklifler'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Owned Cars & Publish Listing
            game.ownedCars.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Galerinizde şu an araç bulunmuyor. İkinci el pazarından araç alarak satışa çıkarabilirsiniz.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(isDark),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: game.ownedCars.length,
                    itemBuilder: (context, index) {
                      final car = game.ownedCars[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(isDark).copyWith(fontSize: 16)),
                                  Text(car.bodyType, style: AppTypography.labelSmall(isDark)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Maliyet Fiyatı', style: AppTypography.labelSmall(isDark)),
                                      Text(CurrencyFormatter.format(car.currentPurchasePrice), style: AppTypography.monoSpec(isDark)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Piyasa Değeri', style: AppTypography.labelSmall(isDark)),
                                      Text(CurrencyFormatter.format(car.estimatedRealValue), style: AppTypography.moneyMedium(isDark)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.campaign_rounded),
                                  label: const Text('Müşteri Çek / İlanı Öne Çıkar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAmber,
                                    foregroundColor: AppColors.backgroundDark,
                                  ),
                                  onPressed: () {
                                    final offer = NegotiationEngine.generateBuyerOffer(car, car.estimatedRealValue * 1.1);
                                    ref.read(gameProvider.notifier).addOffer(offer);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${car.brand} için yeni bir alıcı teklifi geldi!')),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // Tab 2: Incoming Negotiation Offers
            game.incomingOffers.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Henüz gelen pazarlık teklifi bulunmuyor.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium(isDark),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: game.incomingOffers.length,
                    itemBuilder: (context, index) {
                      final offer = game.incomingOffers[index];
                      final car = game.ownedCars.firstWhere(
                        (c) => c.id == offer.carId,
                        orElse: () => CarModel(
                          id: '',
                          brand: 'Bilinmeyen',
                          modelName: 'Araç',
                          modelYear: 2020,
                          bodyType: 'Sedan',
                          colorHex: '#000000',
                          baseMarketValue: 0,
                          currentPurchasePrice: 0,
                          expertise: ExpertiseReport(engineCondition: 100, transmissionCondition: 100, tramerAmount: 0, mileage: 0, isMileageTampered: false, bodyParts: {}),
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(offer.buyerName, style: AppTypography.titleLarge(isDark).copyWith(fontSize: 16)),
                                  Text(CurrencyFormatter.format(offer.offeredAmount), style: AppTypography.moneyMedium(isDark).copyWith(fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('İlgilendiği Araç: ${car.brand} ${car.modelName}', style: AppTypography.labelSmall(isDark).copyWith(color: AppColors.primaryAmber)),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('"${offer.buyerMessage}"', style: AppTypography.bodyMedium(isDark).copyWith(fontStyle: FontStyle.italic)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.errorRed,
                                      side: const BorderSide(color: AppColors.errorRed),
                                    ),
                                    onPressed: () {
                                      ref.read(gameProvider.notifier).rejectOffer(offer.id);
                                    },
                                    child: const Text('Reddet'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.successGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      ref.read(gameProvider.notifier).acceptOffer(offer);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${CurrencyFormatter.format(offer.offeredAmount)} tutarında araç satışı yapıldı!')),
                                      );
                                    },
                                    child: const Text('Teklifi Kabul Et & Sat'),
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
        ),
      ),
    );
  }
}
