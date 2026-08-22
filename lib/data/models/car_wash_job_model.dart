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

  String getLocalizedName([String lang = 'tr']) {
    switch (this) {
      case WashJobType.foamWash:
        return switch (lang) {
          'en' => 'Foam Wash',
          'de' => 'Schaumwäsche',
          'pt' => 'Lavagem com Espuma',
          'es' => 'Lavado con Espuma',
          'ru' => 'Пенная мойка',
          'ar' => 'غسيل رغوي',
          _ => name,
        };
      case WashJobType.interiorSteam:
        return switch (lang) {
          'en' => 'Steam Interior & Exterior Cleaning',
          'de' => 'Dampf-Innen- & Außenreinigung',
          'pt' => 'Limpeza a Vapor Interna e Externa',
          'es' => 'Limpieza a Vapor Interior y Exterior',
          'ru' => 'Паровая химчистка салона и мойка',
          'ar' => 'تنظيف داخلي وخارجي بالبخار',
          _ => name,
        };
      case WashJobType.polishWax:
        return switch (lang) {
          'en' => 'Polishing Wax & Paint Protection',
          'de' => 'Politur & Lackschutz',
          'pt' => 'Polimento e Proteção de Pintura',
          'es' => 'Pulido y Protección de Pintura',
          'ru' => 'Полировка и защита ЛКП',
          'ar' => 'تلميع وحماية الطلاء',
          _ => name,
        };
      case WashJobType.ceramicVip:
        return switch (lang) {
          'en' => 'VIP Nano Ceramic Coating',
          'de' => 'VIP Nano-Keramikversiegelung',
          'pt' => 'Revestimento Cerâmico VIP',
          'es' => 'Recubrimiento Cerámico VIP',
          'ru' => 'VIP нано-керамическое покрытие',
          'ar' => 'طلاء نانو سيراميك VIP',
          _ => name,
        };
    }
  }
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

  String getLocalizedName([String lang = 'tr']) {
    switch (id) {
      case 'scent_melon':
        return switch (lang) {
          'en' => 'Nostalgic Melon & Bubblegum',
          'de' => 'Nostalgische Melone & Kaugummi',
          'pt' => 'Melão Nostálgico e Chiclete',
          'es' => 'Melón Nostálgico y Chicle',
          'ru' => 'Ностальгическая дыня и баблгам',
          'ar' => 'شمام نوستالجي وعلكة',
          _ => name,
        };
      case 'scent_pine':
        return switch (lang) {
          'en' => 'Pine Forest Breeze',
          'de' => 'Kiefernwald-Frische',
          'pt' => 'Brisa de Floresta de Pinho',
          'es' => 'Brisa de Bosque de Pinos',
          'ru' => 'Свежесть хвойного леса',
          'ar' => 'نسيم غابات الصنوبر',
          _ => name,
        };
      case 'scent_amber':
        return switch (lang) {
          'en' => 'VIP Leather & Oriental Amber',
          'de' => 'VIP-Leder & Orientalischer Bernstein',
          'pt' => 'Couro VIP e Âmbar Oriental',
          'es' => 'Cuero VIP y Ámbar Oriental',
          'ru' => 'VIP кожа и восточный янтарь',
          'ar' => 'جلد فاخر وعنبر شرقي VIP',
          _ => name,
        };
      case 'scent_ocean':
        return switch (lang) {
          'en' => 'Aegean Ocean Breeze',
          'de' => 'Ägäis-Ozeanbrise',
          'pt' => 'Brisa do Oceano Egeu',
          'es' => 'Brisa del Océano Egeo',
          'ru' => 'Эгейский морской бриз',
          'ar' => 'نسيم بحر إيجه',
          _ => name,
        };
      default:
        return name;
    }
  }

  String getLocalizedDescription([String lang = 'tr']) {
    switch (id) {
      case 'scent_melon':
        return switch (lang) {
          'en' => 'Nostalgic vibe! Catches the eye of young buyers immediately.',
          'de' => 'Nostalgisches Feeling! Zieht junge Käufer sofort an.',
          'pt' => 'Vibe nostálgica! Chama a atenção de compradores jovens.',
          'es' => '¡Vibra nostálgica! Atrae la atención de compradores jóvenes.',
          'ru' => 'Ностальгический вайб! Привлекает молодых покупателей.',
          'ar' => 'أجواء كلاسيكية مميزة تجذب المشترين الشباب فوراً.',
          _ => description,
        };
      case 'scent_pine':
        return switch (lang) {
          'en' => 'Fresh forest scent, softens negotiation resistance from family buyers.',
          'de' => 'Frischer Waldduft, bricht die Verhandlungssturheit von Familienkäufern.',
          'pt' => 'Aroma fresco de floresta, quebra a resistência de famílias.',
          'es' => 'Aroma fresco a bosque, ablanda la negociación con familias.',
          'ru' => 'Свежий лесной аромат, смягчает торг семейных покупателей.',
          'ar' => 'عطر الغابة المنعش يلين عناد التفاوض لدى العائلات.',
          _ => description,
        };
      case 'scent_amber':
        return switch (lang) {
          'en' => 'Adds a refined premium ambiance to luxury executive cars.',
          'de' => 'Verleiht Luxus- und Oberklasse-Fahrzeugen ein edles Ambiente.',
          'pt' => 'Adiciona uma atmosfera sofisticada e requintada a carros de luxo.',
          'es' => 'Añade una atmósfera elegante y refinada a coches de lujo.',
          'ru' => 'Придает премиальный статус и солидность люксовым авто.',
          'ar' => 'يضفي لمسة فخامة وهيبة على مقصورة السيارات الفاخرة.',
          _ => description,
        };
      case 'scent_ocean':
        return switch (lang) {
          'en' => 'Leaves a fresh new-car aroma throughout the cabin.',
          'de' => 'Verleiht dem Innenraum den Duft eines frisch gewaschenen Neuwagens.',
          'pt' => 'Deixa um aroma de carro novo recém-lavado por toda a cabine.',
          'es' => 'Deja un aroma a coche nuevo recién lavado en todo el habitáculo.',
          'ru' => 'Оставляет в салоне запах свежевымытого нового автомобиля.',
          'ar' => 'يمنح مقصورة السيارة رائحة الانتعاش كأنها جديدة تماماً.',
          _ => description,
        };
      default:
        return description;
    }
  }

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
