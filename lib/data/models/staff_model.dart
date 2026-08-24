import 'package:flutter/material.dart';

enum StaffRole {
  washer,
  apprentice,
  salesman,
  masterMechanic,
  appraiser,
  marketer,
  legalAdvisor,
}

extension StaffRoleExtension on StaffRole {
  String get title => getLocalizedTitle('tr');

  String getLocalizedTitle([String lang = 'tr']) {
    switch (this) {
      case StaffRole.washer:
        return switch (lang) {
          'en' => 'Car Wash & Detailing Specialist',
          'de' => 'Fahrzeugaufbereitung-Spezialist',
          'pt' => 'Especialista em Detalhamento e Lavagem',
          'es' => 'Especialista en Lavado y Detallado',
          'ru' => 'Специалист по детейлингу и мойке',
          'ar' => 'أخصائي غسيل وتلميع السيارات',
          _ => 'Oto Yıkama & Detay Uzmanı',
        };
      case StaffRole.apprentice:
        return switch (lang) {
          'en' => 'Bodywork Apprentice',
          'de' => 'Karosseriebau-Lehrling',
          'pt' => 'Aprendiz de Funilaria',
          'es' => 'Aprendiz de Chapa y Pintura',
          'ru' => 'Ученик кузовщика',
          'ar' => 'مساعد سمكري',
          _ => 'Kaportacı Çırağı',
        };
      case StaffRole.salesman:
        return switch (lang) {
          'en' => 'Sales Consultant',
          'de' => 'Verkaufsberater',
          'pt' => 'Consultor de Vendas',
          'es' => 'Asesor Comercial',
          'ru' => 'Консультант по продажам',
          'ar' => 'مستشار مبيعات',
          _ => 'Satış Danışmanı',
        };
      case StaffRole.masterMechanic:
        return switch (lang) {
          'en' => 'Master Mechanic',
          'de' => 'Kfz-Meister',
          'pt' => 'Mecânico Chefe',
          'es' => 'Jefe de Taller Mecánico',
          'ru' => 'Мастер-механик',
          'ar' => 'كبير الميكانيكيين',
          _ => 'Mekanik Usta',
        };
      case StaffRole.appraiser:
        return switch (lang) {
          'en' => 'Car Inspector & Valuation Expert',
          'de' => 'Gutachter & Fahrzeugprüfer',
          'pt' => 'Avaliador e Perito Automotivo',
          'es' => 'Tasador e Inspector de Vehículos',
          'ru' => 'Эксперт-оценщик и автоэксперт',
          'ar' => 'خبير الفحص والتقييم',
          _ => 'Ekspertiz & Değerleme Uzmanı',
        };
      case StaffRole.marketer:
        return switch (lang) {
          'en' => 'Digital Marketer & Listing Manager',
          'de' => 'Marketing- & Inserate-Manager',
          'pt' => 'Gestor de Marketing e Anúncios',
          'es' => 'Gestor de Marketing y Anuncios',
          'ru' => 'Маркетолог и менеджер объявлений',
          'ar' => 'مسؤول التسويق والإعلانات',
          _ => 'Dijital Pazarlamacı & İlan Yöneticisi',
        };
      case StaffRole.legalAdvisor:
        return switch (lang) {
          'en' => 'Legal & Finance Advisor',
          'de' => 'Rechts- & Finanzberater',
          'pt' => 'Consultor Jurídico e Financeiro',
          'es' => 'Asesor Legal y Financiero',
          'ru' => 'Юрист и финансовый консультант',
          'ar' => 'المستشار القانوني والمالي',
          _ => 'Hukuk & Finans Danışmanı',
        };
    }
  }

  String get description => getLocalizedDescription('tr');

