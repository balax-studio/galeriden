import 'dart:math';
import '../../data/models/customer_model.dart';
import '../../data/models/offer_model.dart';

class NegotiationSuspenseEngine {
  static final Random _random = Random();

  /// Generates a 3-stage dynamic thinking suspense script for Buying (when player makes offer to car seller)
  static List<String> getBuyingSuspenseStages({
    required CustomerArchetype archetype,
    Random? rng,
  }) {
    final r = rng ?? _random;
    final stage1List = _buyingStage1Pool[archetype] ?? _buyingStage1Pool[CustomerArchetype.skepticalOfficial]!;
    final stage2List = _buyingStage2Pool[archetype] ?? _buyingStage2Pool[CustomerArchetype.skepticalOfficial]!;
    final stage3List = _buyingStage3Pool[archetype] ?? _buyingStage3Pool[CustomerArchetype.skepticalOfficial]!;

    return [
      stage1List[r.nextInt(stage1List.length)],
      stage2List[r.nextInt(stage2List.length)],
      stage3List[r.nextInt(stage3List.length)],
    ];
  }

  /// Generates a 3-stage dynamic thinking suspense script for Selling (when showroom buyer evaluates player counter-offer)
  static List<String> getSellingSuspenseStages({
    required CustomerArchetype archetype,
    OfferType? offerType,
    Random? rng,
  }) {
    final r = rng ?? _random;
    final stage1List = _sellingStage1Pool[archetype] ?? _sellingStage1Pool[CustomerArchetype.skepticalOfficial]!;
    final stage2List = _sellingStage2Pool[archetype] ?? _sellingStage2Pool[CustomerArchetype.skepticalOfficial]!;
    final stage3List = _sellingStage3Pool[archetype] ?? _sellingStage3Pool[CustomerArchetype.skepticalOfficial]!;

    return [
      stage1List[r.nextInt(stage1List.length)],
      stage2List[r.nextInt(stage2List.length)],
      stage3List[r.nextInt(stage3List.length)],
    ];
  }

  // ==========================================
  // BUYING SUSPENSE POOLS (Player buys from seller)
  // ==========================================

