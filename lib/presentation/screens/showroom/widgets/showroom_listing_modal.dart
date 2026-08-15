import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/notification_service.dart';
import '../../../../data/models/car_model.dart';
import '../../../../data/models/offer_model.dart';
import '../../../../data/models/theme_palette_model.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/neo_brutal_button.dart';

class ShowroomListingModal {
  static void showCounterOfferSheet(BuildContext context, WidgetRef ref, OfferModel offer, CarModel car) {
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

  static void showListingEditSheet(BuildContext context, WidgetRef ref, CarModel car) {
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

  static Widget _buildDeclarationCard({
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
