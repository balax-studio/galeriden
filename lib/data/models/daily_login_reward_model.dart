import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum LoginRewardType {
  money,
  reputation,
  vipAuctionPass,
  specialPlateVoucher,
  salvagedPartCrate,
  legendaryChassisCrate,
  tuningStageVoucher,
}

class DailyLoginRewardModel {
  final int dayNumber; // 1 to 28
  final int weekNumber; // 1 to 4
  final String title;
  final String description;
  final LoginRewardType type;
  final double moneyAmount;
  final int reputationAmount;
  final String? itemCode;
  final String? itemDisplayName;
  final bool isMilestone;

  const DailyLoginRewardModel({
    required this.dayNumber,
    required this.weekNumber,
    required this.title,
    required this.description,
    required this.type,
    this.moneyAmount = 0.0,
    this.reputationAmount = 0,
    this.itemCode,
    this.itemDisplayName,
    this.isMilestone = false,
  });

  IconData get icon {
    switch (type) {
      case LoginRewardType.money:
        return Icons.attach_money_rounded;
      case LoginRewardType.reputation:
        return Icons.star_rounded;
      case LoginRewardType.vipAuctionPass:
        return Icons.confirmation_number_rounded;
      case LoginRewardType.specialPlateVoucher:
        return Icons.badge_rounded;
      case LoginRewardType.salvagedPartCrate:
        return Icons.inventory_2_rounded;
      case LoginRewardType.legendaryChassisCrate:
        return Icons.stars_rounded;
      case LoginRewardType.tuningStageVoucher:
        return Icons.speed_rounded;
    }
  }

  Color get accentColor {
    if (isMilestone) {
      switch (weekNumber) {
        case 1:
          return AppColors.brutalBlue;
        case 2:
          return const Color(0xFFA855F7);
        case 3:
          return AppColors.brutalYellow;
        case 4:
          return AppColors.brutalGreen;
      }
    }
    return AppColors.brutalYellow;
  }

  static String getSeasonTitle(int cycleCount, {String langCode = 'tr'}) {
    final seasonIndex = cycleCount % 4;
    switch (langCode) {
      case 'en':
        switch (seasonIndex) {
          case 0:
            return 'SEASON 1 • SPRING MARKET & BAZAAR';
          case 1:
            return 'SEASON 2 • SUMMER TOURISM & EXPATS';
          case 2:
            return 'SEASON 3 • AUTUMN FLEET & HARVEST';
          case 3:
          default:
            return 'SEASON 4 • WINTER TYCOON & BIST';
        }
      case 'de':
        switch (seasonIndex) {
          case 0:
            return '1. SAISON • FRÜHLINGS-MARKT & BÖRSEN';
          case 1:
            return '2. SAISON • SOMMER-TOURISMUS & URLAUBER';
          case 2:
            return '3. SAISON • HERBST-WERKSTATT & ERNTE';
          case 3:
          default:
            return '4. SAISON • WINTER-AUTOHAUS-MAGNAT';
        }
      case 'pt':
        switch (seasonIndex) {
          case 0:
            return '1ª TEMPORADA • PRIMAVERA DO COMÉRCIO';
          case 1:
            return '2ª TEMPORADA • VERÃO & TURISMO';
          case 2:
            return '3ª TEMPORADA • OUTONO DE FROTAS & OFICINA';
          case 3:
          default:
            return '4ª TEMPORADA • INVERNO DOS MAGNATAS';
        }
      case 'es':
        switch (seasonIndex) {
          case 0:
            return '1ª TEMPORADA • PRIMAVERA DEL MERCADO';
          case 1:
            return '2ª TEMPORADA • VERANO Y TURISMO';
          case 2:
            return '3ª TEMPORADA • OTOÑO DE TALLER Y FLOTAS';
          case 3:
          default:
            return '4ª TEMPORADA • INVIERNO DE MAGNATES';
        }
      case 'ru':
        switch (seasonIndex) {
          case 0:
            return '1 СЕЗОН • ВЕСЕННИЙ АВТОРЫНОК';
          case 1:
            return '2 СЕЗОН • ЛЕТНИЙ ТУРИЗМ И ПРОКАТ';
          case 2:
            return '3 СЕЗОН • ОСЕННИЙ СЕРВИС И АВТОПАРКИ';
          case 3:
          default:
            return '4 СЕЗОН • ЗИМНИЙ АВТОМАГНАТ';
        }
      case 'ar':
        switch (seasonIndex) {
          case 0:
            return 'الموسم 1 • ربيع التجارة وسوق السيارات';
          case 1:
            return 'الموسم 2 • صيف السياحة والتأجير';
          case 2:
            return 'الموسم 3 • خريف الصيانة والأساطيل';
          case 3:
          default:
            return 'الموسم 4 • شتاء كبار التجار والبورصة';
        }
      case 'tr':
      default:
        switch (seasonIndex) {
          case 0:
            return '1. SEZON • İLKBAHAR ÇARŞI VE PAZAR';
          case 1:
            return '2. SEZON • YAZ GURBETÇİ VE TURİZM';
          case 2:
            return '3. SEZON • SONBAHAR SANAYİ VE HASAT';
          case 3:
          default:
            return '4. SEZON • KIŞ GALERİ AĞALIĞI VE BIST';
        }
    }
  }

