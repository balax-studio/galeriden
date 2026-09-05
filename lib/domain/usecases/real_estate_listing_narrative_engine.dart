import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/models/real_estate_category.dart';
import '../../data/models/real_estate_model.dart';
import '../../data/models/real_estate_offer_model.dart';

class ListingFeatureItem {
  final String id;
  final String label;
  final IconData icon;
  final String narrativeSnippet;

  const ListingFeatureItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.narrativeSnippet,
  });
}

class ListingFeatureGroup {
  final String groupId;
  final String groupTitle;
  final List<ListingFeatureItem> features;

  const ListingFeatureGroup({
    required this.groupId,
    required this.groupTitle,
    required this.features,
  });
}

class RealEstateListingNarrativeEngine {
  /// Mülk kategorisine özel özellik gruplarını döner
  static List<ListingFeatureGroup> getFeatureGroups(RealEstateCategory category) {
    switch (category) {
      case RealEstateCategory.land:
        return _landFeatureGroups;
      case RealEstateCategory.commercial:
      case RealEstateCategory.building:
        return _commercialFeatureGroups;
      case RealEstateCategory.tourismFacility:
      case RealEstateCategory.timeshare:
        return _villaFeatureGroups;
      case RealEstateCategory.housing:
      case RealEstateCategory.housingProjects:
        return _residentialFeatureGroups;
    }
  }

  /// Mülk tipine özel manşet başlık şablonları
  static List<String> getHeadlinePresets(RealEstateCategory category) {
    switch (category) {
      case RealEstateCategory.land:
        return const [
          'Kat Karşılığı & Yatırıma Uygun • Değerli İmar Parseli',
          'Yatırımlık Sanayi & Lojistik İmarı • Kaçırılmayacak Fırsat',
          'Yola Cepheli • Altyapısı Eksiksiz Gelişim Bölgesi',
          'Kelepir Fiyat • İfrazlı Müstakil Tapulu Arsa',
          'Geleceğin Cazibe Merkezinde • Yüksek Emsalli Parsel',
        ];
      case RealEstateCategory.commercial:
      case RealEstateCategory.building:
        return const [
          'Kurumsal Kiracı Adaylı • Yüksek Tabela Değerli Dükkan',
          'Cadde Üstü Köşe Parsel • Yoğun Yaya & Araç Trafiği',
          'Yatırımlık Amortismanı Hızlı • Prestijli Ticari Mülk',
          'Sanayi Bacalı & Yüksek Tavanlı • Her Sektöre Uygun',
          'Kurumsal Market & Banka Ruhsatına Uygun • Düz Ayak',
        ];
      case RealEstateCategory.tourismFacility:
      case RealEstateCategory.timeshare:
        return const [
          'Müstakil Havuzlu & Bahçeli • Emsalsiz Lüks Malikane',
          'Panoramik Manzaralı • Akıllı Ev Konseptli Özel Yaşam',
          'Şehrin Gürültüsünden Uzak • Prestijli Müstakil Villa',
          'Kişiye Özel Tasarım • Geniş Peyzaj ve Müştemilatlı',
          'Doğayla İç İçe • Yüksek Güvenlikli Prestijli Konsept',
        ];
      case RealEstateCategory.housing:
      case RealEstateCategory.housingProjects:
        return const [
          'Sahibinden Acil Satılık • Kaçırılmayacak Kelepir Fırsat',
          'Yüksek Kira Getirili • Yatırımlık Merkezi Konum',
          'Lüks Tasarım & Prestijli • Emsalsiz Yaşam Alanı',
          'Güneş Alan Güney Cephe • Geniş & Ferah Aile Dairesi',
          'Krediye Uygun • Kat Mülkiyetli Masrafsız Daire',
        ];
    }
  }

