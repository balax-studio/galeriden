import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    String selectedStrategy = 'ikna_et';

    final remainingCounters = offer.maxCounters - offer.counterCount;

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
                        Text('KARŞI TEKLİF SUN', style: AppTypography.titleLarge(p.isDark)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: remainingCounters <= 1 ? const Color(0xFFEF4444) : const Color(0xFFFFDE59),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black, width: 1.4),
                          ),
                          child: Text(
                            'Kalan Hak: $remainingCounters / ${offer.maxCounters}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${offer.buyerName} kişisine karşı fiyat ve strateji öner:', style: AppTypography.labelSmall(p.isDark)),
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
                    const SizedBox(height: 12),

                    Text('PAZARLIK YAKLAŞIMI / STRATEJİSİ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: p.primaryColor)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStrategyButton(
                            label: '🔍 Şeffaflık',
                            subtitle: '+%20 İkna Bonusu',
                            isSelected: selectedStrategy == 'ikna_et',
                            onTap: () => setState(() => selectedStrategy = 'ikna_et'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStrategyButton(
                            label: '☕ Çay İkramı',
                            subtitle: 'Esnaf Sıcaklığı',
                            isSelected: selectedStrategy == 'duyguya_oyna',
                            onTap: () => setState(() => selectedStrategy = 'duyguya_oyna'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStrategyButton(
                            label: '💼 Tok Satıcı',
                            subtitle: 'Gençleri Etkiler',
                            isSelected: selectedStrategy == 'sert_dur',
                            onTap: () => setState(() => selectedStrategy = 'sert_dur'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildStrategyButton(
                            label: '⚡ Hızlı Kapat',
                            subtitle: 'Nakit İndirimi',
                            isSelected: selectedStrategy == 'hizli_kapat',
                            onTap: () => setState(() => selectedStrategy = 'hizli_kapat'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    NeoBrutalButton(
                      label: 'Karşı Teklifi İlet',
                      icon: Icons.send_rounded,
                      backgroundColor: const Color(0xFFFFDE59),
                      textColor: Colors.black,
                      fullWidth: true,
                      onPressed: () {
                        Navigator.pop(context);
                        final outcome = ref.read(gameProvider.notifier).counterOffer(
                              offer.id,
                              targetPrice,
                              strategy: selectedStrategy,
                            );
                        NotificationService.showSuccess(context, outcome.responseMessage);
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

  static Widget _buildStrategyButton({
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFDE59) : (isDark ? const Color(0xFF141721) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : (isDark ? const Color(0xFF2A3142) : Colors.grey.shade400),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                color: isSelected ? Colors.black87 : (isDark ? Colors.grey : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showListingEditSheet(BuildContext context, WidgetRef ref, CarModel car) {
    final themeExt = Theme.of(context).extension<AppThemeExtension>()!;
    final p = themeExt.palette;
    final isDark = p.isDark;

    double selectedPrice = car.listingPrice > 0 ? car.listingPrice : (car.estimatedRealValue * 1.20).roundToDouble();
    ListingDeclarationType selectedDeclaration = car.declarationType;
    String selectedPhotoLocation = car.listingPhotoLocation;
    int selectedPhotoCount = car.listingPhotoCount;
    String selectedTone = car.listingTone;
    bool hideDamagedPhotos = car.hideDamagedPhotos;
    bool allowsInstallments = car.allowsInstallments;

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
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Piyasa Ekspertiz Değeri: ${CurrencyFormatter.formatShort(car.estimatedRealValue)}',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: p.textSecondaryColor),
                              ),
                              Text(
                                'Çapa: %${((selectedPrice / car.estimatedRealValue) * 100).toInt()}',
                                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: p.primaryColor),
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
                              HapticFeedback.selectionClick();
                              setState(() {
                                selectedPrice = (val / 1000).round() * 1000.0;
                              });
                            },
                          ),

                          // Real-Time Inline Market Valuation & Buyer Interest Badge
                          Builder(
                            builder: (context) {
                              final double diffRatio = (selectedPrice - car.estimatedRealValue) / car.estimatedRealValue;
                              final double diffPct = diffRatio * 100;
                              Color badgeColor;
                              Color textColor;
                              IconData badgeIcon;
                              String badgeText;

                              if (diffPct <= -10) {
                                badgeColor = const Color(0xFF00E575);
                                textColor = Colors.black;
                                badgeIcon = Icons.bolt_rounded;
                                badgeText = '-%${diffPct.abs().toStringAsFixed(0)} FIRSAT FİYAT (Çok Hızlı Teklif Gelir)';
                              } else if (diffPct <= 5) {
                                badgeColor = const Color(0xFFFFDE59);
                                textColor = Colors.black;
                                badgeIcon = Icons.balance_rounded;
                                badgeText = 'PİYASA DENGESİNDE (Normal Satış Hızı)';
                              } else if (diffPct <= 20) {
                                badgeColor = const Color(0xFFFF7A00);
                                textColor = Colors.black;
                                badgeIcon = Icons.hourglass_bottom_rounded;
                                badgeText = '+%${diffPct.toStringAsFixed(0)} YÜKSEK FİYAT (Yavaş Satış / Tok Satıcı)';
                              } else {
                                badgeColor = const Color(0xFFEF4444);
                                textColor = Colors.white;
                                badgeIcon = Icons.warning_amber_rounded;
                                badgeText = '+%${diffPct.toStringAsFixed(0)} RİSKLİ FİYAT (Alıcılar Pas Geçebilir)';
                              }

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: badgeColor,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.black, width: 1.4),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black, offset: Offset(1.5, 1.5)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(badgeIcon, size: 16, color: textColor),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        badgeText,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ActionChip(
                                label: const Text('Piyasa Değeri', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => selectedPrice = car.estimatedRealValue.roundToDouble());
                                },
                              ),
                              ActionChip(
                                label: const Text('+%10 Kâr', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => selectedPrice = (car.estimatedRealValue * 1.10).roundToDouble());
                                },
                              ),
                              ActionChip(
                                label: const Text('+%20 Tok Satıcı', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => selectedPrice = (car.estimatedRealValue * 1.20).roundToDouble());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Fotoğraf Çekim Lokasyonu & Kalitesi
                    Text(
                      'FOTOĞRAF ÇEKİMİ & SUNUM SANATI',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceCard(
                            title: 'Galeri Önü',
                            subtitle: 'Ücretsiz',
                            isSelected: selectedPhotoLocation == 'dealership',
                            onTap: () => setState(() => selectedPhotoLocation = 'dealership'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildChoiceCard(
                            title: 'Manzaralı',
                            subtitle: '-₺800 (+%3 İlgi)',
                            isSelected: selectedPhotoLocation == 'scenic',
                            onTap: () => setState(() => selectedPhotoLocation = 'scenic'),
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildChoiceCard(
                            title: 'VIP Stüdyo',
                            subtitle: '-₺1.500 (+%5 İlgi)',
                            isSelected: selectedPhotoLocation == 'studio',
                            onTap: () => setState(() => selectedPhotoLocation = 'studio'),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Fotoğraf Adedi & İlan Tonu
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: selectedPhotoCount,
                            decoration: InputDecoration(
                              labelText: 'Fotoğraf Sayısı',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 4, child: Text('4 Fotoğraf')),
                              DropdownMenuItem(value: 8, child: Text('8 Fotoğraf (+%2 İlgi)')),
                              DropdownMenuItem(value: 12, child: Text('12 Detaylı Foto (+%4)')),
                            ],
                            onChanged: (val) => setState(() => selectedPhotoCount = val ?? 4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedTone,
                            decoration: InputDecoration(
                              labelText: 'İlan Tonu',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'standard', child: Text('Standart')),
                              DropdownMenuItem(value: 'friendly', child: Text('Samimi Esnaf')),
                              DropdownMenuItem(value: 'vip', child: Text('VIP / Kurumsal')),
                            ],
                            onChanged: (val) => setState(() => selectedTone = val ?? 'standard'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Senetle Satış & Hasar Gizleme Toggles
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Senetle / Taksitli Satışa Aç', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Taksitli ve senetli alıcıların teklif vermesine izin ver (%20 vade farkı)', style: TextStyle(fontSize: 11)),
                      value: allowsInstallments,
                      activeThumbColor: const Color(0xFF00E575),
                      onChanged: (val) => setState(() => allowsInstallments = val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Hasarlı Açıları Fotoğrafta Gizle', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Kusurlu bölgeleri kadraj dışı bırak (Ekspertizde yakalanma riski taşır)', style: TextStyle(fontSize: 11)),
                      value: hideDamagedPhotos,
                      activeThumbColor: const Color(0xFFFF7A00),
                      onChanged: (val) => setState(() => hideDamagedPhotos = val),
                    ),

                    const SizedBox(height: 16),

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

                    if (car.provenanceLog.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'ARAÇ KÜNYESİ & GEÇMİŞİ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isDark ? const Color(0xFF00F0FF) : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF141721) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF2A3142) : Colors.grey.shade400,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: car.provenanceLog.map((log) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.history_edu_rounded, size: 16, color: Color(0xFFFFDE59)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      log,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? Colors.white70 : const Color(0xFF334155),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

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
                              listingPhotoLocation: selectedPhotoLocation,
                              listingPhotoCount: selectedPhotoCount,
                              listingTone: selectedTone,
                              hideDamagedPhotos: hideDamagedPhotos,
                              allowsInstallments: allowsInstallments,
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

  static Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFDE59) : (isDark ? const Color(0xFF141721) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.black : (isDark ? const Color(0xFF2A3142) : Colors.grey.shade400),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                color: isSelected ? Colors.black87 : (isDark ? Colors.grey : Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
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