  String getLocalizedDescription([String lang = 'tr']) {
    switch (this) {
      case StaffRole.washer:
        return switch (lang) {
          'en' => 'Auto washes and polishes cars • Resale Value +7%',
          'de' => 'Wäscht und poliert Autos automatisch • Wiederverkaufswert +7%',
          'pt' => 'Lava e pole carros automaticamente • Valor de Revenda +7%',
          'es' => 'Lava y pule coches automáticamente • Valor de Reventa +7%',
          'ru' => 'Автоматически моет и полирует авто • Стоимость перепродажи +7%',
          'ar' => 'غسيل وتلميع تلقائي للسيارات • قيمة إعادة البيع +7%',
          _ => 'Araçları otomatik yıkar ve parlatır • Resale Değeri +%7',
        };
      case StaffRole.apprentice:
        return switch (lang) {
          'en' => 'Speeds up spare parts delivery and repair time by 30%',
          'de' => 'Beschleunigt Ersatzteillieferung und Reparaturdauer um 30%',
          'pt' => 'Acelera entrega de peças e reparos em 30%',
          'es' => 'Acelera la entrega de piezas y reparaciones un 30%',
          'ru' => 'Ускоряет доставку запчастей и ремонт на 30%',
          'ar' => 'يسرع شحن قطع الغيار والإصلاح بنسبة 30%',
          _ => 'Yedek parça kargo ve tamir sürelerini %30 hızlandırır',
        };
      case StaffRole.salesman:
        return switch (lang) {
          'en' => 'Allows securing 10% higher negotiation offers from customers',
          'de' => 'Ermöglicht 10% höhere Verhandlungsangebote von Kunden',
          'pt' => 'Garante ofertas de negociação 10% maiores dos clientes',
          'es' => 'Consigue ofertas de negociación un 10% más altas',
          'ru' => 'Позволяет получать предложения клиентов на 10% выгоднее',
          'ar' => 'يساعد في الحصول على عروض تفاوض أعلى بنسبة 10%',
          _ => 'Müşterilerden %10 daha yüksek pazarlık teklifi almanızı sağlar',
        };
      case StaffRole.masterMechanic:
        return switch (lang) {
          'en' => 'Reveals 100% of hidden defects on uninspected car purchases',
          'de' => 'Deckt 100% versteckter Mängel bei ungeprüften Käufen auf',
          'pt' => 'Revela 100% dos defeitos ocultos em compras sem vistoria',
          'es' => 'Descubre el 100% de defectos ocultos en compras sin peritaje',
          'ru' => 'Выявляет 100% скрытых дефектов при покупках без экспертизы',
          'ar' => 'يكشف 100% من العيوب الخفية عند الشراء بدون فحص',
          _ => 'Ekspertizsiz alımlarda gizli ayıpları %100 ortaya çıkarır',
        };
      case StaffRole.appraiser:
        return switch (lang) {
          'en' => 'Eliminates market value estimation error and shows net profit',
          'de' => 'Beseitigt Marktwert-Abweichungen und zeigt den Nettogewinn an',
          'pt' => 'Zera desvios de valor de mercado e exibe lucro líquido',
          'es' => 'Elimina el margen de error del valor de mercado y muestra beneficio neto',
          'ru' => 'Устраняет погрешность рыночной стоимости и показывает чистую прибыль',
          'ar' => 'يزيل خطأ تقدير قيمة السوق ويوضح صافي الربح بدقة',
          _ => 'Piyasa araçlarının gerçek değer sapmasını sıfırlar ve net kârı gösterir',
        };
      case StaffRole.marketer:
        return switch (lang) {
          'en' => 'Increases showroom customer visits and view speed by +50%',
          'de' => 'Steigert Kundenverkehr und Inserats-Klicks um +50%',
          'pt' => 'Aumenta atração de clientes e visualizações em +50%',
          'es' => 'Aumenta la afluencia de clientes y visitas al anuncio un +50%',
          'ru' => 'Увеличивает поток клиентов и просмотры объявлений на +50%',
          'ar' => 'يزيد سرعة جذب العملاء ومشاهدات المعرض بنسبة +50%',
          _ => 'Vitrin araçlarının müşteri çekme ve görüntülenme hızını +%50 artırır',
        };
      case StaffRole.legalAdvisor:
        return switch (lang) {
          'en' => 'Reduces daily corporate tax by 20% and accelerates collections',
          'de' => 'Senkt tägliche Körperschaftsteuer um 20% und beschleunigt Inkasso',
          'pt' => 'Reduz imposto corporativo diário em 20% e acelera cobranças',
          'es' => 'Reduce el impuesto corporativo diario un 20% y agiliza cobros',
          'ru' => 'Снижает ежедневный налог на прибыль на 20% и ускоряет взыскания',
          'ar' => 'يخفض ضريبة الشركات اليومية بنسبة 20% ويسرع التحصيل',
          _ => 'Günlük kurum vergisini %20 düşürür, icra ve tahsilat sürelerini hızlandırır',
        };
    }
  }

  double get dailySalary {
    switch (this) {
      case StaffRole.washer:
        return 1200;
      case StaffRole.apprentice:
        return 1800;
      case StaffRole.salesman:
        return 2500;
      case StaffRole.masterMechanic:
        return 3500;
      case StaffRole.appraiser:
        return 3000;
      case StaffRole.marketer:
        return 2200;
      case StaffRole.legalAdvisor:
        return 4000;
    }
  }

  double get hireFee => dailySalary * 3.5;

  /// Required feature route to hire this staff role
  String get requiredFeatureRoute {
    switch (this) {
      case StaffRole.washer:
        return '/car-wash';
      case StaffRole.apprentice:
      case StaffRole.masterMechanic:
        return '/workshop';
      case StaffRole.appraiser:
        return '/expertise';
      case StaffRole.salesman:
        return '/showroom';
      case StaffRole.marketer:
        return '/photography-studio';
      case StaffRole.legalAdvisor:
        return '/bank';
    }
  }

  /// Human-readable required facility name
  String get requiredFacilityName {
    switch (this) {
      case StaffRole.washer:
        return 'Oto Yıkama & Detailing İstasyonu';
      case StaffRole.apprentice:
      case StaffRole.masterMechanic:
        return 'Oto Tamir Atölyesi';
      case StaffRole.appraiser:
        return 'Kurumsal Ekspertiz İstasyonu';
      case StaffRole.salesman:
        return 'Galeri Vitrini';
      case StaffRole.marketer:
        return 'Fotoğraf & İlan Stüdyosu';
      case StaffRole.legalAdvisor:
        return 'Finans & Hukuk Ofisi';
    }
  }

