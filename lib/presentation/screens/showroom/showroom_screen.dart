import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:galeriden/core/utils/notification_service.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/car_model.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/models/customer_review_model.dart';
import '../../../data/models/expertise_model.dart';
import '../../../data/models/offer_model.dart';
import '../../../data/models/theme_palette_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/app_vector_icons.dart';
import '../../widgets/neo_brutal_badge.dart';
import '../../widgets/neo_brutal_button.dart';
import '../../widgets/neo_brutal_card.dart';

class ShowroomScreen extends ConsumerWidget {
  const ShowroomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
        appBar: AppBar(
          title: const Text(
            'SHOWROOM VE İLANLARIM',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          bottom: TabBar(
            indicatorColor: p.primaryColor,
            indicatorWeight: 3.0,
            labelColor: isDark ? p.primaryColor : const Color(0xFF0F172A),
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            tabs: [
              Tab(text: 'Galerideki Araçlar (${game.ownedCars.length})'),
              Tab(text: 'Gelen Teklifler (${game.incomingOffers.length})'),
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
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    physics: const BouncingScrollPhysics(),
                    itemCount: game.ownedCars.length,
                    itemBuilder: (context, index) {
                      final car = game.ownedCars[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(14),
                          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                          borderColor: car.isDoped
                              ? const Color(0xFFFFDE59)
                              : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                          borderRadius: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            '${car.brand} ${car.modelName}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        NeoBrutalBadge(
                                          text: car.isListed ? 'İLANDA' : 'GARAJDA',
                                          backgroundColor: car.isListed
                                              ? const Color(0xFF00E575)
                                              : (isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0)),
                                          textColor: car.isListed ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                                          fontSize: 9.5,
                                        ),
                                        if (car.isDoped) ...[
                                          const SizedBox(width: 6),
                                          const NeoBrutalBadge(
                                            text: '⚡ DOPİNGLİ',
                                            backgroundColor: Color(0xFFFFDE59),
                                            textColor: Colors.black,
                                            fontSize: 9.5,
                                          ),
                                        ],
                                        if (car.isRare) ...[
                                          const SizedBox(width: 6),
                                          const NeoBrutalBadge(
                                            text: 'NADİR',
                                            backgroundColor: Color(0xFFA855F7),
                                            textColor: Colors.white,
                                            fontSize: 9.5,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  NeoBrutalBadge(
                                    text: car.bodyType,
                                    fontSize: 9.5,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Price Matrix Block
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Maliyet',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.formatShort(car.currentPurchasePrice),
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Piyasa Değeri',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.formatShort(car.estimatedRealValue),
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'İlan Satış Fiyatı',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                          ),
                                        ),
                                        Text(
                                          CurrencyFormatter.formatShort(car.listingPrice),
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Declaration Indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'İlan Beyanı:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  NeoBrutalBadge(
                                    text: car.declarationType == ListingDeclarationType.honest
                                        ? 'Dürüst İlan'
                                        : (car.declarationType == ListingDeclarationType.flawlessClaim
                                            ? 'Hatasız Boyasız Hilesi'
                                            : 'Sayaç Düşürme Hilesi'),
                                    backgroundColor: car.declarationType == ListingDeclarationType.honest
                                        ? const Color(0xFF00E575)
                                        : (car.declarationType == ListingDeclarationType.flawlessClaim
                                            ? const Color(0xFFFF7A00)
                                            : const Color(0xFFEF4444)),
                                    textColor: Colors.black,
                                    fontSize: 10,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Actions
                              Row(
                                children: [
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: 'Fiyat & İlanı Düzenle',
                                      icon: Icons.edit_note_rounded,
                                      backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                      textColor: isDark ? Colors.white : const Color(0xFF0F172A),
                                      fontSize: 11,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      onPressed: () => _showListingEditSheet(context, ref, car),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: NeoBrutalButton(
                                      label: car.isDoped ? 'Dopingli' : 'Öne Çıkar (₺2.5k)',
                                      icon: Icons.bolt_rounded,
                                      backgroundColor: car.isDoped
                                          ? (isDark ? Colors.white12 : Colors.black12)
                                          : const Color(0xFFFFDE59),
                                      textColor: Colors.black,
                                      fontSize: 11,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      onPressed: car.isDoped
                                          ? () => NotificationService.showError(
                                              context,
                                              'Bu araç için doping hakkı zaten kullanıldı!',
                                            )
                                          : () {
                                              if (!car.isListed) {
                                                NotificationService.showError(
                                                  context,
                                                  'Araç ilana konulmadan doping yapılamaz!',
                                                );
                                                return;
                                              }
                                              final activeOffersCount = game.incomingOffers
                                                  .where((o) => o.carId == car.id && !o.isExpired)
                                                  .length;
                                              if (activeOffersCount >= 3) {
                                                NotificationService.showError(
                                                  context,
                                                  'Aracın maksimum teklif sınırına (3/3) ulaşıldı!',
                                                );
                                                return;
                                              }
                                              final success = ref.read(gameProvider.notifier).boostListingDoping(car.id);
                                              if (success) {
                                                NotificationService.showSuccess(
                                                  context,
                                                  '${car.brand} ${car.modelName} için ₺2.500 Doping Uygulandı!',
                                                );
                                              } else {
                                                NotificationService.showError(
                                                  context,
                                                  'Doping için bakiyeniz yetersiz (₺2.500 gereklidir).',
                                                );
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
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    physics: const BouncingScrollPhysics(),
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
                          expertise: ExpertiseReport(
                            engineCondition: 100,
                            transmissionCondition: 100,
                            tramerAmount: 0,
                            mileage: 0,
                            isMileageTampered: false,
                            bodyParts: {},
                          ),
                        ),
                      );

                      final isCountered = offer.status == OfferStatus.countered;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: NeoBrutalCard(
                          padding: const EdgeInsets.all(14),
                          backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                          borderColor: isCountered
                              ? const Color(0xFFFFDE59)
                              : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
                          borderRadius: 12,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${car.brand} ${car.modelName}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.format(offer.offeredAmount),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Teklif Veren: ${offer.buyerName}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                              if (offer.buyerMessage.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E2330) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF333B4F) : const Color(0xFF0F172A),
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    '"${offer.buyerMessage}"',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? p.primaryColor : const Color(0xFF0F172A),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 12),

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  NeoBrutalButton(
                                    label: 'Reddet',
                                    backgroundColor: isDark ? const Color(0xFF1E2330) : const Color(0xFFE2E8F0),
                                    textColor: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
                                    fontSize: 11,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    onPressed: () {
                                      ref.read(gameProvider.notifier).rejectOffer(offer.id);
                                    },
                                  ),
                                  Row(
                                    children: [
                                      NeoBrutalButton(
                                        label: 'Karşı Teklif',
                                        backgroundColor: const Color(0xFFFFDE59),
                                        textColor: Colors.black,
                                        fontSize: 11,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        onPressed: () {
                                          _showCounterOfferSheet(context, ref, offer, car);
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      NeoBrutalButton(
                                        label: 'Kabul Et & Sat',
                                        backgroundColor: const Color(0xFF00E575),
                                        textColor: Colors.black,
                                        fontSize: 11,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        onPressed: () {
                                          final customer = CustomerModel.generateRandomCustomer();
                                          final fraudResult = ref.read(gameProvider.notifier).acceptOfferWithFraudCheck(offer, customer);

                                          if (fraudResult != null && fraudResult.caughtFraud) {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                backgroundColor: isDark ? const Color(0xFF141721) : Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                title: Row(
                                                  children: [
                                                    VectorIconWidget(type: 'error', color: p.errorColor, size: 24),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      fraudResult.title,
                                                      style: TextStyle(
                                                        color: p.errorColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                content: Text(
                                                  '${fraudResult.description}\n\n'
                                                  'Tazminat Cezası: ${CurrencyFormatter.formatShort(fraudResult.fineAmount)}\n'
                                                  'İtibar Kaybı: -${fraudResult.reputationPenalty} Puan',
                                                  style: AppTypography.bodyMedium(p.isDark),
                                                ),
                                                actions: [
                                                  NeoBrutalButton(
                                                    label: 'Tamam',
                                                    backgroundColor: const Color(0xFFEF4444),
                                                    textColor: Colors.white,
                                                    onPressed: () => Navigator.pop(ctx),
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
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

                                            NotificationService.showSuccess(
                                              context,
                                              '${CurrencyFormatter.format(offer.offeredAmount)} tutarında araç satışı yapıldı!',
                                            );
                                          }
                                        },
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
    final isDark = p.isDark;
    double targetPrice = (offer.offeredAmount * 1.08).roundToDouble();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
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
                  NeoBrutalButton(
                    label: 'Karşı Teklifi İlet',
                    icon: Icons.send_rounded,
                    backgroundColor: const Color(0xFFFFDE59),
                    textColor: Colors.black,
                    fullWidth: true,
                    onPressed: () {
                      Navigator.pop(context);
                      final outcome = ref.read(gameProvider.notifier).counterOffer(offer.id, targetPrice);
                      NotificationService.showSuccess(context, outcome.responseMessage);
                    },
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
    final isDark = p.isDark;

    double selectedPrice = car.listingPrice;
    ListingDeclarationType selectedDeclaration = car.declarationType;

    final double minPrice = (car.currentPurchasePrice * 0.8).clamp(10000.0, car.estimatedRealValue);
    final double maxPrice = (car.estimatedRealValue * 1.6).roundToDouble();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF0C0E14) : const Color(0xFFF4F4F0),
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
                    Text(
                      'BELİRLENEN İLAN FİYATI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? p.primaryColor : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Müşterilerin vereceği tüm teklifler belirlediğiniz bu fiyatın altında kalacaktır.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF141721) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A),
                          width: 1.4,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('İlan Satış Fiyatı:', style: AppTypography.labelSmall(p.isDark)),
                              Text(
                                CurrencyFormatter.format(selectedPrice),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? const Color(0xFF00E575) : const Color(0xFF15803D),
                                ),
                              ),
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
                                onPressed: () {
                                  setState(() => selectedPrice = car.estimatedRealValue.roundToDouble());
                                },
                              ),
                              ActionChip(
                                label: const Text('+%10 Kâr', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  setState(() => selectedPrice = (car.estimatedRealValue * 1.10).roundToDouble());
                                },
                              ),
                              ActionChip(
                                label: const Text('+%20 Tok Satıcı', style: TextStyle(fontSize: 11)),
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
                    Text(
                      'İLAN BEYANI (STRATEJİK SEÇİM)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    _buildDeclarationCard(
                      title: 'Dürüst İlan',
                      subtitle: 'Araç durumu olduğu gibi beyan edilir. Risk yok.',
                      color: const Color(0xFF00E575),
                      isSelected: selectedDeclaration == ListingDeclarationType.honest,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.honest),
                      p: p,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDeclarationCard(
                      title: 'Hatasız Boyasız Hilesi',
                      subtitle: 'Hasarlar gizlenir. Müşteri ekspertiz yaptırırsa ₺10k ceza kesilir.',
                      color: const Color(0xFFFF7A00),
                      isSelected: selectedDeclaration == ListingDeclarationType.flawlessClaim,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.flawlessClaim),
                      p: p,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildDeclarationCard(
                      title: 'Sayaç Düşürme Hilesi',
                      subtitle: 'KM düşürülmüş gösterilir. Beyin taramasında yakalanırsa ₺10k ceza kesilir.',
                      color: const Color(0xFFEF4444),
                      isSelected: selectedDeclaration == ListingDeclarationType.tamperedMileageClaim,
                      onTap: () => setState(() => selectedDeclaration = ListingDeclarationType.tamperedMileageClaim),
                      p: p,
                      isDark: isDark,
                    ),

                    const SizedBox(height: 24),
                    NeoBrutalButton(
                      label: 'İlanı Güncelle & Kaydet',
                      icon: Icons.check_circle_rounded,
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        ref.read(gameProvider.notifier).updateCarListingDetails(
                              car.id,
                              customPrice: selectedPrice,
                              declaration: selectedDeclaration,
                            );
                        Navigator.pop(context);
                        NotificationService.showSuccess(context, '${car.brand} ${car.modelName} ilanı güncellendi!');
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

  Widget _buildDeclarationCard({
    required String title,
    required String subtitle,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemePaletteModel p,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: isDark ? 0.25 : 0.15) : (isDark ? const Color(0xFF141721) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : (isDark ? const Color(0xFF2A3142) : const Color(0xFF0F172A)),
            width: isSelected ? 2.0 : 1.2,
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
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: isSelected ? color : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10.5,
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
  }
}
