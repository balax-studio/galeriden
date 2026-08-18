class DetailingOption {
  final String id;
  final String title;
  final String description;
  final double cost;
  final String vectorIcon;
  final String badgeText;
  final double attractivenessBoost;
  final double valueBoostPercent;
  final bool isRisky;

  DetailingOption({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.vectorIcon,
    required this.badgeText,
    required this.attractivenessBoost,
    required this.valueBoostPercent,
    this.isRisky = false,
  });

  static List<DetailingOption> getAvailableOptions() {
    return [
      DetailingOption(
        id: 'det_1',
        title: 'Pasta Cila & Seramik Kaplama',
        description: 'Aracın boyasını ilk günkü parlaklığına kavuşturur. İlan çekiciliğini %30 artırır.',
        cost: 3500,
        vectorIcon: 'rare',
        badgeText: 'Seramik Kaplama',
        attractivenessBoost: 0.30,
        valueBoostPercent: 0.05,
      ),
      DetailingOption(
        id: 'det_2',
        title: 'Çelik Jant & Cam Filmi',
        description: 'Araca estetik bir görünüm katar. İlan değerini %8 artırır.',
        cost: 6000,
        vectorIcon: 'craftsman',
        badgeText: 'Çelik Jant',
        attractivenessBoost: 0.15,
        valueBoostPercent: 0.08,
      ),
      DetailingOption(
        id: 'det_3',
        title: 'Detaylı İç Kuaför & Temizlik',
        description: 'Koltuk ve döşemeleri sıfır gibi temizler. Müşteri ikna şansını +%20 artırır.',
        cost: 2000,
        vectorIcon: 'shield',
        badgeText: 'Detaylı Kuaför',
        attractivenessBoost: 0.20,
        valueBoostPercent: 0.03,
      ),
      DetailingOption(
        id: 'det_4',
        title: 'Motor Ses Dindirici Katkı • Riskli Makyaj',
        description: 'Geçici olarak duman ve sesi keser. Değeri %12 artırır ama %20 ihtimalle müşteri şikayet edebilir!',
        cost: 1500,
        vectorIcon: 'flash',
        badgeText: 'Şark Kurnazlığı',
        attractivenessBoost: 0.10,
        valueBoostPercent: 0.12,
        isRisky: true,
      ),
    ];
  }
}