  String get iconType {
    switch (this) {
      case StaffRole.washer:
        return 'car';
      case StaffRole.apprentice:
        return 'workshop';
      case StaffRole.salesman:
        return 'negotiation';
      case StaffRole.masterMechanic:
        return 'expertise';
      case StaffRole.appraiser:
        return 'search';
      case StaffRole.marketer:
        return 'campaign';
      case StaffRole.legalAdvisor:
        return 'gavel';
    }
  }
}

enum StaffPerk {
  thrifty,     // Maaş beklentisi %20 daha düşük
  hardWorker,  // Verimlilik %25 daha yüksek
  silverTongue,// Müşteri ikna başarısı +%15
  meticulous,  // İş hata payı sıfıra yakın
}

extension StaffPerkExtension on StaffPerk {
  String get title => getLocalizedTitle();

  String getLocalizedTitle([String? langCode]) {
    final lang = langCode ?? 'tr';
    switch (this) {
      case StaffPerk.thrifty:
        switch (lang) {
          case 'en': return 'Thrifty • -20% Salary';
          case 'de': return 'Sparsam • -20% Gehalt';
          case 'pt': return 'Econômico • -20% Salário';
          case 'es': return 'Económico • -20% Salario';
          case 'ru': return 'Экономный • -20% Зарплата';
          case 'ar': return 'مقتصد • -20% راتب';
          default: return 'Tutumlu • -%20 Maaş';
        }
      case StaffPerk.hardWorker:
        switch (lang) {
          case 'en': return 'Hard Worker • +25% Speed';
          case 'de': return 'Fleißig • +25% Tempo';
          case 'pt': return 'Trabalhador • +25% Velocidade';
          case 'es': return 'Trabajador • +25% Velocidad';
          case 'ru': return 'Трудолюбивый • +25% Скорость';
          case 'ar': return 'مجتهد • +25% سرعة';
          default: return 'Çalışkan • +%25 Hız';
        }
      case StaffPerk.silverTongue:
        switch (lang) {
          case 'en': return 'Silver Tongue • +15% Persuasion';
          case 'de': return 'Redegewandt • +15% Überzeugung';
          case 'pt': return 'Lávia • +15% Persuasão';
          case 'es': return 'Elocuente • +15% Persuasión';
          case 'ru': return 'Красноречивый • +15% Убеждение';
          case 'ar': return 'لبق الحديث • +15% إقناع';
          default: return 'Tatlı Dilli • +%15 İkna';
        }
      case StaffPerk.meticulous:
        switch (lang) {
          case 'en': return 'Meticulous • +15% Quality';
          case 'de': return 'Akribisch • +15% Qualität';
          case 'pt': return 'Meticuloso • +15% Qualidade';
          case 'es': return 'Meticuloso • +15% Calidad';
          case 'ru': return 'Педантичный • +15% Качество';
          case 'ar': return 'دقيق • +15% جودة';
          default: return 'Titiz Usta • +%15 Kalite';
        }
    }
  }

  IconData get vectorIcon {
    switch (this) {
      case StaffPerk.thrifty:
        return Icons.savings_rounded;
      case StaffPerk.hardWorker:
        return Icons.bolt_rounded;
      case StaffPerk.silverTongue:
        return Icons.record_voice_over_rounded;
      case StaffPerk.meticulous:
        return Icons.search_rounded;
    }
  }

  String get icon => '';
}

class TeamSynergy {
  final String id;
  final String title;
  final String description;
  final String icon;

  String getLocalizedTitle([String? langCode]) {
    final lang = langCode ?? 'tr';
    switch (id) {
      case 'synergy_sales_force':
        switch (lang) {
          case 'en': return 'Rapid Sales Force';
          case 'de': return 'Schnelle Verkaufskraft';
          case 'pt': return 'Força de Vendas Rápida';
          case 'es': return 'Fuerza de Ventas Rápida';
          case 'ru': return 'Быстрая команда продаж';
          case 'ar': return 'فريق مبيعات سريع';
          default: return title;
        }
      case 'synergy_full_workshop':
        switch (lang) {
          case 'en': return 'Full-Service Workshop';
          case 'de': return 'Voll ausgestattete Werkstatt';
          case 'pt': return 'Oficina Completa';
          case 'es': return 'Taller Integral';
          case 'ru': return 'Полнокомплектная мастерская';
          case 'ar': return 'ورشة عمل متكاملة';
          default: return title;
        }
      case 'synergy_legal_shield':
        switch (lang) {
          case 'en': return 'Corporate Financial & Legal Shield';
          case 'de': return 'Finanz- & Rechtsschutzschild';
          case 'pt': return 'Escudo Financeiro & Jurídico';
          case 'es': return 'Escudo Financiero y Legal';
          case 'ru': return 'Финансово-юридический щит';
          case 'ar': return 'درع مالي وقانوني';
          default: return title;
        }
      case 'synergy_corporate_culture':
      default:
        switch (lang) {
          case 'en': return 'Corporate Dealership Culture';
          case 'de': return 'Unternehmenskultur';
          case 'pt': return 'Cultura Corporativa';
          case 'es': return 'Cultura Corporativa';
          case 'ru': return 'Корпоративная культура';
          case 'ar': return 'ثقافة مؤسسية راقية';
          default: return title;
        }
    }
  }

