import 'package:flutter/material.dart';
import 'listing_model.dart';

enum SellerPersona {
  urgentCash(
    title: 'Acil Nakitçi',
    badgeText: 'ACİL NAKİT (%20 Esner)',
    color: Color(0xFFEF4444),
    icon: Icons.bolt_rounded,
    discountFlexibility: 0.22,
  ),
  meticulousOfficer(
    title: 'Titiz Memur',
    badgeText: 'TİTİZ MEMUR (Hatasız)',
    color: Color(0xFF38BDF8),
    icon: Icons.badge_rounded,
    discountFlexibility: 0.05,
  ),
  colleagueDealer(
    title: 'Galerici Esnafı',
    badgeText: 'ESNAF (Pazarlık Sıkı)',
    color: Color(0xFFFFDE59),
    icon: Icons.handshake_rounded,
    discountFlexibility: 0.10,
  ),
  expat(
    title: 'Gurbetçi',
    badgeText: 'GURBETÇİ (Kelepir)',
    color: Color(0xFF00E575),
    icon: Icons.flight_takeoff_rounded,
    discountFlexibility: 0.18,
  ),
  firstHandElder(
    title: 'İlk Sahibi Emekli',
    badgeText: 'İLK SAHİBİ (Düşük KM)',
    color: Color(0xFF10B981),
    icon: Icons.elderly_rounded,
    discountFlexibility: 0.08,
  ),
  tunedEnthusiast(
    title: 'Genç Modifiyeci',
    badgeText: 'MODİFİYELİ (Yazılımlı)',
    color: Color(0xFFF97316),
    icon: Icons.speed_rounded,
    discountFlexibility: 0.14,
  ),
  fleetManager(
    title: 'Filo Sorumlusu',
    badgeText: 'FİLO ÇIKIŞLI (Faturalı)',
    color: Color(0xFF64748B),
    icon: Icons.business_rounded,
    discountFlexibility: 0.16,
  ),
  collector(
    title: 'Koleksiyoner',
    badgeText: 'KOLEKSİYON (Değerini Bilen)',
    color: Color(0xFFA855F7),
    icon: Icons.diamond_rounded,
    discountFlexibility: 0.03,
  );

  final String title;
  final String badgeText;
  final Color color;
  final IconData icon;
  final double discountFlexibility;

  const SellerPersona({
    required this.title,
    required this.badgeText,
    required this.color,
    required this.icon,
    required this.discountFlexibility,
  });

  static SellerPersona fromString(String trait) {
    if (trait.contains('Acil') || trait.contains('Fırsat')) return SellerPersona.urgentCash;
    if (trait.contains('Memur') || trait.contains('Doktor')) return SellerPersona.meticulousOfficer;
    if (trait.contains('Gurbet') || trait.contains('Almancı')) return SellerPersona.expat;
    if (trait.contains('Emekli') || trait.contains('Amcadan') || trait.contains('İlk Sahibi')) return SellerPersona.firstHandElder;
    if (trait.contains('Modifiye') || trait.contains('Yazılım') || trait.contains('Genç')) return SellerPersona.tunedEnthusiast;
    if (trait.contains('Filo') || trait.contains('Şirket') || trait.contains('Fatura')) return SellerPersona.fleetManager;
    if (trait.contains('Koleksiyon') || trait.contains('Kupon') || trait.contains('Koleksiyoner')) return SellerPersona.collector;
    return SellerPersona.colleagueDealer;
  }
}

enum MarketSortOption {
  defaultSort(label: 'Varsayılan', icon: Icons.sort_rounded),
  priceAsc(label: 'Fiyat: En Düşük', icon: Icons.arrow_upward_rounded),
  priceDesc(label: 'Fiyat: En Yüksek', icon: Icons.arrow_downward_rounded),
  mileageAsc(label: 'KM: En Düşük', icon: Icons.speed_rounded),
  roiDesc(label: 'Kârlılık: En Yüksek', icon: Icons.trending_up_rounded),
  yearDesc(label: 'Model: En Yeni', icon: Icons.calendar_month_rounded);