  static String getSeasonDescription(int cycleCount, {String langCode = 'tr'}) {
    final seasonIndex = cycleCount % 4;
    switch (langCode) {
      case 'en':
        switch (seasonIndex) {
          case 0:
            return 'Market is moving • Daily starter cash and dealership reputation rewards';
          case 1:
            return 'Summer tourism boom • Rental fleet bonuses and foreign currency packages';
          case 2:
            return 'Industrial harvest • Scrapyard discovery and workshop repair vouchers';
          case 3:
          default:
            return 'Luxury dealership management • Stock market funds and holding perks';
        }
      case 'de':
        switch (seasonIndex) {
          case 0:
            return 'Markt belebt sich • Tägliche Geldprämien und Rufboni';
          case 1:
            return 'Sommertourismus-Boom • Mietflotten-Pakete und Währungsboni';
          case 2:
            return 'Industrie- und Werkstatt-Saison • Schrottplatz-Gutscheine';
          case 3:
          default:
            return 'Luxus-Autohaus-Führung • Aktienfonds und Holding-Vorteile';
        }
      case 'pt':
        switch (seasonIndex) {
          case 0:
            return 'Mercado aquecido • Recompensas diárias e bônus de reputação';
          case 1:
            return 'Pico do turismo de verão • Bônus de frotas e pacotes de câmbio';
          case 2:
            return 'Safra industrial • Vouchers de desmanche e revisão de oficina';
          case 3:
          default:
            return 'Gestão de concessionária de luxo • Fundos de ações e bônus VIP';
        }
      case 'es':
        switch (seasonIndex) {
          case 0:
            return 'El mercado se activa • Recompensas diarias y prestigio';
          case 1:
            return 'Auge del turismo estival • Bonos de flotas y divisas';
          case 2:
            return 'Cosecha industrial • Vales de desguace y revisión de taller';
          case 3:
          default:
            return 'Gestión de concesionario de lujo • Fondos bursátiles y ventajas VIP';
        }
      case 'ru':
        switch (seasonIndex) {
          case 0:
            return 'Рынок оживает • Ежедневные денежные награды и бонусы репутации';
          case 1:
            return 'Летний туристический сезон • Бонусы автопроката и валютные пакеты';
          case 2:
            return 'Осенний сезон • Ваучеры авторазборки и ремонта в сервисе';
          case 3:
          default:
            return 'Элитный автобизнес • Инвестиции в акции и холдинг-бонусы';
        }
      case 'ar':
        switch (seasonIndex) {
          case 0:
            return 'انتعاش السوق • مكافآت نقدية يومية وزيادة في السمعة التجارية';
          case 1:
            return 'موسم السياحة الصيفية • عروض تأجير الأساطيل وحزم العملات';
          case 2:
            return 'موسم الورش والصيانة • قسائم فحص التشليح وتعديل السيارات';
          case 3:
          default:
            return 'إدارة معارض النخبة • صناديق استثمار البورصة ومكافآت القابضة';
        }
      case 'tr':
      default:
        switch (seasonIndex) {
          case 0:
            return 'Piyasa hareketleniyor • Siftah nakitleri ve genel esnaf itibar hediyeleri';
          case 1:
            return 'Yaz turizmi ve gurbetçi akını • Kiralama filosu ve döviz destek paketleri';
          case 2:
            return 'Sanayi ve tarım hasadı • Hurdalık arama ve atölye revizyon kuponları';
          case 3:
          default:
            return 'Lüks galeri yönetimi • BIST yatırım fonu ve prestijli holding hediyeleri';
        }
    }
  }

