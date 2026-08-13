import 'package:galeriden/core/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/customer_review_model.dart';
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
                                      Text(CurrencyFormatter.format(car.estimatedRealValue), style: AppTypography.labelSmall(p.isDark)),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('İlan Satış Fiyatı', style: AppTypography.labelSmall(p.isDark)),
                                      Text(CurrencyFormatter.format(car.listingPrice), style: AppTypography.moneyMedium(p.isDark).copyWith(color: p.primaryColor)),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: p.surfaceColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: p.surfaceBorderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('İlan Beyanı:', style: AppTypography.labelSmall(p.isDark)),
                                    Text(
                                      car.declarationType == ListingDeclarationType.honest
                                          ? 'Dürüst İlan'
                                          : (car.declarationType == ListingDeclarationType.flawlessClaim
                                              ? 'Hatasız Boyasız Hilesi'
                                              : 'Sayaç Düşürme Hilesi'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: car.declarationType == ListingDeclarationType.honest
                                            ? p.secondaryColor
                                            : (car.declarationType == ListingDeclarationType.flawlessClaim ? Colors.orange : Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                                      label: const Text('Fiyat & İlanı Düzenle'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: p.textPrimaryColor,
                                        side: BorderSide(color: p.surfaceBorderColor),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => _showListingEditSheet(context, ref, car),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: VectorIconWidget(type: 'flash', color: Colors.black, size: 16),
                                      label: const Text('İlanı Öne Çıkar (₺2.500)'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: p.warningColor,
                                        foregroundColor: Colors.black,
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () {
                                        final success = ref.read(gameProvider.notifier).boostListingDoping(car.id);
                                        if (success) {
                                          NotificationService.showSuccess(context, '${car.brand} ${car.modelName} için ₺2.500 Doping Uygulandı!');
                                        } else {
                                          NotificationService.showError(context, 'Doping için bakiyeniz yetersiz (₺2.500 gereklidir).');
                                        }
                                      },
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
                                            // Auto-generate customer review
                                            final isHonest = car.declarationType == ListingDeclarationType.honest;
                                            final review = CustomerReviewModel(
                                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                                              reviewerName: offer.buyerName,
                                              carTitle: '${car.brand} ${car.modelName}',
                                              rating: isHonest ? (4.0 + (offer.offeredAmount >= car.listingPrice ? 1.0 : 0.0)) : 1.0,
                                              comment: isHonest
                                                  ? 'Harika dürüst bir galerici! Araç tam ekspertizdeki gibi çıktı, çok memnunum.'
                                                  : 'Göz göre göre gizli kusurlu araç sattılar! Kesinlikle tavsiye etmiyorum.',
                                              createdAt: DateTime.now(),
                                            );
                                            ref.read(gameProvider.notifier).addCustomerReview(review);

                                            NotificationService.showSuccess(context, '${CurrencyFormatter.format(offer.offeredAmount)} tutarında araç satışı yapıldı! Müşteri değerlendirmesi eklendi.');
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
                        NotificationService.showSuccess(context, outcome.responseMessage);
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

  void _showListingEditSheet(BuildContext context, WidgetRef ref, CarModel car) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;

    double selectedPrice = car.listingPrice;
    ListingDeclarationType selectedDeclaration = car.declarationType;

    final double minPrice = (car.currentPurchasePrice * 0.8).clamp(10000.0, car.estimatedRealValue);
    final double maxPrice = (car.estimatedRealValue * 1.6).roundToDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.backgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('İLAN AYARLARI', style: AppTypography.titleLarge(p.isDark)),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text('${car.brand} ${car.modelName} (${car.modelYear})', style: AppTypography.labelSmall(p.isDark)),
                    const SizedBox(height: 16),

                    // Price Setting Section
                    Text('BELİRLENEN İLAN FİYATI', style: AppTypography.labelSmall(p.isDark).copyWith(color: p.primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Müşterilerin vereceği tüm teklifler belirlediğiniz bu ilan fiyatının altında kalacaktır.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: p.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: p.surfaceBorderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('İlan Satış Fiyatı:', style: AppTypography.labelSmall(p.isDark)),
                              Text(CurrencyFormatter.format(selectedPrice), style: AppTypography.moneyMedium(p.isDark).copyWith(color: p.primaryColor)),
                            ],
                          ),
                          Slider(
                            value: selectedPrice.clamp(minPrice, maxPrice),
                            min: minPrice,
                            max: maxPrice,
                            divisions: 100,
                            activeColor: p.primaryColor,
                            onChanged: (val) {
                              setState(() {
                                selectedPrice = (val / 1000).round() * 1000.0;
                              });
                            },
                          ),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Piyasa Değeri', style: TextStyle(fontSize: 11)),
                                backgroundColor: p.backgroundColor,
                                onPressed: () {
                                  setState(() => selectedPrice = car.estimatedRealValue.roundToDouble());
                                },
                              ),
                              ActionChip(
                                label: const Text('+%10 Kâr', style: TextStyle(fontSize: 11)),
                                backgroundColor: p.backgroundColor,
                                onPressed: () {
                                  setState(() => selectedPrice = (car.estimatedRealValue * 1.10).roundToDouble());
                                },
                              ),
                              ActionChip(
                                label: const Text('+%20 Tok Satıcı', style: TextStyle(fontSize: 11)),
                                backgroundColor: p.backgroundColor,
                                onPressed: () {
                                  setState(() => selectedPrice = (car.estimatedRealValue * 1.20).roundToDouble());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Declaration Selector Section
                    Text('İLAN BEYANI (SÜRTÜNMESİZ SEÇİM)', style: AppTypography.labelSmall(p.isDark).copyWith(color: p.secondaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    _buildDeclarationCard(
                      title: 'Dürüst İlan',
                      subtitle: 'Araç durumu olduğu gibi beyan edilir. Risk yok.',
                      color: p.secondaryColor,
                      isSelected: selectedDeclaration == ListingDeclarationType.honest,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.honest),
                      p: p,
                    ),
                    const SizedBox(height: 8),
                    _buildDeclarationCard(
                      title: 'Hatasız Boyasız Hilesi',
                      subtitle: 'Hasarlar gizlenir. Müşteri ekspertiz yaptırırsa ₺10k ceza kesilir.',
                      color: Colors.orange,
                      isSelected: selectedDeclaration == ListingDeclarationType.flawlessClaim,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.flawlessClaim),
                      p: p,
                    ),
                    const SizedBox(height: 8),
                    _buildDeclarationCard(
                      title: 'Sayaç Düşürme Hilesi',
                      subtitle: 'KM düşürülmüş gösterilir. Beyin taramasında yakalanırsa ₺10k ceza kesilir.',
                      color: Colors.red,
                      isSelected: selectedDeclaration == ListingDeclarationType.tamperedMileageClaim,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.tamperedMileageClaim),
                      p: p,
                    ),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p.primaryColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          ref.read(gameProvider.notifier).updateCarListingDetails(
                                car.id,
                                customPrice: selectedPrice,
                                declaration: selectedDeclaration,
                              );
                          Navigator.pop(context);
                          NotificationService.showSuccess(context, '${car.brand} ${car.modelName} ilanı güncellendi!');
                        },
                        child: const Text('İlanı Güncelle & Kaydet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
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

  Widget _buildDeclarationCard({
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required dynamic p,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : p.surfaceColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : p.surfaceBorderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? color : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? color : p.textPrimaryColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.labelSmall(p.isDark).copyWith(fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