  final String label;
  final IconData icon;

  const MarketSortOption({required this.label, required this.icon});

  List<ListingModel> sortListings(List<ListingModel> listings) {
    final copy = List<ListingModel>.from(listings);
    switch (this) {
      case MarketSortOption.priceAsc:
        copy.sort((a, b) => a.askingPrice.compareTo(b.askingPrice));
        break;
      case MarketSortOption.priceDesc:
        copy.sort((a, b) => b.askingPrice.compareTo(a.askingPrice));
        break;
      case MarketSortOption.mileageAsc:
        copy.sort((a, b) => a.car.expertise.mileage.compareTo(b.car.expertise.mileage));
        break;
      case MarketSortOption.roiDesc:
        copy.sort((a, b) {
          final roiA = (a.car.estimatedRealValue - a.askingPrice) / (a.askingPrice > 0 ? a.askingPrice : 1);
          final roiB = (b.car.estimatedRealValue - b.askingPrice) / (b.askingPrice > 0 ? b.askingPrice : 1);
          return roiB.compareTo(roiA);
        });
        break;
      case MarketSortOption.yearDesc:
        copy.sort((a, b) => b.car.modelYear.compareTo(a.car.modelYear));
        break;
      case MarketSortOption.defaultSort:
        break;
    }
    return copy;
  }
}

class ListingSlogan {
  final String id;
  final String name;
  final String headline;
  final String appealBuff;
  final Color color;
  final IconData icon;

  const ListingSlogan({
    required this.id,
    required this.name,
    required this.headline,
    required this.appealBuff,
    required this.color,
    required this.icon,
  });

  static const List<ListingSlogan> presets = [
    ListingSlogan(
      id: 'doctor_clean',
      name: 'Doktordan Temiz',
      headline: 'Doktordan temiz, sadece hafta sonları binildi.',
      appealBuff: '+%20 Aile Alıcı İlgisi',
      color: Color(0xFF38BDF8),
      icon: Icons.medical_services_rounded,
    ),
    ListingSlogan(
      id: 'retired_teacher',
      name: 'Emekli Öğretmenden',
      headline: 'Kapalı garajda muhafaza edildi, tek elden titizlikle kullanıldı.',
      appealBuff: '+%18 Güven Primi',
      color: Color(0xFF10B981),
      icon: Icons.school_rounded,
    ),
    ListingSlogan(
      id: 'fully_loaded',
      name: 'Gırtlak Dolu',
      headline: 'Gırtlak dolu, sanayide ve piyasada eşi benzeri yok!',
      appealBuff: '+%15 Genç Alıcı Primi',
      color: Color(0xFFFFDE59),
      icon: Icons.speed_rounded,
    ),
    ListingSlogan(
      id: 'dealer_colleague',
      name: 'Galericiye Yarar',
      headline: 'Esnafa ekmek yedirir, masrafsız devir teslim.',
      appealBuff: '+%25 Hızlı Satış Hızı',
      color: Color(0xFFF97316),
      icon: Icons.storefront_rounded,
    ),
    ListingSlogan(
      id: 'first_come_first_served',
      name: 'İlk Gelen Alır',
      headline: 'Pazarlıksız dip fiyat, ilk gelen alır!',
      appealBuff: '2x Hızlı Müşteri Akışı',
      color: Color(0xFFEF4444),
      icon: Icons.local_fire_department_rounded,
    ),
    ListingSlogan(
      id: 'collector_gem',
      name: 'Koleksiyonluk Kupon',
      headline: 'Koleksiyonluk kupon araç, değerini bilen baksın.',
      appealBuff: 'VIP Zengin Alıcı Teklifi',
      color: Color(0xFFA855F7),
      icon: Icons.diamond_rounded,
    ),
    ListingSlogan(
      id: 'lady_driven',
      name: 'Şehir İçi Titiz',
      headline: 'İçinde sigara içilmedi, koltuklarında leke yok.',
      appealBuff: '+%15 Temiz Algısı',
      color: Color(0xFFEC4899),
      icon: Icons.spa_rounded,
    ),
  ];
}
