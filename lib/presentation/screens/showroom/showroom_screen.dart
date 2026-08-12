import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../domain/usecases/negotiation_engine.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';

class ShowroomScreen extends ConsumerWidget {
  const ShowroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

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
                        style: AppTypography.bodyMedium(p.isDark),
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
                                  Row(
                                    children: [
                                      Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                                      if (car.isRare) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: p.secondaryColor,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              VectorIconWidget(type: 'rare', color: Colors.white, size: 10),
                                              const SizedBox(width: 4),
                                              const Text('NADİR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(car.bodyType, style: AppTypography.labelSmall(p.isDark)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Maliyet Fiyatı', style: AppTypography.labelSmall(p.isDark)),
                                      Text(CurrencyFormatter.format(car.currentPurchasePrice), style: AppTypography.monoSpec(p.isDark)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Piyasa Değeri', style: AppTypography.labelSmall(p.isDark)),
                                      Text(CurrencyFormatter.format(car.estimatedRealValue), style: AppTypography.moneyMedium(p.isDark)),
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
                                    backgroundColor: p.primaryColor,
                                    foregroundColor: Colors.black,
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
                        style: AppTypography.bodyMedium(p.isDark),
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

                      final isCountered = offer.status == OfferStatus.countered;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: isCountered ? p.secondaryColor : p.surfaceBorderColor, width: isCountered ? 2 : 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(offer.buyerName, style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                                      if (offer.counterCount > 0) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: p.secondaryColor.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text('Tur ${offer.counterCount}/${offer.maxCounters}', style: TextStyle(color: p.secondaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(CurrencyFormatter.format(offer.offeredAmount), style: AppTypography.moneyMedium(p.isDark).copyWith(fontSize: 18)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('İlgilendiği Araç: ${car.brand} ${car.modelName}', style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor)),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: p.backgroundColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text('"${offer.buyerMessage}"', style: AppTypography.bodyMedium(p.isDark).copyWith(fontStyle: FontStyle.italic)),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: p.errorColor,
                                      side: BorderSide(color: p.errorColor),
                                    ),
                                    onPressed: () {
                                      ref.read(gameProvider.notifier).rejectOffer(offer.id);
                                    },
                                    child: const Text('Reddet'),
                                  ),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: p.primaryColor,
                                          side: BorderSide(color: p.primaryColor),
                                        ),
                                        onPressed: () {
                                          _showCounterOfferSheet(context, ref, offer, car);
                                        },
                                        child: const Text('Karşı Teklif'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: p.successColor,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          ref.read(gameProvider.notifier).acceptOffer(offer);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('${CurrencyFormatter.format(offer.offeredAmount)} tutarında araç satışı yapıldı!')),
                                          );
                                        },
                                        child: const Text('Kabul Et & Sat'),
                                      ),
                                    ],
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

  void _showCounterOfferSheet(BuildContext context, WidgetRef ref, OfferModel offer, CarModel car) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    double targetPrice = (offer.offeredAmount * 1.08).roundToDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: p.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('KARŞI TEKLİF SUN', style: AppTypography.titleLarge(p.isDark)),
                  const SizedBox(height: 4),
                  Text('${offer.buyerName} kişisine karşı fiyat öner:', style: AppTypography.labelSmall(p.isDark)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Alıcının Teklifi: ${CurrencyFormatter.formatShort(offer.offeredAmount)}', style: AppTypography.labelSmall(p.isDark)),
                      Text('Önerin: ${CurrencyFormatter.format(targetPrice)}', style: AppTypography.moneyMedium(p.isDark).copyWith(color: p.primaryColor)),
                    ],
                  ),
                  Slider(
                    value: targetPrice,
                    min: offer.offeredAmount,
                    max: (car.estimatedRealValue * 1.25).roundToDouble(),
                    divisions: 40,
                    activeColor: p.primaryColor,
                    onChanged: (val) {
                      setState(() {
                        targetPrice = val.roundToDouble();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: p.primaryColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        final outcome = ref.read(gameProvider.notifier).counterOffer(offer.id, targetPrice);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(outcome.responseMessage)),
                        );
                      },
                      child: const Text('Karşı Teklifi İlet', style: TextStyle(fontWeight: FontWeight.bold)),
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
