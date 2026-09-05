class ConstructionStageData {
  final int stageNumber; // 1 to 9
  final String id;
  final String title;
  final String description;
  final double baseCostRatio;
  final int baseDurationDays;
  final String milestoneName;

  const ConstructionStageData({
    required this.stageNumber,
    required this.id,
    required this.title,
    required this.description,
    required this.baseCostRatio,
    required this.baseDurationDays,
    required this.milestoneName,
  });
}

class SubcontractorTier {
  final String id;
  final String name;
  final String subtitle;
  final double costMultiplier;
  final double qualityScore;
  final double incidentRisk;
  final String perkText;

  const SubcontractorTier({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.costMultiplier,
    required this.qualityScore,
    required this.incidentRisk,
    required this.perkText,
  });
}

class ConstructionStagesCatalog {
  static const List<SubcontractorTier> subcontractorTiers = [
    SubcontractorTier(
      id: 'ekonomik',
      name: 'Ekonomik Taşeron Ekibi',
      subtitle: 'Bütçe Dostu • Yüksek Risk',
      costMultiplier: 0.85,
      qualityScore: 0.70,
      incidentRisk: 0.28,
      perkText: 'Yüzde 15 maliyet tasarrufu • Şantiye aksama riski mevcut',
    ),
    SubcontractorTier(
      id: 'usta',
      name: 'Deneyimli Usta Kollektifi',
      subtitle: 'Standart Piyasa • Güvenilir',
      costMultiplier: 1.00,
      qualityScore: 0.90,
      incidentRisk: 0.10,
      perkText: 'Piyasa rayici • Zamanında teslimat ve istikrarlı işçilik',
    ),
    SubcontractorTier(
      id: 'elit',
      name: 'A Sınıfı Mühendislik Firması',
      subtitle: 'Premium Kalite • Sıfır Hata',
      costMultiplier: 1.25,
      qualityScore: 1.00,
      incidentRisk: 0.02,
      perkText: 'Garantili denetim • C35 betonarme ve kusursuz işçilik',
    ),
  ];

  static const List<ConstructionStageData> stages = [
    ConstructionStageData(
      stageNumber: 1,
      id: 'hafriyat_zemin',
      title: '1. Hafriyat & Zemin Güçlendirme',
      description: 'Ekskavatörlerle temel çukuru açılır, iksa ve fore kazık zemin güçlendirmesi yapılır.',
      baseCostRatio: 0.08,
      baseDurationDays: 4,
      milestoneName: 'Zemin Tesviyesi',
    ),
    ConstructionStageData(
      stageNumber: 2,
      id: 'temel_radye',
      title: '2. Radye Temel & Grobeton',
      description: 'Temel demir donatısı bağlanır, membran su yalıtımı ve radye jeneral beton dökülür.',
      baseCostRatio: 0.12,
      baseDurationDays: 4,
      milestoneName: 'Temel Betonu',
    ),
    ConstructionStageData(
      stageNumber: 3,
      id: 'kaba_yapi',
      title: '3. Kaba Yapı & Betonarme Karkas',
      description: 'Kolon, kiriş kalıpları çakılır ve kat kat C35 hazır beton ile karkas yükseltilir.',
      baseCostRatio: 0.20,
      baseDurationDays: 6,
      milestoneName: 'Karkas Tamamlandı',
    ),
    ConstructionStageData(
      stageNumber: 4,
      id: 'duvar_gazbeton',
      title: '4. Dış ve İç Duvar Örme',
      description: 'Gazbeton ve tuğla duvarlar örülerek bağımsız bölümlerin sınırları belirlenir.',
      baseCostRatio: 0.10,
      baseDurationDays: 4,
      milestoneName: 'Duvarlar Örüldü',
    ),
    ConstructionStageData(
      stageNumber: 5,
      id: 'cati_izolasyon',
      title: '5. Çatı Çeliği & Su Yalıtımı',
      description: 'Çatı konstrüksiyonu, kiremit kaplaması ve membran su izolasyonu çekilir.',
      baseCostRatio: 0.10,
      baseDurationDays: 4,
      milestoneName: 'Çatı Kapatıldı',
    ),
    ConstructionStageData(
      stageNumber: 6,
      id: 'tesisat_elektrik',
      title: '6. Elektrik & Sıhhi Tesisat',
      description: 'Temiz - pis su boruları döşenir, yangın ve trifaze elektrik kablolaması tamamlanır.',
      baseCostRatio: 0.10,
      baseDurationDays: 4,
      milestoneName: 'Tesisat Çekildi',
    ),
    ConstructionStageData(
      stageNumber: 7,
      id: 'siva_sap',
      title: '7. Alçı Sıva & Şap Betonu',
      description: 'Daire zeminlerine tesviye şapı atılır, iç duvarlara makineli alçı sıva çekilir.',
      baseCostRatio: 0.08,
      baseDurationDays: 3,
      milestoneName: 'Sıva ve Şap',
    ),
    ConstructionStageData(
      stageNumber: 8,
      id: 'ince_iscilik',
      title: '8. İnce İşçilik, Parke & Seramik',
      description: 'Laminat parke, banyo seramikleri, mutfak dolapları ve çelik kapılar monte edilir.',
      baseCostRatio: 0.12,
      baseDurationDays: 5,
      milestoneName: 'İnce İşler',
    ),
    ConstructionStageData(
      stageNumber: 9,
      id: 'peyzaj_iskan',
      title: '9. Asansör, Peyzaj & İskan Ruhsatı',
      description: 'Asansör yeşil etiket testi, çevre peyzajı ve belediye yapı kullanım izin belgesi alınır.',
      baseCostRatio: 0.10,
      baseDurationDays: 4,
      milestoneName: 'Anahtar Teslim',
    ),
  ];

  static ConstructionStageData getStage(int stageNumber) {
    if (stageNumber < 1) return stages.first;
    if (stageNumber > 9) return stages.last;
    return stages[stageNumber - 1];
  }
}
