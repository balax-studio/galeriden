import 'package:flutter/material.dart';

enum WashJobType {
  foamWash(name: 'Köpüklü Yıkama', baseDuration: 10, icon: Icons.local_car_wash_rounded),
  interiorSteam(name: 'Buharlı İç-Dış Temizlik', baseDuration: 20, icon: Icons.airline_seat_recline_extra_rounded),
  polishWax(name: 'Pasta Cila & Boya Koruma', baseDuration: 35, icon: Icons.auto_awesome_rounded),
  ceramicVip(name: 'VIP Nano Seramik Kaplama', baseDuration: 60, icon: Icons.diamond_rounded);

  final String name;
  final int baseDuration;
  final IconData icon;

  const WashJobType({
    required this.name,
    required this.baseDuration,
    required this.icon,
  });
}

class CustomerWashJob {
  final String id;
  final String customerName;
  final String vehicleName;
  final String customerStory;
  final WashJobType washType;
  final double paymentReward;
  final int masteryXp;
  final bool isVipCustomer;

  const CustomerWashJob({
    required this.id,
    required this.customerName,
    required this.vehicleName,
    required this.customerStory,
    required this.washType,
    required this.paymentReward,
    required this.masteryXp,
    this.isVipCustomer = false,
  });

  static List<CustomerWashJob> generateRandomJobs({int count = 4}) {
    final samplePool = [
      (
        customer: 'Taksici Salih Usta',
        vehicle: 'Fiat Egea Ticari Taksi',
        story: 'Vardiya değişimi var yeğenim, araba balçık içinde. Pırıl pırıl yap akşama işe çıkacağım.',
        type: WashJobType.foamWash,
        reward: 650.0,
        xp: 25,
        isVip: false,
      ),
      (
        customer: 'Avukat Meltem Hanım',
        vehicle: 'Mercedes C200 AMG',
        story: 'Adliyeye yetişeceğim, hafta sonu çocuklar arka koltuğa meyve suyu dökmüş. Detaylı buharlı yıkama şart.',
        type: WashJobType.interiorSteam,
        reward: 1800.0,
        xp: 45,
        isVip: false,
      ),
      (
        customer: 'Müteahhit Ekrem Bey',
        vehicle: 'Range Rover Vogue',
        story: 'Şantiyeden çıktım boyada çimento tozu var. Pasta cila çekip ayna gibi parlatın, akşam yemeğim var.',
        type: WashJobType.polishWax,
        reward: 4200.0,
        xp: 75,
        isVip: true,
      ),
      (
        customer: 'Koleksiyoner Caner Bey',
        vehicle: 'Porsche 911 Carrera 4S',
        story: 'Garajımda özel muhafaza edeceğim. Çift kat nano seramik kaplama ve elmas koruma istiyorum.',
        type: WashJobType.ceramicVip,
        reward: 9500.0,
        xp: 150,
        isVip: true,
      ),
      (
        customer: 'Kurye Kadir',
        vehicle: 'Renault Kangoo Express',
        story: 'Paket taşımaktan iç döşemeler toz toprak oldu. Hızlı bir iç-dış detay alayım usta.',
        type: WashJobType.interiorSteam,
        reward: 1400.0,
        xp: 35,
        isVip: false,
      ),
      (
        customer: 'Doktor Sinan Bey',
        vehicle: 'BMW 520d M Sport',
        story: 'Hastanenin otoparkında güneşten boyası matlaşmış. Canlı bir pasta cila ve cila koruma rica ediyorum.',
        type: WashJobType.polishWax,
        reward: 3800.0,
        xp: 65,
        isVip: false,
      ),
    ];

    samplePool.shuffle();
    return List.generate(count.clamp(1, samplePool.length), (i) {
      final sample = samplePool[i];
      return CustomerWashJob(
        id: 'wash_job_${DateTime.now().millisecondsSinceEpoch}_$i',
        customerName: sample.customer,
        vehicleName: sample.vehicle,
        customerStory: sample.story,
        washType: sample.type,
        paymentReward: sample.reward,
        masteryXp: sample.xp,
        isVipCustomer: sample.isVip,
      );
    });
  }
}

class CarScent {
  final String id;
  final String name;
  final String aromaType;
  final double cost;
  final String description;
  final String buyerAppealBuff;
  final Color badgeColor;
  final IconData icon;

  const CarScent({
    required this.id,
    required this.name,
    required this.aromaType,
    required this.cost,
    required this.description,
    required this.buyerAppealBuff,
    required this.badgeColor,
    required this.icon,
  });

  static const List<CarScent> availableScents = [
    CarScent(
      id: 'scent_melon',
      name: 'Nostaljik Kavun & Sakız',
      aromaType: 'Tatlı / Genç İşi',
      cost: 150.0,
      description: 'Eski sanayi nostaljisi! Genç alıcıların hemen dikkatini çeker.',
      buyerAppealBuff: '+%15 Genç Alıcı İlgisi',
      badgeColor: Color(0xFFFFDE59),
      icon: Icons.bubble_chart_rounded,
    ),
    CarScent(
      id: 'scent_pine',
      name: 'Uludağ Çam Ormanı',
      aromaType: 'Ferah / Aile Güveni',
      cost: 200.0,
      description: 'Ferah orman havası verir, aile babası müşterilerin pazarlık inadını kırar.',
      buyerAppealBuff: '-%15 Müşteri Pazarlık İnadı',
      badgeColor: Color(0xFF00E575),
      icon: Icons.park_rounded,
    ),
    CarScent(
      id: 'scent_amber',
      name: 'VIP Deri & Oryantal Amber',
      aromaType: 'Lüks / Ağırbaşlı',
      cost: 450.0,
      description: 'Lüks D/E segment araçlarda iç mekana ağırbaşlı bir zenginlik havası katar.',
      buyerAppealBuff: '+%20 Vitrin Prestij Primi',
      badgeColor: Color(0xFFA855F7),
      icon: Icons.workspace_premium_rounded,
    ),
    CarScent(
      id: 'scent_ocean',
      name: 'Ege Okyanus Esintisi',
      aromaType: 'Hafif / Kusursuz Temizlik',
      cost: 250.0,
      description: 'Araca yeni yıkanmış sıfır araba kokusu verir.',
      buyerAppealBuff: '+%10 Hızlı Satış Bonusu',
      badgeColor: Color(0xFF38BDF8),
      icon: Icons.waves_rounded,
    ),
  ];
}
