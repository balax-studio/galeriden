import 'dart:math';
import '../../data/models/gossip_item_model.dart';

class GossipEngine {
  static final List<GossipItemModel Function(int inGameDay)> _gossipPool = [
    // 1. Çaycı Necati - SUV & Ticari
    (int day) => GossipItemModel(
      id: 'gossip_necati_suv_$day',
      sourceNpc: 'cayci_necati',
      sourceNpcName: 'Çaycı Necati',
      sourceAvatar: 'cayci',
      title: 'Çay Ocağı SUV Talebi',
      teaser: 'Müteahhitler masada harıl harıl 4x4 soruyor. Bir şeyler dönüyor.',
      content: 'Önümüzdeki günlerde SUV ve arazi araçlarında talep %30 artacak. Garaja çeken iyi kâr yazar.',
      cost: 2500.0,
      accuracy: 0.85,
      type: GossipType.marketTrend,
      targetSegment: 'SUV',
      inGameDay: day,
    ),
    // 2. Çaycı Necati - Sedan & Memur
    (int day) => GossipItemModel(
      id: 'gossip_necati_sedan_$day',
      sourceNpc: 'cayci_necati',
      sourceNpcName: 'Çaycı Necati',
      sourceAvatar: 'cayci',
      title: 'Kamu Tayin Dönemi Kulisleri',
      teaser: 'Memurlar bütçeyi toparlayıp C segmenti sedan aramaya başladı.',
      content: 'Dizel ve otomatik aile sedanlarına yoğun talep geliyor. Hızlı elden çıkarabileceğin temiz sedanları topla.',
      cost: 2200.0,
      accuracy: 0.80,
      type: GossipType.marketTrend,
      targetSegment: 'Sedan',
      inGameDay: day,
    ),
    // 3. Vlogger Berk - Klasik & Genç
    (int day) => GossipItemModel(
      id: 'gossip_berk_klasik_$day',
      sourceNpc: 'vlogger_berk',
      sourceNpcName: 'Vlogger Berk',
      sourceAvatar: 'vlogger',
      title: 'Sosyal Medya Klasik Furyası',
      teaser: 'Maslak tayfası 90lar arabalarını parlatıp video çekme yarışında.',
      content: 'Boğaziçi ve Nişantaşı alıcıları nostaljik sedan ve coupe araçlara yüksek teklif vermeye hazır.',
      cost: 8500.0,
      accuracy: 0.88,
      type: GossipType.rivalIntel,
      targetSegment: 'Klasik',
      inGameDay: day,
    ),
    // 4. Vlogger Berk - Spor & Hot Hatch
    (int day) => GossipItemModel(
      id: 'gossip_berk_spor_$day',
      sourceNpc: 'vlogger_berk',
      sourceNpcName: 'Vlogger Berk',
      sourceAvatar: 'vlogger',
      title: 'Pist Günü Hazırlığı',
      teaser: 'Genç tayfa yazılım atılmış hızlı hatchback avına çıktı.',
      content: 'Egzozlu, süspansiyonlu spor modellere gelen teklifler normal piyasa değerinin %20 üstüne çıkacak.',
      cost: 7500.0,
      accuracy: 0.82,
      type: GossipType.marketTrend,
      targetSegment: 'Spor',
      inGameDay: day,
    ),
    // 5. Çıkmacı İbo - Samanlık
    (int day) => GossipItemModel(
      id: 'gossip_ibo_garaj_$day',
      sourceNpc: 'cikmaci_ibo',
      sourceNpcName: 'Çıkmacı İbo',
      sourceAvatar: 'cikmaci',
      title: 'Terk Edilmiş Garaj İhbarı',
      teaser: 'Sanayinin arkasındaki depoda yıllardır yatan diri bir kasa buldum.',
      content: 'Sahibi acil nakit için kelepir fiyata devretmeye hazır. Restorasyonla iki katı kâr bırakır.',
      cost: 14000.0,
      accuracy: 0.95,
      type: GossipType.bargainTip,
      inGameDay: day,
    ),
    // 6. Çıkmacı İbo - Yedek Parça Durgunluğu
    (int day) => GossipItemModel(
      id: 'gossip_ibo_parca_$day',
      sourceNpc: 'cikmaci_ibo',
      sourceNpcName: 'Çıkmacı İbo',
      sourceAvatar: 'cikmaci',
      title: 'Hurda Girişi & Parça İndirimi',
      teaser: 'Liman gümrüğünden üç tır dolusu orijinal yedek parça indirdik.',
      content: 'Kaporta ve mekanik bakım masraflarında hurdalık indirimleri devreye girdi.',
      cost: 4000.0,
      accuracy: 0.90,
      type: GossipType.marketTrend,
      inGameDay: day,
    ),
    // 7. Usta Selim - Katran Basılmış Motorlar
    (int day) => GossipItemModel(
      id: 'gossip_selim_katran_$day',
      sourceNpc: 'usta_selim',
      sourceNpcName: 'Usta Selim',
      sourceAvatar: 'usta',
      title: 'Ustanın Röntgeni: Yağ Katkısı Hilesi',
      teaser: 'Piyasadaki bazı araçların motoruna kalın yağ basıp dumanı kesmişler.',
      content: 'İlandaki araçların şanzıman ve motor iç aşınmalarını açığa çıkarır, motor kitleme riskini önler.',
      cost: 5500.0,
      accuracy: 1.0,
      type: GossipType.hiddenDefect,
      inGameDay: day,
    ),
    // 8. Usta Selim - Şasi Düzeltme
    (int day) => GossipItemModel(
      id: 'gossip_selim_sasi_$day',
      sourceNpc: 'usta_selim',
      sourceNpcName: 'Usta Selim',
      sourceAvatar: 'usta',
      title: 'Podya ve Direk Uyarısı',
      teaser: 'Kaldırıma sert vurup şasisi gönyeden kaçmış iki araç pazarda geziyor.',
      content: 'Ekspertizde görünmeyen şasi kılcal çatlaklarını ve robotla çekilmiş podyaları doğrudan gösterir.',
      cost: 6000.0,
      accuracy: 1.0,
      type: GossipType.hiddenDefect,
      inGameDay: day,
    ),
    // 9. Noter Katibi Derya - Acil Haciz & Devir
    (int day) => GossipItemModel(
      id: 'gossip_derya_haciz_$day',
      sourceNpc: 'noter_derya',
      sourceNpcName: 'Noter Katibi Derya',
      sourceAvatar: 'noter_derya',
      title: 'Mesai Bitimi Borç Kapatma Satışı',
      teaser: 'Kredisi sıkışmış bir iş insanı bugün noter kapanmadan imza atmak istiyor.',
      content: 'Piyasa değerinin %25 altına bırakılacak temiz bir esnaf aracı pazara düşüyor.',
      cost: 9000.0,
      accuracy: 0.92,
      type: GossipType.bargainTip,
      inGameDay: day,
    ),
    // 10. Ekspertizci Kadir - Boya Mikron Hilesi
    (int day) => GossipItemModel(
      id: 'gossip_kadir_mikron_$day',
      sourceNpc: 'ekspertiz_kadir',
      sourceNpcName: 'Ekspertizci Kadir',
      sourceAvatar: 'ekspertiz_kadir',
      title: 'Vernik İnceltme Operasyonu',
      teaser: 'Tavanı macunlu aracı mikron boyayla orijinal göstermeye çalışanlar var.',
      content: 'İncelenen araçların boya kalınlık hilelerini ve orijinal parça değişimlerini sıfır hatayla raporlar.',
      cost: 4800.0,
      accuracy: 0.96,
      type: GossipType.hiddenDefect,
      inGameDay: day,
    ),
    // 11. Sigortacı Melih - Sel & Dolu Kayıtları
    (int day) => GossipItemModel(
      id: 'gossip_melih_kasko_$day',
      sourceNpc: 'sigortaci_melih',
      sourceNpcName: 'Sigortacı Melih',
      sourceAvatar: 'sigortaci_melih',
      title: 'Tramer Kaydı Şişirilmiş Dosyalar',
      teaser: 'Kaskodan para almak için tampon çiziğine ağır hasar yazdıran bir araç tespit ettik.',
      content: 'Şişirilmiş hasar kayıtlı fakat iskeleti tertemiz olan araçları kelepir fiyata kapatma fırsatı.',
      cost: 7000.0,
      accuracy: 0.90,
      type: GossipType.bargainTip,
      inGameDay: day,
    ),
    // 12. Taksici Şevket Dayı - Yakıt & LPG Trendi
    (int day) => GossipItemModel(
      id: 'gossip_sevket_lpg_$day',
      sourceNpc: 'taksici_sevket',
      sourceNpcName: 'Taksici Şevket Dayı',
      sourceAvatar: 'taksici_sevket',
      title: 'Durak Sohbeti: LPG ve Az Yakanlar',
      teaser: 'Akaryakıt zammı beklentisiyle herkes az yakan 1.3 ve 1.4 motorların peşine düştü.',
      content: 'Ekonomik şehir içi araçların el değiştirme hızı iki katına çıktı. Rafta bekletmeden satarsın.',
      cost: 3000.0,
      accuracy: 0.85,
      type: GossipType.marketTrend,
      targetSegment: 'Ekonomik',
      inGameDay: day,
    ),
    // 13. Gümrükçü Tarık - İcra & Tasfiye Partisi
    (int day) => GossipItemModel(
      id: 'gossip_tarik_tasfiye_$day',
      sourceNpc: 'gumrukcu_tarik',
      sourceNpcName: 'Gümrükçü Tarık',
      sourceAvatar: 'gumrukcu_tarik',
      title: 'Liman Sundurmasında Bekleyen İthal Araç',
      teaser: 'Vergisi ödenmeyip tasfiyeye kalan yabancı plakalı lüks bir sedan var.',
      content: 'İhale masasında piyasanın yarı fiyatına teklif verip kapatabileceğin özel bir parti.',
      cost: 16000.0,
      accuracy: 0.94,
      type: GossipType.rivalIntel,
      targetSegment: 'Lüks',
      inGameDay: day,
    ),
    // 14. Borsa Simsarı Vedat - Faiz & Kredi Esintisi
    (int day) => GossipItemModel(
      id: 'gossip_vedat_faiz_$day',
      sourceNpc: 'simsar_vedat',
      sourceNpcName: 'Borsa Simsarı Vedat',
      sourceAvatar: 'simsar_vedat',
      title: 'Taşıt Kredisi Faiz Dalgalanması',
      teaser: 'Bankalar taşıt kredi musluğunu kısıyor, nakit parası olan galip gelecek.',
      content: 'Piyasada nakit kral oldu. Alıcılar kredi yerine doğrudan nakit indirimi yapan galerilere akıyor.',
      cost: 11000.0,
      accuracy: 0.91,
      type: GossipType.marketTrend,
      inGameDay: day,
    ),
  ];

  /// Generates daily industry gossips available in the district (§4.6.3)
  static List<GossipItemModel> generateDailyGossips(int inGameDay) {
    // Select 4 varied gossips deterministically based on day seed
    final random = Random(inGameDay * 37 + 101);
    final indices = List<int>.generate(_gossipPool.length, (i) => i);
    indices.shuffle(random);

    final selected = indices.take(4).map((idx) => _gossipPool[idx](inGameDay)).toList();
    return selected;
  }
}