  String getLocalizedDescription([String? langCode]) {
    final lang = langCode ?? 'tr';
    switch (id) {
      case 'synergy_sales_force':
        switch (lang) {
          case 'en': return 'Cars sell 25% faster thanks to marketing and sales coordination.';
          case 'de': return 'Fahrzeuge verkaufen sich dank Marketing- und Vertriebsabstimmung 25% schneller.';
          case 'pt': return 'Carros vendem 25% mais rápido graças à integração de vendas e marketing.';
          case 'es': return 'Los coches se venden un 25% más rápido gracias a la coordinación comercial.';
          case 'ru': return 'Автомобили продаются на 25% быстрее благодаря связке маркетинга и продаж.';
          case 'ar': return 'تباع السيارات بنسبة 25% أسرع بفضل التنسيق بين التسويق والمبيعات.';
          default: return description;
        }
      case 'synergy_full_workshop':
        switch (lang) {
          case 'en': return 'Repair and paint times accelerate by 40% with master-apprentice harmony.';
          case 'de': return 'Reparatur- und Lackierzeiten beschleunigen sich um 40% durch Meister-Lehrling-Synergie.';
          case 'pt': return 'Prazos de reparo e pintura aceleram 40% com a harmonia mestre-aprendiz.';
          case 'es': return 'Los tiempos de reparación y pintura se reducen un 40% con la coordinación del taller.';
          case 'ru': return 'Время ремонта и покраски ускоряется на 40% благодаря слаженной работе мастера и ученика.';
          case 'ar': return 'تسريع أوقات الإصلاح والدهان بنسبة 40% بفضل تناغم الأسطى والمتدرب.';
          default: return description;
        }
      case 'synergy_legal_shield':
        switch (lang) {
          case 'en': return 'Provides a 20% expense discount across commercial purchases and tax cycles.';
          case 'de': return 'Bietet 20% Kostenersparnis bei gewerblichen Ankäufen und Steuerzyklen.';
          case 'pt': return 'Gera 20% de redução de despesas em compras comerciais e impostos.';
          case 'es': return 'Otorga un 20% de descuento en gastos en compras comerciales e impuestos.';
          case 'ru': return 'Дает 20% скидку на расходы при коммерческих покупках и налогах.';
          case 'ar': return 'يوفر خصماً بنسبة 20% على المصاريف في المشتريات التجارية وفترات الضرائب.';
          default: return description;
        }
      case 'synergy_corporate_culture':
      default:
        switch (lang) {
          case 'en': return 'Maximizes dealership prestige and customer trust with a full squad.';
          case 'de': return 'Maximiert das Ansehen des Autohauses und das Kundenvertrauen mit einem starken Team.';
          case 'pt': return 'Eleva o prestígio da loja e a confiança dos clientes ao nível máximo.';
          case 'es': return 'Maximiza el prestigio del concesionario y la confianza del cliente.';
          case 'ru': return 'Максимизирует престиж автосалона и доверие клиентов благодаря полной команде.';
          case 'ar': return 'يرفع هيبة المعرض وثقة الزبائن إلى أعلى مستوى بفضل الطاقم المتكامل.';
          default: return description;
        }
    }
  }

  IconData get vectorIcon {
    switch (id) {
      case 'synergy_sales_force':
        return Icons.trending_up_rounded;
      case 'synergy_full_workshop':
        return Icons.build_circle_rounded;
      case 'synergy_legal_shield':
        return Icons.security_rounded;
      case 'synergy_corporate_culture':
      default:
        return Icons.business_rounded;
    }
  }

  const TeamSynergy({
    required this.id,
    required this.title,
    required this.description,
    this.icon = '',
  });
}

class TeamSynergyEngine {
  static List<TeamSynergy> calculateSynergies(List<StaffModel> staff) {
    final List<TeamSynergy> active = [];
    final roles = staff.map((s) => s.role).toSet();

    if (roles.contains(StaffRole.salesman) && roles.contains(StaffRole.marketer)) {
      active.add(const TeamSynergy(
        id: 'synergy_sales_force',
        title: 'Hızlı Satış Gücü',
        description: 'Pazarlama ve satış entegrasyonu sayesinde araçlar %25 daha hızlı satılır.',
      ));
    }

    if (roles.contains(StaffRole.masterMechanic) && roles.contains(StaffRole.apprentice)) {
      active.add(const TeamSynergy(
        id: 'synergy_full_workshop',
        title: 'Tam Teşekküllü Atölye',
        description: 'Usta-çırak uyumu ile parça tamir ve boya süreleri %40 hızlanır.',
      ));
    }

    if (roles.contains(StaffRole.legalAdvisor) && roles.contains(StaffRole.appraiser)) {
      active.add(const TeamSynergy(
        id: 'synergy_legal_shield',
        title: 'Kurumsal Finans & Hukuk Kalkanı',
        description: 'Tüm ticari alımlarda ve vergi dönemlerinde %20 gider indirimi sağlar.',
      ));
    }

    if (staff.length >= 4) {
      active.add(const TeamSynergy(
        id: 'synergy_corporate_culture',
        title: 'Kurumsal Bayi Kültürü',
        description: 'Geniş ekip sayesinde bayi prestij puanı ve müşteri güveni en üst seviyeye çıkar.',
      ));
    }

    return active;
  }
}

