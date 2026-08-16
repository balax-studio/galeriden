import '../../data/models/gossip_item_model.dart';

class GossipEngine {

  /// Generates daily industry gossips available in the district (§4.6.3)
  static List<GossipItemModel> generateDailyGossips(int inGameDay) {
    return [
      GossipItemModel(
        id: 'gossip_necati_$inGameDay',
        sourceNpc: 'cayci_necati',
        sourceNpcName: 'Çaycı Necati',
        sourceAvatar: '☕',
        title: 'Çay Ocağında Konuşulan Piyasa Tüyosu',
        teaser: 'Müteahhitler ve esnaf harıl harıl SUV ve pikap soruyor usta. Bir şeyler dönüyor...',
        content: 'Haftaya SUV ve Ticari araç talebi %30 patlayacak! Önceden stoklayan köşeyi döner.',
        cost: 2000.0,
        accuracy: 0.80,
        type: GossipType.marketTrend,
        targetSegment: 'SUV',
        inGameDay: inGameDay,
      ),
      GossipItemModel(
        id: 'gossip_berk_$inGameDay',
        sourceNpc: 'vlogger_berk',
        sourceNpcName: 'Vlogger Berk',
        sourceAvatar: '📹',
        title: 'Plaza Rakiplerinin Gizli Hamlesi',
        teaser: 'Maslak Plaza galerileri gizli gizli klasik topluyor, hikâyesini çektim...',
        content: 'Boğaziçi Otomotiv önümüzdeki günlerde tüm klasik araçlara yüksek teklif verecek.',
        cost: 8000.0,
        accuracy: 0.85,
        type: GossipType.rivalIntel,
        targetSegment: 'Klasik',
        inGameDay: inGameDay,
      ),
      GossipItemModel(
        id: 'gossip_ibo_$inGameDay',
        sourceNpc: 'cikmaci_ibo',
        sourceNpcName: 'Çıkmacı İbo',
        sourceAvatar: '🔧',
        title: 'Gizli Samanlık / Garaj İhbarı',
        teaser: 'Köyde bir amcanın garajında unutulmuş bir canavar buldum, sana koordinatını vereyim...',
        content: 'Pazara acil satılık ve %35 kâr marjlı özel bir kelepir ilan düştü!',
        cost: 15000.0,
        accuracy: 0.95,
        type: GossipType.bargainTip,
        inGameDay: inGameDay,
      ),
      GossipItemModel(
        id: 'gossip_selim_$inGameDay',
        sourceNpc: 'usta_selim',
        sourceNpcName: 'Usta Selim',
        sourceAvatar: '👴',
        title: 'Ustanın Röntgeni (Gizli Kusur Tespiti)',
        teaser: 'Piyasadaki bazı araçların motoruna katkı maddesi basıp satıyorlar, dikkat et...',
        content: 'İlandaki araçların tüm gizli motor ve şanzıman kusurlarını doğrudan açığa çıkarır.',
        cost: 5000.0,
        accuracy: 1.0,
        type: GossipType.hiddenDefect,
        inGameDay: inGameDay,
      ),
    ];
  }
}