  /// Seçilen özellikler ve mülk kimliğiyle organik ilan metni üretir
  static String generateDescription({
    required RealEstateModel property,
    required String headline,
    required List<String> selectedFeatureIds,
  }) {
    final buffer = StringBuffer();

    // 1. Giriş cümlesi
    buffer.write(headline);
    buffer.write(' • ');
    buffer.write(property.city);
    buffer.write(' ');
    buffer.write(property.district);
    buffer.write(' lokasyonunda yer alan portföyümüz ');
    buffer.write(property.squareMeters);
    buffer.write(' m² kullanım alanına sahiptir.');

    // 2. Oda ve bina niteliği
    if (property.category != RealEstateCategory.land) {
      buffer.write(' ');
      buffer.write(property.roomCount);
      buffer.write(' planında tasarlanan mülk ');
      if (property.buildingAge == 0) {
        buffer.write('sıfır yeni yapıdır.');
      } else {
        buffer.write(property.buildingAge);
        buffer.write(' yaşındadır.');
      }
    }

    // 3. Seçilen detayların akıcı entegrasyonu
    final allFeatures = getFeatureGroups(property.category)
        .expand((g) => g.features)
        .toList();
    final matchedSnippets = <String>[];

    for (final id in selectedFeatureIds) {
      final match = allFeatures.where((f) => f.id == id);
      if (match.isNotEmpty) {
        matchedSnippets.add(match.first.narrativeSnippet);
      }
    }

    if (matchedSnippets.isNotEmpty) {
      buffer.write(' Mülkümüz ');
      buffer.write(matchedSnippets.join(', '));
      if (matchedSnippets.length == 1) {
        buffer.write(' avantajına sahiptir.');
      } else {
        buffer.write(' avantajlarına sahiptir.');
      }
    }

    // 4. Tapu ve yatırım kapanış cümlesi
    buffer.write(' ');
    if (property.isRenovated) {
      buffer.write('A dan Z ye 1. sınıf malzemelerle baştan aşağı yenilenmiş olup hiçbir masrafı bulunmamaktadır. ');
    }
    buffer.write('Resmi tapu durumu ');
    switch (property.deedType) {
      case DeedType.ownershipDeed:
        buffer.write('Kat Mülkiyetli');
        break;
      case DeedType.constructionServitude:
        buffer.write('Kat İrtifaklı');
        break;
      case DeedType.sharedDeed:
        buffer.write('Hisseli Tapulu');
        break;
      case DeedType.unlicensedBuilding:
        buffer.write('Müstakil Parsel');
        break;
    }
    buffer.write(' olup krediye ve hemen devire uygundur. Alıcısına şimdiden hayırlı uğurlu olsun.');

    return buffer.toString();
  }