class StaffTrainingCourse {
  final String id;
  final StaffRole role;
  final String title;
  final String description;
  final String bonusSummary;
  final double cost;
  final IconData icon;
  final Color color;

  String getLocalizedTitle([String? langCode]) {
    final lang = langCode ?? 'tr';
    switch (id) {
      case 'train_washer_ceramic':
        switch (lang) {
          case 'en': return 'Ceramic Coating & Paint Shield';
          case 'de': return 'Keramikversiegelung & Lackschutz';
          case 'pt': return 'Vitrificação Cerâmica & Proteção';
          case 'es': return 'Sellado Cerámico y Protección';
          case 'ru': return 'Керамика и защита ЛКП';
          case 'ar': return 'نانو سيراميك وحماية الطلاء';
          default: return title;
        }
      case 'train_washer_interior_ozone':
        switch (lang) {
          case 'en': return 'VIP Ozone & Medical Interior Detailing';
          case 'de': return 'VIP-Ozon- & Innenraum-Meisterkurs';
          case 'pt': return 'Higienização com Ozônio VIP';
          case 'es': return 'Limpieza con Ozono VIP';
          case 'ru': return 'Озонирование и химчистка VIP';
          case 'ar': return 'تعقيم بالأوزون وتنظيف داخلي VIP';
          default: return title;
        }
      case 'train_appr_fast_dismantle':
        switch (lang) {
          case 'en': return 'Fast Disassembly & Tool Organization';
          case 'de': return 'Schnelle Demontage & Werkzeugordnung';
          case 'pt': return 'Desmontagem Rápida & Ferramentas';
          case 'es': return 'Desmontaje Rápido y Herramientas';
          case 'ru': return 'Быстрый разбор и порядок инструмента';
          case 'ar': return 'فك سريع وتنظيم الأدوات';
          default: return title;
        }
      case 'train_appr_pdr_sheet':
        switch (lang) {
          case 'en': return 'Paintless Dent Repair (PDR)';
          case 'de': return 'Dellenbeseitigung ohne Lackieren';
          case 'pt': return 'Martelinho de Ouro & Lixamento';
          case 'es': return 'Reparación de Abolladuras sin Pintar';
          case 'ru': return 'Удаление вмятин без покраски (PDR)';
          case 'ar': return 'تعديل الصدمات بدون دهان';
          default: return title;
        }
      case 'train_sales_persuasion':
        switch (lang) {
          case 'en': return 'Customer Persuasion & Closing Deals';
          case 'de': return 'Überzeugung & Verkaufsabschluss';
          case 'pt': return 'Persuasão & Fechamento de Vendas';
          case 'es': return 'Persuasión y Cierre de Ventas';
          case 'ru': return 'Искусство убеждения и закрытия сделок';
          case 'ar': return 'إقناع الزبائن وإتمام البيع';
          default: return title;
        }
      case 'train_sales_vip_portfolio':
        switch (lang) {
          case 'en': return 'VIP Collection & High-Net-Worth Portfolio';
          case 'de': return 'VIP-Sammlung & Premium-Kunden';
          case 'pt': return 'Gestão de Portfólio VIP & Luxo';
          case 'es': return 'Cartera de Clientes VIP y Lujo';
          case 'ru': return 'Управление VIP-портфелем и редкими авто';
          case 'ar': return 'إدارة مقتنيات VIP والزبائن المميزين';
          default: return title;
        }
      case 'train_mech_advanced_diag':
        switch (lang) {
          case 'en': return 'Advanced Engine & Transmission Diagnostics';
          case 'de': return 'Erweiterte Motor- & Getriebediagnose';
          case 'pt': return 'Diagnóstico Avançado de Motor & Câmbio';
          case 'es': return 'Diagnóstico Avanzado de Motor y Caja';
          case 'ru': return 'Глубокая диагностика ДВС и КПП';
          case 'ar': return 'فحص متقدم للمحرك وناقل الحركة';
          default: return title;
        }
      case 'train_mech_dyno_ecu':
        switch (lang) {
          case 'en': return 'Dyno & Stage Software Calibration';
          case 'de': return 'Dyno- & Leistungs-Kalibrierung';
          case 'pt': return 'Dinamômetro & Reprogramação de ECU';
          case 'es': return 'Banco de Potencia y Calibración ECU';
          case 'ru': return 'Диностенд и калибровка прошивок ECU';
          case 'ar': return 'داينو وبرمجة المحرك الاحترافية';
          default: return title;
        }
      case 'train_appr_micron_paint':
        switch (lang) {
          case 'en': return 'Micron Paint Gauge & Chassis Certification';
          case 'de': return 'Lackschicht- & Fahrgestellprüfung';
          case 'pt': return 'Medição Micrométrica & Laudo Estrutural';
          case 'es': return 'Medición de Micras y Certificación';
          case 'ru': return 'Толщиномер и сертификация геометрии кузова';
          case 'ar': return 'فحص سماكة الطلاء والشاسيه بالميكرون';
          default: return title;
        }
      case 'train_appr_market_arbitrage':
        switch (lang) {
          case 'en': return 'Damage History & Market Valuation';
          case 'de': return 'Schadenhistorie & Marktwertermittlung';
          case 'pt': return 'Análise de Sinistros & Valor de Mercado';
          case 'es': return 'Historial de Daños y Valoración';
          case 'ru': return 'Анализ истории ДТП и рыночной стоимости';
          case 'ar': return 'تحليل الحوادث وتقييم القيمة السوقية';
          default: return title;
        }
      case 'train_mkt_viral_ad':
        switch (lang) {
          case 'en': return 'Viral Listings & Social Media Creation';
          case 'de': return 'Virale Anzeigen & Social Media';
          case 'pt': return 'Anúncios Virais & Mídias Sociais';
          case 'es': return 'Anuncios Virales y Redes Sociales';
          case 'ru': return 'Вирусные объявления и соцсети';
          case 'ar': return 'إعلانات واسعة الانتشار وتسويق رقمي';
          default: return title;
        }
      case 'train_mkt_target_ads':
        switch (lang) {
          case 'en': return 'Targeted Ads & Showroom Footfall';
          case 'de': return 'Zielgerichtete Werbung & Kundenzulauf';
          case 'pt': return 'Tráfego Pago & Atração de Clientes';
          case 'es': return 'Publicidad Segmentada y Tráfico';
          case 'ru': return 'Таргетированная реклама и поток клиентов';
          case 'ar': return 'إعلانات مستهدفة وجذب زوار المعرض';
          default: return title;
        }
      case 'train_legal_tax_shield':
        switch (lang) {
          case 'en': return 'Tax Optimization & Expense Accounting';
          case 'de': return 'Steueroptimierung & Buchhaltung';
          case 'pt': return 'Otimização Fiscal & Contabilidade';
          case 'es': return 'Optimización Fiscal y Contabilidad';
          case 'ru': return 'Налоговая оптимизация и бухгалтерия';
          case 'ar': return 'تخفيض الضرائب ومحاسبة المصاريف';
          default: return title;
        }
      case 'train_legal_fast_factoring':
      default:
        switch (lang) {
          case 'en': return 'Legal Enforcement & Promissory Protection';
          case 'de': return 'Rechtsschutz & Factoring';
          case 'pt': return 'Cobrança Jurídica & Proteção de Títulos';
          case 'es': return 'Protección Legal y Cobro de Pagarés';
          case 'ru': return 'Юридическая защита и взыскание задолженностей';
          case 'ar': return 'تحصيل الشيكات والكمبيالات قانونياً';
          default: return title;
        }
    }
  }