  static const Map<CustomerArchetype, List<String>> _buyingStage1Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Satıcı teklif rakamına bakıyor • Hesap makinesine sarıldı...',
      'Satıcı gözlüğünü düzeltti • Teklif rakamını dikkatle inceliyor...',
      'Satıcı servis faturalarını açtı • Yaptığı masrafları tek tek sayıyor...',
      'Satıcı ilandaki açıklamalarını gözden geçiriyor • Tereddütle başını kaldırdı...',
    ],
    CustomerArchetype.impatientYouth: [
      'Satıcı telefondaki bildirimine baktı • Fiyatı tartıyor...',
      'Satıcı sosyal medyada yeni alacağı arabanın fotoğraflarına bakıyor...',
      'Anahtarı parmağında çevirerek teklif rakamını hızla süzüyor...',
      'Teklifi görünce arkadaşına mesaj yazmaya başladı...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Satıcı kâr marjını hesaplıyor • Çayından bir yudum aldı...',
      'Cebindeki altın ve döviz kurunu kontrol edip teklifi süzüyor...',
      'Maliyeti kurtarıp kurtarmadığını zihninde hızla çeviriyor...',
      'Tespihini çekerek teklif rakamını dudak bükerek inceliyor...',
    ],
    CustomerArchetype.familyMan: [
      'Satıcı bütçesini gözden geçiriyor • Derin bir nefes aldı...',
      'Bagaj hacmini ve çocukların masraflarını düşünüyor...',
      'Kredi kartı ekstrelerini ve ev bütçesini kafasında topluyor...',
      'Arabanın aileye kattığı anıları hatırlayıp hüzünlendi...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _buyingStage2Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Emsal ilanları kontrol ediyor • Noter ve vergi harcını düşüyor...',
      'TÜVTÜRK muayene tarihini ve kasko bedelini sistemden teyit ediyor...',
      'Yetkili servisteki tanıdığı baş ustayı arayıp piyasa değerini danışıyor...',
      'Aracın bakım geçmişini düşünüp eline kalacak net tutarı hesaplıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Arkadaşına WhatsApp sesli mesaj attı • Aceleyle düşünüyor...',
      'Yeni alacağı jant ve ses sisteminin bütçesini hesaplıyor...',
      'Kapora vereceği diğer satıcıya yazıp süre istiyor...',
      'Hemen satıp yeni maceraya atılmanın heyecanını yaşıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Piyasa rayicini tartıyor • Net eline kalacak nakit parayı hesaplıyor...',
      'Sanayideki ortak esnaf arkadaşına göz işareti yaptı...',
      'Bu parayla yeni araba bağlayıp bağlayamayacağını düşünüyor...',
      'Kendi dükkanının aylık çevirme hızını ve nakit akışını tartıyor...',
    ],
    CustomerArchetype.familyMan: [
      'Eşiyle telefonda fısıldaşıyor • Evden onay bekliyor...',
      'Kurban bayramı ve tatil planı masraflarını hesaplıyor...',
      'Kayınpederine mesaj atıp fiyata onay verip vermediğini soruyor...',
      'Yeni alacakları geniş aile arabasının peşinatını düşünüyor...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _buyingStage3Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Kaşlarını çattı • Son kararını vermek üzere masaya eğildi...',
      'Evrak dosyasını yavaşça kapattı • Masadaki son tavrını belirliyor...',
      'Derin bir nefes alıp gözlüğünü masaya bıraktı • Kararını açıklıyor...',
      'Ciddi bir ifadeyle elini uzatmaya hazırlanıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Kafasını salladı • Kararını heyecanla açıklıyor...',
      'Telefonunu cebine attı • Hızlıca el sıkışmak için doğruldu...',
      'Gözleri parladı • Masadaki son sözünü söylüyor...',
      'Sabırsızca yerinde kıpırdandı • Sonuca varıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Gözlerini kıstı • Elini sertçe masaya koydu...',
      'Tespihini cebine koydu • Son kozunu oynamak üzere doğruldu...',
      'Bıyığını sıvazladı • Masadaki son esnaf kararını açıklıyor...',
      'Gülümseyerek arkasına yaslandı • Kararını masaya bırakıyor...',
    ],
    CustomerArchetype.familyMan: [
      'Tereddütle masaya eğildi • Son sözünü söylüyor...',
      'Çocukların geleceğini düşünüp tereddütle başını salladı...',
      'Gözlerini yumup son kez aile bütçesini tarttı • Kararını veriyor...',
      'Helalleşmek üzere elini uzatmaya hazırlanıyor...',
    ],
  };

  // ==========================================
  // SELLING SUSPENSE POOLS (Buyer purchasing from player's showroom)
  // ==========================================

  static const Map<CustomerArchetype, List<String>> _sellingStage1Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Alıcı karşı teklifi görünce duraksadı • Banka mobil uygulamasını açtı...',
      'Ekspertiz raporundaki boya ve değişen detaylarını tekrar inceliyor...',
      'Ruhsat ve muayene kayıtlarını titizlikle gözden geçiriyor...',
      'Galerinin kurumsal puanına ve esnaf geçmişine bakıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Alıcı arabanın duruşuna ve jantlarına bakıp heyecanlandı...',
      'Karşı teklif rakamını görünce hemen arkadaş grubuna danıştı...',
      'Aracın motor sesini ve hızlanmasını kafasında canlandırıyor...',
      'Sosyal medyada paylaşacağı ilk vitrin fotoğrafının planını yapıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Alıcı karşı teklifi duyunca bıyık altından gülümsedi • Kendi kârını hesaplıyor...',
      'İlan sitelerindeki emsal araç fiyatlarıyla galeri fiyatını kıyaslıyor...',
      'Arabanın üzerine pasta cila çekip ne kadara satacağını düşünüyor...',
      'Piyasadaki anlık likiditeyi ve araç talep hızını ölçüyor...',
    ],
    CustomerArchetype.familyMan: [
      'Alıcı arka koltuk mesafesini ve bagaj hacmini düşünüyor...',
      'Karşı teklifi görünce eşine baktı • Bütçeyi gözden geçiriyor...',
      'Arabanın yakıt tüketimini ve periyodik bakım masraflarını inceliyor...',
      'Güvenlik donanımlarını ve çocuk koltuğu bağlantılarını kontrol ediyor...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _sellingStage2Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Taşıt kredisi faiz oranlarını ve aylık taksit limitini hesaplıyor...',
      'Galerinin garanti ve servis taahhüdünü tartıyor...',
      'Noter masrafları ve kasko bedelini toplam bütçesine ekliyor...',
      'Kendi bankacısını arayıp limit artırımını teyit ediyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Maaş avansını ve kredi kartı limitini birleştirmeyi planlıyor...',
      'Arabayı bu akşam hemen teslim alıp alamayacağını düşünüyor...',
      'Benzin masrafını ve ilk hafta gezeceği rotaları hesaplıyor...',
      'Arkadaşından borç alıp bu farkı kapatmayı değerlendiriyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Aracı alıp hemen üzerine kâr koyarak satıp satamayacağını tartıyor...',
      'Kendi hazır müşterisini arayıp anında devir yapıp yapamayacağını yokluyor...',
      'Sanayideki boyacı arkadaşına parçaların masrafını soruyor...',
      'Nakit parasını bu araca bağlamanın fırsat maliyetini hesaplıyor...',
    ],
    CustomerArchetype.familyMan: [
      'Kasko ve sigorta masraflarını toplam maliyete ekliyor...',
      'Aile bütçesini sarsmadan bu rakamı ödeyip ödeyemeyeceğini hesaplıyor...',
      'Evin ihtiyaçlarını erteleyip bu aracı almanın mantıklı olup olmadığını tartışıyor...',
      'Kayınpederiyle telefonda son bir durum değerlendirmesi yapıyor...',
    ],
  };

  static const Map<CustomerArchetype, List<String>> _sellingStage3Pool = {
    CustomerArchetype.skepticalOfficial: [
      'Gözlüğünü taktı • Karşı teklife bütçesinin yetip yetmeyeceğine karar veriyor...',
      'Evrak çantasını açtı • Son cevabını vermek üzere masaya eğildi...',
      'Ciddi bir duruşla karşı teklife cevabını netleştiriyor...',
      'Son kez arabanın kaportasına bakıp kararını açıklıyor...',
    ],
    CustomerArchetype.impatientYouth: [
      'Anahtarı sabırsızlıkla bekleyerek son kararını açıklıyor...',
      'Gözleri parladı • Masadaki karşı teklife yanıtını veriyor...',
      'Heyecanla yerinden doğrulup elini uzatıyor...',
      'Hızlıca notere geçmek için sabırsızlanıyor...',
    ],
    CustomerArchetype.greedyFlipper: [
      'Elini cebine attı • Son pazarlık hamlesini netleştiriyor...',
      'Ciddi bir ifadeyle masaya doğru eğildi • Son sözü söylüyor...',
      'Gözlerini kısıp galeriye son teklifini tartıyor...',
      'Masadan kalkıp kalkmayacağını kafasında kesinleştiriyor...',
    ],
    CustomerArchetype.familyMan: [
      'Derin bir nefes aldı • Ailesi için son kararını veriyor...',
      'Masaya dönüp elini uzatmaya hazırlanıyor...',
      'Tereddütleri geride bırakıp son cevabını açıklıyor...',
      'Hayırlısı olsun diyerek masadaki net kararını veriyor...',
    ],
  };
}