  // --- KONUT & DAİRE ÖZELLİK GRUPLARI ---
  static const List<ListingFeatureGroup> _residentialFeatureGroups = [
    ListingFeatureGroup(
      groupId: 'facade',
      groupTitle: 'Cephe & Konum',
      features: [
        ListingFeatureItem(
          id: 'res_facade_south',
          label: 'Güney Cepheli',
          icon: Icons.wb_sunny_rounded,
          narrativeSnippet: 'gün boyu güneş alan güney cephesi',
        ),
        ListingFeatureItem(
          id: 'res_facade_east',
          label: 'Doğu Cepheli',
          icon: Icons.brightness_5_rounded,
          narrativeSnippet: 'sabah güneşini alan ferah doğu cephesi',
        ),
        ListingFeatureItem(
          id: 'res_facade_corner',
          label: 'Çift Cepheli & Aydınlık',
          icon: Icons.aspect_ratio_rounded,
          narrativeSnippet: 'çapraz esintili çift cepheli mimarisi',
        ),
      ],
    ),
    ListingFeatureGroup(
      groupId: 'heating',
      groupTitle: 'Isınma & Konfor',
      features: [
        ListingFeatureItem(
          id: 'res_heat_floor',
          label: 'Yerden Isıtma',
          icon: Icons.waves_rounded,
          narrativeSnippet: 'modern yerden ısıtma konforu',
        ),
        ListingFeatureItem(
          id: 'res_heat_combi',
          label: 'Doğalgaz Kombi',
          icon: Icons.local_fire_department_rounded,
          narrativeSnippet: 'bağımsız tasarruflu doğalgaz kombisi',
        ),
        ListingFeatureItem(
          id: 'res_heat_ac',
          label: 'İnverter Klima',
          icon: Icons.ac_unit_rounded,
          narrativeSnippet: 'sessiz inverter klima donanımı',
        ),
      ],
    ),
    ListingFeatureGroup(
      groupId: 'view',
      groupTitle: 'Manzara & Kat',
      features: [
        ListingFeatureItem(
          id: 'res_view_sea',
          label: 'Deniz & Boğaz Manzarası',
          icon: Icons.sailing_rounded,
          narrativeSnippet: 'kapanmaz deniz ve boğaz manzarası',
        ),
        ListingFeatureItem(
          id: 'res_view_city',
          label: 'Panoramik Şehir Manzarası',
          icon: Icons.location_city_rounded,
          narrativeSnippet: 'ışıl ışıl panoramik şehir silüeti',
        ),
        ListingFeatureItem(
          id: 'res_view_park',
          label: 'Peyzaj & Park Manzaralı',
          icon: Icons.park_rounded,
          narrativeSnippet: 'huzur veren yeşil park manzarası',
        ),
      ],
    ),
    ListingFeatureGroup(
      groupId: 'amenities',
      groupTitle: 'Bina & Site Donatıları',
      features: [
        ListingFeatureItem(
          id: 'res_amenity_parking',
          label: 'Kapalı Otopark',
          icon: Icons.local_parking_rounded,
          narrativeSnippet: 'tahsisli kapalı otopark alanı',
        ),
        ListingFeatureItem(
          id: 'res_amenity_security',
          label: '24/7 Özel Güvenlik',
          icon: Icons.shield_rounded,
          narrativeSnippet: '7/24 kameralı güvenlik ve resepsiyon hizmeti',
        ),
        ListingFeatureItem(
          id: 'res_amenity_elevator',
          label: 'Çift Asansörlü',
          icon: Icons.elevator_rounded,
          narrativeSnippet: 'hızlı çift asansör altyapısı',
        ),
        ListingFeatureItem(
          id: 'res_amenity_balcony',
          label: 'Geniş Çift Balkon',
          icon: Icons.deck_rounded,
          narrativeSnippet: 'cam balkonlu geniş oturum alanı',
        ),
        ListingFeatureItem(
          id: 'res_amenity_ensuite',
          label: 'Ebeveyn Banyolu',
          icon: Icons.bathtub_rounded,
          narrativeSnippet: 'özel tasarım ebeveyn banyosu',
        ),
      ],
    ),
  ];