  const StaffTrainingCourse({
    required this.id,
    required this.role,
    required this.title,
    required this.description,
    required this.bonusSummary,
    required this.cost,
    required this.icon,
    required this.color,
  });
}

class StaffRoleSpecializations {
  static const List<StaffTrainingCourse> allCourses = [
    // 1. Washer Courses
    StaffTrainingCourse(
      id: 'train_washer_ceramic',
      role: StaffRole.washer,
      title: 'Seramik Kaplama & İleri Boya Koruma',
      description: 'Detaylı temizlikte araçlara nano boya koruması uygular ve temizlik değer artışını güçlendirir.',
      bonusSummary: 'Yıkama Değer Katkısı +%3 • Hız +%20',
      cost: 6000,
      icon: Icons.auto_fix_high_rounded,
      color: Color(0xFF06B6D4),
    ),
    StaffTrainingCourse(
      id: 'train_washer_interior_ozone',
      role: StaffRole.washer,
      title: 'VIP Medikal Ozon & İç Kuaför Ustalığı',
      description: 'Koltuk ve tavan temizliğinde derinlemesine hijyen sağlayarak alıcı beğenisini artırır.',
      bonusSummary: 'İç Temizlik Bonusu +%4 • Moral +25',
      cost: 14000,
      icon: Icons.sanitizer_rounded,
      color: Color(0xFF3B82F6),
    ),

    // 2. Apprentice Courses
    StaffTrainingCourse(
      id: 'train_appr_fast_dismantle',
      role: StaffRole.apprentice,
      title: 'Hızlı Parça Söküm & Takım Düzeni',
      description: 'Hurdalık ve atölye parça söküm işlemlerini hızlandırır, takım kaybını sıfırlar.',
      bonusSummary: 'Parça Söküm Hızı +%35',
      cost: 5000,
      icon: Icons.handyman_rounded,
      color: Color(0xFFF59E0B),
    ),
    StaffTrainingCourse(
      id: 'train_appr_pdr_sheet',
      role: StaffRole.apprentice,
      title: 'Boyasız Göçük Düzeltme & Zımpara',
      description: 'Ustanın yanındaki destek verimliliğini artırarak kaporta tamir hata payını azaltır.',
      bonusSummary: 'Tamir Başarı Şansı +%20 • Hata -%50',
      cost: 12000,
      icon: Icons.hardware_rounded,
      color: Color(0xFFF97316),
    ),

    // 3. Salesman Courses
    StaffTrainingCourse(
      id: 'train_sales_persuasion',
      role: StaffRole.salesman,
      title: 'Müşteri İkna & Kapora Kapatma',
      description: 'Pazarlık masasında alıcıların ölücü tekliflerini kırar ve karlı satış olasılığını yükseltir.',
      bonusSummary: 'Alıcı Teklif Kabul +%15 • İkna +%20',
      cost: 10000,
      icon: Icons.record_voice_over_rounded,
      color: Color(0xFFEAB308),
    ),
    StaffTrainingCourse(
      id: 'train_sales_vip_portfolio',
      role: StaffRole.salesman,
      title: 'VIP Koleksiyon & Zengin Portföy Yönetimi',
      description: 'Nadir ve lüks araçlar için zengin koleksiyoner alıcıları vitrine daha sık çeker.',
      bonusSummary: 'Lüks Araç Satış Hızı +%35 • Prestij +15',
      cost: 24000,
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFA855F7),
    ),

