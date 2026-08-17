import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum DecorCategory {
  all,
  makam,
  social,
  display,
  security,
  prestige,
}

class ShowroomDecorModel {
  final String id;
  final String title;
  final String description;
  final String perkSummary;
  final DecorCategory category;
  final double cost;
  final double reputationBonus;
  final int minDealershipLevel;
  final IconData icon;
  final Color color;

  const ShowroomDecorModel({
    required this.id,
    required this.title,
    required this.description,
    required this.perkSummary,
    required this.category,
    required this.cost,
    required this.reputationBonus,
    required this.minDealershipLevel,
    required this.icon,
    required this.color,
  });

  static String getCategoryLabel(DecorCategory category) {
    switch (category) {
      case DecorCategory.all:
        return 'Tümü';
      case DecorCategory.makam:
        return 'Makam Odası';
      case DecorCategory.social:
        return 'Sosyal & İkram';
      case DecorCategory.display:
        return 'Vitrin & Şov';
      case DecorCategory.security:
        return 'Güvenlik';
      case DecorCategory.prestige:
        return 'Prestij & Kupa';
    }
  }

  static IconData getCategoryIcon(DecorCategory category) {
    switch (category) {
      case DecorCategory.all:
        return Icons.auto_awesome_rounded;
      case DecorCategory.makam:
        return Icons.chair_rounded;
      case DecorCategory.social:
        return Icons.emoji_food_beverage_rounded;
      case DecorCategory.display:
        return Icons.light_mode_rounded;
      case DecorCategory.security:
        return Icons.security_rounded;
      case DecorCategory.prestige:
        return Icons.emoji_events_rounded;
    }
  }