  // --- TİCARİ & DÜKKAN ÖZELLİK GRUPLARI ---
  static const List<ListingFeatureGroup> _commercialFeatureGroups = [
    ListingFeatureGroup(
      groupId: 'commercial_location',
      groupTitle: 'Lokasyon & Tabela Değeri',
      features: [
        ListingFeatureItem(
          id: 'com_street_front',
          label: 'Ana Cadde Cepheli',
          icon: Icons.add_road_rounded,
          narrativeSnippet: 'ana cadde üzerinde yüksek tabela değeri',
        ),
        ListingFeatureItem(
          id: 'com_corner',
          label: 'Köşe Başında',
          icon: Icons.turn_right_rounded,
          narrativeSnippet: 'çift cepheli köşe parsel konumu',
        ),
        ListingFeatureItem(
          id: 'com_pedestrian',
          label: 'Yoğun Yaya Trafiği',
          icon: Icons.directions_walk_rounded,
          narrativeSnippet: 'duraksız yüksek yaya sirkülasyonu',
        ),
      ],
    ),
    ListingFeatureGroup(
      groupId: 'commercial_architecture',
      groupTitle: 'Mimari Donatı & Altyapı',
      features: [
        ListingFeatureItem(
          id: 'com_high_ceiling',
          label: '4.5m Yüksek Tavan',
          icon: Icons.height_rounded,
          narrativeSnippet: 'ferah 4.5 metre tavan yüksekliği',
        ),
        ListingFeatureItem(
          id: 'com_chimney',
          label: 'Sanayi Bacası & Havalandırma',
          icon: Icons.air_rounded,
          narrativeSnippet: 'ruhsatlı sanayi tipi havalandırma bacası',
        ),
        ListingFeatureItem(
          id: 'com_ramp',
          label: 'Mal Kabul Rampası',
          icon: Icons.local_shipping_rounded,
          narrativeSnippet: 'kamyon ve sevkiyata uygun mal kabul rampası',
        ),
        ListingFeatureItem(
          id: 'com_power',
          label: '3 Faz Sanayi Elektriği',
          icon: Icons.bolt_rounded,
          narrativeSnippet: 'yüksek kilovatlı 3 faz sanayi elektriği',
        ),
      ],
    ),
    ListingFeatureGroup(
      groupId: 'commercial_tenant',
      groupTitle: 'Kurumsal Uygunluk',
      features: [
        ListingFeatureItem(
          id: 'com_corporate_ready',
          label: 'Kurumsal Kiracıya Uygun',
          icon: Icons.verified_user_rounded,
          narrativeSnippet: 'kurumsal zincir firmalara tam uygunluk',
        ),
        ListingFeatureItem(
          id: 'com_bank_permit',
          label: 'Banka & Market Ruhsatlı',
          icon: Icons.account_balance_rounded,
          narrativeSnippet: 'banka ve süpermarket yangın/iskan onayları',
        ),
      ],
    ),
  ];

  // --- ARSA & ARAZİ ÖZELLİK GRUPLARI ---
  static const List<ListingFeatureGroup> _landFeatureGroups = [
    ListingFeatureGroup(
      groupId: 'land_zoning',
      groupTitle: 'İmar Durumu & Emsal',
      features: [
        ListingFeatureItem(
          id: 'land_residential_zone',
          label: 'Konut İmarlı',
          icon: Icons.apartment_rounded,
          narrativeSnippet: 'konut gelişim bölgesinde yer alan onaylı imar hakkı',
        ),
        ListingFeatureItem(
          id: 'land_high_kaks',
          label: 'Yüksek KAKS 2.10',
          icon: Icons.domain_rounded,
          narrativeSnippet: 'yüksek getiri sağlayan 2.10 emsal oranı',
        ),
        ListingFeatureItem(
          id: 'land_commercial_zone',
          label: 'Ticari & Lojistik İmarı',
          icon: Icons.warehouse_rounded,
          narrativeSnippet: 'antrepo ve lojistiğe uygun ticari imar statüsü',
        ),
      ],
    ),
    ListingFeatureGroup(
      groupId: 'land_infrastructure',
      groupTitle: 'Altyapı & Çevre',
      features: [
        ListingFeatureItem(
          id: 'land_road_front',
          label: 'Yola Geniş Cephe',
          icon: Icons.alt_route_rounded,
          narrativeSnippet: 'asfalt yola 35 metre geniş cephe avantajı',
        ),
        ListingFeatureItem(
          id: 'land_utility_ready',
          label: 'Elektrik & Su & Doğalgaz',
          icon: Icons.power_rounded,
          narrativeSnippet: 'parsel sınırına kadar hazır altyapı şebekesi',
        ),
        ListingFeatureItem(
          id: 'land_contractor_ready',
          label: 'Kat Karşılığına Uygun',
          icon: Icons.handshake_rounded,
          narrativeSnippet: 'müteahhitlerin aradığı yüksek kat karşılığı potansiyeli',
        ),
      ],
    ),
  ];