    // 4. Master Mechanic Courses
    StaffTrainingCourse(
      id: 'train_mech_advanced_diag',
      role: StaffRole.masterMechanic,
      title: 'Motor & Şanzıman İleri Teşhis Uzmanlığı',
      description: 'Ekspertizsiz kelepir alımlarda gizli motor arızalarını %100 oranında tespit eder.',
      bonusSummary: 'Gizli Ayıp Tespiti %100 • Tamir Maliyeti -%20',
      cost: 18000,
      icon: Icons.build_circle_rounded,
      color: Color(0xFFEF4444),
    ),
    StaffTrainingCourse(
      id: 'train_mech_dyno_ecu',
      role: StaffRole.masterMechanic,
      title: 'Dyno & Stage Yazılım Kalibrasyonu',
      description: 'Performans yazılımlarını ve motor rektifiye işlemlerini en yüksek tork verimiyle tamamlar.',
      bonusSummary: 'Tuning Başarı Oranı +%30 • Motor Gücü +%10',
      cost: 35000,
      icon: Icons.speed_rounded,
      color: Color(0xFFDC2626),
    ),

    // 5. Appraiser Courses
    StaffTrainingCourse(
      id: 'train_appr_micron_paint',
      role: StaffRole.appraiser,
      title: 'Mikron Boya & Şasi Teşhis Sertifikası',
      description: 'Lokal boya ve değişen parçaları anında tarayarak ekspertiz raporlama süresini yarıya indirir.',
      bonusSummary: 'Ekspertiz Hızı x2 • Doğruluk %100',
      cost: 15000,
      icon: Icons.fact_check_rounded,
      color: Color(0xFF10B981),
    ),
    StaffTrainingCourse(
      id: 'train_appr_market_arbitrage',
      role: StaffRole.appraiser,
      title: 'Tramer & Piyasa Değerleme Analizi',
      description: 'Piyasadaki kelepir araç fırsatlarını algılar ve anlık tahmini kâr marjını net gösterir.',
      bonusSummary: 'Fırsat İlan Tespiti +%40 • Net Kâr Analizi',
      cost: 28000,
      icon: Icons.query_stats_rounded,
      color: Color(0xFF059669),
    ),

    // 6. Marketer Courses
    StaffTrainingCourse(
      id: 'train_mkt_viral_ad',
      role: StaffRole.marketer,
      title: 'Viral İlan & Sosyal Medya Tasarımı',
      description: 'İlan fotoğraflarını ve başlıklarını ilgi çekici kılarak vitrin görüntülenmesini katlar.',
      bonusSummary: 'Vitrin İlan Görüntülenme +%60',
      cost: 8000,
      icon: Icons.campaign_rounded,
      color: Color(0xFFEC4899),
    ),
    StaffTrainingCourse(
      id: 'train_mkt_target_ads',
      role: StaffRole.marketer,
      title: 'Bölgesel Reklam & Müşteri Trafiği',
      description: 'Galeriye fiziksel ve sanal alıcı trafiği çekerek araçların bekleme süresini azaltır.',
      bonusSummary: 'Alıcı Teklif Gelme Hızı +%50',
      cost: 20000,
      icon: Icons.trending_up_rounded,
      color: Color(0xFFDB2777),
    ),

