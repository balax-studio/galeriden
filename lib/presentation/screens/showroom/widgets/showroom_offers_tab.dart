import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/customer_model.dart';
import '../../../../data/models/customer_review_model.dart';
import '../../../../data/models/dealership_model.dart';
import '../../../../data/models/expertise_model.dart';
import '../../../../data/models/offer_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/app_vector_icons.dart';
import '../../../widgets/neo_brutal_button.dart';
import '../../../widgets/neo_brutal_card.dart';
import 'showroom_listing_modal.dart';

class ShowroomOffersTab extends ConsumerWidget {
  final DealershipModel game;
  final ThemePaletteModel palette;

  const ShowroomOffersTab({
    super.key,
    required this.game,
    required this.palette,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = palette.isDark;

    if (game.incomingOffers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Henüz gelen pazarlık teklifi bulunmuyor.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium(palette.isDark),
          ),
        ),
      );
    }

    return ListView.builder(
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
                        color: isDark ? palette.primaryColor : const Color(0xFF0F172A),
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
                            ShowroomListingModal.showCounterOfferSheet(context, ref, offer, car);
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
                                      VectorIconWidget(type: 'error', color: palette.errorColor, size: 24),
                                      const SizedBox(width: 8),
                                      Text(
                                        fraudResult.title,
                                        style: TextStyle(
                                          color: palette.errorColor,
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
                                    style: AppTypography.bodyMedium(palette.isDark),
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
    );
  }
}