  // --- VİLLA & LÜKS ÖZELLİK GRUPLARI ---
  static const List<ListingFeatureGroup> _villaFeatureGroups = [
    ListingFeatureGroup(
      groupId: 'villa_luxury',
      groupTitle: 'Lüks & Müstakil Yaşam',
      features: [
        ListingFeatureItem(
          id: 'villa_pool',
          label: 'Müstakil Yüzme Havuzu',
          icon: Icons.pool_rounded,
          narrativeSnippet: 'özel peyzajlı müstakil yüzme havuzu',
        ),
        ListingFeatureItem(
          id: 'villa_garden',
          label: 'Geniş Müstakil Bahçe',
          icon: Icons.yard_rounded,
          narrativeSnippet: 'otomatik sulamalı 400 m² müstakil yeşil bahçe',
        ),
        ListingFeatureItem(
          id: 'villa_smart_home',
          label: 'Akıllı Ev Otomasyonu',
          icon: Icons.touch_app_rounded,
          narrativeSnippet: 'uzaktan kontrollü akıllı ev ve kamera sistemi',
        ),
        ListingFeatureItem(
          id: 'villa_fireplace',
          label: 'Doğal Taş Şömine',
          icon: Icons.fireplace_rounded,
          narrativeSnippet: 'salonda keyifli doğal taş şömine',
        ),
        ListingFeatureItem(
          id: 'villa_annex',
          label: 'Müştemilat & Görevli Evi',
          icon: Icons.house_siding_rounded,
          narrativeSnippet: 'bağımsız girişli müştemilat konutu',
        ),
      ],
    ),
  ];

  /// Süper vitrin paketi seçildiğinde anında yüksek niyetli alıcı teklifi oluşturur
  static RealEstateOfferModel generateInitialSuperOffer({
    required RealEstateModel property,
    required double askingPrice,
  }) {
    final rand = Random();
    final variance = 0.94 + (rand.nextDouble() * 0.08);
    final offerAmount = ((askingPrice * variance) / 10000).round() * 10000.0;

    String buyerName;
    String buyerNote;

    switch (property.category) {
      case RealEstateCategory.land:
        buyerName = 'Müteahhit Haldun Özkan';
        buyerNote =
            'Süper vitrindeki arsa ilanınızı inceledik. Kat karşılığı veya nakit alım için finansmanımız hazır, tapu devrini hemen yapabiliriz.';
        break;
      case RealEstateCategory.commercial:
      case RealEstateCategory.building:
        buyerName = 'Yatırım Fonu Direktörü Bora Ekşi';
        buyerNote =
            'Kurumsal portföyümüz için tabela değeri ve konumu çok elverişli. Süper vitrin teklifimizle pazarlığa oturmak istiyoruz.';
        break;
      case RealEstateCategory.tourismFacility:
      case RealEstateCategory.timeshare:
        buyerName = 'Sanayici Teoman Karaca';
        buyerNote =
            'Prestijli mülk kriterlerimize tam uyuyor. Süper vitrin üzerinden gördüm, noterde peşin devir yapabiliriz.';
        break;
      case RealEstateCategory.housing:
      case RealEstateCategory.housingProjects:
        buyerName = 'Yatırımcı Kerem Haznedar';
        buyerNote =
            'Süper vitrin ilanınızı inceledim. Finansmanım hazır, tapu devrini bu hafta tamamlayabiliriz.';
        break;
    }

    return RealEstateOfferModel(
      id: 're_offer_super_${DateTime.now().millisecondsSinceEpoch}_${rand.nextInt(999)}',
      realEstateId: property.id,
      buyerName: buyerName,
      buyerNote: buyerNote,
      offeredAmount: offerAmount,
      daysRemaining: 4,
      createdAt: DateTime.now(),
    );
  }
}