  static List<DailyLoginRewardModel> getSeasonalCycle({int cycleCount = 0}) {
    final seasonIndex = cycleCount % 4;
    final List<DailyLoginRewardModel> list = [];
    final double cycleMultiplier = 1.0 + (cycleCount * 0.10); // Her döngüde +%10 ödül artışı

    for (int day = 1; day <= 28; day++) {
      final week = ((day - 1) ~/ 7) + 1;
      final isEndOfWeek = (day % 7 == 0);

      if (isEndOfWeek) {
        if (day == 7) {
          list.add(DailyLoginRewardModel(
            dayNumber: 7,
            weekNumber: 1,
            title: '1. HAFTA KAPANIS HEDIYESI',
            description: seasonIndex == 1
                ? '₺120.000 Nakit ve Gurbetçi Turizm Rent-a-Car Kuponu'
                : (seasonIndex == 2
                    ? '₺120.000 Nakit ve Hurdalık Çifte Arama Bileti'
                    : (seasonIndex == 3
                        ? '₺150.000 Nakit ve BIST Yatırımcı İlişkileri Fonu'
                        : '₺100.000 Nakit Siftah ve VIP Müzayede Katılım Bileti')),
            type: LoginRewardType.vipAuctionPass,
            moneyAmount: (100000.0 * cycleMultiplier).roundToDouble(),
            reputationAmount: 15,
            itemCode: 'vip_pass_s${seasonIndex}_w1',
            itemDisplayName: 'Haftalık VIP Fırsat Kartı',
            isMilestone: true,
          ));
        } else if (day == 14) {
          list.add(DailyLoginRewardModel(
            dayNumber: 14,
            weekNumber: 2,
            title: '2. HAFTA KAPANIS HEDIYESI',
            description: seasonIndex == 1
                ? '₺300.000 Nakit ve Döviz Bürosu Komisyonsuz İşlem Kuponu'
                : (seasonIndex == 2
                    ? '₺300.000 Nakit ve Atölye Parça İşçilik İndirimi'
                    : (seasonIndex == 3
                        ? '₺350.000 Nakit ve VIP Vitrin Doping Sertifikası'
                        : '₺250.000 Nakit ve Ücretsiz Özel Plaka Basım Kuponu')),
            type: LoginRewardType.specialPlateVoucher,
            moneyAmount: (250000.0 * cycleMultiplier).roundToDouble(),
            reputationAmount: 25,
            itemCode: 'special_voucher_s${seasonIndex}_w2',
            itemDisplayName: '2. Hafta Esnaf Beratı',
            isMilestone: true,
          ));
        } else if (day == 21) {
          list.add(DailyLoginRewardModel(
            dayNumber: 21,
            weekNumber: 3,
            title: '3. HAFTA KAPANIS HEDIYESI',
            description: seasonIndex == 1
                ? '₺600.000 Nakit ve Kiralama Filosu Genişletme Desteği'
                : (seasonIndex == 2
                    ? '₺600.000 Nakit ve Çıkma Performans Turbo Sandığı'
                    : (seasonIndex == 3
                        ? '₺700.000 Nakit ve Holding Genel Kurul Prestij Bonusu'
                        : '₺500.000 Nakit ve Efsane Çıkma Motor Sandığı')),
            type: LoginRewardType.salvagedPartCrate,
            moneyAmount: (500000.0 * cycleMultiplier).roundToDouble(),
            reputationAmount: 40,
            itemCode: 'part_crate_s${seasonIndex}_w3',
            itemDisplayName: '3. Hafta Usta Sandığı',
            isMilestone: true,
          ));
        } else {
          // Day 28: Grand Finale
          list.add(DailyLoginRewardModel(
            dayNumber: 28,
            weekNumber: 4,
            title: '28 GÜNLÜK SEZON TACI',
            description: seasonIndex == 1
                ? '₺2.000.000 Sezonluk Büyük İkramiye ve Lüks Turizm Filo Lisansı'
                : (seasonIndex == 2
                    ? '₺2.000.000 Sezonluk Büyük İkramiye ve Efsanevi Ralli Şasisi'
                    : (seasonIndex == 3
                        ? '₺2.500.000 Sezonluk Büyük İkramiye ve Holding Halka Arz Beratı'
                        : '₺1.500.000 Büyük Hibe ve Efsanevi Klasik Şasi Sandığı')),
            type: LoginRewardType.legendaryChassisCrate,
            moneyAmount: (1500000.0 * cycleMultiplier).roundToDouble(),
            reputationAmount: 100,
            itemCode: 'season_crown_s$seasonIndex',
            itemDisplayName: 'Aylık Sezon Tacı',
            isMilestone: true,
          ));
        }
      } else {
        // Daily progressive steps with seasonal bonuses
        final baseMoney = (25000.0 * week + (day % 7) * 5000.0) * cycleMultiplier;
        final baseRep = 2 * week;
        list.add(DailyLoginRewardModel(
          dayNumber: day,
          weekNumber: week,
          title: 'GÜN $day • ESNAF DESTEĞİ',
          description: 'Günlük düzenli galeri işletme desteği',
          type: (day % 3 == 0) ? LoginRewardType.reputation : LoginRewardType.money,
          moneyAmount: baseMoney.roundToDouble(),
          reputationAmount: baseRep,
        ));
      }
    }

    return list;
  }

  static List<DailyLoginRewardModel> get28DaysCycle() {
    return getSeasonalCycle(cycleCount: 0);
  }
}