    // 7. Legal Advisor Courses
    StaffTrainingCourse(
      id: 'train_legal_tax_shield',
      role: StaffRole.legalAdvisor,
      title: 'Vergi İndirimi & Gider Muhasebesi',
      description: 'Resmi şirket giderlerini ve bayi vergi kesintilerini yasal indirimlerle düşürür.',
      bonusSummary: 'Günlük Vergi Kesintisi -%25',
      cost: 16000,
      icon: Icons.shield_rounded,
      color: Color(0xFF6366F1),
    ),
    StaffTrainingCourse(
      id: 'train_legal_fast_factoring',
      role: StaffRole.legalAdvisor,
      title: 'Çek & Senet İcra Tahsilat Kalkanı',
      description: 'Vadeli müşteri senetlerinin karşılıksız çıkma riskini engeller ve tahsilatı hızlandırır.',
      bonusSummary: 'Faktoring Komisyon İndirimi -%40',
      cost: 32000,
      icon: Icons.gavel_rounded,
      color: Color(0xFF4F46E5),
    ),
  ];

  static List<StaffTrainingCourse> coursesForRole(StaffRole role) {
    return allCourses.where((c) => c.role == role).toList();
  }
}

class StaffModel {
  final String id;
  final String name;
  final StaffRole role;
  final DateTime hiredAt;
  final double salaryMultiplier;
  final int tasksCompleted;
  final int masteryLevel;
  final String? specialization;
  final int morale; // 0 to 100
  final int loyaltyScore;
  final StaffPerk? perk;
  final double profitContributed;
  final List<String> completedCourseIds;

  StaffModel({
    required this.id,
    required this.name,
    required this.role,
    required this.hiredAt,
    this.salaryMultiplier = 1.0,
    this.tasksCompleted = 0,
    this.masteryLevel = 1,
    this.specialization,
    this.morale = 100,
    this.loyaltyScore = 100,
    this.perk,
    this.profitContributed = 0.0,
    this.completedCourseIds = const [],
  });

  /// Effective daily salary considering raises, perks, and multipliers
  double get dailySalary {
    double base = role.dailySalary * salaryMultiplier;
    if (perk == StaffPerk.thrifty) {
      base *= 0.85;
    }
    return base;
  }

  /// Speed bonus multiplier gained from experience & perks
  double get speedMultiplier {
    double bonus = 1.0 + (masteryLevel * 0.15);
    if (perk == StaffPerk.hardWorker) bonus += 0.20;
    if (morale > 80) bonus += 0.10;
    if (completedCourseIds.isNotEmpty) bonus += completedCourseIds.length * 0.10;
    return bonus;
  }

  /// Part cost discount from staff mastery
  double get costDiscountPercent => (masteryLevel - 1) * 0.05 + (completedCourseIds.length * 0.03);

  /// Mastery Title display
  String get masteryTitle {
    if (masteryLevel >= 3 || completedCourseIds.length >= 2) return 'Baş Usta';
    if (masteryLevel == 2 || completedCourseIds.isNotEmpty) return 'Kıdemli Usta';
    return role.title;
  }

  StaffModel copyWith({
    String? id,
    String? name,
    StaffRole? role,
    DateTime? hiredAt,
    double? salaryMultiplier,
    int? tasksCompleted,
    int? masteryLevel,
    String? specialization,
    int? morale,
    int? loyaltyScore,
    StaffPerk? perk,
    double? profitContributed,
    List<String>? completedCourseIds,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      hiredAt: hiredAt ?? this.hiredAt,
      salaryMultiplier: salaryMultiplier ?? this.salaryMultiplier,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      specialization: specialization ?? this.specialization,
      morale: morale ?? this.morale,
      loyaltyScore: loyaltyScore ?? this.loyaltyScore,
      perk: perk ?? this.perk,
      profitContributed: profitContributed ?? this.profitContributed,
      completedCourseIds: completedCourseIds ?? this.completedCourseIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'hiredAt': hiredAt.toIso8601String(),
      'salaryMultiplier': salaryMultiplier,
      'tasksCompleted': tasksCompleted,
      'masteryLevel': masteryLevel,
      'specialization': specialization,
      'morale': morale,
      'loyaltyScore': loyaltyScore,
      'perk': perk?.name,
      'profitContributed': profitContributed,
      'completedCourseIds': completedCourseIds,
    };
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: StaffRole.values.firstWhere((r) => r.name == json['role']),
      hiredAt: DateTime.parse(json['hiredAt'] as String),
      salaryMultiplier: (json['salaryMultiplier'] as num?)?.toDouble() ?? 1.0,
      tasksCompleted: json['tasksCompleted'] as int? ?? 0,
      masteryLevel: json['masteryLevel'] as int? ?? 1,
      specialization: json['specialization'] as String?,
      morale: json['morale'] as int? ?? 100,
      loyaltyScore: json['loyaltyScore'] as int? ?? 100,
      perk: json['perk'] != null ? StaffPerk.values.firstWhere((p) => p.name == json['perk'], orElse: () => StaffPerk.hardWorker) : null,
      profitContributed: (json['profitContributed'] as num?)?.toDouble() ?? 0.0,
      completedCourseIds: (json['completedCourseIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }
}
