import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/offer_model.dart';
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
                              Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: p.surfaceColor,
                                   borderRadius: BorderRadius.circular(10),
                                   border: Border.all(color: p.surfaceBorderColor),
                                 ),
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                   children: [
                                     Text('İlan Beyanı:', style: AppTypography.labelSmall(p.isDark)),
                                     DropdownButton<ListingDeclarationType>(
                                       value: car.declarationType,
                                       underline: const SizedBox(),
                                       dropdownColor: p.surfaceColor,
                                       items: const [
                                         DropdownMenuItem(
                                           value: ListingDeclarationType.honest,
                                           child: Text('Dürüst İlan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                         ),
                                         DropdownMenuItem(
                                           value: ListingDeclarationType.flawlessClaim,
                                           child: Text('Hatasız Boyasız Hilesi', style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                                         ),
                                         DropdownMenuItem(
                                           value: ListingDeclarationType.tamperedMileageClaim,
                                           child: Text('Sayaç Düşürme Hilesi', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                                         ),
                                       ],
                                       onChanged: (val) {
                                         if (val != null) {
                                           ref.read(gameProvider.notifier).updateCarListingDeclaration(car.id, val);
                                         }
                                       },
                                     ),
                                   ],
                                 ),
                               ),
                               const SizedBox(height: 8),
                               SizedBox(
                                 width: double.infinity,
                                 child: ElevatedButton.icon(
                                   icon: VectorIconWidget(type: 'flash', color: Colors.black, size: 16),
                                   label: const Text('İlanı Öne Çıkar / Doping (₺2.500)'),
                                   style: ElevatedButton.styleFrom(
                                     backgroundColor: p.warningColor,
                                     foregroundColor: Colors.black,
                                     padding: const EdgeInsets.symmetric(vertical: 10),
                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                   ),
                                   onPressed: () {
                                     final success = ref.read(gameProvider.notifier).boostListingDoping(car.id);
                                     if (success) {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         SnackBar(content: Text('${car.brand} ${car.modelName} için ₺2.500 Doping Uygulandı!')),
                                       );
                                     } else {
                                       ScaffoldMessenger.of(context).showSnackBar(
                                         const SnackBar(content: Text('Doping için bakiyeniz yetersiz (₺2.500 gereklidir).')),
                                       );
                                     }
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
                                  Text('${car.brand} ${car.modelName}', style: AppTypography.titleLarge(p.isDark).copyWith(fontSize: 16)),
                                  Text(CurrencyFormatter.format(offer.offeredAmount), style: AppTypography.moneyMedium(p.isDark)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Teklif Veren: ${offer.buyerName}', style: AppTypography.labelSmall(p.isDark)),
                              if (offer.buyerMessage.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('"${offer.buyerMessage}"', style: TextStyle(fontStyle: FontStyle.italic, color: p.secondaryColor, fontSize: 12)),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
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
                                          final customer = CustomerModel.generateRandomCustomer();
                                          final fraudResult = ref.read(gameProvider.notifier).acceptOfferWithFraudCheck(offer, customer);

                                          if (fraudResult != null && fraudResult.caughtFraud) {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                backgroundColor: p.surfaceColor,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: Row(
                                                  children: [
                                                    VectorIconWidget(type: 'error', color: p.errorColor, size: 24),
                                                    const SizedBox(width: 8),
                                                    Text(fraudResult.title, style: TextStyle(color: p.errorColor, fontWeight: FontWeight.bold, fontSize: 16)),
                                                  ],
                                                ),
                                                content: Text(
                                                  '${fraudResult.description}\n\n'
                                                  'Tazminat Cezası: ₺${CurrencyFormatter.formatShort(fraudResult.fineAmount)}\n'
                                                  'İtibar Kaybı: -${fraudResult.reputationPenalty} Puan',
                                                  style: AppTypography.bodyMedium(p.isDark),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(backgroundColor: p.errorColor, foregroundColor: Colors.white),
                                                    onPressed: () => Navigator.pop(ctx),
                                                    child: const Text('Tamam'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('${CurrencyFormatter.format(offer.offeredAmount)} tutarında araç satışı yapıldı!')),
                                            );
                                          }
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