  static List<ShowroomDecorModel> getAllDecors() {
    return const [
      // 1. Makam Odası & Kişisel Patron Eşyaları (4 items)
      ShowroomDecorModel(
        id: 'decor_leather_chair_desk',
        title: 'Hakiki Deri Patron Koltuğu & Ceviz Masa',
        description: 'Ağır ceviz kaplama makam masası ve yüksek sırtlı deri koltuk. Galeri sahibinin otoritesini hissettirir.',
        perkSummary: '+%4 Pazarlık İkna Gücü (Alıcı indirim direncini kırar)',
        category: DecorCategory.makam,
        cost: 40000,
        reputationBonus: 5.0,
        minDealershipLevel: 1,
        icon: Icons.chair_rounded,
        color: Color(0xFFD97706),
      ),
      ShowroomDecorModel(
        id: 'decor_tesbih_lighter_stand',
        title: 'Oltu Taşı Tesbih & Gümüş Çakmak Standı',
        description: 'Masanın baş köşesinde duran el işçiliği gümüş çakmak ve oltu taşı tesbih standı.',
        perkSummary: 'Pazarlıkta alıcıların masadan kalkma/kaçma riskini %20 düşürür',
        category: DecorCategory.makam,
        cost: 18000,
        reputationBonus: 3.0,
        minDealershipLevel: 1,
        icon: Icons.style_rounded,
        color: Color(0xFF8B5CF6),
      ),
      ShowroomDecorModel(
        id: 'decor_nazar_prayer_frame',
        title: 'Nazar Boncuğu & Bereket Duası Tablosu',
        description: 'Geleneksel pirinç çerçeveli bereket tablosu. Galeriye nazar ve uğursuzluk girmesini engeller.',
        perkSummary: 'Karaborsa baskını, haciz ve noter denetimlerinde %15 hasar koruması',
        category: DecorCategory.makam,
        cost: 12000,
        reputationBonus: 4.0,
        minDealershipLevel: 1,
        icon: Icons.shield_moon_rounded,
        color: Color(0xFF3B82F6),
      ),
      ShowroomDecorModel(
        id: 'decor_money_counter_safe',
        title: 'Çelik Para Kasası & Sahte Para Dedektörü',
        description: 'Makam odası arkasında zırhlı gömme kasa ve mor ışıklı otomatik para sayma makinesi.',
        perkSummary: 'Nakit araç satışlarında +%2 net kâr primi ve sıfır sahte para riski',
        category: DecorCategory.makam,
        cost: 55000,
        reputationBonus: 6.0,
        minDealershipLevel: 2,
        icon: Icons.lock_clock_rounded,
        color: AppColors.brutalGreen,
      ),

      // 2. Sosyal Alan & Esnaf İkram Köşesi (3 items)
      ShowroomDecorModel(
        id: 'decor_copper_samovar',
        title: 'Közde Bakır Semaver & Çay Ocağı',
        description: 'Sürekli demlenen tavşan kanı Rize çayı ile showroomu esnaf ve müşterilerin uğrak noktası yapar.',
        perkSummary: 'Gelen müşterilerin bekleme süresini artırır; konsinye tekliflerini +%25 artırır',
        category: DecorCategory.social,
        cost: 15000,
        reputationBonus: 4.0,
        minDealershipLevel: 1,
        icon: Icons.emoji_food_beverage_rounded,
        color: Color(0xFFF97316),
      ),
      ShowroomDecorModel(
        id: 'decor_tavla_corner',
        title: 'Sedef Kakma Tavla & Esnaf Muhabbet Masası',
        description: 'Sanayi ustaları, esnaf komşular ve müşterilerle dostluğu pekiştiren geleneksel tavla köşesi.',
        perkSummary: 'Sanayi ustalarıyla dostluk; parça ve tamir faturalarında %10 kalıcı indirim',
        category: DecorCategory.social,
        cost: 22000,
        reputationBonus: 5.0,
        minDealershipLevel: 2,
        icon: Icons.casino_rounded,
        color: Color(0xFFEC4899),
      ),
      ShowroomDecorModel(
        id: 'decor_vip_lounge',
        title: 'VIP Kahve Lounge & Barista İstasyonu',
        description: 'Satış görüşmesi sırasında müşterilere özel espresso servisi ve deri koltuklu lüks alan.',
        perkSummary: 'Dürüst araç satışlarında +0.5 Müşteri Yorum Puanı ve +2 Ekstra İtibar',
        category: DecorCategory.social,
        cost: 65000,
        reputationBonus: 12.0,
        minDealershipLevel: 3,
        icon: Icons.coffee_rounded,
        color: Color(0xFFA855F7),
      ),

      // 3. Şov Podyumu & Görsel Mimari (5 items)
      ShowroomDecorModel(
        id: 'decor_led_grid',
        title: 'Tavan Lazer LED Aydınlatma Izgarası',
        description: 'Vitrindeki araçların boyasını parlatan lüks showroom tavan LED petek ızgarası.',
        perkSummary: 'Gün atlamalarında vitrindeki araçlara organik alıcı teklifleri çeker',
        category: DecorCategory.display,
        cost: 25000,
        reputationBonus: 5.0,
        minDealershipLevel: 1,
        icon: Icons.light_mode_rounded,
        color: AppColors.brutalYellow,
      ),
      ShowroomDecorModel(
        id: 'decor_granite_floor',
        title: 'İtalyan Mermer & Parlak Granit Zemin',
        description: 'Yansımalı ayna gibi parlak granit zemin döşemesi ile showroom çekiciliğini zirveye taşır.',
        perkSummary: 'Showroom çekiciliğini ve organik müşteri teklif frekansını artırır',
        category: DecorCategory.display,
        cost: 45000,
        reputationBonus: 8.0,
        minDealershipLevel: 2,
        icon: Icons.grid_view_rounded,
        color: Color(0xFF06B6D4),
      ),
      ShowroomDecorModel(
        id: 'decor_turntable_stage',
        title: 'Döner Platform & Spot Işık Podyumu',
        description: 'Showroom girişinde 360 derece dönen ve özel spotlarla aydınlatılan yıldız podyum sahnesi.',
        perkSummary: 'Vitrindeki Yıldız / Fırsat aracının satış süresini %40 hızlandırır',
        category: DecorCategory.display,
        cost: 85000,
        reputationBonus: 10.0,
        minDealershipLevel: 4,
        icon: Icons.rotate_right_rounded,
        color: Color(0xFF10B981),
      ),
      ShowroomDecorModel(
        id: 'decor_aroma_music_system',
        title: 'Akıllı Koku Difüzörü & Caz Müzik Sistemi',
        description: 'Lüks otel aromaterapi kokuları ve arka planda çalan hafif caz müziği ile premium ambiyans.',
        perkSummary: 'Kurumsal ve zengin müşteri profili çekme ihtimalini +%30 artırır',
        category: DecorCategory.display,
        cost: 38000,
        reputationBonus: 7.0,
        minDealershipLevel: 3,
        icon: Icons.air_rounded,
        color: Color(0xFF6366F1),
      ),
      ShowroomDecorModel(
        id: 'decor_led_totem_sign',
        title: 'Kayan Yazı & Dev Dış Totem Tabela',
        description: 'Ana cadde üzerinden geçen herkesin görebileceği yüksek çözünürlüklü dev LED totem tabela.',
        perkSummary: 'Şehir pazarından galeriye gelen günlük rastgele ayak trafiğini +%20 artırır',
        category: DecorCategory.display,
        cost: 50000,
        reputationBonus: 9.0,
        minDealershipLevel: 3,
        icon: Icons.campaign_rounded,
        color: Color(0xFFE11D48),
      ),

      // 4. Güvenlik & Akıllı Altyapı (3 items)
      ShowroomDecorModel(
        id: 'decor_security_cctv',
        title: 'Akıllı Güvenlik & CCTV Kamera Ağı',
        description: '7/24 gece görüşlü 4K kameralar ile showroom ve garaj çevresini korur.',
        perkSummary: 'Gece park halindeki araçların çizilme ve vandalizm riskini %0\'a indirir',
        category: DecorCategory.security,
        cost: 35000,
        reputationBonus: 6.0,
        minDealershipLevel: 1,
        icon: Icons.security_rounded,
        color: AppColors.brutalGreen,
      ),
      ShowroomDecorModel(
        id: 'decor_laser_alarm_system',
        title: 'Lazer Sensörlü Alarm & Çelik Kepenk',
        description: 'Cam ve kapılara entegre lazer bariyerli otomatik çelik güvenlik kepengi.',
        perkSummary: 'Gece hırsızlık ve parça çalınma olaylarını engeller, sigorta maliyetini düşürür',
        category: DecorCategory.security,
        cost: 60000,
        reputationBonus: 8.0,
        minDealershipLevel: 2,
        icon: Icons.lock_rounded,
        color: Color(0xFF14B8A6),
      ),
      ShowroomDecorModel(
        id: 'decor_plate_recognition_kiosk',
        title: 'Plaka Tanıma & Dijital İlan Kiosku',
        description: 'Girişte müşteri araçlarını ve taleplerini anında tarayan interaktif galeri kiosku.',
        perkSummary: 'Gelen müşterilerin bütçesini otomatik analiz ederek en uygun teklifi sunar',
        category: DecorCategory.security,
        cost: 75000,
        reputationBonus: 7.0,
        minDealershipLevel: 4,
        icon: Icons.qr_code_scanner_rounded,
        color: Color(0xFF0284C7),
      ),

      // 5. Prestij & Başarı Vitrini (1 item)
      ShowroomDecorModel(
        id: 'decor_trophy_cabinet',
        title: 'Kristal Kupa & Başarı Beratları Dolabı',
        description: 'Kazanılan kupa, plaket, ticaret odası beratları ve satılan efsane araçların sergi vitrini.',
        perkSummary: 'Müşteri güvenini maksimuma çıkarır; ekspertiz itirazlarını %30 azaltır',
        category: DecorCategory.prestige,
        cost: 95000,
        reputationBonus: 15.0,
        minDealershipLevel: 5,
        icon: Icons.emoji_events_rounded,
        color: AppColors.brutalYellow,
      ),
    ];
  }

  static ShowroomDecorModel? getById(String id) {
    try {
      return getAllDecors().firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
