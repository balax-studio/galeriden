import 'dart:math';

class ConstructionSiteEvent {
  final String id;
  final String title;
  final String description;
  final double costImpact;
  final int dayDelayImpact;
  final String iconKey;

  const ConstructionSiteEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.costImpact,
    this.dayDelayImpact = 0,
    required this.iconKey,
  });
}

class ConstructionNegativeEventsEngine {
  static final Random _random = Random();

  /// Rolls for a random construction site incident during stage progression
  static ConstructionSiteEvent? rollStageIncident({
    required int stageNumber,
    required double baseStageCost,
    double riskMultiplier = 1.0,
  }) {
    final roll = _random.nextDouble();
    // Base risk chance ~ 22%, scaled by subcontractor risk multiplier
    final triggerThreshold = 0.22 * riskMultiplier;

    if (roll > triggerThreshold) {
      return null;
    }

    final eventTemplates = [
      ConstructionSiteEvent(
        id: 'demir_cimento_zammi',
        title: 'İnşaat Demiri ve Hazır Betona Zam Geldi',
        description: 'Tedarikçi firma piyasa artışları nedeniyle malzeme birim fiyatlarına zam yansıttı.',
        costImpact: (baseStageCost * 0.15).roundToDouble(),
        dayDelayImpact: 0,
        iconKey: 'trending_up',
      ),
      ConstructionSiteEvent(
        id: 'taseron_grevi',
        title: 'Taşeron Ekibi İş Bıraktı • Yevmiye Anlaşmazlığı',
        description: 'Demir ustaları yevmiye artışı talep ederek şantiye çalışmasını geçici olarak durdurdu.',
        costImpact: (baseStageCost * 0.08).roundToDouble(),
        dayDelayImpact: 2,
        iconKey: 'people_outline',
      ),
      ConstructionSiteEvent(
        id: 'asiri_yagis_camur',
        title: 'Şiddetli Yağış & Zemin Çökmesi',
        description: 'Temel çukuru suyla doldu • Tahliye pompası çalıştırıldı ve şantiye güvenliği sağlandı.',
        costImpact: 12500.0,
        dayDelayImpact: 1,
        iconKey: 'water_damage',
      ),
      ConstructionSiteEvent(
        id: 'beton_mikseri_gecikmesi',
        title: 'Hazır Beton Mikseri Sevkiyat Gecikmesi',
        description: 'Trafik ve santral arızası nedeniyle transmikserler geç ulaştı • Ek kimyasal priz geciktirici kullanıldı.',
        costImpact: 8500.0,
        dayDelayImpact: 1,
        iconKey: 'local_shipping',
      ),
      ConstructionSiteEvent(
        id: 'is_guvenligi_denetimi',
        title: 'İş Güvenliği ve SGK Saha Teftişi',
        description: 'Müfettişler iskele ve yaşam hatlarını denetledi • Eksik emniyet ekipmanları için masraf yapıldı.',
        costImpact: 15000.0,
        dayDelayImpact: 0,
        iconKey: 'security',
      ),
      ConstructionSiteEvent(
        id: 'belediye_harc_guncellemesi',
        title: 'Belediye Altyapı Katılım Payı Revizyonu',
        description: 'Fen işleri müdürlüğü kanalizasyon ve asfalt katılım payında harç güncellemesine gitti.',
        costImpact: (baseStageCost * 0.10).roundToDouble(),
        dayDelayImpact: 0,
        iconKey: 'receipt_long',
      ),
    ];

    return eventTemplates[_random.nextInt(eventTemplates.length)];
  }
}
